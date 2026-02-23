# Capítulo 02: Arquitectura y Conceptos Fundamentales

[← Anterior: Introducción](01_Introduccion.md) | [Siguiente: Glosario →](03_Glosario.md)

---

## 📋 Contenido del Capítulo

1. [Introducción a la Arquitectura EMIC](#1-introducción-a-la-arquitectura-emic)
2. [Los 4 Procesos Clave](#2-los-4-procesos-clave)
3. [Volúmenes Lógicos](#3-volúmenes-lógicos)
4. [Conceptos Clave](#4-conceptos-clave)
5. [Flujo de Datos Completo](#5-flujo-de-datos-completo)
6. [Arquitectura en Runtime](#6-arquitectura-en-runtime)
7. [Relación entre Componentes](#7-relación-entre-componentes)

---

## 1. Introducción a la Arquitectura EMIC

La arquitectura de EMIC está diseñada para **separar responsabilidades** y permitir que desarrolladores e integradores trabajen de forma **independiente pero coordinada**.

### Visión de Alto Nivel

EMIC se estructura en **capas de abstracción** donde cada capa tiene un propósito específico:

```
┌─────────────────────────────────────────────────────────────┐
│                    ARQUITECTURA EMIC                        │
│                                                             │
│  ┌───────────────────────────────────────────────────┐    │
│  │         CAPA DE INTEGRACIÓN (Integrador)          │    │
│  │              EMIC-Editor (Visual)                  │    │
│  └──────────────────────┬────────────────────────────┘    │
│                         │                                   │
│  ┌──────────────────────▼───────────────────────────┐    │
│  │      CAPA DE PROCESAMIENTO (Sistema EMIC)        │    │
│  │   Discovery → Transcriptor → Merge → Compiler     │    │
│  └──────────────────────┬────────────────────────────┘    │
│                         │                                   │
│  ┌──────────────────────▼───────────────────────────┐    │
│  │    CAPA DE RECURSOS (Desarrollador - TÚ)         │    │
│  │      EMIC-Libraries (APIs, Drivers, Módulos)      │    │
│  └───────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Principios Arquitectónicos

1. **Separación de Concerns**:
   - Desarrollador: Crea recursos de bajo nivel
   - Integrador: Usa recursos de alto nivel
   - Sistema: Fusiona ambos mundos

2. **Abstracción Progresiva**:
   - Hardware específico → HAL → Drivers → APIs → Módulos
   - Cada capa oculta complejidad de la inferior

3. **Reutilización Masiva**:
   - Un componente, múltiples usos
   - DRY (Don't Repeat Yourself) llevado al extremo

4. **Estandarización Estricta**:
   - Todos los componentes siguen las mismas reglas
   - Interoperabilidad garantizada

---

## 2. Los 4 Procesos Clave

EMIC funciona a través de **4 procesos principales** que transforman componentes individuales en firmware compilable.

### 2.1 EMIC Discovery 🔍

**Propósito:** Extraer y catalogar recursos de las EMIC-Libraries.

**¿Qué hace?**

```
INPUT:                          PROCESO:                    OUTPUT:
┌─────────────┐                ┌──────────┐              ┌─────────────┐
│ EMIC-       │                │  Busca   │              │  Catálogo   │
│ Libraries   │───────────────>│  Tags    │─────────────>│  de         │
│             │                │  DOXYGEN │              │  Recursos   │
│ • .c files  │                │  @fn     │              │             │
│ • .h files  │                │  @alias  │              │ • Funciones │
│ • .emic     │                │  etc.    │              │ • Variables │
│             │                │          │              │ • Eventos   │
└─────────────┘                └──────────┘              └─────────────┘
```

**Ejemplo:**

Tu escribes en `led.h`:

```c
/**
 * @fn void LED_state(uint8_t state);
 * @alias led.state
 * @brief Change LED state
 * @param state 1=on, 0=off, 2=toggle
 * @return Nothing
 */
void LED_state(uint8_t state);
```

**EMIC Discovery extrae:**
- Nombre de función: `LED_state`
- Alias para editor: `led.state`
- Descripción: "Change LED state"
- Parámetros: `state` (1=on, 0=off, 2=toggle)
- Tipo de retorno: void

**Resultado:** Esta función aparece en el toolbox del EMIC-Editor para que integradores la usen.

**¿Cuándo ocurre?**
- Al crear/actualizar un módulo
- Al sincronizar con el SDK
- Bajo demanda del integrador

### 2.2 EMIC Editor 🖥️

**Propósito:** Interfaz visual donde integradores crean la lógica de aplicación.

**¿Qué hace?**

```
INTEGRADOR:                    EDITOR:                     OUTPUT:
┌─────────────┐               ┌──────────┐              ┌─────────────┐
│ Arrastra    │               │ Canvas   │              │  Script     │
│ funciones   │──────────────>│ Visual   │─────────────>│  (XML/JSON) │
│ del toolbox │               │          │              │             │
│             │               │ Conecta  │              │ Contiene:   │
│ Configura   │               │ lógica   │              │ • Llamadas  │
│ parámetros  │               │          │              │ • Flujo     │
│             │               │ Define   │              │ • Config    │
│ Crea flujo  │               │ eventos  │              │             │
└─────────────┘               └──────────┘              └─────────────┘
```

**Características:**
- Drag & Drop de funciones
- Configuración visual de parámetros
- Creación de eventos y callbacks
- Preview de código generado

**Salida:** Script en formato intermedio que describe la aplicación.

> **📝 Nota:** Como desarrollador, NO usas el Editor, pero es importante entender que tu código será utilizado aquí visualmente.

### 2.3 EMIC Generate ⚙️

**Propósito:** Fusionar el Script del integrador con tus EMIC-Libraries para generar código C.

**¿Qué hace?**

```
INPUTS:                        PROCESO:                    OUTPUT:
┌─────────────┐               ┌──────────┐              ┌─────────────┐
│ Script del  │               │          │              │  Código C   │
│ Integrador  │──────────┐    │  EMIC    │              │  Compilable │
│             │          │    │  Codify  │              │             │
└─────────────┘          ├───>│  Engine  │─────────────>│ • main.c    │
                         │    │          │              │ • includes  │
┌─────────────┐          │    │ Procesa: │              │ • configs   │
│ EMIC-       │          │    │ • setInput              │ • makefile  │
│ Libraries   │──────────┘    │ • copy   │              │             │
│ (Tu código) │               │ • define │              │ ¡Listo para │
│             │               │ • macros │              │ compilar!   │
└─────────────┘               └──────────┘              └─────────────┘
```

**Proceso detallado:**

1. **Lee generate.emic** del módulo seleccionado
2. **Interpreta comandos EMIC-Codify:**
   - `EMIC:setInput(...)` - Carga archivos
   - `EMIC:copy(...)` - Copia y procesa código
   - `EMIC:define(...)` - Define macros
   - `.{macro}.` - Sustituye valores
3. **Fusiona:**
   - Tu código C
   - Script del integrador
   - Configuración del hardware
4. **Genera:**
   - Código C final en `TARGET:`
   - Proyecto MPLAB X
   - Configuraciones necesarias

**Ejemplo de generate.emic:**

```
EMIC:setOutput(TARGET:generate.txt)

//-- Configuración de hardware --
EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_USB V1.1)

//-- Cargar APIs necesarias --
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led,pin=Led1)
EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)

//-- Procesar script del integrador --
EMIC:setInput(SYS:usedFunction.emic)

//-- Generar main --
EMIC:setInput(DEV:_main/baremetal/main.emic)

//-- Copiar archivos de usuario --
EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
```

### 2.4 EMIC Compiler 🔨

**Propósito:** Compilar el código C generado con XC8/XC16/XC32.

**¿Qué hace?**

```
INPUT:                         PROCESO:                    OUTPUT:
┌─────────────┐               ┌──────────┐              ┌─────────────┐
│  Código C   │               │ Compiler │              │  Firmware   │
│  (TARGET:)  │──────────────>│ XC8/16   │─────────────>│  (.hex)     │
│             │               │          │              │             │
│ • main.c    │               │ Opciones:│              │ Listo para  │
│ • drivers   │               │ • -O2    │              │ programar   │
│ • configs   │               │ • -Wall  │              │ en MCU      │
│             │               │ • etc.   │              │             │
└─────────────┘               └──────────┘              └─────────────┘
```

**Configuraciones:**
- Nivel de optimización
- Advertencias habilitadas
- Microcontrolador objetivo
- Configuración de fusibles

**Salida:** Firmware `.hex` listo para cargar en el microcontrolador.

---

## 3. Volúmenes Lógicos

EMIC usa un **sistema de volúmenes virtuales** para abstraer rutas físicas del filesystem. Esto facilita portabilidad y organización.

### 3.1 Tabla de Volúmenes

| Volumen | Descripción | Ubicación Física Típica | Uso |
|---------|-------------|-------------------------|-----|
| `DEV:` | EMIC SDK completo | `/Repositorio_EMIC/` | Recursos del desarrollador |
| `TARGET:` | Código generado | `/Module/Target/` | Salida de EMIC Generate |
| `SYS:` | Config del sistema | `/Module/System/` | Configs y scripts |
| `USER:` | Archivos del usuario | `/Projects/User/` | Código personalizado |

### 3.2 Estructura de Volúmenes

```
FILESYSTEM REAL:
C:\EMIC_SDK\
├── _api\           ← DEV:_api\
├── _drivers\       ← DEV:_drivers\
├── _modules\       ← DEV:_modules\
└── ...

C:\Projects\MyModule\
├── System\         ← SYS:
│   ├── generate.emic
│   └── config.json
└── Target\         ← TARGET:
    ├── main.c
    └── ...
```

### 3.3 Uso de Volúmenes en Comandos

```
// Leer desde DEV: (SDK)
EMIC:setInput(DEV:_api/Timers/timer_api.emic)

// Escribir a TARGET: (salida)
EMIC:setOutput(TARGET:main.c)

// Leer config desde SYS:
EMIC:setInput(SYS:config.json)

// Copiar de usuario
EMIC:copy(USER:myFile.c > TARGET:myFile.c)
```

### 3.4 Beneficios de Volúmenes Lógicos

- ✅ **Portabilidad:** El mismo código funciona en cualquier sistema
- ✅ **Abstracción:** No necesitas conocer rutas físicas
- ✅ **Organización:** Separación clara de responsabilidades
- ✅ **Flexibilidad:** Fácil cambio de ubicaciones físicas

---

## 4. Conceptos Clave

### 4.1 EMIC SDK

**Definición:** Software Development Kit completo que contiene todos los componentes reutilizables.

**Anteriormente conocido como:** "Repositorio EMIC" (término legacy)

**Contenido:**
```
EMIC_SDK/
├── _api/          ← APIs de alto nivel
├── _drivers/      ← Drivers de hardware
├── _hal/          ← Hardware Abstraction Layer
├── _hard/         ← Código específico de MCU
├── _main/         ← Punto de entrada (main.c)
├── _modules/      ← Módulos completos
├── _pcb/          ← Configuraciones de hardware
├── _system/       ← Sistema core EMIC
├── _templates/    ← Templates de proyectos
└── _util/         ← Utilidades generales
```

**Propósito:** Biblioteca central de componentes creados por la comunidad.

### 4.2 EMIC-Libraries

**Definición:** Archivos de código C con **anotaciones EMIC-Codify**.

**Características:**
- Código C estándar (.c y .h)
- Tags DOXYGEN para publicación (`@fn`, `@alias`, etc.)
- Comandos EMIC-Codify intercalados
- Documentación integrada

**Ejemplo:**

```c
// led.c - EMIC-Library
EMIC:tag(driverName = LEDs)

/**
 * @fn void LED_state(uint8_t state);
 * @alias led.state
 * @brief Change LED state
 * @param state 1=on, 0=off, 2=toggle
 * @return Nothing
 */
void LED_state(uint8_t state) {
    // Implementación...
}
```

**Diferencia con código C normal:**
- Código C normal: Solo compilable
- EMIC-Library: Compilable + Procesable + Autodocumentado

### 4.3 EMIC-Codify

**Definición:** Lenguaje especializado para **gestión y generación de código**.

**Propósito:**
- Manipular archivos de texto
- Sustituir macros y variables
- Copiar y transformar código
- Controlar flujo de generación

**Comandos principales:**

| Comando | Función |
|---------|---------|
| `EMIC:setInput()` | Procesar archivo |
| `EMIC:setOutput()` | Definir salida |
| `EMIC:copy()` | Copiar y procesar |
| `EMIC:define()` | Definir macro |
| `.{key}.` | Sustituir macro |
| `EMIC:if()` | Condicional |
| `EMIC:foreach()` | Iteración |

**Ejemplo:**

```
EMIC:define(ledName, statusLed)
EMIC:copy(DEV:_api/LEDs/led.c > TARGET:led_.{ledName}..c, name=.{ledName}.)
```

Resultado: Crea `led_statusLed.c` con el nombre parametrizado.

### 4.4 EMIC-Module

**Definición:** Unidad completa de **Hardware + Firmware + Configuración**.

**Componentes:**

```
Module/
├── System/                  ← Configuración
│   ├── generate.emic       ← Script de generación
│   ├── deploy.emic         ← Script de deployment
│   ├── config.json         ← Configuración dinámica
│   ├── module.json         ← Metadata
│   └── program.xml         ← Script del integrador
└── Target/                  ← Código generado
    ├── main.c
    ├── led.c
    └── ...
```

**Propósito:** Encapsular solución completa lista para usar.

### 4.5 Tags (Etiquetas)

**Definición:** Anotaciones especiales para **publicar recursos** en EMIC Discovery.

**Formato DOXYGEN:**

```c
/**
 * @fn <signature>
 * @alias <nombre_en_editor>
 * @brief <descripción>
 * @param <parámetro> <descripción>
 * @return <descripción>
 */
```

**Formato JSON:**

```
EMIC:json(type = Configurator)
{
    'name': 'RS232prot',
    'brief': 'RS232 Protocol',
    'legend': 'Select RS232 Protocol',
    'options': [...]
}
```

**Diferencia con Macros:**
- **Tags:** Para Discovery (publicación)
- **Macros:** Para Generate (sustitución)

### 4.6 Macros

**Definición:** Variables de texto que se sustituyen durante EMIC Generate.

**Grupos de Macros:**

| Grupo | Descripción | Scope |
|-------|-------------|-------|
| `local` | Parámetros del comando actual | Comando |
| `global` | Definidas con EMIC:define() | Archivo |
| `custom` | Grupos personalizados | Definido |

**Ejemplo:**

```
EMIC:define(led.pin, RA0)
EMIC:define(led.port, PORTA)

// Luego...
.{led.pin}. = 1;  // Se convierte en: RA0 = 1;
```

**Búsqueda jerárquica:**
1. Busca en `local`
2. Si no existe, busca en `global`
3. Si no existe, error

---

## 5. Flujo de Datos Completo

Aquí vemos el recorrido completo desde que creas código hasta que se programa en el MCU.

### 5.1 Diagrama Simplificado del Sistema EMIC

![Diagrama EMIC](../../../INFO/DiagramaEMIC.jpg)

**Explicación del diagrama:**

1. **SOURCE Documents (Repositories):**
   - Contiene tus EMIC-Libraries
   - APIs, Drivers, Módulos

2. **EMIC Discovery:**
   - Analiza SOURCE Documents
   - Extrae Tags
   - Genera catálogo de recursos

3. **user SCRIPT:**
   - Integrador crea lógica en EMIC-Editor
   - Usa recursos catalogados

4. **EMIC Transcriptor:**
   - Convierte Script visual a formato intermedio

5. **intermediate document:**
   - Formato procesable por EMIC Merge

6. **EMIC Merge:**
   - Fusiona intermediate + SOURCE Documents
   - Genera TARGET Documents

7. **TARGET Documents:**
   - Código C, HTML, TeX, etc.
   - Listo para compilar

8. **EMIC Compiler:**
   - Compila TARGET Documents

9. **FINAL Documents:**
   - Firmware .hex
   - PDFs, HTMLs, etc.

### 5.2 Flujo Paso a Paso

#### Paso 1: Desarrollo (TÚ)

```
[Desarrollador]
     │
     ├─> Escribe código C
     ├─> Agrega Tags DOXYGEN
     ├─> Crea archivo .emic
     ├─> Define dependencias
     │
     ▼
[EMIC-Library Lista]
```

#### Paso 2: Discovery (Automático)

```
[EMIC-Library]
     │
     ├─> EMIC Discovery lee archivo
     ├─> Encuentra Tags (@fn, @alias, etc.)
     ├─> Extrae metadata
     │
     ▼
[Catálogo de Recursos]
     │
     └─> Publica en EMIC-Editor
```

#### Paso 3: Integración (Integrador)

```
[EMIC-Editor]
     │
     ├─> Integrador ve tus funciones
     ├─> Arrastra y conecta
     ├─> Configura parámetros
     │
     ▼
[Script (XML/JSON)]
```

#### Paso 4: Generación (Automático)

```
[Script] + [EMIC-Libraries]
     │
     ├─> EMIC Generate ejecuta generate.emic
     ├─> Procesa comandos EMIC-Codify
     ├─> Sustituye macros
     ├─> Fusiona todo
     │
     ▼
[Código C Compilable]
```

#### Paso 5: Compilación (Automático)

```
[Código C]
     │
     ├─> XC8/XC16/XC32 Compiler
     ├─> Optimizaciones
     ├─> Linking
     │
     ▼
[Firmware .hex]
```

#### Paso 6: Programación (Integrador)

```
[Firmware .hex]
     │
     ├─> MPLAB IPE / PICkit
     ├─> Programa microcontrolador
     │
     ▼
[Dispositivo Funcionando]
```

---

## 6. Arquitectura en Runtime

Una vez que el firmware está corriendo en el microcontrolador, la arquitectura EMIC define cómo se organiza el código.

### 6.1 Diagrama de Arquitectura en Runtime

![Arquitectura Runtime](../../../INFO/Arquitectura_EMIC.jpg)

**Explicación del diagrama:**

**Inicialización:**
1. **Power On** → Inicialización del μC
2. **Inicialización de controladores** → Setup de periféricos
3. **Inicialización de Drivers** → Setup de cada driver
4. **Inicialización de recursos de hardware** → Config específica

**Loop Principal:**
- **Polling de drivers** → Verificación periódica
- **Polling de recursos de hardware** → Lectura de estados

**Lógica de Aplicación:**
- **Funciones de usuario (A, B, C)** → Tu código custom
- Llamadas a **APIs** (líneas rojas)
- Callbacks desde **Eventos** (líneas naranjas)

**Interacciones:**
- **Interrupciones (Int 1, 2, 3)** → Cambios de estado de hardware
- **Eventos** → Callbacks a funciones de usuario
- **APIs** → Abstracciones de alto nivel

### 6.2 Capas de la Arquitectura en Runtime

```
┌─────────────────────────────────────────────────┐
│         CAPA DE APLICACIÓN (Usuario)            │
│  • Lógica del integrador                        │
│  • Funciones de usuario                         │
│  • Callbacks de eventos                         │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│           CAPA DE APIs (Tu trabajo)             │
│  • LEDs, Timers, Sensores, etc.                 │
│  • Abstracción de alto nivel                    │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│         CAPA DE DRIVERS (Tu trabajo)            │
│  • I2C, UART, SPI, USB, etc.                    │
│  • Control de periféricos                       │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│           CAPA DE HAL (Sistema)                 │
│  • GPIO, ADC, PWM, Timer, etc.                  │
│  • Abstracción de hardware                      │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│         CAPA DE HARDWARE (_hard)                │
│  • Registros específicos de MCU                 │
│  • PIC16F, PIC18F, PIC24F, dsPIC33              │
└─────────────────────────────────────────────────┘
```

### 6.3 Flujo de Eventos

**Evento disparado por hardware:**

```
[Hardware Interrupt]
        ↓
[ISR en _hard]
        ↓
[Driver procesa]
        ↓
[Genera Evento EMIC]
        ↓
[Callback de usuario]
```

**Ejemplo concreto:**

```
[Timer overflow]
        ↓
[ISR_Timer1()]
        ↓
[SystemTimer_tick()]
        ↓
[Evento: timeOut]
        ↓
[myCallback()]  ← Tu código
```

---

## 7. Relación entre Componentes

### 7.1 Mapa de Dependencias

```
           _util (Utilidades generales)
              ↑
              │ usa
              │
           _api (APIs alto nivel)
              ↑
              │ usa
              │
        _drivers (Drivers específicos)
              ↑
              │ usa
              │
           _hal (HAL)
              ↑
              │ usa
              │
          _hard (Hardware específico)
              ↑
              │ accede
              │
         [HARDWARE REAL]
```

**Reglas de dependencia:**
- `_util` → No depende de nadie (puro C)
- `_api` → Puede usar `_drivers`, `_hal`, `_util`
- `_drivers` → Puede usar `_hal`, `_util`
- `_hal` → Puede usar `_hard`, `_util`
- `_hard` → Acceso directo a registros del MCU

### 7.2 Ejemplo de Cadena de Dependencias

**Caso: API de LED que parpadea**

```
LED_blink()  [_api/Indicators/LEDs/]
    │
    ├─> usa Timer_start()  [_api/Timers/]
    │       │
    │       └─> usa SystemTimer  [_drivers/SystemTimer/]
    │               │
    │               └─> usa HAL_Timer  [_hal/Timer/]
    │                       │
    │                       └─> usa TMR1_registers  [_hard/PIC18F/]
    │
    └─> usa GPIO_write()  [_hal/GPIO/]
            │
            └─> usa PORT_registers  [_hard/PIC18F/]
```

### 7.3 Separación de Responsabilidades

| Capa | Responsabilidad | Ejemplo |
|------|----------------|---------|
| **_util** | Operaciones genéricas | String manipulation, math |
| **_api** | Funcionalidad de negocio | LED blink, Sensor read |
| **_drivers** | Control de periférico | I2C transaction, UART tx/rx |
| **_hal** | Abstracción de HW | GPIO set/clear, ADC read |
| **_hard** | Acceso a registros | PORTA = 0x01, TMR1H = 0xFF |

---

## 8. Comparación con Arquitecturas Tradicionales

### 8.1 Desarrollo Tradicional vs EMIC

| Aspecto | Tradicional | EMIC |
|---------|-------------|------|
| **Organización** | Cada quien a su manera | Estructura estándar |
| **Reutilización** | Copy-paste entre proyectos | Componentes versionados |
| **Documentación** | Separada del código | Integrada (Tags) |
| **Abstracción** | Manual y ad-hoc | Capas estandarizadas |
| **Portabilidad** | Reescritura casi completa | HAL + _hard intercambiable |
| **Colaboración** | Difícil | Facilitada por estándares |
| **Curva de aprendizaje** | Empinada por proyecto | Una vez, aplica siempre |

### 8.2 Ejemplo Comparativo

**Código Tradicional:**

```c
// main.c - Todo en un solo archivo
#include <xc.h>

#define LED_PIN PORTAbits.RA0

void delay_ms(uint16_t ms) { /* impl */ }

void main(void) {
    TRISAbits.TRISA0 = 0; // LED output

    while(1) {
        LED_PIN = 1;
        delay_ms(500);
        LED_PIN = 0;
        delay_ms(500);
    }
}
```

**Problema:**
- No reutilizable
- No portable a otro pin
- No documentado
- Hardcoded
- Difícil de mantener

**Código EMIC:**

```c
// API LED (led.h)
/**
 * @fn void LED_blink(uint16_t period);
 * @alias led.blink
 * @brief Blink LED with specified period
 * @param period Time in ms for one complete cycle
 */
void LED_blink(uint16_t period);

// Integrador usa en EMIC-Editor:
// led.blink(1000); // Drag & drop, configura 1000ms
```

**Ventajas:**
- Reutilizable en cualquier proyecto
- Portable (pin configurable)
- Documentado automáticamente
- Configurable visualmente
- Mantenible (actualización centralizada)

---

## 9. Consideraciones de Diseño

### 9.1 Principios SOLID en EMIC

Aunque EMIC es para C (no OOP), aplica principios similares:

1. **Single Responsibility:**
   - Cada API/Driver una sola función
   - LED API: Solo LEDs, no timers ni UART

2. **Open/Closed:**
   - Extensible mediante nuevas APIs
   - Sin modificar código existente

3. **Liskov Substitution:**
   - HAL intercambiable
   - Mismo comportamiento, diferente implementación

4. **Interface Segregation:**
   - APIs específicas, no monolíticas
   - LED, Timer, UART separados

5. **Dependency Inversion:**
   - APIs dependen de abstracciones (HAL)
   - No de implementaciones concretas (_hard)

### 9.2 Patrones de Diseño Aplicados

| Patrón | Aplicación en EMIC |
|--------|-------------------|
| **Strategy** | HAL permite cambiar estrategia de HW |
| **Template Method** | generate.emic define flujo, APIs contenido |
| **Factory** | Discovery crea catálogo de recursos |
| **Observer** | Sistema de Eventos y Callbacks |
| **Adapter** | HAL adapta hardware específico |

---

## 10. Ventajas Arquitectónicas

### 10.1 Para Desarrolladores

1. **Foco en lógica, no en boilerplate:**
   - El sistema maneja la integración
   - Tú te enfocas en funcionalidad

2. **Testabilidad:**
   - Componentes independientes
   - Fácil de probar por separado

3. **Mantenibilidad:**
   - Cambios localizados
   - No efecto dominó

4. **Escalabilidad:**
   - Agregar componentes sin romper existentes

### 10.2 Para Integradores

1. **Abstracción de complejidad:**
   - No necesitan entender bajo nivel
   - Uso visual e intuitivo

2. **Rapidez de desarrollo:**
   - Reutilización masiva
   - Drag & drop

3. **Confiabilidad:**
   - Componentes probados
   - Validados por comunidad

### 10.3 Para el Ecosistema

1. **Crecimiento orgánico:**
   - Cada componente nuevo aumenta valor
   - Efecto red

2. **Calidad creciente:**
   - Feedback continuo
   - Mejoras iterativas

3. **Innovación distribuida:**
   - Múltiples expertos contribuyen
   - Especialización

---

## 11. Resumen del Capítulo

### Conceptos Clave Aprendidos

✅ **4 Procesos:** Discovery, Editor, Generate, Compiler
✅ **Volúmenes Lógicos:** DEV:, TARGET:, SYS:, USER:
✅ **EMIC SDK:** Repositorio central de componentes
✅ **EMIC-Libraries:** Código C con anotaciones
✅ **EMIC-Codify:** Lenguaje de gestión de código
✅ **EMIC-Module:** Hardware + Firmware + Config
✅ **Tags vs Macros:** Publicación vs Sustitución
✅ **Flujo completo:** Desarrollo → Discovery → Integración → Generación → Compilación
✅ **Arquitectura en runtime:** Capas de abstracción
✅ **Separación de concerns:** Desarrollador vs Integrador vs Sistema

### Próximo Paso

Ahora que entiendes la **arquitectura técnica**, el siguiente capítulo te proporcionará un **glosario completo** de todos los términos EMIC para referencia rápida.

**Próximo capítulo:** [Cap 03 - Glosario y Vocabulario EMIC →](03_Glosario.md)

En el Capítulo 03 encontrarás:
- Definiciones precisas de todos los términos
- Referencias cruzadas
- Ejemplos de uso
- Índice alfabético

---

## 12. Diagrama de Referencia Rápida

```
┌──────────────────────────────────────────────────────────────┐
│               ARQUITECTURA EMIC - REFERENCIA                 │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  TU TRABAJO (Desarrollador):                                │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Crear EMIC-Libraries con Tags                      │    │
│  │ • APIs (_api/)                                     │    │
│  │ • Drivers (_drivers/)                              │    │
│  │ • Módulos (_modules/)                              │    │
│  └────────────────────────────────────────────────────┘    │
│                          ↓                                   │
│  PROCESO AUTOMÁTICO (Sistema EMIC):                         │
│  ┌────────────────────────────────────────────────────┐    │
│  │ EMIC Discovery                                     │    │
│  │ • Extrae Tags                                      │    │
│  │ • Publica en Editor                                │    │
│  └────────────────────────────────────────────────────┘    │
│                          ↓                                   │
│  INTEGRADOR (Usa tus recursos):                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │ EMIC Editor                                        │    │
│  │ • Drag & drop                                      │    │
│  │ • Crea Script                                      │    │
│  └────────────────────────────────────────────────────┘    │
│                          ↓                                   │
│  PROCESO AUTOMÁTICO (Sistema EMIC):                         │
│  ┌────────────────────────────────────────────────────┐    │
│  │ EMIC Generate                                      │    │
│  │ • Fusiona tu código + Script                       │    │
│  │ • Genera código C                                  │    │
│  └────────────────────────────────────────────────────┘    │
│                          ↓                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │ EMIC Compiler                                      │    │
│  │ • XC8/XC16/XC32                                    │    │
│  │ • Genera .hex                                      │    │
│  └────────────────────────────────────────────────────┘    │
│                          ↓                                   │
│  RESULTADO:                                                  │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Firmware funcionando en microcontrolador           │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

[← Anterior: Introducción](01_Introduccion.md) | [Siguiente: Glosario →](03_Glosario.md)

---

*Capítulo 02 - Manual de Desarrollo EMIC SDK v1.0*
*Última actualización: Noviembre 2025*
