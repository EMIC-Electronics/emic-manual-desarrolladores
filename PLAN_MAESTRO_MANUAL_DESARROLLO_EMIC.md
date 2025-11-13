# PLAN MAESTRO - Manual de Desarrollo EMIC SDK

**Versión:** 1.0
**Fecha de Creación:** 2025-11-04
**Autor:** EMIC Development Team
**SDK de Referencia:** `C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M`

---

## 📋 CHECKLIST DE PROGRESO

### Sección 1: Introducción y Fundamentos
- [ ] **Cap 00** - Portada y Tabla de Contenidos
- [ ] **Cap 01** - Introducción al Desarrollo EMIC
- [ ] **Cap 02** - Arquitectura y Conceptos Fundamentales
- [ ] **Cap 03** - Glosario y Vocabulario EMIC
- [ ] **Cap 04** - Ventajas de EMIC vs Otros Métodos

### Sección 2: Estructura del EMIC SDK
- [ ] **Cap 05** - Anatomía de un EMIC SDK (Visión General)
- [ ] **Cap 06** - Carpeta `_modules/` - Módulos Hardware + Firmware
- [ ] **Cap 07** - Carpeta `_api/` - APIs de Alto Nivel
- [ ] **Cap 08** - Carpeta `_drivers/` - Drivers de Hardware
- [ ] **Cap 09** - Carpeta `_hal/` - Hardware Abstraction Layer
- [ ] **Cap 10** - Carpeta `_hard/` - Código Específico de MCU
- [ ] **Cap 11** - Carpeta `_main/` - Punto de Entrada
- [ ] **Cap 12** - Carpeta `_pcb/` - Configuración de Hardware
- [ ] **Cap 13** - Carpeta `_templates/` - Templates de Proyectos
- [ ] **Cap 14** - Carpeta `_system/` - Sistema Core EMIC
- [ ] **Cap 15** - Carpeta `_util/` - Utilidades Generales

### Sección 3: EMIC-Codify
- [ ] **Cap 16** - Fundamentos de EMIC-Codify
- [ ] **Cap 17** - Comandos EMIC-Codify (Parte 1: Gestión de Archivos)
- [ ] **Cap 18** - Comandos EMIC-Codify (Parte 2: Macros y Sustitución)
- [ ] **Cap 19** - Comandos EMIC-Codify (Parte 3: Control de Flujo)
- [ ] **Cap 20** - Etiquetado de Recursos (Tags)

### Sección 4: Desarrollo Práctico
- [ ] **Cap 21** - Desarrollo de una API EMIC - Paso a Paso
- [ ] **Cap 22** - Desarrollo de un Driver EMIC
- [ ] **Cap 23** - Desarrollo de un Módulo EMIC Completo
- [ ] **Cap 24** - Creación de Categorías de Módulos
- [ ] **Cap 25** - El Proceso de Generación (generate.emic)
- [ ] **Cap 26** - Configuración Dinámica de Módulos

### Sección 5: Casos Prácticos
- [ ] **Cap 27** - Caso Práctico: API de LEDs
- [ ] **Cap 28** - Caso Práctico: Driver de Sensor I2C
- [ ] **Cap 29** - Caso Práctico: Módulo de Control con USB
- [ ] **Cap 30** - Caso Práctico: Módulo Multi-API Complejo

### Sección 6: Avanzado
- [ ] **Cap 31** - Buenas Prácticas y Convenciones
- [ ] **Cap 32** - Testing y Validación
- [ ] **Cap 33** - Troubleshooting y Debugging
- [ ] **Cap 34** - Optimización y Performance

### Sección 7: Referencias
- [ ] **Cap 35** - Apéndice A: Referencia Rápida de Comandos
- [ ] **Cap 36** - Apéndice B: Referencia Rápida de Tags
- [ ] **Cap 37** - Apéndice C: Plantillas de Código
- [ ] **Cap 38** - Apéndice D: Recursos Adicionales

---

## 🎯 ESTRUCTURA DEL MANUAL

```
Manual_Desarrollo_EMIC/
│
├── Seccion_1_Introduccion/
│   ├── 00_Portada.md
│   ├── 01_Introduccion.md
│   ├── 02_Arquitectura.md
│   ├── 03_Glosario.md
│   └── 04_Ventajas.md
│
├── Seccion_2_Estructura_SDK/
│   ├── 05_Vision_General_SDK.md
│   ├── 06_Carpeta_Modules.md
│   ├── 07_Carpeta_API.md
│   ├── 08_Carpeta_Drivers.md
│   ├── 09_Carpeta_HAL.md
│   ├── 10_Carpeta_Hard.md
│   ├── 11_Carpeta_Main.md
│   ├── 12_Carpeta_PCB.md
│   ├── 13_Carpeta_Templates.md
│   ├── 14_Carpeta_System.md
│   └── 15_Carpeta_Util.md
│
├── Seccion_3_EMIC_Codify/
│   ├── 16_Fundamentos_Codify.md
│   ├── 17_Comandos_Archivos.md
│   ├── 18_Comandos_Macros.md
│   ├── 19_Comandos_Control.md
│   └── 20_Etiquetado_Recursos.md
│
├── Seccion_4_Desarrollo/
│   ├── 21_Desarrollo_API.md
│   ├── 22_Desarrollo_Driver.md
│   ├── 23_Desarrollo_Modulo.md
│   ├── 24_Creacion_Categorias.md
│   ├── 25_Proceso_Generacion.md
│   └── 26_Configuracion_Dinamica.md
│
├── Seccion_5_Casos_Practicos/
│   ├── 27_Practica_API_LED.md
│   ├── 28_Practica_Driver_I2C.md
│   ├── 29_Practica_Modulo_USB.md
│   └── 30_Practica_Modulo_Complejo.md
│
├── Seccion_6_Avanzado/
│   ├── 31_Buenas_Practicas.md
│   ├── 32_Testing.md
│   ├── 33_Troubleshooting.md
│   └── 34_Optimizacion.md
│
└── Seccion_7_Referencias/
    ├── 35_Referencia_Comandos.md
    ├── 36_Referencia_Tags.md
    ├── 37_Plantillas_Codigo.md
    └── 38_Recursos_Adicionales.md
```

---

## 📝 PROMPTS PARA CADA CAPÍTULO

### SECCIÓN 1: INTRODUCCIÓN Y FUNDAMENTOS

---

#### **CAPÍTULO 00: Portada y Tabla de Contenidos**

**Archivo de Salida:** `Seccion_1_Introduccion/00_Portada.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 00 "Portada y Tabla de Contenidos" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Este es el primer documento del manual
- Audiencia: Desarrolladores de recursos EMIC (APIs, Drivers, Módulos)
- SDK de referencia: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M

REFERENCIAS DE ARCHIVOS:
- @PLAN_MAESTRO_MANUAL_DESARROLLO_EMIC.md (este archivo)
- @EMIC.md (descripción general de EMIC)
- @INFO/EMIC(Introduccion).md

CONTENIDO REQUERIDO:
1. Portada profesional con:
   - Título: "Manual de Desarrollo EMIC SDK - Módulos y APIs"
   - Subtítulo: "Guía Completa para Desarrolladores de Recursos EMIC"
   - Versión y fecha
   - Logo/Banner (ASCII art o referencia)

2. Información del manual:
   - Audiencia objetivo
   - Requisitos previos
   - Estructura del manual
   - Cómo usar este manual

3. Tabla de contenidos completa con:
   - Las 7 secciones principales
   - Todos los 38 capítulos
   - Links navegables (anchors)

4. Convenciones usadas en el manual:
   - Bloques de código
   - Notas importantes
   - Advertencias
   - Tips y trucos
   - Referencias cruzadas

FORMATO:
- Markdown profesional
- Tabla de contenidos navegable
- Diseño visual atractivo

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_1_Introduccion\00_Portada.md
```

**Dependencias:** Ninguna (primer capítulo)

---

#### **CAPÍTULO 01: Introducción al Desarrollo EMIC**

**Archivo de Salida:** `Seccion_1_Introduccion/01_Introduccion.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 01 "Introducción al Desarrollo EMIC" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Este capítulo introduce a los desarrolladores al ecosistema EMIC
- Explica el propósito del manual y el enfoque del desarrollo modular

REFERENCIAS DE ARCHIVOS:
- @00_Portada.md (capítulo previo)
- @INFO/EMIC(Introduccion).md
- @INFO/EMIC.md
- @INFO/DiagramaEMIC.jpg
- @INFO/Arquitectura_EMIC.jpg
- @EMIC_Developer_Manual_V2.1.md

CONTENIDO REQUERIDO:
1. ¿Qué es EMIC? (resumen ejecutivo)
2. ¿Para quién es este manual?
   - Perfil del desarrollador de recursos
   - Perfil del integrador (diferencia)
3. Objetivos del manual
4. Requisitos previos:
   - Conocimientos de C
   - Microcontroladores embebidos (PIC, ARM, AVR, etc.)
   - Conceptos de sistemas embebidos
5. Filosofía EMIC:
   - Modularidad
   - Colaboración
   - Reutilización
   - Estandarización
6. Flujo general del ecosistema EMIC:
   - Desarrollador crea EMIC-Libraries
   - EMIC Discovery extrae recursos
   - Integrador crea script en EMIC-Editor
   - EMIC Generate fusiona Libraries + Script
   - Resultado: código C compilable
7. Roles en el ecosistema:
   - Desarrollador (bajo nivel)
   - Integrador (alto nivel)
   - Comunidad EMIC

GRÁFICOS A INCLUIR:
- Diagrama del flujo completo (basado en DiagramaEMIC.jpg)
- Ilustración de roles Desarrollador vs Integrador
- Timeline del proceso de desarrollo

FORMATO:
- Markdown con imágenes
- Texto motivacional e inspirador
- Ejemplos concretos

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_1_Introduccion\01_Introduccion.md
```

**Dependencias:** Cap 00

---

#### **CAPÍTULO 02: Arquitectura y Conceptos Fundamentales**

**Archivo de Salida:** `Seccion_1_Introduccion/02_Arquitectura.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 02 "Arquitectura y Conceptos Fundamentales" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Explica la arquitectura técnica de EMIC
- Introduce conceptos clave que se usarán en todo el manual

REFERENCIAS DE ARCHIVOS:
- @00_Portada.md
- @01_Introduccion.md (capítulo previo)
- @INFO/Arquitectura_EMIC.jpg
- @INFO/DiagramaEMIC.jpg
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md (secciones de arquitectura)
- @EMIC_Developer_Manual_V2.1.md

CONTENIDO REQUERIDO:
1. Arquitectura del sistema EMIC
2. Los 4 procesos clave:
   - **EMIC Discovery**: Extracción de recursos
   - **EMIC Editor**: Creación de scripts
   - **EMIC Generate**: Fusión de código
   - **EMIC Compiler**: Compilación final
3. Volúmenes lógicos:
   - `DEV:` - EMIC SDK
   - `TARGET:` - Código generado
   - `SYS:` - Configuración
   - `USER:` - Archivos del usuario
4. Conceptos clave:
   - **EMIC SDK**: Repositorio de componentes (antes "Repositorio EMIC")
   - **EMIC-Libraries**: Código C con anotaciones
   - **EMIC-Codify**: Lenguaje de gestión de código
   - **EMIC-Module**: Hardware + Firmware
   - **Tags**: Etiquetas de publicación
   - **Macros**: Variables de texto
5. Flujo de datos:
   - SOURCE Documents → Discovery → Editor
   - Script → Transcriptor → Intermediate Document
   - Intermediate + Libraries → Merge → TARGET Documents
   - TARGET → Compiler → FINAL Documents

GRÁFICOS A INCLUIR:
- Diagrama de arquitectura completo (basado en Arquitectura_EMIC.jpg)
- Diagrama de volúmenes lógicos
- Flowchart del flujo de datos
- Diagrama de componentes y sus relaciones

FORMATO:
- Markdown técnico con diagramas
- Tablas comparativas
- Ejemplos de rutas con volúmenes lógicos

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_1_Introduccion\02_Arquitectura.md
```

**Dependencias:** Cap 00, 01

---

#### **CAPÍTULO 03: Glosario y Vocabulario EMIC**

**Archivo de Salida:** `Seccion_1_Introduccion/03_Glosario.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 03 "Glosario y Vocabulario EMIC" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Diccionario completo de términos EMIC
- Referencia rápida para desarrolladores
- Debe ser exhaustivo pero conciso

REFERENCIAS DE ARCHIVOS:
- @01_Introduccion.md
- @02_Arquitectura.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md
- @EMIC.md
- @EMIC_Developer_Manual_V2.1.md

CONTENIDO REQUERIDO:
Términos ordenados alfabéticamente (al menos estos):

**A**
- API (en contexto EMIC)
- Alias (en etiquetado)

**D**
- Desarrollador (rol)
- DEV: (volumen)
- Discovery (proceso)
- Driver (componente)

**E**
- EMIC-Codify
- EMIC-Generate
- EMIC-Libraries
- EMIC-Module
- EMIC SDK
- EMIC-Editor
- Evento (callback)
- Etiqueta (Tag)

**G**
- generate.emic
- Grupo (de macros)

**H**
- HAL (Hardware Abstraction Layer)

**I**
- Integrador (rol)

**M**
- Macro
- Módulo

**S**
- SYS: (volumen)
- SDK

**T**
- TAG
- TARGET: (volumen)

**U**
- USER: (volumen)

**V**
- Volumen lógico

Cada término debe incluir:
1. Definición clara
2. Contexto de uso
3. Ejemplos si aplica
4. Referencias cruzadas a otros términos relacionados

FORMATO:
- Markdown con anchors navegables
- Tabla al inicio con índice alfabético
- Sección por cada letra
- Referencias cruzadas con links

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_1_Introduccion\03_Glosario.md
```

**Dependencias:** Cap 01, 02

---

#### **CAPÍTULO 04: Ventajas de EMIC vs Otros Métodos**

**Archivo de Salida:** `Seccion_1_Introduccion/04_Ventajas.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 04 "Ventajas de EMIC vs Otros Métodos" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Comparación con métodos tradicionales
- Justificación del uso de EMIC
- Casos de uso ideales

REFERENCIAS DE ARCHIVOS:
- @01_Introduccion.md
- @02_Arquitectura.md
- @03_Glosario.md (capítulo previo)
- @INFO/EMIC.md (secciones de propuesta de valor y mercado)
- @INFO/EMIC(Introduccion).md (ventajas)

CONTENIDO REQUERIDO:
1. Problemas del desarrollo tradicional:
   - Repetición de código
   - Falta de estandarización
   - Tiempo de desarrollo elevado
   - Dificultad de colaboración
   - Curva de aprendizaje empinada

2. EMIC vs Desarrollo desde cero:
   - Reutilización vs desarrollo ad-hoc
   - Tiempo de time-to-market
   - Calidad y testing

3. EMIC vs Frameworks existentes:
   - Vs Arduino/mbed/Zephyr
   - Vs PlatformIO
   - Vs Bare Metal tradicional

4. EMIC vs Low-code platforms genéricas

5. Tabla comparativa de características:
   - Reutilización de código
   - Modularidad
   - Curva de aprendizaje
   - Flexibilidad
   - Control de bajo nivel
   - Comunidad
   - Soporte de hardware

6. ROI: Reducción de tiempos
   - Desarrollo: hasta 90% más rápido
   - Mantenimiento
   - Escalabilidad

7. Casos de uso ideales:
   - IIoT industrial
   - Sensores distribuidos
   - Control embebido
   - Comunicación M2M

8. Beneficios de la colaboración comunitaria

GRÁFICOS A INCLUIR:
- Tabla comparativa visual (EMIC vs otros)
- Gráfico de reducción de tiempo
- Diagrama de reutilización de código
- ROI timeline

FORMATO:
- Markdown persuasivo
- Tablas comparativas
- Gráficos de datos

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_1_Introduccion\04_Ventajas.md
```

**Dependencias:** Cap 01, 02, 03

---

### SECCIÓN 2: ESTRUCTURA DEL EMIC SDK

---

#### **CAPÍTULO 05: Anatomía de un EMIC SDK - Visión General**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/05_Vision_General_SDK.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 05 "Anatomía de un EMIC SDK - Visión General" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Primera visión de la estructura completa del SDK
- Introduce todas las carpetas y su propósito
- Base para los siguientes capítulos detallados

REFERENCIAS DE ARCHIVOS:
- @Seccion_1_Introduccion/01_Introduccion.md
- @Seccion_1_Introduccion/02_Arquitectura.md
- @Seccion_1_Introduccion/03_Glosario.md
- @Seccion_1_Introduccion/04_Ventajas.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md (sección "Organización del EMIC SDK")

REFERENCIAS DEL SDK REAL:
- Explorar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\
- Listar contenido de cada carpeta principal

CONTENIDO REQUERIDO:
1. ¿Qué es un EMIC SDK?
   - Diferencia con "Repositorio EMIC" (término antiguo)
   - SDK = Software Development Kit completo
   - Contiene todos los recursos necesarios

2. Estructura completa de carpetas:
   ```
   EMIC_SDK/
   ├── _modules/      ← Módulos (Hardware + Firmware)
   ├── _api/          ← APIs de alto nivel
   ├── _drivers/      ← Drivers de hardware
   ├── _hal/          ← Hardware Abstraction Layer
   ├── _hard/         ← Código específico de MCU
   ├── _main/         ← Punto de entrada (main.c)
   ├── _pcb/          ← Configuración de PCBs
   ├── _templates/    ← Templates de proyectos
   ├── _system/       ← Sistema core EMIC
   └── _util/         ← Utilidades generales
   ```

3. Propósito de cada carpeta (resumen breve):
   - Cada carpeta tendrá su capítulo detallado

4. Convenciones de nombres:
   - Prefijo underscore (_) para carpetas del sistema
   - CamelCase o snake_case según tipo

5. Flujo de dependencias:
   - Diagrama de capas de abstracción
   - `_util` → `_api` → `_drivers` → `_hal` → `_hard`

6. Estadísticas del SDK real:
   - Cantidad de APIs disponibles
   - Cantidad de Drivers
   - Cantidad de Módulos
   - Categorías de módulos

GRÁFICOS A INCLUIR:
- Árbol de directorios visual
- Diagrama de capas de abstracción
- Flowchart de dependencias

FORMATO:
- Markdown con árbol de directorios ASCII art
- Tablas de resumen
- Enlaces a capítulos detallados

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\05_Vision_General_SDK.md
```

**Dependencias:** Cap 01, 02, 03, 04

---

#### **CAPÍTULO 06: Carpeta `_modules/` - Módulos Hardware + Firmware**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/06_Carpeta_Modules.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 06 "Carpeta _modules/ - Módulos Hardware + Firmware" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Detalle completo de la carpeta _modules/
- Explica qué es un módulo EMIC
- Muestra ejemplos reales del SDK

REFERENCIAS DE ARCHIVOS:
- @Seccion_2_Estructura_SDK/05_Vision_General_SDK.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md
- @Guía para la Creación de Módulos en EMIC.md
- @EMIC_Module_Debugging_Guide_for_AI.md

REFERENCIAS DEL SDK REAL:
- Listar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_modules\
- Explorar categorías disponibles:
  - Actuators/
  - Development_Board/
  - Digital_In_Out/
  - Displays_seven_segments/
  - Graphic_Displays/
  - Indoor_Crops/
  - Oil_and_Gas/
  - Power_Supply/
  - Sensors/
  - Storage/
  - Testing/
  - Wired_Communication/
  - Wired_Control/
  - Wireless_Communication/
- Elegir 2-3 módulos como ejemplo (diferentes categorías)

CONTENIDO REQUERIDO:
1. ¿Qué es un Módulo EMIC?
   - Módulo = Hardware + Firmware + Configuración
   - Unidad funcional completa

2. Estructura de la carpeta _modules/:
   ```
   _modules/
   └── {Category}/
       └── {ModuleName}/
           ├── System/
           │   ├── generate.emic
           │   ├── deploy.emic
           │   ├── config.json
           │   ├── module.json
           │   └── program.xml
           ├── Target/
           └── m_description.json
   ```

3. Categorías de módulos (listar todas las reales)

4. Contenido de cada subcarpeta:
   - **System/**: Archivos de configuración
   - **Target/**: Código generado (output)

5. Archivos clave:
   - `generate.emic`: Script de generación
   - `deploy.emic`: Script de deployment
   - `config.json`: Configuración dinámica
   - `module.json`: Metadata del módulo
   - `m_description.json`: Descripción
   - `program.xml`: Código visual del integrador

6. Ejemplos reales del SDK:
   - Analizar estructura de 2-3 módulos reales
   - Mostrar contenido de sus archivos clave

7. Flujo de vida de un módulo:
   - Creación
   - Configuración
   - Instanciación en proyecto
   - Generación de código

GRÁFICOS A INCLUIR:
- Árbol de estructura de módulo
- Diagrama de archivos y su propósito
- Flowchart del flujo de generación

FORMATO:
- Markdown con ejemplos de código real
- Árboles de directorios
- Tablas de metadatos

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\06_Carpeta_Modules.md
```

**Dependencias:** Cap 05

---

#### **CAPÍTULO 07: Carpeta `_api/` - APIs de Alto Nivel**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/07_Carpeta_API.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 07 "Carpeta _api/ - APIs de Alto Nivel" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Detalle de la carpeta _api/
- Qué es una API en EMIC
- Ejemplos reales del SDK

REFERENCIAS DE ARCHIVOS:
- @Seccion_2_Estructura_SDK/05_Vision_General_SDK.md
- @Seccion_2_Estructura_SDK/06_Carpeta_Modules.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md (sección de APIs)

REFERENCIAS DEL SDK REAL:
- Listar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_api\
- Categorías disponibles:
  - Actuators/
  - ADC/
  - Alarm/
  - Audio/
  - Custom/
  - Development_Board/
  - ExternalFIFO_RAM/
  - Indicators/
  - Inputs/
  - Oil_Gas/
  - Power/
  - Protocols/
  - Sensors/
  - Storage/
  - System/
  - Timers/
  - Wired_Communication/
  - Wireless/
- Analizar 3-4 APIs como ejemplo:
  - Indicators/LEDs/ (ejemplo simple)
  - Timers/ (ejemplo común)
  - Wired_Communication/ (ejemplo complejo)

CONTENIDO REQUERIDO:
1. ¿Qué es una API en EMIC?
   - Abstracción de alto nivel
   - Oculta complejidad del hardware
   - Reutilizable en múltiples módulos

2. Diferencia entre API y Driver:
   - API = alto nivel, independiente de hardware específico
   - Driver = bajo nivel, hardware específico

3. Estructura de una API:
   ```
   _api/{Category}/{APIName}/
   ├── {APIName}.emic
   ├── inc/
   │   └── *.h
   └── src/
       └── *.c
   ```

4. Contenido del archivo .emic:
   - Definición de recursos
   - Dependencias
   - Parámetros configurables

5. Categorías de APIs (listar todas)

6. Análisis de APIs reales:
   - **Ejemplo 1: LED API**
     - Leer: _api/Indicators/LEDs/led.emic
     - Mostrar estructura completa
     - Analizar funciones publicadas
     - Explicar dependencias

   - **Ejemplo 2: Timer API**
     - Analizar estructura
     - Configuración de parámetros

   - **Ejemplo 3: API de Comunicación**
     - Complejidad mayor
     - Múltiples dependencias

7. Etiquetado de funciones en APIs:
   - Tags DOXYGEN
   - @fn, @alias, @brief, @param, @return

8. Gestión de dependencias:
   - Referencias a Drivers
   - Referencias a HAL
   - Referencias a otras APIs

GRÁFICOS A INCLUIR:
- Estructura de API visual
- Diagrama de dependencias API → Driver → HAL
- Flowchart de invocación de API

FORMATO:
- Markdown con código real de ejemplos
- Tablas de APIs disponibles
- Bloques de código comentados

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\07_Carpeta_API.md
```

**Dependencias:** Cap 05, 06

---

#### **CAPÍTULO 08: Carpeta `_drivers/` - Drivers de Hardware**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/08_Carpeta_Drivers.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 08 "Carpeta _drivers/ - Drivers de Hardware" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Detalle de la carpeta _drivers/
- Diferencia clave con APIs
- Ejemplos del SDK real

REFERENCIAS DE ARCHIVOS:
- @Seccion_2_Estructura_SDK/05_Vision_General_SDK.md
- @Seccion_2_Estructura_SDK/06_Carpeta_Modules.md
- @Seccion_2_Estructura_SDK/07_Carpeta_API.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md

REFERENCIAS DEL SDK REAL:
- Listar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_drivers\
- Drivers disponibles:
  - ADC/
  - Amp/
  - Display/
  - I2C/
  - RAM/
  - SystemTimer/
  - USB/
- Analizar 2-3 drivers como ejemplo

CONTENIDO REQUERIDO:
1. ¿Qué es un Driver en EMIC?
   - Abstracción de hardware específico
   - Más bajo nivel que APIs
   - Control directo de periféricos

2. API vs Driver (tabla comparativa):
   - Nivel de abstracción
   - Dependencias
   - Reutilización
   - Casos de uso

3. Estructura de un Driver:
   ```
   _drivers/{DriverName}/
   ├── {DriverName}.emic
   ├── inc/
   │   └── *.h
   └── src/
       └── *.c
   ```

4. Análisis de Drivers reales:
   - **SystemTimer**: Driver fundamental
   - **I2C**: Comunicación
   - **Display**: Periférico complejo

5. Dependencias típicas:
   - HAL (Hardware Abstraction Layer)
   - _hard (código específico de MCU)

6. Publicación de recursos en Drivers

7. Integración con APIs

GRÁFICOS A INCLUIR:
- Diagrama de capas: API → Driver → HAL → Hardware
- Estructura de driver visual
- Ejemplo de comunicación I2C

FORMATO:
- Markdown con ejemplos de código real
- Diagramas de bloques
- Comparaciones visuales

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\08_Carpeta_Drivers.md
```

**Dependencias:** Cap 05, 06, 07

---

#### **CAPÍTULO 09: Carpeta `_hal/` - Hardware Abstraction Layer**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/09_Carpeta_HAL.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 09 "Carpeta _hal/ - Hardware Abstraction Layer" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- HAL abstrae los periféricos del microcontrolador
- Permite portabilidad entre diferentes MCUs

REFERENCIAS DE ARCHIVOS:
- @Seccion_2_Estructura_SDK/07_Carpeta_API.md
- @Seccion_2_Estructura_SDK/08_Carpeta_Drivers.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md

REFERENCIAS DEL SDK REAL:
- Listar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_hal\
- Componentes HAL:
  - ADC/
  - Flash/
  - GPIO/
  - I2C/
  - I2S/
  - pins/
  - PWM/
  - RefCLK/
  - SPI/
  - System/
  - Timer/
  - UART/
- Analizar GPIO y UART como ejemplos

CONTENIDO REQUERIDO:
1. ¿Qué es el HAL?
   - Hardware Abstraction Layer
   - Interfaz común para periféricos
   - Portabilidad

2. Propósito del HAL en EMIC:
   - Aislar código de hardware específico
   - Facilitar soporte multi-MCU
   - Simplificar desarrollo de drivers

3. Componentes HAL disponibles (listar todos)

4. Estructura de un componente HAL:
   - Archivos .emic
   - Headers
   - Implementación

5. Análisis de HAL reales:
   - **GPIO HAL**: Control de pines
   - **UART HAL**: Comunicación serial
   - **I2C HAL**: Bus I2C

6. Relación HAL ↔ _hard:
   - HAL define interfaz
   - _hard implementa para MCU específico

7. Uso del HAL en Drivers y APIs

GRÁFICOS A INCLUIR:
- Diagrama de abstracción: Driver → HAL → _hard → Hardware
- Componentes HAL disponibles
- Ejemplo de portabilidad

FORMATO:
- Markdown técnico
- Diagramas de bloques
- Código de ejemplo

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\09_Carpeta_HAL.md
```

**Dependencias:** Cap 07, 08

---

#### **CAPÍTULO 10: Carpeta `_hard/` - Código Específico de MCU**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/10_Carpeta_Hard.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 10 "Carpeta _hard/ - Código Específico de MCU" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- _hard contiene implementaciones específicas por microcontrolador
- Nivel más bajo de la pila de abstracción

REFERENCIAS DE ARCHIVOS:
- @Seccion_2_Estructura_SDK/08_Carpeta_Drivers.md
- @Seccion_2_Estructura_SDK/09_Carpeta_HAL.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md

REFERENCIAS DEL SDK REAL:
- Explorar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_hard\
- Analizar estructura

CONTENIDO REQUERIDO:
1. ¿Qué es _hard?
   - Código dependiente de MCU
   - Registros específicos
   - Configuraciones de hardware

2. Organización por familia de MCU:
   - PIC16F
   - PIC18F
   - PIC24F
   - dsPIC33
   - etc.

3. Contenido típico:
   - Configuración de registros
   - Inicialización de periféricos
   - Funciones de bajo nivel

4. Relación con HAL:
   - HAL define interfaz
   - _hard la implementa

5. Ejemplos de código específico

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\10_Carpeta_Hard.md
```

**Dependencias:** Cap 08, 09

---

#### **CAPÍTULO 11: Carpeta `_main/` - Punto de Entrada**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/11_Carpeta_Main.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 11 "Carpeta _main/ - Punto de Entrada" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- _main contiene el main.c y lógica de inicialización
- Baremetal vs RTOS

REFERENCIAS DE ARCHIVOS:
- @Seccion_2_Estructura_SDK/05_Vision_General_SDK.md
- @Seccion_2_Estructura_SDK/06_Carpeta_Modules.md
- @Seccion_2_Estructura_SDK/10_Carpeta_Hard.md (capítulo previo)

REFERENCIAS DEL SDK REAL:
- Explorar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_main\
- Analizar main.emic disponibles

CONTENIDO REQUERIDO:
1. Propósito de _main
2. Estructura del main.c generado
3. Inicialización de drivers
4. Loop principal
5. Gestión de eventos
6. Baremetal vs RTOS
7. Ejemplo de main.emic

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\11_Carpeta_Main.md
```

**Dependencias:** Cap 05, 06, 10

---

#### **CAPÍTULO 12: Carpeta `_pcb/` - Configuración de Hardware**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/12_Carpeta_PCB.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 12 "Carpeta _pcb/ - Configuración de Hardware" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- _pcb define configuraciones de PCBs
- Mapping de pines
- Configuraciones específicas de hardware

REFERENCIAS DE ARCHIVOS:
- @Seccion_2_Estructura_SDK/06_Carpeta_Modules.md
- @Seccion_2_Estructura_SDK/11_Carpeta_Main.md (capítulo previo)

REFERENCIAS DEL SDK REAL:
- Explorar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_pcb\
- Analizar archivos pcb.emic

CONTENIDO REQUERIDO:
1. Propósito de _pcb
2. Archivo pcb.emic
3. Definición de pines
4. Configuración de periféricos
5. Múltiples versiones de PCB
6. Ejemplo real

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\12_Carpeta_PCB.md
```

**Dependencias:** Cap 06, 11

---

#### **CAPÍTULO 13: Carpeta `_templates/` - Templates de Proyectos**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/13_Carpeta_Templates.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 13 "Carpeta _templates/ - Templates de Proyectos" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- _templates contiene plantillas de proyectos para IDEs
- MPLAB X principalmente

REFERENCIAS DE ARCHIVOS:
- @Seccion_2_Estructura_SDK/05_Vision_General_SDK.md
- @Seccion_2_Estructura_SDK/12_Carpeta_PCB.md (capítulo previo)

REFERENCIAS DEL SDK REAL:
- Explorar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_templates\
- Analizar templates disponibles

CONTENIDO REQUERIDO:
1. Propósito de _templates
2. Templates para MPLAB X
3. Configuración de proyecto
4. Makefiles
5. Cómo se integran en generate.emic

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\13_Carpeta_Templates.md
```

**Dependencias:** Cap 05, 12

---

#### **CAPÍTULO 14: Carpeta `_system/` - Sistema Core EMIC**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/14_Carpeta_System.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 14 "Carpeta _system/ - Sistema Core EMIC" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- _system contiene funciones core del sistema EMIC
- Conversiones de tipos
- Includes necesarios

REFERENCIAS DE ARCHIVOS:
- @Seccion_2_Estructura_SDK/05_Vision_General_SDK.md
- @Seccion_2_Estructura_SDK/13_Carpeta_Templates.md (capítulo previo)

REFERENCIAS DEL SDK REAL:
- Explorar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_system\

CONTENIDO REQUERIDO:
1. Propósito de _system
2. Conversiones de tipos de datos
3. Includes fundamentales
4. Funciones de sistema

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\14_Carpeta_System.md
```

**Dependencias:** Cap 05, 13

---

#### **CAPÍTULO 15: Carpeta `_util/` - Utilidades Generales**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/15_Carpeta_Util.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 15 "Carpeta _util/ - Utilidades Generales" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- _util contiene funciones de uso general
- Independiente de hardware
- Operadores matemáticos, lógicos, strings, etc.

REFERENCIAS DE ARCHIVOS:
- @Seccion_2_Estructura_SDK/05_Vision_General_SDK.md
- @Seccion_2_Estructura_SDK/07_Carpeta_API.md
- @Seccion_2_Estructura_SDK/14_Carpeta_System.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md

REFERENCIAS DEL SDK REAL:
- Explorar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_util\

CONTENIDO REQUERIDO:
1. Propósito de _util
2. Tipos de utilidades:
   - Operadores matemáticos
   - Operadores lógicos
   - Operadores de strings
   - Control de flujo
3. Independencia de hardware
4. Ejemplos de utilidades comunes

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\15_Carpeta_Util.md
```

**Dependencias:** Cap 05, 07, 14

---

### SECCIÓN 3: EMIC-CODIFY

---

#### **CAPÍTULO 16: Fundamentos de EMIC-Codify**

**Archivo de Salida:** `Seccion_3_EMIC_Codify/16_Fundamentos_Codify.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 16 "Fundamentos de EMIC-Codify" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Introducción al lenguaje EMIC-Codify
- Base para todos los comandos

REFERENCIAS DE ARCHIVOS:
- @Seccion_1_Introduccion/02_Arquitectura.md
- @Seccion_2_Estructura_SDK/15_Carpeta_Util.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md (sección "EMIC Codify")

CONTENIDO REQUERIDO:
1. ¿Qué es EMIC-Codify?
2. Propósito y filosofía
3. Comandos vs Etiquetas (Tags)
4. Sintaxis general
5. Volúmenes lógicos (DEV:, TARGET:, SYS:, USER:)
6. Conceptos de macros
7. Flujo de procesamiento
8. Primer ejemplo simple

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_3_EMIC_Codify\16_Fundamentos_Codify.md
```

**Dependencias:** Cap 02, 15

---

#### **CAPÍTULO 17: Comandos EMIC-Codify - Parte 1: Gestión de Archivos**

**Archivo de Salida:** `Seccion_3_EMIC_Codify/17_Comandos_Archivos.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 17 "Comandos EMIC-Codify (Parte 1: Gestión de Archivos)" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Comandos para manipulación de archivos
- setInput, setOutput, restoreOutput, copy

REFERENCIAS DE ARCHIVOS:
- @Seccion_3_EMIC_Codify/16_Fundamentos_Codify.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md (sección de comandos)

CONTENIDO REQUERIDO:
1. Comando setInput:
   - Sintaxis
   - Parámetros
   - Ejemplos

2. Comando setOutput:
   - Sintaxis
   - Parámetros
   - Stack de outputs

3. Comando restoreOutput:
   - Uso
   - Gestión de stack

4. Comando copy:
   - Sintaxis completa
   - Parámetros con macros
   - Ejemplos prácticos

5. Ejemplos del SDK real

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_3_EMIC_Codify\17_Comandos_Archivos.md
```

**Dependencias:** Cap 16

---

#### **CAPÍTULO 18: Comandos EMIC-Codify - Parte 2: Macros y Sustitución**

**Archivo de Salida:** `Seccion_3_EMIC_Codify/18_Comandos_Macros.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 18 "Comandos EMIC-Codify (Parte 2: Macros y Sustitución)" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Comandos para definir y usar macros
- define, unDefine, sustitución .{key}.

REFERENCIAS DE ARCHIVOS:
- @Seccion_3_EMIC_Codify/16_Fundamentos_Codify.md
- @Seccion_3_EMIC_Codify/17_Comandos_Archivos.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md

CONTENIDO REQUERIDO:
1. Comando define:
   - Sintaxis
   - Grupos de macros
   - Ejemplos

2. Comando unDefine:
   - Borrado de macros

3. Sustitución .{key}.:
   - Sintaxis
   - Grupos (local, global)
   - Búsqueda jerárquica

4. Comando foreach:
   - Iteración sobre grupos
   - Uso de .{Item}.

5. Sustitución .{group.*}.:
   - Expansión de grupos completos

6. Ejemplos prácticos del SDK

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_3_EMIC_Codify\18_Comandos_Macros.md
```

**Dependencias:** Cap 16, 17

---

#### **CAPÍTULO 19: Comandos EMIC-Codify - Parte 3: Control de Flujo**

**Archivo de Salida:** `Seccion_3_EMIC_Codify/19_Comandos_Control.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 19 "Comandos EMIC-Codify (Parte 3: Control de Flujo)" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Comandos condicionales
- if, elif, else, endif, ifdef, ifndef

REFERENCIAS DE ARCHIVOS:
- @Seccion_3_EMIC_Codify/16_Fundamentos_Codify.md
- @Seccion_3_EMIC_Codify/18_Comandos_Macros.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md

CONTENIDO REQUERIDO:
1. Comando if:
   - Sintaxis
   - Condiciones
   - Bloques

2. Comandos elif y else

3. Comando endif

4. Comando ifdef:
   - Verificar si macro está definida

5. Comando ifndef:
   - Verificar si macro NO está definida

6. Ejemplos de uso en generate.emic del SDK

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_3_EMIC_Codify\19_Comandos_Control.md
```

**Dependencias:** Cap 16, 18

---

#### **CAPÍTULO 20: Etiquetado de Recursos (Tags)**

**Archivo de Salida:** `Seccion_3_EMIC_Codify/20_Etiquetado_Recursos.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 20 "Etiquetado de Recursos (Tags)" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Tags para publicar recursos en EMIC Discovery
- Diferencia entre Tags y Macros
- Formato DOXYGEN y JSON

REFERENCIAS DE ARCHIVOS:
- @Seccion_3_EMIC_Codify/16_Fundamentos_Codify.md
- @Seccion_3_EMIC_Codify/17_Comandos_Archivos.md
- @Seccion_3_EMIC_Codify/19_Comandos_Control.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md (sección "Tags EMIC Codify")
- @Seccion_2_Estructura_SDK/07_Carpeta_API.md

REFERENCIAS DEL SDK REAL:
- Analizar tags en APIs: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_api\
- Ejemplo: _api/Indicators/LEDs/

CONTENIDO REQUERIDO:
1. ¿Qué son los Tags?
   - Diferencia con Macros
   - Propósito: publicación en Discovery

2. Tag driverName:
   - EMIC:tag(driverName = xxx)
   - Agrupación de recursos

3. Etiquetado de funciones (formato DOXYGEN):
   - @fn: Firma de función
   - @alias: Nombre en editor
   - @brief: Descripción
   - @param: Parámetros
   - @return: Valor de retorno
   - Ejemplo completo

4. Etiquetado de eventos:
   - extern en @fn
   - Callbacks

5. Etiquetado de variables:
   - Formato inline
   - /**<Alias:xxx> Descripción */

6. Funciones variádicas:
   - Parámetros concat
   - Ejemplo con formato "..."

7. Formato JSON para recursos especiales:
   - EMIC:json(type = Configurator)
   - Menús de configuración
   - Ejemplo completo

8. Ejemplos reales del SDK:
   - Analizar LED API
   - Analizar Timer API

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_3_EMIC_Codify\20_Etiquetado_Recursos.md
```

**Dependencias:** Cap 16, 17, 19, Cap 07 (Carpeta API)

---

### SECCIÓN 4: DESARROLLO PRÁCTICO

---

#### **CAPÍTULO 21: Desarrollo de una API EMIC - Paso a Paso**

**Archivo de Salida:** `Seccion_4_Desarrollo/21_Desarrollo_API.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 21 "Desarrollo de una API EMIC - Paso a Paso" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Guía práctica completa para crear una API
- Paso a paso con ejemplos
- Usar API real del SDK como referencia

REFERENCIAS DE ARCHIVOS:
- @Seccion_2_Estructura_SDK/07_Carpeta_API.md
- @Seccion_3_EMIC_Codify/20_Etiquetado_Recursos.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md
- @EMIC_Developer_Manual_V2.1.md

REFERENCIAS DEL SDK REAL:
- Analizar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_api\Indicators\LEDs\
- Usar como ejemplo completo

CONTENIDO REQUERIDO:
1. ¿Cuándo crear una API?
   - Caso de uso
   - Diferencia con Driver

2. Planificación:
   - Definir funcionalidad
   - Identificar dependencias
   - Diseñar interfaz pública

3. **Paso 1**: Crear estructura de carpetas
   ```
   _api/{Category}/{APIName}/
   ├── {APIName}.emic
   ├── inc/
   └── src/
   ```

4. **Paso 2**: Escribir código C (.c y .h)
   - Header con declaraciones
   - Implementación
   - Best practices

5. **Paso 3**: Etiquetar recursos
   - Tags DOXYGEN
   - Funciones públicas
   - Variables (si aplica)

6. **Paso 4**: Crear archivo .emic
   - Definir dependencias
   - Comandos copy
   - Definir macros de compilación

7. **Paso 5**: Testing y validación
   - Integrar en módulo de prueba
   - Verificar Discovery

8. **EJEMPLO COMPLETO: API de LEDs**
   - Código completo comentado
   - Análisis línea por línea del SDK real

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_4_Desarrollo\21_Desarrollo_API.md
```

**Dependencias:** Cap 07, Cap 20

---

#### **CAPÍTULO 22: Desarrollo de un Driver EMIC**

**Archivo de Salida:** `Seccion_4_Desarrollo/22_Desarrollo_Driver.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 22 "Desarrollo de un Driver EMIC" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Guía para crear Drivers de hardware
- Diferencias con APIs
- Ejemplo real del SDK

REFERENCIAS DE ARCHIVOS:
- @Seccion_2_Estructura_SDK/08_Carpeta_Drivers.md
- @Seccion_2_Estructura_SDK/09_Carpeta_HAL.md
- @Seccion_4_Desarrollo/21_Desarrollo_API.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md

REFERENCIAS DEL SDK REAL:
- Analizar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_drivers\
- Elegir SystemTimer o I2C como ejemplo

CONTENIDO REQUERIDO:
1. ¿Cuándo crear un Driver?
2. Driver vs API (repaso)
3. Planificación de driver
4. Paso a paso (similar a Cap 21)
5. Integración con HAL
6. Ejemplo completo de driver real

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_4_Desarrollo\22_Desarrollo_Driver.md
```

**Dependencias:** Cap 08, 09, 21

---

#### **CAPÍTULO 23: Desarrollo de un Módulo EMIC Completo**

**Archivo de Salida:** `Seccion_4_Desarrollo/23_Desarrollo_Modulo.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 23 "Desarrollo de un Módulo EMIC Completo" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Desarrollo completo de un módulo
- Integración de APIs y Drivers
- Ejemplo real del SDK

REFERENCIAS DE ARCHIVOS:
- @Seccion_2_Estructura_SDK/06_Carpeta_Modules.md
- @Seccion_2_Estructura_SDK/12_Carpeta_PCB.md
- @Seccion_4_Desarrollo/21_Desarrollo_API.md
- @Seccion_4_Desarrollo/22_Desarrollo_Driver.md (capítulo previo)
- @Guía para la Creación de Módulos en EMIC.md
- @EMIC_Module_Debugging_Guide_for_AI.md

REFERENCIAS DEL SDK REAL:
- Analizar módulo real: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_modules\
- Elegir módulo de ejemplo (Digital_In_Out o Wired_Control)

CONTENIDO REQUERIDO:
1. ¿Qué es un módulo completo?
2. Planificación del módulo
3. Paso 1: Crear categoría (si no existe)
4. Paso 2: Definir hardware (PCB)
5. Paso 3: Seleccionar APIs/Drivers
6. Paso 4: Crear generate.emic
7. Paso 5: Configurar hardware
8. Paso 6: Metadata (module.json, m_description.json)
9. Paso 7: Testing completo
10. Ejemplo completo paso a paso

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_4_Desarrollo\23_Desarrollo_Modulo.md
```

**Dependencias:** Cap 06, 12, 21, 22

---

#### **CAPÍTULO 24: Creación de Categorías de Módulos**

**Archivo de Salida:** `Seccion_4_Desarrollo/24_Creacion_Categorias.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 24 "Creación de Categorías de Módulos" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Organización de módulos en categorías
- Convenciones de nombres
- Metadata de categorías

REFERENCIAS DE ARCHIVOS:
- @Seccion_2_Estructura_SDK/06_Carpeta_Modules.md
- @Seccion_4_Desarrollo/23_Desarrollo_Modulo.md (capítulo previo)

REFERENCIAS DEL SDK REAL:
- Listar categorías: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_modules\

CONTENIDO REQUERIDO:
1. ¿Qué son las categorías?
2. Categorías existentes (listar todas)
3. Convenciones de nombres
4. Cuándo crear nueva categoría
5. Estructura de categoría
6. Metadata de categoría
7. Ejemplo de creación

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_4_Desarrollo\24_Creacion_Categorias.md
```

**Dependencias:** Cap 06, 23

---

#### **CAPÍTULO 25: El Proceso de Generación (generate.emic)**

**Archivo de Salida:** `Seccion_4_Desarrollo/25_Proceso_Generacion.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 25 "El Proceso de Generación (generate.emic)" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Análisis profundo de generate.emic
- Secuencia de ejecución
- Ejemplos del SDK

REFERENCIAS DE ARCHIVOS:
- @Seccion_2_Estructura_SDK/06_Carpeta_Modules.md
- @Seccion_3_EMIC_Codify/ (todos los capítulos de Codify)
- @Seccion_4_Desarrollo/23_Desarrollo_Modulo.md
- @Seccion_4_Desarrollo/24_Creacion_Categorias.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md (ejemplo de generate.emic)

REFERENCIAS DEL SDK REAL:
- Analizar generate.emic de módulos reales

CONTENIDO REQUERIDO:
1. Propósito de generate.emic
2. Anatomía de un generate.emic típico
3. Secuencia de ejecución:
   - Configuración de salida
   - Config de hardware
   - Procesamiento de funciones/eventos
   - Carga de APIs
   - Carga de main
   - Copia de archivos usuario
   - Definición de módulos compilación
   - Templates
4. Paso de parámetros a APIs
5. Gestión de salidas y stack
6. Ejemplo completo comentado línea por línea

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_4_Desarrollo\25_Proceso_Generacion.md
```

**Dependencias:** Cap 06, Cap 16-20 (Codify), Cap 23, 24

---

#### **CAPÍTULO 26: Configuración Dinámica de Módulos**

**Archivo de Salida:** `Seccion_4_Desarrollo/26_Configuracion_Dinamica.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 26 "Configuración Dinámica de Módulos" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Sistema de Configurator
- Menús interactivos
- config.json y module.json

REFERENCIAS DE ARCHIVOS:
- @Seccion_2_Estructura_SDK/06_Carpeta_Modules.md
- @Seccion_3_EMIC_Codify/20_Etiquetado_Recursos.md (JSON Configurator)
- @Seccion_4_Desarrollo/25_Proceso_Generacion.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md

REFERENCIAS DEL SDK REAL:
- Buscar ejemplos de Configurator en APIs/Drivers

CONTENIDO REQUERIDO:
1. Sistema de Configurator
2. config.json
3. module.json
4. Menús interactivos para integradores
5. Configuración iterativa
6. Validación de configuraciones
7. Ejemplo: Configuración de protocolo RS232

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_4_Desarrollo\26_Configuracion_Dinamica.md
```

**Dependencias:** Cap 06, Cap 20, Cap 25

---

### SECCIÓN 5: CASOS PRÁCTICOS

---

#### **CAPÍTULO 27: Caso Práctico - API de LEDs**

**Archivo de Salida:** `Seccion_5_Casos_Practicos/27_Practica_API_LED.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 27 "Caso Práctico: API de LEDs" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Desarrollo completo desde cero
- Código completo comentado
- Uso del API real del SDK como base

REFERENCIAS DE ARCHIVOS:
- @Seccion_4_Desarrollo/21_Desarrollo_API.md
- @Seccion_4_Desarrollo/26_Configuracion_Dinamica.md (capítulo previo)

REFERENCIAS DEL SDK REAL:
- Analizar en detalle: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_api\Indicators\LEDs\
- Código completo: led.emic, inc/led.h, src/led.c

CONTENIDO REQUERIDO:
1. Planificación del API de LEDs
2. Funcionalidades:
   - state (on/off/toggle)
   - blink (parpadeo con parámetros)
3. Código completo comentado
4. Etiquetado de recursos
5. Archivo .emic completo
6. Testing en módulo

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_5_Casos_Practicos\27_Practica_API_LED.md
```

**Dependencias:** Cap 21, 26

---

#### **CAPÍTULO 28: Caso Práctico - Driver de Sensor I2C**

**Archivo de Salida:** `Seccion_5_Casos_Practicos/28_Practica_Driver_I2C.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 28 "Caso Práctico: Driver de Sensor I2C" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Desarrollo de driver complejo
- Comunicación I2C
- Integración con HAL

REFERENCIAS DE ARCHIVOS:
- @Seccion_4_Desarrollo/22_Desarrollo_Driver.md
- @Seccion_5_Casos_Practicos/27_Practica_API_LED.md (capítulo previo)

REFERENCIAS DEL SDK REAL:
- Analizar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_drivers\I2C\
- Analizar: _hal/I2C/

CONTENIDO REQUERIDO:
1. Planificación del driver
2. Protocolo I2C (breve)
3. Uso del HAL I2C
4. Código completo comentado
5. Gestión de errores
6. Testing

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_5_Casos_Practicos\28_Practica_Driver_I2C.md
```

**Dependencias:** Cap 22, 27

---

#### **CAPÍTULO 29: Caso Práctico - Módulo de Control con USB**

**Archivo de Salida:** `Seccion_5_Casos_Practicos/29_Practica_Modulo_USB.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 29 "Caso Práctico: Módulo de Control con USB" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Módulo completo con múltiples APIs
- Control de actuadores + comunicación USB
- Ejemplo real del SDK

REFERENCIAS DE ARCHIVOS:
- @Seccion_4_Desarrollo/23_Desarrollo_Modulo.md
- @Seccion_5_Casos_Practicos/27_Practica_API_LED.md
- @Seccion_5_Casos_Practicos/28_Practica_Driver_I2C.md (capítulo previo)

REFERENCIAS DEL SDK REAL:
- Analizar módulo con USB: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_modules\Wired_Control\

CONTENIDO REQUERIDO:
1. Planificación del módulo
2. Hardware: Relés + USB
3. APIs necesarias:
   - Relay API
   - USB API
   - LED API
   - Timer API
4. generate.emic completo
5. PCB configuration
6. Testing completo

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_5_Casos_Practicos\29_Practica_Modulo_USB.md
```

**Dependencias:** Cap 23, 27, 28

---

#### **CAPÍTULO 30: Caso Práctico - Módulo Multi-API Complejo**

**Archivo de Salida:** `Seccion_5_Casos_Practicos/30_Practica_Modulo_Complejo.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 30 "Caso Práctico: Módulo Multi-API Complejo" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Módulo avanzado con múltiples APIs
- Comunicación, sensores, actuadores
- Caso real del SDK

REFERENCIAS DE ARCHIVOS:
- @Seccion_4_Desarrollo/23_Desarrollo_Modulo.md
- @Seccion_5_Casos_Practicos/29_Practica_Modulo_USB.md (capítulo previo)

REFERENCIAS DEL SDK REAL:
- Analizar módulo complejo: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_modules\

CONTENIDO REQUERIDO:
1. Planificación de módulo complejo
2. Integración de múltiples APIs
3. Gestión de dependencias
4. generate.emic avanzado
5. Configuración dinámica
6. Testing exhaustivo

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_5_Casos_Practicos\30_Practica_Modulo_Complejo.md
```

**Dependencias:** Cap 23, 29

---

### SECCIÓN 6: AVANZADO

---

#### **CAPÍTULO 31: Buenas Prácticas y Convenciones**

**Archivo de Salida:** `Seccion_6_Avanzado/31_Buenas_Practicas.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 31 "Buenas Prácticas y Convenciones" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Convenciones de código
- Estándares EMIC
- Mejores prácticas

REFERENCIAS DE ARCHIVOS:
- Todos los capítulos de desarrollo (21-30)
- @EMIC_Developer_Manual_V2.1.md

CONTENIDO REQUERIDO:
1. Convenciones de nombres:
   - APIs
   - Drivers
   - Módulos
   - Funciones
   - Variables
2. Documentación obligatoria
3. Gestión de dependencias
4. Optimización de código
5. Reutilización vs duplicación
6. Manejo de errores
7. Versionado
8. Comentarios y legibilidad
9. Testing

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_6_Avanzado\31_Buenas_Practicas.md
```

**Dependencias:** Cap 21-30

---

#### **CAPÍTULO 32: Testing y Validación**

**Archivo de Salida:** `Seccion_6_Avanzado/32_Testing.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 32 "Testing y Validación" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Metodología de testing para EMIC
- Validación de recursos
- Testing de módulos

REFERENCIAS DE ARCHIVOS:
- @Seccion_6_Avanzado/31_Buenas_Practicas.md (capítulo previo)
- @EMIC_Module_Debugging_Guide_for_AI.md

CONTENIDO REQUERIDO:
1. Testing de APIs
2. Testing de Drivers
3. Testing de Módulos
4. Validación de Discovery
5. Testing de generate.emic
6. Simulación vs hardware real
7. Herramientas de testing

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_6_Avanzado\32_Testing.md
```

**Dependencias:** Cap 31

---

#### **CAPÍTULO 33: Troubleshooting y Debugging**

**Archivo de Salida:** `Seccion_6_Avanzado/33_Troubleshooting.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 33 "Troubleshooting y Debugging" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Problemas comunes
- Soluciones
- Herramientas de debug

REFERENCIAS DE ARCHIVOS:
- @Seccion_6_Avanzado/32_Testing.md (capítulo previo)
- @EMIC_Module_Debugging_Guide_for_AI.md

CONTENIDO REQUERIDO:
1. Errores comunes de Discovery
2. Errores de Generate
3. Errores de compilación
4. Debugging de macros
5. Validación de Tags
6. Herramientas de diagnóstico
7. FAQ de problemas

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_6_Avanzado\33_Troubleshooting.md
```

**Dependencias:** Cap 32

---

#### **CAPÍTULO 34: Optimización y Performance**

**Archivo de Salida:** `Seccion_6_Avanzado/34_Optimizacion.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 34 "Optimización y Performance" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Optimización de código generado
- Performance en sistemas embebidos
- Memory management

REFERENCIAS DE ARCHIVOS:
- @Seccion_6_Avanzado/31_Buenas_Practicas.md
- @Seccion_6_Avanzado/33_Troubleshooting.md (capítulo previo)

CONTENIDO REQUERIDO:
1. Optimización de APIs
2. Optimización de memoria
3. Optimización de velocidad
4. Gestión de recursos limitados
5. Profiling
6. Trade-offs

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_6_Avanzado\34_Optimizacion.md
```

**Dependencias:** Cap 31, 33

---

### SECCIÓN 7: REFERENCIAS

---

#### **CAPÍTULO 35: Apéndice A - Referencia Rápida de Comandos**

**Archivo de Salida:** `Seccion_7_Referencias/35_Referencia_Comandos.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 35 "Apéndice A: Referencia Rápida de Comandos" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Referencia rápida de todos los comandos EMIC-Codify
- Formato tipo cheatsheet

REFERENCIAS DE ARCHIVOS:
- @Seccion_3_EMIC_Codify/ (todos los capítulos de Codify)
- @Seccion_6_Avanzado/34_Optimizacion.md (capítulo previo)

CONTENIDO REQUERIDO:
1. Tabla de todos los comandos
2. Sintaxis resumida
3. Parámetros
4. Ejemplos breves
5. Referencias cruzadas a capítulos detallados

FORMATO:
- Tablas concisas
- Quick reference
- Índice alfabético

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_7_Referencias\35_Referencia_Comandos.md
```

**Dependencias:** Cap 16-20, Cap 34

---

#### **CAPÍTULO 36: Apéndice B - Referencia Rápida de Tags**

**Archivo de Salida:** `Seccion_7_Referencias/36_Referencia_Tags.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 36 "Apéndice B: Referencia Rápida de Tags" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Referencia rápida de Tags
- Formato tipo cheatsheet

REFERENCIAS DE ARCHIVOS:
- @Seccion_3_EMIC_Codify/20_Etiquetado_Recursos.md
- @Seccion_7_Referencias/35_Referencia_Comandos.md (capítulo previo)

CONTENIDO REQUERIDO:
1. Todos los tipos de Tags
2. Sintaxis DOXYGEN
3. Sintaxis JSON
4. Ejemplos breves
5. Referencias a capítulos

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_7_Referencias\36_Referencia_Tags.md
```

**Dependencias:** Cap 20, Cap 35

---

#### **CAPÍTULO 37: Apéndice C - Plantillas de Código**

**Archivo de Salida:** `Seccion_7_Referencias/37_Plantillas_Codigo.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 37 "Apéndice C: Plantillas de Código" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Plantillas listas para usar
- Copy-paste templates

REFERENCIAS DE ARCHIVOS:
- @Seccion_4_Desarrollo/ (todos)
- @Seccion_7_Referencias/36_Referencia_Tags.md (capítulo previo)

CONTENIDO REQUERIDO:
1. Template de API completa
2. Template de Driver
3. Template de generate.emic
4. Template de module.json
5. Template de config.json
6. Template de funciones etiquetadas

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_7_Referencias\37_Plantillas_Codigo.md
```

**Dependencias:** Cap 21-26, Cap 36

---

#### **CAPÍTULO 38: Apéndice D - Recursos Adicionales**

**Archivo de Salida:** `Seccion_7_Referencias/38_Recursos_Adicionales.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 38 "Apéndice D: Recursos Adicionales" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Recursos externos
- Comunidad EMIC
- Documentación adicional

REFERENCIAS DE ARCHIVOS:
- @Seccion_7_Referencias/37_Plantillas_Codigo.md (capítulo previo)
- @README.md
- @EMIC.md

CONTENIDO REQUERIDO:
1. Links a documentación oficial
2. Comunidad EMIC
3. GitHub
4. Foros y soporte
5. Tutoriales externos
6. Videos (si existen)
7. Otros manuales relacionados

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_7_Referencias\38_Recursos_Adicionales.md
```

**Dependencias:** Cap 37 (último capítulo)

---

## 📊 ESTADÍSTICAS DEL MANUAL

- **Total de capítulos:** 38
- **Total de secciones:** 7
- **Páginas estimadas:** 300-400 páginas
- **Nivel:** Desarrolladores de recursos EMIC
- **Audiencia:** Desarrolladores con conocimientos de C y sistemas embebidos

---

## 🚀 CÓMO USAR ESTE PLAN

### Para ejecutar cada capítulo:

1. **Abrir nueva sesión de Claude Code**
2. **Copiar el prompt del capítulo deseado**
3. **Ejecutar en Claude Code**
4. **Verificar que el archivo se guardó correctamente**
5. **Marcar en el checklist** ✅

### Orden recomendado:

- **Secuencial:** Capítulos 00 → 38 (ideal para manual completo)
- **Por secciones:** Completar una sección antes de pasar a la siguiente
- **Prioritario:** Cap 00, 01, 02, 05, 16, 21, 23 (core concepts)

---

## 📝 NOTAS FINALES

- Cada prompt es **independiente** y puede ejecutarse en sesiones separadas
- Los prompts incluyen todas las **referencias necesarias** a archivos y capítulos previos
- Se usan **ejemplos reales del SDK** en `C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M`
- El manual será **exhaustivo y práctico**
- Cada capítulo es un **documento standalone** pero referencia otros cuando es necesario

---

**Última actualización:** 2025-11-04
**Versión del Plan:** 1.0
**Status:** ✅ Listo para ejecución
