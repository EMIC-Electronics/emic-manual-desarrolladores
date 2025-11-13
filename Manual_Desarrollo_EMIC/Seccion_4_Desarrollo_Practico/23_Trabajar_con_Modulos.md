# Capítulo 23: Trabajar con Módulos

## Índice
1. [Introducción](#introducción)
2. [¿Qué es un Módulo EMIC?](#qué-es-un-módulo-emic)
3. [Estructura de un Módulo](#estructura-de-un-módulo)
4. [Archivos Clave del Módulo](#archivos-clave-del-módulo)
5. [Ciclo de Vida de un Módulo](#ciclo-de-vida-de-un-módulo)
6. [Tutorial: Crear un Módulo Simple](#tutorial-crear-un-módulo-simple)
7. [Tutorial: Crear un Módulo Multi-Componente](#tutorial-crear-un-módulo-multi-componente)
8. [Proyectos Multi-Módulo](#proyectos-multi-módulo)
9. [Comunicación entre Módulos](#comunicación-entre-módulos)
10. [Gestión de Dependencias](#gestión-de-dependencias)
11. [Configuración Dinámica de Módulos](#configuración-dinámica-de-módulos)
12. [Caso Práctico: Sistema IoT Modular](#caso-práctico-sistema-iot-modular)
13. [Buenas Prácticas](#buenas-prácticas)
14. [Errores Comunes](#errores-comunes)
15. [Resumen del Capítulo](#resumen-del-capítulo)

---

## Introducción

En los capítulos anteriores aprendiste a crear proyectos simples y APIs reutilizables. Ahora aprenderás a trabajar con **módulos**, la unidad fundamental de organización en EMIC que permite crear **sistemas escalables y complejos**.

### ¿Por qué Módulos?

Los módulos permiten:
- ✅ Organizar proyectos complejos en unidades lógicas
- ✅ Reutilizar configuraciones completas de hardware
- ✅ Separar responsabilidades (sensores, comunicación, control)
- ✅ Escalar proyectos de forma incremental
- ✅ Compartir soluciones completas con la comunidad

### Nivel de Complejidad

```
Proyecto Simple (Cap 21)
    ↓
API Reutilizable (Cap 22)
    ↓
Módulo Completo (Cap 23) ← Estás aquí
    ↓
Sistema Multi-Módulo (Cap 23)
```

---

## ¿Qué es un Módulo EMIC?

Un **Módulo EMIC** es una **unidad funcional completa** que encapsula hardware, firmware, configuración y lógica de negocio para resolver un problema específico o proporcionar una funcionalidad bien definida.

### Definición Formal

> **Módulo EMIC**: Conjunto de archivos organizados en carpetas System/ y Target/ que representan una solución hardware+software completa, incluyendo:
> - Configuración de hardware (PCB, pines, periféricos)
> - APIs y drivers necesarios
> - Lógica de aplicación
> - Scripts de generación y deployment
> - Código fuente generado y compilable

### Ejemplos de Módulos

| Módulo | Funcionalidad | Componentes |
|--------|---------------|-------------|
| **Development_Board** | Placa de desarrollo completa | LEDs, timers, UART, LCD, sensores |
| **TemperatureMonitor** | Monitor de temperatura | Sensor, LED status, USB comm |
| **HRD_X2_RELAY** | Control de 2 relays | Relays, entradas digitales |
| **Bluetooth** | Comunicación Bluetooth | Módulo BLE, UART bridge |
| **Lavarropas** | Controlador de lavarropas | Motor, sensores, LCD, selectores |

### Diferencia: Proyecto vs Módulo

| Aspecto | Proyecto | Módulo |
|---------|----------|--------|
| **Es un** | Solución completa deployable | Unidad funcional dentro del proyecto |
| **Contiene** | Uno o más módulos | APIs + Drivers + Lógica |
| **Ubicación** | `USER:/My Projects/` | `USER:/My Projects/{Proyecto}/{Modulo}/` |
| **Propósito** | Firmware final compilable | Funcionalidad específica reutilizable |
| **Cantidad** | 1 por firmware | 1 o más por proyecto |
| **Ejemplos** | "Sistema_Riego", "Alarma_Casa" | "SensorModule", "CommModule" |

---

## Estructura de un Módulo

### Estructura de Directorios

```
_modules/                               # Módulos del SDK (plantillas)
└── Categoria/                          # Ej: Sensors, Actuators, Communication
    └── NombreModulo/                   # Ej: TemperatureMonitor
        ├── m_description.json          # Metadata del módulo
        ├── System/                     # Configuración y scripts
        │   ├── deploy.emic             # Script de deployment
        │   ├── generate.emic           # Script de generación
        │   ├── module.json             # Info del módulo
        │   ├── config.json             # Configuración dinámica
        │   ├── program.xml             # Código visual (EMIC-Editor)
        │   ├── userFncFile.c           # Lógica del usuario
        │   ├── inc/userFncFile.h
        │   └── EMIC-TABS/              # Widgets UI
        │       ├── Resources/
        │       └── Data/
        └── Target/                     # Código generado (salida)
            ├── *.c
            ├── *.h
            ├── Makefile
            ├── generate.txt            # Log de generación
            └── dist/                   # Firmware compilado
                └── production/
                    └── firmware.hex
```

### Carpeta System/

Contiene todos los archivos de **configuración y entrada**:
- **deploy.emic**: Inicializa el módulo (primera vez)
- **generate.emic**: Genera código compilable (cada compilación)
- **module.json**: Metadata del módulo
- **config.json**: Configuración dinámica
- **userFncFile.c/h**: Lógica del integrador
- **program.xml**: Código visual del EMIC-Editor
- **EMIC-TABS/**: Widgets de interfaz

### Carpeta Target/

Contiene todos los archivos **generados por EMIC-Generate**:
- **Código C/H**: APIs instanciadas
- **Makefile**: Script de compilación
- **generate.txt**: Log detallado del proceso
- **dist/firmware.hex**: Firmware compilado

---

## Archivos Clave del Módulo

### 1. module.json

Define metadata del módulo:

```json
{
  "moduleName": "TemperatureMonitor",
  "version": "1.2.0",
  "description": "Sistema de monitoreo de temperatura con alertas",
  "category": "Sensors",
  "author": "Juan Pérez",
  "license": "MIT",
  "dependencies": [],
  "hardware": {
    "mcu": "PIC24FJ64GA002",
    "sensors": ["DHT22"],
    "communication": ["USB"]
  },
  "tags": ["temperature", "monitoring", "usb"]
}
```

### 2. config.json

Configuración dinámica modificable desde EMIC-Editor:

```json
{
  "temperature": {
    "unit": "Celsius",
    "sample_rate_ms": 2000,
    "threshold_high": 30.0,
    "threshold_low": 15.0
  },
  "communication": {
    "usb_baud": 9600,
    "report_interval_ms": 5000
  },
  "leds": {
    "enable_status_led": true,
    "blink_on_reading": false
  }
}
```

**Uso en código:**
```c
// Leer configuración
float threshold_high = config_GetFloat("temperature.threshold_high");
uint16_t sample_rate = config_GetUint16("temperature.sample_rate_ms");
```

### 3. deploy.emic

Script ejecutado **una vez** al crear el módulo. Inicializa archivos y estructura.

```emic
EMIC:setOutput(TARGET:deploy.txt)

    //------------------- Crear archivos iniciales ----------------
    EMIC:setOutput(SYS:inc/userFncFile.h)
    #ifndef USERFNCFILE_H
    #define USERFNCFILE_H

    void EMIC_INIT_USER(void);
    void EMIC_LOOP_USER(void);

    #endif
    EMIC:restoreOutput

    EMIC:setOutput(SYS:userFncFile.c)
    #include "inc/userFncFile.h"

    void EMIC_INIT_USER(void) {
        // Inicialización del usuario
    }

    void EMIC_LOOP_USER(void) {
        // Loop principal del usuario
    }
    EMIC:restoreOutput

    // Copiar templates de UI
    EMIC:copy(DEV:_templates/plugins/sidebar-tabs > SYS:EMIC-TABS)

EMIC:restoreOutput
```

**Propósito:**
- Crear archivos base (userFncFile.c/h)
- Copiar templates de interfaz
- Inicializar configuración
- Solo se ejecuta UNA vez

### 4. generate.emic

Script ejecutado **cada vez** que se compila. Genera el código C final.

```emic
EMIC:setOutput(TARGET:generate.txt)

    //-------------- Hardware Config ---------------------
    EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_USB V1.1)

    //-- Process EMIC-Generate files result --
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    //------------------- APIs -----------------------
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=status,pin=Led1)
    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)
    EMIC:setInput(DEV:_api/Sensors/Temperature/temperature.emic,name=sensor1,pin=AN0)
    EMIC:setInput(DEV:_api/Wired_Communication/USB/USB_API.emic,driver=MCP2200,port=1,baud=9600,name=usb)

    //-------------------- main  -----------------------
    EMIC:setInput(DEV:_main/baremetal/main.emic)

    //-- Copy EMIC-Generate files result ----------------
    EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
    EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)

    //---- Set userFncFile.c as a compiler module ---------
    EMIC:define(c_modules.userFncFile,userFncFile)

    //-- Add all compiler modules to the project --
    EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

**Propósito:**
- Incluir PCB y hardware
- Instanciar APIs necesarias
- Copiar código del usuario
- Generar proyecto MPLAB X
- Se ejecuta en cada compilación

---

## Ciclo de Vida de un Módulo

### Fase 1: Creación (Deploy)

```
1. Integrador crea nuevo módulo en EMIC-Editor
         ↓
2. Sistema ejecuta deploy.emic
         ↓
3. Se crean archivos base:
   - System/userFncFile.c
   - System/userFncFile.h
   - System/EMIC-TABS/
         ↓
4. Módulo listo para configuración
```

### Fase 2: Configuración

```
1. Integrador abre módulo en EMIC-Editor
         ↓
2. Edita generate.emic (qué APIs usar)
         ↓
3. Configura parámetros en config.json
         ↓
4. Programa lógica (program.xml o userFncFile.c)
         ↓
5. Módulo listo para generación
```

### Fase 3: Generación (Generate)

```
1. Integrador presiona "Generate" en EMIC-Editor
         ↓
2. EMIC-Generate ejecuta generate.emic
         ↓
3. Se procesan todas las directivas EMIC:
   - setInput (incluir APIs)
   - copy (copiar archivos)
   - define (registrar módulos)
         ↓
4. Se generan archivos en Target/:
   - Código C de APIs instanciadas
   - userFncFile.c (copiado)
   - main.c
   - Makefile
         ↓
5. Módulo listo para compilación
```

### Fase 4: Compilación

```
1. Integrador presiona "Compile" en EMIC-Editor
         ↓
2. Se ejecuta XC8/XC16/XC32 compiler
         ↓
3. Se compilan todos los archivos .c
         ↓
4. Se genera firmware.hex en Target/dist/
         ↓
5. Módulo listo para deployment en hardware
```

### Diagrama del Ciclo Completo

```
┌────────────────────────────────────────────────────────────┐
│  Fase 1: DEPLOY (una vez)                                  │
│  deploy.emic → System/userFncFile.c                        │
└────────────────────────────────────────────────────────────┘
                         │
                         ↓
┌────────────────────────────────────────────────────────────┐
│  Fase 2: CONFIGURACIÓN (iterativo)                         │
│  Editar generate.emic, config.json, userFncFile.c          │
└────────────────────────────────────────────────────────────┘
                         │
                         ↓
┌────────────────────────────────────────────────────────────┐
│  Fase 3: GENERATE (cada cambio)                            │
│  generate.emic → Target/*.c                                │
└────────────────────────────────────────────────────────────┘
                         │
                         ↓
┌────────────────────────────────────────────────────────────┐
│  Fase 4: COMPILE (cada generate)                           │
│  Target/*.c → firmware.hex                                 │
└────────────────────────────────────────────────────────────┘
                         │
                         ↓
┌────────────────────────────────────────────────────────────┐
│  Fase 5: DEPLOYMENT                                        │
│  firmware.hex → Microcontrolador                           │
└────────────────────────────────────────────────────────────┘
```

---

## Tutorial: Crear un Módulo Simple

Vamos a crear un módulo simple: **LED_Blinker** que hace parpadear un LED con frecuencia configurable.

### Paso 1: Definir Especificaciones

**Nombre:** LED_Blinker
**Categoría:** Indicators
**Funcionalidad:** Hacer parpadear un LED con frecuencia configurable
**Hardware:** 1 LED + 1 Timer
**Configuración:**
- `blink_interval_ms`: Intervalo de parpadeo (default: 500ms)
- `led_pin`: Pin del LED

### Paso 2: Crear Estructura de Directorios

```bash
# En el proyecto
mkdir -p LED_Blinker/System
mkdir -p LED_Blinker/Target
```

### Paso 3: Crear module.json

**Archivo:** `LED_Blinker/System/module.json`

```json
{
  "moduleName": "LED_Blinker",
  "version": "1.0.0",
  "description": "Simple LED blinker with configurable frequency",
  "category": "Indicators",
  "author": "Tu Nombre",
  "hardware": {
    "mcu": "PIC24FJ64GA002",
    "components": ["LED"]
  }
}
```

### Paso 4: Crear config.json

**Archivo:** `LED_Blinker/System/config.json`

```json
{
  "led": {
    "pin": "A0_Pin",
    "blink_interval_ms": 500
  }
}
```

### Paso 5: Crear deploy.emic

**Archivo:** `LED_Blinker/System/deploy.emic`

```emic
EMIC:setOutput(TARGET:deploy.txt)

    //------------------- Crear userFncFile.h ----------------
    EMIC:setOutput(SYS:inc/userFncFile.h)
    #ifndef USERFNCFILE_H
    #define USERFNCFILE_H

    #include <stdint.h>
    #include <stdbool.h>

    void EMIC_INIT_USER(void);
    void EMIC_LOOP_USER(void);

    #endif
    EMIC:restoreOutput

    //------------------- Crear userFncFile.c ----------------
    EMIC:setOutput(SYS:userFncFile.c)
    #include "inc/userFncFile.h"

    /**
     * @fn void EMIC_INIT_USER(void)
     * @brief Inicialización del módulo LED_Blinker
     * @@EMIC_TAG::{FUNCTION,Event:INIT,Type:void}
     */
    void EMIC_INIT_USER(void) {
        // TODO: Inicializar LED y timer
    }

    /**
     * @fn void EMIC_LOOP_USER(void)
     * @brief Loop principal del módulo LED_Blinker
     * @@EMIC_TAG::{FUNCTION,Event:LOOP,Type:void}
     */
    void EMIC_LOOP_USER(void) {
        // TODO: Lógica de parpadeo
    }
    EMIC:restoreOutput

    // Copiar templates de UI
    EMIC:copy(DEV:_templates/plugins/sidebar-tabs > SYS:EMIC-TABS)

EMIC:restoreOutput
```

### Paso 6: Crear generate.emic

**Archivo:** `LED_Blinker/System/generate.emic`

```emic
EMIC:setOutput(TARGET:generate.txt)

    //-------------- Hardware Config ---------------------
    EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_Development_Board)

    //-- Process EMIC-Generate files result --
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    //------------------- APIs -----------------------
    // Leer configuración desde config.json
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=blink_led,pin=.{config.led.pin}.)
    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)

    //-------------------- main  -----------------------
    EMIC:setInput(DEV:_main/baremetal/main.emic)

    //-- Copy EMIC-Generate files result ----------------
    EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
    EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)

    //---- Set userFncFile.c as a compiler module ---------
    EMIC:define(c_modules.userFncFile,userFncFile)

    //-- Add all compiler modules to the project --
    EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

**Nota:** `.{config.led.pin}.` lee el valor de `config.json`

### Paso 7: Implementar userFncFile.c

**Archivo:** `LED_Blinker/System/userFncFile.c`

```c
#include "inc/userFncFile.h"

// Leer configuración desde config.json
// EMIC-Generate sustituye esto con el valor real
#define BLINK_INTERVAL_MS  .{config.led.blink_interval_ms}.

/**
 * @fn void EMIC_INIT_USER(void)
 * @brief Inicialización del módulo LED_Blinker
 * @@EMIC_TAG::{FUNCTION,Event:INIT,Type:void}
 */
void EMIC_INIT_USER(void) {
    // Apagar LED inicialmente
    blink_led_Off();

    // Configurar timer con el intervalo configurado
    timer1_SetPeriod(BLINK_INTERVAL_MS);
    timer1_Start();
}

/**
 * @fn void EMIC_LOOP_USER(void)
 * @brief Loop principal del módulo LED_Blinker
 * @@EMIC_TAG::{FUNCTION,Event:LOOP,Type:void}
 */
void EMIC_LOOP_USER(void) {
    // Verificar si el timer expiró
    if (timer1_HasElapsed()) {
        // Toggle LED
        blink_led_Toggle();

        // Reiniciar timer
        timer1_Restart();
    }
}
```

### Paso 8: Generar y Compilar

```bash
# Ejecutar deploy (primera vez)
emic-generate deploy --module LED_Blinker

# Ejecutar generate
emic-generate compile --module LED_Blinker

# Compilar
cd LED_Blinker/Target
make all
```

### Resultado

```
LED_Blinker/Target/
├── generate.txt                    # Log del proceso
├── led_blink_led.c / .h            # LED instanciado
├── timer_api1.c / .h               # Timer instanciado
├── userFncFile.c / .h              # Lógica del usuario
├── main.c                          # Main generado
├── Makefile
└── dist/production/firmware.hex    # Firmware compilado
```

---

## Tutorial: Crear un Módulo Multi-Componente

Ahora vamos a crear un módulo más complejo: **SmartThermostat** con múltiples componentes.

### Especificaciones

**Funcionalidad:**
- Leer temperatura ambiente (sensor DHT22)
- Controlar calefacción (relay)
- Controlar ventilador (PWM)
- Display LCD para mostrar temperatura
- Comunicación UART para logs
- LEDs de estado (frío, normal, caliente)
- Botones para ajustar temperatura deseada

**Componentes:**
- 1 Sensor DHT22
- 1 Relay (calefacción)
- 1 Motor con PWM (ventilador)
- 1 LCD 16x2
- 1 UART
- 3 LEDs (azul, verde, rojo)
- 2 Botones (subir, bajar)

### Estructura del Módulo

```
SmartThermostat/
├── System/
│   ├── module.json
│   ├── config.json
│   ├── deploy.emic
│   ├── generate.emic
│   ├── userFncFile.c
│   └── inc/userFncFile.h
└── Target/
```

### module.json

```json
{
  "moduleName": "SmartThermostat",
  "version": "1.0.0",
  "description": "Smart thermostat with temperature control and display",
  "category": "Climate_Control",
  "author": "Tu Nombre",
  "hardware": {
    "mcu": "PIC24FJ64GA002",
    "sensors": ["DHT22"],
    "actuators": ["Relay", "PWM_Fan"],
    "display": "LCD_16x2",
    "communication": ["UART"]
  },
  "dependencies": []
}
```

### config.json

```json
{
  "temperature": {
    "target_temp": 22.0,
    "hysteresis": 2.0,
    "unit": "Celsius",
    "sample_rate_ms": 2000
  },
  "control": {
    "heating_mode": "auto",
    "fan_speed_min": 30,
    "fan_speed_max": 100
  },
  "display": {
    "update_interval_ms": 500,
    "brightness": 80
  },
  "communication": {
    "uart_baud": 9600,
    "log_interval_ms": 5000
  }
}
```

### generate.emic

```emic
EMIC:setOutput(TARGET:generate.txt)

    //-------------- Hardware Config ---------------------
    EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_Development_Board)

    //-- Process EMIC-Generate files result --
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    //------------------- Sensors -----------------------
    EMIC:setInput(DEV:_drivers/Temperature/DHT22/dht22.emic,name=temp_sensor,pin=B0_Pin)

    //------------------- Actuators ---------------------
    // Relay para calefacción
    EMIC:setInput(DEV:_api/Actuators/Relay/relay.emic,name=heater,pin=B1_Pin)

    // PWM para ventilador
    EMIC:setInput(DEV:_api/Actuators/PWM/pwm.emic,name=fan,pin=B2_Pin,timer=2,frequency=25000)

    //------------------- Display -----------------------
    EMIC:setInput(DEV:_drivers/Display/LCD_16x2/lcd.emic,name=display,rs=B3_Pin,en=B4_Pin,d4=B5_Pin,d5=B6_Pin,d6=B7_Pin,d7=C0_Pin)

    //------------------- Communication -----------------
    EMIC:setInput(DEV:_api/Wired_Communication/UART/uart.emic,name=uart1,port=1,baud=.{config.communication.uart_baud}.,buffer_size=256)

    //------------------- Indicators --------------------
    // LEDs de estado
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led_cold,pin=A0_Pin)
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led_normal,pin=A1_Pin)
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led_hot,pin=A2_Pin)

    //------------------- Inputs ------------------------
    // Botones para ajustar temperatura
    EMIC:setInput(DEV:_api/Inputs/Button/button.emic,name=btn_up,pin=A3_Pin,debounce=50)
    EMIC:setInput(DEV:_api/Inputs/Button/button.emic,name=btn_down,pin=A4_Pin,debounce=50)

    //------------------- Timers ------------------------
    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)  // Lectura de sensor
    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=3)  // Actualización display
    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=4)  // Logs UART

    //-------------------- main  -----------------------
    EMIC:setInput(DEV:_main/baremetal/main.emic)

    //-- Copy EMIC-Generate files result ----------------
    EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
    EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)

    //---- Set userFncFile.c as a compiler module ---------
    EMIC:define(c_modules.userFncFile,userFncFile)

    //-- Add all compiler modules to the project --
    EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

### userFncFile.c (Completo)

```c
#include "inc/userFncFile.h"
#include <stdio.h>

// Configuración desde config.json
#define TARGET_TEMP           .{config.temperature.target_temp}.
#define HYSTERESIS            .{config.temperature.hysteresis}.
#define SAMPLE_RATE_MS        .{config.temperature.sample_rate_ms}.
#define DISPLAY_UPDATE_MS     .{config.display.update_interval_ms}.
#define LOG_INTERVAL_MS       .{config.communication.log_interval_ms}.
#define FAN_SPEED_MIN         .{config.control.fan_speed_min}.
#define FAN_SPEED_MAX         .{config.control.fan_speed_max}.

// Estados del termostato
typedef enum {
    THERMOSTAT_COOLING,    // Temperatura alta, ventilador ON
    THERMOSTAT_NORMAL,     // Temperatura normal
    THERMOSTAT_HEATING     // Temperatura baja, calefacción ON
} ThermostatState_t;

// Variables globales
static ThermostatState_t current_state = THERMOSTAT_NORMAL;
static float current_temp = 0.0f;
static float target_temp = TARGET_TEMP;
static uint32_t readings_count = 0;

// Prototipos de funciones auxiliares
static void UpdateThermostatState(void);
static void UpdateDisplay(void);
static void SendUartLog(void);
static void HandleButtons(void);
static uint8_t CalculateFanSpeed(float temp);

/**
 * @fn void EMIC_INIT_USER(void)
 * @brief Inicialización del SmartThermostat
 * @@EMIC_TAG::{FUNCTION,Event:INIT,Type:void}
 */
void EMIC_INIT_USER(void) {
    char buffer[64];

    // Inicializar actuadores
    heater_Off();           // Calefacción apagada
    fan_SetDutyCycle(0);    // Ventilador apagado
    fan_Start();

    // Inicializar LEDs
    led_cold_Off();
    led_normal_On();        // Estado inicial: normal
    led_hot_Off();

    // Inicializar display
    display_Init();
    display_Clear();
    display_SetCursor(0, 0);
    display_Print("SmartThermostat");
    display_SetCursor(0, 1);
    display_Print("Inicializando...");

    // Inicializar UART
    uart1_Init();
    uart1_WriteString("=== SmartThermostat System ===\r\n");
    sprintf(buffer, "Target Temp: %.1f C\r\n", target_temp);
    uart1_WriteString(buffer);

    // Configurar timers
    timer1_SetPeriod(SAMPLE_RATE_MS);       // Lectura de sensor
    timer3_SetPeriod(DISPLAY_UPDATE_MS);    // Actualización display
    timer4_SetPeriod(LOG_INTERVAL_MS);      // Logs UART

    timer1_Start();
    timer3_Start();
    timer4_Start();

    // Delay para mostrar mensaje inicial
    __delay_ms(2000);
    display_Clear();

    // Lectura inicial
    if (temp_sensor_Read()) {
        current_temp = temp_sensor_GetTemperature();
        UpdateThermostatState();
    }
}

/**
 * @fn void EMIC_LOOP_USER(void)
 * @brief Loop principal del SmartThermostat
 * @@EMIC_TAG::{FUNCTION,Event:LOOP,Type:void}
 */
void EMIC_LOOP_USER(void) {
    // Lectura de temperatura (cada SAMPLE_RATE_MS)
    if (timer1_HasElapsed()) {
        if (temp_sensor_Read()) {
            current_temp = temp_sensor_GetTemperature();
            readings_count++;
            UpdateThermostatState();
        }
        timer1_Restart();
    }

    // Actualización del display (cada DISPLAY_UPDATE_MS)
    if (timer3_HasElapsed()) {
        UpdateDisplay();
        timer3_Restart();
    }

    // Logs por UART (cada LOG_INTERVAL_MS)
    if (timer4_HasElapsed()) {
        SendUartLog();
        timer4_Restart();
    }

    // Manejo de botones (continuamente)
    HandleButtons();
}

/**
 * @fn static void UpdateThermostatState(void)
 * @brief Actualiza el estado del termostato según la temperatura
 */
static void UpdateThermostatState(void) {
    float temp_high = target_temp + HYSTERESIS;
    float temp_low = target_temp - HYSTERESIS;

    // Determinar nuevo estado
    if (current_temp > temp_high) {
        // Temperatura alta: activar ventilador
        current_state = THERMOSTAT_COOLING;

        heater_Off();
        uint8_t fan_speed = CalculateFanSpeed(current_temp);
        fan_SetDutyCycle(fan_speed);

        led_cold_Off();
        led_normal_Off();
        led_hot_On();

    } else if (current_temp < temp_low) {
        // Temperatura baja: activar calefacción
        current_state = THERMOSTAT_HEATING;

        heater_On();
        fan_SetDutyCycle(0);  // Ventilador apagado

        led_cold_On();
        led_normal_Off();
        led_hot_Off();

    } else {
        // Temperatura normal: todo apagado
        current_state = THERMOSTAT_NORMAL;

        heater_Off();
        fan_SetDutyCycle(0);

        led_cold_Off();
        led_normal_On();
        led_hot_Off();
    }
}

/**
 * @fn static void UpdateDisplay(void)
 * @brief Actualiza la información en el LCD
 */
static void UpdateDisplay(void) {
    char buffer[17];

    // Línea 1: Temperatura actual
    display_SetCursor(0, 0);
    sprintf(buffer, "Temp: %.1f C    ", current_temp);
    display_Print(buffer);

    // Línea 2: Target y estado
    display_SetCursor(0, 1);
    switch (current_state) {
        case THERMOSTAT_COOLING:
            sprintf(buffer, "T:%.0f COOLING  ", target_temp);
            break;
        case THERMOSTAT_HEATING:
            sprintf(buffer, "T:%.0f HEATING  ", target_temp);
            break;
        case THERMOSTAT_NORMAL:
            sprintf(buffer, "T:%.0f NORMAL   ", target_temp);
            break;
    }
    display_Print(buffer);
}

/**
 * @fn static void SendUartLog(void)
 * @brief Envía log por UART con estado actual
 */
static void SendUartLog(void) {
    char buffer[128];

    sprintf(buffer, "[%04lu] Temp: %.1f C | Target: %.1f C | State: ",
            readings_count, current_temp, target_temp);
    uart1_WriteString(buffer);

    switch (current_state) {
        case THERMOSTAT_COOLING:
            uart1_WriteString("COOLING");
            break;
        case THERMOSTAT_HEATING:
            uart1_WriteString("HEATING");
            break;
        case THERMOSTAT_NORMAL:
            uart1_WriteString("NORMAL");
            break;
    }
    uart1_WriteString("\r\n");
}

/**
 * @fn static void HandleButtons(void)
 * @brief Maneja los botones para ajustar temperatura
 */
static void HandleButtons(void) {
    // Botón UP: aumentar temperatura objetivo
    if (btn_up_WasPressed()) {
        target_temp += 1.0f;
        if (target_temp > 35.0f) {
            target_temp = 35.0f;  // Límite máximo
        }
        UpdateThermostatState();
        uart1_WriteString("Target temp increased\r\n");
    }

    // Botón DOWN: disminuir temperatura objetivo
    if (btn_down_WasPressed()) {
        target_temp -= 1.0f;
        if (target_temp < 10.0f) {
            target_temp = 10.0f;  // Límite mínimo
        }
        UpdateThermostatState();
        uart1_WriteString("Target temp decreased\r\n");
    }
}

/**
 * @fn static uint8_t CalculateFanSpeed(float temp)
 * @brief Calcula velocidad del ventilador según temperatura
 * @param temp Temperatura actual
 * @return Velocidad del ventilador (0-100%)
 */
static uint8_t CalculateFanSpeed(float temp) {
    // Mapear temperatura a velocidad del ventilador
    // temp_high → FAN_SPEED_MIN
    // temp_high + 10 → FAN_SPEED_MAX

    float temp_high = target_temp + HYSTERESIS;
    float temp_range = 10.0f;

    if (temp <= temp_high) {
        return FAN_SPEED_MIN;
    }

    if (temp >= temp_high + temp_range) {
        return FAN_SPEED_MAX;
    }

    // Interpolación lineal
    float ratio = (temp - temp_high) / temp_range;
    uint8_t speed = FAN_SPEED_MIN + (uint8_t)(ratio * (FAN_SPEED_MAX - FAN_SPEED_MIN));

    return speed;
}
```

### Resultado de la Generación

```
SmartThermostat/Target/
├── generate.txt
├── dht22_temp_sensor.c / .h       # Sensor DHT22
├── relay_heater.c / .h            # Relay calefacción
├── pwm_fan.c / .h                 # PWM ventilador
├── lcd_display.c / .h             # Display LCD
├── uart_uart1.c / .h              # UART
├── led_led_cold.c / .h            # LED azul
├── led_led_normal.c / .h          # LED verde
├── led_led_hot.c / .h             # LED rojo
├── button_btn_up.c / .h           # Botón subir
├── button_btn_down.c / .h         # Botón bajar
├── timer_api1.c / .h              # Timer 1 (sensor)
├── timer_api3.c / .h              # Timer 3 (display)
├── timer_api4.c / .h              # Timer 4 (UART)
├── userFncFile.c / .h             # Lógica del termostato
├── main.c
├── Makefile
└── dist/production/firmware.hex
```

**Total:** ~30 archivos generados automáticamente desde 1 generate.emic!

---

## Proyectos Multi-Módulo

Los proyectos complejos pueden tener **múltiples módulos** que trabajan juntos.

### Ejemplo: Sistema IoT Industrial

```
Sistema_IoT_Industrial/
├── project.json
├── SensorModule/               # Módulo de sensores
│   ├── System/
│   │   └── generate.emic
│   └── Target/
├── CommunicationModule/        # Módulo de comunicación
│   ├── System/
│   │   └── generate.emic
│   └── Target/
├── ControlModule/              # Módulo de control
│   ├── System/
│   │   └── generate.emic
│   └── Target/
└── DisplayModule/              # Módulo de interfaz
    ├── System/
    │   └── generate.emic
    └── Target/
```

### Ventajas de Multi-Módulo

1. **Separación de responsabilidades**
   - Cada módulo tiene una función clara
   - Fácil de mantener y depurar

2. **Desarrollo paralelo**
   - Diferentes desarrolladores trabajan en diferentes módulos
   - Menos conflictos de código

3. **Reutilización**
   - Un módulo puede usarse en múltiples proyectos
   - Ej: CommunicationModule en todos los productos

4. **Escalabilidad**
   - Añadir nuevas funciones = añadir nuevos módulos
   - No afecta código existente

---

## Comunicación entre Módulos

Los módulos pueden comunicarse de varias formas:

### 1. Variables Globales Compartidas

```c
// En Module1/System/userFncFile.c
extern float temperature_global;  // Declarar extern

// En Module2/System/userFncFile.c
float temperature_global = 0.0f;  // Definir

// Uso en Module1
void EMIC_LOOP_USER(void) {
    if (temperature_global > 30.0f) {
        // Reaccionar a temperatura
    }
}
```

### 2. Eventos EMIC

```c
// Module1 publica evento
EMIC:define(event.temperature_high, OnTemperatureHigh)

// Module2 se suscribe al evento
EMIC:ifdef event.temperature_high
void OnTemperatureHigh(void) {
    // Manejar evento
}
EMIC:endif
```

### 3. Sistema de Mensajes

```c
// msg_queue.h (compartido)
typedef struct {
    uint8_t sender_id;
    uint8_t msg_type;
    uint8_t data[16];
} Message_t;

void msg_Send(Message_t *msg);
bool msg_Receive(Message_t *msg);

// Module1 envía mensaje
Message_t msg = {
    .sender_id = MODULE_SENSOR,
    .msg_type = MSG_TEMP_READING,
    .data = {temp_high, temp_low, ...}
};
msg_Send(&msg);

// Module2 recibe mensaje
Message_t msg;
if (msg_Receive(&msg)) {
    if (msg.msg_type == MSG_TEMP_READING) {
        // Procesar
    }
}
```

---

## Gestión de Dependencias

### Declarar Dependencias en module.json

```json
{
  "moduleName": "ControlModule",
  "dependencies": [
    {
      "module": "SensorModule",
      "version": ">=1.0.0",
      "required": true
    },
    {
      "module": "CommunicationModule",
      "version": "^2.0.0",
      "required": false
    }
  ]
}
```

### Verificación de Dependencias

EMIC-Generate verifica automáticamente:
- ✅ Módulos requeridos presentes
- ✅ Versiones compatibles
- ❌ Error si falta dependencia crítica

---

## Configuración Dinámica de Módulos

### Leer Configuración en Runtime

```c
// Incluir config reader
#include "inc/config.h"

// Leer valores de config.json
void EMIC_INIT_USER(void) {
    float threshold = config_GetFloat("temperature.threshold_high");
    uint16_t interval = config_GetUint16("sampling.interval_ms");
    const char* mode = config_GetString("control.mode");

    // Usar valores
    SetThreshold(threshold);
    SetInterval(interval);
    if (strcmp(mode, "auto") == 0) {
        EnableAutoMode();
    }
}
```

### Modificar Configuración Dinámicamente

```c
// Guardar nueva configuración
config_SetFloat("temperature.threshold_high", 35.0f);
config_Save();  // Persiste en memoria no volátil (EEPROM)
```

---

## Caso Práctico: Sistema IoT Modular

### Arquitectura del Sistema

```
Sistema_Monitoreo_Industrial/
├── project.json
├── SensorModule/                  # Lee sensores (temp, humedad, presión)
├── DataProcessingModule/          # Procesa y almacena datos
├── CommunicationModule/           # Envía datos a la nube (WiFi/LoRa)
├── AlertModule/                   # Sistema de alarmas
└── LocalDisplayModule/            # Display local para operador
```

### Flujo de Datos

```
SensorModule
    ↓ (lectura cada 5s)
DataProcessingModule
    ↓ (procesa y almacena)
    ├→ CommunicationModule (envía a nube cada 1min)
    ├→ AlertModule (verifica umbrales)
    └→ LocalDisplayModule (actualiza display)
```

### Configuración Global (project.json)

```json
{
  "name": "Sistema_Monitoreo_Industrial",
  "version": "1.0.0",
  "modules": [
    "SensorModule",
    "DataProcessingModule",
    "CommunicationModule",
    "AlertModule",
    "LocalDisplayModule"
  ],
  "global_config": {
    "sampling_interval_ms": 5000,
    "cloud_upload_interval_ms": 60000,
    "alert_email": "admin@empresa.com"
  }
}
```

---

## Buenas Prácticas

### 1. Un Módulo, Una Responsabilidad

```
✅ BUENO:
- SensorModule (solo lee sensores)
- CommunicationModule (solo comunicación)
- ControlModule (solo lógica de control)

❌ MALO:
- MegaModule (hace todo: sensores + comunicación + control + display)
```

### 2. Interfaces Claras entre Módulos

```c
✅ BUENO:
// sensor_module.h
float sensor_GetTemperature(void);
float sensor_GetHumidity(void);
bool sensor_IsReady(void);

❌ MALO:
// Acceso directo a variables internas
extern float __sensor_temp_raw;
extern uint8_t __sensor_state;
```

### 3. Configuración Centralizada

```
✅ BUENO:
- Toda la configuración en config.json
- Fácil de modificar sin recompilar

❌ MALO:
- #define hardcodeados en múltiples archivos
- Difícil de mantener
```

### 4. Versionado Semántico

```json
✅ BUENO:
{
  "version": "1.2.3",
  "changelog": [
    "1.2.3: Fix sensor timeout bug",
    "1.2.0: Add humidity sensor support",
    "1.0.0: Initial release"
  ]
}
```

### 5. Documentar Dependencias

```json
✅ BUENO:
{
  "dependencies": [
    {"module": "SensorModule", "version": ">=1.0.0", "reason": "Temperature readings"}
  ]
}
```

---

## Errores Comunes

### Error 1: Módulos Fuertemente Acoplados

```c
❌ MALO:
// Module1 conoce detalles internos de Module2
void Module1_Process(void) {
    if (Module2_internal_state == STATE_READY) {
        float data = Module2_raw_buffer[0];
        // ...
    }
}

✅ BUENO:
// Module1 usa interfaz pública de Module2
void Module1_Process(void) {
    if (Module2_IsReady()) {
        float data = Module2_GetData();
        // ...
    }
}
```

### Error 2: Olvidar Inicializar Módulos

```c
❌ MALO:
void EMIC_INIT_USER(void) {
    // Olvida llamar inicializaciones de submódulos
    my_custom_function();
}

✅ BUENO:
void EMIC_INIT_USER(void) {
    // Inicializar todos los submódulos
    sensor_Init();
    comm_Init();
    display_Init();

    my_custom_function();
}
```

### Error 3: Conflictos de Nombres Globales

```c
❌ MALO:
// Module1.c
int state = 0;  // Variable global

// Module2.c
int state = 0;  // CONFLICTO! Mismo nombre

✅ BUENO:
// Module1.c
static int module1_state = 0;  // static = privado al archivo

// Module2.c
static int module2_state = 0;  // OK, no hay conflicto
```

### Error 4: No Manejar Errores de Módulos

```c
❌ MALO:
sensor_Read();
float temp = sensor_GetTemperature();  // ¿Y si falló la lectura?

✅ BUENO:
if (sensor_Read()) {
    float temp = sensor_GetTemperature();
    ProcessTemperature(temp);
} else {
    LogError("Sensor read failed");
    UseDefaultTemperature();
}
```

---

## Resumen del Capítulo

### Lo que Aprendiste

1. **¿Qué es un módulo EMIC?**
   - Unidad funcional completa (hardware + firmware + lógica)
   - Organizado en System/ (config) y Target/ (generado)
   - Reutilizable y escalable

2. **Estructura de un módulo**
   - **System/**: config, scripts, código usuario
   - **Target/**: código generado, Makefile, firmware.hex
   - **Archivos clave**: deploy.emic, generate.emic, module.json, config.json

3. **Ciclo de vida**
   - Deploy → Configuración → Generate → Compile → Deployment
   - deploy.emic se ejecuta UNA vez
   - generate.emic se ejecuta CADA compilación

4. **Proyectos multi-módulo**
   - Separación de responsabilidades
   - Comunicación entre módulos (variables, eventos, mensajes)
   - Gestión de dependencias

5. **Módulos creados**
   - LED_Blinker (simple)
   - SmartThermostat (complejo con 10+ componentes)

### Diferencia Proyecto vs Módulo

```
Proyecto
    └── Módulo 1 (SensorModule)
    └── Módulo 2 (CommunicationModule)
    └── Módulo 3 (ControlModule)

1 Firmware = 1 Proyecto = N Módulos
```

### Archivos Clave de un Módulo

| Archivo | Propósito | Frecuencia |
|---------|-----------|------------|
| deploy.emic | Inicializar módulo | Una vez (creación) |
| generate.emic | Generar código | Cada compilación |
| module.json | Metadata | Versionado |
| config.json | Configuración dinámica | Modificable en runtime |
| userFncFile.c | Lógica del usuario | Código personalizado |

### Checklist de Calidad de Módulo

- ✅ Responsabilidad única y clara
- ✅ Interfaces bien definidas
- ✅ Configuración centralizada en config.json
- ✅ Dependencias documentadas en module.json
- ✅ Versionado semántico
- ✅ Manejo de errores robusto
- ✅ Nombres únicos (evitar conflictos)
- ✅ Testing exhaustivo
- ✅ Documentación completa

### Próximos Pasos

En los siguientes capítulos aprenderás:
- **Cap 24**: Debugging y Testing (técnicas avanzadas)
- **Cap 25**: Integración de Componentes (sistemas complejos)
- **Cap 26**: Deployment y Producción (publicar y mantener)

---

**¡Felicitaciones!** Ahora dominas el sistema de módulos EMIC, la base para crear soluciones escalables y profesionales. Los módulos permiten organizar proyectos complejos en unidades manejables y reutilizables.

**Recuerda**: Un buen módulo es **cohesivo internamente** (hace una cosa bien) y **débilmente acoplado externamente** (depende poco de otros módulos).

---

**Sección 4 - Capítulo 23**
Manual de Desarrollo EMIC SDK
Versión 1.0.0

---
