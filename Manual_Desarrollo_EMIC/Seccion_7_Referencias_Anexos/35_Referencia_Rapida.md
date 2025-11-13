# Capítulo 35: Referencia Rápida EMIC-Codify

> **Quick Reference Guide** - Guía de consulta rápida para sintaxis, directivas y patrones EMIC-Codify

---

## 📋 Índice

1. [Sintaxis Básica](#1-sintaxis-básica)
2. [Directivas EMIC-Codify](#2-directivas-emic-codify)
3. [Tags de Publicación](#3-tags-de-publicación)
4. [Tipos de Datos](#4-tipos-de-datos)
5. [config.json Template](#5-configjson-template)
6. [module.json Template](#6-modulejson-template)
7. [generate.emic Syntax](#7-generateemic-syntax)
8. [deploy.emic Syntax](#8-deployemic-syntax)
9. [Funciones SDK Comunes](#9-funciones-sdk-comunes)
10. [Patrones Comunes](#10-patrones-comunes)
11. [Volúmenes Lógicos](#11-volúmenes-lógicos)
12. [Comandos CLI](#12-comandos-cli)
13. [Troubleshooting Rápido](#13-troubleshooting-rápido)
14. [Shortcuts y Tips](#14-shortcuts-y-tips)
15. [Referencias Cruzadas](#15-referencias-cruzadas)

---

## 1. Sintaxis Básica

### Estructura de Tags EMIC-Codify

```c
/*** EMIC-Codify: Module Header ***/
// Comentario normal C

//@pub func nombre_funcion
void nombre_funcion(void) {
    // Implementación
}

//@pub var variable_global
uint8_t variable_global = 0;

//@pub:readonly var sensor_value
uint16_t sensor_value;
```

### Convenciones de Nomenclatura

| Elemento | Convención | Ejemplo |
|----------|------------|---------|
| Funciones públicas | PascalCase o snake_case | `LED_Toggle()` o `led_toggle()` |
| Variables públicas | snake_case | `sensor_temperature` |
| Constantes | UPPER_CASE | `MAX_BUFFER_SIZE` |
| Módulos | PascalCase | `UARTDriver` |
| Archivos | snake_case | `uart_driver.c` |

---

## 2. Directivas EMIC-Codify

### Tabla Completa de Directivas

| Directiva | Sintaxis | Propósito | Scope |
|-----------|----------|-----------|-------|
| `@pub` | `@pub tipo nombre` | Publicar recurso al SDK | Global |
| `@app` | `@app tipo nombre` | Recurso de aplicación (no SDK) | Local |
| `@cfg` | `@cfg param` | Parámetro configurable | Module |
| `@init` | `@init prioridad` | Función de inicialización | Module |
| `@loop` | `@loop` | Función de loop principal | Module |
| `@isr` | `@isr vector` | Interrupt Service Routine | Global |
| `@task` | `@task nombre` | Definir task RTOS | Module |
| `@module` | `@module nombre` | Definir módulo | File |
| `@include` | `@include "path"` | Include archivo | File |
| `@require` | `@require modulo` | Dependencia de módulo | Module |
| `@version` | `@version X.Y.Z` | Control de versión | Module |
| `@author` | `@author "Nombre"` | Metadata autor | Module |
| `@description` | `@description "texto"` | Documentación | Any |
| `@param` | `@param nombre descripción` | Documentar parámetro | Function |
| `@return` | `@return descripción` | Documentar retorno | Function |
| `@example` | `@example codigo` | Ejemplo de uso | Any |

### Ejemplos de Uso

```c
//@module UARTDriver
//@version 1.2.0
//@author "EMIC Team"
//@description "Driver UART para PIC32MZ"
//@require GPIO
//@require ClockConfig

//@pub func UART_Init
//@param baudrate Baudrate deseado (9600, 115200, etc)
//@return true si inicialización exitosa
//@example UART_Init(115200);
bool UART_Init(uint32_t baudrate) {
    // Implementación
}

//@pub:readonly var uart_rx_buffer
uint8_t uart_rx_buffer[256];

//@cfg UART_BUFFER_SIZE
#define UART_BUFFER_SIZE 256

//@init 10
void UART_Initialize(void) {
    UART_Init(115200);
}

//@isr UART1_RX
void __ISR(_UART1_RX_VECTOR) UART1_RX_Handler(void) {
    // Handler ISR
}
```

---

## 3. Tags de Publicación

### Tabla de Tags @pub

| Tag | Sintaxis | Acceso | Ejemplo |
|-----|----------|--------|---------|
| `@pub func` | `@pub func nombre` | Read/Execute | `@pub func LED_On` |
| `@pub var` | `@pub var nombre` | Read/Write | `@pub var counter` |
| `@pub:readonly var` | `@pub:readonly var nombre` | Read-only | `@pub:readonly var status` |
| `@pub:writeonly var` | `@pub:writeonly var nombre` | Write-only | `@pub:writeonly var command` |
| `@pub:const` | `@pub:const NOMBRE valor` | Constante | `@pub:const MAX_TEMP 85` |
| `@pub struct` | `@pub struct nombre` | Tipo público | `@pub struct SensorData` |
| `@pub enum` | `@pub enum nombre` | Enum público | `@pub enum State` |

### Ejemplos Completos

```c
//@pub func GPIO_SetOutput
void GPIO_SetOutput(uint8_t pin) {
    // Implementación
}

//@pub var global_counter
volatile uint32_t global_counter = 0;

//@pub:readonly var sensor_temperature
int16_t sensor_temperature;  // Solo lectura desde integrador

//@pub:writeonly var led_brightness
uint8_t led_brightness;  // Solo escritura desde integrador

//@pub:const MAX_SENSORS 8
#define MAX_SENSORS 8

//@pub struct SensorData_t
typedef struct {
    float temperature;
    float humidity;
    uint32_t timestamp;
} SensorData_t;

//@pub enum DeviceState_t
typedef enum {
    STATE_IDLE = 0,
    STATE_ACTIVE,
    STATE_ERROR
} DeviceState_t;
```

---

## 4. Tipos de Datos

### Tipos Primitivos Soportados

| Tipo C | Tamaño | Rango | Uso EMIC |
|--------|--------|-------|----------|
| `uint8_t` | 8 bits | 0 - 255 | ✅ Recomendado |
| `int8_t` | 8 bits | -128 - 127 | ✅ Recomendado |
| `uint16_t` | 16 bits | 0 - 65535 | ✅ Recomendado |
| `int16_t` | 16 bits | -32768 - 32767 | ✅ Recomendado |
| `uint32_t` | 16 bits | 0 - 4294967295 | ✅ Recomendado |
| `int32_t` | 32 bits | -2147483648 - 2147483647 | ✅ Recomendado |
| `float` | 32 bits | ±3.4e±38 | ✅ OK |
| `double` | 64 bits | ±1.7e±308 | ⚠️ Costoso en 16-bit MCU |
| `bool` | 8 bits | true/false | ✅ Recomendado |
| `char` | 8 bits | -128 - 127 | ✅ OK |
| `char*` | puntero | - | ✅ OK |
| `void` | - | - | ✅ Para funciones sin retorno |

### Tipos Complejos

```c
// Estructuras
//@pub struct Point2D_t
typedef struct {
    int16_t x;
    int16_t y;
} Point2D_t;

// Enumeraciones
//@pub enum MotorDirection_t
typedef enum {
    MOTOR_STOP = 0,
    MOTOR_FORWARD,
    MOTOR_REVERSE
} MotorDirection_t;

// Arrays
//@pub var data_buffer
uint8_t data_buffer[256];

// Punteros a función
typedef void (*CallbackFunc_t)(void);

// Uniones (poco común en EMIC)
typedef union {
    uint32_t word;
    uint8_t bytes[4];
} DataUnion_t;
```

---

## 5. config.json Template

### Template Básico

```json
{
  "module": "nombre_modulo",
  "version": "1.0.0",
  "config": {
    "parametro1": {
      "type": "uint8_t",
      "default": 10,
      "min": 0,
      "max": 255,
      "description": "Descripción del parámetro",
      "unit": "ms"
    },
    "parametro2": {
      "type": "bool",
      "default": true,
      "description": "Habilitar funcionalidad"
    },
    "parametro3": {
      "type": "string",
      "default": "value",
      "options": ["value", "other"],
      "description": "Selección de opciones"
    }
  }
}
```

### Tipos de Parámetros Soportados

| Tipo | Campos Requeridos | Campos Opcionales | Ejemplo |
|------|-------------------|-------------------|---------|
| `uint8_t`, `uint16_t`, `uint32_t` | `type`, `default` | `min`, `max`, `unit`, `step` | Baudrate: 115200 |
| `int8_t`, `int16_t`, `int32_t` | `type`, `default` | `min`, `max`, `unit`, `step` | Offset: -10 |
| `float`, `double` | `type`, `default` | `min`, `max`, `unit`, `precision` | Temperatura: 25.5 |
| `bool` | `type`, `default` | - | Enabled: true |
| `string` | `type`, `default` | `options`, `max_length` | Mode: "AUTO" |
| `enum` | `type`, `default`, `options` | - | State: "IDLE" |

### Ejemplo Completo

```json
{
  "module": "UARTDriver",
  "version": "1.2.0",
  "config": {
    "baudrate": {
      "type": "uint32_t",
      "default": 115200,
      "options": [9600, 19200, 38400, 57600, 115200, 230400],
      "description": "Baudrate UART",
      "unit": "bps"
    },
    "data_bits": {
      "type": "uint8_t",
      "default": 8,
      "min": 7,
      "max": 9,
      "description": "Número de bits de datos"
    },
    "parity": {
      "type": "string",
      "default": "NONE",
      "options": ["NONE", "EVEN", "ODD"],
      "description": "Paridad"
    },
    "stop_bits": {
      "type": "uint8_t",
      "default": 1,
      "options": [1, 2],
      "description": "Stop bits"
    },
    "enable_interrupts": {
      "type": "bool",
      "default": true,
      "description": "Habilitar interrupciones RX"
    },
    "rx_buffer_size": {
      "type": "uint16_t",
      "default": 256,
      "min": 16,
      "max": 4096,
      "step": 16,
      "description": "Tamaño buffer RX",
      "unit": "bytes"
    }
  }
}
```

---

## 6. module.json Template

### Template Básico

```json
{
  "name": "ModuleName",
  "category": "Drivers",
  "description": "Module description",
  "version": "1.0.0",
  "author": "Author Name",
  "license": "MIT",
  "tags": ["uart", "communication"],
  "dependencies": [],
  "hardware": ["PIC32MZ", "dsPIC33"],
  "peripherals": ["UART1", "UART2"],
  "resources": {
    "flash": 2048,
    "ram": 512
  }
}
```

### Campos Disponibles

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `name` | string | ✅ | Nombre del módulo (PascalCase) |
| `category` | string | ✅ | Categoría (Drivers, API, HAL, etc) |
| `description` | string | ✅ | Descripción breve |
| `version` | string | ✅ | Versión SemVer (X.Y.Z) |
| `author` | string | ❌ | Autor del módulo |
| `license` | string | ❌ | Licencia (MIT, GPL, Apache, etc) |
| `tags` | array | ❌ | Tags para búsqueda |
| `dependencies` | array | ❌ | Módulos requeridos |
| `hardware` | array | ❌ | MCUs soportados |
| `peripherals` | array | ❌ | Periféricos usados |
| `resources` | object | ❌ | Uso de recursos (flash, ram) |

### Ejemplo Completo

```json
{
  "name": "UARTDriver",
  "category": "Drivers",
  "subcategory": "Communication",
  "description": "Driver UART con soporte DMA e interrupciones para PIC32MZ",
  "version": "1.2.3",
  "author": "EMIC Team",
  "license": "MIT",
  "tags": ["uart", "serial", "communication", "dma", "interrupts"],
  "dependencies": [
    "GPIO",
    "ClockConfig",
    "DMA"
  ],
  "hardware": [
    "PIC32MZ2048EFH",
    "PIC32MZ2048EFG",
    "dsPIC33EP512MU810"
  ],
  "peripherals": [
    "UART1",
    "UART2",
    "DMA0",
    "DMA1"
  ],
  "resources": {
    "flash": 2048,
    "ram": 512,
    "timers": 0,
    "dma_channels": 2
  },
  "documentation": "https://docs.emic.io/drivers/uart",
  "repository": "https://github.com/EMIC/uart-driver"
}
```

---

## 7. generate.emic Syntax

### Estructura de Bloques

```
┌─────────────────────────────────────────┐
│ generate.emic                           │
├─────────────────────────────────────────┤
│ INCLUDE { ... }          ← Includes     │
│ DEFINES { ... }          ← Defines      │
│ DECLARATIONS { ... }     ← Variables    │
│ INIT { ... }             ← Setup code   │
│ LOOP { ... }             ← Main loop    │
│ FUNCTIONS { ... }        ← Funciones    │
│ INTERRUPTS { ... }       ← ISRs         │
└─────────────────────────────────────────┘
```

### Template Completo

```c
/*** EMIC-Generate: Main Application ***/

INCLUDE {
    #include <stdint.h>
    #include <stdbool.h>
    #include "DEV:/api/uart.h"
    #include "DEV:/api/gpio.h"
    #include "DEV:/drivers/sensor.h"
}

DEFINES {
    #define LED_PIN 10
    #define SENSOR_ADDR 0x48
    #define SAMPLE_RATE_MS 100
}

DECLARATIONS {
    // Variables globales
    volatile uint32_t tick_counter = 0;
    uint16_t sensor_value = 0;
    bool system_ready = false;

    // Buffers
    uint8_t uart_rx_buffer[256];
    uint8_t uart_tx_buffer[256];
}

INIT {
    // Inicialización del sistema
    GPIO_SetOutput(LED_PIN);
    UART_Init(115200);
    Sensor_Init(SENSOR_ADDR);

    UART_WriteString("System starting...\r\n");

    // Configurar timer para 1 ms tick
    TIMER_Init(1);
    TIMER_Start();

    system_ready = true;
}

LOOP {
    // Loop principal
    if (tick_counter >= SAMPLE_RATE_MS) {
        tick_counter = 0;

        // Leer sensor
        sensor_value = Sensor_Read();

        // Toggle LED
        GPIO_Toggle(LED_PIN);

        // Enviar por UART
        char buffer[32];
        sprintf(buffer, "Sensor: %u\r\n", sensor_value);
        UART_WriteString(buffer);
    }

    // Procesar UART RX
    if (UART_Available()) {
        uint8_t byte = UART_ReadChar();
        ProcessCommand(byte);
    }
}

FUNCTIONS {
    void ProcessCommand(uint8_t cmd) {
        switch (cmd) {
            case 'R':
                // Reset sensor
                Sensor_Init(SENSOR_ADDR);
                break;
            case 'S':
                // Get status
                UART_WriteString("Status: OK\r\n");
                break;
            default:
                UART_WriteString("Unknown command\r\n");
        }
    }
}

INTERRUPTS {
    // Timer1 interrupt @ 1 kHz
    void __ISR(_TIMER_1_VECTOR) Timer1_Handler(void) {
        tick_counter++;
        IFS0CLR = _IFS0_T1IF_MASK;  // Clear flag
    }
}
```

### Bloques Opcionales

| Bloque | Requerido | Orden | Propósito |
|--------|-----------|-------|-----------|
| `INCLUDE` | ❌ | 1 | Includes de headers |
| `DEFINES` | ❌ | 2 | Definiciones y macros |
| `DECLARATIONS` | ❌ | 3 | Variables globales |
| `INIT` | ✅ | 4 | Código de inicialización (ejecuta una vez) |
| `LOOP` | ✅ | 5 | Loop principal (ejecuta infinitamente) |
| `FUNCTIONS` | ❌ | 6 | Definiciones de funciones auxiliares |
| `INTERRUPTS` | ❌ | 7 | Interrupt Service Routines |

---

## 8. deploy.emic Syntax

### Estructura de Bloques

```
┌─────────────────────────────────────────┐
│ deploy.emic                             │
├─────────────────────────────────────────┤
│ COMPILER { ... }         ← Config XC    │
│ LINKER { ... }           ← Linker opts  │
│ POST_BUILD { ... }       ← Post-build   │
│ FLASH { ... }            ← Flasher      │
└─────────────────────────────────────────┘
```

### Template Completo

```c
/*** EMIC-Deploy: Build Configuration ***/

COMPILER {
    // XC32 Compiler options
    COMPILER = "XC32"
    VERSION = "4.35"

    // Optimization
    OPTIMIZATION = "2"  // -O2

    // Compiler flags
    FLAGS {
        -mprocessor=32MZ2048EFH144
        -Wall
        -Wextra
        -fno-common
        -ffunction-sections
        -fdata-sections
    }

    // Defines
    DEFINES {
        __PIC32MZ__
        FCPU=200000000UL
        PERIPHERAL_CLOCK=100000000UL
    }

    // Include paths
    INCLUDES {
        "DEV:/_system/inc"
        "DEV:/_hal/pic32mz/inc"
        "TARGET:/build"
    }
}

LINKER {
    // Linker script
    SCRIPT = "DEV:/_hard/pic32mz/linker/procdefs.ld"

    // Linker flags
    FLAGS {
        -Wl,--gc-sections
        -Wl,--defsym=_min_heap_size=8192
        -Wl,--defsym=_min_stack_size=2048
    }

    // Libraries
    LIBRARIES {
        m      // Math library
        c      // Standard C library
    }
}

POST_BUILD {
    // Generar archivo HEX
    COMMAND = "xc32-bin2hex"
    ARGS {
        "TARGET:/build/firmware.elf"
    }

    // Calcular checksum
    EXEC {
        python calculate_checksum.py TARGET:/build/firmware.hex
    }

    // Copiar a carpeta release
    COPY {
        FROM = "TARGET:/build/firmware.hex"
        TO = "TARGET:/release/firmware_v1.0.hex"
    }
}

FLASH {
    // Programmer configuration
    TOOL = "ICD4"
    DEVICE = "PIC32MZ2048EFH144"

    // Flash options
    OPTIONS {
        ERASE_ALL = true
        VERIFY = true
        RUN_AFTER = true
    }

    // Command
    COMMAND = "ipecmd.exe"
    ARGS {
        -P32MZ2048EFH144
        -TPICD4
        -M
        -F"TARGET:/build/firmware.hex"
    }
}
```

### Opciones de Compilador

| Opción | Valores | Descripción |
|--------|---------|-------------|
| `COMPILER` | XC8, XC16, XC32 | Toolchain a usar |
| `VERSION` | X.YY | Versión del compilador |
| `OPTIMIZATION` | 0, 1, 2, 3, s | Nivel de optimización |
| `DEVICE` | PIC32MZ2048EFH144 | Microcontrolador target |

### Niveles de Optimización

| Nivel | Descripción | Uso |
|-------|-------------|-----|
| `-O0` | Sin optimización | Debug |
| `-O1` | Optimización básica | Development |
| `-O2` | Optimización moderada | Production |
| `-O3` | Optimización agresiva | Performance critical |
| `-Os` | Optimizar tamaño | Memoria limitada |

---

## 9. Funciones SDK Comunes

### GPIO API

```c
// Configuración
void GPIO_SetOutput(uint8_t pin);
void GPIO_SetInput(uint8_t pin);
void GPIO_SetOpenDrain(uint8_t pin);
void GPIO_SetPullup(uint8_t pin, bool enable);

// Operaciones
void GPIO_Write(uint8_t pin, bool value);
bool GPIO_Read(uint8_t pin);
void GPIO_Toggle(uint8_t pin);

// Ejemplo
GPIO_SetOutput(LED_PIN);
GPIO_Write(LED_PIN, true);   // LED ON
GPIO_Toggle(LED_PIN);         // Toggle state
```

### UART API

```c
// Inicialización
bool UART_Init(uint32_t baudrate);
void UART_Close(void);

// Escritura
void UART_WriteChar(char c);
void UART_WriteString(const char* str);
void UART_WriteBuffer(const uint8_t* data, uint16_t len);
void UART_Printf(const char* format, ...);

// Lectura
char UART_ReadChar(void);
uint16_t UART_ReadBuffer(uint8_t* buffer, uint16_t max_len);
uint16_t UART_Available(void);
void UART_Flush(void);

// Ejemplo
UART_Init(115200);
UART_WriteString("Hello EMIC!\r\n");
if (UART_Available() > 0) {
    char c = UART_ReadChar();
}
```

### SPI API

```c
// Inicialización
bool SPI_Init(uint8_t mode, uint32_t clock_hz);
void SPI_Close(void);

// Configuración
void SPI_SetMode(uint8_t mode);  // 0, 1, 2, 3
void SPI_SetClock(uint32_t clock_hz);
void SPI_SetBitOrder(bool msb_first);

// Transferencia
uint8_t SPI_Transfer(uint8_t data);
void SPI_TransferBuffer(uint8_t* tx_buf, uint8_t* rx_buf, uint16_t len);
void SPI_Write(uint8_t data);
uint8_t SPI_Read(void);

// Ejemplo
SPI_Init(SPI_MODE_0, 1000000);  // 1 MHz
uint8_t response = SPI_Transfer(0xAA);
```

### I2C API

```c
// Inicialización
bool I2C_Init(uint32_t clock_hz);
void I2C_Close(void);

// Operaciones de bajo nivel
void I2C_Start(void);
void I2C_Stop(void);
void I2C_Restart(void);
bool I2C_Write(uint8_t data);
uint8_t I2C_Read(bool ack);

// Operaciones de alto nivel
bool I2C_WriteRegister(uint8_t addr, uint8_t reg, uint8_t value);
uint8_t I2C_ReadRegister(uint8_t addr, uint8_t reg);
bool I2C_WriteBuffer(uint8_t addr, const uint8_t* data, uint16_t len);
bool I2C_ReadBuffer(uint8_t addr, uint8_t* data, uint16_t len);

// Ejemplo
I2C_Init(100000);  // 100 kHz
I2C_WriteRegister(0x48, 0x01, 0xFF);  // Sensor addr 0x48, reg 0x01
uint8_t value = I2C_ReadRegister(0x48, 0x00);
```

### Timer API

```c
// Inicialización
bool TIMER_Init(uint16_t period_ms);
void TIMER_Close(void);

// Control
void TIMER_Start(void);
void TIMER_Stop(void);
void TIMER_Reset(void);

// Operaciones
uint32_t TIMER_GetTicks(void);
uint32_t TIMER_GetMillis(void);
void TIMER_Delay(uint32_t ms);
void TIMER_DelayMicros(uint32_t us);

// Callbacks
void TIMER_SetCallback(void (*callback)(void));

// Ejemplo
TIMER_Init(1);  // 1 ms tick
TIMER_Start();
TIMER_Delay(1000);  // Delay 1 segundo
uint32_t uptime_ms = TIMER_GetMillis();
```

### ADC API

```c
// Inicialización
bool ADC_Init(void);
void ADC_Close(void);

// Configuración
void ADC_SetChannel(uint8_t channel);
void ADC_SetReference(uint8_t ref);  // VREF, VDD, etc
void ADC_SetSampleTime(uint16_t us);

// Lectura
uint16_t ADC_Read(uint8_t channel);
float ADC_ReadVoltage(uint8_t channel);
uint16_t ADC_ReadAverage(uint8_t channel, uint8_t samples);

// Ejemplo
ADC_Init();
uint16_t raw = ADC_Read(0);  // Canal 0
float voltage = ADC_ReadVoltage(0);  // Conversión a voltios
```

### PWM API

```c
// Inicialización
bool PWM_Init(uint8_t channel, uint32_t frequency_hz);
void PWM_Close(uint8_t channel);

// Control
void PWM_Start(uint8_t channel);
void PWM_Stop(uint8_t channel);
void PWM_SetDutyCycle(uint8_t channel, uint8_t percent);  // 0-100
void PWM_SetDutyCycleRaw(uint8_t channel, uint16_t value);

// Ejemplo
PWM_Init(1, 1000);  // Canal 1, 1 kHz
PWM_SetDutyCycle(1, 50);  // 50% duty cycle
PWM_Start(1);
```

---

## 10. Patrones Comunes

### 1. Module Initialization Pattern

```c
//@pub func ModuleName_Init
bool ModuleName_Init(void) {
    // 1. Check if already initialized
    if (module_initialized) {
        return true;
    }

    // 2. Initialize hardware dependencies
    if (!DependencyModule_Init()) {
        return false;
    }

    // 3. Configure hardware registers
    U1MODE = 0x8000;  // Enable UART1
    U1STA = 0x1400;   // Enable TX and RX
    U1BRG = calculate_brg(115200);

    // 4. Initialize internal state
    rx_head = 0;
    rx_tail = 0;
    memset(rx_buffer, 0, sizeof(rx_buffer));

    // 5. Enable interrupts if needed
    IEC0SET = _IEC0_U1RXIE_MASK;
    IPC6SET = (5 << _IPC6_U1IP_POSITION);

    // 6. Mark as initialized
    module_initialized = true;

    return true;
}
```

### 2. ISR Handler Pattern

```c
//@isr UART1_RX
void __ISR(_UART1_RX_VECTOR, IPL5AUTO) UART1_RX_Handler(void) {
    // 1. Save context if needed
    // (handled automatically by compiler with IPL5AUTO)

    // 2. Read data to clear interrupt flag
    uint8_t data = U1RXREG;

    // 3. Process data
    uint16_t next_head = (rx_head + 1) % RX_BUFFER_SIZE;
    if (next_head != rx_tail) {
        rx_buffer[rx_head] = data;
        rx_head = next_head;
    } else {
        // Buffer overflow - discard data
        overflow_count++;
    }

    // 4. Clear interrupt flag
    IFS0CLR = _IFS0_U1RXIF_MASK;

    // 5. Restore context
    // (handled automatically)
}
```

### 3. Polling Loop Pattern

```c
LOOP {
    static uint32_t last_update = 0;
    uint32_t now = TIMER_GetMillis();

    // Task 1: Fast polling (every loop)
    if (UART_Available()) {
        ProcessUARTCommand();
    }

    // Task 2: Periodic @ 100 ms
    if (now - last_update >= 100) {
        last_update = now;

        ReadSensors();
        UpdateControl();
        SendTelemetry();
    }

    // Task 3: Event-driven
    if (button_pressed) {
        HandleButtonPress();
        button_pressed = false;
    }
}
```

### 4. State Machine Pattern

```c
//@pub enum SystemState_t
typedef enum {
    STATE_INIT,
    STATE_IDLE,
    STATE_RUNNING,
    STATE_ERROR,
    STATE_SHUTDOWN
} SystemState_t;

//@pub var current_state
SystemState_t current_state = STATE_INIT;

LOOP {
    switch (current_state) {
        case STATE_INIT:
            if (System_Initialize()) {
                current_state = STATE_IDLE;
            } else {
                current_state = STATE_ERROR;
            }
            break;

        case STATE_IDLE:
            if (start_requested) {
                current_state = STATE_RUNNING;
            }
            break;

        case STATE_RUNNING:
            ProcessData();
            if (error_detected) {
                current_state = STATE_ERROR;
            } else if (stop_requested) {
                current_state = STATE_IDLE;
            }
            break;

        case STATE_ERROR:
            HandleError();
            if (reset_requested) {
                current_state = STATE_INIT;
            }
            break;

        case STATE_SHUTDOWN:
            System_Cleanup();
            // Halt
            while(1);
            break;
    }
}
```

### 5. Event-Driven Pattern

```c
//@pub struct Event_t
typedef struct {
    uint8_t type;
    uint8_t data;
    uint32_t timestamp;
} Event_t;

#define EVENT_QUEUE_SIZE 32
Event_t event_queue[EVENT_QUEUE_SIZE];
volatile uint8_t event_head = 0;
volatile uint8_t event_tail = 0;

// Post event (from ISR or main)
void PostEvent(uint8_t type, uint8_t data) {
    uint8_t next = (event_head + 1) % EVENT_QUEUE_SIZE;
    if (next != event_tail) {
        event_queue[event_head].type = type;
        event_queue[event_head].data = data;
        event_queue[event_head].timestamp = TIMER_GetMillis();
        event_head = next;
    }
}

// Process events
LOOP {
    while (event_head != event_tail) {
        Event_t* event = &event_queue[event_tail];

        switch (event->type) {
            case EVENT_BUTTON:
                HandleButton(event->data);
                break;
            case EVENT_SENSOR:
                HandleSensor(event->data);
                break;
            case EVENT_TIMEOUT:
                HandleTimeout(event->data);
                break;
        }

        event_tail = (event_tail + 1) % EVENT_QUEUE_SIZE;
    }
}
```

### 6. Producer-Consumer Pattern

```c
#define BUFFER_SIZE 64

//@pub var data_buffer
volatile uint16_t data_buffer[BUFFER_SIZE];
volatile uint8_t write_index = 0;
volatile uint8_t read_index = 0;
volatile uint8_t data_count = 0;

// Producer (ISR)
void __ISR(_ADC_VECTOR) ADC_Handler(void) {
    if (data_count < BUFFER_SIZE) {
        data_buffer[write_index] = ADC1BUF0;
        write_index = (write_index + 1) % BUFFER_SIZE;
        data_count++;
    }
    IFS0CLR = _IFS0_AD1IF_MASK;
}

// Consumer (Main loop)
LOOP {
    if (data_count > 0) {
        uint16_t value = data_buffer[read_index];
        read_index = (read_index + 1) % BUFFER_SIZE;
        __builtin_disable_interrupts();
        data_count--;
        __builtin_enable_interrupts();

        ProcessSample(value);
    }
}
```

### 7. Command Handler Pattern

```c
typedef void (*CmdHandler_t)(uint8_t* args, uint8_t len);

typedef struct {
    char cmd;
    CmdHandler_t handler;
} CmdEntry_t;

void Cmd_Reset(uint8_t* args, uint8_t len) {
    System_Reset();
}

void Cmd_Status(uint8_t* args, uint8_t len) {
    UART_Printf("Status: %s\r\n", (system_ok ? "OK" : "ERROR"));
}

void Cmd_SetValue(uint8_t* args, uint8_t len) {
    if (len >= 1) {
        config_value = args[0];
        UART_WriteString("Value set\r\n");
    }
}

const CmdEntry_t cmd_table[] = {
    {'R', Cmd_Reset},
    {'S', Cmd_Status},
    {'V', Cmd_SetValue},
    {0, NULL}  // Terminator
};

void ProcessCommand(uint8_t cmd) {
    for (uint8_t i = 0; cmd_table[i].handler != NULL; i++) {
        if (cmd_table[i].cmd == cmd) {
            cmd_table[i].handler(NULL, 0);
            return;
        }
    }
    UART_WriteString("Unknown command\r\n");
}
```

---

## 11. Volúmenes Lógicos

### Tabla de Volúmenes

| Volumen | Descripción | Ejemplo Path | Acceso |
|---------|-------------|--------------|--------|
| `DEV:` | Repositorio EMIC (SDK) | `DEV:/api/uart.h` | Read-only |
| `TARGET:` | Código generado (build output) | `TARGET:/build/main.c` | Read/Write |
| `SYS:` | Sistema EMIC (core) | `SYS:/config/system.h` | Read-only |
| `USER:` | Archivos del integrador | `USER:/project/app.emic` | Read/Write |

### Jerarquía DEV: (Repositorio EMIC)

```
DEV:/
├── _api/              # APIs de alto nivel
│   ├── uart.h
│   ├── spi.h
│   └── i2c.h
├── _drivers/          # Drivers de hardware externo
│   ├── lcd/
│   ├── sensor/
│   └── motor/
├── _hal/              # Hardware Abstraction Layer
│   ├── pic32mz/
│   └── dspic33/
├── _hard/             # Código específico MCU
│   ├── pic32mz/
│   └── dspic33/
├── _modules/          # Módulos completos
│   ├── Communication/
│   ├── Sensors/
│   └── Actuators/
├── _system/           # Sistema core EMIC
│   ├── inc/
│   └── src/
├── _templates/        # Templates de proyecto
└── _util/             # Utilidades
```

### Uso en Código

```c
// Include desde API
#include "DEV:/api/uart.h"
#include "DEV:/api/gpio.h"

// Include desde driver
#include "DEV:/drivers/lcd/lcd16x2.h"

// Include desde HAL
#include "DEV:/_hal/pic32mz/pic32mz_uart.h"

// Include desde system
#include "SYS:/config/emic_config.h"

// Include archivo generado
#include "TARGET:/build/generated_config.h"

// Include archivo del usuario
#include "USER:/custom_functions.h"
```

---

## 12. Comandos CLI

### Tabla de Comandos

| Comando | Descripción | Ejemplo |
|---------|-------------|---------|
| `emic compile` | Compilar proyecto | `emic compile MyProject` |
| `emic validate` | Validar sintaxis | `emic validate MyProject` |
| `emic debug` | Compilar con debug | `emic debug MyProject` |
| `emic discovery` | Extraer recursos @pub | `emic discovery EMIC_SDK` |
| `emic clean` | Limpiar build | `emic clean MyProject` |
| `emic flash` | Flashear dispositivo | `emic flash MyProject PICKit4` |
| `emic config` | Configurar módulo | `emic config UART baudrate 115200` |
| `emic list modules` | Listar módulos | `emic list modules` |
| `emic list resources` | Listar recursos | `emic list resources UART` |
| `emic info` | Info de módulo | `emic info UARTDriver` |
| `emic create` | Crear proyecto | `emic create MyNewProject PIC32MZ` |
| `emic init` | Inicializar repo | `emic init EMIC_SDK` |
| `emic version` | Versión EMIC-CLI | `emic version` |
| `emic help` | Ayuda | `emic help compile` |

### Ejemplos de Uso

```bash
# Crear nuevo proyecto
emic create IoTDevice PIC32MZ2048EFH144

# Descubrir recursos en repositorio
cd EMIC_SDK
emic discovery .

# Compilar proyecto
cd MyProject
emic compile

# Compilar con modo debug
emic debug

# Validar sintaxis sin compilar
emic validate

# Limpiar archivos generados
emic clean

# Configurar parámetro de módulo
emic config UART baudrate 115200
emic config UART parity NONE
emic config UART rx_buffer_size 512

# Listar módulos disponibles
emic list modules

# Listar módulos de categoría específica
emic list modules --category Drivers

# Ver recursos de un módulo
emic list resources UARTDriver

# Info detallada de módulo
emic info UARTDriver

# Flashear con programmer
emic flash MyProject ICD4
emic flash MyProject PICKit4

# Ver versión
emic version

# Ayuda general
emic help

# Ayuda de comando específico
emic help compile
```

### Opciones Comunes

| Opción | Descripción | Ejemplo |
|--------|-------------|---------|
| `--verbose` | Salida detallada | `emic compile --verbose` |
| `--quiet` | Salida mínima | `emic compile --quiet` |
| `--output` | Directorio de salida | `emic compile --output ./build` |
| `--device` | MCU target | `emic compile --device PIC32MZ2048` |
| `--optimize` | Nivel optimización | `emic compile --optimize 2` |
| `--clean` | Limpiar antes de build | `emic compile --clean` |
| `--help` | Ayuda | `emic compile --help` |

---

## 13. Troubleshooting Rápido

### Errores Comunes

| Error | Causa Probable | Solución |
|-------|----------------|----------|
| `Resource 'FuncName' not found` | Tag @pub faltante o mal escrito | Verificar @pub en código fuente |
| `Module 'ModuleName' not discovered` | Sin tags @pub en módulo | Agregar @pub a funciones/vars |
| `Compilation failed: syntax error` | Sintaxis C inválida | Revisar código C generado |
| `Config validation error` | config.json mal formado | Validar JSON con linter |
| `Linker error: region 'program' overflowed` | Código muy grande | Reducir funcionalidades u optimizar (-Os) |
| `Linker error: undefined reference to 'FuncName'` | Función declarada pero no definida | Implementar función o agregar librería |
| `Multiple definitions of 'varName'` | Variable definida en múltiples archivos | Usar 'extern' en headers |
| `Stack overflow detected` | Stack muy pequeño | Aumentar stack size en linker |
| `Heap allocation failed` | Heap muy pequeño | Aumentar heap size |
| `Invalid baud rate` | Baudrate no soportado por hardware | Usar baudrate estándar |
| `I2C NACK received` | Dispositivo I2C no responde | Verificar dirección y conexión |
| `SPI timeout` | No hay respuesta SPI | Verificar clock y conexiones |
| `UART buffer overflow` | Buffer muy pequeño | Aumentar tamaño de buffer |
| `Timer overflow` | Período muy largo | Usar prescaler mayor |
| `ADC conversion timeout` | ADC mal configurado | Revisar sample time |
| `Flash write failed` | Área protegida o voltaje bajo | Desproteger flash, verificar voltaje |

### Verificaciones Rápidas

```bash
# 1. Verificar sintaxis JSON
cat config.json | python -m json.tool

# 2. Verificar discovery
emic discovery . --verbose

# 3. Validar antes de compilar
emic validate MyProject

# 4. Compilar con verbose
emic compile MyProject --verbose

# 5. Verificar tamaño de programa
xc32-size firmware.elf

# 6. Ver símbolos definidos
xc32-nm firmware.elf | grep MyFunction

# 7. Verificar memoria disponible
xc32-objdump -h firmware.elf
```

### Debug Checklist

```c
// 1. Verificar inicialización
if (!Module_Init()) {
    UART_WriteString("ERROR: Init failed\r\n");
    while(1);  // Halt
}

// 2. Agregar debug prints
UART_Printf("Debug: value=%u\r\n", value);

// 3. Toggle LED para indicar progreso
GPIO_Toggle(DEBUG_LED);

// 4. Verificar valores con assert
#define ASSERT(cond) if(!(cond)) { \
    UART_Printf("ASSERT FAIL: %s:%d\r\n", __FILE__, __LINE__); \
    while(1); \
}

ASSERT(buffer != NULL);
ASSERT(index < BUFFER_SIZE);

// 5. Usar watchdog para detectar hangs
WDT_Enable(1000);  // 1 segundo
// ... código ...
WDT_Clear();  // Kick watchdog

// 6. Verificar stack usage
extern uint32_t _stack;
extern uint32_t _min_stack_size;
uint32_t stack_used = &_stack - get_stack_pointer();
UART_Printf("Stack used: %lu bytes\r\n", stack_used);
```

---

## 14. Shortcuts y Tips

### Atajos de Teclado EMIC-Editor

| Atajo | Acción |
|-------|--------|
| `Ctrl+S` | Guardar archivo |
| `Ctrl+Shift+S` | Guardar todo |
| `Ctrl+B` | Compilar proyecto |
| `Ctrl+Shift+B` | Compilar y flashear |
| `F5` | Iniciar debugging |
| `F9` | Toggle breakpoint |
| `F10` | Step over |
| `F11` | Step into |
| `Ctrl+F` | Buscar |
| `Ctrl+H` | Buscar y reemplazar |
| `Ctrl+G` | Ir a línea |
| `Ctrl+Space` | Autocompletar |
| `Ctrl+/` | Comentar/descomentar |
| `Ctrl+K, Ctrl+C` | Comentar bloque |
| `Ctrl+K, Ctrl+U` | Descomentar bloque |
| `Alt+Up/Down` | Mover línea |
| `Ctrl+D` | Duplicar línea |
| `Ctrl+L` | Eliminar línea |

### Snippets Útiles

```c
// Snippet: ISR handler
//@isr TIMER1
void __ISR(_TIMER_1_VECTOR, IPL3AUTO) Timer1_Handler(void) {
    // TODO: Handler code
    IFS0CLR = _IFS0_T1IF_MASK;
}

// Snippet: Circular buffer
#define BUFFER_SIZE 64
volatile uint8_t buffer[BUFFER_SIZE];
volatile uint8_t head = 0;
volatile uint8_t tail = 0;

void buffer_write(uint8_t data) {
    uint8_t next = (head + 1) % BUFFER_SIZE;
    if (next != tail) {
        buffer[head] = data;
        head = next;
    }
}

bool buffer_read(uint8_t* data) {
    if (head != tail) {
        *data = buffer[tail];
        tail = (tail + 1) % BUFFER_SIZE;
        return true;
    }
    return false;
}

// Snippet: Debounce button
bool button_debounce(bool current_state) {
    static bool last_state = false;
    static uint32_t last_change = 0;
    uint32_t now = TIMER_GetMillis();

    if (current_state != last_state) {
        if (now - last_change > 50) {  // 50 ms debounce
            last_state = current_state;
            last_change = now;
            return true;  // State changed
        }
    }
    return false;
}

// Snippet: Timeout detection
bool wait_for_condition(bool (*condition)(void), uint32_t timeout_ms) {
    uint32_t start = TIMER_GetMillis();
    while (!condition()) {
        if (TIMER_GetMillis() - start > timeout_ms) {
            return false;  // Timeout
        }
    }
    return true;  // Success
}
```

### Naming Conventions

| Elemento | Convención | Ejemplo |
|----------|------------|---------|
| Módulos | PascalCase | `UARTDriver` |
| Funciones públicas | Module_Action | `UART_Init()`, `GPIO_Write()` |
| Funciones privadas | module_action | `uart_calculate_brg()` |
| Variables globales | snake_case | `sensor_value` |
| Variables locales | snake_case | `temp_reading` |
| Constantes | UPPER_CASE | `MAX_BUFFER_SIZE` |
| Macros | UPPER_CASE | `ENABLE_DEBUG` |
| Tipos | PascalCase_t | `SensorData_t` |
| Enums | UPPER_CASE | `STATE_IDLE` |
| Structs | PascalCase_t | `Point2D_t` |
| Defines | UPPER_CASE | `PERIPHERAL_CLOCK` |

### Best Practices Resumidas

```c
// 1. Siempre inicializar variables
uint8_t counter = 0;  // ✅ Good
uint8_t value;        // ❌ Bad (undefined)

// 2. Usar tipos de tamaño fijo
uint16_t temp;        // ✅ Good (explicit size)
int temp;             // ❌ Bad (platform dependent)

// 3. Validar punteros
if (ptr != NULL) {    // ✅ Good
    *ptr = value;
}

// 4. Usar const para valores constantes
const uint8_t MAX = 100;  // ✅ Good
#define MAX 100           // ⚠️ OK pero menos type-safe

// 5. Evitar magic numbers
#define BAUDRATE 115200   // ✅ Good
UART_Init(BAUDRATE);
UART_Init(115200);        // ❌ Bad (magic number)

// 6. Proteger secciones críticas
__builtin_disable_interrupts();
shared_variable++;
__builtin_enable_interrupts();

// 7. Usar volatile para variables compartidas con ISR
volatile uint32_t tick_count = 0;  // ✅ Good
uint32_t tick_count = 0;           // ❌ Bad (compiler optimization)

// 8. Limitar scope de variables
for (uint8_t i = 0; i < 10; i++) {  // ✅ Good (scope limitado)
    // ...
}

// 9. Documentar funciones públicas
//@pub func UART_Init
//@param baudrate Baudrate deseado
//@return true si éxito
bool UART_Init(uint32_t baudrate);

// 10. Manejar errores
if (!UART_Init(115200)) {
    // Handle error
    return false;
}
```

### Performance Tips

```c
// 1. Usar shifts en lugar de multiplicación/división por potencias de 2
value = x << 3;   // ✅ Rápido (x * 8)
value = x * 8;    // ❌ Lento

value = x >> 2;   // ✅ Rápido (x / 4)
value = x / 4;    // ❌ Lento

// 2. Usar tipos nativos del MCU
uint16_t x;       // ✅ Óptimo para 16-bit MCU
uint32_t x;       // ⚠️ OK pero más lento en 16-bit MCU

// 3. Evitar división y módulo si es posible
// En lugar de:
index = (index + 1) % 256;  // ❌ Lento (división)
// Usar:
index = (index + 1) & 0xFF;  // ✅ Rápido (AND) si potencia de 2

// 4. Inline funciones pequeñas
static inline uint8_t min(uint8_t a, uint8_t b) {
    return (a < b) ? a : b;
}

// 5. Usar lookup tables en lugar de cálculos
const uint8_t sin_table[256] = { /* ... */ };
uint8_t value = sin_table[angle];  // ✅ Rápido
float value = sin(angle_rad);      // ❌ Muy lento

// 6. Optimizar loops
// Loop unrolling manual si es crítico
for (i = 0; i < 8; i++) {
    buffer[i] = 0;
}
// vs
buffer[0] = 0; buffer[1] = 0; buffer[2] = 0; buffer[3] = 0;
buffer[4] = 0; buffer[5] = 0; buffer[6] = 0; buffer[7] = 0;
```

---

## 15. Referencias Cruzadas

### Capítulos del Manual

| Tema | Capítulo | Descripción |
|------|----------|-------------|
| Introducción EMIC | Cap. 1 | Overview del ecosistema |
| Primeros pasos | Cap. 2 | Setup inicial |
| EMIC-Codify básico | Cap. 5 | Sintaxis básica |
| Módulos | Cap. 7 | Creación de módulos |
| GPIO | Cap. 8 | Periférico GPIO |
| UART | Cap. 9 | Comunicación serial |
| SPI | Cap. 10 | SPI protocol |
| I2C | Cap. 11 | I2C protocol |
| Timers | Cap. 12 | Timers y PWM |
| ADC | Cap. 13 | Conversión analógico-digital |
| Interrupts | Cap. 14 | Sistema de interrupciones |
| DMA | Cap. 15 | Direct Memory Access |
| Networking | Cap. 20-22 | WiFi, Ethernet, LoRa |
| Protocolos | Cap. 23-26 | MQTT, HTTP, Modbus, CAN |
| File Systems | Cap. 27 | SD card, EEPROM |
| Display & UI | Cap. 28 | LCD, OLED, TFT |
| Sensores | Cap. 29 | Integración de sensores |
| Testing | Cap. 30 | Unit testing |
| RTOS | Cap. 33 | FreeRTOS integration |
| Bootloader | Cap. 34 | Bootloader y OTA |
| Troubleshooting | Cap. 36 | Guía de solución de problemas |
| Glosario | Cap. 37 | Términos técnicos |

### Documentación Externa

**Microchip Resources:**
- PIC32 Family Reference Manual: https://www.microchip.com/pic32
- dsPIC33 Family Reference Manual: https://www.microchip.com/dspic33
- XC32 Compiler User's Guide: https://www.microchip.com/xc32
- MPLAB X IDE User's Guide: https://www.microchip.com/mplab

**Datasheets:**
- PIC32MZ2048EFH: https://www.microchip.com/PIC32MZ2048EFH
- dsPIC33EP512MU810: https://www.microchip.com/dsPIC33EP512MU810

**Estándares:**
- C99 Standard: https://en.cppreference.com/w/c
- MISRA C Guidelines: https://www.misra.org.uk/

**Protocolos:**
- UART: https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter
- SPI: https://en.wikipedia.org/wiki/Serial_Peripheral_Interface
- I2C: https://www.nxp.com/docs/en/user-guide/UM10204.pdf
- CAN: https://www.can-cia.org/
- Modbus: https://modbus.org/
- MQTT: https://mqtt.org/
- HTTP: https://www.ietf.org/rfc/rfc2616.txt

**FreeRTOS:**
- Official Site: https://www.freertos.org/
- Documentation: https://www.freertos.org/Documentation/
- API Reference: https://www.freertos.org/a00106.html

**EMIC Resources:**
- Website: https://emic.io
- Documentation: https://docs.emic.io
- GitHub: https://github.com/EMIC-Electronics
- Community Forum: https://forum.emic.io
- Discord: https://discord.gg/emic

### Herramientas

| Herramienta | Descripción | URL |
|-------------|-------------|-----|
| MPLAB X IDE | IDE oficial Microchip | https://www.microchip.com/mplab/mplab-x-ide |
| XC8 Compiler | Compilador PIC 8-bit | https://www.microchip.com/xc8 |
| XC16 Compiler | Compilador PIC 16-bit | https://www.microchip.com/xc16 |
| XC32 Compiler | Compilador PIC 32-bit | https://www.microchip.com/xc32 |
| EMIC-CLI | CLI tool EMIC | https://github.com/EMIC/emic-cli |
| EMIC-Editor | Web IDE | https://editor.emic.io |
| VSCode Extension | Plugin VSCode | https://marketplace.visualstudio.com/emic |
| PICkit 4 | Programmer/debugger | https://www.microchip.com/pickit4 |
| ICD 4 | Debugger profesional | https://www.microchip.com/icd4 |

---

## 📌 Notas Finales

Esta guía de referencia rápida está diseñada para consulta rápida durante el desarrollo. Para información detallada, consulta los capítulos específicos del manual.

**Progreso del Manual:**
- Capítulo: 35/38 (92.11%)
- Sección 7: 1/4 (25%)

**Próximo capítulo:** Cap. 36 - Troubleshooting Guide

---

*Referencia Rápida EMIC-Codify - v1.0*
*EMIC SDK Development Manual - Section 7*
