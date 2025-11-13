# Capítulo 16: Introducción a EMIC-Codify

## Índice
1. [Introducción](#introducción)
2. [¿Qué es EMIC-Codify?](#qué-es-emic-codify)
3. [Rol en el Flujo de Desarrollo](#rol-en-el-flujo-de-desarrollo)
4. [Características Principales](#características-principales)
5. [Tipos de Archivos .emic](#tipos-de-archivos-emic)
6. [Sintaxis Básica](#sintaxis-básica)
7. [Volúmenes Lógicos](#volúmenes-lógicos)
8. [Directivas EMIC: Principales](#directivas-emic-principales)
9. [Variables y Sustituciones](#variables-y-sustituciones)
10. [Ejemplo Completo: generate.emic](#ejemplo-completo-generateemic)
11. [Proceso de Compilación](#proceso-de-compilación)
12. [Comparación con Otros Lenguajes](#comparación-con-otros-lenguajes)
13. [Buenas Prácticas](#buenas-prácticas)
14. [Resumen del Capítulo](#resumen-del-capítulo)

---

## Introducción

**EMIC-Codify** es el lenguaje de scripting que impulsa el SDK EMIC. Es el **puente entre el código reutilizable del SDK y la lógica específica del integrador**, permitiendo crear firmware personalizado mediante la fusión de componentes preexistentes con configuraciones dinámicas.

A diferencia de lenguajes de programación tradicionales, EMIC-Codify es un **lenguaje de procesamiento de texto** que:
- No se compila directamente a binario
- Se procesa por **EMIC-Generate** para producir código C
- Permite parametrización dinámica mediante variables
- Facilita la reutilización mediante templates

Este capítulo introduce los conceptos fundamentales de EMIC-Codify, necesarios para entender cómo el SDK fusiona componentes y genera código compilable.

---

## ¿Qué es EMIC-Codify?

**EMIC-Codify** es un **lenguaje de scripting de procesamiento de texto** diseñado específicamente para el SDK EMIC. Su propósito principal es **fusionar código del SDK con configuraciones del integrador** para generar código C compilable.

### Definición Formal

> **EMIC-Codify** es un lenguaje declarativo basado en directivas que permite:
> 1. Incluir archivos de forma paramétrica
> 2. Copiar y transformar código con sustituciones de variables
> 3. Definir configuraciones dinámicas
> 4. Controlar el flujo de generación mediante condicionales

### Características Clave

1. **Lenguaje de macros**
   - Procesa texto, no ejecuta lógica
   - Realiza sustituciones de variables
   - Genera código C como salida

2. **Paramétrico**
   - Variables tipo `.{name}.`, `.{pin}.`, `.{system.*}.`
   - Sustitución dinámica en tiempo de generación
   - Permite instancias múltiples del mismo componente

3. **Jerárquico**
   - Archivos .emic incluyen otros archivos .emic
   - Estructura en capas (módulos → APIs → drivers → HAL → _hard)
   - Resolución recursiva de dependencias

4. **Basado en volúmenes lógicos**
   - `DEV:` (código del SDK)
   - `TARGET:` (código generado)
   - `SYS:` (archivos del sistema de compilación)
   - `USER:` (archivos del integrador)

---

## Rol en el Flujo de Desarrollo

### El Problema que Resuelve

**Sin EMIC-Codify:**
```c
// Desarrollador debe escribir todo manualmente
void init_led1() {
    TRISAbits.TRISA0 = 0;  // Pin específico hardcodeado
}

void init_led2() {
    TRISAbits.TRISA1 = 0;  // Duplicación de código
}
```

**Con EMIC-Codify:**
```emic
// En generate.emic
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led1,pin=A0_Pin)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led2,pin=A1_Pin)

// En led.emic (template reutilizable)
EMIC:copy(src/led.c > TARGET:led_.{name}..c,name=.{name}.,pin=.{pin}.)
```

**Resultado: Código C generado automáticamente con parametrización correcta.**

---

### Flujo de Desarrollo EMIC

```
┌─────────────────────────────────────────────────────────────┐
│                   DESARROLLADOR (SDK)                       │
└─────────────────────────────────────────────────────────────┘
        │
        │ Crea componentes reutilizables en C + EMIC-Codify
        ↓
┌─────────────────────────────────────────────────────────────┐
│          SDK EMIC (_api, _drivers, _hal, _hard)            │
│   - Archivos .emic con templates parametrizados            │
│   - Código C con anotaciones DOXYGEN                        │
│   - Variables tipo .{name}., .{pin}.                        │
└─────────────────────────────────────────────────────────────┘
        │
        │ EMIC-Discovery extrae recursos publicados
        ↓
┌─────────────────────────────────────────────────────────────┐
│              ÍNDICE DE RECURSOS (JSON)                      │
└─────────────────────────────────────────────────────────────┘
        │
        │ Integrador ve recursos disponibles
        ↓
┌─────────────────────────────────────────────────────────────┐
│          INTEGRADOR (EMIC-Editor)                           │
│   - Selecciona módulos y APIs                               │
│   - Configura parámetros (pins, nombres, etc.)             │
│   - Programa lógica visual                                  │
└─────────────────────────────────────────────────────────────┘
        │
        │ Genera generate.emic y userFncFile.c
        ↓
┌─────────────────────────────────────────────────────────────┐
│            EMIC-GENERATE (Compilador EMIC)                  │
│   - Procesa generate.emic                                   │
│   - Expande directivas EMIC:                                │
│   - Sustituye variables .{name}., .{pin}.                   │
│   - Genera código C completo                                │
└─────────────────────────────────────────────────────────────┘
        │
        │ Código C fusionado (SDK + lógica integrador)
        ↓
┌─────────────────────────────────────────────────────────────┐
│         COMPILADOR C (XC8/XC16/XC32)                        │
└─────────────────────────────────────────────────────────────┘
        │
        ↓
    Firmware.hex
```

---

## Características Principales

### 1. Procesamiento de Texto, No Ejecución

EMIC-Codify **NO ejecuta código**, solo procesa texto:

```emic
// Esto NO es una operación aritmética
EMIC:define(value, 10 + 5)  // Guarda el STRING "10 + 5"

// Para que sea aritmética, debe estar en C generado:
EMIC:setOutput(TARGET:test.c)
    int result = 10 + 5;  // Esto SÍ es C que se compilará
EMIC:restoreOutput
```

---

### 2. Sustitución de Variables

Las variables se definen con `.{nombre}.` y se sustituyen en tiempo de generación:

```emic
// Definir parámetros
// name=led1, pin=A0_Pin

// Usar en template
void init_.{name}.() {
    HAL_GPIO_PinCfg(.{pin}., OUTPUT);
}

// Resultado después de EMIC-Generate
void init_led1() {
    HAL_GPIO_PinCfg(A0_Pin, OUTPUT);
}
```

---

### 3. Inclusión Paramétrica de Archivos

```emic
// Incluir LED con parámetros específicos
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led1,pin=A0_Pin)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led2,pin=A1_Pin)

// Cada inclusión usa el mismo template pero con diferentes parámetros
```

---

### 4. Copia con Transformación

```emic
// Copiar archivo y sustituir variables en su contenido
EMIC:copy(
    DEV:_api/src/led.c > TARGET:led_.{name}..c,
    name=.{name}.,
    pin=.{pin}.
)

// Resultado:
// - Copia DEV:_api/src/led.c
// - Renombra a TARGET:led_led1.c
// - Sustituye todas las ocurrencias de .{name}. y .{pin}.
```

---

### 5. Condicionales en Tiempo de Generación

```emic
EMIC:ifdef USE_UART
    EMIC:setInput(DEV:_hal/UART/uart.emic)
EMIC:endif

EMIC:ifndef DISABLE_LCD
    EMIC:setInput(DEV:_api/LCD/lcd.emic)
EMIC:endif
```

---

## Tipos de Archivos .emic

El SDK EMIC usa archivos con extensión `.emic` para diferentes propósitos:

### 1. `generate.emic` - Script de Generación Principal

**Ubicación:** `System/generate.emic` (en cada módulo)

**Propósito:** Define qué componentes del SDK se incluyen y cómo se configuran.

**Contenido típico:**
```emic
EMIC:setOutput(TARGET:generate.txt)

    // Hardware Config
    EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_Development_Board)

    // APIs
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led1,pin=A0_Pin)
    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)

    // Main
    EMIC:setInput(DEV:_main/baremetal/main.emic)

    // Copy user code
    EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)

    // Add project template
    EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

---

### 2. `deploy.emic` - Script de Deployment

**Ubicación:** `System/deploy.emic` (en cada módulo)

**Propósito:** Define cómo deployar el firmware compilado al hardware.

**Contenido típico:**
```emic
// Configurar programador
EMIC:define(programmer, pickit3)
EMIC:define(device, .{system.ucName}.)

// Comando de programación
EMIC:shell(
    ipecmd.exe
    -P.{device}.
    -TPPK3
    -F"TARGET:Firmware.hex"
    -M -OL
)
```

---

### 3. Archivos .emic de Componentes (APIs, Drivers, HAL)

**Ubicación:** Dispersos en `_api/`, `_drivers/`, `_hal/`

**Propósito:** Templates parametrizados de componentes reutilizables.

**Ejemplo - `led.emic`:**
```emic
EMIC:tag(driverName = LEDs)

/**
* @fn void LEDs_.{name}._state(uint8_t state);
* @alias .{name}..state
* @brief Change the state of the led
*/

EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

EMIC:copy(inc/led.h > TARGET:inc/led_.{name}..h,name=.{name}.,pin=.{pin}.)
EMIC:copy(src/led.c > TARGET:led_.{name}..c,name=.{name}.,pin=.{pin}.)

EMIC:define(main_includes.led_.{name}.,led_.{name}.)
EMIC:define(c_modules.led_.{name}.,led_.{name}.)
```

---

### 4. Archivos .emic de Configuración (PCB, System)

**Ejemplo - `pcb.emic`:**
```emic
EMIC:ifdef pcb
    EMIC:setInput(DEV:_pcb/inc/.{pcb}..h)
    EMIC:define(system.ucName, .{system.ucName}.)
EMIC:endif
```

---

## Sintaxis Básica

### Comentarios

```emic
// Comentario de una línea

/*
   Comentario
   multi-línea
*/
```

**Nota:** Los comentarios en archivos .emic NO se copian al código C generado (a menos que estén dentro de un bloque EMIC:copy).

---

### Directivas EMIC:

Todas las directivas comienzan con `EMIC:` seguido del nombre de la directiva:

```emic
EMIC:define(variable, valor)
EMIC:setInput(ruta_archivo, param1=valor1, param2=valor2)
EMIC:copy(origen > destino, param1=valor1)
EMIC:setOutput(archivo_destino)
EMIC:restoreOutput
```

---

### Variables

**Definición:**
```emic
EMIC:define(led_name, SystemLED)
EMIC:define(led_pin, A0_Pin)
```

**Uso (sustitución):**
```emic
void init_.{led_name}.() {
    HAL_GPIO_PinCfg(.{led_pin}., OUTPUT);
}
```

**Resultado después de procesamiento:**
```c
void init_SystemLED() {
    HAL_GPIO_PinCfg(A0_Pin, OUTPUT);
}
```

---

### Variables Locales vs Globales

**Variables locales (scope limitado):**
```emic
// Parámetros pasados en setInput son locales
EMIC:setInput(DEV:_api/led.emic, name=led1, pin=A0)

// Dentro de led.emic:
// .{name}. = led1 (local)
// .{pin}. = A0 (local)
```

**Variables globales (scope total):**
```emic
// Definidas con EMIC:define
EMIC:define(system.ucName, pic24FJ64GA002)

// Disponible en cualquier archivo .emic procesado después:
// .{system.ucName}. = pic24FJ64GA002
```

---

## Volúmenes Lógicos

EMIC-Codify utiliza **volúmenes lógicos** para abstraer las rutas del sistema de archivos:

### Volúmenes Disponibles

| Volumen | Descripción | Ruta Física Típica | Uso |
|---------|-------------|-------------------|-----|
| `DEV:` | Código del SDK | `.../EMIC_IA_M/` | Archivos fuente del SDK |
| `TARGET:` | Código generado | `Module/Target/` | Salida de EMIC-Generate |
| `SYS:` | Sistema de compilación | `Module/System/` | Scripts, configs, user code |
| `USER:` | Archivos del integrador | `USER:/My Projects/` | Proyectos del usuario |

---

### Uso de Volúmenes

```emic
// Leer del SDK
EMIC:setInput(DEV:_api/Timers/timer_api.emic)

// Escribir a Target
EMIC:copy(inc/timer.h > TARGET:inc/timer.h)

// Copiar código del integrador
EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
```

---

### Ventajas de los Volúmenes

1. **Portabilidad:** El mismo script funciona en Windows, Linux, macOS
2. **Simplicidad:** No es necesario conocer rutas absolutas
3. **Seguridad:** Limita acceso a áreas específicas del filesystem
4. **Claridad:** Indica el origen/destino de cada archivo

---

## Directivas EMIC: Principales

### 1. `EMIC:define` - Definir Variables

**Sintaxis:**
```emic
EMIC:define(nombre_variable, valor)
```

**Ejemplo:**
```emic
EMIC:define(system.ucName, pic24FJ64GA002)
EMIC:define(system.clockFreq, 32000000)
EMIC:define(c_modules.led, led)
```

**Uso posterior:**
```emic
// La variable está disponible como .{nombre_variable}.
EMIC:setInput(DEV:_hard/.{system.ucName}./GPIO/gpio.emic)
```

---

### 2. `EMIC:setInput` - Incluir Archivo

**Sintaxis:**
```emic
EMIC:setInput(ruta_archivo)
EMIC:setInput(ruta_archivo, param1=valor1, param2=valor2, ...)
```

**Ejemplo sin parámetros:**
```emic
EMIC:setInput(DEV:_main/baremetal/main.emic)
```

**Ejemplo con parámetros:**
```emic
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=led1, pin=A0_Pin)
```

**Efecto:**
- Procesa el archivo especificado
- Los parámetros se convierten en variables locales dentro del archivo incluido
- Es recursivo: el archivo incluido puede incluir otros archivos

---

### 3. `EMIC:copy` - Copiar y Sustituir

**Sintaxis:**
```emic
EMIC:copy(origen > destino)
EMIC:copy(origen > destino, param1=valor1, param2=valor2, ...)
```

**Ejemplo básico:**
```emic
// Copiar sin modificar
EMIC:copy(DEV:_templates/Makefile > TARGET:Makefile)
```

**Ejemplo con sustituciones:**
```emic
// Copiar y sustituir variables en el contenido
EMIC:copy(
    inc/led.h > TARGET:inc/led_.{name}..h,
    name=.{name}.,
    pin=.{pin}.
)
```

**Efecto:**
1. Lee archivo origen
2. Sustituye todas las ocurrencias de los parámetros
3. Escribe resultado en archivo destino

---

### 4. `EMIC:setOutput` y `EMIC:restoreOutput` - Redirigir Salida

**Sintaxis:**
```emic
EMIC:setOutput(archivo_destino)
    // Todo el contenido aquí se escribe en archivo_destino
    int main() {
        // código C
    }
EMIC:restoreOutput
```

**Ejemplo:**
```emic
EMIC:setOutput(TARGET:main.c)
    #include <xc.h>

    int main() {
        init();
        while(1) {
            poll();
        }
    }
EMIC:restoreOutput
```

**Uso típico:** Generar archivos C directamente desde el script .emic.

---

### 5. `EMIC:ifdef` / `EMIC:ifndef` / `EMIC:endif` - Condicionales

**Sintaxis:**
```emic
EMIC:ifdef VARIABLE_NAME
    // Código si VARIABLE_NAME está definida
EMIC:endif

EMIC:ifndef VARIABLE_NAME
    // Código si VARIABLE_NAME NO está definida
EMIC:endif
```

**Ejemplo:**
```emic
EMIC:ifndef UART_DRIVER_EMIC_
EMIC:define(UART_DRIVER_EMIC_, true)
    EMIC:setInput(DEV:_hal/UART/uart.emic)
EMIC:endif
```

**Uso típico:** Evitar inclusiones duplicadas (patrón include guard).

---

### 6. `EMIC:tag` - Etiquetar Recursos (EMIC-Discovery)

**Sintaxis:**
```emic
EMIC:tag(clave = valor)
```

**Ejemplo:**
```emic
EMIC:tag(driverName = LEDs)
EMIC:tag(category = Indicators)
EMIC:tag(version = 1.0.2)
```

**Efecto:** EMIC-Discovery lee estos tags y los incluye en el índice de recursos. Los integradores pueden filtrar/buscar por estos tags.

---

## Variables y Sustituciones

### Sintaxis de Variables

**Formato:** `.{nombre_variable}.`

**Características:**
- Delimitadores: `.{` y `}.`
- Sensible a mayúsculas/minúsculas
- Puede contener puntos: `.{system.ucName}.`
- Se sustituyen en tiempo de procesamiento EMIC-Generate

---

### Tipos de Variables

#### 1. Variables de Sistema

Definidas por EMIC-Generate o por el SDK:

```emic
.{system.ucName}.        // Nombre del microcontrolador (ej: pic24FJ64GA002)
.{system.clockFreq}.     // Frecuencia del reloj (ej: 32000000)
.{system.compiler}.      // Compilador usado (ej: XC16)
```

---

#### 2. Variables de Parámetros Locales

Pasadas en `EMIC:setInput`:

```emic
EMIC:setInput(DEV:_api/led.emic, name=led1, pin=A0_Pin)

// Dentro de led.emic:
// .{name}. → led1
// .{pin}. → A0_Pin
// .{local.name}. → led1 (alias explícito)
```

---

#### 3. Variables Definidas por Usuario

Creadas con `EMIC:define`:

```emic
EMIC:define(MY_CONSTANT, 1000)
EMIC:define(BUFFER_SIZE, 512)

// Uso:
#define BUFFER_SIZE .{BUFFER_SIZE}.
```

---

### Sustitución Anidada

Las variables pueden contener otras variables:

```emic
EMIC:define(prefix, led_)
EMIC:define(name, sensor1)
EMIC:define(full_name, .{prefix}..{name}.)

// .{full_name}. → led_sensor1
```

---

### Sustitución en Nombres de Archivo

```emic
// Variable: name=uart1

EMIC:copy(src/uart.c > TARGET:uart_.{name}..c)

// Resultado: TARGET:uart_uart1.c
```

---

### Ejemplo Completo de Sustituciones

**Archivo: led.emic**
```emic
// Parámetros recibidos: name=led1, pin=A0_Pin

EMIC:setOutput(TARGET:led_.{name}..c)
    #include "led_.{name}..h"

    void init_.{name}.() {
        HAL_GPIO_PinCfg(.{pin}., OUTPUT);
    }

    void .{name}._state(uint8_t state) {
        HAL_GPIO_PinSet(.{pin}., state);
    }
EMIC:restoreOutput
```

**Resultado generado: `TARGET:led_led1.c`**
```c
#include "led_led1.h"

void init_led1() {
    HAL_GPIO_PinCfg(A0_Pin, OUTPUT);
}

void led1_state(uint8_t state) {
    HAL_GPIO_PinSet(A0_Pin, state);
}
```

---

## Ejemplo Completo: generate.emic

Este es un ejemplo real de un archivo `generate.emic` completo:

```emic
EMIC:setOutput(TARGET:generate.txt)

    //-------------- Hardware Config ---------------------
    EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_Development_Board)

    //------------------- Process EMIC-Generate files result ----------------
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    //------------------- APIs -----------------------

    // LEDs
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led1,pin=A2_Pin)
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led4,pin=A1_Pin)
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led5,pin=A0_Pin)

    // Timers
    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)
    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=2)
    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=3)

    // USB Communication
    EMIC:setInput(DEV:_api/Wired_Communication/USB/USB_API.emic,driver=MCP2200,port=1,BufferSize=512,baud=9600,frameLf=\n,name=USB)

    // LCD Display
    EMIC:setInput(DEV:_api/Lavarropas/LCD/LCD_Api.emic)

    // Buttons/Selectors
    EMIC:setInput(DEV:_api/Lavarropas/Selector/buttons_api.emic,group1_pin=Buttons1,group2_pin=Buttons2,rotary_pin=RotarySW)

    // Zero Cross Detector for Triac
    EMIC:setInput(DEV:_api/Lavarropas/Motor/ZeroCross/zero_cross.emic,name=MOTOR,pin=ZC_IN,cn=1)

    // Triac Controller
    EMIC:setInput(DEV:_api/Lavarropas/Motor/TriacControl/triac_control.emic,name=MOTOR,pin=TRIAC_GATE,timer_delay=2,timer_pulse=5)

    // RPM Sensor
    EMIC:setInput(DEV:_api/Lavarropas/Motor/RPM/rpm_motor.emic,pin_name=RPM_PIN)

    // RPM Controller
    EMIC:setInput(DEV:_api/Lavarropas/Motor/Controller/rpm_controller.emic,name=motor1)

    // Temperature Sensor
    EMIC:setInput(DEV:_api/Lavarropas/Temperatura/temp_sensor.emic,temp_pin=NTC_PIN)

    //-------------------- main  -----------------------
    EMIC:setInput(DEV:_main/baremetal/main.emic)

    //------------------- Copy EMIC-Generate files result ----------------
    EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
    EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)

    //------------------- Set userFncFile.c as a compiler module ----------------
    EMIC:define(c_modules.userFncFile,userFncFile)

    //------------------- Add all compiler modules to the project ----------------
    EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

### Análisis del Ejemplo

**1. Redirección de salida:**
```emic
EMIC:setOutput(TARGET:generate.txt)
```
Todo el procesamiento se registra en `TARGET:generate.txt`.

**2. Configuración de hardware:**
```emic
EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_Development_Board)
```
Carga la configuración del PCB (pins, microcontrolador, etc.).

**3. Inclusión de APIs:**
```emic
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led1,pin=A2_Pin)
```
Instancia un LED con nombre `led1` conectado al pin `A2_Pin`.

**4. Múltiples instancias del mismo componente:**
```emic
EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)
EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=2)
EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=3)
```
Tres timers independientes (`timer1`, `timer2`, `timer3`).

**5. Inclusión del main:**
```emic
EMIC:setInput(DEV:_main/baremetal/main.emic)
```
Genera el punto de entrada del firmware.

**6. Copia del código del integrador:**
```emic
EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
```
Incluye el código escrito por el integrador en EMIC-Editor.

**7. Definición de módulos a compilar:**
```emic
EMIC:define(c_modules.userFncFile,userFncFile)
```
Registra `userFncFile.c` como módulo a compilar.

**8. Copia del template de proyecto:**
```emic
EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)
```
Copia Makefile, configuraciones, linker scripts.

---

## Proceso de Compilación

### Flujo Completo

```
┌──────────────────────────────────────────────────────────┐
│  1. INTEGRADOR crea proyecto en EMIC-Editor              │
│     - Selecciona módulos                                  │
│     - Configura parámetros (pins, nombres)               │
│     - Programa lógica visual                             │
└──────────────────────────────────────────────────────────┘
        ↓
┌──────────────────────────────────────────────────────────┐
│  2. EMIC-Editor genera:                                   │
│     - System/generate.emic                                │
│     - System/userFncFile.c                                │
│     - System/program.xml (código visual)                 │
└──────────────────────────────────────────────────────────┘
        ↓
┌──────────────────────────────────────────────────────────┐
│  3. EMIC-GENERATE procesa generate.emic                   │
│     - Expande EMIC:setInput recursivamente               │
│     - Sustituye variables .{name}., .{pin}.              │
│     - Ejecuta EMIC:copy con transformaciones             │
│     - Genera código C en Target/                         │
└──────────────────────────────────────────────────────────┘
        ↓
┌──────────────────────────────────────────────────────────┐
│  4. Código C generado en Target/                          │
│     - main.c                                             │
│     - led_led1.c, led_led2.c                             │
│     - timer_1.c, timer_2.c                               │
│     - userFncFile.c                                      │
│     - Makefile, linker scripts                           │
└──────────────────────────────────────────────────────────┘
        ↓
┌──────────────────────────────────────────────────────────┐
│  5. COMPILADOR C (XC8/XC16/XC32)                         │
│     - Compila todos los .c                               │
│     - Linkea binario final                               │
└──────────────────────────────────────────────────────────┘
        ↓
    Firmware.hex
```

---

### Ejemplo de Transformación

**Entrada: generate.emic**
```emic
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led1,pin=A0_Pin)
```

**Procesamiento:**
1. EMIC-Generate lee `DEV:_api/Indicators/LEDs/led.emic`
2. Establece variables locales: `name=led1`, `pin=A0_Pin`
3. Procesa el contenido de `led.emic`:
   ```emic
   EMIC:copy(src/led.c > TARGET:led_.{name}..c,name=.{name}.,pin=.{pin}.)
   ```
4. Ejecuta la copia:
   - Lee `DEV:_api/Indicators/LEDs/src/led.c`
   - Sustituye `.{name}.` → `led1`, `.{pin}.` → `A0_Pin`
   - Escribe `TARGET:led_led1.c`

**Salida: Target/led_led1.c**
```c
#include "led_led1.h"
#include "gpio.h"

void init_led1() {
    HAL_GPIO_PinCfg(A0_Pin, OUTPUT);
}

void led1_state(uint8_t state) {
    HAL_GPIO_PinSet(A0_Pin, state);
}

void led1_blink(uint16_t timeOn, uint16_t period, uint16_t times) {
    // implementación...
}
```

---

## Comparación con Otros Lenguajes

### EMIC-Codify vs Preprocessor C

| Aspecto | Preprocessor C (`#define`) | EMIC-Codify |
|---------|---------------------------|-------------|
| **Sintaxis** | `#define LED1 PIN_A0` | `EMIC:define(led1, PIN_A0)` |
| **Sustitución** | Token-based, limitada | String-based, completa |
| **Alcance** | Un solo archivo (.c/.h) | Múltiples archivos .emic |
| **Condicionales** | `#ifdef`, `#ifndef` | `EMIC:ifdef`, `EMIC:ifndef` |
| **Operaciones** | Macros complejas posibles | Solo sustitución de texto |
| **Cuando se procesa** | Durante compilación C | Antes de compilación (pre-pre-processing) |

---

### EMIC-Codify vs Templates C++

| Aspecto | Templates C++ | EMIC-Codify |
|---------|---------------|-------------|
| **Tipado** | Type-safe (verificado por compilador) | String-based (sin type checking) |
| **Instanciación** | Automática por compilador | Manual por integrador |
| **Flexibilidad** | Limitada a tipos/valores | Total (cualquier texto) |
| **Complejidad** | Alta (metaprogramación) | Baja (sustitución simple) |
| **Aplicabilidad** | Solo C++ | Cualquier lenguaje |

---

### EMIC-Codify vs CMake/Make

| Aspecto | CMake/Make | EMIC-Codify |
|---------|------------|-------------|
| **Propósito** | Automatizar compilación | Generar código + compilar |
| **Nivel** | Orquestación de build | Generación de código fuente |
| **Variables** | Variables de build | Variables de código |
| **Outputs** | Comandos de compilación | Código C fuente |
| **Relación** | EMIC-Codify genera Makefiles que CMake/Make ejecutan | - |

---

## Buenas Prácticas

### 1. Usar Include Guards en Componentes

```emic
EMIC:ifndef UART_DRIVER_EMIC_
EMIC:define(UART_DRIVER_EMIC_, true)

    EMIC:setInput(DEV:_hal/UART/uart.emic)

EMIC:endif
```

**Razón:** Evita inclusiones duplicadas cuando un componente es requerido por múltiples APIs.

---

### 2. Documentar Parámetros Esperados

```emic
/*****************************************************************************
  @file     led.emic
  @brief    LED API - Requires parameters: name, pin
  @author   EMIC Teams
  @version  1.0.2

  @param name  Name of the LED instance (ej: led1, SystemLED)
  @param pin   Physical pin name (ej: A0_Pin, Led1)
 ******************************************************************************/

EMIC:tag(driverName = LEDs)
```

---

### 3. Usar Variables de Sistema para Portabilidad

```emic
// ✅ BUENO: Usa variable de sistema
EMIC:setInput(DEV:_hard/.{system.ucName}./GPIO/gpio.emic)

// ❌ MALO: Hardcoded
EMIC:setInput(DEV:_hard/pic24FJ64GA002/GPIO/gpio.emic)
```

---

### 4. Separar Lógica en Múltiples Archivos .emic

**En lugar de:**
```emic
// Un solo archivo gigante con todo
EMIC:setOutput(TARGET:everything.c)
    // 1000 líneas de código...
EMIC:restoreOutput
```

**Preferir:**
```emic
// Múltiples archivos especializados
EMIC:setInput(DEV:_api/gpio_api.emic)
EMIC:setInput(DEV:_api/timer_api.emic)
EMIC:setInput(DEV:_api/uart_api.emic)
```

---

### 5. Usar Nombres Descriptivos para Variables

```emic
// ✅ BUENO
EMIC:define(uart_buffer_size, 512)
EMIC:define(system_led_name, StatusLED)

// ❌ MALO
EMIC:define(x, 512)
EMIC:define(a, StatusLED)
```

---

### 6. Comentar Scripts Complejos

```emic
//-------------- Hardware Config ---------------------
// Configure the PCB to use: HRD_Development_Board
// This sets up pin mappings and microcontroller selection
EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_Development_Board)

//------------------- APIs -----------------------
// LED indicators for system status
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led1,pin=A2_Pin)
```

---

### 7. Usar Tags para EMIC-Discovery

```emic
EMIC:tag(driverName = UART)
EMIC:tag(category = Communication)
EMIC:tag(version = 1.2.0)
EMIC:tag(author = EMIC Teams)
EMIC:tag(requiresMCU = PIC24,PIC32)
```

**Razón:** Facilita búsqueda y filtrado de componentes en EMIC-Editor.

---

## Resumen del Capítulo

### Puntos Clave

1. **EMIC-Codify es un lenguaje de procesamiento de texto**
   - NO ejecuta lógica, solo transforma texto
   - Procesa archivos .emic para generar código C
   - Usado por EMIC-Generate antes de la compilación

2. **Tres elementos principales:**
   - **Directivas:** `EMIC:define`, `EMIC:setInput`, `EMIC:copy`, etc.
   - **Variables:** `.{nombre}.` con sustitución en tiempo de generación
   - **Volúmenes:** `DEV:`, `TARGET:`, `SYS:`, `USER:`

3. **Tipos de archivos .emic:**
   - `generate.emic`: Script principal de generación
   - `deploy.emic`: Script de deployment
   - Componentes (.emic en _api, _drivers, _hal): Templates parametrizados

4. **Flujo de desarrollo:**
   - Desarrollador crea componentes con EMIC-Codify
   - Integrador selecciona y configura componentes
   - EMIC-Generate fusiona SDK + lógica integrador
   - Compilador C genera firmware final

5. **Ventajas:**
   - Reutilización de código mediante templates
   - Parametrización dinámica
   - Generación automática de código
   - Simplifica desarrollo embebido

### Directivas Principales

| Directiva | Propósito | Ejemplo |
|-----------|-----------|---------|
| `EMIC:define` | Definir variable | `EMIC:define(name, led1)` |
| `EMIC:setInput` | Incluir archivo | `EMIC:setInput(DEV:_api/led.emic)` |
| `EMIC:copy` | Copiar con sustitución | `EMIC:copy(src > target, name=led1)` |
| `EMIC:setOutput` | Redirigir salida | `EMIC:setOutput(TARGET:main.c)` |
| `EMIC:ifdef` | Condicional | `EMIC:ifdef USE_UART ... EMIC:endif` |
| `EMIC:tag` | Etiquetar recurso | `EMIC:tag(category = Indicators)` |

### Próximos Capítulos

En los siguientes capítulos de la Sección 3 profundizaremos en:
- **Capítulo 17:** Sintaxis avanzada de EMIC-Codify
- **Capítulo 18:** Directivas completas y casos de uso
- **Capítulo 19:** Sistema de módulos y templates
- **Capítulo 20:** Proceso completo de EMIC-Generate

---

**Fin del Capítulo 16**

**Progreso del Manual:**
- **Sección 1 (Introducción):** ████████████████████ 100% (5/5) ✅
- **Sección 2 (Estructura SDK):** ████████████████████ 100% (11/11) ✅
- **Sección 3 (EMIC-Codify):** ████░░░░░░░░░░░░░░░░  20% (1/5)

**Progreso Total: 16/38 capítulos (42.11%)**

---

**Referencias:**
- Capítulo 05: Visión General del SDK
- Capítulo 06: Carpeta `_modules/`
- Capítulo 11: Carpeta `_main/`
- EMIC-Manual-V4.1.1.md
