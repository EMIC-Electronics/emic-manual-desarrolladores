# Capítulo 14: Carpeta `_system/` - Sistema Core EMIC

## Índice
1. [¿Qué es `_system/`?](#1-qué-es-_system)
2. [Estructura de la Carpeta](#2-estructura-de-la-carpeta)
3. [Sistema de Streams](#3-sistema-de-streams)
4. [Funciones de Conversión](#4-funciones-de-conversión)
5. [systemInclusions.emic](#5-systeminclusionsemic)
6. [Uso en APIs y Drivers](#6-uso-en-apis-y-drivers)
7. [Ejemplos Prácticos](#7-ejemplos-prácticos)
8. [Integración con el Código Generado](#8-integración-con-el-código-generado)
9. [Buenas Prácticas](#9-buenas-prácticas)
10. [Resumen](#10-resumen)

---

## 1. ¿Qué es `_system/`?

La carpeta `_system/` contiene **utilidades del sistema EMIC** que son usadas por todas las capas del SDK (APIs, Drivers, HAL). Provee funcionalidades fundamentales como **gestión de streams** y **conversiones de datos**.

### 1.1 Ubicación en la Arquitectura EMIC

```
┌─────────────────────────────────────────────────┐
│          Integrador (EMIC-Editor)                │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│     Módulos (_modules/)                         │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│          APIs (_api/)                           │
│          ↓ usa                                  │
│     System (_system/)      ← ESTE NIVEL         │
│     - Streams                                   │
│     - Conversiones                              │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│        Drivers (_drivers/)                      │
│          ↓ usa                                  │
│     System (_system/)                           │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│          HAL (_hal/)                            │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│        Hardware (_hard/)                        │
└─────────────────────────────────────────────────┘
```

### 1.2 Problema que Resuelve

**Sin `_system/`:**
```c
// Cada API/Driver reimplementa conversiones
void sendUartNumber(uint16_t num)
{
    char str[16];
    sprintf(str, "%u", num);  // Reimplementado en cada API
    UART_send(str);
}
```

**Con `_system/`:**
```c
// Función centralizada, reutilizable
#include "conversionFunctions.h"

void sendUartNumber(uint16_t num)
{
    char str[16];
    uint16_t_to_ascii(num, str, 16);  // Desde _system/
    UART_send(str);
}
```

### 1.3 Responsabilidades de `_system/`

| Responsabilidad | Descripción |
|----------------|-------------|
| **Gestión de Streams** | Abstracción de entrada/salida de datos |
| **Conversiones** | Números ↔ Strings (todas las variantes) |
| **Includes del sistema** | Headers comunes a todo el SDK |
| **Utilidades compartidas** | Funciones auxiliares reutilizables |

---

## 2. Estructura de la Carpeta

### 2.1 Organización de `_system/`

```
_system/
├── systemInclusions.emic        # Orquestador principal
├── Stream/                      # Sistema de streams
│   ├── stream.emic
│   ├── streamIn.emic            # Stream de entrada
│   ├── streamOut.emic           # Stream de salida
│   ├── inc/
│   │   ├── stream.h
│   │   ├── streamIn.h
│   │   └── streamOut.h
│   └── src/
│       ├── stream.c
│       └── streamIn.c
├── inc/                         # Headers del sistema
│   └── conversionFunctions.h   # Funciones de conversión
└── src/                         # Implementaciones
    └── conversionFunctions.c
```

### 2.2 Componentes Principales

| Componente | Propósito |
|-----------|-----------|
| **systemInclusions.emic** | Copia headers del sistema a TARGET: |
| **Stream/** | Sistema de abstracción de E/S |
| **conversionFunctions** | Conversiones entre tipos de datos |

---

## 3. Sistema de Streams

El sistema de streams proporciona una **abstracción unificada** para entrada/salida de datos, independiente del hardware subyacente (UART, USB, I2C, etc.).

### 3.1 ¿Qué es un Stream?

Un stream es una **interfaz genérica** para leer/escribir datos. Permite que el código de alto nivel no dependa del hardware específico.

**Concepto:**
```
┌─────────────────┐
│  Código Usuario │
│  printf("Hello")│
└────────┬────────┘
         ↓
    ┌────────┐
    │ Stream │ ← Abstracción
    └────┬───┘
         ↓
    ┌─────────────────────┐
    │ Hardware específico  │
    │ - UART              │
    │ - USB               │
    │ - Bluetooth         │
    │ - SD Card           │
    └─────────────────────┘
```

### 3.2 streamOut_t - Stream de Salida

**Archivo: `_system/Stream/inc/streamOut.h`**

```c
#ifndef _STREAMOUT_H_
#define _STREAMOUT_H_
#include <stdarg.h>
#include <xc.h>

typedef struct streamOut_S
{
    void (*put)(char);              // Función para escribir 1 char
    uint16_t (*getAvailable)(void); // Función para obtener espacio disponible

} streamOut_t;

void sendDataToStream(const streamOut_t*, char*, va_list);

#endif
```

**Explicación:**
- `put(char)`: Función que escribe un carácter (ej: `UART_putChar()`)
- `getAvailable()`: Función que retorna espacio disponible en buffer
- `sendDataToStream()`: Función helper para enviar datos formateados

---

### 3.3 streamIn_t - Stream de Entrada

**Archivo: `_system/Stream/inc/streamIn.h`**

```c
#ifndef _STREAMIN_H_
#define _STREAMIN_H_
#include <xc.h>
#include <stdarg.h>
#include "streamOut.h"

typedef struct streamIn_S
{
    char (*get)(void);           // Función para leer 1 char
    uint16_t (*count)(void);     // Función para obtener caracteres disponibles

} streamIn_t;

// Funciones de conversión desde stream a tipos de datos
float streamIn_t_ptr_to_float(streamIn_t*);
char streamIn_t_ptr_to_char(streamIn_t*);

uint8_t streamIn_t_ptr_to_uint8_t(streamIn_t*);
uint16_t streamIn_t_ptr_to_uint16_t(streamIn_t*);
uint32_t streamIn_t_ptr_to_uint32_t(streamIn_t*);
uint64_t streamIn_t_ptr_to_uint64_t(streamIn_t*);

int8_t streamIn_t_ptr_to_int8_t(streamIn_t*);
int16_t streamIn_t_ptr_to_int16_t(streamIn_t*);
int32_t streamIn_t_ptr_to_int32_t(streamIn_t*);
int64_t streamIn_t_ptr_to_int64_t(streamIn_t*);

void streamIn_t_ptr_to_ascii(streamIn_t*, char*, int);

#endif
```

**Explicación:**
- `get()`: Función que lee un carácter (ej: `UART_getChar()`)
- `count()`: Función que retorna cuántos caracteres hay disponibles
- `streamIn_t_ptr_to_*()`: Convierte datos del stream a tipos específicos

---

### 3.4 Ejemplo de Uso: UART como Stream

**Implementación de UART2 como streamOut:**

```c
// En _hard/pic24FJ64GA002/UART/src/UARTX.c

// Funciones específicas de UART2
char UART2_IN_pop(void)
{
    return UART2_pop(&UART2_IN_fifo);
}

uint16_t UART2_IN_count(void)
{
    return UART2_count(&UART2_IN_fifo);
}

void UART2_OUT_push(char d)
{
    UART2_push(&UART2_OUT_fifo, d);
}

uint16_t UART2_OUT_count(void)
{
    return UART2_count(&UART2_OUT_fifo);
}

// ========================================
// Crear streams de UART2
// ========================================
const streamIn_t streamIn_Uart2 = {
    .get = UART2_IN_pop,
    .count = UART2_IN_count
};

const streamOut_t streamOut_Uart2 = {
    .put = UART2_OUT_push,
    .getAvailable = UART2_OUT_count
};
```

**Uso del stream en código de usuario:**

```c
#include "streamIn.h"
#include "streamOut.h"

// Leer un número desde UART2
uint16_t readNumber()
{
    return streamIn_t_ptr_to_uint16_t(&streamIn_Uart2);
}

// Enviar un carácter a UART2
void sendChar(char c)
{
    streamOut_Uart2.put(c);
}

// Enviar un string a UART2
void sendString(char* str)
{
    while(*str)
    {
        streamOut_Uart2.put(*str);
        str++;
    }
}
```

---

### 3.5 Ventajas del Sistema de Streams

| Ventaja | Descripción |
|---------|-------------|
| **Portabilidad** | Cambiar de UART a USB solo requiere cambiar el stream |
| **Abstracción** | El código de usuario no conoce el hardware |
| **Reutilización** | Mismas funciones para cualquier interfaz |
| **Testabilidad** | Fácil crear mocks para testing |

**Ejemplo de portabilidad:**

```c
// ANTES: Código atado a UART
void sendNumber(uint16_t num)
{
    char str[16];
    uint16_t_to_ascii(num, str, 16);
    UART2_send(str);  // ← Específico de UART
}

// DESPUÉS: Código genérico con stream
void sendNumber(const streamOut_t* stream, uint16_t num)
{
    char str[16];
    uint16_t_to_ascii(num, str, 16);
    for(int i = 0; str[i]; i++)
    {
        stream->put(str[i]);  // ← Funciona con UART, USB, BT, etc.
    }
}

// Uso:
sendNumber(&streamOut_Uart2, 1234);   // Por UART2
sendNumber(&streamOut_USB, 1234);     // Por USB
sendNumber(&streamOut_Bluetooth, 1234); // Por Bluetooth
```

---

## 4. Funciones de Conversión

Las funciones de conversión permiten transformar entre **números** y **strings** en todas las variantes de tipos de datos.

### 4.1 Conversiones Número → String

**Archivo: `_system/inc/conversionFunctions.h`** (extracto)

```c
#ifndef __CONVERSIONFUNCTIONS_H__
#define __CONVERSIONFUNCTIONS_H__

#include <xc.h>
#include <stdio.h>
#include <stdlib.h>

// ========================================
// Macros para conversión a ASCII (strings)
// ========================================
#define float_to_ascii(string, number, n)     snprintf(string, n, "%1.2f", (double)number)
#define double_to_ascii(string, number, n)    snprintf(string, n, "%1.2f", number)

#define uint8_t_to_ascii(number, string, n)   snprintf(string, n, "%hu", number)
#define uint16_t_to_ascii(number, string, n)  snprintf(string, n, "%u", number)
#define uint32_t_to_ascii(number, string, n)  snprintf(string, n, "%lu", number)
#define uint64_t_to_ascii(number, string, n)  snprintf(string, n, "%llu", number)

#define int8_t_to_ascii(number, string, n)    snprintf(string, n, "%hd", number)
#define int16_t_to_ascii(number, string, n)   snprintf(string, n, "%d", number)
#define int32_t_to_ascii(number, string, n)   snprintf(string, n, "%ld", number)
#define int64_t_to_ascii(number, string, n)   snprintf(string, n, "%lld", number)

#endif
```

**Ejemplo de uso:**

```c
#include "conversionFunctions.h"

void example_number_to_string()
{
    char str[32];

    // Float a string
    float temperature = 23.45;
    float_to_ascii(str, temperature, 32);
    // str = "23.45"

    // uint16_t a string
    uint16_t counter = 1234;
    uint16_t_to_ascii(counter, str, 32);
    // str = "1234"

    // int32_t a string
    int32_t position = -5678;
    int32_t_to_ascii(position, str, 32);
    // str = "-5678"
}
```

---

### 4.2 Conversiones String → Número

**Archivo: `_system/inc/conversionFunctions.h`** (extracto)

```c
// ========================================
// Macros para conversión desde ASCII (strings)
// ========================================
#define ato_float(number)       (float)atof(number)
#define ato_double(number)      atof(number)

#define ato_uint8_t(string)     (uint8_t)atoi(string)
#define ato_uint16_t(string)    (uint16_t)atoi(string)
#define ato_uint32_t(string)    (uint32_t)atol(string)
#define ato_uint64_t(string)    (uint64_t)atoll(string)

#define ato_int8_t(string)      (int8_t)atoi(string)
#define ato_int16_t(string)     atoi(string)
#define ato_int32_t(string)     atol(string)
#define ato_int64_t(string)     atoll(string)
```

**Ejemplo de uso:**

```c
#include "conversionFunctions.h"

void example_string_to_number()
{
    // String a float
    char temp_str[] = "23.45";
    float temperature = ato_float(temp_str);
    // temperature = 23.45

    // String a uint16_t
    char count_str[] = "1234";
    uint16_t counter = ato_uint16_t(count_str);
    // counter = 1234

    // String a int32_t
    char pos_str[] = "-5678";
    int32_t position = ato_int32_t(pos_str);
    // position = -5678
}
```

---

### 4.3 Tabla de Todas las Conversiones Disponibles

| Tipo de Dato | Número → String | String → Número |
|--------------|-----------------|-----------------|
| **float** | `float_to_ascii(str, num, n)` | `ato_float(str)` |
| **double** | `double_to_ascii(str, num, n)` | `ato_double(str)` |
| **uint8_t** | `uint8_t_to_ascii(num, str, n)` | `ato_uint8_t(str)` |
| **uint16_t** | `uint16_t_to_ascii(num, str, n)` | `ato_uint16_t(str)` |
| **uint32_t** | `uint32_t_to_ascii(num, str, n)` | `ato_uint32_t(str)` |
| **uint64_t** | `uint64_t_to_ascii(num, str, n)` | `ato_uint64_t(str)` |
| **int8_t** | `int8_t_to_ascii(num, str, n)` | `ato_int8_t(str)` |
| **int16_t** | `int16_t_to_ascii(num, str, n)` | `ato_int16_t(str)` |
| **int32_t** | `int32_t_to_ascii(num, str, n)` | `ato_int32_t(str)` |
| **int64_t** | `int64_t_to_ascii(num, str, n)` | `ato_int64_t(str)` |

---

## 5. systemInclusions.emic

Este archivo es el **orquestador** que copia los headers del sistema a la carpeta TARGET durante el proceso EMIC-Generate.

### 5.1 Contenido de systemInclusions.emic

**Archivo: `_system/systemInclusions.emic`**

```emic
EMIC:ifndef SYSTEM_INCLUSIONS_EMIC
EMIC:define(SYSTEM_INCLUSIONS_EMIC, true)

// ========================================
// Copiar header de conversiones a TARGET
// ========================================
EMIC:setOutput(TARGET:inc/conversionFunctions.h)
    EMIC:setInput(inc/conversionFunctions.h)
EMIC:restoreOutput

// ========================================
// Copiar implementación (comentado por defecto)
// ========================================
//EMIC:setOutput(TARGET:conversionFunctions.c)
    //EMIC:setInput(src/conversionFunctions.c)
//EMIC:restoreOutput

//EMIC:define(c_modules.conversionFunctions, conversionFunctions.c)

EMIC:endif
```

**Explicación:**
- Copia `conversionFunctions.h` a `TARGET:inc/`
- La implementación (`.c`) está comentada porque las conversiones son **macros inline**
- Uso de `EMIC:ifndef` para evitar inclusiones duplicadas

---

## 6. Uso en APIs y Drivers

Veamos cómo `_system/` es usado por componentes de alto nivel.

### 6.1 Uso en API RS232

**Archivo: `_api/Wired_Communication/RS232/src/rs232.c`** (ejemplo conceptual)

```c
#include "inc/streamOut.h"
#include "inc/streamIn.h"
#include "inc/conversionFunctions.h"

// Stream de UART2
extern const streamOut_t streamOut_Uart2;
extern const streamIn_t streamIn_Uart2;

// ========================================
// Enviar número por RS232
// ========================================
void RS232_sendNumber(uint16_t num)
{
    char str[16];
    uint16_t_to_ascii(num, str, 16);  // ← Desde _system/

    // Enviar carácter por carácter
    for(int i = 0; str[i]; i++)
    {
        streamOut_Uart2.put(str[i]);  // ← Usando stream
    }
}

// ========================================
// Leer número desde RS232
// ========================================
uint16_t RS232_readNumber()
{
    return streamIn_t_ptr_to_uint16_t(&streamIn_Uart2);  // ← Desde _system/
}
```

---

### 6.2 Uso en Driver I2C

**Archivo: `_drivers/I2C_driver/src/I2C_driver.c`** (ejemplo conceptual)

```c
#include "inc/conversionFunctions.h"

// ========================================
// Enviar datos I2C con logging
// ========================================
void I2C_sendWithLog(uint8_t address, uint8_t data)
{
    char str[32];

    // Convertir dirección a string para log
    uint8_t_to_ascii(address, str, 32);  // ← Desde _system/
    Send_Debug("I2C Addr: ");
    Send_Debug(str);

    // Convertir dato a string para log
    uint8_t_to_ascii(data, str, 32);  // ← Desde _system/
    Send_Debug(" Data: ");
    Send_Debug(str);

    // Enviar por I2C
    I2C_write(address, data);
}
```

---

## 7. Ejemplos Prácticos

### 7.1 Ejemplo: Sistema de Telemetría

```c
#include "streamOut.h"
#include "conversionFunctions.h"

// Stream de UART (telemetría)
extern const streamOut_t streamOut_Telemetry;

void sendTelemetry(float temperature, uint16_t humidity, int32_t pressure)
{
    char str[32];

    // Enviar temperatura
    streamOut_Telemetry.put('T');
    streamOut_Telemetry.put(':');
    float_to_ascii(str, temperature, 32);
    for(int i = 0; str[i]; i++) streamOut_Telemetry.put(str[i]);
    streamOut_Telemetry.put('\n');

    // Enviar humedad
    streamOut_Telemetry.put('H');
    streamOut_Telemetry.put(':');
    uint16_t_to_ascii(humidity, str, 32);
    for(int i = 0; str[i]; i++) streamOut_Telemetry.put(str[i]);
    streamOut_Telemetry.put('\n');

    // Enviar presión
    streamOut_Telemetry.put('P');
    streamOut_Telemetry.put(':');
    int32_t_to_ascii(pressure, str, 32);
    for(int i = 0; str[i]; i++) streamOut_Telemetry.put(str[i]);
    streamOut_Telemetry.put('\n');
}

// Salida ejemplo:
// T:23.45
// H:65
// P:101325
```

---

### 7.2 Ejemplo: Parser de Comandos

```c
#include "streamIn.h"
#include "conversionFunctions.h"

// Stream de UART (comandos)
extern const streamIn_t streamIn_Commands;

void parseCommand()
{
    char cmd[16];
    streamIn_t_ptr_to_ascii(&streamIn_Commands, cmd, 16);

    if(strcmp(cmd, "SET") == 0)
    {
        // Leer parámetro numérico
        uint16_t value = streamIn_t_ptr_to_uint16_t(&streamIn_Commands);
        setParameter(value);
    }
    else if(strcmp(cmd, "GET") == 0)
    {
        // Obtener valor y enviarlo
        uint16_t value = getParameter();
        sendNumber(value);
    }
}

// Entrada ejemplo: "SET 1234"
// Entrada ejemplo: "GET"
```

---

## 8. Integración con el Código Generado

### 8.1 Inclusión Automática en generate.emic

```emic
EMIC:setOutput(TARGET:generate.txt)

    //-------------- Hardware Config ---------------------
    EMIC:setInput(DEV:_pcb/pcb.emic, pcb=HRD_D-I4-I_V1.0)

    //------------------- System Inclusions ----------------
    EMIC:setInput(DEV:_system/systemInclusions.emic)
    // ↑ Copia conversionFunctions.h a TARGET:inc/

    //------------------- APIs -----------------------
    EMIC:setInput(DEV:_api/Wired_Communication/RS232/rs232.emic, port=2)
    // ↑ Esta API usa streamOut y conversionFunctions

    //-------------------- main  -----------------------
    EMIC:setInput(DEV:_main/baremetal/main.emic)

    //------------------- Templates ----------------
    EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

### 8.2 Resultado en TARGET:

```
TARGET:/
├── main.c
├── rs232_2.c                # Usa streamOut y conversionFunctions
├── inc/
│   ├── conversionFunctions.h  # ← Copiado desde _system/
│   ├── streamOut.h            # ← Copiado desde _system/Stream/
│   ├── streamIn.h             # ← Copiado desde _system/Stream/
│   └── rs232_2.h
└── ...
```

---

## 9. Buenas Prácticas

### 9.1 Uso de Conversiones

✅ **HACER:**
```c
// Usar funciones de _system/
char str[16];
uint16_t_to_ascii(counter, str, 16);
```

❌ **EVITAR:**
```c
// Reimplementar conversiones
char str[16];
sprintf(str, "%u", counter);  // Más pesado, menos eficiente
```

### 9.2 Uso de Streams

✅ **HACER:**
```c
// Código genérico con stream
void sendData(const streamOut_t* stream, uint16_t data)
{
    char str[16];
    uint16_t_to_ascii(data, str, 16);
    for(int i = 0; str[i]; i++)
        stream->put(str[i]);
}
```

❌ **EVITAR:**
```c
// Código atado al hardware
void sendData(uint16_t data)
{
    char str[16];
    uint16_t_to_ascii(data, str, 16);
    UART2_send(str);  // ← No reutilizable
}
```

### 9.3 Tamaño de Buffers

✅ **HACER:**
```c
// Buffer suficiente para el tipo de dato
char str[16];  // uint16_t: máximo 5 dígitos + '\0'
uint16_t_to_ascii(num, str, 16);
```

❌ **EVITAR:**
```c
// Buffer muy pequeño (overflow risk)
char str[4];  // ← Peligro!
uint32_t_to_ascii(num, str, 4);  // Puede desbordar
```

**Tamaños recomendados:**

| Tipo | Rango | Dígitos Max | Buffer Recomendado |
|------|-------|-------------|-------------------|
| uint8_t | 0-255 | 3 | 8 bytes |
| uint16_t | 0-65535 | 5 | 16 bytes |
| uint32_t | 0-4294967295 | 10 | 16 bytes |
| int16_t | -32768 a 32767 | 6 (con signo) | 16 bytes |
| float | variable | ~10 | 32 bytes |

---

## 10. Resumen

| Concepto | Descripción |
|----------|-------------|
| **_system/** | Utilidades del sistema EMIC (streams, conversiones) |
| **streamOut_t** | Stream de salida genérico (UART, USB, etc.) |
| **streamIn_t** | Stream de entrada genérico |
| **conversionFunctions** | Conversiones número ↔ string (10 tipos) |
| **systemInclusions.emic** | Orquestador que copia headers a TARGET: |
| **Portabilidad** | Cambiar hardware sin cambiar código de usuario |
| **Reutilización** | APIs/Drivers usan las mismas utilidades |

---

## Próximos Pasos

En el **Capítulo 15** (¡último de la Sección 2!) exploraremos la carpeta **`_util/`**, donde se encuentran utilidades independientes que no encajan en otras categorías del SDK.

---

**¿Preguntas?**
El sistema de `_system/` es la **columna vertebral** del SDK EMIC. Streams y conversiones son usados por prácticamente todas las APIs y Drivers, proporcionando una base sólida y consistente para todo el código generado.
