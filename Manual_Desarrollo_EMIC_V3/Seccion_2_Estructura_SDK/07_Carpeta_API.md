# Capítulo 07: Carpeta `_api/` - APIs de Alto Nivel

[← Anterior: Carpeta _modules](06_Carpeta_Modules.md) | [Siguiente: Carpeta _drivers →](08_Carpeta_Drivers.md)

---

## 📋 Contenido del Capítulo

1. [¿Qué es una API en EMIC?](#1-qué-es-una-api-en-emic)
2. [API vs Driver: Diferencias Clave](#2-api-vs-driver-diferencias-clave)
3. [Estructura de una API](#3-estructura-de-una-api)
4. [Categorías de APIs](#4-categorías-de-apis)
5. [Ejemplos Reales del SDK](#5-ejemplos-reales-del-sdk)
6. [Etiquetado con DOXYGEN](#6-etiquetado-con-doxygen)
7. [Gestión de Dependencias](#7-gestión-de-dependencias)
8. [Creación de Nuevas APIs](#8-creación-de-nuevas-apis)

---

## 1. ¿Qué es una API en EMIC?

### 1.1 Definición Conceptual

Una **API** (Application Programming Interface) en EMIC es una **biblioteca de alto nivel** que abstrae la complejidad del hardware y proporciona una interfaz consistente y reutilizable para los integradores.

```
┌────────────────────────────────────────────────────┐
│                  API EMIC                          │
│   Abstracción de Alto Nivel para Integradores     │
└────────────────────────────────────────────────────┘
           │
    ┌──────┴──────┬──────────────┬──────────────┐
    │             │              │              │
ABSTRACCIÓN   PORTABILIDAD   SIMPLICIDAD   REUTILIZACIÓN
    │             │              │              │
Oculta        Funciona en    Interfaz       Mismo código
detalles      varios MCUs    simple         en múltiples
hardware                                    proyectos
```

### 1.2 Características de una API EMIC

✅ **Alto nivel:** Oculta complejidad del hardware
✅ **Portable:** Funciona en diferentes MCUs (abstrae diferencias)
✅ **Documentada:** Tags DOXYGEN para Discovery
✅ **Reutilizable:** Se usa en múltiples módulos
✅ **Parametrizable:** Acepta configuración dinámica
✅ **Independiente del hardware específico:** No depende de un sensor/componente concreto

### 1.3 Propósito de las APIs

```
SIN APIs (código directo):
┌─────────────────────────────────────────┐
│  Integrador escribe:                    │
│                                         │
│  TRISAbits.TRISA0 = 0;  // salida      │
│  LATAbits.LATA0 = 1;    // encender    │
│  __delay_ms(500);                       │
│  LATAbits.LATA0 = 0;    // apagar      │
└─────────────────────────────────────────┘
  ❌ Específico del MCU
  ❌ Difícil de portar
  ❌ Requiere conocer registros

CON APIs (abstracción):
┌─────────────────────────────────────────┐
│  Integrador escribe:                    │
│                                         │
│  LED_On(led1);                          │
│  Delay_ms(500);                         │
│  LED_Off(led1);                         │
└─────────────────────────────────────────┘
  ✅ Portable entre MCUs
  ✅ Fácil de entender
  ✅ No requiere conocer registros
```

---

## 2. API vs Driver: Diferencias Clave

### 2.1 Comparación Conceptual

| Aspecto | API | Driver |
|---------|-----|--------|
| **Nivel** | Alto nivel | Bajo nivel |
| **Abstracción** | Oculta hardware específico | Controla hardware específico |
| **Portabilidad** | Portable entre MCUs | Específico del componente |
| **Dependencias** | Drivers, HAL, otras APIs | HAL, código específico MCU |
| **Ejemplo** | `LED_Toggle()` | `MAX7219_WriteDigit()` |
| **Hardware** | Genérico (cualquier LED) | Específico (chip MAX7219) |

### 2.2 Diagrama de Capas

```
┌────────────────────────────────────────────────────┐
│                 INTEGRADOR                         │
│              (EMIC-Editor / Script)                │
└────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────┐
│                    APIs                            │  ← Abstracción de hardware
│  LED_On(), Timer_Start(), UART_Send()             │     (portable entre MCUs)
└────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────┐
│                  DRIVERS                           │  ← Control de hardware específico
│  MAX7219_Init(), DHT22_Read(), RFM95_Send()       │     (específico del componente)
└────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────┐
│                    HAL                             │  ← Abstracción de periféricos MCU
│  GPIO_Write(), SPI_Transfer(), I2C_Read()         │
└────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────┐
│                  HARDWARE                          │  ← Código específico MCU
│  Registros PIC/ARM/AVR                            │
└────────────────────────────────────────────────────┘
```

### 2.3 Ejemplos Comparativos

**Ejemplo 1: LED**
- **API:** `_api/Indicators/LEDs/` → Abstrae **cualquier LED**
- **Driver:** `_drivers/Displays/MAX7219/` → Controla **chip MAX7219** específico

**Ejemplo 2: Comunicación**
- **API:** `_api/Wired_Communication/RS232/` → Abstrae **comunicación serial genérica**
- **Driver:** `_drivers/USB/MCP2200/` → Controla **chip MCP2200** específico

**Regla de oro:**
> Si funciona con **cualquier hardware del mismo tipo** → **API**
> Si funciona **solo con un chip/componente específico** → **Driver**

---

## 3. Estructura de una API

### 3.1 Árbol de Directorios

```
_api/                                ← Raíz de APIs
│
└── {Category}/                      ← Categoría (ej: Indicators)
    └── {APIName}/                   ← Nombre de la API (ej: LEDs)
        │
        ├── {APIName}.emic           ⭐ Script EMIC (recursos publicados)
        │
        ├── inc/                     ⭐ Headers C
        │   └── {APIName}.h          ← Declaraciones de funciones
        │
        └── src/                     ⭐ Implementación C
            └── {APIName}.c          ← Código de la API
```

**Ejemplo real del SDK:**
```
_api/Indicators/LEDs/
├── led.emic                         ← Script con tags DOXYGEN
├── inc/
│   └── led.h                        ← Declaraciones
└── src/
    └── led.c                        ← Implementación
```

### 3.2 Responsabilidad de Cada Archivo

| Archivo | Propósito | Contenido |
|---------|-----------|-----------|
| **{APIName}.emic** | Define recursos publicados | Tags DOXYGEN, dependencias, macros |
| **inc/{APIName}.h** | Declaraciones C | Prototipos de funciones, defines |
| **src/{APIName}.c** | Implementación C | Código de las funciones |

---

## 4. Categorías de APIs

### 4.1 Listado Completo del SDK Real

Según el SDK en `EMIC_IA_M\_api\`, existen las siguientes categorías:

| # | Categoría | Descripción | Ejemplos |
|---|-----------|-------------|----------|
| 1 | **Actuators** | Control de actuadores | Motores, relés, servos |
| 2 | **ADC** | Conversor analógico-digital | Lectura de sensores analógicos |
| 3 | **Alarm** | Gestión de alarmas | Alertas, notificaciones |
| 4 | **Audio** | Reproducción de audio | Buzzers, altavoces |
| 5 | **Custom** | APIs personalizadas | Específicas del proyecto |
| 6 | **Development_Board** | APIs de placas desarrollo | Recursos de dev boards |
| 7 | **ExternalFIFO_RAM** | Memoria FIFO/RAM externa | Buffers externos |
| 8 | **Indicators** | Indicadores visuales/auditivos | LEDs, buzzers |
| 9 | **Inputs** | Entradas digitales | Botones, switches |
| 10 | **Lavarropas** | Control de lavadoras | Ejemplo IIoT industrial |
| 11 | **Oil_Gas** | Industria petróleo/gas | Sensores industriales |
| 12 | **Power** | Gestión de energía | Sleep modes, power |
| 13 | **Protocols** | Protocolos de comunicación | Modbus, CAN, etc. |
| 14 | **Sensors** | Sensores genéricos | APIs de sensores |
| 15 | **Storage** | Almacenamiento de datos | EEPROM, Flash, SD |
| 16 | **System** | Configuración del sistema | Clock, init, watchdog |
| 17 | **Tecnocrom_Controller** | Controlador industrial | PLC-like systems |
| 18 | **Test** | APIs de prueba | Testing, debugging |
| 19 | **Timers** | Temporizadores | Delays, timeouts |
| 20 | **Wired_Communication** | Comunicación cableada | UART, I2C, SPI, RS485 |
| 21 | **Wireless** | Comunicación inalámbrica | WiFi, LoRa, BLE |

### 4.2 Distribución por Función

```
┌─────────────────────────────────────────────────────┐
│         APIs POR TIPO DE FUNCIÓN                    │
└─────────────────────────────────────────────────────┘

  🔌 COMUNICACIÓN (19%)
      ├── Wired_Communication (UART, I2C, SPI)
      ├── Wireless (WiFi, LoRa, BLE)
      └── Protocols (Modbus, CAN)

  🖥️ INTERFACES USUARIO (19%)
      ├── Indicators (LEDs, buzzers)
      ├── Inputs (botones, switches)
      └── Audio

  ⚙️ PERIFÉRICOS (24%)
      ├── Timers
      ├── ADC
      └── Power

  💾 ALMACENAMIENTO (10%)
      ├── Storage (EEPROM, SD)
      └── ExternalFIFO_RAM

  🏭 INDUSTRIA ESPECÍFICA (14%)
      ├── Oil_Gas
      ├── Lavarropas
      └── Tecnocrom_Controller

  🔧 SISTEMA + OTROS (14%)
      ├── System
      ├── Sensors
      ├── Actuators
      ├── Alarm
      └── Custom
```

---

## 5. Ejemplos Reales del SDK

### 5.1 Ejemplo 1: LED API (Simple)

**Ubicación:** `_api/Indicators/LEDs/`

**Archivo: led.emic**

```emic
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

EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

EMIC:copy(inc/led.h > TARGET:inc/led_.{name}..h,name=.{name}.,pin=.{pin}.)
EMIC:copy(src/led.c > TARGET:led_.{name}..c,name=.{name}.,pin=.{pin}.)

EMIC:define(main_includes.led_.{name}.,led_.{name}.)
EMIC:define(c_modules.led_.{name}.,led_.{name}.)
```

**Análisis del led.emic:**

1. **Tag de driver:**
   ```emic
   EMIC:tag(driverName = LEDs)
   ```
   Identifica la API como "LEDs" en el sistema.

2. **Funciones publicadas (tags DOXYGEN):**
   - `LEDs_.{name}._state(uint8_t state)` → Cambia estado del LED
   - `LEDs_.{name}._blink(...)` → Hace parpadear el LED

3. **Macros:**
   - `.{name}.` → Reemplazado por el nombre dado en generate.emic (ej: "led1")
   - `.{pin}.` → Reemplazado por el pin (ej: "A2_Pin")

4. **Dependencias:**
   - `_hal/GPIO/gpio.emic` → Para controlar el pin
   - `_drivers/SystemTimer/systemTimer.emic` → Para timing del blink

5. **Generación de archivos:**
   - Copia `inc/led.h` a `TARGET:inc/led_led1.h` (ejemplo con name=led1)
   - Copia `src/led.c` a `TARGET:led_led1.c`

**Archivo: inc/led.h**

```c
#include <xc.h>

void LEDs_.{name}._init (void);
EMIC:define(inits.LEDs_.{name}.,LEDs_.{name}._init)

EMIC:ifdef usedFunction.LEDs_.{name}._blink
void LEDs_.{name}._poll (void);
EMIC:define(polls.LEDs_.{name}.,LEDs_.{name}._poll)
EMIC:endif

EMIC:ifdef usedFunction.LEDs_.{name}._state
void LEDs_.{name}._state(uint8_t);
EMIC:endif

EMIC:ifdef usedFunction.LEDs_.{name}._blink
void LEDs_.{name}._blink(uint16_t, uint16_t, uint16_t);
EMIC:endif
```

**Características del header:**

- **Compilación condicional:** Solo incluye funciones si se usan
- **Macros EMIC:** Define `inits` y `polls` para system.c
- **Prototipos:** Declara las funciones públicas

**Uso desde generate.emic:**

```emic
// En _modules/MiModulo/System/generate.emic
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led1,pin=A2_Pin)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led2,pin=B3_Pin)
```

**Resultado:** Se generan `led_led1.c`, `led_led1.h`, `led_led2.c`, `led_led2.h`

---

### 5.2 Ejemplo 2: Timer API (Común)

**Ubicación:** `_api/Timers/`

**Archivo: timer_api.emic**

```emic
EMIC:tag(driverName = TIME)

/**
* @fn void setTime.{name}.(uint16_t time,char mode);
* @alias setTime.{name}.
* @brief Time in milliseconds for the event to be generated.
* @param time Time in milliseconds.
* @param mode T:timer, A:auto-reload.
* @return Nothing
*/

/**
* @fn extern void etOut.{name}.(void);
* @alias timeOut.{name}.
* @brief When the time configured in the timer was established.
* @return Nothing
*/

EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

EMIC:copy(inc/timer_api.h > TARGET:inc/timer_api.{name}..h,name=.{name}.)
EMIC:copy(src/timer_api.c > TARGET:timer_api.{name}..c,name=.{name}.)

EMIC:define(main_includes.timer_api.{name}.,timer_api.{name}.)
EMIC:define(c_modules.timer_api.{name}.,timer_api.{name}.)
```

**Análisis:**

1. **Funciones publicadas:**
   - `setTime.{name}.(uint16_t time, char mode)` → Configura el timer
   - `etOut.{name}.(void)` → Evento de timeout (callback)

2. **Parámetros:**
   - `time`: Tiempo en milisegundos
   - `mode`: 'T' = timer único, 'A' = auto-reload (repetitivo)

3. **Evento publicado:**
   - `timeOut.{name}.` → Se ejecuta cuando el tiempo se cumple

**Uso desde generate.emic:**

```emic
EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)
EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=2)
EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=3)
```

**Uso desde program.xml (integrador):**

```xml
<Init>
  <Call function="setTime1" params="1000,'A'"/>  <!-- Timer 1: 1s auto-reload -->
</Init>

<Event name="timeOut1">
  <Call function="LED_Toggle" params="led1"/>
</Event>
```

---

### 5.3 Ejemplo 3: RS232 API (Complejo)

**Ubicación:** `_api/Wired_Communication/RS232/`

**Archivo: rs232.emic** (fragmento)

```emic
/*****************************************************************************
  @file     rs232.emic
  @brief    RS232 interface
  @author   Francisco Martinez
  @version  v0.0.1
  @date     02/08/2024
 ******************************************************************************/

EMIC:tag(driverName = RS232)
EMIC:ifndef _RS232_API_EMIC
EMIC:define(_RS232_API_EMIC,true)

EMIC:define(UART.{port}._CALLBACK_RX,true)

EMIC:json(type = configurator)
{
    "brief": "El protocolo define el formato de los datos enviados y recibidos",
    "legend": "seleccione protocolo",
    "name": "RS232prot",
    "options":
    [
        {
            "legend": "EMIC Message",
            "value": "EMIC_message",
            "brief": "Mensajes para intercambio de información entre módulos y software EMIC"
        },
        {
            "legend": "TEXT Message",
            "value": "TEXT_line",
            "brief": "Mensajes de textos terminados en fin de línea - para sistemas heredados"
        }
    ]
}

EMIC:if(.{config.RS232prot}.==EMIC_message)
/**
* @fn void pRS232(char* format,...);
* @alias Send_EMIC(concat tag,concat msg)
* @brief Send a EMIC message through the RS232 port
* @return Nothing
* @param tag Etiqueta que identifica el mensaje
* @param msg Contenido del mensaje
*/

/**
* @fn extern void eRS232(char* tag,const streamIn_t* const msg);
* @alias Reception_EMIC
* @brief When it receives a EMIC message through the RS232 port
* @return Nothing
* @param tag Tag to identify the message
* @param msg message payload
*/
EMIC:endif

EMIC:if(.{config.RS232prot}.==TEXT_line)
/**
* @fn variadic pRS232(char* format,...);
* @alias Send_TEXT(concat msg)
* @brief Send a message through the RS232 port
* @return Nothing
* @param msg Contenido del mensaje
*/

/**
* @fn extern void eRS232(const streamIn_t* const msg);
* @alias Reception_TEXT
* @brief When it receives a string through the RS232 port
* @return Nothing
* @param msg message payload
*/
EMIC:endif
```

**Análisis de características avanzadas:**

1. **Configurator JSON:**
   ```json
   {
     "name": "RS232prot",
     "options": ["EMIC_message", "TEXT_line"]
   }
   ```
   Permite al integrador elegir el protocolo en EMIC-Editor.

2. **Compilación condicional:**
   ```emic
   EMIC:if(.{config.RS232prot}.==EMIC_message)
   // Publica funciones para protocolo EMIC
   EMIC:endif

   EMIC:if(.{config.RS232prot}.==TEXT_line)
   // Publica funciones para protocolo TEXT
   EMIC:endif
   ```
   Las funciones publicadas cambian según la configuración.

3. **Funciones variadicas:**
   ```c
   variadic pRS232(char* format,...)
   ```
   Acepta número variable de argumentos (como printf).

4. **Callbacks (eventos):**
   ```c
   extern void eRS232(...)
   ```
   El integrador implementa este evento para recibir mensajes.

5. **Include guard EMIC:**
   ```emic
   EMIC:ifndef _RS232_API_EMIC
   EMIC:define(_RS232_API_EMIC,true)
   ```
   Evita inclusión múltiple.

**Uso desde generate.emic:**

```emic
EMIC:setInput(DEV:_api/Wired_Communication/RS232/rs232.emic,
              port=1,
              baud=115200,
              config.RS232prot=EMIC_message)
```

**Uso desde program.xml:**

```xml
<Loop>
  <Call function="Send_EMIC" params="'TEMP',temperatura"/>
</Loop>

<Event name="Reception_EMIC">
  <If condition="tag == 'CMD'">
    <Call function="ProcessCommand" params="msg"/>
  </If>
</Event>
```

---

## 6. Etiquetado con DOXYGEN

### 6.1 Tags DOXYGEN en EMIC

EMIC utiliza un **subset de DOXYGEN** para publicar recursos en EMIC-Discovery.

**Tags soportados:**

| Tag | Propósito | Ejemplo |
|-----|-----------|---------|
| **@fn** | Prototipo de función | `@fn void LED_On(void);` |
| **@alias** | Nombre simplificado | `@alias LED1.on` |
| **@brief** | Descripción breve | `@brief Turn on the LED` |
| **@param** | Parámetro de función | `@param state 1=on, 0=off` |
| **@return** | Valor de retorno | `@return Nothing` |

### 6.2 Sintaxis Completa

```c
/**
* @fn void FuncionNombre(tipo1 param1, tipo2 param2);
* @alias NombreSimple
* @brief Descripción corta de la función.
* @param param1 Descripción del parámetro 1
* @param param2 Descripción del parámetro 2
* @return Descripción del valor de retorno
*/
```

**Ejemplo real:**

```c
/**
* @fn void LEDs_led1_blink(uint16_t timeOn, uint16_t period, uint16_t times);
* @alias led1.blink
* @brief Blink the led1.
* @param timeOn time that the LED lasts on in each cycle.
* @param period length of time each cycle lasts.
* @param times number of cycles.
* @return Nothing
*/
```

### 6.3 Uso de Macros en Tags

Las macros se expanden en los tags:

```c
/**
* @fn void LEDs_.{name}._state(uint8_t state);
* @alias .{name}..state
* @brief Change the state of the led.
*/
```

Cuando `name=led1`:
```c
/**
* @fn void LEDs_led1_state(uint8_t state);
* @alias led1.state
* @brief Change the state of the led.
*/
```

### 6.4 Funciones con `extern` (Eventos)

Las funciones marcadas con `extern` son **eventos** que el integrador debe implementar:

```c
/**
* @fn extern void etOut1(void);
* @alias timeOut1
* @brief When the time configured in timer1 was established.
* @return Nothing
*/
```

El integrador NO llama a `timeOut1`, sino que **implementa** el callback:

```xml
<Event name="timeOut1">
  <!-- Código del integrador aquí -->
</Event>
```

### 6.5 Modificadores Especiales

**variadic:**
```c
/**
* @fn variadic pRS232(char* format,...);
* @alias Send_TEXT(concat msg)
*/
```
Indica que acepta argumentos variables (como printf).

**concat:**
```c
@alias Send_EMIC(concat tag,concat msg)
```
Los parámetros se concatenan en strings.

---

## 7. Gestión de Dependencias

### 7.1 Tipos de Dependencias

Una API puede depender de:

```
API
 ├── Drivers         (hardware específico)
 ├── HAL             (periféricos MCU)
 ├── Otras APIs      (composición)
 └── System          (utilidades del sistema)
```

### 7.2 Declaración de Dependencias

**Sintaxis:**
```emic
EMIC:setInput(DEV:ruta/archivo.emic)
```

**Ejemplo de LED API:**
```emic
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)
```

### 7.3 Diagrama de Dependencias

**Ejemplo: RS232 API**

```
RS232 API
    ↓
    ├──> UART HAL
    │       ↓
    │       └──> UART Driver (_hard/)
    │
    ├──> SystemTimer Driver
    │       ↓
    │       └──> Timer HAL
    │
    └──> String Utilities (_util/)
```

**En código:**
```emic
EMIC:setInput(DEV:_hal/UART/uart.emic,port=.{port}.)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)
EMIC:setInput(DEV:_util/String/string_utils.emic)
```

### 7.4 Resolución de Dependencias

EMIC-Generate resuelve dependencias **automáticamente** en orden:

```
1. Lee generate.emic del módulo
2. Encuentra EMIC:setInput(DEV:_api/LEDs/led.emic)
3. Lee led.emic
4. Encuentra dependencias:
   - EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
   - EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)
5. Lee gpio.emic y systemTimer.emic
6. Si tienen dependencias, las resuelve recursivamente
7. Copia todos los archivos a Target/ en orden correcto
```

### 7.5 Evitar Dependencias Circulares

❌ **Mal:**
```
API_A depende de API_B
API_B depende de API_A
```

✅ **Bien:**
```
API_A depende de Driver_C
API_B depende de Driver_C
```

**Regla:** Las dependencias siempre deben ir "hacia abajo" en las capas:
```
Módulos → APIs → Drivers → HAL → Hardware
```

---

## 8. Creación de Nuevas APIs

### 8.1 Checklist de Creación

**PASO 1: Planificación**
- [ ] Definir nombre de la API (ej: "PWM_Control")
- [ ] Elegir categoría (ej: "Actuators")
- [ ] Identificar funciones públicas
- [ ] Listar dependencias necesarias

**PASO 2: Estructura de Carpetas**
```bash
mkdir -p _api/{Categoria}/{NombreAPI}/inc
mkdir -p _api/{Categoria}/{NombreAPI}/src
```

**PASO 3: Crear {NombreAPI}.emic**
- [ ] Agregar `EMIC:tag(driverName = ...)`
- [ ] Documentar funciones con tags DOXYGEN
- [ ] Declarar dependencias con `EMIC:setInput`
- [ ] Definir macros y comandos EMIC:copy

**PASO 4: Crear inc/{NombreAPI}.h**
- [ ] Prototipos de funciones
- [ ] Defines y constantes
- [ ] Compilación condicional (`EMIC:ifdef`)

**PASO 5: Crear src/{NombreAPI}.c**
- [ ] Implementación de funciones
- [ ] Lógica de negocio
- [ ] Manejo de estado

**PASO 6: Testing**
- [ ] Ejecutar EMIC-Discovery
- [ ] Verificar recursos publicados
- [ ] Crear módulo de prueba
- [ ] Compilar y probar en hardware

---

### 8.2 Ejemplo: Creando "Servo_API"

**Ubicación:** `_api/Actuators/Servo/`

**1. servo.emic:**
```emic
EMIC:tag(driverName = SERVO)

/**
* @fn void Servo_.{name}._setAngle(uint16_t angle);
* @alias .{name}..setAngle
* @brief Set servo angle in degrees (0-180).
* @param angle Angle in degrees (0-180)
* @return Nothing
*/

/**
* @fn void Servo_.{name}._sweep(uint16_t angleMin, uint16_t angleMax, uint16_t speed);
* @alias .{name}..sweep
* @brief Sweep servo between two angles.
* @param angleMin Minimum angle
* @param angleMax Maximum angle
* @param speed Speed in degrees/second
* @return Nothing
*/

// Dependencias
EMIC:setInput(DEV:_hal/PWM/pwm.emic,channel=.{pwm_channel}.)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

// Copiar archivos
EMIC:copy(inc/servo.h > TARGET:inc/servo_.{name}..h,name=.{name}.,pwm_channel=.{pwm_channel}.)
EMIC:copy(src/servo.c > TARGET:servo_.{name}..c,name=.{name}.,pwm_channel=.{pwm_channel}.)

// Definir includes y módulos
EMIC:define(main_includes.servo_.{name}.,servo_.{name}.)
EMIC:define(c_modules.servo_.{name}.,servo_.{name}.)
```

**2. inc/servo.h:**
```c
#ifndef SERVO_.{name}._H
#define SERVO_.{name}._H

#include <stdint.h>

void Servo_.{name}._init(void);
EMIC:define(inits.Servo_.{name}.,Servo_.{name}._init)

void Servo_.{name}._poll(void);
EMIC:define(polls.Servo_.{name}.,Servo_.{name}._poll)

void Servo_.{name}._setAngle(uint16_t angle);
void Servo_.{name}._sweep(uint16_t angleMin, uint16_t angleMax, uint16_t speed);

#endif
```

**3. src/servo.c:**
```c
#include "servo_.{name}..h"
#include "pwm.h"
#include "systemTimer.h"

// Constantes de calibración
#define SERVO_MIN_PULSE_US  1000  // 1ms (0°)
#define SERVO_MAX_PULSE_US  2000  // 2ms (180°)
#define SERVO_PERIOD_US     20000 // 20ms

typedef struct {
    uint16_t currentAngle;
    uint16_t targetAngle;
    uint16_t sweepMin;
    uint16_t sweepMax;
    uint16_t sweepSpeed;
    bool sweeping;
} Servo_State_t;

static Servo_State_t servo_.{name}._state;

void Servo_.{name}._init(void) {
    PWM_Init(.{pwm_channel}., SERVO_PERIOD_US);
    servo_.{name}._state.currentAngle = 90; // Centro
    servo_.{name}._state.sweeping = false;
    Servo_.{name}._setAngle(90);
}

void Servo_.{name}._setAngle(uint16_t angle) {
    if(angle > 180) angle = 180;

    // Convertir ángulo a ancho de pulso
    uint16_t pulseWidth = SERVO_MIN_PULSE_US +
                         ((angle * (SERVO_MAX_PULSE_US - SERVO_MIN_PULSE_US)) / 180);

    PWM_SetDutyCycle(.{pwm_channel}., pulseWidth);
    servo_.{name}._state.currentAngle = angle;
}

void Servo_.{name}._sweep(uint16_t angleMin, uint16_t angleMax, uint16_t speed) {
    servo_.{name}._state.sweepMin = angleMin;
    servo_.{name}._state.sweepMax = angleMax;
    servo_.{name}._state.sweepSpeed = speed;
    servo_.{name}._state.sweeping = true;
}

void Servo_.{name}._poll(void) {
    if(!servo_.{name}._state.sweeping) return;

    // Lógica de sweep (simplificada)
    static bool direction = true;
    uint16_t current = servo_.{name}._state.currentAngle;

    if(direction) {
        current += 1;
        if(current >= servo_.{name}._state.sweepMax) direction = false;
    } else {
        current -= 1;
        if(current <= servo_.{name}._state.sweepMin) direction = true;
    }

    Servo_.{name}._setAngle(current);
}
```

**4. Uso desde generate.emic:**
```emic
EMIC:setInput(DEV:_api/Actuators/Servo/servo.emic,
              name=servo1,
              pwm_channel=1)

EMIC:setInput(DEV:_api/Actuators/Servo/servo.emic,
              name=servo2,
              pwm_channel=2)
```

**5. Uso desde program.xml:**
```xml
<Init>
  <Call function="servo1.setAngle" params="0"/>
  <Call function="servo2.setAngle" params="180"/>
</Init>

<Loop>
  <Call function="servo1.sweep" params="0,180,45"/>
</Loop>
```

---

## 🎯 Puntos Clave del Capítulo

| Concepto | Explicación |
|----------|-------------|
| **API EMIC** | Biblioteca de alto nivel que abstrae hardware |
| **API vs Driver** | API = genérico y portable, Driver = específico |
| **Estructura** | {APIName}.emic + inc/ + src/ |
| **Tags DOXYGEN** | @fn, @alias, @brief, @param, @return |
| **Macros** | .{name}., .{pin}., etc. (reemplazadas en Generate) |
| **Dependencias** | EMIC:setInput() para Drivers, HAL, otras APIs |
| **21 categorías** | Desde Actuators hasta Wireless |

---

## 📊 Resumen Visual

```
┌────────────────────────────────────────────────────┐
│              API EMIC                              │
│    _api/{Category}/{APIName}/                      │
└────────────────────────────────────────────────────┘
            │
     ┌──────┴──────┬──────────────┐
     │             │              │
{APIName}.emic  inc/*.h        src/*.c
     │             │              │
     │             │              │
Tags DOXYGEN   Prototipos   Implementación
Dependencias   Defines      Lógica
Macros         Compilación  Estado
               condicional
```

---

## ✅ Checklist de Comprensión

Antes de continuar al Capítulo 08, asegúrate de entender:

- [ ] Qué es una API en EMIC (abstracción de alto nivel)
- [ ] La diferencia entre API y Driver
- [ ] La estructura de una API ({APIName}.emic + inc/ + src/)
- [ ] Las 21 categorías de APIs disponibles
- [ ] Los tags DOXYGEN (@fn, @alias, @brief, @param, @return)
- [ ] Cómo funcionan las macros (.{name}., .{pin}.)
- [ ] El propósito de EMIC:setInput() (dependencias)
- [ ] La diferencia entre funciones normales y eventos (extern)
- [ ] Cómo crear una nueva API desde cero

---

## 🎓 Ejercicio Práctico

**Exploración del SDK Real:**

```powershell
# Navega a _api/
cd C:\Users\franc\Dropbox\...\EMIC_IA_M\_api\

# Lista todas las categorías
ls

# Explora la API de LEDs
cd Indicators\LEDs\
cat led.emic

# Cuenta las funciones publicadas (tags @fn)
Select-String "@fn" led.emic

# Explora la API de Timers
cd ..\..\Timers\
cat timer_api.emic
```

**Pregunta de reflexión:**
¿Por qué LED API depende de `_hal/GPIO/` pero NO de un driver específico de LED?

<details>
<summary>Ver respuesta</summary>

**Respuesta:**
Porque LED API es **genérica** y funciona con **cualquier LED** conectado a **cualquier pin GPIO**. Solo necesita controlar un pin (GPIO HAL), no un chip específico.

Si existiera un driver `MAX7219` (chip que controla múltiples LEDs), ese sería un **Driver** específico, no una API genérica.

La regla:
- **API**: Genérica (cualquier LED) → Depende de HAL
- **Driver**: Específica (chip MAX7219) → Depende de HAL + protocolo SPI

</details>

---

[← Anterior: Carpeta _modules](06_Carpeta_Modules.md) | [Siguiente: Carpeta _drivers →](08_Carpeta_Drivers.md)

---

**Progreso del Manual:**

```
Sección 1 (Introducción): ████████████████████ 100% (5/5)
Sección 2 (Estructura):   ██████░░░░░░░░░░░░░░  27% (3/11)
```

**Progreso Total:** 21.05% (8/38 capítulos)

---

*Capítulo 07 - Manual de Desarrollo EMIC SDK v1.0*
*Última actualización: Noviembre 2025*
