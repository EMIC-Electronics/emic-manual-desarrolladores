# Capítulo 18: Sistema de Macros y Sustitución

## Tabla de Contenidos

1. [Introducción al Sistema de Macros](#1-introducción-al-sistema-de-macros)
2. [Comando define](#2-comando-define)
3. [Comando unDefine](#3-comando-undefine)
4. [Sustitución de Macros .{key}.](#4-sustitución-de-macros-key)
5. [Macros de 3 Niveles](#5-macros-de-3-niveles)
6. [Grupos de Macros](#6-grupos-de-macros)
7. [Expansión con Comodín](#7-expansión-con-comodín)
8. [Iteración con foreach/endforeach](#8-iteración-con-foreachendforeach)
9. [Macros para Configuración de APIs](#9-macros-para-configuración-de-apis)
10. [Macros en Compilación de Módulos](#10-macros-en-compilación-de-módulos)
11. [Caso Práctico: API Configurable con Macros](#11-caso-práctico-api-configurable-con-macros)
12. [Errores Comunes y Soluciones](#12-errores-comunes-y-soluciones)

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

## 3. Comando unDefine

El comando `unDefine` elimina una macro previamente definida.

### 3.1 Sintaxis

```
EMIC:unDefine(clave)
EMIC:unDefine(grupo.clave)
EMIC:unDefine(grupo.subgrupo.clave)
```

### 3.2 Comportamiento

| Formato | Acción |
|---------|--------|
| `unDefine(clave)` | Elimina de macros globales |
| `unDefine(grupo.clave)` | Elimina `clave` de la colección `grupo` |
| `unDefine(g1.g2.clave)` | Elimina `clave` de la colección de 3 niveles `g1.g2` |

Si la macro no existe, no produce error (se ignora silenciosamente).

### 3.3 Ejemplos

```c
// Definir y luego eliminar un flag temporal
EMIC:define(USE_DEBUG, true)
// ... código de debug ...
EMIC:unDefine(USE_DEBUG)
// USE_DEBUG ya no existe

// Eliminar de una colección
EMIC:define(c_modules.uart1, uart1)
EMIC:define(c_modules.timer1, timer1)
EMIC:unDefine(c_modules.uart1)
// Solo queda c_modules.timer1

// Eliminar de colección de 3 niveles
EMIC:define(hw.uart.parity, none)
EMIC:unDefine(hw.uart.parity)
```

### 3.4 Casos de Uso

1. **Cleanup de flags temporales** después de usarlos
2. **Remover módulos** de una colección de compilación
3. **Override condicional**: eliminar un valor antes de redefinirlo en otro contexto

---

## 4. Sustitución de Macros .{key}.

La sintaxis `.{key}.` permite sustituir valores en cualquier parte del texto procesado.

### 4.1 Sintaxis de Sustitución

| Sintaxis | Descripción | Ejemplo |
|----------|-------------|---------|
| `.{key}.` | Busca en local, luego global | `.{name}.` → `status` |
| `.{grupo.key}.` | Busca en grupo específico | `.{config.baud}.` → `9600` |
| `.{g1.g2.key}.` | Busca en 3 niveles | `.{hw.uart.baud}.` → `9600` |
| `.{grupo.*}.` | Expande todas las claves (N líneas) | `.{main_includes.*}.` |
| `.{grupo.*}. .[sep].` | Expande join (1 línea) | `.{canales.*}. .[, ].` |

### 4.2 Prioridad de Búsqueda

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

### 4.3 Ejemplos de Sustitución

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

### 4.4 Doble Punto en Nombres de Archivo

Observa que en los nombres de archivo se usa `.{name}..` (con doble punto):

```c
led_.{name}..c
      ↑    ↑
      │    └── Punto del nombre de archivo (.c)
      └── Punto de cierre de la sustitución
```

Esto es porque `.{name}.` se sustituye completamente, incluyendo el punto final. Si escribieras `led_.{name}.c`, obtendríás `led_statusc` (sin el punto).

---

## 5. Macros de 3 Niveles

Además de las colecciones estándar de 2 niveles (`grupo.clave`), EMIC-Codify soporta **colecciones de 3 niveles** para organización jerárquica compleja.

### 5.1 Sintaxis

```c
// 2 niveles: grupo.clave (1 punto)
EMIC:define(c_modules.uart1, uart1)

// 3 niveles: grupo.subgrupo.clave (2 puntos)
EMIC:define(hw.uart.baud, 9600)
EMIC:define(hw.uart.parity, none)
EMIC:define(hw.spi.clock, 1000000)
EMIC:define(hw.spi.mode, 0)
```

La distinción se hace automáticamente por la **cantidad de puntos** en el nombre:
- 1 punto → colección de 2 niveles
- 2 puntos → colección de 3 niveles

### 5.2 Acceso a Valores

```c
// Acceso directo
.{hw.uart.baud}.    // → 9600
.{hw.spi.clock}.    // → 1000000
```

### 5.3 Casos de Uso

```c
// Configuración de periféricos por grupo
EMIC:define(hw.uart.baud, 9600)
EMIC:define(hw.uart.parity, none)
EMIC:define(hw.uart.stopBits, 1)

EMIC:define(hw.spi.clock, 1000000)
EMIC:define(hw.spi.mode, 0)
EMIC:define(hw.spi.bits, 8)

// Usar en código
UART_Init(.{hw.uart.baud}., .{hw.uart.parity}.);
SPI_Init(.{hw.spi.clock}., .{hw.spi.mode}.);
```

### 5.4 Compatibilidad

Las macros de 3 niveles son completamente independientes de las de 2 niveles. Ambas conviven sin conflicto:

```c
// 2 niveles (colección de módulos)
EMIC:define(c_modules.uart1, uart1)

// 3 niveles (configuración de hardware)
EMIC:define(hw.uart.baud, 9600)

// No hay confusión: la cantidad de puntos determina el diccionario
```

---

## 6. Grupos de Macros

EMIC-Codify organiza las macros en **grupos** (también llamados diccionarios o colecciones).

### 6.1 Grupos Predefinidos

| Grupo | Origen | Acceso | Uso Típico |
|-------|--------|--------|------------|
| **local** | Parámetros de comandos | `.{key}.` o `.{local.key}.` | Parametrizar APIs |
| **global** | `EMIC:define(k,v)` | `.{key}.` o `.{global.key}.` | Constantes globales |
| **config** | Configurators JSON | `.{config.key}.` | Opciones del usuario |
| **system** | Sistema EMIC | `.{system.key}.` | Info del MCU, proyecto |

### 6.2 Grupo local: Parámetros de Comandos

Los parámetros pasados en `setInput` o `copy` se almacenan en el grupo **local**:

```c
EMIC:setInput(DEV:_api/LEDs/led.emic, name=status, pin=RB0)
//                                     ↑           ↑
//                                     Estas son macros locales

// Dentro de led.emic:
LED_.{name}._init();   // → LED_status_init();
GPIO_Set(.{pin}.);     // → GPIO_Set(RB0);
```

### 6.3 Grupo global: Macros Globales

Las macros definidas con `EMIC:define` se almacenan en **global** y están disponibles en todo el procesamiento:

```c
// En generate.emic
EMIC:define(PROJECT_VERSION, 2.0)

// En cualquier archivo procesado
const char* version = ".{PROJECT_VERSION}.";  // → "2.0"
```

### 6.4 Grupo config: Configurators JSON

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

### 6.5 Grupos Personalizados para Registros

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

## 7. Expansión con Comodín

Cuando una línea contiene `.{grupo.*}.`, se expande automáticamente generando **una línea por cada clave** de la colección.

### 7.1 Expansión Multilínea (N líneas)

```c
EMIC:define(canales.ch0, ADC_AN0)
EMIC:define(canales.ch1, ADC_AN1)
EMIC:define(canales.ch2, ADC_AN2)

uint16_t val = .{canales.*}.;
```

Resultado (3 líneas):
```c
uint16_t val = ADC_AN0;
uint16_t val = ADC_AN1;
uint16_t val = ADC_AN2;
```

### 7.2 Expansión Join (1 línea con separador)

Para generar **una sola línea** con todos los valores, agregar `.[separador].` después del comodín:

```c
enum { .{canales.*}. .[, ]. };
// → enum { ADC_AN0, ADC_AN1, ADC_AN2 };

int flags = .{opciones.*}. .[ | ]. ;
// → int flags = FLAG_A | FLAG_B | FLAG_C ;
```

**Regla:** Si `.{col.*}.` va seguido de `.[sep].`, genera una línea. Si no, genera N líneas.

### 7.3 Patrones con 3 Niveles

```c
EMIC:define(hw.uart.baud, 9600)
EMIC:define(hw.uart.parity, none)
EMIC:define(hw.spi.clock, 1000000)
EMIC:define(hw.spi.mode, 0)

// Comodín en el 3er nivel (propiedades de un periférico)
prop = .{hw.uart.*}.;
// → prop = 9600; y prop = none;

// Comodín en el 2do nivel (periféricos con cierta propiedad)
speed = .{hw.*.clock}.;
// → speed = 1000000; (solo spi tiene "clock")

// Doble comodín (todo, 2 pasadas)
val = .{hw.*.*}.;
// 1ra pasada: val = .{hw.uart.*}.; y val = .{hw.spi.*}.;
// 2da pasada: val = 9600; val = none; val = 1000000; val = 0;
```

### 7.4 Comparación

| Sintaxis | Resultado | Uso típico |
|----------|-----------|------------|
| `.{col.*}.` | N líneas separadas | Declaraciones, #include |
| `.{col.*}. .[sep].` | 1 línea con separador | Enums, listas de argumentos |

---

## 8. Iteración con foreach/endforeach

Para iterar un **bloque completo** de varias líneas por cada clave de una colección, usar `EMIC:foreach` / `EMIC:endforeach`.

### 8.1 Sintaxis

```
EMIC:foreach(colección.*)
    <bloque con .{*}. y {*}>
EMIC:endforeach
```

### 8.2 Variables del Iterador

| Variable | Descripción | Ejemplo con key "temp" |
|----------|-------------|----------------------|
| `.{*}.` | Nombre de la key (texto literal) | `temp` |
| `{*}` | Key dentro de expresiones macro | `.{sensores.{*}}.` → `.{sensores.temp}.` |

### 8.3 Ejemplo Básico

```c
EMIC:define(sensores.temp, ADC_CH0)
EMIC:define(sensores.hum, ADC_CH1)
EMIC:define(sensores.pres, ADC_CH2)

EMIC:foreach(sensores.*)
    uint16_t read_.{*}.(void) {
        return .{sensores.{*}}.;
    }
EMIC:endforeach
```

Genera:
```c
uint16_t read_temp(void) {
    return ADC_CH0;
}
uint16_t read_hum(void) {
    return ADC_CH1;
}
uint16_t read_pres(void) {
    return ADC_CH2;
}
```

### 8.4 Foreach con 3 Niveles

```c
EMIC:define(hw.uart.baud, 9600)
EMIC:define(hw.uart.parity, none)

EMIC:foreach(hw.uart.*)
    config_uart(.{*}., .{hw.uart.{*}}.);
EMIC:endforeach
```

Genera:
```c
config_uart(baud, 9600);
config_uart(parity, none);
```

### 8.5 Foreach con Directivas EMIC

El bloque puede contener directivas EMIC que serán ejecutadas para cada iteración:

```c
EMIC:define(modulos.uart, uart)
EMIC:define(modulos.spi, spi)

EMIC:foreach(modulos.*)
    EMIC:setInput(DEV:_hal/.{*}./.{*}..emic)
EMIC:endforeach
```

Equivale a:
```c
EMIC:setInput(DEV:_hal/uart/uart.emic)
EMIC:setInput(DEV:_hal/spi/spi.emic)
```

### 8.6 Foreach Anidado

Se pueden anidar foreach usando iteradores de nivel:

| Nivel | Variable literal | Variable en expresión |
|-------|-----------------|----------------------|
| Externo | `.{*}.` | `{*}` |
| Interno | `.{**}.` | `{**}` |
| Tercer nivel | `.{***}.` | `{***}` |

```c
EMIC:define(hw.uart.baud, 9600)
EMIC:define(hw.uart.parity, none)
EMIC:define(hw.spi.clock, 1000000)
EMIC:define(hw.spi.mode, 0)

EMIC:foreach(hw.*)
    // Periferico: .{*}.
    EMIC:foreach(hw.{*}.*)
        set_param(".{*}.", ".{**}.", .{hw.{*}.{**}}.);
    EMIC:endforeach
EMIC:endforeach
```

Genera (salida **intercalada** — cada grupo interno se emite inmediatamente después del externo):
```c
// Periferico: uart
set_param("uart", "baud", 9600);
set_param("uart", "parity", none);
// Periferico: spi
set_param("spi", "clock", 1000000);
set_param("spi", "mode", 0);
```

Al expandir el foreach externo, los iteradores internos se **demoten**: `{**}` pasa a ser `{*}` y `{***}` pasa a ser `{**}` para el foreach hijo.

### 8.7 Semántica de .{*}. dentro del foreach

El iterador `.{*}.` tiene doble semántica dependiendo del **contexto** donde aparece:

| Contexto | Ejemplo | Resultado | Comportamiento |
|----------|---------|-----------|----------------|
| **Standalone** (valor) | `key=.{*}.` | `key=uart` | Consume los puntos delimitadores |
| **Path** (dentro de ruta) | `hw.{*}.*` | `hw.uart.*` | Mantiene los puntos estructurales |

**Regla de detección:** Se considera "path" cuando `.{*}.` está rodeado por caracteres alfanuméricos, `*` o `{` en **ambos lados**. Si alguno de los lados tiene un carácter no-path (espacio, `,`, `)`, fin de línea), se trata como standalone.

Ejemplos:

```c
// Standalone: el punto antes y después son delimitadores de .{*}.
EMIC:define(test_iter_.{*}., procesado)     // → EMIC:define(test_iter_uart, procesado)
TEST_FOREACH: key=.{*}. value=.{col.{*}}.  // → TEST_FOREACH: key=uart value=...

// Path: los puntos son separadores estructurales de la ruta
EMIC:foreach(hw.{*}.*)                      // → EMIC:foreach(hw.uart.*)
EMIC:ifdef hw.{*}.baud                      // → EMIC:ifdef hw.uart.baud
```

> **Nota:** Para evitar ambigüedades, dentro de expresiones macro como `.{col.{*}.prop}.` se recomienda usar `{*}` (sin puntos) que siempre se reemplaza como texto inline.

### 8.8 Errores Comunes

```c
// Error: foreach sin endforeach
EMIC:foreach(sensores.*)
    // código
// Falta EMIC:endforeach → Error al llegar a fin de archivo

// Error: Patrón sin comodín
EMIC:foreach(sensores)  // Error: requiere .* en el patrón

// Error: endforeach sin foreach
EMIC:endforeach  // Error: no hay foreach abierto
```

### 8.9 ¿Cuándo Usar Cada Forma?

| Necesidad | Mecanismo | Ejemplo |
|-----------|-----------|---------|
| Una línea por key | `.{col.*}.` inline | `val = .{canales.*}.;` |
| Una sola línea con todos | `.{col.*}. .[sep].` join | `enum { .{canales.*}. .[, ]. };` |
| Bloque multilínea por key | `EMIC:foreach` | Funciones, includes, bloques C |
| Iteración anidada | `foreach` + `{**}` | Recorrer 2 dimensiones |

---

## 9. Macros para Configuración de APIs

Las macros permiten crear APIs flexibles que se adaptan a diferentes hardware y configuraciones.

### 9.1 Patrón de API Parametrizada

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

### 9.2 Uso desde generate.emic

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

### 9.3 Ejemplo Real: Timer API

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

## 10. Macros en Compilación de Módulos

Un uso crítico de las macros es gestionar qué archivos se incluyen en el proyecto compilable.

### 10.1 Grupos de Compilación

| Grupo | Propósito | Cómo se usa |
|-------|-----------|-------------|
| `main_includes.*` | Headers a incluir en main.c | `#include "led_.{key}..h"` |
| `c_modules.*` | Archivos .c a compilar | Agregados al proyecto MPLAB |

### 10.2 Flujo de Registro y Uso

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

### 10.3 Ejemplo: generate.emic Completo

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

## 11. Caso Práctico: API Configurable con Macros

Vamos a crear una API de comunicación RS232 que demuestra el uso avanzado de macros.

### 11.1 Requisitos

- Soportar diferentes protocolos (EMIC Message, TEXT Line)
- Configurar puerto UART, baudrate, buffer
- Permitir múltiples instancias

### 11.2 Implementación: rs232.emic

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

### 11.3 Uso en generate.emic

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

### 11.4 Resultado

Dependiendo de la selección del usuario en el Configurator:

**Si selecciona "EMIC Message":**
- Se publican: `Send_EMIC(tag, msg)` y `Reception_EMIC` event

**Si selecciona "TEXT Line":**
- Se publican: `Send_TEXT(msg)` y `Reception_TEXT` event

---

## 12. Errores Comunes y Soluciones

### 12.1 Macro No Encontrada

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

### 12.2 Nombre de Archivo Incorrecto

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

### 12.3 Módulo No Compilado

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

### 12.4 Sustitución en Grupo Incorrecto

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

### 12.5 Tabla de Referencia Rápida

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
2. **Definir y eliminar macros** - `EMIC:define(k, v)` y `EMIC:unDefine(k)` para gestión dinámica
3. **Organizar en 2 y 3 niveles** - `grupo.clave` y `grupo.subgrupo.clave`
4. **Registrar módulos** - Grupos `main_includes.*` y `c_modules.*`
5. **Configurar desde UI** - Grupo `config.*` para valores de Configurators
6. **Expandir colecciones inline** - `.{col.*}.` (N líneas) y `.{col.*}. .[sep].` (join)
7. **Iterar bloques completos** - `EMIC:foreach`/`EMIC:endforeach` con anidamiento
8. **Crear instancias múltiples** - Mismo código, diferentes parámetros

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
