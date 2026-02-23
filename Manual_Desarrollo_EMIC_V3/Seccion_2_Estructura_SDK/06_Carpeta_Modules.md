# Capítulo 06: Carpeta `_modules/` - Módulos Hardware + Firmware

[← Anterior: Visión General SDK](05_Vision_General_SDK.md) | [Siguiente: Carpeta _api →](07_Carpeta_API.md)

---

## 📋 Contenido del Capítulo

1. [¿Qué es un Módulo EMIC?](#1-qué-es-un-módulo-emic)
2. [Estructura de la Carpeta _modules/](#2-estructura-de-la-carpeta-_modules)
3. [Categorías de Módulos](#3-categorías-de-módulos)
4. [Archivos Clave de un Módulo](#4-archivos-clave-de-un-módulo)
5. [Ejemplos Reales del SDK](#5-ejemplos-reales-del-sdk)
6. [Flujo de Vida de un Módulo](#6-flujo-de-vida-de-un-módulo)
7. [Creación de Nuevos Módulos](#7-creación-de-nuevos-módulos)
8. [Buenas Prácticas](#8-buenas-prácticas)

---

## 1. ¿Qué es un Módulo EMIC?

### 1.1 Definición Conceptual

Un **Módulo EMIC** es una **unidad funcional completa** que representa un sistema embebido del mundo real, combinando:

```
┌────────────────────────────────────────────────────┐
│               MÓDULO EMIC                          │
│   Unidad Funcional Completa del Mundo Real        │
└────────────────────────────────────────────────────┘
           │
    ┌──────┴──────┬────────────┬──────────────┐
    │             │            │              │
 HARDWARE    FIRMWARE    CONFIGURACIÓN    LÓGICA
    │             │            │              │
    │             │            │              │
 PCB + MCU    APIs +      config.json    program.xml
             Drivers      module.json    (Integrador)
```

### 1.2 Fórmula del Módulo

```
MÓDULO EMIC = Hardware + Firmware + Configuración + Lógica de Aplicación
```

Donde:
- **Hardware**: PCB con microcontrolador y periféricos
- **Firmware**: APIs y Drivers necesarios (reutilizables)
- **Configuración**: Parámetros dinámicos (config.json, module.json)
- **Lógica**: Código del integrador (program.xml)

### 1.3 Módulo vs Proyecto vs API

| Concepto | Definición | Ejemplo |
|----------|------------|---------|
| **Módulo** | Hardware + Firmware completo | `_modules/Wireless_Communication/HRD_WiFi/` |
| **Proyecto** | Instancia de módulo configurada | `USER:/My Projects/Logger_IoT/` |
| **API** | Biblioteca reutilizable | `_api/Timers/timer_api.emic` |

> **📌 Diferencia clave:** Un **Módulo** ES el hardware físico + firmware. Un **Proyecto** USA un módulo configurado para un caso específico.

---

## 2. Estructura de la Carpeta _modules/

### 2.1 Árbol Completo

```
_modules/                              ← Raíz de módulos
│
└── {Category}/                        ← Categoría (ej: Wireless_Communication)
    └── {ModuleName}/                  ← Nombre del módulo (ej: HRD_WiFi)
        │
        ├── m_description.json         ⭐ Descripción del hardware
        │
        ├── System/                    ⭐ Sistema de configuración
        │   ├── generate.emic          ← Script de generación (EMIC-Generate)
        │   ├── deploy.emic            ← Script de deployment (opcional)
        │   ├── config.json            ← Configuración dinámica
        │   ├── module.json            ← Metadata del módulo
        │   ├── program.xml            ← Código visual (EMIC-Editor)
        │   ├── userFncFile.c          ← Código C del integrador
        │   ├── inc/                   ← Headers del integrador
        │   └── EMIC-TABS/             ← Recursos publicados
        │       ├── Resources/         ← Recursos del driver
        │       └── Data/              ← Variables del usuario
        │
        └── Target/                    ⭐ Código generado (OUTPUT)
            ├── main.c                 ← Main generado
            ├── system.c / system.h    ← Inicialización
            ├── user.c / user.h        ← Código del usuario
            └── [otros archivos .c/.h] ← Código de APIs/Drivers
```

### 2.2 Responsabilidad de Cada Carpeta

| Carpeta/Archivo | Propósito | Modificable por Usuario | Regenerado |
|-----------------|-----------|-------------------------|------------|
| **m_description.json** | Documentación del hardware | ❌ No (Desarrollador) | ❌ No |
| **System/** | Configuración y scripts | ✅ Sí (Integrador) | ❌ No |
| **System/generate.emic** | Script maestro de generación | ❌ No (Desarrollador) | ❌ No |
| **System/program.xml** | Lógica del integrador | ✅ Sí (Integrador) | ❌ No |
| **System/config.json** | Parámetros configurables | ✅ Sí (Integrador) | ❌ No |
| **System/userFncFile.c** | Funciones C personalizadas | ✅ Sí (Integrador) | ❌ No |
| **Target/** | Código C compilable | ❌ No (AUTO) | ✅ Sí (cada Generate) |

---

## 3. Categorías de Módulos

### 3.1 Listado Completo del SDK Real

Según el SDK en `EMIC_IA_M\_modules\`, existen las siguientes categorías:

| # | Categoría | Descripción | Ejemplos |
|---|-----------|-------------|----------|
| 1 | **Actuators** | Motores, relés, solenoides | Stepper motors, relays |
| 2 | **Custom** | Módulos personalizados | Soluciones específicas |
| 3 | **Development_Board** | Placas de desarrollo | Development_Board |
| 4 | **Digital_In_Out** | Entradas/salidas digitales | GPIO expanders |
| 5 | **Displays_seven_segments** | Displays 7 segmentos | TM1637, MAX7219 |
| 6 | **Graphic_Displays** | LCDs gráficos, OLEDs | SSD1306, ST7735 |
| 7 | **Indoor_Crops** | Agricultura indoor (IoT) | Sensors + actuators |
| 8 | **Lavarropas** | Control de lavadoras | Motor control, temp |
| 9 | **Oil_and_Gas** | Industria petróleo/gas | Pressure, flow sensors |
| 10 | **Power_Supply** | Fuentes de alimentación | DC-DC converters |
| 11 | **Sensors** | Sensores diversos | Temperature, humidity |
| 12 | **Storage** | Almacenamiento | EEPROM, SD cards |
| 13 | **Tecnocrom_Controller** | Controlador industrial | PLC-like systems |
| 14 | **Testing** | Módulos de prueba | Test benches |
| 15 | **TestModule** | Módulo de ejemplo | Educational module |
| 16 | **Wired_Communication** | Comunicación cableada | UART, I2C, SPI, RS485 |
| 17 | **Wired_Control** | Control por cable | Wired remote controls |
| 18 | **Wireless_Communication** | Comunicación inalámbrica | WiFi, LoRa, BLE, Zigbee |

### 3.2 Distribución por Tipo

```
┌─────────────────────────────────────────────────────┐
│         MÓDULOS POR TIPO DE FUNCIÓN                 │
└─────────────────────────────────────────────────────┘

  🔌 COMUNICACIÓN (22%)
      ├── Wireless_Communication (5 módulos)
      └── Wired_Communication

  📊 SENSORES + ACTUADORES (22%)
      ├── Sensors (2 módulos)
      ├── Actuators
      └── Indoor_Crops

  🖥️ INTERFACES VISUALES (11%)
      ├── Graphic_Displays
      └── Displays_seven_segments

  🏭 INDUSTRIA ESPECÍFICA (17%)
      ├── Oil_and_Gas
      ├── Lavarropas
      └── Tecnocrom_Controller

  🔧 DESARROLLO + TESTING (17%)
      ├── Development_Board
      ├── Testing
      └── TestModule

  ⚡ OTROS (11%)
      ├── Power_Supply
      ├── Storage
      ├── Digital_In_Out
      └── Custom
```

---

## 4. Archivos Clave de un Módulo

### 4.1 `m_description.json` - Descripción del Hardware

**Propósito:** Documentar las características físicas y eléctricas del módulo.

**Ejemplo real del SDK** (`Development_Board/Development_Board/m_description.json`):

```json
{
  "type": "gcc",
  "toolTip": "Development Board",
  "description": "Board designed for tests and Development of new products",
  "Sizes": "7x2cm",
  "ImageFile": "blz1.gif",
  "IconFile": "TBD",
  "Mounting": "Holder Riel DIN",
  "Table": [
    {
      "Name": "VccMax",
      "Value": "5.5V"
    },
    {
      "Name": "VccMin",
      "Value": "4.8V"
    },
    {
      "Name": "IccMax",
      "Value": "50mA"
    }
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
    },
    {
      "PinName": "J2",
      "PinType": "USB",
      "PinDescription": "Connector Mini USB Type B Female Port 5-Pin"
    },
    {
      "PinName": "RX",
      "PinType": "Led",
      "PinDescription": "Reception indicator led"
    },
    {
      "PinName": "TX",
      "PinType": "Led",
      "PinDescription": "Transmission indicator led"
    }
  ],
  "Simulation": "DRN1285.dll",
  "features": [
    "Emic bus compatible.",
    "Size:7x2cm",
    "Mounting type Holder Riel DIN.",
    "Temperature range -25°C a 80°C."
  ],
  "applications": [
    "Data logger.",
    "IoT.",
    "Debugging.",
    "Power Supply."
  ],
  "keyWord": [
    "development",
    "testing",
    "prototyping"
  ]
}
```

**Estructura de m_description.json:**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `type` | string | Tipo de compilador ("gcc", "xc8", "xc16", "xc32") |
| `toolTip` | string | Nombre corto para UI |
| `description` | string | Descripción larga del módulo |
| `Sizes` | string | Dimensiones físicas |
| `ImageFile` | string | Imagen del hardware (PNG/GIF) |
| `IconFile` | string | Icono para UI |
| `Mounting` | string | Tipo de montaje |
| `Table` | array | Especificaciones eléctricas (Vcc, Icc, etc.) |
| `HardwareDescription` | array | Descripción de pines y conectores |
| `Simulation` | string | DLL de simulación (opcional) |
| `features` | array | Características principales |
| `applications` | array | Aplicaciones típicas |
| `keyWord` | array | Palabras clave para búsqueda |

---

### 4.2 `System/generate.emic` - Script de Generación

**Propósito:** Script maestro que invoca todas las APIs y Drivers necesarios para generar el código C compilable.

**Ejemplo real** (`Development_Board/Development_Board/System/generate.emic`):

```emic
EMIC:setOutput(TARGET:generate.txt)

    //-------------- Hardware Config ---------------------
    EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_Development_Board)

    //------------------- Process EMIC-Generate files result ----------------
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    //------------------- APIs -----------------------

    //Leds
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led1,pin=A2_Pin)
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led4,pin=A1_Pin)
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led5,pin=A0_Pin)

    //Timers
    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)
    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=2)
    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=3)

    //USB
    //EMIC:setInput(DEV:_api/Wired_Communication/USB/USB_API.emic,
    //              driver=MCP2200,port=1,BufferSize=512,baud=9600,
    //              frameLf=\n,name=MCP2200)

    //LCD
    EMIC:setInput(DEV:_api/Lavarropas/LCD/LCD_Api.emic)

    //Selectors
    EMIC:setInput(DEV:_api/Lavarropas/Selector/buttons_api.emic,
                  group1_pin=Buttons1,group2_pin=Buttons2,
                  rotary_pin=RotarySW)

    //Controlador de triac
    EMIC:setInput(DEV:_api/Lavarropas/Motor/TriacControl/triac_control.emic,
                  name=MOTOR,pin=TRIAC_GATE,timer_delay=2,timer_pulse=5)

    //Temp Sensor
    EMIC:setInput(DEV:_api/Lavarropas/Temperatura/temp_sensor.emic,
                  temp_pin=NTC_PIN)

    //------------ System Includes --------------
    EMIC:setInput(DEV:_system/system.c)
    EMIC:setInput(DEV:_system/system.h)

    //------------ Main File --------------------
    EMIC:setInput(DEV:_main/main.c)
```

**Estructura del generate.emic:**

1. **Salida**: Define archivo de salida (`TARGET:generate.txt`)
2. **Hardware**: Configura PCB (`_pcb/pcb.emic`)
3. **System files**: Procesa funciones y eventos usados
4. **APIs**: Invoca APIs necesarias con parámetros
5. **System includes**: Incluye archivos del sistema
6. **Main**: Incluye el main.c

**Parámetros en setInput:**

```emic
EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)
              └───┬───┘ └────────┬────────────┘ └──┬──┘
                  │              │                  │
            Volumen lógico   Ruta relativa    Parámetros
```

---

### 4.3 `System/config.json` - Configuración Dinámica

**Propósito:** Parámetros configurables por el integrador (sin modificar generate.emic).

**Ejemplo típico:**

```json
{
  "mcuFamily": "PIC24FJ64GA002",
  "clockFrequency": "32000000",
  "oscillatorType": "FRC_PLL",
  "wifi": {
    "enabled": true,
    "ssid": "${WIFI_SSID}",
    "password": "${WIFI_PASSWORD}",
    "staticIP": false
  },
  "uart": {
    "baudRate": 115200,
    "dataBufferSize": 512
  },
  "debug": {
    "enabled": true,
    "logLevel": "INFO"
  }
}
```

**Uso:** El integrador modifica estos parámetros sin tocar el código.

---

### 4.4 `System/module.json` - Metadata del Módulo

**Propósito:** Información del módulo para el sistema EMIC.

**Ejemplo:**

```json
{
  "name": "HRD_WiFi",
  "version": "1.2.0",
  "author": "EMIC Electronics",
  "category": "Wireless_Communication",
  "mcu": "PIC24FJ64GA002",
  "compiler": "xc16",
  "dependencies": [
    "_api/Wireless/WiFi_ESP8266",
    "_api/Timers/timer_api",
    "_api/Indicators/LEDs/led"
  ],
  "compatiblePCBs": [
    "HRD_WiFi_V1.0",
    "HRD_WiFi_V1.1"
  ]
}
```

---

### 4.5 `System/program.xml` - Código Visual (EMIC-Editor)

**Propósito:** Código de alto nivel creado por el integrador en el EMIC-Editor.

**Ejemplo simplificado:**

```xml
<?xml version="1.0"?>
<Program>
  <Init>
    <Call function="LED_Init" params="led1"/>
    <Call function="WiFi_Init"/>
    <Call function="Timer_Start" params="1,1000"/>
  </Init>

  <Event name="Timer1_Interrupt">
    <Call function="LED_Toggle" params="led1"/>
    <Call function="WiFi_SendData" params="status"/>
  </Event>

  <Loop>
    <Call function="WiFi_CheckConnection"/>
    <Delay ms="100"/>
  </Loop>
</Program>
```

Este XML se convierte en código C durante EMIC-Generate.

---

### 4.6 `System/userFncFile.c` - Código C del Integrador

**Propósito:** Funciones C personalizadas que el integrador puede escribir directamente.

**Ejemplo:**

```c
#include "userFncFile.h"

// Función personalizada del integrador
float calculateAverage(float* data, int count) {
    float sum = 0.0;
    for(int i = 0; i < count; i++) {
        sum += data[i];
    }
    return sum / count;
}

// Callback personalizado
void onWiFiConnected(void) {
    LED_On(led1);
    // Lógica adicional
}

// Estado de la aplicación
typedef struct {
    bool wifiConnected;
    float temperature;
    int errorCount;
} AppState_t;

AppState_t appState = {
    .wifiConnected = false,
    .temperature = 0.0,
    .errorCount = 0
};
```

---

### 4.7 `Target/` - Código Generado (OUTPUT)

**Propósito:** Contiene el código C compilable generado por EMIC-Generate.

**Contenido típico:**

```
Target/
├── main.c                    ← Main generado
├── system.c / system.h       ← Inicialización del sistema
├── user.c / user.h           ← Código del usuario (de program.xml)
├── led_api.c / led_api.h     ← API de LEDs (copiado de _api/)
├── timer_api.c / timer_api.h ← API de Timers
├── wifi_driver.c / .h        ← Driver WiFi (copiado de _drivers/)
├── hal_uart.c / .h           ← HAL UART (copiado de _hal/)
└── pic24_init.c / .h         ← Código específico PIC24 (_hard/)
```

> **⚠️ IMPORTANTE:** El contenido de `Target/` se **SOBREESCRIBE** cada vez que ejecutas EMIC-Generate. **NO modifiques archivos aquí**.

---

## 5. Ejemplos Reales del SDK

### 5.1 Ejemplo 1: Development_Board

**Ubicación:** `_modules/Development_Board/Development_Board/`

**Propósito:** Placa de desarrollo multiuso para pruebas y prototipos.

**Hardware incluido:**
- Microcontrolador PIC24FJ64GA002
- 3 LEDs (RX, TX, General)
- Conector USB Mini-B
- 2 Conectores I2C (EMIC Bus)
- Montaje en riel DIN

**APIs utilizadas:**
- `_api/Indicators/LEDs/` (3 instancias)
- `_api/Timers/timer_api` (3 timers)
- `_api/Lavarropas/LCD/` (opcional)
- `_api/Lavarropas/Selector/` (botones y encoder)
- `_api/Lavarropas/Motor/` (control de triac)
- `_api/Lavarropas/Temperatura/` (sensor NTC)

**Casos de uso:**
- Data logger IoT
- Debugging de nuevos módulos
- Fuente de alimentación para EMIC Bus
- Prototipado rápido

---

### 5.2 Ejemplo 2: HRD_WiFi

**Ubicación:** `_modules/Wireless_Communication/HRD_WiFi/`

**Propósito:** Módulo WiFi para conectividad IoT.

**Hardware incluido:**
- Microcontrolador PIC24 o PIC18
- Módulo WiFi ESP8266 o ESP32
- LEDs indicadores (WiFi status, data)
- Antena externa o PCB

**APIs utilizadas (estimado):**
- `_api/Wireless/WiFi_ESP8266/`
- `_api/Timers/timer_api`
- `_api/Indicators/LEDs/`
- `_api/Wired_Communication/UART/` (para comunicación con ESP)
- `_api/Storage/` (para guardar config WiFi)

**Casos de uso:**
- Monitoreo remoto de sensores
- Control IoT
- Gateway WiFi a Ethernet
- Logger con upload a la nube

---

### 5.3 Ejemplo 3: TemperatureMonitor

**Ubicación:** `_modules/Sensors/TemperatureMonitor/`

**Propósito:** Monitor de temperatura con alarmas.

**Hardware incluido (estimado):**
- Sensor de temperatura (DS18B20, DHT22, o NTC)
- LED indicador
- Buzzer para alarma
- Salida digital para relé

**APIs utilizadas (estimado):**
- `_api/Sensors/Temperature/`
- `_api/Alarm/alarm_api`
- `_api/Indicators/LEDs/`
- `_api/Actuators/Relay/`
- `_api/Timers/timer_api`

**Casos de uso:**
- Control de temperatura industrial
- Alarma de sobretemperatura
- Data logger de temperatura
- HVAC control

---

## 6. Flujo de Vida de un Módulo

### 6.1 Ciclo Completo

```
┌────────────────────────────────────────────────────────┐
│        FLUJO DE VIDA DE UN MÓDULO EMIC                 │
└────────────────────────────────────────────────────────┘

  FASE 1: CREACIÓN DEL MÓDULO (Desarrollador)
  ┌──────────────────────────────────────────┐
  │ 1. Diseñar hardware (PCB + componentes)  │
  │ 2. Crear carpeta en _modules/{Cat}/{Mod}/│
  │ 3. Escribir m_description.json           │
  │ 4. Escribir generate.emic                │
  │ 5. Crear deploy.emic (opcional)          │
  │ 6. Definir config.json y module.json     │
  │ 7. Documentar en README.md               │
  └──────────────────────────────────────────┘
            ↓
  FASE 2: DISCOVERY (Automático)
  ┌──────────────────────────────────────────┐
  │ 1. Sistema lee generate.emic             │
  │ 2. Extrae recursos publicados (tags)     │
  │ 3. Indexa APIs y Drivers disponibles     │
  │ 4. Publica en EMIC-Editor                │
  └──────────────────────────────────────────┘
            ↓
  FASE 3: INTEGRACIÓN (Integrador)
  ┌──────────────────────────────────────────┐
  │ 1. Selecciona módulo en EMIC-Editor      │
  │ 2. Configura parámetros (config.json)    │
  │ 3. Escribe lógica (program.xml)          │
  │ 4. Añade funciones C (userFncFile.c)     │
  └──────────────────────────────────────────┘
            ↓
  FASE 4: GENERACIÓN (Automático)
  ┌──────────────────────────────────────────┐
  │ 1. EMIC-Generate interpreta generate.emic│
  │ 2. Copia APIs y Drivers a Target/        │
  │ 3. Fusiona program.xml con APIs          │
  │ 4. Genera main.c, system.c, user.c       │
  └──────────────────────────────────────────┘
            ↓
  FASE 5: COMPILACIÓN (XC Compiler)
  ┌──────────────────────────────────────────┐
  │ 1. Compila Target/ con XC8/XC16/XC32     │
  │ 2. Genera firmware.hex                   │
  │ 3. Reporta errores/warnings              │
  └──────────────────────────────────────────┘
            ↓
  FASE 6: DEPLOYMENT (PICkit/ICD/Bootloader)
  ┌──────────────────────────────────────────┐
  │ 1. Graba firmware.hex al MCU             │
  │ 2. Ejecuta deploy.emic si existe         │
  │ 3. Verifica funcionamiento               │
  └──────────────────────────────────────────┘
```

### 6.2 Interacción entre Roles

```
DESARROLLADOR                    INTEGRADOR
     │                               │
     │ 1. Crea módulo                │
     │    (_modules/...)             │
     │                               │
     ├──────────────────────────────>│
     │    Publica módulo             │
     │                               │
     │                          2. Usa módulo
     │                             (config.json)
     │                               │
     │<──────────────────────────────┤
     │     Feedback (bugs)           │
     │                               │
     │ 3. Corrige y actualiza        │
     │    (nueva versión)            │
     │                               │
     ├──────────────────────────────>│
     │    Nueva versión              │
     │                               │
```

---

## 7. Creación de Nuevos Módulos

### 7.1 Checklist de Creación

Para crear un módulo nuevo, sigue estos pasos:

**PASO 1: Planificación**
- [ ] Definir nombre del módulo (ej: "HRD_LoRa_Gateway")
- [ ] Elegir categoría (ej: "Wireless_Communication")
- [ ] Listar hardware necesario (MCU, periféricos, componentes)
- [ ] Identificar APIs y Drivers necesarios

**PASO 2: Estructura de Carpetas**
```bash
# Crear carpeta del módulo
mkdir -p _modules/{Categoria}/{NombreModulo}/System
mkdir -p _modules/{Categoria}/{NombreModulo}/Target
```

**PASO 3: Archivos Obligatorios**
- [ ] Crear `m_description.json` (documentación hardware)
- [ ] Crear `System/generate.emic` (script de generación)
- [ ] Crear `System/config.json` (configuración)
- [ ] Crear `System/module.json` (metadata)
- [ ] Crear `README.md` (instrucciones de uso)

**PASO 4: generate.emic**
- [ ] Configurar salida (`EMIC:setOutput(TARGET:generate.txt)`)
- [ ] Configurar PCB (`EMIC:setInput(DEV:_pcb/...)`)
- [ ] Invocar APIs necesarias
- [ ] Invocar Drivers necesarios
- [ ] Incluir system files
- [ ] Incluir main.c

**PASO 5: Testing**
- [ ] Ejecutar EMIC-Discovery
- [ ] Verificar recursos publicados
- [ ] Crear proyecto de prueba
- [ ] Ejecutar EMIC-Generate
- [ ] Compilar con XC
- [ ] Probar en hardware real

**PASO 6: Documentación**
- [ ] Completar m_description.json con todos los campos
- [ ] Escribir README.md detallado
- [ ] Incluir ejemplos de uso
- [ ] Documentar parámetros de config.json

---

### 7.2 Ejemplo: Creando "HRD_LoRa_Node"

**Ubicación:** `_modules/Wireless_Communication/HRD_LoRa_Node/`

**1. m_description.json:**
```json
{
  "type": "xc16",
  "toolTip": "LoRa Communication Node",
  "description": "Long-range wireless module using LoRa RFM95/96",
  "Sizes": "5x3cm",
  "ImageFile": "lora_node.png",
  "Mounting": "PCB mount",
  "Table": [
    { "Name": "VccMax", "Value": "3.6V" },
    { "Name": "VccMin", "Value": "1.8V" },
    { "Name": "RangeMax", "Value": "15km" }
  ],
  "HardwareDescription": [
    {
      "PinName": "MOSI",
      "PinType": "SPI",
      "PinDescription": "SPI MOSI to RFM95"
    },
    {
      "PinName": "DIO0",
      "PinType": "GPIO",
      "PinDescription": "LoRa interrupt pin"
    }
  ],
  "features": [
    "LoRa modulation (SF7-SF12)",
    "Long range: up to 15km",
    "Low power consumption",
    "SPI interface"
  ],
  "applications": [
    "Remote sensors",
    "Agricultural IoT",
    "Smart cities",
    "Asset tracking"
  ],
  "keyWord": ["lora", "lpwan", "wireless", "long-range"]
}
```

**2. System/generate.emic:**
```emic
EMIC:setOutput(TARGET:generate.txt)

    // Hardware Config
    EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_LoRa_Node_V1)

    // APIs
    EMIC:setInput(DEV:_api/Wireless/LoRa/lora_api.emic,name=lora1,
                  frequency=915000000,bandwidth=125000,spreading_factor=7)
    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=status_led,
                  pin=LED_PIN)

    // Drivers
    EMIC:setInput(DEV:_drivers/Wireless/RFM95/rfm95_driver.emic,
                  spi_port=1,cs_pin=LORA_CS,reset_pin=LORA_RST,
                  dio0_pin=LORA_DIO0)

    // System
    EMIC:setInput(DEV:_system/system.c)
    EMIC:setInput(DEV:_system/system.h)

    // Main
    EMIC:setInput(DEV:_main/main.c)
```

**3. System/config.json:**
```json
{
  "lora": {
    "frequency": 915000000,
    "bandwidth": 125000,
    "spreadingFactor": 7,
    "codingRate": "4/5",
    "txPower": 14
  },
  "network": {
    "nodeID": "${NODE_ID}",
    "networkKey": "${NETWORK_KEY}"
  },
  "power": {
    "sleepMode": true,
    "wakeupInterval": 60
  }
}
```

---

### 7.3 Creación de Nueva Categoría

Si necesitas una categoría que no existe:

**Ejemplo: Crear "Medical_Devices"**

```bash
# 1. Crear carpeta de categoría
mkdir _modules/Medical_Devices

# 2. Crear primer módulo
mkdir -p _modules/Medical_Devices/ECG_Monitor/System
mkdir -p _modules/Medical_Devices/ECG_Monitor/Target

# 3. Documentar la nueva categoría
echo "# Medical Devices" > _modules/Medical_Devices/README.md
echo "Módulos para aplicaciones médicas:" >> _modules/Medical_Devices/README.md
echo "- ECG_Monitor: Monitor de electrocardiograma" >> _modules/Medical_Devices/README.md
```

---

## 8. Buenas Prácticas

### 8.1 Nomenclatura de Módulos

✅ **BIEN:**
```
_modules/Wireless_Communication/HRD_WiFi/
_modules/Sensors/TemperatureMonitor/
_modules/Actuators/StepperMotor_NEMA17/
```

❌ **MAL:**
```
_modules/wifi/                      (sin categoría)
_modules/Wireless/wifi module/      (espacios)
_modules/Sensors/temp/              (muy genérico)
```

**Reglas:**
- Nombres descriptivos en PascalCase o snake_case
- Prefijo "HRD_" para hardware de EMIC Electronics
- Sin espacios ni caracteres especiales
- Incluir versión si hay múltiples versiones (V1, V2)

---

### 8.2 Versionado

Usa **Semantic Versioning** (SemVer) en `module.json`:

```json
{
  "version": "1.2.3"
}
```

- **MAJOR** (1.x.x): Cambios incompatibles con versiones anteriores
- **MINOR** (x.2.x): Nueva funcionalidad compatible
- **PATCH** (x.x.3): Correcciones de bugs

---

### 8.3 Documentación

Cada módulo DEBE incluir:

```
_modules/{Category}/{ModuleName}/
├── README.md                 ← Instrucciones de uso
├── m_description.json        ← Especificaciones técnicas
├── CHANGELOG.md              ← Historial de versiones
└── examples/                 ← Ejemplos de uso (opcional)
    └── example_basic.xml
```

**README.md mínimo:**
```markdown
# HRD_WiFi

## Descripción
Módulo WiFi para conectividad IoT basado en ESP8266.

## Hardware
- MCU: PIC24FJ64GA002
- WiFi: ESP8266 (AT firmware)
- LEDs: WiFi status, TX, RX

## Configuración
Editar `System/config.json`:
- `ssid`: Nombre de red WiFi
- `password`: Contraseña WiFi

## APIs Utilizadas
- `_api/Wireless/WiFi_ESP8266/`
- `_api/Timers/timer_api`
- `_api/Indicators/LEDs/`

## Ejemplo de Uso
Ver `examples/example_basic.xml`

## Versión
1.2.0 (última actualización: 2025-01-15)
```

---

### 8.4 Separación de Concerns

```
┌────────────────────────────────────────────────┐
│  ¿QUÉ VA EN CADA PARTE DEL MÓDULO?            │
└────────────────────────────────────────────────┘

  generate.emic →  Configuración de hardware
                   Invocación de APIs/Drivers
                   NO lógica de aplicación

  program.xml   →  Lógica de alto nivel
                   Máquina de estados
                   Llamadas a funciones publicadas

  userFncFile.c →  Funciones C personalizadas
                   Algoritmos complejos
                   Cálculos matemáticos

  config.json   →  Parámetros configurables
                   NO código
```

---

### 8.5 Testing

Checklist de testing para módulos:

- [ ] **Discovery funciona:** Recursos se publican correctamente
- [ ] **Generate funciona:** Target/ se genera sin errores
- [ ] **Compila sin warnings:** XC compiler clean compile
- [ ] **Hardware funciona:** Probado en placa real
- [ ] **Documentación completa:** README.md actualizado
- [ ] **Ejemplos funcionan:** Ejemplos probados y documentados

---

## 🎯 Puntos Clave del Capítulo

| Concepto | Explicación |
|----------|-------------|
| **Módulo EMIC** | Hardware + Firmware + Configuración + Lógica |
| **18 categorías** | Desde Actuators hasta Wireless_Communication |
| **m_description.json** | Documentación del hardware (NO modificar) |
| **generate.emic** | Script maestro de generación (Desarrollador) |
| **config.json** | Parámetros configurables (Integrador) |
| **program.xml** | Lógica visual (Integrador) |
| **Target/** | Código C generado (AUTO, NO modificar) |

---

## 📊 Resumen Visual

```
┌────────────────────────────────────────────────────┐
│              MÓDULO EMIC                           │
│    _modules/{Category}/{ModuleName}/               │
└────────────────────────────────────────────────────┘
            │
     ┌──────┴──────┐
     │             │
  System/       Target/
     │             │
     │             └─> Código C generado (OUTPUT)
     │
     ├─> generate.emic    (Script maestro)
     ├─> config.json      (Configuración)
     ├─> module.json      (Metadata)
     ├─> program.xml      (Lógica visual)
     └─> userFncFile.c    (Código C custom)
```

---

## ✅ Checklist de Comprensión

Antes de continuar al Capítulo 07, asegúrate de entender:

- [ ] Qué es un módulo EMIC (Hardware + Firmware + Config + Lógica)
- [ ] Las 18 categorías de módulos disponibles
- [ ] La estructura System/ vs Target/
- [ ] El propósito de m_description.json
- [ ] El propósito de generate.emic
- [ ] La diferencia entre config.json y module.json
- [ ] Por qué NO se debe modificar Target/
- [ ] El flujo de vida de un módulo (6 fases)
- [ ] Cómo crear un nuevo módulo
- [ ] Las buenas prácticas de nomenclatura y versionado

---

## 🎓 Ejercicio Práctico

**Exploración del SDK Real:**

```powershell
# Navega a _modules/
cd C:\Users\franc\Dropbox\...\EMIC_IA_M\_modules\

# Lista todas las categorías
ls

# Explora un módulo específico
cd Development_Board\Development_Board\

# Lee m_description.json
cat m_description.json

# Lee generate.emic
cat System\generate.emic

# Cuenta las APIs invocadas
Select-String "setInput.*_api" System\generate.emic | Measure-Object
```

**Pregunta de reflexión:**
¿Por qué crees que `Target/` se regenera completamente en vez de modificarse incrementalmente?

<details>
<summary>Ver respuesta</summary>

**Respuesta:**
Regenerar completamente `Target/` garantiza que siempre esté sincronizado con:
1. El código actual de las APIs/Drivers
2. Los cambios en program.xml
3. Los parámetros de config.json

Si se modificara incrementalmente, podrían quedar archivos obsoletos o inconsistencias. La regeneración completa elimina ese riesgo, aunque sea más lenta.

Además, fuerza al integrador a NO modificar Target/ directamente, manteniendo la separación entre configuración (System/) y código generado (Target/).

</details>

---

[← Anterior: Visión General SDK](05_Vision_General_SDK.md) | [Siguiente: Carpeta _api →](07_Carpeta_API.md)

---

**Progreso del Manual:**

```
Sección 1 (Introducción): ████████████████████ 100% (5/5)
Sección 2 (Estructura):   ████░░░░░░░░░░░░░░░░  18% (2/11)
```

**Progreso Total:** 18.42% (7/38 capítulos)

---

*Capítulo 06 - Manual de Desarrollo EMIC SDK v1.0*
*Última actualización: Noviembre 2025*
