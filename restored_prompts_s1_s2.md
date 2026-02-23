
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
