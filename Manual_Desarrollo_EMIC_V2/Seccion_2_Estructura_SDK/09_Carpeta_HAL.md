# Capítulo 09: Carpeta `_hal/` - Hardware Abstraction Layer

[← Anterior: Carpeta _drivers](08_Carpeta_Drivers.md) | [Siguiente: Carpeta _hard →](10_Carpeta_Hard.md)

---

## 📋 Contenido del Capítulo

1. [¿Qué es el HAL en EMIC?](#1-qué-es-el-hal-en-emic)
2. [Propósito del HAL: Portabilidad](#2-propósito-del-hal-portabilidad)
3. [Arquitectura del HAL](#3-arquitectura-del-hal)
4. [Periféricos Disponibles](#4-periféricos-disponibles)
5. [Ejemplos de HAL Reales](#5-ejemplos-de-hal-reales)
6. [HAL vs Driver vs API](#6-hal-vs-driver-vs-api)
7. [Portabilidad entre MCUs](#7-portabilidad-entre-mcus)
8. [Creación de Nuevos HALs](#8-creación-de-nuevos-hals)

---

## 1. ¿Qué es el HAL en EMIC?

### 1.1 Definición Conceptual

El **HAL** (Hardware Abstraction Layer) es la **capa de abstracción de hardware** que oculta las diferencias entre familias de microcontroladores, proporcionando una interfaz unificada para acceder a periféricos internos del MCU.

```
┌────────────────────────────────────────────────────┐
│              HAL (Hardware Abstraction Layer)      │
│   Capa que Abstrae Periféricos Internos del MCU   │
└────────────────────────────────────────────────────┘
           │
    ┌──────┴──────┬──────────────┬──────────────┐
    │             │              │              │
ABSTRACCIÓN   PORTABILIDAD   UNIFORME       PERIFÉRICOS
    │             │              │           INTERNOS
Oculta        Mismo código    API            GPIO
diferencias   PIC/ARM/AVR   consistente      SPI
de registros                                  I2C
                                             UART
                                             Timer
                                             ADC
```

### 1.2 Características del HAL

✅ **Abstrae periféricos internos:** GPIO, SPI, I2C, UART, Timer, ADC, PWM
✅ **Oculta diferencias de MCU:** Mismo código funciona en PIC24, ARM Cortex-M, AVR
✅ **Interfaz consistente:** Mismos nombres de funciones
✅ **Delega a _hard:** El HAL NO implementa, solo redirige
✅ **Transparente:** El desarrollador usa HAL, no _hard directamente

### 1.3 Analogía del HAL

```
┌────────────────────────────────────────────────────┐
│  SIN HAL (código directo de registros):            │
│                                                    │
│  // PIC24                                          │
│  TRISAbits.TRISA0 = 0;  // Output                 │
│  LATAbits.LATA0 = 1;    // High                   │
│                                                    │
│  // ARM Cortex-M                                   │
│  GPIOA->MODER |= (1 << 0);  // Output             │
│  GPIOA->ODR |= (1 << 0);    // High               │
│                                                    │
│  // AVR                                            │
│  DDRA |= (1 << 0);      // Output                 │
│  PORTA |= (1 << 0);     // High                   │
└────────────────────────────────────────────────────┘
  ❌ Código diferente para cada MCU
  ❌ Difícil de portar
  ❌ Requiere conocer registros

┌────────────────────────────────────────────────────┐
│  CON HAL (abstracción):                            │
│                                                    │
│  // PIC24, ARM, AVR - MISMO CÓDIGO                │
│  HAL_GPIO_PinCfg(LED_PIN, GPIO_OUTPUT);           │
│  HAL_GPIO_PinSet(LED_PIN, GPIO_HIGH);             │
└────────────────────────────────────────────────────┘
  ✅ Mismo código para todos los MCUs
  ✅ Fácil portabilidad
  ✅ No requiere conocer registros
```

---

## 2. Propósito del HAL: Portabilidad

### 2.1 El Problema de la Portabilidad

```
┌─────────────────────────────────────────────────────┐
│          PROBLEMA: Cambiar de MCU                   │
└─────────────────────────────────────────────────────┘

Proyecto desarrollado para PIC24FJ64GA002

Cliente pide cambiar a PIC32 por más RAM

┌──────────────────────────────────────┐
│  SIN HAL:                            │
│  • Reescribir TODO el código         │
│  • Cambiar registros UART            │
│  • Cambiar registros SPI             │
│  • Cambiar registros GPIO            │
│  • Cambiar registros Timer           │
│  • Cambiar registros ADC             │
│  • 100+ horas de trabajo             │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  CON HAL:                            │
│  • Cambiar solo _hard/PIC32/         │
│  • APIs, Drivers, Módulos SIN CAMBIOS│
│  • 2-3 horas de trabajo              │
└──────────────────────────────────────┘
```

### 2.2 Beneficios del HAL

| Beneficio | Sin HAL | Con HAL |
|-----------|---------|---------|
| **Portabilidad** | ❌ Reescribir todo | ✅ Cambiar solo _hard |
| **Tiempo de portado** | 100+ horas | 2-3 horas |
| **Familias soportadas** | 1 (desarrollo específico) | Múltiples (PIC, ARM, AVR) |
| **Mantenimiento** | ❌ Código duplicado | ✅ Código único |
| **Curva de aprendizaje** | ❌ Aprender cada MCU | ✅ Aprender HAL una vez |
| **Errores de portado** | ❌ Muchos | ✅ Pocos (probado) |

---

## 3. Arquitectura del HAL

### 3.1 Estructura de Capas Completa

```
┌────────────────────────────────────────────────────┐
│                 INTEGRADOR                         │
│              (EMIC-Editor / Script)                │
└────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────┐
│                   MÓDULO                           │
└────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────┐
│                    APIs                            │  ← Nivel ALTO
│  LED_Toggle(), Timer_Start(), USB_Send()          │     (portable)
└────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────┐
│                  DRIVERS                           │  ← Nivel MEDIO-BAJO
│  MCP2200_Init(), DHT22_Read(), RFM95_Send()       │     (específico chip)
└────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────┐
│                    HAL                             │  ⭐ CAPA DE ABSTRACCIÓN
│  GPIO_Write(), SPI_Transfer(), I2C_Read()         │     (abstrae MCU)
│                                                    │
│  Características:                                 │
│  • Interfaz consistente                           │
│  • NO implementa (delega a _hard)                 │
│  • Abstrae diferencias de MCU                     │
└────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────┐
│                 HARDWARE (_hard/)                  │  ← Código ESPECÍFICO MCU
│  Registros PIC24/PIC32/ARM/AVR                    │     (implementación real)
│                                                    │
│  Características:                                 │
│  • Acceso directo a registros                     │
│  • Específico de cada familia                     │
│  • Implementa funcionalidad real                  │
└────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────┐
│              MICROCONTROLADOR                      │  ← Hardware físico
│  Registros físicos del chip                       │
└────────────────────────────────────────────────────┘
```

### 3.2 Flujo de una Llamada HAL

**Ejemplo: Escribir un pin GPIO**

```
1. Driver llama:
   HAL_GPIO_PinSet(LED_PIN, GPIO_HIGH);
        ↓
2. HAL (_hal/GPIO/gpio.emic) redirige a:
   EMIC:setInput(DEV:_hard/.{system.ucName}./GPIO/gpio.emic)
        ↓
3. _hard selecciona la familia correcta:
   • Si system.ucName = "PIC24FJ64GA002"
     → _hard/PIC24FJ64GA002/GPIO/gpio.emic
   • Si system.ucName = "STM32F4"
     → _hard/STM32F4/GPIO/gpio.emic
        ↓
4. gpio.h define macros específicas:
   #define HAL_GPIO_PinSet(name,value) LAT##name = value  (PIC)
   #define HAL_GPIO_PinSet(name,value) GPIO##name->ODR = value  (ARM)
        ↓
5. Se expande a código específico:
   • PIC24:  LATA = 1;
   • ARM:    GPIOA->ODR = 1;
```

### 3.3 Responsabilidades del HAL

```
┌────────────────────────────────────────────────────┐
│  HAL (_hal/) ES RESPONSABLE DE:                   │
└────────────────────────────────────────────────────┘

  ✅ Proporcionar interfaz consistente
  ✅ Seleccionar implementación correcta (_hard)
  ✅ Pasar parámetros a _hard
  ✅ Documentar API abstracta

┌────────────────────────────────────────────────────┐
│  HAL NO es responsable de:                         │
└────────────────────────────────────────────────────┘

  ❌ Implementar funcionalidad (lo hace _hard)
  ❌ Acceder a registros directamente
  ❌ Lógica de negocio (lo hacen Drivers/APIs)
```

---

## 4. Periféricos Disponibles

### 4.1 Listado Completo del SDK Real

Según el SDK en `EMIC_IA_M\_hal\`, existen los siguientes HALs:

| # | HAL | Descripción | Periférico Abstraído |
|---|-----|-------------|----------------------|
| 1 | **GPIO** | Entradas/Salidas digitales | Pines digitales |
| 2 | **SPI** | Comunicación SPI | SPI1, SPI2, etc. |
| 3 | **I2C** | Comunicación I2C | I2C1, I2C2, etc. |
| 4 | **UART** | Comunicación serial | UART1, UART2, etc. |
| 5 | **Timer** | Temporizadores | Timer0/1/2/3/etc. |
| 6 | **ADC** | Conversor analógico-digital | ADC channels |
| 7 | **PWM** | Modulación por ancho de pulso | PWM outputs |
| 8 | **I2S** | Audio digital | I2S interface |
| 9 | **Flash** | Memoria Flash interna | Program memory |
| 10 | **System** | Configuración del sistema | Clock, init, WDT |
| 11 | **RefCLK** | Clock de referencia | Reference clock |
| 12 | **pins** | Configuración de pines | Pin mapping |

### 4.2 Clasificación por Función

```
┌─────────────────────────────────────────────────────┐
│         HALs POR TIPO DE FUNCIÓN                    │
└─────────────────────────────────────────────────────┘

  🔌 COMUNICACIÓN (33%)
      ├── SPI (master/slave)
      ├── I2C (master/slave)
      ├── UART (serial)
      └── I2S (audio digital)

  ⚙️ PERIFÉRICOS BÁSICOS (33%)
      ├── GPIO (digital I/O)
      ├── Timer (temporizadores)
      ├── ADC (analógico)
      └── PWM (pulsos)

  🔧 SISTEMA (34%)
      ├── System (clock, init)
      ├── Flash (memoria)
      ├── RefCLK (reloj ref)
      └── pins (mapeo)
```

---

## 5. Ejemplos de HAL Reales

### 5.1 Ejemplo 1: GPIO HAL (Más Simple)

**Ubicación:** `_hal/GPIO/`

**Archivo: gpio.emic**

```emic
EMIC:setInput(DEV:_hard/.{system.ucName}./GPIO/gpio.emic)
```

**Análisis:**

1. **Extremadamente simple:** Solo una línea
2. **Delega completamente a _hard:** No hay lógica aquí
3. **Variable .{system.ucName}.:** Selecciona la familia de MCU
   - Si `system.ucName = "PIC24FJ64GA002"` → `_hard/PIC24FJ64GA002/GPIO/gpio.emic`
   - Si `system.ucName = "STM32F4"` → `_hard/STM32F4/GPIO/gpio.emic`

**Implementación en _hard (PIC24):**

**Archivo: _hard/PIC24FJ64GA002/GPIO/inc/gpio.h**

```c
#ifndef PIC_GPIO_H_
#define PIC_GPIO_H_

#include "pins.h"

// Enums de configuración
typedef enum {
    GPIO_OUTPUT,
    GPIO_INPUT,
} gpio_pinConfig_t;

typedef enum {
    GPIO_LOW,
    GPIO_HIGH,
    GPIO_TOGGLE
} gpio_state_t;

// MACROS de abstracción (núcleo del HAL)
#define HAL_GPIO_PinCfg(name,cfg_value) TRIS_##name = cfg_value
#define HAL_GPIO_PinSet(name,value) PIN_##name = value
#define HAL_GPIO_PinGet(name) PIN_##name

#endif
```

**Explicación de las macros:**

```c
// Macro: HAL_GPIO_PinCfg(name, cfg_value)
// Configura dirección del pin (input/output)
HAL_GPIO_PinCfg(A0_Pin, GPIO_OUTPUT);
// Se expande a: TRIS_A0_Pin = GPIO_OUTPUT;
// En PIC: TRIS_A0_Pin es TRISAbits.TRISA0

// Macro: HAL_GPIO_PinSet(name, value)
// Escribe valor al pin
HAL_GPIO_PinSet(A0_Pin, GPIO_HIGH);
// Se expande a: PIN_A0_Pin = GPIO_HIGH;
// En PIC: PIN_A0_Pin es LATAbits.LATA0

// Macro: HAL_GPIO_PinGet(name)
// Lee valor del pin
uint8_t value = HAL_GPIO_PinGet(A0_Pin);
// Se expande a: uint8_t value = PIN_A0_Pin;
// En PIC: PIN_A0_Pin es PORTAbits.RA0
```

**Uso desde Driver:**

```c
// En led.c (driver de LED)
#include "gpio.h"

void LED_Init(void) {
    HAL_GPIO_PinCfg(LED_PIN, GPIO_OUTPUT);
    HAL_GPIO_PinSet(LED_PIN, GPIO_LOW);
}

void LED_On(void) {
    HAL_GPIO_PinSet(LED_PIN, GPIO_HIGH);
}

void LED_Off(void) {
    HAL_GPIO_PinSet(LED_PIN, GPIO_LOW);
}

void LED_Toggle(void) {
    HAL_GPIO_PinSet(LED_PIN, GPIO_TOGGLE);
}
```

---

### 5.2 Ejemplo 2: SPI HAL (Comunicación)

**Ubicación:** `_hal/SPI/`

**Archivo: SPI.emic**

```emic
EMIC:setInput(DEV:_hard/.{system.ucName}./SPI/spi.emic,
              configuracion=.{configuracion}.,
              port=.{port}.,
              pin=.{pin}.)
```

**Análisis:**

1. **Parámetros adicionales:**
   - `configuracion`: Master o Slave
   - `port`: Puerto SPI (1, 2, etc.)
   - `pin`: Pin CS (Chip Select)

2. **Delega con parámetros:** Pasa configuración a _hard

**Uso desde Driver:**

```emic
// En LCDdriver.emic
EMIC:setInput(DEV:_hal/SPI/SPI.emic,
              port=1,
              configuracion=Master,
              pin=LCD_CS)
```

**Funciones típicas del SPI HAL (implementadas en _hard):**

```c
// Inicializar SPI
void SPI1_Initialize(uint32_t baudRate);

// Transferir byte (enviar y recibir)
uint8_t SPI1_Transfer(uint8_t data);

// Escribir múltiples bytes
void SPI1_WriteBlock(const uint8_t* data, uint16_t length);

// Leer múltiples bytes
void SPI1_ReadBlock(uint8_t* buffer, uint16_t length);
```

---

### 5.3 Ejemplo 3: I2C HAL (Comunicación)

**Ubicación:** `_hal/I2C/`

**Archivo: I2C.emic**

```emic
EMIC:setInput(DEV:_hard/.{system.ucName}./I2C/I2C.emic,
              port=.{port}.,
              client=.{client}.,
              interrupt=.{interrupt}.)
```

**Análisis:**

1. **Parámetros:**
   - `port`: Puerto I2C (1, 2)
   - `client`: Nombre del cliente (para callbacks)
   - `interrupt`: Habilitar/deshabilitar interrupciones

2. **Soporte de callbacks:** Permite interrupciones

**Funciones típicas del I2C HAL (implementadas en _hard):**

```c
// Inicializar I2C
void I2C1_Initialize(uint32_t clockSpeed);

// Escribir a dispositivo
bool I2C1_Write(uint8_t address, const uint8_t* data, uint16_t length);

// Leer de dispositivo
bool I2C1_Read(uint8_t address, uint8_t* buffer, uint16_t length);

// Escribir registro específico
bool I2C1_WriteRegister(uint8_t address, uint8_t reg, uint8_t value);

// Leer registro específico
bool I2C1_ReadRegister(uint8_t address, uint8_t reg, uint8_t* value);

// Callback (si interrupt=1)
void I2C1_MasterCallback(void);
void I2C1_SlaveCallback(void);
```

---

### 5.4 Ejemplo 4: UART HAL (Serial)

**Ubicación:** `_hal/UART/`

**Archivo: UART.emic**

```emic
EMIC:setInput(DEV:_hard/.{system.ucName}./UART/UARTX.emic,
              port=.{port}.,
              BufferSize=.{BufferSize}.,
              baud=.{baud}.,
              driver=.{driver}.)
```

**Análisis:**

1. **Parámetros de configuración:**
   - `port`: Puerto UART (1, 2, 3)
   - `BufferSize`: Tamaño del buffer RX/TX
   - `baud`: Velocidad (9600, 115200, etc.)
   - `driver`: Nombre del driver (para callbacks)

2. **Configuración completa:** Baudrate y buffer

**Funciones típicas del UART HAL (implementadas en _hard):**

```c
// Inicializar UART
void UART1_Initialize(uint32_t baudRate);

// Enviar byte
void UART1_Write(uint8_t data);

// Enviar string
void UART1_WriteString(const char* str);

// Leer byte (bloqueante)
uint8_t UART1_Read(void);

// Verificar si hay datos disponibles
bool UART1_IsRxReady(void);

// Verificar si TX está listo
bool UART1_IsTxReady(void);

// Callback RX (interrupción)
void UART1_RxCallback(uint8_t data);
```

---

### 5.5 Ejemplo 5: Timer HAL

**Ubicación:** `_hal/Timer/`

**Archivo: timer.emic**

```emic
EMIC:setInput(DEV:_hard/.{system.ucName}./Timer/timer.emic)
```

**Funciones típicas del Timer HAL (implementadas en _hard):**

```c
// Inicializar timer
void Timer1_Initialize(uint32_t frequencyHz);

// Iniciar timer
void Timer1_Start(void);

// Detener timer
void Timer1_Stop(void);

// Configurar periodo (ms)
void Timer1_SetPeriod(uint16_t milliseconds);

// Callback de interrupción
void Timer1_InterruptCallback(void);
```

---

## 6. HAL vs Driver vs API

### 6.1 Tabla Comparativa Completa

| Aspecto | HAL | Driver | API |
|---------|-----|--------|-----|
| **Nivel** | Medio (abstracción de MCU) | Bajo (hardware específico) | Alto (funcionalidad) |
| **Abstrae** | **Periféricos internos MCU** | Chips/componentes externos | Conceptos genéricos |
| **Hardware** | GPIO, SPI, I2C, UART (MCU) | MCP2200, DHT22, RFM95 (externos) | LED, Timer, USB (genéricos) |
| **Portabilidad** | **Sí (entre MCUs)** | No (específico del chip) | Sí (entre proyectos) |
| **Implementación** | Delega a _hard | Implementa protocolo | Usa Drivers + HAL |
| **Dependencias** | _hard | HAL | Drivers + HAL |
| **Cambio de MCU** | **Solo cambiar _hard** | NO requiere cambios | NO requiere cambios |
| **Ejemplo** | `GPIO_Write()` | `MCP2200_Send()` | `USB_Send()` |

### 6.2 Diagrama de Relaciones

```
┌────────────────────────────────────────────────────┐
│                    APIs                            │
│  Nivel más alto: Abstracción de funcionalidad     │
│                                                    │
│  Ejemplo: USB_Send("data")                        │
│  - Genérico (cualquier USB)                       │
│  - Portable entre proyectos                       │
└────────────────────────────────────────────────────┘
                      ↓ usa
┌────────────────────────────────────────────────────┐
│                  DRIVERS                           │
│  Nivel medio-bajo: Control de chips específicos   │
│                                                    │
│  Ejemplo: MCP2200_Send(data)                      │
│  - Específico del chip MCP2200                    │
│  - Implementa protocolo del chip                  │
└────────────────────────────────────────────────────┘
                      ↓ usa
┌────────────────────────────────────────────────────┐
│                    HAL                             │
│  Nivel medio: Abstracción de periféricos MCU      │
│                                                    │
│  Ejemplo: UART_Write(data)                        │
│  - Genérico (cualquier MCU con UART)              │
│  - Portable entre MCUs                            │
└────────────────────────────────────────────────────┘
                      ↓ delega
┌────────────────────────────────────────────────────┐
│                 HARDWARE (_hard)                   │
│  Nivel bajo: Código específico del MCU            │
│                                                    │
│  Ejemplo: U1TXREG = data; (PIC24)                 │
│  - Específico del MCU                             │
│  - Acceso directo a registros                     │
└────────────────────────────────────────────────────┘
```

### 6.3 Ejemplo Completo: Enviar Datos USB

```
API (_api/Wired_Communication/USB/):
    USB_Send("Hello World");
         ↓
    Llama a Driver MCP2200
         ↓
Driver (_drivers/USB/MCP2200/):
    MCP2200_Send(data, length);
         ↓
    Formatea datos según protocolo MCP2200
    Llama a HAL UART
         ↓
HAL (_hal/UART/):
    UART1_Write(byte);
         ↓
    Delega a _hard específico del MCU
         ↓
Hardware (_hard/PIC24FJ64GA002/UART/):
    U1TXREG = byte;  // Registro específico de PIC24
         ↓
    Hardware físico: pin TX
```

---

## 7. Portabilidad entre MCUs

### 7.1 Caso Práctico: Portar de PIC24 a PIC32

**Escenario:**
Tienes un proyecto completo en PIC24FJ64GA002 y necesitas portarlo a PIC32MZ2048.

**SIN HAL (catástrofe):**

```c
// Código original PIC24 (100+ archivos)
TRISAbits.TRISA0 = 0;  // Output
LATAbits.LATA0 = 1;    // High

U1BRG = 25;            // Baud rate PIC24
U1MODE = 0x8000;       // Enable UART PIC24
U1STA = 0x0400;        // TX enable PIC24

SPI1CON1 = 0x013B;     // SPI config PIC24
// ... 1000+ líneas más ...
```

**Trabajo necesario:**
1. Buscar TODOS los accesos a registros (grep manual)
2. Consultar datasheet de PIC32 para cada registro
3. Reescribir cada línea con registros de PIC32
4. Probar y debuggear (registros diferentes)
5. **Tiempo estimado: 100-200 horas**

**CON HAL (simple):**

```c
// Código con HAL (mismo para PIC24 y PIC32)
HAL_GPIO_PinCfg(LED_PIN, GPIO_OUTPUT);
HAL_GPIO_PinSet(LED_PIN, GPIO_HIGH);

UART1_Initialize(115200);
UART1_Write(data);

SPI1_Initialize(1000000);
SPI1_Transfer(byte);
// ... código portable ...
```

**Trabajo necesario:**
1. Cambiar `system.ucName` de "PIC24FJ64GA002" a "PIC32MZ2048"
2. Si no existe _hard/PIC32MZ2048/, crearlo (copiar de PIC32 similar)
3. Recompilar
4. **Tiempo estimado: 2-4 horas**

### 7.2 Pasos para Portar con HAL

```
┌────────────────────────────────────────────────────┐
│  PASO 1: Cambiar system.ucName                    │
│  En el módulo o configuración global:              │
│  system.ucName = "PIC32MZ2048EFM064"               │
└────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────┐
│  PASO 2: Verificar _hard/PIC32MZ2048EFM064/        │
│  ¿Existe la implementación?                        │
│  • Sí → Continuar                                  │
│  • No → Crear (copiar de PIC32 similar)           │
└────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────┐
│  PASO 3: Ajustar pines (si PCB diferente)          │
│  Mapeo de pines en pins.h:                        │
│  #define LED_PIN A0_Pin  // Cambiar si necesario  │
└────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────┐
│  PASO 4: Compilar con XC32 (vs XC16)              │
│  Cambiar compilador en proyecto                   │
└────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────┐
│  PASO 5: Probar en hardware                        │
│  • APIs: NO cambian                                │
│  • Drivers: NO cambian                             │
│  • Solo _hard es diferente                         │
└────────────────────────────────────────────────────┘
```

### 7.3 Familias Soportadas en el SDK Real

Según `_hard/` del SDK:

| Familia | MCU Específico | Compilador |
|---------|----------------|------------|
| **PIC24** | PIC24FJ64GA002 | XC16 |
| **PIC24** | PIC24FJ64GA004 | XC16 |
| **PIC24** | PIC24FJ128GA010 | XC16 |
| **PIC24** | PIC24FJ128GC006 | XC16 |
| **dsPIC33** | dsPIC33EP512MC806 | XC16 |
| **PIC32** | PIC32MZ2048EFM064 | XC32 |

**Para agregar nuevo MCU:**
Crear carpeta `_hard/{NuevoMCU}/` con la estructura completa de HALs.

---

## 8. Creación de Nuevos HALs

### 8.1 Cuándo Crear un HAL

✅ **Crear HAL cuando:**
- Nuevo periférico interno del MCU (CAN, Ethernet, USB OTG)
- Periférico común en múltiples familias
- Necesitas portabilidad entre MCUs

❌ **NO crear HAL para:**
- Chips externos (eso es Driver)
- Funcionalidad específica de un MCU (dejar en _hard)
- Lógica de negocio (eso es API)

### 8.2 Checklist de Creación

**PASO 1: Identificar periférico**
- [ ] Periférico existe en múltiples MCUs
- [ ] Tiene función similar en diferentes familias
- [ ] Requiere portabilidad

**PASO 2: Diseñar interfaz HAL**
- [ ] Definir funciones abstractas
- [ ] Listar parámetros necesarios
- [ ] Documentar comportamiento esperado

**PASO 3: Crear estructura**
```bash
mkdir _hal/{NuevoHAL}
touch _hal/{NuevoHAL}/{NuevoHAL}.emic
```

**PASO 4: Implementar redirección**
```emic
EMIC:setInput(DEV:_hard/.{system.ucName}./{NuevoHAL}/{NuevoHAL}.emic,
              param1=.{param1}.,
              param2=.{param2}.)
```

**PASO 5: Implementar en _hard para cada MCU**
```bash
mkdir _hard/PIC24FJ64GA002/{NuevoHAL}
mkdir _hard/PIC24FJ64GA002/{NuevoHAL}/inc
touch _hard/PIC24FJ64GA002/{NuevoHAL}/{NuevoHAL}.emic
touch _hard/PIC24FJ64GA002/{NuevoHAL}/inc/{NuevoHAL}.h
```

### 8.3 Ejemplo: Crear CAN HAL

**1. _hal/CAN/CAN.emic:**

```emic
EMIC:setInput(DEV:_hard/.{system.ucName}./CAN/CAN.emic,
              port=.{port}.,
              baudRate=.{baudRate}.,
              mode=.{mode}.)
```

**2. _hard/PIC24FJ64GA002/CAN/inc/CAN.h:**

```c
#ifndef CAN_HAL_H
#define CAN_HAL_H

#include <stdint.h>
#include <stdbool.h>

// Modos de operación
typedef enum {
    CAN_MODE_NORMAL,
    CAN_MODE_LOOPBACK,
    CAN_MODE_LISTEN_ONLY
} CAN_Mode_t;

// Estructura de mensaje CAN
typedef struct {
    uint32_t id;
    uint8_t data[8];
    uint8_t dlc;
    bool extended;
    bool rtr;
} CAN_Message_t;

// Funciones HAL
void CAN1_Initialize(uint32_t baudRate, CAN_Mode_t mode);
bool CAN1_Transmit(const CAN_Message_t* msg);
bool CAN1_Receive(CAN_Message_t* msg);
bool CAN1_IsTxReady(void);
bool CAN1_IsRxReady(void);

// Callbacks
void CAN1_TxCallback(void);
void CAN1_RxCallback(CAN_Message_t* msg);

#endif
```

**3. Uso desde Driver:**

```c
#include "CAN.h"

void MyCAN_Driver_Init(void) {
    CAN1_Initialize(500000, CAN_MODE_NORMAL); // 500 kbps
}

void MyCAN_Driver_Send(uint32_t id, const uint8_t* data, uint8_t length) {
    CAN_Message_t msg;
    msg.id = id;
    msg.dlc = length;
    msg.extended = false;
    msg.rtr = false;
    memcpy(msg.data, data, length);

    while(!CAN1_IsTxReady());
    CAN1_Transmit(&msg);
}
```

---

## 🎯 Puntos Clave del Capítulo

| Concepto | Explicación |
|----------|-------------|
| **HAL** | Hardware Abstraction Layer - Abstrae periféricos MCU |
| **Propósito** | **Portabilidad entre MCUs** (PIC, ARM, AVR) |
| **Responsabilidad** | Delega a _hard, NO implementa |
| **12 HALs** | GPIO, SPI, I2C, UART, Timer, ADC, PWM, I2S, Flash, System, RefCLK, pins |
| **Arquitectura** | HAL redirige a _hard según system.ucName |
| **Beneficio** | Cambiar MCU = 2-4 horas (vs 100+ sin HAL) |
| **Relación** | APIs → Drivers → **HAL** → _hard → Hardware |

---

## 📊 Resumen Visual

```
┌────────────────────────────────────────────────────┐
│                    HAL                             │
│    _hal/{Peripheral}/{Peripheral}.emic             │
└────────────────────────────────────────────────────┘
            │
            │ Delega a _hard según MCU
            ↓
┌────────────────────────────────────────────────────┐
│  EMIC:setInput(DEV:_hard/.{system.ucName}./...)   │
└────────────────────────────────────────────────────┘
            │
     ┌──────┴──────────┬──────────────┐
     │                 │              │
_hard/PIC24/      _hard/ARM/     _hard/AVR/
     │                 │              │
Registros PIC    Registros ARM  Registros AVR
```

---

## ✅ Checklist de Comprensión

Antes de continuar al Capítulo 10, asegúrate de entender:

- [ ] Qué es el HAL (abstracción de periféricos MCU)
- [ ] El propósito del HAL (portabilidad entre MCUs)
- [ ] La diferencia entre HAL, Driver y API
- [ ] Los 12 HALs disponibles en el SDK
- [ ] Cómo el HAL delega a _hard según system.ucName
- [ ] Por qué el HAL NO implementa (solo redirige)
- [ ] El beneficio de portabilidad (2-4h vs 100+h)
- [ ] Cómo crear un nuevo HAL

---

## 🎓 Ejercicio Práctico

**Exploración del SDK Real:**

```powershell
# Navega a _hal/
cd C:\Users\franc\Dropbox\...\EMIC_IA_M\_hal\

# Lista todos los HALs
ls

# Explora GPIO HAL
cat GPIO\gpio.emic

# Explora SPI HAL
cat SPI\SPI.emic

# Navega a _hard para ver implementación
cd ..\_hard\

# Lista familias soportadas
ls

# Explora implementación GPIO para PIC24
cd PIC24FJ64GA002\GPIO\
cat gpio.emic
cat inc\gpio.h
```

**Pregunta de reflexión:**
¿Por qué el HAL es tan simple (solo redirige a _hard) en vez de implementar directamente?

<details>
<summary>Ver respuesta</summary>

**Respuesta:**
Porque el HAL sigue el **principio de delegación** (Separation of Concerns):

1. **HAL** = Interfaz abstracta (QUÉ hacer)
2. **_hard** = Implementación específica (CÓMO hacerlo)

**Ventajas:**
- ✅ **Portabilidad**: Cambiar MCU solo requiere cambiar _hard
- ✅ **Mantenibilidad**: Código específico aislado en _hard
- ✅ **Testabilidad**: Fácil mockear _hard para tests
- ✅ **Escalabilidad**: Agregar nuevo MCU = agregar carpeta _hard

Si el HAL implementara directamente, tendría:
```c
#ifdef PIC24
  // código PIC24
#elif defined(ARM)
  // código ARM
#elif defined(AVR)
  // código AVR
#endif
```
Esto sería **difícil de mantener** y **propenso a errores**.

La delegación es más limpia y escalable.

</details>

---

[← Anterior: Carpeta _drivers](08_Carpeta_Drivers.md) | [Siguiente: Carpeta _hard →](10_Carpeta_Hard.md)

---

**Progreso del Manual:**

```
Sección 1 (Introducción): ████████████████████ 100% (5/5)
Sección 2 (Estructura):   ██████████░░░░░░░░░░  45% (5/11)
```

**Progreso Total:** 26.32% (10/38 capítulos)

---

*Capítulo 09 - Manual de Desarrollo EMIC SDK v1.0*
*Última actualización: Noviembre 2025*
