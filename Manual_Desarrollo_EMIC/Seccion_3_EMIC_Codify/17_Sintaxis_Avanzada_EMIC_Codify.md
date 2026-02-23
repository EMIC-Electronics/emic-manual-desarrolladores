# Capítulo 17: Sintaxis Avanzada de EMIC-Codify

## Índice
1. [Introducción](#introducción)
2. [Variables Avanzadas](#variables-avanzadas)
3. [Ámbito de Variables (Scope)](#ámbito-de-variables-scope)
4. [Sustituciones Complejas](#sustituciones-complejas)
5. [Directivas Avanzadas](#directivas-avanzadas)
6. [Iteración y Expansión de Colecciones](#iteración-y-expansión-de-colecciones)
7. [Patrones de Multi-Instanciación](#patrones-de-multi-instanciación)
8. [Include Guards y Prevención de Duplicados](#include-guards-y-prevención-de-duplicados)
9. [Composición de Componentes](#composición-de-componentes)
10. [Herencia de Variables](#herencia-de-variables)
11. [Debugging y Troubleshooting](#debugging-y-troubleshooting)
12. [Casos Prácticos Avanzados](#casos-prácticos-avanzados)
13. [Buenas Prácticas Avanzadas](#buenas-prácticas-avanzadas)
14. [Resumen del Capítulo](#resumen-del-capítulo)

---

## Introducción

Este capítulo profundiza en las características avanzadas de **EMIC-Codify**, incluyendo patrones complejos de uso, técnicas de optimización, y casos prácticos que demuestran el poder del lenguaje para crear componentes altamente reutilizables y configurables.

Asumimos que ya tienes conocimientos básicos de EMIC-Codify del Capítulo 16. Aquí exploraremos:
- Variables anidadas, de sistema y colecciones de 3 niveles
- Ámbito (scope) y propagación de variables
- Iteración y expansión de colecciones (wildcards, foreach, join)
- Patrones avanzados de multi-instanciación
- Técnicas de debugging
- Casos de uso del mundo real

---

## Variables Avanzadas

### Variables de Sistema

Las **variables de sistema** son definidas por EMIC-Generate o por archivos de configuración (como `pcb.emic`) y están disponibles globalmente en todos los archivos .emic procesados.

#### Variables de Sistema Principales

```emic
.{system.ucName}.        // Nombre del microcontrolador
.{system.clockFreq}.     // Frecuencia del reloj del sistema
.{system.compiler}.      // Compilador (XC8, XC16, XC32)
.{system.arch}.          // Arquitectura (PIC16, PIC24, PIC32)
.{system.voltage}.       // Voltaje de operación
```

#### Ejemplo de Uso

**Archivo: `_hal/SPI/spi.emic`**
```emic
// Delegar al archivo específico del microcontrolador
EMIC:setInput(
    DEV:_hard/.{system.ucName}./SPI/spi.emic,
    configuracion=.{configuracion}.,
    port=.{port}.,
    pin=.{pin}.
)
```

**Procesamiento:**
- Si `system.ucName = pic24FJ64GA002`
- Se expande a: `DEV:_hard/pic24FJ64GA002/SPI/spi.emic`

**Ventaja:** El mismo código funciona para cualquier microcontrolador, la variable de sistema se encarga de la selección.

---

### Variables Anidadas

EMIC-Codify soporta **variables que contienen otras variables**:

```emic
// Definir variables base
EMIC:define(prefix, uart_)
EMIC:define(instance, 1)
EMIC:define(suffix, _driver)

// Variable compuesta
EMIC:define(module_name, .{prefix}..{instance}..{suffix}.)

// Uso: .{module_name}. → uart_1_driver
```

#### Ejemplo Real: Nombre de Módulos Dinámicos

**Archivo: `I2C_driver.emic`**
```emic
EMIC:ifndef I2C_DRIVER_EMIC_
EMIC:define(I2C_DRIVER_EMIC_,true)

// Variable anidada: puerto como parte del nombre
EMIC:define(I2C.{port}._CALLBACK_MASTER,true)
EMIC:define(I2C.{port}._CALLBACK_SLAVE,true)

// Si port=1: I2C1_CALLBACK_MASTER
// Si port=2: I2C2_CALLBACK_MASTER

EMIC:setInput(DEV:_hal/I2C/I2C.emic,port=.{port}.,client=I2c_driver,interrupt=1)

EMIC:copy(inc/I2C_driver.h > TARGET:inc/I2C.{port}._driver.h,port=.{port}.)
EMIC:copy(src/I2C_driver.c > TARGET:I2C.{port}._driver.c,port=.{port}.)

EMIC:define(c_modules.I2C.{port}._driver,I2C.{port}._driver)
EMIC:endif
```

**Ventaja:** Permite crear nombres únicos para cada instancia automáticamente.

---

### Variables con Puntos (Namespacing)

Las variables pueden contener puntos para crear **namespaces lógicos**. EMIC-Codify soporta dos niveles de organización:

#### Colecciones de 2 niveles (`colección.clave`)

```emic
// Namespace de sistema
EMIC:define(system.ucName, pic24FJ64GA002)
EMIC:define(system.clockFreq, 32000000)

// Namespace de módulos
EMIC:define(c_modules.uart1, uart1)
EMIC:define(c_modules.timer1, timer1)
EMIC:define(main_includes.uart1, uart1)
```

#### Colecciones de 3 niveles (`grupo.subgrupo.clave`)

Para organización más compleja, se pueden usar **3 niveles de profundidad**:

```emic
// Hardware → periférico → propiedad
EMIC:define(hw.uart.baud, 9600)
EMIC:define(hw.uart.parity, none)
EMIC:define(hw.spi.clock, 1000000)
EMIC:define(hw.spi.mode, 0)

// Uso: .{hw.uart.baud}. → 9600
// Uso: .{hw.spi.clock}. → 1000000
```

La distinción entre 2 y 3 niveles se determina automáticamente por la **cantidad de puntos** en el nombre:
- `col.key` (1 punto) → colección de 2 niveles
- `col1.col2.key` (2 puntos) → colección de 3 niveles

**Ventaja:** Organización jerárquica clara y prevención de colisiones de nombres.

---

### Variables Locales vs Alias

Cuando se pasan parámetros en `EMIC:setInput`, hay dos formas de referenciarlos:

```emic
// Llamada con parámetros
EMIC:setInput(DEV:_api/led.emic, name=led1, pin=A0_Pin)

// Dentro de led.emic:

// Forma 1: Referencia directa
void init_.{name}.() {  // .{name}. → led1
    HAL_GPIO_PinCfg(.{pin}., OUTPUT);  // .{pin}. → A0_Pin
}

// Forma 2: Alias explícito con "local."
void init_.{local.name}.() {  // .{local.name}. → led1
    HAL_GPIO_PinCfg(.{local.pin}., OUTPUT);
}
```

**Diferencia:**
- `.{name}.` - Variable estándar (puede ser global o local)
- `.{local.name}.` - Alias explícito para parámetro local (mayor claridad)

---

## Ámbito de Variables (Scope)

### Reglas de Ámbito

1. **Variables Globales**: Definidas con `EMIC:define` en el nivel principal
   - Disponibles en todos los archivos procesados después
   - Permanecen durante toda la ejecución de EMIC-Generate

2. **Variables Locales**: Parámetros pasados en `EMIC:setInput`
   - Solo disponibles dentro del archivo incluido
   - NO se propagan a inclusiones anidadas (a menos que se pasen explícitamente)

3. **Precedencia**: Variables locales sobrescriben globales del mismo nombre

---

### Ejemplo de Propagación de Variables

**Archivo: `generate.emic`**
```emic
// Variable global
EMIC:define(system.ucName, pic24FJ64GA002)

// Incluir API con parámetro local
EMIC:setInput(DEV:_api/led.emic, name=led1, pin=A0_Pin)
```

**Archivo: `_api/led.emic`**
```emic
// .{name}. = led1 (local, pasado desde generate.emic)
// .{pin}. = A0_Pin (local, pasado desde generate.emic)
// .{system.ucName}. = pic24FJ64GA002 (global, siempre disponible)

// Incluir HAL GPIO (sin pasar parámetros)
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
```

**Archivo: `_hal/GPIO/gpio.emic`**
```emic
// .{name}. = NO DISPONIBLE (no se propagó)
// .{pin}. = NO DISPONIBLE (no se propagó)
// .{system.ucName}. = pic24FJ64GA002 (global, disponible)

// Debe usar system.ucName para delegar a _hard
EMIC:setInput(DEV:_hard/.{system.ucName}./GPIO/gpio.emic)
```

**Lección:** Las variables locales NO se propagan automáticamente. Solo las variables globales (definidas con `EMIC:define`) están siempre disponibles.

---

### Propagación Explícita de Variables

Para propagar variables locales a inclusiones anidadas, deben pasarse explícitamente:

```emic
// En led.emic, pasar variables locales al siguiente nivel
EMIC:setInput(
    DEV:_hal/GPIO/gpio.emic,
    name=.{name}.,      // Propagar variable local
    pin=.{pin}.         // Propagar variable local
)
```

---

### Ejemplo Completo de Scope

**Nivel 1: `generate.emic`**
```emic
EMIC:define(system.ucName, pic24FJ64GA002)  // Global
EMIC:setInput(DEV:_api/led.emic, name=led1, pin=A0)  // name, pin: Locales
```

**Nivel 2: `_api/led.emic`**
```emic
// Variables disponibles:
// - .{system.ucName}. (global)
// - .{name}. (local)
// - .{pin}. (local)

EMIC:define(led_category, Indicators)  // Global (desde aquí en adelante)

// Propagar pin al siguiente nivel
EMIC:setInput(DEV:_hal/GPIO/gpio.emic, pin=.{pin}.)
```

**Nivel 3: `_hal/GPIO/gpio.emic`**
```emic
// Variables disponibles:
// - .{system.ucName}. (global)
// - .{led_category}. (global, definida en nivel 2)
// - .{pin}. (local, propagada explícitamente)
// - .{name}. NO DISPONIBLE (no propagada)

EMIC:setInput(DEV:_hard/.{system.ucName}./GPIO/gpio.emic, pin=.{pin}.)
```

---

## Sustituciones Complejas

### Sustitución en Nombres de Archivo

Las variables pueden usarse tanto en el **contenido** como en el **nombre** de los archivos:

```emic
// Variable: name=uart1

EMIC:copy(
    src/uart.c > TARGET:uart_.{name}..c,
    name=.{name}.,
    baud=.{baud}.
)

// Resultado:
// - Archivo destino: TARGET:uart_uart1.c
// - Contenido: sustituye .{name}. y .{baud}.
```

---

### Múltiples Sustituciones en Una Línea

```emic
// Variables: port=1, client=I2c_driver, interrupt=1

EMIC:copy(
    src/driver.c > TARGET:I2C.{port}._driver.c,
    port=.{port}.,
    client=.{client}.,
    interrupt=.{interrupt}.
)

// Archivo destino: I2C1_driver.c
// Contenido: sustituye las 3 variables
```

---

### Sustitución en Paths Completos

```emic
// Variables: system.ucName=pic24FJ64GA002, peripheral=SPI

EMIC:setInput(
    DEV:_hard/.{system.ucName}./.{peripheral}./spi.emic
)

// Expande a: DEV:_hard/pic24FJ64GA002/SPI/spi.emic
```

---

### Concatenación de Variables

```emic
// Variables: prefix=timer_, num=1, suffix=_api

EMIC:copy(
    inc/timer.h > TARGET:inc/.{prefix}..{num}..{suffix}..h
)

// Resultado: TARGET:inc/timer_1_api.h
```

---

### Sustitución Condicional

Combinar condicionales con sustituciones:

```emic
EMIC:ifdef USE_INTERRUPTS
    EMIC:define(uart_mode, interrupt)
EMIC:endif

EMIC:ifndef USE_INTERRUPTS
    EMIC:define(uart_mode, polling)
EMIC:endif

EMIC:copy(
    src/uart_.{uart_mode}..c > TARGET:uart.c
)

// Resultado:
// - Si USE_INTERRUPTS definida: copia uart_interrupt.c
// - Si no: copia uart_polling.c
```

---

## Directivas Avanzadas

### `EMIC:setInput` Recursivo

Los archivos .emic pueden incluir otros archivos .emic de forma recursiva:

```
generate.emic
    ↓
    include led.emic
        ↓
        include gpio.emic
            ↓
            include gpio_pic24.emic
```

**Ejemplo del SDK:**

**`generate.emic`:**
```emic
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=led1, pin=A0)
```

**`led.emic`:**
```emic
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)
```

**`gpio.emic`:**
```emic
EMIC:setInput(DEV:_hard/.{system.ucName}./GPIO/gpio.emic)
```

**Profundidad:** No hay límite técnico, pero se recomienda máximo 5 niveles para mantener legibilidad.

---

### `EMIC:setOutput` Múltiple

Generar múltiples archivos desde un solo .emic:

```emic
// Generar header
EMIC:setOutput(TARGET:inc/my_module.h)
    #ifndef MY_MODULE_H
    #define MY_MODULE_H

    void my_function(void);

    #endif
EMIC:restoreOutput

// Generar source
EMIC:setOutput(TARGET:src/my_module.c)
    #include "my_module.h"

    void my_function(void) {
        // implementation
    }
EMIC:restoreOutput
```

**Ejemplo real del SDK:**

**`systemTimer.emic`:**
```emic
EMIC:ifndef _DIVER_SYSTEM_TIMER_EMIC_
EMIC:define(_DIVER_SYSTEM_TIMER_EMIC_,true)

EMIC:setInput(DEV:_hal/Timer/timer.emic)

// Generar header
EMIC:setOutput(TARGET:inc/systemTimer.h)
    EMIC:setInput(inc/systemTimer.h)
EMIC:restoreOutput

// Generar source
EMIC:setOutput(TARGET:systemTimer.c)
    EMIC:setInput(src/systemTimer.c)
EMIC:restoreOutput

EMIC:define(main_includes.systemTimer,systemTimer)
EMIC:define(c_modules.systemTimer,systemTimer)

EMIC:endif
```

---

### `EMIC:copy` con Directorios

Copiar directorios completos:

```emic
// Copiar todo el directorio de templates MPLAB X
EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

// Resultado: Copia toda la estructura de carpetas
// TARGET:
//   ├── Makefile
//   ├── nbproject/
//   │   ├── configurations.xml
//   │   └── project.xml
//   └── ...
```

---

### Condicionales Anidados

```emic
EMIC:ifdef ENABLE_COMMUNICATION

    EMIC:ifdef USE_UART
        EMIC:setInput(DEV:_hal/UART/uart.emic)
    EMIC:endif

    EMIC:ifdef USE_SPI
        EMIC:setInput(DEV:_hal/SPI/spi.emic)
    EMIC:endif

    EMIC:ifdef USE_I2C
        EMIC:setInput(DEV:_hal/I2C/i2c.emic)
    EMIC:endif

EMIC:endif
```

---

## Iteración y Expansión de Colecciones

Cuando se trabaja con colecciones de variables (definidas con namespacing), EMIC-Codify ofrece mecanismos para iterar sobre ellas y generar código automáticamente.

### Expansión Inline con Comodín

La forma más simple de iterar es usando el **comodín `*`** directamente en una referencia a macro:

```emic
EMIC:define(canales.ch0, ADC_AN0)
EMIC:define(canales.ch1, ADC_AN1)
EMIC:define(canales.ch2, ADC_AN2)

// Una línea con comodín genera N líneas (una por key)
uint16_t val = .{canales.*}.;
```

Resultado:
```c
uint16_t val = ADC_AN0;
uint16_t val = ADC_AN1;
uint16_t val = ADC_AN2;
```

#### Patrones de comodín con 3 niveles

```emic
EMIC:define(hw.uart.baud, 9600)
EMIC:define(hw.uart.parity, none)
EMIC:define(hw.spi.clock, 1000000)
EMIC:define(hw.spi.mode, 0)

// Comodín en el 3er nivel: expande propiedades de un periférico
cfg = .{hw.uart.*}.;
// → cfg = 9600; y cfg = none;

// Comodín en el 2do nivel: expande periféricos con una propiedad
init(.{hw.*.mode}.);
// → init(0); (solo spi tiene "mode")

// Doble comodín: expande todo (2 pasadas)
val = .{hw.*.*}.;
// 1ra pasada: val = .{hw.uart.*}.; y val = .{hw.spi.*}.;
// 2da pasada: val = 9600; val = none; val = 1000000; val = 0;
```

---

### Expansión con Separador (Join)

Para generar **una sola línea** con todos los valores separados, se agrega `.[separador].` después del comodín:

```emic
EMIC:define(canales.ch0, ADC_AN0)
EMIC:define(canales.ch1, ADC_AN1)
EMIC:define(canales.ch2, ADC_AN2)

// Join con coma
enum { .{canales.*}. .[, ]. };
// → enum { ADC_AN0, ADC_AN1, ADC_AN2 };

// Join con pipe
int flags = .{opciones.*}. .[ | ]. ;
// → int flags = FLAG_A | FLAG_B | FLAG_C ;
```

**Regla:** Si `.{col.*}.` va seguido de `.[sep].`, genera una línea. Si no, genera N líneas.

---

### Foreach Multilínea

Para iterar un **bloque completo** de varias líneas, se usa `EMIC:foreach` / `EMIC:endforeach`:

```emic
EMIC:define(sensores.temp, ADC_CH0)
EMIC:define(sensores.hum, ADC_CH1)

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
```

**Variables del iterador:**
- `.{*}.` — nombre de la key actual (como texto literal)
- `{*}` — nombre de la key dentro de una expresión macro (ej: `.{sensores.{*}}.`)

---

### Foreach con 3 Niveles

```emic
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

---

### Foreach Anidado

Para iterar colecciones de 3 niveles en ambas dimensiones, se anidan foreach con iteradores de nivel:

| Nivel | Variable literal | Variable en expresión |
|-------|-----------------|----------------------|
| Externo | `.{*}.` | `{*}` |
| Interno | `.{**}.` | `{**}` |
| Tercer nivel | `.{***}.` | `{***}` |

```emic
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

Genera:
```c
// Periferico: uart
set_param("uart", "baud", 9600);
set_param("uart", "parity", none);
// Periferico: spi
set_param("spi", "clock", 1000000);
set_param("spi", "mode", 0);
```

Al expandir el foreach externo, los iteradores internos se "promueven": `{**}` pasa a ser `{*}` para el foreach hijo.

---

### Comparación: ¿Cuándo Usar Cada Forma?

| Necesidad | Mecanismo | Ejemplo |
|-----------|-----------|---------|
| Una línea por key | `.{col.*}.` inline | `val = .{canales.*}.;` |
| Una sola línea con todos | `.{col.*}. .[sep].` join | `enum { .{canales.*}. .[, ]. };` |
| Bloque multilínea por key | `EMIC:foreach` | Funciones, includes, bloques C |
| Iteración anidada | `foreach` + `{**}` | Recorrer 2 dimensiones |

---

## Patrones de Multi-Instanciación

La multi-instanciación es una de las características más poderosas de EMIC-Codify: **crear múltiples instancias independientes de un mismo componente**.

### Patrón Básico

```emic
// En generate.emic
EMIC:setInput(DEV:_api/led.emic, name=led1, pin=A0)
EMIC:setInput(DEV:_api/led.emic, name=led2, pin=A1)
EMIC:setInput(DEV:_api/led.emic, name=led3, pin=A2)
```

**Resultado:**
- `TARGET:led_led1.c`, `TARGET:led_led2.c`, `TARGET:led_led3.c`
- Tres instancias completamente independientes
- Cada una con su propio nombre de función y pin

---

### Ejemplo Real: Múltiples Timers

**Archivo: `generate.emic`**
```emic
// Instanciar 3 timers
EMIC:setInput(DEV:_api/Timers/timer_api.emic, name=1)
EMIC:setInput(DEV:_api/Timers/timer_api.emic, name=2)
EMIC:setInput(DEV:_api/Timers/timer_api.emic, name=3)
```

**Archivo: `timer_api.emic`**
```emic
EMIC:tag(driverName = TIMER)

/**
* @fn void setTime.{name}.(uint16_t time,char mode);
* @alias setTime.{name}.
*/

EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

EMIC:copy(inc/timer_api.h > TARGET:inc/timer_api.{name}..h, name=.{name}.)
EMIC:copy(src/timer_api.c > TARGET:timer_api.{name}..c, name=.{name}.)

EMIC:define(main_includes.timer_api.{name}., timer_api.{name}.)
EMIC:define(c_modules.timer_api.{name}., timer_api.{name}.)
```

**Código C Generado:**

**`timer_api1.c`:**
```c
void setTime1(uint16_t time, char mode) {
    // implementación para timer 1
}

void etOut1(void) {
    // timeout para timer 1
}
```

**`timer_api2.c`:**
```c
void setTime2(uint16_t time, char mode) {
    // implementación para timer 2
}

void etOut2(void) {
    // timeout para timer 2
}
```

---

### Patrón: Multi-Instanciación con Configuración Diferente

```emic
// UART1: Alta velocidad, buffer grande
EMIC:setInput(
    DEV:_api/UART/uart.emic,
    name=uart1,
    port=1,
    baud=115200,
    buffer=1024
)

// UART2: Baja velocidad, buffer pequeño
EMIC:setInput(
    DEV:_api/UART/uart.emic,
    name=uart2,
    port=2,
    baud=9600,
    buffer=128
)
```

---

### Multi-Instanciación de Drivers de Hardware

**Ejemplo: Múltiples I2C**

```emic
// I2C1 para sensor de temperatura
EMIC:setInput(
    DEV:_drivers/I2C/I2C_driver.emic,
    port=1,
    frameID=0x48
)

// I2C2 para pantalla OLED
EMIC:setInput(
    DEV:_drivers/I2C/I2C_driver.emic,
    port=2,
    frameID=0x3C
)
```

**Resultado:**
- Dos drivers I2C independientes
- `I2C1_driver.c` y `I2C2_driver.c`
- Cada uno con su propio callback y configuración

---

## Include Guards y Prevención de Duplicados

### Problema: Inclusiones Duplicadas

Cuando múltiples componentes dependen del mismo driver, puede ocurrir inclusión duplicada:

```emic
// led1 incluye GPIO
EMIC:setInput(DEV:_api/led.emic, name=led1, pin=A0)
    → include GPIO

// led2 también incluye GPIO
EMIC:setInput(DEV:_api/led.emic, name=led2, pin=A1)
    → include GPIO  // ❌ DUPLICADO
```

---

### Solución: Include Guards

Usar `EMIC:ifndef` / `EMIC:define` / `EMIC:endif`:

```emic
EMIC:ifndef GPIO_DRIVER_INCLUDED
EMIC:define(GPIO_DRIVER_INCLUDED, true)

    // Código del driver GPIO
    EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
    EMIC:copy(src/gpio.c > TARGET:gpio.c)

EMIC:endif
```

**Primera vez que se procesa:**
- `GPIO_DRIVER_INCLUDED` no está definida
- Se ejecuta el bloque
- Se define `GPIO_DRIVER_INCLUDED`

**Segunda vez que se procesa:**
- `GPIO_DRIVER_INCLUDED` ya está definida
- Se salta el bloque (no se duplica)

---

### Ejemplo Real del SDK

**`I2C_driver.emic`:**
```emic
EMIC:ifndef I2C_DRIVER_EMIC_
EMIC:define(I2C_DRIVER_EMIC_,true)

    EMIC:define(I2C.{port}._CALLBACK_MASTER,true)
    EMIC:define(I2C.{port}._CALLBACK_SLAVE,true)
    EMIC:setInput(DEV:_hal/I2C/I2C.emic,port=.{port}.,client=I2c_driver,interrupt=1)

    EMIC:copy(inc/I2C_driver.h > TARGET:inc/I2C.{port}._driver.h,port=.{port}.)
    EMIC:copy(src/I2C_driver.c > TARGET:I2C.{port}._driver.c,port=.{port}.)

    EMIC:define(c_modules.I2C.{port}._driver,I2C.{port}._driver)

EMIC:endif
```

**SystemTimer.emic:**
```emic
EMIC:ifndef _DIVER_SYSTEM_TIMER_EMIC_
EMIC:define(_DIVER_SYSTEM_TIMER_EMIC_,true)

    EMIC:setInput(DEV:_hal/Timer/timer.emic)

    EMIC:setOutput(TARGET:inc/systemTimer.h)
        EMIC:setInput(inc/systemTimer.h)
    EMIC:restoreOutput

    EMIC:setOutput(TARGET:systemTimer.c)
        EMIC:setInput(src/systemTimer.c)
    EMIC:restoreOutput

    EMIC:define(main_includes.systemTimer,systemTimer)
    EMIC:define(c_modules.systemTimer,systemTimer)

EMIC:endif
```

---

### Convención de Nombres para Guards

```emic
// Formato: _NOMBRE_DEL_ARCHIVO_EMIC_

EMIC:ifndef _UART_DRIVER_EMIC_
EMIC:define(_UART_DRIVER_EMIC_,true)
    // contenido
EMIC:endif

EMIC:ifndef _SPI_HAL_EMIC_
EMIC:define(_SPI_HAL_EMIC_,true)
    // contenido
EMIC:endif
```

---

## Composición de Componentes

La **composición** es cuando un componente incluye otros componentes como dependencias.

### Ejemplo: LED Depende de GPIO y Timer

**`led.emic`:**
```emic
EMIC:tag(driverName = LEDs)

// Dependencias
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

// Código del LED
EMIC:copy(inc/led.h > TARGET:inc/led_.{name}..h, name=.{name}., pin=.{pin}.)
EMIC:copy(src/led.c > TARGET:led_.{name}..c, name=.{name}., pin=.{pin}.)

EMIC:define(main_includes.led_.{name}., led_.{name}.)
EMIC:define(c_modules.led_.{name}., led_.{name}.)
```

**Jeraquía resultante:**
```
led.emic
    ├── gpio.emic
    │   └── gpio_pic24.emic (según system.ucName)
    └── systemTimer.emic
        └── timer.emic
```

---

### Composición Compleja: API que usa Driver que usa HAL

**`USB_API.emic` (nivel API):**
```emic
// Incluir driver MCP2200
EMIC:setInput(
    DEV:_drivers/USB/MCP2200/MCP2200.emic,
    port=.{port}.,
    baud=.{baud}.
)

// Código de la API
EMIC:copy(src/usb_api.c > TARGET:usb_api.c)
```

**`MCP2200.emic` (nivel Driver):**
```emic
// Incluir HAL UART
EMIC:setInput(
    DEV:_hal/UART/uart.emic,
    port=.{port}.,
    baud=.{baud}.
)

// Código del driver
EMIC:copy(src/mcp2200.c > TARGET:mcp2200.c)
```

**`uart.emic` (nivel HAL):**
```emic
// Delegar a _hard según microcontrolador
EMIC:setInput(
    DEV:_hard/.{system.ucName}./UART/uart.emic,
    port=.{port}.,
    baud=.{baud}.
)
```

**Jerarquía completa:**
```
USB_API.emic
    └── MCP2200.emic
        └── uart.emic (HAL)
            └── uart_pic24.emic (_hard)
```

---

## Herencia de Variables

### Patrón: Variables Calculadas

Usar variables existentes para calcular nuevas:

```emic
// Variables base
EMIC:define(system.clockFreq, 32000000)
EMIC:define(timer_prescaler, 256)

// Variable calculada (conceptualmente)
EMIC:define(timer_tick_us, 8)  // = (256 / 32000000) * 1000000

// Nota: EMIC-Codify NO calcula, hay que hacer el cálculo manualmente
// y poner el resultado
```

---

### Patrón: Extender Configuración

```emic
// Configuración base del PCB
EMIC:setInput(DEV:_pcb/pcb.emic, pcb=HRD_Development_Board)
// Esto define: system.ucName, pines, etc.

// Extender con configuración específica del proyecto
EMIC:define(project.name, MyProject)
EMIC:define(project.version, 1.0.0)
EMIC:define(project.led_count, 3)

// Usar ambas configuraciones
EMIC:setInput(
    DEV:_api/led.emic,
    name=led_status,
    pin=.{board.led1}.  // Pin definido por pcb.emic
)
```

---

## Debugging y Troubleshooting

### Errores Comunes

#### 1. Variable No Definida

**Síntoma:**
```
Error: Variable '.{name}.' not defined in file led.emic:15
```

**Causa:** La variable no fue pasada como parámetro ni definida globalmente.

**Solución:**
```emic
// Asegurar que el parámetro se pasa
EMIC:setInput(DEV:_api/led.emic, name=led1, pin=A0)  // ✅

// O definirla globalmente
EMIC:define(name, led1)  // ✅
```

---

#### 2. Archivo No Encontrado

**Síntoma:**
```
Error: File 'DEV:_api/led.emic' not found
```

**Causa:** Ruta incorrecta o volumen incorrecto.

**Solución:**
```emic
// ❌ MALO: Ruta absoluta
EMIC:setInput(C:/SDK/_api/led.emic)

// ✅ BUENO: Volumen lógico
EMIC:setInput(DEV:_api/led.emic)
```

---

#### 3. Inclusión Circular

**Síntoma:**
```
Error: Circular inclusion detected: led.emic → gpio.emic → led.emic
```

**Causa:** Archivo A incluye B, y B incluye A.

**Solución:** Usar include guards o restructurar dependencias.

```emic
// En ambos archivos
EMIC:ifndef MY_COMPONENT_EMIC_
EMIC:define(MY_COMPONENT_EMIC_,true)
    // contenido
EMIC:endif
```

---

#### 4. Sustitución Incorrecta

**Síntoma:** Variable no se sustituye, aparece literal en código C.

**Ejemplo:**
```c
// Código C generado (MAL)
void init_.{name}.() {  // ❌ Variable no sustituida
    // ...
}
```

**Causa:** Variable no definida o sintaxis incorrecta.

**Solución:**
```emic
// Verificar sintaxis correcta
void init_.{name}.() {  // Correcto

// ❌ ERRORES comunes:
void init_{name}() {     // Falta punto después de }
void init_.name.() {     // Faltan llaves
void init_.{ name }.() { // Espacio dentro de llaves (depende de implementación)
```

---

### Técnicas de Debugging

#### 1. Logging con `EMIC:setOutput`

Generar un archivo de log con valores de variables:

```emic
EMIC:setOutput(TARGET:debug_log.txt)
    Variable name: .{name}.
    Variable pin: .{pin}.
    Variable ucName: .{system.ucName}.
EMIC:restoreOutput
```

**Resultado en `debug_log.txt`:**
```
Variable name: led1
Variable pin: A0_Pin
Variable ucName: pic24FJ64GA002
```

---

#### 2. Verificar Expansión de Variables

Usar comentarios con variables:

```emic
EMIC:setOutput(TARGET:test.c)
    // DEBUG: name=.{name}., pin=.{pin}.
    void init_.{name}.() {
        HAL_GPIO_PinCfg(.{pin}., OUTPUT);
    }
EMIC:restoreOutput
```

**Código C generado:**
```c
// DEBUG: name=led1, pin=A0_Pin
void init_led1() {
    HAL_GPIO_PinCfg(A0_Pin, OUTPUT);
}
```

---

#### 3. Verificar Inclusiones

Agregar comentarios de trace:

```emic
EMIC:setOutput(TARGET:trace.txt)
    Including led.emic with name=.{name}.
EMIC:restoreOutput

EMIC:setInput(DEV:_api/led.emic, name=.{name}., pin=.{pin}.)
```

---

#### 4. Validar Paths Dinámicos

```emic
EMIC:setOutput(TARGET:paths.txt)
    Expected path: DEV:_hard/.{system.ucName}./GPIO/gpio.emic
EMIC:restoreOutput

EMIC:setInput(DEV:_hard/.{system.ucName}./GPIO/gpio.emic)
```

**Resultado en `paths.txt`:**
```
Expected path: DEV:_hard/pic24FJ64GA002/GPIO/gpio.emic
```

Si hay error, se puede ver qué path se intentó usar.

---

## Casos Prácticos Avanzados

### Caso 1: API Genérica con Múltiples Backends

**Objetivo:** Crear una API de comunicación que funcione con UART, USB o Ethernet según configuración.

**Archivo: `comm_api.emic`**
```emic
EMIC:tag(driverName = COMMUNICATION)

// Parámetros: backend = uart | usb | ethernet

EMIC:ifdef backend.uart
    EMIC:setInput(
        DEV:_drivers/UART/uart_driver.emic,
        port=.{port}.,
        baud=.{baud}.
    )
EMIC:endif

EMIC:ifdef backend.usb
    EMIC:setInput(
        DEV:_drivers/USB/MCP2200/MCP2200.emic,
        port=.{port}.
    )
EMIC:endif

EMIC:ifdef backend.ethernet
    EMIC:setInput(
        DEV:_drivers/Ethernet/W5500/w5500.emic,
        spi_port=.{spi_port}.
    )
EMIC:endif

// Código común de la API
EMIC:copy(inc/comm_api.h > TARGET:inc/comm_api.h)
EMIC:copy(src/comm_api.c > TARGET:comm_api.c, backend=.{backend}.)
```

**Uso:**
```emic
// Proyecto 1: Usar UART
EMIC:define(backend.uart, true)
EMIC:setInput(DEV:_api/comm_api.emic, backend=uart, port=1, baud=115200)

// Proyecto 2: Usar USB
EMIC:define(backend.usb, true)
EMIC:setInput(DEV:_api/comm_api.emic, backend=usb, port=1)
```

---

### Caso 2: Configuración Dinámica de Pines

**Objetivo:** Permitir reasignación de pines sin modificar código fuente.

**Archivo: `dynamic_pins.emic`**
```emic
// Definir mapping de pines según hardware revision

EMIC:ifdef HARDWARE_REV_1
    EMIC:define(LED_STATUS, A0_Pin)
    EMIC:define(LED_ERROR, A1_Pin)
    EMIC:define(BUTTON_START, B0_Pin)
EMIC:endif

EMIC:ifdef HARDWARE_REV_2
    EMIC:define(LED_STATUS, C2_Pin)  // Cambiado en rev 2
    EMIC:define(LED_ERROR, C3_Pin)   // Cambiado en rev 2
    EMIC:define(BUTTON_START, B0_Pin)  // Sin cambios
EMIC:endif

// Usar pines
EMIC:setInput(DEV:_api/led.emic, name=status_led, pin=.{LED_STATUS}.)
EMIC:setInput(DEV:_api/led.emic, name=error_led, pin=.{LED_ERROR}.)
EMIC:setInput(DEV:_api/button.emic, name=start_btn, pin=.{BUTTON_START}.)
```

---

### Caso 3: Template de Driver Genérico

**Objetivo:** Crear un driver reutilizable para múltiples chips similares.

**Archivo: `generic_sensor_driver.emic`**
```emic
// Parámetros:
// - chip: Nombre del chip (DHT22, SHT31, BME280)
// - interface: i2c | spi | onewire
// - address: Dirección I2C (si aplica)

EMIC:tag(driverName = SENSOR_GENERIC)

// Incluir interfaz apropiada
EMIC:ifdef interface.i2c
    EMIC:setInput(
        DEV:_drivers/I2C/I2C_driver.emic,
        port=.{port}.,
        frameID=.{address}.
    )
EMIC:endif

EMIC:ifdef interface.spi
    EMIC:setInput(
        DEV:_drivers/SPI/SPI_driver.emic,
        port=.{port}.,
        cs_pin=.{cs_pin}.
    )
EMIC:endif

// Copiar código específico del chip
EMIC:copy(
    chips/.{chip}./sensor_driver.c > TARGET:sensor_.{chip}..c,
    chip=.{chip}.,
    interface=.{interface}.
)

EMIC:copy(
    chips/.{chip}./sensor_driver.h > TARGET:inc/sensor_.{chip}..h,
    chip=.{chip}.
)

EMIC:define(c_modules.sensor_.{chip}., sensor_.{chip}.)
```

**Uso:**
```emic
// Sensor DHT22 por OneWire
EMIC:define(interface.onewire, true)
EMIC:setInput(
    DEV:_drivers/generic_sensor_driver.emic,
    chip=DHT22,
    interface=onewire,
    pin=B5_Pin
)

// Sensor BME280 por I2C
EMIC:define(interface.i2c, true)
EMIC:setInput(
    DEV:_drivers/generic_sensor_driver.emic,
    chip=BME280,
    interface=i2c,
    port=1,
    address=0x76
)
```

---

### Caso 4: Sistema de Plugins Dinámicos

**Objetivo:** Permitir habilitar/deshabilitar features mediante flags.

**Archivo: `features.emic`**
```emic
// Features disponibles (definidas por integrador)
// FEATURE_TELEMETRY
// FEATURE_DATA_LOGGING
// FEATURE_WEB_SERVER
// FEATURE_MODBUS

EMIC:ifdef FEATURE_TELEMETRY
    EMIC:setInput(DEV:_plugins/telemetry/telemetry.emic)
    EMIC:define(plugins.telemetry, enabled)
EMIC:endif

EMIC:ifdef FEATURE_DATA_LOGGING
    EMIC:setInput(DEV:_plugins/data_logging/logger.emic)
    EMIC:define(plugins.logger, enabled)
EMIC:endif

EMIC:ifdef FEATURE_WEB_SERVER
    EMIC:setInput(DEV:_plugins/web_server/httpd.emic)
    EMIC:define(plugins.httpd, enabled)
EMIC:endif

EMIC:ifdef FEATURE_MODBUS
    EMIC:setInput(DEV:_plugins/modbus/modbus.emic)
    EMIC:define(plugins.modbus, enabled)
EMIC:endif
```

**Uso en `generate.emic`:**
```emic
// Proyecto 1: Solo telemetría
EMIC:define(FEATURE_TELEMETRY, true)
EMIC:setInput(DEV:features.emic)

// Proyecto 2: Todo habilitado
EMIC:define(FEATURE_TELEMETRY, true)
EMIC:define(FEATURE_DATA_LOGGING, true)
EMIC:define(FEATURE_WEB_SERVER, true)
EMIC:define(FEATURE_MODBUS, true)
EMIC:setInput(DEV:features.emic)
```

---

## Buenas Prácticas Avanzadas

### 1. Usar Convenciones de Nombrado Consistentes

```emic
// Variables de sistema: system.*
EMIC:define(system.ucName, pic24FJ64GA002)

// Variables de configuración: config.*
EMIC:define(config.uart.baud, 115200)

// Módulos de compilación: c_modules.*
EMIC:define(c_modules.uart1, uart1)

// Includes principales: main_includes.*
EMIC:define(main_includes.uart1, uart1)

// Callbacks: *_CALLBACK
EMIC:define(I2C1_CALLBACK_MASTER, true)
```

---

### 2. Documentar Parámetros Requeridos

```emic
/*****************************************************************************
  @file     sensor_api.emic
  @brief    Generic Sensor API

  @param name       Name of the sensor instance
  @param type       Sensor type (temperature | pressure | humidity)
  @param interface  Communication interface (i2c | spi | analog)
  @param pin        Pin name (for analog sensors)
  @param port       Port number (for digital interfaces)
  @param address    I2C address (if interface=i2c)
 ******************************************************************************/

EMIC:tag(driverName = SENSOR)

// Código...
```

---

### 3. Validar Parámetros

```emic
// Validar que al menos un backend esté definido
EMIC:ifndef backend.uart
EMIC:ifndef backend.usb
EMIC:ifndef backend.ethernet
    EMIC:setOutput(TARGET:ERROR.txt)
        ERROR: No backend defined! Define backend.uart, backend.usb, or backend.ethernet
    EMIC:restoreOutput
EMIC:endif
EMIC:endif
EMIC:endif
```

---

### 4. Separar Configuración de Lógica

```emic
// ✅ BUENO: Separar concerns

// config.emic - Solo configuración
EMIC:define(UART1_BAUD, 115200)
EMIC:define(UART1_BUFFER, 512)
EMIC:define(UART2_BAUD, 9600)
EMIC:define(UART2_BUFFER, 128)

// generate.emic - Solo lógica de generación
EMIC:setInput(DEV:config.emic)
EMIC:setInput(DEV:_api/uart.emic, port=1, baud=.{UART1_BAUD}., buffer=.{UART1_BUFFER}.)
EMIC:setInput(DEV:_api/uart.emic, port=2, baud=.{UART2_BAUD}., buffer=.{UART2_BUFFER}.)
```

---

### 5. Usar Archivos de Índice

```emic
// api_index.emic - Índice de todas las APIs disponibles

EMIC:ifdef USE_LED_API
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=.{led_name}., pin=.{led_pin}.)
EMIC:endif

EMIC:ifdef USE_TIMER_API
    EMIC:setInput(DEV:_api/Timers/timer_api.emic, name=.{timer_name}.)
EMIC:endif

EMIC:ifdef USE_UART_API
    EMIC:setInput(DEV:_api/UART/uart_api.emic, port=.{uart_port}., baud=.{uart_baud}.)
EMIC:endif
```

**Uso:**
```emic
// En generate.emic
EMIC:define(USE_LED_API, true)
EMIC:define(led_name, status)
EMIC:define(led_pin, A0)

EMIC:define(USE_UART_API, true)
EMIC:define(uart_port, 1)
EMIC:define(uart_baud, 115200)

EMIC:setInput(DEV:api_index.emic)
```

---

## Resumen del Capítulo

### Puntos Clave

1. **Variables Avanzadas:**
   - Variables de sistema: `.{system.*}.`
   - Variables anidadas: `.{prefix}..{name}.`
   - Namespacing con puntos (2 y 3 niveles)

2. **Ámbito (Scope):**
   - Variables globales: Disponibles siempre
   - Variables locales: Solo en archivo actual
   - Propagación explícita requerida

3. **Sustituciones Complejas:**
   - En nombres de archivo
   - Múltiples sustituciones simultáneas
   - Concatenación de variables

4. **Iteración y Expansión:**
   - Inline con comodín: `.{col.*}.` → N líneas
   - Join con separador: `.{col.*}. .[sep].` → 1 línea
   - Foreach multilínea: `EMIC:foreach(col.*)` ... `EMIC:endforeach`
   - Foreach anidado: iteradores `{*}`, `{**}`, `{***}`
   - Comodín en 3 niveles: `col1.col2.*`, `col1.*.key`, `col1.*.*`

5. **Patrones Avanzados:**
   - Multi-instanciación de componentes
   - Include guards para prevenir duplicados
   - Composición jerárquica
   - Configuración dinámica

6. **Debugging:**
   - Logging con `EMIC:setOutput`
   - Verificación de expansiones
   - Trace de inclusiones

### Directivas y Patrones

| Patrón | Uso | Ejemplo |
|--------|-----|---------|
| **Include Guard** | Prevenir duplicados | `EMIC:ifndef ... EMIC:define ... EMIC:endif` |
| **Multi-Instancia** | Múltiples copias | `EMIC:setInput(api.emic, name=inst1)` ×N |
| **Composición** | Dependencias | API → Driver → HAL → _hard |
| **Configuración Dinámica** | Adaptabilidad | `EMIC:ifdef REV_1 ... EMIC:endif` |
| **Variables Anidadas** | Nombres dinámicos | `.{prefix}..{name}..{suffix}.` |
| **Inline Wildcard** | Expansión por key | `.{col.*}.` → N líneas |
| **Join con Separador** | Lista en 1 línea | `.{col.*}. .[, ].` |
| **Foreach** | Bloque por key | `EMIC:foreach(col.*)` ... `EMIC:endforeach` |
| **Foreach Anidado** | 2 dimensiones | `{*}` externo, `{**}` interno |

### Casos de Uso Cubiertos

✅ API genérica con múltiples backends
✅ Configuración dinámica de pines según hardware revision
✅ Template de driver genérico para sensores
✅ Sistema de plugins dinámicos
✅ Iteración automática sobre colecciones de periféricos
✅ Generación de enums y listas con expansión join

### Próximo Capítulo

El **Capítulo 18** cubrirá el **catálogo completo de directivas EMIC-Codify** con referencia detallada y ejemplos de uso.

---

**Fin del Capítulo 17**

**Progreso del Manual:**
- **Sección 1 (Introducción):** ████████████████████ 100% (5/5) ✅
- **Sección 2 (Estructura SDK):** ████████████████████ 100% (11/11) ✅
- **Sección 3 (EMIC-Codify):** ████████░░░░░░░░░░░░  40% (2/5)

**Progreso Total: 17/38 capítulos (44.74%)**

---

**Referencias:**
- Capítulo 16: Introducción a EMIC-Codify
- Capítulo 05: Visión General del SDK
- Capítulo 06: Carpeta `_modules/`
