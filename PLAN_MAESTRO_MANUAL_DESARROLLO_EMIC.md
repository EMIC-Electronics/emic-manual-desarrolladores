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


### SECCIÓN 1: INTRODUCCIÓN Y FUNDAMENTOS

---

#### **CAPÍTULO 03: Glosario y Vocabulario EMIC**

**Archivo de Salida:** `Seccion_1_Introduccion/03_Glosario.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 03 "Glosario y Vocabulario EMIC" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Definición clara de los términos únicos del ecosistema EMIC.
- Debe servir como referencia constante.
- Basado en los conceptos de Arquitectura.

REFERENCIAS:
- @Seccion_1_Introduccion/02_Arquitectura.md
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md

CONTENIDO REQUERIDO:
1. Definiciones Clave:
   - EMIC (Ecosistema)
   - SDK (La carpeta raíz)
   - API (Application Programming Interface en contexto EMIC)
   - Driver (Controlador de bajo nivel)
   - HAL (Hardware Abstraction Layer)
   - Módulo (Unidad funcional Hard+Soft)
   - EMIC-Codify (Lenguaje de scripting)
   - Tags (Etiquetas de descubrimiento)
   - Discovery, Transcriptor, Merge, Compiler (Los 4 procesos)
2. Términos de Archivos:
   - .emic, .c, .h, .json
3. Términos de Volúmenes:
   - DEV:, TARGET:, SYS:, USER:
4. Tabla de acrónimos comunes (GPIO, I2C, UART, etc. en contexto EMIC)

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_1_Introduccion\03_Glosario.md
```

**Dependencias:** Cap 02

---

#### **CAPÍTULO 04: Ventajas de EMIC vs Otros Métodos**

**Archivo de Salida:** `Seccion_1_Introduccion/04_Ventajas_EMIC.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 04 "Ventajas de EMIC vs Otros Métodos" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Comparativa técnica y filosófica.
- Por qué un desarrollador debería usar EMIC en lugar de Baremetal puro o Arduino/HALs genéricas.

REFERENCIAS:
- @Seccion_1_Introduccion/01_Introduccion.md

CONTENIDO REQUERIDO:
1. Tabla Comparativa: EMIC vs Baremetal vs Arduino vs Vendor SDKs (Harmony/CodeConfigurator)
2. Ventajas para el Desarrollador:
   - Reutilización real (Write once, use many)
   - Estandarización de drivers
   - Documentación autogenerada (Tags)
3. Ventajas para el Integrador (Cliente del desarrollador):
   - Facilidad de uso (Drag & Drop)
   - Abstracción de hardware compleja
4. Análisis de ROI (Retorno de Inversión) en tiempo de desarrollo
5. El valor de la comunidad y el ecosistema compartido

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_1_Introduccion\04_Ventajas_EMIC.md
```

**Dependencias:** Cap 03

---

### SECCIÓN 2: ESTRUCTURA DEL EMIC SDK

---

#### **CAPÍTULO 05: Anatomía de un EMIC SDK (Visión General)**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/05_Vision_General_SDK.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 05 "Anatomía de un EMIC SDK (Visión General)" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Mapa general de las carpetas del SDK.
- Primera inmersión en la estructura de archivos.

REFERENCIAS:
- Explorar carpeta raíz del SDK: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M

CONTENIDO REQUERIDO:
1. Estructura de Directorios (Árbol ASCII)
2. Descripción breve de cada carpeta raíz:
   - _api, _drivers, _hal, _hard, _main, _modules, _pcb, _system, _templates, _util
3. Flujo de dependencias entre carpetas (quién incluye a quién)
4. Convenciones de nombres de archivos y carpetas
5. Ubicación de archivos de configuración (.json)

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\05_Vision_General_SDK.md
```

**Dependencias:** Cap 04

---

#### **CAPÍTULO 06: Carpeta `_modules/` - Módulos Hardware + Firmware**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/06_Carpeta_Modules.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 06 "Carpeta _modules/ - Módulos Hardware + Firmware" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- La unidad principal de funcionalidad.
- Donde viven los proyectos funcionales.

REFERENCIAS:
- Explorar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_modules

CONTENIDO REQUERIDO:
1. Propósito de `_modules`
2. Estructura interna de un módulo (System/Target/Hardware)
3. Archivos clave: generate.emic, config.json, module.json
4. Categorización (Actuators, Sensors, Comm, etc.)
5. Ejemplo de contenido de un módulo simple

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
- Bibliotecas reutilizables de lógica de aplicación.
- Abstracción pura.

REFERENCIAS:
- Explorar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_api

CONTENIDO REQUERIDO:
1. Propósito de `_api`
2. Diferencia entre API y Driver
3. Estructura interna (Categoría/Nombre/Archivos)
4. Archivos típicos: .c, .h, .emic
5. Cómo las APIs usan los Drivers
6. Ejemplo: API de LEDs, API de Timers

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\07_Carpeta_API.md
```

**Dependencias:** Cap 06

---

#### **CAPÍTULO 08: Carpeta `_drivers/` - Drivers de Hardware**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/08_Carpeta_Drivers.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 08 "Carpeta _drivers/ - Drivers de Hardware" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Controladores de periféricos específicos pero abstraídos.

REFERENCIAS:
- Explorar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_drivers

CONTENIDO REQUERIDO:
1. Propósito de `_drivers`
2. Relación con HAL
3. Drivers vs Hardware directo
4. Estructura de carpeta
5. Ejemplo: Driver de I2C, Driver de Display 7 Seg
6. Tags específicos para Drivers (driverName)

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\08_Carpeta_Drivers.md
```

**Dependencias:** Cap 07

---

#### **CAPÍTULO 09: Carpeta `_hal/` - Hardware Abstraction Layer**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/09_Carpeta_HAL.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 09 "Carpeta _hal/ - Hardware Abstraction Layer" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Capa crítica de portabilidad.
- Interfaz unificada para diferentes microcontroladores.

REFERENCIAS:
- Explorar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_hal

CONTENIDO REQUERIDO:
1. ¿Qué es el HAL en EMIC?
2. Por qué es vital para la reutilización
3. Estructura de carpetas por periférico (GPIO, ADC, UART)
4. Cómo un Driver invoca al HAL
5. Cómo el HAL se mapea al hardware real (_hard)

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\09_Carpeta_HAL.md
```

**Dependencias:** Cap 08

---

#### **CAPÍTULO 10: Carpeta `_hard/` - Código Específico de MCU**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/10_Carpeta_Hard.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 10 "Carpeta _hard/ - Código Específico de MCU" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- La capa más baja.
- Acceso directo a registros del microcontrolador.

REFERENCIAS:
- Explorar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_hard

CONTENIDO REQUERIDO:
1. Propósito de `_hard`
2. Organización por Familia/Modelo de MCU (PIC18, PIC32, AVR)
3. Archivos headers de registros (xc.h, p24xxxx.h)
4. Implementación de funciones HAL
5. Interrupciones y vectores

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\10_Carpeta_Hard.md
```

**Dependencias:** Cap 09

---

#### **CAPÍTULO 11: Carpeta `_main/` - Punto de Entrada**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/11_Carpeta_Main.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 11 "Carpeta _main/ - Punto de Entrada" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- El bucle principal y la inicialización del sistema.

REFERENCIAS:
- Explorar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_main

CONTENIDO REQUERIDO:
1. Propósito de `_main`
2. main.c: Estructura estándar
3. Inicialización de sistema, drivers y aplicación
4. El Super-Loop (while(1))
5. Inyección de código de usuario en el main (Call_Init, Call_Main)
6. main.emic: Cómo se gestiona la generación del main

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\11_Carpeta_Main.md
```

**Dependencias:** Cap 10

---

#### **CAPÍTULO 12: Carpeta `_pcb/` - Configuración de Hardware**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/12_Carpeta_PCB.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 12 "Carpeta _pcb/ - Configuración de Hardware" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Abstracción de la placa física.
- Mapeo de pines lógicos a físicos.

REFERENCIAS:
- Explorar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_pcb

CONTENIDO REQUERIDO:
1. Propósito de `_pcb`
2. Archivo pcb.emic: Definición de pines y recursos
3. Mapeo de Alias de pines (Led1 -> RA0)
4. Configuración de Clock y Fusibles
5. Cambiar de PCB sin cambiar de código de aplicación

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\12_Carpeta_PCB.md
```

**Dependencias:** Cap 11

---

#### **CAPÍTULO 13: Carpeta `_templates/` - Templates de Proyectos**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/13_Carpeta_Templates.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 13 "Carpeta _templates/ - Templates de Proyectos" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Plantillas para IDEs (MPLAB X).
- Base para la compilación.

REFERENCIAS:
- Explorar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_templates

CONTENIDO REQUERIDO:
1. Propósito de `_templates`
2. Estructura de un proyecto MPLAB X template
3. Makefile y configuraciones de compilador
4. Cómo EMIC Generate usa estos templates para crear el proyecto final TARGET

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\13_Carpeta_Templates.md
```

**Dependencias:** Cap 12

---

#### **CAPÍTULO 14: Carpeta `_system/` - Sistema Core EMIC**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/14_Carpeta_System.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 14 "Carpeta _system/ - Sistema Core EMIC" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Funciones internas del sistema EMIC.
- Gestión de tipos y definiciones globales.

REFERENCIAS:
- Explorar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_system

CONTENIDO REQUERIDO:
1. Propósito de `_system`
2. typedefs estándar (uint8_t, etc.)
3. headers globales de inclusión
4. Funciones de sistema (Reset, Delay, etc.)

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\14_Carpeta_System.md
```

**Dependencias:** Cap 13

---

#### **CAPÍTULO 15: Carpeta `_util/` - Utilidades Generales**

**Archivo de Salida:** `Seccion_2_Estructura_SDK/15_Carpeta_Util.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 15 "Carpeta _util/ - Utilidades Generales" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Librerías de ayuda agnósticas al hardware.

REFERENCIAS:
- Explorar: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\_util

CONTENIDO REQUERIDO:
1. Propósito de `_util`
2. Librerías matemáticas, de string, buffers circulares, etc.
3. Cómo usarlas en tus APIs y Drivers
4. Indepencia total del hardware

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_2_Estructura_SDK\15_Carpeta_Util.md
```

**Dependencias:** Cap 14

### SECCIÓN 3: EMIC-CODIFY PARA DESARROLLADORES

---

#### **CAPÍTULO 16: Fundamentos de EMIC-Codify para Desarrollo**

**Archivo de Salida:** `Seccion_3_EMIC_Codify/16_Fundamentos_Codify_Desarrollo.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 16 "Fundamentos de EMIC-Codify para Desarrollo" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Introducción al lenguaje EMIC-Codify
- Enfoque específico en CREAR recursos (Desarrollador) vs integrar (Integrador)
- Primeros pasos para crear una API

REFERENCIAS DE ARCHIVOS:
- @Seccion_2_Estructura_SDK/15_Carpeta_Util.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md

CONTENIDO REQUERIDO:
1. ¿Qué es EMIC-Codify? (Breve repaso)
2. Sintaxis básica
3. Diferencia clave: Codify para Integrar vs Codify para Desarrollar
4. Primer archivo .emic para una API simple
5. Tags básicos de publicación: @fn, @alias, @brief
6. Ejemplo completo: API simple con su archivo .emic

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_3_EMIC_Codify\16_Fundamentos_Codify_Desarrollo.md
```

**Dependencias:** Cap 15

---

#### **CAPÍTULO 17: Comandos de Gestión de Archivos y Recursos**

**Archivo de Salida:** `Seccion_3_EMIC_Codify/17_Comandos_Gestion_Archivos.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 17 "Comandos de Gestión de Archivos y Recursos" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Comandos fundamentales para manipular archivos en el SDK
- Uso de copy, setInput, setOutput

REFERENCIAS DE ARCHIVOS:
- @Seccion_3_EMIC_Codify/16_Fundamentos_Codify_Desarrollo.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md

CONTENIDO REQUERIDO:
1. Comando copy: Uso en APIs reales
2. Comando setOutput: Estructurar archivos generados
3. Comando setInput: Procesar código fuente
4. Caso práctico: Crear archivo .emic para copiar .c y .h
5. Ejemplo completo del SDK: Analizar led.emic línea por línea

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_3_EMIC_Codify\17_Comandos_Gestion_Archivos.md
```

**Dependencias:** Cap 16

---

#### **CAPÍTULO 18: Sistema de Macros y Sustitución**

**Archivo de Salida:** `Seccion_3_EMIC_Codify/18_Sistema_Macros_Sustitucion.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 18 "Sistema de Macros y Sustitución" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Uso de macros para parametrizar recursos
- Configuración flexible de APIs y Drivers

REFERENCIAS DE ARCHIVOS:
- @Seccion_3_EMIC_Codify/17_Comandos_Gestion_Archivos.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md

CONTENIDO REQUERIDO:
1. Comando define: Creación de macros
2. Sustitución .{key}.: Sintaxis y uso
3. Macros para parámetros de configuración de APIs
4. Ejemplo: API con parámetros configurables
5. Uso de foreach para recursos múltiples
6. Caso práctico: Driver configurable con macros

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_3_EMIC_Codify\18_Sistema_Macros_Sustitucion.md
```

**Dependencias:** Cap 17

---

#### **CAPÍTULO 19: Control de Flujo y Condicionales**

**Archivo de Salida:** `Seccion_3_EMIC_Codify/19_Control_Flujo_Condicionales.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 19 "Control de Flujo y Condicionales" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Lógica condicional en la generación de código
- Adaptación a diferentes hardwares o configuraciones

REFERENCIAS DE ARCHIVOS:
- @Seccion_3_EMIC_Codify/18_Sistema_Macros_Sustitucion.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md

CONTENIDO REQUERIDO:
1. Comandos if / elif / else / endif
2. Comandos ifdef / ifndef
3. Generación condicional de código según configuración
4. Ejemplo: API con funcionalidad opcional
5. Caso práctico: Driver con soporte multi-MCU condicional

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_3_EMIC_Codify\19_Control_Flujo_Condicionales.md
```

**Dependencias:** Cap 18

---

#### **CAPÍTULO 20: Etiquetado de Recursos (Tags DOXYGEN y JSON)**

**Archivo de Salida:** `Seccion_3_EMIC_Codify/20_Etiquetado_Recursos_Tags.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 20 "Etiquetado de Recursos (Tags DOXYGEN y JSON)" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Publicación de recursos para EMIC Discovery
- Tags DOXYGEN para funciones y JSON para configuración

REFERENCIAS DE ARCHIVOS:
- @Seccion_3_EMIC_Codify/19_Control_Flujo_Condicionales.md (capítulo previo)
- @INFO/EMIC-USER/EMIC-Manual-V4.1.1.md

CONTENIDO REQUERIDO:
1. ¿Qué son los Tags en EMIC? Diferencia con Macros
2. Tags DOXYGEN para funciones: @fn, @alias, @brief, @param, @return
3. Tags para eventos (callbacks)
4. Tags para variables
5. Tag driverName para agrupar recursos
6. Formato JSON para Configurators
7. Ejemplos reales del SDK (LED API, Timer API)

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_3_EMIC_Codify\20_Etiquetado_Recursos_Tags.md
```

**Dependencias:** Cap 19

---

### SECCIÓN 4: DESARROLLO DE COMPONENTES SDK

---

#### **CAPÍTULO 21: Desarrollo de una API EMIC - Paso a Paso**

**Archivo de Salida:** `Seccion_4_Desarrollo/21_Desarrollo_API_Paso_a_Paso.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 21 "Desarrollo de una API EMIC - Paso a Paso" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Guía completa para crear una nueva API
- Ciclo: Desarrollo -> Integración -> Validación

REFERENCIAS DE ARCHIVOS:
- @Seccion_3_EMIC_Codify/20_Etiquetado_Recursos_Tags.md (capítulo previo)
- Referencia SDK: _api/Indicators/LEDs/

CONTENIDO REQUERIDO:
1. Planificación de la API (Funcionalidad, Interfaz)
2. Estructura de carpetas (_api/{Category}/{Name}/)
3. Desarrollo del Código C (Headers y Source)
4. Etiquetado con Tags DOXYGEN
5. Creación del archivo .emic de definición
6. Validación mediante Integración: Crear proyecto de prueba simple
7. Generación y Compilación para verificar

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_4_Desarrollo\21_Desarrollo_API_Paso_a_Paso.md
```

**Dependencias:** Cap 20

---

#### **CAPÍTULO 22: Desarrollo de un Driver EMIC**

**Archivo de Salida:** `Seccion_4_Desarrollo/22_Desarrollo_Driver.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 22 "Desarrollo de un Driver EMIC" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Creación de Drivers de bajo nivel
- Uso de HAL y acceso a hardware

REFERENCIAS DE ARCHIVOS:
- @Seccion_4_Desarrollo/21_Desarrollo_API_Paso_a_Paso.md (capítulo previo)
- Referencia SDK: _drivers/I2C/, _hal/I2C/

CONTENIDO REQUERIDO:
1. Diferencia Driver vs API
2. Planificación del Driver (Periférico, HAL)
3. Estructura de carpetas (_drivers/{Name}/)
4. Integración con HAL (No acceder directo a registros si hay HAL)
5. Implementación del código C y Tags
6. Validación: Crear módulo con hardware de test
7. Testing en hardware real

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_4_Desarrollo\22_Desarrollo_Driver.md
```

**Dependencias:** Cap 21

---

#### **CAPÍTULO 23: Desarrollo de un Módulo EMIC Completo**

**Archivo de Salida:** `Seccion_4_Desarrollo/23_Desarrollo_Modulo_Completo.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 23 "Desarrollo de un Módulo EMIC Completo" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Creación de un Módulo funcional (Hardware + Firmware)
- Unidad de distribución principal

REFERENCIAS DE ARCHIVOS:
- @Seccion_4_Desarrollo/22_Desarrollo_Driver.md (capítulo previo)
- Referencia SDK: _modules/Digital_In_Out/

CONTENIDO REQUERIDO:
1. Concepto de Módulo: Hardware + Firmware + Configuración
2. Estructura de carpetas (_modules/{Category}/{Name}/)
3. Archivos del Sistema: generate.emic, deploy.emic, config.json
4. Archivo generate.emic: Configurar salida, cargar APIs/Drivers, pines
5. Metadata: module.json y m_description.json
6. Validación mediante Integración: Proyecto de prueba en EMIC-Editor
7. Ciclo de iteración y mejora

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_4_Desarrollo\23_Desarrollo_Modulo_Completo.md
```

**Dependencias:** Cap 22

---

#### **CAPÍTULO 24: Proceso de Generación (generate.emic) Profundo**

**Archivo de Salida:** `Seccion_4_Desarrollo/24_Proceso_Generacion_Generate.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 24 "Proceso de Generación (generate.emic) Profundo" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Dominio avanzado del script de generación
- El corazón de EMIC Generate

REFERENCIAS DE ARCHIVOS:
- @Seccion_4_Desarrollo/23_Desarrollo_Modulo_Completo.md (capítulo previo)
- Referencia SDK: _modules/*/System/generate.emic

CONTENIDO REQUERIDO:
1. Propósito y anatomía detallada de generate.emic
2. Secciones clave: Config salida, Hardware, Eventos, APIs, Main
3. Paso de parámetros a APIs (Macros dinámicas)
4. Gestión de stack de salidas (setOutput/restoreOutput)
5. Ejemplo completo comentado línea por línea
6. Debugging de generate.emic (errores comunes)

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_4_Desarrollo\24_Proceso_Generacion_Generate.md
```

**Dependencias:** Cap 23

---

#### **CAPÍTULO 25: Configuración Dinámica y Parametrización**

**Archivo de Salida:** `Seccion_4_Desarrollo/25_Configuracion_Dinamica_Modulos.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 25 "Configuración Dinámica y Parametrización" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Hacer módulos y APIs configurables por el usuario
- Uso de JSON Configurators

REFERENCIAS DE ARCHIVOS:
- @Seccion_4_Desarrollo/24_Proceso_Generacion_Generate.md (capítulo previo)
- Referencia SDK: module.json, config.json

CONTENIDO REQUERIDO:
1. Sistema de Configurator en EMIC
2. config.json en módulos: Estructura y tipos
3. Configurators en APIs: Menús interactivos JSON
4. Uso de parámetros en generate.emic (lectura y aplicación)
5. Ejemplo: API de comunicación con Baudrate configurable
6. Validación de múltiples configuraciones

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_4_Desarrollo\25_Configuracion_Dinamica_Modulos.md
```

**Dependencias:** Cap 24

---

#### **CAPÍTULO 26: Creación de Categorías y Organización del SDK**

**Archivo de Salida:** `Seccion_4_Desarrollo/26_Categorias_Organizacion_SDK.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 26 "Creación de Categorías y Organización del SDK" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Estructura y organización limpia del SDK
- Best practices de categorización

REFERENCIAS DE ARCHIVOS:
- @Seccion_4_Desarrollo/25_Configuracion_Dinamica_Modulos.md (capítulo previo)
- Referencia SDK: Estructura de directorios

CONTENIDO REQUERIDO:
1. Importancia de la categorización
2. Categorías existentes para APIs y Módulos
3. Criterios para crear nuevas categorías
4. Convenciones de nombres y estructura de carpetas
5. Metadata de categorías
6. Validación de la organización (Discovery)

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_4_Desarrollo\26_Categorias_Organizacion_SDK.md
```

**Dependencias:** Cap 25

---

### SECCIÓN 5: CASOS PRÁCTICOS DE DESARROLLO-INTEGRACIÓN

---

#### **CAPÍTULO 27: Caso Práctico - API de LEDs Desde Cero**

**Archivo de Salida:** `Seccion_5_Casos_Practicos/27_Caso_API_LEDs_Completo.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 27 "Caso Práctico: API de LEDs Desde Cero" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Tutorial completo paso a paso
- Ciclo: Desarrollo -> Integración -> Validación

REFERENCIAS DE ARCHIVOS:
- @Seccion_4_Desarrollo/21_Desarrollo_API_Paso_a_Paso.md
- Referencia SDK: _api/Indicators/LEDs/

CONTENIDO REQUERIDO:
1. Planificación: API de LEDs (state, blink, toggle)
2. Desarrollo: Código C, led.h, led.c
3. Etiquetas: Tags DOXYGEN completos
4. Definición: Archivo led.emic
5. Integración: Módulo de prueba "Test_LED" con hardware virtual/real
6. Validación: Generar, compilar y probar funcionamiento
7. Resultado final: API lista para el SDK

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_5_Casos_Practicos\27_Caso_API_LEDs_Completo.md
```

**Dependencias:** Cap 21, 26

---

#### **CAPÍTULO 28: Caso Práctico - Driver I2C + Sensor**

**Archivo de Salida:** `Seccion_5_Casos_Practicos/28_Caso_Driver_I2C_Sensor.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 28 "Caso Práctico: Driver I2C + Sensor" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Desarrollo de Driver de hardware
- Uso de HAL I2C real

REFERENCIAS DE ARCHIVOS:
- @Seccion_4_Desarrollo/22_Desarrollo_Driver.md
- Referencia SDK: _drivers/I2C/, _hal/I2C/

CONTENIDO REQUERIDO:
1. Planificación: Driver para sensor BME280 (I2C)
2. Integración HAL: Usar funciones I2C del sistema
3. Desarrollo: Código C del driver, manejo de registros del sensor
4. Integración: Módulo "Monitor_Ambiental" con display
5. Configuración: I2C en generate.emic
6. Validación: Lectura de datos reales del sensor
7. Debugging y ajustes

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_5_Casos_Practicos\28_Caso_Driver_I2C_Sensor.md
```

**Dependencias:** Cap 22, 27

---

#### **CAPÍTULO 29: Caso Práctico - Módulo de Control con USB**

**Archivo de Salida:** `Seccion_5_Casos_Practicos/29_Caso_Modulo_Control_USB.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 29 "Caso Práctico: Módulo de Control con USB" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Desarrollo de Módulo complejo multirecurso
- Comunicación USB CDC

REFERENCIAS DE ARCHIVOS:
- @Seccion_4_Desarrollo/23_Desarrollo_Modulo_Completo.md
- Referencia SDK: _modules/Wired_Control/

CONTENIDO REQUERIDO:
1. Planificación: Módulo USB_Relay_Controller
2. Recursos: USB CDC API, Relay API, LED API
3. Estructura y generate.emic: Configuración de USB y periféricos
4. Metadata: Configuración de número de relés
5. Integración: Proyecto de prueba con comandos seriales
6. Validación: Controlar relés desde PC vía terminal
7. Resultado final: Módulo listo para producción

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_5_Casos_Practicos\29_Caso_Modulo_Control_USB.md
```

**Dependencias:** Cap 23, 28

---

#### **CAPÍTULO 30: Caso Práctico - Sistema Multi-Módulo (Gateway Industrial)**

**Archivo de Salida:** `Seccion_5_Casos_Practicos/30_Caso_Gateway_Industrial_Multimodulo.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 30 "Caso Práctico: Sistema Multi-Módulo (Gateway Industrial)" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Desarrollo avanzado de múltiples componentes interconectados
- Modbus, RS485, Display

REFERENCIAS DE ARCHIVOS:
- @Seccion_5_Casos_Practicos/29_Caso_Modulo_Control_USB.md
- Referencia SDK: APIs de Protocolos

CONTENIDO REQUERIDO:
1. Reto: Crear componentes para Gateway Modbus
2. Componente 1: API Modbus RTU
3. Componente 2: Driver RS485 Transceiver
4. Componente 3: Módulo Gateway completo
5. Integración: Proyecto en EMIC-Editor uniendo todo
6. Validación compleja de comunicaciones
7. Conclusión de los casos prácticos

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_5_Casos_Practicos\30_Caso_Gateway_Industrial_Multimodulo.md
```

**Dependencias:** Cap 29

---

### SECCIÓN 6: TESTING, VALIDACIÓN Y TROUBLESHOOTING

---

#### **CAPÍTULO 31: Buenas Prácticas de Desarrollo de Componentes SDK**

**Archivo de Salida:** `Seccion_6_Avanzado/31_Buenas_Practicas_Desarrollo.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 31 "Buenas Prácticas de Desarrollo de Componentes SDK" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Estándares de calidad y estilo
- Mantenibilidad del código

CONTENIDO REQUERIDO:
1. Convenciones de nombres (APIs, Drivers, Funciones)
2. Estructura de código recomendada
3. Documentación obligatoria (Readme, Tags)
4. Gestión de dependencias eficiente
5. Manejo de errores estandarizado
6. Optimización de recursos
7. Versionado semántico de componentes

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_6_Avanzado\31_Buenas_Practicas_Desarrollo.md
```

**Dependencias:** Cap 30

---

#### **CAPÍTULO 32: Testing y Validación de Componentes**

**Archivo de Salida:** `Seccion_6_Avanzado/32_Testing_Validacion_Componentes.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 32 "Testing y Validación de Componentes" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Metodologías de prueba para asegurar calidad
- Validación antes de publicar

CONTENIDO REQUERIDO:
1. Filosofía de testing en EMIC
2. Niveles: Unitario, Integración, Sistema, Hardware
3. Testing de APIs: Casos de prueba
4. Testing de Drivers: Timing y hardware real
5. Testing de Módulos: Configuración e interacción
6. Validación con EMIC Discovery (previo a release)
7. Documentación de pruebas

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_6_Avanzado\32_Testing_Validacion_Componentes.md
```

**Dependencias:** Cap 31

---

#### **CAPÍTULO 33: Troubleshooting y Debugging de Desarrollos**

**Archivo de Salida:** `Seccion_6_Avanzado/33_Troubleshooting_Debugging.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 33 "Troubleshooting y Debugging de Desarrollos" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Solución de problemas comunes durante el desarrollo

CONTENIDO REQUERIDO:
1. Metodología de debugging
2. Errores comunes en APIs (Tags, dependencias)
3. Errores en Drivers (HAL, registros)
4. Errores en generate.emic (Rutas, macros)
5. Errores de EMIC Discovery
6. Debugging en hardware (Herramientas, UART)
7. FAQ técnico

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_6_Avanzado\33_Troubleshooting_Debugging.md
```

**Dependencias:** Cap 32

---

#### **CAPÍTULO 34: Optimización y Performance de Componentes**

**Archivo de Salida:** `Seccion_6_Avanzado/34_Optimizacion_Performance.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 34 "Optimización y Performance de Componentes" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Técnicas para código eficiente en sistemas embebidos

CONTENIDO REQUERIDO:
1. Principios de optimización (Memoria, CPU, Energía)
2. Optimización de Memoria (Stack, Flash, Variables)
3. Optimización de CPU (Interrupciones, Algoritmos)
4. Optimización de Energía (Sleep modes)
5. Profiling y medición
6. Trade-offs: Velocidad vs Tamaño
7. Optimización específica en APIs y Drivers

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_6_Avanzado\34_Optimizacion_Performance.md
```

**Dependencias:** Cap 33

---

### SECCIÓN 7: REFERENCIAS PARA DESARROLLADORES

---

#### **CAPÍTULO 35: Referencia Rápida de Comandos EMIC-Codify**

**Archivo de Salida:** `Seccion_7_Referencias/35_Referencia_Comandos_Codify.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 35 "Referencia Rápida de Comandos EMIC-Codify" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Cheatsheet de comandos para uso diario

CONTENIDO REQUERIDO:
1. Tabla resumen: Gestión de archivos (copy, setInput...)
2. Tabla resumen: Macros (define, substitute...)
3. Tabla resumen: Control de Flujo (if, foreach...)
4. Sintaxis de volúmenes lógicos
5. Parámetros comunes
6. Ejemplos mínimos copy-paste

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_7_Referencias\35_Referencia_Comandos_Codify.md
```

**Dependencias:** Cap 16-19

---

#### **CAPÍTULO 36: Referencia Rápida de Tags (DOXYGEN y JSON)**

**Archivo de Salida:** `Seccion_7_Referencias/36_Referencia_Tags.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 36 "Referencia Rápida de Tags (DOXYGEN y JSON)" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Cheatsheet de etiquetas de publicación

CONTENIDO REQUERIDO:
1. Tags DOXYGEN funciones (@fn, @param...)
2. Tags Eventos y Variables
3. Tag driverName
4. Formato JSON Configurator
5. Ejemplos completos de bloques comentados

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_7_Referencias\36_Referencia_Tags.md
```

**Dependencias:** Cap 20

---

#### **CAPÍTULO 37: Plantillas de Código para Desarrolladores**

**Archivo de Salida:** `Seccion_7_Referencias/37_Plantillas_Codigo.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 37 "Plantillas de Código para Desarrolladores" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Boilerplate code para acelerar el desarrollo

CONTENIDO REQUERIDO:
1. Template de API (.h, .c, .emic)
2. Template de Driver
3. Template de generate.emic completo
4. Template de module.json y config.json
5. Template de JSON Configurator
6. Instrucciones de uso

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_7_Referencias\37_Plantillas_Codigo.md
```

**Dependencias:** General

---

#### **CAPÍTULO 38: Recursos y Comunidad de Desarrolladores**

**Archivo de Salida:** `Seccion_7_Referencias/38_Recursos_Comunidad.md`

**Prompt para Claude Code:**

```
Crea el Capítulo 38 "Recursos y Comunidad de Desarrolladores" del Manual de Desarrollo EMIC SDK.

CONTEXTO:
- Dónde encontrar más ayuda y recursos

CONTENIDO REQUERIDO:
1. Documentación Oficial y API References
2. Repositorios de ejemplos
3. Canales de Comunidad (Foros, Discord)
4. Soporte Técnico y reporte de bugs
5. Cómo contribuir al SDK
6. Herramientas útiles (MPLAB, CLI)

SALIDA:
Guarda en: C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_Desarrollo_EMIC\Seccion_7_Referencias\38_Recursos_Comunidad.md
```

**Dependencias:** Final

