# Capítulo 24: Proceso de Deploy - Instanciación de un Módulo

## 24.1 Introducción

Cuando un **integrador** selecciona un módulo desde el catálogo del Editor EMIC para agregarlo a su proyecto, se dispara un proceso llamado **Deploy**. Este proceso crea el **contexto de trabajo** necesario para que el integrador pueda programar su aplicación.

Este capítulo explica en detalle qué sucede "por debajo" cuando se instancia un nuevo módulo, qué archivos y carpetas se crean, y qué macros quedan disponibles para el proceso de generación posterior.

## 24.2 Visión General del Proceso

```
┌─────────────────────────────────────────────────────────────────┐
│              CATÁLOGO DE MÓDULOS (SDK)                          │
│  _modules/Categoria/NombreModulo/                               │
│  └── System/                                                    │
│      ├── deploy.emic                                            │
│      ├── generate.emic                                          │
│      └── module.webp                                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Usuario selecciona módulo
                              │ desde el Editor EMIC
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                  PROCESO DE INSTANCIACIÓN                       │
│                                                                 │
│  1. Crear estructura de carpetas del proyecto                   │
│  2. Copiar archivos base del módulo                             │
│  3. Generar ID único de conexión                                │
│  4. Configurar volúmenes lógicos                                │
│  5. Inicializar macros del contexto                             │
│  6. Ejecutar deploy.emic                                        │
│  7. Generar archivos iniciales                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                  PROCESO EMIC-DISCOVERY                         │
│                                                                 │
│  8. Ejecutar generate.emic en modo "Discovery"                  │
│  9. Extraer funciones y eventos de las APIs (tags DOXYGEN)      │
│  10. Generar archivo EMIC-TABS/Resources (formato XML)          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              INSTANCIA DEL MÓDULO (Proyecto Usuario)            │
│  My Projects/MiProyecto/USB_1/                                  │
│  ├── System/                                                    │
│  │   ├── module.json                                            │
│  │   ├── Id.txt                                                 │
│  │   ├── deploy.emic                                            │
│  │   ├── generate.emic                                          │
│  │   ├── userFncFile.c        (código del usuario)              │
│  │   ├── inc/userFncFile.h                                      │
│  │   └── EMIC-TABS/           (pestañas del Editor)             │
│  └── target/                  (salida de Generate)              │
└─────────────────────────────────────────────────────────────────┘
```

## 24.3 Paso 1: Creación de la Estructura de Carpetas

Cuando el usuario agrega un módulo a su proyecto, el sistema crea la siguiente estructura:

```
My Projects/
└── NombreProyecto/
    └── NombreInstancia/        # Ej: "USB_1", "USB_2", etc.
        ├── System/             # Carpeta de configuración
        └── target/             # Carpeta de salida (vacía inicialmente)
```

### Nomenclatura de Instancias

Si el usuario agrega múltiples instancias del mismo módulo, el sistema genera nombres únicos:

| Módulo Base | Primera Instancia | Segunda Instancia | Tercera Instancia |
|-------------|-------------------|-------------------|-------------------|
| USB | USB_1 | USB_2 | USB_3 |
| HRD_X2_RELAY | HRD_X2_RELAY_1 | HRD_X2_RELAY_2 | HRD_X2_RELAY_3 |

## 24.4 Paso 2: Copia de Archivos Base

El sistema copia todo el contenido de la carpeta `System/` del módulo original a la instancia:

```
ORIGEN (SDK):                           DESTINO (Proyecto):
_modules/Categoria/Modulo/System/   →   My Projects/Proyecto/Instancia/System/
├── deploy.emic                     →   ├── deploy.emic
├── generate.emic                   →   ├── generate.emic
├── module.webp                     →   ├── module.webp
└── emic-tabs/                      →   └── emic-tabs/
    ├── Code.html                   →       ├── Code.html
    ├── Data.html                   →       ├── Data.html
    ├── Resources.html              →       ├── Resources.html
    └── User.html                   →       └── User.html
```

## 24.5 Paso 3: Generación del ID de Conexión

Cada instancia de módulo recibe un **ID único** para identificarse en la red EMIC Bus. Este ID:

- Es un **número par** entre 2 y 240
- Es **único** dentro del proyecto (no se repite entre módulos)
- Se almacena en `System/Id.txt`
- Se usa para comunicación I2C entre módulos

### Archivo Id.txt

```
78
```

### Uso del ID

El ID está disponible como macro `.{module.Id}.` y se usa típicamente para definir la dirección I2C:

```c
// En deploy.emic o generate.emic
EMIC:setOutput(TARGET:inc/myId.h)
#define _I2C_ID .{module.Id}.
EMIC:restoreOutput
```

Resultado generado:
```c
// TARGET:inc/myId.h
#define _I2C_ID 78
```

## 24.6 Paso 4: Configuración de Volúmenes Lógicos

Durante la instanciación, se configuran los **volúmenes lógicos** que estarán disponibles para los scripts `.emic`:

| Volumen | Apunta a | Ejemplo Real |
|---------|----------|--------------|
| `DEV:` | SDK de desarrollo | `USER:/DEV/EMIC_IA_M` |
| `SYS:` | Carpeta System de la instancia | `USER:/My Projects/Test/USB_1/System` |
| `TARGET:` | Carpeta target de la instancia | `USER:/My Projects/Test/USB_1/target` |
| `PRJ:` | Carpeta del proyecto | `USER:/My Projects/Test` |
| `USER:` | Carpeta raíz del usuario | `C:/Users/.../mariano.hunkeler@.../` |

### Importancia de los Volúmenes

Estos volúmenes permiten que los scripts `.emic` sean **portables** y funcionen independientemente de la ubicación física del proyecto:

```c
// En deploy.emic - funciona en cualquier proyecto
EMIC:copy(DEV:_templates/plugins/sidebar-tabs > SYS:EMIC-TABS)

// Equivalente a (ruta física):
// EMIC:copy(USER:/DEV/EMIC_IA_M/_templates/plugins/sidebar-tabs >
//           USER:/My Projects/Test/USB_1/System/EMIC-TABS)
```

## 24.7 Paso 5: Inicialización de Macros del Contexto

Antes de ejecutar `deploy.emic`, el sistema inicializa un conjunto de **macros globales** que describen el contexto de la instancia:

### Grupo `global`

| Macro | Descripción | Ejemplo |
|-------|-------------|---------|
| `.{global.path}.` | Ruta completa de la instancia | `USER:/My Projects/Test/USB_1` |
| `.{global.userModule}.` | Nombre de la instancia | `USB_1` |
| `.{global.module}.` | Nombre del módulo base | `USB` |
| `.{global.userName}.` | Email del usuario | `mariano.hunkeler@rfindustrial.com` |

### Grupo `project`

| Macro | Descripción | Ejemplo |
|-------|-------------|---------|
| `.{project.name}.` | Nombre del proyecto | `Test` |

### Grupo `module`

| Macro | Descripción | Ejemplo |
|-------|-------------|---------|
| `.{module.name}.` | Nombre de la instancia | `USB_1` |
| `.{module.Id}.` | ID de conexión único | `78` |

### Grupo `user`

| Macro | Descripción | Ejemplo |
|-------|-------------|---------|
| `.{user.name}.` | Email del usuario | `mariano.hunkeler@rfindustrial.com` |

### Grupo `config` (si existe)

Si existe el archivo `SYS:config.json`, su contenido se carga como macros:

```json
// config.json
{
    "baudRate": "9600",
    "protocol": "ASCII"
}
```

Disponibles como:
- `.{config.baudRate}.` → `9600`
- `.{config.protocol}.` → `ASCII`

## 24.8 Paso 6: Ejecución de deploy.emic

Con el contexto preparado, el sistema ejecuta el archivo `deploy.emic` del módulo. Este script es responsable de crear los archivos iniciales necesarios para el Editor.

### Estructura Típica de deploy.emic

```c
EMIC:setOutput(SYS:deploy.txt)

    //------------------- Crear archivos de usuario vacíos ----------------
    EMIC:setOutput(SYS:inc/userFncFile.h)
    // file: userFncFile.h
    EMIC:restoreOutput

    EMIC:setOutput(SYS:userFncFile.c)
    // file: userFncFile.c
    EMIC:restoreOutput

    //------------------- Copiar templates de pestañas ----------------
    EMIC:copy(DEV:_templates/plugins/sidebar-tabs > SYS:EMIC-TABS)

    //------------------- Generar header con ID del módulo ----------------
    EMIC:setOutput(TARGET:inc/myId.h)
    #define _I2C_ID .{module.Id}.
    EMIC:restoreOutput

EMIC:restoreOutput
```

### Acciones del deploy.emic

1. **Crear archivos de usuario vacíos**: `userFncFile.c` y `userFncFile.h` donde el Editor guardará el código del usuario
2. **Copiar templates de pestañas**: Las pestañas del Editor (Code, Data, Resources, User, Functions)
3. **Generar archivos con macros expandidas**: Por ejemplo, el header con el ID del módulo

## 24.9 Paso 7: Archivos Generados

Después del proceso de deploy, la estructura de la instancia queda así:

```
My Projects/Test/USB_1/
├── System/
│   ├── module.json              # Metadatos de la instancia
│   ├── Id.txt                   # ID único de conexión
│   ├── deploy.emic              # Script de deploy (copiado)
│   ├── generate.emic            # Script de generación (copiado)
│   ├── module.webp              # Imagen del módulo
│   ├── deploy.txt               # Log del proceso deploy
│   │
│   ├── userFncFile.c            # Código del usuario (vacío)
│   ├── inc/
│   │   └── userFncFile.h        # Header del usuario (vacío)
│   │
│   └── EMIC-TABS/               # Pestañas del Editor
│       ├── Code                 # Bloques de control de flujo
│       ├── Data                 # Variables del usuario
│       ├── Functions            # Funciones disponibles
│       ├── Resources            # Recursos del módulo (vacío)
│       └── User                 # Interfaz personalizada
│
└── target/
    └── inc/
        └── myId.h               # Header con ID del módulo
```

### Archivo module.json

Contiene los metadatos de la instancia:

```json
{
    "module": "USB",
    "pcbName": null,
    "autorName": null,
    "idConnection": "78",
    "originPath": "USER:/DEV/EMIC_IA_M/_modules/Wired_Communication/USB",
    "emicdevpath": "USER:/DEV/EMIC_IA_M",
    "createdAt": "2025-10-31T22:04:37.047-03:00",
    "updatedAt": "2025-10-31T22:04:37.047-03:00",
    "emicProjectPath": "USER:/My Projects/Test",
    "ModuleInfo": {
        "Id": "USER:/DEV/EMIC_IA_M/_modules/Wired_Communication/USB",
        "Name": "USB",
        "Type": "gcc-2.0",
        "Description": "Communication module with USB port...",
        "Category": "Wired_Communication",
        "Path": "USER:/DEV/EMIC_IA_M/_modules/Wired_Communication/USB",
        "DevPath": "USER:/DEV/EMIC_IA_M"
    }
}
```

## 24.10 Pestañas del Editor (EMIC-TABS)

Las pestañas definen la interfaz del Editor EMIC para esta instancia:

| Pestaña | Archivo | Contenido |
|---------|---------|-----------|
| **Code** | `EMIC-TABS/Code` | Bloques de control de flujo (if, while, switch) |
| **Data** | `EMIC-TABS/Data` | Panel de variables del usuario |
| **Functions** | `EMIC-TABS/Functions` | Funciones matemáticas y de utilidad |
| **Resources** | `EMIC-TABS/Resources` | Funciones y eventos del módulo (se llena después) |
| **User** | `EMIC-TABS/User` | Interfaz personalizada del módulo |

## 24.11 Proceso EMIC-Discovery

El proceso **EMIC-Discovery** es el paso final de la instanciación. Se ejecuta automáticamente después del deploy (o después de que el usuario complete la configuración si hay un Configurator).

### ¿Qué hace EMIC-Discovery?

1. **Ejecuta `generate.emic` en modo "Discovery"**: No genera código, solo analiza las APIs
2. **Extrae los recursos publicados**: Lee los tags DOXYGEN de cada API incluida
3. **Genera el archivo `Resources`**: Crea un XML con todas las funciones y eventos disponibles

### Flujo del Discovery

```
┌─────────────────────────────────────────────────────────────────┐
│                    EMIC-DISCOVERY                                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  1. Cargar generate.emic en modo "Discovery"                    │
│     - No genera archivos de código                              │
│     - Solo analiza las APIs incluidas                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  2. Procesar cada API del módulo                                │
│     - EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,...)     │
│     - EMIC:setInput(DEV:_api/Timers/timer_api.emic,...)        │
│     - Leer tags DOXYGEN (@fn, @alias, @brief, @param)          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  3. Extraer recursos publicados                                 │
│     - Funciones con tag(driverName = X)                        │
│     - Eventos (extern void)                                     │
│     - Variables (@var)                                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  4. Generar XML de Resources                                    │
│     - Agrupar por driverName                                   │
│     - Incluir metadatos (alias, brief, parámetros)             │
│     - Guardar en SYS:/EMIC-TABS/Resources                      │
└─────────────────────────────────────────────────────────────────┘
```

### Estructura del Archivo Resources (XML)

El archivo `EMIC-TABS/Resources` generado tiene el siguiente formato:

```xml
<emic-drivers>
    <emic-driver-container name="LEDs" icon="cable">
        <!-- Funciones del driver LEDs -->
        <emic-program-function
            driver="LEDs"
            name="LEDs_led1_state"
            type="void"
            brief="Change the state of the led, 1-on, 0-off, 2-toggle."
            alias="led1.state"
            draggable="true"
            class="subroutine">
            <emic-function-parameter
                name="state"
                type="uint8_t"
                brief="1-on 0-off 2-toggle">
            </emic-function-parameter>
        </emic-program-function>

        <emic-program-function
            driver="LEDs"
            name="LEDs_led1_blink"
            type="void"
            brief="blink the led1"
            alias="led1.blink"
            draggable="true"
            class="subroutine">
            <emic-function-parameter name="timeOn" type="uint16_t" brief="time on"></emic-function-parameter>
            <emic-function-parameter name="period" type="uint16_t" brief="period"></emic-function-parameter>
            <emic-function-parameter name="times" type="uint16_t" brief="cycles"></emic-function-parameter>
        </emic-program-function>
    </emic-driver-container>

    <emic-driver-container name="TIMER" icon="cable">
        <!-- Funciones del driver TIMER -->
        <emic-program-function
            driver="TIMER"
            name="setTime1"
            type="void"
            brief="Time in milliseconds for the event to be generated."
            alias="setTime1"
            draggable="true"
            class="subroutine">
            <emic-function-parameter name="time" type="uint16_t" brief="Time in ms"></emic-function-parameter>
            <emic-function-parameter name="mode" type="char" brief="T:timer, A:auto-reload"></emic-function-parameter>
        </emic-program-function>

        <!-- Eventos del driver TIMER -->
        <emic-program-event
            driver="TIMER"
            name="etOut1"
            type="void"
            brief="When the time configured in timer1 expires."
            alias="timeOut1"
            draggable="true"
            droppable="">
        </emic-program-event>
    </emic-driver-container>

    <emic-driver-container name="SYSTEM" icon="cable">
        <!-- Eventos del sistema -->
        <emic-program-event
            driver="SYSTEM"
            name="onReset"
            type="void"
            brief="When the module and all its functions are ready."
            alias="onReset"
            draggable="true"
            droppable="">
        </emic-program-event>

        <emic-program-event
            driver="SYSTEM"
            name="SystemConfig"
            type="void"
            brief="Before initializing the drivers."
            alias="SystemConfig"
            draggable="true"
            droppable="">
        </emic-program-event>
    </emic-driver-container>
</emic-drivers>
```

### Elementos del XML

| Elemento | Descripción |
|----------|-------------|
| `<emic-drivers>` | Contenedor raíz de todos los recursos |
| `<emic-driver-container>` | Agrupa recursos por driver (LEDs, TIMER, RELAY, etc.) |
| `<emic-program-function>` | Define una función disponible para el usuario |
| `<emic-program-event>` | Define un evento que el usuario puede implementar |
| `<emic-function-parameter>` | Parámetro de una función |
| `<emic-event-parameter>` | Parámetro de un evento |

### Atributos de Funciones

| Atributo | Origen | Descripción |
|----------|--------|-------------|
| `driver` | `tag(driverName = X)` | Nombre del grupo/driver |
| `name` | `@fn` | Nombre real de la función en C |
| `type` | `@fn` | Tipo de retorno |
| `brief` | `@brief` | Descripción corta |
| `alias` | `@alias` | Nombre amigable mostrado en el Editor |
| `draggable` | Automático | Permite arrastrar al canvas |
| `class` | `@fn` | "subroutine" si retorna void |

### Atributos de Parámetros

| Atributo | Origen | Descripción |
|----------|--------|-------------|
| `name` | `@param` | Nombre del parámetro |
| `type` | `@param` | Tipo de dato |
| `brief` | `@param` | Descripción del parámetro |

### Ejemplo Real: De API a Resources

**En el archivo de la API (`led.emic`):**

```c
EMIC:tag(driverName = LEDs)
/**
* @fn void LEDs_.{name}._state(uint8_t state);
* @alias .{name}..state
* @brief Change the state of the led, 1-on, 0-off, 2-toggle.
* @param state uint8_t 1-on 0-off 2-toggle
* @return Nothing
*/
```

**Resultado en Resources (con `name=led1`):**

```xml
<emic-program-function
    driver="LEDs"
    name="LEDs_led1_state"
    type="void"
    brief="Change the state of the led, 1-on, 0-off, 2-toggle."
    alias="led1.state"
    draggable="true"
    class="subroutine">
    <emic-function-parameter
        name="state"
        type="uint8_t"
        brief="1-on 0-off 2-toggle">
    </emic-function-parameter>
</emic-program-function>
```

### Importancia para el Editor EMIC

El archivo `Resources` es **fundamental** para el Editor EMIC:

1. **Panel de Recursos**: El Editor lee este XML para mostrar las funciones y eventos disponibles
2. **Drag & Drop**: Los elementos con `draggable="true"` se pueden arrastrar al canvas
3. **Autocompletado**: El Editor usa los tipos y parámetros para validar el código
4. **Documentación**: Los atributos `brief` se muestran como tooltips

### Discovery y Configurator

Si el módulo tiene un **Configurator**, el Discovery se ejecuta **después** de que el usuario complete la configuración:

```
Deploy → Configurator? → Sí → Usuario configura → config.json → Discovery
                       → No → Discovery directo
```

Esto es importante porque las opciones de configuración pueden afectar qué APIs se incluyen y, por lo tanto, qué recursos aparecen en el Editor.

## 24.12 Flujo Completo: De la Selección al Editor

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. USUARIO SELECCIONA MÓDULO                                    │
│    - Navega el catálogo en el Editor EMIC                       │
│    - Hace clic en "Agregar" sobre el módulo USB                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. SISTEMA VERIFICA EXISTENCIA                                  │
│    - ¿Existe ya una instancia con ese nombre?                   │
│    - Si existe: carga la existente                              │
│    - Si no existe: continúa con la creación                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. CREAR INSTANCIA (si es nueva)                                │
│    - Crear carpetas: System/, target/                           │
│    - Copiar archivos desde módulo original                      │
│    - Generar ID único                                           │
│    - Guardar module.json                                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. EJECUTAR DEPLOY                                              │
│    - Inicializar macros (global, project, module, user)         │
│    - Procesar deploy.emic                                       │
│    - Crear archivos de usuario vacíos                           │
│    - Copiar templates de pestañas                               │
│    - Generar archivos con macros expandidas                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 5. VERIFICAR CONFIGURACIÓN                                      │
│    - ¿El módulo tiene Configurator?                             │
│    - Si tiene: mostrar pantalla de configuración                │
│    - Si no tiene: continuar al Editor                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 6. DISCOVERY (si no hay Configurator)                           │
│    - Ejecutar generate.emic en modo Discovery                   │
│    - Extraer funciones y eventos de las APIs                    │
│    - Generar contenido de EMIC-TABS/Resources                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 7. EDITOR LISTO                                                 │
│    - El usuario puede programar su aplicación                   │
│    - Arrastrar bloques desde las pestañas                       │
│    - El código se guarda en userFncFile.c                       │
└─────────────────────────────────────────────────────────────────┘
```

## 24.13 Configuradores (Configurator)

Algunos módulos requieren configuración adicional antes de poder usarse. Esto se implementa mediante **Configurators**.

### ¿Qué es un Configurator?

Un Configurator es un formulario interactivo que aparece cuando el usuario agrega el módulo, permitiéndole seleccionar opciones de configuración (puerto serial, velocidad, protocolo, etc.).

### Flujo con Configurator

```
Usuario agrega módulo
        │
        ▼
    ┌──────────┐
    │  Deploy  │
    └──────────┘
        │
        ▼
    ┌──────────────────────────────┐
    │ ¿Tiene Configurator?         │
    └──────────────────────────────┘
        │                │
       Sí               No
        │                │
        ▼                ▼
┌───────────────┐  ┌───────────────┐
│ Mostrar       │  │ Ejecutar      │
│ formulario    │  │ Discovery     │
│ de config     │  │               │
└───────────────┘  └───────────────┘
        │                │
        ▼                │
┌───────────────┐        │
│ Usuario       │        │
│ completa form │        │
└───────────────┘        │
        │                │
        ▼                │
┌───────────────┐        │
│ Guardar       │        │
│ config.json   │        │
└───────────────┘        │
        │                │
        ▼                │
┌───────────────┐        │
│ Re-ejecutar   │◄───────┘
│ Discovery     │
└───────────────┘
        │
        ▼
    Editor listo
```

### Archivo config.json

Las opciones seleccionadas por el usuario se guardan en `config.json`:

```json
{
    "port": "1",
    "baudRate": "9600",
    "protocol": "MODBUS"
}
```

Estas opciones quedan disponibles como macros `.{config.xxx}.` para `generate.emic`.

## 24.14 Implicaciones para el Desarrollador

Como desarrollador de recursos EMIC, al crear un módulo debes considerar:

### En deploy.emic

1. **Crear archivos de usuario vacíos**: El Editor necesita estos archivos para guardar el código
2. **Copiar templates de pestañas**: Para que el Editor tenga la interfaz correcta
3. **Usar macros del contexto**: Especialmente `.{module.Id}.` para identificación

### Macros Disponibles

Durante deploy, tienes acceso a:

```c
// Identificación
.{module.name}.      // Nombre de la instancia (USB_1)
.{module.Id}.        // ID único (78)
.{global.module}.    // Nombre del módulo base (USB)

// Rutas
.{global.path}.      // Ruta de la instancia

// Usuario
.{user.name}.        // Email del usuario
.{project.name}.     // Nombre del proyecto
```

### Ejemplo de deploy.emic Completo

```c
EMIC:setOutput(SYS:deploy.txt)

    // Crear archivos de usuario vacíos
    EMIC:setOutput(SYS:inc/userFncFile.h)
    // file: userFncFile.h
    // Módulo: .{global.module}.
    // Instancia: .{module.name}.
    EMIC:restoreOutput

    EMIC:setOutput(SYS:userFncFile.c)
    // file: userFncFile.c
    // Generado por deploy de .{global.module}.
    #include <stdint.h>
    #include "inc/userFncFile.h"
    EMIC:restoreOutput

    // Copiar templates de pestañas del Editor
    EMIC:copy(DEV:_templates/plugins/sidebar-tabs > SYS:EMIC-TABS)

    // Generar header con ID del módulo
    EMIC:setOutput(TARGET:inc/myId.h)
    // ID de conexión para EMIC Bus
    #define _I2C_ID .{module.Id}.
    #define MODULE_NAME ".{module.name}."
    EMIC:restoreOutput

    // Crear archivo de configuración por defecto (opcional)
    EMIC:setOutput(SYS:Default.txt)
    // Configuración por defecto del módulo .{global.module}.
    // Creado: deploy
    EMIC:restoreOutput

EMIC:restoreOutput
```

## 24.15 Resumen

| Paso | Acción | Resultado |
|------|--------|-----------|
| 1 | Crear estructura | Carpetas `System/` y `target/` |
| 2 | Copiar archivos | Scripts `.emic` y recursos del módulo |
| 3 | Generar ID | Archivo `Id.txt` con número único |
| 4 | Configurar volúmenes | DEV:, SYS:, TARGET:, PRJ: disponibles |
| 5 | Inicializar macros | global, project, module, user, config |
| 6 | Ejecutar deploy.emic | Archivos de usuario y pestañas |
| 7 | Generar archivos iniciales | userFncFile.c, EMIC-TABS/ |
| 8 | EMIC-Discovery | Ejecutar generate.emic en modo Discovery |
| 9 | Extraer recursos | Leer tags DOXYGEN de las APIs |
| 10 | Generar Resources | XML con funciones y eventos para el Editor |

### Archivos Clave Generados

| Archivo | Propósito |
|---------|-----------|
| `module.json` | Metadatos de la instancia |
| `Id.txt` | ID único de conexión |
| `userFncFile.c` | Código del usuario (vacío inicial) |
| `EMIC-TABS/*` | Pestañas del Editor |
| `EMIC-TABS/Resources` | **XML con funciones y eventos (generado por Discovery)** |
| `config.json` | Configuración del usuario (si aplica) |
