# Capítulo 11: Carpeta `_main/` - Punto de Entrada Principal

## Índice
1. [¿Qué es `_main/`?](#1-qué-es-_main)
2. [Estructura del main.c Baremetal](#2-estructura-del-mainc-baremetal)
3. [Flujo de Ejecución del Firmware](#3-flujo-de-ejecución-del-firmware)
4. [Sistema de Inicialización (inits)](#4-sistema-de-inicialización-inits)
5. [Sistema de Polling (polls)](#5-sistema-de-polling-polls)
6. [Eventos del Sistema](#6-eventos-del-sistema)
7. [Integración con el SDK](#7-integración-con-el-sdk)
8. [Ejemplo Completo de Generación](#8-ejemplo-completo-de-generación)
9. [Personalización del Main](#9-personalización-del-main)
10. [Buenas Prácticas](#10-buenas-prácticas)

---

## 1. ¿Qué es `_main/`?

La carpeta `_main/` contiene el **punto de entrada principal** del firmware generado por EMIC. Es donde se define la función `main()` que el microcontrolador ejecuta al iniciarse.

### 1.1 Ubicación en la Arquitectura EMIC

```
┌─────────────────────────────────────────────────┐
│    COMPILACIÓN FINAL → Firmware.hex             │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│         main.c (TARGET:main.c)                  │ ← ESTE NIVEL
│         Generado desde _main/baremetal/         │
├─────────────────────────────────────────────────┤
│  Integra:                                       │
│  - System (_hard/System/)                       │
│  - APIs (_api/)                                 │
│  - Drivers (_drivers/)                          │
│  - Módulos (_modules/)                          │
│  - Código de usuario (userFncFile.c)            │
└─────────────────────────────────────────────────┘
```

### 1.2 Contenido de `_main/`

```
_main/
└── baremetal/
    ├── main.c          # Template del main() con macros EMIC-Codify
    └── main.emic       # Archivo de integración EMIC
```

### 1.3 Responsabilidades de `_main/`

| Responsabilidad | Descripción |
|----------------|-------------|
| **Punto de entrada** | Define la función `main()` que ejecuta el MCU |
| **Inicialización del sistema** | Llama a `initSystem()` de `_hard/System/` |
| **Inicialización de periféricos** | Ejecuta todos los `inits.*` registrados por APIs/Drivers |
| **Loop principal** | Ejecuta `while(1)` con `polls.*` registrados |
| **Eventos del sistema** | Provee hooks `onReset()` y `SystemConfig()` |

---

## 2. Estructura del main.c Baremetal

El archivo **`_main/baremetal/main.c`** es el **template** que EMIC usa para generar el punto de entrada del firmware.

### 2.1 Código Completo del main.c

**Archivo: `_main/baremetal/main.c`**

```c
#include <xc.h>
#include "inc/systemConfig.h"

#include "inc/.{main_includes.*}..h"
#include "inc/.{includes_head.*}..h"
#include "inc/userFncFile.h"

#include ".{includes_src.*}..c"

int main(void)
{
    initSystem();
    EMIC:ifdef usedEvent.SystemConfig
    SystemConfig();
    EMIC:endif
    .{inits.*}.();
    EMIC:ifdef usedEvent.onReset
    onReset();
    EMIC:endif
    do
    {
        .{polls.*}.();
    }
    while(1);
}
```

### 2.2 Análisis Línea por Línea

| Línea | Código | Explicación |
|-------|--------|-------------|
| 1 | `#include <xc.h>` | Header del compilador XC (XC8/XC16/XC32) |
| 2 | `#include "inc/systemConfig.h"` | Configuración de bits del MCU (fuses) |
| 4 | `#include "inc/.{main_includes.*}..h"` | **Macro EMIC**: Incluye headers registrados con `EMIC:define(main_includes.*)` |
| 5 | `#include "inc/.{includes_head.*}..h"` | **Macro EMIC**: Incluye headers del sistema |
| 6 | `#include "inc/userFncFile.h"` | Header con funciones del integrador |
| 8 | `#include ".{includes_src.*}..c"` | **Macro EMIC**: Incluye archivos .c compilados inline |
| 10 | `int main(void)` | **Función main()**: Punto de entrada del firmware |
| 12 | `initSystem();` | Inicialización del MCU (`_hard/System/src/system.c`) |
| 13-15 | `SystemConfig();` | **Evento**: Hook pre-inicialización (opcional) |
| 16 | `.{inits.*}.();` | **Macro EMIC**: Llama a todas las funciones de inicialización |
| 17-19 | `onReset();` | **Evento**: Hook post-inicialización (opcional) |
| 20-24 | `do { .{polls.*}.(); } while(1);` | **Loop infinito**: Ejecuta funciones de polling |

### 2.3 Macros EMIC-Codify en el main.c

El main.c usa **macros especiales** que se expanden durante el proceso **EMIC-Generate**:

| Macro | Descripción | Ejemplo de Expansión |
|-------|-------------|----------------------|
| `.{main_includes.*}.` | Incluye headers registrados | `led_Status.h`, `UART1.h`, `timer1.h` |
| `.{includes_head.*}.` | Headers del sistema | `system.h`, `gpio.h`, `streamOut.h` |
| `.{includes_src.*}.` | Archivos .c inline | `systemConfig.c` |
| `.{inits.*}.` | Funciones de inicialización | `LEDs_Status_init()`, `UART1_init()`, `Timer1_init()` |
| `.{polls.*}.` | Funciones de polling | `LEDs_Status_poll()`, `Timer1_poll()` |

---

## 3. Flujo de Ejecución del Firmware

El main.c sigue una **secuencia estricta** de ejecución:

### 3.1 Diagrama de Flujo

```
┌─────────────────────────────────────────────────┐
│   RESET del Microcontrolador                    │
│   (Power-On, MCLR, Watchdog, etc.)              │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│   Startup Code (C Runtime)                      │
│   - Inicialización de variables estáticas      │
│   - Configuración de stack                      │
│   - Inicialización de .bss (memoria a cero)     │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│   main()                                        │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│   1. initSystem()                               │
│   - Configurar clock del MCU                    │
│   - Configurar oscilador/PLL                    │
│   - Deshabilitar entradas analógicas            │
│   (Código en _hard/{MCU}/System/src/system.c)   │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│   2. SystemConfig() [OPCIONAL]                  │
│   - Hook para configuración pre-inicialización  │
│   - Inicialización de variables globales        │
│   - Configuración de estado inicial             │
│   (Definido por integrador en userFncFile.c)    │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│   3. Ejecutar todas las funciones .{inits.*}    │
│   - LEDs_Status_init()                          │
│   - LEDs_Led2_init()                            │
│   - Timer1_init()                               │
│   - UART2_init()                                │
│   - Digital_init()                              │
│   - ... (todas las APIs/Drivers usados)         │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│   4. onReset() [OPCIONAL]                       │
│   - Hook post-inicialización                    │
│   - Lógica inicial del integrador               │
│   - Ejemplo: LED de bienvenida, mensaje UART    │
│   (Definido por integrador en userFncFile.c)    │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│   5. Loop Principal Infinito: do {...} while(1) │
│                                                 │
│   Ejecutar todas las funciones .{polls.*}:     │
│   - LEDs_Status_poll()                          │
│   - LEDs_Led2_poll()                            │
│   - Timer1_poll()                               │
│   - Digital_poll()                              │
│   - Alarm_poll()                                │
│   - ... (todas las funciones de polling)        │
│                                                 │
│   Repetir infinitamente ↻                       │
└─────────────────────────────────────────────────┘
```

### 3.2 Tiempos de Ejecución Típicos

| Fase | Tiempo Aproximado | Descripción |
|------|-------------------|-------------|
| **Startup Code** | ~1-10 µs | C runtime initialization |
| **initSystem()** | ~100-500 µs | Configuración de clocks y PLL |
| **SystemConfig()** | Variable | Depende del integrador |
| **Todas las inits** | ~1-50 ms | Inicialización de periféricos |
| **onReset()** | Variable | Depende del integrador |
| **Loop (1 iteración)** | ~10-1000 µs | Depende de la complejidad |

> **Nota**: En un PIC24F @ 16 MHz, una iteración del loop puede tardar 10-100 µs si solo se ejecutan polls simples.

---

## 4. Sistema de Inicialización (inits)

El sistema `inits` es el mecanismo que EMIC usa para **registrar funciones de inicialización** que se ejecutan **una sola vez** al arrancar el firmware.

### 4.1 ¿Cómo se Registra un Init?

Cada API/Driver puede registrar una función de inicialización usando:

```emic
EMIC:define(inits.NOMBRE_UNICO, nombre_funcion_init)
```

**Ejemplos del SDK real:**

```c
// _api/Indicators/LEDs/inc/led.h
void LEDs_.{name}._init(void);
EMIC:define(inits.LEDs_.{name}., LEDs_.{name}._init)
```

Esto se expande a:
```c
void LEDs_Status_init(void);
EMIC:define(inits.LEDs_Status, LEDs_Status_init)
```

Durante **EMIC-Generate**, esto se traduce en:
```c
// En main.c
.{inits.*}.();

// Se expande a:
LEDs_Status_init();
LEDs_Led2_init();
Timer1_init();
UART2_init();
// ... (todas las funciones registradas)
```

### 4.2 Ejemplos Reales de Inits

#### Ejemplo 1: Inicialización de LED

**Archivo: `_api/Indicators/LEDs/src/led.c`**

```c
void LEDs_.{name}._init(void)
{
    HAL_GPIO_PinCfg(.{pin}., GPIO_OUTPUT);
}
```

**Expansión para LED llamado "Status" en pin "Led1":**
```c
void LEDs_Status_init(void)
{
    HAL_GPIO_PinCfg(Led1, GPIO_OUTPUT);
}
```

**Propósito:**
- Configura el pin como salida digital

---

#### Ejemplo 2: Inicialización de Relay

**Archivo: `_api/Actuators/Relay/inc/relay.h`**

```c
void initRelay_.{name}.(void);
EMIC:define(inits.initRelay_.{name}., initRelay_.{name}.)
```

**Expansión para Relay llamado "Pump":**
```c
void initRelay_Pump(void);
// Registrado como: inits.initRelay_Pump → initRelay_Pump
```

---

#### Ejemplo 3: Inicialización de ADC

**Archivo: `_api/ADC/inc/ADC.h`**

```c
void init_ADC(void);
EMIC:define(inits.init_ADC, init_ADC)
```

**Implementación:**
```c
void init_ADC(void)
{
    // Configurar ADC del MCU
    AD1CON1 = 0x00E0;  // Auto-convert
    AD1CON2 = 0x0000;
    AD1CON3 = 0x1F05;  // Sample time
    AD1CHS  = 0x0000;
    AD1CSSL = 0x0000;
    AD1CON1bits.ADON = 1;  // Encender ADC
}
```

---

#### Ejemplo 4: Inicialización de RadioFSK (Wireless)

**Archivo: `_api/Wireless/RadioFSK/inc/RadioFSK.h`**

```c
void FSK_Init(void);
EMIC:define(inits.FSK_Init, FSK_Init)
```

**Implementación:**
```c
void FSK_Init(void)
{
    // Inicializar módulo RFM69
    SPI_init();
    RFM69_reset();
    RFM69_setMode(RFM69_MODE_STANDBY);
    RFM69_setFrequency(915000000);  // 915 MHz
    RFM69_setPowerLevel(20);        // 20 dBm
}
```

---

### 4.3 Orden de Ejecución de Inits

El orden en que se ejecutan los inits depende del **orden en que se incluyen en `generate.emic`**:

```emic
// generate.emic (ejemplo)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=Status, pin=Led1)
EMIC:setInput(DEV:_api/Timers/timer_api.emic, name=1)
EMIC:setInput(DEV:_api/Inputs/Digital/Digital.emic)
```

**Resultado en main.c:**
```c
LEDs_Status_init();   // Primero
Timer1_init();        // Segundo
Digital_init();       // Tercero
```

> **Buena práctica**: Incluir primero los drivers de bajo nivel (SPI, I2C) y luego los de alto nivel (sensores, displays).

---

## 5. Sistema de Polling (polls)

El sistema `polls` es el mecanismo que EMIC usa para **registrar funciones que se ejecutan continuamente** en el loop principal.

### 5.1 ¿Cómo se Registra un Poll?

```emic
EMIC:define(polls.NOMBRE_UNICO, nombre_funcion_poll)
```

**Ejemplos del SDK real:**

```c
// _api/Indicators/LEDs/inc/led.h
EMIC:ifdef usedFunction.LEDs_.{name}._blink
void LEDs_.{name}._poll(void);
EMIC:define(polls.LEDs_.{name}., LEDs_.{name}._poll)
EMIC:endif
```

**Explicación:**
- Solo se registra el poll **si el integrador usa la función `blink()`**
- Si el integrador solo usa `state()`, no se registra el poll (optimización)

---

### 5.2 Ejemplos Reales de Polls

#### Ejemplo 1: Poll de LED (para blink)

**Archivo: `_api/Indicators/LEDs/src/led.c`**

```c
static uint16_t blkLed_timerOn = 0;
static uint16_t blkLed_period = 0;
static uint16_t blkLed_times = 0;
static uint32_t blkLed_tStamp;

void LEDs_.{name}._poll(void)
{
    if (blkLed_times > 0)
    {
        uint32_t currentTime = getSystemMilis();

        if ((currentTime - blkLed_tStamp) >= blkLed_period)
        {
            blkLed_tStamp = currentTime;
            blkLed_times--;
            HAL_GPIO_PinSet(.{pin}., GPIO_HIGH);
        }
        else if ((currentTime - blkLed_tStamp) >= blkLed_timerOn)
        {
            HAL_GPIO_PinSet(.{pin}., GPIO_LOW);
        }
    }
}
```

**Propósito:**
- Gestionar el parpadeo del LED sin bloquear el loop principal
- Usa `getSystemMilis()` del SystemTimer

---

#### Ejemplo 2: Poll de ADC

**Archivo: `_api/ADC/inc/ADC.h`**

```c
void poll_ADC(void);
EMIC:define(polls.poll_ADC, poll_ADC)
```

**Implementación:**
```c
void poll_ADC(void)
{
    // Verificar si conversión está completa
    if (AD1CON1bits.DONE)
    {
        // Leer buffer de ADC
        uint16_t value = ADC1BUF0;

        // Procesar valor
        processADCValue(value);

        // Reiniciar conversión
        AD1CON1bits.DONE = 0;
        AD1CON1bits.SAMP = 1;
    }
}
```

**Propósito:**
- Leer conversiones ADC sin bloquear
- Procesar datos en background

---

#### Ejemplo 3: Poll de Alarm

**Archivo: `_api/Alarm/inc/Alarm.h`**

```c
void pollAlarms(void);
EMIC:define(polls.pollAlarms, pollAlarms)
```

**Implementación:**
```c
void pollAlarms(void)
{
    uint32_t currentTime = getSystemMilis();

    for (int i = 0; i < MAX_ALARMS; i++)
    {
        if (alarms[i].active)
        {
            if (currentTime >= alarms[i].triggerTime)
            {
                alarms[i].callback();
                alarms[i].active = 0;
            }
        }
    }
}
```

**Propósito:**
- Gestionar alarmas basadas en tiempo
- Ejecutar callbacks cuando se cumple el tiempo

---

#### Ejemplo 4: Poll de RadioFSK

**Archivo: `_api/Wireless/RadioFSK/inc/RadioFSK.h`**

```c
void FSK_Poll(void);
EMIC:define(polls.FSK_Poll, FSK_Poll)
```

**Implementación:**
```c
void FSK_Poll(void)
{
    // Verificar si hay datos recibidos
    if (RFM69_dataAvailable())
    {
        uint8_t buffer[64];
        uint8_t len = RFM69_receive(buffer, 64);

        // Procesar paquete recibido
        processRFPacket(buffer, len);
    }

    // Verificar timeout de transmisión
    if (txTimeoutExpired())
    {
        handleTxTimeout();
    }
}
```

---

### 5.3 Loop Principal: Ejecución Continua

```c
do
{
    .{polls.*}.();
}
while(1);
```

**Se expande a:**
```c
do
{
    LEDs_Status_poll();
    LEDs_Led2_poll();
    Timer1_poll();
    ADC_poll();
    Alarm_poll();
    FSK_Poll();
}
while(1);
```

**Características:**
- **No bloqueante**: Cada poll debe ejecutarse rápidamente
- **Polling vs Interrupciones**: Los polls complementan las interrupciones (IRQs)
- **Frecuencia de ejecución**: Depende de cuántos polls hay (típicamente 1-10 kHz)

---

## 6. Eventos del Sistema

EMIC provee dos **eventos opcionales** que el integrador puede implementar:

### 6.1 Evento: SystemConfig()

```c
EMIC:ifdef usedEvent.SystemConfig
SystemConfig();
EMIC:endif
```

**¿Cuándo se ejecuta?**
- **Después de `initSystem()`**
- **Antes de los `inits.*`**

**¿Para qué sirve?**
- Inicializar variables globales del usuario
- Configurar estado inicial de la aplicación
- Preparar estructuras de datos

**Ejemplo de uso:**

```c
// userFncFile.c
void SystemConfig(void)
{
    // Inicializar máquina de estados
    currentState = STATE_IDLE;

    // Inicializar contadores
    packetCount = 0;
    errorCount = 0;

    // Configurar modo de operación
    operationMode = MODE_NORMAL;
}
```

---

### 6.2 Evento: onReset()

```c
EMIC:ifdef usedEvent.onReset
onReset();
EMIC:endif
```

**¿Cuándo se ejecuta?**
- **Después de todos los `inits.*`**
- **Antes del loop principal**

**¿Para qué sirve?**
- Lógica de bienvenida/startup
- Diagnóstico inicial
- Mostrar versión del firmware

**Ejemplo de uso:**

```c
// userFncFile.c
void onReset(void)
{
    // Parpadear LED 3 veces para indicar boot exitoso
    for (int i = 0; i < 3; i++)
    {
        Status.state(1);
        delay(200);
        Status.state(0);
        delay(200);
    }

    // Enviar mensaje de bienvenida por UART
    Send_EMIC("SYS", "Firmware v1.2.3 - Ready!");

    // Cargar configuración de EEPROM
    loadConfigFromEEPROM();
}
```

---

### 6.3 Publicación de Eventos en main.emic

**Archivo: `_main/baremetal/main.emic`**

```emic
EMIC:tag(driverName = SYSTEM)

/**
* @fn extern void onReset();
* @alias onReset
* @brief When the module and all its functions are ready.
* @return Nothing
*/

/**
* @fn extern void SystemConfig();
* @alias SystemConfig
* @brief before initializing the drivers, recommended for initializing system variables.
* @return Nothing
*/

EMIC:setInput(DEV:_hal/System/system.emic)
EMIC:copy(DEV:_main/baremetal/main.c > TARGET:main.c)

EMIC:define(c_modules.main, main)
```

**Explicación:**
- Los eventos se publican con **DOXYGEN tags** como `@fn` y `@alias`
- El integrador puede usarlos en EMIC-Editor:
  - Arrastrando `onReset` a su programa
  - Escribiendo lógica en el bloque generado

---

## 7. Integración con el SDK

El main.c integra **todos los componentes del SDK** en un único archivo compilable.

### 7.1 Diagrama de Integración

```
┌─────────────────────────────────────────────────────────┐
│                    generate.emic                        │
│   (Orquestador del proceso de compilación)              │
└──────────────────┬──────────────────────────────────────┘
                   ↓
       ┌───────────┴────────────┬────────────────┬────────────────┐
       ↓                        ↓                ↓                ↓
┌─────────────┐    ┌─────────────────┐   ┌──────────────┐   ┌──────────┐
│ _pcb/       │    │ _api/           │   │ _drivers/    │   │ _main/   │
│ pcb.emic    │    │ led.emic        │   │ I2C_driver   │   │ main.emic│
└──────┬──────┘    └────────┬────────┘   └──────┬───────┘   └────┬─────┘
       │                    │                   │                │
       │                    ↓                   ↓                │
       │          EMIC:define(inits.LED_init)  EMIC:define(...) │
       │          EMIC:define(polls.LED_poll)                    │
       │                    │                   │                │
       └────────────────────┴───────────────────┴────────────────┘
                             ↓
                ┌────────────────────────────────┐
                │     EMIC-Generate Process      │
                │   - Expande macros .{*}.       │
                │   - Fusiona código             │
                │   - Copia a TARGET:            │
                └────────────┬───────────────────┘
                             ↓
                ┌────────────────────────────────┐
                │       TARGET:main.c            │
                │  (Código C compilable final)   │
                └────────────┬───────────────────┘
                             ↓
                ┌────────────────────────────────┐
                │   Compilador XC8/XC16/XC32     │
                │   (Microchip MPLAB XC)         │
                └────────────┬───────────────────┘
                             ↓
                ┌────────────────────────────────┐
                │      Firmware.hex              │
                │   (Listo para grabar en MCU)   │
                └────────────────────────────────┘
```

### 7.2 Secuencia de Archivos Incluidos

**Orden de includes en main.c generado:**

```c
// 1. Headers del compilador
#include <xc.h>

// 2. Configuración del sistema (fuses)
#include "inc/systemConfig.h"

// 3. Headers de APIs/Drivers (registrados con main_includes)
#include "inc/led_Status.h"
#include "inc/led_Led2.h"
#include "inc/UART2.h"
#include "inc/timer1.h"

// 4. Headers del sistema (registrados con includes_head)
#include "inc/system.h"
#include "inc/gpio.h"
#include "inc/systemTimer.h"

// 5. Headers del usuario
#include "inc/userFncFile.h"

// 6. Archivos .c inline (para optimización)
#include "systemConfig.c"
```

---

## 8. Ejemplo Completo de Generación

Veamos un ejemplo real de cómo se genera el main.c para un módulo con LEDs, UART y Timer.

### 8.1 Archivo generate.emic del Módulo

```emic
EMIC:setOutput(TARGET:generate.txt)

    //-------------- Hardware Config ---------------------
    EMIC:setInput(DEV:_pcb/pcb.emic, pcb=HRD_D-I4-I_V1.0)

    //------------------- Process EMIC-Generate files result ----------------
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    //------------------- APIs -----------------------
    // LEDs
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=Status, pin=Led1)
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=Led2, pin=Led2)
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=Led3, pin=Led3)

    // Timer
    EMIC:setInput(DEV:_api/Timers/timer_api.emic, name=1)

    // Digital Inputs
    EMIC:setInput(DEV:_api/Inputs/Digital/Digital.emic)

    // Communication
    EMIC:setInput(DEV:_api/Wired_Communication/EMICBus/EMICBus.emic, port=2, frameID=0)

    //-------------------- main  -----------------------
    EMIC:setInput(DEV:_main/baremetal/main.emic)

    //------------------- Copy EMIC-Generate files result ----------------
    EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
    EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)

    //------------------- Set userFncFile.c as compiler module ----------------
    EMIC:define(c_modules.userFncFile, userFncFile)

    //------------------- Add all compiler modules to the project ----------------
    EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

### 8.2 main.c Generado (TARGET:main.c)

**Expansión de macros:**

```c
#include <xc.h>
#include "inc/systemConfig.h"

// Expansión de .{main_includes.*}.
#include "inc/led_Status.h"
#include "inc/led_Led2.h"
#include "inc/led_Led3.h"
#include "inc/timer1.h"
#include "inc/Digital.h"
#include "inc/EMICBus2.h"

// Expansión de .{includes_head.*}.
#include "inc/system.h"
#include "inc/gpio.h"
#include "inc/systemTimer.h"
#include "inc/streamOut.h"

#include "inc/userFncFile.h"

// Expansión de .{includes_src.*}.
#include "systemConfig.c"

int main(void)
{
    // Inicialización del sistema (PIC24FJ64GA002)
    initSystem();

    // Evento SystemConfig (si el usuario lo implementó)
    #ifdef usedEvent_SystemConfig
    SystemConfig();
    #endif

    // Expansión de .{inits.*}.
    LEDs_Status_init();
    LEDs_Led2_init();
    LEDs_Led3_init();
    Timer1_init();
    Digital_init();
    EMICBus2_init();

    // Evento onReset (si el usuario lo implementó)
    #ifdef usedEvent_onReset
    onReset();
    #endif

    // Loop principal
    do
    {
        // Expansión de .{polls.*}.
        LEDs_Status_poll();
        LEDs_Led2_poll();
        LEDs_Led3_poll();
        Timer1_poll();
        Digital_poll();
        EMICBus2_poll();
    }
    while(1);
}
```

### 8.3 Ejecución en el Microcontrolador

**Secuencia temporal:**

```
Tiempo    Evento
─────────────────────────────────────────────────────────
t=0 ms    RESET del microcontrolador (Power-On)
t=0.001   C Runtime Initialization
t=0.002   main() comienza
t=0.100   initSystem() → Configurar PLL a 32 MHz
t=0.110   SystemConfig() → Inicializar variables del usuario
t=0.120   LEDs_Status_init() → Configurar RB5 como salida
t=0.121   LEDs_Led2_init() → Configurar RB6 como salida
t=0.122   LEDs_Led3_init() → Configurar RB7 como salida
t=0.125   Timer1_init() → Configurar Timer1 a 1ms
t=0.130   Digital_init() → Configurar entradas digitales
t=0.135   EMICBus2_init() → Configurar UART2 a 115200 baud
t=0.140   onReset() → Parpadear LED Status 3 veces
t=0.800   Inicio del loop principal
─────────────────────────────────────────────────────────
          LOOP INFINITO (frecuencia ~10 kHz)
t=0.800   LEDs_Status_poll() → Procesar blink
t=0.805   LEDs_Led2_poll() → Procesar blink
t=0.810   LEDs_Led3_poll() → Procesar blink
t=0.815   Timer1_poll() → Procesar eventos de timer
t=0.820   Digital_poll() → Leer entradas digitales
t=0.825   EMICBus2_poll() → Procesar mensajes UART
t=0.830   ← Volver al inicio del loop
t=0.830   LEDs_Status_poll() → ...
          ... (repetir infinitamente)
```

---

## 9. Personalización del Main

En la mayoría de los casos, **no necesitas modificar el main.c** directamente. EMIC provee hooks para personalizarlo.

### 9.1 Agregar Código de Inicialización

**Opción 1: Usar SystemConfig()**

```c
// userFncFile.c
void SystemConfig(void)
{
    // Tu código de inicialización aquí
    globalVariable = 100;
    configMode = CONFIG_MODE_ADVANCED;
}
```

**Opción 2: Usar onReset()**

```c
// userFncFile.c
void onReset(void)
{
    // Tu código post-inicialización aquí
    Status.blink(500, 1000, 3);  // Parpadear 3 veces
    Send_EMIC("SYS", "Boot OK");
}
```

### 9.2 Agregar Código en el Loop

**Opción 1: Crear tu propio poll en un API personalizado**

```c
// _api/Custom/MyAPI/inc/myapi.h
void MyAPI_poll(void);
EMIC:define(polls.MyAPI_poll, MyAPI_poll)
```

```c
// _api/Custom/MyAPI/src/myapi.c
void MyAPI_poll(void)
{
    // Tu lógica aquí
    if (buttonPressed())
    {
        handleButtonPress();
    }
}
```

**Opción 2: Usar eventos de Timer**

```c
// userFncFile.c
void every_100ms(void)
{
    // Tu código cada 100 ms
    updateDisplay();
}
```

Luego en EMIC-Editor:
```
Timer1.every(100) -> every_100ms
```

---

## 10. Buenas Prácticas

### 10.1 Inicialización

✅ **HACER:**
- Inicializar periféricos de bajo nivel primero (SPI, I2C)
- Luego inicializar sensores/displays que dependen de ellos
- Usar `SystemConfig()` para variables globales
- Usar `onReset()` para lógica de startup

❌ **EVITAR:**
- Modificar directamente `_main/baremetal/main.c` (se sobrescribe)
- Poner código bloqueante en `SystemConfig()` o `onReset()`
- Inicializar variables globales fuera de `SystemConfig()`

### 10.2 Polling

✅ **HACER:**
- Mantener los polls **rápidos** (< 100 µs idealmente)
- Usar máquinas de estado si la lógica es compleja
- Aprovechar interrupciones para eventos críticos

❌ **EVITAR:**
- Usar `delay()` o `__delay_ms()` en polls (bloquean el loop)
- Hacer operaciones pesadas (ej: cálculos complejos) en polls
- Ignorar el watchdog timer si está habilitado

### 10.3 Eventos del Sistema

✅ **HACER:**
```c
// SystemConfig: Inicialización ligera
void SystemConfig(void)
{
    machineState = IDLE;
    counter = 0;
}

// onReset: Lógica de startup (puede tardar más)
void onReset(void)
{
    for (int i = 0; i < 3; i++)
    {
        Status.state(1);
        delay(200);
        Status.state(0);
        delay(200);
    }
}
```

❌ **EVITAR:**
```c
// NO hacer esto en SystemConfig (demasiado pesado)
void SystemConfig(void)
{
    loadConfigFromEEPROM();      // Bloqueante
    calibrateSensors();          // Bloqueante
    sendWelcomeMessage();        // Bloqueante
}
```

### 10.4 Optimización del Loop

**Medir frecuencia del loop:**

```c
// userFncFile.c
static uint32_t loopCounter = 0;
static uint32_t lastPrintTime = 0;

void debugLoopFrequency(void)
{
    loopCounter++;

    uint32_t now = getSystemMilis();
    if (now - lastPrintTime >= 1000)  // Cada 1 segundo
    {
        // loopCounter = número de iteraciones en 1 segundo
        Send_EMIC("DEBUG", "Loop freq: %lu Hz", loopCounter);
        loopCounter = 0;
        lastPrintTime = now;
    }
}
EMIC:define(polls.debugLoopFrequency, debugLoopFrequency)
```

**Resultado típico:**
```
Loop freq: 8500 Hz  → Muy bueno (117 µs por iteración)
Loop freq: 500 Hz   → Revisar (2 ms por iteración, algo está bloqueando)
```

---

## Resumen

| Concepto | Descripción |
|----------|-------------|
| **_main/** | Carpeta con el punto de entrada del firmware |
| **main.c** | Template baremetal con macros EMIC-Codify |
| **initSystem()** | Primera función, inicializa el MCU (_hard/System) |
| **SystemConfig()** | Evento pre-inicialización (opcional) |
| **inits.\*** | Funciones de inicialización registradas por APIs/Drivers |
| **onReset()** | Evento post-inicialización (opcional) |
| **polls.\*** | Funciones de polling ejecutadas en loop infinito |
| **while(1)** | Loop principal que ejecuta todos los polls continuamente |

---

## Próximos Pasos

En el **Capítulo 12** exploraremos la carpeta **`_pcb/`**, donde se define la **configuración de hardware** (PCBs y pines) para los módulos EMIC.

---

**¿Preguntas?**
El main.c es el **corazón del firmware**, donde todo se une: System, HAL, Drivers, APIs y el código del integrador. Gracias al sistema de `inits` y `polls`, el proceso es **completamente automático** y **extensible**.
