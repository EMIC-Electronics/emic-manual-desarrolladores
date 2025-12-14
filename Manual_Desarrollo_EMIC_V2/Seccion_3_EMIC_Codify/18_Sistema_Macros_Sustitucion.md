# Capítulo 18: Sistema de Macros y Sustitución

## Tabla de Contenidos

1. [Introducción al Sistema de Macros](#1-introducción-al-sistema-de-macros)
2. [Comando define](#2-comando-define)
3. [Sustitución de Macros .{key}.](#3-sustitución-de-macros-key)
4. [Grupos de Macros](#4-grupos-de-macros)
5. [Macros para Configuración de APIs](#5-macros-para-configuración-de-apis)
6. [Macros en Compilación de Módulos](#6-macros-en-compilación-de-módulos)
7. [Caso Práctico: API Configurable con Macros](#7-caso-práctico-api-configurable-con-macros)
8. [Errores Comunes y Soluciones](#8-errores-comunes-y-soluciones)

---

## 1. Introducción al Sistema de Macros

Las macros son el corazón de EMIC-Codify. Permiten **parametrizar** el código generado, creando componentes reutilizables que se adaptan a diferentes configuraciones sin modificar el código fuente.

### 1.1 ¿Por qué son importantes las Macros?

```
┌─────────────────────────────────────────────────────────────────┐
│              CÓDIGO ESTÁTICO vs CÓDIGO PARAMETRIZADO             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  SIN MACROS (código duplicado):                                  │
│  ─────────────────────────────                                   │
│  led_status.c  →  LED en pin RB0                                 │
│  led_error.c   →  LED en pin RB1  (código casi idéntico)         │
│  led_power.c   →  LED en pin RC0  (código casi idéntico)         │
│                                                                  │
│  CON MACROS (código parametrizado):                              │
│  ─────────────────────────────────                               │
│  led.c         →  LED en pin .{pin}.                             │
│                   + instancia con pin=RB0 → led_status.c         │
│                   + instancia con pin=RB1 → led_error.c          │
│                   + instancia con pin=RC0 → led_power.c          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Flujo de Sustitución

```
                    PROCESO DE SUSTITUCIÓN
                    ─────────────────────

Archivo fuente          Parámetros           Archivo generado
─────────────           ──────────           ────────────────

led_.{name}..c    +    name=status    →     led_status.c

void LED_.{name}._on()  →  void LED_status_on()
GPIO_Set(.{pin}.)       →  GPIO_Set(RB0)
```

---

## 2. Comando define

El comando `define` crea macros globales que estarán disponibles durante todo el procesamiento.

### 2.1 Sintaxis

```
EMIC:define(clave, valor)
EMIC:define(grupo.clave, valor)
```

### 2.2 Usos Comunes

#### Definir constantes del proyecto:
```c
EMIC:define(VERSION, 1.0)
EMIC:define(AUTOR, MiEmpresa)
EMIC:define(MCU, PIC24FJ64GA004)
```

#### Registrar módulos para compilación:
```c
// Patrón usado en todas las APIs del SDK
EMIC:define(main_includes.led_status, led_status)
EMIC:define(c_modules.led_status, led_status)
```

Este patrón es **crítico** porque registra los archivos generados en grupos especiales que luego serán usados para:
- `main_includes.*` → Generar los `#include` en `main.c`
- `c_modules.*` → Agregar archivos `.c` al proyecto MPLAB

#### Definir flags de configuración:
```c
EMIC:define(_RS232_API_EMIC, true)
EMIC:define(UART1_CALLBACK_RX, true)
```

### 2.3 Ejemplo Real: API de LEDs

Del archivo `_api/Indicators/LEDs/led.emic`:

```c
EMIC:tag(driverName = LEDs)

// Dependencias
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

// Copiar archivos con parámetros
EMIC:copy(inc/led.h > TARGET:inc/led_.{name}..h, name=.{name}., pin=.{pin}.)
EMIC:copy(src/led.c > TARGET:led_.{name}..c, name=.{name}., pin=.{pin}.)

// Registrar para compilación
EMIC:define(main_includes.led_.{name}., led_.{name}.)
EMIC:define(c_modules.led_.{name}., led_.{name}.)
```

Cuando se llama con `name=status, pin=Led1`:
- Se crea `led_status.h` y `led_status.c`
- Se registra `led_status` en los grupos de compilación

---

## 3. Sustitución de Macros .{key}.

La sintaxis `.{key}.` permite sustituir valores en cualquier parte del texto procesado.

### 3.1 Sintaxis de Sustitución

| Sintaxis | Descripción | Ejemplo |
|----------|-------------|---------|
| `.{key}.` | Busca en local, luego global | `.{name}.` → `status` |
| `.{grupo.key}.` | Busca en grupo específico | `.{config.baud}.` → `9600` |
| `.{grupo.*}.` | Expande todas las claves del grupo | `.{main_includes.*}.` |

### 3.2 Prioridad de Búsqueda

Cuando se usa `.{key}.` sin especificar grupo:

```
1. Primero busca en "local" (parámetros del comando)
   Ejemplo: EMIC:setInput(file.emic, name=valor)
            Aquí 'name' está en local

2. Si no existe, busca en "global" (EMIC:define)
   Ejemplo: EMIC:define(VERSION, 1.0)
            Aquí 'VERSION' está en global

3. Si no existe en ninguno → ERROR
```

### 3.3 Ejemplos de Sustitución

#### En nombres de archivos:
```c
// Origen
EMIC:copy(src/led.c > TARGET:led_.{name}..c, name=status)

// Resultado: copia a "led_status.c"
```

#### En código C:
```c
// Archivo fuente (led.h)
void LED_.{name}._on(void);
void LED_.{name}._off(void);
void LED_.{name}._blink(uint16_t period);

// Con name=status, genera:
void LED_status_on(void);
void LED_status_off(void);
void LED_status_blink(uint16_t period);
```

#### En tags DOXYGEN:
```c
/**
* @fn void LEDs_.{name}._state(uint8_t state);
* @alias .{name}..state
* @brief Change the state of the led .{name}.
*/

// Con name=Error, publica:
// Función: LEDs_Error_state
// Alias: Error.state
```

### 3.4 Doble Punto en Nombres de Archivo

Observa que en los nombres de archivo se usa `.{name}..` (con doble punto):

```c
led_.{name}..c
      ↑    ↑
      │    └── Punto del nombre de archivo (.c)
      └── Punto de cierre de la sustitución
```

Esto es porque `.{name}.` se sustituye completamente, incluyendo el punto final. Si escribieras `led_.{name}.c`, obtendríás `led_statusc` (sin el punto).

---

## 4. Grupos de Macros

EMIC-Codify organiza las macros en **grupos** (también llamados diccionarios o colecciones).

### 4.1 Grupos Predefinidos

| Grupo | Origen | Acceso | Uso Típico |
|-------|--------|--------|------------|
| **local** | Parámetros de comandos | `.{key}.` o `.{local.key}.` | Parametrizar APIs |
| **global** | `EMIC:define(k,v)` | `.{key}.` o `.{global.key}.` | Constantes globales |
| **config** | Configurators JSON | `.{config.key}.` | Opciones del usuario |
| **system** | Sistema EMIC | `.{system.key}.` | Info del MCU, proyecto |

### 4.2 Grupo local: Parámetros de Comandos

Los parámetros pasados en `setInput` o `copy` se almacenan en el grupo **local**:

```c
EMIC:setInput(DEV:_api/LEDs/led.emic, name=status, pin=RB0)
//                                     ↑           ↑
//                                     Estas son macros locales

// Dentro de led.emic:
LED_.{name}._init();   // → LED_status_init();
GPIO_Set(.{pin}.);     // → GPIO_Set(RB0);
```

### 4.3 Grupo global: Macros Globales

Las macros definidas con `EMIC:define` se almacenan en **global** y están disponibles en todo el procesamiento:

```c
// En generate.emic
EMIC:define(PROJECT_VERSION, 2.0)

// En cualquier archivo procesado
const char* version = ".{PROJECT_VERSION}.";  // → "2.0"
```

### 4.4 Grupo config: Configurators JSON

Cuando el usuario selecciona opciones en un Configurator, los valores se guardan en **config**:

```c
// En rs232.emic
EMIC:json(type = configurator)
{
    "name": "RS232prot",
    "options": [
        {"legend": "EMIC Message", "value": "EMIC_message"},
        {"legend": "TEXT Message", "value": "TEXT_line"}
    ]
}

// Usar el valor seleccionado por el usuario
EMIC:if(.{config.RS232prot}.==EMIC_message)
    // Código para protocolo EMIC
EMIC:endif
```

### 4.5 Grupos Personalizados para Registros

Un patrón muy común es usar grupos para registrar elementos que luego serán procesados:

```c
// Registrar módulos de compilación
EMIC:define(c_modules.led_status, led_status)
EMIC:define(c_modules.timer1, timer1)
EMIC:define(c_modules.rs232, rs232)

// Luego, en el template de proyecto MPLAB:
// Se expanden todas las claves del grupo c_modules
// para agregar los archivos .c al proyecto
```

---

## 5. Macros para Configuración de APIs

Las macros permiten crear APIs flexibles que se adaptan a diferentes hardware y configuraciones.

### 5.1 Patrón de API Parametrizada

```c
// led.emic - API parametrizada
EMIC:tag(driverName = LEDs)

// Tags con parámetros sustituibles
/**
* @fn void LEDs_.{name}._state(uint8_t state);
* @alias .{name}..state
* @brief Control LED .{name}. connected to pin .{pin}.
*/

// Dependencias
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)

// Copiar con sustitución de parámetros
EMIC:copy(inc/led.h > TARGET:inc/led_.{name}..h, name=.{name}., pin=.{pin}.)
EMIC:copy(src/led.c > TARGET:led_.{name}..c, name=.{name}., pin=.{pin}.)

// Registrar para compilación
EMIC:define(main_includes.led_.{name}., led_.{name}.)
EMIC:define(c_modules.led_.{name}., led_.{name}.)
```

### 5.2 Uso desde generate.emic

```c
// generate.emic del módulo
EMIC:setOutput(TARGET:generate.txt)

// Instanciar múltiples LEDs con diferentes parámetros
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=status, pin=Led1)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=error, pin=Led2)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=power, pin=RC0)

EMIC:restoreOutput
```

**Resultado:** Se generan 6 archivos:
- `led_status.h`, `led_status.c`
- `led_error.h`, `led_error.c`
- `led_power.h`, `led_power.c`

### 5.3 Ejemplo Real: Timer API

Del archivo `_api/Timers/timer_api.emic`:

```c
EMIC:tag(driverName = TIMER)

/**
* @fn void setTime.{name}.(uint16_t time, char mode);
* @alias setTime.{name}.
* @brief Set timer .{name}. with specified time in milliseconds.
*/

/**
* @fn extern void etOut.{name}.(void);
* @alias timeOut.{name}.
* @brief Event triggered when timer .{name}. expires.
*/

EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

EMIC:copy(inc/timer_api.h > TARGET:inc/timer_api.{name}..h, name=.{name}.)
EMIC:copy(src/timer_api.c > TARGET:timer_api.{name}..c, name=.{name}.)

EMIC:define(main_includes.timer_api.{name}., timer_api.{name}.)
EMIC:define(c_modules.timer_api.{name}., timer_api.{name}.)
```

Uso:
```c
EMIC:setInput(DEV:_api/Timers/timer_api.emic, name=1)
EMIC:setInput(DEV:_api/Timers/timer_api.emic, name=Blink)
```

Genera funciones: `setTime1()`, `setTimeBlink()`, eventos `timeOut1()`, `timeOutBlink()`

---

## 6. Macros en Compilación de Módulos

Un uso crítico de las macros es gestionar qué archivos se incluyen en el proyecto compilable.

### 6.1 Grupos de Compilación

| Grupo | Propósito | Cómo se usa |
|-------|-----------|-------------|
| `main_includes.*` | Headers a incluir en main.c | `#include "led_.{key}..h"` |
| `c_modules.*` | Archivos .c a compilar | Agregados al proyecto MPLAB |

### 6.2 Flujo de Registro y Uso

```
┌─────────────────────────────────────────────────────────────────┐
│                 REGISTRO Y USO DE MÓDULOS                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. API REGISTRA MÓDULOS:                                        │
│  ─────────────────────────                                       │
│  // led.emic                                                     │
│  EMIC:define(main_includes.led_status, led_status)               │
│  EMIC:define(c_modules.led_status, led_status)                   │
│                                                                  │
│  // timer.emic                                                   │
│  EMIC:define(main_includes.timer1, timer1)                       │
│  EMIC:define(c_modules.timer1, timer1)                           │
│                                                                  │
│  2. CONTENIDO DE LOS GRUPOS:                                     │
│  ───────────────────────────                                     │
│  main_includes = {                                               │
│      led_status: "led_status",                                   │
│      timer1: "timer1"                                            │
│  }                                                               │
│                                                                  │
│  3. TEMPLATE EXPANDE GRUPOS:                                     │
│  ───────────────────────────                                     │
│  // En main.c template                                           │
│  #include ".{main_includes.*}..h"                                │
│                                                                  │
│  → #include "led_status.h"                                       │
│  → #include "timer1.h"                                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 6.3 Ejemplo: generate.emic Completo

```c
EMIC:setOutput(TARGET:generate.txt)

//-------------- Hardware Config ---------------------
EMIC:setInput(DEV:_pcb/pcb.emic, pcb=HRD_USB V1.1)

//-- Process EMIC-Generate files result --
EMIC:setInput(SYS:usedFunction.emic)
EMIC:setInput(SYS:usedEvent.emic)

//------------------- APIs -----------------------
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=status, pin=Led1)
EMIC:setInput(DEV:_api/Timers/timer_api.emic, name=1)
EMIC:setInput(DEV:_api/Sensors/Temperature/temperature.emic, pin=AN0)

//-------------------- main  -----------------------
EMIC:setInput(DEV:_main/baremetal/main.emic)

//-- Copy EMIC-Generate files result ----------------
EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)

//---- Set userFncFile.c as a compiler module ---------
EMIC:define(c_modules.userFncFile, userFncFile)

//-- Add all compiler modules to the project. --
EMIC:copy(DEV:_templates\projects\mplabx > TARGET:)

EMIC:restoreOutput
```

---

## 7. Caso Práctico: API Configurable con Macros

Vamos a crear una API de comunicación RS232 que demuestra el uso avanzado de macros.

### 7.1 Requisitos

- Soportar diferentes protocolos (EMIC Message, TEXT Line)
- Configurar puerto UART, baudrate, buffer
- Permitir múltiples instancias

### 7.2 Implementación: rs232.emic

```c
/*****************************************************************************
  @file     rs232.emic
  @brief    RS232 API con configuración flexible mediante macros
 *****************************************************************************/
EMIC:tag(driverName = RS232)

// Protección contra inclusión múltiple
EMIC:ifndef _RS232_API_EMIC
EMIC:define(_RS232_API_EMIC, true)

// Configurar callback del UART
EMIC:define(UART.{port}._CALLBACK_RX, true)

// Configurator para selección de protocolo
EMIC:json(type = configurator)
{
    "brief": "Define el formato de los datos enviados y recibidos",
    "legend": "Seleccione protocolo",
    "name": "RS232prot",
    "options": [
        {
            "legend": "EMIC Message",
            "value": "EMIC_message",
            "brief": "Mensajes para intercambio entre módulos EMIC"
        },
        {
            "legend": "TEXT Line",
            "value": "TEXT_line",
            "brief": "Mensajes de texto terminados en fin de línea"
        }
    ]
}

// Funciones condicionales según protocolo seleccionado
EMIC:if(.{config.RS232prot}.==EMIC_message)
/**
* @fn void pRS232(char* format,...);
* @alias Send_EMIC(concat tag, concat msg)
* @brief Send an EMIC message through RS232 port .{port}.
* @param tag Tag identifying the message
* @param msg Message content
*/

/**
* @fn extern void eRS232(char* tag, const streamIn_t* const msg);
* @alias Reception_EMIC
* @brief When receiving an EMIC message through RS232 port .{port}.
* @param tag Tag to identify the message
* @param msg Message payload
*/
EMIC:endif

EMIC:if(.{config.RS232prot}.==TEXT_line)
/**
* @fn variadic pRS232(char* format,...);
* @alias Send_TEXT(concat msg)
* @brief Send a text message through RS232 port .{port}.
* @param msg Message content
*/

/**
* @fn extern void eRS232(const streamIn_t* const msg);
* @alias Reception_TEXT
* @brief When receiving a string through RS232 port .{port}.
* @param msg Message payload
*/
EMIC:endif

/**
* @fn extern void eBeRS232();
* @alias endSend
* @brief When finish sending data by RS232 port .{port}.
*/

// Dependencias
EMIC:setInput(DEV:_system/Stream/stream.emic)
EMIC:setInput(DEV:_system/Stream/streamOut.emic)
EMIC:setInput(DEV:_system/Stream/streamIn.emic)
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_hal/UART/UART.emic, port=.{port}., BufferSize=.{BufferSize}., baud=.{baud}., name=.{name}., driver=RS232_TTL)

// Generar archivos de salida
EMIC:setOutput(TARGET:inc/rs232.h)
    EMIC:setInput(inc/rs232.h, port=.{port}., frameLf=.{frameLf}.)
EMIC:restoreOutput

EMIC:setOutput(TARGET:rs232.c)
    EMIC:setInput(src/rs232.c, port=.{port}., frameLf=.{frameLf}., name=.{name}.)
EMIC:restoreOutput

// Registrar para compilación
EMIC:define(main_includes.rs232, rs232)
EMIC:define(c_modules.rs232, rs232)

EMIC:endif
```

### 7.3 Uso en generate.emic

```c
// Configurar RS232 con parámetros específicos
EMIC:setInput(DEV:_api/Wired_Communication/RS232/rs232.emic,
    port=1,
    BufferSize=256,
    baud=9600,
    frameLf=\n,
    name=COM1
)
```

### 7.4 Resultado

Dependiendo de la selección del usuario en el Configurator:

**Si selecciona "EMIC Message":**
- Se publican: `Send_EMIC(tag, msg)` y `Reception_EMIC` event

**Si selecciona "TEXT Line":**
- Se publican: `Send_TEXT(msg)` y `Reception_TEXT` event

---

## 8. Errores Comunes y Soluciones

### 8.1 Macro No Encontrada

**Error:**
```
Error: No se encuentra 'pin' en ninguna colección
```

**Causa:** La macro no fue pasada como parámetro ni definida globalmente.

**Solución:**
```c
// Asegurarse de pasar todos los parámetros requeridos
EMIC:setInput(DEV:_api/LEDs/led.emic, name=status, pin=RB0)
//                                                  ↑ No olvidar
```

### 8.2 Nombre de Archivo Incorrecto

**Error:**
```
Archivo generado: led_statusc (sin el punto)
```

**Causa:** Falta el doble punto en el nombre.

**Solución:**
```c
// Incorrecto
EMIC:copy(src/led.c > TARGET:led_.{name}.c)

// Correcto (doble punto)
EMIC:copy(src/led.c > TARGET:led_.{name}..c)
```

### 8.3 Módulo No Compilado

**Error:**
```
Linking error: undefined reference to 'LED_status_on'
```

**Causa:** El archivo .c no se registró en `c_modules`.

**Solución:**
```c
// Siempre registrar después de copiar
EMIC:copy(src/led.c > TARGET:led_.{name}..c, name=.{name}.)
EMIC:define(c_modules.led_.{name}., led_.{name}.)  // ← No olvidar
```

### 8.4 Sustitución en Grupo Incorrecto

**Error:**
```
Macro 'baud' no encontrada cuando debería existir
```

**Causa:** Intentar acceder a macro de config sin que el usuario haya seleccionado.

**Solución:**
```c
// Usar el grupo correcto
.{config.RS232prot}.  // Valor del Configurator
.{baud}.              // Parámetro local pasado en setInput
```

### 8.5 Tabla de Referencia Rápida

| Problema | Síntoma | Solución |
|----------|---------|----------|
| Macro faltante | "No se encuentra 'X'" | Verificar parámetros en setInput |
| Nombre mal formado | Archivo sin extensión | Usar `.{name}..ext` (doble punto) |
| No compila | Linking error | Registrar en `c_modules.*` |
| Grupo incorrecto | Valor inesperado | Verificar local vs global vs config |
| Include faltante | Header not found | Registrar en `main_includes.*` |

---

## Resumen

Las macros en EMIC-Codify permiten:

1. **Parametrizar código** - Crear componentes reutilizables con `.{key}.`
2. **Definir constantes** - Usar `EMIC:define(k, v)` para valores globales
3. **Registrar módulos** - Grupos `main_includes.*` y `c_modules.*`
4. **Configurar desde UI** - Grupo `config.*` para valores de Configurators
5. **Crear instancias múltiples** - Mismo código, diferentes parámetros

**Patrón típico de API:**
```c
EMIC:tag(driverName = MiAPI)

// Tags con parámetros
/**
* @fn void MiAPI_.{name}._funcion(void);
*/

// Dependencias
EMIC:setInput(DEV:_hal/xxx.emic)

// Copiar con sustitución
EMIC:copy(src/api.c > TARGET:api_.{name}..c, name=.{name}.)

// Registrar para compilación
EMIC:define(main_includes.api_.{name}., api_.{name}.)
EMIC:define(c_modules.api_.{name}., api_.{name}.)
```

---

**Navegación:**
- [← Capítulo 17: Comandos de Gestión de Archivos](17_Comandos_Gestion_Archivos.md)
- [→ Capítulo 19: Control de Flujo y Condicionales](19_Control_Flujo_Condicionales.md)
