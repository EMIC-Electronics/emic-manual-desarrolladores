# Capítulo 20: Etiquetado de Recursos (Tags)

## Tabla de Contenidos

1. [Introducción al Sistema de Tags](#1-introducción-al-sistema-de-tags)
2. [Tag driverName](#2-tag-drivername)
3. [Tags DOXYGEN para Funciones](#3-tags-doxygen-para-funciones)
4. [Tags para Eventos (Callbacks)](#4-tags-para-eventos-callbacks)
5. [Tags para Variables](#5-tags-para-variables)
6. [Funciones Variádicas y Concat](#6-funciones-variádicas-y-concat)
7. [Configurators JSON](#7-configurators-json)
8. [Ejemplo Completo: API con Todos los Tags](#8-ejemplo-completo-api-con-todos-los-tags)
9. [Validación con EMIC Discovery](#9-validación-con-emic-discovery)
10. [Errores Comunes y Soluciones](#10-errores-comunes-y-soluciones)

---

## 1. Introducción al Sistema de Tags

Los **Tags** son etiquetas especiales que permiten **publicar recursos** (funciones, eventos, variables) para que sean visibles y utilizables en EMIC-Editor.

### 1.1 ¿Por qué son necesarios los Tags?

```
┌─────────────────────────────────────────────────────────────────┐
│                    PUBLICACIÓN DE RECURSOS                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  CÓDIGO C (sin tags):                                            │
│  ────────────────────                                            │
│  void LED_on(void);        → NO visible en EMIC-Editor           │
│  void LED_off(void);       → NO visible en EMIC-Editor           │
│                                                                  │
│  CÓDIGO C (con tags):                                            │
│  ────────────────────                                            │
│  /**                                                             │
│  * @fn void LED_on(void);                                        │
│  * @alias turnOn                                                 │
│  * @brief Turn on the LED                                        │
│  */                                                              │
│  void LED_on(void);        → VISIBLE como bloque "turnOn"        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Tipos de Recursos Publicables

| Tipo | Descripción | Cómo aparece en EMIC-Editor |
|------|-------------|----------------------------|
| **Función** | Acción ejecutable | Bloque de acción |
| **Evento** | Callback del sistema | Bloque de evento (disparador) |
| **Variable** | Dato accesible | Valor en expresiones |
| **Configurator** | Menú de opciones | Selector en configuración |

### 1.3 Flujo de Publicación

```
Archivo .emic          EMIC Discovery         EMIC-Editor
─────────────          ──────────────         ───────────

Tags DOXYGEN    →→→    Extrae recursos   →→→  Bloques visuales
@fn, @alias...         y metadatos            disponibles para
                                              el usuario
```

---

## 2. Tag driverName

El tag `driverName` agrupa todos los recursos de una API bajo un nombre común.

### 2.1 Sintaxis

```c
EMIC:tag(driverName = NombreDelGrupo)
```

### 2.2 Propósito

- Agrupa funciones, eventos y variables relacionados
- Define cómo aparecen en el árbol de EMIC-Editor
- Facilita la organización de recursos

### 2.3 Ejemplos Reales del SDK

```c
// led.emic
EMIC:tag(driverName = LEDs)
// Todos los recursos aparecerán bajo "LEDs" en el Editor

// timer_api.emic
EMIC:tag(driverName = TIMER)
// Recursos agrupados bajo "TIMER"

// rs232.emic
EMIC:tag(driverName = RS232)
// Recursos agrupados bajo "RS232"

// temperature.emic
EMIC:tag(driverName = TEMPERATURE)
// Recursos agrupados bajo "TEMPERATURE"
```

### 2.4 Resultado en EMIC-Editor

```
Árbol de Recursos:
├── LEDs
│   ├── status.state()
│   ├── status.blink()
│   └── error.state()
├── TIMER
│   ├── setTime1()
│   └── [evento] timeOut1
├── RS232
│   ├── Send_EMIC()
│   └── [evento] Reception_EMIC
└── TEMPERATURE
    ├── getTemperature()
    ├── setThreshold()
    └── [evento] tempHigh
```

---

## 3. Tags DOXYGEN para Funciones

Las funciones se publican usando comentarios en formato DOXYGEN.

### 3.1 Estructura Completa

```c
/**
* @fn tipo_retorno nombre_funcion(parametros);
* @alias NombreEnEditor
* @brief Descripción corta de la función
* @param param1 Descripción del parámetro 1
* @param param2 Descripción del parámetro 2
* @return Descripción del valor de retorno
*/
```

### 3.2 Tags Obligatorios vs Opcionales

| Tag | Obligatorio | Descripción |
|-----|-------------|-------------|
| `@fn` | ✅ Sí | Firma de la función en C |
| `@alias` | ✅ Sí | Nombre mostrado en EMIC-Editor |
| `@brief` | ⚠️ Recomendado | Descripción para el usuario |
| `@param` | ⚠️ Si hay parámetros | Documenta cada parámetro |
| `@return` | ⚠️ Recomendado | Describe el valor de retorno |

### 3.3 Ejemplos Reales del SDK

#### Función simple sin parámetros:
```c
/**
* @fn float getTemperature(void);
* @alias getTemperature
* @brief Get current temperature reading from sensor
* @return Temperature in Celsius degrees
*/
```

#### Función con un parámetro:
```c
/**
* @fn void calibrateSensor(float offset);
* @alias calibrate
* @brief Calibrate temperature sensor by adding an offset
* @param offset Calibration offset in Celsius
* @return Nothing
*/
```

#### Función con múltiples parámetros:
```c
/**
* @fn void setThreshold(float minTemp, float maxTemp);
* @alias setThreshold
* @brief Set temperature thresholds for triggering events
* @param minTemp Minimum temperature threshold in Celsius
* @param maxTemp Maximum temperature threshold in Celsius
* @return Nothing
*/
```

#### Función parametrizada con macros:
```c
/**
* @fn void LEDs_.{name}._state(uint8_t state);
* @alias .{name}..state
* @brief Change the state of the LED .{name}.
* @param state 1-on, 0-off, 2-toggle
* @return Nothing
*/
```
Con `name=status` genera:
- Función C: `LEDs_status_state()`
- Alias en Editor: `status.state`

#### Función con retorno:
```c
/**
* @fn uint8_t RelaySPI_getChannelState(uint8_t channel);
* @alias getRelayState
* @brief Get current mode of a specific relay channel
* @param channel Channel number (1-32)
* @return Channel mode: 0=Standby, 1=Input, 2=ON, 3=OFF
*/
```

---

## 4. Tags para Eventos (Callbacks)

Los eventos son funciones que el sistema llama cuando ocurre algo. Se identifican con `extern` en `@fn`.

### 4.1 Sintaxis

```c
/**
* @fn extern void nombreEvento(parametros);
* @alias NombreEnEditor
* @brief Descripción de cuándo se dispara
* @param param1 Información que recibe el evento
* @return Nothing
*/
```

### 4.2 Diferencia entre Función y Evento

| Aspecto | Función | Evento |
|---------|---------|--------|
| `@fn` | `void func()` | `extern void event()` |
| Quién llama | El usuario (desde bloques) | El sistema (automático) |
| En Editor | Bloque de acción | Bloque disparador |
| Implementación | En la API | El usuario define qué hacer |

### 4.3 Ejemplos Reales del SDK

#### Evento sin parámetros:
```c
/**
* @fn extern void tempLow(void);
* @alias tempLow
* @brief Event triggered when temperature falls below minimum threshold
* @return Nothing
*/
```

#### Evento con parámetro:
```c
/**
* @fn extern void eADC(int32_t Result);
* @alias DataReady
* @brief Dato del ADC listo
* @param Result Resultado de la conversión
* @return Nothing
*/
```

#### Evento con parámetro de texto:
```c
/**
* @fn extern void eRS232(char* tag, const streamIn_t* const msg);
* @alias Reception_EMIC
* @brief When receiving an EMIC message through RS232
* @param tag Tag to identify the message
* @param msg Message payload
* @return Nothing
*/
```

#### Evento parametrizado con macros:
```c
/**
* @fn extern void etOut.{name}.(void);
* @alias timeOut.{name}.
* @brief When timer .{name}. expires
* @return Nothing
*/
```
Con `name=1` genera evento `timeOut1`

### 4.4 Cómo se usan los Eventos

En EMIC-Editor, el usuario arrastra el bloque de evento y define qué acciones ejecutar:

```
┌─────────────────────────────────────────┐
│  [Evento] Reception_EMIC                │
│  ───────────────────────────────────────│
│  Cuando: Se recibe mensaje RS232        │
│  Parámetros: tag, msg                   │
│  ───────────────────────────────────────│
│  Acciones:                              │
│    → Mostrar tag en display             │
│    → Guardar msg en memoria             │
│    → Encender LED                       │
└─────────────────────────────────────────┘
```

---

## 5. Tags para Variables

Las variables permiten acceder a datos del sistema desde EMIC-Editor.

### 5.1 Sintaxis

```c
/**
* @var tipo nombre_variable = valor_inicial;
* @alias .nombreEnEditor
* @brief Descripción de la variable
*/
```

### 5.2 Ejemplos Reales del SDK

#### Variable numérica:
```c
/**
* @var float Temperature_currentValue = 25.0;
* @alias .value
* @brief Current temperature reading in Celsius
*/
```

#### Variable con opciones:
```c
/**
* @var uint8_t Temperature_unit = 0;
* @alias .unit
* @brief Temperature display unit (0=Celsius, 1=Fahrenheit, 2=Kelvin)
* @options TEMP_CELSIUS("°C"), TEMP_FAHRENHEIT("°F"), TEMP_KELVIN("K")
*/
```

### 5.3 Uso en EMIC-Editor

Las variables aparecen en expresiones y asignaciones:
- `TEMPERATURE.value` → Leer temperatura actual
- `TEMPERATURE.unit` → Obtener unidad configurada

---

## 6. Funciones Variádicas y Concat

Para funciones que concatenan múltiples valores de texto, se usa `concat` en los parámetros.

### 6.1 Sintaxis

```c
/**
* @fn void funcion(char* format, ...);
* @alias NombreEnEditor(concat param1, concat param2)
* @brief Descripción
* @param param1 Descripción
* @param param2 Descripción
* @return Nothing
*/
```

### 6.2 Palabra clave `variadic`

Para funciones variádicas que no usan el patrón estándar:

```c
/**
* @fn variadic pRS232(char* format, ...);
* @alias Send_TEXT(concat msg)
* @brief Send a text message
* @param msg Message content
* @return Nothing
*/
```

### 6.3 Ejemplos Reales del SDK

#### Envío de mensaje EMIC (dos parámetros concat):
```c
/**
* @fn void pRS232(char* format, ...);
* @alias Send_EMIC(concat tag, concat msg)
* @brief Send an EMIC message through RS232
* @param tag Tag identifying the message
* @param msg Message content
* @return Nothing
*/
```

En EMIC-Editor el usuario puede escribir:
- `Send_EMIC("TEMP", "25.5")`
- `Send_EMIC("STATUS", TEMPERATURE.value)`

#### Reporte formateado:
```c
/**
* @fn void printFormatted(char* format, ...);
* @alias TempReport(concat prefix, concat unit)
* @brief Print formatted temperature report
* @param prefix Text to add before temperature value
* @param unit Temperature unit to display (C, F, K)
* @return Nothing
*/
```

---

## 7. Configurators JSON

Los Configurators crean menús de opciones que el usuario puede seleccionar en EMIC-Editor.

### 7.1 Sintaxis

```c
EMIC:json(type = Configurator)
{
    "name": "nombreInterno",
    "brief": "Descripción del configurador",
    "legend": "Texto mostrado al usuario",
    "options": [
        {
            "legend": "Opción 1",
            "brief": "Descripción de opción 1",
            "value": "VALOR_1"
        },
        {
            "legend": "Opción 2",
            "brief": "Descripción de opción 2",
            "value": "VALOR_2"
        }
    ]
}
```

### 7.2 Campos del Configurator

| Campo | Obligatorio | Descripción |
|-------|-------------|-------------|
| `name` | ✅ Sí | Identificador interno (usado en `.{config.name}.`) |
| `brief` | ⚠️ Recomendado | Descripción general |
| `legend` | ✅ Sí | Texto mostrado al usuario |
| `options` | ✅ Sí | Array de opciones disponibles |
| `options[].legend` | ✅ Sí | Texto de la opción |
| `options[].brief` | ⚠️ Recomendado | Descripción de la opción |
| `options[].value` | ✅ Sí | Valor interno cuando se selecciona |

### 7.3 Ejemplos Reales del SDK

#### Selector de protocolo RS232:
```c
EMIC:json(type = Configurator)
{
    "name": "RS232prot",
    "brief": "RS232 Protocol",
    "legend": "Select RS232 Protocol",
    "options": [
        {
            "legend": "EMIC message",
            "brief": "Send and receive EMIC messages",
            "value": "EMIC_message"
        },
        {
            "legend": "TEXT line",
            "brief": "Send and receive lines of text",
            "value": "TEXT_line"
        }
    ]
}
```

#### Selector de velocidad de muestreo:
```c
EMIC:json(type = Configurator)
{
    "name": "TempSensor",
    "brief": "Temperature Sensor Configuration",
    "legend": "Select sensor sampling rate",
    "options": [
        {
            "legend": "Fast sampling (500ms)",
            "brief": "Updates temperature reading every 500ms",
            "value": "TEMP_FAST_SAMPLING"
        },
        {
            "legend": "Normal sampling (1s)",
            "brief": "Updates temperature reading every 1 second",
            "value": "TEMP_NORMAL_SAMPLING"
        },
        {
            "legend": "Power saving (5s)",
            "brief": "Updates temperature reading every 5 seconds",
            "value": "TEMP_POWER_SAVING"
        }
    ]
}
```

### 7.4 Usar el Valor del Configurator

```c
// Acceder al valor seleccionado
EMIC:if(.{config.RS232prot}.=="EMIC_message")
    // Código para protocolo EMIC
EMIC:endif

EMIC:if(.{config.TempSensor}.=="TEMP_FAST_SAMPLING")
    #define SAMPLE_INTERVAL_MS 500
EMIC:endif
```

---

## 8. Ejemplo Completo: API con Todos los Tags

Veamos una API completa que utiliza todos los tipos de tags.

### 8.1 API de Temperatura (temperature.emic)

```c
// 1. Agrupar recursos bajo "TEMPERATURE"
EMIC:tag(driverName = TEMPERATURE)

// 2. FUNCIONES
/**
* @fn float getTemperature(void);
* @alias getTemperature
* @brief Get current temperature reading from sensor
* @return Temperature in Celsius degrees
*/

/**
* @fn void setThreshold(float minTemp, float maxTemp);
* @alias setThreshold
* @brief Set temperature thresholds for triggering events
* @param minTemp Minimum temperature threshold in Celsius
* @param maxTemp Maximum temperature threshold in Celsius
* @return Nothing
*/

/**
* @fn void calibrateSensor(float offset);
* @alias calibrate
* @brief Calibrate temperature sensor by adding an offset
* @param offset Calibration offset in Celsius
* @return Nothing
*/

// 3. FUNCIÓN VARIÁDICA
/**
* @fn void printFormatted(char* format,...);
* @alias TempReport(concat prefix, concat unit)
* @brief Print formatted temperature report
* @param prefix Text to add before temperature value
* @param unit Temperature unit to display (C, F, K)
* @return Nothing
*/

// 4. EVENTOS
/**
* @fn extern void tempLow(void);
* @alias tempLow
* @brief Event triggered when temperature falls below minimum threshold
* @return Nothing
*/

/**
* @fn extern void tempHigh(void);
* @alias tempHigh
* @brief Event triggered when temperature rises above maximum threshold
* @return Nothing
*/

/**
* @fn extern void tempAlert(float value);
* @alias tempAlert
* @brief Event triggered on significant temperature change
* @param value The new temperature value
* @return Nothing
*/

// 5. VARIABLES
/**
* @var float Temperature_currentValue = 25.0;
* @alias .value
* @brief Current temperature reading in Celsius
*/

/**
* @var uint8_t Temperature_unit = 0;
* @alias .unit
* @brief Temperature display unit (0=Celsius, 1=Fahrenheit, 2=Kelvin)
* @options TEMP_CELSIUS("°C"), TEMP_FAHRENHEIT("°F"), TEMP_KELVIN("K")
*/

// 6. CONFIGURATOR
EMIC:json(type = Configurator)
{
    "name": "TempSensor",
    "brief": "Temperature Sensor Configuration",
    "legend": "Select sensor sampling rate",
    "options": [
        {
            "legend": "Fast sampling (500ms)",
            "brief": "Updates every 500ms",
            "value": "TEMP_FAST_SAMPLING"
        },
        {
            "legend": "Normal sampling (1s)",
            "brief": "Updates every 1 second",
            "value": "TEMP_NORMAL_SAMPLING"
        },
        {
            "legend": "Power saving (5s)",
            "brief": "Updates every 5 seconds",
            "value": "TEMP_POWER_SAVING"
        }
    ]
}

// 7. COMANDOS EMIC-CODIFY
EMIC:copy(inc/temperature.h > TARGET:inc/temperature.h, pin=.{pin}.)
EMIC:copy(src/temperature.c > TARGET:temperature.c, pin=.{pin}.)

EMIC:define(main_includes.temperature, temperature)
EMIC:define(c_modules.temperature, temperature)
```

### 8.2 Resultado en EMIC-Editor

```
TEMPERATURE
├── [Función] getTemperature() → float
├── [Función] setThreshold(minTemp, maxTemp)
├── [Función] calibrate(offset)
├── [Función] TempReport(prefix, unit)
├── [Evento] tempLow
├── [Evento] tempHigh
├── [Evento] tempAlert(value)
├── [Variable] .value (float)
├── [Variable] .unit (uint8_t)
└── [Configurator] TempSensor
    ├── Fast sampling (500ms)
    ├── Normal sampling (1s)
    └── Power saving (5s)
```

---

## 9. Validación con EMIC Discovery

EMIC Discovery es el proceso que extrae los tags y publica los recursos.

### 9.1 Qué Procesa Discovery

| Tipo de Archivo | Procesado | Tags Extraídos |
|-----------------|-----------|----------------|
| `.emic` | ✅ Sí | Todos |
| `.h` | ✅ Sí | @fn, @var |
| `.c` | ❌ No | - |
| `.json` | ❌ No | - |

### 9.2 Verificar Publicación

1. **En EMIC-Editor**: Abrir el árbol de recursos y buscar tu API
2. **Verificar funciones**: Deben aparecer como bloques arrastrables
3. **Verificar eventos**: Deben aparecer como disparadores
4. **Verificar configurators**: Deben aparecer en la configuración del módulo

### 9.3 Errores de Discovery

Si un recurso no aparece:

1. **Verificar sintaxis de tags**: El formato DOXYGEN debe ser exacto
2. **Verificar @fn**: La firma debe coincidir con la declaración real
3. **Verificar driverName**: Debe estar definido antes de los tags
4. **Verificar archivo .emic**: Debe estar en la ruta correcta del SDK

---

## 10. Errores Comunes y Soluciones

### 10.1 Función No Aparece en Editor

**Causa:** Falta `@fn` o sintaxis incorrecta.

```c
// Incorrecto (falta @fn)
/**
* @alias myFunction
* @brief Does something
*/

// Correcto
/**
* @fn void myFunction(void);
* @alias myFunction
* @brief Does something
*/
```

### 10.2 Evento No Se Reconoce

**Causa:** Falta `extern` en `@fn`.

```c
// Incorrecto (no es evento)
/**
* @fn void onDataReady(void);
*/

// Correcto (es evento)
/**
* @fn extern void onDataReady(void);
*/
```

### 10.3 Parámetros No Coinciden

**Causa:** `@fn` no coincide con la declaración real en el `.h`.

```c
// En .emic
/**
* @fn void setTemp(float temp);
*/

// En .h (DEBE coincidir)
void setTemp(float temp);  // ✅ Correcto
void setTemp(int temp);    // ❌ No coincide
```

### 10.4 Configurator No Aparece

**Causa:** JSON malformado o nombre duplicado.

```c
// Incorrecto (comillas simples en lugar de dobles)
EMIC:json(type = Configurator)
{
    'name': 'test'  // ❌ Usar comillas dobles
}

// Correcto
EMIC:json(type = Configurator)
{
    "name": "test"  // ✅
}
```

### 10.5 Tabla de Referencia Rápida

| Problema | Verificar | Solución |
|----------|-----------|----------|
| Función no aparece | `@fn` presente | Agregar firma completa |
| Evento no funciona | `extern` en `@fn` | Agregar `extern void` |
| Alias incorrecto | `@alias` | Verificar nombre |
| Sin descripción | `@brief` | Agregar descripción |
| Parámetro falta | `@param` | Documentar cada parámetro |
| Configurator invisible | JSON válido | Verificar comillas y estructura |
| No agrupado | `driverName` | Agregar `EMIC:tag(driverName=...)` |

---

## Resumen

El sistema de Tags permite publicar recursos del SDK:

| Recurso | Tag Principal | Identificador |
|---------|--------------|---------------|
| Función | `@fn tipo nombre()` | Sin `extern` |
| Evento | `@fn extern void nombre()` | Con `extern` |
| Variable | `@var tipo nombre` | `@var` |
| Configurator | `EMIC:json(type=Configurator)` | JSON |
| Agrupación | `EMIC:tag(driverName=X)` | Nombre del grupo |

**Estructura mínima de una función publicada:**
```c
EMIC:tag(driverName = MiAPI)

/**
* @fn void miFuncion(int param);
* @alias miFuncion
* @brief Descripción de la función
* @param param Descripción del parámetro
* @return Nothing
*/
```

---

**Navegación:**
- [← Capítulo 19: Control de Flujo y Condicionales](19_Control_Flujo_Condicionales.md)
- [→ Capítulo 21: Desarrollo de una API - Paso a Paso](../Seccion_4_Desarrollo/21_Desarrollo_API_Paso_a_Paso.md)
