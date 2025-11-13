# Capítulo 15: Carpeta `_util/` - Utilidades del Sistema

## Índice
1. [Introducción](#introducción)
2. [¿Qué es `_util/`?](#qué-es-_util)
3. [Estructura de `_util/`](#estructura-de-_util)
4. [Comparadores Numéricos (`NumericalComparers/`)](#comparadores-numéricos)
5. [Operadores Matemáticos (`Opertors/`)](#operadores-matemáticos)
6. [Selectores (`Selectors/`)](#selectores)
7. [Manipulación de Strings (`Strings/`)](#manipulación-de-strings)
8. [Diferencia entre `_util/` y `_system/`](#diferencia-entre-_util-y-_system)
9. [Uso en EMIC-Editor](#uso-en-emic-editor)
10. [Buenas Prácticas](#buenas-prácticas)
11. [Resumen del Capítulo](#resumen-del-capítulo)

---

## Introducción

La carpeta **`_util/`** (Utilities) contiene **utilidades de alto nivel independientes del hardware** que facilitan la programación en EMIC-Editor. A diferencia de `_system/` que proporciona abstracciones del hardware, `_util/` ofrece funciones auxiliares para operaciones comunes como comparaciones, operadores matemáticos, control de flujo y manipulación de strings.

Estas utilidades están diseñadas para ser **completamente portables** y **agnósticas del hardware**, funcionando de la misma manera en cualquier microcontrolador soportado por EMIC SDK.

**Ubicación en el SDK:**
```
DEV:_util/
```

**Relación con otros componentes:**

```
Integrador (EMIC-Editor)
    ↓
┌─────────────────────────────────┐
│  _util/ (Utilidades Alto Nivel) │ ← Operadores, comparadores, strings
└─────────────────────────────────┘
    ↓
┌─────────────────────────────────┐
│  _system/ (Conversiones, I/O)   │
└─────────────────────────────────┘
    ↓
[APIs → Drivers → HAL → _hard → Hardware]
```

---

## ¿Qué es `_util/`?

**`_util/`** es una biblioteca de **funciones auxiliares de propósito general** que:

1. **Simplifica la programación visual en EMIC-Editor**
   - Bloques drag-and-drop para operaciones comunes
   - Sintaxis intuitiva para desarrolladores sin experiencia en C

2. **Proporciona abstracciones de alto nivel**
   - Comparadores numéricos (`(a == b)?`, `(a > b)?`)
   - Operadores matemáticos (`+`, `-`, `*`, `/`, `%`)
   - Estructuras de control (`if-else`, `switch-case`)
   - Manipulación de strings (`compare`, `length`, `toUpperCase`)

3. **Mantiene independencia del hardware**
   - No accede directamente a periféricos
   - Funciona igual en PIC24, dsPIC33, PIC32
   - Solo utiliza funciones estándar de C (`strcmp`, `strlen`, etc.)

4. **Genera código C optimizado**
   - Macros inline para operadores simples
   - Funciones en C para operaciones complejas
   - Sin overhead de llamadas a función para operaciones básicas

---

## Estructura de `_util/`

```
_util/
├── NumericalComparers/      # Comparadores numéricos y lógicos
│   ├── comparer.emic        # ==, >, <, !=, <=, >=, AND, OR
│   └── Module.xml
│
├── Opertors/                # Operadores matemáticos (typo intencional en SDK)
│   ├── Operators.h          # +, -, *, /, %
│   └── Module.xml
│
├── Selectors/               # Estructuras de control de flujo
│   ├── doIf.emic           # if-else
│   ├── xSele.emic          # switch-case
│   ├── order.emic          # compare ordenado (=, >, <)
│   └── Module.xml
│
└── Strings/                 # Manipulación de cadenas de texto
    ├── compare.emic         # Comparar strings
    ├── length.emic          # Longitud de string
    ├── toUpperCase.emic     # Convertir a mayúsculas
    ├── toLetterCase.emic    # Convertir case
    ├── clearBlankSpaces.emic # Eliminar espacios
    ├── index.emic           # Buscar posición
    ├── isContainedIn.emic   # Verificar si contiene
    ├── inc/                 # Headers (.h)
    ├── src/                 # Implementaciones (.c)
    └── Module.xml
```

**Categorías de utilidades:**

| Categoría | Propósito | Hardware? | Ejemplos |
|-----------|-----------|-----------|----------|
| **NumericalComparers** | Comparaciones numéricas | NO | `(a == b)?`, `(a > b)?` |
| **Opertors** | Operaciones aritméticas | NO | `a + b`, `a * b` |
| **Selectors** | Control de flujo | NO | `if-else`, `switch-case` |
| **Strings** | Manipulación de texto | NO | `compare`, `length`, `toUpperCase` |

---

## Comparadores Numéricos

### Ubicación
```
DEV:_util/NumericalComparers/comparer.emic
```

### Comparadores Disponibles

#### 1. `esIgualN` - Igualdad (`==`)

**Sintaxis en EMIC-Editor:**
```emic
(a ≙ b)
```

**JSON Metadata:**
```json
{
    "Nombre": "esIgualN",
    "NombreToolBox": "(•=•)?",
    "Tipo": "SistemFnc",
    "title": "Return 1 is Equal or 0 if not",
    "FunctionReturn": ["1","0"],
    "FunctioNParametros": "2"
}
```

**Código generado (C):**
```c
if (a == b) {
    // true
}
```

---

#### 2. `esMayorN` - Mayor que (`>`)

**Sintaxis en EMIC-Editor:**
```emic
(a > b)
```

**JSON Metadata:**
```json
{
    "Nombre": "esMayorN",
    "NombreToolBox": "(•>•)?",
    "Tipo": "SistemFnc",
    "title": "operator mayor",
    "FunctionReturn": ["1","0"],
    "FunctioNParametros": "2"
}
```

---

#### 3. `esMenorN` - Menor que (`<`)

**Sintaxis en EMIC-Editor:**
```emic
(a < b)
```

**JSON Metadata:**
```json
{
    "Nombre": "esMenorN",
    "NombreToolBox": "(•<•)?",
    "Tipo": "SistemFnc",
    "title": "operator menor",
    "FunctionReturn": ["1","0"],
    "FunctioNParametros": "2"
}
```

---

#### 4. `esNoIgualN` - Desigualdad (`!=`)

**Sintaxis en EMIC-Editor:**
```emic
(a ≠ b)
```

**JSON Metadata:**
```json
{
    "Nombre": "esNoIgualN",
    "NombreToolBox": "(•≠•)?",
    "Tipo": "SistemFnc",
    "title": "operator !=",
    "FunctionReturn": ["1","0"],
    "FunctioNParametros": "2"
}
```

---

#### 5. `esNoMayN` - Menor o igual (`<=`)

**Sintaxis en EMIC-Editor:**
```emic
(a ≤ b)
```

**JSON Metadata:**
```json
{
    "Nombre": "esNoMayN",
    "NombreToolBox": "(•≤•)?",
    "Tipo": "SistemFnc",
    "title": "operator ≤",
    "FunctionReturn": ["1","0"],
    "FunctioNParametros": "2"
}
```

---

#### 6. `esNoMenN` - Mayor o igual (`>=`)

**Sintaxis en EMIC-Editor:**
```emic
(a ≥ b)
```

**JSON Metadata:**
```json
{
    "Nombre": "esNoMenN",
    "NombreToolBox": "(•≥•)?",
    "Tipo": "SistemFnc",
    "title": "operator ≥",
    "FunctionReturn": ["1","0"],
    "FunctioNParametros": "2"
}
```

---

### Operadores Lógicos

#### 7. `_OR` - OR Lógico

**Sintaxis en EMIC-Editor:**
```emic
(condition1 OR condition2)
```

**JSON Metadata:**
```json
{
    "Nombre": "_OR",
    "NombreToolBox": "(• OR •)",
    "Tipo": "SistemFnc",
    "title": "operator OR",
    "FunctionReturn": ["1","0"],
    "FunctioNParametros": "2"
}
```

**Código generado (C):**
```c
if (condition1 || condition2) {
    // true
}
```

---

#### 8. `_AND` - AND Lógico

**Sintaxis en EMIC-Editor:**
```emic
(condition1 AND condition2)
```

**JSON Metadata:**
```json
{
    "Nombre": "_AND",
    "NombreToolBox": "(• AND •)",
    "Tipo": "SistemFnc",
    "title": "operator AND",
    "FunctionReturn": ["1","0"],
    "FunctioNParametros": "2"
}
```

**Código generado (C):**
```c
if (condition1 && condition2) {
    // true
}
```

---

### Ejemplo Práctico: Sistema de Alarmas

**Problema:** Activar alarma si temperatura > 50°C O presión > 1000 kPa

**Código en EMIC-Editor:**
```emic
// Leer sensores
temperatura = ADC.ReadChannel(0)
presion = ADC.ReadChannel(1)

// Evaluar condiciones
if ((temperatura > 50) OR (presion > 1000)) {
    GPIO.SetPin(Alarma, HIGH)
} else {
    GPIO.SetPin(Alarma, LOW)
}
```

**Código C generado:**
```c
// Leer sensores
temperatura = HAL_ADC_Read(0);
presion = HAL_ADC_Read(1);

// Evaluar condiciones
if ((temperatura > 50) || (presion > 1000)) {
    HAL_GPIO_PinSet(Alarma, 1);
} else {
    HAL_GPIO_PinSet(Alarma, 0);
}
```

---

## Operadores Matemáticos

### Ubicación
```
DEV:_util/Opertors/Operators.h
```

> **Nota:** El nombre "Opertors" es un typo intencional presente en el SDK real.

### Operadores Disponibles

#### 1. `_MAS` - Suma (`+`)

**Sintaxis en EMIC-Editor:**
```emic
(a + b)
```

**JSON Metadata:**
```json
{
    "Nombre": "_MAS",
    "NombreToolBox": "(• + •)",
    "Tipo": "SistemFnc",
    "title": "Return the sum of two numbers.",
    "parameters": [
        {"name": "A", "tooltip": "First number.", "type": ""},
        {"name": "B", "tooltip": "Second number.", "type": ""}
    ]
}
```

**Código generado (C):**
```c
result = a + b;
```

---

#### 2. `MENOS` - Resta (`-`)

**Sintaxis en EMIC-Editor:**
```emic
(a - b)
```

**JSON Metadata:**
```json
{
    "Nombre": "MENOS",
    "NombreToolBox": "(• - •)",
    "Tipo": "SistemFnc",
    "title": "Return the substraction of two numbers."
}
```

**Código generado (C):**
```c
result = a - b;
```

---

#### 3. `MULTIPLICACION` - Multiplicación (`*`)

**Sintaxis en EMIC-Editor:**
```emic
(a * b)
```

**JSON Metadata:**
```json
{
    "Nombre": "MULTIPLICACION",
    "NombreToolBox": "(• * •)",
    "Tipo": "SistemFnc",
    "title": "Return the multiplication of two numbers."
}
```

**Código generado (C):**
```c
result = a * b;
```

---

#### 4. `DIVISION` - División (`/`)

**Sintaxis en EMIC-Editor:**
```emic
(a / b)
```

**JSON Metadata:**
```json
{
    "Nombre": "DIVISION",
    "NombreToolBox": "(• / •)",
    "Tipo": "SistemFnc",
    "title": "Return the division of two numbers."
}
```

**Código generado (C):**
```c
result = a / b;
```

---

#### 5. `RESTO` - Módulo (`%`)

**Sintaxis en EMIC-Editor:**
```emic
(a % b)
```

**JSON Metadata:**
```json
{
    "Nombre": "RESTO",
    "NombreToolBox": "(• % •)",
    "Tipo": "SistemFnc",
    "title": "Return the integer rest of the division between two numbers."
}
```

**Código generado (C):**
```c
result = a % b;
```

---

### Ejemplo Práctico: Cálculo de Promedios

**Problema:** Calcular promedio de 4 lecturas de ADC

**Código en EMIC-Editor:**
```emic
// Leer 4 muestras
sample1 = ADC.ReadChannel(0)
sample2 = ADC.ReadChannel(0)
sample3 = ADC.ReadChannel(0)
sample4 = ADC.ReadChannel(0)

// Calcular suma
suma = (sample1 + sample2)
suma = (suma + sample3)
suma = (suma + sample4)

// Calcular promedio
promedio = (suma / 4)

// Enviar resultado
UART.Print("Promedio: ")
UART.PrintNumber(promedio)
```

**Código C generado:**
```c
// Leer 4 muestras
sample1 = HAL_ADC_Read(0);
sample2 = HAL_ADC_Read(0);
sample3 = HAL_ADC_Read(0);
sample4 = HAL_ADC_Read(0);

// Calcular suma
suma = sample1 + sample2;
suma = suma + sample3;
suma = suma + sample4;

// Calcular promedio
promedio = suma / 4;

// Enviar resultado
UART1_Print("Promedio: ");
UART1_PrintNumber(promedio);
```

---

## Selectores

### Ubicación
```
DEV:_util/Selectors/
```

Los **Selectors** implementan estructuras de control de flujo en EMIC-Editor.

---

### 1. `doIf` - Estructura If-Else

#### Sintaxis en EMIC-Editor
```emic
⟨if: condition
    [ do: block1 ]
    [ else: block2 ]
⟩
```

#### JSON Metadata
```json
{
    "Nombre": "doIf",
    "NombreToolBox": "if(?)do:[]",
    "Tipo": "SistemFnc",
    "title": "Execute the code depending on the condition"
}
```

#### Código generado (C)
```c
if (condition) {
    // block1
} else {
    // block2
}
```

#### Ejemplo: Control de LED según temperatura

**EMIC-Editor:**
```emic
temperatura = ADC.ReadChannel(0)

⟨if: (temperatura > 50)
    [ do: GPIO.SetPin(Led1, HIGH) ]
    [ else: GPIO.SetPin(Led1, LOW) ]
⟩
```

**Código C generado:**
```c
temperatura = HAL_ADC_Read(0);

if (temperatura > 50) {
    HAL_GPIO_PinSet(Led1, 1);
} else {
    HAL_GPIO_PinSet(Led1, 0);
}
```

---

### 2. `xSele` - Estructura Switch-Case

#### Sintaxis en EMIC-Editor
```emic
⟨Evaluate: variable
    [in case of: value1, do: block1]
    [in case of: value2, do: block2]
    [in case of: value3, do: block3]
⟩
```

#### JSON Metadata
```json
{
    "Nombre": "xSele",
    "NombreToolBox": "applyInCase",
    "Tipo": "SistemFnc",
    "title": "Execute the code depending on the value of the selector"
}
```

#### Código generado (C)
```c
switch(variable) {
    case value1:
        // block1
        break;
    case value2:
        // block2
        break;
    case value3:
        // block3
        break;
}
```

#### Ejemplo: Máquina de Estados

**EMIC-Editor:**
```emic
⟨Evaluate: estado
    [in case of: 0, do: {
        // Estado IDLE
        GPIO.SetPin(Led1, LOW)
        GPIO.SetPin(Led2, LOW)
    }]
    [in case of: 1, do: {
        // Estado WORKING
        GPIO.SetPin(Led1, HIGH)
        GPIO.SetPin(Led2, LOW)
    }]
    [in case of: 2, do: {
        // Estado ERROR
        GPIO.SetPin(Led1, LOW)
        GPIO.SetPin(Led2, HIGH)
    }]
⟩
```

**Código C generado:**
```c
switch(estado) {
    case 0:
        // Estado IDLE
        HAL_GPIO_PinSet(Led1, 0);
        HAL_GPIO_PinSet(Led2, 0);
        break;
    case 1:
        // Estado WORKING
        HAL_GPIO_PinSet(Led1, 1);
        HAL_GPIO_PinSet(Led2, 0);
        break;
    case 2:
        // Estado ERROR
        HAL_GPIO_PinSet(Led1, 0);
        HAL_GPIO_PinSet(Led2, 1);
        break;
}
```

---

### 3. `order` - Comparación Ordenada

#### Sintaxis en EMIC-Editor
```emic
⟨Compare: A Y B
    [if =, do: block1]
    [if >, do: block2]
    [if <, do: block3]
⟩
```

#### JSON Metadata
```json
{
    "Nombre": "CompareOrder",
    "NombreToolBox": "aplyInCase(=,>,<)",
    "Tipo": "SistemFnc",
    "title": "Execute the code depending on the comparison"
}
```

#### Código generado (C)
```c
int8_t comp_result = (A == B) ? 0 : ((A > B) ? 1 : -1);
switch(comp_result) {
    case 0:
        // block1 (iguales)
        break;
    case 1:
        // block2 (A mayor)
        break;
    case -1:
        // block3 (A menor)
        break;
}
```

#### Ejemplo: Comparar setpoint con medición

**EMIC-Editor:**
```emic
setpoint = 100
medicion = ADC.ReadChannel(0)

⟨Compare: medicion Y setpoint
    [if =, do: {
        // Igual - LED verde
        GPIO.SetPin(LedVerde, HIGH)
        GPIO.SetPin(LedRojo, LOW)
        GPIO.SetPin(LedAzul, LOW)
    }]
    [if >, do: {
        // Mayor - LED rojo (sobrecalentamiento)
        GPIO.SetPin(LedVerde, LOW)
        GPIO.SetPin(LedRojo, HIGH)
        GPIO.SetPin(LedAzul, LOW)
    }]
    [if <, do: {
        // Menor - LED azul (subcalentamiento)
        GPIO.SetPin(LedVerde, LOW)
        GPIO.SetPin(LedRojo, LOW)
        GPIO.SetPin(LedAzul, HIGH)
    }]
⟩
```

---

## Manipulación de Strings

### Ubicación
```
DEV:_util/Strings/
```

La carpeta **Strings** proporciona funciones para manipular cadenas de texto, útiles para parseo de comandos, telemetría, y comunicación con periféricos.

---

### 1. `compare` - Comparar Strings

#### Archivo EMIC
```
DEV:_util/Strings/compare.emic
```

#### JSON Metadata
```json
{
    "Nombre": "compare",
    "NombreToolBox": "compare",
    "Tipo": "SistemFnc",
    "title": "Return 0 if both string are equals, return 1 if the first string is greater than the second one, and return -1 in the opposite case.",
    "returnInfo": {"type":"int8_t","tooltip":"Position."},
    "parameters": [
        {"name": "First string", "type": "char*"},
        {"name": "Second string", "type": "char*"}
    ]
}
```

#### Sintaxis en EMIC-Editor
```emic
result = Text.Compare(string1, string2)
```

#### Implementación en C

**Header (`inc/compare.h`):**
```c
int8_t compare(char* string_1, char* string_2);
```

**Implementación (`src/compare.c`):**
```c
int8_t compare(char* string_1, char* string_2)
{
    int8_t result = strcmp(string_1, string_2);

    if (result > 0)
        return 1;
    else if (result == 0)
        return 0;
    else
        return -1;
}
```

#### Ejemplo: Parser de Comandos

**EMIC-Editor:**
```emic
// Leer comando desde UART
UART.ReadLine(buffer, 50)

// Comparar con comandos conocidos
if ((Text.Compare(buffer, "LED_ON") == 0)) {
    GPIO.SetPin(Led1, HIGH)
    UART.Print("OK: LED encendido\n")
}

if ((Text.Compare(buffer, "LED_OFF") == 0)) {
    GPIO.SetPin(Led1, LOW)
    UART.Print("OK: LED apagado\n")
}

if ((Text.Compare(buffer, "STATUS") == 0)) {
    UART.Print("Sistema funcionando\n")
}
```

**Código C generado:**
```c
// Leer comando desde UART
UART1_ReadLine(buffer, 50);

// Comparar con comandos conocidos
if (compare(buffer, "LED_ON") == 0) {
    HAL_GPIO_PinSet(Led1, 1);
    UART1_Print("OK: LED encendido\n");
}

if (compare(buffer, "LED_OFF") == 0) {
    HAL_GPIO_PinSet(Led1, 0);
    UART1_Print("OK: LED apagado\n");
}

if (compare(buffer, "STATUS") == 0) {
    UART1_Print("Sistema funcionando\n");
}
```

---

### 2. `length` - Longitud de String

#### Archivo EMIC
```
DEV:_util/Strings/length.emic
```

#### JSON Metadata
```json
{
    "Nombre": "length",
    "NombreToolBox": "length",
    "Tipo": "SistemFnc",
    "title": "Return the length of a text.",
    "returnInfo": {"type":"uint16_t","tooltip":"Length."},
    "parameters": [
        {"name": "Text", "type": "char*"}
    ]
}
```

#### Sintaxis en EMIC-Editor
```emic
len = Text.Length(myString)
```

#### Implementación EMIC
```emic
EMIC:copy(inc/length.h > TARGET:inc/length.h)
EMIC:copy(src/length.c > TARGET:src/length.c)
```

#### Ejemplo: Validar longitud de entrada

**EMIC-Editor:**
```emic
// Leer entrada del usuario
UART.ReadLine(input, 100)

// Validar longitud
len = Text.Length(input)

if ((len > 0) AND (len < 20)) {
    // Longitud válida - procesar
    UART.Print("Comando recibido: ")
    UART.Print(input)
} else {
    // Longitud inválida
    UART.Print("ERROR: Comando muy largo\n")
}
```

---

### 3. `toUpperCase` - Convertir a Mayúsculas

#### Archivo EMIC
```
DEV:_util/Strings/toUpperCase.emic
```

#### JSON Metadata
```json
{
    "Nombre": "toUpperCase",
    "NombreToolBox": "toUpperCase",
    "Tipo": "SistemFnc",
    "title": "Modifies the string and set all alphabetic characters in upper case.",
    "returnInfo": {"type":"void"},
    "parameters": [
        {"name": "string", "type": "char*"}
    ]
}
```

#### Sintaxis en EMIC-Editor
```emic
Text.toUpperCase(myString)
```

#### Implementación EMIC
```emic
EMIC:copy(inc/toLetterCase.h > TARGET:inc/toLetterCase.h)
EMIC:copy(src/toLetterCase.c > TARGET:src/toLetterCase.c)
```

#### Ejemplo: Normalizar comandos

**EMIC-Editor:**
```emic
// Leer comando
UART.ReadLine(comando, 50)

// Normalizar a mayúsculas (para comparación case-insensitive)
Text.toUpperCase(comando)

// Comparar
if ((Text.Compare(comando, "START") == 0)) {
    // Usuario escribió "start", "START", "Start", etc.
    InitSystem()
}
```

---

### Funciones Adicionales de Strings

#### 4. `clearBlankSpaces` - Eliminar Espacios

**Propósito:** Elimina espacios en blanco al inicio y final de un string.

**Uso típico:** Limpiar entrada del usuario antes de procesar.

---

#### 5. `index` - Buscar Posición

**Propósito:** Encuentra la posición de un carácter o substring dentro de un string.

**Retorno:** Índice de la primera ocurrencia, o -1 si no se encuentra.

---

#### 6. `isContainedIn` - Verificar Contención

**Propósito:** Verifica si un string está contenido dentro de otro.

**Retorno:** 1 si está contenido, 0 si no.

---

#### 7. `toLetterCase` - Convertir Case

**Propósito:** Convierte entre mayúsculas y minúsculas de manera configurable.

---

### Tabla Resumen de Funciones String

| Función | Entrada | Salida | Uso Típico |
|---------|---------|--------|------------|
| `compare` | `char* s1, char* s2` | `int8_t` (0, 1, -1) | Comparar comandos |
| `length` | `char* str` | `uint16_t` | Validar longitud |
| `toUpperCase` | `char* str` | `void` (modifica) | Normalizar entrada |
| `toLetterCase` | `char* str` | `void` (modifica) | Convertir case |
| `clearBlankSpaces` | `char* str` | `void` (modifica) | Limpiar entrada |
| `index` | `char* str, char c` | `int16_t` | Buscar carácter |
| `isContainedIn` | `char* str, char* sub` | `uint8_t` | Verificar substring |

---

## Diferencia entre `_util/` y `_system/`

Aunque ambas carpetas contienen **utilidades**, tienen propósitos y niveles de abstracción muy diferentes:

### Comparación

| Aspecto | `_system/` | `_util/` |
|---------|-----------|----------|
| **Nivel** | Bajo nivel (hardware I/O) | Alto nivel (lógica) |
| **Propósito** | Abstraer hardware de comunicación | Facilitar programación visual |
| **Dependencias** | Depende de HAL/Drivers | Independiente del hardware |
| **Contenido** | Streams, conversiones, I/O | Operadores, comparadores, strings |
| **Uso típico** | `streamIn_t`, `streamOut_t` | `if-else`, `+`, `-`, `compare` |
| **Portabilidad** | Portable (usa HAL) | Completamente portable (solo C estándar) |

### Diagrama de Capas

```
┌──────────────────────────────────────┐
│     Integrador (EMIC-Editor)         │
└──────────────────────────────────────┘
              ↓
┌──────────────────────────────────────┐
│  _util/ (Operadores, Comparadores)   │ ← Alto nivel, lógica pura
└──────────────────────────────────────┘
              ↓
┌──────────────────────────────────────┐
│  _system/ (Streams, Conversiones)    │ ← Bajo nivel, abstracciones I/O
└──────────────────────────────────────┘
              ↓
┌──────────────────────────────────────┐
│  _api/ (APIs hardware)               │
└──────────────────────────────────────┘
```

### Ejemplo de Uso Combinado

**Escenario:** Leer temperatura de UART, comparar con setpoint, y activar ventilador.

**Código EMIC-Editor:**
```emic
// Leer temperatura desde UART (usa _system/streamIn_t)
UART.ReadLine(buffer, 20)

// Convertir string a número (usa _system/conversionFunctions)
temperatura = ato_uint16_t(buffer)

// Comparar con setpoint (usa _util/NumericalComparers)
⟨if: (temperatura > 50)
    [ do: {
        // Activar ventilador
        GPIO.SetPin(Ventilador, HIGH)
    }]
    [ else: {
        // Apagar ventilador
        GPIO.SetPin(Ventilador, LOW)
    }]
⟩
```

**Flujo de capas:**
1. **UART.ReadLine** → usa `_system/streamIn_t` (abstracción I/O)
2. **ato_uint16_t** → usa `_system/conversionFunctions` (conversión de datos)
3. **(temperatura > 50)** → usa `_util/NumericalComparers` (comparador)
4. **if-else** → usa `_util/Selectors` (control de flujo)
5. **GPIO.SetPin** → usa `_api/` (API hardware)

---

## Uso en EMIC-Editor

Las utilidades de `_util/` están diseñadas para ser usadas en el **editor visual EMIC-Editor** mediante bloques drag-and-drop.

### Integración con EMIC-Editor

#### 1. Metadata JSON

Cada función en `_util/` incluye metadata JSON que define su apariencia en el editor:

```json
{
    "Nombre": "esIgualN",
    "NombreToolBox": "(•=•)?",
    "Tipo": "SistemFnc",
    "title": "Return 1 is Equal or 0 if not",
    "FunctionReturn": ["1","0"],
    "FunctioNParametros": "2",
    "InnerHTML": "..."
}
```

**Campos importantes:**
- `Nombre`: ID interno de la función
- `NombreToolBox`: Texto mostrado en la toolbox (usa símbolos Unicode)
- `Tipo`: Tipo de función (`SistemFnc`)
- `title`: Tooltip de ayuda
- `InnerHTML`: HTML del bloque visual

---

#### 2. Bloques Visuales

**Ejemplo: Comparador numérico**

HTML del bloque:
```html
<div type='statement'
     originalclass='comparator'
     operator='=='
     class='lineaDeCodigo'
     definir='useEsIgualNV1'
     originalid='esIgualN'
     draggable='true'>
    (<div type='' class='parametroDiv'></div> ≙ <div type='' class='parametroDiv'></div>)
</div>
```

**Resultado visual en editor:**
```
┌───────────────────────┐
│  (  [param1] ≙ [param2]  ) │
└───────────────────────┘
```

---

#### 3. Proceso de Uso

1. **Desarrollador arrastra bloque** desde toolbox
2. **Completa parámetros** (variables, constantes, otras expresiones)
3. **EMIC-Generate procesa** el bloque
4. **Genera código C** equivalente

**Ejemplo paso a paso:**

**Paso 1 - Arrastrar bloque "if":**
```
┌───────────────────────────┐
│  ⟨if: [condition]         │
│    [ do: [block1] ]       │
│    [ else: [block2] ]     │
│  ⟩                        │
└───────────────────────────┘
```

**Paso 2 - Completar condición:**
```
┌───────────────────────────┐
│  ⟨if: (temp > 50)         │
│    [ do: [block1] ]       │
│    [ else: [block2] ]     │
│  ⟩                        │
└───────────────────────────┘
```

**Paso 3 - Completar bloques:**
```
┌───────────────────────────┐
│  ⟨if: (temp > 50)         │
│    [ do:                  │
│       GPIO.SetPin(Led, 1) │
│    ]                      │
│    [ else:                │
│       GPIO.SetPin(Led, 0) │
│    ]                      │
│  ⟩                        │
└───────────────────────────┘
```

**Paso 4 - Código C generado:**
```c
if (temp > 50) {
    HAL_GPIO_PinSet(Led, 1);
} else {
    HAL_GPIO_PinSet(Led, 0);
}
```

---

### Ventajas de las Utilidades Visuales

1. **Accesibilidad**
   - No requiere conocimientos de sintaxis C
   - Bloques autoexplicativos con tooltips

2. **Prevención de errores**
   - Type checking visual
   - No hay errores de sintaxis (paréntesis, punto y coma)

3. **Rapidez de desarrollo**
   - Drag-and-drop más rápido que escribir
   - Autocompletado de parámetros

4. **Legibilidad**
   - Código visual más fácil de entender
   - Estructura clara con indentación automática

---

## Buenas Prácticas

### 1. Usar Utilidades en lugar de C Directo

**❌ Evitar:**
```c
// NO escribir C directamente en userFncFile.c
if (a == b) {
    // ...
}
```

**✅ Preferir:**
```emic
// Usar bloques de EMIC-Editor
⟨if: (a ≙ b)
    [ do: {...} ]
⟩
```

**Razón:** EMIC-Editor garantiza código correcto y mantenible.

---

### 2. Validar Entrada de Usuario

Cuando se trabaja con strings de comunicación:

**✅ Buena práctica:**
```emic
// Leer comando
UART.ReadLine(buffer, 50)

// Validar longitud
len = Text.Length(buffer)

⟨if: ((len > 0) AND (len < 20))
    [ do: {
        // Normalizar
        Text.toUpperCase(buffer)

        // Procesar comando
        ProcessCommand(buffer)
    }]
    [ else: {
        UART.Print("ERROR: Invalid command\n")
    }]
⟩
```

---

### 3. Normalizar Strings para Comparación

**✅ Buena práctica:**
```emic
// Leer comando
UART.ReadLine(comando, 50)

// Normalizar a mayúsculas
Text.toUpperCase(comando)

// Comparar (case-insensitive)
if ((Text.Compare(comando, "START") == 0)) {
    // Acepta: start, START, Start, sTaRt, etc.
    InitSystem()
}
```

---

### 4. Usar `xSele` para Múltiples Condiciones

**❌ Evitar:**
```emic
⟨if: (estado == 0)
    [ do: { HandleIdle() }]
⟩

⟨if: (estado == 1)
    [ do: { HandleWorking() }]
⟩

⟨if: (estado == 2)
    [ do: { HandleError() }]
⟩
```

**✅ Preferir:**
```emic
⟨Evaluate: estado
    [in case of: 0, do: { HandleIdle() }]
    [in case of: 1, do: { HandleWorking() }]
    [in case of: 2, do: { HandleError() }]
⟩
```

**Razón:** `switch` es más eficiente que múltiples `if` secuenciales.

---

### 5. Combinar Operadores Lógicos

**✅ Buena práctica:**
```emic
// Alarma si: (temp > 50 AND presion > 1000) OR (bateria < 10)

⟨if: (((temp > 50) AND (presion > 1000)) OR (bateria < 10))
    [ do: {
        GPIO.SetPin(Alarma, HIGH)
        UART.Print("ALARMA ACTIVADA\n")
    }]
⟩
```

---

### 6. Documentar Comparaciones Complejas

**✅ Buena práctica:**
```emic
// Verificar rango válido de temperatura (20-80°C)
validTemp = ((temp >= 20) AND (temp <= 80))

⟨if: validTemp
    [ do: {
        // Temperatura en rango
        ProcessTemperature(temp)
    }]
    [ else: {
        // Fuera de rango
        UART.Print("ERROR: Temp out of range\n")
    }]
⟩
```

---

### 7. Usar `order` para Comparaciones Tricotómicas

Cuando necesitas tres casos (mayor, igual, menor):

**✅ Buena práctica:**
```emic
setpoint = 100
medicion = ADC.ReadChannel(0)

⟨Compare: medicion Y setpoint
    [if =, do: {
        // Perfecto - mantener
        GPIO.SetPin(LedVerde, HIGH)
    }]
    [if >, do: {
        // Sobrepasado - reducir
        ReducePower()
        GPIO.SetPin(LedRojo, HIGH)
    }]
    [if <, do: {
        // Insuficiente - aumentar
        IncreasePower()
        GPIO.SetPin(LedAzul, HIGH)
    }]
⟩
```

---

## Resumen del Capítulo

### Puntos Clave

1. **`_util/` proporciona utilidades de alto nivel independientes del hardware**
   - Comparadores numéricos (==, >, <, !=, <=, >=)
   - Operadores matemáticos (+, -, *, /, %)
   - Estructuras de control (if-else, switch-case)
   - Manipulación de strings

2. **Diferencia con `_system/`**
   - `_system/`: Abstracciones de I/O hardware (streams, conversiones)
   - `_util/`: Operaciones lógicas puras (sin acceso a hardware)

3. **Diseñadas para EMIC-Editor**
   - Bloques visuales drag-and-drop
   - Metadata JSON define apariencia
   - Generan código C optimizado

4. **Completamente portables**
   - Funcionan igual en todos los MCU
   - Solo usan funciones estándar de C
   - No dependen de HAL/_hard

### Estructura Resumida

```
_util/
├── NumericalComparers/  → ==, >, <, !=, <=, >=, AND, OR
├── Opertors/            → +, -, *, /, %
├── Selectors/           → if-else, switch-case, compare-order
└── Strings/             → compare, length, toUpperCase, etc.
```

### Flujo de Uso

```
Integrador usa bloques visuales en EMIC-Editor
    ↓
EMIC-Generate procesa metadata JSON
    ↓
Genera código C con operadores/comparadores
    ↓
Compila con XC8/XC16/XC32
    ↓
Firmware ejecutable (.hex)
```

### Próximos Pasos

Has completado la **Sección 2: Estructura del SDK EMIC** (11/11 capítulos).

**Próxima sección:**
- **Sección 3: EMIC-Codify Language** (Capítulos 16-20)
  - Sintaxis del lenguaje EMIC
  - Macros y directivas
  - Sistema de módulos
  - Proceso de compilación

---

**Fin del Capítulo 15**

**Progreso del Manual:**
- **Sección 1 (Introducción):** ████████████████████ 100% (5/5)
- **Sección 2 (Estructura SDK):** ████████████████████ 100% (11/11) ✅ **COMPLETADA**

**Progreso Total: 15/38 capítulos (39.47%)**

---

**Referencias:**
- Capítulo 05: Visión General del SDK
- Capítulo 14: Carpeta `_system/`
- Capítulo 08: Carpeta `_drivers/`
- Capítulo 09: Carpeta `_hal/`
