# Capítulo 16: Fundamentos de EMIC-Codify para Desarrollo

## Tabla de Contenidos

1. [¿Qué es EMIC-Codify?](#1-qué-es-emic-codify)
2. [Sistema de Macros](#2-sistema-de-macros)
3. [Sintaxis Básica](#3-sintaxis-básica)
4. [Codify para Integrar vs Codify para Desarrollar](#4-codify-para-integrar-vs-codify-para-desarrollar)
5. [Sistema de Volúmenes Lógicos](#5-sistema-de-volúmenes-lógicos)
6. [Primer Archivo .emic para una API](#6-primer-archivo-emic-para-una-api)
7. [Tags Básicos de Publicación](#7-tags-básicos-de-publicación)
8. [Ejemplo Completo: API Simple](#8-ejemplo-completo-api-simple)
9. [Flujo de Procesamiento](#9-flujo-de-procesamiento)
10. [Errores Comunes y Debugging](#10-errores-comunes-y-debugging)

---

## 1. ¿Qué es EMIC-Codify?

EMIC-Codify es un **lenguaje de procesamiento de texto** diseñado específicamente para crear código C compilable a partir de un conjunto de archivos de texto llamados "EMIC-Libraries".

### 1.1 Propósito Principal

EMIC-Codify cumple dos funciones fundamentales:

1. **Comandos de Manipulación**: Permiten procesar, fusionar y transformar el contenido de las EMIC-Libraries, guardando el resultado en archivos de salida.

2. **Etiquetas de Publicación**: Se utilizan para extraer referencias al código (funciones, variables, eventos) y publicarlas en el EMIC-Editor durante la fase de Discovery.

### 1.2 Contexto de Ejecución

EMIC-Codify se ejecuta en dos contextos principales:

| Contexto | Propósito | Archivos Procesados |
|----------|-----------|---------------------|
| **Discovery** | Indexar recursos disponibles | Solo `.emic` y `.h` |
| **Generate (Compile)** | Crear código compilable | Todos los archivos |

> **📝 Nota:** En modo Discovery, solo se procesan archivos `.emic` y `.h` para optimizar el rendimiento y extraer únicamente la información de publicación.

### 1.3 Componentes del Lenguaje

EMIC-Codify está formado por:

```
EMIC-Codify
├── Comandos (EMIC:xxx)
│   ├── Gestión de Archivos (setInput, setOutput, copy, restoreOutput)
│   ├── Macros (define, unDefine)
│   ├── Control de Flujo (if, ifdef, ifndef, elif, else, endif)
│   └── Iteración (foreach, endforeach)
│
├── Sustitución de Texto
│   ├── .{key}. → Sustitución simple
│   ├── .{group.key}. → Sustitución con grupo (2 niveles)
│   ├── .{g1.g2.key}. → Sustitución con 3 niveles
│   ├── .{group.*}. → Expansión de grupo (N líneas)
│   └── .{group.*}. .[sep]. → Expansión join (1 línea)
│
└── Etiquetas de Publicación
    ├── Formato DOXYGEN (@fn, @alias, @brief, @param, @return)
    ├── Tag driverName (EMIC:tag)
    └── Formato JSON (EMIC:json)
```

---

## 2. Sistema de Macros

Las macros son el mecanismo central de EMIC-Codify para parametrizar y personalizar el código generado. Permiten definir valores que serán sustituidos durante el procesamiento.

### 2.1 Grupos de Macros

EMIC-Codify organiza las macros en grupos (o diccionarios):

| Grupo | Descripción | Cómo se crea | Ejemplo de acceso |
|-------|-------------|--------------|-------------------|
| **local** | Parámetros pasados en comandos | `EMIC:setInput(file, name=valor)` | `.{name}.` o `.{local.name}.` |
| **global** | Macros definidas globalmente | `EMIC:define(clave, valor)` | `.{clave}.` o `.{global.clave}.` |
| **config** | Valores de configuradores JSON | Selección del usuario en Editor | `.{config.nombre}.` |
| **system** | Macros del sistema EMIC | Automático | `.{system.mcu}.` |

### 2.2 Prioridad de Búsqueda

Cuando se usa `.{clave}.` sin especificar grupo:

```
1. Buscar en "local" (parámetros del comando actual)
      ↓ Si no existe
2. Buscar en "global" (macros definidas con EMIC:define)
      ↓ Si no existe
3. ERROR: "No se encuentra clave en ninguna colección"
```

### 2.3 Definir y Usar Macros

**Definir macros globales:**
```c
EMIC:define(VERSION, 1.0)
EMIC:define(AUTOR, MiEmpresa)
EMIC:define(proyecto.nombre, MiProyecto)  // En grupo "proyecto"
```

**Pasar macros locales en comandos:**
```c
EMIC:setInput(api.emic, name=LED1, pin=RA0, color=rojo)
EMIC:copy(src/code.c > TARGET:output.c, id=001, tipo=sensor)
```

**Usar macros en el código:**
```c
// En cualquier archivo procesado:
const char* version = ".{VERSION}.";           // → "1.0"
void .{name}._init(void);                      // → LED1_init(void);
#define PIN_USADO .{pin}.                      // → RA0
const char* proyecto = ".{proyecto.nombre}.";  // → "MiProyecto"
```

### 2.4 Valor por Defecto

Se puede especificar un valor por defecto usando el operador `|`:

```c
// Sintaxis: .{valorPorDefecto|grupo.clave}.
uint8_t timeout = .{100|config.timeout}.;  // Usa 100 si config.timeout no existe
```

### 2.5 Expansión de Grupo Completo

Para expandir todas las claves de un grupo, usar `.*`:

```c
// Si el grupo "inits" contiene: {LED: LED_init, Timer: Timer_init, USB: USB_init}

.{inits.*}.();
// Se expande a (una línea por key):
// LED_init();
// Timer_init();
// USB_init();
```

**Expansión Join (una sola línea):** Agregar `.[separador].` después para generar una sola línea:

```c
enum { .{canales.*}. .[, ]. };
// → enum { ADC_AN0, ADC_AN1, ADC_AN2 };
```

### 2.6 Macros de 3 Niveles

Para organización jerárquica más compleja, se soportan **3 niveles de profundidad**:

```c
// Definir con 3 niveles: grupo.subgrupo.clave
EMIC:define(hw.uart.baud, 9600)
EMIC:define(hw.uart.parity, none)
EMIC:define(hw.spi.clock, 1000000)

// Acceder: .{hw.uart.baud}. → 9600
// Expandir: .{hw.uart.*}. → una línea por propiedad de uart
```

La distinción entre 2 y 3 niveles se determina automáticamente por la cantidad de puntos en el nombre.

---

## 3. Sintaxis Básica

### 3.1 Comandos EMIC

Los comandos tienen la forma general:

```
EMIC:comando([parámetros])
```

> **⚠️ Importante:** Los parámetros entre corchetes `[]` son opcionales. Los parámetros pueden repetirse usando `[[parametro]]`.

### 3.2 Tabla de Comandos Principales

| Comando | Sintaxis | Descripción |
|---------|----------|-------------|
| `setInput` | `EMIC:setInput([origin:][dir/]file[[,key=value]])` | Procesa un archivo |
| `setOutput` | `EMIC:setOutput([target:][dir/]file)` | Establece archivo de salida |
| `restoreOutput` | `EMIC:restoreOutput` | Restaura salida anterior |
| `copy` | `EMIC:copy(origen > destino[[,key=value]])` | Copia procesando |
| `define` | `EMIC:define([group.]key,value)` | Define una macro |
| `unDefine` | `EMIC:unDefine([group.]key)` | Elimina una macro |
| `if` | `EMIC:if(condition)` | Condicional |
| `ifdef` | `EMIC:ifdef(macro)` | Si macro está definida |
| `ifndef` | `EMIC:ifndef(macro)` | Si macro NO está definida |
| `elif` | `EMIC:elif(condition)` | Else if |
| `else` | `EMIC:else` | Else |
| `endif` | `EMIC:endif` | Fin de condicional |
| `foreach` | `EMIC:foreach(group.*)` | Itera sobre colección |
| `endforeach` | `EMIC:endforeach` | Fin de iteración |
| `tag` | `EMIC:tag(driverName = xxx)` | Define nombre de driver |
| `json` | `EMIC:json(type = xxx)` | Define recurso JSON |

### 3.3 Sustitución de Macros

La sustitución se realiza con la sintaxis `.{xxx}.`:

```c
// Sustitución simple (busca en local, luego en global)
void LED_.{name}._init(void);

// Sustitución con grupo específico
const char* MCU_NAME = ".{system.mcu}.";

// Sustitución con valor por defecto
uint8_t baudRate = .{9600|config.baudRate}.;

// Expansión de grupo completo (N líneas)
.{inits.*}.();  // Expande todas las claves del grupo "inits"

// Expansión join (1 línea con separador)
enum { .{canales.*}. .[, ]. };  // Todos los valores separados por coma

// Sustitución con 3 niveles
.{hw.uart.baud}.  // → 9600
```

### 3.4 Orden de Búsqueda de Macros

Cuando se usa `.{key}.` sin grupo:

```
1. Buscar en "local" (parámetros del comando actual)
2. Si no existe → Buscar en "global"
3. Si no existe → ERROR
```

Cuando se usa `.{group.key}.`:

```
1. Buscar en el diccionario "group"
2. Si no existe el grupo o la clave → Usar valor por defecto si existe
3. Si no hay valor por defecto → ERROR
```

---

## 4. Codify para Integrar vs Codify para Desarrollar

### 4.1 Diferencias Fundamentales

| Aspecto | Integrador | Desarrollador |
|---------|------------|---------------|
| **Objetivo** | Usar componentes existentes | Crear componentes nuevos |
| **Archivos que crea** | Scripts en EMIC-Editor | Archivos .emic, .c, .h |
| **Uso de comandos** | Indirecto (via EMIC-Editor) | Directo (escribe comandos) |
| **Tags DOXYGEN** | No los escribe | Los escribe para publicar |
| **Conocimiento requerido** | Básico de EMIC-Codify | Dominio completo |

### 4.2 Lo que el Integrador Ve

El integrador trabaja en el EMIC-Editor y ve los recursos publicados:

```
┌─────────────────────────────────────────────────────────────┐
│                      EMIC-Editor                             │
├─────────────────────────────────────────────────────────────┤
│  Drivers Disponibles:                                        │
│  ├── LEDs                                                    │
│  │   ├── [Función] led.state(state)                         │
│  │   ├── [Función] led.blink(timeOn, period, times)         │
│  │   └── [Variable] led.status                              │
│  ├── Timers                                                  │
│  │   ├── [Función] timer.setTime(time, mode)                │
│  │   └── [Evento] timer.onTimeout()                         │
│  └── USB                                                     │
│      ├── [Función] USB.send(tag, msg)                       │
│      └── [Evento] USB.onReceive(tag, msg)                   │
└─────────────────────────────────────────────────────────────┘
```

### 4.3 Lo que el Desarrollador Escribe

El desarrollador escribe el código que hace posible esa interfaz:

```c
// led.emic - Archivo que el desarrollador crea
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
* @brief Blink the .{name}. LED
* @param timeOn Time that the LED stays on in each cycle
* @param period Length of time each cycle lasts
* @param times Number of cycles
* @return Nothing
*/

// Dependencias
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

// Copiar archivos procesados
EMIC:copy(inc/led.h > TARGET:inc/led_.{name}..h, name=.{name}., pin=.{pin}.)
EMIC:copy(src/led.c > TARGET:led_.{name}..c, name=.{name}., pin=.{pin}.)

// Registrar en diccionarios del sistema
EMIC:define(main_includes.led_.{name}., led_.{name}.)
EMIC:define(c_modules.led_.{name}., led_.{name}.)
```

### 4.4 El Ciclo Completo

```
┌──────────────────────────────────────────────────────────────────┐
│                    CICLO DE DESARROLLO EMIC                       │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  DESARROLLADOR                          INTEGRADOR                │
│  ─────────────                          ──────────                │
│                                                                   │
│  1. Escribe led.emic ──────────────────────────────────────────┐ │
│     (con tags @fn, @alias, etc.)                                │ │
│                                                                  │ │
│  2. Escribe led.h, led.c ────────────────────────────────────┐  │ │
│     (código C con .{name}.)                                   │  │ │
│                                                               │  │ │
│                              ┌────────────────────────────────┘  │ │
│                              ↓                                    │ │
│                         EMIC Discovery                            │ │
│                              │                                    │ │
│                              ↓                                    │ │
│                    ┌─────────────────────┐                        │ │
│                    │    EMIC-Editor      │←───────────────────────┘ │
│                    │  (Recursos visibles)│                          │
│                    └─────────────────────┘                          │
│                              │                                      │
│                              ↓                                      │
│                    3. Crea Script visual ←──── INTEGRADOR          │
│                              │                                      │
│                              ↓                                      │
│                         EMIC Generate                               │
│                              │                                      │
│                              ↓                                      │
│                    ┌─────────────────────┐                          │
│                    │   Código C Final    │                          │
│                    │   (Compilable)      │                          │
│                    └─────────────────────┘                          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 5. Sistema de Volúmenes Lógicos

### 5.1 Volúmenes Disponibles

EMIC define volúmenes lógicos para abstraer las rutas físicas:

| Volumen | Referencia | Uso Típico |
|---------|------------|------------|
| `DEV:` | Repositorio del SDK | Leer APIs, drivers, HAL |
| `TARGET:` | Carpeta de salida del proyecto | Escribir código generado |
| `SYS:` | Configuración de la aplicación | Leer/escribir configs |
| `USER:` | Archivos del usuario (integrador) | Leer código del usuario |

### 5.2 Uso en Comandos

```c
// Leer desde el SDK
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic)

// Escribir en la carpeta del proyecto
EMIC:setOutput(TARGET:inc/led_StatusLED.h)

// Copiar procesando: origen > destino
EMIC:copy(DEV:_api/Indicators/LEDs/src/led.c > TARGET:led_StatusLED.c)

// Rutas relativas (desde el archivo actual)
EMIC:setInput(inc/header.h)
EMIC:copy(src/code.c > TARGET:output.c)
```

### 5.3 Validación de Volúmenes

El intérprete valida que las rutas incluyan volúmenes válidos:

```csharp
// Del TreeMaker.cs - líneas 521-537
if (line.Contains(":"))
{
    string volume = line.Substring(0, line.IndexOf(":"));
    if (mediaAccess.VirtualDrivers.Keys.Contains(volume))
    {
        stackFiles.Push(codigoActual);
        codigoActual = line;
    }
    else
    {
        exceptions.Add(new EmicException("error",
            $"La ruta debe incluir un volumen válido",
            fileName, nroLinea, 0));
    }
}
```

---

## 6. Primer Archivo .emic para una API

### 6.1 Estructura Mínima

Un archivo `.emic` para una API debe contener:

```c
// 1. Tag de agrupación (opcional pero recomendado)
EMIC:tag(driverName = MiAPI)

// 2. Publicación de recursos (funciones, eventos, variables)
/**
* @fn void MiAPI_init(void);
* @alias init
* @brief Inicializa la API
* @return Nothing
*/

// 3. Dependencias (otras APIs, HAL, drivers)
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)

// 4. Copia de archivos fuente
EMIC:copy(inc/miapi.h > TARGET:inc/miapi.h)
EMIC:copy(src/miapi.c > TARGET:miapi.c)

// 5. Registro en diccionarios del sistema
EMIC:define(main_includes.miapi, miapi)
EMIC:define(c_modules.miapi, miapi)
```

### 6.2 Anatomía del Archivo

```
mi_api.emic
│
├── CABECERA
│   └── EMIC:tag(driverName = xxx)
│       Define cómo se agruparán los recursos en el Editor
│
├── PUBLICACIÓN DE RECURSOS
│   ├── Funciones: /** @fn ... @alias ... @brief ... */
│   ├── Eventos: /** @fn extern ... @alias ... */
│   └── Variables: /** @var ... @alias ... */
│
├── DEPENDENCIAS
│   └── EMIC:setInput(DEV:_hal/xxx/xxx.emic)
│       Carga otras APIs o HAL necesarios
│
├── COPIA DE ARCHIVOS
│   ├── EMIC:copy(inc/xxx.h > TARGET:inc/xxx.h, params...)
│   └── EMIC:copy(src/xxx.c > TARGET:xxx.c, params...)
│       Procesa y copia los archivos fuente
│
└── REGISTRO EN DICCIONARIOS
    ├── EMIC:define(main_includes.xxx, xxx)
    │   Para que main.c incluya el header
    └── EMIC:define(c_modules.xxx, xxx)
        Para que MPLAB compile el .c
```

### 6.3 Ejemplo: API de Contador Simple

Creemos una API simple que cuenta eventos:

**Estructura de carpetas:**
```
_api/Utilities/Counter/
├── counter.emic
├── inc/
│   └── counter.h
└── src/
    └── counter.c
```

**counter.emic:**
```c
EMIC:tag(driverName = Counter)

/**
* @fn void Counter_.{name}._reset(void);
* @alias .{name}..reset
* @brief Reset the counter to zero
* @return Nothing
*/

/**
* @fn void Counter_.{name}._increment(void);
* @alias .{name}..increment
* @brief Increment the counter by one
* @return Nothing
*/

/**
* @fn uint32_t Counter_.{name}._getValue(void);
* @alias .{name}..getValue
* @brief Get the current counter value
* @return Current count value
*/

/**
* @var uint32_t Counter_.{name}._value = 0;
* @alias .{name}..value
* @brief Current counter value (read-only recommended)
*/

// Copiar archivos procesados
EMIC:copy(inc/counter.h > TARGET:inc/counter_.{name}..h, name=.{name}.)
EMIC:copy(src/counter.c > TARGET:counter_.{name}..c, name=.{name}.)

// Registrar en el sistema
EMIC:define(main_includes.counter_.{name}., counter_.{name}.)
EMIC:define(c_modules.counter_.{name}., counter_.{name}.)
```

---

## 7. Tags Básicos de Publicación

### 7.1 Tag `driverName`

Agrupa los recursos bajo un nombre común en el EMIC-Editor:

```c
EMIC:tag(driverName = LEDs)
```

Resultado en el Editor:
```
└── LEDs
    ├── led.state()
    ├── led.blink()
    └── led.status
```

### 7.2 Formato DOXYGEN para Funciones

```c
/**
* @fn tipo nombreFuncion([parámetros]);
* @alias aliasEnEditor
* @brief Descripción breve de la función
* @param nombreParam1 Descripción del parámetro 1
* @param nombreParam2 Descripción del parámetro 2
* @return Descripción del valor de retorno
*/
```

**Ejemplo completo:**
```c
/**
* @fn void LEDs_.{name}._blink(uint16_t timeOn, uint16_t period, uint16_t times);
* @alias .{name}..blink
* @brief Hace parpadear el LED con los tiempos especificados
* @param timeOn Tiempo en ms que el LED permanece encendido
* @param period Duración total de cada ciclo en ms
* @param times Número de ciclos de parpadeo
* @return Nothing
*/
```

### 7.3 Formato DOXYGEN para Eventos

Los eventos se definen agregando `extern` al `@fn`:

```c
/**
* @fn extern void Timer_.{name}._onTimeout(void);
* @alias .{name}..onTimeout
* @brief Se dispara cuando el temporizador llega a cero
* @return Nothing
*/
```

> **📝 Nota:** La palabra clave `extern` indica al sistema que esta es una función que el integrador debe implementar (callback).

### 7.4 Formato DOXYGEN para Variables

```c
/**
* @var tipo nombreVariable [= valorInicial];
* @alias aliasEnEditor
* @brief Descripción de la variable
*/
```

**Ejemplo:**
```c
/**
* @var uint8_t LEDs_.{name}._currentState = 0;
* @alias .{name}..status
* @brief Estado actual del LED (0=apagado, 1=encendido, 2=parpadeando)
*/
```

### 7.5 Tabla Resumen de Tags

| Tag | Uso | Ejemplo |
|-----|-----|---------|
| `@fn` | Firma de función | `@fn void init(void);` |
| `@fn extern` | Evento (callback) | `@fn extern void onEvent(void);` |
| `@var` | Variable | `@var uint8_t status = 0;` |
| `@alias` | Nombre en Editor | `@alias led.init` |
| `@brief` | Descripción | `@brief Inicializa el LED` |
| `@param` | Parámetro | `@param pin Número de pin` |
| `@return` | Retorno | `@return Valor actual` |

---

## 8. Ejemplo Completo: API Simple

### 8.1 Especificación

Crearemos una API de **Botón** (Button) con:
- Función para leer el estado
- Función para configurar debounce
- Evento cuando se presiona
- Variable con el estado actual

### 8.2 Estructura de Archivos

```
_api/Input/Button/
├── button.emic
├── inc/
│   └── button.h
└── src/
    └── button.c
```

### 8.3 Archivo button.emic

```c
// ============================================================
// EMIC API: Button
// Autor: [Tu nombre]
// Descripción: API para manejo de botones con debounce
// ============================================================

EMIC:tag(driverName = Button)

// ---------------------- FUNCIONES ----------------------

/**
* @fn uint8_t Button_.{name}._getState(void);
* @alias .{name}..getState
* @brief Lee el estado actual del botón
* @return 1 si está presionado, 0 si no
*/

/**
* @fn void Button_.{name}._setDebounce(uint16_t ms);
* @alias .{name}..setDebounce
* @brief Configura el tiempo de debounce
* @param ms Tiempo de debounce en milisegundos
* @return Nothing
*/

// ---------------------- EVENTOS ----------------------

/**
* @fn extern void Button_.{name}._onPress(void);
* @alias .{name}..onPress
* @brief Se ejecuta cuando el botón es presionado
* @return Nothing
*/

/**
* @fn extern void Button_.{name}._onRelease(void);
* @alias .{name}..onRelease
* @brief Se ejecuta cuando el botón es liberado
* @return Nothing
*/

// ---------------------- VARIABLES ----------------------

/**
* @var uint8_t Button_.{name}._state = 0;
* @alias .{name}..state
* @brief Estado actual del botón (0=liberado, 1=presionado)
*/

/**
* @var uint16_t Button_.{name}._debounceTime = 50;
* @alias .{name}..debounceMs
* @brief Tiempo de debounce configurado en ms
*/

// ---------------------- DEPENDENCIAS ----------------------

EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

// ---------------------- COPIAR ARCHIVOS ----------------------

EMIC:copy(inc/button.h > TARGET:inc/button_.{name}..h, name=.{name}., pin=.{pin}.)
EMIC:copy(src/button.c > TARGET:button_.{name}..c, name=.{name}., pin=.{pin}.)

// ---------------------- REGISTRAR EN SISTEMA ----------------------

EMIC:define(main_includes.button_.{name}., button_.{name}.)
EMIC:define(c_modules.button_.{name}., button_.{name}.)

// Registrar función init
EMIC:define(inits.Button_.{name}., Button_.{name}._init)

// Registrar función poll (necesaria para debounce)
EMIC:define(polls.Button_.{name}., Button_.{name}._poll)
```

### 8.4 Archivo button.h

```c
// ============================================================
// Button API - Header
// Instancia: .{name}.
// Pin: .{pin}.
// ============================================================

#ifndef BUTTON_.{name}._H
#define BUTTON_.{name}._H

#include <stdint.h>
#include "gpio.h"

// ---------------------- VARIABLES PÚBLICAS ----------------------

extern uint8_t Button_.{name}._state;
extern uint16_t Button_.{name}._debounceTime;

// ---------------------- FUNCIONES PÚBLICAS ----------------------

/**
 * Inicializa el botón
 */
void Button_.{name}._init(void);

/**
 * Polling para debounce (llamar desde main loop)
 */
void Button_.{name}._poll(void);

/**
 * Lee el estado actual del botón
 * @return 1 si presionado, 0 si liberado
 */
uint8_t Button_.{name}._getState(void);

/**
 * Configura el tiempo de debounce
 * @param ms Tiempo en milisegundos
 */
void Button_.{name}._setDebounce(uint16_t ms);

// ---------------------- EVENTOS (CALLBACKS) ----------------------

/**
 * Evento: botón presionado
 * Implementar en código de usuario
 */
extern void Button_.{name}._onPress(void);

/**
 * Evento: botón liberado
 * Implementar en código de usuario
 */
extern void Button_.{name}._onRelease(void);

#endif // BUTTON_.{name}._H
```

### 8.5 Archivo button.c

```c
// ============================================================
// Button API - Implementation
// Instancia: .{name}.
// Pin: .{pin}.
// ============================================================

#include "button_.{name}..h"
#include "systemTimer.h"

// ---------------------- VARIABLES ----------------------

uint8_t Button_.{name}._state = 0;
uint16_t Button_.{name}._debounceTime = 50;

// Variables internas
static uint8_t _lastRawState = 0;
static uint8_t _debounceCounter = 0;
static uint32_t _lastPollTime = 0;

// ---------------------- IMPLEMENTACIÓN ----------------------

void Button_.{name}._init(void) {
    // Configurar pin como entrada con pull-up
    GPIO_SetPinInput(.{pin}.);
    GPIO_EnablePullUp(.{pin}.);

    // Leer estado inicial
    _lastRawState = GPIO_ReadPin(.{pin}.) ? 0 : 1; // Activo bajo
    Button_.{name}._state = _lastRawState;
}

void Button_.{name}._poll(void) {
    uint32_t currentTime = SystemTimer_GetMs();

    // Solo procesar cada 1ms
    if (currentTime == _lastPollTime) return;
    _lastPollTime = currentTime;

    // Leer estado raw del pin (activo bajo)
    uint8_t rawState = GPIO_ReadPin(.{pin}.) ? 0 : 1;

    // Debounce
    if (rawState != _lastRawState) {
        _debounceCounter = 0;
        _lastRawState = rawState;
    } else {
        if (_debounceCounter < Button_.{name}._debounceTime) {
            _debounceCounter++;
        } else if (rawState != Button_.{name}._state) {
            // Estado estable diferente al actual
            uint8_t oldState = Button_.{name}._state;
            Button_.{name}._state = rawState;

            // Disparar eventos
            if (rawState == 1 && oldState == 0) {
                Button_.{name}._onPress();
            } else if (rawState == 0 && oldState == 1) {
                Button_.{name}._onRelease();
            }
        }
    }
}

uint8_t Button_.{name}._getState(void) {
    return Button_.{name}._state;
}

void Button_.{name}._setDebounce(uint16_t ms) {
    Button_.{name}._debounceTime = ms;
}

// ---------------------- WEAK CALLBACKS ----------------------
// Implementaciones débiles para evitar errores de linkeo

__attribute__((weak)) void Button_.{name}._onPress(void) {
    // Implementar en código de usuario
}

__attribute__((weak)) void Button_.{name}._onRelease(void) {
    // Implementar en código de usuario
}
```

### 8.6 Uso desde generate.emic

```c
// En el generate.emic del módulo
EMIC:setInput(DEV:_api/Input/Button/button.emic, name=Start, pin=BTN_START)
EMIC:setInput(DEV:_api/Input/Button/button.emic, name=Stop, pin=BTN_STOP)
```

Esto generará:
- `button_Start.h`, `button_Start.c`
- `button_Stop.h`, `button_Stop.c`

Con funciones como:
- `Button_Start_getState()`
- `Button_Stop_onPress()`

---

## 9. Flujo de Procesamiento

### 9.1 Fase Discovery

Durante Discovery, el intérprete:

1. **Lee archivos `.emic` y `.h`**
2. **Ignora otros tipos de archivo**
3. **Extrae tags DOXYGEN** y los almacena en `emicDrivers`
4. **Procesa configuradores JSON** (detiene si falta selección)
5. **Genera XML** con recursos publicados

```
generate.emic
     │
     ↓ EMIC:setInput(led.emic, name=Status, pin=Led1)
     │
     ↓ Procesa led.emic
     │
     ├── Lee EMIC:tag(driverName = LEDs)
     │       → driverName = "LEDs"
     │
     ├── Lee /** @fn void LEDs_.{name}._state... */
     │       → Sustituye .{name}. por "Status"
     │       → Registra función en emicDrivers["LEDs"]
     │
     ├── Lee /** @fn extern void LEDs_.{name}._onBlink... */
     │       → Registra evento en emicDrivers["LEDs"]
     │
     └── Ignora EMIC:copy (solo Discovery)
```

### 9.2 Fase Generate (Compile)

Durante Generate:

1. **Procesa TODOS los archivos**
2. **Ejecuta comandos copy**
3. **Escribe a archivos de salida**
4. **Sustituye todas las macros**

```
generate.emic
     │
     ↓ EMIC:setOutput(TARGET:generate.txt)
     │
     ↓ EMIC:setInput(led.emic, name=Status, pin=Led1)
     │
     ↓ Procesa led.emic
     │
     ├── EMIC:copy(inc/led.h > TARGET:inc/led_Status.h, name=Status, pin=Led1)
     │       │
     │       ↓ Procesa led.h
     │       │
     │       ├── void LEDs_.{name}._init(void);
     │       │       → void LEDs_Status_init(void);
     │       │
     │       └── #define LED_PIN .{pin}.
     │               → #define LED_PIN Led1
     │
     └── EMIC:define(main_includes.led_Status, led_Status)
             → Registra para incluir en main.c
```

### 9.3 Diagrama de Estados del Condicional

```
                    ┌─────────────────┐
                    │  codigValido    │
                    │    = true       │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ↓              ↓              ↓
         EMIC:ifdef     EMIC:ifndef    EMIC:if
              │              │              │
              ↓              ↓              ↓
         ¿Definido?    ¿NO Definido?   ¿Condición?
              │              │              │
         ┌────┴────┐    ┌────┴────┐    ┌────┴────┐
         │         │    │         │    │         │
        Sí        No   Sí        No   True    False
         │         │    │         │    │         │
         ↓         ↓    ↓         ↓    ↓         ↓
     Procesar  Ignorar Procesar Ignorar Procesar Ignorar
         │         │    │         │    │         │
         └────┬────┘    └────┬────┘    └────┬────┘
              │              │              │
              └──────────────┼──────────────┘
                             │
                             ↓
                        EMIC:endif
                             │
                             ↓
                    ┌─────────────────┐
                    │  Restaurar      │
                    │  codigValido    │
                    └─────────────────┘
```

---

## 10. Errores Comunes y Debugging

### 10.1 Errores de Sustitución de Macros

**Error:** `No se encuentra "xxx" en ninguna colección`

**Causa:** Se usa `.{xxx}.` pero la macro no está definida.

**Solución:**
```c
// Verificar que el parámetro se pasa en el comando
EMIC:setInput(api.emic, name=valor)  // ✅ Correcto
EMIC:setInput(api.emic)               // ❌ Falta name

// O usar valor por defecto
.{valorDefault|name}.  // Usa "valorDefault" si name no existe
```

### 10.2 Errores de Volumen

**Error:** `La ruta debe incluir un volumen válido`

**Causa:** Se usa una ruta sin volumen en `setOutput`.

**Solución:**
```c
EMIC:setOutput(TARGET:archivo.txt)  // ✅ Correcto
EMIC:setOutput(archivo.txt)          // ❌ Falta volumen
```

### 10.3 Errores de Sintaxis en copy

**Error:** `Falta caracter '>' en la línea`

**Causa:** Sintaxis incorrecta en EMIC:copy.

**Solución:**
```c
EMIC:copy(origen.c > TARGET:destino.c)  // ✅ Correcto
EMIC:copy(origen.c, TARGET:destino.c)   // ❌ Falta >
```

### 10.4 Errores de endif Desbalanceado

**Error:** Stack vacío al hacer Pop

**Causa:** Más `endif` que `if/ifdef/ifndef`.

**Solución:** Verificar que cada condicional tenga su `endif`:
```c
EMIC:ifdef FEATURE_X
    // código
    EMIC:ifdef FEATURE_Y   // ← Anidado
        // código
    EMIC:endif             // ← Cierra FEATURE_Y
EMIC:endif                 // ← Cierra FEATURE_X
```

### 10.5 Herramienta de Debugging

El intérprete genera un archivo `generate.txt` con información de trazado:

```c
// En generate.emic, al inicio:
EMIC:setOutput(TARGET:generate.txt)

// Todo el procesamiento se registra aquí
```

### 10.6 Lista de Verificación para Debugging

- [ ] ¿Todos los parámetros necesarios se pasan en `setInput`/`copy`?
- [ ] ¿Las rutas incluyen volúmenes válidos (`DEV:`, `TARGET:`, etc.)?
- [ ] ¿Los `if/ifdef/ifndef` tienen sus correspondientes `endif`?
- [ ] ¿Los archivos referenciados existen en las rutas indicadas?
- [ ] ¿Los tags DOXYGEN tienen el formato correcto?
- [ ] ¿El `driverName` está definido antes de los recursos?

---

## Resumen del Capítulo

En este capítulo aprendiste:

1. **Qué es EMIC-Codify** y sus dos funciones principales (comandos y etiquetas)
2. **La arquitectura del intérprete** y cómo mantiene el estado
3. **Sintaxis básica** de comandos y sustitución de macros
4. **Diferencias entre integrador y desarrollador** en el uso de Codify
5. **Sistema de volúmenes lógicos** para abstraer rutas
6. **Estructura de un archivo .emic** para APIs
7. **Tags básicos** (@fn, @alias, @brief, @param, @return)
8. **Ejemplo completo** de una API de botón
9. **Flujo de procesamiento** en Discovery y Generate
10. **Debugging** de errores comunes

---

## Próximo Capítulo

En el **Capítulo 17: Comandos de Gestión de Archivos y Recursos**, profundizaremos en:
- Comando `copy` con ejemplos avanzados
- Comando `setInput` para dependencias
- Comando `setOutput` y `restoreOutput`
- Gestión del stack de salidas
- Ejemplos reales del SDK

---

*Manual de Desarrollo EMIC SDK - Versión 2.0*
*Capítulo 16 de 38*
