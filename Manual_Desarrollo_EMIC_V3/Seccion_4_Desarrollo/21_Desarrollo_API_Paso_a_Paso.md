# Capítulo 21: Desarrollo de una API EMIC - Paso a Paso

## Tabla de Contenidos

### PARTE 1: DESARROLLO DE LA API
1. [Planificación de la API](#1-planificación-de-la-api)
2. [Paso 1: Estructura de Carpetas](#2-paso-1-estructura-de-carpetas)
3. [Paso 2: Código C - Header (.h)](#3-paso-2-código-c---header-h)
4. [Paso 3: Código C - Implementación (.c)](#4-paso-3-código-c---implementación-c)
5. [Paso 4: Etiquetado con Tags DOXYGEN](#5-paso-4-etiquetado-con-tags-doxygen)
6. [Paso 5: Crear Archivo .emic](#6-paso-5-crear-archivo-emic)

### PARTE 2: VALIDACIÓN MEDIANTE INTEGRACIÓN
7. [Paso 6: Crear Proyecto de Prueba](#7-paso-6-crear-proyecto-de-prueba)
8. [Paso 7: Generar Código y Compilar](#8-paso-7-generar-código-y-compilar)
9. [Paso 8: Testing en Hardware](#9-paso-8-testing-en-hardware)

### EJEMPLO COMPLETO
10. [API de LEDs - Código Completo](#10-api-de-leds---código-completo)

---

## PARTE 1: DESARROLLO DE LA API

---

## 1. Planificación de la API

Antes de escribir código, es fundamental planificar la API.

### 1.1 Preguntas Clave

| Pregunta | Respuesta para API de LEDs |
|----------|---------------------------|
| ¿Qué funcionalidad ofrece? | Control de LEDs (encender, apagar, parpadear) |
| ¿Qué recursos de hardware necesita? | GPIO (salida digital) |
| ¿Qué dependencias tiene? | HAL GPIO, System Timer |
| ¿Es parametrizable? | Sí: nombre del LED, pin asignado |
| ¿Puede haber múltiples instancias? | Sí: LED_status, LED_error, etc. |

### 1.2 Definir la Interfaz Pública

```
API: LEDs
─────────

FUNCIONES:
├── state(uint8_t state)     → Cambiar estado (on/off/toggle)
└── blink(timeOn, period, times) → Parpadear

PARÁMETROS DE INSTANCIA:
├── name  → Nombre único del LED (status, error, power)
└── pin   → Pin GPIO asignado (RB0, RC1, etc.)

DEPENDENCIAS:
├── _hal/GPIO/gpio.emic      → Control de pines
└── _drivers/SystemTimer     → Temporización para blink
```

### 1.3 Diagrama de Flujo

```
┌─────────────────────────────────────────────────────────────────┐
│                 FLUJO DE DESARROLLO DE API                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. PLANIFICAR          2. CREAR ESTRUCTURA                      │
│  ─────────────          ───────────────────                      │
│  • Funcionalidad        _api/Indicators/LEDs/                    │
│  • Interfaz             ├── led.emic                             │
│  • Dependencias         ├── inc/led.h                            │
│                         └── src/led.c                            │
│                                                                  │
│  3. CÓDIGO C            4. TAGS DOXYGEN                          │
│  ──────────             ──────────────                           │
│  • Header (.h)          • @fn para funciones                     │
│  • Source (.c)          • @alias para EMIC-Editor                │
│  • Usar HAL             • @brief, @param, @return                │
│                                                                  │
│  5. ARCHIVO .emic       6. VALIDAR                               │
│  ────────────────       ─────────                                │
│  • driverName           • Crear módulo de prueba                 │
│  • Dependencias         • EMIC Generate                          │
│  • copy archivos        • Compilar y probar                      │
│  • Registrar módulos                                             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Paso 1: Estructura de Carpetas

### 2.1 Ubicación en el SDK

```
EMIC_SDK/
└── _api/
    └── {Categoría}/
        └── {NombreAPI}/
            ├── {nombreAPI}.emic    ← Archivo principal
            ├── inc/
            │   └── {nombreAPI}.h   ← Header
            └── src/
                └── {nombreAPI}.c   ← Implementación
```

### 2.2 Ejemplo: API de LEDs

```
EMIC_SDK/
└── _api/
    └── Indicators/           ← Categoría
        └── LEDs/             ← Nombre de la API
            ├── led.emic      ← Archivo EMIC-Codify
            ├── inc/
            │   └── led.h     ← Declaraciones
            └── src/
                └── led.c     ← Implementación
```

### 2.3 Convenciones de Nombres

| Elemento | Convención | Ejemplo |
|----------|------------|---------|
| Categoría | PascalCase o snake_case | `Indicators`, `Wired_Communication` |
| Carpeta API | PascalCase | `LEDs`, `Temperature` |
| Archivo .emic | minúsculas | `led.emic`, `temperature.emic` |
| Archivo .h/.c | minúsculas | `led.h`, `led.c` |
| Funciones C | PascalCase_nombre | `LEDs_status_state()` |

### 2.4 Crear la Estructura

```bash
# En el SDK, crear carpetas
mkdir -p _api/Indicators/LEDs/inc
mkdir -p _api/Indicators/LEDs/src

# Crear archivos vacíos
touch _api/Indicators/LEDs/led.emic
touch _api/Indicators/LEDs/inc/led.h
touch _api/Indicators/LEDs/src/led.c
```

---

## 3. Paso 2: Código C - Header (.h)

El header declara las funciones públicas de la API.

### 3.1 Estructura del Header

```c
// led.h
#include <xc.h>

// Función de inicialización (llamada automáticamente)
void LEDs_.{name}._init(void);
EMIC:define(inits.LEDs_.{name}., LEDs_.{name}._init)

// Función de polling (si es necesaria)
EMIC:ifdef usedFunction.LEDs_.{name}._blink
void LEDs_.{name}._poll(void);
EMIC:define(polls.LEDs_.{name}., LEDs_.{name}._poll)
EMIC:endif

// Declaraciones de funciones públicas (condicionales)
EMIC:ifdef usedFunction.LEDs_.{name}._state
void LEDs_.{name}._state(uint8_t state);
EMIC:endif

EMIC:ifdef usedFunction.LEDs_.{name}._blink
void LEDs_.{name}._blink(uint16_t timeOn, uint16_t period, uint16_t times);
EMIC:endif
```

### 3.2 Elementos Clave del Header

#### Macros de Sustitución
```c
LEDs_.{name}._state  →  LEDs_status_state (cuando name=status)
```

#### Registro de Inicialización
```c
EMIC:define(inits.LEDs_.{name}., LEDs_.{name}._init)
```
Esto registra la función `init` para que sea llamada automáticamente al inicio.

#### Registro de Polling
```c
EMIC:define(polls.LEDs_.{name}., LEDs_.{name}._poll)
```
Registra la función `poll` para ser llamada en el loop principal.

#### Compilación Condicional
```c
EMIC:ifdef usedFunction.LEDs_.{name}._blink
// Solo se incluye si el usuario usa esta función
EMIC:endif
```

### 3.3 Grupos de Registro del Sistema

| Grupo | Propósito | Cuándo se llama |
|-------|-----------|-----------------|
| `inits.*` | Funciones de inicialización | Una vez al inicio |
| `polls.*` | Funciones de polling | En cada iteración del loop |
| `main_includes.*` | Headers a incluir | En main.c |
| `c_modules.*` | Archivos .c a compilar | En el proyecto |

---

## 4. Paso 3: Código C - Implementación (.c)

### 4.1 Estructura del Source

```c
// led.c
#include <xc.h>
#include "inc/led_.{name}..h"
#include "inc/gpio.h"
#include "inc/systemTimer.h"

// Inicialización
void LEDs_.{name}._init(void)
{
    HAL_GPIO_PinCfg(.{pin}., GPIO_OUTPUT);
}

// Función state (condicional)
EMIC:ifdef usedFunction.LEDs_.{name}._state
void LEDs_.{name}._state(uint8_t status)
{
    switch (status)
    {
        case 0:  // OFF
            HAL_GPIO_PinSet(.{pin}., GPIO_LOW);
            break;
        case 1:  // ON
            HAL_GPIO_PinSet(.{pin}., GPIO_HIGH);
            break;
        case 2:  // TOGGLE
            if (HAL_GPIO_PinGet(.{pin}.))
                HAL_GPIO_PinSet(.{pin}., GPIO_LOW);
            else
                HAL_GPIO_PinSet(.{pin}., GPIO_HIGH);
            break;
    }
}
EMIC:endif

// Función blink (condicional)
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

void LEDs_.{name}._poll(void)
{
    if (blkLed_period > 0)
    {
        if (getSystemMilis() - blkLed_tStamp > blkLed_period)
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
        else if (getSystemMilis() - blkLed_tStamp > blkLed_timerOn)
        {
            HAL_GPIO_PinSet(.{pin}., GPIO_LOW);
        }
    }
}
EMIC:endif
```

### 4.2 Buenas Prácticas de Código Embebido

#### Usar el HAL (No acceder directamente a registros)
```c
// ✅ CORRECTO - Usar HAL
HAL_GPIO_PinSet(.{pin}., GPIO_HIGH);

// ❌ INCORRECTO - Acceso directo a registros
LATB |= (1 << 0);  // No portable
```

#### Variables Estáticas para Estado Interno
```c
// Estado interno de la API (no expuesto)
static uint16_t blkLed_period = 0;
static uint32_t blkLed_tStamp;
```

#### Compilación Condicional para Optimizar Tamaño
```c
// Solo incluir código si la función se usa
EMIC:ifdef usedFunction.LEDs_.{name}._blink
// Código de blink
EMIC:endif
```

---

## 5. Paso 4: Etiquetado con Tags DOXYGEN

Los tags publican las funciones en EMIC-Editor.

### 5.1 Tag para Función state

```c
/**
* @fn void LEDs_.{name}._state(uint8_t state);
* @alias .{name}..state
* @brief Change the state of the LED, 1-on, 0-off, 2-toggle.
* @param state 1-on, 0-off, 2-toggle
* @return Nothing
*/
```

**Resultado con `name=status`:**
- Función C: `LEDs_status_state(uint8_t state)`
- Alias en Editor: `status.state`
- Aparece bajo grupo: `LEDs`

### 5.2 Tag para Función blink

```c
/**
* @fn void LEDs_.{name}._blink(uint16_t timeOn, uint16_t period, uint16_t times);
* @alias .{name}..blink
* @brief Blink the LED .{name}.
* @param timeOn Time that the LED stays on in each cycle (ms).
* @param period Length of time each cycle lasts (ms).
* @param times Number of cycles (0 = infinite).
* @return Nothing
*/
```

### 5.3 Estructura del Alias

```
.{name}..state
  │      │
  │      └── Nombre de la función
  └── Parámetro name (se sustituye)

Resultado: status.state, error.state, power.state
```

---

## 6. Paso 5: Crear Archivo .emic

El archivo `.emic` es el corazón de la API.

### 6.1 Estructura Completa

```c
// led.emic

// 1. IDENTIFICACIÓN
EMIC:tag(driverName = LEDs)

// 2. TAGS DE PUBLICACIÓN
/**
* @fn void LEDs_.{name}._state(uint8_t state);
* @alias .{name}..state
* @brief Change the state of the LED, 1-on, 0-off, 2-toggle.
* @param state 1-on, 0-off, 2-toggle
* @return Nothing
*/

/**
* @fn void LEDs_.{name}._blink(uint16_t timeOn, uint16_t period, uint16_t times);
* @alias .{name}..blink
* @brief Blink the LED .{name}.
* @param timeOn Time on in each cycle (ms).
* @param period Cycle length (ms).
* @param times Number of cycles.
* @return Nothing
*/

// 3. DEPENDENCIAS
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

// 4. COPIAR ARCHIVOS AL PROYECTO
EMIC:copy(inc/led.h > TARGET:inc/led_.{name}..h, name=.{name}., pin=.{pin}.)
EMIC:copy(src/led.c > TARGET:led_.{name}..c, name=.{name}., pin=.{pin}.)

// 5. REGISTRAR PARA COMPILACIÓN
EMIC:define(main_includes.led_.{name}., led_.{name}.)
EMIC:define(c_modules.led_.{name}., led_.{name}.)
```

### 6.2 Secciones Explicadas

#### 1. Identificación
```c
EMIC:tag(driverName = LEDs)
```
Agrupa todos los recursos bajo "LEDs" en el Editor.

#### 2. Tags de Publicación
Los comentarios DOXYGEN que definen qué funciones estarán disponibles.

#### 3. Dependencias
```c
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)
```
Carga las APIs/drivers que esta API necesita.

#### 4. Copiar Archivos
```c
EMIC:copy(inc/led.h > TARGET:inc/led_.{name}..h, name=.{name}., pin=.{pin}.)
```
- Origen: `inc/led.h` (relativo al .emic)
- Destino: `TARGET:inc/led_status.h` (en el proyecto)
- Parámetros: Se sustituyen `.{name}.` y `.{pin}.`

#### 5. Registrar para Compilación
```c
EMIC:define(main_includes.led_.{name}., led_.{name}.)
EMIC:define(c_modules.led_.{name}., led_.{name}.)
```
Agrega el archivo al proyecto MPLAB.

---

## PARTE 2: VALIDACIÓN MEDIANTE INTEGRACIÓN

---

## 7. Paso 6: Crear Proyecto de Prueba

### 7.1 Usar la API desde generate.emic

En un módulo de prueba, agregar la API:

```c
// generate.emic del módulo de prueba
EMIC:setOutput(TARGET:generate.txt)

// Hardware
EMIC:setInput(DEV:_pcb/pcb.emic, pcb=HRD_USB V1.1)

// Procesar funciones y eventos del usuario
EMIC:setInput(SYS:usedFunction.emic)
EMIC:setInput(SYS:usedEvent.emic)

// INSTANCIAR LA API DE LEDs
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=status, pin=Led1)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=error, pin=Led2)

// Timer para pruebas
EMIC:setInput(DEV:_api/Timers/timer_api.emic, name=1)

// Main
EMIC:setInput(DEV:_main/baremetal/main.emic)

// Archivos del usuario
EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
EMIC:define(c_modules.userFncFile, userFncFile)

// Template del proyecto
EMIC:copy(DEV:_templates\projects\mplabx > TARGET:)

EMIC:restoreOutput
```

### 7.2 Resultado de la Instanciación

```
Con: EMIC:setInput(...led.emic, name=status, pin=Led1)

Se generan:
├── inc/led_status.h    ← Header con funciones para LED "status"
└── led_status.c        ← Implementación configurada para pin Led1

Funciones disponibles:
├── LEDs_status_init()   ← Llamada automáticamente
├── LEDs_status_state()  ← Control on/off/toggle
└── LEDs_status_blink()  ← Parpadeo
```

### 7.3 Verificar en EMIC-Editor

1. Abrir EMIC-Editor
2. Ejecutar Discovery en el SDK
3. Verificar que aparece el grupo "LEDs"
4. Verificar funciones: `status.state`, `status.blink`

---

## 8. Paso 7: Generar Código y Compilar

### 8.1 Proceso de Generación

```
EMIC-Editor                EMIC Generate              MPLAB X
───────────                ─────────────              ───────

Proyecto visual    →→→    Procesa .emic      →→→    Proyecto C
con bloques               genera archivos           compilable
                          .c y .h
```

### 8.2 Verificar Archivos Generados

Después de EMIC Generate, verificar en `Target/`:

```
Target/
├── inc/
│   ├── led_status.h      ← Generado
│   ├── led_error.h       ← Generado
│   ├── gpio.h            ← De dependencia
│   └── systemTimer.h     ← De dependencia
├── led_status.c          ← Generado
├── led_error.c           ← Generado
├── main.c                ← Principal
└── proyecto.X/           ← Proyecto MPLAB
```

### 8.3 Compilar en MPLAB X

1. Abrir el proyecto en `Target/proyecto.X/`
2. Compilar (Build)
3. Verificar que no hay errores
4. Si hay errores, revisar:
   - Dependencias faltantes
   - Sintaxis de tags
   - Parámetros no sustituidos

### 8.4 Errores Comunes de Compilación

| Error | Causa | Solución |
|-------|-------|----------|
| `undefined reference to HAL_GPIO_*` | Falta dependencia | Agregar `setInput` de gpio.emic |
| `led_.{name}..h not found` | Parámetro no sustituido | Verificar `copy` con parámetros |
| `multiple definition` | Protección faltante | Agregar guards en .h |

---

## 9. Paso 8: Testing en Hardware

### 9.1 Programar el Microcontrolador

1. Conectar el programador (PICkit, ICD, etc.)
2. En MPLAB X: Make and Program Device
3. Verificar que el firmware se carga correctamente

### 9.2 Plan de Pruebas para API de LEDs

| Test | Acción | Resultado Esperado |
|------|--------|-------------------|
| T1 | Llamar `status.state(1)` | LED status enciende |
| T2 | Llamar `status.state(0)` | LED status apaga |
| T3 | Llamar `status.state(2)` | LED status cambia de estado |
| T4 | Llamar `status.blink(100, 500, 5)` | LED parpadea 5 veces |
| T5 | Llamar `error.state(1)` | LED error enciende (independiente) |

### 9.3 Debugging

Si algo no funciona:

1. **Verificar pin asignado**: ¿El pin físico coincide con la configuración?
2. **Verificar polaridad**: ¿LED activo en alto o bajo?
3. **Usar debugger**: Poner breakpoints en las funciones
4. **Agregar logs**: Enviar estado por UART para verificar

---

## 10. API de LEDs - Código Completo

### 10.1 Archivo led.emic

```c
EMIC:tag(driverName = LEDs)

/**
* @fn void LEDs_.{name}._state(uint8_t state);
* @alias .{name}..state
* @brief Change the state of the LED, 1-on, 0-off, 2-toggle.
* @param state 1-on, 0-off, 2-toggle
* @return Nothing
*/

/**
* @fn void LEDs_.{name}._blink(uint16_t timeOn, uint16_t period, uint16_t times);
* @alias .{name}..blink
* @brief Blink the LED .{name}.
* @param timeOn Time that the LED stays on in each cycle (ms).
* @param period Length of time each cycle lasts (ms).
* @param times Number of cycles (0 = infinite).
* @return Nothing
*/

EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

EMIC:copy(inc/led.h > TARGET:inc/led_.{name}..h, name=.{name}., pin=.{pin}.)
EMIC:copy(src/led.c > TARGET:led_.{name}..c, name=.{name}., pin=.{pin}.)

EMIC:define(main_includes.led_.{name}., led_.{name}.)
EMIC:define(c_modules.led_.{name}., led_.{name}.)
```

### 10.2 Archivo inc/led.h

```c
#include <xc.h>

void LEDs_.{name}._init(void);
EMIC:define(inits.LEDs_.{name}., LEDs_.{name}._init)

EMIC:ifdef usedFunction.LEDs_.{name}._blink
void LEDs_.{name}._poll(void);
EMIC:define(polls.LEDs_.{name}., LEDs_.{name}._poll)
EMIC:endif

EMIC:ifdef usedFunction.LEDs_.{name}._state
void LEDs_.{name}._state(uint8_t state);
EMIC:endif

EMIC:ifdef usedFunction.LEDs_.{name}._blink
void LEDs_.{name}._blink(uint16_t timeOn, uint16_t period, uint16_t times);
EMIC:endif
```

### 10.3 Archivo src/led.c

```c
#include <xc.h>
#include "inc/led_.{name}..h"
#include "inc/gpio.h"
#include "inc/systemTimer.h"

void LEDs_.{name}._init(void)
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
                HAL_GPIO_PinSet(.{pin}., GPIO_LOW);
            else
                HAL_GPIO_PinSet(.{pin}., GPIO_HIGH);
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

void LEDs_.{name}._poll(void)
{
    if (blkLed_period > 0)
    {
        if (getSystemMilis() - blkLed_tStamp > blkLed_period)
        {
            if (blkLed_times > 0)
            {
                blkLed_times--;
                if (blkLed_times == 0)
                    blkLed_period = 0;
            }
            if (blkLed_period > 0)
            {
                HAL_GPIO_PinSet(.{pin}., GPIO_HIGH);
                blkLed_tStamp = getSystemMilis();
            }
        }
        else if (getSystemMilis() - blkLed_tStamp > blkLed_timerOn)
        {
            HAL_GPIO_PinSet(.{pin}., GPIO_LOW);
        }
    }
}
EMIC:endif
```

---

## Resumen

### Checklist de Desarrollo de API

- [ ] **Planificar**: Definir funcionalidad, interfaz, dependencias
- [ ] **Estructura**: Crear carpetas `_api/Categoría/NombreAPI/`
- [ ] **Header (.h)**: Declaraciones con macros y registros
- [ ] **Source (.c)**: Implementación usando HAL
- [ ] **Tags**: Documentar con DOXYGEN en el .emic
- [ ] **Archivo .emic**: driverName, dependencias, copy, define
- [ ] **Validar**: Crear módulo de prueba
- [ ] **Compilar**: Verificar sin errores en MPLAB X
- [ ] **Probar**: Testing en hardware real

### Patrón Típico de API

```c
// miapi.emic
EMIC:tag(driverName = MiAPI)

/**
* @fn void MiAPI_.{name}._funcion(tipo param);
* @alias .{name}..funcion
* @brief Descripción
* @param param Descripción
* @return Nothing
*/

EMIC:setInput(DEV:_hal/dependencia.emic)

EMIC:copy(inc/miapi.h > TARGET:inc/miapi_.{name}..h, name=.{name}.)
EMIC:copy(src/miapi.c > TARGET:miapi_.{name}..c, name=.{name}.)

EMIC:define(main_includes.miapi_.{name}., miapi_.{name}.)
EMIC:define(c_modules.miapi_.{name}., miapi_.{name}.)
```

---

**Navegación:**
- [← Capítulo 20: Etiquetado de Recursos](../Seccion_3_EMIC_Codify/20_Etiquetado_Recursos_Tags.md)
- [→ Capítulo 22: Desarrollo de un Driver EMIC](22_Desarrollo_Driver.md)
