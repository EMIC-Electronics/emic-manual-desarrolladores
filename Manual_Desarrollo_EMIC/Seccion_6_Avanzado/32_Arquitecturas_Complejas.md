# Capítulo 32: Arquitecturas Complejas

## Índice
1. [Introducción a Arquitecturas Complejas](#1-introducción-a-arquitecturas-complejas)
2. [Multi-Core Systems](#2-multi-core-systems)
3. [Memory Management](#3-memory-management)
4. [Inter-Process Communication (IPC)](#4-inter-process-communication-ipc)
5. [Resource Sharing y Synchronization](#5-resource-sharing-y-synchronization)
6. [Deadlock Prevention](#6-deadlock-prevention)
7. [Priority Inversion](#7-priority-inversion)
8. [Distributed Systems](#8-distributed-systems)
9. [Communication Protocols para IPC](#9-communication-protocols-para-ipc)
10. [Redundancy y Fault Tolerance](#10-redundancy-y-fault-tolerance)
11. [Real-Time Constraints](#11-real-time-constraints)
12. [Cache Coherency](#12-cache-coherency)
13. [Case Study](#13-case-study-sistema-multi-core-completo)
14. [Best Practices](#14-best-practices)

---

## 1. Introducción a Arquitecturas Complejas

### 1.1 Single-Core vs Multi-Core

```
╔════════════════════════════════════════════════════════╗
║              SINGLE-CORE                               ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║   ┌──────────────────────────────────┐                ║
║   │         CPU CORE                 │                ║
║   │  ┌────────────────────────────┐  │                ║
║   │  │  Task 1                    │  │                ║
║   │  │  Task 2   (time-slicing)   │  │                ║
║   │  │  Task 3                    │  │                ║
║   │  └────────────────────────────┘  │                ║
║   └──────────────────────────────────┘                ║
║                                                        ║
║   Ventajas:                                            ║
║   ✅ Simple (no cache coherency)                      ║
║   ✅ Determinístico                                   ║
║   ✅ Bajo costo                                       ║
║                                                        ║
║   Desventajas:                                         ║
║   ❌ Performance limitado                             ║
║   ❌ No paralelismo real                              ║
╚════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════╗
║              MULTI-CORE (DUAL-CORE)                    ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║   ┌─────────────────┐  ┌─────────────────┐           ║
║   │   CPU CORE 0    │  │   CPU CORE 1    │           ║
║   │  ┌───────────┐  │  │  ┌───────────┐  │           ║
║   │  │ Task 1    │  │  │  │ Task 2    │  │           ║
║   │  │ (Control) │  │  │  │ (Comms)   │  │           ║
║   │  └───────────┘  │  │  └───────────┘  │           ║
║   └─────────────────┘  └─────────────────┘           ║
║            ↓                     ↓                     ║
║       ┌──────────────────────────────┐                ║
║       │    SHARED MEMORY             │                ║
║       └──────────────────────────────┘                ║
║                                                        ║
║   Ventajas:                                            ║
║   ✅ 2x performance (paralelismo real)                ║
║   ✅ Separation of concerns                           ║
║   ✅ Mejor responsiveness                             ║
║                                                        ║
║   Desventajas:                                         ║
║   ❌ Complejo (sincronización)                        ║
║   ❌ Cache coherency issues                           ║
║   ❌ Mayor costo                                      ║
╚════════════════════════════════════════════════════════╝
```

### 1.2 Cuándo Usar Arquitecturas Complejas

**Usar multi-core cuando:**

1. ✅ **Performance crítico** y single-core no alcanza
2. ✅ **Separation of concerns** (ej: control + comunicaciones)
3. ✅ **Real-time + non-real-time** tasks separados
4. ✅ **Safety-critical** (redundancia)

**Ejemplo de caso de uso:**

```
Sistema de control industrial:

Core 0 (Real-time):
├─ Control loop @ 1 kHz (determinístico)
├─ Safety monitoring
└─ Sensor acquisition

Core 1 (General-purpose):
├─ Ethernet TCP/IP stack
├─ Web server
├─ Data logging
└─ HMI updates

→ Core 0 nunca es interrumpido por comunicaciones
→ Determinism garantizado
```

### 1.3 Trade-offs y Challenges

| Aspecto | Single-Core | Multi-Core |
|---------|-------------|------------|
| **Complejidad** | Baja | Alta |
| **Performance** | Limitado | 2x (dual-core) |
| **Determinism** | Alto | Medio (cache coherency) |
| **Debug** | Fácil | Difícil |
| **Sincronización** | Innecesaria | Crítica |
| **Costo** | Bajo | Alto |
| **Consumo** | Bajo | Alto |

---

## 2. Multi-Core Systems

### 2.1 PIC32MZ Dual-Core Architecture

**PIC32MZ2064DAR169:** Dual-core @ 200 MHz cada core

```
╔════════════════════════════════════════════════════════════╗
║            PIC32MZ DUAL-CORE ARCHITECTURE                  ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║  ┌─────────────────────┐      ┌─────────────────────┐    ║
║  │   CORE 0 (Master)   │      │   CORE 1 (Slave)    │    ║
║  │   MIPS M-class      │      │   MIPS M-class      │    ║
║  │   @ 200 MHz         │      │   @ 200 MHz         │    ║
║  │                     │      │                     │    ║
║  │  ┌───────────────┐  │      │  ┌───────────────┐  │    ║
║  │  │  L1 I-Cache   │  │      │  │  L1 I-Cache   │  │    ║
║  │  │  16 KB        │  │      │  │  16 KB        │  │    ║
║  │  └───────────────┘  │      │  └───────────────┘  │    ║
║  │  ┌───────────────┐  │      │  ┌───────────────┐  │    ║
║  │  │  L1 D-Cache   │  │      │  │  L1 D-Cache   │  │    ║
║  │  │  8 KB         │  │      │  │  8 KB         │  │    ║
║  │  └───────────────┘  │      │  └───────────────┘  │    ║
║  └──────────┬──────────┘      └──────────┬──────────┘    ║
║             │                            │                ║
║             └──────────┬─────────────────┘                ║
║                        │                                  ║
║              ┌─────────▼────────────┐                     ║
║              │   SYSTEM BUS         │                     ║
║              └─────────┬────────────┘                     ║
║                        │                                  ║
║         ┌──────────────┼──────────────┐                   ║
║         │              │              │                   ║
║  ┌──────▼─────┐ ┌─────▼──────┐ ┌────▼─────┐             ║
║  │ RAM 512 KB │ │ Flash 2 MB │ │ Periph.  │             ║
║  │ (Shared)   │ │            │ │          │             ║
║  └────────────┘ └────────────┘ └──────────┘             ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
```

### 2.2 Core Roles y Load Balancing

**Estrategia típica:**

```c
// ============================================================
// CORE 0: Real-time critical tasks
// ============================================================
void core0_main(void) {
    // Configuración inicial
    core0_init();

    while (1) {
        // Loop de control @ 1 kHz (1 ms period)
        wait_for_timer_interrupt();

        // 1. Leer sensores (100 µs)
        read_all_sensors();

        // 2. Ejecutar control loop (400 µs)
        pid_control_update();

        // 3. Actualizar outputs (50 µs)
        update_actuators();

        // 4. Safety checks (50 µs)
        safety_monitor();

        // Total: 600 µs → 40% CPU load en Core 0
    }
}

// ============================================================
// CORE 1: Non-real-time tasks
// ============================================================
void core1_main(void) {
    // Configuración inicial
    core1_init();

    while (1) {
        // 1. Procesar Ethernet
        ethernet_process();  // Time-varying

        // 2. Actualizar HMI
        hmi_update();  // ~50 ms

        // 3. Data logging
        if (log_timer_expired()) {
            log_data_to_sd_card();  // ~100 ms
        }

        // 4. Comunicaciones Modbus
        modbus_process();

        // CPU load variable (10-80%)
    }
}
```

### 2.3 Core-to-Core Communication

**Shared Memory + Semaphores:**

```c
// Región de memoria compartida
#define SHARED_MEM_BASE 0x80020000
#define SHARED_MEM_SIZE 4096

typedef struct {
    // Datos de sensores (escritos por Core 0)
    volatile float temperature;
    volatile float pressure;
    volatile float flow_rate;

    // Comandos (escritos por Core 1)
    volatile uint32_t command;
    volatile float setpoint;

    // Flags de sincronización
    volatile uint32_t sensor_data_ready;
    volatile uint32_t command_ready;

    // Stats
    volatile uint32_t core0_loop_count;
    volatile uint32_t core1_loop_count;
} SharedData_t;

// Puntero a shared memory
SharedData_t* g_shared = (SharedData_t*)SHARED_MEM_BASE;

// ============================================================
// CORE 0: Producer (sensor data)
// ============================================================
void core0_publish_sensor_data(void) {
    // Actualizar datos
    g_shared->temperature = sensor_temp_read();
    g_shared->pressure = sensor_pressure_read();
    g_shared->flow_rate = sensor_flow_read();

    // Memory barrier (asegurar que writes son visibles)
    __sync_synchronize();

    // Setear flag
    g_shared->sensor_data_ready = 1;

    g_shared->core0_loop_count++;
}

// ============================================================
// CORE 1: Consumer (sensor data)
// ============================================================
void core1_consume_sensor_data(void) {
    // Polling flag
    if (g_shared->sensor_data_ready) {
        // Memory barrier
        __sync_synchronize();

        // Leer datos
        float temp = g_shared->temperature;
        float pressure = g_shared->pressure;
        float flow = g_shared->flow_rate;

        // Clear flag
        g_shared->sensor_data_ready = 0;

        // Procesar datos (ej: enviar por Ethernet)
        ethernet_send_telemetry(temp, pressure, flow);
    }
}

// ============================================================
// CORE 1: Producer (commands)
// ============================================================
void core1_send_command_to_core0(uint32_t cmd, float setpoint) {
    g_shared->command = cmd;
    g_shared->setpoint = setpoint;

    __sync_synchronize();

    g_shared->command_ready = 1;
}

// ============================================================
// CORE 0: Consumer (commands)
// ============================================================
void core0_check_commands(void) {
    if (g_shared->command_ready) {
        __sync_synchronize();

        uint32_t cmd = g_shared->command;
        float setpoint = g_shared->setpoint;

        g_shared->command_ready = 0;

        // Ejecutar comando
        execute_command(cmd, setpoint);
    }
}
```

### 2.4 Cache Coherency

**Problema de cache coherency:**

```
Time    Core 0 Cache        Shared Memory       Core 1 Cache
────────────────────────────────────────────────────────────
t0      value = 100         value = 100         value = 100
t1      value = 200         value = 100 ❌      value = 100
        (modified)          (stale!)            (stale!)

→ Core 0 modificó en cache pero no escribió a memoria
→ Core 1 lee valor viejo!
```

**Solución 1: Cache flush + invalidate:**

```c
// Core 0: Flush cache después de escribir
void core0_write_shared_data(uint32_t value) {
    g_shared->data = value;

    // Flush D-cache (forzar write a memoria)
    __builtin_mips_cache(0x15, &g_shared->data);  // Hit Writeback

    __sync_synchronize();  // Memory barrier
}

// Core 1: Invalidate cache antes de leer
uint32_t core1_read_shared_data(void) {
    __sync_synchronize();

    // Invalidate D-cache (forzar read desde memoria)
    __builtin_mips_cache(0x11, &g_shared->data);  // Hit Invalidate

    return g_shared->data;
}
```

**Solución 2: Uncached memory region:**

```c
// Marcar shared memory como uncached (no se cachea)
#define SHARED_MEM_BASE 0xA0020000  // Uncached virtual address (KSEG1)

// Ahora accesos son siempre desde RAM (sin cache coherency issues)
// Trade-off: Más lento (no cache), pero coherente
```

### 2.5 Ejemplo: Dual-Core Processing

**Benchmark: Procesamiento de imagen (320x240 pixels)**

```c
// ============================================================
// SINGLE-CORE: Procesar toda la imagen
// ============================================================
void process_image_single_core(uint8_t* image) {
    for (int y = 0; y < 240; y++) {
        for (int x = 0; x < 320; x++) {
            image[y * 320 + x] = apply_filter(image, x, y);
        }
    }
}
// Tiempo: 80 ms @ 200 MHz

// ============================================================
// DUAL-CORE: Dividir imagen en dos mitades
// ============================================================
volatile bool core1_done = false;

// Core 0: Procesar mitad superior
void core0_process_half(uint8_t* image) {
    for (int y = 0; y < 120; y++) {  // 0-119
        for (int x = 0; x < 320; x++) {
            image[y * 320 + x] = apply_filter(image, x, y);
        }
    }
}

// Core 1: Procesar mitad inferior
void core1_process_half(uint8_t* image) {
    for (int y = 120; y < 240; y++) {  // 120-239
        for (int x = 0; x < 320; x++) {
            image[y * 320 + x] = apply_filter(image, x, y);
        }
    }

    __sync_synchronize();
    core1_done = true;
}

// Coordinación
void process_image_dual_core(uint8_t* image) {
    core1_done = false;

    // Iniciar Core 1 (asíncrono)
    trigger_core1_task(core1_process_half, image);

    // Core 0 procesa su mitad
    core0_process_half(image);

    // Esperar a que Core 1 termine
    while (!core1_done);

    // Imagen completa procesada
}
// Tiempo: 42 ms @ 200 MHz (1.9x speedup)
```

---

## 3. Memory Management

### 3.1 Memory Layout

**Layout completo de memoria:**

```
╔═══════════════════════════════════════════════════════════╗
║               MEMORIA PIC32MZ (512 KB RAM)                ║
╠═══════════════════════════════════════════════════════════╣
║  0x80000000                                               ║
║  ┌─────────────────────────────────────────────────────┐ ║
║  │  .text (código ejecutable)                          │ ║
║  │  → Ejecutado desde Flash (cached)                   │ ║
║  ├─────────────────────────────────────────────────────┤ ║
║  │  .data (variables inicializadas)                    │ ║
║  │  uint32_t counter = 100;                            │ ║
║  ├─────────────────────────────────────────────────────┤ ║
║  │  .bss (variables no inicializadas)                  │ ║
║  │  uint8_t buffer[1024];                              │ ║
║  ├─────────────────────────────────────────────────────┤ ║
║  │  HEAP (dynamic allocation)                          │ ║
║  │      ↓ Crece hacia abajo                            │ ║
║  │         (malloc, free)                              │ ║
║  │                                                      │ ║
║  │  ┌──────────────────────────────────────────────┐   │ ║
║  │  │  Shared Memory (Core 0 ↔ Core 1)            │   │ ║
║  │  │  4 KB uncached (0xA0020000)                  │   │ ║
║  │  └──────────────────────────────────────────────┘   │ ║
║  │                                                      │ ║
║  │         ...                                          │ ║
║  │                                                      │ ║
║  │      ↑ Crece hacia arriba                            │ ║
║  │  STACK Core 1 (8 KB)                                │ ║
║  ├─────────────────────────────────────────────────────┤ ║
║  │  Stack Guard (512 bytes)                            │ ║
║  ├─────────────────────────────────────────────────────┤ ║
║  │  STACK Core 0 (8 KB)                                │ ║
║  └─────────────────────────────────────────────────────┘ ║
║  0x8007FFFF (512 KB)                                      ║
╚═══════════════════════════════════════════════════════════╝
```

### 3.2 Heap Allocators

**First-Fit Allocator:**

```c
// ============================================================
// Implementación de heap allocator custom
// ============================================================
#define HEAP_SIZE (64 * 1024)  // 64 KB

typedef struct HeapBlock {
    size_t size;             // Tamaño del bloque (incluyendo header)
    bool is_free;            // Flag de disponibilidad
    struct HeapBlock* next;  // Puntero al siguiente bloque
} HeapBlock_t;

static uint8_t heap_memory[HEAP_SIZE] __attribute__((aligned(16)));
static HeapBlock_t* heap_head = NULL;

// Inicializar heap
void heap_init(void) {
    heap_head = (HeapBlock_t*)heap_memory;
    heap_head->size = HEAP_SIZE;
    heap_head->is_free = true;
    heap_head->next = NULL;
}

// First-fit allocation
void* heap_malloc(size_t size) {
    if (size == 0) return NULL;

    // Alinear a 16 bytes
    size_t aligned_size = (size + 15) & ~15;
    size_t total_size = aligned_size + sizeof(HeapBlock_t);

    HeapBlock_t* current = heap_head;

    // Buscar primer bloque libre que sea suficientemente grande
    while (current != NULL) {
        if (current->is_free && current->size >= total_size) {
            // Encontrado!

            // Si el bloque es mucho más grande, dividirlo
            if (current->size >= total_size + sizeof(HeapBlock_t) + 32) {
                // Crear nuevo bloque con el espacio restante
                HeapBlock_t* new_block = (HeapBlock_t*)((uint8_t*)current + total_size);
                new_block->size = current->size - total_size;
                new_block->is_free = true;
                new_block->next = current->next;

                current->size = total_size;
                current->next = new_block;
            }

            current->is_free = false;

            // Retornar puntero después del header
            return (void*)((uint8_t*)current + sizeof(HeapBlock_t));
        }

        current = current->next;
    }

    // No hay memoria disponible
    return NULL;
}

// Free
void heap_free(void* ptr) {
    if (ptr == NULL) return;

    // Obtener header del bloque
    HeapBlock_t* block = (HeapBlock_t*)((uint8_t*)ptr - sizeof(HeapBlock_t));
    block->is_free = true;

    // Coalescing: Unir bloques libres adyacentes
    HeapBlock_t* current = heap_head;
    while (current != NULL && current->next != NULL) {
        if (current->is_free && current->next->is_free) {
            // Unir current con next
            current->size += current->next->size;
            current->next = current->next->next;
        } else {
            current = current->next;
        }
    }
}

// Heap stats
void heap_stats(size_t* total_free, size_t* largest_block) {
    *total_free = 0;
    *largest_block = 0;

    HeapBlock_t* current = heap_head;
    while (current != NULL) {
        if (current->is_free) {
            *total_free += current->size;
            if (current->size > *largest_block) {
                *largest_block = current->size;
            }
        }
        current = current->next;
    }
}
```

**Buddy System Allocator (más eficiente):**

```c
// Buddy system: Bloques de tamaños potencia de 2
// Ventaja: Fast allocation/deallocation, no external fragmentation

#define BUDDY_MIN_SIZE 32      // 32 bytes mínimo
#define BUDDY_MAX_SIZE 32768   // 32 KB máximo
#define BUDDY_LEVELS 10        // log2(32768/32) = 10

typedef struct {
    uint8_t level;  // Nivel en el árbol buddy
    bool is_free;
} BuddyBlock_t;

static uint8_t buddy_memory[BUDDY_MAX_SIZE] __attribute__((aligned(32768)));
static BuddyBlock_t buddy_blocks[1024];  // Tabla de bloques

void* buddy_alloc(size_t size) {
    // Redondear size a potencia de 2
    size_t block_size = BUDDY_MIN_SIZE;
    while (block_size < size) {
        block_size *= 2;
    }

    // Encontrar bloque libre del tamaño apropiado
    // Si no existe, dividir un bloque más grande (split)
    // ...

    return ptr;
}

void buddy_free(void* ptr) {
    // Marcar bloque como libre
    // Intentar merge con "buddy" (bloque adyacente del mismo tamaño)
    // ...
}
```

### 3.3 Memory Protection Unit (MPU)

```c
// Configurar MPU para proteger regiones críticas
void mpu_init(void) {
    // Región 0: Flash (read-only, executable)
    MPU_RASR0 = MPU_RASR_ENABLE | MPU_RASR_SIZE_2MB | MPU_RASR_AP_READONLY | MPU_RASR_XN_DISABLE;
    MPU_RBAR0 = FLASH_BASE | MPU_RBAR_VALID | 0;

    // Región 1: RAM (read-write, no execute)
    MPU_RASR1 = MPU_RASR_ENABLE | MPU_RASR_SIZE_512KB | MPU_RASR_AP_FULL | MPU_RASR_XN_ENABLE;
    MPU_RBAR1 = RAM_BASE | MPU_RBAR_VALID | 1;

    // Región 2: Stack (read-write, no execute, guard page)
    MPU_RASR2 = MPU_RASR_ENABLE | MPU_RASR_SIZE_8KB | MPU_RASR_AP_FULL | MPU_RASR_XN_ENABLE;
    MPU_RBAR2 = STACK_BASE | MPU_RBAR_VALID | 2;

    // Región 3: Peripherals (read-write, no cache, no execute)
    MPU_RASR3 = MPU_RASR_ENABLE | MPU_RASR_SIZE_512MB | MPU_RASR_AP_FULL | MPU_RASR_XN_ENABLE | MPU_RASR_TEX_DEVICE;
    MPU_RBAR3 = PERIPH_BASE | MPU_RBAR_VALID | 3;

    // Habilitar MPU
    MPU_CTRL = MPU_CTRL_ENABLE | MPU_CTRL_PRIVDEFENA;
}

// Handler de MPU fault
void __attribute__((interrupt)) MPU_Fault_Handler(void) {
    // Violación de MPU detectada!
    uint32_t fault_addr = MPU_MMAR;  // Memory Manage Address Register

    // Log error
    log_error("MPU Fault at address: 0x%08X", fault_addr);

    // Recovery action
    system_reset();
}
```

### 3.4 Stack Overflow Detection

```c
// Patrón de stack guard (canary)
#define STACK_GUARD_PATTERN 0xDEADBEEF

// Inicializar guard
void stack_guard_init(void) {
    extern uint32_t _stack_guard;
    _stack_guard = STACK_GUARD_PATTERN;
}

// Verificar stack guard periódicamente
bool stack_guard_check(void) {
    extern uint32_t _stack_guard;
    if (_stack_guard != STACK_GUARD_PATTERN) {
        // Stack overflow detectado!
        log_error("Stack overflow detected!");
        return false;
    }
    return true;
}

// Llamar desde main loop o timer ISR
void safety_monitor(void) {
    if (!stack_guard_check()) {
        // Acción de emergencia
        emergency_shutdown();
        system_reset();
    }
}
```

---

## 4. Inter-Process Communication (IPC)

### 4.1 Message Queues

```c
// ============================================================
// Message Queue Implementation
// ============================================================
#define QUEUE_SIZE 32

typedef struct {
    uint8_t data[64];  // Mensaje de hasta 64 bytes
    uint16_t length;
} Message_t;

typedef struct {
    Message_t messages[QUEUE_SIZE];
    volatile uint16_t head;
    volatile uint16_t tail;
    volatile uint16_t count;
} MessageQueue_t;

// Queue global (puede ser en shared memory para multi-core)
MessageQueue_t g_queue __attribute__((section(".shared_data")));

// Enviar mensaje
bool queue_send(MessageQueue_t* queue, const uint8_t* data, uint16_t length) {
    if (queue->count >= QUEUE_SIZE) {
        return false;  // Queue full
    }

    // Copiar mensaje
    memcpy(queue->messages[queue->head].data, data, length);
    queue->messages[queue->head].length = length;

    // Actualizar head
    queue->head = (queue->head + 1) % QUEUE_SIZE;

    __sync_synchronize();  // Memory barrier

    queue->count++;

    return true;
}

// Recibir mensaje
bool queue_receive(MessageQueue_t* queue, uint8_t* data, uint16_t* length) {
    if (queue->count == 0) {
        return false;  // Queue empty
    }

    __sync_synchronize();

    // Copiar mensaje
    memcpy(data, queue->messages[queue->tail].data, queue->messages[queue->tail].length);
    *length = queue->messages[queue->tail].length;

    // Actualizar tail
    queue->tail = (queue->tail + 1) % QUEUE_SIZE;

    queue->count--;

    return true;
}
```

### 4.2 Semaphores

```c
// ============================================================
// Semaphore Implementation (binary)
// ============================================================
typedef struct {
    volatile uint32_t count;  // 0 o 1 (binary semaphore)
} Semaphore_t;

void semaphore_init(Semaphore_t* sem, uint32_t initial_value) {
    sem->count = initial_value;
}

// Wait (P operation, acquire)
void semaphore_wait(Semaphore_t* sem) {
    while (1) {
        // Atomic test-and-set
        uint32_t old_value = __sync_fetch_and_sub(&sem->count, 1);

        if (old_value > 0) {
            // Successfully acquired
            __sync_synchronize();
            return;
        } else {
            // Failed, restore count
            __sync_fetch_and_add(&sem->count, 1);

            // Yield CPU (si hay scheduler)
            // yield();

            // O esperar un poco
            __delay_us(10);
        }
    }
}

// Signal (V operation, release)
void semaphore_signal(Semaphore_t* sem) {
    __sync_synchronize();
    __sync_fetch_and_add(&sem->count, 1);
}

// ============================================================
// Counting Semaphore
// ============================================================
typedef struct {
    volatile uint32_t count;
    uint32_t max_count;
} CountingSemaphore_t;

void counting_sem_init(CountingSemaphore_t* sem, uint32_t initial, uint32_t max) {
    sem->count = initial;
    sem->max_count = max;
}

void counting_sem_wait(CountingSemaphore_t* sem) {
    while (1) {
        uint32_t old = __sync_fetch_and_sub(&sem->count, 1);
        if (old > 0) {
            __sync_synchronize();
            return;
        } else {
            __sync_fetch_and_add(&sem->count, 1);
            __delay_us(10);
        }
    }
}

void counting_sem_signal(CountingSemaphore_t* sem) {
    while (1) {
        uint32_t old = __sync_fetch_and_add(&sem->count, 1);
        if (old < sem->max_count) {
            __sync_synchronize();
            return;
        } else {
            // Ya estaba en max
            __sync_fetch_and_sub(&sem->count, 1);
            break;
        }
    }
}
```

### 4.3 Producer-Consumer con Queues

```c
// ============================================================
// Producer-Consumer Pattern
// ============================================================
MessageQueue_t g_sensor_queue;
Semaphore_t g_queue_mutex;
Semaphore_t g_items_available;
Semaphore_t g_space_available;

void ipc_init(void) {
    semaphore_init(&g_queue_mutex, 1);  // Mutex (binary)
    semaphore_init(&g_items_available, 0);  // Inicialmente vacío
    semaphore_init(&g_space_available, QUEUE_SIZE);  // Inicialmente lleno de espacio
}

// ============================================================
// PRODUCER (Core 0 o ISR)
// ============================================================
void producer_send_sensor_data(float temperature, float pressure) {
    // Esperar a que haya espacio
    semaphore_wait(&g_space_available);

    // Lock queue
    semaphore_wait(&g_queue_mutex);

    // Crear mensaje
    typedef struct {
        float temp;
        float press;
    } SensorMsg_t;

    SensorMsg_t msg = {
        .temp = temperature,
        .press = pressure
    };

    // Enviar
    queue_send(&g_sensor_queue, (uint8_t*)&msg, sizeof(msg));

    // Unlock queue
    semaphore_signal(&g_queue_mutex);

    // Signal que hay item disponible
    semaphore_signal(&g_items_available);
}

// ============================================================
// CONSUMER (Core 1)
// ============================================================
void consumer_process_sensor_data(void) {
    // Esperar a que haya item disponible
    semaphore_wait(&g_items_available);

    // Lock queue
    semaphore_wait(&g_queue_mutex);

    // Recibir mensaje
    uint8_t buffer[64];
    uint16_t length;
    queue_receive(&g_sensor_queue, buffer, &length);

    // Unlock queue
    semaphore_signal(&g_queue_mutex);

    // Signal que hay espacio disponible
    semaphore_signal(&g_space_available);

    // Procesar mensaje
    SensorMsg_t* msg = (SensorMsg_t*)buffer;
    process_data(msg->temp, msg->press);
}
```

---

## 5. Resource Sharing y Synchronization

### 5.1 Mutex Implementation

```c
// ============================================================
// Mutex (Mutual Exclusion)
// ============================================================
typedef struct {
    volatile uint32_t locked;  // 0 = unlocked, 1 = locked
    volatile uint32_t owner;   // Task ID del owner (para debug)
} Mutex_t;

void mutex_init(Mutex_t* mutex) {
    mutex->locked = 0;
    mutex->owner = 0;
}

void mutex_lock(Mutex_t* mutex) {
    uint32_t task_id = get_current_task_id();

    while (1) {
        // Atomic test-and-set
        if (__sync_bool_compare_and_swap(&mutex->locked, 0, 1)) {
            // Successfully acquired lock
            mutex->owner = task_id;
            __sync_synchronize();
            return;
        }

        // Lock is held by another task, wait
        __delay_us(1);
    }
}

bool mutex_trylock(Mutex_t* mutex) {
    if (__sync_bool_compare_and_swap(&mutex->locked, 0, 1)) {
        mutex->owner = get_current_task_id();
        __sync_synchronize();
        return true;
    }
    return false;
}

void mutex_unlock(Mutex_t* mutex) {
    __sync_synchronize();
    mutex->owner = 0;
    mutex->locked = 0;
}

// Uso
Mutex_t g_spi_mutex;

void safe_spi_transfer(uint8_t* data, size_t len) {
    mutex_lock(&g_spi_mutex);

    // Critical section: Solo un task puede usar SPI a la vez
    spi_transfer(data, len);

    mutex_unlock(&g_spi_mutex);
}
```

### 5.2 Reader-Writer Locks

```c
// ============================================================
// Reader-Writer Lock
// Permite múltiples readers simultáneos, pero solo 1 writer
// ============================================================
typedef struct {
    volatile uint32_t readers;      // Número de readers activos
    volatile uint32_t writer_locked; // 0 = no writer, 1 = writer activo
    Mutex_t mutex;                  // Protege readers counter
} RWLock_t;

void rwlock_init(RWLock_t* lock) {
    lock->readers = 0;
    lock->writer_locked = 0;
    mutex_init(&lock->mutex);
}

// Reader lock
void rwlock_read_lock(RWLock_t* lock) {
    while (1) {
        // Esperar a que no haya writer
        while (lock->writer_locked) {
            __delay_us(1);
        }

        mutex_lock(&lock->mutex);

        // Double-check que no hay writer
        if (lock->writer_locked == 0) {
            lock->readers++;
            mutex_unlock(&lock->mutex);
            __sync_synchronize();
            return;
        }

        mutex_unlock(&lock->mutex);
    }
}

void rwlock_read_unlock(RWLock_t* lock) {
    mutex_lock(&lock->mutex);
    lock->readers--;
    mutex_unlock(&lock->mutex);
}

// Writer lock
void rwlock_write_lock(RWLock_t* lock) {
    // Adquirir writer lock
    while (!__sync_bool_compare_and_swap(&lock->writer_locked, 0, 1)) {
        __delay_us(1);
    }

    // Esperar a que no haya readers
    while (lock->readers > 0) {
        __delay_us(1);
    }

    __sync_synchronize();
}

void rwlock_write_unlock(RWLock_t* lock) {
    __sync_synchronize();
    lock->writer_locked = 0;
}

// Ejemplo de uso
RWLock_t g_config_lock;
ConfigData_t g_shared_config;

// Múltiples tasks pueden leer simultáneamente
void task_read_config(void) {
    rwlock_read_lock(&g_config_lock);

    // Leer config (muchos readers OK)
    float setpoint = g_shared_config.setpoint;
    uint32_t mode = g_shared_config.mode;

    rwlock_read_unlock(&g_config_lock);

    use_config(setpoint, mode);
}

// Solo un task puede escribir (y bloquea todos los readers)
void task_update_config(float new_setpoint) {
    rwlock_write_lock(&g_config_lock);

    // Modificar config (solo 1 writer, no readers)
    g_shared_config.setpoint = new_setpoint;

    rwlock_write_unlock(&g_config_lock);
}
```

### 5.3 Spinlocks

```c
// ============================================================
// Spinlock (busy-waiting, solo para critical sections MUY cortas)
// ============================================================
typedef struct {
    volatile uint32_t locked;
} Spinlock_t;

void spinlock_init(Spinlock_t* lock) {
    lock->locked = 0;
}

void spinlock_lock(Spinlock_t* lock) {
    while (!__sync_bool_compare_and_swap(&lock->locked, 0, 1)) {
        // Busy wait (spin)
        // Usar solo para critical sections < 10 µs
    }
    __sync_synchronize();
}

void spinlock_unlock(Spinlock_t* lock) {
    __sync_synchronize();
    lock->locked = 0;
}

// Uso: Proteger shared counter (muy rápido)
Spinlock_t g_counter_lock;
volatile uint32_t g_shared_counter;

void increment_shared_counter(void) {
    spinlock_lock(&g_counter_lock);
    g_shared_counter++;  // 1 ciclo
    spinlock_unlock(&g_counter_lock);
}
```

### 5.4 Lock-Free Algorithms

```c
// ============================================================
// Lock-free ring buffer (sin mutex, usando atomic operations)
// ============================================================
typedef struct {
    uint8_t buffer[256];
    volatile uint32_t head;
    volatile uint32_t tail;
} LockFreeRingBuffer_t;

// Push (producer)
bool lockfree_push(LockFreeRingBuffer_t* rb, uint8_t data) {
    uint32_t current_head, next_head;

    do {
        current_head = rb->head;
        next_head = (current_head + 1) & 0xFF;

        // Check si está lleno
        if (next_head == rb->tail) {
            return false;  // Full
        }

    } while (!__sync_bool_compare_and_swap(&rb->head, current_head, next_head));

    // Ahora tenemos "reservado" el slot en current_head
    rb->buffer[current_head] = data;

    return true;
}

// Pop (consumer)
bool lockfree_pop(LockFreeRingBuffer_t* rb, uint8_t* data) {
    uint32_t current_tail, next_tail;

    do {
        current_tail = rb->tail;

        // Check si está vacío
        if (current_tail == rb->head) {
            return false;  // Empty
        }

        next_tail = (current_tail + 1) & 0xFF;

    } while (!__sync_bool_compare_and_swap(&rb->tail, current_tail, next_tail));

    // Ahora tenemos "reservado" el slot en current_tail
    *data = rb->buffer[current_tail];

    return true;
}

// Ventaja: Sin mutex → No hay contention, muy rápido
// Desventaja: Más complejo, solo funciona para estructuras simples
```

---

## 6. Deadlock Prevention

### 6.1 Deadlock Conditions

**4 condiciones necesarias para deadlock:**

```
1. MUTUAL EXCLUSION: Recursos no compartibles
2. HOLD AND WAIT: Process mantiene recursos mientras espera otros
3. NO PREEMPTION: Recursos no pueden ser forzosamente quitados
4. CIRCULAR WAIT: Ciclo de dependencies entre processes
```

**Ejemplo de deadlock:**

```c
// ❌ DEADLOCK SCENARIO
Mutex_t g_mutex_A;
Mutex_t g_mutex_B;

// Task 1
void task1(void) {
    mutex_lock(&g_mutex_A);  // Lock A
    __delay_ms(10);          // Simulate work
    mutex_lock(&g_mutex_B);  // Wait for B (bloqueado si Task2 tiene B)

    // Critical section con A y B

    mutex_unlock(&g_mutex_B);
    mutex_unlock(&g_mutex_A);
}

// Task 2
void task2(void) {
    mutex_lock(&g_mutex_B);  // Lock B
    __delay_ms(10);
    mutex_lock(&g_mutex_A);  // Wait for A (bloqueado si Task1 tiene A)

    // Critical section con A y B

    mutex_unlock(&g_mutex_A);
    mutex_unlock(&g_mutex_B);
}

// Deadlock:
// Task1 tiene A, espera B
// Task2 tiene B, espera A
// → Ambos bloqueados forever!
```

### 6.2 Prevention Strategies

**Solución 1: Lock ordering**

```c
// ✅ SOLUCIÓN: Siempre adquirir locks en el mismo orden

// Task 1
void task1_fixed(void) {
    mutex_lock(&g_mutex_A);  // Primero A
    mutex_lock(&g_mutex_B);  // Luego B

    // Critical section

    mutex_unlock(&g_mutex_B);
    mutex_unlock(&g_mutex_A);
}

// Task 2
void task2_fixed(void) {
    mutex_lock(&g_mutex_A);  // Primero A (mismo orden!)
    mutex_lock(&g_mutex_B);  // Luego B

    // Critical section

    mutex_unlock(&g_mutex_B);
    mutex_unlock(&g_mutex_A);
}

// No deadlock: Orden consistente previene circular wait
```

**Solución 2: Try-lock con timeout**

```c
// ✅ Usar trylock y retry si falla

bool acquire_both_locks_safe(Mutex_t* a, Mutex_t* b, uint32_t timeout_ms) {
    uint32_t start_time = get_tick_ms();

    while ((get_tick_ms() - start_time) < timeout_ms) {
        // Intentar lock A
        if (mutex_trylock(a)) {
            // Intentar lock B
            if (mutex_trylock(b)) {
                // Ambos adquiridos!
                return true;
            } else {
                // B no disponible, release A y retry
                mutex_unlock(a);
            }
        }

        // Esperar un poco antes de retry
        __delay_ms(1);
    }

    // Timeout
    return false;
}

void task_safe(void) {
    if (acquire_both_locks_safe(&g_mutex_A, &g_mutex_B, 1000)) {
        // Critical section

        mutex_unlock(&g_mutex_B);
        mutex_unlock(&g_mutex_A);
    } else {
        // Error: timeout
        log_error("Could not acquire locks");
    }
}
```

**Solución 3: Banker's Algorithm (resource allocation graph)**

```c
// Algoritmo complejo, raramente usado en embedded
// Ver literatura de sistemas operativos
```

### 6.3 Detection y Recovery

```c
// Watchdog para detectar deadlock
#define WATCHDOG_TIMEOUT_MS 5000

typedef struct {
    uint32_t last_heartbeat;
    bool is_alive;
} TaskMonitor_t;

TaskMonitor_t g_task_monitors[10];

// Cada task debe hacer heartbeat periódicamente
void task_heartbeat(uint8_t task_id) {
    g_task_monitors[task_id].last_heartbeat = get_tick_ms();
    g_task_monitors[task_id].is_alive = true;
}

// Monitor task (prioridad alta)
void deadlock_monitor_task(void) {
    while (1) {
        uint32_t now = get_tick_ms();

        for (uint8_t i = 0; i < 10; i++) {
            if (g_task_monitors[i].is_alive) {
                uint32_t elapsed = now - g_task_monitors[i].last_heartbeat;
                if (elapsed > WATCHDOG_TIMEOUT_MS) {
                    // Deadlock detectado!
                    log_error("Task %d deadlock detected!", i);

                    // Recovery: Reset system
                    system_reset();
                }
            }
        }

        __delay_ms(1000);  // Check cada 1 segundo
    }
}
```

---

## 7. Priority Inversion

### 7.1 Qué es Priority Inversion

```
╔════════════════════════════════════════════════════════╗
║              PRIORITY INVERSION                        ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║  Prioridades: High (H) > Medium (M) > Low (L)         ║
║                                                        ║
║  Scenario:                                             ║
║  ────────────────────────────────────────             ║
║  t0: Task L adquiere mutex                             ║
║  t1: Task M empieza a ejecutar (preempts L)           ║
║  t2: Task H necesita mutex (bloqueado por L)          ║
║                                                        ║
║  Problema:                                             ║
║  ────────────────────────────────────────             ║
║  - Task H (high priority) está bloqueado por L        ║
║  - Task M (medium priority) ejecuta                   ║
║  - Task L (low priority) no puede ejecutar (preempted)║
║                                                        ║
║  Resultado: Task H espera a que M termine!            ║
║  → Priority inversion (H < M efectivamente)           ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
```

**Timeline:**

```
Time  →
─────────────────────────────────────────────────────
Task H:           [blocked waiting mutex]
Task M:      [Running........................]
Task L: [Lock]  [blocked by M]        [Unlock]
─────────────────────────────────────────────────────
        ↑                              ↑
    L locks mutex              L finally unlocks
    H wants mutex              H can now run
```

### 7.2 Priority Inheritance Protocol

```c
// ============================================================
// Mutex con Priority Inheritance
// ============================================================
typedef struct {
    volatile uint32_t locked;
    volatile uint32_t owner_task_id;
    volatile uint32_t owner_original_priority;
} PIMutex_t;

extern uint32_t g_task_priorities[MAX_TASKS];  // Array de prioridades

void pi_mutex_init(PIMutex_t* mutex) {
    mutex->locked = 0;
    mutex->owner_task_id = 0;
    mutex->owner_original_priority = 0;
}

void pi_mutex_lock(PIMutex_t* mutex) {
    uint32_t current_task = get_current_task_id();
    uint32_t current_priority = g_task_priorities[current_task];

    while (1) {
        if (__sync_bool_compare_and_swap(&mutex->locked, 0, 1)) {
            // Adquirido!
            mutex->owner_task_id = current_task;
            mutex->owner_original_priority = current_priority;
            __sync_synchronize();
            return;
        }

        // Mutex bloqueado por otro task

        // PRIORITY INHERITANCE:
        // Si owner tiene menor prioridad, elevarlo temporalmente
        uint32_t owner = mutex->owner_task_id;
        if (g_task_priorities[owner] < current_priority) {
            g_task_priorities[owner] = current_priority;  // Heredar prioridad
        }

        // Yield CPU
        task_yield();
    }
}

void pi_mutex_unlock(PIMutex_t* mutex) {
    uint32_t current_task = get_current_task_id();

    // Restaurar prioridad original
    g_task_priorities[current_task] = mutex->owner_original_priority;

    __sync_synchronize();

    mutex->owner_task_id = 0;
    mutex->locked = 0;
}
```

**Ejemplo con Priority Inheritance:**

```
Time  →
─────────────────────────────────────────────────────
Task H:           [blocked]→[runs!]
Task M:      [blocked by higher priority L]
Task L: [Lock]  [L inherits H priority!] [Unlock]
─────────────────────────────────────────────────────
        ↑         ↑                       ↑
    L locks    L priority    L unlocks, H runs
               raised to H
```

### 7.3 Priority Ceiling Protocol

```c
// ============================================================
// Priority Ceiling: Cada mutex tiene una "ceiling priority"
// El task que adquiere el mutex hereda ceiling priority
// ============================================================
typedef struct {
    volatile uint32_t locked;
    uint32_t ceiling_priority;  // Máxima prioridad de todos los tasks que usan este mutex
    volatile uint32_t owner_task_id;
    volatile uint32_t owner_original_priority;
} PCMutex_t;

void pc_mutex_init(PCMutex_t* mutex, uint32_t ceiling_priority) {
    mutex->locked = 0;
    mutex->ceiling_priority = ceiling_priority;
    mutex->owner_task_id = 0;
    mutex->owner_original_priority = 0;
}

void pc_mutex_lock(PCMutex_t* mutex) {
    uint32_t current_task = get_current_task_id();
    uint32_t original_priority = g_task_priorities[current_task];

    while (!__sync_bool_compare_and_swap(&mutex->locked, 0, 1)) {
        task_yield();
    }

    // Adquirido!
    mutex->owner_task_id = current_task;
    mutex->owner_original_priority = original_priority;

    // Elevar a ceiling priority
    g_task_priorities[current_task] = mutex->ceiling_priority;

    __sync_synchronize();
}

void pc_mutex_unlock(PCMutex_t* mutex) {
    uint32_t current_task = get_current_task_id();

    // Restaurar prioridad original
    g_task_priorities[current_task] = mutex->owner_original_priority;

    __sync_synchronize();

    mutex->owner_task_id = 0;
    mutex->locked = 0;
}

// Ventaja: Previene deadlock (si ceiling priorities son correctas)
// Desventaja: Puede elevar prioridad más de lo necesario
```

---

## 8. Distributed Systems

### 8.1 Master-Slave Architecture

```c
// ============================================================
// Master-Slave Pattern
// Master: Coordina, envía comandos
// Slaves: Ejecutan comandos, reportan status
// ============================================================

// Protocolo de comunicación
typedef enum {
    CMD_READ_SENSOR = 0x01,
    CMD_SET_ACTUATOR = 0x02,
    CMD_GET_STATUS = 0x03,
    CMD_RESET = 0xFF
} Command_t;

typedef struct __attribute__((packed)) {
    uint8_t slave_id;
    uint8_t command;
    uint8_t data_length;
    uint8_t data[32];
    uint8_t checksum;
} MasterSlavePacket_t;

// ============================================================
// MASTER
// ============================================================
void master_send_command(uint8_t slave_id, Command_t cmd, uint8_t* data, uint8_t len) {
    MasterSlavePacket_t packet;

    packet.slave_id = slave_id;
    packet.command = cmd;
    packet.data_length = len;
    memcpy(packet.data, data, len);
    packet.checksum = calculate_checksum(&packet, sizeof(packet) - 1);

    // Enviar por RS485 / CAN / Ethernet
    rs485_send((uint8_t*)&packet, sizeof(packet));

    // Esperar respuesta del slave
    MasterSlavePacket_t response;
    if (rs485_receive((uint8_t*)&response, sizeof(response), 1000)) {
        // Procesar respuesta
        process_slave_response(&response);
    } else {
        log_error("Slave %d timeout", slave_id);
    }
}

// ============================================================
// SLAVE
// ============================================================
void slave_main_loop(uint8_t my_slave_id) {
    while (1) {
        MasterSlavePacket_t packet;

        // Esperar comando del master
        if (rs485_receive((uint8_t*)&packet, sizeof(packet), TIMEOUT_INFINITE)) {
            // Verificar que es para nosotros
            if (packet.slave_id == my_slave_id || packet.slave_id == 0xFF) {  // 0xFF = broadcast
                // Verificar checksum
                if (verify_checksum(&packet, sizeof(packet))) {
                    // Ejecutar comando
                    execute_command(&packet);

                    // Enviar respuesta
                    send_response_to_master(&packet);
                }
            }
        }
    }
}

void execute_command(MasterSlavePacket_t* packet) {
    switch (packet->command) {
        case CMD_READ_SENSOR:
            // Leer sensor y llenar packet.data con resultado
            packet->data[0] = read_sensor();
            packet->data_length = 1;
            break;

        case CMD_SET_ACTUATOR:
            // Activar actuador con valor en packet.data
            set_actuator(packet->data[0]);
            packet->data_length = 0;  // No data en respuesta
            break;

        case CMD_GET_STATUS:
            // Reportar status
            packet->data[0] = get_system_status();
            packet->data_length = 1;
            break;

        case CMD_RESET:
            // Reset
            system_reset();
            break;
    }
}
```

### 8.2 Publish-Subscribe Pattern

```c
// ============================================================
// Pub-Sub Pattern (ej: MQTT-like)
// ============================================================
#define MAX_TOPICS 10
#define MAX_SUBSCRIBERS 5

typedef void (*SubscriberCallback_t)(const char* topic, uint8_t* data, uint16_t len);

typedef struct {
    char topic[32];
    SubscriberCallback_t callbacks[MAX_SUBSCRIBERS];
    uint8_t subscriber_count;
} Topic_t;

static Topic_t g_topics[MAX_TOPICS];
static uint8_t g_topic_count = 0;

// Subscribe
bool pubsub_subscribe(const char* topic, SubscriberCallback_t callback) {
    // Buscar topic existente
    for (uint8_t i = 0; i < g_topic_count; i++) {
        if (strcmp(g_topics[i].topic, topic) == 0) {
            // Topic existe, agregar subscriber
            if (g_topics[i].subscriber_count < MAX_SUBSCRIBERS) {
                g_topics[i].callbacks[g_topics[i].subscriber_count++] = callback;
                return true;
            }
            return false;  // Max subscribers alcanzado
        }
    }

    // Topic no existe, crear nuevo
    if (g_topic_count < MAX_TOPICS) {
        strcpy(g_topics[g_topic_count].topic, topic);
        g_topics[g_topic_count].callbacks[0] = callback;
        g_topics[g_topic_count].subscriber_count = 1;
        g_topic_count++;
        return true;
    }

    return false;
}

// Publish
void pubsub_publish(const char* topic, uint8_t* data, uint16_t len) {
    // Encontrar topic
    for (uint8_t i = 0; i < g_topic_count; i++) {
        if (strcmp(g_topics[i].topic, topic) == 0) {
            // Notificar a todos los subscribers
            for (uint8_t j = 0; j < g_topics[i].subscriber_count; j++) {
                g_topics[i].callbacks[j](topic, data, len);
            }
            return;
        }
    }
}

// Ejemplo de uso
void temperature_callback(const char* topic, uint8_t* data, uint16_t len) {
    float* temp = (float*)data;
    printf("Temperature updated: %.2f\n", *temp);
}

void logger_callback(const char* topic, uint8_t* data, uint16_t len) {
    // Log all events
    log_data(topic, data, len);
}

void init_pubsub_example(void) {
    // Múltiples subscribers al mismo topic
    pubsub_subscribe("sensor/temperature", temperature_callback);
    pubsub_subscribe("sensor/temperature", logger_callback);
}

void sensor_task(void) {
    float temp = read_temperature();
    pubsub_publish("sensor/temperature", (uint8_t*)&temp, sizeof(temp));
}
```

### 8.3 Request-Reply Pattern

```c
// ============================================================
// Request-Reply (RPC-like)
// ============================================================
typedef enum {
    REQ_GET_TEMPERATURE = 1,
    REQ_SET_SETPOINT = 2,
    REQ_START_MOTOR = 3
} RequestType_t;

typedef struct {
    uint32_t request_id;  // Único por request
    RequestType_t type;
    uint8_t data[32];
    uint16_t data_len;
} Request_t;

typedef struct {
    uint32_t request_id;  // Mismo que el request
    uint8_t status;       // 0 = OK, error codes
    uint8_t data[32];
    uint16_t data_len;
} Reply_t;

// Cliente
Reply_t send_request_and_wait(Request_t* req, uint32_t timeout_ms) {
    static uint32_t next_request_id = 1;
    req->request_id = next_request_id++;

    // Enviar request
    network_send(req, sizeof(Request_t));

    // Esperar reply
    Reply_t reply;
    uint32_t start = get_tick_ms();

    while ((get_tick_ms() - start) < timeout_ms) {
        if (network_receive(&reply, sizeof(Reply_t), 10)) {
            if (reply.request_id == req->request_id) {
                return reply;  // Reply recibido!
            }
        }
    }

    // Timeout
    reply.status = 0xFF;  // Error: timeout
    return reply;
}

// Servidor
void server_process_requests(void) {
    Request_t req;

    if (network_receive(&req, sizeof(Request_t), 100)) {
        Reply_t reply;
        reply.request_id = req.request_id;

        // Procesar request
        switch (req.type) {
            case REQ_GET_TEMPERATURE:
                {
                    float temp = read_temperature();
                    memcpy(reply.data, &temp, sizeof(temp));
                    reply.data_len = sizeof(temp);
                    reply.status = 0;  // OK
                }
                break;

            case REQ_SET_SETPOINT:
                {
                    float setpoint = *(float*)req.data;
                    set_setpoint(setpoint);
                    reply.data_len = 0;
                    reply.status = 0;  // OK
                }
                break;

            default:
                reply.status = 1;  // Error: unknown request
                reply.data_len = 0;
                break;
        }

        // Enviar reply
        network_send(&reply, sizeof(Reply_t));
    }
}
```

---

## 9. Communication Protocols para IPC

### 9.1 CAN Bus Network

```c
// ============================================================
// CAN Bus Multi-Master Network
// ============================================================

// Configurar CAN @ 500 kbps
void can_init(void) {
    // Configuración del módulo CAN (ej: PIC32 CAN1)
    C1CONbits.ON = 0;  // Deshabilitar para config

    // Baud rate: 500 kbps @ 40 MHz
    C1CFGbits.BRP = 4;    // Bit rate prescaler
    C1CFGbits.SJW = 1;    // Sync jump width
    C1CFGbits.PRSEG = 1;  // Propagation segment
    C1CFGbits.SEG1PH = 3; // Phase segment 1
    C1CFGbits.SEG2PH = 3; // Phase segment 2

    // Configurar filtros (aceptar todos los mensajes)
    C1RXF0bits.SID = 0x000;
    C1RXM0bits.SID = 0x000;  // Mask = 0 (aceptar todo)

    C1CONbits.ON = 1;  // Habilitar CAN
}

// Enviar mensaje CAN
bool can_send(uint16_t id, uint8_t* data, uint8_t len) {
    // Esperar que TX buffer esté disponible
    while (C1TX0CONbits.TXREQ);

    // Configurar mensaje
    C1TX0SIDbits.SID = id;
    C1TX0DLCbits.DLC = len;

    // Copiar datos
    uint32_t* tx_data = (uint32_t*)&C1TX0D0;
    memcpy(tx_data, data, len);

    // Enviar
    C1TX0CONbits.TXREQ = 1;

    return true;
}

// Recibir mensaje CAN
bool can_receive(uint16_t* id, uint8_t* data, uint8_t* len, uint32_t timeout_ms) {
    uint32_t start = get_tick_ms();

    while ((get_tick_ms() - start) < timeout_ms) {
        if (C1RX0CONbits.RXFUL) {
            // Mensaje recibido
            *id = C1RX0SIDbits.SID;
            *len = C1RX0DLCbits.DLC;

            // Copiar datos
            uint32_t* rx_data = (uint32_t*)&C1RX0D0;
            memcpy(data, rx_data, *len);

            // Clear flag
            C1RX0CONbits.RXFUL = 0;

            return true;
        }
    }

    return false;  // Timeout
}

// Ejemplo: Sistema distribuido con CAN
#define CAN_ID_MASTER 0x100
#define CAN_ID_SLAVE1 0x101
#define CAN_ID_SLAVE2 0x102

void master_broadcast_command(uint8_t cmd) {
    uint8_t data[1] = { cmd };
    can_send(CAN_ID_MASTER, data, 1);
}

void slave_listen_commands(uint16_t my_id) {
    uint16_t id;
    uint8_t data[8];
    uint8_t len;

    if (can_receive(&id, data, &len, 100)) {
        if (id == CAN_ID_MASTER) {
            // Comando del master
            execute_command(data[0]);

            // Enviar respuesta
            uint8_t response[2] = { data[0], get_status() };
            can_send(my_id, response, 2);
        }
    }
}
```

---

## 10. Redundancy y Fault Tolerance

### 10.1 Active-Standby

```c
// ============================================================
// Active-Standby Redundancy
// MCU principal + MCU de respaldo
// ============================================================

typedef enum {
    ROLE_ACTIVE,
    ROLE_STANDBY
} SystemRole_t;

SystemRole_t g_role = ROLE_STANDBY;
bool g_partner_alive = false;

// Heartbeat entre MCUs (via UART/CAN)
#define HEARTBEAT_INTERVAL_MS 100
#define HEARTBEAT_TIMEOUT_MS 500

void send_heartbeat(void) {
    uint8_t msg[4] = { 0xAA, 0x55, g_role, get_system_health() };
    uart_send(msg, 4);
}

void check_partner_heartbeat(void) {
    static uint32_t last_heartbeat = 0;
    uint8_t msg[4];

    if (uart_receive(msg, 4, 10)) {
        if (msg[0] == 0xAA && msg[1] == 0x55) {
            last_heartbeat = get_tick_ms();
            g_partner_alive = true;
        }
    }

    // Check timeout
    if ((get_tick_ms() - last_heartbeat) > HEARTBEAT_TIMEOUT_MS) {
        g_partner_alive = false;

        // Si partner murió y somos standby → promover a active
        if (g_role == ROLE_STANDBY) {
            log_info("Partner failed, promoting to ACTIVE");
            g_role = ROLE_ACTIVE;
            activate_outputs();  // Tomar control
        }
    }
}

void main_redundant_loop(void) {
    while (1) {
        // Enviar heartbeat
        if (timer_elapsed_ms(HEARTBEAT_INTERVAL_MS)) {
            send_heartbeat();
        }

        // Check partner
        check_partner_heartbeat();

        // Ejecutar según rol
        if (g_role == ROLE_ACTIVE) {
            // Control activo
            run_control_loop();
            update_outputs();
        } else {
            // Standby: solo monitorear
            monitor_system();
            keep_outputs_disabled();
        }
    }
}
```

### 10.2 Triple Modular Redundancy (TMR)

```c
// ============================================================
// TMR: 3 sensores, mayoría gana (voting)
// ============================================================

typedef struct {
    float value;
    bool valid;
} SensorReading_t;

float tmr_read_sensor(void) {
    SensorReading_t readings[3];

    // Leer 3 sensores
    readings[0].value = read_sensor_1();
    readings[0].valid = sensor_1_is_healthy();

    readings[1].value = read_sensor_2();
    readings[1].valid = sensor_2_is_healthy();

    readings[2].value = read_sensor_3();
    readings[2].valid = sensor_3_is_healthy();

    // Voting: Encontrar mayoría
    // Algoritmo: Comparar valores, si 2 o más están cerca → promedio de esos
    const float THRESHOLD = 1.0f;  // Tolerancia

    // Comparar 0-1
    if (readings[0].valid && readings[1].valid) {
        if (fabsf(readings[0].value - readings[1].value) < THRESHOLD) {
            // 0 y 1 coinciden
            if (readings[2].valid && fabsf(readings[2].value - readings[0].value) < THRESHOLD) {
                // Los 3 coinciden
                return (readings[0].value + readings[1].value + readings[2].value) / 3.0f;
            } else {
                // 0 y 1 coinciden, 2 es outlier
                log_warning("Sensor 2 outlier");
                return (readings[0].value + readings[1].value) / 2.0f;
            }
        }
    }

    // Comparar 0-2
    if (readings[0].valid && readings[2].valid) {
        if (fabsf(readings[0].value - readings[2].value) < THRESHOLD) {
            // 0 y 2 coinciden, 1 es outlier
            log_warning("Sensor 1 outlier");
            return (readings[0].value + readings[2].value) / 2.0f;
        }
    }

    // Comparar 1-2
    if (readings[1].valid && readings[2].valid) {
        if (fabsf(readings[1].value - readings[2].value) < THRESHOLD) {
            // 1 y 2 coinciden, 0 es outlier
            log_warning("Sensor 0 outlier");
            return (readings[1].value + readings[2].value) / 2.0f;
        }
    }

    // No hay mayoría → error crítico
    log_error("TMR failure: no majority");
    enter_safe_mode();
    return 0.0f;
}
```

### 10.3 Watchdog Patterns

```c
// ============================================================
// Watchdog externo + interno
// ============================================================

// Watchdog interno (MCU reset automático)
void internal_watchdog_init(void) {
    // Configurar WDT para 2 segundos timeout
    WDTCONbits.ON = 1;
    WDTCONbits.WDTCLR = 0;  // Clear WDT
}

void internal_watchdog_kick(void) {
    WDTCONbits.WDTCLR = 1;  // Reset WDT counter
}

// Watchdog externo (vía GPIO toggle)
#define EXT_WDG_PIN LATAbits.LATA0

void external_watchdog_kick(void) {
    // Toggle pin (external watchdog espera toggle periódico)
    EXT_WDG_PIN = !EXT_WDG_PIN;
}

// Main loop
void main_loop_with_watchdog(void) {
    internal_watchdog_init();

    while (1) {
        // Ejecutar tareas
        task1();
        task2();
        task3();

        // Kick watchdogs
        internal_watchdog_kick();
        external_watchdog_kick();

        // Si hay deadlock/hang, watchdog resetea el sistema
    }
}
```

---

## 11. Real-Time Constraints

### 11.1 Worst-Case Execution Time (WCET)

```c
// Medir WCET de función crítica
uint32_t measure_wcet(void (*function)(void), uint32_t iterations) {
    uint32_t max_cycles = 0;

    for (uint32_t i = 0; i < iterations; i++) {
        uint32_t start = TMR2;  // Timer de alta resolución
        function();
        uint32_t end = TMR2;
        uint32_t cycles = end - start;

        if (cycles > max_cycles) {
            max_cycles = cycles;
        }
    }

    return max_cycles;
}

// Ejemplo
void control_loop_task(void) {
    read_sensors();
    pid_update();
    write_outputs();
}

void analyze_wcet(void) {
    uint32_t wcet = measure_wcet(control_loop_task, 10000);
    float wcet_us = wcet / (FCY / 1000000.0f);

    printf("WCET: %lu cycles (%.2f us)\n", wcet, wcet_us);

    // Verificar que WCET < deadline
    const float DEADLINE_US = 1000.0f;  // 1 ms deadline
    if (wcet_us < DEADLINE_US) {
        printf("✅ WCET OK (%.1f%% de deadline)\n", (wcet_us / DEADLINE_US) * 100.0f);
    } else {
        printf("❌ WCET excede deadline!\n");
    }
}
```

### 11.2 Rate-Monotonic Scheduling

```c
// Rate-Monotonic: Prioridad inversamente proporcional al período
// Menor período → Mayor prioridad

typedef struct {
    void (*function)(void);
    uint32_t period_ms;
    uint32_t next_run_time;
    uint8_t priority;  // Mayor número = mayor prioridad
} RTTask_t;

RTTask_t g_tasks[5] = {
    { task_100Hz, 10,  0, 5 },  // 100 Hz → Prioridad 5 (máxima)
    { task_50Hz,  20,  0, 4 },  // 50 Hz  → Prioridad 4
    { task_10Hz,  100, 0, 3 },  // 10 Hz  → Prioridad 3
    { task_1Hz,   1000, 0, 2 }, // 1 Hz   → Prioridad 2
    { task_slow,  5000, 0, 1 }  // 0.2 Hz → Prioridad 1 (mínima)
};

void rms_scheduler(void) {
    uint32_t now = get_tick_ms();

    // Encontrar task de mayor prioridad que esté ready
    RTTask_t* ready_task = NULL;
    uint8_t max_priority = 0;

    for (int i = 0; i < 5; i++) {
        if (now >= g_tasks[i].next_run_time) {
            if (g_tasks[i].priority > max_priority) {
                max_priority = g_tasks[i].priority;
                ready_task = &g_tasks[i];
            }
        }
    }

    // Ejecutar task de mayor prioridad
    if (ready_task != NULL) {
        ready_task->function();
        ready_task->next_run_time = now + ready_task->period_ms;
    }
}
```

---

## 12. Cache Coherency

### 12.1 False Sharing

```c
// ============================================================
// FALSE SHARING: Dos cores acceden a variables en la misma cache line
// ============================================================

// ❌ False sharing (ambas variables en misma cache line)
struct {
    volatile uint32_t counter_core0;  // Core 0 modifica esto
    volatile uint32_t counter_core1;  // Core 1 modifica esto
} g_counters;  // Ambas en la misma cache line (64 bytes típico)

// Problema: Cada write invalida cache line del otro core → Lento!

// ✅ Solución: Cache line padding
struct {
    volatile uint32_t counter_core0;
    uint8_t padding0[60];  // Pad a 64 bytes (cache line size)
    volatile uint32_t counter_core1;
    uint8_t padding1[60];
} g_counters_optimized;

// Ahora cada counter está en su propia cache line → No false sharing
```

### 12.2 Memory Barriers

```c
// Memory barriers aseguran orden de memory operations

// Compiler barrier (previene reordering por compilador)
#define COMPILER_BARRIER() asm volatile("" ::: "memory")

// Full memory barrier (previene reordering por CPU + cache flush)
#define MEMORY_BARRIER() __sync_synchronize()

// Ejemplo de uso
volatile bool g_data_ready = false;
volatile uint32_t g_data_value = 0;

// Producer (Core 0)
void producer(void) {
    g_data_value = 12345;

    MEMORY_BARRIER();  // Asegurar que write a data_value sea visible antes de flag

    g_data_ready = true;
}

// Consumer (Core 1)
void consumer(void) {
    while (!g_data_ready) {
        // Spin wait
    }

    MEMORY_BARRIER();  // Asegurar que leemos data_value DESPUÉS de ver flag

    uint32_t value = g_data_value;  // Garantizado que es 12345
    process(value);
}
```

---

## 13. Case Study: Sistema Multi-Core Completo

### Aplicación: Control Industrial Dual-Core

**Descripción:**
- PIC32MZ dual-core @ 200 MHz
- Core 0: Control loops (PID) @ 1 kHz
- Core 1: Ethernet comunicaciones + HMI
- Shared memory para IPC
- Fault tolerance con watchdog

**Arquitectura:**

```
╔════════════════════════════════════════════════════════════╗
║                   CORE 0 (Real-Time)                       ║
╠════════════════════════════════════════════════════════════╣
║  ┌──────────────────────────────────────────────────────┐ ║
║  │  Control Loop @ 1 kHz (Timer ISR)                    │ ║
║  │  ├─ Read ADC (sensors)                               │ ║
║  │  ├─ PID calculation                                  │ ║
║  │  ├─ PWM output (actuators)                           │ ║
║  │  └─ Safety checks                                    │ ║
║  └──────────────────────────────────────────────────────┘ ║
║  ┌──────────────────────────────────────────────────────┐ ║
║  │  Data Publisher                                      │ ║
║  │  └─ Write sensor data a shared memory (100 Hz)      │ ║
║  └──────────────────────────────────────────────────────┘ ║
║  ┌──────────────────────────────────────────────────────┐ ║
║  │  Command Consumer                                    │ ║
║  │  └─ Read commands desde shared memory               │ ║
║  └──────────────────────────────────────────────────────┘ ║
╚════════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════════╗
║                 CORE 1 (Communications)                    ║
╠════════════════════════════════════════════════════════════╣
║  ┌──────────────────────────────────────────────────────┐ ║
║  │  Ethernet Stack (TCP/IP)                             │ ║
║  │  ├─ Modbus TCP server                                │ ║
║  │  ├─ Web server (HMI)                                 │ ║
║  │  └─ MQTT publisher                                   │ ║
║  └──────────────────────────────────────────────────────┘ ║
║  ┌──────────────────────────────────────────────────────┐ ║
║  │  Data Consumer                                       │ ║
║  │  └─ Read sensor data desde shared memory            │ ║
║  └──────────────────────────────────────────────────────┘ ║
║  ┌──────────────────────────────────────────────────────┐ ║
║  │  Command Producer                                    │ ║
║  │  └─ Write commands a shared memory                  │ ║
║  └──────────────────────────────────────────────────────┘ ║
╚════════════════════════════════════════════════════════════╝

                            ↕
              ┌─────────────────────────┐
              │   SHARED MEMORY (4 KB)  │
              │   (uncached region)     │
              └─────────────────────────┘
```

**Código completo:**

```c
// ============================================================
// SHARED MEMORY STRUCTURE
// ============================================================
#define SHARED_MEM_BASE 0xA0020000  // Uncached

typedef struct {
    // Sensor data (Core 0 → Core 1)
    float temperature;
    float pressure;
    float flow_rate;
    uint32_t sensor_timestamp;
    volatile uint32_t sensor_data_ready;

    // Commands (Core 1 → Core 0)
    float temperature_setpoint;
    float pressure_setpoint;
    uint32_t system_mode;  // 0=manual, 1=auto
    volatile uint32_t command_ready;

    // Status
    uint32_t core0_loop_count;
    uint32_t core1_loop_count;
    uint32_t core0_errors;
    uint32_t core1_errors;

    // Synchronization
    Semaphore_t data_semaphore;
    Semaphore_t command_semaphore;
} SharedData_t;

volatile SharedData_t* g_shared = (SharedData_t*)SHARED_MEM_BASE;

// ============================================================
// CORE 0: REAL-TIME CONTROL
// ============================================================
void core0_main(void) {
    // Inicialización
    adc_init();
    pwm_init();
    timer_init_1khz();

    semaphore_init(&g_shared->data_semaphore, 1);
    semaphore_init(&g_shared->command_semaphore, 1);

    while (1) {
        // Main loop solo hace background tasks
        // Control loop está en ISR (determinístico)

        watchdog_kick();

        // Check commands desde Core 1
        if (g_shared->command_ready) {
            semaphore_wait(&g_shared->command_semaphore);

            float temp_sp = g_shared->temperature_setpoint;
            float press_sp = g_shared->pressure_setpoint;
            uint32_t mode = g_shared->system_mode;

            g_shared->command_ready = 0;

            semaphore_signal(&g_shared->command_semaphore);

            // Aplicar comandos
            apply_setpoints(temp_sp, press_sp, mode);
        }
    }
}

// ISR de control @ 1 kHz
void __ISR(_TIMER_1_VECTOR, IPL7SRS) Timer1_ISR(void) {
    // 1. Read sensors (ADC ya configurado con DMA)
    float temp = adc_get_temperature();
    float pressure = adc_get_pressure();
    float flow = adc_get_flow();

    // 2. PID control
    float temp_output = pid_update(&g_temp_pid, temp);
    float press_output = pid_update(&g_press_pid, pressure);

    // 3. Update actuators (PWM)
    pwm_set_duty_cycle(0, temp_output);
    pwm_set_duty_cycle(1, press_output);

    // 4. Safety checks
    if (temp > MAX_TEMP || pressure > MAX_PRESSURE) {
        emergency_shutdown();
    }

    // 5. Publish data a Core 1 (cada 10 loops = 100 Hz)
    static uint8_t publish_counter = 0;
    if (++publish_counter >= 10) {
        publish_counter = 0;

        if (semaphore_try_wait(&g_shared->data_semaphore)) {
            g_shared->temperature = temp;
            g_shared->pressure = pressure;
            g_shared->flow_rate = flow;
            g_shared->sensor_timestamp = get_tick_ms();
            __sync_synchronize();
            g_shared->sensor_data_ready = 1;

            semaphore_signal(&g_shared->data_semaphore);
        }
    }

    g_shared->core0_loop_count++;

    IFS0bits.T1IF = 0;  // Clear interrupt flag
}

// ============================================================
// CORE 1: COMMUNICATIONS
// ============================================================
void core1_main(void) {
    // Inicialización
    ethernet_init();
    modbus_tcp_init();
    webserver_init();
    mqtt_init();

    while (1) {
        // 1. Procesar Ethernet stack
        ethernet_process();

        // 2. Procesar Modbus TCP requests
        modbus_tcp_process();

        // 3. Actualizar HMI web
        webserver_process();

        // 4. Publish telemetry MQTT
        if (timer_elapsed_ms(1000)) {  // Cada 1 segundo
            mqtt_publish_telemetry();
        }

        // 5. Consumir sensor data desde Core 0
        if (g_shared->sensor_data_ready) {
            semaphore_wait(&g_shared->data_semaphore);

            float temp = g_shared->temperature;
            float pressure = g_shared->pressure;
            float flow = g_shared->flow_rate;

            g_shared->sensor_data_ready = 0;

            semaphore_signal(&g_shared->data_semaphore);

            // Guardar en buffer para web/MQTT
            update_telemetry_cache(temp, pressure, flow);
        }

        g_shared->core1_loop_count++;
    }
}

// Recibir comando desde red (Modbus TCP)
void modbus_tcp_write_register(uint16_t address, uint16_t value) {
    semaphore_wait(&g_shared->command_semaphore);

    switch (address) {
        case 0:  // Temperature setpoint
            g_shared->temperature_setpoint = (float)value / 10.0f;
            break;
        case 1:  // Pressure setpoint
            g_shared->pressure_setpoint = (float)value / 10.0f;
            break;
        case 2:  // System mode
            g_shared->system_mode = value;
            break;
    }

    __sync_synchronize();
    g_shared->command_ready = 1;

    semaphore_signal(&g_shared->command_semaphore);
}
```

**Performance metrics:**

```
Core 0:
├─ Control loop: 1 kHz (1 ms period)
├─ Execution time: 300 µs (30% CPU load)
├─ Jitter: < 5 µs
└─ Determinism: ✅ Garantizado (no interrumpido por Core 1)

Core 1:
├─ Ethernet: Variable (10-80% CPU)
├─ Web requests: ~50 ms cada request
├─ MQTT publish: 1 Hz (20 ms burst)
└─ Determinism: ❌ No crítico

IPC:
├─ Shared memory access: < 1 µs
├─ Semaphore overhead: < 2 µs
├─ Latency Core0→Core1: 10 ms (100 Hz publish rate)
└─ Latency Core1→Core0: < 10 µs (command checked cada loop)

System:
├─ Uptime: > 1000 horas (probado)
├─ Fault recovery: Watchdog reset < 2 segundos
└─ Total RAM usage: 180 KB / 512 KB (35%)
```

---

## 14. Best Practices

### 14.1 Design Patterns

**Pattern 1: Core separation por criticidad**
```
Core 0 = Real-time (control, safety)
Core 1 = Non-real-time (comms, logging, HMI)
```

**Pattern 2: Lockless communication cuando sea posible**
```
Ring buffers lock-free (atomic ops)
vs
Mutex-protected queues (más lento)
```

**Pattern 3: Cache line awareness**
```
Alinear estructuras shared a cache line boundaries
Evitar false sharing
```

### 14.2 Testing Strategies

```c
// Test de stress para IPC
void stress_test_ipc(void) {
    const uint32_t ITERATIONS = 100000;

    uint32_t start = get_tick_ms();

    for (uint32_t i = 0; i < ITERATIONS; i++) {
        // Core 0: Write
        semaphore_wait(&g_sem);
        g_shared_data = i;
        semaphore_signal(&g_sem);

        // Core 1: Read
        semaphore_wait(&g_sem);
        uint32_t value = g_shared_data;
        semaphore_signal(&g_sem);

        assert(value == i);  // Verificar coherencia
    }

    uint32_t elapsed = get_tick_ms() - start;
    printf("IPC throughput: %lu ops/sec\n", (ITERATIONS * 1000) / elapsed);
}
```

### 14.3 Debugging Multi-Core

```c
// GPIO debug pins para visualizar actividad de cada core
void debug_pin_toggle_core0(void) {
    LATA0 = !LATA0;  // Osciloscopio: Ver actividad Core 0
}

void debug_pin_toggle_core1(void) {
    LATA1 = !LATA1;  // Osciloscopio: Ver actividad Core 1
}

// Logging con core ID
#define LOG(fmt, ...) printf("[Core %d] " fmt "\n", get_core_id(), ##__VA_ARGS__)
```

---

## Conclusión

Las **arquitecturas complejas** (multi-core, distribuidas, redundantes) ofrecen beneficios significativos en **performance**, **separation of concerns**, y **fault tolerance**, pero introducen **complejidad** en:

- **Sincronización** (mutexes, semaphores, lock-free algorithms)
- **Cache coherency** (memory barriers, false sharing)
- **Deadlock prevention** (lock ordering, priority inheritance)
- **Debugging** (race conditions, timing issues)

**Cuándo usar:**
✅ Performance crítico (control + comunicaciones)
✅ Safety-critical (redundancia)
✅ Sistemas distribuidos (IoT networks)

**Cuándo NO usar:**
❌ Aplicaciones simples (overhead no justificado)
❌ Equipo sin experiencia en multi-threading
❌ Restricciones de costo (MCU más caro)

Con las técnicas presentadas, un sistema dual-core puede lograr **2x performance** y **separation of concerns** efectiva, manteniendo **determinismo** en el core de control y **flexibilidad** en el core de comunicaciones.

---

**Próximo capítulo: RTOS Integration** (FreeRTOS, tasks, scheduling)
