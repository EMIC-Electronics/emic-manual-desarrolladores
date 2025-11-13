# Capítulo 13: Carpeta `_templates/` - Plantillas de Proyectos

## Índice
1. [¿Qué es `_templates/`?](#1-qué-es-_templates)
2. [Estructura de la Carpeta](#2-estructura-de-la-carpeta)
3. [Template MPLAB X](#3-template-mplab-x)
4. [Makefiles y Compilación](#4-makefiles-y-compilación)
5. [Configuración del Proyecto](#5-configuración-del-proyecto)
6. [Linker Script](#6-linker-script)
7. [Uso en generate.emic](#7-uso-en-generateemic)
8. [Compilación del Proyecto](#8-compilación-del-proyecto)
9. [Plugins y Extensiones](#9-plugins-y-extensiones)
10. [Crear Nuevo Template](#10-crear-nuevo-template)

---

## 1. ¿Qué es `_templates/`?

La carpeta `_templates/` contiene **plantillas de proyectos** para diferentes IDEs y herramientas de compilación. Estas plantillas permiten que el código generado por EMIC pueda **compilarse fácilmente** sin configuración manual.

### 1.1 Ubicación en el Proceso de Compilación

```
┌─────────────────────────────────────────────────┐
│   EMIC-Generate procesa generate.emic           │
│   Fusiona SDK + código de usuario                │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│   Código C generado en TARGET:                  │
│   - main.c                                      │
│   - led_Status.c                                 │
│   - UART2.c                                     │
│   - systemTimer.c                               │
│   - userFncFile.c                               │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│   Templates (_templates/)  ← ESTE NIVEL         │
│   Copia archivos de proyecto:                   │
│   - Makefile                                    │
│   - nbproject/configurations.xml               │
│   - nbproject/project.xml                       │
│   - p24FJ64GA002.gld (linker script)            │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│   Proyecto MPLAB X completo en TARGET:          │
│   Listo para abrir y compilar                   │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│   Compilador XC16/XC32/XC8                      │
│   Genera firmware.hex                           │
└─────────────────────────────────────────────────┘
```

### 1.2 Problema que Resuelve

**Sin `_templates/`:**
```bash
# Debes configurar manualmente:
1. Crear proyecto MPLAB X desde cero
2. Agregar todos los archivos .c y .h al proyecto
3. Configurar microcontrolador (PIC24FJ64GA002)
4. Configurar compilador (XC16)
5. Configurar linker script (p24FJ64GA002.gld)
6. Configurar opciones de compilación
7. Agregar include paths

Tiempo: ~30 minutos por proyecto
```

**Con `_templates/`:**
```emic
// Una sola línea en generate.emic:
EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

Tiempo: 0 segundos (automático)
```

### 1.3 Responsabilidades de `_templates/`

| Responsabilidad | Descripción |
|----------------|-------------|
| **Configuración de IDE** | Archivos de proyecto para MPLAB X |
| **Makefiles** | Compilación desde línea de comandos |
| **Linker script** | Mapeo de memoria del MCU |
| **Compilación automática** | Lista de archivos fuente y headers |
| **Opciones del compilador** | Flags, optimizaciones, warnings |
| **Plugins** | Extensiones para el IDE (opcional) |

---

## 2. Estructura de la Carpeta

### 2.1 Organización de `_templates/`

```
_templates/
├── projects/                    # Plantillas de proyectos
│   └── mplabx/                 # Template para MPLAB X
│       ├── Makefile
│       ├── p24FJ64GA002.gld    # Linker script para PIC24
│       ├── nbproject/          # Configuración MPLAB X
│       │   ├── configurations.xml
│       │   ├── project.xml
│       │   ├── Makefile-default.mk
│       │   ├── Makefile-impl.mk
│       │   ├── Makefile-variables.mk
│       │   ├── Makefile-genesis.properties
│       │   ├── Makefile-local-default.mk
│       │   └── private/
│       │       └── configurations.xml
│       ├── build/              # Carpeta de salida (objetos)
│       └── dist/               # Carpeta de salida (hex/elf)
└── plugins/                    # Plugins para el IDE
    └── sidebar-tabs/           # Plugin de pestañas laterales
        ├── Code/
        ├── Data/
        ├── Functions/
        ├── Resources/
        └── User/
```

### 2.2 Tipos de Templates Disponibles

| Template | IDE | Compilador | Estado |
|----------|-----|------------|--------|
| **mplabx** | MPLAB X v6.x | XC8/XC16/XC32 | ✅ Disponible |
| vscode | Visual Studio Code | GCC ARM | ⏳ Futuro |
| eclipse | Eclipse CDT | GCC ARM | ⏳ Futuro |
| platformio | PlatformIO | GCC | ⏳ Futuro |

> **Nota**: Actualmente, EMIC SDK solo incluye template para MPLAB X (IDE oficial de Microchip).

---

## 3. Template MPLAB X

El template de MPLAB X es el más importante, ya que es el IDE estándar para microcontroladores PIC.

### 3.1 Archivos Clave del Template

#### 3.1.1 Makefile Principal

**Archivo: `_templates/projects/mplabx/Makefile`**

```makefile
#
#  There exist several targets which are by default empty and which can be
#  used for execution of your targets. These targets are usually executed
#  before and after some main targets. They are:
#
#     .build-pre:              called before 'build' target
#     .build-post:             called after 'build' target
#     .clean-pre:              called before 'clean' target
#     .clean-post:             called after 'clean' target
#     .clobber-pre:            called before 'clobber' target
#     .clobber-post:           called after 'clobber' target
#     .all-pre:                called before 'all' target
#     .all-post:               called after 'all' target
#     .help-pre:               called before 'help' target
#     .help-post:              called after 'help' target
#
#  Main targets can be executed directly, and they are:
#
#     build                    build a specific configuration
#     clean                    remove built files from a configuration
#     clobber                  remove all built files
#     all                      build all configurations
#     help                     print help message

# Environment
MKDIR=mkdir
CP=cp
CCADMIN=CCadmin
RANLIB=ranlib

# build
build: .build-post

.build-pre:
# Add your pre 'build' code here...

.build-post: .build-impl
# Add your post 'build' code here...

# clean
clean: .clean-post

.clean-pre:
# Add your pre 'clean' code here...

.clean-post: .clean-impl
# Add your post 'clean' code here...

# clobber
clobber: .clobber-post

.clobber-pre:
# Add your pre 'clobber' code here...

.clobber-post: .clobber-impl
# Add your post 'clobber' code here...

# all
all: .all-post

.all-pre:
# Add your pre 'all' code here...

.all-post: .all-impl
# Add your post 'all' code here...

# help
help: .help-post

.help-pre:
# Add your pre 'help' code here...

.help-post: .help-impl
# Add your post 'help' code here...

# include project implementation makefile
include nbproject/Makefile-impl.mk

# include project make variables
include nbproject/Makefile-variables.mk
```

**Propósito:**
- Define **targets** (build, clean, clobber, all, help)
- Provee **hooks** (.build-pre, .build-post, etc.)
- Incluye Makefiles de implementación

---

#### 3.1.2 Makefile de Configuración

**Archivo: `_templates/projects/mplabx/nbproject/Makefile-default.mk`** (extracto)

```makefile
# Environment
MKDIR=gnumkdir -p
RM=rm -f
MV=mv
CP=cp

# Macros
CND_CONF=default
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
IMAGE_TYPE=debug
OUTPUT_SUFFIX=elf
DEBUGGABLE_SUFFIX=elf
FINAL_IMAGE=${DISTDIR}/target.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
else
IMAGE_TYPE=production
OUTPUT_SUFFIX=hex
DEBUGGABLE_SUFFIX=elf
FINAL_IMAGE=${DISTDIR}/target.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
endif

# Object Directory
OBJECTDIR=build/${CND_CONF}/${IMAGE_TYPE}

# Distribution Directory
DISTDIR=dist/${CND_CONF}/${IMAGE_TYPE}

# Source Files Quoted if spaced
SOURCEFILES_QUOTED_IF_SPACED=codigo.c

# Object Files Quoted if spaced
OBJECTFILES_QUOTED_IF_SPACED=${OBJECTDIR}/codigo.o

# ======================================
# Processor and Compiler Configuration
# ======================================
MP_PROCESSOR_OPTION=24FJ64GA002
MP_LINKER_FILE_OPTION=,--script=p24FJ64GA002.gld

# ======================================
# Compilation Rules
# ======================================
${OBJECTDIR}/codigo.o: codigo.c
	@${MKDIR} "${OBJECTDIR}"
	@${RM} ${OBJECTDIR}/codigo.o.d
	@${RM} ${OBJECTDIR}/codigo.o
	${MP_CC} $(MP_EXTRA_CC_PRE) codigo.c -o ${OBJECTDIR}/codigo.o \
		-c -mcpu=$(MP_PROCESSOR_OPTION) \
		-MP -MMD -MF "${OBJECTDIR}/codigo.o.d" \
		-g -D__DEBUG \
		-omf=elf -DXPRJ_default=$(CND_CONF) \
		$(COMPARISON_BUILD) -msmall-code -O0 \
		-msmart-io=1 -Wall -msfr-warn=off \
		-mdfp="${DFP_DIR}/xc16"
```

**Propósito:**
- Define **rutas de salida** (build/, dist/)
- Especifica **microcontrolador** (`MP_PROCESSOR_OPTION=24FJ64GA002`)
- Especifica **linker script** (`p24FJ64GA002.gld`)
- Define **reglas de compilación** para cada archivo .c

---

## 4. Makefiles y Compilación

### 4.1 Flujo de Compilación con Makefiles

```
┌─────────────────────────────────────────────────┐
│  Usuario ejecuta: make build                    │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  Makefile (raíz)                                │
│  → Llama a .build-impl                          │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  nbproject/Makefile-impl.mk                     │
│  → Llama a Makefile-default.mk                  │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  nbproject/Makefile-default.mk                  │
│  Para cada archivo .c:                          │
│  1. Compila .c → .o (objeto)                    │
│  2. Genera .d (dependencias)                    │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  Linker (xc16-ld)                               │
│  Une todos los .o + librerías                   │
│  Usando p24FJ64GA002.gld                        │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│  Salida:                                        │
│  - dist/default/production/target.production.hex│
│  - dist/default/production/target.production.elf│
└─────────────────────────────────────────────────┘
```

### 4.2 Comandos de Make Disponibles

| Comando | Descripción |
|---------|-------------|
| `make build` | Compila el proyecto (modo production) |
| `make build TYPE_IMAGE=DEBUG_RUN` | Compila en modo debug |
| `make clean` | Elimina archivos compilados |
| `make clobber` | Elimina todo (build/ y dist/) |
| `make all` | Compila todas las configuraciones |
| `make help` | Muestra ayuda |

**Ejemplo de uso:**
```bash
cd /path/to/project
make clean
make build
# Resultado: dist/default/production/target.production.hex
```

---

## 5. Configuración del Proyecto

### 5.1 Archivo configurations.xml

**Archivo: `_templates/projects/mplabx/nbproject/configurations.xml`** (extracto)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configurationDescriptor version="65">
  <logicalFolder name="root" displayName="root" projectFiles="true">
    <!-- ========================================= -->
    <!-- Header Files                              -->
    <!-- ========================================= -->
    <logicalFolder name="HeaderFiles"
                   displayName="Header Files"
                   projectFiles="true">
      <!-- Macro EMIC-Codify: incluye todos los headers -->
      <itemPath>inc/.{includes_head.*}..h</itemPath>
    </logicalFolder>

    <!-- ========================================= -->
    <!-- Linker Script                             -->
    <!-- ========================================= -->
    <logicalFolder name="LinkerScript"
                   displayName="Linker Files"
                   projectFiles="true">
    </logicalFolder>

    <!-- ========================================= -->
    <!-- Source Files                              -->
    <!-- ========================================= -->
    <logicalFolder name="SourceFiles"
                   displayName="Source Files"
                   projectFiles="true">
      <!-- Macro EMIC-Codify: incluye todos los archivos .c -->
      <itemPath>.{c_modules.*}..c</itemPath>
    </logicalFolder>

    <!-- ========================================= -->
    <!-- Important Files                           -->
    <!-- ========================================= -->
    <logicalFolder name="ExternalFiles"
                   displayName="Important Files"
                   projectFiles="false">
      <itemPath>Makefile</itemPath>
    </logicalFolder>
  </logicalFolder>

  <!-- ========================================= -->
  <!-- Configuration: default                    -->
  <!-- ========================================= -->
  <confs>
    <conf name="default" type="2">
      <toolsSet>
        <developmentServer>localhost</developmentServer>

        <!-- Macro EMIC-Codify: microcontrolador -->
        <targetDevice>.{system.ucName}.</targetDevice>

        <targetHeader></targetHeader>
        <targetPluginBoard></targetPluginBoard>
        <platformTool>noID</platformTool>

        <!-- Compilador: XC16 -->
        <languageToolchain>XC16</languageToolchain>
        <languageToolchainVersion>2.00</languageToolchainVersion>
        <platform>3</platform>
      </toolsSet>

      <packs>
        <pack name="PIC24F-GA-GB_DFP" vendor="Microchip" version="1.8.217"/>
      </packs>

      <!-- ========================================= -->
      <!-- XC16 Compiler Options                     -->
      <!-- ========================================= -->
      <C30>
        <property key="code-model" value="small-code"/>
        <property key="enable-all-warnings" value="true"/>
        <property key="enable-symbols" value="true"/>
        <property key="oXC16gcc-smar-io-lvl" value="1"/>
        <property key="optimization-level" value="0"/>
      </C30>

      <!-- ========================================= -->
      <!-- XC16 Linker Options                       -->
      <!-- ========================================= -->
      <C30-LD>
        <property key="enable-data-init" value="true"/>
        <property key="enable-default-isr" value="true"/>
        <property key="enable-handles" value="true"/>
        <property key="enable-pack-data" value="true"/>
      </C30-LD>
    </conf>
  </confs>
</configurationDescriptor>
```

**Macros EMIC-Codify en configurations.xml:**

| Macro | Descripción | Ejemplo de Expansión |
|-------|-------------|----------------------|
| `.{includes_head.*}.` | Todos los headers | `system.h`, `gpio.h`, `led_Status.h` |
| `.{c_modules.*}.` | Todos los archivos .c | `main.c`, `led_Status.c`, `UART2.c` |
| `.{system.ucName}.` | Microcontrolador | `pic24FJ64GA002` |

**Expansión automática durante EMIC-Generate:**

```xml
<!-- ANTES (template): -->
<itemPath>.{c_modules.*}..c</itemPath>

<!-- DESPUÉS (proyecto generado): -->
<itemPath>main.c</itemPath>
<itemPath>led_Status.c</itemPath>
<itemPath>led_Led2.c</itemPath>
<itemPath>UART2.c</itemPath>
<itemPath>systemTimer.c</itemPath>
<itemPath>userFncFile.c</itemPath>
```

---

### 5.2 Archivo project.xml

**Archivo: `_templates/projects/mplabx/nbproject/project.xml`**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://www.netbeans.org/ns/project/1">
    <type>com.microchip.mplab.nbide.embedded.makeproject</type>
    <configuration>
        <data xmlns="http://www.netbeans.org/ns/make-project/1">
            <!-- Nombre del proyecto (macros EMIC) -->
            <name>.{project.name}.-.{module.name}.</name>

            <creation-uuid>db71606b-cdf8-4363-9df4-b0bcd60b3e33</creation-uuid>
            <make-project-type>0</make-project-type>
            <sourceEncoding>ISO-8859-15</sourceEncoding>
            <make-dep-projects/>
            <sourceRootList>
                <sourceRootElem>.</sourceRootElem>
            </sourceRootList>
            <confList>
                <confElem>
                    <name>default</name>
                    <type>2</type>
                </confElem>
            </confList>
        </data>
    </configuration>
</project>
```

**Expansión del nombre del proyecto:**

```xml
<!-- ANTES (template): -->
<name>.{project.name}.-.{module.name}.</name>

<!-- DESPUÉS (proyecto generado): -->
<name>MyProject-HRD_X4I_DIGITAL_I</name>
```

---

## 6. Linker Script

El linker script define el **mapeo de memoria** del microcontrolador.

### 6.1 Archivo p24FJ64GA002.gld

**Archivo: `_templates/projects/mplabx/p24FJ64GA002.gld`** (extracto)

```c
/*
 * Linker script for PIC24FJ64GA002
 * (c) Copyright 2013 Microchip Technology, Inc
 */

OUTPUT_ARCH("24FJ64GA002")
CRT0_STARTUP(crt0_standard.o)
CRT1_STARTUP(crt1_standard.o)
CRT_STARTMODE(crt_start_mode_normal)

OPTIONAL(-lpPIC24Fxxx)
OPTIONAL(-lfx)

/*
** Memory Regions
*/
MEMORY
{
  data  (a!xr)   : ORIGIN = 0x800,         LENGTH = 0x2000
  reset          : ORIGIN = 0x0,           LENGTH = 0x4
  ivt            : ORIGIN = 0x4,           LENGTH = 0xFC
  _reserved      : ORIGIN = 0x100,         LENGTH = 0x4
  aivt           : ORIGIN = 0x104,         LENGTH = 0xFC
  program (xr)   : ORIGIN = 0x200,         LENGTH = 0xA9FC
  CONFIG2        : ORIGIN = 0xABFC,        LENGTH = 0x2
  CONFIG1        : ORIGIN = 0xABFE,        LENGTH = 0x2
}

__CONFIG2 = 0xABFC;
__CONFIG1 = 0xABFE;

__NO_HANDLES = 1;          /* Suppress handles on this device  */
__CODE_BASE = 0x200;
__CODE_LENGTH = 0xA9FC;
__IVT_BASE  = 0x4;
__AIVT_BASE = 0x104;
__DATA_BASE = 0x800;
__DATA_LENGTH = 0x2000;

/*
** ==================== Section Map ======================
*/
SECTIONS
{
  /*
  ** Reset Instruction
  */
  .reset :
  {
        SHORT(ABSOLUTE(__reset));
        SHORT(0x04);
        SHORT((ABSOLUTE(__reset) >> 16) & 0x7F);
        SHORT(0);
  } >reset

  /*
  ** Interrupt Vector Tables
  */
  .ivt __IVT_BASE :
  {
    LONG(DEFINED(__ReservedTrap0)  ? ABSOLUTE(__ReservedTrap0)  :
         ABSOLUTE(__DefaultInterrupt));
    LONG(DEFINED(__OscillatorFail) ? ABSOLUTE(__OscillatorFail) :
         ABSOLUTE(__DefaultInterrupt));
    LONG(DEFINED(__AddressError)   ? ABSOLUTE(__AddressError)   :
         ABSOLUTE(__DefaultInterrupt));
    /* ... (vectores de interrupción) */
  } >ivt

  /*
  ** Program Memory
  */
  .text __CODE_BASE :
  {
        *(.init);
        *(.user_init);
        KEEP (*(.handle));
        KEEP (*(.isr*));
        *(.libc) *(.libm) *(.libdsp);  /* keep together in this order */
        *(.lib*);
        *(.text);
  } >program

  /*
  ** Data Memory
  */
  .data :
  {
    __data_init_start = .;
    *(.data);
    *(.data.*);
    __data_init_end = .;
  } >data

  .bss :
  {
    *(.bss);
    *(.bss.*);
  } >data

  /* ... (más secciones) */
}
```

**Regiones de memoria del PIC24FJ64GA002:**

| Región | Dirección | Tamaño | Propósito |
|--------|-----------|--------|-----------|
| **reset** | 0x000 | 4 bytes | Instrucción de reset |
| **ivt** | 0x004 | 252 bytes | Tabla de vectores de interrupción |
| **program** | 0x200 | 43,516 bytes | Código de programa (flash) |
| **data** | 0x800 | 8,192 bytes | RAM (datos y stack) |
| **CONFIG1** | 0xABFE | 2 bytes | Fuses de configuración 1 |
| **CONFIG2** | 0xABFC | 2 bytes | Fuses de configuración 2 |

**Propósito del linker script:**
- Define dónde va cada sección en memoria
- Mapea código (`.text`) a flash
- Mapea datos (`.data`, `.bss`) a RAM
- Coloca vectores de interrupción
- Coloca configuration bits

---

## 7. Uso en generate.emic

El template se copia automáticamente durante el proceso de generación.

### 7.1 Sintaxis en generate.emic

```emic
// Copiar template completo a TARGET:
EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)
```

### 7.2 Ejemplo Completo de generate.emic

```emic
EMIC:setOutput(TARGET:generate.txt)

    //-------------- Hardware Config ---------------------
    EMIC:setInput(DEV:_pcb/pcb.emic, pcb=HRD_D-I4-I_V1.0)

    //------------------- APIs -----------------------
    EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=Status, pin=Led1)
    EMIC:setInput(DEV:_api/Timers/timer_api.emic, name=1)

    //-------------------- main  -----------------------
    EMIC:setInput(DEV:_main/baremetal/main.emic)

    //------------------- User code ----------------
    EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
    EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
    EMIC:define(c_modules.userFncFile, userFncFile)

    //===============================================
    // COPIAR TEMPLATE DE MPLAB X
    //===============================================
    EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

**Resultado en TARGET:/**

```
TARGET:/
├── main.c                      # Generado por EMIC
├── led_Status.c                # Generado por EMIC
├── timer1.c                    # Generado por EMIC
├── userFncFile.c               # Del integrador
├── inc/                        # Headers
│   ├── system.h
│   ├── led_Status.h
│   ├── timer1.h
│   └── userFncFile.h
├── Makefile                    # ← De template
├── p24FJ64GA002.gld            # ← De template
├── nbproject/                  # ← De template
│   ├── configurations.xml      # (con macros expandidas)
│   ├── project.xml             # (con macros expandidas)
│   └── ...
├── build/                      # ← De template
└── dist/                       # ← De template
```

---

## 8. Compilación del Proyecto

Una vez generado el proyecto con el template, puedes compilarlo de dos maneras.

### 8.1 Compilación desde MPLAB X IDE

#### Paso 1: Abrir el proyecto

```
File → Open Project
Navegar a: TARGET:/
Seleccionar la carpeta del proyecto
Click "Open Project"
```

#### Paso 2: Verificar configuración

```
Project Properties → Conf: [default] → XC16 (Global Options)

Verificar:
- Device: pic24FJ64GA002
- Compiler Toolchain: XC16 v2.00
- Linker Script: p24FJ64GA002.gld
```

#### Paso 3: Compilar

```
Método 1: Click en el botón "Build Main Project" (martillo)
Método 2: Production → Build Main Project
Método 3: F11

Salida en ventana Output:
----------------------------------------------------------------------
BUILD SUCCESSFUL (total time: 3s)
----------------------------------------------------------------------
```

#### Paso 4: Verificar salida

```
Archivo generado:
dist/default/production/target.production.hex

Tamaño típico: 10-50 KB (dependiendo del código)
```

---

### 8.2 Compilación desde Línea de Comandos

#### Requisitos previos

```bash
# Verificar que XC16 esté en el PATH
xc16-gcc --version
# Salida esperada: xc16-gcc (MPLAB XC16) v2.00 ...

# Verificar make
make --version
# Salida esperada: GNU Make 4.x
```

#### Comandos de compilación

```bash
# Limpiar proyecto
make clean

# Compilar (modo production)
make build

# Compilar (modo debug)
make build TYPE_IMAGE=DEBUG_RUN

# Ver ayuda
make help
```

**Ejemplo de salida:**

```bash
$ make build
make -f nbproject/Makefile-default.mk SUBPROJECTS= .build-conf
make[1]: Entering directory '/path/to/project'
make  -f nbproject/Makefile-default.mk dist/default/production/target.production.hex
make[2]: Entering directory '/path/to/project'

Building file: main.c
CLEAN SUCCESSFUL (total time: 189ms)
Loading code from /path/to/project/dist/default/production/target.production.hex...
Loading completed
BUILD SUCCESSFUL (total time: 3s)
make[2]: Leaving directory '/path/to/project'
make[1]: Leaving directory '/path/to/project'
```

---

## 9. Plugins y Extensiones

La carpeta `_templates/plugins/` contiene extensiones para el IDE.

### 9.1 Plugin sidebar-tabs

```
_templates/plugins/sidebar-tabs/
├── Code/          # Pestañas de código
├── Data/          # Pestañas de datos
├── Functions/     # Pestañas de funciones
├── Resources/     # Pestañas de recursos
└── User/          # Pestañas de usuario
```

**Propósito:**
- Organizar el código en pestañas laterales
- Mejorar navegación en proyectos grandes
- Facilitar edición de funciones

**Instalación:**
```emic
// Copiar plugin al proyecto
EMIC:copy(DEV:_templates/plugins/sidebar-tabs > TARGET:sidebar-tabs)
```

> **Nota**: Este plugin es **experimental** y está en desarrollo.

---

## 10. Crear Nuevo Template

Si quieres agregar soporte para otro IDE (ej: Visual Studio Code), puedes crear un nuevo template.

### 10.1 Pasos para Crear Template

#### Paso 1: Crear estructura base

```bash
mkdir _templates/projects/vscode
cd _templates/projects/vscode
```

#### Paso 2: Crear archivos de configuración

**Archivo: `_templates/projects/vscode/.vscode/tasks.json`**

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Build Firmware",
            "type": "shell",
            "command": "xc16-gcc",
            "args": [
                "-mcpu=.{system.ucName}.",
                "-omf=elf",
                "-O0",
                "-msmart-io=1",
                "-Wall",
                ".{c_modules.*}..c",
                "-o",
                "firmware.elf"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        }
    ]
}
```

**Archivo: `_templates/projects/vscode/.vscode/c_cpp_properties.json`**

```json
{
    "configurations": [
        {
            "name": "XC16",
            "includePath": [
                "${workspaceFolder}/inc/**",
                "C:/Program Files/Microchip/xc16/v2.00/include"
            ],
            "defines": [
                "__XC16__"
            ],
            "compilerPath": "C:/Program Files/Microchip/xc16/v2.00/bin/xc16-gcc.exe",
            "cStandard": "c99",
            "intelliSenseMode": "gcc-x86"
        }
    ],
    "version": 4
}
```

#### Paso 3: Usar en generate.emic

```emic
// Copiar template de VSCode
EMIC:copy(DEV:_templates/projects/vscode > TARGET:)
```

---

## Resumen

| Concepto | Descripción |
|----------|-------------|
| **_templates/** | Carpeta con plantillas de proyectos para IDEs |
| **mplabx/** | Template para MPLAB X (IDE de Microchip) |
| **Makefile** | Compilación desde línea de comandos |
| **configurations.xml** | Configuración del proyecto (archivos, compilador) |
| **p24FJ64GA002.gld** | Linker script (mapeo de memoria) |
| **Macros EMIC** | `.{c_modules.*}.`, `.{system.ucName}.` se expanden automáticamente |
| **make build** | Compila el proyecto generando firmware.hex |
| **plugins/** | Extensiones para el IDE (experimental) |

---

## Próximos Pasos

En el **Capítulo 14** exploraremos la carpeta **`_system/`**, donde se encuentran las utilidades del sistema EMIC como gestión de streams, conversiones y funciones auxiliares.

---

**¿Preguntas?**
Los templates eliminan completamente la necesidad de configurar proyectos manualmente. **Una sola línea** (`EMIC:copy`) genera un proyecto completo, listo para compilar en segundos.
