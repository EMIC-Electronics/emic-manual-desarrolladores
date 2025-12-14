# Capítulo 19: Control de Flujo y Condicionales

## Tabla de Contenidos

1. [Introducción al Control de Flujo](#1-introducción-al-control-de-flujo)
2. [Comando ifndef/ifdef](#2-comando-ifndefifdef)
3. [Comando if/elif/else/endif](#3-comando-ifelifelseendif)
4. [Operadores de Comparación](#4-operadores-de-comparación)
5. [Generación Condicional de Código](#5-generación-condicional-de-código)
6. [Patrón de Abstracción Multi-MCU](#6-patrón-de-abstracción-multi-mcu)
7. [Caso Práctico: API con Protocolo Configurable](#7-caso-práctico-api-con-protocolo-configurable)
8. [Errores Comunes y Soluciones](#8-errores-comunes-y-soluciones)

---

## 1. Introducción al Control de Flujo

El control de flujo en EMIC-Codify permite generar código condicionalmente, adaptando el resultado según configuraciones, parámetros o la existencia de macros.

### 1.1 ¿Por qué es necesario?

```
┌─────────────────────────────────────────────────────────────────┐
│              GENERACIÓN CONDICIONAL DE CÓDIGO                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  PROBLEMA: Una API de comunicación que debe soportar            │
│  diferentes protocolos (EMIC Message vs TEXT Line)              │
│                                                                  │
│  SIN CONDICIONALES:                                              │
│  ───────────────────                                             │
│  rs232_emic.emic    → Solo protocolo EMIC                        │
│  rs232_text.emic    → Solo protocolo TEXT (código duplicado)     │
│                                                                  │
│  CON CONDICIONALES:                                              │
│  ──────────────────                                              │
│  rs232.emic         → Un solo archivo                            │
│    EMIC:if(protocolo == EMIC_message)                            │
│        // Funciones para EMIC                                    │
│    EMIC:endif                                                    │
│    EMIC:if(protocolo == TEXT_line)                               │
│        // Funciones para TEXT                                    │
│    EMIC:endif                                                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Comandos Disponibles

| Comando | Propósito | Ejemplo |
|---------|-----------|---------|
| `ifndef` | Ejecutar si macro NO existe | `EMIC:ifndef _API_EMIC` |
| `ifdef` | Ejecutar si macro existe | `EMIC:ifdef DEBUG_MODE` |
| `if` | Ejecutar si condición es verdadera | `EMIC:if(.{config.x}.==valor)` |
| `elif` | Condición alternativa | `EMIC:elif(.{config.x}.==otro)` |
| `else` | Bloque por defecto | `EMIC:else` |
| `endif` | Cerrar bloque condicional | `EMIC:endif` |

---

## 2. Comando ifndef/ifdef

Estos comandos verifican la **existencia** de una macro, no su valor.

### 2.1 Sintaxis

```
EMIC:ifndef macro_name
    // Se ejecuta si macro_name NO está definida
EMIC:endif

EMIC:ifdef macro_name
    // Se ejecuta si macro_name SÍ está definida
EMIC:endif
```

### 2.2 Uso Principal: Protección contra Inclusión Múltiple

El uso más común de `ifndef` es evitar que un archivo `.emic` se procese más de una vez:

```c
// systemTimer.emic
EMIC:ifndef _DRIVER_SYSTEM_TIMER_EMIC_
EMIC:define(_DRIVER_SYSTEM_TIMER_EMIC_, true)

// ... contenido del archivo ...

EMIC:setInput(DEV:_hal/Timer/timer.emic)

EMIC:setOutput(TARGET:inc/systemTimer.h)
    EMIC:setInput(inc/systemTimer.h)
EMIC:restoreOutput

EMIC:setOutput(TARGET:systemTimer.c)
    EMIC:setInput(src/systemTimer.c)
EMIC:restoreOutput

EMIC:define(main_includes.systemTimer, systemTimer)
EMIC:define(c_modules.systemTimer, systemTimer)

EMIC:endif
```

### 2.3 Patrón Estándar de Protección

```c
EMIC:ifndef _NOMBRE_UNICO_EMIC_
EMIC:define(_NOMBRE_UNICO_EMIC_, true)

// Todo el contenido del archivo aquí

EMIC:endif
```

**Convención de nombres:**
- Usar prefijo `_` y sufijo `_EMIC_` o `_EMIC`
- Nombre descriptivo en mayúsculas
- Ejemplos: `_RS232_API_EMIC`, `_PIC_UART1_EMIC`, `_BLUETOOTH_EMIC`

### 2.4 Ejemplos Reales del SDK

#### Driver I2C:
```c
// I2C_driver.emic
EMIC:ifndef I2C_DRIVER_EMIC_
EMIC:define(I2C_DRIVER_EMIC_, true)

EMIC:setInput(DEV:_hal/I2C/I2C.emic)
// ... resto del driver ...

EMIC:endif
```

#### API de ADC:
```c
// ADC.emic
EMIC:ifndef ADC_EMIC_
EMIC:define(ADC_EMIC_, true)

EMIC:tag(driverName = ADC)

/**
* @fn void start_ADC(uint8_t Freq, uint32_t Quantity);
* @alias StartADC
*/

// ... resto de la API ...

EMIC:endif
```

#### UART con parámetro en el nombre:
```c
// UARTX.emic (para PIC32MZ)
EMIC:ifndef _PIC_UART.{port}._EMIC
EMIC:define(_PIC_UART.{port}._EMIC, true)

// Permite múltiples instancias: UART1, UART2, etc.
// Cada una con su propia protección

EMIC:endif
```

### 2.5 ifdef para Funcionalidad Opcional

```c
// Habilitar callback de recepción solo si está definido
EMIC:define(UART.{port}._CALLBACK_RX, true)

// En otro archivo:
EMIC:ifdef UART1_CALLBACK_RX
    // Código para manejar callback de recepción
EMIC:endif
```

---

## 3. Comando if/elif/else/endif

El comando `if` evalúa **condiciones** basadas en valores de macros.

### 3.1 Sintaxis

```
EMIC:if(condición)
    // Código si condición es verdadera
EMIC:elif(otra_condición)
    // Código si otra_condición es verdadera
EMIC:else
    // Código por defecto
EMIC:endif
```

### 3.2 Ejemplo Básico

```c
EMIC:if(.{config.protocolo}.==EMIC_message)
    // Generar código para protocolo EMIC
EMIC:endif

EMIC:if(.{config.protocolo}.==TEXT_line)
    // Generar código para protocolo TEXT
EMIC:endif
```

### 3.3 Ejemplo Real: RS232 con Protocolo Configurable

Del archivo `_api/Wired_Communication/RS232_M/rs232.emic`:

```c
EMIC:tag(driverName = RS232)
EMIC:ifndef _RS232_API_EMIC
EMIC:define(_RS232_API_EMIC, true)

// Configurator para selección de protocolo
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

// Publicar funciones según protocolo seleccionado
EMIC:if(.{config.RS232prot}.=="EMIC_message")
/**
* @fn void pRS232(char* format,...);
* @alias Send_EMIC(concat tag, concat msg)
* @brief Send an EMIC message through the RS232 port
* @param tag Tag identifying the message
* @param msg Message content
*/

/**
* @fn extern void eRS232(char* tag, const streamIn_t* const msg);
* @alias Reception_EMIC
* @brief When receiving an EMIC message through RS232
* @param tag Tag to identify the message
* @param msg Message payload
*/
EMIC:endif

EMIC:if(.{config.RS232prot}.=="TEXT_line")
/**
* @fn variadic pRS232(char* format,...);
* @alias Send_TEXT(concat msg)
* @brief Send a text message through the RS232 port
* @param msg Message content
*/

/**
* @fn extern void eRS232(const streamIn_t* const msg);
* @alias Reception_TEXT
* @brief When receiving a string through RS232
* @param msg Message payload
*/
EMIC:endif

// ... resto del archivo ...
EMIC:endif
```

### 3.4 Condicionales dentro de Código C

Los comandos EMIC también funcionan dentro de archivos `.c` y `.h`:

```c
// rs232.c
void UART_RX_Callback(void) {
    frameFlag = 0;

    EMIC:if(.{config.RS232prot}.==EMIC_message)

    char tag[20];
    // Parsear mensaje EMIC
    parseEMICMessage(&streamIn_Uart.{port}., tag);
    eRS232(tag, &streamIn_Uart.{port}.);

    EMIC:endif

    EMIC:if(.{config.RS232prot}.==TEXT_line)

    // Enviar línea de texto directamente
    eRS232(&streamIn_Uart.{port}.);

    EMIC:endif
}
```

**Resultado según configuración:**

Si usuario selecciona "EMIC_message":
```c
void UART_RX_Callback(void) {
    frameFlag = 0;

    char tag[20];
    parseEMICMessage(&streamIn_Uart1, tag);
    eRS232(tag, &streamIn_Uart1);
}
```

Si usuario selecciona "TEXT_line":
```c
void UART_RX_Callback(void) {
    frameFlag = 0;

    eRS232(&streamIn_Uart1);
}
```

---

## 4. Operadores de Comparación

### 4.1 Operadores Disponibles

| Operador | Significado | Ejemplo |
|----------|-------------|---------|
| `==` | Igual a | `.{config.x}.==valor` |
| `!=` | Diferente de | `.{config.x}.!=valor` |

### 4.2 Comparación de Strings

Para comparar con strings que contienen espacios o caracteres especiales, usar comillas:

```c
// Sin comillas (valores simples)
EMIC:if(.{config.RS232prot}.==EMIC_message)

// Con comillas (recomendado para claridad)
EMIC:if(.{config.RS232prot}.=="EMIC_message")

// Con comillas (necesario si hay espacios)
EMIC:if(.{config.deviceName}.=="Mi Dispositivo")
```

### 4.3 Comparación con Parámetros Locales

```c
// Comparar parámetro pasado en setInput
EMIC:if(.{mode}.==debug)
    #define DEBUG_ENABLED 1
EMIC:endif

EMIC:if(.{mode}.==release)
    #define DEBUG_ENABLED 0
EMIC:endif
```

### 4.4 Comparación con Macros del Sistema

```c
// Comparar con información del sistema
EMIC:if(.{system.ucName}.==PIC32MZ2048EFM064)
    // Código específico para PIC32MZ
EMIC:endif

EMIC:if(.{system.ucName}.==PIC24FJ64GA004)
    // Código específico para PIC24
EMIC:endif
```

---

## 5. Generación Condicional de Código

### 5.1 Publicar Funciones Condicionalmente

```c
EMIC:tag(driverName = MiAPI)

// Función siempre disponible
/**
* @fn void MiAPI_init(void);
* @alias init
* @brief Initialize the API
*/

// Función solo si DEBUG está habilitado
EMIC:ifdef DEBUG_MODE
/**
* @fn void MiAPI_debug(char* msg);
* @alias debug
* @brief Print debug message
* @param msg Debug message to print
*/
EMIC:endif

// Función según configuración del usuario
EMIC:if(.{config.advancedFeatures}.==enabled)
/**
* @fn void MiAPI_advanced(void);
* @alias advanced
* @brief Advanced feature (only if enabled)
*/
EMIC:endif
```

### 5.2 Incluir Dependencias Condicionalmente

```c
// Siempre necesario
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)

// Solo si se usa comunicación
EMIC:ifdef USE_COMMUNICATION
EMIC:setInput(DEV:_hal/UART/UART.emic, port=1)
EMIC:endif

// Según tipo de display configurado
EMIC:if(.{config.displayType}.==LCD)
EMIC:setInput(DEV:_drivers/Display/LCD/lcd.emic)
EMIC:endif

EMIC:if(.{config.displayType}.==OLED)
EMIC:setInput(DEV:_drivers/Display/OLED/oled.emic)
EMIC:endif
```

### 5.3 Generar Código C Condicional

```c
// En el archivo .h
#ifndef MI_API_H
#define MI_API_H

void MiAPI_init(void);
void MiAPI_process(void);

EMIC:if(.{config.useCallbacks}.==true)
typedef void (*MiAPI_Callback)(uint8_t event);
void MiAPI_setCallback(MiAPI_Callback cb);
EMIC:endif

#endif
```

---

## 6. Patrón de Abstracción Multi-MCU

EMIC utiliza condicionales implícitos a través del sistema de volúmenes para soportar múltiples microcontroladores.

### 6.1 Arquitectura HAL

```
┌─────────────────────────────────────────────────────────────────┐
│                    ABSTRACCIÓN MULTI-MCU                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  _hal/UART/UART.emic (interfaz común)                           │
│         │                                                        │
│         ▼                                                        │
│  EMIC:setInput(DEV:_hard/.{system.ucName}./UART/UARTX.emic)     │
│         │                                                        │
│         ├──► _hard/PIC32MZ2048EFM064/UART/UARTX.emic            │
│         ├──► _hard/PIC24FJ64GA004/UART/UARTX.emic               │
│         └──► _hard/dsPIC33EP512MC806/UART/UARTX.emic            │
│                                                                  │
│  La macro .{system.ucName}. contiene el MCU seleccionado        │
│  El código correcto se incluye automáticamente                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 6.2 Archivo HAL (Interfaz)

```c
// _hal/UART/UART.emic
// Este archivo es la interfaz común

EMIC:setInput(DEV:_hard/.{system.ucName}./UART/UARTX.emic,
    port=.{port}.,
    BufferSize=.{BufferSize}.,
    baud=.{baud}.,
    driver=.{driver}.
)
```

### 6.3 Implementación Específica de MCU

```c
// _hard/PIC32MZ2048EFM064/UART/UARTX.emic
EMIC:ifndef _PIC_UART.{port}._EMIC
EMIC:define(_PIC_UART.{port}._EMIC, true)

EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_system/Stream/streamIn.emic)
EMIC:setInput(DEV:_system/Stream/streamOut.emic)

EMIC:setOutput(TARGET:inc/UART.{port}..h)
    EMIC:setInput(inc/UARTX.h, port=.{port}., BufferSize=.{BufferSize}., baud=.{baud}.)
EMIC:restoreOutput

EMIC:setOutput(TARGET:UART.{port}..c)
    EMIC:setInput(src/UARTX.c, port=.{port}., BufferSize=.{BufferSize}., baud=.{baud}.)
EMIC:restoreOutput

EMIC:define(c_modules.UART.{port}., UART.{port}.)
EMIC:endif
```

### 6.4 Ventajas del Patrón

1. **Código portable**: Las APIs usan el HAL, no acceden directamente al hardware
2. **Fácil agregar MCUs**: Solo crear nueva carpeta en `_hard/`
3. **Sin código condicional explícito**: El sistema resuelve automáticamente

---

## 7. Caso Práctico: API con Protocolo Configurable

Vamos a analizar paso a paso cómo funciona la API RS232 del SDK.

### 7.1 Estructura del Archivo

```c
// rs232.emic - Estructura completa

// 1. Identificación para EMIC Discovery
EMIC:tag(driverName = RS232)

// 2. Protección contra inclusión múltiple
EMIC:ifndef _RS232_API_EMIC
EMIC:define(_RS232_API_EMIC, true)

// 3. Configurar macro para callback del UART
EMIC:define(UART.{port}._CALLBACK_RX, true)

// 4. Configurator para que el usuario elija protocolo
EMIC:json(type = Configurator)
{
    "name": "RS232prot",
    "options": [
        {"legend": "EMIC message", "value": "EMIC_message"},
        {"legend": "TEXT line", "value": "TEXT_line"}
    ]
}

// 5. Funciones condicionales según protocolo
EMIC:if(.{config.RS232prot}.=="EMIC_message")
/**
* @fn void pRS232(char* format,...);
* @alias Send_EMIC(concat tag, concat msg)
*/

/**
* @fn extern void eRS232(char* tag, const streamIn_t* const msg);
* @alias Reception_EMIC
*/
EMIC:endif

EMIC:if(.{config.RS232prot}.=="TEXT_line")
/**
* @fn variadic pRS232(char* format,...);
* @alias Send_TEXT(concat msg)
*/

/**
* @fn extern void eRS232(const streamIn_t* const msg);
* @alias Reception_TEXT
*/
EMIC:endif

// 6. Dependencias
EMIC:setInput(DEV:_system/Stream/stream.emic)
EMIC:setInput(DEV:_system/Stream/streamOut.emic)
EMIC:setInput(DEV:_system/Stream/streamIn.emic)
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_hal/UART/UART.emic, port=.{port}., BufferSize=.{BufferSize}., baud=.{baud}.)

// 7. Generar archivos
EMIC:setOutput(TARGET:inc/rs232.h)
    EMIC:setInput(inc/rs232.h, port=.{port}., frameLf=.{frameLf}.)
EMIC:restoreOutput

EMIC:setOutput(TARGET:rs232.c)
    EMIC:setInput(src/rs232.c, port=.{port}., frameLf=.{frameLf}.)
EMIC:restoreOutput

// 8. Registrar para compilación
EMIC:define(main_includes.rs232, rs232)
EMIC:define(c_modules.rs232, rs232)

EMIC:endif
```

### 7.2 Flujo de Ejecución

```
Usuario en EMIC-Editor:
    1. Agrega API RS232 al proyecto
    2. Aparece Configurator "RS232prot"
    3. Selecciona "EMIC message"

EMIC Discovery:
    4. Procesa rs232.emic
    5. Evalúa EMIC:if(.{config.RS232prot}.=="EMIC_message") → TRUE
    6. Publica: Send_EMIC, Reception_EMIC
    7. Evalúa EMIC:if(.{config.RS232prot}.=="TEXT_line") → FALSE
    8. NO publica: Send_TEXT, Reception_TEXT

EMIC Generate:
    9. Genera rs232.h y rs232.c con código para EMIC_message
```

### 7.3 Resultado en EMIC-Editor

**Si usuario selecciona "EMIC message":**
- Bloques disponibles: `Send_EMIC(tag, msg)`, evento `Reception_EMIC`

**Si usuario selecciona "TEXT line":**
- Bloques disponibles: `Send_TEXT(msg)`, evento `Reception_TEXT`

---

## 8. Errores Comunes y Soluciones

### 8.1 endif Faltante

**Error:**
```
Error: Se esperaba EMIC:endif
```

**Causa:** Falta cerrar un bloque condicional.

**Solución:**
```c
// Incorrecto
EMIC:ifndef _API_EMIC
EMIC:define(_API_EMIC, true)
// ... código ...
// Falta EMIC:endif

// Correcto
EMIC:ifndef _API_EMIC
EMIC:define(_API_EMIC, true)
// ... código ...
EMIC:endif
```

### 8.2 Condición Siempre Falsa

**Error:** El código condicional nunca se genera.

**Causa:** El valor de la macro no coincide exactamente.

**Solución:**
```c
// Si el Configurator define value="EMIC_message"

// Incorrecto (sin comillas cuando el valor las tiene)
EMIC:if(.{config.RS232prot}.==EMIC_message)

// Correcto
EMIC:if(.{config.RS232prot}.=="EMIC_message")
```

### 8.3 Macro No Definida en Comparación

**Error:**
```
Error: No se encuentra 'config.miOpcion' en ninguna colección
```

**Causa:** El Configurator no está definido o tiene otro nombre.

**Solución:**
```c
// Verificar que el nombre en EMIC:json coincide
EMIC:json(type = Configurator)
{
    "name": "miOpcion",  // ← Este nombre
    ...
}

// Usar el mismo nombre en la condición
EMIC:if(.{config.miOpcion}.==valor)  // ← Debe coincidir
```

### 8.4 Protección Duplicada

**Error:** El archivo no se procesa la segunda vez (comportamiento esperado, pero puede confundir).

**Causa:** La protección `ifndef` funciona correctamente.

**Solución:** Esto es comportamiento normal. Si necesitas múltiples instancias, usa parámetros en el nombre de la macro:

```c
// Permite múltiples instancias
EMIC:ifndef _API_.{name}._EMIC
EMIC:define(_API_.{name}._EMIC, true)
// ...
EMIC:endif
```

### 8.5 Tabla de Referencia Rápida

| Problema | Síntoma | Solución |
|----------|---------|----------|
| endif faltante | Error de sintaxis | Verificar que cada if/ifndef tiene su endif |
| Condición siempre falsa | Código no se genera | Verificar comillas y valores exactos |
| Macro no encontrada | Error de macro | Verificar nombre del Configurator |
| Archivo no se procesa | Sin errores, sin salida | Verificar protección ifndef |
| Comparación incorrecta | Resultado inesperado | Usar `==` no `=` |

---

## Resumen

El control de flujo en EMIC-Codify permite:

1. **Proteger archivos** contra inclusión múltiple con `ifndef/endif`
2. **Generar código condicional** según configuración del usuario con `if/endif`
3. **Publicar funciones selectivamente** en EMIC Discovery
4. **Abstraer diferencias de hardware** mediante el patrón HAL + `system.ucName`
5. **Crear APIs configurables** con Configurators JSON

**Patrones más usados:**

```c
// Protección de archivo
EMIC:ifndef _MI_API_EMIC
EMIC:define(_MI_API_EMIC, true)
// contenido
EMIC:endif

// Código según configuración
EMIC:if(.{config.opcion}.=="valor")
// código condicional
EMIC:endif

// Abstracción de MCU (en HAL)
EMIC:setInput(DEV:_hard/.{system.ucName}./periferico/archivo.emic)
```

---

**Navegación:**
- [← Capítulo 18: Sistema de Macros y Sustitución](18_Sistema_Macros_Sustitucion.md)
- [→ Capítulo 20: Etiquetado de Recursos (Tags)](20_Etiquetado_Recursos_Tags.md)
