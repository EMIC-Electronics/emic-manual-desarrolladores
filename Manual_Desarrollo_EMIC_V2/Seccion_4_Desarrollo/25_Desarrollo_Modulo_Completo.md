# Capítulo 25: Desarrollo de Módulo Completo

## 25.1 Introducción

Un **módulo EMIC** es una unidad de hardware independiente que combina un PCB específico con las APIs y drivers necesarios para su funcionamiento. Los módulos representan el nivel más alto de abstracción en el SDK EMIC y son los componentes que los usuarios finales seleccionan en el Editor EMIC para construir sus proyectos.

A diferencia de las APIs (que exponen funcionalidades) y los drivers (que controlan hardware), un módulo:

- Define un **hardware físico específico** (PCB)
- Integra múltiples **APIs y drivers** preconfigurados
- Proporciona una **interfaz visual** para el Editor EMIC
- Genera un **proyecto compilable** completo para MPLAB X

### Relación con Otros Capítulos

Este capítulo asume conocimiento de:
- **Capítulo 23**: Proceso de Generación (EMIC Generate) - explica cómo funciona `generate.emic`
- **Capítulo 24**: Proceso de Deploy e Instanciación - explica cómo funciona `deploy.emic` y EMIC-Discovery
- **Capítulo 26**: Plugins del Editor - explica el sistema de plugins

## 25.2 Estructura de Carpetas de un Módulo

Un módulo EMIC sigue una estructura de carpetas estándar:

```
_modules/
└── Categoria/
    └── NombreModulo/
        ├── m_description.json      # Metadatos del módulo
        └── System/
            ├── deploy.emic         # Script de deploy (ver cap. 24)
            ├── generate.emic       # Script de generación (ver cap. 23)
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

El archivo `generate.emic` es el script principal que orquesta la generación de código C para el módulo. Para una explicación detallada del proceso de generación, consulte el **Capítulo 23**.

### Resumen de la Estructura

```c
EMIC:setOutput(TARGET:generate.txt)

    // 1. Configuración de hardware (PCB)
    EMIC:setInput(DEV:_pcb/pcb.emic,pcb=NOMBRE_PCB)

    // 2. Procesar funciones/eventos usados por el usuario
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    // 3. Cargar APIs del módulo
    EMIC:setInput(DEV:_api/Categoria/api.emic,parametros...)

    // 4. Generar main.c
    EMIC:setInput(DEV:_main/baremetal/main.emic)

    // 5. Copiar código del usuario
    EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
    EMIC:define(c_modules.userFncFile,userFncFile)

    // 6. Generar proyecto MPLAB X
    EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

### Ejemplo Real: Módulo HRD_2Relays

```c
EMIC:setOutput(TARGET:generate.txt)

    EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_USB V1.1)

    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    // APIs disponibles en este módulo
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led,pin=Led1)
    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)
    EMIC:setInput(DEV:_api/Wired_Communication/USB/USB_API.emic,driver=MCP2200,port=1,BufferSize=512,baud=9600,frameLf=\n,name=MCP2200)
    EMIC:setInput(DEV:_api/Wired_Communication/EMICBus/EMICBus.emic,port=2,frameID=0)
    EMIC:setInput(DEV:_api/Actuators/Relay/relay.emic,name=ON,pin=RelayON)
    EMIC:setInput(DEV:_api/Actuators/Relay/relay.emic,name=DIR,pin=RelayDIR)

    EMIC:setInput(DEV:_main/baremetal/main.emic)

    EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
    EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
    EMIC:define(c_modules.userFncFile,userFncFile)

    EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

> **Nota**: Para entender cómo funciona el sistema de grupos (`inits.*`, `polls.*`, `c_modules.*`), la expansión de macros, y el orden de ejecución, consulte el **Capítulo 23: Proceso de Generación**.

### Importancia del generate.emic para el Editor

El archivo `generate.emic` tiene un rol dual:

1. **Durante EMIC-Generate**: Genera el código C compilable
2. **Durante EMIC-Discovery**: Se ejecuta en modo "Discovery" para extraer las funciones y eventos de las APIs (basado en tags DOXYGEN) y generar automáticamente el archivo `Resources` del Editor

Por esta razón, las APIs que se incluyen en `generate.emic` determinan qué funciones y eventos estarán disponibles para el usuario en el Editor EMIC. Ver **Capítulo 24** para más detalles sobre EMIC-Discovery.

## 25.5 Script de Deploy: deploy.emic

El archivo `deploy.emic` se ejecuta cuando el usuario crea una nueva instancia del módulo en el Editor EMIC. Para una explicación detallada del proceso de deploy, consulte el **Capítulo 24**.

### Estructura Básica

```c
EMIC:setOutput(TARGET:deploy.txt)
    // Crear archivos de usuario vacíos
    EMIC:setOutput(SYS:inc/userFncFile.h)
    // file: userFncFile.h
    EMIC:restoreOutput

    EMIC:setOutput(SYS:userFncFile.c)
    // file: userFncFile.c
    EMIC:restoreOutput

    // Copiar plugins del Editor (ver capítulo 26)
    EMIC:copy(DEV:_templates/plugins/sidebar-tabs > SYS:EMIC-TABS)

    // Generar ID único para EMIC Bus
    EMIC:setOutput(TARGET:inc/myId.h)
    #define _I2C_ID .{module.Id}.
    EMIC:restoreOutput

EMIC:restoreOutput
```

### Funciones del deploy.emic

1. **Crear archivos de usuario vacíos**: Prepara `userFncFile.h` y `userFncFile.c`
2. **Copiar plugins del Editor**: Los plugins base (Code, Data, Functions, User) para la interfaz del Editor
3. **Generar ID único**: Crea un identificador para el módulo en la red EMIC Bus

> **Importante**: El archivo `Resources` (que contiene las funciones y eventos del módulo) **NO** se copia en el deploy. Se genera automáticamente por el proceso **EMIC-Discovery** después del deploy, basándose en los tags DOXYGEN de las APIs incluidas en `generate.emic`. Ver **Capítulo 24** para más detalles.

## 25.6 Configuración de Hardware: PCB

Cada módulo referencia un archivo PCB que define la configuración específica del hardware.

### Estructura del Archivo PCB

Los archivos PCB se ubican en `_pcb/inc/` y generan tres headers principales:

| Archivo Generado | Contenido |
|------------------|-----------|
| `systemConfig.h` | Pragma config del microcontrolador |
| `system.h` | Definiciones de frecuencia (FOSC, FCY) |
| `pins.h` | Asignación de pines físicos |

### Ejemplo: Header PCB HRD_USB V1.1

```c
// Archivo: _pcb/inc/HRD_USB V1.1.h

EMIC:setOutput(TARGET:inc/systemConfig.h)
#pragma config POSCMOD = NONE       // Primary Oscillator Select
#pragma config I2C1SEL = PRI        // I2C1 Pin Location Select
#pragma config FNOSC = FRCPLL       // Fast RC Oscillator with PLL
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

EMIC:setInput(DEV:_hal/pins/setPin.emic,pin=B6,name=Led1)
EMIC:setInput(DEV:_hal/pins/setPin.emic,pin=B10,name=MCP2200_TX)
EMIC:setInput(DEV:_hal/pins/setPin.emic,pin=B15,name=MCP2200_RX)
EMIC:restoreOutput
```

### Macros del Sistema Definidas por PCB

| Macro | Propósito |
|-------|-----------|
| `system.ucName` | Nombre del microcontrolador (para HAL y proyecto MPLAB) |
| `system.i2c` | Puerto I2C a usar |

## 25.7 Caso de Estudio: Crear un Módulo de Sensor

Vamos a crear un módulo completo para un sensor de temperatura con las siguientes características:
- LED indicador
- Sensor de temperatura analógico
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
            └── module.webp
```

### Paso 2: Crear m_description.json

```json
{
    "type": "gcc",
    "toolTip": "Temperature monitoring module",
    "description": "Module for monitoring temperature with configurable sampling rate.",
    "Sizes": "5x3cm",
    "Mounting": "Holder Riel DIN",

    "Table": [
        {"Name": "VccMax", "Value": "5.5V"},
        {"Name": "VccMin", "Value": "4.5V"},
        {"Name": "Temp Range", "Value": "-40°C to 125°C"}
    ],

    "HardwareDescription": [
        {"PinName": "AN0", "PinType": "Analog", "PinDescription": "Temperature sensor input"},
        {"PinName": "LED", "PinType": "Led", "PinDescription": "Status indicator"}
    ],

    "features": [
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

    // Configuración del PCB
    EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_USB V1.1)

    // Archivos del Editor
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    // APIs del módulo - estas determinarán qué funciones
    // aparecen en el Editor (via EMIC-Discovery)
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=status,pin=Led1)
    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)
    EMIC:setInput(DEV:_api/Sensors/Temperature/temperature.emic,name=_X,pin=AN0)

    // Main y código de usuario
    EMIC:setInput(DEV:_main/baremetal/main.emic)
    EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
    EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
    EMIC:define(c_modules.userFncFile,userFncFile)

    // Proyecto MPLAB X
    EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

### Paso 4: Crear deploy.emic

```c
EMIC:setOutput(SYS:deploy.txt)
    // Crear archivos de usuario vacíos
    EMIC:setOutput(SYS:inc/userFncFile.h)
    // file: userFncFile.h
    EMIC:restoreOutput

    EMIC:setOutput(SYS:userFncFile.c)
    // file: userFncFile.c
    EMIC:restoreOutput

    // Copiar plugins del Editor
    EMIC:copy(DEV:_templates/plugins/sidebar-tabs > SYS:EMIC-TABS)

    // Generar ID único
    EMIC:setOutput(TARGET:inc/myId.h)
    #define _I2C_ID .{module.Id}.
    EMIC:restoreOutput

EMIC:restoreOutput
```

### Resultado del Deploy + Discovery

Después del proceso de instanciación (deploy + EMIC-Discovery), la carpeta `EMIC-TABS/` contendrá:

```
EMIC-TABS/
├── Code        # Plugin de control de flujo (copiado del template)
├── Data        # Plugin de variables (copiado del template)
├── Functions   # Plugin de funciones de usuario (copiado del template)
├── User        # Plugin personalizado (copiado del template)
└── Resources   # GENERADO por EMIC-Discovery con funciones/eventos del módulo
```

El archivo `Resources` es generado automáticamente por EMIC-Discovery y contendrá las funciones de LEDs, TIMER y TEMPERATURE basándose en los tags DOXYGEN de esas APIs.

## 25.8 Resumen

### Archivos de un Módulo

| Archivo | Propósito | Capítulo de Referencia |
|---------|-----------|------------------------|
| `m_description.json` | Metadatos para el Editor | Este capítulo |
| `generate.emic` | Script de generación de código | Capítulo 23 |
| `deploy.emic` | Script de instanciación | Capítulo 24 |

### Archivos Generados Automáticamente

| Archivo | Generado Por | Descripción |
|---------|--------------|-------------|
| `EMIC-TABS/Resources` | EMIC-Discovery | Funciones y eventos del módulo (XML) |
| `EMIC-TABS/Code` | deploy.emic (copia) | Plugin de control de flujo |
| `EMIC-TABS/Data` | deploy.emic (copia) | Plugin de variables |
| `EMIC-TABS/Functions` | deploy.emic (copia) | Plugin de funciones de usuario |

### Flujo de Desarrollo de un Módulo

1. **Diseñar el hardware** y crear/seleccionar el archivo PCB correspondiente
2. **Crear la estructura de carpetas** del módulo en `_modules/Categoria/`
3. **Definir los metadatos** en `m_description.json`
4. **Configurar generate.emic** seleccionando las APIs necesarias (determina qué aparece en el Editor)
5. **Configurar deploy.emic** para la inicialización (copia plugins base)
6. **Probar el módulo** creando un proyecto en el Editor EMIC
7. **Verificar la compilación** en MPLAB X y el funcionamiento del firmware

> **Nota**: No es necesario crear el archivo `Resources` manualmente. Se genera automáticamente por EMIC-Discovery basándose en los tags DOXYGEN de las APIs incluidas en `generate.emic`.

### Referencias Cruzadas

- **Capítulo 21**: Desarrollo de API - cómo crear las APIs que usa el módulo
- **Capítulo 22**: Desarrollo de Driver - cómo crear los drivers de bajo nivel
- **Capítulo 23**: Proceso de Generación - sistema de grupos, expansión de macros
- **Capítulo 24**: Proceso de Deploy - instanciación y EMIC-Discovery
- **Capítulo 26**: Plugins del Editor - sistema de plugins extensible
