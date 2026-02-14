# Capítulo 18: Directivas Completas de EMIC-Codify

## Índice
1. [Introducción](#introducción)
2. [Catálogo de Directivas](#catálogo-de-directivas)
3. [Directivas de Definición](#directivas-de-definición)
4. [Directivas de Inclusión](#directivas-de-inclusión)
5. [Directivas de Copia](#directivas-de-copia)
6. [Directivas de Redirección de Salida](#directivas-de-redirección-de-salida)
7. [Directivas Condicionales](#directivas-condicionales)
8. [Directivas de Metadata](#directivas-de-metadata)
9. [Directivas Especiales](#directivas-especiales)
10. [Tabla de Referencia Rápida](#tabla-de-referencia-rápida)
11. [Árbol de Decisión](#árbol-de-decisión)
12. [Errores Comunes](#errores-comunes)
13. [Resumen del Capítulo](#resumen-del-capítulo)

---

## Introducción

Este capítulo es una **referencia completa** de todas las directivas disponibles en EMIC-Codify. Cada directiva está documentada con:
- **Sintaxis formal** (tipo BNF)
- **Parámetros** (requeridos y opcionales)
- **Comportamiento detallado**
- **Ejemplos del SDK real**
- **Errores comunes y soluciones**

Este capítulo está diseñado para ser usado como **referencia rápida** durante el desarrollo. Se recomienda marcarlo como favorito para consultas frecuentes.

---

## Catálogo de Directivas

EMIC-Codify proporciona **12 directivas principales**:

| Directiva | Categoría | Propósito | Frecuencia de Uso |
|-----------|-----------|-----------|-------------------|
| `EMIC:define` | Definición | Definir variables globales | ⭐⭐⭐⭐⭐ |
| `EMIC:unDefine` | Definición | Eliminar variable definida | ⭐⭐ |
| `EMIC:setInput` | Inclusión | Incluir archivos .emic | ⭐⭐⭐⭐⭐ |
| `EMIC:copy` | Copia | Copiar archivos con sustitución | ⭐⭐⭐⭐⭐ |
| `EMIC:setOutput` | Redirección | Redirigir salida a archivo | ⭐⭐⭐⭐ |
| `EMIC:restoreOutput` | Redirección | Restaurar salida estándar | ⭐⭐⭐⭐ |
| `EMIC:ifdef` | Condicional | Si variable está definida | ⭐⭐⭐⭐ |
| `EMIC:ifndef` | Condicional | Si variable NO está definida | ⭐⭐⭐⭐⭐ |
| `EMIC:endif` | Condicional | Fin de bloque condicional | ⭐⭐⭐⭐⭐ |
| `EMIC:foreach` | Iteración | Iterar sobre colección | ⭐⭐⭐⭐ |
| `EMIC:endforeach` | Iteración | Fin de bloque foreach | ⭐⭐⭐⭐ |
| `EMIC:tag` | Metadata | Etiquetar recursos | ⭐⭐⭐ |

**Nota:** También existe `EMIC:else`, `EMIC:elif` e `EMIC:if` para condicionales avanzados.

---

## Directivas de Definición

### `EMIC:define` - Definir Variable Global

#### Sintaxis Formal

```bnf
EMIC:define(<nombre_variable>, <valor>)

<nombre_variable> ::= identificador válido (puede contener puntos)
<valor>          ::= cualquier string (puede contener variables .{*}.)
```

#### Descripción

Define una **variable global** que estará disponible en todos los archivos .emic procesados después de su definición. La variable puede ser referenciada usando la sintaxis `.{nombre_variable}.`.

#### Parámetros

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `nombre_variable` | string | ✅ | Nombre de la variable (sin `.{}`) |
| `valor` | string | ✅ | Valor a asignar (se guarda como string literal) |

#### Comportamiento

1. **Crea variable global** en el contexto de EMIC-Generate
2. **Disponible inmediatamente** después de la definición
3. **Permanece** hasta el final de la ejecución
4. **Sobrescribe** si ya existe variable con mismo nombre
5. **NO evalúa expresiones** - guarda el valor como string literal

#### Ejemplos del SDK

**Ejemplo 1: Variable de sistema**
```emic
EMIC:define(system.ucName, pic24FJ64GA002)
EMIC:define(system.clockFreq, 32000000)
EMIC:define(system.compiler, XC16)
```

**Ejemplo 2: Definición de módulos de compilación**
```emic
EMIC:define(c_modules.uart1, uart1)
EMIC:define(c_modules.timer1, timer1)
EMIC:define(main_includes.systemTimer, systemTimer)
```

**Ejemplo 3: Callbacks**
```emic
EMIC:define(I2C.{port}._CALLBACK_MASTER, true)
EMIC:define(I2C.{port}._CALLBACK_SLAVE, true)
```

**Ejemplo 4: Include guard**
```emic
EMIC:define(_DIVER_SYSTEM_TIMER_EMIC_, true)
```

**Ejemplo 5: Variable con otra variable**
```emic
EMIC:define(module_name, uart_.{port}._driver)
// Si port=1: module_name = uart_1_driver
```

#### Casos de Uso

1. **Configuración global del sistema**
2. **Registrar módulos a compilar**
3. **Include guards**
4. **Flags de características (feature flags)**
5. **Nombres de archivos dinámicos**

#### Errores Comunes

**❌ Error: Incluir `.{}` en el nombre**
```emic
EMIC:define(.{name}., led1)  // ❌ MAL
```
**✅ Correcto:**
```emic
EMIC:define(name, led1)  // ✅ BIEN
```

**❌ Error: Esperar evaluación de expresiones**
```emic
EMIC:define(result, 10 + 5)  // Guarda "10 + 5" como string, NO calcula
```

**❌ Error: Variables entre comillas**
```emic
EMIC:define("name", "led1")  // ❌ No usar comillas
```
**✅ Correcto:**
```emic
EMIC:define(name, led1)  // ✅ Sin comillas
```

---

### `EMIC:unDefine` - Eliminar Variable

#### Sintaxis Formal

```bnf
EMIC:unDefine(<nombre_variable>)

<nombre_variable> ::= identificador (puede contener puntos para colecciones)
```

#### Descripción

Elimina una variable previamente definida. Soporta variables globales simples y variables con namespace (colecciones de 2 y 3 niveles).

#### Parámetros

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `nombre_variable` | string | Si | Nombre de la variable a eliminar |

#### Comportamiento

1. **Sin punto**: Elimina de variables globales (`misMacros["global"]`)
2. **Un punto** (ej: `col.key`): Elimina `key` de la colección `col`
3. **Dos puntos** (ej: `col1.col2.key`): Elimina `key` de la colección de 3 niveles `col1.col2`
4. **Si no existe**: No produce error, se ignora silenciosamente

#### Ejemplos

**Ejemplo 1: Eliminar variable global**
```emic
EMIC:define(USE_DEBUG, true)
// ... código de debug ...
EMIC:unDefine(USE_DEBUG)
// USE_DEBUG ya no existe
```

**Ejemplo 2: Eliminar de colección**
```emic
EMIC:define(c_modules.uart1, uart1)
EMIC:define(c_modules.timer1, timer1)
EMIC:unDefine(c_modules.uart1)
// Solo queda c_modules.timer1
```

**Ejemplo 3: Eliminar de colección de 3 niveles**
```emic
EMIC:define(hw.uart.baud, 9600)
EMIC:define(hw.uart.parity, none)
EMIC:unDefine(hw.uart.parity)
// Solo queda hw.uart.baud
```

---

## Directivas de Inclusión

### `EMIC:setInput` - Incluir Archivo

#### Sintaxis Formal

```bnf
EMIC:setInput(<ruta_archivo>)
EMIC:setInput(<ruta_archivo>, <param1>=<valor1>, <param2>=<valor2>, ...)

<ruta_archivo> ::= volumen ":" path relativo
<volumen>      ::= "DEV" | "TARGET" | "SYS" | "USER"
<paramN>       ::= identificador de parámetro
<valorN>       ::= valor del parámetro (puede contener variables)
```

#### Descripción

Incluye y procesa otro archivo .emic, opcionalmente pasando parámetros que se convierten en **variables locales** dentro del archivo incluido.

#### Parámetros

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `ruta_archivo` | path | ✅ | Ruta del archivo a incluir (con volumen lógico) |
| `param1=valor1` | key=value | ❌ | Parámetros opcionales (variables locales) |

#### Comportamiento

1. **Lee el archivo** especificado
2. **Crea variables locales** para cada parámetro
3. **Procesa el contenido** del archivo recursivamente
4. **Las variables locales NO se propagan** a inclusiones anidadas
5. **Las variables globales** están siempre disponibles

#### Ejemplos del SDK

**Ejemplo 1: Inclusión simple sin parámetros**
```emic
EMIC:setInput(DEV:_main/baremetal/main.emic)
EMIC:setInput(DEV:_hal/Timer/timer.emic)
```

**Ejemplo 2: Inclusión con parámetros**
```emic
EMIC:setInput(
    DEV:_api/Indicators/LEDs/led.emic,
    name=led1,
    pin=A0_Pin
)
```

**Ejemplo 3: Inclusión con variables en la ruta**
```emic
// Delegar al archivo específico del microcontrolador
EMIC:setInput(DEV:_hard/.{system.ucName}./GPIO/gpio.emic)
```

**Ejemplo 4: Múltiples parámetros**
```emic
EMIC:setInput(
    DEV:_api/UART/uart_api.emic,
    port=1,
    baud=115200,
    buffer=1024,
    name=uart_debug
)
```

**Ejemplo 5: Propagación explícita de variables**
```emic
// Propagar variable local al siguiente nivel
EMIC:setInput(
    DEV:_hal/SPI/spi.emic,
    configuracion=.{configuracion}.,
    port=.{port}.,
    pin=.{pin}.
)
```

**Ejemplo 6: Inclusión desde diferentes volúmenes**
```emic
// Desde SDK
EMIC:setInput(DEV:_api/led.emic)

// Archivos generados por EMIC-Generate
EMIC:setInput(SYS:usedFunction.emic)
EMIC:setInput(SYS:usedEvent.emic)
```

#### Casos de Uso

1. **Incluir componentes del SDK** (APIs, Drivers, HAL)
2. **Delegar a implementaciones específicas** (por MCU)
3. **Componer jerarquías de dependencias**
4. **Multi-instanciación** (llamar múltiples veces con diferentes parámetros)
5. **Incluir archivos generados** por EMIC-Generate

#### Errores Comunes

**❌ Error: Ruta absoluta en lugar de volumen**
```emic
EMIC:setInput(C:/SDK/_api/led.emic)  // ❌ MAL
```
**✅ Correcto:**
```emic
EMIC:setInput(DEV:_api/led.emic)  // ✅ BIEN
```

**❌ Error: Usar comillas en parámetros**
```emic
EMIC:setInput(DEV:_api/led.emic, name="led1")  // ❌ No usar comillas
```
**✅ Correcto:**
```emic
EMIC:setInput(DEV:_api/led.emic, name=led1)  // ✅ Sin comillas
```

**❌ Error: Asumir que variables locales se propagan**
```emic
// En generate.emic
EMIC:setInput(DEV:_api/led.emic, name=led1, pin=A0)

// En led.emic
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
// ❌ .{name}. y .{pin}. NO estarán disponibles en gpio.emic
```

**✅ Correcto:**
```emic
// En led.emic - propagar explícitamente
EMIC:setInput(DEV:_hal/GPIO/gpio.emic, pin=.{pin}.)
// ✅ Ahora .{pin}. sí está disponible
```

---

## Directivas de Copia

### `EMIC:copy` - Copiar Archivo con Sustitución

#### Sintaxis Formal

```bnf
EMIC:copy(<origen> > <destino>)
EMIC:copy(<origen> > <destino>, <param1>=<valor1>, <param2>=<valor2>, ...)

<origen>  ::= volumen ":" path origen
<destino> ::= volumen ":" path destino
<paramN>  ::= identificador
<valorN>  ::= valor de sustitución
```

#### Descripción

Copia un archivo o directorio desde `origen` a `destino`, opcionalmente sustituyendo variables en el **contenido** y/o **nombre de archivo**.

#### Parámetros

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `origen` | path | ✅ | Ruta del archivo/directorio origen |
| `destino` | path | ✅ | Ruta destino (puede contener variables) |
| `param1=valor1` | key=value | ❌ | Sustituciones a realizar |

#### Comportamiento

1. **Lee archivo/directorio origen**
2. **Sustituye variables** especificadas en el contenido
3. **Sustituye variables** en el nombre del archivo destino
4. **Escribe archivo destino** con contenido transformado
5. **Si origen es directorio**, copia recursivamente todo

#### Ejemplos del SDK

**Ejemplo 1: Copia simple sin sustitución**
```emic
EMIC:copy(DEV:_templates/Makefile > TARGET:Makefile)
```

**Ejemplo 2: Copia con sustitución en contenido**
```emic
EMIC:copy(
    inc/led.h > TARGET:inc/led_.{name}..h,
    name=.{name}.,
    pin=.{pin}.
)

// Si name=led1, pin=A0_Pin:
// - Archivo destino: inc/led_led1.h
// - Contenido: sustituye .{name}. → led1, .{pin}. → A0_Pin
```

**Ejemplo 3: Copia con variable en nombre de destino**
```emic
EMIC:copy(
    src/timer_api.c > TARGET:timer_api.{name}..c,
    name=.{name}.
)

// Si name=1: timer_api1.c
// Si name=2: timer_api2.c
```

**Ejemplo 4: Copia de directorio completo**
```emic
EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

// Copia toda la estructura:
// TARGET:
//   ├── Makefile
//   ├── nbproject/
//   │   ├── configurations.xml
//   │   └── project.xml
//   └── ...
```

**Ejemplo 5: Múltiples sustituciones**
```emic
EMIC:copy(
    src/I2C_driver.c > TARGET:I2C.{port}._driver.c,
    port=.{port}.,
    frameID=.{frameID}.,
    baud=.{baud}.
)
```

**Ejemplo 6: Copiar desde SYS: (archivos del integrador)**
```emic
EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
```

**Ejemplo 7: Copiar archivos de configuración de PCB**
```emic
EMIC:copy(inc/.{pcb}..h > TARGET:inc/.{pcb}..h)

// Si pcb=HRD_Development_Board:
// Copia: inc/HRD_Development_Board.h → TARGET:inc/HRD_Development_Board.h
```

#### Casos de Uso

1. **Generar archivos .c/.h** con parametrización
2. **Copiar templates de proyecto** (Makefiles, configs)
3. **Multi-instanciación** (generar múltiples archivos desde un template)
4. **Copiar código del integrador** (SYS: → TARGET:)
5. **Copiar recursos** (assets, linker scripts)

#### Errores Comunes

**❌ Error: Olvidar el separador `>`**
```emic
EMIC:copy(src/led.c TARGET:led.c)  // ❌ Falta >
```
**✅ Correcto:**
```emic
EMIC:copy(src/led.c > TARGET:led.c)  // ✅ Con >
```

**❌ Error: Usar `=` en lugar de `>` para separar origen y destino**
```emic
EMIC:copy(src/led.c = TARGET:led.c, name=led1)  // ❌ MAL
```
**✅ Correcto:**
```emic
EMIC:copy(src/led.c > TARGET:led.c, name=led1)  // ✅ BIEN
```

**❌ Error: No propagar variables necesarias**
```emic
// Si .{name}. está en el archivo pero no se pasa:
EMIC:copy(src/led.c > TARGET:led_.{name}..c)
// ❌ .{name}. aparecerá literal en el código C
```
**✅ Correcto:**
```emic
EMIC:copy(src/led.c > TARGET:led_.{name}..c, name=.{name}.)
// ✅ .{name}. se sustituirá correctamente
```

---

## Directivas de Redirección de Salida

### `EMIC:setOutput` - Redirigir Salida

#### Sintaxis Formal

```bnf
EMIC:setOutput(<archivo_destino>)
    <contenido>
EMIC:restoreOutput

<archivo_destino> ::= volumen ":" path
<contenido>       ::= cualquier texto (puede incluir EMIC:setInput)
```

#### Descripción

Redirige toda la salida generada (incluido output de `EMIC:setInput`) al archivo especificado hasta que se encuentre `EMIC:restoreOutput`.

#### Parámetros

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `archivo_destino` | path | ✅ | Archivo donde redirigir la salida |

#### Comportamiento

1. **Abre archivo destino** para escritura
2. **Redirige toda salida** al archivo
3. **Procesa contenido** del bloque (incluye, sustituciones, etc.)
4. **Escribe resultado** en el archivo
5. **Restaura salida** con `EMIC:restoreOutput`

#### Ejemplos del SDK

**Ejemplo 1: Generar archivo C directamente**
```emic
EMIC:setOutput(TARGET:test.c)
    #include <xc.h>

    void test_function(void) {
        // código C
    }
EMIC:restoreOutput
```

**Ejemplo 2: Generar header desde template**
```emic
EMIC:setOutput(TARGET:inc/systemTimer.h)
    EMIC:setInput(inc/systemTimer.h)
EMIC:restoreOutput
```

**Ejemplo 3: Archivo de log de variables**
```emic
EMIC:setOutput(TARGET:debug_log.txt)
    Variable name: .{name}.
    Variable pin: .{pin}.
    Variable ucName: .{system.ucName}.
EMIC:restoreOutput
```

**Ejemplo 4: Generar múltiples archivos**
```emic
// Header
EMIC:setOutput(TARGET:inc/my_module.h)
    #ifndef MY_MODULE_H
    #define MY_MODULE_H
    void my_function(void);
    #endif
EMIC:restoreOutput

// Source
EMIC:setOutput(TARGET:src/my_module.c)
    #include "my_module.h"
    void my_function(void) {
        // implementación
    }
EMIC:restoreOutput
```

**Ejemplo 5: Archivo principal generate.txt**
```emic
EMIC:setOutput(TARGET:generate.txt)
    // Todo el generate.emic típicamente está dentro de setOutput
    EMIC:setInput(DEV:_pcb/pcb.emic, pcb=HRD_Development_Board)
    EMIC:setInput(DEV:_api/led.emic, name=led1, pin=A0)
    // ...
EMIC:restoreOutput
```

#### Casos de Uso

1. **Registrar todo el proceso** de generación (generate.txt)
2. **Generar archivos C/H** directamente desde .emic
3. **Crear archivos de log/debug**
4. **Generar múltiples archivos** desde un solo .emic
5. **Wrappear inclusión** de templates

#### Errores Comunes

**❌ Error: Olvidar EMIC:restoreOutput**
```emic
EMIC:setOutput(TARGET:file.c)
    // contenido
// ❌ Falta EMIC:restoreOutput
// Todo lo que sigue se escribirá en file.c
```
**✅ Correcto:**
```emic
EMIC:setOutput(TARGET:file.c)
    // contenido
EMIC:restoreOutput  // ✅ Restaurar salida
```

**❌ Error: Anidar setOutput sin restaurar**
```emic
EMIC:setOutput(TARGET:file1.c)
    EMIC:setOutput(TARGET:file2.c)  // ❌ No anidar
        // contenido
    EMIC:restoreOutput
EMIC:restoreOutput
```
**✅ Correcto:**
```emic
EMIC:setOutput(TARGET:file1.c)
    // contenido
EMIC:restoreOutput

EMIC:setOutput(TARGET:file2.c)  // ✅ Separar
    // contenido
EMIC:restoreOutput
```

---

### `EMIC:restoreOutput` - Restaurar Salida

#### Sintaxis Formal

```bnf
EMIC:restoreOutput
```

#### Descripción

Restaura la salida al stream anterior (generalmente stdout o el `EMIC:setOutput` previo). **Siempre debe usarse** para cerrar un bloque `EMIC:setOutput`.

#### Parámetros

Ninguno.

#### Comportamiento

1. **Cierra el archivo** actual de salida
2. **Restaura** el stream de salida anterior
3. **Obligatorio** para cada `EMIC:setOutput`

#### Ejemplo

```emic
EMIC:setOutput(TARGET:file.c)
    // Todo aquí va a file.c
EMIC:restoreOutput  // Obligatorio

// Aquí la salida vuelve a donde estaba antes
```

---

## Directivas Condicionales

### `EMIC:ifdef` - Si Variable Definida

#### Sintaxis Formal

```bnf
EMIC:ifdef <nombre_variable>
    <bloque_then>
EMIC:endif

<nombre_variable> ::= identificador (sin .{})
<bloque_then>     ::= cualquier contenido EMIC-Codify
```

#### Descripción

Ejecuta el bloque `<bloque_then>` **solo si** la variable especificada está definida (existe).

#### Parámetros

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `nombre_variable` | string | ✅ | Nombre de variable a verificar (sin `.{}`) |

#### Comportamiento

1. **Verifica existencia** de la variable
2. **Si existe**: Procesa el bloque
3. **Si NO existe**: Salta el bloque
4. **NO evalúa valor** - solo verifica existencia

#### Ejemplos del SDK

**Ejemplo 1: Condicional simple**
```emic
EMIC:ifdef USE_UART
    EMIC:setInput(DEV:_hal/UART/uart.emic)
EMIC:endif
```

**Ejemplo 2: Incluir feature opcional**
```emic
EMIC:ifdef ENABLE_TELEMETRY
    EMIC:setInput(DEV:_plugins/telemetry/telemetry.emic)
    EMIC:define(features.telemetry, enabled)
EMIC:endif
```

**Ejemplo 3: Condicional con backend**
```emic
EMIC:ifdef backend.uart
    EMIC:setInput(DEV:_drivers/UART/uart_driver.emic, port=.{port}.)
EMIC:endif

EMIC:ifdef backend.usb
    EMIC:setInput(DEV:_drivers/USB/MCP2200/MCP2200.emic, port=.{port}.)
EMIC:endif
```

**Ejemplo 4: Condicionales anidados**
```emic
EMIC:ifdef ENABLE_COMMUNICATION

    EMIC:ifdef USE_UART
        EMIC:setInput(DEV:_hal/UART/uart.emic)
    EMIC:endif

    EMIC:ifdef USE_SPI
        EMIC:setInput(DEV:_hal/SPI/spi.emic)
    EMIC:endif

EMIC:endif
```

**Ejemplo 5: Evento del usuario (usedEvent)**
```emic
EMIC:ifdef usedEvent.SystemConfig
    SystemConfig();
EMIC:endif

EMIC:ifdef usedEvent.onReset
    onReset();
EMIC:endif
```

#### Casos de Uso

1. **Feature flags** (habilitar/deshabilitar funcionalidades)
2. **Backends opcionales** (UART/USB/Ethernet)
3. **Eventos del usuario** (SystemConfig, onReset)
4. **Configuración por hardware revision**
5. **Compilación condicional**

---

### `EMIC:ifndef` - Si Variable NO Definida

#### Sintaxis Formal

```bnf
EMIC:ifndef <nombre_variable>
    <bloque_then>
EMIC:endif

<nombre_variable> ::= identificador (sin .{})
<bloque_then>     ::= cualquier contenido EMIC-Codify
```

#### Descripción

Ejecuta el bloque `<bloque_then>` **solo si** la variable especificada **NO** está definida.

**Uso principal:** Include guards (prevenir inclusiones duplicadas).

#### Parámetros

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `nombre_variable` | string | ✅ | Nombre de variable a verificar |

#### Comportamiento

1. **Verifica existencia** de la variable
2. **Si NO existe**: Procesa el bloque
3. **Si existe**: Salta el bloque
4. **Inverso de ifdef**

#### Ejemplos del SDK

**Ejemplo 1: Include guard típico**
```emic
EMIC:ifndef _DIVER_SYSTEM_TIMER_EMIC_
EMIC:define(_DIVER_SYSTEM_TIMER_EMIC_, true)

    // Código del driver
    EMIC:setInput(DEV:_hal/Timer/timer.emic)
    EMIC:copy(inc/systemTimer.h > TARGET:inc/systemTimer.h)

EMIC:endif
```

**Ejemplo 2: Include guard para I2C driver**
```emic
EMIC:ifndef I2C_DRIVER_EMIC_
EMIC:define(I2C_DRIVER_EMIC_, true)

    EMIC:define(I2C.{port}._CALLBACK_MASTER, true)
    EMIC:setInput(DEV:_hal/I2C/I2C.emic, port=.{port}.)
    EMIC:copy(inc/I2C_driver.h > TARGET:inc/I2C.{port}._driver.h, port=.{port}.)

EMIC:endif
```

**Ejemplo 3: Valor por defecto**
```emic
EMIC:ifndef UART_BAUD
    EMIC:define(UART_BAUD, 9600)  // Valor por defecto si no está definido
EMIC:endif
```

**Ejemplo 4: Lógica else (con ifdef + ifndef)**
```emic
EMIC:ifdef USE_UART
    // Código para UART
    EMIC:setInput(DEV:_hal/UART/uart.emic)
EMIC:endif

EMIC:ifndef USE_UART
    // Código alternativo (else)
    EMIC:setInput(DEV:_hal/USB/usb.emic)
EMIC:endif
```

**Ejemplo 5: Validación de parámetros**
```emic
EMIC:ifndef backend.uart
EMIC:ifndef backend.usb
EMIC:ifndef backend.ethernet
    // Ningún backend definido - error
    EMIC:setOutput(TARGET:ERROR.txt)
        ERROR: No backend defined!
    EMIC:restoreOutput
EMIC:endif
EMIC:endif
EMIC:endif
```

#### Casos de Uso

1. **Include guards** (⭐⭐⭐⭐⭐ Uso más común)
2. **Valores por defecto**
3. **Lógica "else"** (combinado con ifdef)
4. **Validación de configuración**
5. **Prevenir duplicados**

---

### `EMIC:endif` - Fin de Bloque Condicional

#### Sintaxis Formal

```bnf
EMIC:endif
```

#### Descripción

Marca el **fin de un bloque condicional** (`EMIC:ifdef` o `EMIC:ifndef`). **Obligatorio** para cada condicional.

#### Parámetros

Ninguno.

#### Comportamiento

1. **Cierra el bloque condicional** más reciente
2. **Restaura** el flujo normal de procesamiento
3. **Debe haber uno** por cada `ifdef`/`ifndef`

#### Errores Comunes

**❌ Error: Olvidar EMIC:endif**
```emic
EMIC:ifdef USE_UART
    EMIC:setInput(DEV:_hal/UART/uart.emic)
// ❌ Falta EMIC:endif
```

**❌ Error: endif sin ifdef/ifndef**
```emic
EMIC:setInput(DEV:_api/led.emic)
EMIC:endif  // ❌ No hay ifdef/ifndef previo
```

**❌ Error: Desbalance de endif**
```emic
EMIC:ifdef USE_UART
    EMIC:ifdef DEBUG
        // código
    EMIC:endif
// ❌ Falta segundo EMIC:endif para USE_UART
```
**✅ Correcto:**
```emic
EMIC:ifdef USE_UART
    EMIC:ifdef DEBUG
        // código
    EMIC:endif
EMIC:endif  // ✅ Ambos cerrados
```

---

## Directivas de Iteración

### `EMIC:foreach` / `EMIC:endforeach` - Iterar sobre Colección

#### Sintaxis Formal

```bnf
EMIC:foreach(<colección>.*)
    <bloque>
EMIC:endforeach

<colección> ::= nombre de colección definida con EMIC:define
<bloque>    ::= cualquier contenido EMIC-Codify (puede contener directivas)
```

#### Descripción

Repite un bloque de texto para cada elemento de una colección. Es la versión multilínea de la expansión inline con comodín `.{col.*}.`.

#### Parámetros

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `colección.*` | pattern | Si | Patrón con comodín indicando la colección a iterar |

#### Variables del Iterador

Dentro del bloque, se pueden usar variables especiales para acceder al elemento actual:

| Variable | Descripción | Ejemplo con key "temp" |
|----------|-------------|----------------------|
| `.{*}.` | Nombre de la key actual (texto literal) | `temp` |
| `{*}` | Key dentro de expresiones macro | `.{sensores.{*}}.` → `.{sensores.temp}.` |

#### Comportamiento

1. **Captura** todas las líneas entre `foreach` y `endforeach`
2. **Obtiene las keys** de la colección con `getValues()`
3. **Por cada key**, duplica el bloque reemplazando `.{*}.` y `{*}`
4. **Encola las líneas** expandidas para reprocesamiento
5. **El reprocesamiento** resuelve las macros `.{col.keyN}.` a sus valores finales

#### Ejemplos

**Ejemplo 1: Foreach básico (2 niveles)**
```emic
EMIC:define(sensores.temp, ADC_CH0)
EMIC:define(sensores.hum, ADC_CH1)
EMIC:define(sensores.pres, ADC_CH2)

EMIC:foreach(sensores.*)
    uint16_t read_.{*}.(void) { return .{sensores.{*}}.; }
EMIC:endforeach
```

Genera:
```c
uint16_t read_temp(void) { return ADC_CH0; }
uint16_t read_hum(void) { return ADC_CH1; }
uint16_t read_pres(void) { return ADC_CH2; }
```

**Ejemplo 2: Foreach con 3 niveles**
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

**Ejemplo 3: Foreach con directivas EMIC en el bloque**
```emic
EMIC:define(modulos.uart, uart)
EMIC:define(modulos.spi, spi)

EMIC:foreach(modulos.*)
    EMIC:setInput(DEV:_hal/.{*}./.{*}..emic)
EMIC:endforeach
```

Equivale a:
```emic
EMIC:setInput(DEV:_hal/uart/uart.emic)
EMIC:setInput(DEV:_hal/spi/spi.emic)
```

#### Foreach Anidado

Se pueden anidar foreach usando iteradores de nivel: `.{*}.` para el externo, `.{**}.` para el interno y `.{***}.` para un tercer nivel.

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

**Regla de iteradores:**

| Nivel | Variable literal | Variable en expresión |
|-------|-----------------|----------------------|
| Externo | `.{*}.` | `{*}` |
| Interno | `.{**}.` | `{**}` |
| Tercer nivel | `.{***}.` | `{***}` |

Al expandir un nivel, los iteradores internos se "promueven": `{**}` pasa a ser `{*}` para el foreach hijo.

#### Errores Comunes

**Error: foreach sin endforeach**
```emic
EMIC:foreach(sensores.*)
    // código
// Falta EMIC:endforeach → Error al llegar a fin de archivo
```

**Error: endforeach sin foreach**
```emic
EMIC:endforeach  // Error: no hay foreach abierto
```

**Error: Patrón sin comodín**
```emic
EMIC:foreach(sensores)  // Error: requiere .* en el patrón
```

---

## Expansión Inline con Comodín

### Expansión Multilínea (una línea por key)

#### Sintaxis

```bnf
texto .{colección.*}. texto
```

#### Descripción

Cuando una línea contiene `.{colección.*}.`, se expande a N líneas (una por cada key de la colección). Es la versión de una sola línea del `EMIC:foreach`.

#### Ejemplo

```emic
EMIC:define(canales.ch0, ADC_AN0)
EMIC:define(canales.ch1, ADC_AN1)
EMIC:define(canales.ch2, ADC_AN2)

uint16_t val = .{canales.*}.;
```

Se expande primero a:
```
uint16_t val = .{canales.ch0}.;
uint16_t val = .{canales.ch1}.;
uint16_t val = .{canales.ch2}.;
```

Y luego cada macro se resuelve a su valor:
```c
uint16_t val = ADC_AN0;
uint16_t val = ADC_AN1;
uint16_t val = ADC_AN2;
```

#### Patrones con 3 Niveles

**Comodín en el tercer nivel** (`col1.col2.*`):
```emic
// Expande las propiedades de hw.uart
prop = .{hw.uart.*}.;
// → prop = .{hw.uart.baud}.; y prop = .{hw.uart.parity}.;
```

**Comodín en el segundo nivel** (`col1.*.key`):
```emic
// Expande los periféricos que tienen "speed"
speed = .{hw.*.speed}.;
// → speed = .{hw.uart.speed}.; y speed = .{hw.spi.speed}.;
```

**Doble comodín** (`col1.*.*`):
```emic
// Expande todos los periféricos y todas sus propiedades
val = .{hw.*.*}.;
// Primera pasada: val = .{hw.uart.*}.; y val = .{hw.spi.*}.;
// Segunda pasada: val = .{hw.uart.baud}.; val = .{hw.uart.parity}.; ...
```

---

### Expansión con Separador (Join en una línea)

#### Sintaxis

```bnf
texto .{colección.*}. .[separador]. texto
```

#### Descripción

Cuando `.{colección.*}.` va seguido de `.[separador].`, en lugar de generar N líneas, genera **una sola línea** con todos los valores concatenados por el separador indicado.

#### Ejemplo

```emic
EMIC:define(canales.ch0, ADC_AN0)
EMIC:define(canales.ch1, ADC_AN1)
EMIC:define(canales.ch2, ADC_AN2)

enum { .{canales.*}. .[, ]. };
```

Se expande primero a:
```
enum { .{canales.ch0}., .{canales.ch1}., .{canales.ch2}. };
```

Y luego se resuelven los valores:
```c
enum { ADC_AN0, ADC_AN1, ADC_AN2 };
```

#### Más Ejemplos

**Separador `|`:**
```emic
int flags = .{opciones.*}. .[ | ]. ;
// → int flags = FLAG_A | FLAG_B | FLAG_C ;
```

**Separador `+`:**
```emic
int total = .{valores.*}. .[ + ]. ;
// → int total = 10 + 20 + 30 ;
```

**Separador `\n` (concatenación sin separador visible):**
```emic
.{includes.*}. .[
].
// → Genera cada include en líneas separadas pero desde una sola línea fuente
```

**Con 3 niveles:**
```emic
int params = .{hw.uart.*}. .[, ]. ;
// → int params = 9600, none ;
```

#### Comparación: Multilínea vs Join

| Sintaxis | Resultado | Uso típico |
|----------|-----------|------------|
| `.{col.*}.` | N líneas separadas | Declaraciones, definiciones |
| `.{col.*}. .[sep].` | 1 línea con separador | Enums, listas de argumentos, expresiones |

---

## Directivas de Metadata

### `EMIC:tag` - Etiquetar Recurso

#### Sintaxis Formal

```bnf
EMIC:tag(<key> = <value>)

<key>   ::= identificador
<value> ::= string (sin comillas)
```

#### Descripción

Define metadata (etiquetas) para el recurso actual. Esta información es extraída por **EMIC-Discovery** y usada por **EMIC-Editor** para buscar, filtrar y categorizar componentes.

#### Parámetros

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `key` | string | ✅ | Nombre de la propiedad |
| `value` | string | ✅ | Valor de la propiedad |

#### Comportamiento

1. **Registra metadata** del componente
2. **EMIC-Discovery** lee estas tags
3. **Incluye en índice** de recursos
4. **EMIC-Editor** usa para búsqueda/filtrado
5. **NO afecta** la generación de código

#### Tags Comunes

| Tag | Descripción | Ejemplo |
|-----|-------------|---------|
| `driverName` | Nombre del driver/componente | `TIMER`, `UART`, `LEDs` |
| `category` | Categoría del componente | `Communication`, `Indicators` |
| `version` | Versión del componente | `1.0.2`, `2.1.0` |
| `author` | Autor del componente | `EMIC Teams` |
| `requiresMCU` | MCUs soportados | `PIC24,PIC32` |
| `requiresPeripheral` | Periféricos necesarios | `SPI,I2C` |

#### Ejemplos del SDK

**Ejemplo 1: Tag simple**
```emic
EMIC:tag(driverName = LEDs)
```

**Ejemplo 2: Múltiples tags**
```emic
EMIC:tag(driverName = TIMER)
EMIC:tag(category = System)
EMIC:tag(version = 1.0.2)
EMIC:tag(author = EMIC Teams)
```

**Ejemplo 3: Tag en LED API**
```emic
EMIC:tag(driverName = LEDs)

/**
* @fn void LEDs_.{name}._state(uint8_t state);
* @alias .{name}..state
* @brief Change the state of the led
*/

// Resto del código...
```

**Ejemplo 4: Tag en driver UART**
```emic
EMIC:tag(driverName = UART)
EMIC:tag(category = Communication)
EMIC:tag(requiresPeripheral = UART)
```

**Ejemplo 5: Tag en main.emic**
```emic
EMIC:tag(driverName = SYSTEM)
```

#### Casos de Uso

1. **Identificar componente** para EMIC-Discovery
2. **Categorización** en EMIC-Editor
3. **Búsqueda y filtrado** de componentes
4. **Versionado** de componentes
5. **Documentación automática**

#### Errores Comunes

**❌ Error: Usar comillas**
```emic
EMIC:tag("driverName" = "UART")  // ❌ No usar comillas
```
**✅ Correcto:**
```emic
EMIC:tag(driverName = UART)  // ✅ Sin comillas
```

**❌ Error: Usar `:` en lugar de `=`**
```emic
EMIC:tag(driverName: UART)  // ❌ Usar =
```
**✅ Correcto:**
```emic
EMIC:tag(driverName = UART)  // ✅ Con =
```

---

## Directivas Especiales

### `EMIC:json` - Metadata JSON (Raro)

#### Descripción

En algunos archivos antiguos del SDK, se encuentra una directiva `EMIC:json` que parece contener metadata en formato JSON. **Su uso es poco común** y posiblemente obsoleto en favor de `EMIC:tag`.

#### Ejemplo encontrado

```emic
/*RFI JSon
{
    'Nombre': 'esIgualN',
    'NombreToolBox':  '(•=•)?',
    'Tipo' : 'SistemFnc',
    'title': 'Return 1 is Equal or 0 if not ',
    'FunctionReturn': ['1','0'],
    'FunctioNParametros': '2'
}
*/
```

**Nota:** Este formato está embebido en comentarios C y procesado por herramientas auxiliares, NO es una directiva EMIC: estándar.

---

## Tabla de Referencia Rápida

### Cheat Sheet de Directivas

| Directiva | Sintaxis | Uso Principal | Ejemplo Corto |
|-----------|----------|---------------|---------------|
| **define** | `EMIC:define(var, val)` | Definir variable global | `EMIC:define(name, led1)` |
| **unDefine** | `EMIC:unDefine(var)` | Eliminar variable | `EMIC:unDefine(c_modules.uart1)` |
| **setInput** | `EMIC:setInput(file, p=v)` | Incluir archivo | `EMIC:setInput(DEV:_api/led.emic, name=led1)` |
| **copy** | `EMIC:copy(src > dst, p=v)` | Copiar con sustitución | `EMIC:copy(led.c > led_.{n}..c, n=.{n}.)` |
| **setOutput** | `EMIC:setOutput(file)` | Redirigir salida | `EMIC:setOutput(TARGET:out.c)` |
| **restoreOutput** | `EMIC:restoreOutput` | Restaurar salida | `EMIC:restoreOutput` |
| **ifdef** | `EMIC:ifdef var ... EMIC:endif` | Si definida | `EMIC:ifdef USE_UART ... EMIC:endif` |
| **ifndef** | `EMIC:ifndef var ... EMIC:endif` | Si NO definida | `EMIC:ifndef GUARD_ ... EMIC:endif` |
| **endif** | `EMIC:endif` | Cerrar condicional | `EMIC:endif` |
| **foreach** | `EMIC:foreach(col.*)` | Iterar colección | `EMIC:foreach(sensores.*)` |
| **endforeach** | `EMIC:endforeach` | Cerrar iteración | `EMIC:endforeach` |
| **tag** | `EMIC:tag(key = val)` | Metadata | `EMIC:tag(driverName = LEDs)` |

### Cheat Sheet de Expansión Inline

| Sintaxis | Resultado | Ejemplo |
|----------|-----------|---------|
| `.{col.*}.` | N líneas (una por key) | `.{canales.*}.` → una línea por canal |
| `.{col.*}. .[sep].` | 1 línea con separador | `.{canales.*}. .[, ].` → `ch0, ch1, ch2` |
| `.{c1.c2.*}.` | N líneas (3er nivel) | `.{hw.uart.*}.` → una línea por propiedad |
| `.{c1.*.key}.` | N líneas (comodín medio) | `.{hw.*.speed}.` → una línea por periférico |
| `.{c1.*.*}.` | N×M líneas (doble comodín) | `.{hw.*.*}.` → todas las propiedades de todos |

---

### Tabla de Frecuencia de Uso

| Directiva | Uso en SDK | Contexto Típico |
|-----------|------------|-----------------|
| `ifndef` + `define` + `endif` | ⭐⭐⭐⭐⭐ | Include guards (inicio de cada .emic) |
| `setInput` | ⭐⭐⭐⭐⭐ | Incluir componentes (usado en todo el SDK) |
| `copy` | ⭐⭐⭐⭐⭐ | Generar archivos C/H (cada componente) |
| `define` | ⭐⭐⭐⭐⭐ | Configuración global, módulos compilación |
| `setOutput` + `restoreOutput` | ⭐⭐⭐⭐ | Generar archivos, logging |
| `ifdef` | ⭐⭐⭐⭐ | Features opcionales, eventos |
| `foreach` + `endforeach` | ⭐⭐⭐⭐ | Iterar colecciones, generación masiva |
| `.{col.*}.` (inline) | ⭐⭐⭐⭐ | Expansión rápida en una línea |
| `.{col.*}. .[sep].` (join) | ⭐⭐⭐ | Enums, listas de argumentos |
| `tag` | ⭐⭐⭐ | Inicio de APIs/Drivers |
| `unDefine` | ⭐⭐ | Cleanup de variables temporales |

---

## Árbol de Decisión

### ¿Qué Directiva Usar?

```
¿Qué quieres hacer?
│
├─ Definir una variable global
│   └─→ EMIC:define(nombre, valor)
│
├─ Eliminar una variable
│   └─→ EMIC:unDefine(nombre)
│
├─ Incluir otro archivo .emic
│   └─→ EMIC:setInput(archivo, param=val)
│
├─ Copiar archivo con sustituciones
│   └─→ EMIC:copy(origen > destino, param=val)
│
├─ Generar archivo C directamente
│   └─→ EMIC:setOutput(archivo)
│       ... contenido C ...
│       EMIC:restoreOutput
│
├─ Prevenir inclusión duplicada
│   └─→ EMIC:ifndef GUARD_
│       EMIC:define(GUARD_, true)
│       ... código ...
│       EMIC:endif
│
├─ Incluir algo condicionalmente
│   ├─ Si variable ESTÁ definida
│   │   └─→ EMIC:ifdef VAR
│   │       ... código ...
│   │       EMIC:endif
│   │
│   └─ Si variable NO está definida
│       └─→ EMIC:ifndef VAR
│           ... código ...
│           EMIC:endif
│
├─ Iterar sobre una colección
│   ├─ Multilínea (bloque por cada key)
│   │   └─→ EMIC:foreach(col.*)
│   │       ... bloque con .{*}. y {*} ...
│   │       EMIC:endforeach
│   │
│   ├─ Una línea por key (inline)
│   │   └─→ texto .{col.*}. texto
│   │
│   └─ Una sola línea con separador (join)
│       └─→ texto .{col.*}. .[sep]. texto
│
└─ Etiquetar componente para EMIC-Discovery
    └─→ EMIC:tag(driverName = MiComponente)
```

---

## Errores Comunes

### Top 10 Errores Más Frecuentes

#### 1. Olvidar `EMIC:endif`

**Síntoma:** Error de parsing, directivas subsecuentes fallan

**Causa:**
```emic
EMIC:ifdef USE_UART
    EMIC:setInput(DEV:_hal/UART/uart.emic)
// ❌ Falta EMIC:endif
```

**Solución:**
```emic
EMIC:ifdef USE_UART
    EMIC:setInput(DEV:_hal/UART/uart.emic)
EMIC:endif  // ✅ Siempre cerrar
```

---

#### 2. Olvidar `EMIC:restoreOutput`

**Síntoma:** Todo el output subsecuente va al archivo equivocado

**Causa:**
```emic
EMIC:setOutput(TARGET:file.c)
    // contenido
// ❌ Falta EMIC:restoreOutput
```

**Solución:**
```emic
EMIC:setOutput(TARGET:file.c)
    // contenido
EMIC:restoreOutput  // ✅ Siempre restaurar
```

---

#### 3. Usar comillas en parámetros

**Síntoma:** Variables literales con comillas en código generado

**Causa:**
```emic
EMIC:define("name", "led1")  // ❌
EMIC:setInput(DEV:_api/led.emic, name="led1")  // ❌
```

**Solución:**
```emic
EMIC:define(name, led1)  // ✅ Sin comillas
EMIC:setInput(DEV:_api/led.emic, name=led1)  // ✅
```

---

#### 4. Incluir `.{}` en nombre de variable en define

**Síntoma:** Variable no se sustituye correctamente

**Causa:**
```emic
EMIC:define(.{name}., led1)  // ❌
```

**Solución:**
```emic
EMIC:define(name, led1)  // ✅ Sin delimitadores
// Usar como: .{name}.
```

---

#### 5. Usar `=` en lugar de `>` en EMIC:copy

**Síntoma:** Error de sintaxis

**Causa:**
```emic
EMIC:copy(src/led.c = TARGET:led.c)  // ❌
```

**Solución:**
```emic
EMIC:copy(src/led.c > TARGET:led.c)  // ✅ Usar >
```

---

#### 6. Asumir que variables locales se propagan

**Síntoma:** Variables undefined en archivos incluidos

**Causa:**
```emic
// En generate.emic
EMIC:setInput(DEV:_api/led.emic, name=led1, pin=A0)

// En led.emic
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
// ❌ .{name}. y .{pin}. NO están disponibles en gpio.emic
```

**Solución:**
```emic
// En led.emic - propagar explícitamente
EMIC:setInput(DEV:_hal/GPIO/gpio.emic, pin=.{pin}.)  // ✅
```

---

#### 7. Ruta absoluta en lugar de volumen lógico

**Síntoma:** Error "File not found"

**Causa:**
```emic
EMIC:setInput(C:/SDK/_api/led.emic)  // ❌
```

**Solución:**
```emic
EMIC:setInput(DEV:_api/led.emic)  // ✅ Volumen lógico
```

---

#### 8. No pasar parámetros de sustitución en EMIC:copy

**Síntoma:** Variables aparecen literales (`.{name}.`) en código C

**Causa:**
```emic
EMIC:copy(src/led.c > TARGET:led_.{name}..c)
// ❌ .{name}. en el contenido no se sustituirá
```

**Solución:**
```emic
EMIC:copy(src/led.c > TARGET:led_.{name}..c, name=.{name}.)
// ✅ Ahora sí se sustituye
```

---

#### 9. Include guard con nombre equivocado

**Síntoma:** Componente incluido múltiples veces

**Causa:**
```emic
// En uart_driver.emic
EMIC:ifndef GPIO_DRIVER_EMIC_  // ❌ Nombre equivocado
EMIC:define(GPIO_DRIVER_EMIC_, true)
    // código UART
EMIC:endif
```

**Solución:**
```emic
// En uart_driver.emic
EMIC:ifndef UART_DRIVER_EMIC_  // ✅ Nombre correcto
EMIC:define(UART_DRIVER_EMIC_, true)
    // código UART
EMIC:endif
```

---

#### 10. Esperar evaluación de expresiones en define

**Síntoma:** Variables contienen expresiones sin evaluar

**Causa:**
```emic
EMIC:define(result, 10 + 5)
// ❌ Guarda "10 + 5" como string, NO calcula 15
```

**Solución:**
```emic
EMIC:define(result, 15)  // ✅ Calcular manualmente
```

---

## Resumen del Capítulo

### Puntos Clave

1. **12 Directivas Principales:**
   - `define`, `unDefine`, `setInput`, `copy` (gestión de datos y archivos)
   - `setOutput`, `restoreOutput` (generación de archivos)
   - `ifdef`, `ifndef`, `endif` (condicionales)
   - `foreach`, `endforeach` (iteración sobre colecciones)
   - `tag` (metadata)

2. **Patrones Esenciales:**
   - Include Guard: `ifndef` + `define` + `endif`
   - Multi-Instancia: `setInput` múltiples veces
   - Copia Parametrizada: `copy` con sustituciones
   - Iteración: `foreach` / `endforeach` para colecciones
   - Expansión Inline: `.{col.*}.` para una línea por key
   - Expansión Join: `.{col.*}. .[sep].` para una sola línea

3. **Reglas de Oro:**
   - Siempre cerrar condicionales (`endif`) y foreach (`endforeach`)
   - Siempre restaurar salida (`restoreOutput`)
   - Nunca usar comillas en parámetros
   - Propagar variables locales explícitamente

4. **Usos Más Comunes:**
   - `ifndef` + `define` → Include guards
   - `setInput` → Incluir componentes
   - `copy` → Generar archivos C/H
   - `define` → Configuración global
   - `foreach` → Iterar colecciones de módulos/periféricos
   - `.{col.*}. .[, ].` → Generar enums, listas

### Referencia Visual

```
┌─────────────────────────────────────────┐
│       DIRECTIVAS EMIC-CODIFY            │
├─────────────────────────────────────────┤
│                                         │
│  DEFINICIÓN                             │
│  ├─ EMIC:define                         │
│  └─ EMIC:unDefine                       │
│                                         │
│  INCLUSIÓN                              │
│  ├─ EMIC:setInput                       │
│                                         │
│  COPIA                                  │
│  ├─ EMIC:copy                           │
│                                         │
│  REDIRECCIÓN                            │
│  ├─ EMIC:setOutput                      │
│  └─ EMIC:restoreOutput                  │
│                                         │
│  CONDICIONALES                          │
│  ├─ EMIC:ifdef                          │
│  ├─ EMIC:ifndef                         │
│  └─ EMIC:endif                          │
│                                         │
│  ITERACIÓN                              │
│  ├─ EMIC:foreach                        │
│  └─ EMIC:endforeach                     │
│                                         │
│  EXPANSIÓN INLINE                       │
│  ├─ .{col.*}.          (multilínea)     │
│  └─ .{col.*}. .[sep].  (join)          │
│                                         │
│  METADATA                               │
│  └─ EMIC:tag                            │
│                                         │
└─────────────────────────────────────────┘
```

### Próximo Capítulo

El **Capítulo 19** cubrirá el **Sistema de Módulos y Templates**, mostrando cómo crear componentes reutilizables usando estas directivas.

---

**Fin del Capítulo 18**

**Progreso del Manual:**
- **Sección 1 (Introducción):** ████████████████████ 100% (5/5) ✅
- **Sección 2 (Estructura SDK):** ████████████████████ 100% (11/11) ✅
- **Sección 3 (EMIC-Codify):** ████████████████░░░░  60% (3/5)

**Progreso Total: 18/38 capítulos (47.37%)**

---

**Referencias:**
- Capítulo 16: Introducción a EMIC-Codify
- Capítulo 17: Sintaxis Avanzada de EMIC-Codify
