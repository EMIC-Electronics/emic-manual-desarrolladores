# Capítulo 21: Crear tu Primer Proyecto EMIC

## Índice
1. [Introducción](#introducción)
2. [¿Qué es un Proyecto EMIC?](#qué-es-un-proyecto-emic)
3. [Diferencia: SDK vs Proyecto](#diferencia-sdk-vs-proyecto)
4. [Requisitos Previos](#requisitos-previos)
5. [Estructura de un Proyecto](#estructura-de-un-proyecto)
6. [Tutorial Paso a Paso: Proyecto "Blink LED"](#tutorial-paso-a-paso-proyecto-blink-led)
7. [Configurar el Módulo](#configurar-el-módulo)
8. [Escribir generate.emic](#escribir-generateemic)
9. [Programar Lógica en EMIC-Editor](#programar-lógica-en-emic-editor)
10. [Generar Código C](#generar-código-c)
11. [Compilar el Firmware](#compilar-el-firmware)
12. [Verificar y Depurar](#verificar-y-depurar)
13. [Proyecto Completo: Sistema de Monitoreo](#proyecto-completo-sistema-de-monitoreo)
14. [Buenas Prácticas](#buenas-prácticas)
15. [Errores Comunes y Soluciones](#errores-comunes-y-soluciones)
16. [Resumen del Capítulo](#resumen-del-capítulo)

---

## Introducción

Este capítulo marca el inicio de la **Sección 4: Desarrollo Práctico**, donde pasamos de la teoría a la práctica real. Aquí aprenderás a **crear tu primer proyecto EMIC desde cero**, paso a paso, hasta obtener un firmware compilado y funcional.

### ¿Qué vamos a construir?

En este capítulo crearás **dos proyectos completos**:
1. **Blink LED**: El "Hola Mundo" de sistemas embebidos
2. **Sistema de Monitoreo**: Proyecto más complejo con múltiples componentes

### Prerrequisitos

Antes de comenzar, debes haber completado:
- ✅ Sección 1: Introducción al SDK EMIC
- ✅ Sección 2: Estructura del SDK
- ✅ Sección 3: EMIC-Codify Language

---

## ¿Qué es un Proyecto EMIC?

Un **Proyecto EMIC** es una **solución específica para un problema real** creada por un **integrador** utilizando los recursos disponibles en un **Repositorio EMIC (SDK)**.

### Definición Formal

> **Proyecto EMIC**: Conjunto de módulos configurados, lógica personalizada y archivos de compilación que, al procesarse con EMIC-Generate, producen un firmware compilable (.hex) para un microcontrolador específico.

### Características de un Proyecto

```
Proyecto EMIC = SDK (recursos) + Configuración (parámetros) + Lógica (integrador)
                        ↓
                  EMIC-Generate
                        ↓
                  Código C compilable
                        ↓
                  XC8/XC16/XC32
                        ↓
                  Firmware.hex
```

### Componentes de un Proyecto

1. **Metadata del proyecto** (`project.json`)
2. **Uno o más módulos** (carpetas con System/ y Target/)
3. **Configuración de cada módulo** (config.json, module.json)
4. **Scripts de generación** (generate.emic, deploy.emic)
5. **Lógica del integrador** (userFncFile.c, program.xml)
6. **Código generado** (Target/ folder)

---

## Diferencia: SDK vs Proyecto

Es **crítico** entender esta distinción:

| Aspecto | Repositorio EMIC (SDK) | Proyecto EMIC |
|---------|------------------------|---------------|
| **Es un** | Biblioteca de componentes | Solución específica |
| **Creado por** | Desarrolladores | Integradores |
| **Contiene** | Templates reutilizables | Módulos instanciados |
| **Propósito** | Reutilización en múltiples proyectos | Resolver problema específico |
| **Ubicación** | `DEV:/` (repositorio Git) | `USER:/My Projects/` |
| **Resultado** | Recursos indexados (Discovery) | Firmware compilable (.hex) |
| **Archivos clave** | _api/, _drivers/, _hal/, _hard/ | System/generate.emic, Target/*.c |
| **Versionado** | Git (público/privado) | Proyecto individual |

### Ejemplo Visual

```
┌──────────────────────────────────────────────────────────────┐
│                  SDK EMIC (Desarrollador)                    │
│                                                              │
│  _api/Indicators/LEDs/                                       │
│  ├── led.emic           ← Template genérico                 │
│  ├── inc/led.h          ← Código parametrizado              │
│  └── src/led.c          ← Usa .{name}., .{pin}.             │
│                                                              │
└──────────────────────────────────────────────────────────────┘
                         │
                         │ Integrador usa SDK
                         ↓
┌──────────────────────────────────────────────────────────────┐
│            Proyecto EMIC: "Sistema_Semaforo"                 │
│                     (Integrador)                             │
│                                                              │
│  Sistema_Semaforo/                                           │
│  ├── System/                                                 │
│  │   ├── generate.emic  ← Instancia 3 LEDs:                 │
│  │   │                     led_rojo (pin A0)                 │
│  │   │                     led_amarillo (pin A1)             │
│  │   │                     led_verde (pin A2)                │
│  │   └── userFncFile.c  ← Lógica del semáforo               │
│  └── Target/                                                 │
│      ├── led_rojo.c      ← Código generado                   │
│      ├── led_amarillo.c  ← Código generado                   │
│      └── led_verde.c     ← Código generado                   │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## Requisitos Previos

### Hardware Requerido

Para seguir este tutorial necesitas:
- **Placa de desarrollo** compatible con EMIC (ej: HRD_Development_Board)
- **Microcontrolador** PIC24/dsPIC33/PIC32
- **Programador** (PICkit 3, PICkit 4, ICD3, etc.)
- **LED** conectado a un pin GPIO (o usar LED onboard)

### Software Requerido

- **MPLAB X IDE** (v5.40 o superior)
- **XC8/XC16/XC32 Compiler** según tu MCU
- **EMIC SDK** clonado localmente
- **EMIC-Editor** (interfaz web o local)

### Conocimientos Requeridos

- ✅ Conceptos básicos de sistemas embebidos
- ✅ Estructura del SDK EMIC (Sección 2)
- ✅ Sintaxis EMIC-Codify (Sección 3)
- ✅ Nociones básicas de C

---

## Estructura de un Proyecto

### Estructura de Directorios

```
USER:/My Projects/MiProyecto/     # Carpeta raíz del proyecto
│
├── project.json                   # Metadata del proyecto
│
├── Module1/                       # Primer módulo (ej: Development_Board)
│   │
│   ├── System/                    # Archivos de configuración
│   │   ├── module.json           # Info del módulo (nombre, versión)
│   │   ├── config.json           # Configuración dinámica
│   │   ├── deploy.emic           # Script de deployment
│   │   ├── generate.emic         # Script de generación (CLAVE)
│   │   ├── program.xml           # Código visual (EMIC-Editor)
│   │   ├── userFncFile.c         # Código C del integrador
│   │   ├── inc/userFncFile.h     # Header del integrador
│   │   └── EMIC-TABS/
│   │       ├── Resources/        # Recursos del driver
│   │       └── Data/             # Variables del usuario
│   │
│   └── Target/                   # Código C generado (SALIDA)
│       ├── *.c                   # Archivos C generados
│       ├── *.h                   # Headers generados
│       ├── Makefile              # Build script
│       ├── generate.txt          # Log de generación
│       └── dist/                 # Firmware compilado (.hex)
│
├── Module2/                       # Segundo módulo (opcional)
│   ├── System/
│   └── Target/
│
└── Module3/                       # Tercer módulo (opcional)
    ├── System/
    └── Target/
```

### Archivo Clave: project.json

```json
{
  "name": "MiProyecto",
  "autor": "Juan Pérez",
  "Description": "Sistema de monitoreo de temperatura",
  "Visibility": "Private",
  "Status": "Active",
  "Version": "1.0.0",
  "GitHubRepositoryUrl": ""
}
```

### Archivo Clave: module.json

```json
{
  "moduleName": "Development_Board",
  "version": "1.0.0",
  "description": "Módulo principal del proyecto",
  "category": "Development_Board"
}
```

---

## Tutorial Paso a Paso: Proyecto "Blink LED"

Vamos a crear el proyecto más simple: **hacer parpadear un LED**.

### Paso 1: Crear la Estructura del Proyecto

```
USER:/My Projects/Blink_LED/
├── project.json
└── Main/
    ├── System/
    │   ├── module.json
    │   ├── generate.emic
    │   └── userFncFile.c
    └── Target/
```

### Paso 2: Crear project.json

```json
{
  "name": "Blink_LED",
  "autor": "Tu Nombre",
  "Description": "Mi primer proyecto EMIC - LED parpadeante",
  "Visibility": "Private",
  "Status": "Active",
  "Version": "1.0.0",
  "GitHubRepositoryUrl": ""
}
```

### Paso 3: Crear module.json

```json
{
  "moduleName": "Main",
  "version": "1.0.0",
  "description": "Módulo principal - Blink LED",
  "category": "Development_Board"
}
```

### Paso 4: Escribir generate.emic

Este es el **archivo más importante**. Aquí defines qué componentes del SDK usar:

```emic
EMIC:setOutput(TARGET:generate.txt)

    //-------------- Hardware Config ---------------------
    EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_Development_Board)

    //------------------- Process EMIC-Generate files result ----------------
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    //------------------- APIs -----------------------

    // LED1 en pin A0
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led1,pin=A0_Pin)

    // Timer para controlar parpadeo (1 segundo)
    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)

    //-------------------- main  -----------------------
    EMIC:setInput(DEV:_main/baremetal/main.emic)

    //------------------- Copy EMIC-Generate files result ----------------
    EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
    EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)

    //------------------- Set userFncFile.c as a compiler module ----------------
    EMIC:define(c_modules.userFncFile,userFncFile)

    //------------------- Add all compiler modules to the project. ----------------
    EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

### Explicación Línea por Línea

```emic
// 1. Redirigir salida a generate.txt (log)
EMIC:setOutput(TARGET:generate.txt)

// 2. Configurar hardware (placa de desarrollo)
EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_Development_Board)
```
- Define qué placa usas
- Carga configuración de pines, clock, etc.

```emic
// 3. Procesar recursos del EMIC-Editor
EMIC:setInput(SYS:usedFunction.emic)
EMIC:setInput(SYS:usedEvent.emic)
```
- Archivos generados por EMIC-Editor
- Contienen funciones y eventos que el integrador programó

```emic
// 4. Incluir API de LED
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led1,pin=A0_Pin)
```
- Instancia el template `led.emic`
- Parámetros:
  - `name=led1` → Todas las funciones se llamarán `led1_*()`
  - `pin=A0_Pin` → LED conectado al pin A0

```emic
// 5. Incluir API de Timer
EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)
```
- Instancia el timer número 1
- Permite crear delays y eventos temporales

```emic
// 6. Incluir main.c baremetal
EMIC:setInput(DEV:_main/baremetal/main.emic)
```
- Punto de entrada del firmware
- Inicializa hardware y ejecuta loop principal

```emic
// 7. Copiar código del integrador
EMIC:copy(SYS:userFncFile.h > TARGET:inc/userFncFile.h)
EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
```
- `userFncFile.c` contiene la lógica que escribirás
- Se copia desde System/ a Target/

```emic
// 8. Añadir userFncFile.c como módulo de compilación
EMIC:define(c_modules.userFncFile,userFncFile)
```
- Registra el archivo para que se incluya en el Makefile

```emic
// 9. Copiar proyecto MPLAB X (Makefile, configuraciones)
EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)
```
- Copia template de MPLAB X
- Incluye Makefile con todos los módulos definidos

### Paso 5: Escribir userFncFile.c

Este archivo contiene **tu lógica**:

```c
#include "inc/userFncFile.h"

// Variable global para contar ciclos
static int contador = 0;

/**
 * @fn void EMIC_INIT_USER(void)
 * @brief Inicialización del usuario (se ejecuta una vez)
 *
 * Código etiquetado para EMIC-Discovery
 * @@EMIC_TAG::{FUNCTION,Event:INIT,Type:void}
 */
void EMIC_INIT_USER(void) {
    // Inicializar LED apagado
    led1_Off();

    // Configurar timer a 1 segundo
    timer1_SetPeriod(1000);  // 1000 ms
    timer1_Start();
}

/**
 * @fn void EMIC_LOOP_USER(void)
 * @brief Loop principal del usuario (se ejecuta constantemente)
 *
 * @@EMIC_TAG::{FUNCTION,Event:LOOP,Type:void}
 */
void EMIC_LOOP_USER(void) {
    // Verificar si pasó 1 segundo
    if (timer1_HasElapsed()) {
        // Toggle LED
        led1_Toggle();

        // Incrementar contador
        contador++;

        // Reiniciar timer
        timer1_Restart();
    }
}
```

### Paso 6: Escribir userFncFile.h

```c
#ifndef USERFNCFILE_H
#define USERFNCFILE_H

#include <stdint.h>
#include <stdbool.h>

// Incluir APIs utilizadas
#include "led_led1.h"
#include "timer_api1.h"

// Prototipos de funciones del usuario
void EMIC_INIT_USER(void);
void EMIC_LOOP_USER(void);

#endif // USERFNCFILE_H
```

---

## Programar Lógica en EMIC-Editor

EMIC-Editor es la interfaz visual para programar. Aquí puedes:
1. **Seleccionar recursos** del SDK (funciones publicadas)
2. **Conectar bloques** visualmente
3. **Generar program.xml** automáticamente

### Ejemplo: Blink LED en EMIC-Editor

```xml
<!-- program.xml generado automáticamente -->
<Program>
  <Event name="INIT">
    <Block type="FunctionCall" function="led1_Off" />
    <Block type="FunctionCall" function="timer1_SetPeriod">
      <Param name="period" value="1000" />
    </Block>
    <Block type="FunctionCall" function="timer1_Start" />
  </Event>

  <Event name="LOOP">
    <Block type="If">
      <Condition>
        <Block type="FunctionCall" function="timer1_HasElapsed" />
      </Condition>
      <Then>
        <Block type="FunctionCall" function="led1_Toggle" />
        <Block type="FunctionCall" function="timer1_Restart" />
      </Then>
    </Block>
  </Event>
</Program>
```

**Nota**: Puedes usar EMIC-Editor visual O escribir código C manualmente. Ambos son válidos.

---

## Generar Código C

### Ejecutar EMIC-Generate

```bash
# Desde la línea de comandos
emic-generate compile --project "USER:/My Projects/Blink_LED" --module Main
```

### ¿Qué sucede internamente?

1. **EMIC-Generate lee** `System/generate.emic`
2. **Procesa todas las directivas** EMIC:setInput, EMIC:copy
3. **Resuelve dependencias** recursivamente
4. **Sustituye variables** .{name}., .{pin}.
5. **Genera archivos C** en `Target/`

### Resultado: Archivos Generados

```
Target/
├── generate.txt              # Log detallado del proceso
├── led_led1.c                # Código LED generado
├── led_led1.h
├── timer_api1.c              # Código Timer generado
├── timer_api1.h
├── userFncFile.c             # Tu código (copiado)
├── userFncFile.h
├── main.c                    # main.c baremetal
├── Makefile                  # Build script
└── nbproject/                # Proyecto MPLAB X
```

### Ejemplo: led_led1.c Generado

```c
// Generado por EMIC-Generate
// Template: DEV:_api/Indicators/LEDs/led.emic
// Parámetros: name=led1, pin=A0_Pin

#include "led_led1.h"

void led1_Init(void) {
    // Configurar pin A0 como salida
    TRISAbits.TRISA0 = 0;
    led1_Off();
}

void led1_On(void) {
    LATAbits.LATA0 = 1;
}

void led1_Off(void) {
    LATAbits.LATA0 = 0;
}

void led1_Toggle(void) {
    LATAbits.LATA0 ^= 1;
}

bool led1_GetState(void) {
    return LATAbits.LATA0;
}
```

---

## Compilar el Firmware

### Opción 1: Desde MPLAB X IDE

1. Abrir proyecto: `Target/nbproject/`
2. Seleccionar dispositivo (PIC24FJ64GA002, etc.)
3. Compilar: **Production → Build Main Project**
4. Resultado: `Target/dist/production/firmware.hex`

### Opción 2: Desde Línea de Comandos (Make)

```bash
cd Target/
make clean
make all

# Resultado
ls dist/production/firmware.hex
```

### Opción 3: Desde EMIC-CLI

```bash
emic-generate compile --project "Blink_LED" --module Main --build
```

### Verificar Compilación Exitosa

```bash
# Debe mostrar:
BUILD SUCCESSFUL (exit value 0, total time: 5s)
```

---

## Verificar y Depurar

### 1. Verificar generate.txt

```bash
cat Target/generate.txt
```

Ejemplo de salida:
```
[INFO] Processing generate.emic...
[INFO] Loading PCB: HRD_Development_Board
[INFO] Including API: led.emic (name=led1, pin=A0_Pin)
[INFO]   - Copying led.h → TARGET:inc/led_led1.h
[INFO]   - Copying led.c → TARGET:led_led1.c
[INFO] Including API: timer_api.emic (name=1)
[INFO]   - Copying timer_api.h → TARGET:inc/timer_api1.h
[INFO]   - Copying timer_api.c → TARGET:timer_api1.c
[INFO] Copying userFncFile.c → TARGET:userFncFile.c
[INFO] Generation completed successfully!
[INFO] Files generated: 8
```

### 2. Verificar Makefile

```makefile
# Verificar que todos los módulos estén incluidos
SOURCES = \
    led_led1.c \
    timer_api1.c \
    userFncFile.c \
    main.c
```

### 3. Depurar Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| `File not found: DEV:_api/...` | SDK no encontrado | Verificar ruta al SDK |
| `Variable .{pin}. not substituted` | Parámetro no definido | Añadir `pin=X` al setInput |
| `Multiple definition of led_Init` | Instancia duplicada | Usar nombres únicos (led1, led2) |
| `Compiler error: unknown type` | Falta include | Verificar headers en userFncFile.h |

---

## Proyecto Completo: Sistema de Monitoreo

Ahora crearemos un proyecto más complejo: **Sistema de Monitoreo de Temperatura con Alarmas**.

### Especificaciones

**Hardware:**
- Sensor de temperatura (DHT22)
- 3 LEDs (verde, amarillo, rojo)
- Buzzer para alarma
- Display LCD para mostrar temperatura
- Comunicación UART para logs

**Lógica:**
- Leer temperatura cada 2 segundos
- LED verde: temperatura normal (< 25°C)
- LED amarillo: temperatura alta (25-30°C)
- LED rojo + buzzer: temperatura crítica (> 30°C)
- Mostrar temperatura en LCD
- Enviar logs por UART

### Estructura del Proyecto

```
USER:/My Projects/Sistema_Monitoreo/
├── project.json
└── Monitor_Temperatura/
    ├── System/
    │   ├── module.json
    │   ├── generate.emic
    │   ├── userFncFile.c
    │   └── inc/userFncFile.h
    └── Target/
```

### generate.emic Completo

```emic
EMIC:setOutput(TARGET:generate.txt)

    //-------------- Hardware Config ---------------------
    EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_Development_Board)

    //------------------- Process EMIC-Generate files result ----------------
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    //------------------- APIs -----------------------

    // LEDs de estado (verde, amarillo, rojo)
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led_verde,pin=A0_Pin)
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led_amarillo,pin=A1_Pin)
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led_rojo,pin=A2_Pin)

    // Buzzer para alarma
    EMIC:setInput(DEV:_api/Indicators/Buzzer/buzzer.emic,name=alarm,pin=B0_Pin)

    // Sensor de temperatura DHT22
    EMIC:setInput(DEV:_drivers/Temperature/DHT22/dht22.emic,name=temp_sensor,pin=B1_Pin)

    // Display LCD 16x2
    EMIC:setInput(DEV:_drivers/Display/LCD_16x2/lcd.emic,name=display,rs=B2_Pin,en=B3_Pin,d4=B4_Pin,d5=B5_Pin,d6=B6_Pin,d7=B7_Pin)

    // UART para logs (9600 baud)
    EMIC:setInput(DEV:_api/Wired_Communication/UART/uart.emic,name=uart1,port=1,baud=9600,buffer_size=128)

    // Timers
    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)  // Lectura de sensor (2s)
    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=2)  // Actualización LCD (500ms)

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

### userFncFile.c Completo

```c
#include "inc/userFncFile.h"
#include <stdio.h>

// Estados del sistema
typedef enum {
    ESTADO_NORMAL,
    ESTADO_ALTA,
    ESTADO_CRITICA
} EstadoTemperatura_t;

// Variables globales
static EstadoTemperatura_t estado_actual = ESTADO_NORMAL;
static float temperatura_actual = 0.0f;
static int lecturas_realizadas = 0;

// Umbrales de temperatura (°C)
#define TEMP_UMBRAL_ALTA     25.0f
#define TEMP_UMBRAL_CRITICA  30.0f

// Intervalos de tiempo (ms)
#define INTERVALO_LECTURA    2000   // 2 segundos
#define INTERVALO_LCD        500    // 500 ms

/**
 * @fn void EMIC_INIT_USER(void)
 * @brief Inicialización del sistema de monitoreo
 *
 * @@EMIC_TAG::{FUNCTION,Event:INIT,Type:void}
 */
void EMIC_INIT_USER(void) {
    char buffer[64];

    // Inicializar LEDs apagados
    led_verde_Off();
    led_amarillo_Off();
    led_rojo_Off();

    // Inicializar buzzer apagado
    alarm_Off();

    // Inicializar LCD
    display_Init();
    display_Clear();
    display_SetCursor(0, 0);
    display_Print("Sistema Monitor");
    display_SetCursor(0, 1);
    display_Print("Temperatura");

    // Delay para mostrar mensaje inicial
    __delay_ms(2000);
    display_Clear();

    // Inicializar UART
    uart1_Init();
    uart1_WriteString("=== Sistema de Monitoreo de Temperatura ===\r\n");
    uart1_WriteString("Iniciando...\r\n");

    // Configurar timers
    timer1_SetPeriod(INTERVALO_LECTURA);
    timer1_Start();

    timer2_SetPeriod(INTERVALO_LCD);
    timer2_Start();

    // Lectura inicial del sensor
    if (temp_sensor_Read()) {
        temperatura_actual = temp_sensor_GetTemperature();
        sprintf(buffer, "Temp inicial: %.1f C\r\n", temperatura_actual);
        uart1_WriteString(buffer);
    } else {
        uart1_WriteString("Error: No se pudo leer sensor\r\n");
    }

    // Estado inicial
    ActualizarEstado();
}

/**
 * @fn void EMIC_LOOP_USER(void)
 * @brief Loop principal del sistema
 *
 * @@EMIC_TAG::{FUNCTION,Event:LOOP,Type:void}
 */
void EMIC_LOOP_USER(void) {
    // Verificar si es momento de leer sensor (cada 2s)
    if (timer1_HasElapsed()) {
        LeerTemperatura();
        timer1_Restart();
    }

    // Verificar si es momento de actualizar LCD (cada 500ms)
    if (timer2_HasElapsed()) {
        ActualizarDisplay();
        timer2_Restart();
    }
}

/**
 * @fn void LeerTemperatura(void)
 * @brief Lee temperatura del sensor y actualiza estado
 */
void LeerTemperatura(void) {
    char buffer[64];

    // Leer sensor DHT22
    if (temp_sensor_Read()) {
        temperatura_actual = temp_sensor_GetTemperature();
        lecturas_realizadas++;

        // Log por UART
        sprintf(buffer, "[%04d] Temp: %.1f C | Estado: ",
                lecturas_realizadas, temperatura_actual);
        uart1_WriteString(buffer);

        // Actualizar estado según temperatura
        ActualizarEstado();

    } else {
        uart1_WriteString("ERROR: Fallo lectura sensor\r\n");
    }
}

/**
 * @fn void ActualizarEstado(void)
 * @brief Actualiza LEDs y alarmas según temperatura
 */
void ActualizarEstado(void) {
    EstadoTemperatura_t nuevo_estado;

    // Determinar nuevo estado
    if (temperatura_actual < TEMP_UMBRAL_ALTA) {
        nuevo_estado = ESTADO_NORMAL;
    } else if (temperatura_actual < TEMP_UMBRAL_CRITICA) {
        nuevo_estado = ESTADO_ALTA;
    } else {
        nuevo_estado = ESTADO_CRITICA;
    }

    // Actualizar LEDs y buzzer según estado
    switch (nuevo_estado) {
        case ESTADO_NORMAL:
            led_verde_On();
            led_amarillo_Off();
            led_rojo_Off();
            alarm_Off();
            uart1_WriteString("NORMAL\r\n");
            break;

        case ESTADO_ALTA:
            led_verde_Off();
            led_amarillo_On();
            led_rojo_Off();
            alarm_Off();
            uart1_WriteString("ALTA\r\n");
            break;

        case ESTADO_CRITICA:
            led_verde_Off();
            led_amarillo_Off();
            led_rojo_On();
            alarm_On();  // Activar buzzer
            uart1_WriteString("CRITICA!!!\r\n");
            break;
    }

    // Guardar estado actual
    estado_actual = nuevo_estado;
}

/**
 * @fn void ActualizarDisplay(void)
 * @brief Actualiza información en LCD
 */
void ActualizarDisplay(void) {
    char buffer[17];  // 16 caracteres + null terminator

    // Línea 1: Temperatura
    display_SetCursor(0, 0);
    sprintf(buffer, "Temp: %.1f C    ", temperatura_actual);
    display_Print(buffer);

    // Línea 2: Estado
    display_SetCursor(0, 1);
    switch (estado_actual) {
        case ESTADO_NORMAL:
            display_Print("Estado: NORMAL  ");
            break;
        case ESTADO_ALTA:
            display_Print("Estado: ALTA    ");
            break;
        case ESTADO_CRITICA:
            display_Print("Estado: CRITICA!");
            break;
    }
}
```

### userFncFile.h

```c
#ifndef USERFNCFILE_H
#define USERFNCFILE_H

#include <stdint.h>
#include <stdbool.h>
#include <xc.h>

// Incluir todas las APIs utilizadas
#include "led_led_verde.h"
#include "led_led_amarillo.h"
#include "led_led_rojo.h"
#include "buzzer_alarm.h"
#include "dht22_temp_sensor.h"
#include "lcd_display.h"
#include "uart_uart1.h"
#include "timer_api1.h"
#include "timer_api2.h"

// Prototipos de funciones del usuario
void EMIC_INIT_USER(void);
void EMIC_LOOP_USER(void);

// Funciones auxiliares
void LeerTemperatura(void);
void ActualizarEstado(void);
void ActualizarDisplay(void);

#endif // USERFNCFILE_H
```

### Flujo de Ejecución

```
┌──────────────────────────────────────────────────────────┐
│                   EMIC_INIT_USER()                       │
│  - Inicializar hardware                                  │
│  - Configurar LEDs, LCD, UART                            │
│  - Configurar timers (2s y 500ms)                        │
│  - Lectura inicial de temperatura                        │
└──────────────────────────────────────────────────────────┘
                         │
                         ↓
        ┌────────────────────────────────┐
        │     EMIC_LOOP_USER()           │
        │   (ejecuta constantemente)     │
        └────────────────────────────────┘
                  │
                  ├───→ Cada 2s: LeerTemperatura()
                  │              ├─→ temp_sensor_Read()
                  │              ├─→ ActualizarEstado()
                  │              └─→ Log UART
                  │
                  └───→ Cada 500ms: ActualizarDisplay()
                                    ├─→ display_SetCursor()
                                    └─→ display_Print()
```

### Resultado: Archivos Generados

```
Target/
├── generate.txt
├── led_led_verde.c / .h          # LED verde
├── led_led_amarillo.c / .h       # LED amarillo
├── led_led_rojo.c / .h           # LED rojo
├── buzzer_alarm.c / .h           # Buzzer
├── dht22_temp_sensor.c / .h      # Sensor DHT22
├── lcd_display.c / .h            # Display LCD
├── uart_uart1.c / .h             # UART
├── timer_api1.c / .h             # Timer 1 (2s)
├── timer_api2.c / .h             # Timer 2 (500ms)
├── userFncFile.c / .h            # Lógica del integrador
├── main.c                        # Main baremetal
├── Makefile
└── dist/production/firmware.hex  # Firmware compilado
```

---

## Buenas Prácticas

### 1. Organización de Proyectos

```
✅ BUENO:
USER:/My Projects/
├── Control_Motores/           # Un proyecto = una carpeta
├── Sistema_Riego/
└── Alarma_Seguridad/

❌ MALO:
USER:/My Projects/
├── Proyecto1/
├── test/
├── nuevo/
└── copia_proyecto1/
```

### 2. Nombrar Módulos

```
✅ BUENO:
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led_estado,pin=A0_Pin)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led_alarma,pin=A1_Pin)

❌ MALO:
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=l1,pin=A0_Pin)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=l2,pin=A1_Pin)
```

### 3. Comentar generate.emic

```emic
✅ BUENO:
//------------------- Sensores de Temperatura -----------------------
// Sensor DHT22 para ambiente interior (ubicación: sala principal)
EMIC:setInput(DEV:_drivers/Temperature/DHT22/dht22.emic,name=temp_interior,pin=B1_Pin)

// Sensor DS18B20 para ambiente exterior (ubicación: patio)
EMIC:setInput(DEV:_drivers/Temperature/DS18B20/ds18b20.emic,name=temp_exterior,pin=B2_Pin)

❌ MALO:
EMIC:setInput(DEV:_drivers/Temperature/DHT22/dht22.emic,name=t1,pin=B1_Pin)
EMIC:setInput(DEV:_drivers/Temperature/DS18B20/ds18b20.emic,name=t2,pin=B2_Pin)
```

### 4. Manejar Errores

```c
✅ BUENO:
if (temp_sensor_Read()) {
    temperatura = temp_sensor_GetTemperature();
    // Procesar temperatura
} else {
    uart1_WriteString("ERROR: Sensor no responde\r\n");
    led_error_On();
}

❌ MALO:
temp_sensor_Read();
temperatura = temp_sensor_GetTemperature();  // ¿Y si falló?
```

### 5. Usar Variables Descriptivas

```c
✅ BUENO:
#define TEMP_UMBRAL_CRITICA  30.0f
#define INTERVALO_LECTURA    2000  // ms

❌ MALO:
#define T  30.0f
#define I  2000
```

### 6. Documentar con DOXYGEN

```c
✅ BUENO:
/**
 * @fn void LeerTemperatura(void)
 * @brief Lee temperatura del sensor DHT22 y actualiza estado del sistema
 * @details Esta función:
 *   - Lee el sensor DHT22
 *   - Actualiza la variable global temperatura_actual
 *   - Llama a ActualizarEstado() si la lectura es exitosa
 *   - Envía log por UART con el resultado
 * @return void
 */
void LeerTemperatura(void);

❌ MALO:
void LeerTemperatura(void);  // lee temperatura
```

---

## Errores Comunes y Soluciones

### Error 1: SDK No Encontrado

```
ERROR: File not found: DEV:_api/Indicators/LEDs/led.emic
```

**Causa**: EMIC-Generate no encuentra el SDK

**Solución**:
1. Verificar ruta al SDK en configuración
2. Asegurar que `DEV:` apunta al directorio correcto
3. Verificar que el archivo existe en el SDK

### Error 2: Variable No Sustituida

```c
// En código generado aparece:
void .{name}._Init(void) {
    // ...
}
```

**Causa**: Parámetro no definido en generate.emic

**Solución**:
```emic
// ANTES (mal):
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic)

// DESPUÉS (bien):
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led1,pin=A0_Pin)
```

### Error 3: Instancia Duplicada

```
ERROR: Multiple definition of 'led_Init'
```

**Causa**: Dos instancias con el mismo `name`

**Solución**:
```emic
// ANTES (mal):
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led,pin=A0_Pin)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led,pin=A1_Pin)

// DESPUÉS (bien):
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led1,pin=A0_Pin)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led2,pin=A1_Pin)
```

### Error 4: Include No Encontrado

```c
fatal error: led_led1.h: No such file or directory
```

**Causa**: Falta incluir header en userFncFile.h

**Solución**:
```c
// En userFncFile.h
#include "led_led1.h"
#include "timer_api1.h"
// etc.
```

### Error 5: Función No Declarada

```
error: implicit declaration of function 'led1_Toggle'
```

**Causa**:
1. Falta include en userFncFile.h
2. API no incluida en generate.emic

**Solución**:
1. Verificar que existe `EMIC:setInput(DEV:_api/.../led.emic,name=led1,...)`
2. Incluir header en userFncFile.h

---

## Resumen del Capítulo

### Lo que Aprendiste

1. **¿Qué es un proyecto EMIC?**
   - Solución específica para un problema real
   - Combina SDK + configuración + lógica del integrador
   - Resultado: Firmware compilable (.hex)

2. **Diferencia SDK vs Proyecto**
   - SDK: Biblioteca de componentes reutilizables (desarrolladores)
   - Proyecto: Solución específica (integradores)

3. **Estructura de un proyecto**
   - project.json (metadata)
   - Módulos con System/ y Target/
   - generate.emic (script de generación)
   - userFncFile.c (lógica del integrador)

4. **Proceso completo**
   - Crear estructura
   - Escribir generate.emic
   - Programar lógica (C o EMIC-Editor)
   - Ejecutar EMIC-Generate
   - Compilar con XC8/XC16/XC32
   - Obtener firmware.hex

5. **Proyectos creados**
   - Blink LED (básico)
   - Sistema de Monitoreo (avanzado)

### Archivos Clave

| Archivo | Propósito |
|---------|-----------|
| project.json | Metadata del proyecto |
| module.json | Metadata del módulo |
| generate.emic | Script de generación (CRÍTICO) |
| userFncFile.c | Lógica del integrador |
| userFncFile.h | Headers del integrador |
| Target/generate.txt | Log del proceso |
| Target/Makefile | Build script |
| Target/dist/firmware.hex | Firmware compilado |

### Flujo Completo

```
1. Integrador crea estructura de proyecto
         ↓
2. Escribe generate.emic (qué APIs usar)
         ↓
3. Programa lógica (userFncFile.c o EMIC-Editor)
         ↓
4. Ejecuta EMIC-Generate
         ↓
5. EMIC-Generate fusiona SDK + lógica → Target/
         ↓
6. Compila con XC8/XC16/XC32
         ↓
7. Obtiene firmware.hex
         ↓
8. Programa microcontrolador
```

### Próximos Pasos

En los siguientes capítulos aprenderás:
- **Cap 22**: Desarrollar una API Personalizada
- **Cap 23**: Trabajar con Módulos
- **Cap 24**: Debugging y Testing
- **Cap 25**: Integración de Componentes
- **Cap 26**: Deployment y Producción

---

**¡Felicitaciones!** Has creado tu primer proyecto EMIC completo. Ahora tienes las bases para crear soluciones embebidas reales utilizando el SDK EMIC.

**Recuerda**: Un proyecto EMIC NO es código C tradicional. Es una **combinación de componentes del SDK configurados dinámicamente** mediante EMIC-Codify. Este enfoque modular te permite:
- ✅ Reutilizar componentes probados
- ✅ Configurar hardware sin modificar código
- ✅ Crear múltiples instancias del mismo componente
- ✅ Mantener código limpio y organizado

---

**Sección 4 - Capítulo 21**
Manual de Desarrollo EMIC SDK
Versión 1.0.0

---
