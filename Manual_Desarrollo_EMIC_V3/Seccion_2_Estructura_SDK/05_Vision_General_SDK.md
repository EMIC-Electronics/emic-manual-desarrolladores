# Capítulo 05: Anatomía de un EMIC SDK - Visión General

[← Anterior: Ventajas](../Seccion_1_Introduccion/04_Ventajas.md) | [Siguiente: Carpeta _modules →](06_Carpeta_Modules.md)

---

## 📋 Contenido del Capítulo

1. [¿Qué es un EMIC SDK?](#1-qué-es-un-emic-sdk)
2. [Estructura Completa de Carpetas](#2-estructura-completa-de-carpetas)
3. [Propósito de Cada Carpeta](#3-propósito-de-cada-carpeta)
4. [Convenciones de Nombres](#4-convenciones-de-nombres)
5. [Flujo de Dependencias y Capas](#5-flujo-de-dependencias-y-capas)
6. [Estadísticas del SDK Real](#6-estadísticas-del-sdk-real)
7. [Navegación Eficiente](#7-navegación-eficiente)
8. [Siguientes Pasos](#8-siguientes-pasos)

---

## 1. ¿Qué es un EMIC SDK?

### 1.1 Definición Completa

Un **EMIC SDK** (Software Development Kit) es un **repositorio estructurado y completo** que contiene todos los recursos necesarios para desarrollar sistemas embebidos para diversas familias de microcontroladores (PIC, ARM Cortex-M, AVR, RISC-V, etc.).

```
┌────────────────────────────────────────────────────────┐
│                    EMIC SDK                            │
│  Software Development Kit para Sistemas Embebidos      │
└────────────────────────────────────────────────────────┘

      ┌─────────────────────────────────────┐
      │   ¿QUÉ CONTIENE UN EMIC SDK?        │
      └─────────────────────────────────────┘
               │
      ┌────────┴────────────────────────┐
      │                                  │
   CÓDIGO C                    EMIC-CODIFY
  (bajo nivel)                (alto nivel)
      │                                  │
      │                                  │
  • _api/                        • generate.emic
  • _drivers/                    • deploy.emic
  • _hal/                        • Tags DOXYGEN
  • _hard/                       • Macros
  • _util/                       • Comandos EMIC
```

### 1.2 SDK vs "Repositorio EMIC" (Término Antiguo)

| Aspecto | Término Antiguo | Término Actual |
|---------|-----------------|----------------|
| **Nombre** | "Repositorio EMIC" | **EMIC SDK** |
| **Definición** | Lugar donde se guardan recursos | **Kit completo de desarrollo** |
| **Alcance** | Ambiguo | Claro y profesional |
| **Estándar** | Terminología interna | **Estándar de la industria** |

> **📌 IMPORTANTE:** A partir de EMIC V4, el término oficial es **"EMIC SDK"**. Si encuentras documentación antigua que usa "Repositorio EMIC", se refiere al mismo concepto.

### 1.3 Contenido del SDK

Un EMIC SDK completo contiene:

✅ **EMIC-Libraries**: Código C con anotaciones EMIC-Codify
✅ **Módulos Hardware + Firmware**: Soluciones funcionales completas
✅ **APIs de Alto Nivel**: Abstracción de hardware específico
✅ **Drivers**: Control de dispositivos externos (sensores, displays, etc.)
✅ **HAL**: Hardware Abstraction Layer (periféricos del MCU)
✅ **Templates**: Plantillas de proyectos (MPLAB X, etc.)
✅ **Documentación**: Embebida en el código mediante DOXYGEN

---

## 2. Estructura Completa de Carpetas

### 2.1 Árbol de Directorios del SDK

```
EMIC_SDK/                             ← Directorio raíz del SDK
│
├── .emic/                            ⭐ Metadatos del Repositorio (OBLIGATORIO)
│   └── repository.json               ← Descriptor del SDK
│
├── _modules/                         ⭐ Módulos (Hardware + Firmware)
│   └── {Category}/                      Organizados por categoría
│       └── {ModuleName}/
│           ├── System/                  ← Configuración y scripts
│           │   ├── generate.emic        ← Script de generación
│           │   ├── deploy.emic          ← Script de deployment
│           │   ├── config.json          ← Configuración dinámica
│           │   ├── module.json          ← Metadata del módulo
│           │   └── program.xml          ← Código visual (EMIC-Editor)
│           ├── Target/                  ← Código generado (output)
│           └── m_description.json       ← Descripción general
│
├── _api/                             ⭐ APIs de Alto Nivel
│   └── {Category}/                      Aíslan hardware específico
│       └── {ApiName}/
│           ├── ApiName.emic             ← Script EMIC (recursos)
│           ├── inc/                     ← Headers (.h)
│           └── src/                     ← Implementación (.c)
│
├── _drivers/                         ⭐ Drivers de Hardware Externo
│   └── {Category}/                      Sensores, displays, actuadores
│       └── {DriverName}/
│           ├── DriverName.emic          ← Script EMIC
│           ├── inc/                     ← Headers
│           └── src/                     ← Código C
│
├── _hal/                             ⭐ Hardware Abstraction Layer
│   └── {Peripheral}/                    Periféricos del MCU
│       ├── hal_peripheral.emic
│       ├── inc/
│       └── src/
│
├── _hard/                            ⭐ Código Específico de MCU
│   └── {MCU_Family}/                    PIC18, PIC24, dsPIC33, etc.
│       ├── mcu_init.emic
│       ├── inc/
│       └── src/
│
├── _main/                            ⭐ Punto de Entrada
│   └── main.c                           Archivo main.c baremetal
│
├── _pcb/                             ⭐ Configuración de PCBs
│   └── {PCB_Name}/
│       ├── pcb_config.emic
│       └── pinout.json                  Mapeo de pines
│
├── _templates/                       ⭐ Templates de Proyectos
│   ├── MPLABX/                          Plantilla MPLAB X
│   ├── Makefile/                        Plantilla Makefile
│   └── VSCode/                          Configuración VSCode
│
├── _system/                          ⭐ Sistema Core EMIC
│   ├── conversions/                     Conversión de tipos
│   ├── includes/                        Includes automáticos
│   └── core/                            Motor de generación
│
└── _util/                            ⭐ Utilidades Generales
    ├── Math/                            Operadores matemáticos
    ├── String/                          Manipulación de cadenas
    ├── Logic/                           Operadores lógicos
    └── Flow/                            Control de flujo
```

### 2.2 Vista Simplificada por Capas

```
┌─────────────────────────────────────────────────────┐
│                    USUARIO                          │  ← Integrador
│              (EMIC-Editor / Script)                 │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│  CAPA 1: MÓDULOS (_modules/)                        │  ← Soluciones completas
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│  CAPA 2: APIs (_api/)                               │  ← Abstracción hardware
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│  CAPA 3: DRIVERS (_drivers/)                        │  ← Dispositivos externos
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│  CAPA 4: HAL (_hal/)                                │  ← Periféricos MCU
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│  CAPA 5: HARDWARE (_hard/)                          │  ← Código específico MCU
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│              MICROCONTROLADOR                       │  ← PIC18/24/33
└─────────────────────────────────────────────────────┘

  + TRANSVERSALES: _util/ (cualquier capa), _system/ (motor)
```

---

## 3. Propósito de Cada Carpeta

### 3.0 `.emic/` - Metadatos del Repositorio

**Propósito:**
Contiene metadatos obligatorios que identifican y describen el SDK.

**Características:**
- 🎯 **Obligatoria** para que el sistema reconozca el SDK
- 🎯 **Contiene `repository.json`** con información del repositorio
- 🎯 **Permite indexación** en catálogos y búsquedas
- 🎯 **Define autoría, licencia y tags**

**Archivo principal:**
```json
{
  "name": "EMIC_SDK",
  "description": "Descripción del SDK...",
  "type": "SDK",
  "tags": ["tag1", "tag2"],
  "author": "Autor",
  "license": "Proprietary"
}
```

> **⚠️ IMPORTANTE:** Sin esta carpeta, el sistema EMIC no reconocerá el directorio como un SDK válido.

👉 **Detalle completo:** [Capítulo 05b](05b_Carpeta_EMIC_Repository.md)

---

### 3.1 `_modules/` - Módulos Hardware + Firmware

**Propósito:**
Contiene **módulos completos** que representan unidades funcionales del mundo real.

**Características:**
- 🎯 **Hardware + Firmware juntos**
- 🎯 **Soluciones listas para usar**
- 🎯 **Configurables mediante config.json**
- 🎯 **Código generado en Target/**

**Ejemplo:**
Un módulo "USB_Logger" incluye firmware para manejar USB + lógica de logging.

👉 **Detalle completo:** [Capítulo 06](06_Carpeta_Modules.md)

---

### 3.2 `_api/` - APIs de Alto Nivel

**Propósito:**
Abstracción de hardware específico para facilitar portabilidad.

**Características:**
- 🎯 **Independiente del hardware**
- 🎯 **Interface consistente**
- 🎯 **Llamables desde scripts (EMIC-Editor)**
- 🎯 **Tags DOXYGEN para publicar recursos**

**Ejemplo:**
`_api/Timers/timer_api.emic` → Abstrae Timer0/Timer1/Timer2 según MCU.

**Estructura interna:**
```
_api/Timers/
├── timer_api.emic      ← Script EMIC con dependencias
├── inc/
│   └── timer_api.h     ← Header con tags DOXYGEN
└── src/
    └── timer_api.c     ← Implementación en C
```

👉 **Detalle completo:** [Capítulo 07](07_Carpeta_API.md)

---

### 3.3 `_drivers/` - Drivers de Hardware Externo

**Propósito:**
Control de dispositivos externos (sensores, displays, actuadores, etc.).

**Características:**
- 🎯 **Dispositivos fuera del MCU**
- 🎯 **Interfaz estándar (I2C, SPI, UART, GPIO)**
- 🎯 **Reutilizables entre proyectos**
- 🎯 **Documentados con DOXYGEN**

**Ejemplo:**
`_drivers/Displays/LCD_16x2/` → Driver para LCD 16x2 por I2C.

👉 **Detalle completo:** [Capítulo 08](08_Carpeta_Drivers.md)

---

### 3.4 `_hal/` - Hardware Abstraction Layer

**Propósito:**
Abstrae periféricos del microcontrolador (ADC, UART, SPI, I2C, PWM, etc.).

**Características:**
- 🎯 **Periféricos internos del MCU**
- 🎯 **Mismo código para diferentes PICs**
- 🎯 **Oculta detalles de registros**
- 🎯 **Facilita portabilidad**

**Ejemplo:**
`_hal/ADC/` → Configura ADC sin conocer registros específicos del PIC.

👉 **Detalle completo:** [Capítulo 09](09_Carpeta_HAL.md)

---

### 3.5 `_hard/` - Código Específico de MCU

**Propósito:**
Código de bajo nivel específico para cada familia de microcontroladores.

**Características:**
- 🎯 **Acceso directo a registros**
- 🎯 **Configuración de clock**
- 🎯 **Inicialización del MCU**
- 🎯 **Manejo de interrupciones**

**Ejemplo:**
`_hard/PIC18F/` vs `_hard/PIC24F/` → Código diferente según la familia.

👉 **Detalle completo:** [Capítulo 10](10_Carpeta_Hard.md)

---

### 3.6 `_main/` - Punto de Entrada

**Propósito:**
Contiene el archivo `main.c` que sirve como punto de entrada del programa.

**Características:**
- 🎯 **Único archivo main.c**
- 🎯 **Inicialización del sistema**
- 🎯 **Loop principal**
- 🎯 **Generado/modificado automáticamente**

**Ejemplo de main.c:**
```c
#include "system.h"

void main(void) {
    // Inicialización generada por EMIC
    SYSTEM_Initialize();

    // Loop principal
    while(1) {
        SYSTEM_Tasks();
    }
}
```

👉 **Detalle completo:** [Capítulo 11](11_Carpeta_Main.md)

---

### 3.7 `_pcb/` - Configuración de PCBs

**Propósito:**
Define configuraciones específicas de placas de circuito impreso (pinout, recursos).

**Características:**
- 🎯 **Mapeo de pines**
- 🎯 **Configuración de periféricos**
- 🎯 **Reutilizable entre proyectos**
- 🎯 **JSON + scripts EMIC**

**Ejemplo:**
`_pcb/HRD_USB_V1.1/pcb.emic` → Define pinout de la placa HRD_USB.

👉 **Detalle completo:** [Capítulo 12](12_Carpeta_PCB.md)

---

### 3.8 `_templates/` - Templates de Proyectos

**Propósito:**
Plantillas para proyectos de diferentes IDEs y sistemas de build.

**Características:**
- 🎯 **Configuración MPLAB X**
- 🎯 **Makefiles**
- 🎯 **VSCode settings**
- 🎯 **Git ignore**

**Ejemplo:**
`_templates/MPLABX/nbproject/` → Configuración de proyecto MPLAB X.

👉 **Detalle completo:** [Capítulo 13](13_Carpeta_Templates.md)

---

### 3.9 `_system/` - Sistema Core EMIC

**Propósito:**
Motor de generación de código EMIC (conversiones, includes, core).

**Características:**
- 🎯 **Conversión de tipos**
- 🎯 **Includes automáticos**
- 🎯 **Motor de interpretación EMIC-Codify**
- 🎯 **NO modificar (sistema)**

**Ejemplo:**
`_system/conversions/int_to_string.c` → Conversión automática de tipos.

👉 **Detalle completo:** [Capítulo 14](14_Carpeta_System.md)

---

### 3.10 `_util/` - Utilidades Generales

**Propósito:**
Funciones de uso general, independientes del hardware.

**Características:**
- 🎯 **Operadores matemáticos**
- 🎯 **Manipulación de cadenas**
- 🎯 **Operadores lógicos**
- 🎯 **Control de flujo**
- 🎯 **100% portables**

**Ejemplo:**
`_util/Math/sqrt.c` → Raíz cuadrada sin dependencias de hardware.

👉 **Detalle completo:** [Capítulo 15](15_Carpeta_Util.md)

---

## 4. Convenciones de Nombres

### 4.1 Carpetas del Sistema

```
┌─────────────────────────────────────────┐
│  REGLA: Todas las carpetas del SDK      │
│  comienzan con UNDERSCORE (_)           │
└─────────────────────────────────────────┘
```

**Ejemplos:**
- ✅ `_api/`
- ✅ `_drivers/`
- ✅ `_modules/`
- ❌ `api/` (incorrecto, falta _)

**Razón:**
El prefijo `_` indica que es **parte del SDK** y no debe confundirse con carpetas de usuario.

---

### 4.2 Nombres de Archivos

| Tipo | Convención | Ejemplo |
|------|------------|---------|
| **Scripts EMIC** | `nombre.emic` | `generate.emic`, `timer_api.emic` |
| **Headers C** | `nombre.h` | `timer_api.h`, `lcd_driver.h` |
| **Source C** | `nombre.c` | `timer_api.c`, `lcd_driver.c` |
| **Config JSON** | `*.json` | `config.json`, `module.json` |
| **Program XML** | `program.xml` | `program.xml` (EMIC-Editor) |

---

### 4.3 Nombres de Categorías

**CamelCase o snake_case según contexto:**

```
_modules/
├── Actuators                ← CamelCase (categoría)
├── Development_Board        ← snake_case con mayúscula inicial
└── Wireless_Communication   ← snake_case descriptivo
```

**Criterio:**
- Categorías descriptivas: `snake_case` con mayúscula inicial
- Categorías simples: `CamelCase`

---

## 5. Flujo de Dependencias y Capas

### 5.1 Diagrama de Capas de Abstracción

```
┌─────────────────────────────────────────────────────┐
│              INTEGRADOR (Script)                    │
└─────────────────────────────────────────────────────┘
          │
          │ Llama a recursos de:
          ↓
┌─────────────────────────────────────────────────────┐
│                  _modules/                          │  Nivel 5: Módulos
│  (Usa APIs, Drivers, HAL según necesidad)          │  (más alto)
└─────────────────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────────────────┐
│                    _api/                            │  Nivel 4: APIs
│  (Llama a Drivers, HAL, _util)                     │
└─────────────────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────────────────┐
│                  _drivers/                          │  Nivel 3: Drivers
│  (Usa HAL para comunicación)                       │
└─────────────────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────────────────┐
│                    _hal/                            │  Nivel 2: HAL
│  (Abstrae periféricos del MCU)                     │
└─────────────────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────────────────┐
│                   _hard/                            │  Nivel 1: Hardware
│  (Código específico del MCU)                       │  (más bajo)
└─────────────────────────────────────────────────────┘

    + _util/ (transversal, accesible desde cualquier capa)
    + _system/ (motor de generación, capa invisible)
```

### 5.2 Reglas de Dependencias

| Capa | Puede Llamar A | NO Puede Llamar A |
|------|----------------|-------------------|
| **_modules/** | _api, _drivers, _hal, _util | _hard (debe usar HAL) |
| **_api/** | _drivers, _hal, _util | _modules |
| **_drivers/** | _hal, _util | _api, _modules |
| **_hal/** | _hard, _util | _api, _drivers, _modules |
| **_hard/** | _util | Ninguna capa superior |
| **_util/** | Solo estándar C | Ninguna capa |

> **📌 Regla de Oro:** Las dependencias **siempre van hacia abajo** (capas inferiores).

---

### 5.3 Flowchart del Proceso de Compilación

```
┌──────────────────────────────────────────────────────────┐
│  1. INTEGRADOR crea script en EMIC-Editor               │
│     (Usa recursos publicados por _api/, _drivers/)      │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│  2. EMIC-DISCOVERY extrae recursos del SDK              │
│     (Lee tags DOXYGEN en _api/, _drivers/, etc.)        │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│  3. EMIC-GENERATE fusiona Script + SDK                  │
│     (Interpreta generate.emic del módulo)               │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│  4. Código C generado en _modules/{Module}/Target/      │
│     (Listo para compilar con XC8/XC16/XC32)             │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│  5. COMPILADOR XC genera firmware.hex                   │
│     (Usando MPLAB X o línea de comandos)                │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│  6. DEPLOYMENT al microcontrolador                       │
│     (PICkit, ICD, bootloader, etc.)                     │
└──────────────────────────────────────────────────────────┘
```

---

## 6. Estadísticas del SDK Real

### 6.1 Inventario Completo

Según el SDK real en `C:\Users\franc\Dropbox\...\DEV\EMIC_IA_M\`:

| Componente | Cantidad | Descripción |
|------------|----------|-------------|
| **Categorías de Módulos** | 18 | Grupos temáticos de módulos |
| **Categorías de APIs** | 21 | Grupos de APIs disponibles |
| **Total de APIs** | 68+ | APIs reutilizables |
| **Total de Drivers** | 19+ | Drivers de hardware externo |
| **Carpetas principales** | 12 | `.emic/`, `_api/`, `_drivers/`, `_hal/`, etc. |

### 6.2 Categorías de Módulos Disponibles

```
_modules/
├── Actuators                    ← Motores, relés, solenoides
├── Custom                       ← Módulos personalizados
├── Development_Board            ← Placas de desarrollo
├── Digital_In_Out               ← Entradas/salidas digitales
├── Displays_seven_segments      ← Displays 7 segmentos
├── Graphic_Displays             ← LCDs gráficos, OLED
├── Indoor_Crops                 ← Agricultura indoor (IoT)
├── Lavarropas                   ← Control de lavarropas (ejemplo IIoT)
├── Oil_and_Gas                  ← Industria petróleo/gas
├── Power_Supply                 ← Fuentes de alimentación
├── Sensors                      ← Sensores (temp, humedad, presión)
├── Storage                      ← EEPROM, SD, Flash
├── Tecnocrom_Controller         ← Controlador industrial
├── Testing                      ← Módulos de prueba
├── TestModule                   ← Módulo de ejemplo
├── Wired_Communication          ← UART, I2C, SPI, RS485
├── Wired_Control                ← Control por cable
└── Wireless_Communication       ← WiFi, LoRa, BLE, Zigbee
```

### 6.3 Categorías de APIs Principales

```
_api/
├── Actuators           ← Control de actuadores
├── ADC                 ← Conversor analógico-digital
├── Alarm               ← Gestión de alarmas
├── Audio               ← Reproducción de audio
├── Custom              ← APIs personalizadas
├── Development_Board   ← APIs para dev boards
├── Indicators          ← LEDs, buzzers
├── Inputs              ← Botones, switches
├── Power               ← Gestión de energía
├── Protocols           ← Protocolos de comunicación
├── Sensors             ← APIs de sensores
├── Storage             ← Almacenamiento de datos
├── System              ← Configuración del sistema
├── Timers              ← Temporizadores
├── Wired_Communication ← Comunicación cableada
└── Wireless            ← Comunicación inalámbrica
```

> **📊 Nota:** Estas cifras corresponden al SDK real al momento de escribir este manual. El SDK está en constante crecimiento mediante contribuciones de la comunidad.

---

## 7. Navegación Eficiente

### 7.1 ¿Cómo Encontrar Recursos?

**Caso 1: Necesito controlar un LED**

```
1. ¿Es hardware externo o periférico del MCU?
   → Periférico del MCU (GPIO)

2. Buscar en _api/ o _hal/
   → _api/Indicators/LEDs/

3. Revisar archivo .emic
   → led_api.emic (contiene recursos publicados)

4. Leer tags DOXYGEN
   → @fn LED_On(), @fn LED_Off(), @fn LED_Toggle()
```

**Caso 2: Necesito leer sensor de temperatura I2C**

```
1. ¿Es hardware externo?
   → Sí

2. Buscar en _drivers/Sensors/
   → _drivers/Sensors/TMP102/ (ejemplo)

3. Revisar .emic
   → tmp102_driver.emic

4. Usar recursos publicados
   → TMP102_ReadTemperature()
```

**Caso 3: Necesito crear módulo completo**

```
1. Elegir categoría en _modules/
   → _modules/Wireless_Communication/

2. Crear carpeta del módulo
   → _modules/Wireless_Communication/MiModuloLoRa/

3. Crear estructura
   ├── System/
   │   ├── generate.emic
   │   ├── deploy.emic
   │   └── config.json
   └── Target/

4. Implementar generate.emic
   → Invocar APIs/Drivers necesarios
```

### 7.2 Atajos de Navegación

| Objetivo | Ruta Rápida |
|----------|-------------|
| **Ver todos los módulos** | `_modules/` → Elegir categoría |
| **Buscar API específica** | `_api/{Category}/` |
| **Encontrar driver** | `_drivers/{Category}/` |
| **Ver periféricos MCU** | `_hal/{Peripheral}/` |
| **Código específico PIC** | `_hard/{MCU_Family}/` |
| **Utilidades generales** | `_util/` |

---

## 8. Siguientes Pasos

### 8.1 Roadmap de la Sección 2

En los próximos capítulos, explorarás **EN DETALLE** cada carpeta del SDK:

```
✅ Capítulo 05: Visión General SDK (este capítulo)

Próximos capítulos:

📘 Capítulo 05b: .emic/ - Metadatos del Repositorio
   - Archivo repository.json
   - Campos obligatorios y opcionales
   - Indexación y búsqueda de SDKs

📘 Capítulo 06: _modules/ - Módulos Hardware + Firmware
   - Estructura de un módulo
   - generate.emic y deploy.emic
   - config.json y module.json
   - Ejemplos reales del SDK

📘 Capítulo 07: _api/ - APIs de Alto Nivel
   - Creación de APIs
   - Tags DOXYGEN
   - Publicación de recursos
   - Ejemplos: Timer API, LED API

📘 Capítulo 08: _drivers/ - Drivers de Hardware
   - Drivers de sensores
   - Drivers de displays
   - Drivers de comunicación
   - Ejemplos reales

📘 Capítulo 09: _hal/ - Hardware Abstraction Layer
   - Abstracción de periféricos
   - Portabilidad entre MCUs
   - Ejemplos: ADC HAL, UART HAL

📘 Capítulo 10: _hard/ - Código Específico MCU
   - PIC18 vs PIC24 vs dsPIC33
   - Inicialización de hardware
   - Configuración de clock

📘 Capítulo 11: _main/ - Punto de Entrada
📘 Capítulo 12: _pcb/ - Configuración PCBs
📘 Capítulo 13: _templates/ - Templates
📘 Capítulo 14: _system/ - Sistema Core
📘 Capítulo 15: _util/ - Utilidades
```

### 8.2 Conocimiento Acumulado

Al completar este capítulo, ya sabes:

✅ Qué es un EMIC SDK y para qué sirve
✅ La estructura completa de carpetas
✅ El propósito de cada carpeta (visión general)
✅ Las convenciones de nombres
✅ El flujo de dependencias entre capas
✅ Las estadísticas del SDK real
✅ Cómo navegar eficientemente

**Próximo capítulo:** Exploración detallada de `_modules/`, la carpeta más importante del SDK.

---

## 🎯 Puntos Clave del Capítulo

| Concepto | Explicación |
|----------|-------------|
| **EMIC SDK** | Software Development Kit completo para embebidos |
| **12 carpetas principales** | `.emic/`, `_modules/`, `_api/`, `_drivers/`, `_hal/`, `_hard/`, `_main/`, `_pcb/`, `_templates/`, `_system/`, `_util/` |
| **Prefijo `_`** | Todas las carpetas del SDK comienzan con underscore |
| **Capas de abstracción** | 5 niveles: Módulos → API → Drivers → HAL → Hardware |
| **Dependencias** | Siempre van hacia abajo (capas inferiores) |
| **SDK Real** | 18 categorías de módulos, 68+ APIs, 19+ drivers |

---

## 📊 Resumen Visual

```
┌──────────────────────────────────────────────────────┐
│              EMIC SDK = TODO LO NECESARIO            │
│        para desarrollar sistemas embebidos           │
└──────────────────────────────────────────────────────┘

      .emic/    →  Metadatos del SDK (OBLIGATORIO)

     _modules/  →  Soluciones completas
          ↓
      _api/     →  Abstracción hardware
          ↓
    _drivers/  →  Dispositivos externos
          ↓
      _hal/    →  Periféricos MCU
          ↓
     _hard/    →  Código específico MCU

    + _util/      (transversal)
    + _system/    (motor EMIC)
    + _main/      (entry point)
    + _pcb/       (configuración)
    + _templates/ (plantillas)
```

---

## ✅ Checklist de Comprensión

Antes de continuar al Capítulo 06, asegúrate de entender:

- [ ] La diferencia entre "EMIC SDK" y "Repositorio EMIC"
- [ ] Los nombres de las 12 carpetas principales del SDK (incluyendo `.emic/`)
- [ ] El propósito general de cada carpeta
- [ ] Por qué las carpetas comienzan con `_`
- [ ] Las 5 capas de abstracción (módulos → hardware)
- [ ] La regla de dependencias (siempre hacia abajo)
- [ ] Las estadísticas del SDK real (18 categorías de módulos)
- [ ] Cómo navegar para encontrar APIs, drivers o módulos

---

## 🎓 Ejercicio Práctico

**Exploración del SDK Real:**

```bash
# Navega al SDK
cd C:\Users\franc\Dropbox\EMIC\...\EMIC_IA_M\

# Lista las carpetas principales
ls -d _*/

# Cuenta las categorías de módulos
ls _modules/ | wc -l

# Explora una categoría de APIs
ls _api/Timers/

# Revisa un archivo .emic
cat _api/Timers/timer_api.emic
```

**Pregunta de reflexión:**
¿Por qué crees que EMIC separa `_api/` de `_drivers/` si ambos contienen código reutilizable?

<details>
<summary>Ver respuesta</summary>

**Respuesta:**
`_api/` abstrae hardware específico (portable entre MCUs), mientras que `_drivers/` controla dispositivos externos (portable entre proyectos). Separar ambos facilita la portabilidad y la organización.

Ejemplo:
- `_api/Timers/` → Funciona en PIC18 y PIC24 (abstrae Timer0/Timer1)
- `_drivers/LCD_I2C/` → Funciona con cualquier MCU que tenga I2C

</details>

---

[← Anterior: Ventajas](../Seccion_1_Introduccion/04_Ventajas.md) | [Siguiente: Carpeta _modules →](06_Carpeta_Modules.md)

---

**Progreso del Manual:**

```
Sección 1 (Introducción): ████████████████████ 100% (5/5)
Sección 2 (Estructura):   ██░░░░░░░░░░░░░░░░░░  9%  (1/11)
```

**Progreso Total:** 15.79% (6/38 capítulos)

---

*Capítulo 05 - Manual de Desarrollo EMIC SDK v1.0*
*Última actualización: Noviembre 2025*
