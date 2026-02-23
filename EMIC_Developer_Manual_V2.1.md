# EMIC CODIFY

## Introducción

EMIC es una plataforma para desarrollar código C para microcontroladores PIC de microchip.

El modelo de trabajo EMIC esta basado en un esquema modular, escalable, ordenado, colaborativo y autodescriptivo, que permite dividir las etapas necesarias para obtener soluciones complejas en tareas más simples que son llevadas a cabo por distintos actores en distintos momentos.

Actores claves:

* Desarrolladores: Crean el codigo de menor nivel en la pila de abstraccion, que es la materia prima que utilizaran los integradores para crear un proyecto concreto.

* Integradores: Crean una solucion a un problema real, utilizando los recursos creados por los desarrolladores. La caracteristica principal de los Integradores es que conocen el campo en donde se desempeña el producto desarrollado, no solo las condiciones ambientales, y electromagneticas, sino que tambien saben las costumbres del usuario objetivo. Ademas da feedback al desarrollador para corregir bugs y mejorar la calidad del código.

> Nota: La definición separada de los roles es figurativa y no implica que no puedan ser representada por la misma persona.

Esquema de funcionamiento:

1. Los desarrolladores crean "EMIC-Libraries" usando código C y "EMIC-Codify", que incluyen etiquetado de recursos de programacion como funciones y variables que permiten  a integradores utilizar esas referencia como punto de conexión con el código de bajo nivel para crear las soluciones.

2. En la etapa Discovery, el sistema EMIC, interpreta el metatexto contenido de las "EMIC-Libraries" y extrae referencias a funciones, variables y otros recursos de las bibliotecas. Estas referencias se publican en la interfaz de usuario llamada "EMIC-Editor", esto permite que el código sea accesible desde un entorno de programación de alto nivel para los integradores. 

3. En la fase de integracion, el integrador, crea aplicaciones para una solución a un requerimiento específico, desde el "EMIC-editor" el "integrador", creará un script que contenga la lógica de funcionamiento de la solución.

4. Ese script es utilizado por otro proceso del sistema llamado "EMIC-Generate" , que accede a las "EMIC-Libraries" creadas por los desarrolladores en el primer paso y lo integra con el Script creado en la face de integracion, para obtener un resultado final, que es un programa C compilable con XC compiler de microchip.

Los archivos de las "EMIC-Libraries", creados por los desarrolladores, se alojan en repositorios de GitHub y están organizados respetando las especificaciones de EMIC.

## Organizacion de los repositorios EMIC

Cada usuario cuenta con un espacio de almacebaniento en el servidor, en donde se define un volumen (o disco) virtual demonimado "USER:/", tamien existe un sistema de mapeo dinámico en el que se pueden definir algunos volúmenes (o discos) virtuales de almacenamiento , entre ellos se encuentran "DEV:/" que se mapea en "USER:/DEV" y "PROJECTS:/"  que se mapea en "USER:/My Projects".
Dentro de "DEV:/", se encuentran los repositorios, y en cada uno de los repositorios existen varias carpetas en donde se guarda de forma ordenada las EMIC-Libraries, de la siguiente forma:


-  `_modules` : Contiene información relacionadas a los EMIC-Modules, se designa con el nombre "EMIC-Module" a un grupo de recursos de hardare y firmware que describen a una unidad funcional del mundo real, generalmente un módulo representa a un placa electronica que contiene el microcontrolador con los periféricos, así como al firmare formado por las funciones que controlan los recursos de hardware y la lógica propia de la aplicacion embebida en ese hardware. La carpeta _modules contiene dos subcarpetas que serán copiadas a la carpeta en donde se creará la implementacíon de una solución específica:
     - System: Contiene los archivos con información que se utilizará para la implentación de la solución en la etapa de generación de código compilable. Dentro de System debe existir un archivo llamado generate.emic, en conteniendo código escrito en EMIC-Codify, que será interpretado en las etapas EMIC-Discovery para indexar los recursos disponibles y EMIC-Generate para crear el código compilable.
     - Target: Contiene el resultado del proceso de Generación, es decir el código fuente listo para compilar.

- `_api`: Las APIs son las bibliotecas que se integrarán al código final, siempre que sean invocadas desde el EMIC-Generate, o desde otra API. **Es importante destacar que las APIs son un conjunto de funciones cuyo propósito principal es crear una capa que aísle el acceso a funciones que dependen de un hardware específico**. Por este motivo, las APIs generalmente deberán utilizar funciones localizadas en la carpeta `_drivers`. Por ejemplo, para un sensor de temperatura, deberían existir funciones como `readTemperature()`. Como la API recibirá un parámetro llamado `driver` con el nombre del sensor específico, utilizará ese parámetro para incluir el driver del sensor correspondiente. La estructura interna de cada carpeta que define una API es la Siguiente:
    - ApiName.emic (archivo que contiene el script EMIC con las definiciones de los recursos disponibles y las dependencias).
    - inc (carpeta que contiene archivos header de C - estos archivos pueden contener comandos en EMIC.Codify)
    - src (carpeta que contiene archivos con código C - estos archivos pueden contener comandos en EMIC.Codify).

- `_drivers`: Contiene el código necesario para controlar hardware específico, pero a diferencia de _hard, que contiene código específico para los periféricos de los microcontroladores, _drivers contiene código para controlar hardware externo como sensores, displays, módulos de comunicación, etc. Las APIs en _api utilizan estos drivers para proporcionar una interfaz de alto nivel.

- `_hal`: Hardware Abstraction Layer, proporciona una capa de abstracción para acceder a recursos de hardware específicos de los microcontroladores. Esto permite que el código de nivel superior sea independiente del microcontrolador utilizado.

- `_hard` : Código de controladores de recursos de hardware específicas para diferentes microcontroladores.

- `_main` : Contiene el archivo main.c 

- `_pcb` : Definiciones específicas para placas de circuito impreso.

- `_templates` : Plantillas para proyectos, como configuraciones para mplab-X.

- `_system` : Código de apoyo necesario para convertir el Script en lenguaje C, las funciones implementadas en esta carpetas incluyen principalmente las conversiones de tipos de datos.

- `_util` : Contiene APIs con funciones de uso general, independiente del hardware, los casos típocos de las bibliotecas incluidas son:
    - Operadores matematicos.
    - Operadores lógicos.
    - Operadores de cadenas de caracteres.
    - Operadores de control de flujo.
    - Etc.



## EMIC Codify

EMIC Codify es un lenguaje pensado para crear código C compilable a partir de un conjunto de archivos de texto existentes llamados "EMIC-Libraries".

El código creado está basado:
- Código existente en las EMIC-Libraries.
- Parámetros de los comandos EMIC.
- "Script" creado en el "EMIC-Editor".
- Preferencias del usuario obtenidas del entorno. 

EMIC-Codify está formado por comandos y etiquetas:

- Los comandos permiten manipular el contenido de las EMIC-Libraries guardando el resultado de las modificaciones en los archivos de salida.

- La etiquetas se utilizan para extraer referencias al código (funciones, variables, etc.) y utlizarlas en el EMIC-Editor.

Cuando el sistema EMIC fusiona el script editado en EMIC-Editor, con las EMIC-Libraries, lo hace siguiendo instrucciones incluidas en el código de las EMIC-Libraries comenzando por la interpretacion del generate.emic incluida en la carpeta _modules/{module name}/System/generate.emic. 

Estas instrucciones estarán escritas en un lenguaje de programación creado especialmente para el manejo de documentos de texto y código llamado EMIC-Codify.

Una vez que está listo el script (editado en el EMIC-Editor), el integrador, presiona el boton "Generate".
Luego, el sistema comienza a generar la solución interpretando los comandos ubicados en un archivo llamado **generate.emic**. Estos comandos indican los pasos a seguir, incluyendo las rutas con las ubicaciones de todas las dependencias del proyecto. A medida que se invocan los archivos para formar parte de la solución, se ejecutan los comandos EMIC que se encuentran en esos archivos.

Existen comandos con la forma **EMIC:xxxx(yyyy)** que indican una acción que se ejecuta inmediatamente, o evalúan una condición para determinar si el próximo bloque de código debe ser interpretado o ignorado.

El resto de las líneas de texto que no contienen comandos serán enviadas a un archivo de salida que formará parte de la solución final. Aunque, si dentro de este texto se encuentra una expresión de la forma **.{xxx.yyy}.**, será reemplazada por otro texto que fue definido previamente.

Para acceder a los distintos archivos contenidos, tanto en el repositorio, como en el proyecto que se está editando, se crea dinámicamente, un sistema de rutas y volúmenes lógicos. De esta manera, para referirse a un archivo en particular no hace falta conocer su verdadera ubicación.
Los volúmenes lógicos son:

| Volumen   | Referencia                                                        |
|-----------|-------------------------------------------------------------------|
| `DEV:`    | Volumen donde se encuentran los archivos del repositorio.         |
| `TARGET:` | Volumen donde se van almacenando los archivos generados en el proceso de compilación. |
| `SYS:`    | Volumen donde se crean los archivos de configuración de cada aplicación. |
| `USER:`   | Volumen donde se ubican los archivos del usuario (integrador).    |


* Estos volumenes són válidos durante la integración de cada proyectos no tienen sentido en otros contextos.

## Comandos EMIC Codify

> Nota: Los términos encerrados entre corchetes son opcionales y entre dobles corchetes se pueden repetir varias veces.

---

### Comandos con parametros

Algunos comandos emic, como *setInput* y *copy*,  pueden incluir la definicion de pares de clave-valor llamados ***macros*** que serán usados como texto variable durante el procesamiento.

Es decir que durante el procesamiento del comando se crea un grupo temporal de claves llamado **local**, en el grupo local se definen las claves y valores que fueron definidas en el comando.

Luego, para obtener el valor de cada parametro dentro del procesamiento del archivo invocado en el comando. Se utiliza cualquiera de las siguiente notaciones indistintamente:

- **.{local.*key*}.**
- **.{*key*}.**



---

### setInput

Inicializa el procesamiento de un archivo. Cuando finaliza, se continuará procesando el archivo actual. El comando puede incluir la definicion de pares de clave-valor llamados ***macros*** que serán usados como texto variable durante el procesamiento.

#### Sintaxis:

```markdown
EMIC:setInput([origin:][dir/]file[[,key=value]])
```

#### Definiciones:

| Nombre   | Opcional | Descripción                                                                                         |
|----------|:--------:|-----------------------------------------------------------------------------------------------------|
| `origin` | Sí       | Volumen en el que se ubica el archivo. Si se omite, se usará el volumen actual.                     |
| `dir`    | Sí       | Ruta del archivo.                                                                                   |
| `file`   | No       | Nombre del archivo.                                                                                 |
| `key`    | Sí       | Nombre de cada parámetro que será utilizado en la interpretación del archivo.                       |
| `value`  | Sí       | Valor que tomará el parámetro que reemplaza a la clave en la interpretación del archivo.            |

---

### setOutput

Establece el archivo de salida. Todo el texto generado durante el procesamiento siguiente al comando será enviado al archivo indicado. Si el archivo no existe, se creará en el momento en que se intente escribir en él. Cada vez que se ejecuta este comando, la salida actual se almacena para ser restablecida posteriormente.

#### Sintaxis:

```markdown
EMIC:setOutput([target:][dir/]file)
```

#### Definiciones:

| Nombre   | Opcional | Descripción                                                                                        |
|----------|:--------:|----------------------------------------------------------------------------------------------------|
| `target` | Sí       | Volumen en el que se encuentra el archivo de salida. Si se omite, se usará el volumen de salida actual. |
| `dir`    | Sí       | Ruta del archivo. Si no existe, se crea. Si se omite, se usará la ruta de salida actual.                |
| `file`   | No       | Nombre del archivo. Si el archivo no existe, se crea.                                             |

---

### restoreOutput

Restablece el archivo de salida al destino anterior.

#### Sintaxis:

```markdown
EMIC:restoreOutput
```

---

### copy

Indica al sistema que se debe procesar un archivo y enviar el texto generado durante el procesamiento a un archivo de salida especificado. Si el archivo no existe, se creará en el momento en que se intente escribir en él. Al ejecutar el comando, se pueden definir mediante pares de clave-valor un conjunto de ***macros*** que serán usadas como texto variable durante el procesamiento.

#### Sintaxis:

```markdown
EMIC:copy([origin:][dir1/]file1,[target:][dir2/]file2[[,key=value]])
```

#### Definiciones:

| Nombre   | Opcional | Descripción                                                                                       |
|----------|:--------:|---------------------------------------------------------------------------------------------------|
| `origin` | Sí       | Volumen en el que se encuentra el archivo de entrada. Si se omite, se usará el volumen actual.    |
| `dir1`   | Sí       | Ruta del archivo de entrada. Si se omite, se usará la ruta del archivo procesado actualmente.     |
| `file1`  | No       | Nombre del archivo de entrada.                                                                    |
| `target` | Sí       | Volumen en el que se encuentra el archivo de salida. Si se omite, se usará el volumen de salida actual. |
| `dir2`   | Sí       | Ruta del archivo de salida. Si no existe, se crea. Si se omite, se usará la ruta de salida actual. |
| `file2`  | No       | Nombre del archivo de salida. Si el archivo no existe, se crea.                                   |
| `key`    | Sí       | Nombre de cada parámetro que será utilizado en la interpretación del archivo.                     |
| `value`  | Sí       | Valor que tomará el parámetro que reemplaza a la clave en la interpretación del archivo.          |



---

### define

Define una nueva ***macro*** formada por una clave y un valor, que será almacenada para su posterior utilización.

#### Sintaxis:

```markdown
EMIC:define([group.]key,value)
```

#### Definiciones:

| Nombre   | Opcional | Descripción                                                                        |
|----------|:--------:|------------------------------------------------------------------------------------|
| `group`  | Sí       | Nombre del grupo en que se define la macro. Si se omite, se usa el grupo por defecto ***global*** |
| `key`    | No       | Clave que identifica a la ***macro***.                                             |
| `value`  | No       | Texto que se guarda de la ***macro***.                                              |

---

### unDefine

Borra una ***macro***.

#### Sintaxis:

```markdown
EMIC:unDefine([group.]key)
```

#### Definiciones:

| Nombre   | Opcional | Descripción                                                                        |
|----------|:--------:|------------------------------------------------------------------------------------|
| `group`  | Sí       | Nombre del grupo en que se define la macro. Si se omite, se usa el grupo por defecto ***global*** |
| `key`    | No       | Clave que identifica a la ***macro***.                                             |

---

### .{[group].key}.

Este comando se usa en las partes del texto que queremos que sean sustituidas por otro texto definido previamente.

Reemplaza .{[**group**.]**key**}. por el valor asignado con:

```markdown
EMIC:define([group.]key,value)
```

#### Sintaxis:

text... .{[**group**.]**key**}. ...more text

en caso que se omita el grupo, se buscara la clave en el grupo llamado "*local*", si no hay una clave definida en el grupo *local* se buscara en el grupo "*global*", y en caso que no esxista en *global*, se mostrará un mensaje de error.

#### Grupos de macros disponibles:

| Grupo | Descripción | Ejemplo de acceso | Cuándo se crea |
|-------|-------------|-------------------|----------------|
| **local** | Parámetros pasados en comandos EMIC (setInput, copy, etc.) | `.{nombre}.` o `.{local.nombre}.` | Durante procesamiento de comandos |
| **global** | Macros definidas con EMIC:define sin grupo | `.{nombre}.` o `.{global.nombre}.` | Con EMIC:define(nombre,valor) |
| **config** | Valores de configuradores JSON seleccionados por el usuario | `.{config.nombre}.` | Durante EMIC:Discovery con configuradores |
| **system** | Macros del sistema (ej: nombre del microcontrolador) | `.{system.nombre}.` | Por el sistema EMIC |


---


### EMIC:foreach(**group**)    .{Item}.     EMIC:endfor



#### Sintaxis:

```markdown
EMIC:foreach(group)
    linea1 ...
    linea2a ... .{Item}.  ... linea2b
    linea3 ... 
    ... 
EMIC:endfor
```

---
### .{group.*}.

Este comando se usa en las partes del texto que queremos que sean sustituidas por todas las definiciones pertencientes al grupo 

```markdown
EMIC:define(**group**.**key**,**value**)
```

es similar a EMIC:foreach(**group**) , pero solo permite una linea.

---


### if

#### Sintaxis:

Evalua la condición, si resulta verdadera, continua interpretando las siguientes lineas, de contrario, saltea hasta encontrar el final del bloque (endif)

```markdown
EMIC:if(condition)
```

#### Definiciones:

| Nombre   | Opcional | Descripción        |
|----------|:--------:|--------------------|
| `condition` | No | La condición a evaluar. |

---

### elif

Complemto del comando anterior.

#### Sintaxis:

```markdown
EMIC:elif(condition)
```

#### Definiciones:

| Nombre   | Opcional | Descripción        |
|----------|:--------:|--------------------|
| `condition` | No | La condición a evaluar. |

---

### ifdef

#### Sintaxis:

```markdown
EMIC:ifdef(macro)
```

Si fue definada la macro, continua interpretando las siguientes lineas, de contrario, saltea hasta encontrar el final del bloque (endif)



#### Definiciones:

| Nombre   | Opcional | Descripción        |
|----------|:--------:|--------------------|
| `macro` | No | La macro a evaluar si está definida. |

---

### ifndef

Si no fue definada la macro, continua interpretando las siguientes lineas, de contrario, saltea hasta encontrar el final del bloque (endif)



#### Sintaxis:

```markdown
EMIC:ifndef(macro)
```



#### Definiciones:

| Nombre   | Opcional | Descripción        |
|----------|:--------:|--------------------|
| `macro` | No | La macro a evaluar si no está definida. |

---

### else

#### Sintaxis:

```markdown
EMIC:else
```

#### Definiciones:

---

### endif

#### Sintaxis:

```markdown
EMIC:endif
```

#### Definiciones:

---

## Tags EMIC Codify

Las etiquetas EMIC, son pequeños fragmentos de textos utilizados para identificar recursos de programacion disponibles en el archivo de origen y publicarlos en EMIC-Editor, es decir que se utilizan en la etapa llamada EMIC.Discovery.
Esto permite que el acceso a estos recursos (que pueden ser varibles; funciones; definiciones de macros; etc. ), alojados en las bibliotecas de codigo estén disponible para el integrador cuando crea el script.

### tag

#### Sintaxis:

```markdown
EMIC:tag(driverName = xxxx)
```

Permite definir una etiqueta que el sistema utilizará con un proposito específico.

- La etiqueta denominada **driverName** se utiliza para agrupar los recursos de programación logrando que en el **Editor EMIC** se presenten de manera ordenada.

---
 ### Publicacion de recursos.

La publicacion de recursos es utilizada para conectar el codigo de las EMIC-Libraries con el EMIC-Editor, se realiza durante el proceso llamado EMIC-Discovery, que se ejecuta en el momento que el integrador comienza a crear un proyecto, y selecciona los modulos que formaran parte de la solucion.

Para indentificar los recursos que sean accesibles desde el editor, el desarrollador los debe marcar con alguna etiqueta específica para el tipo de recurso.

**Es importante destacar que todas las definiciones de funciones, eventos y variables deben estar dentro de un archivo ".emic"** para que puedan ser descubiertas y publicadas correctamente durante el proceso EMIC-Discovery.

### Etiquetado de recursos:

Hay muchos tipos de recursos que pueden ser publicados, y por lo tanto podrian ser usados en la etapa de integración.

A continuación se analizan los mas usados:

#### Funciones:

- Formato DOXYGEN: 

Similar a la forma de documentar funciones en DOXYGEN, 


* @fn *tipo* *nombre* ([lista de parametros])
* @alias *alias*   
* @brief *resumen_que_explica_la_funcion*
* @param *nombre_parametro1* *resumen_que_explica_el_parametro1*
* @param *nombre_parametro2* *resumen_que_explica_el_parametro2*
........
* @param *nombre_parametron* *resumen_que_explica_el_parametron*
* @return *resumen_que_explica_el_return*



Ejemplo:
```plaintext
/**
* @fn void setTime.{name}.(uint16_t time,char mode);
* @alias setTime.{name}.
* @brief Time in milliseconds for the event to be generated. 
* @param time Time in milliseconds.
* @param mode T:timer, A:auto-reload.
* @return Nothing
*/
```

* Caso especial de publicacion de funciones:

Funciones variádicas.

Definidas cuando reciben un parametro "char* format" y otro parmetro del tipo variadico "...", ademas en el alias se agregan uno o mas parametros del tipo concat.
Estas funciones permiten (en el editor) concatenar varias valores en cada unos de los parametros vituales del tipo concat y los agrega a una lista de punteros, al mismo tiempo, rellena un array de char con un caracter que define el tipo del puntero, manteniendo el orden en que se concatenan los parametros (similar a printf).


```
/**
* @fn void pUSB(char* format,...);
* @alias Send(concat tag,concat msg)
* @brief Send a EMIC message through the USB port
* @return Nothing
* @param tag Etiqueta que identifica el mensaje
* @param msg Contenido del mensaje
*/
```



#### Eventos:

- Formato DOXYGEN: 

Similar a la forma de documentar funciones en DOXYGEN agregando la palabra "extern", 

* @fn extern *tipo* *nombre* ([lista de parametros])
* @alias *alias*   
* @brief *resumen_que_explica_la_funcion*
* @param *nombre_parametro1* *resumen_que_explica_el_parametro1*
* @param *nombre_parametro2* *resumen_que_explica_el_parametro2*
........
* @param *nombre_parametron* *resumen_que_explica_el_parametron*
* @return *resumen_que_explica_el_return*

Ejemplo:
```plaintext
/**
* @fn extern void etOut.{name}.(void);
* @alias timeOut.{name}.
* @brief When the time configured in the timer1 was established. 
* @return Nothing
*/
```

#### Variables:

El formato para definir variables ahora es similar al de las funciones, utilizando un estilo Doxygen para mejor claridad:

```plaintext
/**
* @var type varName [= initialValue];
* @alias varAlias
* @brief Descripción de la variable y su propósito
*/
```

Ejemplo:
```plaintext
/**
* @var uint8_t ledStatus = 0;
* @alias statusLED
* @brief Estado actual del LED (0=apagado, 1=encendido, 2=parpadeando)
*/
```

Para variables más complejas o con opciones específicas:
```plaintext
/**
* @var uint8_t temperatureUnit = TEMP_CELSIUS;
* @alias tempUnit
* @brief Unidad de temperatura para mostrar los valores
* @options TEMP_CELSIUS("°C"), TEMP_FAHRENHEIT("°F"), TEMP_KELVIN("K")
*/
```

Similar a la forma de documentar variables en DOXYGEN 
```
type varName [=val] /**<Alias:varAlias> Descripcion   */
```


- Formato JSON: 
EMIC:json(type = ***type*** )


La definicion de recursos en formato json, es usado para definir recursos no estandarizados,
sin embargos algunos tipos de recursos especiales son procesados durante la fase de Discovery.

Cuando el recurso no es reconocido  durante el proceso EMIC:Discovery se indexan sin procesarlos, es decir que se copian tal como estan declarados, y serán procesados posteriormente.

Tipos de recursos EMIC:json

* Configurator: 
    Es procesado por EMIC:Discovery siguiendo los siguientes pasos:

    * Evelua si existe una macro con el mismo nombre.
    * Si existe sigue adelante con el proceso.
    * Si no existe, detiene el proceso y presenta en la pantalla un menu de opciones para que el integrador decida solo una.
    * Una vez que el integrador decide, crea una macro asignandole el valor seleccionado.
    * Sigue el proceso EMIC:Discovery.



Ejemplo:

```
EMIC:json(type = Configurator)
{
	'name': 'RS232prot',
	'brief': 'RS232 Protocol',
	"legend': 'Select RS232 Protocol',
	'options': [
		{
			'legend': 'EMIC message',
			'brief': 'Send and receive EMIC messages',
			'value': 'EMIC_message'
		},
		{
			'legend': 'TEXT line',
			'brief': 'Send and receive lines of text that end with a special characters',
			'value': 'TEXT_line'
		}
	]
}
```

### Acceso a valores de configuradores

**IMPORTANTE**: Los configuradores crean macros en el grupo especial `config`, que están disponibles globalmente en todo el proyecto sin necesidad de pasarlas como parámetros.

#### Sintaxis de acceso:

Para acceder al valor de un configurador, usar la sintaxis: `.{config.nombreConfigurador}.`

**Ejemplo:**

Si se define un configurador con `"name": "btName"`, el valor seleccionado por el usuario estará disponible como `.{config.btName}.`

#### Uso en archivos .c/.h:

Los valores de configuradores pueden usarse directamente en cualquier archivo procesado:

```c
void init() {
    // Usar valor del configurador directamente
    sendCommand("AT+NAME.{config.btName}.\r\n");
    sendCommand("AT+PIN.{config.btPass}.\r\n");
}
```

#### NO es necesario pasar configuradores como parámetros:

A diferencia de los parámetros locales, los configuradores NO deben pasarse en comandos `EMIC:copy`:

```
// ✅ CORRECTO - Solo pasar parámetros locales
EMIC:copy(src/file.c > TARGET:file.c,
          port=.{port}.,
          name=.{name}.)
// Los configuradores están disponibles automáticamente

// ❌ INCORRECTO - No pasar configuradores
EMIC:copy(src/file.c > TARGET:file.c,
          btName=.{config.btName}.)  // Innecesario
```

#### Diferencia entre parámetros locales y configuradores:

| Tipo | Ámbito | Sintaxis | Pasar en EMIC:copy |
|------|--------|----------|-------------------|
| Parámetro local | Local al archivo | `.{nombre}.` | ✅ Sí (necesario) |
| Configurador | Global al proyecto | `.{config.nombre}.` | ❌ No (automático) |

---

## Diccionarios del Sistema

EMIC utiliza grupos de macros (diccionarios) para organizar y gestionar diferentes aspectos del proceso de generación de código. Estos diccionarios permiten que las APIs registren sus componentes de manera automática y que el sistema los integre correctamente en el proyecto final.

### Diccionarios de Ejecución

Estos diccionarios controlan el flujo de ejecución del programa embebido.

#### `inits`

**Propósito**: Registra funciones de inicialización que deben ejecutarse una sola vez al arrancar el microcontrolador.

**Definición**: Cada API define su función de inicialización en este grupo.

```c
EMIC:define(inits.LEDs_.{name}.,LEDs_.{name}._init)
```

**Uso en main.c**:
```c
.{inits.*}.();
```

**Expansión generada**:
```c
LEDs_StatusLED._init();
LEDs_ErrorLED._init();
Relay_ON._init();
// ... todas las funciones init de las APIs incluidas
```

**Ubicación típica**: Se define en archivos `.h` de cada API (ejemplo: `_api/Indicators/LEDs/inc/led.h`)

---

#### `polls`

**Propósito**: Registra funciones que deben ejecutarse continuamente en el bucle principal del programa.

**Definición**: Solo se registran las funciones poll de las APIs que las necesitan (generalmente aquellas que manejan temporizadores, eventos asíncronos, etc.).

```c
EMIC:ifdef usedFunction.LEDs_.{name}._blink
void LEDs_.{name}._poll (void);
EMIC:define(polls.LEDs_.{name}.,LEDs_.{name}._poll)
EMIC:endif
```

**Uso en main.c**:
```c
while(1) {
    .{polls.*}.();
}
```

**Expansión generada**:
```c
while(1) {
    LEDs_StatusLED._poll();
    Timer1._poll();
    USB_MCP2200._poll();
    // ... todas las funciones poll de las APIs que las requieren
}
```

**Ubicación típica**: Se define en archivos `.h` de cada API, condicionalmente según si se usa la funcionalidad que requiere polling.

---

### Diccionarios de Integración con el Proyecto

Estos diccionarios gestionan cómo se integran los archivos generados en el proyecto de compilación.

#### `main_includes`

**Propósito**: Registra los archivos header (.h) que deben incluirse en el archivo `main.c`.

**Definición**: Cada API registra su archivo header en este grupo.

```c
EMIC:define(main_includes.led_.{name}.,led_.{name}.)
```

**Uso en main.c**:
```c
#include "inc/.{main_includes.*}..h"
```

**Expansión generada**:
```c
#include "inc/led_StatusLED.h"
#include "inc/led_ErrorLED.h"
#include "inc/relay_ON.h"
// ... todos los headers de las APIs incluidas
```

**Ubicación de definición**: En archivos `.emic` de cada API (ejemplo: `_api/Indicators/LEDs/led.emic`)

---

#### `includes_head`

**Propósito**: Registra headers adicionales del proyecto que necesitan ser incluidos tanto en `main.c` como en la configuración del proyecto MPLAB X.

**Definición**: Similar a `main_includes`, pero típicamente usado para componentes de bajo nivel (HAL, drivers de sistema, etc.).

```c
EMIC:define(includes_head.gpio,gpio)
EMIC:define(includes_head.systemTimer,systemTimer)
```

**Uso en main.c**:
```c
#include "inc/.{includes_head.*}..h"
```

**Uso en configurations.xml**:
```xml
<itemPath>inc/.{includes_head.*}..h</itemPath>
```

**Diferencia con `main_includes`**:
- `main_includes`: Headers de APIs de nivel de aplicación
- `includes_head`: Headers de componentes de sistema (HAL, drivers base, etc.)

---

#### `c_modules`

**Propósito**: Registra los archivos fuente (.c) que deben ser compilados como módulos del proyecto en MPLAB X.

**Definición**: Cada API registra su archivo fuente en este grupo.

```c
EMIC:define(c_modules.led_.{name}.,led_.{name}.)
```

**Uso en configurations.xml**:
```xml
<logicalFolder name="SourceFiles" displayName="Source Files" projectFiles="true">
    <itemPath>.{c_modules.*}..c</itemPath>
</logicalFolder>
```

**Expansión generada en configurations.xml**:
```xml
<itemPath>led_StatusLED.c</itemPath>
<itemPath>led_ErrorLED.c</itemPath>
<itemPath>relay_ON.c</itemPath>
<itemPath>userFncFile.c</itemPath>
<!-- ... todos los módulos C del proyecto -->
```

**Ubicación de definición**: En archivos `.emic` de cada API

---

#### `includes_src`

**Propósito**: Registra archivos fuente (.c) que deben ser incluidos directamente en `main.c` usando `#include`, en lugar de ser compilados como módulos separados.

**Uso en main.c**:
```c
#include ".{includes_src.*}..c"
```

**Nota**: Este diccionario se usa raramente, solo para código que debe ser incluido inline en main.c (por ejemplo, código que requiere estar en el mismo archivo de compilación que main).

---

### Flujo de Trabajo de los Diccionarios

```
1. API define sus componentes
   ├─ led.emic
   │   ├─ EMIC:define(main_includes.led_StatusLED, led_StatusLED)
   │   └─ EMIC:define(c_modules.led_StatusLED, led_StatusLED)
   │
   ├─ led.h
   │   ├─ EMIC:define(inits.LEDs_StatusLED, LEDs_StatusLED._init)
   │   └─ EMIC:define(polls.LEDs_StatusLED, LEDs_StatusLED._poll)

2. Sistema expande los diccionarios
   ├─ main.c
   │   ├─ #include "inc/led_StatusLED.h"    ← main_includes
   │   ├─ LEDs_StatusLED._init();           ← inits
   │   └─ while(1) { LEDs_StatusLED._poll(); }  ← polls
   │
   └─ configurations.xml
       └─ <itemPath>led_StatusLED.c</itemPath>  ← c_modules
```

---

### Ejemplo Completo de Uso

**En _api/Indicators/LEDs/led.emic:**
```c
EMIC:copy(inc/led.h > TARGET:inc/led_.{name}..h,name=.{name}.,pin=.{pin}.)
EMIC:copy(src/led.c > TARGET:led_.{name}..c,name=.{name}.,pin=.{pin}.)

EMIC:define(main_includes.led_.{name}.,led_.{name}.)
EMIC:define(c_modules.led_.{name}.,led_.{name}.)
```

**En _api/Indicators/LEDs/inc/led.h:**
```c
void LEDs_.{name}._init (void);
EMIC:define(inits.LEDs_.{name}.,LEDs_.{name}._init)

EMIC:ifdef usedFunction.LEDs_.{name}._blink
void LEDs_.{name}._poll (void);
EMIC:define(polls.LEDs_.{name}.,LEDs_.{name}._poll)
EMIC:endif
```

**Resultado en main.c generado:**
```c
#include "inc/led_StatusLED.h"    // ← expansión de .{main_includes.*}.

int main(void)
{
    initSystem();
    LEDs_StatusLED._init();       // ← expansión de .{inits.*}.

    while(1)
    {
        LEDs_StatusLED._poll();   // ← expansión de .{polls.*}.
    }
}
```

**Resultado en configurations.xml generado:**
```xml
<itemPath>led_StatusLED.c</itemPath>  <!-- expansión de .{c_modules.*}. -->
```

---

## Ejemplos:

_modules/Wired_Control/HRD_2Relays_USBController/System/generate.emic

```
EMIC:setOutput(TARGET:generate.txt)


//-------------- Hardware Config ---------------------
EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_USB V1.1)

//-- Process EMIC-Generate files result --
EMIC:setInput(SYS:usedFunction.emic)
EMIC:setInput(SYS:usedEvent.emic)

//------------------- APIs -----------------------
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led,pin=Led1)
EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)
EMIC:setInput(DEV:_api/Wired_Communication/USB/USB_API.emic,driver=MCP2200,port=1,BufferSize=512,baud=9600,frameLf=\n,name=MCP2200)
EMIC:setInput(DEV:_api/Wired_Communication/EMICBus/EMICBus.emic,port=2,frameID=0)
EMIC:setInput(DEV:_api/Actuators/Relay/relay.emic,name=ON,pin=RelayON)
EMIC:setInput(DEV:_api/Actuators/Relay/relay.emic,name=DIR,pin=RelayDIR)
//-------------------- main  -----------------------
EMIC:setInput(DEV:_main/baremetal/main.emic)

//-- Copy  EMIC-Generate files result ----------------
EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
EMIC:copy(SYS:userFncFile.c >TARGET:userFncFile.c)

//---- Set userFncFile.c as a copiler module ---------
EMIC:define(c_modules.userFncFile,userFncFile)

//-- Add all compiler modules to the project. --
EMIC:copy(DEV:_templates\projects\mplabx > TARGET:)

EMIC:restoreOutput
```


_api/Indicators/LEDs/led.emic

EMIC:tag(driverName = LEDs)

/**
* @fn void LEDs_.{name}._state(uint8_t state);
* @alias .{name}..state
* @brief Change the state of the led, 1-on, 0-off, 2-toggle. 
* @param state 1-on 0-off 2-toggle
* @return Nothing
*/


/**
* @fn void LEDs_.{name}._blink(uint16_t timeOn, uint16_t period, uint16_t times);
* @alias .{name}..blink
* @brief blink the .{name}. 
* @param timeOn time that the LED lasts on in each cycle.
* @param period length of time each cycle lasts.
* @param times number of cycles.
* @return Nothing
*/

/**
* @var uint8_t LEDs_.{name}._currentState = 0;
* @alias .{name}..status
* @brief Current state of the LED (0=off, 1=on, 2=blinking)
*/

EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)

EMIC:copy(inc/led.h > TARGET:inc/led_.{name}..h,name=.{name}.,pin=.{pin}.)

EMIC:copy(src/led.c > TARGET:led_.{name}..c,name=.{name}.,pin=.{pin}.)

EMIC:define(main_includes.led_.{name}.,led_.{name}.)
EMIC:define(c_modules.led_.{name}.,led_.{name}.)

### Ejemplo de una API con dependencia de driver específico

_api/Sensors/Temperature/temperature.emic

EMIC:tag(driverName = TEMPERATURE)

/**
* @fn float Temperature_.{name}._getValue(void);
* @alias getTemperature.{name}.
* @brief Get the current temperature value from sensor
* @return Temperature in Celsius degrees
*/

/**
* @fn void Temperature_.{name}._setThresholds(float min, float max);
* @alias setThreshold.{name}.
* @brief Set temperature alert thresholds
* @param min Minimum temperature threshold in Celsius
* @param max Maximum temperature threshold in Celsius
* @return Nothing
*/

/**
* @fn extern void Temperature_.{name}._onLowTemp(void);
* @alias tempLow.{name}.
* @brief Event triggered when temperature falls below minimum threshold
* @return Nothing
*/

/**
* @var float Temperature_.{name}._currentValue = 25.0;
* @alias .{name}..value
* @brief Current temperature reading in Celsius
*/

/**
* @var uint8_t Temperature_.{name}._unit = 0;
* @alias .{name}..unit
* @brief Temperature display unit (0=Celsius, 1=Fahrenheit, 2=Kelvin)
* @options TEMP_CELSIUS("°C"), TEMP_FAHRENHEIT("°F"), TEMP_KELVIN("K")
*/

// Importante: La API recibe el driver específico como parámetro y lo utiliza para incluir el código del sensor correspondiente
EMIC:setInput(ORIGIN:_drivers/Temperature/.{driver}./driver.emic)
EMIC:setInput(ORIGIN:_hal/ADC/adc.emic)

EMIC:copy(inc/temperature.h > TARGET:inc/temperature_.{name}..h,name=.{name}.,driver=.{driver}.)
EMIC:copy(src/temperature.c > TARGET:temperature_.{name}..c,name=.{name}.,driver=.{driver}.)

EMIC:define(main_includes.temperature_.{name}.,temperature_.{name}.)
EMIC:define(c_modules.temperature_.{name}.,temperature_.{name}.)