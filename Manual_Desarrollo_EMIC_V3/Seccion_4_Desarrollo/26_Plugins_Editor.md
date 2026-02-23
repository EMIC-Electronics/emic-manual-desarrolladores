# Capítulo 26: Plugins del Editor

## 26.1 Introducción

El **Editor EMIC** utiliza un sistema de **plugins** para proporcionar las herramientas de edición visual al usuario. Los plugins definen las pestañas laterales (sidebar-tabs) que contienen los bloques, funciones y controles que el usuario puede arrastrar al canvas de programación.

### ¿Qué es un Plugin?

Un plugin es un archivo **XML** que declara **Web Components** prediseñados en el backend del Editor. Cada plugin define:

- Qué componentes visuales mostrar
- Cómo organizarlos en contenedores
- Qué atributos y comportamientos tienen

### Sistema Extensible

El sistema de plugins está diseñado para ser **flexible**:

- Actualmente, todos los módulos instancian los mismos plugins base
- En el futuro, módulos especiales podrán incorporar plugins personalizados
- Por ejemplo: un módulo con pantalla LCD podría incluir un editor gráfico especializado

## 26.2 Ubicación de los Plugins

Los plugins base se encuentran en:

```
_templates/
└── plugins/
    └── sidebar-tabs/
        ├── Code        # Control de flujo y operadores
        ├── Data        # Variables y estructuras de datos
        ├── Functions   # Funciones de usuario
        └── User        # Personalización (vacío por defecto)
```

### Copia Durante el Deploy

Durante la instanciación de un módulo, el `deploy.emic` copia estos plugins a la carpeta del proyecto:

```c
EMIC:copy(DEV:_templates/plugins/sidebar-tabs > SYS:EMIC-TABS)
```

Resultado en el proyecto del usuario:

```
My Projects/MiProyecto/USB_1/
└── System/
    └── EMIC-TABS/
        ├── Code        # Copiado del template
        ├── Data        # Copiado del template
        ├── Functions   # Copiado del template
        ├── User        # Copiado del template
        └── Resources   # GENERADO por EMIC-Discovery (no es un plugin)
```

> **Nota**: El archivo `Resources` NO es un plugin. Es generado automáticamente por EMIC-Discovery y contiene las funciones/eventos específicos del módulo.

## 26.3 Estructura de un Plugin

Los plugins son archivos XML que referencian **Web Components** (Custom Elements) predefinidos en el Editor EMIC.

### Formato General

```xml
<emic-contenedor-tipo name="Nombre del Grupo" icon="icono">
    <emic-elemento-tipo
        name="nombre_interno"
        alias="Nombre Visible"
        brief="Descripción">
        <!-- Parámetros opcionales -->
    </emic-elemento-tipo>
</emic-contenedor-tipo>
```

### Tipos de Contenedores

| Contenedor | Propósito |
|------------|-----------|
| `<emic-flow-container>` | Agrupa bloques de control de flujo |
| `<emic-math-container>` | Agrupa operadores matemáticos y de comparación |
| `<emic-utility-container>` | Agrupa funciones de utilidad |
| `<emic-data-container>` | Agrupa tipos de datos |
| `<emic-functions-panel>` | Panel de funciones de usuario |
| `<emic-variables-panel>` | Panel de variables |

## 26.4 Plugin: Code

El plugin `Code` proporciona los bloques de control de flujo, operadores y funciones de utilidad.

### Contenido Completo

```xml
<!-- Control de Flujo -->
<emic-flow-container name="Control de Flujo">
    <emic-flow-if name="conditional_if" alias="if...else"
        brief="Estructura condicional if-else"></emic-flow-if>
    <emic-flow-switch name="conditional_switch" alias="switch"
        brief="Estructura condicional switch-case"></emic-flow-switch>
</emic-flow-container>

<!-- Operadores de Comparación -->
<emic-math-container name="Comparación">
    <emic-math-equal></emic-math-equal>
    <emic-math-notequal></emic-math-notequal>
    <emic-math-greater></emic-math-greater>
    <emic-math-less></emic-math-less>
    <emic-math-greaterequal></emic-math-greaterequal>
    <emic-math-lessequal></emic-math-lessequal>
</emic-math-container>

<!-- Operadores Aritméticos -->
<emic-math-container name="Operadores">
    <emic-math-plus></emic-math-plus>
    <emic-math-minus></emic-math-minus>
    <emic-math-multiplication></emic-math-multiplication>
    <emic-math-division></emic-math-division>
</emic-math-container>

<!-- Manipulación de Strings -->
<emic-utility-container name="Manipulación de Strings" icon="text_format">
    <emic-utility-function category="String" name="string_length" type="uint16_t"
        brief="Obtiene la longitud de una cadena de texto" alias="string.length">
        <emic-function-parameter name="str" type="char*" brief="Cadena de texto">
        </emic-function-parameter>
    </emic-utility-function>
    <emic-utility-function category="String" name="string_compare" type="int8_t"
        brief="Compara dos cadenas de texto" alias="string.compare">
        <emic-function-parameter name="str1" type="char*" brief="Primera cadena">
        </emic-function-parameter>
        <emic-function-parameter name="str2" type="char*" brief="Segunda cadena">
        </emic-function-parameter>
    </emic-utility-function>
    <!-- ... más funciones de string -->
</emic-utility-container>

<!-- Manipulación de Arrays -->
<emic-utility-container name="Manipulación de Arrays" icon="data_array">
    <emic-utility-function category="Array" name="array_sort" type="void"
        brief="Ordena un array de enteros" alias="array.sort">
        <emic-function-parameter name="arr" type="int*" brief="Array a ordenar">
        </emic-function-parameter>
        <emic-function-parameter name="size" type="uint16_t" brief="Tamaño del array">
        </emic-function-parameter>
    </emic-utility-function>
    <!-- ... más funciones de array -->
</emic-utility-container>

<!-- Conversiones de Tipos -->
<emic-utility-container name="Conversiones de Tipos" icon="swap_horiz">
    <emic-utility-function category="Convert" name="convert_intToString" type="void"
        brief="Convierte un entero a cadena" alias="convert.intToString">
        <emic-function-parameter name="value" type="int32_t" brief="Valor entero">
        </emic-function-parameter>
        <emic-function-parameter name="buffer" type="char*" brief="Buffer de salida">
        </emic-function-parameter>
        <emic-function-parameter name="buffer_size" type="uint16_t" brief="Tamaño del buffer">
        </emic-function-parameter>
    </emic-utility-function>
    <!-- ... más funciones de conversión -->
</emic-utility-container>

<!-- Operaciones Matemáticas -->
<emic-utility-container name="Operaciones Matemáticas" icon="functions">
    <emic-utility-function category="Math" name="math_abs" type="int32_t"
        brief="Valor absoluto de un número" alias="math.abs">
        <emic-function-parameter name="value" type="int32_t" brief="Valor de entrada">
        </emic-function-parameter>
    </emic-utility-function>
    <emic-utility-function category="Math" name="math_random" type="uint32_t"
        brief="Genera un número aleatorio" alias="math.random">
        <emic-function-parameter name="min" type="uint32_t" brief="Valor mínimo">
        </emic-function-parameter>
        <emic-function-parameter name="max" type="uint32_t" brief="Valor máximo">
        </emic-function-parameter>
    </emic-utility-function>
    <!-- ... más funciones matemáticas -->
</emic-utility-container>
```

### Elementos del Plugin Code

| Elemento | Tipo | Descripción |
|----------|------|-------------|
| `emic-flow-if` | Bloque | Estructura condicional if-else |
| `emic-flow-switch` | Bloque | Estructura switch-case |
| `emic-math-equal` | Operador | Comparación de igualdad (==) |
| `emic-math-plus` | Operador | Suma (+) |
| `emic-utility-function` | Función | Función de utilidad predefinida |

## 26.5 Plugin: Data

El plugin `Data` proporciona el panel de gestión de variables y estructuras de datos.

### Contenido

```xml
<emic-variables-panel>
    <emic-data-container name="Variables" icon="variables" emic-type="emic-data-variable">
    </emic-data-container>
    <emic-data-container emic-type="emic-data-array"></emic-data-container>
    <emic-data-container emic-type="emic-data-struct"></emic-data-container>
    <emic-data-container emic-type="emic-data-map"></emic-data-container>
    <emic-data-container emic-type="emic-data-buffer"></emic-data-container>
    <emic-data-container emic-type="emic-data-variable"></emic-data-container>
</emic-variables-panel>
```

### Tipos de Datos Soportados

| Tipo | Elemento | Descripción |
|------|----------|-------------|
| Variable | `emic-data-variable` | Variables simples (int, float, char, etc.) |
| Array | `emic-data-array` | Arreglos de datos |
| Struct | `emic-data-struct` | Estructuras de datos |
| Map | `emic-data-map` | Mapas clave-valor |
| Buffer | `emic-data-buffer` | Buffers de comunicación |

## 26.6 Plugin: Functions

El plugin `Functions` proporciona el panel para crear funciones de usuario.

### Contenido

```xml
<emic-functions-panel>
    <emic-data-container name="Functions" icon="function" emic-type="emic-user-function">
    </emic-data-container>
</emic-functions-panel>
```

Este plugin permite al usuario:
- Crear funciones personalizadas
- Definir parámetros y tipos de retorno
- Organizar código reutilizable

## 26.7 Plugin: User

El plugin `User` está vacío por defecto y es un espacio reservado para personalizaciones futuras del módulo.

```xml
<!-- Archivo User vacío -->
```

## 26.8 Archivo Resources (No es un Plugin)

Es importante distinguir que el archivo `Resources` **NO** es un plugin. Es generado automáticamente por **EMIC-Discovery** y contiene las funciones y eventos específicos del módulo.

### Diferencia Clave

| Característica | Plugins (Code, Data, etc.) | Resources |
|----------------|---------------------------|-----------|
| Origen | Copiado de `_templates/plugins/` | Generado por EMIC-Discovery |
| Contenido | Herramientas genéricas | Funciones/eventos del módulo |
| Formato | XML con Web Components | XML con funciones DOXYGEN |
| Modificación | Igual para todos los módulos | Único para cada módulo |

### Estructura de Resources

```xml
<emic-drivers>
    <emic-driver-container name="LEDs" icon="cable">
        <emic-program-function driver="LEDs" name="LEDs_led1_state" type="void"
            brief="Change the state of the led" alias="led1.state" draggable="true">
            <emic-function-parameter name="state" type="uint8_t"
                brief="1-on 0-off 2-toggle">
            </emic-function-parameter>
        </emic-program-function>
    </emic-driver-container>

    <emic-driver-container name="SYSTEM" icon="cable">
        <emic-program-event driver="SYSTEM" name="onReset" type="void"
            brief="When the module is ready" alias="onReset" draggable="true" droppable="">
        </emic-program-event>
    </emic-driver-container>
</emic-drivers>
```

Ver **Capítulo 24** para más detalles sobre cómo se genera este archivo.

## 26.9 Web Components Disponibles

Los plugins referencian Web Components predefinidos en el Editor EMIC. Estos son algunos de los principales:

### Contenedores

| Componente | Descripción |
|------------|-------------|
| `emic-flow-container` | Contenedor de bloques de control |
| `emic-math-container` | Contenedor de operadores |
| `emic-utility-container` | Contenedor de funciones de utilidad |
| `emic-driver-container` | Contenedor de funciones de un driver |
| `emic-variables-panel` | Panel de gestión de variables |
| `emic-functions-panel` | Panel de funciones de usuario |

### Bloques de Control

| Componente | Descripción |
|------------|-------------|
| `emic-flow-if` | Estructura if-else |
| `emic-flow-switch` | Estructura switch-case |
| `emic-flow-while` | Bucle while |
| `emic-flow-for` | Bucle for |

### Operadores

| Componente | Símbolo | Descripción |
|------------|---------|-------------|
| `emic-math-equal` | == | Igualdad |
| `emic-math-notequal` | != | Diferencia |
| `emic-math-greater` | > | Mayor que |
| `emic-math-less` | < | Menor que |
| `emic-math-plus` | + | Suma |
| `emic-math-minus` | - | Resta |
| `emic-math-multiplication` | * | Multiplicación |
| `emic-math-division` | / | División |

### Funciones y Eventos

| Componente | Descripción |
|------------|-------------|
| `emic-utility-function` | Función de utilidad predefinida |
| `emic-program-function` | Función de una API del módulo |
| `emic-program-event` | Evento que puede implementar el usuario |

### Datos

| Componente | Descripción |
|------------|-------------|
| `emic-data-variable` | Variable simple |
| `emic-data-array` | Arreglo |
| `emic-data-struct` | Estructura |
| `emic-data-buffer` | Buffer |
| `emic-user-function` | Función definida por el usuario |

## 26.10 Plugins Personalizados (Futuro)

El sistema de plugins está diseñado para permitir **extensiones personalizadas** en módulos especiales.

### Caso de Uso: Módulo con Pantalla LCD

Un módulo que controla una pantalla LCD podría incluir un **editor gráfico** especializado:

```
_modules/
└── Display/
    └── LCD_Module/
        ├── m_description.json
        └── System/
            ├── deploy.emic
            ├── generate.emic
            └── plugins/               # Plugins personalizados
                └── GraphicEditor      # Editor gráfico para la pantalla
```

### Deploy con Plugin Personalizado

```c
EMIC:setOutput(SYS:deploy.txt)
    // Copiar plugins base
    EMIC:copy(DEV:_templates/plugins/sidebar-tabs > SYS:EMIC-TABS)

    // Agregar plugin personalizado del módulo
    EMIC:copy(SYS:plugins/GraphicEditor > SYS:EMIC-TABS/GraphicEditor)

    // ... resto del deploy
EMIC:restoreOutput
```

### Estructura del Plugin Personalizado

```xml
<!-- GraphicEditor -->
<emic-graphic-editor-panel name="Editor Gráfico" icon="image">
    <emic-graphic-tool name="draw_rectangle" alias="Rectángulo"
        brief="Dibuja un rectángulo"></emic-graphic-tool>
    <emic-graphic-tool name="draw_circle" alias="Círculo"
        brief="Dibuja un círculo"></emic-graphic-tool>
    <emic-graphic-tool name="draw_text" alias="Texto"
        brief="Inserta texto"></emic-graphic-tool>
    <!-- ... más herramientas gráficas -->
</emic-graphic-editor-panel>
```

> **Nota**: Los Web Components personalizados (`emic-graphic-editor-panel`, `emic-graphic-tool`) deberían estar implementados en el backend del Editor para que el plugin funcione.

## 26.11 Resumen

### Plugins Estándar

| Plugin | Contenido | Archivo |
|--------|-----------|---------|
| Code | Control de flujo, operadores, utilidades | `_templates/plugins/sidebar-tabs/Code` |
| Data | Variables, arrays, structs | `_templates/plugins/sidebar-tabs/Data` |
| Functions | Funciones de usuario | `_templates/plugins/sidebar-tabs/Functions` |
| User | Personalización (vacío) | `_templates/plugins/sidebar-tabs/User` |

### Diferencia Plugin vs Resources

| Aspecto | Plugins | Resources |
|---------|---------|-----------|
| Origen | Template copiado | Generado por EMIC-Discovery |
| Contenido | Herramientas genéricas | APIs específicas del módulo |
| Cuándo se crea | Durante deploy | Después del deploy |

### Características del Sistema

- **Formato XML**: Los plugins son archivos XML sin extensión
- **Web Components**: Referencian Custom Elements prediseñados
- **Extensible**: Diseñado para soportar plugins personalizados en el futuro
- **Separación de responsabilidades**: Plugins (herramientas) vs Resources (funciones del módulo)

### Referencias

- **Capítulo 24**: Proceso de Deploy - copia de plugins al proyecto
- **Capítulo 25**: Desarrollo de Módulo - uso de plugins en deploy.emic
