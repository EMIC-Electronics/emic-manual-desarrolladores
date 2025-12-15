# Capítulo 25: Desarrollo de Módulo Completo

## 25.1 Introducción

Un **módulo EMIC** es una unidad de hardware independiente que combina un PCB específico con las APIs y drivers necesarios para su funcionamiento. Los módulos representan el nivel más alto de abstracción en el SDK EMIC y son los componentes que los usuarios finales seleccionan en el Editor EMIC para construir sus proyectos.

A diferencia de las APIs (que exponen funcionalidades) y los drivers (que controlan hardware), un módulo:

- Define un **hardware físico específico** (PCB)
- Integra múltiples **APIs y drivers** preconfigurados
- Proporciona una **interfaz visual** para el Editor EMIC
- Genera un **proyecto compilable** completo para MPLAB X

## 25.2 Estructura de Carpetas de un Módulo

Un módulo EMIC sigue una estructura de carpetas estándar:

```
_modules/
└── Categoria/
    └── NombreModulo/
        ├── m_description.json      # Metadatos del módulo
        └── System/
            ├── deploy.emic         # Script de deploy
            ├── generate.emic       # Script de generación
            └── module.webp         # Imagen del módulo
```

### Ejemplo Real: Módulo HRD_2Relays

```
_modules/
└── Wired_Control/
    └── HRD_2Relays/
        ├── m_description.json
        └── System/
            ├── deploy.emic
            ├── generate.emic
            └── module.webp
```

## 25.3 Archivo de Metadatos: m_description.json

El archivo `m_description.json` contiene la información descriptiva del módulo que se muestra en el Editor EMIC.

### Estructura Básica

```json
{
    "type": "gcc",
    "toolTip": "Descripción corta para tooltip",
    "description": "Descripción completa del módulo y sus capacidades.",
    "Sizes": "7x2cm",
    "ImageFile": "module.gif",
    "IconFile": "icon.png",
    "Mounting": "Holder Riel DIN",

    "Table": [
        {"Name": "VccMax", "Value": "5.5V"},
        {"Name": "VccMin", "Value": "4.8V"},
        {"Name": "IccMax", "Value": "50mA"}
    ],

    "HardwareDescription": [
        {
            "PinName": "J4,J5",
            "PinType": "I2C",
            "PinDescription": "EMIC connector"
        },
        {
            "PinName": "LED",
            "PinType": "Led",
            "PinDescription": "General purpose led"
        }
    ],

    "features": [
        "Emic bus compatible.",
        "Size: 7x2cm",
        "Temperature range -25°C a 80°C."
    ],

    "applications": [
        "Data logger.",
        "IoT.",
        "Control industrial."
    ],

    "keyWord": [
        "relay",
        "control",
        "actuator"
    ]
}
```

### Campos Principales

| Campo | Descripción |
|-------|-------------|
| `type` | Tipo de compilador: `gcc`, `gcc-2.0` |
| `toolTip` | Texto mostrado al pasar el mouse |
| `description` | Descripción detallada del módulo |
| `Table` | Especificaciones eléctricas |
| `HardwareDescription` | Descripción de pines y conectores |
| `features` | Lista de características |
| `applications` | Aplicaciones sugeridas |
| `keyWord` | Palabras clave para búsqueda |

## 25.4 Script de Generación: generate.emic

El archivo `generate.emic` es el script principal que orquesta la generación de código C para el módulo.

### Estructura Estándar

```c
EMIC:setOutput(TARGET:generate.txt)

    //-------------- Hardware Config ---------------------
    EMIC:setInput(DEV:_pcb/pcb.emic,pcb=NOMBRE_PCB)

    //------------------- Process EMIC-Generate files result ----------------
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    //------------------- APIs -----------------------
    // Aquí se incluyen las APIs del módulo

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

### Ejemplo Real: Módulo HRD_2Relays

Archivo: `_modules/Wired_Control/HRD_2Relays/System/generate.emic`

```c
EMIC:setOutput(TARGET:generate.txt)

    //-------------- Hardware Config ---------------------
    EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_USB V1.1)

    //------------------- Process EMIC-Generate files result ----------------
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    //------------------- APIs -----------------------
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led,pin=Led1)

    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)
    EMIC:setInput(DEV:_api/Wired_Communication/USB/USB_API.emic,driver=MCP2200,port=1,BufferSize=512,baud=9600,frameLf=\n,name=MCP2200)
    EMIC:setInput(DEV:_api/Wired_Communication/EMICBus/EMICBus.emic,port=2,frameID=0)
    EMIC:setInput(DEV:_api/Actuators/Relay/relay.emic,name=ON,pin=RelayON)
    EMIC:setInput(DEV:_api/Actuators/Relay/relay.emic,name=DIR,pin=RelayDIR)

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

### Secciones del generate.emic

#### 1. Hardware Config
```c
EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_USB V1.1)
```
Carga la configuración del PCB específico, que incluye:
- Configuración del microcontrolador (pragma config)
- Definición de frecuencias (FOSC, FCY)
- Asignación de pines

#### 2. Process EMIC-Generate Files
```c
EMIC:setInput(SYS:usedFunction.emic)
EMIC:setInput(SYS:usedEvent.emic)
```
Procesa los archivos generados por el Editor EMIC que contienen las funciones y eventos que el usuario utilizó en su programa visual.

#### 3. APIs
```c
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led,pin=Led1)
EMIC:setInput(DEV:_api/Actuators/Relay/relay.emic,name=ON,pin=RelayON)
```
Incluye las APIs disponibles en el módulo, cada una con sus parámetros de configuración.

#### 4. Main
```c
EMIC:setInput(DEV:_main/baremetal/main.emic)
```
Incluye el template del main que integra todos los componentes.

#### 5. User Code
```c
EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
EMIC:define(c_modules.userFncFile,userFncFile)
```
Copia el código del usuario (generado desde el Editor visual) al proyecto.

#### 6. Project Template
```c
EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)
```
Copia la estructura del proyecto MPLAB X.

## 25.5 Script de Deploy: deploy.emic

El archivo `deploy.emic` se ejecuta cuando el usuario crea una nueva instancia del módulo en el Editor EMIC. Prepara los archivos iniciales del proyecto.

### Estructura Básica

```c
EMIC:setOutput(TARGET:deploy.txt)
    //------------------- Copy generate files ----------------
    EMIC:setOutput(SYS:inc/userFncFile.h)
    // file: userFncFile.h
    EMIC:restoreOutput

    EMIC:setOutput(SYS:userFncFile.c)
    // file: userFncFile.c
    EMIC:restoreOutput

    EMIC:copy(DEV:_templates/plugins/sidebar-tabs > SYS:EMIC-TABS)

    EMIC:setOutput(TARGET:inc/myId.h)
    #define _I2C_ID .{module.Id}.
    EMIC:restoreOutput

EMIC:restoreOutput
```

### Funciones del deploy.emic

1. **Crear archivos de usuario vacíos**: Prepara `userFncFile.h` y `userFncFile.c`
2. **Copiar templates de pestañas**: Configura las pestañas del Editor
3. **Generar ID único**: Crea un identificador para el módulo en la red EMIC Bus

## 25.6 Archivos Generados por el Editor

Cuando el usuario programa visualmente en el Editor EMIC, se generan automáticamente dos archivos importantes:

### usedFunction.emic

Contiene las definiciones de las funciones que el usuario utilizó:

```c
// Functions:
EMIC:define(usedFunction.LEDs_led_blink,LEDs_led_blink)
EMIC:define(usedFunction.pI2C,pI2C)
EMIC:define(usedFunction.pUSB,pUSB)
```

### usedEvent.emic

Contiene las definiciones de los eventos que el usuario implementó:

```c
// Events:
EMIC:define(usedEvent.eI2C,eI2C)
EMIC:define(usedEvent.eUSB,eUSB)
EMIC:define(usedEvent.SystemConfig,SystemConfig)
```

### Propósito

Estos archivos permiten que el sistema incluya **solo el código necesario** para las funciones y eventos que realmente se usan, optimizando el tamaño del firmware final.

## 25.7 Configuración de Hardware: PCB

Cada módulo referencia un archivo PCB que define la configuración específica del hardware.

### Archivo pcb.emic

```c
EMIC:copy(inc/.{pcb}..h > TARGET:inc/.{pcb}..h)
```

Este archivo simplemente copia el header del PCB correspondiente según el parámetro `pcb`.

### Ejemplo de Header PCB

Archivo: `_pcb/inc/HRD_USB V1.1.h`

```c
EMIC:setOutput(TARGET:inc/systemConfig.h)
#pragma config POSCMOD = NONE       // Primary Oscillator Select
#pragma config I2C1SEL = PRI        // I2C1 Pin Location Select
#pragma config OSCIOFNC = ON        // Use RA3 as I/O
#pragma config FCKSM = CSDCMD       // Clock Switching disabled
#pragma config FNOSC = FRCPLL       // Fast RC Oscillator with PLL
#pragma config WDTPS = PS32768      // Watchdog Timer Postscaler
#pragma config FWDTEN = OFF         // Watchdog Timer disabled
#pragma config JTAGEN = OFF         // JTAG disabled
EMIC:restoreOutput

EMIC:setOutput(TARGET:inc/system.h)
#define FOSC 32000000
#define FCY (FOSC/2)
EMIC:restoreOutput

EMIC:setOutput(TARGET:inc/pins.h)
#include <xc.h>

EMIC:define(system.ucName,pic24FJ64GA002)
EMIC:define(system.i2c,2)

EMIC:setInput(DEV:_hal/pins/setPin.emic,pin=B14,name=MCP2200_RST)
EMIC:setInput(DEV:_hal/pins/setPin.emic,pin=B6,name=Led1)
EMIC:setInput(DEV:_hal/pins/setPin.emic,pin=B10,name=MCP2200_TX)
EMIC:setInput(DEV:_hal/pins/setPin.emic,pin=B15,name=MCP2200_RX)

EMIC:restoreOutput
```

### Elementos del PCB

| Elemento | Descripción |
|----------|-------------|
| `systemConfig.h` | Pragma config del microcontrolador |
| `system.h` | Definiciones de frecuencia |
| `pins.h` | Asignación de pines |
| `system.ucName` | Nombre del microcontrolador (para HAL) |
| `system.i2c` | Puerto I2C a usar |

## 25.8 Pestañas del Editor: emic-tabs

Las pestañas definen la interfaz visual del módulo en el Editor EMIC.

### Resources.html

Define las funciones y eventos disponibles para el usuario:

```html
<emic-driver-container name="LEDs" icon="cable">
    <emic-program-function
        driver="LEDs"
        name="LEDs_led_state"
        type="uint8_t"
        brief="Change the state of the led"
        alias="led.state"
        draggable="true">
        <emic-function-parameter
            name="state"
            type="uint8_t"
            brief="1-on 0-off 2-toggle">
        </emic-function-parameter>
    </emic-program-function>

    <emic-program-function
        driver="LEDs"
        name="LEDs_led_blink"
        type="void"
        brief="blink the led"
        alias="led.blink"
        draggable="true"
        class="subroutine">
        <emic-function-parameter name="timeOn" type="uint16_t" brief="time on"></emic-function-parameter>
        <emic-function-parameter name="period" type="uint16_t" brief="period"></emic-function-parameter>
        <emic-function-parameter name="times" type="uint16_t" brief="cycles"></emic-function-parameter>
    </emic-program-function>
</emic-driver-container>

<emic-driver-container name="RELAY" icon="cable">
    <emic-program-function
        driver="RELAY"
        name="relay_ON"
        type="void"
        brief="Modifies Relay ON status"
        alias="setStatusON"
        draggable="true">
        <emic-function-parameter name="stateRelay" type="uint8_t" brief="0-off, 1-on, 2-toggle"></emic-function-parameter>
    </emic-program-function>
</emic-driver-container>

<emic-driver-container name="SYSTEM" icon="cable">
    <emic-program-event
        driver="SYSTEM"
        name="onReset"
        type="void"
        brief="When the module is ready"
        alias="onReset"
        draggable="true"
        droppable="">
    </emic-program-event>

    <emic-program-event
        driver="SYSTEM"
        name="SystemConfig"
        type="void"
        brief="Before initializing drivers"
        alias="SystemConfig"
        draggable="true"
        droppable="">
    </emic-program-event>
</emic-driver-container>
```

### Code.html

Define los bloques de control de flujo:

```html
<emic-flow-container name="Control de Flujo" icon="fork_right">
    <emic-flow-if
        name="conditional_if"
        alias="if...else"
        brief="Estructura condicional if-else"
        draggable="true">
    </emic-flow-if>

    <emic-flow-switch
        name="conditional_switch"
        alias="switch"
        brief="Estructura condicional switch-case"
        draggable="true">
    </emic-flow-switch>
</emic-flow-container>

<emic-math-container name="Comparación" icon="calculate">
    <emic-math-equal name="equal" alias="==" brief="Igualdad" draggable="true"></emic-math-equal>
    <emic-math-notequal name="notequal" alias="!=" brief="Diferencia" draggable="true"></emic-math-notequal>
    <emic-math-greater name="greater" alias=">" brief="Mayor que" draggable="true"></emic-math-greater>
    <emic-math-less name="less" alias="<" brief="Menor que" draggable="true"></emic-math-less>
</emic-math-container>
```

### Data.html

Panel de variables del usuario:

```html
<emic-variables-panel></emic-variables-panel>
```

## 25.9 Código del Usuario: userFncFile

El código que el usuario crea en el Editor visual se traduce a C en `userFncFile.c`.

### Ejemplo de userFncFile.c

```c
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include "inc/userFncFile.h"
#include "inc/.{main_includes.*}..h"

void SystemConfig()
{
    LEDs_led_blink(100, 200, 5);
}

void eI2C(char* tag, const streamIn_t* const msg)
{
    LEDs_led_blink(100, 101, 1);
    pUSB("$s\t$r", tag, msg);
}

void eUSB(char* tag, const streamIn_t* const msg)
{
    LEDs_led_blink(50, 100, 2);
    pI2C("$s\t$r", tag, msg);
}
```

Este código implementa:
- `SystemConfig()`: Se ejecuta antes de inicializar drivers
- `eI2C()`: Evento cuando llega un mensaje por EMIC Bus
- `eUSB()`: Evento cuando llega un mensaje por USB

## 25.10 Flujo de Generación Completo

```
┌─────────────────────────────────────────────────────────────┐
│                    EDITOR EMIC                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │  Resources  │  │    Code     │  │    Data     │          │
│  │  (drag)     │  │  (if/else)  │  │ (variables) │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
│                         │                                    │
│                         ▼                                    │
│              ┌─────────────────────┐                        │
│              │   Genera archivos   │                        │
│              └─────────────────────┘                        │
│                         │                                    │
└─────────────────────────┼────────────────────────────────────┘
                          ▼
              ┌─────────────────────┐
              │ System/             │
              │ ├── usedFunction.emic│
              │ ├── usedEvent.emic  │
              │ └── userFncFile.c   │
              └─────────────────────┘
                          │
                          ▼
              ┌─────────────────────┐
              │   generate.emic     │
              │   (Proceso EMIC)    │
              └─────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
    ┌──────────┐   ┌──────────┐   ┌──────────┐
    │ PCB.h    │   │ APIs     │   │ Drivers  │
    │ (config) │   │ (.emic)  │   │ (.emic)  │
    └──────────┘   └──────────┘   └──────────┘
          │               │               │
          └───────────────┼───────────────┘
                          ▼
              ┌─────────────────────┐
              │     target/         │
              │ ├── *.c, *.h       │
              │ ├── main.c         │
              │ ├── Makefile       │
              │ └── nbproject/     │
              └─────────────────────┘
                          │
                          ▼
              ┌─────────────────────┐
              │    MPLAB X IDE      │
              │    (Compilación)    │
              └─────────────────────┘
                          │
                          ▼
              ┌─────────────────────┐
              │  firmware.hex       │
              │  (Flash al MCU)     │
              └─────────────────────┘
```

## 25.11 Caso de Estudio: Crear un Módulo de Sensor

Vamos a crear un módulo completo para un sensor de temperatura con las siguientes características:
- LED indicador
- Sensor de temperatura analógico
- Comunicación USB
- Timer para muestreo periódico

### Paso 1: Crear Estructura de Carpetas

```
_modules/
└── Sensors/
    └── TemperatureMonitor/
        ├── m_description.json
        └── System/
            ├── deploy.emic
            ├── generate.emic
            ├── module.webp
            └── emic-tabs/
                ├── Code.html
                ├── Data.html
                ├── Resources.html
                └── User.html
```

### Paso 2: Crear m_description.json

```json
{
    "type": "gcc",
    "toolTip": "Temperature monitoring module",
    "description": "Module for monitoring temperature with USB communication and configurable sampling rate.",
    "Sizes": "5x3cm",
    "Mounting": "Holder Riel DIN",

    "Table": [
        {"Name": "VccMax", "Value": "5.5V"},
        {"Name": "VccMin", "Value": "4.5V"},
        {"Name": "Temp Range", "Value": "-40°C to 125°C"}
    ],

    "HardwareDescription": [
        {"PinName": "AN0", "PinType": "Analog", "PinDescription": "Temperature sensor input"},
        {"PinName": "LED", "PinType": "Led", "PinDescription": "Status indicator"},
        {"PinName": "USB", "PinType": "USB", "PinDescription": "Communication port"}
    ],

    "features": [
        "USB communication",
        "Configurable sampling rate",
        "Status LED indicator",
        "EMIC Bus compatible"
    ],

    "applications": [
        "Environmental monitoring",
        "Industrial temperature control",
        "Data logging"
    ],

    "keyWord": ["temperature", "sensor", "monitor", "analog"]
}
```

### Paso 3: Crear generate.emic

```c
EMIC:setOutput(TARGET:generate.txt)

    //-------------- Hardware Config ---------------------
    EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_USB V1.1)

    //-- Process EMIC-Generate files result --
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    //------------------- APIs -----------------------
    // LED indicador de estado
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=status,pin=Led1)

    // Timer para muestreo periódico
    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)

    // Sensor de temperatura analógico
    EMIC:setInput(DEV:_api/Sensors/Temperature/temperature.emic,name=_X,pin=AN0)

    // Comunicación USB (opcional, comentado por defecto)
    //EMIC:setInput(DEV:_api/Wired_Communication/USB/USB_API.emic,driver=MCP2200,port=1,BufferSize=512,baud=9600,frameLf=\n,name=MCP2200)

    //-------------------- main  -----------------------
    EMIC:setInput(DEV:_main/baremetal/main.emic)

    //-- Copy EMIC-Generate files result ----------------
    EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
    EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)

    //---- Set userFncFile.c as a compiler module ---------
    EMIC:define(c_modules.userFncFile,userFncFile)

    //-- Add all compiler modules to the project. --
    EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

### Paso 4: Crear deploy.emic

```c
EMIC:setOutput(SYS:deploy.txt)
    //------------------- Copy generate files ----------------
    EMIC:setOutput(SYS:inc/userFncFile.h)
    // file: userFncFile.h
    EMIC:restoreOutput

    EMIC:setOutput(SYS:userFncFile.c)
    // file: userFncFile.c
    EMIC:restoreOutput

    EMIC:copy(DEV:_templates/plugins/sidebar-tabs > SYS:EMIC-TABS)

    EMIC:setOutput(TARGET:inc/myId.h)
    #define _I2C_ID .{module.Id}.
    EMIC:restoreOutput

EMIC:restoreOutput
```

### Paso 5: Crear Resources.html

```html
<emic-driver-container name="Variables" icon="variable">
    <emic-variable name="temperature" type="float" brief="Current temperature" draggable="true"></emic-variable>
    <emic-variable name="threshold" type="float" brief="Alert threshold" draggable="true"></emic-variable>
    <emic-program-literal></emic-program-literal>
</emic-driver-container>

<emic-driver-container name="LEDs" icon="cable">
    <emic-program-function driver="LEDs" name="LEDs_status_state" type="uint8_t"
        brief="Change LED state" alias="status.state" draggable="true">
        <emic-function-parameter name="state" type="uint8_t" brief="1-on 0-off 2-toggle"></emic-function-parameter>
    </emic-program-function>
    <emic-program-function driver="LEDs" name="LEDs_status_blink" type="void"
        brief="Blink the LED" alias="status.blink" draggable="true" class="subroutine">
        <emic-function-parameter name="timeOn" type="uint16_t" brief="Time on (ms)"></emic-function-parameter>
        <emic-function-parameter name="period" type="uint16_t" brief="Period (ms)"></emic-function-parameter>
        <emic-function-parameter name="times" type="uint16_t" brief="Number of blinks"></emic-function-parameter>
    </emic-program-function>
</emic-driver-container>

<emic-driver-container name="TEMPERATURE" icon="thermostat">
    <emic-program-function driver="TEMPERATURE" name="getTemperature_X" type="float"
        brief="Read temperature in Celsius" alias="readTemp" draggable="true">
    </emic-program-function>
</emic-driver-container>

<emic-driver-container name="TIMER" icon="timer">
    <emic-program-function driver="TIMER" name="setTime1" type="void"
        brief="Set timer interval" alias="setTime1" draggable="true" class="subroutine">
        <emic-function-parameter name="time" type="uint16_t" brief="Time in ms"></emic-function-parameter>
        <emic-function-parameter name="mode" type="char" brief="T:timer, A:auto-reload"></emic-function-parameter>
    </emic-program-function>
    <emic-program-event driver="TIMER" name="etOut1" type="void"
        brief="Timer expired event" alias="timeOut1" draggable="true" droppable="">
    </emic-program-event>
</emic-driver-container>

<emic-driver-container name="SYSTEM" icon="settings">
    <emic-program-event driver="SYSTEM" name="onReset" type="void"
        brief="Module ready" alias="onReset" draggable="true" droppable="">
    </emic-program-event>
    <emic-program-event driver="SYSTEM" name="SystemConfig" type="void"
        brief="System configuration" alias="SystemConfig" draggable="true" droppable="">
    </emic-program-event>
</emic-driver-container>
```

## 25.12 Resumen

| Archivo | Propósito |
|---------|-----------|
| `m_description.json` | Metadatos y descripción para el Editor |
| `generate.emic` | Script principal de generación de código |
| `deploy.emic` | Inicialización al crear instancia del módulo |
| `emic-tabs/*.html` | Interfaz visual del Editor EMIC |
| `usedFunction.emic` | Funciones usadas (generado por Editor) |
| `usedEvent.emic` | Eventos usados (generado por Editor) |
| `userFncFile.c` | Código del usuario (generado por Editor) |

### Flujo de Desarrollo de un Módulo

1. **Diseñar el hardware** y crear el archivo PCB correspondiente
2. **Crear la estructura de carpetas** del módulo
3. **Definir los metadatos** en `m_description.json`
4. **Configurar generate.emic** con las APIs y drivers necesarios
5. **Configurar deploy.emic** para la inicialización
6. **Crear las pestañas** del Editor en `emic-tabs/`
7. **Probar el módulo** creando un proyecto en el Editor EMIC
8. **Verificar la compilación** y el funcionamiento del firmware
