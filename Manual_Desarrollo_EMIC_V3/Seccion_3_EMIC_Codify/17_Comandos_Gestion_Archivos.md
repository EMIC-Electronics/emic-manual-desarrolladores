# Capítulo 17: Comandos de Gestión de Archivos y Recursos

## Tabla de Contenidos

1. [Introducción](#1-introducción)
2. [Comando setInput](#2-comando-setinput)
3. [Comando setOutput](#3-comando-setoutput)
4. [Comando copy](#4-comando-copy)
5. [Comando restoreOutput](#5-comando-restoreoutput)
6. [Patrones de Uso Comunes](#6-patrones-de-uso-comunes)
7. [Caso Práctico: Crear un .emic Completo](#7-caso-práctico-crear-un-emic-completo)
8. [Errores Comunes y Soluciones](#8-errores-comunes-y-soluciones)

---

## 1. Introducción

Los comandos de gestión de archivos son fundamentales para el desarrollo en EMIC-Codify. Permiten:

- **Procesar archivos** del SDK (setInput)
- **Dirigir la salida** a archivos específicos (setOutput)
- **Copiar y transformar** archivos con parámetros (copy)
- **Gestionar el stack** de archivos de salida (restoreOutput)

### 1.1 Flujo General de Archivos

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLUJO DE ARCHIVOS EMIC                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   DEV: (SDK)              →→→        TARGET: (Proyecto)          │
│   ───────────                        ──────────────────          │
│                                                                  │
│   _api/LEDs/                         inc/                        │
│   ├── led.emic   ─── setInput ───→   ├── led_Status.h            │
│   ├── inc/led.h  ─── copy ───────→   └── led_Error.h             │
│   └── src/led.c  ─── copy ───────→   led_Status.c                │
│                                      led_Error.c                 │
│                                                                  │
│   _hal/GPIO/                                                     │
│   └── gpio.emic  ─── setInput ───→   (procesado internamente)    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Comando setInput

El comando `setInput` procesa un archivo y ejecuta los comandos EMIC contenidos en él. Es el mecanismo principal para **cargar dependencias** y **ejecutar scripts**.

### 2.1 Sintaxis

```
EMIC:setInput([volumen:][ruta/]archivo[, param1=valor1, param2=valor2, ...])
```

### 2.2 Parámetros

| Parámetro | Opcional | Descripción |
|-----------|:--------:|-------------|
| `volumen` | Sí | Volumen lógico (DEV:, SYS:, USER:). Si se omite, usa la ruta del archivo actual |
| `ruta` | Sí | Ruta relativa al archivo |
| `archivo` | No | Nombre del archivo a procesar |
| `param=valor` | Sí | Macros locales disponibles durante el procesamiento |

### 2.3 Ejemplos del SDK Real

**Cargar una API con parámetros:**
```c
// Cargar API de LEDs con nombre y pin específicos
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=Status, pin=Led1)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=Error, pin=Led2)
```

**Cargar API de Timer:**
```c
// El Timer requiere un nombre para identificarlo
EMIC:setInput(DEV:_api/Timers/timer_api.emic, name=1)
EMIC:setInput(DEV:_api/Timers/timer_api.emic, name=Heartbeat)
```

**Cargar API de comunicación USB con múltiples parámetros:**
```c
EMIC:setInput(DEV:_api/Wired_Communication/USB/USB_API.emic,
              driver=MCP2200,
              port=1,
              BufferSize=512,
              baud=9600,
              frameLf=\n,
              name=MCP2200)
```

**Cargar dependencias del HAL:**
```c
// Dentro de una API, cargar el HAL necesario
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)
```

**Cargar configuración de pines:**
```c
// Configurar pines específicos del hardware
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B1, name=IN1)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B2, name=IN2)
EMIC:setInput(DEV:_hal/pins/setPin.emic, pin=B11, name=Led1)
```

**Cargar archivos del sistema:**
```c
// Cargar funciones y eventos usados (generados por EMIC-Editor)
EMIC:setInput(SYS:usedFunction.emic)
EMIC:setInput(SYS:usedEvent.emic)
```

### 2.4 Rutas Relativas vs Absolutas

```c
// Ruta absoluta (con volumen)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic)

// Ruta relativa (desde el archivo actual)
// Si estamos en _api/MiAPI/miapi.emic:
EMIC:setInput(inc/header.h)        // → _api/MiAPI/inc/header.h
EMIC:setInput(../Utils/util.emic)  // → _api/Utils/util.emic
```

### 2.5 Uso en APIs Reales

**Ejemplo: led.emic del SDK**
```c
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
* @brief blink the .{name}.
* @param timeOn time that the LED lasts on in each cycle.
* @param period length of time each cycle lasts.
* @param times number of cycles.
* @return Nothing
*/

// Cargar dependencias usando setInput
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

// ... resto del archivo
```

---

## 3. Comando setOutput

El comando `setOutput` establece el archivo de destino para todo el texto generado a partir de ese punto. Se usa para **crear archivos de salida** en el proyecto.

### 3.1 Sintaxis

```
EMIC:setOutput([volumen:][ruta/]archivo)
```

### 3.2 Parámetros

| Parámetro | Opcional | Descripción |
|-----------|:--------:|-------------|
| `volumen` | No* | Volumen de destino (generalmente TARGET:) |
| `ruta` | Sí | Ruta dentro del volumen |
| `archivo` | No | Nombre del archivo de salida |

> **⚠️ Importante:** Siempre incluir el volumen `TARGET:` para evitar errores.

### 3.3 Ejemplos Prácticos

**Crear archivo de log de generación:**
```c
// Primera línea típica de generate.emic
EMIC:setOutput(TARGET:generate.txt)
```

**Crear archivos header en la carpeta inc/:**
```c
EMIC:setOutput(TARGET:inc/systemConfig.h)
// ... contenido del header ...
EMIC:restoreOutput

EMIC:setOutput(TARGET:inc/system.h)
// ... contenido del header ...
EMIC:restoreOutput

EMIC:setOutput(TARGET:inc/pins.h)
// ... contenido del header ...
EMIC:restoreOutput
```

**Crear archivos de código fuente:**
```c
EMIC:setOutput(TARGET:ADC.c)
// ... contenido del .c ...
EMIC:restoreOutput
```

### 3.4 Stack de Salidas

Cada `setOutput` **apila** la salida actual. Esto permite anidar salidas:

```c
EMIC:setOutput(TARGET:archivo1.c)
    // Escribiendo en archivo1.c

    EMIC:setOutput(TARGET:archivo2.h)
        // Escribiendo en archivo2.h
    EMIC:restoreOutput  // Vuelve a archivo1.c

    // Continuamos en archivo1.c
EMIC:restoreOutput  // Vuelve a la salida anterior
```

### 3.5 Ejemplo Real: ADC.emic

```c
EMIC:tag(driverName = ADC)
EMIC:ifndef ADC_EMIC_
EMIC:define(ADC_EMIC_,true)

// ... publicación de funciones ...

// Cargar dependencias
EMIC:setInput(DEV:_drivers/ADC/LTC2500/LTC2500.emic)
EMIC:setInput(DEV:_drivers/Amp/PGA280/PGA280.emic, configuracion=.{configuracion}., port=.{port}., pin=.{pin}.)
EMIC:setInput(DEV:_hal/RefCLK/RefCLK.emic, PinName=.{PinName}.)

// Crear header usando setOutput + setInput
EMIC:setOutput(TARGET:inc/ADC.h)
    EMIC:setInput(inc/ADC.h)
EMIC:restoreOutput

// Crear source usando setOutput + setInput
EMIC:setOutput(TARGET:ADC.c)
    EMIC:setInput(src/ADC.c)
EMIC:restoreOutput

// Registrar en diccionarios
EMIC:define(main_includes.ADC, ADC)
EMIC:define(c_modules.ADC, ADC)

EMIC:endif
```

### 3.6 Errores Comunes con setOutput

```c
// ❌ INCORRECTO: Falta volumen
EMIC:setOutput(systemConfig.h)

// ✅ CORRECTO: Con volumen TARGET:
EMIC:setOutput(TARGET:inc/systemConfig.h)

// ❌ INCORRECTO: Volumen incorrecto para código generado
EMIC:setOutput(SYS:deploy.txt)

// ✅ CORRECTO: Usar TARGET: para archivos generados
EMIC:setOutput(TARGET:deploy.txt)
```

---

## 4. Comando copy

El comando `copy` es el más versátil: **procesa un archivo de origen** y **escribe el resultado en un archivo de destino**, todo en un solo comando. Permite pasar parámetros que estarán disponibles durante el procesamiento.

### 4.1 Sintaxis

```
EMIC:copy([volumen1:][ruta1/]origen > [volumen2:][ruta2/]destino[, param1=valor1, ...])
```

> **📝 Nota:** El separador entre origen y destino es el carácter `>`.

### 4.2 Parámetros

| Parámetro | Opcional | Descripción |
|-----------|:--------:|-------------|
| `volumen1` | Sí | Volumen del archivo origen (default: ruta actual) |
| `origen` | No | Archivo a procesar |
| `volumen2` | Sí | Volumen destino (default: TARGET:) |
| `destino` | No | Archivo de salida |
| `param=valor` | Sí | Macros locales para el procesamiento |

### 4.3 Ejemplos del SDK Real

**Copiar archivos de una API con parámetros:**
```c
// Del led.emic real del SDK
EMIC:copy(inc/led.h > TARGET:inc/led_.{name}..h, name=.{name}., pin=.{pin}.)
EMIC:copy(src/led.c > TARGET:led_.{name}..c, name=.{name}., pin=.{pin}.)
```

**Copiar archivos del Timer:**
```c
// Del timer_api.emic real del SDK
EMIC:copy(inc/timer_api.h > TARGET:inc/timer_api.{name}..h, name=.{name}.)
EMIC:copy(src/timer_api.c > TARGET:timer_api.{name}..c, name=.{name}.)
```

**Copiar archivos de entrada/salida digital:**
```c
EMIC:copy(inc/input.h > TARGET:inc/input_.{name}..h, name=.{name}., pin=.{pin}.)
EMIC:copy(src/input.c > TARGET:input_.{name}..c, name=.{name}., pin=.{pin}.)

EMIC:copy(inc/output.h > TARGET:inc/output_.{name}..h, name=.{name}., pin=.{pin}.)
EMIC:copy(src/output.c > TARGET:output_.{name}..c, name=.{name}., pin=.{pin}.)
```

**Copiar archivos del sistema (sin parámetros):**
```c
// Copiar archivos generados por el usuario
EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
```

**Copiar templates de proyecto MPLAB:**
```c
// Copia todo el directorio de templates
EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)
```

**Copiar archivos PCB:**
```c
EMIC:copy(inc/.{pcb}..h > TARGET:inc/.{pcb}..h)
```

### 4.4 Equivalencia entre copy y setOutput+setInput

`EMIC:copy` es **azucar sintactica** para la combinacion `setOutput` / `setInput` / `restoreOutput`. Las siguientes dos formas son **exactamente equivalentes**:

**Forma compacta — `copy`:**
```c
EMIC:copy(inc/led.h > TARGET:inc/led_.{name}..h, name=.{name}., pin=.{pin}.)
```

**Forma expandida — `setOutput` + `setInput` + `restoreOutput`:**
```c
EMIC:setOutput(TARGET:inc/led_.{name}..h)
    EMIC:setInput(inc/led.h, name=.{name}., pin=.{pin}.)
EMIC:restoreOutput
```

### 4.5 Cuando usar cada forma

**Usar `copy`** cuando el destino se compone de **un solo archivo de entrada** sin texto adicional. Es mas conciso y legible:

```c
// Un archivo de entrada, sin texto extra → usar copy
EMIC:copy(inc/UART.h > TARGET:inc/UART1.h, port=1, baud=9600)
EMIC:copy(src/UART.c > TARGET:UART1.c, port=1, baud=9600)
```

**Usar `setOutput` / `restoreOutput`** cuando se necesita:
- **Multiples archivos de entrada** al mismo destino
- **Texto literal** intercalado entre los archivos

```c
// Multiples archivos de entrada + texto literal → usar setOutput/restoreOutput
EMIC:setOutput(TARGET:inc/system_config.h)
    #ifndef SYSTEM_CONFIG_H
    #define SYSTEM_CONFIG_H

    // Archivo 1: configuracion del clock
    EMIC:setInput(inc/clock_config.h, freq=.{freq}.)

    // Archivo 2: configuracion de pines
    EMIC:setInput(inc/pin_config.h, pcb=.{pcb}.)

    // Texto literal que no viene de ningun archivo
    #define BOARD_NAME ".{pcb}."
    #define FIRMWARE_VERSION ".{version}."

    #endif
EMIC:restoreOutput
```

> **Regla simple:** Si hay un solo `setInput` entre `setOutput` y `restoreOutput`, y no hay texto literal alrededor, reemplazar por `EMIC:copy`.

### 4.6 Convenciones de Rutas de Destino

```c
// ✅ CORRECTO: Headers van a inc/
EMIC:copy(inc/Digital.h > TARGET:inc/Digital.h)

// ✅ CORRECTO: Sources van a la raíz de TARGET
EMIC:copy(src/Digital.c > TARGET:Digital.c)

// ❌ INCORRECTO: No duplicar src/ en destino
EMIC:copy(src/Digital.c > TARGET:src/Digital.c)
```

### 4.7 Propagación de Parámetros

Los parámetros pasados en `copy` están disponibles en el archivo procesado:

**En el comando:**
```c
EMIC:copy(src/sensor.c > TARGET:sensor_.{id}..c, id=Temp, pin=AN0, gain=2)
```

**En el archivo sensor.c:**
```c
// Los parámetros .{id}., .{pin}., .{gain}. están disponibles
void Sensor_.{id}._init(void) {
    ADC_SetPin(.{pin}.);
    ADC_SetGain(.{gain}.);
}
```

**Resultado en sensor_Temp.c:**
```c
void Sensor_Temp_init(void) {
    ADC_SetPin(AN0);
    ADC_SetGain(2);
}
```

---

## 5. Comando restoreOutput

El comando `restoreOutput` restaura el archivo de salida anterior del stack. Se usa siempre después de `setOutput` para volver al contexto anterior.

### 5.1 Sintaxis

```
EMIC:restoreOutput
```

### 5.2 Funcionamiento del Stack

```
┌───────────────────────────────────────────────────────────────┐
│                    STACK DE SALIDAS                            │
├───────────────────────────────────────────────────────────────┤
│                                                                │
│  1. Estado inicial                                             │
│     Stack: [ ]                                                 │
│     Salida actual: (ninguna)                                   │
│                                                                │
│  2. EMIC:setOutput(TARGET:main.c)                              │
│     Stack: [ ]                                                 │
│     Salida actual: TARGET:main.c                               │
│                                                                │
│  3. EMIC:setOutput(TARGET:inc/header.h)                        │
│     Stack: [ TARGET:main.c ]                                   │
│     Salida actual: TARGET:inc/header.h                         │
│                                                                │
│  4. EMIC:restoreOutput                                         │
│     Stack: [ ]                                                 │
│     Salida actual: TARGET:main.c                               │
│                                                                │
│  5. EMIC:restoreOutput                                         │
│     Stack: [ ]                                                 │
│     Salida actual: (ninguna)                                   │
│                                                                │
└───────────────────────────────────────────────────────────────┘
```

### 5.3 Ejemplo Práctico

```c
// generate.emic típico
EMIC:setOutput(TARGET:generate.txt)

// Configurar PCB - esto internamente usa setOutput/restoreOutput
EMIC:setInput(DEV:_pcb/pcb.emic, pcb=MiPlaca)

// Cargar APIs
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=Status, pin=Led1)

// Cargar main
EMIC:setInput(DEV:_main/baremetal/main.emic)

// Copiar archivos del usuario
EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)

// Copiar templates
EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

---

## 6. Patrones de Uso Comunes

### 6.1 Patrón: API Completa

Estructura típica de un archivo .emic de API:

```c
// 1. Tag de agrupación
EMIC:tag(driverName = MiAPI)

// 2. Guard de inclusión única
EMIC:ifndef MiAPI_EMIC_
EMIC:define(MiAPI_EMIC_, true)

// 3. Publicación de recursos
/**
* @fn void MiAPI_.{name}._init(void);
* @alias .{name}..init
* @brief Inicializa la API
* @return Nothing
*/

// 4. Dependencias
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

// 5. Copiar archivos
EMIC:copy(inc/miapi.h > TARGET:inc/miapi_.{name}..h, name=.{name}., param=.{param}.)
EMIC:copy(src/miapi.c > TARGET:miapi_.{name}..c, name=.{name}., param=.{param}.)

// 6. Registrar en diccionarios
EMIC:define(main_includes.miapi_.{name}., miapi_.{name}.)
EMIC:define(c_modules.miapi_.{name}., miapi_.{name}.)

EMIC:endif
```

### 6.2 Patrón: Generate.emic de Módulo

```c
// 1. Archivo de log
EMIC:setOutput(TARGET:generate.txt)

// 2. Configuración de hardware
EMIC:setInput(DEV:_pcb/pcb.emic, pcb=NombrePCB)

// 3. Procesar funciones y eventos del usuario
EMIC:setInput(SYS:usedFunction.emic)
EMIC:setInput(SYS:usedEvent.emic)

// 4. Cargar APIs necesarias
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=Status, pin=Led1)
EMIC:setInput(DEV:_api/Timers/timer_api.emic, name=1)
EMIC:setInput(DEV:_api/Actuators/Relay/relay.emic, name=Power, pin=RelayPwr)

// 5. Cargar main
EMIC:setInput(DEV:_main/baremetal/main.emic)

// 6. Copiar archivos del usuario
EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
EMIC:define(c_modules.userFncFile, userFncFile)

// 7. Copiar templates del proyecto
EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

### 6.3 Patrón: Generación Condicional

```c
// Copiar archivos solo si se usa cierta funcionalidad
EMIC:ifdef USE_BLUETOOTH
    EMIC:setInput(DEV:_api/Wireless/Bluetooth_BLE/BluetoothBLE.emic, name=BT1)
EMIC:endif

EMIC:ifdef USE_MODBUS
    EMIC:setInput(DEV:_api/Protocols/Modbus/Modbus.emic, port=1)
EMIC:endif
```

### 6.4 Patrón: Múltiples Instancias

```c
// Crear múltiples LEDs
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=Led1, pin=Led1)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=Led2, pin=Led2)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=Led3, pin=Led3)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=Led4, pin=Led4)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=Led5, pin=Led5)
```

---

## 7. Caso Práctico: Crear un .emic Completo

Vamos a crear una API de **Sensor de Temperatura** paso a paso.

### 7.1 Estructura de Carpetas

```
_api/Sensors/Temperature/
├── temperature.emic      ← Archivo principal
├── inc/
│   └── temperature.h     ← Header template
└── src/
    └── temperature.c     ← Source template
```

### 7.2 Archivo temperature.emic

```c
// ============================================================
// API: Temperature Sensor
// Descripción: Lee temperatura de sensores analógicos
// Parámetros requeridos: name, pin, driver
// ============================================================

EMIC:tag(driverName = TEMPERATURE)

// Guard de inclusión única
EMIC:ifndef Temperature_.{name}._EMIC_
EMIC:define(Temperature_.{name}._EMIC_, true)

// ==================== FUNCIONES ====================

/**
* @fn float Temperature_.{name}._getValue(void);
* @alias getTemperature.{name}.
* @brief Get the current temperature value from sensor
* @return Temperature in Celsius degrees
*/

/**
* @fn void Temperature_.{name}._setUnit(uint8_t unit);
* @alias setUnit.{name}.
* @brief Set temperature display unit
* @param unit 0=Celsius, 1=Fahrenheit, 2=Kelvin
* @return Nothing
*/

/**
* @fn void Temperature_.{name}._setThresholds(float min, float max);
* @alias setThreshold.{name}.
* @brief Set temperature alert thresholds
* @param min Minimum temperature threshold in Celsius
* @param max Maximum temperature threshold in Celsius
* @return Nothing
*/

// ==================== EVENTOS ====================

/**
* @fn extern void Temperature_.{name}._onLowTemp(void);
* @alias tempLow.{name}.
* @brief Event triggered when temperature falls below minimum threshold
* @return Nothing
*/

/**
* @fn extern void Temperature_.{name}._onHighTemp(void);
* @alias tempHigh.{name}.
* @brief Event triggered when temperature exceeds maximum threshold
* @return Nothing
*/

// ==================== VARIABLES ====================

/**
* @var float Temperature_.{name}._currentValue = 25.0;
* @alias .{name}..value
* @brief Current temperature reading in Celsius
*/

// ==================== DEPENDENCIAS ====================

// Cargar HAL del ADC
EMIC:setInput(DEV:_hal/ADC/adc.emic)

// Cargar driver del sensor específico
EMIC:setInput(DEV:_drivers/Temperature/.{driver}./driver.emic, pin=.{pin}.)

// Cargar timer para polling
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

// ==================== COPIAR ARCHIVOS ====================

// Header: pasar todos los parámetros necesarios
EMIC:copy(inc/temperature.h > TARGET:inc/temperature_.{name}..h,
          name=.{name}.,
          pin=.{pin}.,
          driver=.{driver}.)

// Source: pasar todos los parámetros necesarios
EMIC:copy(src/temperature.c > TARGET:temperature_.{name}..c,
          name=.{name}.,
          pin=.{pin}.,
          driver=.{driver}.)

// ==================== REGISTRAR EN SISTEMA ====================

// Para que main.c incluya el header
EMIC:define(main_includes.temperature_.{name}., temperature_.{name}.)

// Para que MPLAB compile el .c
EMIC:define(c_modules.temperature_.{name}., temperature_.{name}.)

// Registrar función init
EMIC:define(inits.Temperature_.{name}., Temperature_.{name}._init)

// Registrar función poll (para verificar thresholds)
EMIC:define(polls.Temperature_.{name}., Temperature_.{name}._poll)

EMIC:endif
```

### 7.3 Archivo inc/temperature.h

```c
// ============================================================
// Temperature API - Header
// Instancia: .{name}.
// Driver: .{driver}.
// Pin: .{pin}.
// ============================================================

#ifndef TEMPERATURE_.{name}._H
#define TEMPERATURE_.{name}._H

#include <stdint.h>

// ==================== CONSTANTES ====================

#define TEMP_UNIT_CELSIUS    0
#define TEMP_UNIT_FAHRENHEIT 1
#define TEMP_UNIT_KELVIN     2

// ==================== VARIABLES PÚBLICAS ====================

extern float Temperature_.{name}._currentValue;
extern uint8_t Temperature_.{name}._unit;

// ==================== FUNCIONES PÚBLICAS ====================

void Temperature_.{name}._init(void);
void Temperature_.{name}._poll(void);
float Temperature_.{name}._getValue(void);
void Temperature_.{name}._setUnit(uint8_t unit);
void Temperature_.{name}._setThresholds(float min, float max);

// ==================== EVENTOS ====================

extern void Temperature_.{name}._onLowTemp(void);
extern void Temperature_.{name}._onHighTemp(void);

#endif // TEMPERATURE_.{name}._H
```

### 7.4 Archivo src/temperature.c

```c
// ============================================================
// Temperature API - Implementation
// Instancia: .{name}.
// Driver: .{driver}.
// Pin: .{pin}.
// ============================================================

#include "temperature_.{name}..h"
#include "adc.h"
#include "systemTimer.h"

// ==================== VARIABLES ====================

float Temperature_.{name}._currentValue = 25.0f;
uint8_t Temperature_.{name}._unit = TEMP_UNIT_CELSIUS;

static float _minThreshold = -40.0f;
static float _maxThreshold = 85.0f;
static uint8_t _lastAlarmState = 0;

// ==================== IMPLEMENTACIÓN ====================

void Temperature_.{name}._init(void) {
    ADC_Init(.{pin}.);
    Temperature_.{name}._currentValue = 25.0f;
    _lastAlarmState = 0;
}

void Temperature_.{name}._poll(void) {
    // Leer valor del ADC
    uint16_t rawValue = ADC_Read(.{pin}.);

    // Convertir a temperatura (depende del sensor)
    Temperature_.{name}._currentValue = (float)rawValue * 0.1f - 40.0f;

    // Verificar thresholds
    uint8_t currentAlarm = 0;
    if (Temperature_.{name}._currentValue < _minThreshold) {
        currentAlarm = 1;
        if (_lastAlarmState != 1) {
            Temperature_.{name}._onLowTemp();
        }
    } else if (Temperature_.{name}._currentValue > _maxThreshold) {
        currentAlarm = 2;
        if (_lastAlarmState != 2) {
            Temperature_.{name}._onHighTemp();
        }
    }
    _lastAlarmState = currentAlarm;
}

float Temperature_.{name}._getValue(void) {
    float temp = Temperature_.{name}._currentValue;

    switch (Temperature_.{name}._unit) {
        case TEMP_UNIT_FAHRENHEIT:
            return temp * 9.0f / 5.0f + 32.0f;
        case TEMP_UNIT_KELVIN:
            return temp + 273.15f;
        default:
            return temp;
    }
}

void Temperature_.{name}._setUnit(uint8_t unit) {
    if (unit <= TEMP_UNIT_KELVIN) {
        Temperature_.{name}._unit = unit;
    }
}

void Temperature_.{name}._setThresholds(float min, float max) {
    _minThreshold = min;
    _maxThreshold = max;
}

// ==================== WEAK CALLBACKS ====================

__attribute__((weak)) void Temperature_.{name}._onLowTemp(void) {
    // Implementar en código de usuario
}

__attribute__((weak)) void Temperature_.{name}._onHighTemp(void) {
    // Implementar en código de usuario
}
```

### 7.5 Uso de la API

En el `generate.emic` del módulo:

```c
// Crear dos sensores de temperatura
EMIC:setInput(DEV:_api/Sensors/Temperature/temperature.emic,
              name=Ambiente,
              pin=AN0,
              driver=NTC10K)

EMIC:setInput(DEV:_api/Sensors/Temperature/temperature.emic,
              name=Motor,
              pin=AN1,
              driver=PT100)
```

Esto generará:
- `temperature_Ambiente.h`, `temperature_Ambiente.c`
- `temperature_Motor.h`, `temperature_Motor.c`

---

## 8. Errores Comunes y Soluciones

### 8.1 Error: "No se encuentra X en ninguna colección"

**Causa:** Falta pasar un parámetro requerido.

```c
// ❌ Error: Falta el parámetro 'name'
EMIC:setInput(DEV:_api/Timers/timer_api.emic)

// ✅ Correcto
EMIC:setInput(DEV:_api/Timers/timer_api.emic, name=1)
```

### 8.2 Error: "La ruta debe incluir un volumen válido"

**Causa:** Falta el volumen en setOutput.

```c
// ❌ Error
EMIC:setOutput(systemConfig.h)

// ✅ Correcto
EMIC:setOutput(TARGET:inc/systemConfig.h)
```

### 8.3 Error: "Falta carácter '>'"

**Causa:** Sintaxis incorrecta en copy.

```c
// ❌ Error
EMIC:copy(origen.c, TARGET:destino.c)

// ✅ Correcto
EMIC:copy(origen.c > TARGET:destino.c)
```

### 8.4 Error: Archivos .c en carpeta incorrecta

**Causa:** Usar `TARGET:src/` para archivos .c.

```c
// ❌ Incorrecto: MPLAB no encontrará el archivo
EMIC:copy(src/Digital.c > TARGET:src/Digital.c)

// ✅ Correcto: .c en raíz de TARGET
EMIC:copy(src/Digital.c > TARGET:Digital.c)
```

### 8.5 Error: Stack desbalanceado

**Causa:** Más restoreOutput que setOutput.

```c
// ❌ Error: restoreOutput sin setOutput previo
EMIC:restoreOutput

// ✅ Correcto: Siempre en pares
EMIC:setOutput(TARGET:archivo.c)
    // contenido
EMIC:restoreOutput
```

---

## Resumen del Capítulo

En este capítulo aprendiste:

1. **setInput**: Procesa archivos y carga dependencias con parámetros
2. **setOutput**: Establece el archivo de destino para la salida
3. **copy**: Combina procesamiento y copia en un solo comando
4. **restoreOutput**: Gestiona el stack de archivos de salida
5. **Patrones comunes**: API completa, generate.emic, múltiples instancias
6. **Caso práctico**: API de temperatura con los tres archivos

---

## Próximo Capítulo

En el **Capítulo 18: Sistema de Macros y Sustitución**, profundizaremos en:
- Comando `define` y `unDefine`
- Grupos de macros personalizados
- Sustitución con `.{key}.`
- Expansión de grupos con `.*`
- Macros en configuradores JSON

---

*Manual de Desarrollo EMIC SDK - Versión 2.0*
*Capítulo 17 de 38*
