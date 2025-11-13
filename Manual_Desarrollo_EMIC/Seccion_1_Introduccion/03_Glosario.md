# Capítulo 03: Glosario y Vocabulario EMIC

[← Anterior: Arquitectura](02_Arquitectura.md) | [Siguiente: Ventajas →](04_Ventajas.md)

---

## 📋 Contenido del Capítulo

Este glosario proporciona definiciones precisas de todos los términos técnicos utilizados en el ecosistema EMIC. Está organizado alfabéticamente con referencias cruzadas para facilitar la navegación.

---

## 🔤 Índice Alfabético

[**A**](#a) | [**B**](#b) | [**C**](#c) | [**D**](#d) | [**E**](#e) | [**F**](#f) | [**G**](#g) | [**H**](#h) | [**I**](#i) | [**L**](#l) | [**M**](#m) | [**P**](#p) | [**R**](#r) | [**S**](#s) | [**T**](#t) | [**U**](#u) | [**V**](#v) | [**X**](#x)

---

## A

### Abstracción

**Definición:** Proceso de ocultar detalles de implementación de bajo nivel para exponer solo la funcionalidad esencial.

**Contexto en EMIC:** El sistema de capas (_util → _api → _drivers → _hal → _hard) proporciona abstracción progresiva, donde cada capa oculta la complejidad de las inferiores.

**Ejemplo:**
```c
// Alto nivel (API) - Abstracción
LED_blink(1000);

// Bajo nivel (registros) - Detalle oculto
PORTA = 0x01;
__delay_ms(500);
PORTA = 0x00;
```

**Ver también:** [API](#api), [HAL](#hal), [Driver](#driver)

---

### Alias

**Definición:** Nombre alternativo simplificado que se asigna a una función o recurso para su uso en el EMIC-Editor.

**Contexto en EMIC:** Definido en el tag `@alias` de las funciones publicadas. El alias es el nombre que verá el integrador en el toolbox del editor.

**Ejemplo:**
```c
/**
 * @fn void LED_state(uint8_t state);
 * @alias led.state           ← Alias
 * @brief Change LED state
 */
```

**Uso:** El integrador ve `led.state` en lugar de `LED_state` en el editor visual.

**Ver también:** [Tag](#tag), [EMIC-Editor](#emic-editor)

---

### API

**Definición:** Application Programming Interface. En EMIC, conjunto de funciones de alto nivel que abstraen funcionalidad compleja en operaciones simples.

**Ubicación:** `DEV:_api/{Category}/{APIName}/`

**Características:**
- Alto nivel de abstracción
- Independiente de hardware específico
- Reutilizable en múltiples proyectos
- Documentada con Tags DOXYGEN

**Estructura típica:**
```
_api/Indicators/LEDs/
├── led.emic          ← Script EMIC
├── inc/
│   └── led.h        ← Headers
└── src/
    └── led.c        ← Implementación
```

**Ejemplo de API:** LED, Timer, Sensor, Display, Motor

**Diferencia con Driver:**
- API: Alto nivel, lógica de negocio
- Driver: Bajo nivel, control de hardware

**Ver también:** [Driver](#driver), [EMIC-Library](#emic-library)

---

## B

### Baremetal

**Definición:** Programación directa sobre hardware sin sistema operativo.

**Contexto en EMIC:** Los firmwares generados son típicamente baremetal, ejecutándose directamente sobre el microcontrolador sin RTOS.

**Ubicación:** `DEV:_main/baremetal/main.emic`

**Características:**
- Loop principal infinito
- Gestión manual de recursos
- Control total del hardware
- Máximo performance

**Ver también:** [RTOS](#rtos), [Main](#main)

---

## C

### Callback

**Definición:** Función que se ejecuta en respuesta a un evento específico.

**Contexto en EMIC:** Los eventos publicados como `extern` en las EMIC-Libraries se convierten en callbacks para el código del integrador.

**Ejemplo:**
```c
// En driver (publicado)
/**
 * @fn extern void onTimeout(void);
 * @alias timer.onTimeout
 * @brief Called when timer expires
 */

// Integrador define
void onTimeout(void) {
    LED_toggle();
}
```

**Ver también:** [Evento](#evento), [ISR](#isr)

---

### Compilador XC

**Definición:** Suite de compiladores de Microchip para microcontroladores PIC (uno de los compiladores soportados por EMIC).

**Variantes:**
- **XC8:** PIC10/12/16/18
- **XC16:** PIC24, dsPIC30/33
- **XC32:** PIC32

**Contexto en EMIC:** EMIC Generate produce código C que se compila con el compilador apropiado para la plataforma objetivo (XC8/XC16/XC32 para PIC, GCC ARM para Cortex-M, AVR-GCC para AVR, etc.) en la fase EMIC Compiler.

**Ver también:** [EMIC Compiler](#emic-compiler)

---

### Configurator

**Definición:** Recurso especial tipo JSON que presenta menús interactivos de configuración al integrador durante EMIC Discovery.

**Sintaxis:**
```
EMIC:json(type = Configurator)
{
    'name': 'protocolType',
    'brief': 'Communication Protocol',
    'legend': 'Select protocol',
    'options': [
        {'legend': 'UART', 'value': 'UART'},
        {'legend': 'I2C', 'value': 'I2C'}
    ]
}
```

**Uso:** Permite al integrador elegir opciones de configuración antes de la generación.

**Ver también:** [EMIC Discovery](#emic-discovery), [Tag JSON](#tag-json)

---

## D

### Dependencia

**Definición:** Relación donde un componente requiere otro componente para funcionar correctamente.

**Contexto en EMIC:** Las dependencias se declaran en archivos `.emic` usando comandos `EMIC:setInput()`.

**Ejemplo:**
```
// LED API depende de:
EMIC:setInput(DEV:_hal/GPIO/gpio.emic)
EMIC:setInput(DEV:_drivers/SystemTimer/systemTimer.emic)
```

**Gestión:** El sistema EMIC resuelve dependencias automáticamente durante la generación.

**Ver también:** [EMIC Generate](#emic-generate), [setInput](#setinput)

---

### Desarrollador

**Definición:** Usuario EMIC con conocimientos profundos de programación en C y sistemas embebidos que crea recursos reutilizables (APIs, Drivers, Módulos).

**Rol:**
- Escribe código de bajo nivel
- Etiqueta recursos con Tags
- Crea EMIC-Libraries
- Monetiza por uso masivo

**Diferencia con Integrador:**
- Desarrollador: Crea componentes
- Integrador: Usa componentes

**Ver también:** [Integrador](#integrador), [EMIC-Library](#emic-library)

---

### DEV:

**Definición:** Volumen lógico que apunta al EMIC SDK completo.

**Ubicación física:** Directorio raíz del SDK (ej: `C:\EMIC_SDK\`)

**Contenido:**
```
DEV:
├── _api/
├── _drivers/
├── _hal/
├── _hard/
├── _main/
├── _modules/
├── _pcb/
├── _system/
├── _templates/
└── _util/
```

**Uso:**
```
EMIC:setInput(DEV:_api/LEDs/led.emic)
```

**Ver también:** [Volumen Lógico](#volumen-lógico), [TARGET:](#target), [SYS:](#sys)

---

### Discovery

Ver [EMIC Discovery](#emic-discovery)

---

### Driver

**Definición:** Componente de software que controla un periférico o dispositivo de hardware específico.

**Ubicación:** `DEV:_drivers/{DriverName}/`

**Nivel:** Más bajo que API, más alto que HAL

**Características:**
- Control directo de hardware
- Gestión de protocolos
- Manejo de interrupciones

**Estructura:**
```
_drivers/I2C/
├── i2c.emic
├── inc/
│   └── i2c.h
└── src/
    └── i2c.c
```

**Ejemplos:** I2C, UART, SPI, USB, ADC, Display

**Diferencia con API:**
- Driver: Bajo nivel, hardware específico
- API: Alto nivel, lógica de negocio

**Ver también:** [API](#api), [HAL](#hal)

---

### DOXYGEN

**Definición:** Sistema de documentación estándar para código C/C++.

**Contexto en EMIC:** Se usa formato DOXYGEN para etiquetar funciones y variables que serán publicadas en EMIC Discovery.

**Tags DOXYGEN usados en EMIC:**
- `@fn` - Firma de función
- `@alias` - Nombre en editor
- `@brief` - Descripción breve
- `@param` - Parámetro
- `@return` - Valor de retorno

**Ejemplo:**
```c
/**
 * @fn void LED_blink(uint16_t period);
 * @alias led.blink
 * @brief Blink LED with specified period
 * @param period Time in milliseconds
 * @return Nothing
 */
```

**Ver también:** [Tag](#tag), [Etiquetado](#etiquetado)

---

## E

### EMIC

**Definición:** Electrónica Modular Inteligente Colaborativa. Framework low-code para desarrollo de sistemas embebidos IoT/IIoT.

**Componentes principales:**
- EMIC SDK
- EMIC-Editor
- EMIC Discovery
- EMIC Generate
- EMIC Compiler

**Filosofía:**
- Modularidad
- Colaboración
- Reutilización
- Estandarización

**Ver también:** [EMIC SDK](#emic-sdk)

---

### EMIC-Codify

**Definición:** Lenguaje especializado para gestión y generación de código dentro del ecosistema EMIC.

**Propósito:**
- Manipular archivos de texto
- Sustituir macros
- Controlar flujo de generación
- Copiar y transformar código

**Comandos principales:**
- `EMIC:setInput()`
- `EMIC:setOutput()`
- `EMIC:copy()`
- `EMIC:define()`
- `EMIC:if()`
- `EMIC:foreach()`

**Ejemplo:**
```
EMIC:define(ledPin, RA0)
EMIC:copy(DEV:led.c > TARGET:led.c, pin=.{ledPin}.)
```

**Ver también:** [Comando EMIC](#comando-emic), [Macro](#macro)

---

### EMIC Compiler

**Definición:** Cuarto proceso del sistema EMIC que compila el código C generado usando XC8/XC16/XC32.

**Input:** Código C en `TARGET:`

**Output:** Firmware `.hex`

**Proceso:**
1. Lee código C generado
2. Invoca compilador XC
3. Aplica optimizaciones
4. Genera archivo .hex

**Ver también:** [EMIC Generate](#emic-generate), [Compilador XC](#compilador-xc)

---

### EMIC Discovery

**Definición:** Primer proceso del sistema EMIC que analiza EMIC-Libraries y extrae recursos etiquetados para publicarlos en el Editor.

**Input:** EMIC-Libraries con Tags

**Output:** Catálogo de recursos

**Proceso:**
1. Lee archivos del SDK
2. Busca Tags DOXYGEN y JSON
3. Extrae metadata
4. Indexa recursos
5. Publica en EMIC-Editor

**¿Cuándo ocurre?**
- Al crear/actualizar módulo
- Al sincronizar SDK
- Bajo demanda

**Ver también:** [Tag](#tag), [EMIC-Editor](#emic-editor)

---

### EMIC-Editor

**Definición:** Segundo proceso del sistema EMIC. Interfaz visual donde integradores crean la lógica de aplicación mediante drag & drop.

**Características:**
- Canvas visual
- Toolbox con recursos
- Configuración de parámetros
- Preview de código

**Input:** Catálogo de recursos (de Discovery)

**Output:** Script en formato intermedio

**Usuario:** Integrador

**Ver también:** [Integrador](#integrador), [Script](#script)

---

### EMIC Generate

**Definición:** Tercer proceso del sistema EMIC que fusiona el Script del integrador con las EMIC-Libraries del desarrollador para generar código C compilable.

**Input:**
- Script del integrador
- EMIC-Libraries del desarrollador

**Output:** Código C en `TARGET:`

**Motor:** EMIC-Codify Engine

**Proceso:**
1. Lee `generate.emic`
2. Interpreta comandos EMIC-Codify
3. Fusiona código
4. Sustituye macros
5. Genera archivos en TARGET:

**Ver también:** [EMIC-Codify](#emic-codify), [generate.emic](#generateemic)

---

### EMIC-Library

**Definición:** Archivo de código C con anotaciones EMIC-Codify y Tags DOXYGEN que lo hacen procesable por el sistema EMIC.

**Características:**
- Código C estándar
- Tags para publicación
- Comandos EMIC-Codify
- Documentación integrada

**Diferencia con código C normal:**
- C normal: Solo compilable
- EMIC-Library: Compilable + Procesable + Autodocumentado

**Ejemplo:**
```c
EMIC:tag(driverName = LEDs)

/**
 * @fn void LED_state(uint8_t state);
 * @alias led.state
 * @brief Change LED state
 */
void LED_state(uint8_t state) {
    // Implementación
}
```

**Ver también:** [Tag](#tag), [EMIC-Codify](#emic-codify)

---

### EMIC-Module

**Definición:** Unidad completa de Hardware + Firmware + Configuración lista para usar.

**Estructura:**
```
Module/
├── System/
│   ├── generate.emic
│   ├── deploy.emic
│   ├── config.json
│   ├── module.json
│   └── program.xml
└── Target/
    └── (código generado)
```

**Componentes:**
- Hardware: PCB + componentes
- Firmware: APIs + Drivers utilizados
- Configuración: Parámetros específicos

**Ver también:** [Módulo](#módulo)

---

### EMIC SDK

**Definición:** Software Development Kit completo que contiene todos los componentes reutilizables del ecosistema EMIC.

**Anteriormente:** "Repositorio EMIC" (término legacy)

**Estructura:**
```
EMIC_SDK/
├── _api/          ← APIs alto nivel
├── _drivers/      ← Drivers hardware
├── _hal/          ← HAL
├── _hard/         ← Código específico MCU
├── _main/         ← Main files
├── _modules/      ← Módulos completos
├── _pcb/          ← Configs hardware
├── _system/       ← Sistema core
├── _templates/    ← Templates
└── _util/         ← Utilidades
```

**Ver también:** [DEV:](#dev)

---

### Etiquetado

**Definición:** Proceso de agregar Tags a funciones y variables para que sean reconocidas por EMIC Discovery.

**Formatos:**
1. **DOXYGEN:** Para funciones y eventos
2. **JSON:** Para recursos especiales

**Ejemplo DOXYGEN:**
```c
/**
 * @fn void myFunction(void);
 * @alias my.function
 * @brief Description
 */
```

**Ejemplo JSON:**
```
EMIC:json(type = Configurator)
{ ... }
```

**Ver también:** [Tag](#tag), [DOXYGEN](#doxygen)

---

### Evento

**Definición:** Callback que se ejecuta en respuesta a una condición o interrupción del hardware.

**Etiquetado:** Usando `extern` en el tag `@fn`

**Ejemplo:**
```c
/**
 * @fn extern void onTimeout(void);
 * @alias timer.timeout
 * @brief Called when timer expires
 */
```

**Implementación:** El integrador define la función en su código de usuario.

**Ver también:** [Callback](#callback), [ISR](#isr)

---

## F

### Firmware

**Definición:** Software que se ejecuta directamente sobre el hardware del microcontrolador.

**En EMIC:** Resultado final del proceso de compilación (archivo `.hex`).

**Formato:** Intel HEX o binario, listo para programar en MCU.

**Ver también:** [EMIC Compiler](#emic-compiler)

---

## G

### generate.emic

**Definición:** Archivo script principal de un módulo EMIC que define el proceso de generación de código.

**Ubicación:** `Module/System/generate.emic`

**Contenido típico:**
```
EMIC:setOutput(TARGET:generate.txt)

// Configuración hardware
EMIC:setInput(DEV:_pcb/pcb.emic,pcb=...)

// Cargar APIs
EMIC:setInput(DEV:_api/.../api.emic,...)

// Generar main
EMIC:setInput(DEV:_main/baremetal/main.emic)

// Copiar archivos usuario
EMIC:copy(SYS:userFile.c > TARGET:userFile.c)
```

**Función:** Orquesta todo el proceso de generación de código.

**Ver también:** [EMIC Generate](#emic-generate), [EMIC-Codify](#emic-codify)

---

### Grupo (de macros)

**Definición:** Conjunto de macros relacionadas bajo un mismo nombre de grupo.

**Grupos predefinidos:**
- `local` - Parámetros del comando actual
- `global` - Macros definidas globalmente

**Sintaxis:**
```
EMIC:define(group.key, value)
```

**Acceso:**
```
.{group.key}.
```

**Ver también:** [Macro](#macro), [define](#define)

---

## H

### HAL

**Definición:** Hardware Abstraction Layer. Capa de abstracción que proporciona interfaz unificada para periféricos del microcontrolador.

**Ubicación:** `DEV:_hal/`

**Propósito:**
- Abstraer hardware específico
- Permitir portabilidad entre MCUs
- Interfaz común

**Componentes típicos:**
- GPIO (pines digitales)
- ADC (conversión A/D)
- UART (comunicación serial)
- I2C, SPI (buses)
- Timer, PWM

**Relación:**
```
Driver → usa HAL → usa _hard → accede Hardware
```

**Ver también:** [_hard](#_hard), [Driver](#driver)

---

### _hard

**Definición:** Carpeta del SDK que contiene código específico de cada familia de microcontroladores.

**Ubicación:** `DEV:_hard/`

**Contenido:**
- Configuración de registros
- Acceso directo a hardware
- Código dependiente de MCU

**Organización:**
```
_hard/
├── PIC16F/
├── PIC18F/
├── PIC24F/
└── dsPIC33/
```

**Ver también:** [HAL](#hal)

---

## I

### Integrador

**Definición:** Usuario EMIC que utiliza componentes creados por desarrolladores para crear soluciones específicas.

**Rol:**
- Usa EMIC-Editor (visual)
- Combina APIs y Módulos
- Crea lógica de aplicación
- Monetiza por proyecto

**Conocimientos:**
- Menor nivel técnico que desarrollador
- Conoce el problema del cliente
- Enfocado en soluciones

**Diferencia con Desarrollador:**
- Integrador: Usa componentes
- Desarrollador: Crea componentes

**Ver también:** [Desarrollador](#desarrollador), [EMIC-Editor](#emic-editor)

---

### ISR

**Definición:** Interrupt Service Routine. Función que se ejecuta al ocurrir una interrupción de hardware.

**Contexto en EMIC:** Las ISR se implementan en la capa `_hard` o drivers, y generan eventos para el código de usuario.

**Flujo:**
```
[Interrupción Hardware]
        ↓
[ISR en _hard]
        ↓
[Driver procesa]
        ↓
[Genera Evento EMIC]
        ↓
[Callback de usuario]
```

**Ver también:** [Evento](#evento), [Callback](#callback)

---

## L

### Low-code

**Definición:** Metodología de desarrollo que minimiza la cantidad de código escrito manualmente, usando herramientas visuales.

**EMIC como plataforma low-code:**
- Integrador: Low-code (EMIC-Editor visual)
- Desarrollador: Pro-code (C + EMIC-Codify)

**Ver también:** [EMIC-Editor](#emic-editor)

---

## M

### Macro

**Definición:** Variable de texto que se sustituye por su valor durante el proceso EMIC Generate.

**Definición:**
```
EMIC:define(key, value)
```

**Uso:**
```
.{key}.
```

**Ejemplo:**
```
EMIC:define(ledPin, RA0)
EMIC:define(ledPort, PORTA)

// En código:
.{ledPort}. = 1;  // Se convierte en: PORTA = 1;
```

**Grupos:** local, global, custom

**Diferencia con Tag:**
- Macro: Para sustitución de texto (Generate)
- Tag: Para publicación de recursos (Discovery)

**Ver también:** [define](#define), [Grupo](#grupo-de-macros)

---

### Main

**Definición:** Punto de entrada del firmware. Función `main()` donde comienza la ejecución.

**Ubicación en SDK:** `DEV:_main/`

**Tipos:**
- `baremetal` - Sin RTOS
- `rtos` - Con sistema operativo

**Estructura típica:**
```c
void main(void) {
    // Inicialización
    init_hardware();
    init_drivers();
    init_app();

    // Loop infinito
    while(1) {
        poll_drivers();
        app_logic();
    }
}
```

**Ver también:** [Baremetal](#baremetal), [RTOS](#rtos)

---

### MCU

**Definición:** MicroController Unit. Microcontrolador.

**En EMIC:** Soporta múltiples familias de microcontroladores según el SDK específico.

**Familias comunes:**
- **PIC** (Microchip): PIC10/12/16/18, PIC24, dsPIC30/33, PIC32
- **ARM Cortex-M** (varios fabricantes): M0/M0+/M3/M4/M7
- **AVR** (Microchip/Atmel): ATmega, ATtiny, XMEGA
- **RISC-V**: SiFive, GigaDevice, Espressif
- **Otros**: según disponibilidad en cada SDK

**Ver también:** [PIC](#pic)

---

### Módulo

**Definición:** Unidad funcional completa que combina hardware y firmware.

**Sinónimo:** EMIC-Module

**Ubicación:** `DEV:_modules/{Category}/{ModuleName}/`

**Componentes:**
1. **Hardware:** PCB, componentes, conectores
2. **Firmware:** APIs y Drivers necesarios
3. **Configuración:** Scripts y parámetros

**Ejemplo:** Módulo de control de motores, módulo sensor I2C, módulo display

**Ver también:** [EMIC-Module](#emic-module)

---

### Modularidad

**Definición:** Principio de diseño que divide un sistema en partes independientes (módulos) que pueden combinarse.

**En EMIC:** Uno de los 4 pilares filosóficos.

**Beneficios:**
- Reutilización
- Mantenibilidad
- Escalabilidad
- Testabilidad

**Ver también:** [EMIC](#emic)

---

## P

### PCB

**Definición:** Printed Circuit Board. Placa de circuito impreso.

**En EMIC:** Configuración de hardware asociada a un módulo.

**Ubicación:** `DEV:_pcb/`

**Archivo:** `pcb.emic`

**Contenido:**
- Asignación de pines
- Configuración de periféricos
- Características del hardware

**Ejemplo:**
```
EMIC:define(Led1, RA0)
EMIC:define(RelayON, RA1)
EMIC:define(MCU, PIC18F45K50)
```

**Ver también:** [Módulo](#módulo)

---

### PIC

**Definición:** Familia de microcontroladores de Microchip Technology.

**En EMIC:** Microcontroladores objetivo principales.

**Familias:**
- **8-bit:** PIC10/12/16/18
- **16-bit:** PIC24, dsPIC30/33
- **32-bit:** PIC32

**Ver también:** [MCU](#mcu), [Compilador XC](#compilador-xc)

---

### Polling

**Definición:** Técnica donde el software verifica periódicamente el estado del hardware.

**Alternativa:** Interrupciones (evento-driven)

**En EMIC:** Usado en el loop principal para drivers que no requieren tiempo crítico.

**Ejemplo:**
```c
while(1) {
    poll_driver1();
    poll_driver2();
    poll_driver3();
}
```

**Ver también:** [ISR](#isr), [Main](#main)

---

## R

### Recurso

**Definición:** Elemento publicado en EMIC Discovery que puede ser utilizado por integradores.

**Tipos de recursos:**
- Funciones
- Variables
- Eventos
- Configurators

**Publicación:** Mediante Tags DOXYGEN o JSON

**Ver también:** [Tag](#tag), [EMIC Discovery](#emic-discovery)

---

### Repositorio EMIC

**Definición:** Término legacy para [EMIC SDK](#emic-sdk).

**Nota:** Se recomienda usar "EMIC SDK" en documentación nueva.

---

### RTOS

**Definición:** Real-Time Operating System. Sistema operativo en tiempo real.

**En EMIC:** Opcional, puede usarse en lugar de baremetal.

**Ubicación:** `DEV:_main/rtos/`

**Ventajas:**
- Multitarea
- Gestión de prioridades
- Mejor organización

**Desventajas:**
- Mayor overhead
- Mayor complejidad
- Más memoria RAM

**Ver también:** [Baremetal](#baremetal), [Main](#main)

---

## S

### Script

**Definición:** Código generado por el integrador en EMIC-Editor que describe la lógica de la aplicación.

**Formato:** XML o JSON

**Ubicación:** `Module/System/program.xml`

**Contenido:**
- Llamadas a funciones
- Flujo de control
- Configuración de parámetros
- Conexiones de eventos

**Uso:** Input para EMIC Generate

**Ver también:** [EMIC-Editor](#emic-editor), [EMIC Generate](#emic-generate)

---

### SDK

**Definición:** Software Development Kit. Conjunto de herramientas y componentes para desarrollo.

**En EMIC:** Ver [EMIC SDK](#emic-sdk)

---

### setInput

**Definición:** Comando EMIC-Codify que indica al sistema procesar un archivo.

**Sintaxis:**
```
EMIC:setInput([origin:][dir/]file[[,key=value]])
```

**Función:**
- Lee y procesa archivo
- Puede pasar parámetros (macros locales)
- Ejecuta comandos EMIC en el archivo

**Ejemplo:**
```
EMIC:setInput(DEV:_api/LEDs/led.emic,name=statusLed,pin=RA0)
```

**Ver también:** [EMIC-Codify](#emic-codify), [Macro](#macro)

---

### SYS:

**Definición:** Volumen lógico que apunta a la carpeta System del módulo.

**Ubicación física:** `Module/System/`

**Contenido:**
- generate.emic
- config.json
- module.json
- program.xml (Script del integrador)
- Archivos de usuario

**Uso:**
```
EMIC:setInput(SYS:usedFunction.emic)
```

**Ver también:** [Volumen Lógico](#volumen-lógico), [DEV:](#dev), [TARGET:](#target)

---

## T

### Tag

**Definición:** Etiqueta especial en código que EMIC Discovery reconoce para publicar recursos.

**Formatos:**
1. **DOXYGEN:** `@fn`, `@alias`, `@brief`, `@param`, `@return`
2. **JSON:** `EMIC:json(type = ...)`

**Propósito:** Hacer recursos accesibles en EMIC-Editor

**Diferencia con Macro:**
- Tag: Para Discovery (publicación)
- Macro: Para Generate (sustitución)

**Ver también:** [DOXYGEN](#doxygen), [Tag JSON](#tag-json)

---

### Tag JSON

**Definición:** Tag en formato JSON para recursos especiales no estándar.

**Sintaxis:**
```
EMIC:json(type = ResourceType)
{
    'name': '...',
    'brief': '...',
    ...
}
```

**Tipos comunes:**
- `Configurator` - Menús de configuración
- Custom types definidos por usuario

**Ver también:** [Configurator](#configurator), [Tag](#tag)

---

### TARGET:

**Definición:** Volumen lógico donde EMIC Generate escribe el código C compilable generado.

**Ubicación física:** `Module/Target/`

**Contenido típico:**
```
TARGET:
├── main.c
├── led.c
├── timer.c
├── inc/
│   ├── led.h
│   └── timer.h
└── (archivos generados)
```

**Uso:**
```
EMIC:setOutput(TARGET:main.c)
```

**Ver también:** [Volumen Lógico](#volumen-lógico), [DEV:](#dev), [SYS:](#sys)

---

### Template

**Definición:** Plantilla predefinida para proyectos.

**Ubicación:** `DEV:_templates/`

**Tipos:**
- Proyectos MPLAB X
- Makefiles
- Configuraciones de compilador

**Uso:** EMIC Generate copia templates a TARGET para crear proyecto compilable.

**Ver también:** [EMIC Generate](#emic-generate)

---

## U

### USER:

**Definición:** Volumen lógico que apunta a archivos del usuario/integrador.

**Ubicación física:** Variable, típicamente en proyectos de usuario

**Contenido:**
- Código personalizado del integrador
- Archivos específicos del proyecto
- Recursos no estándar

**Uso:**
```
EMIC:copy(USER:myCode.c > TARGET:myCode.c)
```

**Ver también:** [Volumen Lógico](#volumen-lógico)

---

## V

### Volumen Lógico

**Definición:** Sistema de abstracción de rutas físicas usando prefijos.

**Volúmenes definidos:**

| Volumen | Ubicación | Propósito |
|---------|-----------|-----------|
| `DEV:` | EMIC SDK | Recursos del desarrollador |
| `TARGET:` | Module/Target/ | Código generado |
| `SYS:` | Module/System/ | Configuración |
| `USER:` | Proyectos usuario | Código personalizado |

**Beneficios:**
- Portabilidad
- Abstracción de rutas
- Organización clara

**Ejemplo:**
```
EMIC:copy(DEV:_api/led.c > TARGET:led.c)
```

**Ver también:** [DEV:](#dev), [TARGET:](#target), [SYS:](#sys), [USER:](#user)

---

## X

### XC8 / XC16 / XC32

Ver [Compilador XC](#compilador-xc)

---

## 📚 Términos Relacionados por Categoría

### Arquitectura del Sistema
- [EMIC](#emic)
- [EMIC SDK](#emic-sdk)
- [EMIC Discovery](#emic-discovery)
- [EMIC-Editor](#emic-editor)
- [EMIC Generate](#emic-generate)
- [EMIC Compiler](#emic-compiler)

### Componentes de Software
- [API](#api)
- [Driver](#driver)
- [HAL](#hal)
- [EMIC-Library](#emic-library)
- [EMIC-Module](#emic-module)

### Lenguaje EMIC-Codify
- [EMIC-Codify](#emic-codify)
- [Comando EMIC](#setinput)
- [Macro](#macro)
- [Grupo](#grupo-de-macros)

### Etiquetado
- [Tag](#tag)
- [DOXYGEN](#doxygen)
- [Tag JSON](#tag-json)
- [Alias](#alias)
- [Etiquetado](#etiquetado)

### Volúmenes
- [Volumen Lógico](#volumen-lógico)
- [DEV:](#dev)
- [TARGET:](#target)
- [SYS:](#sys)
- [USER:](#user)

### Roles
- [Desarrollador](#desarrollador)
- [Integrador](#integrador)

### Hardware
- [MCU](#mcu)
- [PIC](#pic)
- [PCB](#pcb)
- [Firmware](#firmware)

---

## 🔍 Cómo Usar Este Glosario

### Para Búsqueda Rápida:
1. Usa el [Índice Alfabético](#-índice-alfabético) al inicio
2. Click en la letra para saltar a esa sección
3. Las referencias cruzadas te llevan a términos relacionados

### Para Aprendizaje:
1. Lee términos por categoría (ver sección final)
2. Sigue las referencias "Ver también"
3. Vuelve a este glosario cuando encuentres un término desconocido en otros capítulos

### Como Referencia:
- Bookmark este capítulo para consulta rápida
- Usa Ctrl+F para buscar términos específicos
- Las definiciones incluyen ejemplos de código cuando es relevante

---

## 📝 Notas

> **💡 Tip:** Este glosario es una referencia viva. A medida que avances en el manual, vuelve aquí para refrescar conceptos.

> **📝 Nota:** Algunos términos tienen definiciones específicas en el contexto EMIC que pueden diferir de su uso general en programación.

---

## Resumen del Capítulo

En este capítulo has obtenido:

✅ **Definiciones precisas** de todos los términos EMIC
✅ **Referencias cruzadas** para navegación fácil
✅ **Ejemplos de código** cuando es relevante
✅ **Contexto de uso** para cada término
✅ **Organización alfabética** y por categorías

### Próximo Paso

Con el vocabulario EMIC dominado, el siguiente capítulo explora las **ventajas competitivas** de usar EMIC vs otros métodos de desarrollo.

**Próximo capítulo:** [Cap 04 - Ventajas de EMIC vs Otros Métodos →](04_Ventajas.md)

---

[← Anterior: Arquitectura](02_Arquitectura.md) | [Siguiente: Ventajas →](04_Ventajas.md)

---

*Capítulo 03 - Manual de Desarrollo EMIC SDK v1.0*
*Última actualización: Noviembre 2025*
