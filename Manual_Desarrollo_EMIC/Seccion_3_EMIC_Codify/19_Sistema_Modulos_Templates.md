# Capítulo 19: Sistema de Módulos y Templates

## Índice
1. [Introducción](#introducción)
2. [¿Qué es un Template EMIC?](#qué-es-un-template-emic)
3. [Anatomía de un Template](#anatomía-de-un-template)
4. [Crear un Template desde Cero](#crear-un-template-desde-cero)
5. [Patrones de Diseño de Templates](#patrones-de-diseño-de-templates)
6. [Sistema de Módulos](#sistema-de-módulos)
7. [Documentación con DOXYGEN](#documentación-con-doxygen)
8. [Testing y Validación](#testing-y-validación)
9. [Best Practices](#best-practices)
10. [Ejemplos Completos](#ejemplos-completos)
11. [Resumen del Capítulo](#resumen-del-capítulo)

---

## Introducción

Este capítulo es un **tutorial completo** sobre cómo crear componentes reutilizables en EMIC SDK usando EMIC-Codify. Aprenderás a diseñar templates parametrizados que pueden ser instanciados múltiples veces con diferentes configuraciones.

**Lo que aprenderás:**
- Crear templates desde cero (paso a paso)
- Aplicar patrones de diseño probados
- Estructurar módulos completos
- Documentar componentes para EMIC-Discovery
- Probar y validar templates

**Requisitos previos:**
- Capítulos 16-18 (Fundamentos de EMIC-Codify)
- Conocimientos básicos de C
- Comprensión de la estructura del SDK (Sección 2)

---

## ¿Qué es un Template EMIC?

### Definición

> Un **Template EMIC** es un componente de código parametrizado que puede ser **instanciado múltiples veces** con diferentes configuraciones, generando código C independiente para cada instancia.

### Características

1. **Parametrizado**: Acepta parámetros (name, pin, port, etc.)
2. **Reutilizable**: Mismo template → múltiples instancias
3. **Independiente**: Cada instancia genera código separado
4. **Auto-contenido**: Incluye sus propias dependencias
5. **Documentado**: Metadata para EMIC-Discovery

### Ventajas

✅ **Reducción de código duplicado**
```c
// Sin template: 100 líneas × 3 LEDs = 300 líneas
// Con template: 100 líneas base + 3 instancias = ~100 líneas
```

✅ **Consistencia**: Todos los LEDs usan la misma implementación

✅ **Mantenibilidad**: Un bug fix se propaga a todas las instancias

✅ **Escalabilidad**: Fácil añadir más instancias

✅ **Abstracción**: El integrador no ve la complejidad interna

### Ejemplo: LED Template

**Sin template (código duplicado):**
```c
// led1.c
void led1_init() { TRISA0 = 0; }
void led1_state(uint8_t s) { LATA0 = s; }

// led2.c
void led2_init() { TRISA1 = 0; }
void led2_state(uint8_t s) { LATA1 = s; }

// led3.c - MISMO CÓDIGO, DIFERENTES PINES
void led3_init() { TRISA2 = 0; }
void led3_state(uint8_t s) { LATA2 = s; }
```

**Con template:**
```emic
// En generate.emic - Instanciar 3 veces
EMIC:setInput(DEV:_api/led.emic, name=led1, pin=A0_Pin)
EMIC:setInput(DEV:_api/led.emic, name=led2, pin=A1_Pin)
EMIC:setInput(DEV:_api/led.emic, name=led3, pin=A2_Pin)

// Genera led1.c, led2.c, led3.c automáticamente
```

---

## Anatomía de un Template

Un template típico consta de **4 componentes principales**:

```
_api/Indicators/LEDs/           ← Carpeta del componente
├── led.emic                    ← 1. Script EMIC (coordinador)
├── inc/                        ← 2. Headers (templates C)
│   └── led.h
└── src/                        ← 3. Source (templates C)
    └── led.c
```

### 1. Script EMIC (.emic)

**Propósito**: Coordinar la generación del componente

**Archivo: `led.emic`**
```emic
EMIC:tag(driverName = LEDs)

/**
* @fn void LEDs_.{name}._state(uint8_t state);
* @alias .{name}..state
* @brief Change the state of the led, 1-on, 0-off, 2-toggle.
* @param state 1-on 0-off 2-toggle
* @return Nothing
*/

/**
* @fn void LEDs_.{name}._blink(uint16_t timeOn, uint16_t period, uint16_t times);
* @alias .{name}..blink
* @brief blink the .{name}.
* @param timeOn time that the LED lasts on in each cycle.
* @param period length of time each cycle lasts.
* @param times number of cycles.
* @return Nothing
*/

EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

EMIC:copy(inc/led.h > TARGET:inc/led_.{name}..h, name=.{name}., pin=.{pin}.)
EMIC:copy(src/led.c > TARGET:led_.{name}..c, name=.{name}., pin=.{pin}.)

EMIC:define(main_includes.led_.{name}., led_.{name}.)
EMIC:define(c_modules.led_.{name}., led_.{name}.)
```

**Responsabilidades:**
1. **Tags** para EMIC-Discovery
2. **Documentación DOXYGEN** de funciones públicas
3. **Incluir dependencias** (GPIO, Timer)
4. **Copiar templates** con sustituciones
5. **Registrar módulo** para compilación

---

### 2. Header Template (inc/led.h)

**Propósito**: Declarar interfaz pública del componente

**Archivo: `inc/led.h`**
```c
#include <xc.h>

void LEDs_.{name}._init (void);
EMIC:define(inits.LEDs_.{name}., LEDs_.{name}._init)

EMIC:ifdef usedFunction.LEDs_.{name}._blink
void LEDs_.{name}._poll (void);
EMIC:define(polls.LEDs_.{name}., LEDs_.{name}._poll)
EMIC:endif

EMIC:ifdef usedFunction.LEDs_.{name}._state
void LEDs_.{name}._state(uint8_t);
EMIC:endif

EMIC:ifdef usedFunction.LEDs_.{name}._blink
void LEDs_.{name}._blink(uint16_t, uint16_t, uint16_t);
EMIC:endif
```

**Elementos clave:**
- **Variables en nombres**: `LEDs_.{name}._init`
- **Registro de inits**: `EMIC:define(inits.*, ...)`
- **Compilación condicional**: `EMIC:ifdef usedFunction.*`
- **Declaraciones de funciones**: Con parámetros

---

### 3. Source Template (src/led.c)

**Propósito**: Implementación del componente

**Archivo: `src/led.c`**
```c
#include <xc.h>
#include "inc/led_.{name}..h"
#include "inc/gpio.h"
#include "inc/systemTimer.h"

void LEDs_.{name}._init (void)
{
    HAL_GPIO_PinCfg(.{pin}., GPIO_OUTPUT);
}

EMIC:ifdef usedFunction.LEDs_.{name}._state
void LEDs_.{name}._state(uint8_t status)
{
    switch (status)
    {
        case 0:
            HAL_GPIO_PinSet(.{pin}., GPIO_LOW);
            break;
        case 1:
            HAL_GPIO_PinSet(.{pin}., GPIO_HIGH);
            break;
        case 2:
            if (HAL_GPIO_PinGet(.{pin}.))
            {
                HAL_GPIO_PinSet(.{pin}., GPIO_LOW);
            }
            else
            {
                HAL_GPIO_PinSet(.{pin}., GPIO_HIGH);
            }
            break;
    }
}
EMIC:endif

EMIC:ifdef usedFunction.LEDs_.{name}._blink
static uint16_t blkLed_timerOn = 0;
static uint16_t blkLed_period = 0;
static uint16_t blkLed_times = 0;
static uint32_t blkLed_tStamp;

void LEDs_.{name}._blink(uint16_t timeOn, uint16_t period, uint16_t times)
{
    HAL_GPIO_PinSet(.{pin}., GPIO_HIGH);
    blkLed_timerOn = timeOn;
    blkLed_period = period;
    blkLed_times = times;
    blkLed_tStamp = getSystemMilis();
}

void LEDs_.{name}._poll ()
{
    if (blkLed_period > 0)
    {
        if ( getSystemMilis() - blkLed_tStamp > blkLed_period )
        {
            if (blkLed_times > 0)
            {
                blkLed_times--;
                if (blkLed_times == 0)
                {
                    blkLed_period = 0;
                }
            }
            if (blkLed_period > 0)
            {
                HAL_GPIO_PinSet(.{pin}., GPIO_HIGH);
                blkLed_tStamp = getSystemMilis();
            }
        }
        else if ( getSystemMilis() - blkLed_tStamp > blkLed_timerOn )
        {
            HAL_GPIO_PinSet(.{pin}., GPIO_LOW);
        }
    }
}
EMIC:endif
```

**Elementos clave:**
- **Includes dinámicos**: `#include "inc/led_.{name}..h"`
- **Variables en código**: `.{pin}.`, `.{name}.`
- **Compilación condicional**: Solo incluir funciones usadas
- **Variables estáticas**: Por instancia (si es necesario)

---

### Diagrama de Flujo de Generación

```
generate.emic
    ↓
EMIC:setInput(DEV:_api/led.emic, name=led1, pin=A0_Pin)
    ↓
led.emic procesa:
    ├─ Incluye dependencias (GPIO, Timer)
    ├─ Copia inc/led.h → TARGET:inc/led_led1.h
    │   └─ Sustituye .{name}. → led1, .{pin}. → A0_Pin
    └─ Copia src/led.c → TARGET:led_led1.c
        └─ Sustituye .{name}. → led1, .{pin}. → A0_Pin
    ↓
Código C generado:
    ├─ TARGET:inc/led_led1.h
    └─ TARGET:led_led1.c
```

---

## Crear un Template desde Cero

Vamos a crear un **template de Button (botón)** paso a paso.

### Paso 1: Definir Requisitos

**Funcionalidad deseada:**
- Detectar si el botón está presionado
- Debouncing automático
- Callback al presionar
- Multi-instanciable

**Parámetros necesarios:**
- `name`: Nombre de la instancia (ej: btn1, startButton)
- `pin`: Pin físico (ej: B0_Pin, BUTTON1)
- `debounce_ms`: Tiempo de debounce en ms (opcional, default: 50)

**Dependencias:**
- GPIO (HAL)
- SystemTimer (para debounce)

---

### Paso 2: Crear Estructura de Carpetas

```
_api/Inputs/Button/
├── button.emic
├── inc/
│   └── button.h
└── src/
    └── button.c
```

---

### Paso 3: Escribir Script EMIC (button.emic)

```emic
EMIC:tag(driverName = BUTTON)
EMIC:tag(category = Inputs)

/**
* @fn uint8_t Button_.{name}._isPressed(void);
* @alias .{name}..isPressed
* @brief Check if button is currently pressed
* @return 1 if pressed, 0 if not
*/

/**
* @fn extern void on.{name}.Pressed(void);
* @alias on.{name}.Pressed
* @brief Callback when button is pressed (user must implement)
* @return Nothing
*/

// Dependencias
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

// Valor por defecto para debounce
EMIC:ifndef debounce_ms
    EMIC:define(debounce_ms, 50)
EMIC:endif

// Copiar templates
EMIC:copy(
    inc/button.h > TARGET:inc/button_.{name}..h,
    name=.{name}.,
    pin=.{pin}.,
    debounce_ms=.{debounce_ms}.
)

EMIC:copy(
    src/button.c > TARGET:button_.{name}..c,
    name=.{name}.,
    pin=.{pin}.,
    debounce_ms=.{debounce_ms}.
)

// Registrar para compilación
EMIC:define(main_includes.button_.{name}., button_.{name}.)
EMIC:define(c_modules.button_.{name}., button_.{name}.)
```

---

### Paso 4: Escribir Header Template (inc/button.h)

```c
#ifndef BUTTON_.{name}._H
#define BUTTON_.{name}._H

#include <xc.h>
#include <stdint.h>

// Inicialización (llamada automáticamente)
void Button_.{name}._init(void);
EMIC:define(inits.Button_.{name}., Button_.{name}._init)

// Poll (debe llamarse en loop principal)
void Button_.{name}._poll(void);
EMIC:define(polls.Button_.{name}., Button_.{name}._poll)

// API pública
uint8_t Button_.{name}._isPressed(void);

// Callback (el usuario debe implementar)
extern void on.{name}.Pressed(void);
EMIC:define(usedEvent.on.{name}.Pressed, true)

#endif
```

---

### Paso 5: Escribir Source Template (src/button.c)

```c
#include "inc/button_.{name}..h"
#include "inc/gpio.h"
#include "inc/systemTimer.h"

// Estado interno
static uint8_t button_state = 0;       // 0: released, 1: pressed
static uint8_t button_last_read = 0;
static uint32_t button_last_change = 0;

void Button_.{name}._init(void)
{
    // Configurar pin como entrada con pull-up
    HAL_GPIO_PinCfg(.{pin}., GPIO_INPUT_PULLUP);
    button_state = 0;
    button_last_read = 1;  // Pull-up → HIGH cuando no presionado
    button_last_change = 0;
}

uint8_t Button_.{name}._isPressed(void)
{
    return button_state;
}

void Button_.{name}._poll(void)
{
    uint8_t current_read = HAL_GPIO_PinGet(.{pin}.);

    // Detectar cambio
    if (current_read != button_last_read)
    {
        button_last_read = current_read;
        button_last_change = getSystemMilis();
    }

    // Debouncing
    if ((getSystemMilis() - button_last_change) > .{debounce_ms}.)
    {
        uint8_t new_state = (current_read == 0) ? 1 : 0;  // Invertir (pull-up)

        // Detectar transición: no presionado → presionado
        if (new_state == 1 && button_state == 0)
        {
            button_state = 1;

            // Llamar callback
            EMIC:ifdef usedEvent.on.{name}.Pressed
            on.{name}.Pressed();
            EMIC:endif
        }
        else if (new_state == 0 && button_state == 1)
        {
            button_state = 0;
        }
    }
}
```

---

### Paso 6: Usar el Template

**En generate.emic:**
```emic
// Botón de inicio con debounce por defecto (50ms)
EMIC:setInput(
    DEV:_api/Inputs/Button/button.emic,
    name=startButton,
    pin=START_BTN_Pin
)

// Botón de parada con debounce personalizado
EMIC:setInput(
    DEV:_api/Inputs/Button/button.emic,
    name=stopButton,
    pin=STOP_BTN_Pin,
    debounce_ms=100
)
```

**En userFncFile.c (código del integrador):**
```c
// Implementar callback
void onstartButtonPressed(void)
{
    // Código al presionar startButton
    led1_state(1);
}

void onstopButtonPressed(void)
{
    // Código al presionar stopButton
    led1_state(0);
}
```

**Código generado:**
- `TARGET:inc/button_startButton.h`
- `TARGET:button_startButton.c`
- `TARGET:inc/button_stopButton.h`
- `TARGET:button_stopButton.c`

---

## Patrones de Diseño de Templates

### Patrón 1: Template Simple

**Características:**
- Sin dependencias externas
- Parámetros básicos (name, pin)
- Una o dos funciones

**Ejemplo: Toggle Pin**

```emic
// toggle.emic
EMIC:tag(driverName = TOGGLE)

EMIC:setInput(DEV:_hal/GPIO/gpio.emic)

EMIC:copy(inc/toggle.h > TARGET:inc/toggle_.{name}..h, name=.{name}., pin=.{pin}.)
EMIC:copy(src/toggle.c > TARGET:toggle_.{name}..c, name=.{name}., pin=.{pin}.)

EMIC:define(c_modules.toggle_.{name}., toggle_.{name}.)
```

---

### Patrón 2: Template con Dependencias

**Características:**
- Requiere otros componentes (GPIO, Timer, etc.)
- Incluye dependencias con `EMIC:setInput`
- Más parámetros de configuración

**Ejemplo: LED (visto anteriormente)**
- Depende de: GPIO + SystemTimer
- Parámetros: name, pin
- Funciones: state, blink

---

### Patrón 3: Template Multi-Instanciable con Estado

**Características:**
- Variables estáticas por instancia
- Poll function para actualización
- Múltiples instancias independientes

**Ejemplo: Timer API**

```emic
// timer_api.emic
EMIC:tag(driverName = TIMER)

EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

EMIC:copy(inc/timer_api.h > TARGET:inc/timer_api.{name}..h, name=.{name}.)
EMIC:copy(src/timer_api.c > TARGET:timer_api.{name}..c, name=.{name}.)

EMIC:define(main_includes.timer_api.{name}., timer_api.{name}.)
EMIC:define(c_modules.timer_api.{name}., timer_api.{name}.)
```

**Estado por instancia:**
```c
// En timer_api1.c
static uint16_t timer_value = 0;
static uint8_t timer_mode = 0;

// En timer_api2.c - INDEPENDIENTE
static uint16_t timer_value = 0;  // ¡Variables separadas!
static uint8_t timer_mode = 0;
```

---

### Patrón 4: Template con Backends Opcionales

**Características:**
- Múltiples implementaciones posibles
- Selección mediante condicionales
- Un solo template, varios backends

**Ejemplo: Communication API**

```emic
// comm_api.emic
EMIC:tag(driverName = COMMUNICATION)

// Parámetro: backend = uart | usb | ethernet

EMIC:ifdef backend.uart
    EMIC:setInput(DEV:_drivers/UART/uart_driver.emic, port=.{port}., baud=.{baud}.)
EMIC:endif

EMIC:ifdef backend.usb
    EMIC:setInput(DEV:_drivers/USB/MCP2200/MCP2200.emic, port=.{port}.)
EMIC:endif

EMIC:ifdef backend.ethernet
    EMIC:setInput(DEV:_drivers/Ethernet/W5500/w5500.emic, spi_port=.{spi_port}.)
EMIC:endif

// Código común
EMIC:copy(inc/comm_api.h > TARGET:inc/comm_api.h)
EMIC:copy(src/comm_api.c > TARGET:comm_api.c, backend=.{backend}.)
```

**Uso:**
```emic
// Proyecto 1: UART
EMIC:define(backend.uart, true)
EMIC:setInput(DEV:_api/comm_api.emic, backend=uart, port=1, baud=115200)

// Proyecto 2: USB
EMIC:define(backend.usb, true)
EMIC:setInput(DEV:_api/comm_api.emic, backend=usb, port=1)
```

---

### Patrón 5: Template con Configuración Dinámica

**Características:**
- Valores por defecto para parámetros opcionales
- Verificación de parámetros
- Flexibilidad sin complejidad

**Ejemplo: UART con defaults**

```emic
// uart_api.emic

// Valores por defecto
EMIC:ifndef baud
    EMIC:define(baud, 9600)
EMIC:endif

EMIC:ifndef buffer_size
    EMIC:define(buffer_size, 256)
EMIC:endif

EMIC:ifndef parity
    EMIC:define(parity, NONE)
EMIC:endif

// Usar parámetros
EMIC:copy(
    src/uart.c > TARGET:uart_.{port}..c,
    port=.{port}.,
    baud=.{baud}.,
    buffer_size=.{buffer_size}.,
    parity=.{parity}.
)
```

**Uso:**
```emic
// Mínimo (usa defaults)
EMIC:setInput(DEV:_api/uart_api.emic, port=1)

// Personalizado
EMIC:setInput(DEV:_api/uart_api.emic, port=2, baud=115200, buffer_size=1024, parity=EVEN)
```

---

## Sistema de Módulos

### ¿Qué es un Módulo EMIC?

Un **módulo** es una unidad completa de hardware + firmware con su propio `generate.emic`.

**Estructura:**
```
_modules/Category/ModuleName/
├── System/
│   ├── generate.emic       ← Script principal del módulo
│   ├── deploy.emic         ← Script de deployment
│   ├── module.json         ← Metadata del módulo
│   ├── config.json         ← Configuración dinámica
│   └── userFncFile.c       ← Código del integrador
└── Target/                 ← Código generado (output)
```

---

### generate.emic de un Módulo

**Ejemplo: Módulo con 2 Relays + LED + Timer + EMICBus**

**Archivo: `_modules/Actuators/HRD_X2_RELAY/System/generate.emic`**
```emic
EMIC:setOutput(TARGET:generate.txt)

    //-------------- Hardware Config ---------------------
    EMIC:setInput(DEV:_pcb/pcb.emic, pcb=HDR_uC2Relay_V2.0)

    //------------------- Process EMIC-Generate files result ----------------
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    //------------------- APIs -----------------------
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=SystemLED, pin=Led1)
    EMIC:setInput(DEV:_api/Actuators/Relay/relay.emic, name=Relay1, pin=Rele1)
    EMIC:setInput(DEV:_api/Actuators/Relay/relay.emic, name=Relay2, pin=Rele2)
    EMIC:setInput(DEV:_api/Timers/timer_api.emic, name=1)
    EMIC:setInput(DEV:_api/Wired_Communication/EMICBus/EMICBus.emic, port=1, frameID=0)

    //-------------------- main  -----------------------
    EMIC:setInput(DEV:_main/baremetal/main.emic)

    //------------------- Copy EMIC-Generate files result ----------------
    EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
    EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)

    //------------------- Set userFncFile.c as compiler module ----------------
    EMIC:define(c_modules.userFncFile, userFncFile)

    //------------------- Add all compiler modules to the project ----------------
    EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

**Responsabilidades del generate.emic:**
1. **Configurar hardware** (PCB)
2. **Incluir archivos generados** (usedFunction, usedEvent)
3. **Instanciar APIs** (LEDs, Relays, Timers, etc.)
4. **Incluir main.c**
5. **Copiar código del integrador**
6. **Copiar template de proyecto** (Makefile, etc.)

---

### module.json - Metadata del Módulo

```json
{
    "name": "HRD_X2_RELAY",
    "version": "1.0.0",
    "category": "Actuators",
    "description": "Módulo con 2 relays controlables",
    "author": "EMIC Teams",
    "hardware": {
        "pcb": "HDR_uC2Relay_V2.0",
        "mcu": "pic24FJ64GA002",
        "relays": 2,
        "leds": 1
    },
    "apis": [
        "LEDs",
        "Relay",
        "Timer",
        "EMICBus"
    ]
}
```

---

## Documentación con DOXYGEN

EMIC-Discovery extrae funciones documentadas con **tags DOXYGEN especiales** en los archivos .emic.

### Formato de Documentación

```emic
/**
* @fn <signature de la función>
* @alias <alias para EMIC-Editor>
* @brief <descripción breve>
* @param <nombre> <descripción del parámetro>
* @return <descripción del retorno>
*/
```

### Ejemplo Completo

```emic
/**
* @fn void LEDs_.{name}._state(uint8_t state);
* @alias .{name}..state
* @brief Change the state of the led, 1-on, 0-off, 2-toggle.
* @param state 1-on 0-off 2-toggle
* @return Nothing
*/

/**
* @fn void LEDs_.{name}._blink(uint16_t timeOn, uint16_t period, uint16_t times);
* @alias .{name}..blink
* @brief blink the .{name}.
* @param timeOn time that the LED lasts on in each cycle.
* @param period length of time each cycle lasts.
* @param times number of cycles.
* @return Nothing
*/
```

### EMIC-Discovery

**Proceso:**
1. EMIC-Discovery **escanea todos los archivos .emic**
2. **Extrae** todos los bloques `/** @fn ... */`
3. **Lee los tags** `EMIC:tag`
4. **Genera índice JSON** con todos los recursos
5. **EMIC-Editor** muestra estos recursos al integrador

**Resultado en EMIC-Editor:**
```
Indicadores > LEDs
  └─ led
      ├─ .{name}..state(state) - Change the state of the led
      └─ .{name}..blink(timeOn, period, times) - blink the led
```

---

## Testing y Validación

### 1. Test de Instancia Única

```emic
// En generate.emic
EMIC:setInput(DEV:_api/myComponent.emic, name=test1, pin=A0)
```

**Verificar:**
- ✅ Archivos generados: `TARGET:myComponent_test1.c`, `TARGET:inc/myComponent_test1.h`
- ✅ Compilación sin errores
- ✅ Funciones accesibles en userFncFile.c

---

### 2. Test de Multi-Instanciación

```emic
// En generate.emic
EMIC:setInput(DEV:_api/myComponent.emic, name=inst1, pin=A0)
EMIC:setInput(DEV:_api/myComponent.emic, name=inst2, pin=A1)
EMIC:setInput(DEV:_api/myComponent.emic, name=inst3, pin=A2)
```

**Verificar:**
- ✅ 3 pares de archivos generados
- ✅ Cada instancia es independiente (variables separadas)
- ✅ No hay colisiones de nombres

---

### 3. Test de Parámetros Opcionales

```emic
// Con defaults
EMIC:setInput(DEV:_api/myComponent.emic, name=test1)

// Con todos los parámetros
EMIC:setInput(DEV:_api/myComponent.emic, name=test2, param1=value1, param2=value2)
```

**Verificar:**
- ✅ Defaults aplicados correctamente
- ✅ Parámetros personalizados usados cuando se proporcionan

---

### 4. Test de Dependencias

**Verificar:**
- ✅ Dependencias incluidas automáticamente
- ✅ Include guards previenen duplicados
- ✅ Orden de inclusión correcto

---

### 5. Validar Código Generado

**Checklist:**
```
□ Código C compilable (sin errores)
□ Nombres de funciones únicos por instancia
□ Variables sustituidas correctamente (no quedan .{*}.)
□ Includes correctos
□ Init functions registradas
□ Poll functions registradas (si aplica)
□ Callbacks definidos correctamente
```

---

## Best Practices

### 1. Nomenclatura Consistente

```emic
// ✅ BUENO: Prefijo claro + nombre + sufijo
void LEDs_.{name}._init(void);
void LEDs_.{name}._state(uint8_t state);
void Button_.{name}._isPressed(void);

// ❌ MALO: Nombres ambiguos
void .{name}._init(void);  // ¿Qué tipo de componente?
void do_something_.{name}.(void);  // Poco descriptivo
```

---

### 2. Include Guards Siempre

```emic
EMIC:ifndef _MY_COMPONENT_EMIC_
EMIC:define(_MY_COMPONENT_EMIC_, true)

    // Código del template

EMIC:endif
```

---

### 3. Valores por Defecto para Opcionales

```emic
// Proveer defaults razonables
EMIC:ifndef buffer_size
    EMIC:define(buffer_size, 256)
EMIC:endif

EMIC:ifndef timeout_ms
    EMIC:define(timeout_ms, 1000)
EMIC:endif
```

---

### 4. Documentación Completa

```emic
/**
* @fn <firma exacta con variables>
* @alias <alias corto y claro>
* @brief <descripción de UNA línea>
* @param <cada parámetro documentado>
* @return <qué retorna>
*/
```

---

### 5. Separar Interfaz de Implementación

**Header (.h):**
- Solo declaraciones
- Definiciones de macros
- Typedefs

**Source (.c):**
- Implementaciones
- Variables estáticas
- Funciones auxiliares privadas

---

### 6. Usar Compilación Condicional

```c
EMIC:ifdef usedFunction.MyComponent_.{name}._advancedFeature
    // Solo incluir si el usuario usa esta función
    void MyComponent_.{name}._advancedFeature(void) {
        // implementación
    }
EMIC:endif
```

**Ventaja:** Reduce tamaño del binario final.

---

### 7. Registrar Inits y Polls

```c
// En header
void MyComponent_.{name}._init(void);
EMIC:define(inits.MyComponent_.{name}., MyComponent_.{name}._init)

void MyComponent_.{name}._poll(void);
EMIC:define(polls.MyComponent_.{name}., MyComponent_.{name}._poll)
```

**Razón:** `main.emic` los llamará automáticamente.

---

### 8. Tags Descriptivos

```emic
EMIC:tag(driverName = MyComponent)
EMIC:tag(category = Communication)
EMIC:tag(version = 1.0.0)
EMIC:tag(author = Your Name)
EMIC:tag(requiresPeripheral = UART,I2C)
EMIC:tag(requiresMCU = PIC24,dsPIC33)
```

---

## Ejemplos Completos

### Ejemplo 1: Sensor de Temperatura (ADC + Conversión)

**temperature.emic:**
```emic
EMIC:tag(driverName = TEMPERATURE_SENSOR)
EMIC:tag(category = Sensors)

/**
* @fn float Temperature_.{name}._read(void);
* @alias .{name}..read
* @brief Read temperature in Celsius
* @return Temperature value in °C
*/

// Dependencias
EMIC:setInput(DEV:_hal/ADC/adc.emic, channel=.{channel}.)

// Default: Sensor tipo LM35 (10mV/°C)
EMIC:ifndef sensor_mv_per_c
    EMIC:define(sensor_mv_per_c, 10)
EMIC:endif

EMIC:copy(inc/temperature.h > TARGET:inc/temperature_.{name}..h, name=.{name}., channel=.{channel}.)
EMIC:copy(src/temperature.c > TARGET:temperature_.{name}..c, name=.{name}., channel=.{channel}., mv_per_c=.{sensor_mv_per_c}.)

EMIC:define(c_modules.temperature_.{name}., temperature_.{name}.)
```

**temperature.c:**
```c
#include "inc/temperature_.{name}..h"
#include "inc/adc.h"

float Temperature_.{name}._read(void)
{
    uint16_t adc_value = HAL_ADC_Read(.{channel}.);

    // Convertir ADC a voltaje (asumiendo 3.3V ref, 10-bit ADC)
    float voltage_mv = (adc_value * 3300.0) / 1024.0;

    // Convertir voltaje a temperatura
    float temperature_c = voltage_mv / .{mv_per_c}.;

    return temperature_c;
}
```

**Uso:**
```emic
EMIC:setInput(DEV:_api/temperature.emic, name=ambientTemp, channel=0)
```

---

### Ejemplo 2: PWM para Control de Motor

**motor_pwm.emic:**
```emic
EMIC:tag(driverName = MOTOR_PWM)
EMIC:tag(category = Actuators)

/**
* @fn void Motor_.{name}._setSpeed(uint8_t speed);
* @alias .{name}..setSpeed
* @brief Set motor speed (0-100%)
* @param speed Speed percentage 0-100
* @return Nothing
*/

EMIC:setInput(DEV:_hal/PWM/pwm.emic, channel=.{channel}.)
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)

EMIC:copy(inc/motor_pwm.h > TARGET:inc/motor_pwm_.{name}..h, name=.{name}., channel=.{channel}., dir_pin=.{dir_pin}.)
EMIC:copy(src/motor_pwm.c > TARGET:motor_pwm_.{name}..c, name=.{name}., channel=.{channel}., dir_pin=.{dir_pin}.)

EMIC:define(c_modules.motor_pwm_.{name}., motor_pwm_.{name}.)
```

**motor_pwm.c:**
```c
#include "inc/motor_pwm_.{name}..h"
#include "inc/pwm.h"
#include "inc/gpio.h"

void Motor_.{name}._init(void)
{
    HAL_PWM_Init(.{channel}., 1000);  // 1 kHz PWM
    HAL_GPIO_PinCfg(.{dir_pin}., GPIO_OUTPUT);
}

void Motor_.{name}._setSpeed(uint8_t speed)
{
    if (speed > 100) speed = 100;

    uint16_t duty = (speed * 1023) / 100;  // 0-100% → 0-1023
    HAL_PWM_SetDuty(.{channel}., duty);
}

void Motor_.{name}._setDirection(uint8_t forward)
{
    HAL_GPIO_PinSet(.{dir_pin}., forward ? 1 : 0);
}
```

---

## Resumen del Capítulo

### Puntos Clave

1. **Templates = Código Reutilizable Parametrizado**
   - Un template → múltiples instancias
   - Reducen duplicación de código
   - Facilitan mantenimiento

2. **Anatomía de un Template:**
   - Script .emic (coordinador)
   - Header template (.h)
   - Source template (.c)

3. **Proceso de Creación:**
   - Definir requisitos y parámetros
   - Crear estructura de carpetas
   - Escribir script .emic con tags
   - Implementar templates C con variables
   - Documentar con DOXYGEN

4. **Patrones de Diseño:**
   - Simple (solo GPIO)
   - Con dependencias (GPIO + Timer)
   - Multi-instanciable con estado
   - Con backends opcionales
   - Con configuración dinámica

5. **Sistema de Módulos:**
   - `generate.emic` orquesta todo
   - Combina múltiples APIs
   - Incluye main + templates + user code

6. **Best Practices:**
   - Include guards siempre
   - Valores por defecto
   - Documentación completa
   - Compilación condicional
   - Registrar inits/polls

### Próximo Capítulo

El **Capítulo 20** cubrirá el **Proceso completo de EMIC-Generate**, cerrando la Sección 3 con una visión end-to-end del compilador EMIC.

---

**Fin del Capítulo 19**

**Progreso del Manual:**
- **Sección 1 (Introducción):** ████████████████████ 100% (5/5) ✅
- **Sección 2 (Estructura SDK):** ████████████████████ 100% (11/11) ✅
- **Sección 3 (EMIC-Codify):** ████████████████████░  80% (4/5)

**Progreso Total: 19/38 capítulos (50%) 🎉 ¡MITAD DEL MANUAL!**

---

**Referencias:**
- Capítulo 16: Introducción a EMIC-Codify
- Capítulo 17: Sintaxis Avanzada de EMIC-Codify
- Capítulo 18: Directivas Completas de EMIC-Codify
- Capítulo 06: Carpeta `_modules/`
- Capítulo 07: Carpeta `_api/`
