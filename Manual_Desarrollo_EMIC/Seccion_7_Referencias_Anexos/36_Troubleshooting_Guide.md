# Capítulo 36: Troubleshooting Guide

> **Guía Completa de Diagnóstico y Solución de Problemas** - Metodologías, herramientas y casos prácticos para resolver errores comunes en desarrollo EMIC

---

## 📋 Índice

1. [Metodología de Debugging](#1-metodología-de-debugging)
2. [Errores de Compilación](#2-errores-de-compilación)
3. [Errores de Linker](#3-errores-de-linker)
4. [Errores de Runtime](#4-errores-de-runtime)
5. [Problemas de Configuración](#5-problemas-de-configuración)
6. [Problemas de Comunicación](#6-problemas-de-comunicación)
7. [Problemas de Hardware](#7-problemas-de-hardware)
8. [Problemas de Memoria](#8-problemas-de-memoria)
9. [Problemas de Timing](#9-problemas-de-timing)
10. [Problemas con Interrupts](#10-problemas-con-interrupts)
11. [Debugging con MPLAB X](#11-debugging-con-mplab-x)
12. [Debugging sin Debugger](#12-debugging-sin-debugger)
13. [Herramientas de Diagnóstico](#13-herramientas-de-diagnóstico)
14. [Casos Prácticos Resueltos](#14-casos-prácticos-resueltos)
15. [Checklists de Diagnóstico](#15-checklists-de-diagnóstico)

---

## 1. Metodología de Debugging

### Enfoque Sistemático

El debugging efectivo requiere un proceso metódico:

```
┌─────────────────────────────────────────┐
│  1. REPRODUCIR EL PROBLEMA              │
│     - Identificar condiciones exactas   │
│     - Documentar comportamiento         │
│     - Verificar reproducibilidad        │
├─────────────────────────────────────────┤
│  2. AISLAR LA CAUSA                     │
│     - Divide and conquer                │
│     - Eliminar variables                │
│     - Crear caso de prueba mínimo       │
├─────────────────────────────────────────┤
│  3. FORMULAR HIPÓTESIS                  │
│     - Basada en síntomas observados     │
│     - Considerar causas múltiples       │
│     - Priorizar más probable primero    │
├─────────────────────────────────────────┤
│  4. VERIFICAR HIPÓTESIS                 │
│     - Diseñar experimento               │
│     - Ejecutar y observar               │
│     - Confirmar o descartar             │
├─────────────────────────────────────────┤
│  5. IMPLEMENTAR SOLUCIÓN                │
│     - Corregir causa raíz               │
│     - Evitar parches temporales         │
│     - Documentar cambio                 │
├─────────────────────────────────────────┤
│  6. VERIFICAR SOLUCIÓN                  │
│     - Confirmar problema resuelto       │
│     - Probar casos edge                 │
│     - Verificar no hay regresiones      │
└─────────────────────────────────────────┘
```

### Divide and Conquer

Técnica fundamental para aislar problemas:

```c
// Problema: Sistema no funciona correctamente
// Estrategia: Dividir en bloques y probar cada uno

// PASO 1: Verificar inicialización básica
void main(void) {
    GPIO_SetOutput(DEBUG_LED);
    GPIO_Write(DEBUG_LED, 1);  // LED encendido = MCU ejecutando

    while(1);  // ¿LED enciende? → MCU funciona, clock OK
}

// PASO 2: Verificar periférico básico
void main(void) {
    UART_Init(115200);
    UART_WriteString("Hello\r\n");  // ¿Recibe mensaje? → UART funciona

    while(1);
}

// PASO 3: Verificar módulo sospechoso
void main(void) {
    UART_Init(115200);
    UART_WriteString("Starting sensor...\r\n");

    if (!Sensor_Init()) {
        UART_WriteString("ERROR: Sensor init failed\r\n");  // ← Problema identificado
    } else {
        UART_WriteString("Sensor OK\r\n");
    }

    while(1);
}
```

### Proceso Iterativo

```c
// Iteración 1: Reproducir
// Resultado: Sistema se resetea después de 10 segundos

// Iteración 2: Aislar
// Deshabilitar módulos uno por uno
// Resultado: Reset desaparece sin módulo WiFi → WiFi es sospechoso

// Iteración 3: Hipótesis
// H1: Stack overflow en WiFi_Connect()
// H2: Watchdog timeout durante WiFi_Connect()
// H3: Voltaje insuficiente (WiFi consume mucho)

// Iteración 4: Verificar H1 (Stack overflow)
void WiFi_Connect(void) {
    UART_Printf("Stack before: %p\r\n", __builtin_frame_address(0));
    // ... código WiFi ...
    UART_Printf("Stack after: %p\r\n", __builtin_frame_address(0));
    // Diferencia > 2000 bytes → Stack overflow confirmado!
}

// Iteración 5: Solución
// Aumentar stack size en linker script
// _min_stack_size = 2048;  // ANTES
// _min_stack_size = 4096;  // DESPUÉS

// Iteración 6: Verificar
// Sistema funciona correctamente sin resets → RESUELTO
```

---

## 2. Errores de Compilación

### Tabla de Errores Comunes

| Error | Causa | Solución | Ejemplo |
|-------|-------|----------|---------|
| `syntax error` | Sintaxis C inválida | Revisar línea indicada | Falta `;` o `}` |
| `undeclared identifier 'X'` | Variable no declarada | Declarar o incluir header | `#include "module.h"` |
| `redefinition of 'X'` | Definición duplicada | Usar `extern` o `static` | Ver ejemplo abajo |
| `expected ';' before 'X'` | Falta punto y coma | Agregar `;` en línea anterior | - |
| `implicit declaration of function 'X'` | Función sin prototipo | Agregar prototipo o include | `void func(void);` |
| `incompatible types` | Asignación de tipos incompatibles | Hacer cast o corregir tipo | `(uint8_t)value` |
| `assignment makes pointer from integer` | Asignar número a puntero | Usar `&` o corregir tipo | `ptr = &value;` |
| `dereferencing pointer to incomplete type` | Struct incompleto | Incluir definición completa | Include header |
| `'X' has no member named 'Y'` | Campo no existe en struct | Verificar nombre de campo | Revisar definición |
| `too few/many arguments to function 'X'` | Número de parámetros incorrecto | Ajustar llamada | Ver prototipo |

### Ejemplo 1: undeclared identifier

```c
// ❌ ERROR: 'GPIO_Write' undeclared
void main(void) {
    GPIO_Write(LED_PIN, 1);  // ERROR: función no declarada
}

// ✅ SOLUCIÓN: Incluir header
#include "DEV:/api/gpio.h"

void main(void) {
    GPIO_Write(LED_PIN, 1);  // OK
}
```

### Ejemplo 2: redefinition

```c
// ❌ ERROR: redefinition of 'counter'

// file: module_a.c
uint8_t counter = 0;  // Definición

// file: module_b.c
uint8_t counter = 0;  // ERROR: redefinition

// ✅ SOLUCIÓN: Usar extern

// file: globals.h
extern uint8_t counter;  // Declaración

// file: globals.c
uint8_t counter = 0;  // Definición única

// file: module_a.c
#include "globals.h"
void func_a(void) {
    counter++;  // OK
}

// file: module_b.c
#include "globals.h"
void func_b(void) {
    counter++;  // OK
}
```

### Ejemplo 3: incompatible types

```c
// ❌ ERROR: incompatible types
uint8_t value = 3.14;  // ERROR: float → uint8_t

// ✅ SOLUCIÓN 1: Cast explícito
uint8_t value = (uint8_t)3.14;  // OK: value = 3

// ✅ SOLUCIÓN 2: Usar tipo correcto
float value = 3.14;  // OK
```

### Ejemplo 4: implicit declaration

```c
// ❌ ERROR: implicit declaration of function 'Calculate'
void main(void) {
    uint16_t result = Calculate(10, 20);  // ERROR: no prototype
}

uint16_t Calculate(uint16_t a, uint16_t b) {
    return a + b;
}

// ✅ SOLUCIÓN 1: Prototipo antes de uso
uint16_t Calculate(uint16_t a, uint16_t b);  // Prototipo

void main(void) {
    uint16_t result = Calculate(10, 20);  // OK
}

uint16_t Calculate(uint16_t a, uint16_t b) {
    return a + b;
}

// ✅ SOLUCIÓN 2: Definir antes de uso
uint16_t Calculate(uint16_t a, uint16_t b) {
    return a + b;
}

void main(void) {
    uint16_t result = Calculate(10, 20);  // OK
}
```

---

## 3. Errores de Linker

### Tabla de Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| `undefined reference to 'func'` | Función declarada pero no definida | Implementar función o linkar librería |
| `multiple definition of 'var'` | Variable definida en múltiples .c | Usar `extern` (ver Cap. 2) |
| `region 'program' overflowed by X bytes` | Código muy grande para flash | Optimizar (-Os) o reducir funcionalidades |
| `region 'data' overflowed by X bytes` | RAM insuficiente | Reducir variables o usar memoria externa |
| `cannot find -lm` | Librería no encontrada | Agregar path o instalar librería |
| `section '.text' will not fit` | Flash insuficiente | Reducir código |
| `relocation truncated to fit` | Dirección fuera de rango | Revisar linker script |

### Ejemplo 1: undefined reference

```c
// ❌ ERROR: undefined reference to 'ProcessData'

// file: main.c
#include "module.h"

void main(void) {
    ProcessData();  // Declarada en module.h pero no implementada
}

// file: module.h
void ProcessData(void);  // Solo prototipo, falta implementación!

// ✅ SOLUCIÓN: Implementar función

// file: module.c
#include "module.h"

void ProcessData(void) {
    // Implementación
}
```

### Ejemplo 2: region overflowed

```
❌ ERROR:
Link Error: program region 'kseg0_program_mem' overflowed by 4352 bytes
Memory region         Used Size    Region Size    %age Used
kseg0_program_mem:    131072 B     126720 B       103.43%
```

**Diagnóstico:**
```bash
# Ver tamaño de secciones
xc32-size firmware.elf
   text    data     bss     dec     hex filename
 131072    2048    4096  137216   21800 firmware.elf

# Ver qué funciones ocupan más espacio
xc32-nm --size-sort --radix=d firmware.elf | tail -20
```

**Soluciones:**

```c
// SOLUCIÓN 1: Optimizar para tamaño
// En Makefile o proyecto MPLAB X
CFLAGS += -Os  // Optimize for size

// SOLUCIÓN 2: Eliminar código debug
#ifdef DEBUG
    UART_Printf("Debug: value=%u\r\n", value);  // Solo en debug
#endif

// SOLUCIÓN 3: Usar const para strings (van a ROM, no RAM)
const char* message = "Hello World";  // ✅ En ROM
char message[] = "Hello World";       // ❌ En RAM (copia)

// SOLUCIÓN 4: Eliminar funcionalidades no esenciales
// Comentar módulos no usados en generate.emic
```

### Ejemplo 3: RAM overflow

```
❌ ERROR:
Link Error: data region 'kseg1_data_mem' overflowed by 2048 bytes
Memory region         Used Size    Region Size    %age Used
kseg1_data_mem:       67584 B      65536 B        103.12%
```

**Soluciones:**

```c
// SOLUCIÓN 1: Reducir buffers
uint8_t uart_buffer[4096];  // ❌ Muy grande
uint8_t uart_buffer[256];   // ✅ Optimizado

// SOLUCIÓN 2: Usar allocation dinámica (heap)
uint8_t* buffer = malloc(1024);  // Desde heap, no stack
// ... usar buffer ...
free(buffer);

// SOLUCIÓN 3: Usar memoria externa
#define USE_EXTERNAL_RAM
#ifdef USE_EXTERNAL_RAM
    uint8_t __attribute__((address(0x20000000))) large_buffer[32768];
#endif

// SOLUCIÓN 4: Hacer variables static en funciones (comparten memoria)
void process_a(void) {
    static uint8_t temp_buffer[512];  // Compartida entre llamadas
}

void process_b(void) {
    static uint8_t temp_buffer[512];  // Diferente buffer
}
```

---

## 4. Errores de Runtime

### Tipos de Crashes

```c
// 1. STACK OVERFLOW
// Síntoma: Reset aleatorio, corrupción de variables
// Causa: Stack muy pequeño o recursión profunda

void recursive_func(uint16_t depth) {
    uint8_t buffer[256];  // 256 bytes por llamada!
    if (depth > 0) {
        recursive_func(depth - 1);  // ← Stack crece rápidamente
    }
}

// SOLUCIÓN: Aumentar stack o evitar recursión
// Linker script: _min_stack_size = 4096;

// 2. HEAP EXHAUSTION
// Síntoma: malloc() retorna NULL, sistema se cuelga
// Causa: Heap muy pequeño o memory leaks

uint8_t* buffer = malloc(1024);
if (buffer == NULL) {
    UART_WriteString("ERROR: Out of memory!\r\n");  // ← Detectar early
    return false;
}

// SOLUCIÓN: Aumentar heap o liberar memoria
// Linker script: _min_heap_size = 8192;
```

### Stack Overflow Detection

```c
// Técnica 1: Stack canary (manual)
#define STACK_CANARY 0xDEADBEEF

uint32_t stack_canary = STACK_CANARY;

void check_stack(void) {
    if (stack_canary != STACK_CANARY) {
        UART_WriteString("FATAL: Stack overflow detected!\r\n");
        while(1);  // Halt
    }
}

void main(void) {
    while(1) {
        check_stack();  // Verificar periódicamente
        // ... código ...
    }
}

// Técnica 2: Compiler stack checking (XC32)
// En MPLAB X: Project Properties → XC32 Compiler → Additional Options
// -fstack-check

// Técnica 3: Hardware stack overflow detection (PIC32 specific)
void __attribute__((nomips16)) _general_exception_handler(void) {
    uint32_t cause = _CP0_GET_CAUSE();

    if (cause & 0x00000080) {  // Stack overflow exception
        UART_WriteString("FATAL: Stack overflow!\r\n");
        while(1);
    }
}
```

### Watchdog Reset Detection

```c
// Detectar si el último reset fue por watchdog
void check_reset_cause(void) {
    if (RCONbits.WDTO) {  // Watchdog timeout
        UART_WriteString("WARNING: Watchdog reset detected!\r\n");
        RCONbits.WDTO = 0;  // Clear flag

        // Log o enviar alerta
    }

    if (RCONbits.BOR) {  // Brown-out reset
        UART_WriteString("WARNING: Brown-out reset detected!\r\n");
        RCONbits.BOR = 0;
    }
}

void main(void) {
    check_reset_cause();  // Primera línea en main

    // ... resto del código ...
}
```

### Null Pointer Dereference

```c
// ❌ PROBLEMA: Crash al acceder puntero NULL
uint8_t* buffer = NULL;
*buffer = 0x55;  // ← CRASH!

// ✅ SOLUCIÓN: Siempre validar punteros
uint8_t* buffer = get_buffer();

if (buffer != NULL) {
    *buffer = 0x55;  // Seguro
} else {
    UART_WriteString("ERROR: Null pointer\r\n");
    return ERROR_NULL_POINTER;
}

// ✅ MEJOR: Usar aserciones
#define ASSERT(cond) if(!(cond)) { \
    UART_Printf("ASSERT FAIL: %s:%d\r\n", __FILE__, __LINE__); \
    while(1); \
}

ASSERT(buffer != NULL);
*buffer = 0x55;  // Si llega aquí, buffer es válido
```

---

## 5. Problemas de Configuración

### config.json Inválido

```json
❌ ERROR: JSON mal formado
{
  "module": "UART",
  "config": {
    "baudrate": 115200,  // ← Coma extra antes de }
  }
}

✅ SOLUCIÓN: JSON válido
{
  "module": "UART",
  "config": {
    "baudrate": 115200
  }
}
```

**Herramienta de validación:**

```bash
# Validar JSON con Python
python -m json.tool config.json

# Si hay error, indica línea
Expecting property name enclosed in double quotes: line 5 column 3 (char 78)
```

### Parámetros Fuera de Rango

```json
❌ ERROR: Valor fuera de rango
{
  "config": {
    "baudrate": {
      "type": "uint32_t",
      "default": 115200,
      "min": 9600,
      "max": 230400
    }
  }
}

// Usuario configura:
"baudrate": 500000  // ← Fuera de rango!
```

**Solución: Validación en código**

```c
bool UART_SetBaudrate(uint32_t baudrate) {
    const uint32_t MIN_BAUD = 9600;
    const uint32_t MAX_BAUD = 230400;

    if (baudrate < MIN_BAUD || baudrate > MAX_BAUD) {
        UART_Printf("ERROR: Baudrate %lu out of range [%lu, %lu]\r\n",
                    baudrate, MIN_BAUD, MAX_BAUD);
        return false;
    }

    // Configurar baudrate
    U1BRG = calculate_brg(baudrate);
    return true;
}
```

### Conflicto de Periféricos

```json
❌ ERROR: Dos módulos usan mismo periférico

// Módulo A
{
  "peripherals": ["UART1", "SPI1"]
}

// Módulo B
{
  "peripherals": ["UART1", "I2C1"]  // ← UART1 conflicto!
}
```

**Solución: Sistema de detección**

```c
// Registro de periféricos usados
typedef struct {
    const char* peripheral;
    const char* owner_module;
} PeripheralAllocation_t;

PeripheralAllocation_t peripheral_registry[32];
uint8_t peripheral_count = 0;

bool claim_peripheral(const char* peripheral, const char* module) {
    // Verificar si ya está en uso
    for (uint8_t i = 0; i < peripheral_count; i++) {
        if (strcmp(peripheral_registry[i].peripheral, peripheral) == 0) {
            UART_Printf("ERROR: %s already claimed by %s!\r\n",
                        peripheral,
                        peripheral_registry[i].owner_module);
            return false;
        }
    }

    // Registrar
    peripheral_registry[peripheral_count].peripheral = peripheral;
    peripheral_registry[peripheral_count].owner_module = module;
    peripheral_count++;

    return true;
}

// Uso
if (!claim_peripheral("UART1", "UARTDriver")) {
    return false;  // ERROR: Conflicto detectado
}
```

---

## 6. Problemas de Comunicación

### UART Troubleshooting

#### Problema 1: No Recibe Datos

```c
// Síntoma: UART_Available() siempre retorna 0

// DIAGNÓSTICO PASO A PASO:

// 1. Verificar configuración hardware
UART_Init(115200);
UART_Printf("UART TX test\r\n");  // ¿Se recibe en PC? → TX funciona

// 2. Verificar RX habilitado
if (!(U1STA & _U1STA_URXEN_MASK)) {
    UART_WriteString("ERROR: RX not enabled!\r\n");
    U1STASET = _U1STA_URXEN_MASK;  // Habilitar RX
}

// 3. Verificar interrupción RX (si se usa)
if (!(IEC0 & _IEC0_U1RXIE_MASK)) {
    UART_WriteString("WARNING: RX interrupt disabled\r\n");
}

// 4. Verificar buffer overflow
if (U1STA & _U1STA_OERR_MASK) {
    UART_WriteString("ERROR: UART overrun!\r\n");
    U1STACLR = _U1STA_OERR_MASK;  // Clear overflow
}

// 5. Test de loopback (conectar TX → RX)
UART_WriteChar('A');
TIMER_Delay(10);
if (UART_Available()) {
    char c = UART_ReadChar();
    if (c == 'A') {
        UART_WriteString("Loopback OK\r\n");  // Hardware funciona
    }
} else {
    UART_WriteString("Loopback FAIL - hardware issue\r\n");
}
```

#### Problema 2: Datos Corruptos

```c
// Síntoma: Recibe caracteres incorrectos, "basura"

// CAUSA COMÚN: Baudrate error

// DIAGNÓSTICO:
// Baudrate real = PERIPHERAL_CLOCK / (16 * (BRG + 1))
// Error % = |Baudrate_Real - Baudrate_Target| / Baudrate_Target * 100

uint32_t calculate_baudrate_error(uint32_t target_baud) {
    uint32_t pbclk = 100000000UL;  // 100 MHz peripheral clock
    uint32_t brg = (pbclk / (16 * target_baud)) - 1;
    uint32_t actual_baud = pbclk / (16 * (brg + 1));

    int32_t error = actual_baud - target_baud;
    uint32_t error_percent = (abs(error) * 100) / target_baud;

    UART_Printf("Target: %lu, Actual: %lu, Error: %lu%%\r\n",
                target_baud, actual_baud, error_percent);

    return error_percent;
}

// SOLUCIÓN: Usar baudrate con menor error
// Baudrates estándar: 9600, 19200, 38400, 57600, 115200
// Con PBCLK=100MHz, 115200 tiene error ~0.16% (OK)
```

### SPI Troubleshooting

```c
// Problema: Dispositivo SPI no responde

// DIAGNÓSTICO:

// 1. Verificar clock
// Usar osciloscopio en pin SCK
// ¿Hay clock durante SPI_Transfer()? NO → Ver config
// SPI_Init(SPI_MODE_0, 1000000);  // 1 MHz

// 2. Verificar modo SPI (CPOL, CPHA)
// Modo 0: CPOL=0, CPHA=0 (más común)
// Modo 1: CPOL=0, CPHA=1
// Modo 2: CPOL=1, CPHA=0
// Modo 3: CPOL=1, CPHA=1
// → Revisar datasheet del dispositivo

// 3. Verificar CS (Chip Select)
void SPI_TransferWithCS(uint8_t* data, uint16_t len) {
    GPIO_Write(SPI_CS_PIN, 0);  // CS = LOW (activo)
    TIMER_DelayMicros(1);        // Setup time

    for (uint16_t i = 0; i < len; i++) {
        data[i] = SPI_Transfer(data[i]);
    }

    TIMER_DelayMicros(1);        // Hold time
    GPIO_Write(SPI_CS_PIN, 1);  // CS = HIGH (inactivo)
}

// 4. Verificar bit order (MSB vs LSB first)
// La mayoría de dispositivos usan MSB first
// Si datos incorrectos, probar invertir:
uint8_t reverse_bits(uint8_t byte) {
    byte = (byte & 0xF0) >> 4 | (byte & 0x0F) << 4;
    byte = (byte & 0xCC) >> 2 | (byte & 0x33) << 2;
    byte = (byte & 0xAA) >> 1 | (byte & 0x55) << 1;
    return byte;
}
```

### I2C Troubleshooting

```c
// Problema: I2C_Read() recibe NACK

// DIAGNÓSTICO:

// 1. Verificar dirección del dispositivo
// Direcciones son 7-bit, se shifean izq para R/W bit
// Ejemplo: Sensor address = 0x48 (datasheet)
// Dirección write = 0x90 (0x48 << 1 | 0)
// Dirección read  = 0x91 (0x48 << 1 | 1)

#define SENSOR_ADDR 0x48

bool I2C_ReadSensor(uint8_t reg, uint8_t* value) {
    I2C_Start();

    // Write address + register
    if (!I2C_Write(SENSOR_ADDR << 1 | 0)) {  // Write mode
        UART_Printf("ERROR: Device 0x%02X not responding (NACK)\r\n", SENSOR_ADDR);
        I2C_Stop();
        return false;
    }

    if (!I2C_Write(reg)) {
        UART_WriteString("ERROR: Register write NACK\r\n");
        I2C_Stop();
        return false;
    }

    // Repeated start + read
    I2C_Restart();
    if (!I2C_Write(SENSOR_ADDR << 1 | 1)) {  // Read mode
        UART_WriteString("ERROR: Read NACK\r\n");
        I2C_Stop();
        return false;
    }

    *value = I2C_Read(false);  // NACK en última lectura
    I2C_Stop();

    return true;
}

// 2. Verificar pull-ups
// I2C requiere pull-ups en SDA y SCL (típico: 4.7kΩ)
// Síntoma sin pull-ups: Bus siempre en LOW
// Verificar con multímetro: SDA y SCL deben estar en ~3.3V en reposo

// 3. Scanner I2C (buscar dispositivos)
void I2C_Scanner(void) {
    UART_WriteString("Scanning I2C bus...\r\n");

    for (uint8_t addr = 0x08; addr < 0x78; addr++) {
        I2C_Start();
        bool ack = I2C_Write(addr << 1 | 0);  // Write mode
        I2C_Stop();

        if (ack) {
            UART_Printf("Device found at 0x%02X\r\n", addr);
        }

        TIMER_Delay(10);
    }

    UART_WriteString("Scan complete\r\n");
}

// 4. Verificar bus stuck (SDA o SCL stuck LOW)
bool I2C_RecoverBus(void) {
    // Si bus stuck, enviar 9 clocks para liberar
    for (uint8_t i = 0; i < 9; i++) {
        // Toggle SCL manualmente (via GPIO)
        GPIO_Write(SCL_PIN, 0);
        TIMER_DelayMicros(5);
        GPIO_Write(SCL_PIN, 1);
        TIMER_DelayMicros(5);
    }

    // Verificar si SDA está HIGH ahora
    if (GPIO_Read(SDA_PIN)) {
        UART_WriteString("Bus recovered\r\n");
        return true;
    } else {
        UART_WriteString("Bus still stuck\r\n");
        return false;
    }
}
```

---

## 7. Problemas de Hardware

### LEDs de Debug

```c
// Técnica fundamental: Usar LEDs para diagnosticar sin UART/debugger

#define LED_STATUS   10  // Verde: Sistema OK
#define LED_ERROR    11  // Rojo: Error detectado
#define LED_ACTIVITY 12  // Azul: Actividad

void debug_led_init(void) {
    GPIO_SetOutput(LED_STATUS);
    GPIO_SetOutput(LED_ERROR);
    GPIO_SetOutput(LED_ACTIVITY);
}

// Patrón 1: Morse code para errores
void led_morse(const char* pattern) {
    // '.' = 200ms, '-' = 600ms, espacio = 200ms
    for (const char* p = pattern; *p; p++) {
        GPIO_Write(LED_ERROR, 1);
        TIMER_Delay(*p == '.' ? 200 : 600);
        GPIO_Write(LED_ERROR, 0);
        TIMER_Delay(200);
    }
    TIMER_Delay(1000);  // Pausa entre repeticiones
}

// Uso:
// while(1) led_morse("...---...");  // SOS

// Patrón 2: Blink code (número de blinks = código de error)
void led_error_code(uint8_t code) {
    while(1) {
        for (uint8_t i = 0; i < code; i++) {
            GPIO_Toggle(LED_ERROR);
            TIMER_Delay(200);
            GPIO_Toggle(LED_ERROR);
            TIMER_Delay(200);
        }
        TIMER_Delay(2000);  // Pausa larga
    }
}

// Uso:
// if (!UART_Init()) led_error_code(1);  // 1 blink = UART error
// if (!SPI_Init()) led_error_code(2);   // 2 blinks = SPI error

// Patrón 3: LED heartbeat
void led_heartbeat(void) {
    static uint32_t last_toggle = 0;
    uint32_t now = TIMER_GetMillis();

    if (now - last_toggle > 500) {
        GPIO_Toggle(LED_STATUS);
        last_toggle = now;
    }
}

// Uso en loop:
LOOP {
    led_heartbeat();  // LED parpadea → sistema ejecutando
    // Si LED se congela → sistema colgado
}
```

### Checklist de Verificación Hardware

```
□ Alimentación
  □ Voltaje correcto (3.3V ±10% = 2.97V - 3.63V)
  □ Corriente suficiente (verificar con multímetro)
  □ Capacitores de desacoplo cerca del MCU (100nF + 10µF)
  □ Regulador no sobrecalentado

□ Oscilador
  □ Crystal conectado (si usa external oscillator)
  □ Load capacitors correctos (típico: 15-22pF según crystal)
  □ Clock oscilando (verificar con osciloscopio en pin OSC2)
  □ Frequency correcta

□ Reset
  □ Pin MCLR con pull-up (~10kΩ)
  □ Botón reset funciona
  □ No resets espontáneos

□ Programador
  □ Conexiones: MCLR, PGC, PGD, VDD, GND
  □ Cable no muy largo (<30cm ideal)
  □ Voltaje programming correcto

□ Periféricos
  □ Pines GPIO no tienen cortos
  □ Pull-ups/pull-downs donde necesario
  □ Dispositivos externos alimentados
  □ Niveles de voltaje compatibles (3.3V vs 5V)

□ PCB
  □ Soldaduras correctas (no cold joints)
  □ No puentes de soldadura (shorts)
  □ Componentes orientación correcta (polarizados)
  □ Conexiones a tierra (GND plane)
```

### Mediciones con Multímetro

```c
// 1. Verificar alimentación
// Medir VDD: Debe ser 3.3V ±10%
// Si <3.0V → Regulador incorrecto o carga excesiva
// Si >3.6V → Peligro, puede dañar MCU

// 2. Verificar consumo de corriente
// PIC32MZ @ 200MHz: ~150mA típico
// + Periféricos (WiFi: +200mA, etc)
// Si excesivo → Buscar corto

// 3. Verificar continuidad
// Verificar GND entre MCU y dispositivos
// Verificar VDD paths
// Verificar señales críticas (SDA, SCL, CS, etc)

// 4. Verificar pull-ups I2C
// Medir resistencia SDA a VDD: ~4.7kΩ
// Medir resistencia SCL a VDD: ~4.7kΩ
// Si infinito → Falta pull-up
```

---

## 8. Problemas de Memoria

### Stack Overflow

```c
// CAUSA 1: Recursión profunda
uint32_t fibonacci(uint32_t n) {
    if (n <= 1) return n;
    return fibonacci(n-1) + fibonacci(n-2);  // ← Cada llamada usa stack
}

// fibonacci(30) → ~1.5 millones de llamadas → STACK OVERFLOW

// SOLUCIÓN: Versión iterativa
uint32_t fibonacci_iterative(uint32_t n) {
    if (n <= 1) return n;
    uint32_t a = 0, b = 1;
    for (uint32_t i = 2; i <= n; i++) {
        uint32_t temp = a + b;
        a = b;
        b = temp;
    }
    return b;
}

// CAUSA 2: Arrays grandes en stack
void process_data(void) {
    uint8_t buffer[4096];  // ← 4KB en stack!
    // ...
}

// SOLUCIÓN: Array estático o dinámico
static uint8_t buffer[4096];  // ✅ No consume stack

// o
uint8_t* buffer = malloc(4096);  // ✅ En heap
```

### Memory Leak Detection

```c
// Problema: Heap se agota gradualmente

// TÉCNICA: Monitorear heap usage
void check_heap(void) {
    static uint32_t min_heap_free = 0xFFFFFFFF;
    uint32_t heap_free = xPortGetFreeHeapSize();  // FreeRTOS

    if (heap_free < min_heap_free) {
        min_heap_free = heap_free;
        UART_Printf("Heap watermark: %lu bytes free\r\n", heap_free);
    }

    if (heap_free < 1024) {
        UART_WriteString("WARNING: Low heap!\r\n");
    }
}

// Llamar periódicamente
LOOP {
    check_heap();
    // ...
}

// LEAK COMÚN: Olvidar free()
void bad_function(void) {
    char* buffer = malloc(256);
    // ... usar buffer ...
    // ❌ Olvidó free(buffer) → MEMORY LEAK
}

void good_function(void) {
    char* buffer = malloc(256);
    if (buffer == NULL) return;

    // ... usar buffer ...

    free(buffer);  // ✅ Libera memoria
}
```

### Herramienta: Heap Profiler

```c
// Wrapper para malloc/free con tracking

typedef struct {
    void* ptr;
    uint32_t size;
    const char* file;
    uint16_t line;
} AllocInfo_t;

#define MAX_ALLOCS 100
AllocInfo_t alloc_table[MAX_ALLOCS];
uint16_t alloc_count = 0;

void* tracked_malloc(uint32_t size, const char* file, uint16_t line) {
    void* ptr = malloc(size);

    if (ptr != NULL && alloc_count < MAX_ALLOCS) {
        alloc_table[alloc_count].ptr = ptr;
        alloc_table[alloc_count].size = size;
        alloc_table[alloc_count].file = file;
        alloc_table[alloc_count].line = line;
        alloc_count++;
    }

    return ptr;
}

void tracked_free(void* ptr) {
    for (uint16_t i = 0; i < alloc_count; i++) {
        if (alloc_table[i].ptr == ptr) {
            // Remover de tabla
            for (uint16_t j = i; j < alloc_count - 1; j++) {
                alloc_table[j] = alloc_table[j+1];
            }
            alloc_count--;
            break;
        }
    }

    free(ptr);
}

void dump_heap_leaks(void) {
    UART_Printf("Heap leaks: %u allocations not freed\r\n", alloc_count);
    for (uint16_t i = 0; i < alloc_count; i++) {
        UART_Printf("  %p: %lu bytes at %s:%u\r\n",
                    alloc_table[i].ptr,
                    alloc_table[i].size,
                    alloc_table[i].file,
                    alloc_table[i].line);
    }
}

// Uso:
#define malloc(size) tracked_malloc(size, __FILE__, __LINE__)
#define free(ptr) tracked_free(ptr)

// Al final del programa:
dump_heap_leaks();  // Muestra allocaciones no liberadas
```

---

## 9. Problemas de Timing

### Race Conditions

```c
// ❌ PROBLEMA: Race condition

volatile uint32_t counter = 0;

// ISR
void __ISR(_TIMER_1_VECTOR) Timer_Handler(void) {
    counter++;  // Modifica counter
    IFS0CLR = _IFS0_T1IF_MASK;
}

// Main loop
void main(void) {
    while(1) {
        if (counter >= 1000) {  // Lee counter
            counter = 0;         // Modifica counter → RACE!
            ProcessData();
        }
    }
}

// PROBLEMA: counter puede cambiar entre if y asignación
// Si ISR se ejecuta justo después del if, counter se resetea incorrectamente

// ✅ SOLUCIÓN 1: Sección crítica
void main(void) {
    while(1) {
        __builtin_disable_interrupts();
        if (counter >= 1000) {
            counter = 0;
            __builtin_enable_interrupts();
            ProcessData();
        } else {
            __builtin_enable_interrupts();
        }
    }
}

// ✅ SOLUCIÓN 2: Variable local (atomic read)
void main(void) {
    while(1) {
        uint32_t count = counter;  // Lectura atómica (32-bit MCU)
        if (count >= 1000) {
            __builtin_disable_interrupts();
            counter -= 1000;  // Restar en lugar de resetear
            __builtin_enable_interrupts();
            ProcessData();
        }
    }
}

// ✅ SOLUCIÓN 3: Flag pattern
volatile bool event_flag = false;

void __ISR(_TIMER_1_VECTOR) Timer_Handler(void) {
    if (++counter >= 1000) {
        counter = 0;
        event_flag = true;  // Set flag (escritura atómica)
    }
    IFS0CLR = _IFS0_T1IF_MASK;
}

void main(void) {
    while(1) {
        if (event_flag) {
            event_flag = false;  // Clear flag
            ProcessData();
        }
    }
}
```

### Deadline Miss Detection

```c
// Detectar si tarea no cumple deadline

typedef struct {
    const char* name;
    uint32_t period_ms;
    uint32_t worst_case_ms;
    uint32_t last_execution_ms;
    uint32_t deadline_misses;
} Task_t;

Task_t sensor_task = {
    .name = "Sensor Acquisition",
    .period_ms = 100,  // Debe ejecutar cada 100ms
    .worst_case_ms = 0,
    .last_execution_ms = 0,
    .deadline_misses = 0
};

void execute_task(Task_t* task, void (*func)(void)) {
    uint32_t start = TIMER_GetMillis();

    // Verificar deadline
    uint32_t since_last = start - task->last_execution_ms;
    if (since_last > task->period_ms * 1.1) {  // 10% margen
        task->deadline_misses++;
        UART_Printf("WARNING: %s deadline miss (%lu ms late)\r\n",
                    task->name, since_last - task->period_ms);
    }

    // Ejecutar tarea
    func();

    // Medir execution time
    uint32_t execution_time = TIMER_GetMillis() - start;
    if (execution_time > task->worst_case_ms) {
        task->worst_case_ms = execution_time;
        UART_Printf("%s worst case: %lu ms\r\n", task->name, execution_time);
    }

    task->last_execution_ms = start;
}

// Uso:
LOOP {
    static uint32_t last_sensor = 0;
    uint32_t now = TIMER_GetMillis();

    if (now - last_sensor >= 100) {
        last_sensor = now;
        execute_task(&sensor_task, ReadSensors);
    }
}
```

---

## 10. Problemas con Interrupts

### ISR No Se Ejecuta

```c
// DIAGNÓSTICO:

// 1. Verificar ISR definida correctamente
void __ISR(_UART1_RX_VECTOR, IPL3AUTO) UART1_RX_Handler(void) {
    // Toggle LED para verificar ejecución
    GPIO_Toggle(DEBUG_LED);  // ¿LED parpadea? → ISR ejecuta

    uint8_t data = U1RXREG;
    IFS0CLR = _IFS0_U1RXIF_MASK;
}

// 2. Verificar interrupción habilitada
void UART_EnableRX_Interrupt(void) {
    // Habilitar interrupt en peripheral
    U1STASET = _U1STA_URXEN_MASK;

    // Clear flag
    IFS0CLR = _IFS0_U1RXIF_MASK;

    // Set priority
    IPC6CLR = _IPC6_U1IP_MASK;
    IPC6SET = (3 << _IPC6_U1IP_POSITION);  // Priority 3

    // Set subpriority
    IPC6CLR = _IPC6_U1IS_MASK;
    IPC6SET = (2 << _IPC6_U1IS_POSITION);  // Subpriority 2

    // Enable interrupt
    IEC0SET = _IEC0_U1RXIE_MASK;

    // Verify
    if (IEC0 & _IEC0_U1RXIE_MASK) {
        UART_WriteString("UART RX interrupt enabled\r\n");
    } else {
        UART_WriteString("ERROR: Failed to enable interrupt!\r\n");
    }
}

// 3. Verificar interrupciones globales habilitadas
__builtin_enable_interrupts();

// 4. Verificar vector correcto
// Ver device datasheet para vector numbers
// PIC32MZ: UART1 RX = vector 32
```

### ISR Se Ejecuta Constantemente

```c
// PROBLEMA: ISR ejecuta en loop infinito

// CAUSA COMÚN: Flag no se limpia

void __ISR(_TIMER_1_VECTOR) Timer_Handler(void) {
    // ... código ...

    // ❌ OLVIDÓ LIMPIAR FLAG
    // IFS0CLR = _IFS0_T1IF_MASK;  ← Falta esto!
}

// Resultado: ISR se re-ejecuta inmediatamente → sistema colgado

// ✅ SOLUCIÓN: Siempre limpiar flag
void __ISR(_TIMER_1_VECTOR) Timer_Handler(void) {
    // ... código ...

    IFS0CLR = _IFS0_T1IF_MASK;  // Clear interrupt flag
}
```

### Context Corruption

```c
// PROBLEMA: Variables se corrompen después de ISR

volatile uint16_t sensor_value;

void ReadSensor(void) {
    sensor_value = ADC_Read(0);  // Lee 12 bits (0-4095)
}

void __ISR(_TIMER_1_VECTOR) Timer_Handler(void) {
    sensor_value = ADC_Read(0);  // ISR también modifica!
    IFS0CLR = _IFS0_T1IF_MASK;
}

// PROBLEMA: Si ISR interrumpe ReadSensor(), valor se pierde

// ✅ SOLUCIÓN 1: Deshabilitar interrupts durante acceso
void ReadSensor(void) {
    __builtin_disable_interrupts();
    sensor_value = ADC_Read(0);
    __builtin_enable_interrupts();
}

// ✅ SOLUCIÓN 2: Variables separadas
uint16_t sensor_value_main;
volatile uint16_t sensor_value_isr;

void ReadSensor(void) {
    sensor_value_main = ADC_Read(0);
}

void __ISR(_TIMER_1_VECTOR) Timer_Handler(void) {
    sensor_value_isr = ADC_Read(0);
    IFS0CLR = _IFS0_T1IF_MASK;
}

// En main: Copiar con protección
__builtin_disable_interrupts();
sensor_value_main = sensor_value_isr;
__builtin_enable_interrupts();
```

---

## 11. Debugging con MPLAB X

### Breakpoints

```c
// 1. Breakpoint simple
void process_data(uint16_t value) {
    // ← Click en margen izquierdo para breakpoint
    if (value > 1000) {
        handle_high_value();
    }
}

// 2. Conditional breakpoint
// Click derecho en breakpoint → Properties
// Condition: value > 2000
// Solo se detiene si condición es verdadera

// 3. Breakpoint con hit count
// Properties → Hit Count: Break after 10 hits
// Útil para loops: Detener en iteración específica
```

### Watch Variables

```
// Window → Debugging → Variables

Agregar:
- sensor_value
- buffer[0..15]  // Ver array completo
- *ptr           // Dereferencing puntero
- struct_var.field  // Campo de struct
```

### Step Execution

```
F7  - Step Into: Entra en función
F8  - Step Over: Ejecuta función completa
F11 - Step Out: Sale de función actual
F5  - Continue: Continúa hasta próximo breakpoint
```

### Memory View

```
// Window → PIC Memory Views → File Registers

Ver contenido de:
- Registros periféricos (U1MODE, U1STA, etc)
- Variables específicas
- Arrays completos
- Región de memoria

// Ejemplo: Ver UART registers
Buscar: U1MODE
Ver:
  U1MODE: 0x8000  (bit 15 = ON)
  U1STA:  0x1400  (TX y RX enabled)
  U1BRG:  0x0035  (Baudrate)
```

### Call Stack

```
// Window → Debugging → Call Stack

Muestra:
main() → ProcessData() → CalculateValue() ← Aquí está
                                              ^
                                              Detiene aquí

// Útil para ver cómo llegó a función actual
```

---

## 12. Debugging sin Debugger

### Printf Debugging

```c
// Técnica clásica: Imprimir valores para diagnosticar

void ProcessSensor(void) {
    uint16_t raw = ADC_Read(0);
    UART_Printf("DEBUG: ADC raw = %u\r\n", raw);  // ← Agregar prints

    float voltage = (raw * 3.3f) / 4095.0f;
    UART_Printf("DEBUG: voltage = %.2f V\r\n", voltage);

    if (voltage > 2.5f) {
        UART_WriteString("DEBUG: Over threshold\r\n");
        trigger_alarm();
    }
}

// Output:
// DEBUG: ADC raw = 3000
// DEBUG: voltage = 2.42 V
// ← No imprime "Over threshold" → problema en threshold
```

### Assert Macros

```c
// Detectar condiciones inválidas

#define ASSERT(cond) \
    if (!(cond)) { \
        UART_Printf("ASSERT FAIL: %s:%d: %s\r\n", __FILE__, __LINE__, #cond); \
        while(1) GPIO_Toggle(LED_ERROR);  /* Blink error LED */ \
    }

// Uso:
ASSERT(buffer != NULL);
ASSERT(index < BUFFER_SIZE);
ASSERT(temperature > -40 && temperature < 125);

// Output si falla:
// ASSERT FAIL: main.c:123: index < BUFFER_SIZE
```

### Post-Mortem Analysis

```c
// Guardar estado antes de crash

typedef struct {
    uint32_t pc;           // Program counter
    uint32_t sp;           // Stack pointer
    uint32_t error_code;
    uint32_t timestamp;
    char message[64];
} CrashReport_t;

CrashReport_t crash_report __attribute__((persistent));

void save_crash_report(uint32_t error, const char* msg) {
    crash_report.pc = _CP0_GET_EPC();  // Exception PC
    crash_report.sp = (uint32_t)__builtin_frame_address(0);
    crash_report.error_code = error;
    crash_report.timestamp = TIMER_GetMillis();
    strncpy(crash_report.message, msg, sizeof(crash_report.message) - 1);

    // Forzar reset
    SYSKEY = 0x00000000;
    SYSKEY = 0xAA996655;
    SYSKEY = 0x556699AA;
    RSWRSTSET = 1;
    uint16_t dummy = RSWRST;
    while(1);
}

void check_crash_report(void) {
    if (crash_report.error_code != 0) {
        UART_Printf("=== CRASH REPORT ===\r\n");
        UART_Printf("Error code: %lu\r\n", crash_report.error_code);
        UART_Printf("PC: 0x%08lX\r\n", crash_report.pc);
        UART_Printf("SP: 0x%08lX\r\n", crash_report.sp);
        UART_Printf("Time: %lu ms\r\n", crash_report.timestamp);
        UART_Printf("Message: %s\r\n", crash_report.message);

        // Clear report
        crash_report.error_code = 0;
    }
}

void main(void) {
    UART_Init(115200);
    check_crash_report();  // Primera línea en main

    // ... resto del código ...
}

// Uso:
if (critical_error) {
    save_crash_report(ERR_CRITICAL, "Sensor timeout");
    // Sistema se resetea y muestra crash report al arrancar
}
```

---

## 13. Herramientas de Diagnóstico

### Logic Analyzer

```
Herramienta: Saleae Logic, DSLogic, etc

Uso típico:
1. Conectar probes a señales digitales (SDA, SCL, TX, RX, CS, SCK, MOSI, MISO)
2. Configurar sample rate (típico: 24 MHz para protocolos rápidos)
3. Configurar decoder (I2C, SPI, UART, etc)
4. Capturar comunicación
5. Analizar protocolo

Ejemplo: Diagnosticar I2C

Captura muestra:
  SDA: ___┐┌─┐┌┐┐┌─┐┌┐┐┌─...
  SCL: ___┘└┐└┘└┘└┐└┘└┘└┐...

Decoder muestra:
  START → 0x48 (W) ACK → 0x01 ACK → STOP
         ^^^^^^         ^^^^
        Address       Register

  → Confirma: Dirección correcta, dispositivo responde (ACK)

  Si muestra NACK → Dispositivo no responde (problema hardware o dirección)
```

### Osciloscopio

```
Mediciones típicas:

1. Verificar clock crystal
   - Probe en OSC2
   - Medir frecuencia: ¿Coincide con crystal? (ej: 8.000 MHz)
   - Amplitud: Debe ser >1V pico-pico
   - Si no oscila → Problema en crystal, load caps, o configuración

2. Verificar señales SPI
   - CH1: CLK
   - CH2: MOSI
   - CH3: CS

   Verificar:
   - CLK toggle durante transferencia
   - MOSI cambia datos
   - CS activa (LOW) durante transferencia
   - Timing: Setup/hold time según datasheet

3. Medir tiempos críticos
   - Pulsos PWM: Duty cycle correcto?
   - Delays: Duración real vs esperada?
   - ISR latency: Tiempo entre evento → inicio ISR

4. Detectar glitches
   - Modo: Single shot
   - Trigger: Edge con holdoff
   - Ver si hay pulsos inesperados en señales
```

### Terminal Serial (PuTTY, Tera Term, etc)

```
Configuración:
- Port: COMx (Windows) o /dev/ttyUSBx (Linux)
- Baud rate: 115200
- Data bits: 8
- Stop bits: 1
- Parity: None
- Flow control: None

Uso:
1. Recibir mensajes debug del MCU
2. Enviar comandos al MCU
3. Ver logs en tiempo real

Tips:
- Agregar timestamp a cada línea (útil para timing)
- Guardar log a archivo
- Usar colores para diferentes niveles (INFO, WARNING, ERROR)
```

---

## 14. Casos Prácticos Resueltos

### Caso 1: Sistema Se Resetea Aleatoriamente

**Síntomas:**
- Sistema funciona 10-30 segundos, luego se resetea
- Reset ocurre más frecuentemente bajo carga (WiFi activo)
- Sin patrón predecible

**Diagnóstico Paso a Paso:**

```c
// PASO 1: Identificar tipo de reset
void main(void) {
    UART_Init(115200);

    if (RCONbits.WDTO) {
        UART_WriteString("Reset: Watchdog\r\n");
    } else if (RCONbits.BOR) {
        UART_WriteString("Reset: Brown-out\r\n");
    } else if (RCONbits.SWR) {
        UART_WriteString("Reset: Software\r\n");
    } else {
        UART_WriteString("Reset: Power-on\r\n");
    }

    RCONbits.WDTO = 0;
    RCONbits.BOR = 0;
    RCONbits.SWR = 0;
}

// Resultado: "Reset: Watchdog" → Watchdog timeout

// PASO 2: ¿Watchdog configurado intencionalmente?
// No → Stack overflow probable (triggera exception que causa WDT reset)

// PASO 3: Medir stack usage
extern uint32_t _stack;
extern uint32_t _min_stack_size;

void check_stack_usage(void) {
    uint32_t sp = (uint32_t)__builtin_frame_address(0);
    uint32_t stack_used = (uint32_t)&_stack - sp;
    uint32_t stack_total = (uint32_t)&_min_stack_size;

    UART_Printf("Stack: %lu / %lu bytes (%.1f%%)\r\n",
                stack_used, stack_total,
                (stack_used * 100.0f) / stack_total);

    if (stack_used > stack_total * 0.9) {
        UART_WriteString("WARNING: Stack >90%!\r\n");
    }
}

// Llamar antes de funciones grandes
void WiFi_Connect(void) {
    check_stack_usage();  // "Stack: 1950 / 2048 bytes (95.2%)" → PROBLEMA!
    // ...
}

// PASO 4: Analizar funciones con mayor stack
// WiFi_Connect() usa buffers grandes:
void WiFi_Connect(void) {
    char http_request[512];   // 512 bytes
    char http_response[1024]; // 1024 bytes
    // Total: ~1.5 KB solo en esta función!
}
```

**Causa Raíz:**
Stack overflow en `WiFi_Connect()` por buffers locales grandes

**Solución:**

```c
// Opción 1: Aumentar stack size
// En linker script:
// _min_stack_size = 2048;  // ANTES
_min_stack_size = 4096;  // DESPUÉS

// Opción 2: Usar buffers estáticos (no en stack)
static char http_request[512];
static char http_response[1024];

void WiFi_Connect(void) {
    // Usar buffers estáticos
}

// Opción 3: Malloc (heap)
void WiFi_Connect(void) {
    char* http_request = malloc(512);
    char* http_response = malloc(1024);

    if (http_request == NULL || http_response == NULL) {
        free(http_request);
        free(http_response);
        return false;
    }

    // ... usar buffers ...

    free(http_request);
    free(http_response);
}
```

**Verificación:**
Sistema funciona >24 horas sin resets → RESUELTO

---

### Caso 2: UART Recibe Datos Corruptos

**Síntomas:**
- TX funciona correctamente
- RX recibe "basura" (caracteres aleatorios)
- A veces caracteres correctos mezclados con incorrectos

**Diagnóstico:**

```c
// PASO 1: Test de loopback
// Conectar TX → RX directamente
UART_WriteString("TEST");
TIMER_Delay(10);

char buffer[5];
for (uint8_t i = 0; i < 4; i++) {
    if (UART_Available()) {
        buffer[i] = UART_ReadChar();
    }
}
buffer[4] = '\0';

UART_Printf("Loopback received: %s\r\n", buffer);
// Resultado: "T�S�" → Corrupción confirmada incluso en loopback

// PASO 2: Verificar baudrate error
uint32_t PBCLK = 100000000UL;  // 100 MHz
uint32_t target_baud = 115200;
uint32_t brg = (PBCLK / (16 * target_baud)) - 1;
uint32_t actual_baud = PBCLK / (16 * (brg + 1));

int32_t error = actual_baud - target_baud;
float error_percent = (abs(error) * 100.0f) / target_baud;

UART_Printf("BRG: %lu\r\n", brg);           // BRG: 53
UART_Printf("Target: %lu\r\n", target_baud);  // Target: 115200
UART_Printf("Actual: %lu\r\n", actual_baud);  // Actual: 115740
UART_Printf("Error: %.2f%%\r\n", error_percent);  // Error: 0.47%
// 0.47% < 2% → Baudrate OK

// PASO 3: Verificar framing errors
if (U1STA & _U1STA_FERR_MASK) {
    UART_WriteString("ERROR: Framing error!\r\n");  // ← Detectado!
}

// PASO 4: Verificar overrun
if (U1STA & _U1STA_OERR_MASK) {
    UART_WriteString("ERROR: Overrun!\r\n");
}
```

**Causa Raíz:**
Framing errors por problema de clock

**Diagnóstico Profundo:**

```c
// Verificar configuración de clock
// PBCLK debe ser 100 MHz, pero...

uint32_t pbclk = SYSTEMConfigPerformance(200000000UL);
UART_Printf("PBCLK: %lu Hz\r\n", pbclk);  // PBCLK: 50000000 Hz (50 MHz!)

// ← PROBLEMA: PBCLK es 50 MHz, no 100 MHz!
// BRG calculado para 100 MHz está WRONG
```

**Solución:**

```c
// Opción 1: Corregir PBCLK divider
// PBCLK = SYSCLK / PB_DIV
// Cambiar PB_DIV de 4 a 2

PB2DIVbits.PBDIV = 0b000001;  // Divide by 2 → PBCLK = 100 MHz

// Opción 2: Recalcular BRG para PBCLK real
uint32_t PBCLK = 50000000UL;  // 50 MHz real
uint32_t target_baud = 115200;
uint32_t brg = (PBCLK / (16 * target_baud)) - 1;  // BRG = 26

U1BRG = brg;
```

**Verificación:**
UART recibe datos correctamente → RESUELTO

---

### Caso 3: I2C Sensor No Responde

**Síntomas:**
- I2C_Write() retorna NACK
- Sensor funcionó previamente
- Mismo código, nuevo PCB

**Diagnóstico:**

```c
// PASO 1: Scanner I2C
void I2C_Scanner(void) {
    UART_WriteString("Scanning I2C bus...\r\n");

    uint8_t found = 0;
    for (uint8_t addr = 0x08; addr < 0x78; addr++) {
        I2C_Start();
        bool ack = I2C_Write(addr << 1 | 0);
        I2C_Stop();

        if (ack) {
            UART_Printf("Device found at 0x%02X\r\n", addr);
            found++;
        }
        TIMER_Delay(1);
    }

    if (found == 0) {
        UART_WriteString("No devices found!\r\n");  // ← Ningún dispositivo!
    }
}

// PASO 2: Verificar señales con multímetro
// Medir voltaje en SDA y SCL en reposo
// SDA: 0.2V  ← PROBLEMA: Debería estar en ~3.3V
// SCL: 0.3V  ← PROBLEMA: Debería estar en ~3.3V

// PASO 3: Verificar pull-ups
// Medir resistencia SDA → VDD: ∞ (infinito)
// Medir resistencia SCL → VDD: ∞ (infinito)
// ← Faltantes pull-ups!

// PASO 4: Revisar schematic
// Pull-ups R10 y R11 (4.7kΩ) presentes en schematic
// PERO... componentes marcados como DNP (Do Not Place) en PCB
```

**Causa Raíz:**
Pull-ups I2C no poblados en PCB

**Solución:**

```
Opción 1: Soldar resistencias pull-up
- R10: 4.7kΩ entre SDA y VDD
- R11: 4.7kΩ entre SCL y VDD

Opción 2: Temporalmente, usar pull-ups internos (si MCU tiene)
// PIC32 no tiene pull-ups internos suficientemente fuertes para I2C
// Solución temporal: Resistencias externas temporales

Opción 3: Usar otro par de pines con hardware I2C que tenga pull-ups
```

**Verificación:**
```c
// Después de soldar pull-ups
// Multímetro:
// SDA: 3.28V ✅
// SCL: 3.27V ✅

// Scanner:
I2C_Scanner();
// Output:
// Scanning I2C bus...
// Device found at 0x48  ← Sensor detectado!
```

→ RESUELTO

---

### Caso 4: Consumo Excesivo de CPU

**Síntomas:**
- CPU usage 95-100% constante
- Sistema responde lento
- Batería se descarga rápido

**Diagnóstico:**

```c
// PASO 1: Profiling básico
typedef struct {
    const char* name;
    uint32_t start_time;
    uint32_t total_time;
    uint32_t call_count;
} ProfileEntry_t;

#define MAX_PROFILE_ENTRIES 10
ProfileEntry_t profile_table[MAX_PROFILE_ENTRIES];
uint8_t profile_count = 0;

void profile_start(const char* name) {
    for (uint8_t i = 0; i < profile_count; i++) {
        if (strcmp(profile_table[i].name, name) == 0) {
            profile_table[i].start_time = TIMER_GetMicros();
            return;
        }
    }

    // Nuevo entry
    if (profile_count < MAX_PROFILE_ENTRIES) {
        profile_table[profile_count].name = name;
        profile_table[profile_count].start_time = TIMER_GetMicros();
        profile_table[profile_count].total_time = 0;
        profile_table[profile_count].call_count = 0;
        profile_count++;
    }
}

void profile_end(const char* name) {
    uint32_t now = TIMER_GetMicros();

    for (uint8_t i = 0; i < profile_count; i++) {
        if (strcmp(profile_table[i].name, name) == 0) {
            profile_table[i].total_time += (now - profile_table[i].start_time);
            profile_table[i].call_count++;
            return;
        }
    }
}

void profile_report(void) {
    UART_WriteString("\r\n=== PROFILE REPORT ===\r\n");
    for (uint8_t i = 0; i < profile_count; i++) {
        uint32_t avg_us = profile_table[i].total_time / profile_table[i].call_count;
        UART_Printf("%s: %lu calls, avg %lu us\r\n",
                    profile_table[i].name,
                    profile_table[i].call_count,
                    avg_us);
    }
}

// Instrumentar código
LOOP {
    profile_start("ReadSensors");
    ReadSensors();
    profile_end("ReadSensors");

    profile_start("UpdateDisplay");
    UpdateDisplay();
    profile_end("UpdateDisplay");

    profile_start("CheckButtons");
    CheckButtons();
    profile_end("CheckButtons");

    static uint32_t last_report = 0;
    if (TIMER_GetMillis() - last_report > 10000) {
        profile_report();
        last_report = TIMER_GetMillis();
    }
}

// Output:
// === PROFILE REPORT ===
// ReadSensors: 1000 calls, avg 250 us
// UpdateDisplay: 1000 calls, avg 5000 us
// CheckButtons: 1000 calls, avg 12000 us  ← PROBLEMA!
```

**Análisis:**
`CheckButtons()` toma 12 ms por llamada, se llama cada loop → 100% CPU

**Causa Raíz:**

```c
// Código actual (MALO)
void CheckButtons(void) {
    // Polling de 4 botones con delay
    for (uint8_t i = 0; i < 4; i++) {
        if (GPIO_Read(button_pins[i]) == 0) {
            TIMER_Delay(50);  // Debounce → 50ms per button!
            if (GPIO_Read(button_pins[i]) == 0) {
                HandleButton(i);
            }
        }
    }
}
// 4 botones × 50ms = 200ms potencial
// PERO medir mostró 12ms promedio → aún mucho
```

**Solución:**

```c
// Versión optimizada (interrupt-driven)
volatile uint8_t button_events = 0;

void __ISR(_CHANGE_NOTICE_VECTOR) ButtonChange_Handler(void) {
    // Detectar cuál botón cambió
    static uint8_t last_state = 0xFF;
    uint8_t current_state = (GPIO_Read(BTN0) << 0) |
                            (GPIO_Read(BTN1) << 1) |
                            (GPIO_Read(BTN2) << 2) |
                            (GPIO_Read(BTN3) << 3);

    uint8_t changed = last_state ^ current_state;
    button_events |= changed & ~current_state;  // Falling edge

    last_state = current_state;

    // Clear CN interrupt flag
    CNFCLR = 0xFFFF;
    IFS1CLR = _IFS1_CNIF_MASK;
}

void CheckButtons(void) {
    if (button_events) {
        for (uint8_t i = 0; i < 4; i++) {
            if (button_events & (1 << i)) {
                button_events &= ~(1 << i);
                HandleButton(i);
            }
        }
    }
}

// Nuevo profile:
// CheckButtons: 1000 calls, avg 15 us  ← 800x más rápido!
```

**Verificación:**
CPU usage: 5% → RESUELTO

---

## 15. Checklists de Diagnóstico

### Pre-Compilation Checklist

```
□ Código
  □ Todos los archivos guardados
  □ Includes correctos
  □ Prototipos de funciones
  □ No warnings del compilador

□ Configuración
  □ Device correcto seleccionado
  □ Clock configuration correcta
  □ Optimization level apropiado
  □ Linker script correcto

□ Periféricos
  □ Pines asignados correctamente
  □ No conflictos de pines
  □ Peripherals habilitados

□ Memoria
  □ Programa cabe en flash
  □ Variables caben en RAM
  □ Stack size suficiente
  □ Heap size suficiente (si se usa)
```

### Hardware Checklist

```
□ Alimentación
  □ VDD = 3.3V ±10%
  □ Corriente suficiente
  □ Capacitores desacoplo
  □ Sin ruido en alimentación

□ Clock
  □ Crystal oscilando
  □ Frecuencia correcta
  □ Load capacitors correctos

□ Reset
  □ MCLR con pull-up
  □ No resets espontáneos
  □ Reset button funcional

□ Conexiones
  □ No cortos (multímetro continuidad)
  □ Soldaduras correctas
  □ Cables no sueltos
  □ GND común entre dispositivos

□ Señales
  □ Niveles lógicos correctos (3.3V o 5V)
  □ Pull-ups donde necesario (I2C, etc)
  □ No crosstalk entre señales
```

### Software Checklist

```
□ Inicialización
  □ Periféricos inicializados
  □ En orden correcto
  □ Return values verificados

□ Interrupts
  □ ISR definidas correctamente
  □ Flags se limpian
  □ Prioridades configuradas
  □ Globales habilitadas

□ Comunicación
  □ Baudrate correcto
  □ Protocolo correcto (mode, parity, etc)
  □ Timeouts implementados
  □ Error handling

□ Timing
  □ Delays apropiados
  □ Deadlines se cumplen
  □ No busy-wait loops largos
```

### Performance Checklist

```
□ CPU
  □ Usage <80%
  □ Funciones críticas optimizadas
  □ No polling innecesario

□ Memoria
  □ Stack usage <80%
  □ Heap usage <80%
  □ No memory leaks
  □ Buffers tamaño apropiado

□ Timing
  □ ISR latency acceptable
  □ Task deadlines met
  □ Jitter acceptable

□ Power
  □ Consumo dentro de spec
  □ Sleep modes usados
  □ Periféricos off cuando no se usan
```

---

## 🎯 Resumen

El debugging efectivo combina:
1. **Metodología sistemática**: Divide and conquer
2. **Herramientas apropiadas**: Debugger, logic analyzer, osciloscopio
3. **Experiencia**: Reconocer patrones de errores comunes
4. **Paciencia**: Proceso iterativo de hipótesis → verificación
5. **Documentación**: Registrar soluciones para futuros problemas

**Regla de oro:** Si estás "stuck" >30 minutos, toma un break. Perspectiva fresca ayuda.

---

**Progreso del Manual:**
- Capítulo: 36/38 (94.74%)
- Sección 7: 2/4 (50%)

**Próximo capítulo:** Cap. 37 - Glosario Completo

---

*Troubleshooting Guide EMIC SDK - v1.0*
*EMIC SDK Development Manual - Section 7*
