# Capítulo 33: RTOS Integration

## Índice
1. [Introducción a RTOS](#1-introducción-a-rtos)
2. [FreeRTOS Fundamentals](#2-freertos-fundamentals)
3. [Task Creation y Management](#3-task-creation-y-management)
4. [Scheduling Algorithms](#4-scheduling-algorithms)
5. [Queues](#5-queues)
6. [Semaphores](#6-semaphores)
7. [Event Groups](#7-event-groups)
8. [Software Timers](#8-software-timers)
9. [Memory Management](#9-memory-management)
10. [Direct-to-Task Notifications](#10-direct-to-task-notifications)
11. [Critical Sections](#11-critical-sections-y-interrupts)
12. [Integración con EMIC SDK](#12-integración-con-emic-sdk)
13. [Case Study](#13-case-study-sistema-multi-task-completo)
14. [Debugging](#14-debugging-rtos-applications)
15. [Best Practices](#15-best-practices)

---

## 1. Introducción a RTOS

### 1.1 ¿Qué es un RTOS?

**RTOS (Real-Time Operating System):** Sistema operativo diseñado para aplicaciones con restricciones temporales **predecibles** y **determinísticas**.

```
╔════════════════════════════════════════════════════════════╗
║              CARACTERÍSTICAS DE UN RTOS                    ║
╠════════════════════════════════════════════════════════════╣
║  ✅ Determinismo: Tiempos de respuesta predecibles        ║
║  ✅ Multitasking: Múltiples tareas concurrentes           ║
║  ✅ Scheduling: Algoritmo de planificación configurable   ║
║  ✅ Sincronización: Primitivas (mutex, semaphore, queue)  ║
║  ✅ Low latency: Respuesta rápida a eventos               ║
║  ✅ Small footprint: Optimizado para embedded             ║
╚════════════════════════════════════════════════════════════╝
```

### 1.2 Bare-Metal vs RTOS

**Comparación:**

| Aspecto | Bare-Metal | RTOS |
|---------|------------|------|
| **Complejidad** | Baja | Media-Alta |
| **Multitasking** | Manual (superloop) | Automático (scheduler) |
| **Determinismo** | Alto (si se diseña bien) | Alto (garantizado) |
| **Overhead** | Mínimo | 1-5% CPU |
| **Sincronización** | Manual (flags) | Primitivas built-in |
| **Escalabilidad** | Limitada | Alta |
| **Debug** | Simple | Complejo (race conditions) |
| **Footprint** | Mínimo | 5-20 KB Flash + RAM |

**Código comparativo:**

```c
// ============================================================
// BARE-METAL: Superloop
// ============================================================
void main_bare_metal(void) {
    system_init();

    while (1) {
        // Task 1: Leer sensores (cada 100 ms)
        if (timer_elapsed_ms(100)) {
            read_sensors();
        }

        // Task 2: Control loop (cada 10 ms)
        if (timer_elapsed_ms(10)) {
            control_loop();
        }

        // Task 3: Comunicaciones
        if (uart_data_available()) {
            process_uart();
        }

        // Task 4: Actualizar display (cada 1 segundo)
        if (timer_elapsed_ms(1000)) {
            update_display();
        }
    }
}
// Problema: Difícil sincronizar múltiples tasks con diferentes períodos

// ============================================================
// RTOS: Tasks independientes
// ============================================================
void task_sensors(void* params) {
    while (1) {
        read_sensors();
        vTaskDelay(pdMS_TO_TICKS(100));  // 100 ms
    }
}

void task_control(void* params) {
    while (1) {
        control_loop();
        vTaskDelay(pdMS_TO_TICKS(10));  // 10 ms
    }
}

void task_comms(void* params) {
    while (1) {
        process_uart();
        vTaskDelay(pdMS_TO_TICKS(1));  // Check frecuente
    }
}

void task_display(void* params) {
    while (1) {
        update_display();
        vTaskDelay(pdMS_TO_TICKS(1000));  // 1 segundo
    }
}

void main_rtos(void) {
    system_init();

    // Crear tasks
    xTaskCreate(task_sensors, "Sensors", 256, NULL, 2, NULL);
    xTaskCreate(task_control, "Control", 256, NULL, 3, NULL);  // Mayor prioridad
    xTaskCreate(task_comms, "Comms", 256, NULL, 2, NULL);
    xTaskCreate(task_display, "Display", 256, NULL, 1, NULL);  // Menor prioridad

    // Iniciar scheduler
    vTaskStartScheduler();

    // No retorna
}
// Ventaja: Cada task es independiente, fácil de mantener
```

### 1.3 Cuándo Usar RTOS

**Usar RTOS cuando:**

1. ✅ **Múltiples tareas** con diferentes períodos/prioridades
2. ✅ **Complejidad creciente** (>3-4 tasks con sincronización)
3. ✅ **Real-time constraints** estrictos
4. ✅ **Código modular** (separation of concerns)
5. ✅ **Equipo con experiencia** en RTOS

**NO usar RTOS cuando:**

1. ❌ Aplicación simple (1-2 tasks)
2. ❌ RAM limitada (< 8 KB disponible)
3. ❌ Ultra low power (RTOS consume ~1% extra)
4. ❌ Equipo sin experiencia (curva de aprendizaje)

### 1.4 FreeRTOS Overview

**FreeRTOS:** RTOS open-source más popular para embedded systems

```
╔════════════════════════════════════════════════════════════╗
║                   FREERTOS FEATURES                        ║
╠════════════════════════════════════════════════════════════╣
║  ✅ Open Source (MIT License)                             ║
║  ✅ Soporta 40+ arquitecturas (ARM, PIC, AVR, etc.)       ║
║  ✅ Footprint pequeño (~5 KB Flash, ~200 bytes RAM/task)  ║
║  ✅ Preemptive y cooperative scheduling                   ║
║  ✅ Prioridades ilimitadas (configurable)                 ║
║  ✅ Queues, Semaphores, Mutexes, Event Groups             ║
║  ✅ Software Timers                                        ║
║  ✅ Direct-to-task notifications                          ║
║  ✅ Stack overflow detection                              ║
║  ✅ Documentación excelente                               ║
╚════════════════════════════════════════════════════════════╝
```

---

## 2. FreeRTOS Fundamentals

### 2.1 Arquitectura de FreeRTOS

```
╔════════════════════════════════════════════════════════════╗
║              FREERTOS ARCHITECTURE                         ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║  ┌──────────────────────────────────────────────────────┐ ║
║  │          APPLICATION TASKS                           │ ║
║  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐       │ ║
║  │  │ Task 1 │ │ Task 2 │ │ Task 3 │ │ Task N │       │ ║
║  │  └────────┘ └────────┘ └────────┘ └────────┘       │ ║
║  └──────────────────────────────────────────────────────┘ ║
║                          ↕                                 ║
║  ┌──────────────────────────────────────────────────────┐ ║
║  │          FREERTOS API                                │ ║
║  │  Queue | Semaphore | Mutex | EventGroup | Timer     │ ║
║  └──────────────────────────────────────────────────────┘ ║
║                          ↕                                 ║
║  ┌──────────────────────────────────────────────────────┐ ║
║  │          SCHEDULER (Kernel)                          │ ║
║  │  - Task selection (priority-based)                   │ ║
║  │  - Context switching                                 │ ║
║  │  - Tick interrupt handler                            │ ║
║  └──────────────────────────────────────────────────────┘ ║
║                          ↕                                 ║
║  ┌──────────────────────────────────────────────────────┐ ║
║  │          PORT LAYER (MCU-specific)                   │ ║
║  │  - Context save/restore (assembly)                   │ ║
║  │  - Interrupt management                              │ ║
║  │  - Critical sections                                 │ ║
║  └──────────────────────────────────────────────────────┘ ║
║                          ↕                                 ║
║  ┌──────────────────────────────────────────────────────┐ ║
║  │          HARDWARE (PIC32, dsPIC33, etc.)             │ ║
║  └──────────────────────────────────────────────────────┘ ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
```

### 2.2 Task States

**Estados de una task:**

```
         ┌──────────────────────────────────────┐
         │                                      │
         │         SUSPENDED                    │
         │  (explícitamente suspendida)         │
         │                                      │
         └──────────────────────────────────────┘
                  ↑                     ↓
        vTaskSuspend()         vTaskResume()
                  │                     │
    ┌─────────────┴─────────────────────┴───────────────┐
    │                                                    │
    │  ┌──────────────┐                                 │
    │  │   RUNNING    │  ← Ejecutando en CPU            │
    │  └──────────────┘                                 │
    │         ↕                                          │
    │    Preemption                                      │
    │         ↕                                          │
    │  ┌──────────────┐                                 │
    │  │    READY     │  ← Esperando CPU                │
    │  └──────────────┘                                 │
    │         ↕                                          │
    │   Event/Delay                                      │
    │         ↕                                          │
    │  ┌──────────────┐                                 │
    │  │   BLOCKED    │  ← Esperando evento/timeout     │
    │  └──────────────┘                                 │
    │                                                    │
    └────────────────────────────────────────────────────┘
```

**Transiciones:**

1. **RUNNING → READY**: Task de mayor prioridad se vuelve ready (preemption)
2. **READY → RUNNING**: Scheduler selecciona task (tiene mayor prioridad)
3. **RUNNING → BLOCKED**: Task espera evento (queue, semaphore, delay)
4. **BLOCKED → READY**: Evento ocurre o timeout expira
5. **RUNNING/READY → SUSPENDED**: `vTaskSuspend()` llamado
6. **SUSPENDED → READY**: `vTaskResume()` llamado

### 2.3 Context Switching

**¿Qué es context switch?**

Guardar estado de task actual (registros CPU) y restaurar estado de nueva task.

```c
// Context switch overhead típico:
// PIC32 @ 200 MHz: 2-5 µs
// Cortex-M4 @ 168 MHz: 1-3 µs

// Context guardado:
// - Todos los registros de CPU
// - Program Counter (PC)
// - Stack Pointer (SP)
// - Status Register (SR)
```

**Cuándo ocurre:**

1. **Preemption**: Task de mayor prioridad se vuelve ready
2. **Yield voluntario**: `taskYIELD()` o blocking API call
3. **Tick interrupt**: Time slicing (si está habilitado)

### 2.4 Tick Interrupt

```c
// Tick interrupt: Latido del scheduler
// Configurable en FreeRTOSConfig.h

#define configTICK_RATE_HZ  1000  // 1 ms tick (típico)
// Opciones comunes: 100 Hz (10 ms), 1000 Hz (1 ms), 10000 Hz (100 µs)

// Trade-off:
// Tick rate alto (ej: 10 kHz):
//   ✅ Mejor resolución de delays
//   ❌ Más overhead de interrupts
// Tick rate bajo (ej: 100 Hz):
//   ✅ Menos overhead
//   ❌ Resolución gruesa (delays solo en múltiplos de 10 ms)
```

### 2.5 Idle Task

```c
// Idle task: Task de prioridad 0 (mínima) que siempre existe
// Se ejecuta cuando no hay otras tasks ready

void vApplicationIdleHook(void) {
    // Hook opcional ejecutado en idle task
    // Útil para:
    // - Entrar en low-power mode
    // - Background tasks (ej: garbage collection)
    // - Watchdog kick

    // ⚠️ NUNCA bloquear en idle hook!
}

// Ejemplo: Low power en idle
void vApplicationIdleHook(void) {
    // Entrar en sleep mode (CPU off, periféricos on)
    __asm__ volatile("wait");  // PIC32 WAIT instruction
    // Wakeup por cualquier interrupt
}
```

---

## 3. Task Creation y Management

### 3.1 xTaskCreate()

```c
// ============================================================
// Crear una task
// ============================================================

// Prototipo
BaseType_t xTaskCreate(
    TaskFunction_t pvTaskCode,   // Función de la task
    const char* pcName,           // Nombre (debug)
    uint16_t usStackDepth,        // Stack size (words, no bytes!)
    void* pvParameters,           // Parámetro pasado a task
    UBaseType_t uxPriority,       // Prioridad (0 = mínima)
    TaskHandle_t* pxCreatedTask   // Handle (opcional)
);

// Ejemplo básico
void vTaskBlink(void* pvParameters) {
    while (1) {
        gpio_led_toggle();
        vTaskDelay(pdMS_TO_TICKS(500));  // 500 ms
    }
}

void main(void) {
    // Crear task
    xTaskCreate(
        vTaskBlink,        // Función
        "Blink",           // Nombre
        128,               // Stack: 128 words = 512 bytes (PIC32)
        NULL,              // Sin parámetros
        1,                 // Prioridad 1
        NULL               // No necesitamos handle
    );

    // Iniciar scheduler
    vTaskStartScheduler();

    // No retorna (scheduler nunca termina)
    while (1);
}
```

### 3.2 Task Priorities

```c
// Prioridades: 0 (mínima) a configMAX_PRIORITIES-1 (máxima)
// Típicamente: configMAX_PRIORITIES = 5 o 10

#define PRIORITY_IDLE       0  // Idle task (reservado)
#define PRIORITY_LOW        1
#define PRIORITY_MEDIUM     2
#define PRIORITY_HIGH       3
#define PRIORITY_CRITICAL   4

// Ejemplo: Sistema con diferentes prioridades
void main(void) {
    xTaskCreate(vTaskSensors,  "Sensors",  256, NULL, PRIORITY_HIGH,     NULL);
    xTaskCreate(vTaskControl,  "Control",  256, NULL, PRIORITY_CRITICAL, NULL);
    xTaskCreate(vTaskComms,    "Comms",    512, NULL, PRIORITY_MEDIUM,   NULL);
    xTaskCreate(vTaskDisplay,  "Display",  256, NULL, PRIORITY_LOW,      NULL);

    vTaskStartScheduler();
}

// Regla: Task de mayor prioridad siempre ejecuta primero
// Si dos tasks tienen la misma prioridad → Round-robin (time slicing)
```

### 3.3 Task Handles

```c
// Handle: Referencia a una task (para control dinámico)

TaskHandle_t xSensorTaskHandle = NULL;

void vTaskSensors(void* pvParameters) {
    while (1) {
        read_sensors();
        vTaskDelay(pdMS_TO_TICKS(100));
    }
}

void main(void) {
    // Crear task y obtener handle
    xTaskCreate(vTaskSensors, "Sensors", 256, NULL, 2, &xSensorTaskHandle);

    vTaskStartScheduler();
}

// Usar handle para control dinámico
void suspend_sensor_task(void) {
    if (xSensorTaskHandle != NULL) {
        vTaskSuspend(xSensorTaskHandle);  // Suspender task
    }
}

void resume_sensor_task(void) {
    if (xSensorTaskHandle != NULL) {
        vTaskResume(xSensorTaskHandle);  // Reanudar task
    }
}

void delete_sensor_task(void) {
    if (xSensorTaskHandle != NULL) {
        vTaskDelete(xSensorTaskHandle);  // Eliminar task
        xSensorTaskHandle = NULL;
    }
}
```

### 3.4 vTaskDelay vs vTaskDelayUntil

```c
// ============================================================
// vTaskDelay: Delay relativo (desde ahora)
// ============================================================
void vTaskPeriodicWithDelay(void* pvParameters) {
    while (1) {
        do_work();  // Tiempo variable (ej: 10-20 ms)

        vTaskDelay(pdMS_TO_TICKS(100));  // Delay 100 ms desde AHORA
    }
}
// Período real: 100 ms + tiempo de do_work() = 110-120 ms (drift!)

// ============================================================
// vTaskDelayUntil: Delay absoluto (período fijo)
// ============================================================
void vTaskPeriodicWithDelayUntil(void* pvParameters) {
    TickType_t xLastWakeTime = xTaskGetTickCount();
    const TickType_t xPeriod = pdMS_TO_TICKS(100);

    while (1) {
        do_work();  // Tiempo variable

        // Delay hasta el próximo período exacto
        vTaskDelayUntil(&xLastWakeTime, xPeriod);
    }
}
// Período real: Exactamente 100 ms (sin drift!)
// Recomendado para control loops
```

### 3.5 Ejemplo: Múltiples Tasks

```c
// ============================================================
// Ejemplo completo con 4 tasks
// ============================================================

// Task 1: Adquisición de sensores @ 10 Hz
void vTaskSensors(void* pvParameters) {
    TickType_t xLastWakeTime = xTaskGetTickCount();
    const TickType_t xPeriod = pdMS_TO_TICKS(100);  // 100 ms = 10 Hz

    while (1) {
        // Leer sensores
        float temp = read_temperature();
        float pressure = read_pressure();

        // Enviar a queue (veremos más adelante)
        // xQueueSend(xSensorQueue, &sensor_data, 0);

        vTaskDelayUntil(&xLastWakeTime, xPeriod);
    }
}

// Task 2: Control loop @ 100 Hz
void vTaskControl(void* pvParameters) {
    TickType_t xLastWakeTime = xTaskGetTickCount();
    const TickType_t xPeriod = pdMS_TO_TICKS(10);  // 10 ms = 100 Hz

    while (1) {
        // Control PID
        pid_update();

        vTaskDelayUntil(&xLastWakeTime, xPeriod);
    }
}

// Task 3: Comunicaciones (event-driven)
void vTaskComms(void* pvParameters) {
    while (1) {
        // Esperar datos UART (blocking)
        uint8_t data;
        if (uart_receive(&data, portMAX_DELAY)) {  // Block forever
            process_uart_data(data);
        }
    }
}

// Task 4: Display update @ 1 Hz
void vTaskDisplay(void* pvParameters) {
    TickType_t xLastWakeTime = xTaskGetTickCount();
    const TickType_t xPeriod = pdMS_TO_TICKS(1000);  // 1 segundo

    while (1) {
        update_display();

        vTaskDelayUntil(&xLastWakeTime, xPeriod);
    }
}

void main(void) {
    system_init();

    // Crear tasks
    xTaskCreate(vTaskSensors, "Sensors", 256, NULL, 3, NULL);  // Alta prioridad
    xTaskCreate(vTaskControl, "Control", 256, NULL, 4, NULL);  // Máxima prioridad
    xTaskCreate(vTaskComms,   "Comms",   512, NULL, 2, NULL);  // Media
    xTaskCreate(vTaskDisplay, "Display", 256, NULL, 1, NULL);  // Baja

    vTaskStartScheduler();

    while (1);  // No debe llegar aquí
}
```

---

## 4. Scheduling Algorithms

### 4.1 Preemptive Scheduling

```c
// Preemptive: Task de mayor prioridad interrumpe a la de menor prioridad

#define configUSE_PREEMPTION  1  // Habilitar preemption

// Ejemplo:
// Task Low (prioridad 1) está ejecutando
// Task High (prioridad 3) se vuelve ready
// → Scheduler inmediatamente suspende Low y ejecuta High

Timeline:
──────────────────────────────────────────────────
Low:  [Running.............]  [Blocked]
High:            [Preempts Low, Running....]
──────────────────────────────────────────────────
              ↑
         Event hace High ready
```

### 4.2 Cooperative Scheduling

```c
// Cooperative: Task debe ceder control voluntariamente

#define configUSE_PREEMPTION  0  // Deshabilitar preemption

// Task debe llamar explícitamente:
taskYIELD();  // Ceder control al scheduler

// Sin yield → task ejecuta hasta completar/blocked
// ⚠️ Raro en sistemas real-time (menos determinismo)
```

### 4.3 Time Slicing (Round-Robin)

```c
// Time slicing: Tasks de igual prioridad comparten CPU

#define configUSE_PREEMPTION           1
#define configUSE_TIME_SLICING         1  // Habilitar time slicing
#define configTICK_RATE_HZ             1000  // 1 ms tick

// Si hay 2 tasks con prioridad 2 (ambas ready):
// → Cada una ejecuta por 1 tick (1 ms) antes de cambiar

Timeline:
──────────────────────────────────────────────────
Task A (pri 2):  [1ms] ─── [1ms] ─── [1ms]
Task B (pri 2):  ─── [1ms] ─── [1ms] ─── [1ms]
──────────────────────────────────────────────────
              Round-robin entre A y B
```

### 4.4 Ejemplo: Scheduler Behavior

```c
// 3 tasks con diferentes prioridades
void vTaskHigh(void* params) {    // Prioridad 3
    while (1) {
        printf("High\n");
        vTaskDelay(pdMS_TO_TICKS(100));  // Block por 100 ms
    }
}

void vTaskMedium(void* params) {  // Prioridad 2
    while (1) {
        printf("Medium\n");
        vTaskDelay(pdMS_TO_TICKS(200));  // Block por 200 ms
    }
}

void vTaskLow(void* params) {     // Prioridad 1
    while (1) {
        printf("Low\n");
        vTaskDelay(pdMS_TO_TICKS(300));  // Block por 300 ms
    }
}

// Behavior:
// t=0ms:   High, Medium, Low todas ready → High ejecuta (mayor prioridad)
// t=100ms: High blocked → Medium ejecuta
// t=200ms: Medium blocked → Low ejecuta
// t=300ms: Low blocked, High ready → High ejecuta
// ...
```

---

## 5. Queues

### 5.1 Queue Fundamentals

```c
// Queue: FIFO para pasar datos entre tasks (thread-safe)

// Crear queue
QueueHandle_t xQueueCreate(
    UBaseType_t uxQueueLength,  // Número de elementos
    UBaseType_t uxItemSize      // Tamaño de cada elemento (bytes)
);

// Ejemplo: Queue para sensor data
typedef struct {
    float temperature;
    float pressure;
    uint32_t timestamp;
} SensorData_t;

QueueHandle_t xSensorQueue;

void init_queues(void) {
    // Queue de 10 elementos, cada uno de tipo SensorData_t
    xSensorQueue = xQueueCreate(10, sizeof(SensorData_t));

    if (xSensorQueue == NULL) {
        // Error: No hay memoria suficiente
        error_handler();
    }
}
```

### 5.2 xQueueSend y xQueueReceive

```c
// ============================================================
// PRODUCER TASK
// ============================================================
void vTaskSensorProducer(void* pvParameters) {
    SensorData_t data;

    while (1) {
        // Leer sensores
        data.temperature = read_temperature();
        data.pressure = read_pressure();
        data.timestamp = xTaskGetTickCount();

        // Enviar a queue (block máximo 100 ms si está llena)
        if (xQueueSend(xSensorQueue, &data, pdMS_TO_TICKS(100)) != pdPASS) {
            // Queue llena después de timeout
            log_error("Queue full!");
        }

        vTaskDelay(pdMS_TO_TICKS(100));  // 10 Hz
    }
}

// ============================================================
// CONSUMER TASK
// ============================================================
void vTaskDataConsumer(void* pvParameters) {
    SensorData_t data;

    while (1) {
        // Recibir desde queue (block hasta que haya data)
        if (xQueueReceive(xSensorQueue, &data, portMAX_DELAY) == pdPASS) {
            // Procesar datos
            printf("Temp: %.2f, Pressure: %.2f\n",
                   data.temperature, data.pressure);

            // Enviar por Ethernet, guardar en SD, etc.
            send_to_cloud(data);
        }
    }
}
```

### 5.3 Queue from ISR

```c
// ============================================================
// Enviar desde ISR (interrupt-safe)
// ============================================================
QueueHandle_t xADCQueue;

void __ISR(_ADC_VECTOR, IPL5SOFT) ADC_ISR(void) {
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;

    // Leer ADC
    uint16_t adc_value = ADC1BUF0;

    // Enviar a queue (versión FromISR)
    xQueueSendFromISR(xADCQueue, &adc_value, &xHigherPriorityTaskWoken);

    // Si enviar a queue desbloqueó una task de mayor prioridad,
    // hacer context switch al salir de ISR
    portYIELD_FROM_ISR(xHigherPriorityTaskWoken);

    IFS1bits.AD1IF = 0;
}

// Task que consume datos del ADC
void vTaskADCConsumer(void* pvParameters) {
    uint16_t adc_value;

    while (1) {
        if (xQueueReceive(xADCQueue, &adc_value, portMAX_DELAY) == pdPASS) {
            // Procesar valor del ADC
            float voltage = adc_value * 3.3f / 4096.0f;
            process_voltage(voltage);
        }
    }
}
```

### 5.4 Ejemplo: Producer-Consumer

```c
// ============================================================
// Sistema completo producer-consumer
// ============================================================
QueueHandle_t xDataQueue;

// Producer: Genera datos periódicamente
void vProducerTask(void* pvParameters) {
    uint32_t counter = 0;

    while (1) {
        // Generar dato
        uint32_t data = counter++;

        // Enviar a queue
        if (xQueueSend(xDataQueue, &data, pdMS_TO_TICKS(10)) != pdPASS) {
            printf("Queue full, data lost!\n");
        }

        vTaskDelay(pdMS_TO_TICKS(50));  // 20 Hz
    }
}

// Consumer 1: Procesa datos rápidamente
void vConsumer1Task(void* pvParameters) {
    uint32_t data;

    while (1) {
        if (xQueueReceive(xDataQueue, &data, portMAX_DELAY) == pdPASS) {
            printf("Consumer1 received: %lu\n", data);
            vTaskDelay(pdMS_TO_TICKS(20));  // Procesamiento rápido
        }
    }
}

// Consumer 2: Procesa datos lentamente
void vConsumer2Task(void* pvParameters) {
    uint32_t data;

    while (1) {
        if (xQueueReceive(xDataQueue, &data, portMAX_DELAY) == pdPASS) {
            printf("Consumer2 received: %lu\n", data);
            vTaskDelay(pdMS_TO_TICKS(100));  // Procesamiento lento
        }
    }
}

void main(void) {
    // Crear queue de 5 elementos
    xDataQueue = xQueueCreate(5, sizeof(uint32_t));

    // Crear tasks
    xTaskCreate(vProducerTask,  "Producer",  128, NULL, 2, NULL);
    xTaskCreate(vConsumer1Task, "Consumer1", 128, NULL, 2, NULL);
    xTaskCreate(vConsumer2Task, "Consumer2", 128, NULL, 2, NULL);

    vTaskStartScheduler();
}

// Behavior:
// - Producer genera datos cada 50 ms
// - Consumer1 procesa cada 20 ms
// - Consumer2 procesa cada 100 ms
// - Si queue se llena (5 elementos), producer pierde datos
```

---

## 6. Semaphores

### 6.1 Binary Semaphores

```c
// Binary semaphore: Flag sincronización (0 o 1)

SemaphoreHandle_t xBinarySemaphore;

void init_semaphores(void) {
    // Crear binary semaphore (inicialmente vacío)
    xBinarySemaphore = xSemaphoreCreateBinary();

    if (xBinarySemaphore == NULL) {
        error_handler();
    }
}

// Ejemplo: ISR notifica a task
void __ISR(_UART_RX_VECTOR, IPL4SOFT) UART_RX_ISR(void) {
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;

    // Leer dato UART
    uint8_t data = U1RXREG;
    store_uart_data(data);

    // Dar semáforo (notificar task)
    xSemaphoreGiveFromISR(xBinarySemaphore, &xHigherPriorityTaskWoken);

    portYIELD_FROM_ISR(xHigherPriorityTaskWoken);

    IFS0bits.U1RXIF = 0;
}

// Task espera semáforo
void vTaskUARTHandler(void* pvParameters) {
    while (1) {
        // Esperar semáforo (block hasta que ISR lo dé)
        if (xSemaphoreTake(xBinarySemaphore, portMAX_DELAY) == pdTRUE) {
            // Procesar datos UART
            uint8_t data = get_uart_data();
            process_uart(data);
        }
    }
}
```

### 6.2 Counting Semaphores

```c
// Counting semaphore: Contador (0 a max)
// Útil para resource pools

SemaphoreHandle_t xCountingSemaphore;

void init_counting_semaphore(void) {
    // Crear counting semaphore (máximo 5, inicial 5)
    xCountingSemaphore = xSemaphoreCreateCounting(5, 5);
}

// Ejemplo: Pool de buffers
#define MAX_BUFFERS 5
uint8_t buffer_pool[MAX_BUFFERS][256];

void vTaskConsumer(void* pvParameters) {
    while (1) {
        // Tomar un buffer del pool
        if (xSemaphoreTake(xCountingSemaphore, pdMS_TO_TICKS(100)) == pdTRUE) {
            // Hay buffer disponible
            uint8_t* buffer = allocate_buffer_from_pool();

            // Usar buffer
            read_data_to_buffer(buffer);
            process_buffer(buffer);

            // Devolver buffer al pool
            free_buffer_to_pool(buffer);
            xSemaphoreGive(xCountingSemaphore);
        } else {
            // No hay buffers disponibles
            log_warning("No buffers available");
        }
    }
}
```

### 6.3 Mutex (Mutual Exclusion)

```c
// Mutex: Proteger recursos compartidos

SemaphoreHandle_t xSPIMutex;

void init_mutex(void) {
    xSPIMutex = xSemaphoreCreateMutex();

    if (xSPIMutex == NULL) {
        error_handler();
    }
}

// Task 1: Usa SPI
void vTask1(void* pvParameters) {
    while (1) {
        // Adquirir mutex (lock SPI)
        if (xSemaphoreTake(xSPIMutex, pdMS_TO_TICKS(100)) == pdTRUE) {
            // Critical section: Solo esta task puede usar SPI
            spi_transfer_data(data1, sizeof(data1));

            // Release mutex (unlock SPI)
            xSemaphoreGive(xSPIMutex);
        }

        vTaskDelay(pdMS_TO_TICKS(10));
    }
}

// Task 2: También usa SPI
void vTask2(void* pvParameters) {
    while (1) {
        if (xSemaphoreTake(xSPIMutex, pdMS_TO_TICKS(100)) == pdTRUE) {
            // Critical section
            spi_transfer_data(data2, sizeof(data2));

            xSemaphoreGive(xSPIMutex);
        }

        vTaskDelay(pdMS_TO_TICKS(20));
    }
}

// Mutex garantiza que solo una task usa SPI a la vez
```

**Mutex vs Binary Semaphore:**

| Característica | Mutex | Binary Semaphore |
|----------------|-------|------------------|
| **Ownership** | Sí (solo quien tomó puede dar) | No (cualquiera puede dar) |
| **Priority Inheritance** | Sí (previene priority inversion) | No |
| **Recursividad** | Sí (recursive mutex) | No |
| **Uso** | Proteger recursos | Sincronización de eventos |

### 6.4 Recursive Mutex

```c
// Recursive mutex: Permite que la misma task lo tome múltiples veces

SemaphoreHandle_t xRecursiveMutex;

void init_recursive_mutex(void) {
    xRecursiveMutex = xSemaphoreCreateRecursiveMutex();
}

void function_level_1(void) {
    xSemaphoreTakeRecursive(xRecursiveMutex, portMAX_DELAY);

    // Critical section
    function_level_2();  // Llamada anidada

    xSemaphoreGiveRecursive(xRecursiveMutex);
}

void function_level_2(void) {
    xSemaphoreTakeRecursive(xRecursiveMutex, portMAX_DELAY);

    // Critical section (funciona porque es recursive)

    xSemaphoreGiveRecursive(xRecursiveMutex);
}

// Mutex normal → Deadlock (task se bloquea a sí misma)
// Recursive mutex → OK (cuenta niveles de recursión)
```

---

## 7. Event Groups

### 7.1 Event Group Basics

```c
// Event group: Grupo de bits para sincronización de múltiples eventos

EventGroupHandle_t xEventGroup;

// Definir bits de eventos
#define EVENT_SENSOR_READY   (1 << 0)  // Bit 0
#define EVENT_DATA_PROCESSED (1 << 1)  // Bit 1
#define EVENT_COMMS_READY    (1 << 2)  // Bit 2

void init_event_groups(void) {
    xEventGroup = xEventGroupCreate();

    if (xEventGroup == NULL) {
        error_handler();
    }
}
```

### 7.2 Setting y Waiting for Events

```c
// ============================================================
// Task 1: Setear evento cuando sensor esté listo
// ============================================================
void vTaskSensor(void* pvParameters) {
    while (1) {
        // Leer sensor
        read_sensor();

        // Setear bit de evento
        xEventGroupSetBits(xEventGroup, EVENT_SENSOR_READY);

        vTaskDelay(pdMS_TO_TICKS(100));
    }
}

// ============================================================
// Task 2: Procesar datos
// ============================================================
void vTaskProcessing(void* pvParameters) {
    while (1) {
        // Procesar datos
        process_data();

        // Setear evento
        xEventGroupSetBits(xEventGroup, EVENT_DATA_PROCESSED);

        vTaskDelay(pdMS_TO_TICKS(50));
    }
}

// ============================================================
// Task 3: Esperar múltiples eventos
// ============================================================
void vTaskComms(void* pvParameters) {
    EventBits_t uxBits;
    const EventBits_t uxBitsToWaitFor = EVENT_SENSOR_READY | EVENT_DATA_PROCESSED;

    while (1) {
        // Esperar a que AMBOS eventos ocurran
        uxBits = xEventGroupWaitBits(
            xEventGroup,        // Event group
            uxBitsToWaitFor,    // Bits a esperar
            pdTRUE,             // Clear bits on exit
            pdTRUE,             // Wait for ALL bits (AND)
            portMAX_DELAY       // Block indefinidamente
        );

        // Ambos eventos ocurrieron
        if ((uxBits & uxBitsToWaitFor) == uxBitsToWaitFor) {
            // Enviar datos por comunicación
            send_data();
        }
    }
}
```

### 7.3 Ejemplo: Multi-Event Synchronization

```c
// Sistema que sincroniza 3 tasks

#define EVENT_INIT_COMPLETE    (1 << 0)
#define EVENT_CONFIG_LOADED    (1 << 1)
#define EVENT_NETWORK_READY    (1 << 2)
#define EVENT_ALL_READY        (EVENT_INIT_COMPLETE | EVENT_CONFIG_LOADED | EVENT_NETWORK_READY)

// Task 1: Inicialización
void vTaskInit(void* pvParameters) {
    // Inicializar hardware
    hardware_init();

    // Notificar que init completó
    xEventGroupSetBits(xEventGroup, EVENT_INIT_COMPLETE);

    // Task termina
    vTaskDelete(NULL);
}

// Task 2: Cargar configuración
void vTaskConfig(void* pvParameters) {
    // Cargar config desde SD card
    load_config_from_sd();

    // Notificar
    xEventGroupSetBits(xEventGroup, EVENT_CONFIG_LOADED);

    vTaskDelete(NULL);
}

// Task 3: Conectar red
void vTaskNetwork(void* pvParameters) {
    // Conectar WiFi
    wifi_connect();

    // Notificar
    xEventGroupSetBits(xEventGroup, EVENT_NETWORK_READY);

    vTaskDelete(NULL);
}

// Task 4: Aplicación principal (espera a que todo esté listo)
void vTaskMain(void* pvParameters) {
    // Esperar a que TODAS las tareas de inicio completen
    xEventGroupWaitBits(
        xEventGroup,
        EVENT_ALL_READY,
        pdFALSE,         // No clear bits
        pdTRUE,          // Wait for ALL bits
        portMAX_DELAY
    );

    // Todo listo, iniciar aplicación
    printf("System ready!\n");

    while (1) {
        // Aplicación principal
        run_application();
        vTaskDelay(pdMS_TO_TICKS(10));
    }
}
```

---

## 8. Software Timers

### 8.1 Timer Creation

```c
// Software timer: Callback ejecutado periódicamente (sin crear task)

TimerHandle_t xTimer;

// Callback del timer
void vTimerCallback(TimerHandle_t xTimer) {
    // Esta función se ejecuta en contexto del timer daemon task
    printf("Timer expired!\n");

    // ⚠️ No bloquear aquí (no usar vTaskDelay, xQueueReceive con timeout largo, etc.)
}

void init_timers(void) {
    // Crear timer
    xTimer = xTimerCreate(
        "MyTimer",           // Nombre (debug)
        pdMS_TO_TICKS(1000), // Período: 1 segundo
        pdTRUE,              // Auto-reload (repetir)
        (void*)0,            // Timer ID (opcional)
        vTimerCallback       // Callback
    );

    if (xTimer == NULL) {
        error_handler();
    }

    // Iniciar timer
    xTimerStart(xTimer, 0);
}
```

### 8.2 One-Shot vs Auto-Reload

```c
// ============================================================
// ONE-SHOT TIMER: Ejecuta solo una vez
// ============================================================
void vOneShotCallback(TimerHandle_t xTimer) {
    printf("One-shot timer expired (only once)\n");
}

TimerHandle_t xOneShotTimer = xTimerCreate(
    "OneShot",
    pdMS_TO_TICKS(5000),  // 5 segundos
    pdFALSE,              // One-shot (no auto-reload)
    NULL,
    vOneShotCallback
);

// Iniciar (ejecutará solo 1 vez después de 5 segundos)
xTimerStart(xOneShotTimer, 0);

// ============================================================
// AUTO-RELOAD TIMER: Ejecuta periódicamente
// ============================================================
void vAutoReloadCallback(TimerHandle_t xTimer) {
    printf("Auto-reload timer tick\n");
}

TimerHandle_t xAutoReloadTimer = xTimerCreate(
    "AutoReload",
    pdMS_TO_TICKS(1000),  // 1 segundo
    pdTRUE,               // Auto-reload (repetir)
    NULL,
    vAutoReloadCallback
);

// Iniciar (ejecutará cada 1 segundo)
xTimerStart(xAutoReloadTimer, 0);
```

### 8.3 Timer Control

```c
TimerHandle_t xTimer;

// Iniciar timer
xTimerStart(xTimer, 0);

// Detener timer
xTimerStop(xTimer, 0);

// Resetear timer (reiniciar período)
xTimerReset(xTimer, 0);

// Cambiar período
xTimerChangePeriod(xTimer, pdMS_TO_TICKS(2000), 0);  // Cambiar a 2 segundos

// Desde ISR
BaseType_t xHigherPriorityTaskWoken = pdFALSE;
xTimerStartFromISR(xTimer, &xHigherPriorityTaskWoken);
portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
```

### 8.4 Ejemplo: Periodic Actions

```c
// Sistema con múltiples timers para tareas periódicas

// Timer 1: Heartbeat LED cada 500 ms
void vHeartbeatCallback(TimerHandle_t xTimer) {
    gpio_led_toggle();
}

// Timer 2: Watchdog kick cada 1 segundo
void vWatchdogCallback(TimerHandle_t xTimer) {
    watchdog_kick();
}

// Timer 3: Log stats cada 10 segundos
void vStatsCallback(TimerHandle_t xTimer) {
    log_system_stats();
}

void init_system_timers(void) {
    TimerHandle_t xHeartbeatTimer = xTimerCreate(
        "Heartbeat", pdMS_TO_TICKS(500), pdTRUE, NULL, vHeartbeatCallback);

    TimerHandle_t xWatchdogTimer = xTimerCreate(
        "Watchdog", pdMS_TO_TICKS(1000), pdTRUE, NULL, vWatchdogCallback);

    TimerHandle_t xStatsTimer = xTimerCreate(
        "Stats", pdMS_TO_TICKS(10000), pdTRUE, NULL, vStatsCallback);

    // Iniciar todos los timers
    xTimerStart(xHeartbeatTimer, 0);
    xTimerStart(xWatchdogTimer, 0);
    xTimerStart(xStatsTimer, 0);
}

// Ventaja vs tasks: Menos RAM (no stack por timer), ejecutan en timer daemon task
```

---

## 9. Memory Management

### 9.1 Heap Schemes

FreeRTOS ofrece 5 esquemas de heap (heap_1 a heap_5):

```c
// ============================================================
// HEAP_1: Allocate-only (no free)
// ============================================================
// - Más simple
// - pvPortMalloc() funciona, vPortFree() no hace nada
// - Útil si nunca se eliminan tasks/queues
// - No fragmentación

// ============================================================
// HEAP_2: Allocate y free (first-fit)
// ============================================================
// - Permite free
// - Puede fragmentarse
// - No coalesce bloques libres adyacentes
// - Deprecated (usar heap_4)

// ============================================================
// HEAP_3: Wrapper de malloc/free estándar
// ============================================================
// - Usa malloc/free de libc
// - Thread-safe (con critical sections)
// - Tamaño de heap determinado por linker script

// ============================================================
// HEAP_4: Allocate y free con coalescing
// ============================================================
// - Recommended para mayoría de aplicaciones
// - First-fit algorithm
// - Coalesce bloques libres adyacentes
// - Reduce fragmentación

// ============================================================
// HEAP_5: Como heap_4 pero con múltiples regiones de RAM
// ============================================================
// - Para MCUs con RAM no contigua
// - Ej: Internal RAM + External RAM
```

**Configuración de heap:**

```c
// FreeRTOSConfig.h

// Tamaño total del heap (bytes)
#define configTOTAL_HEAP_SIZE  (20 * 1024)  // 20 KB

// Usar heap_4 (recomendado)
// En Makefile: incluir heap_4.c
```

### 9.2 pvPortMalloc y vPortFree

```c
// Allocate memory (thread-safe)
void* pvPortMalloc(size_t xWantedSize);

// Free memory
void vPortFree(void* pv);

// Ejemplo
uint8_t* buffer = (uint8_t*)pvPortMalloc(256);
if (buffer == NULL) {
    // Out of memory!
    error_handler();
}

// Usar buffer...

vPortFree(buffer);
```

### 9.3 Stack Size

```c
// Cada task tiene su propio stack (configurado en xTaskCreate)

xTaskCreate(
    vMyTask,
    "MyTask",
    256,        // Stack size: 256 WORDS (no bytes!)
                // PIC32: 256 words = 256 * 4 = 1024 bytes
                // Cortex-M: 256 words = 256 * 4 = 1024 bytes
    NULL,
    2,
    NULL
);

// ¿Cómo determinar stack size?
// 1. Análisis estático (peor caso de call stack)
// 2. Runtime measurement (uxTaskGetStackHighWaterMark)
// 3. Stack overflow detection
```

### 9.4 Stack Overflow Detection

```c
// FreeRTOSConfig.h

// Método 1: Verificar stack pointer al context switch
#define configCHECK_FOR_STACK_OVERFLOW  1

// Método 2: Verificar stack pattern (más robusto)
#define configCHECK_FOR_STACK_OVERFLOW  2

// Hook llamado si se detecta overflow
void vApplicationStackOverflowHook(TaskHandle_t xTask, char* pcTaskName) {
    // Stack overflow detectado!
    printf("Stack overflow in task: %s\n", pcTaskName);

    // Acción de emergencia
    error_handler();

    // No retornar
    while (1);
}
```

### 9.5 Memory Stats

```c
// Obtener memoria libre en heap
size_t xPortGetFreeHeapSize(void);

// Obtener mínima memoria libre alcanzada (worst-case)
size_t xPortGetMinimumEverFreeHeapSize(void);

// Stack high water mark (bytes libres mínimos en stack de task)
UBaseType_t uxTaskGetStackHighWaterMark(TaskHandle_t xTask);

// Ejemplo: Análisis de memoria
void analyze_memory_usage(void) {
    size_t free_heap = xPortGetFreeHeapSize();
    size_t min_heap = xPortGetMinimumEverFreeHeapSize();

    printf("Heap free: %u bytes\n", free_heap);
    printf("Heap min free: %u bytes\n", min_heap);
    printf("Heap usage: %.1f%%\n",
           100.0f * (1.0f - (float)free_heap / configTOTAL_HEAP_SIZE));

    // Verificar stack de cada task
    TaskHandle_t xHandle = xTaskGetHandle("MyTask");
    UBaseType_t uxHighWaterMark = uxTaskGetStackHighWaterMark(xHandle);
    printf("Task 'MyTask' stack free: %u words\n", uxHighWaterMark);

    // Si uxHighWaterMark < 50 → Stack muy ajustado, aumentar!
}
```

---

## 10. Direct-to-Task Notifications

### 10.1 Task Notification Basics

```c
// Task notification: Método liviano de señalización (alternativa a semaphore/queue)
// Cada task tiene un valor de notificación de 32 bits

// Enviar notificación
BaseType_t xTaskNotify(
    TaskHandle_t xTaskToNotify,
    uint32_t ulValue,         // Valor a enviar
    eNotifyAction eAction     // Acción (increment, overwrite, etc.)
);

// Esperar notificación
BaseType_t xTaskNotifyWait(
    uint32_t ulBitsToClearOnEntry,
    uint32_t ulBitsToClearOnExit,
    uint32_t* pulNotificationValue,
    TickType_t xTicksToWait
);
```

### 10.2 Use Cases

```c
// ============================================================
// Caso 1: Reemplazo de binary semaphore
// ============================================================
TaskHandle_t xTaskHandle = NULL;

// ISR da notificación
void __ISR(_TIMER_1_VECTOR, IPL5SOFT) Timer1_ISR(void) {
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;

    // Notificar task (incrementar counter)
    vTaskNotifyGiveFromISR(xTaskHandle, &xHigherPriorityTaskWoken);

    portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
    IFS0bits.T1IF = 0;
}

// Task espera notificación
void vTask(void* pvParameters) {
    xTaskHandle = xTaskGetCurrentTaskHandle();

    while (1) {
        // Esperar notificación (como semaphore take)
        ulTaskNotifyTake(pdTRUE, portMAX_DELAY);  // Clear on exit

        // ISR ocurrió
        process_timer_event();
    }
}

// Ventaja vs semaphore: 45% más rápido, menos RAM

// ============================================================
// Caso 2: Enviar valor de datos
// ============================================================
void vSenderTask(void* pvParameters) {
    uint32_t data_to_send = 12345;

    // Enviar notificación con valor
    xTaskNotify(xReceiverHandle, data_to_send, eSetValueWithOverwrite);

    vTaskDelay(pdMS_TO_TICKS(100));
}

void vReceiverTask(void* pvParameters) {
    xReceiverHandle = xTaskGetCurrentTaskHandle();
    uint32_t received_value;

    while (1) {
        // Esperar notificación
        if (xTaskNotifyWait(0, 0xFFFFFFFF, &received_value, portMAX_DELAY) == pdTRUE) {
            printf("Received: %lu\n", received_value);
        }
    }
}
```

### 10.3 Ejemplo: ISR to Task Notification

```c
// Sistema que usa notificaciones para comunicación ISR → Task

TaskHandle_t xADCTaskHandle = NULL;

// ISR de ADC
void __ISR(_ADC_VECTOR, IPL6SOFT) ADC_ISR(void) {
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;

    uint16_t adc_value = ADC1BUF0;

    // Enviar valor del ADC como notificación
    xTaskNotifyFromISR(
        xADCTaskHandle,
        adc_value,                  // Valor
        eSetValueWithOverwrite,     // Sobrescribir valor anterior
        &xHigherPriorityTaskWoken
    );

    portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
    IFS1bits.AD1IF = 0;
}

// Task procesa valores del ADC
void vADCTask(void* pvParameters) {
    xADCTaskHandle = xTaskGetCurrentTaskHandle();
    uint32_t adc_value;

    while (1) {
        // Esperar notificación del ISR
        if (xTaskNotifyWait(0, 0, &adc_value, portMAX_DELAY) == pdTRUE) {
            // Procesar valor
            float voltage = (float)adc_value * 3.3f / 4096.0f;
            printf("Voltage: %.3f V\n", voltage);
        }
    }
}
```

---

## 11. Critical Sections y Interrupts

### 11.1 Critical Sections

```c
// Critical section: Deshabilitar interrupts temporalmente

void access_shared_resource(void) {
    // Entrar en critical section
    taskENTER_CRITICAL();

    // Acceso a recurso compartido (no interrumpible)
    g_shared_counter++;
    g_shared_data = new_value;

    // Salir de critical section
    taskEXIT_CRITICAL();
}

// ⚠️ Usar SOLO para secciones MUY cortas (< 10 µs)
// De lo contrario, afecta latencia de interrupts
```

### 11.2 Interrupt-Safe API

```c
// APIs FromISR: Versiones interrupt-safe

// Queue
xQueueSendFromISR(xQueue, &data, &xHigherPriorityTaskWoken);
xQueueReceiveFromISR(xQueue, &data, &xHigherPriorityTaskWoken);

// Semaphore
xSemaphoreGiveFromISR(xSemaphore, &xHigherPriorityTaskWoken);
xSemaphoreTakeFromISR(xSemaphore, &xHigherPriorityTaskWoken);  // Raramente usado

// Event group
xEventGroupSetBitsFromISR(xEventGroup, bits, &xHigherPriorityTaskWoken);

// Task notification
vTaskNotifyGiveFromISR(xTaskHandle, &xHigherPriorityTaskWoken);
xTaskNotifyFromISR(xTaskHandle, value, action, &xHigherPriorityTaskWoken);

// Timer
xTimerStartFromISR(xTimer, &xHigherPriorityTaskWoken);

// Siempre terminar ISR con:
portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
```

### 11.3 Interrupt Priorities

```c
// FreeRTOSConfig.h

// Prioridad máxima de interrupt que puede usar API FromISR
#define configMAX_SYSCALL_INTERRUPT_PRIORITY  5

// En PIC32, interrupts con prioridad > 5 NO pueden usar FreeRTOS API
// Interrupts con prioridad ≤ 5 pueden usar API FromISR

// Ejemplo:
void interrupt_init(void) {
    // Interrupt alta prioridad (6) → NO puede usar FreeRTOS API
    IPC1bits.T1IP = 6;
    IEC0bits.T1IE = 1;

    // Interrupt normal (4) → Puede usar FreeRTOS API
    IPC2bits.U1IP = 4;
    IEC0bits.U1IE = 1;
}

void __ISR(_TIMER_1_VECTOR, IPL6SOFT) Timer1_Critical_ISR(void) {
    // ⚠️ NO usar FreeRTOS API aquí (prioridad 6 > configMAX_SYSCALL)

    // Solo procesamiento crítico
    critical_processing();

    IFS0bits.T1IF = 0;
}

void __ISR(_UART_1_RX_VECTOR, IPL4SOFT) UART_ISR(void) {
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;

    // ✅ Puede usar FreeRTOS API (prioridad 4 < configMAX_SYSCALL)
    xQueueSendFromISR(xUARTQueue, &data, &xHigherPriorityTaskWoken);

    portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
    IFS0bits.U1RXIF = 0;
}
```

---

## 12. Integración con EMIC SDK

### 12.1 FreeRTOSConfig.h para PIC32

```c
// FreeRTOSConfig.h - Configuración para PIC32MZ @ 200 MHz

#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

// CPU frequency
#define configCPU_CLOCK_HZ            (200000000UL)
#define configPERIPHERAL_CLOCK_HZ     (100000000UL)

// Scheduler
#define configUSE_PREEMPTION          1
#define configUSE_TIME_SLICING        1
#define configTICK_RATE_HZ            ((TickType_t)1000)  // 1 ms tick
#define configMAX_PRIORITIES          (5)
#define configMINIMAL_STACK_SIZE      ((uint16_t)128)    // 128 words = 512 bytes
#define configTOTAL_HEAP_SIZE         ((size_t)(40 * 1024))  // 40 KB

// Task names
#define configMAX_TASK_NAME_LEN       (16)

// Queue
#define configQUEUE_REGISTRY_SIZE     8

// Timers
#define configUSE_TIMERS              1
#define configTIMER_TASK_PRIORITY     (configMAX_PRIORITIES - 1)
#define configTIMER_QUEUE_LENGTH      10
#define configTIMER_TASK_STACK_DEPTH  (configMINIMAL_STACK_SIZE * 2)

// Memory
#define configSUPPORT_DYNAMIC_ALLOCATION  1
#define configAPPLICATION_ALLOCATED_HEAP  0

// Stack overflow detection
#define configCHECK_FOR_STACK_OVERFLOW    2

// Interrupt priorities (PIC32)
#define configMAX_SYSCALL_INTERRUPT_PRIORITY  5
#define configKERNEL_INTERRUPT_PRIORITY       1

// API includes
#define INCLUDE_vTaskPrioritySet      1
#define INCLUDE_uxTaskPriorityGet     1
#define INCLUDE_vTaskDelete           1
#define INCLUDE_vTaskSuspend          1
#define INCLUDE_vTaskDelayUntil       1
#define INCLUDE_vTaskDelay            1
#define INCLUDE_xTaskGetSchedulerState 1
#define INCLUDE_xTaskGetCurrentTaskHandle 1
#define INCLUDE_uxTaskGetStackHighWaterMark 1

#endif /* FREERTOS_CONFIG_H */
```

### 12.2 Integrar con EMIC Modules

```c
// Estructura: Cada módulo EMIC → Una task

// ============================================================
// Módulo 1: SensorHub (task de adquisición)
// ============================================================
void vTaskSensorHub(void* pvParameters) {
    TickType_t xLastWakeTime = xTaskGetTickCount();
    const TickType_t xPeriod = pdMS_TO_TICKS(100);  // 10 Hz

    while (1) {
        // Leer sensores (código EMIC-Codify generado)
        sensorHub_ReadAllSensors();

        // Publicar datos a queue
        SensorData_t data;
        sensorHub_GetData(&data);
        xQueueSend(xSensorQueue, &data, 0);

        vTaskDelayUntil(&xLastWakeTime, xPeriod);
    }
}

// ============================================================
// Módulo 2: ControlLoop (task de control)
// ============================================================
void vTaskControlLoop(void* pvParameters) {
    TickType_t xLastWakeTime = xTaskGetTickCount();
    const TickType_t xPeriod = pdMS_TO_TICKS(10);  // 100 Hz

    while (1) {
        // Control PID (código EMIC)
        controlLoop_Update();

        vTaskDelayUntil(&xLastWakeTime, xPeriod);
    }
}

// ============================================================
// Módulo 3: WiFiComm (task de comunicaciones)
// ============================================================
void vTaskWiFiComm(void* pvParameters) {
    SensorData_t data;

    while (1) {
        // Esperar datos del sensor hub
        if (xQueueReceive(xSensorQueue, &data, portMAX_DELAY) == pdPASS) {
            // Enviar por WiFi
            wifiComm_SendData(&data);
        }
    }
}

// ============================================================
// Main: Inicializar y crear tasks
// ============================================================
int main(void) {
    // Inicialización hardware (EMIC-generated)
    system_init();

    // Crear queues
    xSensorQueue = xQueueCreate(10, sizeof(SensorData_t));

    // Crear tasks por módulo
    xTaskCreate(vTaskSensorHub,   "SensorHub",  256, NULL, 3, NULL);
    xTaskCreate(vTaskControlLoop, "Control",    256, NULL, 4, NULL);  // Más alta prioridad
    xTaskCreate(vTaskWiFiComm,    "WiFi",       512, NULL, 2, NULL);

    // Iniciar scheduler
    vTaskStartScheduler();

    // No retorna
    while (1);

    return 0;
}
```

---

## 13. Case Study: Sistema Multi-Task Completo

### Aplicación: Sistema IoT con 6 Tasks

**Descripción:**
- Adquisición de 3 sensores (temperatura, presión, humedad)
- Control PID de temperatura
- Data logging en SD card
- Comunicación WiFi (MQTT)
- Display OLED actualización
- Diagnóstico del sistema

**Arquitectura:**

```
╔════════════════════════════════════════════════════════════╗
║                    TASKS HIERARCHY                         ║
╠════════════════════════════════════════════════════════════╣
║  Priority 4 (Critical):                                    ║
║    └─ vTaskControl (PID @ 100 Hz)                          ║
║                                                            ║
║  Priority 3 (High):                                        ║
║    └─ vTaskSensorAcq (Sensors @ 10 Hz)                     ║
║                                                            ║
║  Priority 2 (Medium):                                      ║
║    ├─ vTaskDataLogging (SD card @ 1 Hz)                    ║
║    └─ vTaskWiFi (MQTT publish @ 1 Hz)                      ║
║                                                            ║
║  Priority 1 (Low):                                         ║
║    ├─ vTaskDisplay (OLED @ 2 Hz)                           ║
║    └─ vTaskDiagnostics (Stats @ 0.1 Hz)                    ║
╚════════════════════════════════════════════════════════════╝
```

**Código completo:**

```c
// ============================================================
// GLOBAL QUEUES Y SEMAPHORES
// ============================================================
QueueHandle_t xSensorDataQueue;      // Sensor data: Acq → Logging/WiFi
QueueHandle_t xControlDataQueue;     // Control output: Control → Display
SemaphoreHandle_t xSDCardMutex;      // Protect SD card access

// ============================================================
// DATA STRUCTURES
// ============================================================
typedef struct {
    float temperature;
    float pressure;
    float humidity;
    uint32_t timestamp;
} SensorData_t;

typedef struct {
    float setpoint;
    float process_variable;
    float control_output;
    uint32_t timestamp;
} ControlData_t;

// ============================================================
// TASK 1: SENSOR ACQUISITION (Priority 3)
// ============================================================
void vTaskSensorAcq(void* pvParameters) {
    TickType_t xLastWakeTime = xTaskGetTickCount();
    const TickType_t xPeriod = pdMS_TO_TICKS(100);  // 100 ms = 10 Hz
    SensorData_t data;

    while (1) {
        // Leer sensores
        data.temperature = read_temperature();  // Ej: DHT22
        data.pressure = read_pressure();        // Ej: BMP280
        data.humidity = read_humidity();
        data.timestamp = xTaskGetTickCount();

        // Publicar a queue (consumido por Logging y WiFi)
        xQueueSend(xSensorDataQueue, &data, 0);

        // Log local
        printf("[SensorAcq] T:%.1f P:%.1f H:%.1f\n",
               data.temperature, data.pressure, data.humidity);

        vTaskDelayUntil(&xLastWakeTime, xPeriod);
    }
}

// ============================================================
// TASK 2: CONTROL LOOP (Priority 4 - Highest)
// ============================================================
void vTaskControl(void* pvParameters) {
    TickType_t xLastWakeTime = xTaskGetTickCount();
    const TickType_t xPeriod = pdMS_TO_TICKS(10);  // 10 ms = 100 Hz

    // PID state
    float setpoint = 25.0f;  // 25°C
    float kp = 2.0f, ki = 0.5f, kd = 0.1f;
    float integral = 0.0f, prev_error = 0.0f;

    ControlData_t control_data;

    while (1) {
        // Leer temperatura actual (de última lectura)
        float pv = read_temperature();

        // PID calculation
        float error = setpoint - pv;
        integral += error * 0.01f;  // dt = 10 ms
        float derivative = (error - prev_error) / 0.01f;
        float output = kp * error + ki * integral + kd * derivative;
        prev_error = error;

        // Saturar output (0-100%)
        if (output > 100.0f) output = 100.0f;
        if (output < 0.0f) output = 0.0f;

        // Actualizar PWM heater
        set_heater_pwm((uint8_t)output);

        // Publicar control data para display
        control_data.setpoint = setpoint;
        control_data.process_variable = pv;
        control_data.control_output = output;
        control_data.timestamp = xTaskGetTickCount();
        xQueueSend(xControlDataQueue, &control_data, 0);

        vTaskDelayUntil(&xLastWakeTime, xPeriod);
    }
}

// ============================================================
// TASK 3: DATA LOGGING (Priority 2)
// ============================================================
void vTaskDataLogging(void* pvParameters) {
    SensorData_t data;
    ControlData_t control;

    while (1) {
        // Esperar nuevos sensor data (timeout 1 segundo)
        if (xQueueReceive(xSensorDataQueue, &data, pdMS_TO_TICKS(1000)) == pdPASS) {
            // Adquirir mutex de SD card
            if (xSemaphoreTake(xSDCardMutex, pdMS_TO_TICKS(100)) == pdTRUE) {
                // Escribir a SD card
                char log_line[128];
                snprintf(log_line, sizeof(log_line),
                         "%lu,%.2f,%.2f,%.2f\n",
                         data.timestamp, data.temperature,
                         data.pressure, data.humidity);

                sd_card_write_line(log_line);

                // Release mutex
                xSemaphoreGive(xSDCardMutex);

                printf("[Logging] Data logged to SD\n");
            }
        }

        // No usar vTaskDelay aquí (ya hay timeout en xQueueReceive)
    }
}

// ============================================================
// TASK 4: WiFi COMMUNICATIONS (Priority 2)
// ============================================================
void vTaskWiFi(void* pvParameters) {
    SensorData_t data;

    // Conectar WiFi (una vez al inicio)
    wifi_connect("SSID", "password");
    mqtt_connect("broker.hivemq.com", 1883);

    while (1) {
        // Esperar sensor data (timeout 2 segundos)
        if (xQueueReceive(xSensorDataQueue, &data, pdMS_TO_TICKS(2000)) == pdPASS) {
            // Publicar a MQTT
            char payload[128];
            snprintf(payload, sizeof(payload),
                     "{\"temp\":%.2f,\"press\":%.2f,\"hum\":%.2f}",
                     data.temperature, data.pressure, data.humidity);

            mqtt_publish("sensors/data", payload);

            printf("[WiFi] Published to MQTT\n");
        }
    }
}

// ============================================================
// TASK 5: DISPLAY UPDATE (Priority 1)
// ============================================================
void vTaskDisplay(void* pvParameters) {
    TickType_t xLastWakeTime = xTaskGetTickCount();
    const TickType_t xPeriod = pdMS_TO_TICKS(500);  // 500 ms = 2 Hz

    SensorData_t sensor_data;
    ControlData_t control_data;

    while (1) {
        // Leer últimos datos de queues (sin block)
        xQueuePeek(xSensorDataQueue, &sensor_data, 0);
        xQueuePeek(xControlDataQueue, &control_data, 0);

        // Actualizar display OLED
        oled_clear();
        oled_printf(0, 0, "Temp: %.1f C", sensor_data.temperature);
        oled_printf(0, 1, "Setpoint: %.1f C", control_data.setpoint);
        oled_printf(0, 2, "Output: %.0f%%", control_data.control_output);
        oled_printf(0, 3, "Press: %.1f hPa", sensor_data.pressure);
        oled_update();

        printf("[Display] Screen updated\n");

        vTaskDelayUntil(&xLastWakeTime, xPeriod);
    }
}

// ============================================================
// TASK 6: DIAGNOSTICS (Priority 1)
// ============================================================
void vTaskDiagnostics(void* pvParameters) {
    TickType_t xLastWakeTime = xTaskGetTickCount();
    const TickType_t xPeriod = pdMS_TO_TICKS(10000);  // 10 segundos = 0.1 Hz

    while (1) {
        // Obtener stats de memoria
        size_t free_heap = xPortGetFreeHeapSize();
        size_t min_heap = xPortGetMinimumEverFreeHeapSize();

        printf("\n[Diagnostics] ========== SYSTEM STATS ==========\n");
        printf("Heap free: %u bytes (min: %u bytes)\n", free_heap, min_heap);
        printf("Uptime: %lu seconds\n", xTaskGetTickCount() / 1000);

        // Stack high water mark de cada task
        printf("Stack usage:\n");
        printf("  SensorAcq:  %u words free\n", uxTaskGetStackHighWaterMark(NULL));
        // (Para otras tasks necesitamos sus handles)

        // CPU usage (si está habilitado)
        #if configGENERATE_RUN_TIME_STATS
        char stats_buffer[512];
        vTaskGetRunTimeStats(stats_buffer);
        printf("Runtime stats:\n%s\n", stats_buffer);
        #endif

        printf("===============================================\n\n");

        vTaskDelayUntil(&xLastWakeTime, xPeriod);
    }
}

// ============================================================
// MAIN
// ============================================================
int main(void) {
    // Inicialización hardware
    system_init();
    uart_init();
    i2c_init();
    spi_init();
    sd_card_init();
    wifi_init();
    oled_init();

    // Crear queues
    xSensorDataQueue = xQueueCreate(5, sizeof(SensorData_t));
    xControlDataQueue = xQueueCreate(5, sizeof(ControlData_t));

    // Crear mutexes
    xSDCardMutex = xSemaphoreCreateMutex();

    if (xSensorDataQueue == NULL || xControlDataQueue == NULL || xSDCardMutex == NULL) {
        printf("ERROR: Failed to create queues/mutexes\n");
        while (1);
    }

    // Crear tasks
    xTaskCreate(vTaskSensorAcq,    "SensorAcq",  256, NULL, 3, NULL);
    xTaskCreate(vTaskControl,      "Control",    256, NULL, 4, NULL);
    xTaskCreate(vTaskDataLogging,  "Logging",    512, NULL, 2, NULL);  // Mayor stack (SD card)
    xTaskCreate(vTaskWiFi,         "WiFi",       512, NULL, 2, NULL);  // Mayor stack (network)
    xTaskCreate(vTaskDisplay,      "Display",    256, NULL, 1, NULL);
    xTaskCreate(vTaskDiagnostics,  "Diagnostics",256, NULL, 1, NULL);

    printf("FreeRTOS system starting...\n");

    // Iniciar scheduler
    vTaskStartScheduler();

    // No debe llegar aquí
    printf("ERROR: Scheduler failed to start!\n");
    while (1);

    return 0;
}

// ============================================================
// HOOKS
// ============================================================
void vApplicationStackOverflowHook(TaskHandle_t xTask, char* pcTaskName) {
    printf("ERROR: Stack overflow in task '%s'\n", pcTaskName);
    while (1);
}

void vApplicationMallocFailedHook(void) {
    printf("ERROR: Malloc failed (out of heap memory)\n");
    while (1);
}

void vApplicationIdleHook(void) {
    // Entrar en low-power mode cuando idle
    #if configUSE_IDLE_HOOK_LOW_POWER
    __asm__ volatile("wait");
    #endif
}
```

**Performance Analysis:**

```
╔════════════════════════════════════════════════════════════╗
║              PERFORMANCE METRICS                           ║
╠════════════════════════════════════════════════════════════╣
║  Task            Period   WCET    CPU Load   Priority     ║
║  ──────────────────────────────────────────────────────   ║
║  SensorAcq       100 ms   5 ms    5%         3            ║
║  Control         10 ms    2 ms    20%        4 (highest)  ║
║  Logging         1000 ms  50 ms   5%         2            ║
║  WiFi            1000 ms  100 ms  10%        2            ║
║  Display         500 ms   10 ms   2%         1            ║
║  Diagnostics     10000 ms 5 ms    0.05%      1            ║
║  ──────────────────────────────────────────────────────   ║
║  TOTAL CPU Load:                  ~42%                     ║
║  Peak CPU Load:                   ~60% (WiFi burst)        ║
║  Idle time:                       ~58%                     ║
║  ──────────────────────────────────────────────────────   ║
║  RAM Usage:                                                ║
║    - Task stacks (6 tasks):       6.5 KB                   ║
║    - Queues (2):                  0.5 KB                   ║
║    - Heap free:                   30 KB / 40 KB            ║
║    - Total RAM:                   ~15 KB                   ║
║  ──────────────────────────────────────────────────────   ║
║  Flash Usage:                     ~80 KB                   ║
║    - FreeRTOS kernel:             ~15 KB                   ║
║    - Application code:            ~65 KB                   ║
╚════════════════════════════════════════════════════════════╝
```

---

## 14. Debugging RTOS Applications

### 14.1 vTaskList

```c
// Obtener lista de todas las tasks con stats

#define configUSE_TRACE_FACILITY  1
#define configUSE_STATS_FORMATTING_FUNCTIONS  1

void print_task_list(void) {
    char buffer[512];

    vTaskList(buffer);

    printf("Task List:\n");
    printf("Name          State  Priority  Stack  Num\n");
    printf("============================================\n");
    printf("%s\n", buffer);
}

// Output ejemplo:
// Name          State  Priority  Stack  Num
// ============================================
// Control       R      4         128    2
// SensorAcq     B      3         200    1
// WiFi          B      2         350    3
// Display       B      1         220    4
// IDLE          R      0         50     0
//
// State: R=Running, B=Blocked, S=Suspended, D=Deleted
// Stack: High water mark (words remaining)
```

### 14.2 Runtime Stats

```c
// Estadísticas de tiempo de ejecución por task

#define configGENERATE_RUN_TIME_STATS  1
#define portCONFIGURE_TIMER_FOR_RUN_TIME_STATS()  /* Config timer */
#define portGET_RUN_TIME_COUNTER_VALUE()  TMR2  /* Read timer */

void print_runtime_stats(void) {
    char buffer[512];

    vTaskGetRunTimeStats(buffer);

    printf("Runtime Stats:\n");
    printf("Task            Abs Time      %% Time\n");
    printf("==========================================\n");
    printf("%s\n", buffer);
}

// Output ejemplo:
// Task            Abs Time      % Time
// ==========================================
// Control         12500         20%
// SensorAcq       3125          5%
// WiFi            6250          10%
// Display         1250          2%
// IDLE            38750         62%
```

### 14.3 Common Pitfalls

```c
// ============================================================
// PITFALL 1: Stack overflow (stack size muy pequeño)
// ============================================================
// ❌ MAL
xTaskCreate(vMyTask, "MyTask", 64, NULL, 2, NULL);  // 64 words (256 bytes) → insuficiente

// ✅ BIEN: Usar stack overflow detection + aumentar size
#define configCHECK_FOR_STACK_OVERFLOW  2
xTaskCreate(vMyTask, "MyTask", 256, NULL, 2, NULL);  // 256 words (1024 bytes)

// Verificar high water mark
UBaseType_t uxHighWaterMark = uxTaskGetStackHighWaterMark(NULL);
if (uxHighWaterMark < 50) {
    printf("WARNING: Stack getting low!\n");
}

// ============================================================
// PITFALL 2: Blocking en ISR
// ============================================================
// ❌ MAL
void __ISR(_TIMER_1_VECTOR, IPL5SOFT) Timer1_ISR(void) {
    vTaskDelay(pdMS_TO_TICKS(10));  // ERROR! No bloquear en ISR
    IFS0bits.T1IF = 0;
}

// ✅ BIEN: Solo notificar a task
void __ISR(_TIMER_1_VECTOR, IPL5SOFT) Timer1_ISR(void) {
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;
    vTaskNotifyGiveFromISR(xTaskHandle, &xHigherPriorityTaskWoken);
    portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
    IFS0bits.T1IF = 0;
}

// ============================================================
// PITFALL 3: Priority inversion (no usar mutex)
// ============================================================
// ❌ MAL: Binary semaphore para proteger recurso
SemaphoreHandle_t xResourceSem = xSemaphoreCreateBinary();
xSemaphoreGive(xResourceSem);

xSemaphoreTake(xResourceSem, portMAX_DELAY);
use_shared_resource();
xSemaphoreGive(xResourceSem);
// Problema: No hay priority inheritance → priority inversion

// ✅ BIEN: Usar mutex (tiene priority inheritance)
SemaphoreHandle_t xResourceMutex = xSemaphoreCreateMutex();

xSemaphoreTake(xResourceMutex, portMAX_DELAY);
use_shared_resource();
xSemaphoreGive(xResourceMutex);

// ============================================================
// PITFALL 4: Deadlock (lock ordering incorrecto)
// ============================================================
// ❌ MAL: Diferentes ordenes de locks
void task1(void) {
    xSemaphoreTake(xMutexA, portMAX_DELAY);
    xSemaphoreTake(xMutexB, portMAX_DELAY);
    // ...
    xSemaphoreGive(xMutexB);
    xSemaphoreGive(xMutexA);
}

void task2(void) {
    xSemaphoreTake(xMutexB, portMAX_DELAY);  // Orden diferente!
    xSemaphoreTake(xMutexA, portMAX_DELAY);
    // ...
    xSemaphoreGive(xMutexA);
    xSemaphoreGive(xMutexB);
}
// → Deadlock!

// ✅ BIEN: Mismo orden siempre
void task1(void) {
    xSemaphoreTake(xMutexA, portMAX_DELAY);  // Siempre A primero
    xSemaphoreTake(xMutexB, portMAX_DELAY);  // Luego B
    // ...
}

void task2(void) {
    xSemaphoreTake(xMutexA, portMAX_DELAY);  // Siempre A primero
    xSemaphoreTake(xMutexB, portMAX_DELAY);  // Luego B
    // ...
}
```

---

## 15. Best Practices

### 15.1 Task Design Guidelines

```c
// ✅ BIEN: Task con estructura clara
void vWellDesignedTask(void* pvParameters) {
    // 1. Inicialización local
    init_local_resources();

    // 2. Loop infinito
    while (1) {
        // 3. Esperar evento/delay
        if (xQueueReceive(xQueue, &data, pdMS_TO_TICKS(100)) == pdPASS) {
            // 4. Procesar evento
            process_data(&data);
        }

        // 5. Periodic work (si aplica)
        do_periodic_work();
    }

    // 6. Cleanup (si task puede terminar)
    cleanup_resources();
    vTaskDelete(NULL);
}

// ❌ MAL: Task sin delay (CPU 100%)
void vBadTask(void* pvParameters) {
    while (1) {
        // Polling sin delay → CPU 100%!
        if (check_condition()) {
            do_work();
        }
        // Falta vTaskDelay!
    }
}
```

### 15.2 Priority Assignment

```
╔════════════════════════════════════════════════════════════╗
║              PRIORITY ASSIGNMENT GUIDE                     ║
╠════════════════════════════════════════════════════════════╣
║  Priority 0:  Idle task (reservado)                        ║
║                                                            ║
║  Priority 1:  Low priority background tasks                ║
║               - Display updates                            ║
║               - Diagnostics                                ║
║               - Statistics logging                         ║
║                                                            ║
║  Priority 2:  Normal priority tasks                        ║
║               - Communications (WiFi, Ethernet)            ║
║               - Data logging                               ║
║               - User interface                             ║
║                                                            ║
║  Priority 3:  High priority tasks                          ║
║               - Sensor acquisition                         ║
║               - Fast processing                            ║
║                                                            ║
║  Priority 4+: Critical real-time tasks                     ║
║               - Control loops                              ║
║               - Safety monitoring                          ║
║               - Time-critical ISR processing               ║
╚════════════════════════════════════════════════════════════╝
```

### 15.3 Stack Sizing

```c
// Regla general para stack size:
// - Minimum: 128 words (512 bytes)
// - Normal: 256 words (1024 bytes)
// - Large (network stack, recursion): 512-1024 words (2-4 KB)

// Análisis:
// 1. Calcular peor caso de call stack
// 2. Agregar margin 50%
// 3. Verificar con uxTaskGetStackHighWaterMark()

void analyze_task_stack(TaskHandle_t xTask, const char* name) {
    UBaseType_t uxHighWaterMark = uxTaskGetStackHighWaterMark(xTask);

    if (uxHighWaterMark < 50) {
        printf("WARNING: Task '%s' stack critically low (%u words free)\n",
               name, uxHighWaterMark);
    } else if (uxHighWaterMark < 100) {
        printf("CAUTION: Task '%s' stack getting low (%u words free)\n",
               name, uxHighWaterMark);
    } else {
        printf("OK: Task '%s' stack healthy (%u words free)\n",
               name, uxHighWaterMark);
    }
}
```

### 15.4 Performance Optimization

```c
// 1. Minimizar context switches
//    - Usar vTaskDelayUntil() en vez de vTaskDelay()
//    - Agrupar operaciones

// 2. Usar task notifications en vez de queues/semaphores cuando sea posible
//    (45% más rápido, menos RAM)

// 3. Correct tick rate
//    - Típico: 1000 Hz (1 ms resolution)
//    - Si no necesitas alta resolución: 100 Hz (menos overhead)

// 4. Disable time slicing si no lo necesitas
#define configUSE_TIME_SLICING  0

// 5. Ajustar configMAX_PRIORITIES
//    - Solo usar las prioridades que realmente necesitas
//    - Menos prioridades = scheduler más rápido
```

---

## Conclusión

**FreeRTOS** es una herramienta poderosa para construir sistemas embebidos complejos con **multitasking real-time**. Los beneficios incluyen:

✅ **Modularidad**: Cada task es independiente
✅ **Determinismo**: Scheduling predecible
✅ **Sincronización**: Primitivas built-in (queue, semaphore, mutex)
✅ **Escalabilidad**: Fácil agregar nuevas features (más tasks)
✅ **Portabilidad**: 40+ arquitecturas soportadas

**Trade-offs:**

❌ **Overhead**: 1-5% CPU + ~200 bytes RAM por task
❌ **Complejidad**: Curva de aprendizaje, debugging más difícil
❌ **Footprint**: ~15 KB Flash para kernel

**Cuándo usar FreeRTOS:**
- Sistemas con >3 tasks concurrentes
- Real-time constraints estrictos
- Necesidad de sincronización compleja
- Equipo con experiencia en RTOS

Con las técnicas presentadas en este capítulo, puedes integrar FreeRTOS en tus proyectos EMIC y construir sistemas **multi-task robustos y determinísticos**.

---

**Próximo capítulo: Bootloader y OTA Updates** (actualización de firmware remota)
