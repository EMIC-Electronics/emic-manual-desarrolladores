# Capítulo 31: Optimización Avanzada

## Índice
1. [Introducción a la Optimización](#1-introducción-a-la-optimización)
2. [Optimización de Memoria RAM](#2-optimización-de-memoria-ram)
3. [Optimización de Memoria Flash](#3-optimización-de-memoria-flash)
4. [Compiler Optimizations](#4-compiler-optimizations)
5. [Assembly Optimization](#5-assembly-optimization)
6. [Interrupt Optimization](#6-interrupt-optimization)
7. [DMA Usage Patterns](#7-dma-usage-patterns)
8. [Algoritmos y Estructuras de Datos](#8-algoritmos-y-estructuras-de-datos)
9. [Power Optimization](#9-power-optimization)
10. [I/O Optimization](#10-io-optimization)
11. [Profiling y Measurement](#11-profiling-y-measurement)
12. [Case Study Completo](#12-case-study-completo)
13. [Best Practices](#13-best-practices)

---

## 1. Introducción a la Optimización

### 1.1 ¿Por Qué Optimizar?

La optimización en sistemas embebidos es **crítica** por las restricciones de recursos:

```
╔══════════════════════════════════════════════════════════╗
║         RESTRICCIONES EN SISTEMAS EMBEBIDOS              ║
╠══════════════════════════════════════════════════════════╣
║  ⚡ Memoria RAM limitada    (2-512 KB típico)           ║
║  💾 Memoria Flash limitada  (32-2048 KB típico)         ║
║  ⏱️  CPU speed limitada      (8-200 MHz típico)          ║
║  🔋 Batería limitada        (días/meses de autonomía)   ║
║  💵 Costo por unidad        (cada byte cuenta)          ║
╚══════════════════════════════════════════════════════════╝
```

**Razones para optimizar:**

1. **Recursos limitados**: Cumplir con constraints de hardware
2. **Performance**: Respuesta en tiempo real
3. **Autonomía**: Maximizar vida de batería
4. **Costo**: Usar MCU más económico
5. **Escalabilidad**: Agregar features sin cambiar hardware

### 1.2 Trade-offs Fundamentales

```
      VELOCIDAD
          ↑
          |
    ←─────┼─────→  TAMAÑO
          |
          ↓
       CONSUMO
```

**No se puede optimizar todo simultáneamente:**

| Objetivo | Beneficio | Trade-off |
|----------|-----------|-----------|
| **Velocidad** | Ejecución más rápida | Mayor tamaño de código, mayor consumo |
| **Tamaño** | Menos Flash/RAM | Ejecución más lenta |
| **Consumo** | Mayor autonomía | Menor velocidad, código más complejo |

**Ejemplo real:**

```c
// Opción 1: VELOCIDAD (lookup table)
const uint16_t sin_lut[360] = { 0, 17, 34, ... };  // 720 bytes Flash
uint16_t fast_sin(uint16_t angle) {
    return sin_lut[angle % 360];  // ~10 ciclos
}

// Opción 2: TAMAÑO (cálculo)
uint16_t small_sin(uint16_t angle) {
    return (uint16_t)(sin(angle * 3.14159 / 180.0) * 1000);  // ~500 ciclos, 0 bytes Flash extra
}

// Opción 3: BALANCEADO (LUT pequeña + interpolación)
const uint16_t sin_lut_small[91] = { 0, 17, 34, ... };  // 182 bytes Flash
uint16_t balanced_sin(uint16_t angle) {
    // Interpolación lineal entre puntos
    // ~50 ciclos, 182 bytes Flash
}
```

### 1.3 Metodología: Measure, Optimize, Verify

```
╔════════════════════════════════════════════════════════╗
║           PROCESO DE OPTIMIZACIÓN                      ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║  1. MEASURE (Medir)                                   ║
║     └─ Identificar cuellos de botella                 ║
║     └─ Profiling de código                            ║
║     └─ Análisis de memoria                            ║
║                                                        ║
║  2. OPTIMIZE (Optimizar)                              ║
║     └─ Aplicar técnica específica                     ║
║     └─ Enfocarse en hot paths (80/20 rule)           ║
║     └─ Una optimización a la vez                      ║
║                                                        ║
║  3. VERIFY (Verificar)                                ║
║     └─ Medir nuevamente                               ║
║     └─ Validar funcionalidad (testing)                ║
║     └─ Comparar con baseline                          ║
║                                                        ║
║  4. ITERATE                                           ║
║     └─ Repetir proceso                                ║
║     └─ Documentar cambios                             ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
```

**Regla de Pareto (80/20):**
- El **80% del tiempo** se ejecuta en el **20% del código**
- **Optimizar ese 20% crítico** → Máximo impacto

### 1.4 Profiling Tools

**Herramientas para medir:**

| Tool | Qué Mide | Uso |
|------|----------|-----|
| **MPLAB X Profiler** | Ciclos por función | Timing detallado |
| **Stopwatch (Timer)** | Tiempo de ejecución | Macro-profiling |
| **GPIO toggling** | Timing con osciloscopio | ISR, eventos críticos |
| **Memory Reports** | RAM/Flash usage | Linker output |
| **Logic Analyzer** | Timing de I/O | Protocolos, señales |

---

## 2. Optimización de Memoria RAM

### 2.1 Memory Layout

**Layout típico de RAM:**

```
╔═══════════════════════════════════════════════════════╗
║               MEMORIA RAM - PIC32                     ║
╠═══════════════════════════════════════════════════════╣
║  0x80000000                                           ║
║  ┌─────────────────────────────────────────┐         ║
║  │  .data (variables inicializadas)        │ ← Copia ║
║  │  uint32_t counter = 100;                │   Flash ║
║  ├─────────────────────────────────────────┤         ║
║  │  .bss (variables no inicializadas)      │         ║
║  │  uint8_t buffer[1024];                  │         ║
║  ├─────────────────────────────────────────┤         ║
║  │  HEAP (malloc, free)                    │         ║
║  │      ↓ Crece hacia abajo                │         ║
║  │         (dynamic allocation)            │         ║
║  │                                          │         ║
║  │         ...                              │         ║
║  │                                          │         ║
║  │      ↑ Crece hacia arriba                │         ║
║  │  STACK (funciones, variables locales)   │         ║
║  ├─────────────────────────────────────────┤         ║
║  │  Stack Guard (opcional)                 │         ║
║  └─────────────────────────────────────────┘         ║
║  0x8000FFFF (ejemplo 64 KB RAM)                      ║
╚═══════════════════════════════════════════════════════╝
```

**Optimizaciones:**

1. **Minimizar .data** → menos copia desde Flash al inicio
2. **Usar .bss** para buffers grandes → no ocupan Flash
3. **Evitar heap (malloc)** → usar memory pools
4. **Stack dimensionado correctamente** → ni muy grande ni muy pequeño

### 2.2 Stack Size Optimization

**Problema:** Stack overflow (difícil de detectar)

```c
// ❌ MAL - Stack overflow riesgo
void deep_recursion(uint32_t n) {
    uint8_t local_buffer[512];  // 512 bytes en stack
    if (n > 0) {
        deep_recursion(n - 1);  // Cada llamada usa 512 bytes!
    }
}

// ✅ BIEN - Buffer estático
static uint8_t shared_buffer[512];  // En .bss, no en stack
void optimized_function(uint32_t n) {
    // Usar shared_buffer (solo 1 instancia)
}
```

**Calcular stack size necesario:**

```c
// Análisis de call chain más profunda:
// main() → task_process() → sensor_read() → i2c_transaction()

// Estimación:
// main():            20 bytes (vars locales)
// task_process():    50 bytes (buffer temporal)
// sensor_read():     30 bytes
// i2c_transaction(): 40 bytes
// ISR (worst case):  80 bytes
// Overhead (15%):    33 bytes
// ─────────────────────────────
// TOTAL:            253 bytes

// Stack size recomendado: 512 bytes (margen 2x)
```

**Configurar stack en linker script:**

```ld
/* Linker script (PIC32) */
_min_stack_size = 512;  /* Mínimo stack size */
```

### 2.3 Heap Management

**Evitar malloc/free en sistemas críticos:**

```c
// ❌ MAL - Fragmentación de heap
void process_data(void) {
    uint8_t* buffer = (uint8_t*)malloc(256);  // Fragmentación!
    // ... usar buffer ...
    free(buffer);
}

// ✅ BIEN - Memory pool (preallocado)
#define POOL_SIZE 10
#define BUFFER_SIZE 256

typedef struct {
    uint8_t data[BUFFER_SIZE];
    bool in_use;
} MemBlock_t;

static MemBlock_t memory_pool[POOL_SIZE];

MemBlock_t* pool_alloc(void) {
    for (uint8_t i = 0; i < POOL_SIZE; i++) {
        if (!memory_pool[i].in_use) {
            memory_pool[i].in_use = true;
            return &memory_pool[i];
        }
    }
    return NULL;  // Pool agotado
}

void pool_free(MemBlock_t* block) {
    if (block != NULL) {
        block->in_use = false;
    }
}
```

**Ventajas del memory pool:**
- ✅ No fragmentación
- ✅ Tiempo de allocación predecible (O(1))
- ✅ Fácil debugging (número fijo de bloques)
- ✅ Sin overhead de malloc/free

### 2.4 Variable Placement y Packing

**Alignment y padding:**

```c
// ❌ MAL - Desperdicio de memoria por padding
struct BadStruct {
    uint8_t  a;  // 1 byte
                 // 3 bytes padding (alignment a 4 bytes)
    uint32_t b;  // 4 bytes
    uint8_t  c;  // 1 byte
                 // 3 bytes padding
};  // Total: 12 bytes (50% desperdicio!)

// ✅ BIEN - Ordenar por tamaño descendente
struct GoodStruct {
    uint32_t b;  // 4 bytes
    uint8_t  a;  // 1 byte
    uint8_t  c;  // 1 byte
                 // 2 bytes padding
};  // Total: 8 bytes (25% desperdicio)

// ✅ MEJOR - Usar __attribute__((packed))
struct __attribute__((packed)) OptimalStruct {
    uint8_t  a;  // 1 byte
    uint32_t b;  // 4 bytes (sin padding!)
    uint8_t  c;  // 1 byte
};  // Total: 6 bytes (0% desperdicio)
// NOTA: Puede ser más lento en algunos MCUs (acceso no alineado)
```

**Bitfields para flags:**

```c
// ❌ MAL - 8 bytes para 8 flags
typedef struct {
    bool flag1;
    bool flag2;
    bool flag3;
    bool flag4;
    bool flag5;
    bool flag6;
    bool flag7;
    bool flag8;
} Flags_Bad_t;  // 8 bytes

// ✅ BIEN - 1 byte para 8 flags
typedef struct {
    uint8_t flag1 : 1;
    uint8_t flag2 : 1;
    uint8_t flag3 : 1;
    uint8_t flag4 : 1;
    uint8_t flag5 : 1;
    uint8_t flag6 : 1;
    uint8_t flag7 : 1;
    uint8_t flag8 : 1;
} Flags_Good_t;  // 1 byte (87.5% ahorro!)
```

### 2.5 Buffer Optimization

**Ring buffer eficiente:**

```c
// Ring buffer con size potencia de 2 (optimización con AND mask)
#define RING_SIZE 256  // Potencia de 2
#define RING_MASK (RING_SIZE - 1)

typedef struct {
    uint8_t buffer[RING_SIZE];
    volatile uint16_t head;
    volatile uint16_t tail;
} RingBuffer_t;

// ✅ RÁPIDO - Usa AND mask en vez de modulo
void ring_push(RingBuffer_t* rb, uint8_t data) {
    rb->buffer[rb->head & RING_MASK] = data;  // AND es MUY rápido
    rb->head++;
}

uint8_t ring_pop(RingBuffer_t* rb) {
    uint8_t data = rb->buffer[rb->tail & RING_MASK];
    rb->tail++;
    return data;
}

// ❌ LENTO - Modulo es caro en CPU
void ring_push_slow(RingBuffer_t* rb, uint8_t data) {
    rb->buffer[rb->head % RING_SIZE] = data;  // Modulo = división (lento!)
    rb->head++;
}
```

### 2.6 Ejemplo Completo: Reducir RAM de 80% a 50%

**Aplicación original:**

```c
// ANTES: 40 KB RAM usada de 50 KB disponibles (80%)

// Problema 1: Múltiples buffers grandes en stack
void uart_process(void) {
    uint8_t rx_buffer[2048];  // 2 KB en stack! ❌
    uint8_t tx_buffer[2048];  // 2 KB en stack! ❌
    // ...
}

// Problema 2: Structs mal alineados
typedef struct {
    uint8_t id;      // 1 byte + 3 padding
    uint32_t value;  // 4 bytes
    uint8_t status;  // 1 byte + 3 padding
} SensorData_t;  // 12 bytes (array de 100 = 1200 bytes)

SensorData_t sensor_array[100];

// Problema 3: Heap fragmentado
void* ptrs[50];
void fragmentation_demo(void) {
    for (int i = 0; i < 50; i++) {
        ptrs[i] = malloc(random_size());  // Fragmentación! ❌
    }
}
```

**Aplicación optimizada:**

```c
// DESPUÉS: 25 KB RAM usada (50%) → Ahorro de 15 KB (37.5%)

// Solución 1: Buffers estáticos compartidos
static uint8_t shared_rx_buffer[2048];  // En .bss, no en stack ✅
static uint8_t shared_tx_buffer[2048];

void uart_process(void) {
    // Usar buffers estáticos (solo 4 bytes de punteros en stack)
}

// Solución 2: Struct optimizado
typedef struct {
    uint32_t value;  // 4 bytes
    uint8_t id;      // 1 byte
    uint8_t status;  // 1 byte
                     // 2 bytes padding (inevitable con alignment)
} SensorData_t;  // 8 bytes (array de 100 = 800 bytes → ahorro 400 bytes)

// Solución 3: Memory pool (sin fragmentación)
#define POOL_BLOCKS 50
typedef struct {
    uint8_t data[128];
    bool in_use;
} PoolBlock_t;

static PoolBlock_t memory_pool[POOL_BLOCKS];  // Preallocado, sin fragmentación ✅
```

**Resultado:**
```
ANTES: 40 KB / 50 KB (80%)
DESPUÉS: 25 KB / 50 KB (50%)
AHORRO: 15 KB (37.5% de reducción)
```

---

## 3. Optimización de Memoria Flash

### 3.1 Code Size Reduction Techniques

**Técnicas principales:**

1. **Eliminar código muerto** (dead code elimination)
2. **Usar funciones compartidas** (code reuse)
3. **Optimizar strings y literals**
4. **Link-time optimization (LTO)**
5. **Compilar con `-Os`** (optimize for size)

### 3.2 Dead Code Elimination

**Ejemplo:**

```c
// ❌ Código muerto (nunca se ejecuta)
void unused_function(void) {
    // Esta función nunca es llamada → ocupa Flash innecesariamente
}

#if 0
void disabled_code(void) {
    // Este código está deshabilitado pero aún ocupa espacio en algunos casos
}
#endif

// ✅ Solución: Eliminar con linker (--gc-sections)
```

**Configurar en XC32 (PIC32):**

```makefile
# Makefile
LDFLAGS += -Wl,--gc-sections  # Eliminar secciones no usadas

CFLAGS += -ffunction-sections  # Cada función en su propia sección
CFLAGS += -fdata-sections       # Cada variable en su propia sección
```

**Resultado:**
```
ANTES: 180 KB Flash (sin --gc-sections)
DESPUÉS: 150 KB Flash (con --gc-sections)
AHORRO: 30 KB (16.7%)
```

### 3.3 Function Inlining Strategies

```c
// ❌ Overhead de llamada a función
uint16_t add(uint16_t a, uint16_t b) {
    return a + b;
}

void process(void) {
    uint16_t result = add(x, y);  // Overhead: push args, call, return
}

// ✅ Inline para funciones pequeñas
static inline uint16_t add(uint16_t a, uint16_t b) {
    return a + b;
}
// Resultado: El compilador inserta el código directamente → sin overhead
```

**Guía de inlining:**

| Función | ¿Inline? | Razón |
|---------|----------|-------|
| < 3 líneas | ✅ Sí | Overhead > código |
| Llamada 1 vez | ✅ Sí | No hay duplicación |
| Llamada 100 veces | ❌ No | Duplicaría código 100x |
| Loop interno | ✅ Sí | Critical path |
| Funciones grandes | ❌ No | Explota el tamaño |

### 3.4 Literal Pool Optimization

```c
// ❌ Múltiples strings duplicados
void log_error(uint8_t code) {
    if (code == 1) printf("Error: Sensor timeout\n");
    if (code == 2) printf("Error: Sensor timeout\n");  // String duplicado!
    if (code == 3) printf("Error: Communication failed\n");
}

// ✅ Reutilizar strings
static const char* const error_messages[] = {
    "Error: Sensor timeout",
    "Error: Communication failed"
};

void log_error_optimized(uint8_t code) {
    printf("%s\n", error_messages[code]);
}
```

**Strings en Flash (no en RAM):**

```c
// ❌ String en RAM (ocupa RAM + Flash para inicializar)
const char message[] = "Hello World";  // En RAM

// ✅ String en Flash (solo Flash)
const char message[] __attribute__((space(prog))) = "Hello World";  // Solo Flash
// O en XC8:
const char message[] __attribute__((space(psv))) = "Hello World";
```

### 3.5 Linker Script Optimization

**Agrupar código por frecuencia de uso:**

```ld
/* Linker script - Agrupar código "hot" junto */
SECTIONS
{
    .text : {
        *(.text.main)           /* Código crítico primero */
        *(.text.isr_*)          /* ISRs */
        *(.text.hot_path)       /* Hot path functions */
        *(.text)                /* Resto del código */
    } > FLASH

    .text.cold : {
        *(.text.cold)           /* Código raramente usado al final */
        *(.text.init_once)      /* Inicialización (solo se ejecuta 1 vez) */
    } > FLASH
}
```

**Marcar funciones como "cold":**

```c
// Funciones raramente ejecutadas (inicialización, error handling)
void __attribute__((cold)) system_init_once(void) {
    // Solo se ejecuta 1 vez al inicio
}

void __attribute__((cold)) fatal_error_handler(void) {
    // Solo se ejecuta en caso de error crítico (raro)
}
```

### 3.6 Shared Code Sections

**Reutilizar código entre funciones:**

```c
// ❌ Código duplicado
void process_sensor_A(void) {
    uart_send_start();
    uart_send_data_A();
    uart_send_checksum();
    uart_send_end();
}

void process_sensor_B(void) {
    uart_send_start();      // Duplicado!
    uart_send_data_B();
    uart_send_checksum();   // Duplicado!
    uart_send_end();        // Duplicado!
}

// ✅ Factorizar código común
static void uart_send_frame(void (*send_data_fn)(void)) {
    uart_send_start();
    send_data_fn();  // Callback para parte específica
    uart_send_checksum();
    uart_send_end();
}

void process_sensor_A(void) {
    uart_send_frame(uart_send_data_A);
}

void process_sensor_B(void) {
    uart_send_frame(uart_send_data_B);
}
```

### 3.7 Ejemplo: Reducir Flash de 180 KB a 120 KB

**Estrategia aplicada:**

```
╔══════════════════════════════════════════════════════════╗
║        OPTIMIZACIÓN FLASH - CASO REAL                    ║
╠══════════════════════════════════════════════════════════╣
║  Técnica                          Ahorro                 ║
║  ──────────────────────────────   ──────────────         ║
║  1. Dead code elimination         -15 KB (8%)           ║
║  2. Link-time optimization (LTO)  -20 KB (11%)          ║
║  3. String pooling                -10 KB (6%)           ║
║  4. Function inlining (críticas)  -5 KB (3%)            ║
║  5. Compile con -Os               -10 KB (6%)           ║
║  ──────────────────────────────   ──────────────         ║
║  TOTAL AHORRO:                    -60 KB (33%)          ║
║  RESULTADO:                       120 KB                ║
╚══════════════════════════════════════════════════════════╝
```

**Configuración del proyecto:**

```makefile
# Makefile optimizado para size
CC = xc32-gcc

CFLAGS  = -Os                     # Optimize for size
CFLAGS += -flto                   # Link-time optimization
CFLAGS += -ffunction-sections     # Función por sección
CFLAGS += -fdata-sections         # Data por sección
CFLAGS += -fno-exceptions         # Sin excepciones C++
CFLAGS += -fno-unwind-tables      # Sin tablas de unwinding

LDFLAGS  = -Wl,--gc-sections      # Eliminar secciones no usadas
LDFLAGS += -flto                  # LTO en linking
LDFLAGS += -Wl,-Map=output.map    # Generar map file para análisis
```

---

## 4. Compiler Optimizations

### 4.1 Optimization Levels

| Level | Descripción | Velocidad | Tamaño | Debug |
|-------|-------------|-----------|--------|-------|
| **-O0** | Sin optimización | Lento | Grande | Fácil |
| **-O1** | Optimización básica | Medio | Medio | Posible |
| **-O2** | Optimización alta | Rápido | Grande | Difícil |
| **-O3** | Máxima optimización | Muy rápido | Muy grande | Muy difícil |
| **-Os** | Optimizar para size | Medio-lento | Pequeño | Difícil |
| **-Og** | Optimizado para debug | Medio | Medio | Fácil |

**Recomendaciones:**

```
Development:   -Og  (debugging fácil)
Testing:       -O1  (balance)
Production:    -O2  (performance)
Size-critical: -Os  (tamaño mínimo)
```

### 4.2 Link-Time Optimization (LTO)

**Sin LTO:** Cada archivo `.c` se optimiza independientemente

```
main.c  ──[gcc -O2]──> main.o  ──┐
sensor.c ──[gcc -O2]──> sensor.o ──┼──[ld]──> app.elf
uart.c  ──[gcc -O2]──> uart.o  ──┘
```

**Con LTO:** Optimización global en linking

```
main.c  ──[gcc -O2 -flto]──> main.o  ──┐
sensor.c ──[gcc -O2 -flto]──> sensor.o ──┼──[ld -flto]──> app.elf
uart.c  ──[gcc -O2 -flto]──> uart.o  ──┘                   ↑
                                                            │
                                            (Re-optimiza globalmente)
```

**Ventajas:**
- Inlining entre archivos diferentes
- Mejor dead code elimination
- Optimización de constantes globales
- 5-15% mejora típica

**Ejemplo:**

```c
// sensor.c
int sensor_read_internal(void) {
    return adc_read();  // Función pequeña
}

// main.c
#include "sensor.h"
int main(void) {
    int value = sensor_read_internal();  // Con LTO: se inline aunque esté en otro archivo
}
```

### 4.3 Function Attributes

```c
// always_inline: Forzar inline
static inline __attribute__((always_inline)) uint32_t critical_func(void) {
    return value * 2;
}

// noinline: Nunca inline (útil para debugging)
void __attribute__((noinline)) debug_helper(void) {
    // Queremos ver esta función en el stack trace
}

// hot: Optimizar agresivamente (función llamada frecuentemente)
void __attribute__((hot)) main_loop_task(void) {
    // Código crítico
}

// cold: Optimizar para size (función rara)
void __attribute__((cold)) error_handler(void) {
    // Solo se ejecuta en casos raros
}

// pure: Función sin side effects (permite optimizaciones agresivas)
int __attribute__((pure)) calculate_checksum(const uint8_t* data, size_t len) {
    // No modifica estado global, solo depende de argumentos
}

// const: Función sin side effects y no lee estado global
int __attribute__((const)) add(int a, int b) {
    return a + b;
}
```

### 4.4 Loop Unrolling

```c
// ❌ Loop sin unroll
void process_array(uint8_t* data, size_t len) {
    for (size_t i = 0; i < len; i++) {
        data[i] = data[i] * 2 + 1;
    }
}
// Overhead: comparación, incremento, branch en cada iteración

// ✅ Loop unrolling manual (factor 4)
void process_array_unrolled(uint8_t* data, size_t len) {
    size_t i = 0;

    // Procesar de a 4 elementos
    for (; i + 3 < len; i += 4) {
        data[i + 0] = data[i + 0] * 2 + 1;
        data[i + 1] = data[i + 1] * 2 + 1;
        data[i + 2] = data[i + 2] * 2 + 1;
        data[i + 3] = data[i + 3] * 2 + 1;
    }

    // Procesar elementos restantes
    for (; i < len; i++) {
        data[i] = data[i] * 2 + 1;
    }
}
// Resultado: 4x menos overhead de loop

// ✅ Dejar que el compilador lo haga
void process_array_auto(uint8_t* data, size_t len) {
    #pragma GCC unroll 4
    for (size_t i = 0; i < len; i++) {
        data[i] = data[i] * 2 + 1;
    }
}
```

### 4.5 Const Correctness

```c
// ❌ Sin const: El compilador no puede optimizar
void process(uint8_t* data, uint32_t value) {
    for (int i = 0; i < 100; i++) {
        data[i] += value;  // El compilador no sabe si 'value' cambia
    }
}

// ✅ Con const: El compilador puede optimizar agresivamente
void process_optimized(uint8_t* data, const uint32_t value) {
    // El compilador sabe que 'value' NO cambia → puede poner en registro
    for (int i = 0; i < 100; i++) {
        data[i] += value;
    }
}

// ✅ Puntero const
void read_only_access(const uint8_t* data) {
    // Compilador sabe que no se modifica 'data' → optimizaciones posibles
}
```

### 4.6 Volatile Usage (correcto)

```c
// ✅ Volatile para hardware registers
#define PORTA (*(volatile uint8_t*)0x0010)

void blink_led(void) {
    PORTA |= 0x01;   // Sin volatile, el compilador podría optimizar esto
    __delay_ms(100);
    PORTA &= ~0x01;  // y esto, eliminando uno de los dos
}

// ❌ Volatile mal usado (overhead innecesario)
volatile int counter = 0;  // No es necesario si solo lo usa 1 thread

void increment(void) {
    counter++;  // Cada acceso a 'counter' será lento (no se cachea en registro)
}

// ✅ Volatile solo cuando es necesario
int counter = 0;  // Normal variable

// Solo marcar volatile si:
// 1. Es hardware register (memory-mapped I/O)
// 2. Es modificado por ISR
// 3. Es compartido entre threads (RTOS)
```

### 4.7 Benchmark Comparativo

**Test:** Loop procesando 1000 elementos

```c
uint8_t data[1000];

void test_function(void) {
    for (int i = 0; i < 1000; i++) {
        data[i] = (data[i] * 3 + 7) / 2;
    }
}
```

**Resultados (PIC32MZ @ 200 MHz):**

| Optimización | Ciclos | Tiempo (µs) | Tamaño (bytes) |
|--------------|--------|-------------|----------------|
| -O0 | 85,000 | 425 | 420 |
| -O1 | 32,000 | 160 | 380 |
| -O2 | 18,000 | 90 | 450 |
| -O3 | 15,000 | 75 | 580 |
| -Os | 28,000 | 140 | 320 |
| -O2 + LTO | 14,000 | 70 | 420 |

**Conclusión:**
- `-O0` → `-O2`: **5.6x más rápido** (pero +7% tamaño)
- `-O2` → `-Os`: **30% más lento** (pero -29% tamaño)
- **LTO agrega 5-10% mejora adicional**

---

## 5. Assembly Optimization

### 5.1 Cuándo Usar Assembly

**Usar assembly solo cuando:**

1. ✅ Performance crítico (hot path medido)
2. ✅ Operaciones específicas del MCU (DSP instructions)
3. ✅ Acceso a registros especiales
4. ✅ Atomicidad garantizada
5. ✅ Ya optimizaste con C y no es suficiente

**NO usar assembly si:**
- ❌ "Creo que será más rápido" (sin medir)
- ❌ Código general (portabilidad)
- ❌ El compilador ya lo hace bien

### 5.2 Inline Assembly en C

**Sintaxis básica:**

```c
// Ejemplo: Toggle pin ultra-rápido (PIC32)
void fast_gpio_toggle(void) {
    __asm__ volatile (
        "lui $t0, 0xBF88 \n"     // Cargar dirección de PORTAINV
        "ori $t0, $t0, 0x6040 \n"
        "ori $t1, $zero, 0x01 \n"  // Máscara bit 0
        "sw $t1, 0($t0) \n"        // Write a PORTAINV (toggle)
        :                           // No outputs
        :                           // No inputs
        : "$t0", "$t1"              // Clobbers
    );
}
```

**Ejemplo con inputs/outputs:**

```c
// Multiplicación optimizada con DSP (dsPIC33)
int16_t dsp_multiply(int16_t a, int16_t b) {
    int16_t result;
    __asm__ volatile (
        "mpy %1, %2, A \n"   // Multiplicar en acumulador A
        "sac A, %0 \n"       // Store acumulador en result
        : "=r" (result)      // Output
        : "r" (a), "r" (b)   // Inputs
        : "A"                // Clobbers (acumulador A)
    );
    return result;
}
```

### 5.3 DSP Instructions (dsPIC33)

**Código C estándar:**

```c
// Filtro FIR en C (lento)
int16_t fir_filter_c(int16_t* samples, int16_t* coeffs, uint8_t taps) {
    int32_t acc = 0;
    for (uint8_t i = 0; i < taps; i++) {
        acc += (int32_t)samples[i] * coeffs[i];
    }
    return (int16_t)(acc >> 15);  // Normalizar
}
```

**Código optimizado con DSP:**

```c
// Filtro FIR con instrucciones DSP (5x más rápido)
int16_t fir_filter_dsp(int16_t* samples, int16_t* coeffs, uint8_t taps) {
    int16_t result;

    __asm__ volatile (
        "clr A, [%1]+=2, W4, [%2]+=2, W5 \n"  // Clear A, load first values
        "repeat %3 \n"                         // Repeat 'taps' times
        "mac W4*W5, A, [%1]+=2, W4, [%2]+=2, W5 \n"  // MAC operation
        "sac.r A, %0 \n"                       // Store with rounding
        : "=r" (result)
        : "r" (samples), "r" (coeffs), "r" (taps - 1)
        : "W4", "W5", "A"
    );

    return result;
}
```

**Ventaja:** La instrucción `mac` (Multiply-ACcumulate) hace:
- Multiplicación
- Acumulación
- Load de siguientes valores
- **Todo en 1 ciclo** (vs ~10 ciclos en C)

### 5.4 Critical Sections

**Deshabilitar interrupts de forma atómica:**

```c
// ❌ Problema: No atómico
void critical_update(void) {
    IEC0bits.T1IE = 0;  // Deshabilitar interrupt
    // ¿Qué pasa si llega un interrupt AQUÍ? → Race condition
    global_counter++;
    IEC0bits.T1IE = 1;  // Habilitar interrupt
}

// ✅ Solución con assembly (atómico)
void critical_update_safe(void) {
    uint32_t saved_status;

    __asm__ volatile (
        "di %0 \n"           // Disable interrupts, guardar status
        "ehb \n"             // Execution hazard barrier
        : "=r" (saved_status)
        :
        : "memory"
    );

    global_counter++;  // Ahora es seguro

    __asm__ volatile (
        "mtc0 %0, $12 \n"    // Restore status
        :
        : "r" (saved_status)
        : "memory"
    );
}
```

### 5.5 Ejemplo: DSP Filter Optimization (5x Speedup)

**Test:** Filtro FIR de 32 taps procesando señal a 10 kHz

**Versión C:**

```c
#define FIR_TAPS 32
int16_t fir_samples[FIR_TAPS];
const int16_t fir_coeffs[FIR_TAPS] = { /* coeficientes */ };

int16_t fir_filter_c(int16_t new_sample) {
    // Shift samples
    for (int i = FIR_TAPS - 1; i > 0; i--) {
        fir_samples[i] = fir_samples[i - 1];
    }
    fir_samples[0] = new_sample;

    // Calcular output
    int32_t acc = 0;
    for (int i = 0; i < FIR_TAPS; i++) {
        acc += (int32_t)fir_samples[i] * fir_coeffs[i];
    }

    return (int16_t)(acc >> 15);
}
```

**Versión DSP optimizada:**

```c
// Usar circular buffer (DMA automático en dsPIC33)
int16_t __attribute__((space(ymemory), aligned(64))) fir_samples[FIR_TAPS];
const int16_t __attribute__((space(xmemory), aligned(64))) fir_coeffs[FIR_TAPS] = { /* coeficientes */ };

int16_t fir_filter_dsp_optimized(int16_t new_sample) {
    static uint8_t index = 0;
    int16_t result;

    // Update circular buffer
    fir_samples[index] = new_sample;
    index = (index + 1) & (FIR_TAPS - 1);  // Wrap around

    // FIR calculation con DSP (1 ciclo por tap!)
    __asm__ volatile (
        "clr A, [%1]+=2, W4, [%2]+=2, W5 \n"
        "repeat #31 \n"  // 32 taps
        "mac W4*W5, A, [%1]+=2, W4, [%2]+=2, W5 \n"
        "sac.r A, #15, %0 \n"
        : "=r" (result)
        : "r" (fir_samples + index), "r" (fir_coeffs)
        : "W4", "W5", "A"
    );

    return result;
}
```

**Resultado:**

| Versión | Ciclos | Tiempo @ 70 MHz | Speedup |
|---------|--------|-----------------|---------|
| C (-O0) | 3,500 | 50 µs | 1x |
| C (-O2) | 1,200 | 17 µs | 2.9x |
| DSP asm | 700 | 10 µs | **5x** |

**Conclusión:** Assembly con DSP instructions es **5x más rápido** que C optimizado.

---

## 6. Interrupt Optimization

### 6.1 ISR Latency Reduction

**Latencia de ISR:**

```
  Evento ──┐
           │
           ↓
  ┌────────────────────────────────────────┐
  │ 1. Detección hardware      (1-3 ciclos)│
  │ 2. Context save            (10-30 ciclos) ← OPTIMIZAR
  │ 3. Vector jump             (2-5 ciclos)│
  │ 4. ISR execution           (variable)  │ ← OPTIMIZAR
  │ 5. Context restore         (10-30 ciclos) ← OPTIMIZAR
  └────────────────────────────────────────┘
           ↓
   ISR completado
```

**Optimizaciones:**

### 6.2 Shadow Registers (PIC32/dsPIC)

```c
// ❌ Sin shadow registers: Context save completo (~30 ciclos)
void __ISR(_TIMER_1_VECTOR, IPL3SOFT) Timer1Handler(void) {
    // Compilador guarda todos los registros en stack (lento)
    gpio_led_toggle();
    IFS0bits.T1IF = 0;
}

// ✅ Con shadow registers: Context save automático (1 ciclo!)
void __ISR(_TIMER_1_VECTOR, IPL3SRS) Timer1Handler(void) {
    // Shadow register set → context save automático en hardware
    gpio_led_toggle();
    IFS0bits.T1IF = 0;
}
// Ahorro: ~28 ciclos (context save + restore)
```

**Configuración de shadow registers:**

```c
// PIC32: 8 shadow register sets disponibles
// Asignar a interrupts de alta prioridad

void interrupt_init(void) {
    PRISS = 0x76543210;  // Shadow set por priority level
    // Priority 7 → Shadow set 7
    // Priority 6 → Shadow set 6
    // ...
}
```

### 6.3 ISR Execution Time Optimization

```c
// ❌ ISR lento (50 µs)
void __ISR(_ADC_VECTOR, IPL5SOFT) ADC_ISR(void) {
    uint16_t adc_value = ADC1BUF0;

    // ❌ Procesamiento pesado en ISR (malo!)
    float voltage = adc_value * 3.3 / 4096.0;  // Float math (lento)
    float current = voltage / 0.1;
    float power = voltage * current;

    // ❌ División (muy lento)
    uint16_t average = (adc_sum / adc_count);

    // ❌ I/O lento
    uart_send_string("ADC value: ");
    uart_send_number(adc_value);

    IFS1bits.AD1IF = 0;
}

// ✅ ISR rápido (10 µs)
volatile uint16_t adc_value_latest;
volatile bool adc_new_data = false;

void __ISR(_ADC_VECTOR, IPL5SRS) ADC_ISR_Fast(void) {
    // Solo capturar valor y setear flag
    adc_value_latest = ADC1BUF0;
    adc_new_data = true;

    IFS1bits.AD1IF = 0;
    // Total: ~10 µs (5x más rápido)
}

// Main loop procesa datos
void main_loop(void) {
    if (adc_new_data) {
        adc_new_data = false;

        // Procesamiento pesado FUERA del ISR
        float voltage = adc_value_latest * 3.3f / 4096.0f;
        float current = voltage / 0.1f;
        float power = voltage * current;

        uart_send_data(power);
    }
}
```

**Regla de oro:**
```
ISR debe ser < 10% del período de la interrupción
```

Ejemplo:
- Interrupt cada 100 µs (10 kHz)
- ISR debe ser < 10 µs
- Si ISR = 50 µs → Problema! (50% del tiempo en ISR)

### 6.4 Interrupt Priority Configuration

```c
// Configurar prioridades (PIC32)
void interrupt_priority_setup(void) {
    // Prioridad 7 = Más alta
    // Prioridad 1 = Más baja

    // Críticos (alta prioridad)
    IPC1bits.T1IP = 7;    // Timer crítico
    IPC6bits.AD1IP = 6;   // ADC

    // Normales (prioridad media)
    IPC7bits.U1IP = 4;    // UART
    IPC8bits.SPI1IP = 4;  // SPI

    // Bajos (baja prioridad)
    IPC2bits.T2IP = 2;    // Timer no crítico
}
```

**Nested interrupts:**

```
Priority 7 ISR ─────────────────────────────────
                 │
Priority 5 ISR ──┴──────┐  ← Puede interrumpir Priority 5
                         │
Priority 3 ISR ──────────┴──┐  ← Puede interrumpir Priority 3
                             │
Main code ────────────────────┴────────────────
```

### 6.5 Avoiding Long ISRs

```c
// ❌ ISR muy largo (malo)
void __ISR(_UART1_RX_VECTOR, IPL4SOFT) UART_RX_ISR(void) {
    char c = U1RXREG;

    // ❌ Parsing en ISR (puede ser largo)
    if (c == '\n') {
        parse_command(rx_buffer);  // Función compleja!
        execute_command();         // Peor aún!
    } else {
        rx_buffer[rx_index++] = c;
    }

    IFS0bits.U1RXIF = 0;
}

// ✅ ISR corto + deferred processing
volatile bool command_ready = false;

void __ISR(_UART1_RX_VECTOR, IPL4SOFT) UART_RX_ISR_Fast(void) {
    char c = U1RXREG;

    if (c == '\n') {
        command_ready = true;  // Solo setear flag
    } else {
        rx_buffer[rx_index++] = c;
    }

    IFS0bits.U1RXIF = 0;
}

// Main loop procesa comando
void main_loop(void) {
    if (command_ready) {
        command_ready = false;
        parse_command(rx_buffer);  // Fuera del ISR
        execute_command();
    }
}
```

### 6.6 Ejemplo: Reducir ISR de 50 µs a 10 µs

**Caso:** ISR de ADC que procesa y envía datos

**Antes (50 µs):**

```c
void __ISR(_ADC_VECTOR, IPL5SOFT) ADC_ISR_Slow(void) {
    // 1. Leer ADC (2 µs)
    uint16_t raw = ADC1BUF0;

    // 2. Convertir a voltaje con float (15 µs) ❌
    float voltage = (float)raw * 3.3f / 4096.0f;

    // 3. Aplicar filtro (10 µs) ❌
    voltage = voltage * 0.9f + last_voltage * 0.1f;
    last_voltage = voltage;

    // 4. Formatear string (20 µs) ❌
    sprintf(buffer, "V=%.2f\n", voltage);

    // 5. Enviar UART (3 µs)
    uart_send_string(buffer);

    IFS1bits.AD1IF = 0;
}
// TOTAL: ~50 µs (demasiado!)
```

**Después (10 µs):**

```c
volatile uint16_t adc_raw_value;
volatile bool adc_data_ready = false;

void __ISR(_ADC_VECTOR, IPL5SRS) ADC_ISR_Fast(void) {
    // 1. Leer ADC (2 µs)
    adc_raw_value = ADC1BUF0;

    // 2. Setear flag (1 µs)
    adc_data_ready = true;

    IFS1bits.AD1IF = 0;
    // TOTAL: ~3 µs (16x más rápido!)
}

// Main loop: Procesamiento diferido
void main_loop(void) {
    if (adc_data_ready) {
        adc_data_ready = false;

        // Procesamiento fuera del ISR
        float voltage = (float)adc_raw_value * 3.3f / 4096.0f;
        voltage = voltage * 0.9f + last_voltage * 0.1f;
        last_voltage = voltage;

        sprintf(buffer, "V=%.2f\n", voltage);
        uart_send_string(buffer);
    }
}
```

**Resultado:**
- **ISR: 50 µs → 3 µs (16x mejora)**
- **Latencia: Baja** (solo lectura de ADC)
- **Robustez:** ISR no bloquea otros interrupts

---

## 7. DMA Usage Patterns

### 7.1 When to Use DMA

**DMA (Direct Memory Access):** Transferencia de datos sin CPU

```
╔════════════════════════════════════════════════════════╗
║  SIN DMA:                                              ║
║                                                        ║
║  Periférico → ISR → CPU → RAM                         ║
║                   ↑                                    ║
║              Ocupa CPU!                                ║
║                                                        ║
║  CON DMA:                                              ║
║                                                        ║
║  Periférico → DMA → RAM                               ║
║                                                        ║
║  CPU libre para otras tareas! ✅                       ║
╚════════════════════════════════════════════════════════╝
```

**Cuándo usar DMA:**

| Caso de Uso | ¿DMA? | Razón |
|-------------|-------|-------|
| ADC a 100 Hz | ❌ No | ISR simple es suficiente |
| ADC a 10 kHz | ✅ Sí | ISR cada 100 µs (mucha carga) |
| UART 9600 bps | ❌ No | Bajo throughput |
| UART 115200 bps | ✅ Sí | Alto throughput |
| SPI 1 MHz | ❌ No | Transferencias cortas |
| SPI 20 MHz | ✅ Sí | Transferencias largas |
| I2C | ❌ No | Protocolo lento |

### 7.2 ADC + DMA (Continuous Sampling)

**Sin DMA:**

```c
// ❌ ISR cada muestra (alto overhead)
void __ISR(_ADC_VECTOR, IPL5SOFT) ADC_ISR(void) {
    adc_buffer[adc_index++] = ADC1BUF0;
    if (adc_index >= ADC_BUFFER_SIZE) {
        adc_index = 0;
        adc_buffer_ready = true;
    }
    IFS1bits.AD1IF = 0;
}
// Problema: ISR llamado 10,000 veces/segundo a 10 kHz
```

**Con DMA:**

```c
#define ADC_BUFFER_SIZE 256
uint16_t __attribute__((aligned(512))) adc_buffer_A[ADC_BUFFER_SIZE];
uint16_t __attribute__((aligned(512))) adc_buffer_B[ADC_BUFFER_SIZE];

void adc_dma_init(void) {
    // Configurar ADC para auto-sampling
    AD1CON1bits.ASAM = 1;  // Auto-start sampling
    AD1CON1bits.SSRC = 0b111;  // Auto-convert

    // Configurar DMA Channel 0
    DMA0CONbits.AMODE = 0b00;  // Register indirect
    DMA0CONbits.MODE = 0b10;   // Continuous ping-pong mode

    DMA0PAD = (volatile unsigned int)&ADC1BUF0;  // Peripheral address
    DMA0STA = __builtin_dma_offset(adc_buffer_A);  // Buffer A
    DMA0STB = __builtin_dma_offset(adc_buffer_B);  // Buffer B
    DMA0CNT = ADC_BUFFER_SIZE - 1;

    IFS0bits.DMA0IF = 0;
    IEC0bits.DMA0IE = 1;  // Interrupt cuando buffer lleno

    DMA0CONbits.CHEN = 1;  // Enable DMA
    AD1CON1bits.ADON = 1;  // Start ADC
}

// ISR solo cuando buffer completo (256 muestras)
void __ISR(_DMA0_VECTOR, IPL4SOFT) DMA0_ISR(void) {
    // Determinar qué buffer está lleno
    if (DMA0CONbits.PPST == 0) {
        // Buffer A listo para procesar
        process_adc_samples(adc_buffer_A, ADC_BUFFER_SIZE);
    } else {
        // Buffer B listo para procesar
        process_adc_samples(adc_buffer_B, ADC_BUFFER_SIZE);
    }

    IFS0bits.DMA0IF = 0;
}
```

**Ventaja:**
- Sin DMA: **10,000 ISRs/segundo**
- Con DMA: **39 ISRs/segundo** (10,000 / 256)
- **256x menos overhead de ISR!**

### 7.3 UART + DMA (Buffered I/O)

**TX con DMA:**

```c
#define UART_TX_BUFFER_SIZE 256
uint8_t uart_tx_buffer[UART_TX_BUFFER_SIZE];

void uart_dma_tx_init(void) {
    // Configurar DMA para UART TX
    DMA1CONbits.AMODE = 0b00;  // Register indirect
    DMA1CONbits.MODE = 0b01;   // One-shot mode
    DMA1CONbits.DIR = 1;       // RAM → Peripheral

    DMA1PAD = (volatile unsigned int)&U1TXREG;
    DMA1STA = __builtin_dma_offset(uart_tx_buffer);

    IFS0bits.DMA1IF = 0;
    IEC0bits.DMA1IE = 1;

    DMA1CONbits.CHEN = 1;
}

void uart_send_string_dma(const char* str) {
    uint16_t len = strlen(str);
    memcpy(uart_tx_buffer, str, len);

    DMA1CNT = len - 1;
    DMA1CONbits.CHEN = 1;  // Start transfer
    DMA1REQbits.FORCE = 1;  // Force first transfer
}

// ISR cuando transfer completo
void __ISR(_DMA1_VECTOR, IPL3SOFT) DMA1_ISR(void) {
    // TX completo
    uart_tx_busy = false;
    IFS0bits.DMA1IF = 0;
}
```

**RX con DMA:**

```c
#define UART_RX_BUFFER_SIZE 256
uint8_t uart_rx_buffer[UART_RX_BUFFER_SIZE];

void uart_dma_rx_init(void) {
    DMA2CONbits.AMODE = 0b00;
    DMA2CONbits.MODE = 0b00;   // Continuous mode
    DMA2CONbits.DIR = 0;       // Peripheral → RAM

    DMA2PAD = (volatile unsigned int)&U1RXREG;
    DMA2STA = __builtin_dma_offset(uart_rx_buffer);
    DMA2CNT = UART_RX_BUFFER_SIZE - 1;

    DMA2CONbits.CHEN = 1;
}

// Polling para leer datos (sin ISR!)
uint16_t uart_rx_available(void) {
    return UART_RX_BUFFER_SIZE - DMA2CNT - 1;
}
```

### 7.4 SPI + DMA (High-Speed Transfers)

**SPI con DMA (ej: SD Card):**

```c
void spi_dma_init(void) {
    // TX DMA
    DMA3CONbits.DIR = 1;  // RAM → SPI
    DMA3PAD = (volatile unsigned int)&SPI1BUF;

    // RX DMA
    DMA4CONbits.DIR = 0;  // SPI → RAM
    DMA4PAD = (volatile unsigned int)&SPI1BUF;

    DMA3CONbits.CHEN = 1;
    DMA4CONbits.CHEN = 1;
}

void spi_transfer_block_dma(uint8_t* tx_data, uint8_t* rx_data, uint16_t len) {
    DMA3STA = __builtin_dma_offset(tx_data);
    DMA3CNT = len - 1;

    DMA4STA = __builtin_dma_offset(rx_data);
    DMA4CNT = len - 1;

    // Start transfer
    DMA3CONbits.CHEN = 1;
    DMA4CONbits.CHEN = 1;
    DMA3REQbits.FORCE = 1;

    // Wait for completion
    while (!IFS0bits.DMA4IF);
    IFS0bits.DMA4IF = 0;
}
```

**Benchmark:** Transferir 512 bytes por SPI a 20 MHz

| Método | Tiempo | CPU Usage |
|--------|--------|-----------|
| Polling | 210 µs | 100% |
| ISR per byte | 205 µs | 80% |
| **DMA** | **205 µs** | **0%** ✅ |

**Ventaja:** CPU completamente libre durante transfer!

### 7.5 Memory-to-Memory DMA

```c
// Copiar grandes bloques de memoria con DMA (más rápido que memcpy)
void dma_memcpy(void* dest, const void* src, size_t len) {
    DMA5CONbits.AMODE = 0b00;
    DMA5CONbits.MODE = 0b01;  // One-shot
    DMA5CONbits.DIR = 0;      // Doesn't matter (memory to memory)

    DMA5STA = __builtin_dma_offset(src);
    DMA5STB = __builtin_dma_offset(dest);
    DMA5CNT = len - 1;

    DMA5CONbits.CHEN = 1;
    DMA5REQbits.FORCE = 1;

    while (!IFS0bits.DMA5IF);
    IFS0bits.DMA5IF = 0;
}

// Benchmark: Copiar 4 KB
// memcpy():     85 µs
// dma_memcpy(): 42 µs (2x más rápido)
```

### 7.6 Ejemplo: ADC Sampling 10 kHz con DMA

**Aplicación:** Adquisición continua a 10 kHz (100 µs/muestra)

**Configuración completa:**

```c
#define SAMPLE_RATE 10000  // 10 kHz
#define BUFFER_SIZE 256

uint16_t __attribute__((aligned(512))) adc_bufferA[BUFFER_SIZE];
uint16_t __attribute__((aligned(512))) adc_bufferB[BUFFER_SIZE];
volatile bool buffer_A_ready = false;
volatile bool buffer_B_ready = false;

void system_init(void) {
    // Timer para trigger ADC a 10 kHz
    PR3 = (FCY / SAMPLE_RATE) - 1;  // FCY = 70 MHz para dsPIC33
    T3CONbits.TON = 1;

    // ADC configuración
    AD1CON1bits.ASAM = 1;      // Auto sampling
    AD1CON1bits.SSRC = 0b010;  // Timer3 trigger
    AD1CON2bits.SMPI = 0;      // Interrupt cada muestra
    AD1CON2bits.CHPS = 0;      // Sample CH0

    // DMA configuración (ping-pong)
    DMA0CONbits.AMODE = 0b00;
    DMA0CONbits.MODE = 0b10;   // Continuous ping-pong
    DMA0CONbits.DIR = 0;       // Peripheral → RAM

    DMA0PAD = (volatile unsigned int)&ADC1BUF0;
    DMA0STA = __builtin_dma_offset(adc_bufferA);
    DMA0STB = __builtin_dma_offset(adc_bufferB);
    DMA0CNT = BUFFER_SIZE - 1;

    IFS0bits.DMA0IF = 0;
    IEC0bits.DMA0IE = 1;

    DMA0CONbits.CHEN = 1;
    AD1CON1bits.ADON = 1;
}

// ISR cada 256 muestras (cada 25.6 ms)
void __ISR(_DMA0_VECTOR, IPL5SOFT) DMA0_ISR(void) {
    if (DMA0CONbits.PPST == 0) {
        buffer_A_ready = true;
    } else {
        buffer_B_ready = true;
    }
    IFS0bits.DMA0IF = 0;
}

// Main loop procesa buffers completos
void main(void) {
    system_init();

    while (1) {
        if (buffer_A_ready) {
            buffer_A_ready = false;
            process_samples(adc_bufferA, BUFFER_SIZE);  // 25 ms disponibles
        }

        if (buffer_B_ready) {
            buffer_B_ready = false;
            process_samples(adc_bufferB, BUFFER_SIZE);
        }
    }
}
```

**Resultado:**
- Adquisición continua a 10 kHz
- **ISR cada 25.6 ms** (no cada 100 µs)
- CPU libre para procesamiento
- **Sin pérdida de muestras**

---

## 8. Algoritmos y Estructuras de Datos

### 8.1 Algorithm Complexity (Big O Notation)

```
╔════════════════════════════════════════════════════════╗
║  COMPLEJIDAD DE ALGORITMOS                             ║
╠════════════════════════════════════════════════════════╣
║  O(1)      Constante     Acceso a array              ║
║  O(log n)  Logarítmico   Búsqueda binaria            ║
║  O(n)      Lineal        Búsqueda lineal             ║
║  O(n²)     Cuadrático    Bubble sort                 ║
║  O(2ⁿ)     Exponencial   Recursión ineficiente       ║
╚════════════════════════════════════════════════════════╝
```

**Ejemplo: Búsqueda**

```c
// O(n) - Linear search
int linear_search(int* array, int size, int target) {
    for (int i = 0; i < size; i++) {  // n iteraciones
        if (array[i] == target) return i;
    }
    return -1;
}
// Tiempo: n=1000 → 1000 comparaciones (worst case)

// O(log n) - Binary search (array ordenado)
int binary_search(int* array, int size, int target) {
    int left = 0, right = size - 1;
    while (left <= right) {
        int mid = (left + right) / 2;
        if (array[mid] == target) return mid;
        if (array[mid] < target) left = mid + 1;
        else right = mid - 1;
    }
    return -1;
}
// Tiempo: n=1000 → 10 comparaciones (log₂ 1000 ≈ 10)
// 100x más rápido!
```

### 8.2 Sorting Algorithms

```c
// ❌ Bubble sort: O(n²) - Muy lento
void bubble_sort(int* array, int size) {
    for (int i = 0; i < size - 1; i++) {
        for (int j = 0; j < size - i - 1; j++) {
            if (array[j] > array[j + 1]) {
                int temp = array[j];
                array[j] = array[j + 1];
                array[j + 1] = temp;
            }
        }
    }
}
// n=100: 10,000 comparaciones

// ✅ Quicksort: O(n log n) - Mucho más rápido
void quicksort(int* array, int left, int right) {
    if (left >= right) return;

    int pivot = array[right];
    int i = left - 1;

    for (int j = left; j < right; j++) {
        if (array[j] < pivot) {
            i++;
            int temp = array[i];
            array[i] = array[j];
            array[j] = temp;
        }
    }

    int temp = array[i + 1];
    array[i + 1] = array[right];
    array[right] = temp;

    int partition = i + 1;
    quicksort(array, left, partition - 1);
    quicksort(array, partition + 1, right);
}
// n=100: ~700 comparaciones (14x más rápido)
```

### 8.3 Hash Tables vs Linear Search

```c
// ❌ Linear search: O(n)
typedef struct {
    uint32_t id;
    char name[32];
} User_t;

User_t users[1000];

User_t* find_user_linear(uint32_t id) {
    for (int i = 0; i < 1000; i++) {
        if (users[i].id == id) return &users[i];
    }
    return NULL;
}
// Tiempo promedio: 500 comparaciones

// ✅ Hash table: O(1) amortizado
#define HASH_TABLE_SIZE 1024

typedef struct HashNode {
    User_t user;
    struct HashNode* next;
} HashNode_t;

HashNode_t* hash_table[HASH_TABLE_SIZE];

uint32_t hash_function(uint32_t id) {
    return id % HASH_TABLE_SIZE;
}

User_t* find_user_hash(uint32_t id) {
    uint32_t index = hash_function(id);
    HashNode_t* node = hash_table[index];

    while (node != NULL) {
        if (node->user.id == id) return &node->user;
        node = node->next;
    }
    return NULL;
}
// Tiempo promedio: 1-2 comparaciones (250x más rápido!)
```

### 8.4 Ring Buffers

```c
// Ring buffer eficiente (ya visto antes)
#define BUFFER_SIZE 256  // Potencia de 2

typedef struct {
    uint8_t buffer[BUFFER_SIZE];
    volatile uint16_t head;
    volatile uint16_t tail;
} RingBuffer_t;

// O(1) - Constante
bool ring_push(RingBuffer_t* rb, uint8_t data) {
    uint16_t next_head = (rb->head + 1) & (BUFFER_SIZE - 1);
    if (next_head == rb->tail) return false;  // Full

    rb->buffer[rb->head] = data;
    rb->head = next_head;
    return true;
}

bool ring_pop(RingBuffer_t* rb, uint8_t* data) {
    if (rb->head == rb->tail) return false;  // Empty

    *data = rb->buffer[rb->tail];
    rb->tail = (rb->tail + 1) & (BUFFER_SIZE - 1);
    return true;
}
```

### 8.5 Fixed-Point Arithmetic

```c
// ❌ Floating-point (lento en MCUs sin FPU)
float calculate_power(float voltage, float current) {
    return voltage * current;
}
// ~100 ciclos en PIC32 (sin FPU)

// ✅ Fixed-point Q16.16 (rápido)
typedef int32_t fixed_t;  // 16 bits enteros, 16 bits fraccionarios
#define FIXED_SHIFT 16
#define FLOAT_TO_FIXED(f) ((fixed_t)((f) * (1 << FIXED_SHIFT)))
#define FIXED_TO_FLOAT(x) ((float)(x) / (1 << FIXED_SHIFT))

fixed_t fixed_multiply(fixed_t a, fixed_t b) {
    int64_t result = (int64_t)a * b;
    return (fixed_t)(result >> FIXED_SHIFT);
}

fixed_t calculate_power_fixed(fixed_t voltage, fixed_t current) {
    return fixed_multiply(voltage, current);
}
// ~10 ciclos (10x más rápido!)

// Ejemplo de uso
float v = 3.3;
float i = 2.5;

fixed_t v_fixed = FLOAT_TO_FIXED(v);  // 216268 (0x00034CCC)
fixed_t i_fixed = FLOAT_TO_FIXED(i);  // 163840 (0x00028000)
fixed_t p_fixed = fixed_multiply(v_fixed, i_fixed);
float p = FIXED_TO_FLOAT(p_fixed);    // 8.25 W
```

### 8.6 Lookup Tables (LUT)

```c
// ❌ Cálculo en runtime (muy lento)
float calculate_sin(float angle_deg) {
    return sinf(angle_deg * 3.14159f / 180.0f);
}
// ~500 ciclos

// ✅ Lookup table (100x más rápido)
const int16_t sin_lut[360] = {
    0, 17, 35, 52, 70, 87, 105, 122, 139, 156,  // 0-9 grados
    // ... (360 valores)
};

int16_t fast_sin(uint16_t angle_deg) {
    return sin_lut[angle_deg % 360];
}
// ~5 ciclos (100x más rápido!)

// ✅ LUT pequeña + interpolación lineal (balance)
const int16_t sin_lut_small[91] = {
    0, 17, 35, 52, 70, 87, 105, 122, 139, 156,  // 0-90 grados cada 1°
    // ... (91 valores)
};

int16_t interpolated_sin(uint16_t angle_deg) {
    angle_deg = angle_deg % 360;

    // Simetría para reducir LUT
    bool negative = false;
    if (angle_deg >= 180) {
        angle_deg -= 180;
        negative = true;
    }
    if (angle_deg > 90) {
        angle_deg = 180 - angle_deg;
    }

    // Interpolación lineal
    uint16_t index = angle_deg;
    uint16_t frac = 0;  // Simplificado (sin fracción en este ejemplo)

    int16_t result = sin_lut_small[index];
    return negative ? -result : result;
}
// ~20 ciclos, solo 182 bytes Flash (vs 720 bytes LUT completa)
```

### 8.7 Ejemplo: Lookup Table sin/cos (100x Faster)

**Caso:** Generar señal PWM senoidal a 10 kHz para inversor

```c
// ❌ Cálculo directo (demasiado lento)
void update_pwm_slow(void) {
    static float angle = 0.0f;

    float sine_value = sinf(angle);  // ~500 ciclos
    uint16_t duty = (uint16_t)((sine_value + 1.0f) * 500.0f);

    OC1RS = duty;

    angle += 0.01f;  // Incremento
    if (angle >= 6.28318f) angle = 0.0f;
}
// Tiempo: ~550 ciclos = 2.75 µs @ 200 MHz
// Frecuencia máxima: ~360 kHz

// ✅ Lookup table (100x más rápido)
#define LUT_SIZE 360
const uint16_t sine_lut[LUT_SIZE] = {
    500, 508, 517, 526, 534, 543, 552, 560, 569, 577,  // Valores PWM duty cycle
    // ... (360 valores precomputados)
};

void update_pwm_fast(void) {
    static uint16_t angle_index = 0;

    OC1RS = sine_lut[angle_index];  // ~3 ciclos

    angle_index++;
    if (angle_index >= LUT_SIZE) angle_index = 0;
}
// Tiempo: ~5 ciclos = 0.025 µs @ 200 MHz
// Frecuencia máxima: 40 MHz (110x más rápido!)
```

**Trade-off:**
- Flash usado: 720 bytes (360 values × 2 bytes)
- Speedup: 110x
- **ROI excelente:** 720 bytes → 110x performance

---

## 9. Power Optimization

### 9.1 Sleep Modes

**PIC32 Sleep Modes:**

```
╔════════════════════════════════════════════════════════╗
║  MODO         CONSUMO    CPU    PERIFÉRICOS  WAKEUP   ║
╠════════════════════════════════════════════════════════╣
║  Run          100 mA     ✅ Sí   ✅ Activos    N/A     ║
║  Idle         30 mA      ❌ No    ✅ Activos    Fast   ║
║  Sleep        5 mA       ❌ No    ❌ Off        Slow   ║
║  Deep Sleep   1 µA       ❌ No    ❌ Off        Ext Int║
╚════════════════════════════════════════════════════════╝
```

**Idle mode:**

```c
void enter_idle(void) {
    // CPU off, periféricos ON
    // Wakeup por cualquier interrupt

    asm volatile("wait");  // Enter Idle mode

    // Continúa aquí después del wakeup
}

// Ejemplo: Esperar UART con low power
void uart_receive_low_power(uint8_t* buffer, uint16_t len) {
    for (uint16_t i = 0; i < len; i++) {
        while (!U1STAbits.URXDA) {
            enter_idle();  // Sleep mientras espera
        }
        buffer[i] = U1RXREG;
    }
}
// Ahorro: 100 mA → 30 mA mientras espera
```

**Sleep mode:**

```c
void enter_sleep(void) {
    // Configurar wakeup source
    IEC0bits.INT0IE = 1;  // External interrupt 0
    IPC0bits.INT0IP = 7;  // Máxima prioridad

    // Deshabilitar periféricos no necesarios
    PMD1 = 0xFFFF;  // Power off all peripherals
    PMD2 = 0xFFFF;

    // Enter Sleep
    OSCCONbits.SLPEN = 1;
    asm volatile("wait");

    // Wakeup aquí (INT0 triggered)

    // Re-habilitar periféricos
    PMD1 = 0;
    PMD2 = 0;
}
```

### 9.2 Clock Gating

```c
// Deshabilitar periféricos no usados (PIC32)
void clock_gating_init(void) {
    // PMDx = Peripheral Module Disable

    PMD1bits.AD1MD = 1;   // ADC off
    PMD1bits.CTMUMD = 1;  // CTMU off
    PMD1bits.CVRMD = 1;   // Comparator off

    PMD2bits.CMP1MD = 1;  // Comparator 1 off
    PMD2bits.CMP2MD = 1;  // Comparator 2 off

    PMD3bits.IC1MD = 1;   // Input Capture 1 off
    PMD3bits.IC2MD = 1;

    PMD4bits.T2MD = 1;    // Timer 2 off
    PMD4bits.T3MD = 1;    // Timer 3 off

    PMD5bits.U1MD = 0;    // UART1 ON (necesario)
    PMD5bits.U2MD = 1;    // UART2 OFF

    PMD6bits.SPI1MD = 0;  // SPI1 ON (necesario)
    PMD6bits.SPI2MD = 1;  // SPI2 OFF
}
// Ahorro típico: 10-20 mA
```

### 9.3 Peripheral Power Management

```c
// Habilitar periférico solo cuando se necesita
void sensor_read_low_power(void) {
    // 1. Habilitar periférico
    PMD1bits.AD1MD = 0;  // ADC ON
    AD1CON1bits.ADON = 1;
    __delay_us(20);  // Stabilization time

    // 2. Realizar lectura
    AD1CON1bits.SAMP = 1;
    while (!AD1CON1bits.DONE);
    uint16_t result = ADC1BUF0;

    // 3. Deshabilitar periférico
    AD1CON1bits.ADON = 0;
    PMD1bits.AD1MD = 1;  // ADC OFF

    // Ahorro: ~5 mA mientras ADC OFF
}
```

### 9.4 Dynamic Frequency Scaling

```c
// Cambiar frecuencia según carga de trabajo

void set_cpu_speed_high(void) {
    // 200 MHz (performance mode)
    SYSKEY = 0x0;
    SYSKEY = 0xAA996655;
    SYSKEY = 0x556699AA;

    OSCCONbits.NOSC = 0b011;  // Primary oscillator with PLL
    OSCCONbits.OSWEN = 1;
    while (OSCCONbits.OSWEN);

    SYSKEY = 0x0;
    // Consumo: 100 mA
}

void set_cpu_speed_low(void) {
    // 8 MHz (low power mode)
    SYSKEY = 0x0;
    SYSKEY = 0xAA996655;
    SYSKEY = 0x556699AA;

    OSCCONbits.NOSC = 0b111;  // FRC oscillator
    OSCCONbits.OSWEN = 1;
    while (OSCCONbits.OSWEN);

    SYSKEY = 0x0;
    // Consumo: 10 mA (10x menos!)
}

void main_loop(void) {
    while (1) {
        if (high_performance_needed) {
            set_cpu_speed_high();
            // Procesamiento intensivo
        } else {
            set_cpu_speed_low();
            // Tareas simples (sensores, etc.)
        }
    }
}
```

### 9.5 Low-Power Design Patterns

**Pattern 1: Event-driven (vs polling)**

```c
// ❌ Polling (CPU siempre activa)
void main_polling(void) {
    while (1) {
        if (button_is_pressed()) {
            handle_button();
        }
        if (uart_data_available()) {
            handle_uart();
        }
        // CPU 100% activa (100 mA)
    }
}

// ✅ Event-driven (CPU en idle)
void main_event_driven(void) {
    while (1) {
        asm volatile("wait");  // CPU idle hasta interrupt

        // Wakeup por interrupt
        if (button_pressed_flag) {
            button_pressed_flag = false;
            handle_button();
        }
        if (uart_data_flag) {
            uart_data_flag = false;
            handle_uart();
        }
        // CPU idle la mayor parte del tiempo (30 mA)
    }
}
// Ahorro: 70 mA
```

**Pattern 2: Scheduled wakeup**

```c
// Wakeup periódico para medir sensores
void low_power_sensor_loop(void) {
    // Configurar RTC para wakeup cada 1 segundo
    RTCCON = 0x8000;  // Enable RTC
    RTCALRM = 0x8401;  // Alarm cada 1 segundo

    while (1) {
        // Medir sensores
        float temperature = read_temperature_sensor();
        float humidity = read_humidity_sensor();

        // Enviar datos
        uart_send_data(temperature, humidity);

        // Sleep por 1 segundo
        enter_sleep();  // 5 mA

        // Wakeup por RTC alarm
    }
}
// Duty cycle: 20 ms activo / 1000 ms total = 2%
// Consumo promedio: 100 mA × 2% + 5 mA × 98% = 6.9 mA
```

### 9.6 Ejemplo: Reducir Consumo de 100 mA a 5 mA

**Aplicación:** Sensor IoT con WiFi que reporta cada 1 minuto

**Antes (100 mA promedio):**

```c
void main_power_hungry(void) {
    wifi_init();  // WiFi siempre ON (80 mA)

    while (1) {
        // Medir cada 1 minuto
        float temp = read_temperature();

        // Enviar a cloud
        wifi_send_data(temp);

        // Delay activo (CPU 100%, WiFi ON)
        __delay_ms(60000);  // 60 segundos
    }
}
// Consumo: 100 mA continuo
// Batería 2000 mAh → 20 horas
```

**Después (5 mA promedio):**

```c
void main_power_optimized(void) {
    wifi_init();
    wifi_sleep_mode_enable();  // WiFi en sleep (1 mA)

    // Configurar RTC wakeup cada 60 segundos
    rtc_set_alarm_interval(60);

    // Deshabilitar periféricos no usados
    clock_gating_init();

    while (1) {
        // 1. Wakeup por RTC

        // 2. Habilitar WiFi
        wifi_wakeup();  // 500 ms para conectar

        // 3. Medir sensor (10 ms)
        float temp = read_temperature();

        // 4. Enviar datos (200 ms)
        wifi_send_data(temp);

        // 5. WiFi a sleep mode
        wifi_sleep_mode_enable();

        // 6. CPU a deep sleep
        enter_sleep();  // 1 mA hasta próximo RTC alarm
    }
}

// Cálculo de consumo:
// WiFi active (500 ms + 200 ms): 80 mA × 700 ms = 56 mA·s
// Sensor active (10 ms): 30 mA × 10 ms = 0.3 mA·s
// Sleep (59 segundos): 1 mA × 59000 ms = 59 mA·s
// ───────────────────────────────────────────────
// Total 60 segundos: 115.3 mA·s
// Promedio: 115.3 mA·s / 60 s = 1.92 mA

// Batería 2000 mAh → 1042 horas (43 días!) → 52x mejora
```

**Optimizaciones aplicadas:**

1. ✅ WiFi en sleep mode (80 mA → 1 mA)
2. ✅ CPU en deep sleep (30 mA → 1 mA)
3. ✅ Periféricos deshabilitados (clock gating)
4. ✅ Wakeup por RTC (no polling)
5. ✅ Duty cycle bajo (2% activo)

**Resultado:**
- **Consumo: 100 mA → 1.92 mA (52x mejor)**
- **Autonomía: 20 horas → 43 días**

---

## 10. I/O Optimization

### 10.1 Polling vs Interrupts vs DMA

| Método | CPU Usage | Latencia | Mejor para |
|--------|-----------|----------|------------|
| **Polling** | 100% | Variable | Debugging |
| **Interrupts** | 5-20% | Baja | Eventos raros |
| **DMA** | 0% | Muy baja | Alto throughput |

### 10.2 Buffering Strategies

```c
// ❌ Sin buffer (byte-by-byte)
void uart_send_message_slow(const char* msg) {
    while (*msg) {
        while (U1STAbits.UTXBF);  // Wait for TX buffer
        U1TXREG = *msg++;
    }
}
// Problema: Muchas esperas (polling)

// ✅ Con buffer + DMA
#define TX_BUFFER_SIZE 256
uint8_t tx_buffer[TX_BUFFER_SIZE];
volatile uint16_t tx_head = 0, tx_tail = 0;

void uart_send_message_fast(const char* msg) {
    uint16_t len = strlen(msg);
    memcpy(&tx_buffer[tx_head], msg, len);
    tx_head += len;

    // Trigger DMA si no está activo
    if (!DMA1CONbits.CHEN) {
        start_uart_dma_tx();
    }
}
// CPU libre inmediatamente!
```

### 10.3 UART Throughput Optimization

**Aumentar baudrate:**

```c
// ❌ 9600 bps (lento)
void uart_init_slow(void) {
    U1BRG = (FCY / (16 * 9600)) - 1;  // 9600 bps
    U1MODEbits.ON = 1;
}
// Throughput: 960 bytes/segundo

// ✅ 115200 bps (rápido)
void uart_init_fast(void) {
    U1BRG = (FCY / (16 * 115200)) - 1;  // 115200 bps
    U1MODEbits.ON = 1;
}
// Throughput: 11,520 bytes/segundo (12x más rápido)

// ✅ 921600 bps (muy rápido, requiere buen cable)
void uart_init_very_fast(void) {
    U1BRG = (FCY / (16 * 921600)) - 1;  // 921600 bps
    U1MODEbits.ON = 1;
}
// Throughput: 92,160 bytes/segundo (96x más rápido)
```

**Binary protocol vs ASCII:**

```c
// ❌ ASCII (ineficiente)
char buffer[50];
sprintf(buffer, "T:%d,H:%d\n", temperature, humidity);
uart_send_string(buffer);  // 20 bytes

// ✅ Binary (eficiente)
typedef struct __attribute__((packed)) {
    uint8_t header;      // 0xAA
    int16_t temperature; // 2 bytes
    uint16_t humidity;   // 2 bytes
    uint8_t checksum;    // 1 byte
} SensorPacket_t;  // Total: 6 bytes

SensorPacket_t packet = {
    .header = 0xAA,
    .temperature = temperature,
    .humidity = humidity
};
packet.checksum = calculate_checksum(&packet, sizeof(packet) - 1);
uart_send_binary(&packet, sizeof(packet));  // 6 bytes (3.3x más eficiente)
```

---

## 11. Profiling y Measurement

### 11.1 Timer-Based Profiling

```c
// Medir tiempo de ejecución con timer
uint32_t profile_start(void) {
    return TMR2;  // Timer de 32 bits
}

uint32_t profile_end(uint32_t start) {
    uint32_t end = TMR2;
    return end - start;  // Ciclos transcurridos
}

// Uso
uint32_t start = profile_start();
my_function();
uint32_t cycles = profile_end(start);
printf("Cycles: %lu, Time: %.2f us\n", cycles, cycles / (FCY / 1000000.0));
```

### 11.2 GPIO Toggling para Timing

```c
// Medir con osciloscopio
void measure_function_timing(void) {
    LATA |= (1 << 0);  // Pin HIGH (inicio)

    my_function();  // Función a medir

    LATA &= ~(1 << 0);  // Pin LOW (fin)

    // Medir con osciloscopio la duración del pulso
}
```

### 11.3 Memory Usage Analysis

```bash
# Analizar memoria con linker map file
xc32-gcc ... -Wl,-Map=output.map

# Ver secciones de memoria
grep "\.text" output.map
grep "\.data" output.map
grep "\.bss" output.map

# Ver funciones más grandes
sort -k2 -n output.map | tail -20
```

**Ejemplo de map file:**

```
.text       0x9d000000   0x12000   code.o
.data       0x80000000   0x500     data.o
.bss        0x80000500   0x2000    variables.o

Function sizes:
main           0x9d000100   320 bytes
sensor_read    0x9d000240   1200 bytes  ← Grande!
uart_send      0x9d000710   80 bytes
```

---

## 12. Case Study Completo

### Aplicación: Sistema IoT Multi-Sensor

**Descripción:**
- 5 sensores (temp, humedad, presión, luz, acelerómetro)
- Envío de datos por WiFi cada 10 segundos
- Display OLED local
- Batería Li-Ion 2000 mAh

**Código inicial (sin optimizar):**

```c
void main_unoptimized(void) {
    system_init();
    wifi_init();
    display_init();

    while (1) {
        // Leer sensores (float math, sin DMA)
        float temp = read_temperature();     // 50 ms
        float humidity = read_humidity();    // 50 ms
        float pressure = read_pressure();    // 50 ms
        uint16_t light = read_light();       // 30 ms
        AccelData_t accel = read_accel();    // 40 ms

        // Procesar (float math pesado)
        float heat_index = calculate_heat_index(temp, humidity);  // 20 ms

        // Display (string formatting + I2C lento)
        char buffer[50];
        sprintf(buffer, "T:%.1f H:%.1f P:%.1f", temp, humidity, pressure);
        display_show(buffer);  // 100 ms

        // WiFi (sin sleep, binary ineficiente)
        wifi_send_ascii_data(buffer);  // 300 ms

        // Delay activo
        __delay_ms(10000);
    }
}
```

**Análisis del código original:**

```
╔════════════════════════════════════════════════════════╗
║           ANÁLISIS BEFORE OPTIMIZATION                 ║
╠════════════════════════════════════════════════════════╣
║  RAM Usage:    45 KB / 50 KB  (90%)                   ║
║  Flash Usage:  170 KB / 200 KB (85%)                  ║
║  CPU Load:     100% continuo                          ║
║  Consumo:      85 mA promedio                         ║
║  Autonomía:    23.5 horas                             ║
║  Ejecución:    640 ms por ciclo                       ║
╚════════════════════════════════════════════════════════╝

Problemas identificados:
1. Float math extensivo (sin FPU) → Lento
2. Sprintf para strings → Flash grande
3. Display I2C sin DMA → Bloqueo CPU
4. WiFi siempre ON → Alto consumo
5. Delay activo → Desperdicio CPU
6. Buffers grandes en stack → RAM overflow riesgo
7. ASCII protocol → Ineficiente
```

**Código optimizado:**

```c
// ====================================================================
// OPTIMIZACIÓN 1: Fixed-point en vez de float
// ====================================================================
typedef int32_t fixed16_t;  // Q16.16
#define FLOAT_TO_FIXED(f) ((fixed16_t)((f) * 65536.0f))
#define FIXED_TO_FLOAT(x) ((float)(x) / 65536.0f)

// ====================================================================
// OPTIMIZACIÓN 2: Structs compactos y alineados
// ====================================================================
typedef struct __attribute__((packed)) {
    int16_t temperature;  // Temp * 100 (ej: 2540 = 25.40°C)
    uint16_t humidity;    // Humidity * 100
    uint32_t pressure;    // Pressure in Pa
    uint16_t light;       // Light in lux
    int16_t accel_x;      // Accel en mG
    int16_t accel_y;
    int16_t accel_z;
    uint8_t checksum;
} __attribute__((aligned(4))) SensorData_t;  // 17 bytes (vs 50 bytes ASCII)

// ====================================================================
// OPTIMIZACIÓN 3: Memory pools (no malloc)
// ====================================================================
#define POOL_SIZE 4
static SensorData_t sensor_pool[POOL_SIZE];
static uint8_t pool_index = 0;

SensorData_t* pool_alloc(void) {
    SensorData_t* block = &sensor_pool[pool_index];
    pool_index = (pool_index + 1) % POOL_SIZE;
    return block;
}

// ====================================================================
// OPTIMIZACIÓN 4: Lookup table para heat index (vs cálculo float)
// ====================================================================
const int16_t heat_index_lut[50][50] = {
    // Precomputado para temp=[0-50°C] y humidity=[0-100%]
    // ...
};

int16_t fast_heat_index(int16_t temp, uint16_t humidity) {
    return heat_index_lut[temp][humidity / 2];  // ~5 ciclos vs 5000 ciclos
}

// ====================================================================
// OPTIMIZACIÓN 5: Display con DMA + double buffering
// ====================================================================
static uint8_t display_buffer_A[128 * 8];  // En .bss (no stack)
static uint8_t display_buffer_B[128 * 8];
static uint8_t* active_buffer = display_buffer_A;

void display_update_async(SensorData_t* data) {
    // Renderizar en buffer inactivo
    uint8_t* back_buffer = (active_buffer == display_buffer_A) ? display_buffer_B : display_buffer_A;

    // Renderizar (sin sprintf, usar itoa custom)
    render_data_to_buffer(back_buffer, data);

    // DMA transfer (non-blocking)
    i2c_dma_transfer(DISPLAY_ADDR, back_buffer, sizeof(display_buffer_A));

    // Swap buffers
    active_buffer = back_buffer;
}

// ====================================================================
// OPTIMIZACIÓN 6: WiFi power management + binary protocol
// ====================================================================
void wifi_send_optimized(SensorData_t* data) {
    // Wakeup WiFi
    wifi_wakeup();  // 200 ms

    // Enviar binary (17 bytes vs 50 bytes ASCII)
    wifi_send_binary(data, sizeof(SensorData_t));  // 50 ms vs 300 ms

    // Sleep WiFi
    wifi_enter_sleep();  // 1 mA vs 80 mA
}

// ====================================================================
// OPTIMIZACIÓN 7: Main loop con deep sleep
// ====================================================================
void main_optimized(void) {
    system_init();
    wifi_init();
    display_init();

    // Clock gating (deshabilitar periféricos no usados)
    PMD1 = 0xFFFF;
    PMD2 = 0xFFFF;
    PMD1bits.T1MD = 0;  // Solo Timer1 para RTC

    // RTC wakeup cada 10 segundos
    rtc_set_alarm_interval(10);

    while (1) {
        // ═══ Wakeup por RTC ═══

        // 1. Leer sensores CON DMA (25 ms vs 220 ms)
        SensorData_t* data = pool_alloc();
        data->temperature = read_temperature_dma();
        data->humidity = read_humidity_dma();
        data->pressure = read_pressure_dma();
        data->light = read_light_dma();
        read_accel_dma(&data->accel_x, &data->accel_y, &data->accel_z);

        // 2. Calcular heat index con LUT (0.01 ms vs 20 ms)
        int16_t heat = fast_heat_index(data->temperature / 100, data->humidity / 100);

        // 3. Actualizar display ASYNC (5 ms vs 100 ms)
        display_update_async(data);

        // 4. Enviar WiFi (250 ms vs 300 ms)
        wifi_send_optimized(data);

        // Total tiempo activo: ~280 ms (vs 640 ms) → 2.3x más rápido

        // 5. Enter deep sleep (1 mA) por 9.72 segundos
        enter_deep_sleep();

        // ═══ Wakeup en próximo ciclo ═══
    }
}
```

**Resultados de optimización:**

```
╔════════════════════════════════════════════════════════════════════╗
║              RESULTADOS COMPARATIVOS                               ║
╠════════════════════════════════════════════════════════════════════╣
║  Métrica           ANTES        DESPUÉS      MEJORA                ║
║  ─────────────────────────────────────────────────────────────     ║
║  RAM Usage         45 KB (90%)  22 KB (44%)   -51%  ✅             ║
║  Flash Usage       170 KB (85%) 95 KB (48%)   -44%  ✅             ║
║  Ciclo ejecución   640 ms       280 ms        2.3x  ✅             ║
║  Consumo promedio  85 mA        3.2 mA        26x   ✅             ║
║  Autonomía         23.5 horas   625 horas     26x   ✅             ║
║                                  (26 días!)                        ║
║  CPU load          100%         2.8%          36x   ✅             ║
╚════════════════════════════════════════════════════════════════════╝

Técnicas aplicadas:
✅ 1. Fixed-point arithmetic (float → fixed)
✅ 2. Structs compactos y alineados
✅ 3. Memory pools (no malloc/free)
✅ 4. Lookup tables (heat index)
✅ 5. DMA para I2C, ADC, UART
✅ 6. Display double buffering + DMA
✅ 7. WiFi power management
✅ 8. Binary protocol (vs ASCII)
✅ 9. Deep sleep con RTC wakeup
✅ 10. Clock gating (periféricos off)
✅ 11. Compiler -Os + LTO
✅ 12. Dead code elimination
```

**Análisis económico:**

```
Beneficio de optimización:

1. Hardware más barato:
   - Antes: PIC32MZ (2 MB Flash, 512 KB RAM) → $12/unidad
   - Después: PIC32MX (256 KB Flash, 64 KB RAM) → $4/unidad
   - Ahorro: $8/unidad
   - Producción 10,000 unidades: $80,000 ahorro

2. Batería más pequeña:
   - Antes: 2000 mAh (23 horas)
   - Después: 500 mAh (155 horas con mismo 26x mejora)
   - Ahorro: $2/unidad → $20,000 total

3. Total ahorro: $100,000 en producción
```

---

## 13. Best Practices

### 13.1 Evitar Premature Optimization

```
"Premature optimization is the root of all evil" - Donald Knuth
```

**Proceso correcto:**

```
1. Hacer que funcione (correctness)
2. Medir performance (profiling)
3. Identificar bottlenecks (80/20 rule)
4. Optimizar hot paths
5. Verificar que sigue funcionando (testing)
```

**❌ Mal:**
```c
// Optimizar sin medir primero
void process_data(uint8_t* data) {
    // Código ultra-optimizado pero ilegible
    // Sin saber si es realmente necesario
}
```

**✅ Bien:**
```c
// 1. Versión simple y clara
void process_data_v1(uint8_t* data) {
    for (int i = 0; i < 100; i++) {
        data[i] = calculate_value(i);  // Simple
    }
}

// 2. Medir: 500 µs (demasiado lento!)

// 3. Optimizar hot path (calculate_value es el 80% del tiempo)
int16_t calculate_value_optimized(int index) {
    return value_lut[index];  // LUT es 100x más rápido
}

// 4. Nueva medición: 5 µs (100x mejora)
```

### 13.2 Readable Code vs Optimized Code

**Balance entre legibilidad y performance:**

```c
// ✅ Legible (para código no crítico)
float calculate_average(float* values, int count) {
    float sum = 0.0f;
    for (int i = 0; i < count; i++) {
        sum += values[i];
    }
    return sum / count;
}

// ✅ Optimizado (solo para hot paths)
// NOTA: Documentar POR QUÉ está optimizado
int32_t calculate_average_fast(int16_t* values, int count) {
    // OPTIMIZADO: Esta función es llamada 10,000 veces/segundo
    // Fixed-point (Q16.16) para evitar FPU (50x más rápido)
    int32_t sum = 0;
    for (int i = 0; i < count; i++) {
        sum += values[i];
    }
    return sum / count;  // Division sigue siendo lenta, pero aceptable
}
```

### 13.3 Documentar Optimizaciones

```c
// ✅ BIEN DOCUMENTADO
/**
 * @brief Fast sine calculation using lookup table
 *
 * OPTIMIZATION:
 * - Replaced sinf() [~500 cycles] with LUT [~5 cycles]
 * - Trade-off: 720 bytes Flash for 100x speedup
 * - Profiling showed this function is 60% of CPU time in main loop
 * - Date: 2024-01-15
 * - Author: John Doe
 *
 * @param angle_deg Angle in degrees [0-359]
 * @return Sine value scaled by 1000 [-1000 to +1000]
 */
int16_t fast_sin(uint16_t angle_deg) {
    return sin_lut[angle_deg % 360];
}
```

### 13.4 Testing Después de Optimizar

```c
// Siempre verificar que la optimización no rompió nada

// Test unitario
void test_fast_sin(void) {
    // Verificar contra sinf()
    for (int angle = 0; angle < 360; angle++) {
        int16_t fast = fast_sin(angle);
        float reference = sinf(angle * 3.14159f / 180.0f) * 1000.0f;
        int16_t ref_int = (int16_t)reference;

        // Tolerar error de ±1 (por redondeo de LUT)
        assert(abs(fast - ref_int) <= 1);
    }
}
```

### 13.5 Version Control de Optimizaciones

```bash
# Git commit message ejemplo
git commit -m "perf: Optimize sensor_read() with DMA

- Replaced ISR-based ADC read with DMA
- Reduces CPU usage from 80% to 5%
- Profiling: 120 µs → 10 µs (12x faster)
- Trade-off: +200 bytes Flash for DMA config
- Tested: 10,000 iterations, no errors

Closes #123"
```

---

## 14. Checklist de Optimización

```
╔════════════════════════════════════════════════════════╗
║       CHECKLIST DE OPTIMIZACIÓN PASO A PASO            ║
╠════════════════════════════════════════════════════════╣
║  FASE 1: MEASUREMENT                                   ║
║  ─────────────────────────────────────────             ║
║  □ Medir RAM usage actual                              ║
║  □ Medir Flash usage actual                            ║
║  □ Profiling de funciones (timing)                     ║
║  □ Identificar hot paths (80/20 rule)                  ║
║  □ Medir consumo de corriente                          ║
║  □ Establecer baseline metrics                         ║
║                                                        ║
║  FASE 2: RAM OPTIMIZATION                              ║
║  ─────────────────────────────────────────             ║
║  □ Eliminar buffers grandes en stack                   ║
║  □ Usar memory pools (evitar malloc)                   ║
║  □ Optimizar struct packing/alignment                  ║
║  □ Usar bitfields para flags                           ║
║  □ Dimensionar stack correctamente                     ║
║                                                        ║
║  FASE 3: FLASH OPTIMIZATION                            ║
║  ─────────────────────────────────────────             ║
║  □ Compilar con -Os (optimize for size)                ║
║  □ Habilitar LTO (link-time optimization)              ║
║  □ Usar --gc-sections (dead code elimination)          ║
║  □ String pooling (reutilizar strings)                 ║
║  □ Eliminar código debug en producción                 ║
║                                                        ║
║  FASE 4: PERFORMANCE OPTIMIZATION                      ║
║  ─────────────────────────────────────────             ║
║  □ Usar DMA para I/O de alto throughput                ║
║  □ Optimizar ISRs (< 10% del período)                  ║
║  □ Usar shadow registers en ISRs críticos              ║
║  □ Lookup tables para funciones pesadas                ║
║  □ Fixed-point arithmetic (evitar float)               ║
║  □ Inline funciones pequeñas y críticas                ║
║  □ Loop unrolling en hot paths                         ║
║                                                        ║
║  FASE 5: POWER OPTIMIZATION                            ║
║  ─────────────────────────────────────────             ║
║  □ Usar sleep modes (Idle, Sleep, Deep Sleep)          ║
║  □ Clock gating (deshabilitar periféricos)             ║
║  □ WiFi/Bluetooth sleep cuando no se usa               ║
║  □ Event-driven architecture (no polling)              ║
║  □ Duty cycle bajo (active time mínimo)                ║
║                                                        ║
║  FASE 6: VERIFICATION                                  ║
║  ─────────────────────────────────────────             ║
║  □ Re-medir RAM usage                                  ║
║  □ Re-medir Flash usage                                ║
║  □ Re-profiling de timing                              ║
║  □ Testing funcional completo                          ║
║  □ Medir consumo de corriente nuevamente               ║
║  □ Comparar con baseline                               ║
║  □ Documentar cambios y trade-offs                     ║
║                                                        ║
║  FASE 7: DEPLOYMENT                                    ║
║  ─────────────────────────────────────────             ║
║  □ Code review                                         ║
║  □ Commit con mensaje descriptivo                      ║
║  □ Tag de versión                                      ║
║  □ Actualizar documentación                            ║
║  □ Changelog entry                                     ║
╚════════════════════════════════════════════════════════╝
```

---

## Conclusión

La **optimización avanzada** en sistemas embebidos requiere un enfoque **metódico y medido**. Las técnicas presentadas en este capítulo permiten:

✅ **Reducir RAM** hasta 50% (memory pools, struct packing)
✅ **Reducir Flash** hasta 40% (LTO, dead code elimination, -Os)
✅ **Acelerar ejecución** hasta 100x (DMA, lookup tables, assembly DSP)
✅ **Reducir consumo** hasta 50x (sleep modes, clock gating, WiFi management)

**Principios clave:**

1. **Medir primero** (no optimizar ciegamente)
2. **Enfocarse en hot paths** (regla 80/20)
3. **Balance de trade-offs** (velocidad vs tamaño vs consumo)
4. **Verificar siempre** (testing después de optimizar)
5. **Documentar decisiones** (para mantenimiento futuro)

Con estas técnicas, un sistema IoT típico puede pasar de **23 horas** a **26 días** de autonomía, usar un MCU **3x más barato**, y ejecutar **10x más rápido** - todo con optimizaciones sistemáticas y bien medidas.

---

**Próximo capítulo: Arquitecturas Complejas** (multi-core, memory management, IPC)
