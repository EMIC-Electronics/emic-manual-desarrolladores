# Capítulo 10: Carpeta `_hard/` - Código Específico de MCU

## Índice
1. [¿Qué es `_hard/`?](#1-qué-es-_hard)
2. [Organización por Familia de MCU](#2-organización-por-familia-de-mcu)
3. [Estructura de Periféricos](#3-estructura-de-periféricos)
4. [Ejemplos Reales del SDK](#4-ejemplos-reales-del-sdk)
5. [Comparación entre Familias de MCU](#5-comparación-entre-familias-de-mcu)
6. [Relación con el HAL](#6-relación-con-el-hal)
7. [Agregar Soporte para Nuevo MCU](#7-agregar-soporte-para-nuevo-mcu)
8. [Buenas Prácticas](#8-buenas-prácticas)
9. [Ejercicio Práctico](#9-ejercicio-práctico)

---

## 1. ¿Qué es `_hard/`?

La carpeta `_hard/` (hardware) contiene **implementaciones específicas para cada familia de microcontrolador** soportada por el SDK EMIC. Es el **nivel más bajo de la pila de abstracción**, donde se encuentra el código que interactúa directamente con los **registros del MCU**.

### 1.1 Ubicación en la Arquitectura EMIC

```
┌─────────────────────────────────────────────────┐
│          Integrador (EMIC-Editor)               │ ← Alto nivel
├─────────────────────────────────────────────────┤
│           Módulos (_modules/)                   │
├─────────────────────────────────────────────────┤
│              APIs (_api/)                       │ ← Portables entre MCUs
├─────────────────────────────────────────────────┤
│           Drivers (_drivers/)                   │
├─────────────────────────────────────────────────┤
│              HAL (_hal/)                        │ ← Abstrae MCU
├─────────────────────────────────────────────────┤
│          Hardware (_hard/)      ← ESTE NIVEL    │ ← MCU-específico
├─────────────────────────────────────────────────┤
│   Registros del Microcontrolador (TRIS, LAT,   │
│   U1MODE, SPI1CON, ADC1BUF0, etc.)              │ ← Bajo nivel
└─────────────────────────────────────────────────┘
```

### 1.2 Responsabilidades de `_hard/`

| Responsabilidad | Descripción |
|----------------|-------------|
| **Registros del MCU** | Acceso directo a registros específicos (TRIS, LAT, U1MODE, etc.) |
| **Inicialización de hardware** | Configuración de clocks, osciladores, periféricos |
| **Implementación de HAL** | Código real que ejecuta las funciones abstractas del HAL |
| **Mapeo de pines** | Definiciones de pines específicas del chip (RP0, RB0, etc.) |
| **Interrupciones** | Vectores y handlers específicos del MCU |

### 1.3 Características Clave

- **NO es portable** entre familias de MCU
- **Depende del compilador** (XC8/XC16/XC32 para PIC, GCC ARM para Cortex-M, etc.)
- **Una carpeta por cada MCU** soportado
- **El HAL delega aquí** todas las operaciones de hardware

---

## 2. Organización por Familia de MCU

El SDK EMIC organiza `_hard/` en **carpetas separadas por familia de microcontrolador**:

```
_hard/
├── pic24FJ64GA002/           # PIC24F de 16 bits (Microchip)
├── pic24FJ128GA010/
├── pic24FJ128GC006/
├── PIC24FJ64GA004/
├── pic24FJxxxGA010/
├── dsPIC33EP512MC806/        # dsPIC33 de 16 bits con DSP (Microchip)
├── PIC32MZ2048EFM064/        # PIC32 de 32 bits (Microchip)
├── STM32F407VG/              # ARM Cortex-M4 (STMicroelectronics) - ejemplo futuro
├── ATMEGA328P/               # AVR de 8 bits (Microchip/Atmel) - ejemplo futuro
└── ESP32-C3/                 # RISC-V (Espressif) - ejemplo futuro
```

### 2.1 Familias Actualmente Soportadas (SDK Real)

| Familia MCU | Arquitectura | Bits | Fabricante | Compilador |
|------------|--------------|------|------------|------------|
| **PIC24FJ64GA002** | PIC24F | 16 | Microchip | XC16 |
| **PIC24FJ128GA010** | PIC24F | 16 | Microchip | XC16 |
| **PIC24FJ128GC006** | PIC24F | 16 | Microchip | XC16 |
| **PIC24FJ64GA004** | PIC24F | 16 | Microchip | XC16 |
| **dsPIC33EP512MC806** | dsPIC33E | 16 (DSP) | Microchip | XC16 |
| **PIC32MZ2048EFM064** | MIPS M-class | 32 | Microchip | XC32 |

> **Nota**: EMIC es **multiplataforma**. Puedes agregar soporte para ARM Cortex-M, AVR, RISC-V, etc., creando las carpetas correspondientes en `_hard/`.

---

## 3. Estructura de Periféricos

Dentro de cada carpeta de MCU, los periféricos están organizados en **subcarpetas**:

### 3.1 Estructura Típica (Ejemplo: PIC24FJ64GA002)

```
_hard/pic24FJ64GA002/
├── GPIO/                     # Entradas/salidas digitales
│   ├── gpio.emic
│   └── inc/
│       └── gpio.h
├── pins/                     # Configuración de pines individuales
│   ├── setPinA0.h
│   ├── setPinB0.h
│   ├── setPinB1.h
│   └── ... (21 archivos)
├── UART/                     # Comunicación serial
│   ├── UARTX.emic
│   ├── inc/
│   │   └── UARTX.h
│   └── src/
│       └── UARTX.c
├── SPI/                      # Bus SPI
│   ├── spi.emic
│   ├── Master/
│   │   ├── inc/spi.h
│   │   └── src/spi.c
│   └── Slave/
│       ├── inc/spi.h
│       └── src/spi.c
├── I2C/                      # Bus I2C
│   ├── I2C.emic
│   ├── inc/I2C.h
│   └── src/I2C.c
├── Timer/                    # Temporizadores
│   ├── timer.emic
│   ├── inc/timer.h
│   └── src/timer.c
├── ADC/                      # Conversor Analógico-Digital
│   ├── adc.emic
│   ├── inc/adc.h
│   └── src/adc.c
├── Flash/                    # Memoria Flash interna
│   ├── flash.emic
│   └── inc/flash.h
└── System/                   # Inicialización del MCU
    ├── system.emic
    ├── inc/system.h
    └── src/system.c
```

### 3.2 Periféricos Disponibles por Familia

| Periférico | PIC24FJ64GA002 | PIC32MZ2048 | dsPIC33EP512 |
|-----------|----------------|-------------|--------------|
| **GPIO** | ✅ | ✅ | ✅ |
| **pins** | ✅ | ❌ | ✅ |
| **UART** | ✅ | ✅ | ✅ |
| **SPI** | ✅ | ✅ | ✅ |
| **I2C** | ✅ | ✅ | ❌ |
| **Timer** | ✅ | ✅ | ✅ |
| **ADC** | ✅ | ✅ | ❌ |
| **PWM** | ❌ | ✅ | ✅ |
| **I2S** | ❌ | ✅ | ❌ |
| **RefClock** | ❌ | ✅ | ✅ |
| **Flash** | ✅ | ❌ | ❌ |
| **System** | ✅ | ✅ | ✅ |

> **Importante**: No todos los MCUs tienen los mismos periféricos. `_hard/` refleja las **capacidades reales del hardware**.

---

## 4. Ejemplos Reales del SDK

Veamos implementaciones reales de `_hard/` del SDK EMIC.

### 4.1 Ejemplo 1: GPIO para PIC24FJ64GA002

#### Archivo: `_hard/pic24FJ64GA002/GPIO/gpio.emic`

```emic
EMIC:ifndef _PIC_GPIO_EMIC_
EMIC:define(_PIC_GPIO_EMIC_,true)

EMIC:copy(inc/gpio.h > TARGET:/inc/gpio.h)

EMIC:endif
```

#### Archivo: `_hard/pic24FJ64GA002/GPIO/inc/gpio.h`

```c
#ifndef PIC_GPIO_H_
#define PIC_GPIO_H_

#include "pins.h"

typedef enum
{
    GPIO_OUTPUT,
    GPIO_INPUT,
} gpio_pinConfig_t;

typedef enum
{
    GPIO_LOW,
    GPIO_HIGH,
    GPIO_TOGGLE
} gpio_state_t;

// ========================================
// Macros HAL - Implementación Real
// ========================================
#define HAL_GPIO_PinCfg(name,cfg_value) TRIS_##name = cfg_value
#define HAL_GPIO_PinSet(name,value) PIN_##name = value
#define HAL_GPIO_PinGet(name) PIN_##name

#endif
```

**Explicación:**
- `HAL_GPIO_PinCfg(LED, GPIO_OUTPUT)` → se expande a `TRIS_LED = GPIO_OUTPUT`
- `HAL_GPIO_PinSet(LED, GPIO_HIGH)` → se expande a `PIN_LED = GPIO_HIGH`
- Usa **macros de preprocesador** (`##`) para construir nombres de registros

---

### 4.2 Ejemplo 2: Configuración de Pines (pins)

#### Archivo: `_hard/pic24FJ64GA002/pins/setPinB0.h`

```c
#define TRIS_.{name}.       _TRISB0
#define PIN_.{name}.        _RB0
#define LAT_.{name}.        _LATB0
#define ODC_.{name}.        _ODB0
#define RPOUT_.{name}.      RPOR0bits.RP0R
#define RPIN_.{name}.       0
#define CN_.{name}.         4
#define ADC_value_.{name}.  Buffer_entradas[2]
#define HAL_SetAnalog_.{name}.()  {_PCFG2=0; adc_addAnalogChannel(2);}
```

**Explicación:**
- Define **macros específicas para cada pin físico** del MCU
- `.{name}.` es un **placeholder de EMIC-Codify** (ej: `.{name}. = LED`)
- `_TRISB0` es el **registro TRI-STATE del pin RB0** (1=input, 0=output)
- `_RB0` es el **valor del pin RB0** (lectura)
- `_LATB0` es el **latch del pin RB0** (escritura)
- `RPOR0bits.RP0R` es el **Remappable Pin Output Register** (PPS)

**Uso en código generado:**
```c
TRIS_LED = 0;        // Si LED está en RB0 → TRIS_LED se expande a _TRISB0
LAT_LED = 1;         // LAT_LED se expande a _LATB0
```

---

### 4.3 Ejemplo 3: UART para PIC24FJ64GA002

#### Archivo: `_hard/pic24FJ64GA002/UART/UARTX.emic`

```emic
/*************************************************************************//**

  @file     UARTX.emic

  @brief    Hardware Library to use UART

  @author   Rottoli Luciano

  @version  v0.0.1

  @date     01/03/2024

 ******************************************************************************/

EMIC:ifndef _PIC_UART.{port}._EMIC
EMIC:define(_PIC_UART.{port}._EMIC,true)

EMIC:setInput(DEV:_hal/GPIO/gpio.emic)

EMIC:setInput(DEV:_system/Stream/streamIn.emic)
EMIC:setInput(DEV:_system/Stream/streamOut.emic)

EMIC:copy(inc/UARTX.h > TARGET:inc/UART.{port}..h,port=.{port}.,BufferSize=.{BufferSize}.,baud=.{baud}.,driver=.{driver}.)
EMIC:copy(src/UARTX.c > TARGET:UART.{port}..c,port=.{port}.,BufferSize=.{BufferSize}.,baud=.{baud}.,driver=.{driver}.)

EMIC:define(c_modules.UART.{port}.,UART.{port}.)
EMIC:endif
```

#### Archivo: `_hard/pic24FJ64GA002/UART/inc/UARTX.h` (extracto)

```c
#ifndef _UART.{port}._H_
#define _UART.{port}._H_

#include <xc.h>
#include "streamOut.h"
#include "streamIn.h"

#define UART.{port}._MAX_BUFFER_SIZE .{BufferSize}.

typedef struct {
    char buffer[UART.{port}._MAX_BUFFER_SIZE];
    uint16_t start;      // Pointer to the start of the queue
    uint16_t end;        // Pointer to the end of the queue
    uint16_t count;      // Count of data elements in the queue
} UART_FIFO;

// Variables externas
extern uint8_t     UART.{port}._flowControlVar;
extern uint8_t     UART.{port}._inverted;
extern UART_FIFO   UART.{port}._IN_fifo;
extern UART_FIFO   UART.{port}._OUT_fifo;

// Funciones públicas
void UART.{port}._init(void);
void UART.{port}._ON(void);
void UART.{port}._OFF(void);
void UART.{port}._bd(uint32_t uartSpeed);
char UART.{port}._IN_pop(void);
uint16_t UART.{port}._IN_count(void);
void UART.{port}._OUT_push(char d);

#endif
```

#### Archivo: `_hard/pic24FJ64GA002/UART/src/UARTX.c` (extracto)

```c
#include <xc.h>
#include "inc/gpio.h"
#include "inc/streamOut.h"
#include "inc/streamIn.h"
#include "inc/UART.{port}..h"
#include "inc/system.h"

// =====================================================
// Configuración de Baud Rate (REGISTRO U1BRG)
// =====================================================
void UART.{port}._bd(uint32_t uartSpeed)
{
    switch(uartSpeed)
    {
        case 600:
        case 1200:
        case 2400:
        case 4800:
        case 9600:
        case 14400:
        case 19200:
        case 28800:
        case 38400:
        case 56000:
        case 57600:
            U.{port}.BRG = ((FCY / (16 * uartSpeed)) - 1);
            break;

        case 115200:
        case 128000:
        case 153600:
        case 230400:
        case 256000:
            U.{port}.BRG = ((FCY / (16 * uartSpeed)) - 1);
            break;
        default:
            U.{port}.BRG = ((FCY / ((uint16_t)16 * 9600)) - 1);
        break;
    }
}

// =====================================================
// Configuración de modo Simplex (REGISTRO U1MODE)
// =====================================================
void UART.{port}._simplexMode(void)
{
    U.{port}.MODEbits.RTSMD = 1;
    U.{port}.MODEbits.UEN1 = 1;
    U.{port}.MODEbits.UEN0 = 0;
}

// =====================================================
// Inversión de señales UART (REGISTROS U1STA/U1MODE)
// =====================================================
void UART.{port}._invert(uint8_t invert)
{
    U.{port}.STAbits.UTXINV = invert;
    U.{port}.MODEbits.RXINV = invert;
    UART.{port}._inverted = invert;
}

// =====================================================
// Operaciones de FIFO (buffer circular)
// =====================================================
void UART.{port}._push(UART_FIFO *fifo, char data)
{
    _U.{port}.RXIE = 0;  // Desactivar interrupciones
    _U.{port}.TXIE = 0;

    if (fifo==&UART.{port}._OUT_fifo && fifo->count == 0) {
        _U.{port}.TXIF = 1;  // Forzar interrupción TX
    }

    fifo->buffer[fifo->end] = data;
    fifo->end = (fifo->end + 1) % UART.{port}._MAX_BUFFER_SIZE;
    fifo->count++;

    if(fifo->count >= UART.{port}._MAX_BUFFER_SIZE)
    {
        fifo->count = UART.{port}._MAX_BUFFER_SIZE;
    }

    _U.{port}.RXIE = 1;  // Reactivar interrupciones
    _U.{port}.TXIE = 1;
}
```

**Explicación:**
- **Acceso directo a registros del PIC24**: `U1BRG`, `U1MODEbits`, `U1STAbits`
- **Fórmula de baud rate**: `BRG = (FCY / (16 * baudrate)) - 1`
- **Control de interrupciones**: `_U1RXIE`, `_U1TXIE`, `_U1TXIF`
- **FIFO circular** para buffering de datos TX/RX
- **Parametrización con EMIC-Codify**: `.{port}.`, `.{BufferSize}.`, `.{baud}.`

---

### 4.4 Ejemplo 4: I2C para PIC24FJ64GA002

#### Archivo: `_hard/pic24FJ64GA002/I2C/I2C.emic`

```emic
EMIC:ifndef __PIC_I2C.{port}._EMIC__
EMIC:define(__PIC_I2C.{port}._EMIC__,true)

    EMIC:copy(inc/I2C.h > TARGET:inc/I2C.{port}..h,port=.{port}.,client=.{client}.)
    EMIC:copy(src/I2C.c > TARGET:I2C.{port}..c,port=.{port}.,client=.{client}.,interrupt=.{interrupt}.)

EMIC:define(c_modules.I2C.{port}.,I2C.{port}.)
EMIC:endif
```

#### Archivo: `_hard/pic24FJ64GA002/I2C/inc/I2C.h` (extracto)

```c
#ifndef __PIC_I2C.{port}._H__
#define __PIC_I2C.{port}._H__

#include <xc.h>

// Funciones I2C Master
void Init_Master_I2C.{port}.(uint16_t frec, uint8_t address);
void Start_I2C.{port}.();
void Stop_I2C.{port}.();
void Write_I2C.{port}.(unsigned char byte);
uint8_t Read_I2C.{port}.(uint8_t Ack);

// Funciones de diagnóstico
void CollisionReset_I2C.{port}.();
void OverflowReset_I2C.{port}.();
uint8_t IsStartI2c.{port}.();
uint8_t IsCollisionDetectI2c.{port}.();
uint8_t IsStopI2c.{port}.();

#endif
```

**Explicación:**
- Primitivas I2C: **Start**, **Stop**, **Write**, **Read**
- Gestión de **errores de colisión** y **overflow**
- Configuración de **frecuencia** del bus I2C

---

### 4.5 Ejemplo 5: SPI para PIC24FJ64GA002

#### Archivo: `_hard/pic24FJ64GA002/SPI/spi.emic`

```emic
EMIC:ifndef _PIC_SPI.{port}._EMIC
EMIC:define(_PIC_SPI.{port}._EMIC,true)

EMIC:setInput(DEV:_hal/GPIO/gpio.emic)

EMIC:copy(.{configuracion}./inc/spi.h > TARGET:inc/spi.{port}..h,port=.{port}.,pin=.{pin}.)
EMIC:copy(.{configuracion}./src/spi.c > TARGET:spi.{port}..c,port=.{port}.,pin=.{pin}.)

EMIC:define(c_modules.spi.{port}.,spi.{port}.)
EMIC:endif
```

**Explicación:**
- `.{configuracion}.` puede ser `Master/` o `Slave/`
- Diferentes implementaciones según el **modo de operación**
- Copia archivos desde `Master/inc/spi.h` o `Slave/inc/spi.h` según configuración

---

## 5. Comparación entre Familias de MCU

Una de las fortalezas de `_hard/` es que **cada MCU tiene su propia implementación**, adaptada a sus registros y arquitectura.

### 5.1 Comparación: System Initialization

Veamos cómo difiere la **inicialización del sistema** entre tres familias de Microchip.

#### **PIC24FJ64GA002** (16 bits)

**Archivo: `_hard/pic24FJ64GA002/System/src/system.c`**

```c
void initSystem(void)
{
    CLKDIV = 0x3040;      // Configurar divisor de clock
    AD1PCFG = 0xFFFF;     // Deshabilitar entradas analógicas (todos digitales)
}
```

**Características:**
- **Muy simple** (2 registros)
- `CLKDIV`: Divisor de clock del sistema
- `AD1PCFG`: Configuración de pines analógicos/digitales

---

#### **dsPIC33EP512MC806** (16 bits con DSP)

**Archivo: `_hard/dsPIC33EP512MC806/System/src/system.c`**

```c
void initSystem(void)
{
    // Configuración del PLL
    _PLLPOST = 0;
    _PLLPRE = 0;
    _PLLDIV = 63;

    // Cambio de oscilador con funciones builtin
    __builtin_write_OSCCONH(0x01);
    __builtin_write_OSCCONL(OSCCON | 0x01);

    // Esperar cambio de clock
    while(OSCCONbits.COSC != 0b001);

    // Esperar que el PLL se bloquee
    while(OSCCONbits.LOCK != 1);

    // Deshabilitar entradas analógicas
    ANSELB = 0;
    ANSELC = 0;
    ANSELD = 0;
    ANSELE = 0;
    ANSELG = 0;
}
```

**Características:**
- **PLL manual** con divisores (`_PLLPOST`, `_PLLPRE`, `_PLLDIV`)
- **Funciones builtin** del compilador XC16
- **Espera activa** hasta que el PLL se estabilice
- **Múltiples registros ANSEL** por puerto

---

#### **PIC32MZ2048EFM064** (32 bits, MIPS)

**Archivo: `_hard/PIC32MZ2048EFM064/System/src/system.c`**

```c
void initSystem(void)
{
    // PIC32MZ System Initialization

    // ========================================
    // Desbloquear registros del sistema
    // ========================================
    SYSKEY = 0x00000000;
    SYSKEY = 0xAA996655;
    SYSKEY = 0x556699AA;

    // ========================================
    // Configurar SPLL (System PLL)
    // ========================================
    SPLLCONbits.PLLMULT = 50;    // PLLMULT = 50 (200 MHz desde 8MHz)
    SPLLCONbits.PLLODIV = 2;     // Dividir por 2 → 200MHz
    SPLLCONbits.PLLICLK = 1;     // Usar FRC como entrada del SPLL

    // ========================================
    // Configurar clocks periféricos
    // ========================================
    PB1DIVbits.ON = 1;           // Habilitar PBCLK1
    PB1DIVbits.PBDIV = 4;        // PBCLK1 = SYSCLK / 5 = 40MHz

    PB2DIVbits.ON = 1;           // Habilitar PBCLK2
    PB2DIVbits.PBDIV = 1;        // PBCLK2 = SYSCLK / 2 = 100MHz

    // ========================================
    // Deshabilitar todas las funciones analógicas
    // ========================================
    ANSELA = 0;
    ANSELB = 0;
    ANSELC = 0;
    ANSELD = 0;
    ANSELE = 0;
    ANSELF = 0;
    ANSELG = 0;

    // ========================================
    // Bloquear registros del sistema
    // ========================================
    SYSKEY = 0x00000000;

    // Esperar que el PLL se estabilice
    while(!(CLKSTATbits.SPLLRDY));
}
```

**Características:**
- **Sistema de protección SYSKEY** (seguridad)
- **PLL más complejo** con múltiples divisores
- **Clocks periféricos independientes** (PBCLK1, PBCLK2, etc.)
- **7 puertos con ANSEL** (vs 5 del dsPIC33)
- **200 MHz de clock** del sistema

---

### 5.2 Tabla Comparativa: System Initialization

| Aspecto | PIC24FJ64GA002 | dsPIC33EP512MC806 | PIC32MZ2048EFM064 |
|---------|----------------|-------------------|-------------------|
| **Complejidad** | Muy simple | Media | Alta |
| **Líneas de código** | ~4 | ~20 | ~40 |
| **Protección SYSKEY** | ❌ | ❌ | ✅ |
| **PLL manual** | ❌ | ✅ | ✅ |
| **Clocks periféricos** | Simple | Simple | Múltiples independientes |
| **Frecuencia típica** | 16-32 MHz | 60-70 MHz | 200 MHz |
| **Puertos analógicos** | 1 registro (`AD1PCFG`) | 5 registros (`ANSELB-G`) | 7 registros (`ANSELA-G`) |

**Conclusión:** A medida que el MCU es **más potente**, la inicialización se vuelve **más compleja**.

---

### 5.3 Comparación: Disponibilidad de Periféricos

| Periférico | PIC24FJ64GA002 | PIC32MZ2048 | dsPIC33EP512 | ARM Cortex-M4 (ejemplo) |
|-----------|----------------|-------------|--------------|------------------------|
| GPIO | ✅ | ✅ | ✅ | ✅ |
| UART | ✅ (2 módulos) | ✅ (6 módulos) | ✅ (4 módulos) | ✅ (múltiples) |
| SPI | ✅ | ✅ | ✅ | ✅ |
| I2C | ✅ | ✅ | ❌ | ✅ |
| Timer | ✅ (5 timers) | ✅ (9 timers) | ✅ (9 timers) | ✅ |
| ADC | ✅ (10-bit) | ✅ (12-bit) | ❌ | ✅ (12-bit) |
| PWM | ❌ | ✅ | ✅ | ✅ |
| I2S | ❌ | ✅ | ❌ | ✅ |
| CAN | ❌ | ✅ | ❌ | ✅ |
| USB | ❌ | ✅ | ❌ | ✅ |
| Flash (self-write) | ✅ | ❌ | ❌ | ✅ |

> **Importante**: `_hard/` refleja las **capacidades reales del MCU**. Si el chip no tiene I2C, no existirá la carpeta `I2C/` en su `_hard/`.

---

## 6. Relación con el HAL

El HAL **delega** todas las operaciones de hardware a `_hard/`.

### 6.1 Flujo de Ejecución

```
┌─────────────────────────────────────────────────────┐
│  Integrador escribe:                                │
│  LED.state(1);                                      │
└──────────────────┬──────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────────┐
│  API (led.emic):                                    │
│  LEDs_LED_state(uint8_t state)                      │
│  {                                                  │
│      HAL_GPIO_PinSet(LED, state);                   │
│  }                                                  │
└──────────────────┬──────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────────┐
│  HAL (_hal/GPIO/gpio.emic):                         │
│  EMIC:setInput(DEV:_hard/.{system.ucName}./GPIO/   │
│                gpio.emic)                           │
│                                                     │
│  Delega a: _hard/pic24FJ64GA002/GPIO/gpio.emic      │
└──────────────────┬──────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────────┐
│  _hard (pic24FJ64GA002/GPIO/inc/gpio.h):            │
│  #define HAL_GPIO_PinSet(name,value) PIN_##name = value│
│                                                     │
│  Expande a: PIN_LED = 1                             │
└──────────────────┬──────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────────┐
│  Pins (pic24FJ64GA002/pins/setPinB5.h):             │
│  #define PIN_LED _RB5                               │
│                                                     │
│  Expande a: _RB5 = 1                                │
└──────────────────┬──────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────────┐
│  Registro del PIC24FJ64GA002:                       │
│  PORTB bit 5 = 1 (HIGH)                             │
│  → Pin físico 14 en el chip → LED enciende         │
└─────────────────────────────────────────────────────┘
```

### 6.2 Ventajas de esta Arquitectura

| Ventaja | Descripción |
|---------|-------------|
| **Portabilidad** | Cambiar de MCU solo requiere cambiar `system.ucName` |
| **Abstracción** | El integrador no necesita saber que `_RB5` es un registro |
| **Mantenibilidad** | Cada MCU tiene su código aislado en su carpeta |
| **Escalabilidad** | Agregar nuevo MCU = crear nueva carpeta en `_hard/` |
| **Testing** | Puedes testear implementaciones específicas por separado |

---

## 7. Agregar Soporte para Nuevo MCU

Si quieres **agregar soporte para un nuevo microcontrolador**, sigue estos pasos:

### 7.1 Proceso General

```
1. Crear carpeta en _hard/
   ├── _hard/NUEVO_MCU/

2. Implementar periféricos necesarios
   ├── GPIO/
   ├── UART/
   ├── SPI/
   ├── I2C/
   ├── Timer/
   ├── ADC/
   ├── System/
   └── pins/ (opcional)

3. Adaptar código a registros del nuevo MCU
   (ej: U1BRG → UART1->BRR para STM32)

4. Configurar compilador en SDK
   (ej: XC16 → GCC ARM)

5. Probar con módulo simple
   (ej: LED blink)

6. Validar cada periférico
```

### 7.2 Ejemplo Práctico: Agregar STM32F407VG (ARM Cortex-M4)

#### Paso 1: Crear estructura de carpetas

```bash
mkdir _hard/STM32F407VG
mkdir _hard/STM32F407VG/GPIO
mkdir _hard/STM32F407VG/UART
mkdir _hard/STM32F407VG/SPI
mkdir _hard/STM32F407VG/I2C
mkdir _hard/STM32F407VG/Timer
mkdir _hard/STM32F407VG/ADC
mkdir _hard/STM32F407VG/System
```

#### Paso 2: Implementar GPIO para STM32

**Archivo: `_hard/STM32F407VG/GPIO/gpio.emic`**

```emic
EMIC:ifndef _STM32_GPIO_EMIC_
EMIC:define(_STM32_GPIO_EMIC_,true)

EMIC:copy(inc/gpio.h > TARGET:/inc/gpio.h)

EMIC:endif
```

**Archivo: `_hard/STM32F407VG/GPIO/inc/gpio.h`**

```c
#ifndef STM32_GPIO_H_
#define STM32_GPIO_H_

#include "stm32f4xx.h"  // Header de ST para STM32F4

typedef enum
{
    GPIO_OUTPUT,
    GPIO_INPUT,
} gpio_pinConfig_t;

typedef enum
{
    GPIO_LOW,
    GPIO_HIGH,
    GPIO_TOGGLE
} gpio_state_t;

// ========================================
// Macros HAL - Implementación para STM32
// ========================================
// Nota: En STM32, los pines se configuran de forma diferente a PIC

#define HAL_GPIO_PinCfg(name, cfg_value) \
    do { \
        if (cfg_value == GPIO_OUTPUT) { \
            GPIO_PORT_##name->MODER |= (1 << (GPIO_PIN_##name * 2)); \
        } else { \
            GPIO_PORT_##name->MODER &= ~(3 << (GPIO_PIN_##name * 2)); \
        } \
    } while(0)

#define HAL_GPIO_PinSet(name, value) \
    do { \
        if (value == GPIO_HIGH) { \
            GPIO_PORT_##name->BSRR = (1 << GPIO_PIN_##name); \
        } else if (value == GPIO_LOW) { \
            GPIO_PORT_##name->BSRR = (1 << (GPIO_PIN_##name + 16)); \
        } else if (value == GPIO_TOGGLE) { \
            GPIO_PORT_##name->ODR ^= (1 << GPIO_PIN_##name); \
        } \
    } while(0)

#define HAL_GPIO_PinGet(name) \
    ((GPIO_PORT_##name->IDR >> GPIO_PIN_##name) & 1)

#endif
```

**Explicación de diferencias PIC24 vs STM32:**

| Aspecto | PIC24FJ64GA002 | STM32F407VG |
|---------|----------------|-------------|
| **Registro de dirección** | `TRIS` (1 bit por pin) | `MODER` (2 bits por pin) |
| **Lectura de pin** | `PORT` | `IDR` (Input Data Register) |
| **Escritura de pin** | `LAT` | `ODR` (Output Data Register) |
| **Set/Clear atómico** | No disponible | `BSRR` (Bit Set/Reset Register) |
| **Toggle** | Lectura + XOR | XOR en `ODR` |

#### Paso 3: Implementar System para STM32

**Archivo: `_hard/STM32F407VG/System/src/system.c`**

```c
#include "stm32f4xx.h"

void initSystem(void)
{
    // ========================================
    // Habilitar HSE (High Speed External) - 8 MHz
    // ========================================
    RCC->CR |= RCC_CR_HSEON;
    while(!(RCC->CR & RCC_CR_HSERDY));

    // ========================================
    // Configurar PLL para 168 MHz
    // PLL = HSE * (PLLN / PLLM) / PLLP
    // PLL = 8 MHz * (336 / 8) / 2 = 168 MHz
    // ========================================
    RCC->PLLCFGR = (8 << 0)        // PLLM = 8
                 | (336 << 6)      // PLLN = 336
                 | (0 << 16)       // PLLP = 2 (00 = /2)
                 | (RCC_PLLCFGR_PLLSRC_HSE)  // Fuente = HSE
                 | (7 << 24);      // PLLQ = 7

    // Habilitar PLL
    RCC->CR |= RCC_CR_PLLON;
    while(!(RCC->CR & RCC_CR_PLLRDY));

    // ========================================
    // Configurar Flash latency (5 wait states para 168MHz)
    // ========================================
    FLASH->ACR = FLASH_ACR_ICEN | FLASH_ACR_DCEN | FLASH_ACR_LATENCY_5WS;

    // ========================================
    // Configurar divisores de bus
    // ========================================
    RCC->CFGR |= RCC_CFGR_HPRE_DIV1;    // AHB  = 168 MHz
    RCC->CFGR |= RCC_CFGR_PPRE2_DIV2;   // APB2 = 84 MHz
    RCC->CFGR |= RCC_CFGR_PPRE1_DIV4;   // APB1 = 42 MHz

    // ========================================
    // Seleccionar PLL como fuente de clock del sistema
    // ========================================
    RCC->CFGR |= RCC_CFGR_SW_PLL;
    while((RCC->CFGR & RCC_CFGR_SWS) != RCC_CFGR_SWS_PLL);

    // ========================================
    // Habilitar clocks de periféricos GPIO
    // ========================================
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN
                  | RCC_AHB1ENR_GPIOBEN
                  | RCC_AHB1ENR_GPIOCEN
                  | RCC_AHB1ENR_GPIODEN
                  | RCC_AHB1ENR_GPIOEEN;
}
```

**Comparación de complejidad:**

```
PIC24FJ64GA002:   ~4 líneas de código
STM32F407VG:      ~50 líneas de código
```

> **Nota**: La arquitectura ARM Cortex-M es **mucho más compleja** en configuración de clocks que los PIC de 16 bits.

#### Paso 4: Actualizar configuración del SDK

En el archivo `module.json` del proyecto, especificar el nuevo MCU:

```json
{
    "system": {
        "ucName": "STM32F407VG",
        "compiler": "arm-none-eabi-gcc",
        "compilerPath": "C:/Program Files/GNU Arm Embedded Toolchain/bin/",
        "architecture": "ARM Cortex-M4"
    }
}
```

El HAL automáticamente buscará en `_hard/STM32F407VG/` al compilar.

---

## 8. Buenas Prácticas

### 8.1 Organización de Código

✅ **HACER:**
- Un archivo `.emic` por periférico
- Separar `.h` en `inc/` y `.c` en `src/`
- Usar macros HAL consistentes entre MCUs
- Documentar registros específicos con comentarios

❌ **EVITAR:**
- Código hardcodeado sin macros de EMIC-Codify
- Mezclar múltiples periféricos en un solo archivo
- Depender de headers de otros MCUs

### 8.2 Nomenclatura de Registros

**Convención:**
```c
// PIC: Usar nombres directos del datasheet
U1BRG   // UART1 Baud Rate Generator
SPI1CON // SPI1 Control Register

// ARM: Usar estructuras de ST/NXP
UART1->BRR   // UART1 Baud Rate Register
SPI1->CR1    // SPI1 Control Register 1
```

### 8.3 Compatibilidad con HAL

**CRÍTICO**: Las macros HAL deben ser **idénticas** entre MCUs.

```c
// _hard/pic24FJ64GA002/GPIO/inc/gpio.h
#define HAL_GPIO_PinCfg(name,cfg_value) TRIS_##name = cfg_value

// _hard/STM32F407VG/GPIO/inc/gpio.h
#define HAL_GPIO_PinCfg(name,cfg_value) /* implementación diferente pero misma firma */
```

El HAL espera:
- `HAL_GPIO_PinCfg(name, value)`
- `HAL_GPIO_PinSet(name, value)`
- `HAL_GPIO_PinGet(name)`

**No cambies los nombres de las macros HAL** entre MCUs.

### 8.4 Documentación de Diferencias

Documenta las **diferencias clave** entre MCUs:

```c
/*
 * PIC24FJ64GA002:
 * - UART tiene U1MODE, U1STA, U1BRG
 * - Baud rate: BRG = (FCY / (16 * baudrate)) - 1
 *
 * STM32F407VG:
 * - UART tiene USART1->CR1, USART1->SR, USART1->BRR
 * - Baud rate: BRR = (APB_Clock / baudrate)
 *
 * Ambos implementan la misma interfaz HAL.
 */
```

---

## 9. Ejercicio Práctico

### Ejercicio: Implementar `_hard/` para AVR ATMEGA328P

**Objetivo**: Agregar soporte para el microcontrolador **ATMEGA328P** (usado en Arduino Uno).

#### Requisitos:
1. Crear carpeta `_hard/ATMEGA328P/`
2. Implementar **GPIO** compatible con HAL
3. Implementar **System** con inicialización básica
4. Implementar **UART** con baud rate configurable

#### Pistas:

**Registros GPIO en AVR:**
- `DDRx`: Data Direction Register (0=input, 1=output)
- `PORTx`: Output data
- `PINx`: Input data

**Registros UART en AVR:**
- `UBRR0`: Baud Rate Register
- `UCSR0A`, `UCSR0B`, `UCSR0C`: Control/Status Registers
- `UDR0`: Data Register

**Fórmula baud rate:**
```c
UBRR0 = (F_CPU / (16 * baudrate)) - 1;
```

#### Solución (parcial):

**`_hard/ATMEGA328P/GPIO/inc/gpio.h`**

```c
#ifndef AVR_GPIO_H_
#define AVR_GPIO_H_

#include <avr/io.h>

typedef enum {
    GPIO_OUTPUT,
    GPIO_INPUT,
} gpio_pinConfig_t;

typedef enum {
    GPIO_LOW,
    GPIO_HIGH,
    GPIO_TOGGLE
} gpio_state_t;

// Macros HAL para AVR
#define HAL_GPIO_PinCfg(name, cfg_value) DDR_##name = cfg_value
#define HAL_GPIO_PinSet(name, value) \
    do { \
        if (value == GPIO_HIGH) PORT_##name = 1; \
        else if (value == GPIO_LOW) PORT_##name = 0; \
        else PORT_##name ^= 1; \
    } while(0)
#define HAL_GPIO_PinGet(name) PIN_##name

#endif
```

**`_hard/ATMEGA328P/System/src/system.c`**

```c
#include <avr/io.h>

void initSystem(void)
{
    // ATMEGA328P no requiere configuración de clock
    // (usa oscilador interno de 8 MHz por defecto)
    // Deshabilitar entradas analógicas (todas digitales)
    ADCSRA = 0;     // Deshabilitar ADC
    ACSR = (1 << ACD);  // Deshabilitar comparador analógico
}
```

---

## Resumen

| Concepto | Descripción |
|----------|-------------|
| **_hard/** | Carpeta con código específico para cada MCU |
| **Nivel más bajo** | Acceso directo a registros del hardware |
| **No portable** | Cada MCU tiene su propia implementación |
| **Organización** | Una carpeta por familia de MCU |
| **Periféricos** | GPIO, UART, SPI, I2C, Timer, ADC, PWM, System, etc. |
| **Relación con HAL** | El HAL delega a `_hard/` según `system.ucName` |
| **Extensibilidad** | Agregar nuevo MCU = crear nueva carpeta |

---

## Próximos Pasos

En el **Capítulo 11** exploraremos la carpeta **`_main/`**, donde se define el **punto de entrada principal** del firmware generado por EMIC.

---

**¿Preguntas?**
La carpeta `_hard/` es el **corazón de la portabilidad** del SDK EMIC. Aunque el código aquí **NO es portable**, su **arquitectura modular** permite soportar múltiples MCUs sin reescribir las capas superiores (API, Drivers, Módulos).
