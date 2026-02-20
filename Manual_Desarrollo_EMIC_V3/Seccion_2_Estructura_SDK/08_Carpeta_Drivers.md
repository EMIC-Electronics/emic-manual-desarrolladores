# Capítulo 08: Carpeta `_drivers/` - Drivers de Hardware

[← Anterior: Carpeta _api](07_Carpeta_API.md) | [Siguiente: Carpeta _hal →](09_Carpeta_HAL.md)

---

## 📋 Contenido del Capítulo

1. [¿Qué es un Driver en EMIC?](#1-qué-es-un-driver-en-emic)
2. [Driver vs API: Diferencias Definitivas](#2-driver-vs-api-diferencias-definitivas)
3. [Estructura de un Driver](#3-estructura-de-un-driver)
4. [Categorías de Drivers](#4-categorías-de-drivers)
5. [Ejemplos Reales del SDK](#5-ejemplos-reales-del-sdk)
6. [Dependencias de Drivers](#6-dependencias-de-drivers)
7. [Integración con APIs](#7-integración-con-apis)
8. [Creación de Nuevos Drivers](#8-creación-de-nuevos-drivers)

---

## 1. ¿Qué es un Driver en EMIC?

### 1.1 Definición Conceptual

Un **Driver** en EMIC es una **biblioteca de bajo nivel** que controla hardware específico (chips, sensores, componentes externos) proporcionando una interfaz directa con el dispositivo.

```
┌────────────────────────────────────────────────────┐
│                  DRIVER EMIC                       │
│   Control de Hardware Específico de Bajo Nivel    │
└────────────────────────────────────────────────────┘
           │
    ┌──────┴──────┬──────────────┬──────────────┐
    │             │              │              │
ESPECÍFICO    BAJO NIVEL    HARDWARE        PROTOCOLO
   CHIP                      EXTERNO        ESPECÍFICO
    │             │              │              │
MCP2200       Registros      Sensor         I2C/SPI
(chip USB)    directos       DHT22          UART
```

### 1.2 Características de un Driver EMIC

✅ **Bajo nivel:** Acceso directo al hardware
✅ **Específico:** Diseñado para un chip/componente concreto
✅ **Protocolo:** Implementa comunicación con el dispositivo
✅ **Dependiente de HAL:** Usa abstracción de periféricos MCU
✅ **Reutilizable:** Se usa en múltiples proyectos
✅ **NO portable:** Cambiar chip requiere cambiar driver

### 1.3 Propósito de los Drivers

```
┌────────────────────────────────────────────────────┐
│  SIN Driver (código directo en el módulo):         │
│                                                    │
│  // Inicializar sensor DHT22                      │
│  GPIO_SetOutput(DATA_PIN);                        │
│  GPIO_Write(DATA_PIN, LOW);                       │
│  Delay_ms(18);                                    │
│  GPIO_Write(DATA_PIN, HIGH);                      │
│  GPIO_SetInput(DATA_PIN);                         │
│  // ... 50 líneas más de protocolo DHT22 ...     │
└────────────────────────────────────────────────────┘
  ❌ Repetido en cada módulo que usa DHT22
  ❌ Difícil de mantener
  ❌ Propenso a errores

┌────────────────────────────────────────────────────┐
│  CON Driver (abstracción reutilizable):            │
│                                                    │
│  DHT22_ReadTemperature(&temp, &humidity);         │
└────────────────────────────────────────────────────┘
  ✅ Reutilizable en todos los módulos
  ✅ Fácil de mantener
  ✅ Testeado y confiable
```

---

## 2. Driver vs API: Diferencias Definitivas

### 2.1 Comparación Completa

| Aspecto | Driver | API |
|---------|--------|-----|
| **Nivel de Abstracción** | Bajo nivel (hardware directo) | Alto nivel (funcionalidad) |
| **Hardware** | **Específico** (chip MCP2200, sensor DHT22) | **Genérico** (cualquier LED, cualquier UART) |
| **Portabilidad** | **NO portable** (cambiar chip = cambiar driver) | **Portable** (funciona en cualquier MCU) |
| **Protocolo** | Implementa protocolo del chip | Abstrae protocolo |
| **Dependencias** | HAL + código específico MCU | Drivers + HAL |
| **Ejemplo** | `MCP2200_SendByte()` | `USB_Send()` |
| **Cambio de hardware** | Requiere nuevo driver | NO requiere cambios |
| **Documentación** | Datasheet del chip | Concepto genérico |
| **Testing** | Específico del chip | Funcional genérico |

### 2.2 Diagrama de Capas Completo

```
┌────────────────────────────────────────────────────┐
│                 INTEGRADOR                         │
│              (EMIC-Editor / Script)                │
└────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────┐
│                   MÓDULO                           │  ← Solución completa
│  (Combina APIs según necesidad)                   │
└────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────┐
│                    APIs                            │  ← Nivel ALTO
│  LED_Toggle(), Timer_Start(), USB_Send()          │     (portable, genérico)
│                                                    │
│  Características:                                 │
│  • Genéricas (cualquier LED)                      │
│  • Portables entre MCUs                           │
│  • Abstraen complejidad                           │
└────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────┐
│                  DRIVERS                           │  ← Nivel BAJO
│  MCP2200_Init(), DHT22_Read(), RFM95_SendPacket() │     (específico, NO portable)
│                                                    │
│  Características:                                 │
│  • Específicos de chip/componente                 │
│  • Implementan protocolo del dispositivo          │
│  • Acceso directo al hardware                     │
└────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────┐
│                    HAL                             │  ← Abstracción de periféricos
│  GPIO_Write(), SPI_Transfer(), I2C_Read()         │     (abstrae registros MCU)
└────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────┐
│                 HARDWARE (_hard/)                  │  ← Código específico MCU
│  Registros PIC/ARM/AVR                            │
└────────────────────────────────────────────────────┘
```

### 2.3 Ejemplos Comparativos

**Caso 1: LED**
- **Driver:** NO existe driver de LED genérico (es muy simple)
- **API:** `_api/Indicators/LEDs/` → Abstrae **cualquier LED**
- **Razón:** Un LED solo necesita GPIO (HAL), no protocolo complejo

**Caso 2: Sensor de Temperatura I2C**
- **Driver:** `_drivers/Sensors/TMP102/` → Controla chip **TMP102** específico
- **API:** `_api/Sensors/Temperature/` → Abstrae **cualquier sensor** de temperatura
- **Razón:** TMP102 tiene protocolo I2C específico, pero la API abstrae el concepto "temperatura"

**Caso 3: Comunicación USB**
- **Driver:** `_drivers/USB/MCP2200/` → Controla chip **MCP2200** específico
- **API:** `_api/Wired_Communication/USB/` → Abstrae **comunicación USB genérica**
- **Razón:** MCP2200 es un chip UART-to-USB específico, la API abstrae "enviar/recibir datos USB"

### 2.4 Regla de Decisión: ¿API o Driver?

```
┌─────────────────────────────────────────┐
│  ¿DEBO CREAR API O DRIVER?              │
└─────────────────────────────────────────┘

  ❓ ¿Controla un chip/componente específico?
      │
      ├─ Sí ──> DRIVER
      │         Ejemplo: MAX7219, DHT22, RFM95
      │
      └─ No ──> API
                Ejemplo: LED genérico, Timer, UART

  ❓ ¿Tiene protocolo propietario/específico?
      │
      ├─ Sí ──> DRIVER
      │         Ejemplo: TMP102 (I2C con comandos específicos)
      │
      └─ No ──> API
                Ejemplo: GPIO toggle, delay

  ❓ ¿Cambiar hardware requiere cambiar código?
      │
      ├─ Sí ──> DRIVER
      │         Ejemplo: Cambiar de MCP2200 a FT232
      │
      └─ No ──> API
                Ejemplo: Cambiar pin del LED
```

---

## 3. Estructura de un Driver

### 3.1 Árbol de Directorios

```
_drivers/                            ← Raíz de drivers
│
└── {DriverCategory}/                ← Categoría (ej: USB)
    └── {DriverName}/                ← Nombre del driver (ej: MCP2200)
        │
        ├── {DriverName}.emic        ⭐ Script EMIC (dependencias)
        │
        ├── inc/                     ⭐ Headers C
        │   └── {DriverName}.h       ← Declaraciones + protocolo
        │
        └── src/                     ⭐ Implementación C
            └── {DriverName}.c       ← Código del driver
```

**Ejemplo real del SDK:**
```
_drivers/USB/MCP2200/
├── MCP2200.emic                     ← Script con dependencias HAL
├── inc/
│   └── mcp2200.h                    ← Declaraciones
└── src/
    └── mcp2200.c                    ← Implementación del protocolo
```

### 3.2 Diferencias con APIs

| Aspecto | Driver | API |
|---------|--------|-----|
| **Macros** | Menos comunes (chip específico) | Muy comunes (.{name}., .{pin}.) |
| **Tags DOXYGEN** | Menos frecuentes (no para integradores) | Siempre (publican recursos) |
| **Dependencias** | HAL + _hard | Drivers + HAL |
| **Parámetros** | Configuración del chip | Instancias múltiples |

---

## 4. Categorías de Drivers

### 4.1 Listado Completo del SDK Real

Según el SDK en `EMIC_IA_M\_drivers\`, existen las siguientes categorías:

| # | Categoría | Descripción | Ejemplos |
|---|-----------|-------------|----------|
| 1 | **ADC** | Conversores analógico-digitales externos | ADC externos I2C/SPI |
| 2 | **Amp** | Amplificadores | Amplificadores de audio/señal |
| 3 | **Display** | Displays y pantallas | LCD, OLED, 7-segmentos |
| 4 | **I2C** | Drivers de comunicación I2C | I2C master/slave |
| 5 | **RAM** | Memorias RAM externas | SRAM, FIFO externas |
| 6 | **SystemTimer** | Timer del sistema | Temporizador fundamental |
| 7 | **USB** | Chips USB | MCP2200, FT232, etc. |

### 4.2 Clasificación por Función

```
┌─────────────────────────────────────────────────────┐
│         DRIVERS POR TIPO DE FUNCIÓN                 │
└─────────────────────────────────────────────────────┘

  🔌 COMUNICACIÓN (29%)
      ├── I2C (protocolo I2C)
      └── USB (chips USB como MCP2200)

  🖥️ INTERFAZ VISUAL (14%)
      └── Display (LCDs, OLEDs)

  ⚙️ SISTEMA (14%)
      └── SystemTimer (timer fundamental)

  💾 ALMACENAMIENTO/PROCESAMIENTO (43%)
      ├── RAM (memorias externas)
      ├── ADC (conversores externos)
      └── Amp (amplificadores)
```

---

## 5. Ejemplos Reales del SDK

### 5.1 Ejemplo 1: SystemTimer (Driver Fundamental)

**Ubicación:** `_drivers/SystemTimer/`

**Propósito:** Proporcionar un timer de sistema en milisegundos para delays y timeouts.

**Archivo: systemTimer.emic**

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

**Análisis:**

1. **Include guard:**
   ```emic
   EMIC:ifndef _DIVER_SYSTEM_TIMER_EMIC_
   EMIC:define(_DIVER_SYSTEM_TIMER_EMIC_,true)
   ```
   Evita inclusión múltiple del driver.

2. **Dependencia de HAL:**
   ```emic
   EMIC:setInput(DEV:_hal/Timer/timer.emic)
   ```
   Depende del HAL de Timer (abstrae Timer0/Timer1/Timer2 según MCU).

3. **Copia de archivos:**
   ```emic
   EMIC:setOutput(TARGET:inc/systemTimer.h)
       EMIC:setInput(inc/systemTimer.h)
   EMIC:restoreOutput
   ```
   Copia el header a Target/inc/

4. **Sin macros:** No usa .{name}. porque es un driver singleton (solo una instancia).

**Archivo: inc/systemTimer.h**

```c
#include <xc.h>

uint32_t getSystemMilis(void);
void systemTimeInit(void);
EMIC:define(inits.systemTimeInit,systemTimeInit)
```

**Funciones públicas:**
- `getSystemMilis()` → Retorna milisegundos desde el inicio
- `systemTimeInit()` → Inicializa el timer (llamado automáticamente)

**Uso desde APIs:**

```emic
// En led.emic (API de LEDs)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

// Ahora puede usar getSystemMilis() en led.c
uint32_t lastToggle = getSystemMilis();
```

---

### 5.2 Ejemplo 2: I2C Driver (Comunicación)

**Ubicación:** `_drivers/I2C/`

**Propósito:** Driver de comunicación I2C master/slave.

**Archivo: I2C_driver.emic**

```emic
EMIC:ifndef I2C_DRIVER_EMIC_
EMIC:define(I2C_DRIVER_EMIC_,true)

EMIC:define(I2C.{port}._CALLBACK_MASTER,true)
EMIC:define(I2C.{port}._CALLBACK_SLAVE,true)

EMIC:setInput(DEV:_hal/I2C/I2C.emic,port=.{port}.,client=I2c_driver,interrupt=1)

EMIC:copy(inc/I2C_driver.h > TARGET:inc/I2C.{port}._driver.h,port=.{port}.)
EMIC:copy(src/I2C_driver.c > TARGET:I2C.{port}._driver.c,port=.{port}.,frameID=.{frameID}.)

EMIC:define(c_modules.I2C.{port}._driver,I2C.{port}._driver)
EMIC:endif
```

**Análisis:**

1. **Callbacks habilitados:**
   ```emic
   EMIC:define(I2C.{port}._CALLBACK_MASTER,true)
   EMIC:define(I2C.{port}._CALLBACK_SLAVE,true)
   ```
   Habilita interrupciones para I2C master y slave.

2. **Dependencia de HAL I2C:**
   ```emic
   EMIC:setInput(DEV:_hal/I2C/I2C.emic,port=.{port}.,client=I2c_driver,interrupt=1)
   ```
   Parámetros:
   - `port`: Puerto I2C (1, 2, etc.)
   - `client`: Nombre del cliente (para callbacks)
   - `interrupt`: Habilitar interrupciones

3. **Macros de instancia:**
   - `.{port}.` → Puerto I2C (permite múltiples instancias)
   - `.{frameID}.` → ID de frame para protocolo

4. **Archivos generados:**
   - `I2C1_driver.h`, `I2C1_driver.c` (si port=1)
   - `I2C2_driver.h`, `I2C2_driver.c` (si port=2)

**Uso desde API:**

```emic
// En sensor_api.emic
EMIC:setInput(DEV:_drivers/I2C/I2C_driver.emic,port=1,frameID=0x48)

// Ahora puede usar funciones I2C en sensor_api.c
I2C1_Write(0x48, data, length);
I2C1_Read(0x48, buffer, length);
```

---

### 5.3 Ejemplo 3: MCP2200 (Chip USB Específico)

**Ubicación:** `_drivers/USB/MCP2200/`

**Propósito:** Driver para chip MCP2200 (UART-to-USB de Microchip).

**Archivo: MCP2200.emic**

```emic
EMIC:ifndef _MCP2200_EMIC
EMIC:define(_MCP2200_EMIC,true)

EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_hal/UART/UART.emic,port=.{port}.,BufferSize=.{BufferSize}.,baud=.{baud}.,driver=.{driver}.)

EMIC:copy(inc/mcp2200.h > TARGET:inc/MCP2200.h,port=.{port}.)
EMIC:copy(src/mcp2200.c > TARGET:MCP2200.c,port=.{port}.)

EMIC:define(c_modules.MCP2200,MCP2200)

/*==================[end of file]============================================*/
EMIC:endif
```

**Análisis:**

1. **Dependencias múltiples:**
   ```emic
   EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
   EMIC:setInput(DEV:_hal/UART/UART.emic,port=.{port}.,...)
   ```
   - GPIO: Para controlar pines del MCP2200 (reset, status)
   - UART: Para comunicación MCU ↔ MCP2200

2. **Parámetros del chip:**
   - `port`: Puerto UART conectado al MCP2200
   - `BufferSize`: Tamaño del buffer UART
   - `baud`: Velocidad de comunicación
   - `driver`: Nombre del driver (para callbacks)

3. **Singleton:** No usa macros .{name}. porque típicamente hay un solo MCP2200 por módulo.

**Uso desde API USB:**

```emic
// En USB_API.emic
EMIC:setInput(DEV:_drivers/USB/MCP2200/MCP2200.emic,
              port=1,
              BufferSize=512,
              baud=115200,
              driver=USB_Driver)

// Ahora puede usar funciones MCP2200 en USB_API.c
MCP2200_Send(data, length);
MCP2200_Receive(buffer, maxLength);
```

---

### 5.4 Ejemplo 4: LCDdriver (Display)

**Ubicación:** `_drivers/Display/`

**Propósito:** Driver para displays LCD controlados por SPI.

**Archivo: LCDdriver.emic**

```emic
EMIC:ifndef _LCDdriver_EMIC
EMIC:define(_LCDdriver_EMIC,true)

EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_hal/SPI/SPI.emic,port=.{port}.,configuracion=Master,pin=.{pin}.)

EMIC:copy(inc/LCDdriver.h > TARGET:inc/LCDdriver.h)
EMIC:copy(src/LCDdriver.c > TARGET:LCDdriver.c,port=.{port}.)

EMIC:define(c_modules.LCDdriver,LCDdriver)
/*==================[end of file]============================================*/
EMIC:endif
```

**Análisis:**

1. **Protocolo SPI:**
   ```emic
   EMIC:setInput(DEV:_hal/SPI/SPI.emic,port=.{port}.,configuracion=Master,pin=.{pin}.)
   ```
   - `port`: Puerto SPI
   - `configuracion=Master`: MCU es master, LCD es slave
   - `pin`: Pin CS (Chip Select)

2. **GPIO adicional:**
   Necesario para pines DC (Data/Command), RESET, etc.

3. **Singleton:** Típicamente un solo display por módulo.

**Características del código (src/LCDdriver.c):**

```c
// Funciones típicas de un LCD driver
void LCD_Init(void);
void LCD_Clear(void);
void LCD_SetPixel(uint8_t x, uint8_t y, bool color);
void LCD_WriteChar(char c);
void LCD_WriteString(const char* str);
void LCD_DrawLine(uint8_t x1, uint8_t y1, uint8_t x2, uint8_t y2);

// Funciones de bajo nivel (protocolo SPI)
static void LCD_WriteCommand(uint8_t cmd);
static void LCD_WriteData(uint8_t data);
static void LCD_Reset(void);
```

---

## 6. Dependencias de Drivers

### 6.1 Tipos de Dependencias

Un Driver típicamente depende de:

```
DRIVER
 ├── HAL              (periféricos del MCU)
 ├── _hard            (código específico de MCU)
 └── Otros Drivers    (menos común)
```

### 6.2 Ejemplo de Cadena de Dependencias

**Caso: Driver I2C**

```
API Sensor de Temperatura
    ↓
    └──> Driver I2C
            ↓
            ├──> HAL I2C
            │       ↓
            │       └──> _hard/PIC24/i2c_pic24.c
            │
            └──> HAL GPIO (para pines SDA/SCL)
                    ↓
                    └──> _hard/PIC24/gpio_pic24.c
```

**En código:**

```emic
// Temperatura API
EMIC:setInput(DEV:_drivers/I2C/I2C_driver.emic,port=1)

// I2C Driver
EMIC:setInput(DEV:_hal/I2C/I2C.emic,port=1)

// I2C HAL
EMIC:setInput(DEV:_hard/PIC24/i2c_pic24.emic)
```

### 6.3 Dependencias Comunes por Tipo

| Driver | Depende de HAL | Protocolo |
|--------|----------------|-----------|
| **SystemTimer** | Timer HAL | N/A (interno) |
| **I2C_driver** | I2C HAL, GPIO HAL | I2C master/slave |
| **MCP2200** | UART HAL, GPIO HAL | UART |
| **LCDdriver** | SPI HAL, GPIO HAL | SPI + comandos LCD |
| **DHT22** | GPIO HAL | OneWire (custom) |
| **RFM95 (LoRa)** | SPI HAL, GPIO HAL | SPI + LoRa protocol |

---

## 7. Integración con APIs

### 7.1 Flujo de Integración

```
┌────────────────────────────────────────────────────┐
│              INTEGRADOR                            │
│        (Usa API de alto nivel)                     │
└────────────────────────────────────────────────────┘
                      ↓
         USB_Send("Hello World");
                      ↓
┌────────────────────────────────────────────────────┐
│              API USB                               │
│  _api/Wired_Communication/USB/                     │
│                                                    │
│  Abstrae: "enviar datos por USB"                  │
└────────────────────────────────────────────────────┘
                      ↓
         EMIC:setInput(DEV:_drivers/USB/MCP2200/...)
                      ↓
┌────────────────────────────────────────────────────┐
│           DRIVER MCP2200                           │
│  _drivers/USB/MCP2200/                             │
│                                                    │
│  Implementa: protocolo específico del chip MCP2200 │
│  • Configuración del chip                         │
│  • Envío de comandos específicos                  │
│  • Manejo de buffer interno del chip              │
└────────────────────────────────────────────────────┘
                      ↓
         EMIC:setInput(DEV:_hal/UART/...)
                      ↓
┌────────────────────────────────────────────────────┐
│              HAL UART                              │
│  _hal/UART/                                        │
│                                                    │
│  Abstrae: periférico UART del MCU                 │
└────────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────────┐
│              HARDWARE                              │
│  Registros específicos del MCU                    │
└────────────────────────────────────────────────────┘
```

### 7.2 Ejemplo Completo: Sensor de Temperatura I2C

**Archivo: temperatura_api.emic** (API)

```emic
EMIC:tag(driverName = TEMPERATURA)

/**
* @fn float Temperatura_Read(void);
* @alias ReadTemp
* @brief Read temperature in Celsius
* @return Temperature in °C
*/

// Depende del driver I2C
EMIC:setInput(DEV:_drivers/I2C/I2C_driver.emic,port=1,frameID=0x48)

EMIC:copy(inc/temperatura_api.h > TARGET:inc/temperatura_api.h)
EMIC:copy(src/temperatura_api.c > TARGET:temperatura_api.c)
```

**Archivo: temperatura_api.c** (implementación)

```c
#include "temperatura_api.h"
#include "I2C1_driver.h"

#define TMP102_ADDRESS  0x48
#define TMP102_TEMP_REG 0x00

float Temperatura_Read(void) {
    uint8_t data[2];

    // Usar driver I2C para leer del chip TMP102
    I2C1_Write(TMP102_ADDRESS, &TMP102_TEMP_REG, 1);
    I2C1_Read(TMP102_ADDRESS, data, 2);

    // Convertir datos del TMP102 a temperatura
    int16_t rawTemp = (data[0] << 4) | (data[1] >> 4);
    if(rawTemp & 0x800) rawTemp |= 0xF000; // Signo extendido

    float tempC = rawTemp * 0.0625;
    return tempC;
}
```

**Uso desde integrador:**

```xml
<Init>
  <Variable name="temp" type="float"/>
</Init>

<Loop>
  <Call function="ReadTemp" result="temp"/>
  <Call function="LED_On" if="temp > 30"/>
</Loop>
```

---

## 8. Creación de Nuevos Drivers

### 8.1 Checklist de Creación

**PASO 1: Investigación del Chip**
- [ ] Leer datasheet completo
- [ ] Identificar protocolo de comunicación (I2C, SPI, UART, etc.)
- [ ] Listar comandos y registros
- [ ] Identificar dependencias de HAL necesarias

**PASO 2: Estructura de Carpetas**
```bash
mkdir -p _drivers/{Categoria}/{NombreChip}/inc
mkdir -p _drivers/{Categoria}/{NombreChip}/src
```

**PASO 3: Crear {NombreChip}.emic**
- [ ] Include guard (`EMIC:ifndef`)
- [ ] Declarar dependencias de HAL
- [ ] Definir comandos EMIC:copy
- [ ] Configurar c_modules

**PASO 4: Crear inc/{NombreChip}.h**
- [ ] Prototipos de funciones públicas
- [ ] Defines del protocolo/registros
- [ ] Structs de configuración

**PASO 5: Crear src/{NombreChip}.c**
- [ ] Implementación del protocolo
- [ ] Funciones de inicialización
- [ ] Funciones de lectura/escritura
- [ ] Manejo de errores

**PASO 6: Testing**
- [ ] Probar con hardware real
- [ ] Verificar protocolo con osciloscopio/analizador lógico
- [ ] Documentar limitaciones conocidas

---

### 8.2 Ejemplo: Creando Driver RFM95 (LoRa)

**Ubicación:** `_drivers/Wireless/RFM95/`

**1. RFM95.emic:**

```emic
EMIC:ifndef _RFM95_DRIVER_EMIC
EMIC:define(_RFM95_DRIVER_EMIC,true)

// Dependencias de HAL
EMIC:setInput(DEV:_hal/SPI/SPI.emic,port=.{spi_port}.,configuracion=Master,pin=.{cs_pin}.)
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)

// Copiar archivos
EMIC:copy(inc/rfm95.h > TARGET:inc/rfm95.h,
          spi_port=.{spi_port}.,
          cs_pin=.{cs_pin}.,
          reset_pin=.{reset_pin}.,
          dio0_pin=.{dio0_pin}.)

EMIC:copy(src/rfm95.c > TARGET:rfm95.c,
          spi_port=.{spi_port}.,
          cs_pin=.{cs_pin}.,
          reset_pin=.{reset_pin}.,
          dio0_pin=.{dio0_pin}.)

EMIC:define(c_modules.RFM95,RFM95)

EMIC:endif
```

**2. inc/rfm95.h:**

```c
#ifndef RFM95_H
#define RFM95_H

#include <stdint.h>
#include <stdbool.h>

// Registros del RFM95 (LoRa mode)
#define RFM95_REG_FIFO              0x00
#define RFM95_REG_OP_MODE           0x01
#define RFM95_REG_FR_MSB            0x06
#define RFM95_REG_FR_MID            0x07
#define RFM95_REG_FR_LSB            0x08
#define RFM95_REG_PA_CONFIG         0x09
#define RFM95_REG_FIFO_ADDR_PTR     0x0D
#define RFM95_REG_FIFO_TX_BASE      0x0E
#define RFM95_REG_FIFO_RX_BASE      0x0F
#define RFM95_REG_IRQ_FLAGS         0x12
#define RFM95_REG_RX_NB_BYTES       0x13
#define RFM95_REG_PKT_SNR_VALUE     0x19
#define RFM95_REG_PKT_RSSI_VALUE    0x1A
#define RFM95_REG_MODEM_CONFIG_1    0x1D
#define RFM95_REG_MODEM_CONFIG_2    0x1E
#define RFM95_REG_PAYLOAD_LENGTH    0x22
#define RFM95_REG_DIO_MAPPING_1     0x40
#define RFM95_REG_VERSION           0x42

// Modos de operación
#define RFM95_MODE_SLEEP            0x00
#define RFM95_MODE_STANDBY          0x01
#define RFM95_MODE_TX               0x03
#define RFM95_MODE_RX_CONTINUOUS    0x05
#define RFM95_MODE_RX_SINGLE        0x06

// Configuración
typedef struct {
    uint32_t frequency;      // Frecuencia en Hz (ej: 915000000 para 915MHz)
    uint8_t txPower;         // Potencia TX (2-20 dBm)
    uint8_t spreadingFactor; // SF7-SF12
    uint32_t bandwidth;      // 125000, 250000, 500000 Hz
    uint8_t codingRate;      // 5-8 (CR 4/5 a 4/8)
} RFM95_Config_t;

// Funciones públicas
bool RFM95_Init(const RFM95_Config_t* config);
bool RFM95_Send(const uint8_t* data, uint8_t length);
int16_t RFM95_Receive(uint8_t* buffer, uint8_t maxLength);
int16_t RFM95_GetRSSI(void);
int8_t RFM95_GetSNR(void);
void RFM95_Sleep(void);
void RFM95_Standby(void);

#endif
```

**3. src/rfm95.c:**

```c
#include "rfm95.h"
#include "SPI.{spi_port}..h"
#include "gpio.h"

// Pines de configuración (macros reemplazadas)
#define RFM95_CS_PIN    .{cs_pin}.
#define RFM95_RESET_PIN .{reset_pin}.
#define RFM95_DIO0_PIN  .{dio0_pin}.

// Funciones privadas
static void RFM95_WriteRegister(uint8_t reg, uint8_t value);
static uint8_t RFM95_ReadRegister(uint8_t reg);
static void RFM95_SetMode(uint8_t mode);
static void RFM95_Reset(void);

bool RFM95_Init(const RFM95_Config_t* config) {
    // Reset del chip
    RFM95_Reset();

    // Verificar versión del chip
    uint8_t version = RFM95_ReadRegister(RFM95_REG_VERSION);
    if(version != 0x12) return false; // RFM95 = 0x12

    // Modo sleep para configuración
    RFM95_SetMode(RFM95_MODE_SLEEP);

    // Configurar modo LoRa (vs FSK)
    RFM95_WriteRegister(RFM95_REG_OP_MODE, 0x80); // LoRa mode

    // Configurar frecuencia
    uint64_t frf = ((uint64_t)config->frequency << 19) / 32000000;
    RFM95_WriteRegister(RFM95_REG_FR_MSB, (uint8_t)(frf >> 16));
    RFM95_WriteRegister(RFM95_REG_FR_MID, (uint8_t)(frf >> 8));
    RFM95_WriteRegister(RFM95_REG_FR_LSB, (uint8_t)(frf >> 0));

    // Configurar potencia TX
    RFM95_WriteRegister(RFM95_REG_PA_CONFIG, 0x80 | (config->txPower - 2));

    // Configurar spreading factor, bandwidth, coding rate
    uint8_t bw = (config->bandwidth == 125000) ? 0x70 :
                 (config->bandwidth == 250000) ? 0x80 : 0x90;
    uint8_t cr = (config->codingRate - 5) << 1;
    RFM95_WriteRegister(RFM95_REG_MODEM_CONFIG_1, bw | cr | 0x00); // Implicit header off

    uint8_t sf = config->spreadingFactor << 4;
    RFM95_WriteRegister(RFM95_REG_MODEM_CONFIG_2, sf | 0x04); // CRC on

    // FIFO base addresses
    RFM95_WriteRegister(RFM95_REG_FIFO_TX_BASE, 0x00);
    RFM95_WriteRegister(RFM95_REG_FIFO_RX_BASE, 0x00);

    // Modo standby
    RFM95_SetMode(RFM95_MODE_STANDBY);

    return true;
}

bool RFM95_Send(const uint8_t* data, uint8_t length) {
    if(length > 255) return false;

    // Standby mode
    RFM95_SetMode(RFM95_MODE_STANDBY);

    // Set FIFO pointer
    RFM95_WriteRegister(RFM95_REG_FIFO_ADDR_PTR, 0x00);

    // Write payload
    for(uint8_t i = 0; i < length; i++) {
        RFM95_WriteRegister(RFM95_REG_FIFO, data[i]);
    }

    // Set payload length
    RFM95_WriteRegister(RFM95_REG_PAYLOAD_LENGTH, length);

    // TX mode
    RFM95_SetMode(RFM95_MODE_TX);

    // Wait for TX done (polling DIO0)
    while(GPIO_Read(RFM95_DIO0_PIN) == 0);

    // Clear IRQ flags
    RFM95_WriteRegister(RFM95_REG_IRQ_FLAGS, 0xFF);

    return true;
}

// ... (más funciones)

static void RFM95_WriteRegister(uint8_t reg, uint8_t value) {
    GPIO_Write(RFM95_CS_PIN, 0); // CS low
    SPI.{spi_port}._Transfer(reg | 0x80); // Write bit
    SPI.{spi_port}._Transfer(value);
    GPIO_Write(RFM95_CS_PIN, 1); // CS high
}

static uint8_t RFM95_ReadRegister(uint8_t reg) {
    GPIO_Write(RFM95_CS_PIN, 0); // CS low
    SPI.{spi_port}._Transfer(reg & 0x7F); // Read bit
    uint8_t value = SPI.{spi_port}._Transfer(0x00);
    GPIO_Write(RFM95_CS_PIN, 1); // CS high
    return value;
}

static void RFM95_Reset(void) {
    GPIO_Write(RFM95_RESET_PIN, 0);
    __delay_ms(10);
    GPIO_Write(RFM95_RESET_PIN, 1);
    __delay_ms(10);
}

static void RFM95_SetMode(uint8_t mode) {
    RFM95_WriteRegister(RFM95_REG_OP_MODE, 0x80 | mode);
}
```

**4. Uso desde API LoRa:**

```emic
// En lora_api.emic
EMIC:setInput(DEV:_drivers/Wireless/RFM95/RFM95.emic,
              spi_port=1,
              cs_pin=LORA_CS,
              reset_pin=LORA_RST,
              dio0_pin=LORA_DIO0)
```

---

## 🎯 Puntos Clave del Capítulo

| Concepto | Explicación |
|----------|-------------|
| **Driver EMIC** | Biblioteca de bajo nivel para hardware específico |
| **Driver vs API** | Driver = específico del chip, API = genérico |
| **Estructura** | {DriverName}.emic + inc/ + src/ |
| **7 categorías** | ADC, Amp, Display, I2C, RAM, SystemTimer, USB |
| **Dependencias** | HAL + _hard (NO otros drivers típicamente) |
| **Sin tags DOXYGEN** | Drivers no publican para integradores (solo para APIs) |
| **Protocolo** | Implementa comunicación con el chip específico |

---

## 📊 Resumen Visual

```
┌────────────────────────────────────────────────────┐
│              DRIVER EMIC                           │
│    _drivers/{Category}/{DriverName}/               │
└────────────────────────────────────────────────────┘
            │
     ┌──────┴──────┬──────────────┐
     │             │              │
{DriverName}.emic  inc/*.h      src/*.c
     │             │              │
     │             │              │
Dependencias   Defines del    Protocolo del
de HAL         chip/registros  chip específico
Include guard  Funciones       Lectura/escritura
               públicas        registros
```

---

## ✅ Checklist de Comprensión

Antes de continuar al Capítulo 09, asegúrate de entender:

- [ ] Qué es un Driver en EMIC (control de hardware específico)
- [ ] La diferencia fundamental entre Driver y API
- [ ] La estructura de un Driver ({DriverName}.emic + inc/ + src/)
- [ ] Las 7 categorías de Drivers disponibles
- [ ] Por qué drivers NO usan tags DOXYGEN (no para integradores)
- [ ] Cómo los Drivers dependen de HAL
- [ ] La integración Driver → API → Integrador
- [ ] Cómo crear un driver para un chip nuevo (ej: RFM95)

---

## 🎓 Ejercicio Práctico

**Exploración del SDK Real:**

```powershell
# Navega a _drivers/
cd C:\Users\franc\Dropbox\...\EMIC_IA_M\_drivers\

# Lista todas las categorías
ls

# Explora el driver SystemTimer
cd SystemTimer\
cat systemTimer.emic
cat inc\systemTimer.h

# Explora el driver I2C
cd ..\I2C\
cat I2C_driver.emic

# Cuenta las dependencias de HAL
Select-String "setInput.*_hal" I2C_driver.emic
```

**Pregunta de reflexión:**
¿Por qué el driver MCP2200 (USB) depende de UART HAL y no de USB HAL?

<details>
<summary>Ver respuesta</summary>

**Respuesta:**
Porque el chip **MCP2200** es un **conversor UART-to-USB**. Desde el punto de vista del MCU:
- El MCU se comunica con el MCP2200 por **UART** (no USB directo)
- El MCP2200 se encarga de convertir UART → USB hacia el PC

Por lo tanto:
- **Driver MCP2200** depende de **UART HAL** (comunicación MCU ↔ MCP2200)
- El **USB** es transparente para el MCU (lo maneja el chip)

Si el MCU tuviera USB nativo (como PIC32 con USB OTG), entonces existiría un **USB HAL** y drivers USB que lo usarían.

</details>

---

[← Anterior: Carpeta _api](07_Carpeta_API.md) | [Siguiente: Carpeta _hal →](09_Carpeta_HAL.md)

---

**Progreso del Manual:**

```
Sección 1 (Introducción): ████████████████████ 100% (5/5)
Sección 2 (Estructura):   ████████░░░░░░░░░░░░  36% (4/11)
```

**Progreso Total:** 23.68% (9/38 capítulos)

---

*Capítulo 08 - Manual de Desarrollo EMIC SDK v1.0*
*Última actualización: Noviembre 2025*
