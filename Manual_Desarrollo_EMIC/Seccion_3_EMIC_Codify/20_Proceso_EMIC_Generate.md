# Capítulo 20: Proceso Completo de EMIC-Generate

## Índice
1. [Introducción](#introducción)
2. [Visión General del Proceso](#visión-general-del-proceso)
3. [Componentes del Sistema](#componentes-del-sistema)
4. [Fases de EMIC-Generate](#fases-de-emic-generate)
5. [Flujo Detallado Paso a Paso](#flujo-detallado-paso-a-paso)
6. [Archivos Generados](#archivos-generados)
7. [Proceso de Compilación C](#proceso-de-compilación-c)
8. [Debugging del Proceso](#debugging-del-proceso)
9. [Caso Práctico Completo](#caso-práctico-completo)
10. [Optimizaciones y Performance](#optimizaciones-y-performance)
11. [Troubleshooting](#troubleshooting)
12. [Resumen del Capítulo](#resumen-del-capítulo)

---

## Introducción

Este capítulo cierra la **Sección 3: EMIC-Codify Language** con una visión completa del proceso de compilación EMIC, desde que el integrador programa en EMIC-Editor hasta obtener el firmware `.hex` listo para grabar en el microcontrolador.

**Lo que aprenderás:**
- Cómo funciona EMIC-Generate internamente
- Cada fase del proceso de compilación
- Archivos intermedios y finales generados
- Cómo debuggear problemas
- El flujo completo end-to-end

**Este conocimiento te permitirá:**
- Entender qué hace el sistema "bajo el capó"
- Diagnosticar errores de compilación
- Optimizar tiempos de generación
- Crear componentes más eficientes

---

## Visión General del Proceso

### Pipeline Completo

```
┌─────────────────────────────────────────────────────────────┐
│  1. INTEGRADOR                                              │
│     - Programa lógica en EMIC-Editor                        │
│     - Selecciona módulos y configura parámetros             │
│     - Crea program.xml (representación visual)              │
└─────────────────────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────────────────────┐
│  2. EMIC-EDITOR                                             │
│     - Convierte program.xml → userFncFile.c                 │
│     - Genera generate.emic con configuración                │
│     - Crea config.json con parámetros dinámicos             │
└─────────────────────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────────────────────┐
│  3. EMIC-GENERATE (Compilador EMIC)                        │
│     - Lee generate.emic                                     │
│     - Procesa directivas EMIC: recursivamente              │
│     - Sustituye variables .{*}.                             │
│     - Copia templates con transformaciones                  │
│     - Genera código C en Target/                            │
└─────────────────────────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────────────────────────┐
│  4. COMPILADOR C (XC8/XC16/XC32)                           │
│     - Compila archivos .c                                   │
│     - Linkea bibliotecas                                    │
│     - Genera binario .elf                                   │
│     - Crea archivo .hex                                     │
└─────────────────────────────────────────────────────────────┘
        ↓
    Firmware.hex (listo para grabar)
```

### Tiempo Típico

| Fase | Tiempo Aproximado | Nota |
|------|-------------------|------|
| EMIC-Editor → generate.emic | < 1 segundo | Instantáneo |
| EMIC-Generate | 2-10 segundos | Depende de complejidad |
| Compilador C | 10-60 segundos | Depende de cantidad de código |
| **Total** | **15-70 segundos** | Proyecto típico |

---

## Componentes del Sistema

### 1. EMIC-Editor (Frontend)

**Responsabilidades:**
- Interfaz visual de programación
- Traducir bloques visuales → código C
- Generar `generate.emic` con configuración
- Crear `userFncFile.c` con lógica del integrador

**Inputs:**
- Interacción del usuario (drag & drop)
- Selección de módulos/APIs
- Configuración de parámetros

**Outputs:**
- `System/program.xml` (representación visual)
- `System/generate.emic` (script de generación)
- `System/userFncFile.c` (código del integrador)
- `System/config.json` (configuración dinámica)

---

### 2. EMIC-Generate (Motor de Generación)

**Responsabilidades:**
- Procesar archivos `.emic`
- Ejecutar directivas `EMIC:`
- Sustituir variables `.{*}.`
- Copiar templates con transformaciones
- Generar código C compilable

**Inputs:**
- `System/generate.emic` (entrada principal)
- Archivos `.emic` del SDK (`DEV:`)
- Templates C/H
- Archivos del integrador (`SYS:`)

**Outputs:**
- `Target/*.c` (archivos fuente C)
- `Target/inc/*.h` (headers)
- `Target/Makefile` (script de compilación)
- `Target/generate.txt` (log del proceso)

---

### 3. Compilador C (Backend)

**Responsabilidades:**
- Compilar código C → objeto (.o)
- Linker → binario ejecutable (.elf)
- Convertir → formato HEX

**Inputs:**
- `Target/*.c` (código fuente)
- `Target/inc/*.h` (headers)
- `Target/Makefile` (instrucciones)
- Linker script (`.gld`)

**Outputs:**
- `Target/dist/*.hex` (firmware final)
- `Target/build/*.o` (archivos objeto)
- `Target/dist/*.elf` (binario con debug info)

---

## Fases de EMIC-Generate

EMIC-Generate opera en **5 fases secuenciales**:

### Fase 1: Inicialización

**Objetivo:** Preparar el entorno de ejecución

**Acciones:**
1. Crear contexto de variables (mapa vacío)
2. Definir volúmenes lógicos:
   - `DEV:` → Ruta del SDK
   - `TARGET:` → Carpeta Target del módulo
   - `SYS:` → Carpeta System del módulo
   - `USER:` → Carpeta del usuario
3. Configurar salida por defecto (stdout)
4. Inicializar stack de archivos incluidos

**Duración:** < 10ms

---

### Fase 2: Parsing de generate.emic

**Objetivo:** Leer y parsear el archivo de entrada principal

**Acciones:**
1. Abrir `System/generate.emic`
2. Leer línea por línea
3. Identificar directivas `EMIC:`
4. Construir AST (Abstract Syntax Tree) simplificado
5. Validar sintaxis básica

**Duración:** < 50ms

**Ejemplo de parsing:**
```emic
EMIC:define(system.ucName, pic24FJ64GA002)
```
**Parse tree:**
```
DirectiveNode
  ├─ type: "define"
  ├─ param1: "system.ucName"
  └─ param2: "pic24FJ64GA002"
```

---

### Fase 3: Procesamiento Recursivo

**Objetivo:** Ejecutar todas las directivas en orden

**Acciones:**
1. Iterar sobre cada directiva
2. Ejecutar según tipo:
   - `define` → Agregar a mapa de variables
   - `setInput` → **Recursión:** procesar archivo incluido
   - `copy` → Agregar a cola de copias
   - `setOutput` → Cambiar stream de salida
   - `ifdef`/`ifndef` → Evaluar condicional
3. Mantener contexto de variables (global + local)
4. Propagar variables según scope

**Duración:** 1-8 segundos (depende de profundidad de recursión)

**Ejemplo de recursión:**
```
generate.emic (profundidad 0)
    ↓ EMIC:setInput(DEV:_api/led.emic)
    led.emic (profundidad 1)
        ↓ EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
        gpio.emic (profundidad 2)
            ↓ EMIC:setInput(DEV:_hard/pic24FJ64GA002/GPIO/gpio.emic)
            gpio_pic24.emic (profundidad 3)
```

---

### Fase 4: Sustitución de Variables

**Objetivo:** Reemplazar todas las variables `.{*}.` con sus valores

**Acciones:**
1. Para cada archivo en cola de copia:
2. Leer contenido original
3. Buscar patrones `.{nombre}.`
4. Buscar `nombre` en mapa de variables
5. Sustituir con valor encontrado
6. Si no se encuentra → error o dejar literal

**Duración:** 0.5-2 segundos

**Ejemplo:**
```c
// Template original
void LEDs_.{name}._init(void) {
    HAL_GPIO_PinCfg(.{pin}., OUTPUT);
}

// Variables: name=led1, pin=A0_Pin
// Resultado después de sustitución:
void LEDs_led1_init(void) {
    HAL_GPIO_PinCfg(A0_Pin, OUTPUT);
}
```

---

### Fase 5: Generación de Archivos

**Objetivo:** Escribir todos los archivos finales a disco

**Acciones:**
1. Para cada archivo en cola de copia:
2. Crear directorios necesarios
3. Escribir contenido transformado
4. Registrar en `generate.txt`
5. Copiar templates de proyecto (Makefile, etc.)

**Duración:** 0.5-1 segundo

**Resultado:**
```
Target/
├── main.c
├── led_led1.c
├── led_led2.c
├── timer_api1.c
├── userFncFile.c
├── inc/
│   ├── led_led1.h
│   ├── led_led2.h
│   ├── timer_api1.h
│   └── userFncFile.h
├── Makefile
└── generate.txt
```

---

## Flujo Detallado Paso a Paso

Vamos a seguir un ejemplo real paso a paso.

### Input: generate.emic

```emic
EMIC:setOutput(TARGET:generate.txt)

    //-------------- Hardware Config ---------------------
    EMIC:setInput(DEV:_pcb/pcb.emic, pcb=HRD_Development_Board)

    //------------------- Process EMIC-Generate files result ----------------
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    //------------------- APIs -----------------------
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=led1, pin=A0_Pin)
    EMIC:setInput(DEV:_api/Timers/timer_api.emic, name=1)

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

### Paso 1: Redirigir salida

```
EMIC:setOutput(TARGET:generate.txt)
```

**Acción:** Toda la salida se escribirá en `Target/generate.txt`

---

### Paso 2: Configurar hardware

```
EMIC:setInput(DEV:_pcb/pcb.emic, pcb=HRD_Development_Board)
```

**Acciones:**
1. Abrir `DEV:_pcb/pcb.emic`
2. Crear variable local: `pcb=HRD_Development_Board`
3. Procesar contenido de `pcb.emic`:
   ```emic
   EMIC:copy(inc/.{pcb}..h > TARGET:inc/.{pcb}..h)
   ```
4. Sustituir: `.{pcb}.` → `HRD_Development_Board`
5. Ejecutar copia: `inc/HRD_Development_Board.h` → `TARGET:inc/HRD_Development_Board.h`
6. Archivo copiado define:
   ```c
   #define system.ucName pic24FJ64GA002
   #define PIN_A0 A0_Pin
   // ... más pines
   ```

**Variables globales creadas:**
- `system.ucName = pic24FJ64GA002`
- `A0_Pin = definido en PCB`

---

### Paso 3: Incluir usedFunction.emic

```
EMIC:setInput(SYS:usedFunction.emic)
```

**Acción:** Este archivo es generado por EMIC-Editor y contiene:
```emic
EMIC:define(usedFunction.LEDs_led1_state, true)
EMIC:define(usedFunction.LEDs_led1_blink, true)
EMIC:define(usedFunction.setTime1, true)
```

**Resultado:** Variables de feature flags creadas para compilación condicional.

---

### Paso 4: Instanciar LED

```
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=led1, pin=A0_Pin)
```

**Acciones:**
1. Abrir `DEV:_api/Indicators/LEDs/led.emic`
2. Variables locales: `name=led1`, `pin=A0_Pin`
3. Procesar contenido de `led.emic`:

```emic
EMIC:tag(driverName = LEDs)

// Dependencias
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

// Copiar templates
EMIC:copy(inc/led.h > TARGET:inc/led_.{name}..h, name=.{name}., pin=.{pin}.)
EMIC:copy(src/led.c > TARGET:led_.{name}..c, name=.{name}., pin=.{pin}.)

// Registrar módulo
EMIC:define(main_includes.led_.{name}., led_.{name}.)
EMIC:define(c_modules.led_.{name}., led_.{name}.)
```

4. **Recursión:** Procesar `gpio.emic` y `systemTimer.emic`
5. **Copias:**
   - `inc/led.h` → `TARGET:inc/led_led1.h` (sustituir `name=led1`, `pin=A0_Pin`)
   - `src/led.c` → `TARGET:led_led1.c` (sustituir `name=led1`, `pin=A0_Pin`)
6. **Variables globales:**
   - `main_includes.led_led1 = led_led1`
   - `c_modules.led_led1 = led_led1`

---

### Paso 5: Instanciar Timer

```
EMIC:setInput(DEV:_api/Timers/timer_api.emic, name=1)
```

**Similar a LED, genera:**
- `TARGET:inc/timer_api1.h`
- `TARGET:timer_api1.c`
- Variables: `c_modules.timer_api1 = timer_api1`

---

### Paso 6: Incluir main.c

```
EMIC:setInput(DEV:_main/baremetal/main.emic)
```

**Contenido de `main.emic`:**
```emic
EMIC:setInput(DEV:_hal/System/system.emic)
EMIC:copy(DEV:_main/baremetal/main.c > TARGET:main.c)
EMIC:define(c_modules.main, main)
```

**Template `main.c`:**
```c
int main(void)
{
    initSystem();

    EMIC:ifdef usedEvent.SystemConfig
    SystemConfig();
    EMIC:endif

    .{inits.*}.();  // ← Expande a todas las funciones init

    EMIC:ifdef usedEvent.onReset
    onReset();
    EMIC:endif

    do {
        .{polls.*}.();  // ← Expande a todas las funciones poll
    } while(1);
}
```

**Después de sustitución:**
```c
int main(void)
{
    initSystem();

    LEDs_led1_init();
    Timer_api1_init();

    do {
        LEDs_led1_poll();
        Timer_api1_poll();
    } while(1);
}
```

---

### Paso 7: Copiar código del integrador

```
EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
```

**Acción:** Copiar el código escrito por el integrador en EMIC-Editor.

---

### Paso 8: Copiar templates de proyecto

```
EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)
```

**Acción:** Copiar **todo el directorio** de templates MPLAB X:
- `Makefile`
- `nbproject/configurations.xml`
- `nbproject/project.xml`
- Linker scripts (`.gld`)

**configurations.xml** contiene variables EMIC:
```xml
<targetDevice>.{system.ucName}.</targetDevice>
<itemPath>.{c_modules.*}..c</itemPath>
```

**Después de sustitución:**
```xml
<targetDevice>pic24FJ64GA002</targetDevice>
<itemPath>main.c</itemPath>
<itemPath>led_led1.c</itemPath>
<itemPath>timer_api1.c</itemPath>
<itemPath>userFncFile.c</itemPath>
```

---

### Paso 9: Restaurar salida

```
EMIC:restoreOutput
```

**Acción:** Cerrar `generate.txt`, volver a salida estándar.

---

## Archivos Generados

Después de EMIC-Generate, la carpeta `Target/` contiene:

```
Target/
├── generate.txt                   # Log del proceso
│
├── main.c                         # Punto de entrada
├── led_led1.c                     # Código del LED
├── timer_api1.c                   # Código del Timer
├── systemTimer.c                  # Driver de timer del sistema
├── gpio.c                         # HAL GPIO
├── gpio_pic24FJ64GA002.c          # _hard específico del MCU
├── userFncFile.c                  # Código del integrador
│
├── inc/                           # Headers
│   ├── led_led1.h
│   ├── timer_api1.h
│   ├── systemTimer.h
│   ├── gpio.h
│   ├── userFncFile.h
│   └── HRD_Development_Board.h   # Configuración PCB
│
├── Makefile                       # Script de compilación
│
├── nbproject/                     # Proyecto MPLAB X
│   ├── configurations.xml
│   ├── project.xml
│   └── Makefile-*.mk
│
├── p24FJ64GA002.gld              # Linker script
│
├── build/                         # Archivos objeto (generados por compilador)
│   ├── main.o
│   ├── led_led1.o
│   └── ...
│
└── dist/                          # Binarios finales (generados por compilador)
    ├── firmware.hex               # ¡FIRMWARE FINAL!
    ├── firmware.elf
    └── firmware.map
```

### generate.txt - Log del Proceso

**Contenido típico:**
```
[EMIC-Generate] Starting...
[EMIC-Generate] Processing: System/generate.emic
[EMIC-Generate] Including: DEV:_pcb/pcb.emic (pcb=HRD_Development_Board)
[EMIC-Generate]   Copying: DEV:_pcb/inc/HRD_Development_Board.h → TARGET:inc/HRD_Development_Board.h
[EMIC-Generate]   Define: system.ucName = pic24FJ64GA002
[EMIC-Generate] Including: SYS:usedFunction.emic
[EMIC-Generate]   Define: usedFunction.LEDs_led1_state = true
[EMIC-Generate] Including: DEV:_api/Indicators/LEDs/led.emic (name=led1, pin=A0_Pin)
[EMIC-Generate]   Including: DEV:_hal/GPIO/gpio.emic
[EMIC-Generate]     Including: DEV:_hard/pic24FJ64GA002/GPIO/gpio.emic
[EMIC-Generate]       Copying: DEV:_hard/pic24FJ64GA002/GPIO/gpio.c → TARGET:gpio_pic24.c
[EMIC-Generate]   Including: DEV:_drivers/SystemTimer/systemTimer.emic
[EMIC-Generate]     Copying: DEV:_drivers/SystemTimer/systemTimer.c → TARGET:systemTimer.c
[EMIC-Generate]   Copying: DEV:_api/Indicators/LEDs/inc/led.h → TARGET:inc/led_led1.h
[EMIC-Generate]   Copying: DEV:_api/Indicators/LEDs/src/led.c → TARGET:led_led1.c
[EMIC-Generate]   Define: c_modules.led_led1 = led_led1
[EMIC-Generate] Including: DEV:_api/Timers/timer_api.emic (name=1)
[EMIC-Generate]   Copying: DEV:_api/Timers/inc/timer_api.h → TARGET:inc/timer_api1.h
[EMIC-Generate]   Copying: DEV:_api/Timers/src/timer_api.c → TARGET:timer_api1.c
[EMIC-Generate] Including: DEV:_main/baremetal/main.emic
[EMIC-Generate]   Copying: DEV:_main/baremetal/main.c → TARGET:main.c
[EMIC-Generate] Copying: SYS:userFncFile.c → TARGET:userFncFile.c
[EMIC-Generate] Copying directory: DEV:_templates/projects/mplabx → TARGET:
[EMIC-Generate] Complete! 15 files generated.
[EMIC-Generate] Duration: 3.2 seconds
```

---

## Proceso de Compilación C

Después de EMIC-Generate, el **compilador C** toma el relevo:

### 1. Invocación del Makefile

```bash
cd Target/
make clean
make all
```

### 2. Compilación de Archivos .c → .o

```bash
xc16-gcc -c main.c -o build/main.o
xc16-gcc -c led_led1.c -o build/led_led1.o
xc16-gcc -c timer_api1.c -o build/timer_api1.o
xc16-gcc -c userFncFile.c -o build/userFncFile.o
# ... todos los archivos .c
```

**Flags típicos:**
- `-mcpu=24FJ64GA002` (MCU target)
- `-O1` (optimización nivel 1)
- `-Wall` (todos los warnings)
- `-I./inc` (directorio de includes)

### 3. Linking

```bash
xc16-gcc build/*.o -o dist/firmware.elf \
    -Wl,--script=p24FJ64GA002.gld \
    -Wl,--heap=512 \
    -Wl,--stack=256
```

**Linker script (`.gld`):**
- Define mapa de memoria (Flash, RAM)
- Asigna secciones (code, data, bss)
- Configura stack y heap

### 4. Conversión a HEX

```bash
xc16-bin2hex dist/firmware.elf
```

**Resultado:** `dist/firmware.hex` (listo para programar)

### Makefile Generado

**Ejemplo de Makefile típico:**
```makefile
# Generated by EMIC-Generate
DEVICE = pic24FJ64GA002
COMPILER = xc16-gcc

SOURCES = main.c \
          led_led1.c \
          timer_api1.c \
          systemTimer.c \
          gpio_pic24.c \
          userFncFile.c

OBJECTS = $(SOURCES:.c=.o)

all: dist/firmware.hex

dist/firmware.hex: dist/firmware.elf
	xc16-bin2hex $<

dist/firmware.elf: $(OBJECTS)
	$(COMPILER) $(OBJECTS) -o $@ -mcpu=$(DEVICE) -Wl,--script=p$(DEVICE).gld

%.o: %.c
	$(COMPILER) -c $< -o $@ -mcpu=$(DEVICE) -O1 -Wall -I./inc

clean:
	rm -f build/*.o dist/*
```

---

## Debugging del Proceso

### Técnica 1: Revisar generate.txt

**Qué buscar:**
```
[EMIC-Generate] Error: Variable '.{name}.' not defined in led.emic:15
```

**Solución:** Asegurar que la variable se pasa como parámetro.

---

### Técnica 2: Inspeccionar Archivos Generados

**Verificar sustituciones:**
```bash
cat Target/led_led1.c | grep ".{"
```

**Si encuentra `.{name}.` literal:**
- Variable no fue sustituida
- Verificar que se pasó en `EMIC:copy`

---

### Técnica 3: Compilación Incremental

**Compilar un archivo a la vez:**
```bash
xc16-gcc -c Target/led_led1.c -o test.o -mcpu=pic24FJ64GA002 -I./Target/inc
```

**Si falla:** El problema está en el código C generado, no en EMIC-Generate.

---

### Técnica 4: Diff de Archivos Generados

**Comparar dos generaciones:**
```bash
diff Target_old/led_led1.c Target_new/led_led1.c
```

**Útil para:** Ver qué cambió después de modificar el template.

---

### Técnica 5: Verbose Mode

**Si EMIC-Generate soporta modo verbose:**
```bash
emic-generate --verbose System/generate.emic
```

**Output detallado:**
```
[DEBUG] Opening file: DEV:_api/led.emic
[DEBUG] Local vars: name=led1, pin=A0_Pin
[DEBUG] Processing line 23: EMIC:copy(inc/led.h > TARGET:inc/led_led1.h, ...)
[DEBUG] Substituting: .{name}. → led1
[DEBUG] Substituting: .{pin}. → A0_Pin
[DEBUG] Writing file: TARGET:inc/led_led1.h (2048 bytes)
```

---

## Caso Práctico Completo

Vamos a seguir un proyecto real de principio a fin.

### Proyecto: Sistema de Control de Temperatura

**Requisitos:**
- Leer temperatura (ADC)
- Mostrar en LCD
- Controlar ventilador (PWM)
- LED de status
- Comunicación UART

---

### Paso 1: EMIC-Editor - Programar Lógica

**El integrador programa:**
```
on SystemConfig():
    display.clear()
    display.print("Temp Control v1.0")

on poll():
    temp = tempSensor.read()
    display.setCursor(0, 1)
    display.print("Temp: " + temp + "C")

    if (temp > 30):
        fan.setSpeed(100)
        statusLed.state(ON)
    else:
        fan.setSpeed(0)
        statusLed.state(OFF)
```

---

### Paso 2: EMIC-Editor Genera Archivos

**`System/generate.emic`:**
```emic
EMIC:setOutput(TARGET:generate.txt)

    EMIC:setInput(DEV:_pcb/pcb.emic, pcb=MyCustomBoard)
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    // APIs
    EMIC:setInput(DEV:_api/Sensors/Temperature/temp_adc.emic, name=tempSensor, channel=0)
    EMIC:setInput(DEV:_api/Display/LCD_I2C/lcd.emic, name=display, address=0x27)
    EMIC:setInput(DEV:_api/Actuators/PWM_Fan/fan.emic, name=fan, pwm_channel=1)
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=statusLed, pin=LED_STATUS)
    EMIC:setInput(DEV:_api/Communication/UART/uart.emic, port=1, baud=115200)

    EMIC:setInput(DEV:_main/baremetal/main.emic)

    EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
    EMIC:define(c_modules.userFncFile, userFncFile)

    EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

**`System/userFncFile.c`:**
```c
#include <xc.h>
#include "inc/temp_adc_tempSensor.h"
#include "inc/lcd_display.h"
#include "inc/fan_fan.h"
#include "inc/led_statusLed.h"

void SystemConfig() {
    LCD_display_clear();
    LCD_display_print("Temp Control v1.0");
}

void onPoll() {
    float temp = TempSensor_tempSensor_read();

    LCD_display_setCursor(0, 1);
    char buffer[20];
    sprintf(buffer, "Temp: %.1fC", temp);
    LCD_display_print(buffer);

    if (temp > 30.0) {
        Fan_fan_setSpeed(100);
        LEDs_statusLed_state(1);
    } else {
        Fan_fan_setSpeed(0);
        LEDs_statusLed_state(0);
    }
}
```

---

### Paso 3: Ejecutar EMIC-Generate

```bash
cd Module/System/
emic-generate generate.emic
```

**Output:**
```
[EMIC-Generate] Starting...
[EMIC-Generate] Processing: generate.emic
[EMIC-Generate] Including PCB: MyCustomBoard
[EMIC-Generate] Generating temp sensor...
[EMIC-Generate] Generating LCD display...
[EMIC-Generate] Generating PWM fan...
[EMIC-Generate] Generating status LED...
[EMIC-Generate] Generating UART...
[EMIC-Generate] Generating main...
[EMIC-Generate] Copying user code...
[EMIC-Generate] Copying MPLAB X templates...
[EMIC-Generate] Success! 23 files generated in 4.5 seconds
```

---

### Paso 4: Archivos Generados en Target/

```
Target/
├── main.c
├── temp_adc_tempSensor.c
├── lcd_display.c
├── fan_fan.c
├── led_statusLed.c
├── uart1.c
├── adc.c                  (HAL)
├── i2c.c                  (HAL para LCD)
├── pwm.c                  (HAL)
├── gpio.c                 (HAL)
├── systemTimer.c          (Driver)
├── userFncFile.c
├── inc/
│   ├── (todos los .h correspondientes)
│   └── MyCustomBoard.h
├── Makefile
├── nbproject/
└── p24FJ64GA002.gld
```

---

### Paso 5: Compilar con Make

```bash
cd ../Target/
make clean
make all
```

**Output:**
```
Cleaning build artifacts...
Compiling main.c...
Compiling temp_adc_tempSensor.c...
Compiling lcd_display.c...
Compiling fan_fan.c...
Compiling led_statusLed.c...
Compiling uart1.c...
Compiling adc.c...
Compiling i2c.c...
Compiling pwm.c...
Compiling gpio.c...
Compiling systemTimer.c...
Compiling userFncFile.c...
Linking...
Generating HEX file...
BUILD SUCCESSFUL!

Output file: dist/firmware.hex
Program size: 14,528 bytes (22% of Flash)
RAM usage: 1,024 bytes (12% of RAM)
Build time: 24 seconds
```

---

### Paso 6: Programar Microcontrolador

```bash
# Con pickit3
ipecmd -P24FJ64GA002 -TPPK3 -Fdist/firmware.hex -M -OL

# O desde MPLAB X IDE
# Menu: Production → Make and Program Device
```

**Output:**
```
Connecting to PICkit 3...
Target device: PIC24FJ64GA002
Erasing...
Programming...
Verifying...
SUCCESS! Device programmed.
```

---

### Paso 7: Sistema Funcionando

**En el microcontrolador:**
```
LCD muestra:
┌────────────────┐
│Temp Control v1.0│
│Temp: 25.3C      │
└────────────────┘

- Ventilador apagado (temp < 30°C)
- LED de status apagado
- UART transmitiendo datos de telemetría
```

**Cuando temperatura sube:**
```
LCD muestra:
┌────────────────┐
│Temp Control v1.0│
│Temp: 32.1C      │
└────────────────┘

- Ventilador a 100% (PWM)
- LED de status encendido
```

---

## Optimizaciones y Performance

### 1. Cache de Archivos Incluidos

**Problema:** `gpio.emic` incluido 10 veces (por cada LED, botón, etc.)

**Solución:** Include guard previene reprocessing
```emic
EMIC:ifndef _GPIO_EMIC_
EMIC:define(_GPIO_EMIC_, true)
    // Solo se procesa una vez
EMIC:endif
```

**Mejora:** 10x más rápido

---

### 2. Compilación Incremental

**Solo recompilar archivos modificados:**
```bash
make  # Solo compila .c que cambiaron desde último build
```

**Mejora:** Build subsecuente 5-10x más rápido

---

### 3. Parallel Compilation

**Makefile con jobs paralelos:**
```bash
make -j4  # Compilar 4 archivos en paralelo
```

**Mejora:** Build 2-3x más rápido en multi-core

---

## Troubleshooting

### Problema 1: "Variable not defined"

**Error:**
```
[EMIC-Generate] Error: Variable '.{name}.' not defined in led.emic:15
```

**Causa:** Variable no pasada como parámetro

**Solución:**
```emic
// ❌ MAL
EMIC:setInput(DEV:_api/led.emic, pin=A0)  // Falta 'name'

// ✅ BIEN
EMIC:setInput(DEV:_api/led.emic, name=led1, pin=A0)
```

---

### Problema 2: "File not found"

**Error:**
```
[EMIC-Generate] Error: File 'DEV:_api/led.emic' not found
```

**Causa:** Ruta incorrecta o SDK no configurado

**Solución:**
1. Verificar ruta del SDK en configuración
2. Verificar que archivo existe
3. Verificar volumen correcto (`DEV:`, no ruta absoluta)

---

### Problema 3: Código C con Variables Literales

**Síntoma:**
```c
// En archivo .c generado:
void LEDs_.{name}._init(void) {  // ❌ Variable no sustituida
```

**Causa:** Variable no pasada en `EMIC:copy`

**Solución:**
```emic
// ❌ MAL
EMIC:copy(src/led.c > TARGET:led_.{name}..c)

// ✅ BIEN
EMIC:copy(src/led.c > TARGET:led_.{name}..c, name=.{name}., pin=.{pin}.)
```

---

### Problema 4: Compilación C Falla

**Error:**
```
led_led1.c:15: error: 'A0_Pin' undeclared
```

**Causa:** Pin no definido en PCB

**Solución:**
1. Verificar que PCB tiene definición del pin
2. Verificar que `pcb.emic` fue incluido
3. Verificar ortografía del nombre del pin

---

### Problema 5: Linker Error - "Undefined reference"

**Error:**
```
undefined reference to `HAL_GPIO_PinSet'
```

**Causa:** Dependencia no incluida o no compilada

**Solución:**
1. Verificar que `gpio.c` está en lista de archivos a compilar
2. Verificar que `c_modules.gpio` fue definido
3. Revisar `generate.txt` para ver si GPIO fue incluido

---

## Resumen del Capítulo

### Puntos Clave

1. **Pipeline Completo:**
   - EMIC-Editor → generate.emic
   - EMIC-Generate → Código C
   - Compilador C → Firmware.hex

2. **5 Fases de EMIC-Generate:**
   - Inicialización (contexto, volúmenes)
   - Parsing (AST)
   - Procesamiento recursivo (ejecutar directivas)
   - Sustitución de variables
   - Generación de archivos

3. **Archivos Generados:**
   - `generate.txt` (log)
   - Archivos `.c/.h` (código fuente)
   - `Makefile` (compilación)
   - Proyecto IDE completo

4. **Debugging:**
   - Revisar `generate.txt`
   - Inspeccionar archivos generados
   - Buscar variables no sustituidas
   - Compilación incremental

5. **Optimizaciones:**
   - Include guards
   - Compilación incremental
   - Jobs paralelos

### Flujo Completo Resumido

```
Usuario programa en EMIC-Editor
    ↓
generate.emic + userFncFile.c
    ↓
EMIC-Generate procesa (3-10 seg)
    ↓
Target/ con código C
    ↓
make (20-60 seg)
    ↓
firmware.hex
    ↓
Programar MCU
    ↓
¡Sistema funcionando!
```

### Fin de la Sección 3

Con este capítulo cerramos la **Sección 3: EMIC-Codify Language**, donde aprendimos:
- Fundamentos de EMIC-Codify (Cap 16)
- Sintaxis avanzada (Cap 17)
- Directivas completas (Cap 18)
- Sistema de módulos y templates (Cap 19)
- Proceso completo de EMIC-Generate (Cap 20)

**Siguiente sección:**
- **Sección 4: Desarrollo Práctico** (Capítulos 21-26)
  - Crear primer proyecto
  - Desarrollar APIs
  - Trabajar con módulos
  - Debugging
  - Testing
  - Deployment

---

**Fin del Capítulo 20**

**Progreso del Manual:**
- **Sección 1 (Introducción):** ████████████████████ 100% (5/5) ✅
- **Sección 2 (Estructura SDK):** ████████████████████ 100% (11/11) ✅
- **Sección 3 (EMIC-Codify):** ████████████████████ 100% (5/5) ✅

**Progreso Total: 20/38 capítulos (52.63%)**

🎉 **¡SECCIÓN 3 COMPLETADA AL 100%!** 🎉

---

**Referencias:**
- Capítulo 16: Introducción a EMIC-Codify
- Capítulo 17: Sintaxis Avanzada de EMIC-Codify
- Capítulo 18: Directivas Completas de EMIC-Codify
- Capítulo 19: Sistema de Módulos y Templates
- Capítulo 06: Carpeta `_modules/`
- Capítulo 11: Carpeta `_main/`
