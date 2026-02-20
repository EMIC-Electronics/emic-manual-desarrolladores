# Capítulo 22: Desarrollo de un Driver EMIC

## Tabla de Contenidos

### PARTE 1: DESARROLLO DEL DRIVER
1. [¿Qué es un Driver? Driver vs API](#1-qué-es-un-driver-driver-vs-api)
2. [Planificación del Driver](#2-planificación-del-driver)
3. [Paso 1: Estructura de Carpetas](#3-paso-1-estructura-de-carpetas)
4. [Paso 2: Integración con HAL](#4-paso-2-integración-con-hal)
5. [Paso 3: Código del Driver](#5-paso-3-código-del-driver)
6. [Paso 4: Crear Archivo .emic](#6-paso-4-crear-archivo-emic)

### PARTE 2: VALIDACIÓN
7. [Paso 5: Crear Módulo de Prueba](#7-paso-5-crear-módulo-de-prueba)
8. [Paso 6: Testing y Debugging](#8-paso-6-testing-y-debugging)

### EJEMPLOS
9. [Ejemplo 1: Driver SystemTimer](#9-ejemplo-1-driver-systemtimer)
10. [Ejemplo 2: Driver de Display LCD](#10-ejemplo-2-driver-de-display-lcd)

---

## PARTE 1: DESARROLLO DEL DRIVER

---

## 1. ¿Qué es un Driver? Driver vs API

### 1.1 Definición de Driver

Un **Driver** es un componente de software que:
- Controla **hardware específico** (chips, periféricos, sensores)
- Abstrae los detalles de comunicación del hardware
- Proporciona funciones de bajo nivel para otros componentes
- Generalmente **no se publica** directamente en EMIC-Editor

### 1.2 Driver vs API: Diferencias Clave

```
┌─────────────────────────────────────────────────────────────────┐
│                     DRIVER vs API                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  DRIVER                           API                            │
│  ──────                           ───                            │
│  • Control de hardware            • Funcionalidad de alto nivel  │
│  • Bajo nivel                     • Alto nivel                   │
│  • Usa el HAL                     • Usa Drivers                  │
│  • Sin tags (no publicado)        • Con tags (publicado)         │
│  • Interno al SDK                 • Visible en EMIC-Editor       │
│                                                                  │
│  EJEMPLO:                                                        │
│  ────────                                                        │
│  Driver SPI ←── Driver LCD ←── API Display ←── Usuario           │
│    (HAL)         (chip)         (funciones)    (bloques)         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 1.3 Jerarquía de Componentes

```
Usuario (EMIC-Editor)
       ↓
┌─────────────────┐
│      APIs       │  ← Funciones publicadas (con tags)
│  (Alto nivel)   │     Ej: LED_on(), Display_print()
└────────┬────────┘
         ↓
┌─────────────────┐
│    Drivers      │  ← Control de chips específicos
│  (Medio nivel)  │     Ej: LCD_sendCommand(), ADS1231_read()
└────────┬────────┘
         ↓
┌─────────────────┐
│      HAL        │  ← Abstracción de periféricos MCU
│  (Bajo nivel)   │     Ej: SPI_write(), I2C_read()
└────────┬────────┘
         ↓
┌─────────────────┐
│     _hard       │  ← Código específico del MCU
│  (Hardware)     │     Ej: Registros PIC32, PIC24
└─────────────────┘
```

### 1.4 ¿Cuándo Crear un Driver?

| Situación | Crear Driver | Crear API |
|-----------|--------------|-----------|
| Controlar chip externo (ADC, LCD, sensor) | ✅ | ❌ |
| Funcionalidad para el usuario | ❌ | ✅ |
| Protocolo de comunicación específico | ✅ | ❌ |
| Abstracción de alto nivel | ❌ | ✅ |
| Sin interacción directa del usuario | ✅ | ❌ |

---

## 2. Planificación del Driver

### 2.1 Preguntas Clave

| Pregunta | Ejemplo: Driver SystemTimer |
|----------|---------------------------|
| ¿Qué hardware controla? | Timer interno del MCU |
| ¿Qué HAL necesita? | `_hal/Timer/timer.emic` |
| ¿Qué funciones expone? | `getSystemMilis()` |
| ¿Requiere inicialización? | Sí: `systemTimeInit()` |
| ¿Usa interrupciones/callbacks? | Sí: callback cada 1ms |

### 2.2 Diagrama del Driver

```
┌─────────────────────────────────────────────────────────────────┐
│                   DRIVER SYSTEMTIMER                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ENTRADA (HAL):                                                  │
│  ─────────────                                                   │
│  timer.emic → timer4_init(callback)                              │
│                                                                  │
│  FUNCIONALIDAD INTERNA:                                          │
│  ─────────────────────                                           │
│  • Contador de milisegundos                                      │
│  • Callback incrementa contador cada 1ms                         │
│                                                                  │
│  SALIDA (para APIs):                                             │
│  ──────────────────                                              │
│  getSystemMilis() → uint32_t (tiempo actual)                     │
│                                                                  │
│  USUARIOS:                                                       │
│  ─────────                                                       │
│  • API de LEDs (para blink)                                      │
│  • API de Timers (temporización)                                 │
│  • Cualquier componente que necesite tiempo                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Paso 1: Estructura de Carpetas

### 3.1 Ubicación en el SDK

```
EMIC_SDK/
└── _drivers/
    └── {Categoría}/
        └── {NombreDriver}/          ← Opcional si hay variantes
            ├── {driver}.emic
            ├── inc/
            │   └── {driver}.h
            └── src/
                └── {driver}.c
```

### 3.2 Ejemplos de Estructura

#### Driver Simple (SystemTimer):
```
_drivers/
└── SystemTimer/
    ├── systemTimer.emic
    ├── inc/
    │   └── systemTimer.h
    └── src/
        └── systemTimer.c
```

#### Driver con Variantes (ADC):
```
_drivers/
└── ADC/
    ├── ADS1231/              ← Variante 1
    │   ├── ADS1231.emic
    │   ├── inc/ADS1231.h
    │   └── src/ADS1231.c
    └── LTC2500/              ← Variante 2
        ├── LTC2500.emic
        ├── inc/LTC2500.h
        └── src/LTC2500.c
```

#### Driver de Periférico (Display):
```
_drivers/
└── Display/
    ├── LCDdriver.emic
    ├── inc/
    │   └── LCDdriver.h
    └── src/
        └── LCDdriver.c
```

### 3.3 Convenciones de Nombres

| Elemento | Convención | Ejemplo |
|----------|------------|---------|
| Carpeta categoría | PascalCase | `ADC`, `Display`, `RAM` |
| Carpeta driver | PascalCase o código | `ADS1231`, `SystemTimer` |
| Archivo .emic | camelCase o código | `systemTimer.emic`, `ADS1231.emic` |
| Funciones | prefijo_accion | `systemTimeInit()`, `LCD_write()` |

---

## 4. Paso 2: Integración con HAL

### 4.1 ¿Qué es el HAL?

El **HAL (Hardware Abstraction Layer)** proporciona funciones genéricas para periféricos del MCU:

| HAL | Funciones | Ubicación |
|-----|-----------|-----------|
| GPIO | `HAL_GPIO_PinSet()`, `HAL_GPIO_PinCfg()` | `_hal/GPIO/` |
| SPI | `SPI_write()`, `SPI_read()` | `_hal/SPI/` |
| I2C | `I2C_write()`, `I2C_read()` | `_hal/I2C/` |
| UART | `UART_send()`, `UART_receive()` | `_hal/UART/` |
| Timer | `timer_init()`, `timer_start()` | `_hal/Timer/` |

### 4.2 Usar HAL en el Driver

```c
// En el archivo .emic del driver
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_hal/SPI/SPI.emic, port=.{port}., configuracion=Master)
EMIC:setInput(DEV:_hal/Timer/timer.emic)
```

### 4.3 Regla de Oro: No Acceder Directamente a Registros

```c
// ❌ INCORRECTO - Acceso directo a registros
void LCD_init(void) {
    TRISB &= ~(1 << 5);     // No portable
    LATB |= (1 << 5);       // Específico de PIC
}

// ✅ CORRECTO - Usar HAL
void LCD_init(void) {
    HAL_GPIO_PinCfg(LCD_CS, GPIO_OUTPUT);
    HAL_GPIO_PinSet(LCD_CS, GPIO_HIGH);
}
```

### 4.4 Beneficios del HAL

| Beneficio | Descripción |
|-----------|-------------|
| **Portabilidad** | Mismo driver funciona en PIC24, PIC32, dsPIC |
| **Mantenibilidad** | Cambios de hardware solo afectan `_hard/` |
| **Reutilización** | Un driver sirve para múltiples módulos |
| **Abstracción** | El driver no conoce detalles del MCU |

---

## 5. Paso 3: Código del Driver

### 5.1 Estructura del Header (.h)

```c
// systemTimer.h
#include <xc.h>

// Declaración de funciones públicas
uint32_t getSystemMilis(void);

// Función de inicialización
void systemTimeInit(void);
EMIC:define(inits.systemTimeInit, systemTimeInit)
```

### 5.2 Estructura del Source (.c)

```c
// systemTimer.c
#include <xc.h>
#include "inc/systemTimer.h"
#include "inc/timer.h"          // Del HAL

// Variables privadas (static)
static uint32_t systemMilis = 0;

// Función pública
uint32_t getSystemMilis(void)
{
    return systemMilis;
}

// Callback llamado por el HAL cada 1ms
void callback(void)
{
    systemMilis++;
}

// Inicialización
void systemTimeInit(void)
{
    timer4_init(callback);      // Usa función del HAL
}
```

### 5.3 Patrones Comunes en Drivers

#### Patrón: Inicialización con Callback
```c
void driver_init(void)
{
    HAL_peripheral_init(my_callback);
}

void my_callback(void)
{
    // Procesar evento del hardware
}
```

#### Patrón: Comunicación SPI
```c
void driver_write(uint8_t data)
{
    HAL_GPIO_PinSet(CS_PIN, GPIO_LOW);   // Chip select
    SPI_write(data);                      // Enviar dato
    HAL_GPIO_PinSet(CS_PIN, GPIO_HIGH);  // Liberar
}

uint8_t driver_read(void)
{
    uint8_t data;
    HAL_GPIO_PinSet(CS_PIN, GPIO_LOW);
    data = SPI_read();
    HAL_GPIO_PinSet(CS_PIN, GPIO_HIGH);
    return data;
}
```

#### Patrón: Estado Interno
```c
static struct {
    uint8_t initialized;
    uint16_t counter;
    uint8_t buffer[64];
} driver_state = {0};

void driver_init(void)
{
    driver_state.initialized = 1;
    driver_state.counter = 0;
}
```

---

## 6. Paso 4: Crear Archivo .emic

### 6.1 Estructura del .emic de un Driver

```c
// driver.emic

// 1. PROTECCIÓN CONTRA INCLUSIÓN MÚLTIPLE
EMIC:ifndef _MI_DRIVER_EMIC_
EMIC:define(_MI_DRIVER_EMIC_, true)

// 2. DEPENDENCIAS (HAL)
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_hal/SPI/SPI.emic, port=.{port}.)

// 3. COPIAR ARCHIVOS
EMIC:copy(inc/driver.h > TARGET:inc/driver.h)
EMIC:copy(src/driver.c > TARGET:driver.c, port=.{port}.)

// 4. REGISTRAR PARA COMPILACIÓN
EMIC:define(c_modules.driver, driver)

// 5. CERRAR PROTECCIÓN
EMIC:endif
```

### 6.2 Diferencias con .emic de API

| Aspecto | Driver | API |
|---------|--------|-----|
| `EMIC:tag(driverName=...)` | ❌ No (no se publica) | ✅ Sí |
| Tags DOXYGEN | ❌ No | ✅ Sí |
| `main_includes.*` | Opcional | ✅ Generalmente sí |
| `c_modules.*` | ✅ Sí | ✅ Sí |
| Protección `ifndef` | ✅ Sí | ✅ Sí |

### 6.3 Ejemplo: SystemTimer .emic

```c
// systemTimer.emic
EMIC:ifndef _DRIVER_SYSTEM_TIMER_EMIC_
EMIC:define(_DRIVER_SYSTEM_TIMER_EMIC_, true)

// Dependencia: HAL de Timer
EMIC:setInput(DEV:_hal/Timer/timer.emic)

// Generar archivos usando setOutput/setInput
EMIC:setOutput(TARGET:inc/systemTimer.h)
    EMIC:setInput(inc/systemTimer.h)
EMIC:restoreOutput

EMIC:setOutput(TARGET:systemTimer.c)
    EMIC:setInput(src/systemTimer.c)
EMIC:restoreOutput

// Registrar para compilación
EMIC:define(main_includes.systemTimer, systemTimer)
EMIC:define(c_modules.systemTimer, systemTimer)

EMIC:endif
```

### 6.4 Ejemplo: LCD Driver .emic

```c
// LCDdriver.emic
EMIC:ifndef _LCDdriver_EMIC
EMIC:define(_LCDdriver_EMIC, true)

// Dependencias HAL
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_hal/SPI/SPI.emic, port=.{port}., configuracion=Master, pin=.{pin}.)

// Copiar archivos
EMIC:copy(inc/LCDdriver.h > TARGET:inc/LCDdriver.h)
EMIC:copy(src/LCDdriver.c > TARGET:LCDdriver.c, port=.{port}.)

// Registrar
EMIC:define(c_modules.LCDdriver, LCDdriver)

EMIC:endif
```

---

## PARTE 2: VALIDACIÓN

---

## 7. Paso 5: Crear Módulo de Prueba

### 7.1 Probar Driver desde una API

La forma típica de probar un driver es usarlo desde una API:

```c
// mi_api.emic - API que usa el driver
EMIC:tag(driverName = MiAPI)

/**
* @fn void MiAPI_test(void);
* @alias test
* @brief Test the driver functionality
* @return Nothing
*/

// Cargar el driver
EMIC:setInput(DEV:_drivers/MiDriver/driver.emic, port=1)

// Copiar archivos de la API
EMIC:copy(inc/mi_api.h > TARGET:inc/mi_api.h)
EMIC:copy(src/mi_api.c > TARGET:mi_api.c)

EMIC:define(main_includes.mi_api, mi_api)
EMIC:define(c_modules.mi_api, mi_api)
```

### 7.2 Probar Driver desde generate.emic

Para pruebas rápidas, cargar el driver directamente:

```c
// generate.emic del módulo de prueba
EMIC:setOutput(TARGET:generate.txt)

// Hardware
EMIC:setInput(DEV:_pcb/pcb.emic, pcb=MI_PLACA)

// Cargar driver directamente
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

// Cargar API que usa el driver (para verificar integración)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=test, pin=RB0)

// Main
EMIC:setInput(DEV:_main/baremetal/main.emic)

// ... resto del generate.emic
EMIC:restoreOutput
```

### 7.3 Verificar Funcionamiento

1. **Compilar**: Sin errores de linking
2. **Inicialización**: Verificar que `init` se llama
3. **Funcionalidad**: Probar funciones del driver
4. **Integración**: Verificar que APIs que lo usan funcionan

---

## 8. Paso 6: Testing y Debugging

### 8.1 Plan de Pruebas para Driver

| Test | Descripción | Verificación |
|------|-------------|--------------|
| T1 | Inicialización | Sin errores, hardware configurado |
| T2 | Función principal | Retorna valores correctos |
| T3 | Comunicación HAL | SPI/I2C/GPIO funcionan |
| T4 | Timing | Tiempos correctos |
| T5 | Integración | APIs que lo usan funcionan |

### 8.2 Técnicas de Debugging

#### Usar LED para indicar estado:
```c
void driver_init(void)
{
    // ... inicialización ...

    // Indicar éxito con LED
    HAL_GPIO_PinSet(DEBUG_LED, GPIO_HIGH);
}
```

#### Usar UART para logs:
```c
void driver_process(void)
{
    printf("Driver: valor = %d\n", valor);
}
```

#### Usar osciloscopio:
- Verificar señales SPI/I2C
- Medir tiempos de comunicación
- Verificar niveles de voltaje

### 8.3 Errores Comunes en Drivers

| Error | Causa | Solución |
|-------|-------|----------|
| Comunicación falla | Pin mal configurado | Verificar HAL y PCB |
| Timing incorrecto | Clock mal configurado | Verificar configuración del periférico |
| No inicializa | `init` no registrado | Agregar `EMIC:define(inits.xxx, xxx)` |
| Conflicto de recursos | Periférico usado por otro driver | Verificar asignación de puertos |

---

## 9. Ejemplo 1: Driver SystemTimer

Driver completo que proporciona temporización en milisegundos.

### 9.1 Archivo systemTimer.emic

```c
EMIC:ifndef _DRIVER_SYSTEM_TIMER_EMIC_
EMIC:define(_DRIVER_SYSTEM_TIMER_EMIC_, true)

EMIC:setInput(DEV:_hal/Timer/timer.emic)

EMIC:setOutput(TARGET:inc/systemTimer.h)
    EMIC:setInput(inc/systemTimer.h)
EMIC:restoreOutput

EMIC:setOutput(TARGET:systemTimer.c)
    EMIC:setInput(src/systemTimer.c)
EMIC:restoreOutput

EMIC:define(main_includes.systemTimer, systemTimer)
EMIC:define(c_modules.systemTimer, systemTimer)

EMIC:endif
```

### 9.2 Archivo inc/systemTimer.h

```c
#include <xc.h>

// Función pública: obtener tiempo actual
uint32_t getSystemMilis(void);

// Inicialización (registrada automáticamente)
void systemTimeInit(void);
EMIC:define(inits.systemTimeInit, systemTimeInit)
```

### 9.3 Archivo src/systemTimer.c

```c
#include <xc.h>
#include "inc/systemTimer.h"
#include "inc/timer.h"

static uint32_t systemMilis = 0;

uint32_t getSystemMilis(void)
{
    return systemMilis;
}

void callback(void)
{
    systemMilis++;
}

void systemTimeInit(void)
{
    timer4_init(callback);
}
```

### 9.4 Uso desde una API

```c
// En led.c (API de LEDs)
#include "inc/systemTimer.h"

void LEDs_status_blink(uint16_t timeOn, uint16_t period, uint16_t times)
{
    // Usa el driver SystemTimer
    blkLed_tStamp = getSystemMilis();
    // ...
}

void LEDs_status_poll(void)
{
    if (getSystemMilis() - blkLed_tStamp > blkLed_period)
    {
        // ...
    }
}
```

---

## 10. Ejemplo 2: Driver de Display LCD

Driver para pantalla LCD controlada por SPI.

### 10.1 Archivo LCDdriver.emic

```c
EMIC:ifndef _LCDdriver_EMIC
EMIC:define(_LCDdriver_EMIC, true)

// Dependencias HAL
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_hal/SPI/SPI.emic, port=.{port}., configuracion=Master, pin=.{pin}.)

// Copiar archivos
EMIC:copy(inc/LCDdriver.h > TARGET:inc/LCDdriver.h)
EMIC:copy(src/LCDdriver.c > TARGET:LCDdriver.c, port=.{port}.)

// Registrar
EMIC:define(c_modules.LCDdriver, LCDdriver)

EMIC:endif
```

### 10.2 Archivo inc/LCDdriver.h

```c
#include <xc.h>

// Inicialización
void LCD_init(void);
EMIC:define(inits.LCD_init, LCD_init)

// Funciones de control
void LCD_clear(void);
void LCD_setCursor(uint8_t x, uint8_t y);
void LCD_writeChar(char c);
void LCD_writeString(const char* str);

// Funciones de bajo nivel
void LCD_sendCommand(uint8_t cmd);
void LCD_sendData(uint8_t data);
```

### 10.3 Archivo src/LCDdriver.c

```c
#include <xc.h>
#include "inc/LCDdriver.h"
#include "inc/gpio.h"
#include "inc/SPI.{port}..h"

#define LCD_CS_PIN      LCD_CS
#define LCD_DC_PIN      LCD_DC
#define LCD_RST_PIN     LCD_RST

void LCD_init(void)
{
    // Configurar pines
    HAL_GPIO_PinCfg(LCD_CS_PIN, GPIO_OUTPUT);
    HAL_GPIO_PinCfg(LCD_DC_PIN, GPIO_OUTPUT);
    HAL_GPIO_PinCfg(LCD_RST_PIN, GPIO_OUTPUT);

    // Reset del LCD
    HAL_GPIO_PinSet(LCD_RST_PIN, GPIO_LOW);
    // delay
    HAL_GPIO_PinSet(LCD_RST_PIN, GPIO_HIGH);

    // Secuencia de inicialización del LCD
    LCD_sendCommand(0x21);  // Extended commands
    LCD_sendCommand(0xB0);  // Set contrast
    LCD_sendCommand(0x04);  // Set temp coefficient
    LCD_sendCommand(0x14);  // LCD bias mode
    LCD_sendCommand(0x20);  // Standard commands
    LCD_sendCommand(0x0C);  // LCD in normal mode

    LCD_clear();
}

void LCD_sendCommand(uint8_t cmd)
{
    HAL_GPIO_PinSet(LCD_DC_PIN, GPIO_LOW);   // Command mode
    HAL_GPIO_PinSet(LCD_CS_PIN, GPIO_LOW);   // Select
    SPI.{port}._write(cmd);
    HAL_GPIO_PinSet(LCD_CS_PIN, GPIO_HIGH);  // Deselect
}

void LCD_sendData(uint8_t data)
{
    HAL_GPIO_PinSet(LCD_DC_PIN, GPIO_HIGH);  // Data mode
    HAL_GPIO_PinSet(LCD_CS_PIN, GPIO_LOW);
    SPI.{port}._write(data);
    HAL_GPIO_PinSet(LCD_CS_PIN, GPIO_HIGH);
}

void LCD_clear(void)
{
    for (int i = 0; i < 504; i++)  // 84x48 / 8
    {
        LCD_sendData(0x00);
    }
    LCD_setCursor(0, 0);
}

void LCD_setCursor(uint8_t x, uint8_t y)
{
    LCD_sendCommand(0x80 | x);
    LCD_sendCommand(0x40 | y);
}

void LCD_writeChar(char c)
{
    // Enviar datos del carácter desde font table
    for (int i = 0; i < 5; i++)
    {
        LCD_sendData(font[c - 32][i]);
    }
    LCD_sendData(0x00);  // Espacio entre caracteres
}

void LCD_writeString(const char* str)
{
    while (*str)
    {
        LCD_writeChar(*str++);
    }
}
```

### 10.4 Uso desde generate.emic

```c
// En un módulo que necesita display LCD
EMIC:setInput(DEV:_drivers/Display/LCDdriver.emic, port=1, pin=SPI1_CS)
```

---

## Resumen

### Checklist de Desarrollo de Driver

- [ ] **Planificar**: Hardware a controlar, HAL necesario
- [ ] **Estructura**: Crear carpetas en `_drivers/`
- [ ] **HAL**: Identificar y usar funciones del HAL
- [ ] **Header (.h)**: Declaraciones + registro de init
- [ ] **Source (.c)**: Implementación usando HAL
- [ ] **Archivo .emic**: Protección, dependencias, copy, registro
- [ ] **Validar**: Probar desde API o módulo
- [ ] **Testing**: Verificar funcionalidad completa

### Patrón Típico de Driver

```c
// driver.emic
EMIC:ifndef _MI_DRIVER_EMIC_
EMIC:define(_MI_DRIVER_EMIC_, true)

EMIC:setInput(DEV:_hal/XXX/xxx.emic)

EMIC:copy(inc/driver.h > TARGET:inc/driver.h)
EMIC:copy(src/driver.c > TARGET:driver.c)

EMIC:define(c_modules.driver, driver)

EMIC:endif
```

### Diferencias Clave: Driver vs API

| Aspecto | Driver | API |
|---------|--------|-----|
| Propósito | Control de hardware | Funcionalidad usuario |
| Tags DOXYGEN | No | Sí |
| Visible en Editor | No | Sí |
| Usa | HAL | Drivers + HAL |
| Ubicación | `_drivers/` | `_api/` |

---

**Navegación:**
- [← Capítulo 21: Desarrollo de una API](21_Desarrollo_API_Paso_a_Paso.md)
- [→ Capítulo 23: Desarrollo de un Módulo Completo](23_Desarrollo_Modulo_Completo.md)
