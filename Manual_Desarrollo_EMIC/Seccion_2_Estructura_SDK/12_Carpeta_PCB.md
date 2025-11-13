# Capítulo 12: Carpeta `_pcb/` - Configuración de Hardware (PCBs)

## Índice
1. [¿Qué es `_pcb/`?](#1-qué-es-_pcb)
2. [Estructura de una Configuración PCB](#2-estructura-de-una-configuración-pcb)
3. [Componentes de un Archivo PCB](#3-componentes-de-un-archivo-pcb)
4. [PCBs Disponibles en el SDK](#4-pcbs-disponibles-en-el-sdk)
5. [Ejemplos Reales de Configuraciones](#5-ejemplos-reales-de-configuraciones)
6. [Flujo de Mapeo de Pines](#6-flujo-de-mapeo-de-pines)
7. [Uso en generate.emic](#7-uso-en-generateemic)
8. [Reutilización de Módulos](#8-reutilización-de-módulos)
9. [Crear Nueva Configuración PCB](#9-crear-nueva-configuración-pcb)
10. [Buenas Prácticas](#10-buenas-prácticas)

---

## 1. ¿Qué es `_pcb/`?

La carpeta `_pcb/` contiene **configuraciones de hardware** que definen cómo se mapean los **pines físicos del microcontrolador** a **nombres lógicos** usados por el software. Esto permite **reutilizar el mismo código** en diferentes placas PCB.

### 1.1 Ubicación en la Arquitectura EMIC

```
┌─────────────────────────────────────────────────┐
│    Módulo EMIC (Software Genérico)              │
│    - LED.state(1)                               │
│    - UART.send("Hello")                         │
│    - Button.read()                              │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│    Configuración PCB (_pcb/)    ← ESTE NIVEL    │
│    - Led1 = RB5                                 │
│    - UART_TX = RB10                             │
│    - Button = RB14                              │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│    Hardware Físico (Placa PCB)                  │
│    - Pin 14 del IC → LED                        │
│    - Pin 21 del IC → UART TX                    │
│    - Pin 25 del IC → Botón                      │
└─────────────────────────────────────────────────┘
```

### 1.2 Problema que Resuelve

**Sin `_pcb/`:**
```c
// Código hardcodeado para una PCB específica
TRISB5 = 0;     // LED en RB5
LATB5 = 1;      // Encender LED
```

**Problema**: Si cambias de PCB y el LED está en RB7, debes modificar todo el código.

**Con `_pcb/`:**
```emic
// Código genérico
LED.state(1);   // Funciona en CUALQUIER PCB
```

**Solución**: La configuración PCB mapea automáticamente `LED` al pin correcto.

### 1.3 Responsabilidades de `_pcb/`

| Responsabilidad | Descripción |
|----------------|-------------|
| **Fuses del MCU** | Configuración de bits de configuración (#pragma config) |
| **Frecuencia del clock** | Definir FOSC y FCY |
| **Selección de MCU** | Especificar qué microcontrolador se usa |
| **Mapeo de pines** | Asignar nombres lógicos a pines físicos |
| **Configuraciones de periféricos** | Definir qué I2C/SPI/UART usar |
| **Nombre de la placa** | Identificador único de la PCB |

---

## 2. Estructura de una Configuración PCB

### 2.1 Organización de la Carpeta `_pcb/`

```
_pcb/
├── pcb.emic                  # Orquestador (copia el .h seleccionado)
└── inc/                      # Configuraciones de todas las PCBs
    ├── HRD_D-I4-I_V1.0.h           # PCB 1: Digital In/Out 4 canales
    ├── HRD_Development_Board.h     # PCB 2: Placa de desarrollo
    ├── HRD_USB_Relay V1.2.h        # PCB 3: Relés con USB
    ├── HRD_RFM96W.h                # PCB 4: LoRa RFM96
    ├── Lavarropas.h                # PCB 5: Control de lavarropas
    └── ... (27 PCBs en total)
```

### 2.2 Archivo Orquestador: `pcb.emic`

**Archivo: `_pcb/pcb.emic`**

```emic
EMIC:copy(inc/.{pcb}..h > TARGET:inc/.{pcb}..h)
```

**Explicación:**
- `.{pcb}.` es un **parámetro** que se pasa desde `generate.emic`
- Copia el archivo `.h` correspondiente a la carpeta `TARGET:inc/`

**Ejemplo de uso:**
```emic
// En generate.emic
EMIC:setInput(DEV:_pcb/pcb.emic, pcb=HRD_D-I4-I_V1.0)
```

Esto expande a:
```emic
EMIC:copy(inc/HRD_D-I4-I_V1.0.h > TARGET:inc/HRD_D-I4-I_V1.0.h)
```

---

## 3. Componentes de un Archivo PCB

Cada archivo `.h` de configuración PCB contiene **3 secciones principales**:

### 3.1 Sección 1: systemConfig.h (Fuses del MCU)

Define los **configuration bits** del microcontrolador:

```c
EMIC:setOutput(TARGET:inc/systemConfig.h)
// CONFIG2
#pragma config POSCMOD = NONE       // Primary Oscillator disabled
#pragma config I2C1SEL = PRI        // I2C1 default pins
#pragma config IOL1WAY = ON         // IOLOCK Protection
#pragma config OSCIOFNC = ON        // RA3 as I/O
#pragma config FCKSM = CSDCMD       // Clock switching disabled
#pragma config FNOSC = FRCPLL       // FRC Oscillator with PLL
#pragma config SOSCSEL = SOSC       // Secondary Oscillator
#pragma config WUTSEL = LEG         // Wake-up timer
#pragma config IESO = OFF           // Two-Speed Start-up disabled
// CONFIG1
#pragma config WDTPS = PS32768      // Watchdog Timer Postscaler 1:32768
#pragma config FWPSA = PR128        // WDT Prescaler 1:128
#pragma config WINDIS = OFF         // Windowed WDT disabled
#pragma config FWDTEN = OFF         // Watchdog Timer disabled
#pragma config ICS = PGx1           // EMUC1/EMUD1 shared with PGC1/PGD1
#pragma config GWRP = OFF           // Write protection disabled
#pragma config GCP = OFF            // Code protection disabled
#pragma config JTAGEN = OFF         // JTAG port disabled
EMIC:restoreOutput
```

**Propósito:**
- Configurar el oscilador (interno FRC con PLL)
- Deshabilitar watchdog timer (WDT)
- Configurar protección de código
- Habilitar/deshabilitar JTAG

---

### 3.2 Sección 2: system.h (Frecuencia del Clock)

Define la **frecuencia del sistema**:

```c
EMIC:setOutput(TARGET:inc/system.h)

#define FOSC 32000000      // 32 MHz (oscilador)
#define FCY (FOSC/2)       // 16 MHz (frecuencia de instrucción)

#include <xc.h>
EMIC:restoreOutput
```

**Propósito:**
- `FOSC`: Frecuencia del oscilador (usado para cálculos de timing)
- `FCY`: Frecuencia de ciclo de instrucción (usada por `__delay_ms()`, UART, etc.)

**Cálculo de FCY:**
- **PIC24/dsPIC33**: `FCY = FOSC / 2`
- **PIC32**: `FCY = PBCLK` (depende de divisores)

---

### 3.3 Sección 3: pins.h (Mapeo de Pines)

Define el **microcontrolador** y **mapea pines** a nombres lógicos:

```c
EMIC:setOutput(TARGET:inc/pins.h)

#include <xc.h>

// Define microcontroller type
EMIC:define(system.ucName, pic24FJ64GA002)

// I2C configuration
EMIC:define(system.i2c, 2)

// Digital inputs
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B6, name=DigIn1)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B8, name=DigIn2)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B12, name=DigIn3)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B14, name=DigIn4)

// LEDs
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B5, name=Led1)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B7, name=Led2)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B9, name=Led3)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B13, name=Led4)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B15, name=Led5)

// Board name definition
EMIC:define(system.boardName, HRD_D-I4-I_V1.0)
EMIC:restoreOutput
```

**Propósito:**
- `system.ucName`: Especifica qué carpeta de `_hard/` usar
- `system.i2c`: Indica qué módulo I2C usar (I2C1 o I2C2)
- `setPin.emic`: Mapea pines físicos (B5, B6, etc.) a nombres lógicos (Led1, DigIn1, etc.)
- `system.boardName`: Identificador único de la placa

---

## 4. PCBs Disponibles en el SDK

El SDK EMIC incluye **27 configuraciones de PCBs** diferentes:

### 4.1 Lista Completa de PCBs

| Categoría | Nombre de PCB | Descripción |
|-----------|--------------|-------------|
| **Digital I/O** | `HRD_D-I4-I_V1.0` | 4 entradas digitales + 5 LEDs |
| **Desarrollo** | `HRD_Development_Board` | Placa de desarrollo general (botones, LCD, NTC, RPM) |
| **Comunicación USB** | `HRD_USB_Relay V1.2` | 2 Relés controlados por USB (MCP2200) |
| | `HRD_USBSD` | USB con almacenamiento SD |
| | `HRD_USB V1.1` | Comunicación USB genérica |
| **Wireless** | `HRD_RFM96W` | Radio LoRa RFM96W (SPI) |
| | `HRD_BLUETOOTH_V1.0` | Módulo Bluetooth |
| | `HRD_WiFi5Click_V1.1` | WiFi ESP8266 |
| | `HRD_WIFI_CH376` | WiFi con chip CH376 |
| | `HRD_SIM800L_V2.0` | GSM/GPRS SIM800L |
| **Comunicación Industrial** | `HRD_MODBUS_RTU` | Modbus RTU (RS485) |
| | `HRD_RS232D_V1.0` | Comunicación RS232 |
| | `HRD_RS485_V1.0` | Comunicación RS485 |
| **IoT Industrial** | `HDR_CRACK_PIN_IOT_V2.1` | Monitoreo de grietas con IoT |
| | `HDR_CRACK_PIN_IOT_test` | Versión de prueba |
| **Control Industrial** | `Lavarropas` | Control de lavarropas V1 |
| | `Lavarropas_2` | Control de lavarropas V2 |
| | `HRD_Tecnocrom_Base` | Base Tecnocrom |
| | `HDR_PRINTER_DRIVER` | Driver de impresora |
| | `HDR_uC2Relay_V2.0` | Microcontrolador + 2 relés |
| **Sensores** | `HRD_Celda_V1` | Celda de carga / balanza |
| | `HRD_MedidorDeVelocidadDelSonido` | Medidor de velocidad del sonido |
| | `HRD_E-CRYS-B` | Sensor cristalográfico |
| | `HRD_E-CTR-B` | Controlador |
| **Energía** | `HRD_Ecometro V4` | Medidor de consumo eléctrico |
| **Otros** | `Dina_PCB_V2` | PCB personalizado Dina |
| | `DynaBase_PCB_V2.0` | Base dinámica |

> **Total**: 27 configuraciones de PCB en el SDK actual

---

## 5. Ejemplos Reales de Configuraciones

Veamos ejemplos completos de 3 PCBs con diferentes propósitos.

### 5.1 Ejemplo 1: HRD_D-I4-I_V1.0 (Digital In/Out Simple)

**Archivo: `_pcb/inc/HRD_D-I4-I_V1.0.h`**

```c
//--------------------------------[XC16]

// ========================================
// 1. systemConfig.h - Fuses del MCU
// ========================================
EMIC:setOutput(TARGET:inc/systemConfig.h)
#pragma config POSCMOD = NONE       // Primary Oscillator disabled
#pragma config I2C1SEL = PRI        // I2C1 default pins
#pragma config IOL1WAY = ON         // IOLOCK Protection
#pragma config OSCIOFNC = ON        // RA3 as I/O
#pragma config FCKSM = CSDCMD       // Clock switching disabled
#pragma config FNOSC = FRCPLL       // FRC Oscillator with PLL
#pragma config SOSCSEL = SOSC       // Secondary Oscillator
#pragma config WUTSEL = LEG         // Wake-up timer
#pragma config IESO = OFF           // Two-Speed Start-up disabled
#pragma config WDTPS = PS32768      // Watchdog Postscaler 1:32768
#pragma config FWPSA = PR128        // WDT Prescaler 1:128
#pragma config WINDIS = OFF         // Windowed WDT disabled
#pragma config FWDTEN = OFF         // Watchdog disabled
#pragma config ICS = PGx1           // Programming pins PGC1/PGD1
#pragma config GWRP = OFF           // Write protection disabled
#pragma config GCP = OFF            // Code protection disabled
#pragma config JTAGEN = OFF         // JTAG disabled
EMIC:restoreOutput

// ========================================
// 2. system.h - Frecuencia del clock
// ========================================
EMIC:setOutput(TARGET:inc/system.h)
#define FOSC 32000000      // 32 MHz
#define FCY (FOSC/2)       // 16 MHz

#include <xc.h>
EMIC:restoreOutput

// ========================================
// 3. pins.h - Mapeo de pines
// ========================================
EMIC:setOutput(TARGET:inc/pins.h)

// MCU: PIC24FJ64GA002
EMIC:define(system.ucName, pic24FJ64GA002)

// I2C: Usar I2C2
EMIC:define(system.i2c, 2)

// Digital inputs
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B6, name=DigIn1)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B8, name=DigIn2)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B12, name=DigIn3)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B14, name=DigIn4)

// LEDs
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B5, name=Led1)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B7, name=Led2)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B9, name=Led3)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B13, name=Led4)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B15, name=Led5)

// Board name
EMIC:define(system.boardName, HRD_D-I4-I_V1.0)
EMIC:restoreOutput
```

**Resumen:**
- **MCU**: PIC24FJ64GA002 @ 32 MHz
- **4 entradas digitales**: B6, B8, B12, B14
- **5 LEDs**: B5, B7, B9, B13, B15
- **I2C**: Módulo I2C2

---

### 5.2 Ejemplo 2: HRD_Development_Board (Placa Compleja)

**Archivo: `_pcb/inc/HRD_Development_Board.h`**

```c
EMIC:setOutput(TARGET:inc/systemConfig.h)
// ... (fuses similares a ejemplo anterior)
EMIC:restoreOutput

EMIC:setOutput(TARGET:inc/system.h)
#define FOSC 32000000
#define FCY (FOSC/2)
EMIC:restoreOutput

EMIC:setOutput(TARGET:inc/pins.h)

#include <xc.h>

EMIC:define(system.ucName, pic24FJ64GA002)
EMIC:define(system.i2c, 2)

// ========================================
// Top Pins - Switchs & Rotary Encoder
// ========================================
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B15, name=Buttons2)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B14, name=Buttons1)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B13, name=RotarySW)

// ========================================
// Top Pins - Sensors
// ========================================
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B12, name=NTC_PIN)  // Temperature (analog)

// ========================================
// Top Pins - LCD Display (SPI)
// ========================================
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B11, name=LCD_CLK)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B10, name=LCD_MOSI)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B9, name=LCD_RCLK)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B8, name=B8_Pin)    // General purpose
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B7, name=RPM_PIN)   // RPM sensor
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B6, name=LCD_MISO)

// ========================================
// Bottom Pins - Motor Control
// ========================================
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B5, name=TRIAC_GATE)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B4, name=ZC_IN)     // Zero cross

// ========================================
// Bottom Pins - Digital Inputs
// ========================================
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=A4, name=DIG_INPUT_2)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=A3, name=DIG_INPUT_4)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=A2, name=A2_Pin)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B3, name=B3_Pin)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B2, name=B2_Pin)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=A1, name=A1_Pin)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=A0, name=A0_Pin)

EMIC:restoreOutput
```

**Resumen:**
- **MCU**: PIC24FJ64GA002 @ 32 MHz
- **Botones**: 2 botones + 1 rotary encoder
- **Sensores**: NTC (temperatura), RPM
- **Display**: LCD con SPI (CLK, MOSI, MISO, RCLK)
- **Control de motor**: TRIAC + Zero Cross detection
- **Entradas digitales**: 7 pines disponibles

---

### 5.3 Ejemplo 3: HRD_RFM96W (LoRa Radio)

**Archivo: `_pcb/inc/HRD_RFM96W.h`**

```c
EMIC:setOutput(systemConfig.h)
// ... (fuses)
EMIC:restoreOutput

EMIC:setOutput(system.h)
#define FOSC 32000000
#define FCY (FOSC/2)

#include <xc.h>
#include <libpic30.h>

#define compiler "XC16"
EMIC:restoreOutput

EMIC:setOutput(pins.h)

// MCU: PIC24 (genérico)
EMIC:define(system.ucName, PIC24)
EMIC:define(system.i2c, 2)

// ========================================
// LEDs
// ========================================
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B5, name=Led1)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=A2, name=Led2)

// ========================================
// RFM96 DIO pins (interrupciones del radio)
// ========================================
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B10, name=RFM96_DIO0)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B12, name=RFM96_DIO1)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B14, name=RFM96_DIO2)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B6, name=RFM96_DIO3)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B8, name=RFM96_DIO4)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B4, name=RFM96_DIO5)

// ========================================
// RFM96 Control pins
// ========================================
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B7, name=RFXReset)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B14, name=RFM_WAKE_UP)

// ========================================
// SPI pins (comunicación con RFM96)
// ========================================
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B15, name=RFM_MISO)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B13, name=RFM_MOSI)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B11, name=RFM_CLK)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B9, name=RFM_CS)

// ========================================
// I2C pins
// ========================================
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B2, name=SDA_)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B3, name=SCL_)

// ========================================
// Programming pins
// ========================================
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B1, name=PGC)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B9, name=PGD)

#define USE_I2C2

#include "myId.h"

EMIC:define(system.boardName, HRD_RF_LORA)
EMIC:restoreOutput
```

**Resumen:**
- **MCU**: PIC24 (genérico)
- **Radio LoRa**: RFM96W con 6 pines DIO (interrupciones)
- **SPI**: MISO, MOSI, CLK, CS
- **Control**: Reset, Wake Up
- **I2C**: SDA, SCL
- **Programación**: PGC, PGD

---

## 6. Flujo de Mapeo de Pines

Entender cómo se mapean los pines es crucial para trabajar con `_pcb/`.

### 6.1 Diagrama de Flujo Completo

```
┌─────────────────────────────────────────────────────────┐
│  1. generate.emic del Módulo                           │
│  EMIC:setInput(DEV:_pcb/pcb.emic, pcb=HRD_D-I4-I_V1.0) │
└──────────────────┬──────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────────────┐
│  2. _pcb/pcb.emic                                       │
│  EMIC:copy(inc/.{pcb}..h > TARGET:inc/.{pcb}..h)       │
│  Expande a: inc/HRD_D-I4-I_V1.0.h                       │
└──────────────────┬──────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────────────┐
│  3. _pcb/inc/HRD_D-I4-I_V1.0.h                          │
│  EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B5,      │
│                 name=Led1)                              │
└──────────────────┬──────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────────────┐
│  4. _hal/pins/setPin.emic                               │
│  EMIC:setInput(DEV:_hard/.{system.ucName}./pins/       │
│                 setPin.{pin}..h, name=.{name}.)         │
│  Expande a:                                             │
│  DEV:_hard/pic24FJ64GA002/pins/setPinB5.h, name=Led1    │
└──────────────────┬──────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────────────┐
│  5. _hard/pic24FJ64GA002/pins/setPinB5.h                │
│  #define TRIS_.{name}.    _TRISB5                       │
│  #define PIN_.{name}.     _RB5                          │
│  #define LAT_.{name}.     _LATB5                        │
│  #define RPOUT_.{name}.   RPOR2bits.RP5R                │
│  ...                                                    │
│  Expande a (con name=Led1):                             │
│  #define TRIS_Led1    _TRISB5                           │
│  #define PIN_Led1     _RB5                              │
│  #define LAT_Led1     _LATB5                            │
└──────────────────┬──────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────────────┐
│  6. Código de API (led.c)                               │
│  HAL_GPIO_PinCfg(.{pin}., GPIO_OUTPUT);                 │
│  Expande a:                                             │
│  HAL_GPIO_PinCfg(Led1, GPIO_OUTPUT);                    │
└──────────────────┬──────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────────────┐
│  7. Macro HAL (_hard/pic24FJ64GA002/GPIO/gpio.h)        │
│  #define HAL_GPIO_PinCfg(name, cfg_value)               │
│          TRIS_##name = cfg_value                        │
│  Expande a:                                             │
│  TRIS_Led1 = GPIO_OUTPUT;                               │
└──────────────────┬──────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────────────┐
│  8. Código C final compilable                           │
│  _TRISB5 = 0;   // GPIO_OUTPUT = 0                      │
│                                                         │
│  → Configura el pin RB5 como salida digital            │
└─────────────────────────────────────────────────────────┘
```

### 6.2 Ejemplo Paso a Paso

**Paso 1**: Integrador usa LED en EMIC-Editor
```
LED.state(1);
```

**Paso 2**: API expande a
```c
LEDs_LED_state(1);
```

**Paso 3**: API llama HAL
```c
void LEDs_LED_state(uint8_t state)
{
    HAL_GPIO_PinSet(LED, state);  // .{pin}. = LED
}
```

**Paso 4**: HAL expande macro
```c
#define HAL_GPIO_PinSet(name, value) LAT_##name = value
// Expande a: LAT_LED = 1;
```

**Paso 5**: PCB define LAT_LED
```c
// Desde _hard/pic24FJ64GA002/pins/setPinB5.h
#define LAT_LED _LATB5
// Expande a: _LATB5 = 1;
```

**Paso 6**: Código C final
```c
_LATB5 = 1;  // Registro del PIC24FJ64GA002
```

**Resultado físico**: Pin 14 del IC (RB5) → 3.3V → LED enciende ✅

---

## 7. Uso en generate.emic

Cada módulo especifica qué PCB usar en su archivo `generate.emic`.

### 7.1 Sintaxis

```emic
EMIC:setInput(DEV:_pcb/pcb.emic, pcb=NOMBRE_DE_LA_PCB)
```

### 7.2 Ejemplo Completo de generate.emic

**Archivo: `_modules/Digital_In_Out/HRD_X4I-DIGITAL-I/System/generate.emic`**

```emic
EMIC:setOutput(TARGET:generate.txt)

    //-------------- Hardware Config ---------------------
    EMIC:setInput(DEV:_pcb/pcb.emic, pcb=HRD_D-I4-I_V1.0)
    // ↑ Selecciona la PCB "HRD_D-I4-I_V1.0"

    //------------------- Process EMIC-Generate files ----------------
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    //------------------- APIs -----------------------
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=Status, pin=Led1)
    // ↑ Usa el pin "Led1" (definido en la PCB como RB5)

    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=Led2, pin=Led2)
    // ↑ Usa el pin "Led2" (definido en la PCB como RB7)

    EMIC:setInput(DEV:_api/Inputs/Digital/Digital.emic)

    //-------------------- main  -----------------------
    EMIC:setInput(DEV:_main/baremetal/main.emic)

    //------------------- Copy user code ----------------
    EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
    EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)

    EMIC:define(c_modules.userFncFile, userFncFile)

    //------------------- Add project templates ----------------
    EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

**Resultado:**
- Se carga la configuración `HRD_D-I4-I_V1.0.h`
- `Led1` mapea a RB5
- `Led2` mapea a RB7
- `DigIn1` a `DigIn4` están disponibles

---

## 8. Reutilización de Módulos

La gran ventaja de `_pcb/` es la **reutilización** del mismo software en diferentes hardware.

### 8.1 Escenario: Mismo Módulo, Diferentes PCBs

Imagina que tienes un módulo "Controlador de LED" que quieres usar en 3 placas diferentes.

#### PCB 1: Development Board

```emic
// generate.emic para Development Board
EMIC:setInput(DEV:_pcb/pcb.emic, pcb=HRD_Development_Board)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=Status, pin=Led1)
```

**En HRD_Development_Board.h:**
```emic
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B5, name=Led1)
```

**Resultado**: `Status` → RB5

---

#### PCB 2: USB Relay Board

```emic
// generate.emic para USB Relay Board
EMIC:setInput(DEV:_pcb/pcb.emic, pcb=HRD_USB_Relay V1.2)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=Status, pin=Led1)
```

**En HRD_USB_Relay V1.2.h:**
```emic
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B6, name=Led1)
```

**Resultado**: `Status` → RB6 (diferente pin!)

---

#### PCB 3: LoRa Board

```emic
// generate.emic para LoRa Board
EMIC:setInput(DEV:_pcb/pcb.emic, pcb=HRD_RFM96W)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=Status, pin=Led1)
```

**En HRD_RFM96W.h:**
```emic
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B5, name=Led1)
```

**Resultado**: `Status` → B5

---

### 8.2 Ventajas de la Reutilización

| Sin `_pcb/` | Con `_pcb/` |
|------------|------------|
| Reescribir código para cada PCB | **1 código sirve para todas las PCBs** |
| Hardcodear pines (`_LATB5 = 1;`) | Usar nombres lógicos (`LED.state(1)`) |
| Difícil mantener múltiples versiones | Fácil agregar nuevas PCBs |
| Propenso a errores | Robusto y escalable |
| 100+ horas de trabajo | **5 minutos** (crear archivo .h) |

---

## 9. Crear Nueva Configuración PCB

Supongamos que diseñaste una nueva placa y quieres agregar su configuración al SDK.

### 9.1 Pasos para Crear una Nueva PCB

#### Paso 1: Crear archivo de configuración

**Nombre**: `_pcb/inc/MiPlaca_V1.0.h`

```c
//--------------------------------[XC16]

// ========================================
// 1. systemConfig.h - Fuses
// ========================================
EMIC:setOutput(TARGET:inc/systemConfig.h)
#pragma config POSCMOD = NONE
#pragma config I2C1SEL = PRI
#pragma config IOL1WAY = ON
#pragma config OSCIOFNC = ON
#pragma config FCKSM = CSDCMD
#pragma config FNOSC = FRCPLL
#pragma config SOSCSEL = SOSC
#pragma config WUTSEL = LEG
#pragma config IESO = OFF
#pragma config WDTPS = PS32768
#pragma config FWPSA = PR128
#pragma config WINDIS = OFF
#pragma config FWDTEN = OFF
#pragma config ICS = PGx1
#pragma config GWRP = OFF
#pragma config GCP = OFF
#pragma config JTAGEN = OFF
EMIC:restoreOutput

// ========================================
// 2. system.h - Frecuencia
// ========================================
EMIC:setOutput(TARGET:inc/system.h)
#define FOSC 32000000
#define FCY (FOSC/2)

#include <xc.h>
EMIC:restoreOutput

// ========================================
// 3. pins.h - Mapeo de pines
// ========================================
EMIC:setOutput(TARGET:inc/pins.h)

#include <xc.h>

// MCU: PIC24FJ64GA002
EMIC:define(system.ucName, pic24FJ64GA002)

// I2C: Usar I2C1
EMIC:define(system.i2c, 1)

// LEDs (según tu diseño PCB)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B4, name=Led_Status)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B5, name=Led_Error)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B6, name=Led_Comm)

// Botones
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B13, name=Button_Start)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B14, name=Button_Stop)

// Relés
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B8, name=Relay1)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B9, name=Relay2)

// Sensor de temperatura (ADC)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=A0, name=Temp_Sensor)

// UART (pines fijos en PIC24)
// TX2 = RP10 (RB10)
// RX2 = RP11 (RB11)

// SPI (para SD Card)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B15, name=SPI_MISO)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B13, name=SPI_MOSI)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B11, name=SPI_CLK)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B12, name=SD_CS)

// Board name
EMIC:define(system.boardName, MiPlaca_V1.0)
EMIC:restoreOutput
```

#### Paso 2: Usar en generate.emic

```emic
EMIC:setInput(DEV:_pcb/pcb.emic, pcb=MiPlaca_V1.0)
```

#### Paso 3: Compilar y probar

```bash
# Ejecutar EMIC-Generate
emic-generate generate.emic

# Compilar con MPLAB X
xc16-gcc -o firmware.hex ...
```

---

### 9.2 Checklist de Configuración PCB

✅ **Información del MCU:**
- [ ] `system.ucName` definido (ej: `pic24FJ64GA002`)
- [ ] `FOSC` y `FCY` correctos
- [ ] Fuses (#pragma config) configurados

✅ **Mapeo de pines:**
- [ ] Todos los LEDs mapeados
- [ ] Todos los botones mapeados
- [ ] Pines de comunicación (UART, SPI, I2C) mapeados
- [ ] Sensores/actuadores mapeados
- [ ] Pines de programación (PGC, PGD) no usados por otra función

✅ **Configuraciones especiales:**
- [ ] `system.i2c` definido (1 o 2)
- [ ] `system.boardName` único
- [ ] Includes adicionales si es necesario (ej: `myId.h`)

---

## 10. Buenas Prácticas

### 10.1 Nomenclatura de Pines

✅ **HACER:**
```emic
// Nombres descriptivos y claros
EMIC:setInput(..., pin=B5, name=Led_Status)
EMIC:setInput(..., pin=B6, name=Button_Start)
EMIC:setInput(..., pin=A0, name=Sensor_Temp)
```

❌ **EVITAR:**
```emic
// Nombres genéricos o confusos
EMIC:setInput(..., pin=B5, name=Pin1)
EMIC:setInput(..., pin=B6, name=X)
EMIC:setInput(..., pin=A0, name=Analog)
```

### 10.2 Organización de Archivos PCB

✅ **HACER:**
- Usar versionado en el nombre: `MiPlaca_V1.0.h`, `MiPlaca_V2.0.h`
- Agregar comentarios explicando secciones
- Agrupar pines por función (LEDs juntos, botones juntos, etc.)

❌ **EVITAR:**
- Nombres genéricos: `placa1.h`, `test.h`
- Sin comentarios
- Pines desordenados

### 10.3 Compatibilidad de MCU

Si usas múltiples MCUs, considera:

```emic
// Opción 1: MCU específico
EMIC:define(system.ucName, pic24FJ64GA002)

// Opción 2: Familia genérica (si el código es portable)
EMIC:define(system.ucName, PIC24)
```

**Cuándo usar cada uno:**
- `pic24FJ64GA002`: Si usas features específicas del chip (ej: número de pines)
- `PIC24`: Si el código funciona en cualquier PIC24

---

## Resumen

| Concepto | Descripción |
|----------|-------------|
| **_pcb/** | Carpeta con configuraciones de hardware (PCBs) |
| **pcb.emic** | Orquestador que carga el .h correspondiente |
| **inc/*.h** | Archivos de configuración de cada PCB |
| **3 Secciones** | systemConfig.h (fuses), system.h (clock), pins.h (mapeo) |
| **setPin.emic** | Mapea pines físicos a nombres lógicos |
| **27 PCBs** | SDK incluye 27 configuraciones predefinidas |
| **Reutilización** | Mismo código funciona en múltiples PCBs |
| **Portabilidad** | Cambiar PCB = cambiar 1 línea en generate.emic |

---

## Próximos Pasos

En el **Capítulo 13** exploraremos la carpeta **`_templates/`**, donde se encuentran las plantillas de proyectos para IDEs como MPLAB X, que facilitan la compilación del código generado.

---

**¿Preguntas?**
La carpeta `_pcb/` es la clave para la **portabilidad de hardware** en EMIC. Gracias a ella, puedes diseñar múltiples versiones de un producto sin reescribir una sola línea de código.
