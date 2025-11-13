# Capítulo 22: Desarrollar una API Personalizada

## Índice
1. [Introducción](#introducción)
2. [¿Qué es una API EMIC?](#qué-es-una-api-emic)
3. [Diferencia: API vs Driver vs HAL](#diferencia-api-vs-driver-vs-hal)
4. [Anatomía de una API](#anatomía-de-una-api)
5. [Requisitos Previos](#requisitos-previos)
6. [Tutorial Completo: API Button](#tutorial-completo-api-button)
7. [Paso 1: Planificar la API](#paso-1-planificar-la-api)
8. [Paso 2: Crear Estructura de Carpetas](#paso-2-crear-estructura-de-carpetas)
9. [Paso 3: Escribir button.emic](#paso-3-escribir-buttonemic)
10. [Paso 4: Crear button.h](#paso-4-crear-buttonh)
11. [Paso 5: Implementar button.c](#paso-5-implementar-buttonc)
12. [Paso 6: Testing y Validación](#paso-6-testing-y-validación)
13. [Paso 7: Documentar con DOXYGEN](#paso-7-documentar-con-doxygen)
14. [Ejemplo Avanzado: API PWM](#ejemplo-avanzado-api-pwm)
15. [Patrones de Diseño de APIs](#patrones-de-diseño-de-apis)
16. [Buenas Prácticas](#buenas-prácticas)
17. [Errores Comunes](#errores-comunes)
18. [Resumen del Capítulo](#resumen-del-capítulo)

---

## Introducción

En el capítulo anterior aprendiste a **usar APIs** para crear proyectos. Ahora aprenderás a **crear tus propias APIs** reutilizables que otros integradores (o tú mismo) podrán usar en múltiples proyectos.

### ¿Por qué Crear APIs?

Las APIs EMIC son el **corazón del SDK**. Crear APIs de calidad permite:
- ✅ Reutilizar código en múltiples proyectos
- ✅ Compartir componentes con la comunidad
- ✅ Abstraer complejidad de hardware
- ✅ Facilitar el trabajo de integradores
- ✅ Construir bibliotecas corporativas

### ¿Quién Crea APIs?

**Desarrolladores** con conocimientos de:
- Programación C embebida
- Hardware específico (MCU, periféricos, sensores)
- EMIC-Codify (parametrización)
- Diseño de interfaces reutilizables

---

## ¿Qué es una API EMIC?

Una **API EMIC** es un **componente reutilizable y parametrizable** que encapsula funcionalidad de hardware o software, exponiendo una interfaz simple para que los integradores la usen sin conocer los detalles internos.

### Definición Formal

> **API EMIC**: Conjunto de archivos (`.emic`, `.c`, `.h`) que:
> 1. Proporciona funciones y variables públicas
> 2. Se parametriza mediante variables tipo `.{name}.`, `.{pin}.`
> 3. Se puede instanciar múltiples veces con configuraciones diferentes
> 4. Declara sus dependencias (drivers, HAL)
> 5. Se documenta con etiquetas DOXYGEN para EMIC-Discovery

### Ejemplo Conceptual

```
┌─────────────────────────────────────────────────────────────┐
│              API: Button (Botón Genérico)                   │
│                                                             │
│  ENTRADA:                                                   │
│    name   = "boton_inicio"                                  │
│    pin    = B0_Pin                                          │
│    debounce = 50 (ms)                                       │
│                                                             │
│  SALIDA (código generado):                                  │
│    void boton_inicio_Init(void)                             │
│    bool boton_inicio_IsPressed(void)                        │
│    bool boton_inicio_WasPressed(void)                       │
│                                                             │
│  DEPENDENCIAS:                                              │
│    HAL/GPIO (para leer pin)                                 │
│    SystemTimer (para debounce)                              │
└─────────────────────────────────────────────────────────────┘
```

### Características Clave

1. **Parametrizable**
   - Múltiples instancias con nombres diferentes
   - Configuración flexible (pins, tiempos, modos)

2. **Reutilizable**
   - Funciona en diferentes proyectos
   - No hardcodea valores específicos

3. **Autodescriptiva**
   - Documenta sus funciones con DOXYGEN
   - EMIC-Discovery extrae recursos publicados

4. **Modular**
   - Declara dependencias explícitamente
   - Se integra con otras APIs/drivers

---

## Diferencia: API vs Driver vs HAL

Es crucial entender las diferencias entre las capas del SDK:

| Aspecto | API | Driver | HAL |
|---------|-----|--------|-----|
| **Nivel** | Alto | Medio | Bajo |
| **Abstracción** | Funcionalidad completa | Control de chip | Acceso a periférico MCU |
| **Portabilidad** | Alta (independiente de MCU) | Media (depende de protocolo) | Baja (específico de MCU) |
| **Ejemplo** | LED, Timer, UART | DHT22, RFM95, MCP2200 | GPIO, SPI, I2C |
| **Depende de** | Drivers, HAL | HAL | Hardware (_hard) |
| **Usuario típico** | Integrador | Desarrollador API | Desarrollador Driver |

### Ejemplo Visual

```
┌──────────────────────────────────────────────────────────────┐
│                     API: Sensor de Temperatura               │
│  - temp_sensor_Read()                                        │
│  - temp_sensor_GetTemperature()                              │
│  - temp_sensor_SetUnit(CELSIUS/FAHRENHEIT)                   │
│                                                              │
│  Abstracción: "Leer temperatura" sin conocer tipo de sensor │
└──────────────────────────────────────────────────────────────┘
                         │
                         ↓ depende de
┌──────────────────────────────────────────────────────────────┐
│                  Driver: DHT22 (sensor específico)           │
│  - dht22_Init()                                              │
│  - dht22_ReadData()                                          │
│  - dht22_GetHumidity()                                       │
│                                                              │
│  Abstracción: Control del chip DHT22                        │
└──────────────────────────────────────────────────────────────┘
                         │
                         ↓ depende de
┌──────────────────────────────────────────────────────────────┐
│                    HAL: GPIO (periférico MCU)                │
│  - HAL_GPIO_PinCfg()                                         │
│  - HAL_GPIO_PinSet()                                         │
│  - HAL_GPIO_PinGet()                                         │
│                                                              │
│  Abstracción: Acceso genérico a pines del MCU               │
└──────────────────────────────────────────────────────────────┘
                         │
                         ↓ depende de
┌──────────────────────────────────────────────────────────────┐
│              _hard: PIC24 (hardware específico)              │
│  - Registros: TRISA, LATA, PORTA                            │
│  - Código específico del microcontrolador                    │
└──────────────────────────────────────────────────────────────┘
```

---

## Anatomía de una API

### Estructura de Directorios

```
_api/
└── Categoria/           # Ej: Indicators, Sensors, Communication
    └── NombreAPI/       # Ej: Button, LED, Temperature
        ├── nombre_api.emic    # Script EMIC (CLAVE)
        ├── inc/               # Headers
        │   └── nombre_api.h
        └── src/               # Implementación
            └── nombre_api.c
```

### Archivo .emic (Script EMIC)

El archivo `.emic` es el **punto de entrada**. Define:
1. **Tags** para EMIC-Discovery
2. **Documentación DOXYGEN** de funciones publicadas
3. **Dependencias** (otros drivers/APIs)
4. **Directivas de copia** con parametrización

**Ejemplo:**
```emic
EMIC:tag(driverName = BUTTON)

/**
* @fn bool button_.{name}._IsPressed(void);
* @alias .{name}..IsPressed
* @brief Check if button is currently pressed
* @return true if pressed, false otherwise
*/

EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

EMIC:copy(inc/button.h > TARGET:inc/button_.{name}..h,name=.{name}.,pin=.{pin}.,debounce=.{debounce}.)
EMIC:copy(src/button.c > TARGET:button_.{name}..c,name=.{name}.,pin=.{pin}.,debounce=.{debounce}.)

EMIC:define(main_includes.button_.{name}.,button_.{name}.)
EMIC:define(c_modules.button_.{name}.,button_.{name}.)
```

### Archivo .h (Header)

El header define:
1. **Prototipos de funciones** con variables `.{name}.`
2. **Condicionales EMIC** para incluir solo funciones usadas
3. **Macros de inicialización** (registradas en `inits`)

**Ejemplo:**
```c
#include <xc.h>

void button_.{name}._Init(void);
EMIC:define(inits.button_.{name}.,button_.{name}._Init)

EMIC:ifdef usedFunction.button_.{name}._IsPressed
bool button_.{name}._IsPressed(void);
EMIC:endif

EMIC:ifdef usedFunction.button_.{name}._WasPressed
bool button_.{name}._WasPressed(void);
void button_.{name}._Poll(void);
EMIC:define(polls.button_.{name}.,button_.{name}._Poll)
EMIC:endif
```

### Archivo .c (Implementación)

La implementación contiene:
1. **Código C** con variables parametrizadas `.{name}.`, `.{pin}.`
2. **Condicionales EMIC** para compilar solo lo necesario
3. **Llamadas a HAL/drivers** de capas inferiores

**Ejemplo:**
```c
#include "inc/button_.{name}..h"
#include "inc/gpio.h"
#include "inc/systemTimer.h"

void button_.{name}._Init(void) {
    HAL_GPIO_PinCfg(.{pin}., GPIO_INPUT);
}

EMIC:ifdef usedFunction.button_.{name}._IsPressed
bool button_.{name}._IsPressed(void) {
    return HAL_GPIO_PinGet(.{pin}.) == GPIO_LOW;  // Pull-up activo
}
EMIC:endif
```

---

## Requisitos Previos

### Conocimientos Requeridos

- ✅ Programación C embebida (punteros, estructuras, bitwise)
- ✅ EMIC-Codify (Sección 3 completa)
- ✅ Estructura del SDK (Sección 2)
- ✅ Crear proyectos EMIC (Capítulo 21)
- ✅ Hardware específico que la API controlará

### Herramientas Requeridas

- **Editor de texto** (VSCode, Sublime, etc.)
- **SDK EMIC** clonado localmente
- **EMIC-Generate** para testing
- **MPLAB X + XC Compiler** para compilación
- **Documentación del hardware** (datasheet del sensor/chip)

---

## Tutorial Completo: API Button

Vamos a crear una **API completa de Botón** desde cero, paso a paso.

### Especificaciones

**Funcionalidad:**
- Detectar si el botón está presionado actualmente
- Detectar si el botón fue presionado (edge detection)
- Debounce configurable (eliminar rebotes)
- Soportar pull-up interno o externo
- Múltiples instancias (varios botones)

**Parámetros:**
- `name`: Nombre de la instancia (ej: "start_button", "stop_button")
- `pin`: Pin GPIO conectado (ej: "B0_Pin", "A3_Pin")
- `debounce`: Tiempo de debounce en ms (default: 50ms)
- `pull_mode`: "internal" o "external" (default: "internal")

**Funciones Públicas:**
- `button_{name}_Init()`: Inicializar hardware
- `button_{name}_IsPressed()`: Retorna true si está presionado AHORA
- `button_{name}_WasPressed()`: Retorna true si fue presionado desde última consulta
- `button_{name}_Poll()`: Actualizar estado (llamar en loop)

**Dependencias:**
- HAL/GPIO (para leer pin)
- SystemTimer (para debounce)

---

## Paso 1: Planificar la API

### Diagrama de Estados

```
┌──────────────┐
│   RELEASED   │ (Estado inicial)
│  (no presionado)
└──────┬───────┘
       │ Presionado por > debounce_ms
       ↓
┌──────────────┐
│   PRESSED    │
│  (presionado)
└──────┬───────┘
       │ Liberado por > debounce_ms
       ↓
┌──────────────┐
│   RELEASED   │
└──────────────┘
```

### Máquina de Estados

```c
typedef enum {
    BTN_STATE_RELEASED,   // Botón liberado
    BTN_STATE_PRESSED,    // Botón presionado
    BTN_STATE_DEBOUNCING  // En proceso de debounce
} ButtonState_t;
```

### Variables Internas

```c
static ButtonState_t state = BTN_STATE_RELEASED;
static uint32_t last_change_time = 0;
static bool was_pressed_flag = false;
```

---

## Paso 2: Crear Estructura de Carpetas

```bash
# Crear directorios
mkdir -p _api/Inputs/Button/inc
mkdir -p _api/Inputs/Button/src
```

**Resultado:**
```
_api/
└── Inputs/
    └── Button/
        ├── button.emic      # A crear
        ├── inc/
        │   └── button.h     # A crear
        └── src/
            └── button.c     # A crear
```

---

## Paso 3: Escribir button.emic

**Archivo:** `_api/Inputs/Button/button.emic`

```emic
EMIC:tag(driverName = BUTTON)
EMIC:tag(category = Inputs)

/**
* @fn void button_.{name}._Init(void);
* @alias .{name}..Init
* @brief Initialize button hardware (configure GPIO pin)
* @return Nothing
*/

/**
* @fn bool button_.{name}._IsPressed(void);
* @alias .{name}..IsPressed
* @brief Check if button is currently pressed
* @return true if button is pressed, false otherwise
*/

/**
* @fn bool button_.{name}._WasPressed(void);
* @alias .{name}..WasPressed
* @brief Check if button was pressed since last call (edge detection)
* @details This function returns true only once per button press.
*          Call button_.{name}._Poll() in your main loop for this to work.
* @return true if button was pressed, false otherwise
*/

/**
* @fn void button_.{name}._Poll(void);
* @alias .{name}..Poll
* @brief Update button state (debounce processing)
* @details Call this function in your main loop
* @return Nothing
*/

// Dependencias
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

// Valores por defecto para parámetros opcionales
EMIC:ifndef debounce
    EMIC:define(debounce, 50)
EMIC:endif

EMIC:ifndef pull_mode
    EMIC:define(pull_mode, internal)
EMIC:endif

// Copiar archivos con sustitución de variables
EMIC:copy(inc/button.h > TARGET:inc/button_.{name}..h,name=.{name}.,pin=.{pin}.,debounce=.{debounce}.,pull_mode=.{pull_mode}.)
EMIC:copy(src/button.c > TARGET:button_.{name}..c,name=.{name}.,pin=.{pin}.,debounce=.{debounce}.,pull_mode=.{pull_mode}.)

// Registrar archivos en el sistema de compilación
EMIC:define(main_includes.button_.{name}.,button_.{name}.)
EMIC:define(c_modules.button_.{name}.,button_.{name}.)
```

### Explicación Línea por Línea

```emic
EMIC:tag(driverName = BUTTON)
EMIC:tag(category = Inputs)
```
- Tags para EMIC-Discovery
- Clasifican la API en el sistema

```emic
/**
* @fn bool button_.{name}._IsPressed(void);
* @alias .{name}..IsPressed
* ...
*/
```
- Documentación DOXYGEN
- `@fn`: Prototipo de la función (con variables `.{name}.`)
- `@alias`: Nombre corto para EMIC-Editor (sin prefijo "button_")
- EMIC-Discovery extrae esto para publicar en el IDE

```emic
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)
```
- Declarar dependencias
- Se incluyen recursivamente durante EMIC-Generate

```emic
EMIC:ifndef debounce
    EMIC:define(debounce, 50)
EMIC:endif
```
- Valor por defecto para parámetro opcional
- Si el integrador no define `debounce`, se usa 50ms

```emic
EMIC:copy(inc/button.h > TARGET:inc/button_.{name}..h,name=.{name}.,pin=.{pin}.,debounce=.{debounce}.)
```
- Copiar header al Target con sustitución de variables
- `name=.{name}.`: Todas las apariciones de `.{name}.` se reemplazan con el valor del parámetro `name`

```emic
EMIC:define(main_includes.button_.{name}.,button_.{name}.)
```
- Registrar el módulo para que se incluya en main.c

```emic
EMIC:define(c_modules.button_.{name}.,button_.{name}.)
```
- Registrar el archivo .c para que se agregue al Makefile

---

## Paso 4: Crear button.h

**Archivo:** `_api/Inputs/Button/inc/button.h`

```c
#ifndef BUTTON_.{name}._H
#define BUTTON_.{name}._H

#include <xc.h>
#include <stdint.h>
#include <stdbool.h>

// Definir constantes de configuración
#define BUTTON_.{name}._DEBOUNCE_MS  .{debounce}.

// Estados del botón
typedef enum {
    BUTTON_.{name}._STATE_RELEASED,
    BUTTON_.{name}._STATE_PRESSED,
    BUTTON_.{name}._STATE_DEBOUNCING
} Button_.{name}._State_t;

// ============================================================
// Función de inicialización (siempre incluida)
// ============================================================
void button_.{name}._Init(void);
EMIC:define(inits.button_.{name}.,button_.{name}._Init)

// ============================================================
// Funciones condicionales (solo si son usadas)
// ============================================================

EMIC:ifdef usedFunction.button_.{name}._IsPressed
bool button_.{name}._IsPressed(void);
EMIC:endif

EMIC:ifdef usedFunction.button_.{name}._WasPressed
bool button_.{name}._WasPressed(void);
void button_.{name}._Poll(void);
EMIC:define(polls.button_.{name}.,button_.{name}._Poll)
EMIC:endif

#endif // BUTTON_.{name}._H
```

### Explicación de Include Guards

```c
#ifndef BUTTON_.{name}._H
#define BUTTON_.{name}._H
...
#endif
```
- Protege contra inclusión múltiple
- Usa `.{name}.` para hacer el guard único por instancia

### Explicación de Condicionales EMIC

```c
EMIC:ifdef usedFunction.button_.{name}._IsPressed
bool button_.{name}._IsPressed(void);
EMIC:endif
```
- Solo incluye la función si el integrador la usa
- Optimiza tamaño del código compilado
- `usedFunction` es generado por EMIC-Editor

### Registro de Inicialización

```c
EMIC:define(inits.button_.{name}.,button_.{name}._Init)
```
- Registra la función de inicialización
- main.c llamará automáticamente a todas las funciones registradas en `inits`

### Registro de Poll

```c
EMIC:define(polls.button_.{name}.,button_.{name}._Poll)
```
- Registra la función de polling
- main.c llamará automáticamente en el loop principal

---

## Paso 5: Implementar button.c

**Archivo:** `_api/Inputs/Button/src/button.c`

```c
#include "inc/button_.{name}..h"
#include "inc/gpio.h"
#include "inc/systemTimer.h"

// ============================================================
// Variables estáticas (privadas de este módulo)
// ============================================================
static Button_.{name}._State_t button_state = BUTTON_.{name}._STATE_RELEASED;
static uint32_t last_change_time = 0;
static bool was_pressed_flag = false;
static bool current_reading = false;
static bool last_stable_reading = false;

// ============================================================
// Función de inicialización (siempre incluida)
// ============================================================
void button_.{name}._Init(void) {
    // Configurar pin como entrada
    HAL_GPIO_PinCfg(.{pin}., GPIO_INPUT);

    // Configurar pull-up si es necesario
    EMIC:ifdef pull_mode.internal
        HAL_GPIO_PinPullUp(.{pin}., GPIO_PULLUP_ENABLE);
    EMIC:endif

    // Inicializar estado
    button_state = BUTTON_.{name}._STATE_RELEASED;
    was_pressed_flag = false;
    last_change_time = getSystemMilis();

    // Leer estado inicial
    current_reading = HAL_GPIO_PinGet(.{pin}.);
    last_stable_reading = current_reading;
}

// ============================================================
// Función IsPressed (solo si es usada)
// ============================================================
EMIC:ifdef usedFunction.button_.{name}._IsPressed
bool button_.{name}._IsPressed(void) {
    // Lógica invertida porque pull-up
    // LOW = presionado, HIGH = liberado
    bool pin_state = HAL_GPIO_PinGet(.{pin}.);
    return (pin_state == GPIO_LOW);
}
EMIC:endif

// ============================================================
// Función WasPressed (solo si es usada)
// ============================================================
EMIC:ifdef usedFunction.button_.{name}._WasPressed
bool button_.{name}._WasPressed(void) {
    if (was_pressed_flag) {
        was_pressed_flag = false;  // Clear flag
        return true;
    }
    return false;
}
EMIC:endif

// ============================================================
// Función Poll (solo si WasPressed es usada)
// ============================================================
EMIC:ifdef usedFunction.button_.{name}._WasPressed
void button_.{name}._Poll(void) {
    // Leer estado actual del pin
    current_reading = HAL_GPIO_PinGet(.{pin}.);
    uint32_t current_time = getSystemMilis();

    switch (button_state) {
        case BUTTON_.{name}._STATE_RELEASED:
            // Esperando a que se presione
            if (current_reading == GPIO_LOW) {  // Pull-up: LOW = presionado
                // Cambio detectado, iniciar debounce
                button_state = BUTTON_.{name}._STATE_DEBOUNCING;
                last_change_time = current_time;
            }
            break;

        case BUTTON_.{name}._STATE_DEBOUNCING:
            // Verificando estabilidad de la señal
            if (current_reading == last_stable_reading) {
                // Volvió al estado anterior, cancelar
                button_state = (last_stable_reading == GPIO_LOW) ?
                               BUTTON_.{name}._STATE_PRESSED :
                               BUTTON_.{name}._STATE_RELEASED;
            } else {
                // Verificar si pasó el tiempo de debounce
                if (current_time - last_change_time >= BUTTON_.{name}._DEBOUNCE_MS) {
                    // Cambio confirmado
                    last_stable_reading = current_reading;

                    if (current_reading == GPIO_LOW) {
                        // Presionado confirmado
                        button_state = BUTTON_.{name}._STATE_PRESSED;
                        was_pressed_flag = true;  // Setear flag
                    } else {
                        // Liberado confirmado
                        button_state = BUTTON_.{name}._STATE_RELEASED;
                    }
                }
            }
            break;

        case BUTTON_.{name}._STATE_PRESSED:
            // Esperando a que se libere
            if (current_reading == GPIO_HIGH) {  // Pull-up: HIGH = liberado
                // Cambio detectado, iniciar debounce
                button_state = BUTTON_.{name}._STATE_DEBOUNCING;
                last_change_time = current_time;
            }
            break;
    }
}
EMIC:endif
```

### Explicación del Algoritmo de Debounce

**Problema:** Los botones mecánicos producen múltiples transiciones rápidas (rebotes) al presionar/liberar.

**Solución:** Esperar un tiempo fijo (debounce_ms) después de detectar un cambio. Si el estado se mantiene estable durante ese tiempo, confirmar el cambio.

**Estados:**
1. **RELEASED**: Botón liberado, esperando presión
2. **DEBOUNCING**: Cambio detectado, verificando estabilidad
3. **PRESSED**: Botón presionado, esperando liberación

**Flujo:**
```
RELEASED → (detecta LOW) → DEBOUNCING
                              ↓
                    (espera debounce_ms)
                              ↓
                    (confirma cambio) → PRESSED → setear flag
                              ↓
PRESSED → (detecta HIGH) → DEBOUNCING
                              ↓
                    (espera debounce_ms)
                              ↓
                    (confirma cambio) → RELEASED
```

---

## Paso 6: Testing y Validación

### Crear Proyecto de Testing

**generate.emic del proyecto de prueba:**

```emic
EMIC:setOutput(TARGET:generate.txt)

    // Hardware Config
    EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_Development_Board)

    // APIs
    EMIC:setInput(DEV:_api/Inputs/Button/button.emic,name=start_btn,pin=B0_Pin,debounce=50)
    EMIC:setInput(DEV:_api/Inputs/Button/button.emic,name=stop_btn,pin=B1_Pin,debounce=100)
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led1,pin=A0_Pin)
    EMIC:setInput(DEV:_api/Wired_Communication/UART/uart.emic,name=uart1,port=1,baud=9600)

    // Main
    EMIC:setInput(DEV:_main/baremetal/main.emic)

    // Copy user files
    EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
    EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)

    EMIC:define(c_modules.userFncFile,userFncFile)

    // Copy project template
    EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

### Código de Testing (userFncFile.c)

```c
#include "inc/userFncFile.h"

/**
 * @fn void EMIC_INIT_USER(void)
 * @brief Testing de API Button
 * @@EMIC_TAG::{FUNCTION,Event:INIT,Type:void}
 */
void EMIC_INIT_USER(void) {
    uart1_WriteString("=== Testing Button API ===\r\n");
    uart1_WriteString("start_btn: B0 (debounce 50ms)\r\n");
    uart1_WriteString("stop_btn:  B1 (debounce 100ms)\r\n");
    uart1_WriteString("LED: Toggles on start_btn press\r\n\r\n");

    led1_Off();
}

/**
 * @fn void EMIC_LOOP_USER(void)
 * @brief Loop de testing
 * @@EMIC_TAG::{FUNCTION,Event:LOOP,Type:void}
 */
void EMIC_LOOP_USER(void) {
    // Testing IsPressed (estado actual)
    if (start_btn_IsPressed()) {
        uart1_WriteString("[start_btn] is pressed\r\n");
        __delay_ms(500);  // Evitar spam
    }

    // Testing WasPressed (edge detection)
    if (start_btn_WasPressed()) {
        uart1_WriteString("[start_btn] WAS pressed! Toggling LED\r\n");
        led1_Toggle();
    }

    if (stop_btn_WasPressed()) {
        uart1_WriteString("[stop_btn] WAS pressed!\r\n");
        led1_Off();
    }
}
```

### Verificaciones de Testing

| Test | Procedimiento | Resultado Esperado |
|------|---------------|-------------------|
| **Init** | Compilar y flashear | No errores de compilación |
| **IsPressed** | Mantener botón presionado | Mensajes continuos por UART |
| **WasPressed** | Presionar y soltar rápidamente | Mensaje UNA sola vez |
| **Debounce** | Presionar rápidamente múltiples veces | Solo detecta presiones estables |
| **Multiple instances** | Usar start_btn y stop_btn | Ambos funcionan independientemente |
| **LED control** | Presionar start_btn | LED hace toggle |

---

## Paso 7: Documentar con DOXYGEN

### Documentación Completa en button.emic

```emic
/**
* @file button.emic
* @brief API for button input with debounce support
* @author Tu Nombre
* @date 2025-11-05
* @version 1.0.0
*
* @details
* This API provides button input functionality with configurable debounce.
* Supports multiple button instances with independent configurations.
*
* Features:
* - Software debounce (configurable time)
* - Edge detection (WasPressed)
* - Level detection (IsPressed)
* - Internal or external pull-up support
* - Multiple instances support
*
* Dependencies:
* - HAL/GPIO (pin configuration and reading)
* - SystemTimer (debounce timing)
*
* Example usage:
* @code
* // In generate.emic:
* EMIC:setInput(DEV:_api/Inputs/Button/button.emic,name=my_button,pin=B0_Pin,debounce=50)
*
* // In userFncFile.c:
* if (my_button_WasPressed()) {
*     // Do something on button press
* }
* @endcode
*
* @param name Button instance name (e.g., "start", "stop", "menu")
* @param pin GPIO pin connected to button (e.g., "B0_Pin", "A3_Pin")
* @param debounce Debounce time in milliseconds (default: 50)
* @param pull_mode "internal" or "external" (default: "internal")
*/

/**
* @fn void button_.{name}._Init(void);
* @alias .{name}..Init
* @brief Initialize button hardware
*
* @details
* Configures the GPIO pin as input and enables pull-up if configured.
* This function is called automatically during system initialization.
*
* @return Nothing
*
* @note This function is always included in compilation
*/

/**
* @fn bool button_.{name}._IsPressed(void);
* @alias .{name}..IsPressed
* @brief Check if button is currently pressed
*
* @details
* Returns the current state of the button without debouncing.
* Use this function for real-time status checking.
*
* @return true if button is pressed, false if released
*
* @warning This function does not perform debouncing.
*          For reliable press detection, use WasPressed() instead.
*
* @see button_.{name}._WasPressed
*/

/**
* @fn bool button_.{name}._WasPressed(void);
* @alias .{name}..WasPressed
* @brief Check if button was pressed since last call
*
* @details
* This function implements edge detection with debouncing.
* Returns true only ONCE per button press, even if called multiple times
* while the button is still held down.
*
* IMPORTANT: You must call button_.{name}._Poll() in your main loop
* for this function to work correctly.
*
* @return true if button was pressed since last call, false otherwise
*
* @note This function clears the internal flag when returning true
* @see button_.{name}._Poll
*
* @code
* // Example usage:
* void EMIC_LOOP_USER(void) {
*     if (start_button_WasPressed()) {
*         // This code executes ONCE per press
*         StartSystem();
*     }
* }
* @endcode
*/

/**
* @fn void button_.{name}._Poll(void);
* @alias .{name}..Poll
* @brief Update button state (debounce processing)
*
* @details
* This function must be called periodically (in main loop) to update
* the internal button state machine. It performs debounce filtering
* and sets the "was pressed" flag when a stable press is detected.
*
* @return Nothing
*
* @note This function is called automatically by main.c if WasPressed is used
* @see button_.{name}._WasPressed
*/
```

### Beneficios de Documentar

1. **EMIC-Discovery** extrae la documentación y la muestra en EMIC-Editor
2. **Integradores** entienden cómo usar la API sin leer el código
3. **Maintenance** facilita futuras modificaciones
4. **Collaboration** permite que otros desarrolladores contribuyan

---

## Ejemplo Avanzado: API PWM

Vamos a crear una API más compleja: **PWM (Pulse Width Modulation)** para control de velocidad de motores o brillo de LEDs.

### Especificaciones PWM

**Funcionalidad:**
- Configurar frecuencia PWM (Hz)
- Configurar duty cycle (0-100%)
- Iniciar/detener PWM
- Cambiar duty cycle en tiempo real
- Múltiples canales PWM independientes

**Parámetros:**
- `name`: Nombre del canal (ej: "motor1", "led_pwm")
- `pin`: Pin de salida PWM
- `timer`: Timer hardware a usar (1, 2, 3, etc.)
- `frequency`: Frecuencia en Hz (default: 1000)

**Funciones:**
- `pwm_{name}_Init()`
- `pwm_{name}_Start()`
- `pwm_{name}_Stop()`
- `pwm_{name}_SetDutyCycle(uint8_t percent)`
- `pwm_{name}_SetFrequency(uint16_t hz)`

### Estructura de Archivos

```
_api/
└── Actuators/
    └── PWM/
        ├── pwm.emic
        ├── inc/
        │   └── pwm.h
        └── src/
            └── pwm.c
```

### pwm.emic

```emic
EMIC:tag(driverName = PWM)
EMIC:tag(category = Actuators)

/**
* @fn void pwm_.{name}._SetDutyCycle(uint8_t percent);
* @alias .{name}..SetDutyCycle
* @brief Set PWM duty cycle (0-100%)
* @param percent Duty cycle percentage (0 = always OFF, 100 = always ON)
* @return Nothing
*/

/**
* @fn void pwm_.{name}._Start(void);
* @alias .{name}..Start
* @brief Start PWM output
* @return Nothing
*/

/**
* @fn void pwm_.{name}._Stop(void);
* @alias .{name}..Stop
* @brief Stop PWM output (pin goes LOW)
* @return Nothing
*/

// Dependencias
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_hal/Timer/timer.emic)

// Valores por defecto
EMIC:ifndef frequency
    EMIC:define(frequency, 1000)
EMIC:endif

EMIC:copy(inc/pwm.h > TARGET:inc/pwm_.{name}..h,name=.{name}.,pin=.{pin}.,timer=.{timer}.,frequency=.{frequency}.)
EMIC:copy(src/pwm.c > TARGET:pwm_.{name}..c,name=.{name}.,pin=.{pin}.,timer=.{timer}.,frequency=.{frequency}.)

EMIC:define(main_includes.pwm_.{name}.,pwm_.{name}.)
EMIC:define(c_modules.pwm_.{name}.,pwm_.{name}.)
```

### pwm.h (Simplificado)

```c
#ifndef PWM_.{name}._H
#define PWM_.{name}._H

#include <stdint.h>

// Constantes
#define PWM_.{name}._FREQUENCY  .{frequency}.
#define PWM_.{name}._TIMER      .{timer}.

// Funciones
void pwm_.{name}._Init(void);
EMIC:define(inits.pwm_.{name}.,pwm_.{name}._Init)

void pwm_.{name}._Start(void);
void pwm_.{name}._Stop(void);
void pwm_.{name}._SetDutyCycle(uint8_t percent);
void pwm_.{name}._SetFrequency(uint16_t hz);

#endif
```

### pwm.c (Implementación Simplificada)

```c
#include "inc/pwm_.{name}..h"
#include "inc/gpio.h"
#include "inc/timer.h"

// Variables privadas
static uint16_t current_duty = 0;      // Valor actual del duty cycle (0-PR.{timer}.)
static uint16_t period_value = 0;     // Valor del período (PR.{timer}.)
static bool is_running = false;

void pwm_.{name}._Init(void) {
    // Configurar pin como salida
    HAL_GPIO_PinCfg(.{pin}., GPIO_OUTPUT);
    HAL_GPIO_PinSet(.{pin}., GPIO_LOW);

    // Calcular período del timer para la frecuencia deseada
    // period = (FCY / (PRESCALER * FREQUENCY)) - 1
    // Asumiendo FCY = 16MHz, PRESCALER = 8
    period_value = (16000000UL / (8UL * PWM_.{name}._FREQUENCY)) - 1;

    // Configurar Timer.{timer}.
    HAL_Timer_Init(PWM_.{name}._TIMER, period_value);
    HAL_Timer_SetPrescaler(PWM_.{name}._TIMER, TIMER_PRESCALER_8);

    // Configurar Output Compare para PWM
    HAL_Timer_ConfigPWM(PWM_.{name}._TIMER, .{pin}.);

    // Iniciar con 0% duty cycle
    pwm_.{name}._SetDutyCycle(0);

    is_running = false;
}

void pwm_.{name}._Start(void) {
    if (!is_running) {
        HAL_Timer_Start(PWM_.{name}._TIMER);
        is_running = true;
    }
}

void pwm_.{name}._Stop(void) {
    if (is_running) {
        HAL_Timer_Stop(PWM_.{name}._TIMER);
        HAL_GPIO_PinSet(.{pin}., GPIO_LOW);
        is_running = false;
    }
}

void pwm_.{name}._SetDutyCycle(uint8_t percent) {
    // Validar rango
    if (percent > 100) {
        percent = 100;
    }

    // Calcular valor del duty cycle
    // duty = (percent * period) / 100
    current_duty = ((uint32_t)percent * period_value) / 100;

    // Actualizar registro del timer
    HAL_Timer_SetCompareValue(PWM_.{name}._TIMER, current_duty);
}

void pwm_.{name}._SetFrequency(uint16_t hz) {
    // Recalcular período
    period_value = (16000000UL / (8UL * hz)) - 1;
    HAL_Timer_SetPeriod(PWM_.{name}._TIMER, period_value);

    // Reajustar duty cycle para mantener el porcentaje
    // (el valor absoluto cambia con la frecuencia)
    uint8_t current_percent = (current_duty * 100) / period_value;
    pwm_.{name}._SetDutyCycle(current_percent);
}
```

### Ejemplo de Uso

```emic
// En generate.emic:
EMIC:setInput(DEV:_api/Actuators/PWM/pwm.emic,name=motor1,pin=B2_Pin,timer=2,frequency=20000)
EMIC:setInput(DEV:_api/Actuators/PWM/pwm.emic,name=led_brightness,pin=A4_Pin,timer=3,frequency=1000)
```

```c
// En userFncFile.c:
void EMIC_INIT_USER(void) {
    // Motor a 50% velocidad
    motor1_SetDutyCycle(50);
    motor1_Start();

    // LED apagado inicialmente
    led_brightness_SetDutyCycle(0);
    led_brightness_Start();
}

void EMIC_LOOP_USER(void) {
    // Fade in LED (0% → 100%)
    for (uint8_t i = 0; i <= 100; i++) {
        led_brightness_SetDutyCycle(i);
        __delay_ms(10);
    }

    // Fade out LED (100% → 0%)
    for (uint8_t i = 100; i > 0; i--) {
        led_brightness_SetDutyCycle(i);
        __delay_ms(10);
    }
}
```

---

## Patrones de Diseño de APIs

### Patrón 1: API Simple (Stateless)

**Características:**
- Sin estado interno
- Funciones independientes
- Ejemplo: Math API, String API

```c
// math_api.h
int32_t math_Add(int32_t a, int32_t b);
int32_t math_Multiply(int32_t a, int32_t b);
float math_Sqrt(float x);
```

**Ventajas:**
- Simple de implementar
- Fácil de testear
- No consume RAM

**Cuándo usar:** Operaciones puramente funcionales sin contexto.

### Patrón 2: API con Estado (Stateful)

**Características:**
- Mantiene estado interno
- Requiere Init/Poll
- Ejemplo: Button API, Timer API

```c
// button_api.h
void button_Init(void);
bool button_IsPressed(void);
bool button_WasPressed(void);
void button_Poll(void);  // Actualiza estado interno
```

**Ventajas:**
- Encapsula complejidad
- Permite edge detection, debounce, etc.

**Cuándo usar:** Cuando el comportamiento depende del historial.

### Patrón 3: API con Callbacks

**Características:**
- Registra funciones de callback
- Notificación asíncrona
- Ejemplo: UART Receive, Timer Events

```c
// uart_api.h
typedef void (*UartCallback_t)(uint8_t data);
void uart_RegisterCallback(UartCallback_t callback);
```

```c
// Uso:
void OnDataReceived(uint8_t data) {
    // Procesar dato
}

void EMIC_INIT_USER(void) {
    uart_RegisterCallback(OnDataReceived);
}
```

**Ventajas:**
- Desacopla emisor de receptor
- Respuesta inmediata a eventos

**Cuándo usar:** Eventos asíncronos (interrupciones, comunicación).

### Patrón 4: API con Configuración Dinámica

**Características:**
- Configurable en runtime
- Múltiples modos de operación
- Ejemplo: SPI API, ADC API

```c
// spi_api.h
typedef enum {
    SPI_MODE_MASTER,
    SPI_MODE_SLAVE
} SpiMode_t;

typedef enum {
    SPI_CLOCK_1MHz,
    SPI_CLOCK_4MHz,
    SPI_CLOCK_8MHz
} SpiClock_t;

void spi_Init(SpiMode_t mode, SpiClock_t clock);
void spi_SetMode(SpiMode_t mode);
void spi_SetClock(SpiClock_t clock);
```

**Ventajas:**
- Flexible
- Adaptable a diferentes escenarios

**Cuándo usar:** Hardware con múltiples configuraciones.

---

## Buenas Prácticas

### 1. Nomenclatura Consistente

```c
✅ BUENO:
void button_start_Init(void);
bool button_start_IsPressed(void);
bool button_start_WasPressed(void);

❌ MALO:
void initButton_start(void);
bool pressed_start(void);
bool was_pressed_start_btn(void);
```

**Regla:** `{api}_{instance}_{Action}()`

### 2. Usar Tipos Estándar

```c
✅ BUENO:
#include <stdint.h>
#include <stdbool.h>

bool button_IsPressed(void);        // bool para booleanos
uint8_t led_GetBrightness(void);    // uint8_t para 0-255
uint16_t timer_GetElapsed(void);    // uint16_t para valores grandes

❌ MALO:
int button_IsPressed(void);         // int para booleanos
char led_GetBrightness(void);       // char para números
int timer_GetElapsed(void);         // int sin tamaño definido
```

### 3. Documentar Parámetros Obligatorios vs Opcionales

```emic
✅ BUENO:
/**
* @param name [REQUIRED] Instance name
* @param pin [REQUIRED] GPIO pin
* @param debounce [OPTIONAL] Debounce time in ms (default: 50)
*/

EMIC:ifndef debounce
    EMIC:define(debounce, 50)
EMIC:endif
```

### 4. Validar Parámetros

```c
✅ BUENO:
void pwm_SetDutyCycle(uint8_t percent) {
    if (percent > 100) {
        percent = 100;  // Clamp al máximo
    }
    // Aplicar duty cycle
}

❌ MALO:
void pwm_SetDutyCycle(uint8_t percent) {
    // No valida, comportamiento indefinido si percent > 100
    duty = percent;
}
```

### 5. Incluir Solo lo Necesario (ifdef)

```c
✅ BUENO:
EMIC:ifdef usedFunction.button_.{name}._WasPressed
void button_.{name}._WasPressed(void) {
    // Solo compilado si se usa
}
EMIC:endif

❌ MALO:
void button_.{name}._WasPressed(void) {
    // Siempre compilado, desperdicia flash
}
```

### 6. Registrar Init/Poll Correctamente

```c
✅ BUENO:
void button_Init(void);
EMIC:define(inits.button,button_Init)

void button_Poll(void);
EMIC:define(polls.button,button_Poll)

❌ MALO:
void button_Init(void);  // No registrado, no se llama automáticamente
```

---

## Errores Comunes

### Error 1: Olvidar Parametrizar Variables

```c
❌ MALO:
void button_Init(void) {
    HAL_GPIO_PinCfg(B0_Pin, GPIO_INPUT);  // Hardcodeado!
}

✅ BUENO:
void button_.{name}._Init(void) {
    HAL_GPIO_PinCfg(.{pin}., GPIO_INPUT);  // Parametrizado
}
```

### Error 2: Conflictos de Nombres Globales

```c
❌ MALO:
static int state;  // Conflicto si hay múltiples instancias

✅ BUENO:
static int button_.{name}._state;  // Único por instancia
```

### Error 3: No Declarar Dependencias

```emic
❌ MALO:
EMIC:copy(src/button.c > TARGET:button_.{name}..c)
// Falta: EMIC:setInput(DEV:_hal/GPIO/gpio.emic)

✅ BUENO:
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:copy(src/button.c > TARGET:button_.{name}..c)
```

### Error 4: Include Guards Incorrectos

```c
❌ MALO:
#ifndef BUTTON_H  // Mismo nombre para todas las instancias
#define BUTTON_H

✅ BUENO:
#ifndef BUTTON_.{name}._H  // Único por instancia
#define BUTTON_.{name}._H
```

### Error 5: No Documentar con DOXYGEN

```c
❌ MALO:
// Devuelve true si está presionado
bool button_IsPressed(void);

✅ BUENO:
/**
* @fn bool button_.{name}._IsPressed(void);
* @alias .{name}..IsPressed
* @brief Check if button is currently pressed
* @return true if pressed, false otherwise
*/
```

---

## Resumen del Capítulo

### Lo que Aprendiste

1. **¿Qué es una API EMIC?**
   - Componente reutilizable y parametrizable
   - Encapsula funcionalidad de hardware/software
   - Expone interfaz simple para integradores

2. **Anatomía de una API**
   - archivo.emic (script con tags y dependencias)
   - inc/archivo.h (prototipos y condicionales)
   - src/archivo.c (implementación con variables .{name}.)

3. **Proceso completo de creación**
   - Planificar (especificaciones, parámetros, funciones)
   - Crear estructura de carpetas
   - Escribir .emic con tags DOXYGEN
   - Implementar .h con include guards
   - Implementar .c con lógica parametrizada
   - Testing y validación
   - Documentar completamente

4. **Patrones de diseño**
   - Stateless (sin estado)
   - Stateful (con estado)
   - Con callbacks (eventos)
   - Con configuración dinámica

5. **APIs creadas**
   - Button (completa, con debounce)
   - PWM (avanzada, multi-canal)

### Diferencia API vs Driver vs HAL

```
API (Alto nivel)        → Funcionalidad completa para integrador
    ↓ usa
Driver (Medio)          → Control de chip/sensor específico
    ↓ usa
HAL (Bajo)              → Acceso a periférico MCU
    ↓ usa
_hard (Hardware)        → Registros del microcontrolador
```

### Archivos Clave

| Archivo | Propósito |
|---------|-----------|
| api.emic | Script EMIC con tags, dependencias y directivas de copia |
| inc/api.h | Prototipos, condicionales EMIC, registro de init/poll |
| src/api.c | Implementación con variables parametrizadas |

### Checklist de Calidad de API

- ✅ Documentación DOXYGEN completa
- ✅ Todos los parámetros parametrizados (.{name}., .{pin}., etc.)
- ✅ Include guards únicos por instancia
- ✅ Dependencias declaradas explícitamente
- ✅ Condicionales EMIC para código opcional
- ✅ Init/Poll registrados correctamente
- ✅ Validación de parámetros
- ✅ Testing con múltiples instancias
- ✅ Variables globales únicas por instancia
- ✅ Tipos estándar (stdint.h, stdbool.h)

### Próximos Pasos

En los siguientes capítulos aprenderás:
- **Cap 23**: Trabajar con Módulos (proyectos multi-módulo)
- **Cap 24**: Debugging y Testing (técnicas avanzadas)
- **Cap 25**: Integración de Componentes (APIs complejas)
- **Cap 26**: Deployment y Producción (publicar en el SDK)

---

**¡Felicitaciones!** Ahora sabes crear APIs reutilizables de calidad profesional. Las APIs que crees pueden ser compartidas con la comunidad EMIC y usadas en miles de proyectos.

**Recuerda**: Una buena API es **simple de usar, difícil de mal usar, y bien documentada**.

---

**Sección 4 - Capítulo 22**
Manual de Desarrollo EMIC SDK
Versión 1.0.0

---
