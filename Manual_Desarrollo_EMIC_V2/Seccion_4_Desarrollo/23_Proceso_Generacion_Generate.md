# Capítulo 23: Proceso de Generación (EMIC Generate)

## 23.1 Introducción

El proceso **EMIC Generate** es el corazón del sistema EMIC. Transforma los scripts `.emic` en código C compilable para microcontroladores PIC. Este capítulo explica en detalle cómo funciona este proceso, desde los archivos de entrada hasta el proyecto MPLAB X generado.

### ¿Qué hace EMIC Generate?

1. **Procesa** el archivo `generate.emic` del módulo
2. **Ejecuta** los comandos EMIC-Codify secuencialmente
3. **Expande** las macros `.{key}.` con sus valores
4. **Fusiona** código de múltiples fuentes (APIs, drivers, HAL)
5. **Genera** archivos C, headers y proyecto MPLAB X
6. **Produce** un proyecto listo para compilar

## 23.2 Flujo General del Proceso

```
┌─────────────────────────────────────────────────────────────────┐
│                      ENTRADA                                     │
├─────────────────────────────────────────────────────────────────┤
│  System/                                                         │
│  ├── generate.emic        (Script principal)                    │
│  ├── usedFunction.emic    (Funciones usadas - del Editor)       │
│  ├── usedEvent.emic       (Eventos usados - del Editor)         │
│  └── userFncFile.c        (Código del usuario)                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    EMIC GENERATE                                 │
├─────────────────────────────────────────────────────────────────┤
│  1. Leer generate.emic                                          │
│  2. Procesar cada comando secuencialmente                       │
│  3. Cargar y procesar archivos .emic de APIs/Drivers            │
│  4. Expandir macros .{key}.                                     │
│  5. Copiar archivos .c y .h al target                           │
│  6. Registrar módulos de compilación                            │
│  7. Generar proyecto MPLAB X                                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      SALIDA                                      │
├─────────────────────────────────────────────────────────────────┤
│  target/                                                         │
│  ├── *.c                  (Archivos fuente)                     │
│  ├── inc/*.h              (Headers)                             │
│  ├── main.c               (Punto de entrada)                    │
│  ├── Makefile             (Build system)                        │
│  └── nbproject/           (Proyecto MPLAB X)                    │
│      └── configurations.xml                                      │
└─────────────────────────────────────────────────────────────────┘
```

## 23.3 Anatomía de generate.emic

El archivo `generate.emic` tiene una estructura estándar con secciones bien definidas:

### Estructura Completa Comentada

```c
// ═══════════════════════════════════════════════════════════════
// SECCIÓN 1: CONFIGURACIÓN DE SALIDA
// ═══════════════════════════════════════════════════════════════
EMIC:setOutput(TARGET:generate.txt)
// Todo lo que sigue se escribe en TARGET:generate.txt
// Este archivo es un log del proceso de generación

    // ═══════════════════════════════════════════════════════════
    // SECCIÓN 2: CONFIGURACIÓN DE HARDWARE (PCB)
    // ═══════════════════════════════════════════════════════════
    EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_USB V1.1)
    // Carga la configuración del PCB específico
    // Define: system.ucName, pines, frecuencias, pragma config

    // ═══════════════════════════════════════════════════════════
    // SECCIÓN 3: PROCESAMIENTO DE FUNCIONES Y EVENTOS USADOS
    // ═══════════════════════════════════════════════════════════
    EMIC:setInput(SYS:usedFunction.emic)
    // Carga las funciones que el usuario usó en el Editor
    // Define macros: usedFunction.nombreFuncion

    EMIC:setInput(SYS:usedEvent.emic)
    // Carga los eventos que el usuario implementó
    // Define macros: usedEvent.nombreEvento

    // ═══════════════════════════════════════════════════════════
    // SECCIÓN 4: CARGA DE APIs
    // ═══════════════════════════════════════════════════════════
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led,pin=Led1)
    // Carga la API de LEDs con parámetros de configuración
    // La API registra: inits.*, polls.*, c_modules.*, main_includes.*

    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)
    // Carga la API de Timer

    EMIC:setInput(DEV:_api/Wired_Communication/USB/USB_API.emic,
                  driver=MCP2200,port=1,BufferSize=512,baud=9600,frameLf=\n)
    // Carga la API de USB con configuración completa

    // ═══════════════════════════════════════════════════════════
    // SECCIÓN 5: CARGA DEL MAIN
    // ═══════════════════════════════════════════════════════════
    EMIC:setInput(DEV:_main/baremetal/main.emic)
    // Carga el template del main que usa las macros de grupos

    // ═══════════════════════════════════════════════════════════
    // SECCIÓN 6: COPIA DE ARCHIVOS DEL USUARIO
    // ═══════════════════════════════════════════════════════════
    EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
    EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
    // Copia el código del usuario (generado por el Editor)

    // ═══════════════════════════════════════════════════════════
    // SECCIÓN 7: REGISTRO DE MÓDULOS DE COMPILACIÓN
    // ═══════════════════════════════════════════════════════════
    EMIC:define(c_modules.userFncFile,userFncFile)
    // Registra userFncFile.c como módulo a compilar

    // ═══════════════════════════════════════════════════════════
    // SECCIÓN 8: GENERACIÓN DEL PROYECTO MPLAB X
    // ═══════════════════════════════════════════════════════════
    EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)
    // Copia y procesa el template del proyecto MPLAB X
    // Expande las macros en configurations.xml

EMIC:restoreOutput
// Cierra el archivo de salida
```

## 23.4 Sistema de Grupos de Registro

El sistema EMIC usa **grupos de macros** para registrar recursos que se expanden posteriormente. Esto permite que múltiples APIs/drivers contribuyan a las mismas secciones del código.

### Grupos Principales

| Grupo | Propósito | Uso en código |
|-------|-----------|---------------|
| `inits.*` | Funciones de inicialización | `.{inits.*}.();` |
| `polls.*` | Funciones de polling | `.{polls.*}.();` |
| `c_modules.*` | Archivos .c a compilar | `.{c_modules.*}..c` |
| `main_includes.*` | Headers a incluir en main | `#include "inc/.{main_includes.*}..h"` |
| `includes_head.*` | Headers adicionales | Para configurations.xml |

### Cómo Funcionan los Grupos

#### 1. Registro por APIs/Drivers

Cada API registra sus recursos en los grupos correspondientes:

```c
// En led.emic
EMIC:define(inits.led_.{name}.,LEDs_.{name}._init)
EMIC:define(polls.led_.{name}.,LEDs_.{name}._poll)
EMIC:define(c_modules.led_.{name}.,led_.{name}.)
EMIC:define(main_includes.led_.{name}.,led_.{name}.)
```

Con `name=led`, esto genera:
```c
EMIC:define(inits.led_led,LEDs_led_init)
EMIC:define(polls.led_led,LEDs_led_poll)
EMIC:define(c_modules.led_led,led_led)
EMIC:define(main_includes.led_led,led_led)
```

#### 2. Expansión en el Main

El template `main.c` usa estos grupos:

```c
// _main/baremetal/main.c (template)
#include "inc/.{main_includes.*}..h"

int main(void)
{
    initSystem();
    EMIC:ifdef usedEvent.SystemConfig
    SystemConfig();
    EMIC:endif
    .{inits.*}.();        // Expande a todas las funciones init
    EMIC:ifdef usedEvent.onReset
    onReset();
    EMIC:endif
    do
    {
        .{polls.*}.();    // Expande a todas las funciones poll
    }
    while(1);
}
```

#### 3. Resultado Generado

Después del proceso Generate, el `main.c` generado contiene:

```c
// target/main.c (generado)
#include "inc/systemTimer.h"
#include "inc/led_led.h"
#include "inc/timer_api1.h"
#include "inc/USB_API.h"
#include "inc/EMICBus.h"

int main(void)
{
    initSystem();
    SystemConfig();
    systemTimeInit();
    LEDs_led_init();
    USB_Init();
    EMICBus_init();
    do
    {
        LEDs_led_poll();
        Poll_USB();
        poll_EMICBus();
    }
    while(1);
}
```

## 23.5 Procesamiento de usedFunction y usedEvent

Los archivos `usedFunction.emic` y `usedEvent.emic` son generados por el Editor EMIC y contienen información sobre qué recursos utiliza el usuario.

### usedFunction.emic

```c
// Generado por el Editor EMIC
// Functions:
EMIC:define(usedFunction.LEDs_led_blink,LEDs_led_blink)
EMIC:define(usedFunction.pI2C,pI2C)
EMIC:define(usedFunction.pUSB,pUSB)
```

### usedEvent.emic

```c
// Generado por el Editor EMIC
// Events:
EMIC:define(usedEvent.eI2C,eI2C)
EMIC:define(usedEvent.eUSB,eUSB)
EMIC:define(usedEvent.SystemConfig,SystemConfig)
```

### Uso en Condicionales

Estas macros permiten incluir código condicionalmente:

```c
// En el template main.c
EMIC:ifdef usedEvent.SystemConfig
SystemConfig();
EMIC:endif

EMIC:ifdef usedEvent.onReset
onReset();
EMIC:endif
```

Si el usuario no implementó `SystemConfig()`, la llamada no se incluye en el código generado.

## 23.6 Generación del Proyecto MPLAB X

El template del proyecto MPLAB X también usa macros para generar la configuración correcta.

### Template configurations.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configurationDescriptor version="65">
  <logicalFolder name="root" displayName="root" projectFiles="true">
    <logicalFolder name="HeaderFiles" displayName="Header Files" projectFiles="true">
      <itemPath>inc/.{includes_head.*}..h</itemPath>
    </logicalFolder>
    <logicalFolder name="SourceFiles" displayName="Source Files" projectFiles="true">
      <itemPath>.{c_modules.*}..c</itemPath>
    </logicalFolder>
  </logicalFolder>
  <confs>
    <conf name="default" type="2">
      <toolsSet>
        <targetDevice>.{system.ucName}.</targetDevice>
        <languageToolchain>XC16</languageToolchain>
      </toolsSet>
    </conf>
  </confs>
</configurationDescriptor>
```

### Resultado Generado

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configurationDescriptor version="65">
  <logicalFolder name="root" displayName="root" projectFiles="true">
    <logicalFolder name="HeaderFiles" displayName="Header Files" projectFiles="true">
      <itemPath>inc/system.h</itemPath>
    </logicalFolder>
    <logicalFolder name="SourceFiles" displayName="Source Files" projectFiles="true">
      <itemPath>timer.c</itemPath>
      <itemPath>systemTimer.c</itemPath>
      <itemPath>led_led.c</itemPath>
      <itemPath>timer_api1.c</itemPath>
      <itemPath>stream.c</itemPath>
      <itemPath>USB_API.c</itemPath>
      <itemPath>main.c</itemPath>
      <itemPath>userFncFile.c</itemPath>
    </logicalFolder>
  </logicalFolder>
  <confs>
    <conf name="default" type="2">
      <toolsSet>
        <targetDevice>pic24FJ64GA002</targetDevice>
        <languageToolchain>XC16</languageToolchain>
      </toolsSet>
    </conf>
  </confs>
</configurationDescriptor>
```

## 23.7 Volúmenes Lógicos en el Proceso

Durante el proceso Generate, se usan diferentes volúmenes lógicos:

| Volumen | Descripción | Ejemplo de Ruta Real |
|---------|-------------|----------------------|
| `DEV:` | SDK de desarrollo | `EMIC_IA_M/` |
| `TARGET:` | Carpeta de salida del proyecto | `My Projects/Test/USB_3/target/` |
| `SYS:` | Carpeta System del módulo | `My Projects/Test/USB_3/System/` |
| `USER:` | Carpeta del usuario | `My Projects/` |

### Flujo de Archivos

```
DEV:_api/Indicators/LEDs/
├── led.emic           ──────┐
├── inc/led.h          ──────┼──► EMIC Generate ──► TARGET:
└── src/led.c          ──────┘                      ├── led_led.c
                                                    └── inc/led_led.h

SYS:
├── usedFunction.emic  ──────┐
├── usedEvent.emic     ──────┼──► EMIC Generate ──► TARGET:main.c
└── userFncFile.c      ──────┘                      (con código condicional)
```

## 23.8 Paso de Parámetros a APIs

Los parámetros pasados en `setInput` se convierten en macros locales dentro del archivo `.emic` procesado.

### En generate.emic

```c
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=status,pin=Led1)
```

### En led.emic

```c
// Los parámetros están disponibles como macros:
// .{name}. = "status"
// .{pin}. = "Led1"

EMIC:copy(inc/led.h > TARGET:inc/led_.{name}..h)
// Genera: TARGET:inc/led_status.h

EMIC:copy(src/led.c > TARGET:led_.{name}..c)
// Genera: TARGET:led_status.c
```

### Dentro del Código C

Los archivos `.c` y `.h` también pueden usar estas macros:

```c
// En src/led.c (template)
void LEDs_.{name}._init(void)
{
    // Pin definido por parámetro
    .{pin}._DIR = 0;  // Output
    .{pin}. = 0;      // Off
}
```

Después de procesar con `name=status` y `pin=Led1`:

```c
// En target/led_status.c (generado)
void LEDs_status_init(void)
{
    Led1_DIR = 0;  // Output
    Led1 = 0;      // Off
}
```

## 23.9 Stack de Salidas

El proceso Generate mantiene un **stack de archivos de salida** usando `setOutput` y `restoreOutput`.

### Ejemplo de Uso

```c
EMIC:setOutput(TARGET:generate.txt)
    // Escribiendo en generate.txt

    EMIC:setOutput(TARGET:inc/config.h)
        // Ahora escribiendo en config.h
        #define VERSION "1.0"
    EMIC:restoreOutput
    // Vuelve a escribir en generate.txt

    EMIC:setOutput(TARGET:inc/pins.h)
        // Ahora escribiendo en pins.h
        #define LED_PIN RB6
    EMIC:restoreOutput
    // Vuelve a generate.txt

EMIC:restoreOutput
// Cierra generate.txt
```

### Diagrama del Stack

```
┌─────────────────┐
│   generate.txt  │ ◄── Archivo base (setOutput inicial)
├─────────────────┤
│   config.h      │ ◄── setOutput anidado
├─────────────────┤
│   pins.h        │ ◄── Otro setOutput anidado
└─────────────────┘

Orden de operaciones:
1. setOutput(generate.txt)  → Stack: [generate.txt]
2. setOutput(config.h)      → Stack: [generate.txt, config.h]
3. restoreOutput            → Stack: [generate.txt]
4. setOutput(pins.h)        → Stack: [generate.txt, pins.h]
5. restoreOutput            → Stack: [generate.txt]
6. restoreOutput            → Stack: []
```

## 23.10 Orden de Ejecución

El orden de los comandos en `generate.emic` es **crítico**. Las dependencias deben cargarse antes de los componentes que las usan.

### Orden Correcto

```c
// 1. PRIMERO: Configuración de hardware
EMIC:setInput(DEV:_pcb/pcb.emic,pcb=...)
// Define: system.ucName, pines

// 2. SEGUNDO: Funciones/eventos usados
EMIC:setInput(SYS:usedFunction.emic)
EMIC:setInput(SYS:usedEvent.emic)
// Define: usedFunction.*, usedEvent.*

// 3. TERCERO: Drivers de bajo nivel (si los hay)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)
// Puede ser dependencia de APIs

// 4. CUARTO: APIs
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,...)
EMIC:setInput(DEV:_api/Timers/timer_api.emic,...)
// Usan drivers y definen grupos

// 5. QUINTO: Main
EMIC:setInput(DEV:_main/baremetal/main.emic)
// Usa los grupos definidos por APIs

// 6. SEXTO: Código del usuario
EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
EMIC:define(c_modules.userFncFile,userFncFile)

// 7. ÚLTIMO: Proyecto MPLAB X
EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)
// Usa todos los grupos definidos
```

### Errores por Orden Incorrecto

```c
// ❌ ERROR: Cargar API antes que PCB
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led,pin=Led1)
EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_USB V1.1)
// El pin Led1 no está definido cuando se procesa led.emic

// ❌ ERROR: Main antes que APIs
EMIC:setInput(DEV:_main/baremetal/main.emic)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led,pin=Led1)
// Los grupos inits.* y polls.* están vacíos cuando se procesa main
```

## 23.11 Archivo de Log: generate.txt

El archivo `generate.txt` en la carpeta `target/` es un log del proceso de generación. Útil para debugging.

### Contenido Típico

```
    //-------------- Hardware Config ---------------------

//Define la primera posicion de la memoria persistente
#define persist_ __attribute__((section(".persist")))
char persist_ persistInit;

    //------------------- Process EMIC-Generate files result ----------------

// Functions:
// (funciones definidas por usedFunction.emic)

// Events:
// (eventos definidos por usedEvent.emic)

    //------------------- APIs -----------------------
// (salida de cada API procesada)

    //-------------------- main  -----------------------
// (procesamiento del main)

    //------------------- Copy  EMIC-Generate files result ----------------
// (archivos copiados)

    //------------------- Add all compiler modules to the project ----------------
// (proyecto MPLAB generado)
```

## 23.12 Ejemplo Completo: Proceso Paso a Paso

Veamos el proceso completo para un módulo con LED y USB.

### Paso 1: Estado Inicial

```
System/
├── generate.emic
├── usedFunction.emic     # EMIC:define(usedFunction.LEDs_led_blink,...)
├── usedEvent.emic        # EMIC:define(usedEvent.eUSB,...)
└── userFncFile.c         # void eUSB(...) { LEDs_led_blink(...); }

target/
└── (vacío)
```

### Paso 2: Procesar PCB

```c
EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_USB V1.1)
```

**Resultado:**
- Define `system.ucName = pic24FJ64GA002`
- Genera `TARGET:inc/systemConfig.h` (pragma config)
- Genera `TARGET:inc/system.h` (frecuencias)
- Genera `TARGET:inc/pins.h` (asignación de pines)

### Paso 3: Cargar Funciones/Eventos Usados

```c
EMIC:setInput(SYS:usedFunction.emic)
EMIC:setInput(SYS:usedEvent.emic)
```

**Resultado:**
- Define `usedFunction.LEDs_led_blink`
- Define `usedEvent.eUSB`
- Define `usedEvent.SystemConfig`

### Paso 4: Cargar API de LEDs

```c
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led,pin=Led1)
```

**Resultado:**
- Copia `led.c` → `TARGET:led_led.c`
- Copia `led.h` → `TARGET:inc/led_led.h`
- Define `inits.led_led = LEDs_led_init`
- Define `polls.led_led = LEDs_led_poll`
- Define `c_modules.led_led = led_led`
- Define `main_includes.led_led = led_led`

### Paso 5: Cargar API de USB

```c
EMIC:setInput(DEV:_api/Wired_Communication/USB/USB_API.emic,...)
```

**Resultado:**
- Copia archivos USB al target
- Define `inits.USB = USB_Init`
- Define `polls.USB = Poll_USB`
- Define `c_modules.USB_API = USB_API`

### Paso 6: Cargar Main

```c
EMIC:setInput(DEV:_main/baremetal/main.emic)
```

**Resultado:**
- Procesa template `main.c`
- Expande `.{main_includes.*}.` → `led_led`, `USB_API`, ...
- Expande `.{inits.*}.` → `LEDs_led_init`, `USB_Init`, ...
- Expande `.{polls.*}.` → `LEDs_led_poll`, `Poll_USB`, ...
- Genera `TARGET:main.c` con código expandido

### Paso 7: Copiar Código Usuario

```c
EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
EMIC:define(c_modules.userFncFile,userFncFile)
```

**Resultado:**
- Copia código del usuario
- Registra para compilación

### Paso 8: Generar Proyecto MPLAB

```c
EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)
```

**Resultado:**
- Copia estructura del proyecto
- Expande `.{c_modules.*}.` en configurations.xml
- Expande `.{system.ucName}.` → `pic24FJ64GA002`
- Genera proyecto MPLAB X completo

### Estado Final

```
target/
├── main.c
├── led_led.c
├── USB_API.c
├── userFncFile.c
├── (otros .c)
├── inc/
│   ├── systemConfig.h
│   ├── system.h
│   ├── pins.h
│   ├── led_led.h
│   ├── USB_API.h
│   └── (otros .h)
├── Makefile
└── nbproject/
    ├── configurations.xml  (con lista de archivos)
    └── project.xml
```

## 23.13 Debugging del Proceso Generate

### Errores Comunes y Soluciones

#### Error: "Macro no definida"

```
Error: Undefined macro '.{pin}.'
```

**Causa:** El parámetro no fue pasado en `setInput`.

**Solución:**
```c
// Agregar el parámetro faltante
EMIC:setInput(DEV:_api/led.emic,name=led,pin=Led1)
//                                      ^^^^^^^^
```

#### Error: "Archivo no encontrado"

```
Error: File not found 'DEV:_api/MiAPI/miapi.emic'
```

**Causa:** Ruta incorrecta o archivo no existe.

**Solución:** Verificar la ruta y que el archivo exista.

#### Error: "Stack de salida desbalanceado"

**Causa:** Más `restoreOutput` que `setOutput`, o viceversa.

**Solución:** Verificar que cada `setOutput` tenga su `restoreOutput`.

#### Error: "Grupo vacío"

```c
// main.c generado tiene .{inits.*}.() vacío
```

**Causa:** Las APIs no registraron sus funciones en los grupos.

**Solución:** Verificar que las APIs usen `EMIC:define(inits.xxx,...)`.

### Técnicas de Debugging

1. **Revisar generate.txt**: Contiene el log del proceso
2. **Verificar macros definidas**: Buscar `EMIC:define` en los archivos
3. **Probar APIs individualmente**: Cargar una API a la vez
4. **Revisar orden de carga**: Las dependencias deben ir primero

## 23.14 Resumen del Proceso

| Fase | Acción | Resultado |
|------|--------|-----------|
| 1 | Cargar PCB | Macros de sistema, pragma config |
| 2 | Cargar usedFunction/Event | Macros de recursos usados |
| 3 | Cargar APIs | Archivos .c/.h, registros en grupos |
| 4 | Cargar Main | main.c con grupos expandidos |
| 5 | Copiar usuario | userFncFile.c |
| 6 | Generar proyecto | MPLAB X listo para compilar |

### Grupos y su Expansión

| Grupo | Registro | Expansión |
|-------|----------|-----------|
| `inits.*` | `EMIC:define(inits.led,LED_init)` | `LED_init();` |
| `polls.*` | `EMIC:define(polls.led,LED_poll)` | `LED_poll();` |
| `c_modules.*` | `EMIC:define(c_modules.led,led)` | `<itemPath>led.c</itemPath>` |
| `main_includes.*` | `EMIC:define(main_includes.led,led)` | `#include "inc/led.h"` |

### Volúmenes en el Proceso

| Volumen | Lee de | Escribe en |
|---------|--------|------------|
| `DEV:` | SDK | - |
| `SYS:` | Módulo | Módulo |
| `TARGET:` | - | Proyecto generado |
