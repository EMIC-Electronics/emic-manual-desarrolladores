# Capítulo 25: Integración de Componentes

## Índice
1. [Introducción](#introducción)
2. [Principios de Integración](#principios-de-integración)
3. [Patrones de Integración](#patrones-de-integración)
4. [Arquitecturas Escalables](#arquitecturas-escalables)
5. [Caso Práctico: Sistema de Riego Inteligente](#caso-práctico-sistema-de-riego-inteligente)
6. [Gestión de Recursos Compartidos](#gestión-de-recursos-compartidos)
7. [Sincronización y Timing](#sincronización-y-timing)
8. [Manejo de Eventos](#manejo-de-eventos)
9. [Optimización de Memoria](#optimización-de-memoria)
10. [Performance y Eficiencia](#performance-y-eficiencia)
11. [Caso Práctico: Gateway IoT Industrial](#caso-práctico-gateway-iot-industrial)
12. [Buenas Prácticas](#buenas-prácticas)
13. [Anti-Patrones](#anti-patrones)
14. [Resumen del Capítulo](#resumen-del-capítulo)

---

## Introducción

En los capítulos anteriores aprendiste a crear proyectos, APIs y módulos individuales. Ahora aprenderás a **integrar múltiples componentes** para crear sistemas complejos, escalables y robustos.

### El Desafío de la Integración

```
Sistema Simple:        1 Sensor → 1 LED
Sistema Complejo:      5 Sensores + 3 Actuadores + Display + WiFi + SD Card
                       + Control PID + Estado persistente + Telemetría
```

**Desafíos:**
- Gestión de recursos compartidos (UART, SPI, I2C)
- Sincronización de timing (múltiples tareas concurrentes)
- Manejo de eventos complejos
- Optimización de memoria (RAM limitada)
- Performance y eficiencia energética

### ¿Qué Aprenderás?

- ✅ Patrones de integración probados
- ✅ Arquitecturas escalables (capas, eventos, FSM)
- ✅ Gestión de recursos compartidos
- ✅ Optimización de memoria y performance
- ✅ Casos prácticos de sistemas reales

---

## Principios de Integración

### 1. Separation of Concerns (SoC)

Cada componente debe tener **una responsabilidad única y bien definida**.

```
✅ BUENO:
- SensorModule: Solo lectura de sensores
- StorageModule: Solo almacenamiento
- CommModule: Solo comunicación

❌ MALO:
- MegaModule: Lee sensores + almacena + comunica + controla actuadores
```

### 2. Loose Coupling (Bajo Acoplamiento)

Los componentes deben **depender de interfaces**, no de implementaciones concretas.

```c
✅ BUENO:
// Interfaz genérica
typedef struct {
    float (*Read)(void);
    bool (*IsReady)(void);
} ISensor_t;

void ProcessSensor(ISensor_t* sensor) {
    if (sensor->IsReady()) {
        float value = sensor->Read();
        // Procesar
    }
}

❌ MALO:
void ProcessSensor(void) {
    if (dht22_IsReady()) {  // Acoplado a DHT22 específicamente
        float value = dht22_Read();
    }
}
```

### 3. High Cohesion (Alta Cohesión)

Los elementos dentro de un componente deben estar **estrechamente relacionados**.

```c
✅ BUENO:
// Módulo SensorManager: Todo relacionado con sensores
void sensor_Init(void);
void sensor_Read(void);
void sensor_Calibrate(void);
float sensor_GetValue(void);

❌ MALO:
// Módulo MixedStuff: Funciones no relacionadas
void stuff_ReadSensor(void);
void stuff_SendWiFi(void);
void stuff_BlinkLED(void);
void stuff_SaveSD(void);
```

### 4. Information Hiding (Ocultamiento de Información)

Los detalles internos deben estar **ocultos** mediante encapsulación.

```c
✅ BUENO:
// sensor.h
float sensor_GetTemperature(void);  // Interfaz pública

// sensor.c
static uint16_t raw_adc_value;      // Detalle interno (static)
static float calibration_offset;    // Detalle interno (static)

❌ MALO:
// sensor.h
extern uint16_t raw_adc_value;      // Expone detalles internos
extern float calibration_offset;
```

---

## Patrones de Integración

### Patrón 1: Layered Architecture (Arquitectura en Capas)

```
┌─────────────────────────────────────────────────────┐
│              Application Layer                      │
│  (Lógica de negocio, control, decisiones)          │
└─────────────────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────┐
│            Service Layer                            │
│  (Procesamiento, algoritmos, conversiones)         │
└─────────────────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────┐
│              API Layer                              │
│  (Interfaces de alto nivel, abstracciones)         │
└─────────────────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────┐
│            Driver Layer                             │
│  (Control de hardware específico)                  │
└─────────────────────────────────────────────────────┘
```

**Ejemplo:**
```c
// Application Layer
void irrigation_Controller(void) {
    float soil_moisture = sensor_GetSoilMoisture();  // API Layer

    if (soil_moisture < THRESHOLD_LOW) {
        valve_Open();   // API Layer
        pump_Start();   // API Layer
    }
}

// API Layer
float sensor_GetSoilMoisture(void) {
    uint16_t adc_value = moistureSensor_ReadADC();  // Driver Layer
    return adc_ValueToPercent(adc_value);           // Service Layer
}

// Driver Layer
uint16_t moistureSensor_ReadADC(void) {
    return HAL_ADC_Read(ADC_CHANNEL_MOISTURE);
}
```

### Patrón 2: Event-Driven Architecture

```c
// Sistema de eventos
typedef enum {
    EVENT_SENSOR_READING,
    EVENT_THRESHOLD_EXCEEDED,
    EVENT_COMMUNICATION_READY,
    EVENT_ERROR_DETECTED
} EventType_t;

typedef struct {
    EventType_t type;
    void* data;
} Event_t;

// Cola de eventos
#define EVENT_QUEUE_SIZE 16
static Event_t event_queue[EVENT_QUEUE_SIZE];
static uint8_t queue_head = 0;
static uint8_t queue_tail = 0;

// Publicar evento
void event_Publish(EventType_t type, void* data) {
    Event_t event = {type, data};
    event_queue[queue_head] = event;
    queue_head = (queue_head + 1) % EVENT_QUEUE_SIZE;
}

// Procesar eventos
void event_Process(void) {
    while (queue_tail != queue_head) {
        Event_t event = event_queue[queue_tail];
        queue_tail = (queue_tail + 1) % EVENT_QUEUE_SIZE;

        switch (event.type) {
            case EVENT_SENSOR_READING:
                OnSensorReading(event.data);
                break;
            case EVENT_THRESHOLD_EXCEEDED:
                OnThresholdExceeded(event.data);
                break;
            // ...
        }
    }
}
```

### Patrón 3: State Machine (Máquina de Estados)

```c
typedef enum {
    STATE_IDLE,
    STATE_READING_SENSORS,
    STATE_PROCESSING_DATA,
    STATE_SENDING_DATA,
    STATE_ERROR
} SystemState_t;

static SystemState_t current_state = STATE_IDLE;

void system_StateMachine(void) {
    switch (current_state) {
        case STATE_IDLE:
            if (timer_HasElapsed()) {
                current_state = STATE_READING_SENSORS;
            }
            break;

        case STATE_READING_SENSORS:
            if (sensors_ReadAll()) {
                current_state = STATE_PROCESSING_DATA;
            } else {
                current_state = STATE_ERROR;
            }
            break;

        case STATE_PROCESSING_DATA:
            data_Process();
            current_state = STATE_SENDING_DATA;
            break;

        case STATE_SENDING_DATA:
            if (comm_Send(data)) {
                current_state = STATE_IDLE;
            } else {
                current_state = STATE_ERROR;
            }
            break;

        case STATE_ERROR:
            error_Handle();
            current_state = STATE_IDLE;
            break;
    }
}
```

### Patrón 4: Observer Pattern (Publicador-Suscriptor)

```c
// Callback para observadores
typedef void (*SensorCallback_t)(float value);

// Lista de observadores
#define MAX_OBSERVERS 5
static SensorCallback_t observers[MAX_OBSERVERS];
static uint8_t observer_count = 0;

// Registrar observador
void sensor_RegisterObserver(SensorCallback_t callback) {
    if (observer_count < MAX_OBSERVERS) {
        observers[observer_count++] = callback;
    }
}

// Notificar a todos los observadores
void sensor_NotifyObservers(float value) {
    for (uint8_t i = 0; i < observer_count; i++) {
        observers[i](value);
    }
}

// Uso:
void OnTemperatureChange(float temp) {
    LOG_INFO_F("Temperature changed: %.1f C", temp);
    display_UpdateTemperature(temp);
}

void EMIC_INIT_USER(void) {
    sensor_RegisterObserver(OnTemperatureChange);
}

void EMIC_LOOP_USER(void) {
    if (sensor_Read()) {
        float temp = sensor_GetTemperature();
        sensor_NotifyObservers(temp);  // Notifica automáticamente
    }
}
```

---

## Arquitecturas Escalables

### Arquitectura 1: Monolítica Simple

```
┌──────────────────────────────────────────┐
│         main.c (Todo en un archivo)      │
│  - Sensores                              │
│  - Actuadores                            │
│  - Comunicación                          │
│  - Lógica de control                     │
└──────────────────────────────────────────┘
```

**Ventajas:**
- Simple de entender
- Rápido de desarrollar (proyectos pequeños)

**Desventajas:**
- No escala bien (>500 líneas)
- Difícil de mantener
- Difícil de testear

**Cuándo usar:** Proyectos muy simples (<3 componentes)

### Arquitectura 2: Modular

```
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│  Sensor     │  │  Actuator   │  │    Comm     │
│  Module     │  │   Module    │  │   Module    │
└─────────────┘  └─────────────┘  └─────────────┘
       ↓                ↓                 ↓
┌──────────────────────────────────────────────┐
│           Controller Module                  │
└──────────────────────────────────────────────┘
       ↓
┌──────────────────────────────────────────────┐
│              main.c                          │
└──────────────────────────────────────────────┘
```

**Ventajas:**
- Separación de responsabilidades
- Fácil de testear módulos individuales
- Reutilizable

**Desventajas:**
- Más complejo inicialmente
- Requiere diseño previo

**Cuándo usar:** Proyectos medianos (3-10 componentes)

### Arquitectura 3: Event-Driven con FSM

```
┌──────────────────────────────────────────────┐
│            Event Queue                       │
└──────────────────────────────────────────────┘
       ↑                ↑                ↑
       │                │                │
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│  Sensor     │  │  Comm       │  │   Timer     │
│  (Producer) │  │ (Producer)  │  │ (Producer)  │
└─────────────┘  └─────────────┘  └─────────────┘
       ↓
┌──────────────────────────────────────────────┐
│        State Machine (Consumer)              │
│  IDLE → READING → PROCESSING → SENDING      │
└──────────────────────────────────────────────┘
       ↓
┌──────────────────────────────────────────────┐
│            Actuators                         │
└──────────────────────────────────────────────┘
```

**Ventajas:**
- Muy escalable (10+ componentes)
- Bajo acoplamiento
- Fácil de extender

**Desventajas:**
- Más complejo de implementar
- Overhead de cola de eventos

**Cuándo usar:** Proyectos grandes (>10 componentes)

---

## Caso Práctico: Sistema de Riego Inteligente

Vamos a integrar **10+ componentes** en un sistema real.

### Especificaciones

**Hardware:**
- 4 Sensores de humedad de suelo (ADC)
- 1 Sensor de temperatura/humedad ambiente (DHT22)
- 1 Sensor de lluvia (digital)
- 4 Electroválvulas (relays)
- 1 Bomba de agua (relay)
- 1 Display LCD 20x4
- 1 Módulo WiFi (ESP8266)
- 1 SD Card (logging)
- 3 Botones (manual, auto, config)
- 4 LEDs de estado

**Funcionalidad:**
- Monitoreo continuo de humedad del suelo
- Riego automático según umbrales
- Detección de lluvia (desactivar riego)
- Display con información en tiempo real
- Telemetría WiFi (MQTT)
- Logging en SD Card
- Modo manual y automático
- Configuración persistente

### Arquitectura del Sistema

```
┌────────────────────────────────────────────────────────────┐
│                  Application Layer                         │
│  irrigation_Controller() - Lógica de control principal     │
└────────────────────────────────────────────────────────────┘
                              ↓
┌────────────────────────────────────────────────────────────┐
│                   Service Layer                            │
│  - irrigation_DecisionEngine()  (decisiones)               │
│  - data_ProcessSensorReadings() (procesamiento)            │
│  - telemetry_PreparePayload()   (formateo)                │
└────────────────────────────────────────────────────────────┘
                              ↓
┌────────────────────────────────────────────────────────────┐
│                     API Layer                              │
│  sensor_*, valve_*, pump_*, display_*, wifi_*, sd_*        │
└────────────────────────────────────────────────────────────┘
                              ↓
┌────────────────────────────────────────────────────────────┐
│                   Driver Layer                             │
│  ADC, GPIO, SPI, UART, I2C                                 │
└────────────────────────────────────────────────────────────┘
```

### Estado del Sistema (FSM)

```c
typedef enum {
    SYSTEM_STATE_INIT,
    SYSTEM_STATE_IDLE,
    SYSTEM_STATE_READING_SENSORS,
    SYSTEM_STATE_DECIDING_ACTION,
    SYSTEM_STATE_IRRIGATING,
    SYSTEM_STATE_LOGGING,
    SYSTEM_STATE_SENDING_TELEMETRY,
    SYSTEM_STATE_ERROR
} SystemState_t;
```

### Gestión de Recursos

**Recursos compartidos:**
- UART1: WiFi ESP8266
- UART2: Debug logging
- SPI: SD Card
- ADC: 4 sensores de humedad
- Timers: Múltiples tareas

**Solución:**
```c
// Gestor de recursos compartidos
bool resource_RequestUART1(void) {
    if (!uart1_IsBusy()) {
        uart1_SetBusy(true);
        return true;
    }
    return false;
}

void resource_ReleaseUART1(void) {
    uart1_SetBusy(false);
}

// Uso:
if (resource_RequestUART1()) {
    wifi_SendData(data);
    resource_ReleaseUART1();
} else {
    LOG_WARNING("UART1 busy, queuing data");
    queue_Add(data);
}
```

### Código Principal (main.c)

```c
#include "system.h"

static SystemState_t current_state = SYSTEM_STATE_INIT;

void EMIC_INIT_USER(void) {
    LOG_INFO("=== Smart Irrigation System ===");

    // Inicializar todos los componentes
    sensors_Init();
    valves_Init();
    pump_Init();
    display_Init();
    wifi_Init();
    sd_Init();
    buttons_Init();

    // Cargar configuración
    config_Load();

    // Mostrar splash screen
    display_ShowSplash();
    __delay_ms(2000);

    current_state = SYSTEM_STATE_IDLE;
    LOG_INFO("System ready");
}

void EMIC_LOOP_USER(void) {
    // Procesar eventos
    event_Process();

    // Máquina de estados
    system_StateMachine();

    // Actualizar display (no bloqueante)
    display_Update();

    // Procesar comandos de usuario
    buttons_Process();
}

void system_StateMachine(void) {
    switch (current_state) {
        case SYSTEM_STATE_IDLE:
            if (timer_ReadSensors_HasElapsed()) {
                current_state = SYSTEM_STATE_READING_SENSORS;
            }
            break;

        case SYSTEM_STATE_READING_SENSORS:
            if (sensors_ReadAll()) {
                current_state = SYSTEM_STATE_DECIDING_ACTION;
            } else {
                LOG_ERROR("Sensor read failed");
                current_state = SYSTEM_STATE_ERROR;
            }
            break;

        case SYSTEM_STATE_DECIDING_ACTION:
            IrrigationDecision_t decision = irrigation_Decide();

            if (decision.should_irrigate) {
                current_state = SYSTEM_STATE_IRRIGATING;
            } else {
                current_state = SYSTEM_STATE_LOGGING;
            }
            break;

        case SYSTEM_STATE_IRRIGATING:
            irrigation_Execute();
            current_state = SYSTEM_STATE_LOGGING;
            break;

        case SYSTEM_STATE_LOGGING:
            sd_LogData();
            current_state = SYSTEM_STATE_SENDING_TELEMETRY;
            break;

        case SYSTEM_STATE_SENDING_TELEMETRY:
            if (wifi_IsConnected()) {
                telemetry_Send();
            }
            current_state = SYSTEM_STATE_IDLE;
            break;

        case SYSTEM_STATE_ERROR:
            error_Handle();
            current_state = SYSTEM_STATE_IDLE;
            break;
    }
}
```

### Módulo de Sensores (sensors.c)

```c
#include "sensors.h"

// Estado de los sensores
typedef struct {
    float soil_moisture[4];     // 4 zonas
    float air_temperature;
    float air_humidity;
    bool rain_detected;
    uint32_t last_reading_time;
} SensorData_t;

static SensorData_t sensor_data;

void sensors_Init(void) {
    // Inicializar ADC para sensores de humedad
    for (uint8_t i = 0; i < 4; i++) {
        adc_InitChannel(ADC_CHANNEL_MOISTURE_BASE + i);
    }

    // Inicializar DHT22
    dht22_Init();

    // Inicializar sensor de lluvia
    rain_sensor_Init();

    LOG_INFO("Sensors initialized");
}

bool sensors_ReadAll(void) {
    bool success = true;

    // Leer sensores de humedad (ADC)
    for (uint8_t i = 0; i < 4; i++) {
        uint16_t adc_value = adc_Read(ADC_CHANNEL_MOISTURE_BASE + i);
        sensor_data.soil_moisture[i] = adc_ToPercent(adc_value);

        LOG_DEBUG_F("Zone %d moisture: %.1f%%", i, sensor_data.soil_moisture[i]);
    }

    // Leer DHT22 (temperatura y humedad ambiente)
    if (dht22_Read()) {
        sensor_data.air_temperature = dht22_GetTemperature();
        sensor_data.air_humidity = dht22_GetHumidity();
        LOG_DEBUG_F("Air: %.1fC, %.1f%%", sensor_data.air_temperature, sensor_data.air_humidity);
    } else {
        LOG_ERROR("DHT22 read failed");
        success = false;
    }

    // Leer sensor de lluvia
    sensor_data.rain_detected = rain_sensor_IsRaining();
    if (sensor_data.rain_detected) {
        LOG_INFO("Rain detected!");
    }

    sensor_data.last_reading_time = getSystemSeconds();

    // Publicar evento
    event_Publish(EVENT_SENSOR_READING, &sensor_data);

    return success;
}

float sensors_GetSoilMoisture(uint8_t zone) {
    if (zone < 4) {
        return sensor_data.soil_moisture[zone];
    }
    return 0.0f;
}

float sensors_GetAirTemperature(void) {
    return sensor_data.air_temperature;
}

bool sensors_IsRaining(void) {
    return sensor_data.rain_detected;
}
```

### Módulo de Riego (irrigation.c)

```c
#include "irrigation.h"

// Configuración
typedef struct {
    float threshold_low;     // Umbral bajo (iniciar riego)
    float threshold_high;    // Umbral alto (detener riego)
    uint16_t max_duration_s; // Duración máxima de riego
    bool manual_mode;        // Modo manual ON/OFF
} IrrigationConfig_t;

static IrrigationConfig_t config = {
    .threshold_low = 30.0f,
    .threshold_high = 60.0f,
    .max_duration_s = 600,  // 10 minutos
    .manual_mode = false
};

// Estado del riego
typedef struct {
    bool is_irrigating;
    uint8_t active_zones;    // Bitmask de zonas activas
    uint32_t start_time;
} IrrigationState_t;

static IrrigationState_t state = {0};

IrrigationDecision_t irrigation_Decide(void) {
    IrrigationDecision_t decision = {0};

    // Si está lloviendo, no regar
    if (sensors_IsRaining()) {
        LOG_INFO("Rain detected, irrigation disabled");
        decision.should_irrigate = false;
        return decision;
    }

    // Si está en modo manual, no decidir automáticamente
    if (config.manual_mode) {
        decision.should_irrigate = false;
        return decision;
    }

    // Verificar cada zona
    for (uint8_t zone = 0; zone < 4; zone++) {
        float moisture = sensors_GetSoilMoisture(zone);

        if (moisture < config.threshold_low) {
            decision.should_irrigate = true;
            decision.zones_to_irrigate |= (1 << zone);
            LOG_INFO_F("Zone %d needs water (%.1f%%)", zone, moisture);
        }
    }

    return decision;
}

void irrigation_Execute(void) {
    IrrigationDecision_t decision = irrigation_Decide();

    if (!decision.should_irrigate) {
        return;
    }

    LOG_INFO("Starting irrigation...");

    // Activar bomba
    pump_Start();
    __delay_ms(500);  // Esperar presión

    // Abrir válvulas necesarias
    for (uint8_t zone = 0; zone < 4; zone++) {
        if (decision.zones_to_irrigate & (1 << zone)) {
            valve_Open(zone);
            LOG_INFO_F("Zone %d valve opened", zone);
        }
    }

    state.is_irrigating = true;
    state.active_zones = decision.zones_to_irrigate;
    state.start_time = getSystemSeconds();

    // Publicar evento
    event_Publish(EVENT_IRRIGATION_STARTED, &state);
}

void irrigation_Stop(void) {
    if (!state.is_irrigating) {
        return;
    }

    LOG_INFO("Stopping irrigation...");

    // Cerrar todas las válvulas
    for (uint8_t zone = 0; zone < 4; zone++) {
        valve_Close(zone);
    }

    // Apagar bomba
    pump_Stop();

    uint32_t duration = getSystemSeconds() - state.start_time;
    LOG_INFO_F("Irrigation stopped (duration: %lu seconds)", duration);

    state.is_irrigating = false;
    state.active_zones = 0;

    // Publicar evento
    event_Publish(EVENT_IRRIGATION_STOPPED, &duration);
}

void irrigation_Update(void) {
    if (!state.is_irrigating) {
        return;
    }

    uint32_t elapsed = getSystemSeconds() - state.start_time;

    // Verificar duración máxima
    if (elapsed > config.max_duration_s) {
        LOG_WARNING("Max irrigation duration reached");
        irrigation_Stop();
        return;
    }

    // Verificar si se alcanzó el umbral alto
    bool all_zones_satisfied = true;
    for (uint8_t zone = 0; zone < 4; zone++) {
        if (state.active_zones & (1 << zone)) {
            float moisture = sensors_GetSoilMoisture(zone);
            if (moisture < config.threshold_high) {
                all_zones_satisfied = false;
                break;
            }
        }
    }

    if (all_zones_satisfied) {
        LOG_INFO("All zones satisfied");
        irrigation_Stop();
    }
}
```

### Módulo de Display (display.c)

```c
#include "display.h"

// Pantallas del display
typedef enum {
    DISPLAY_SCREEN_STATUS,
    DISPLAY_SCREEN_SENSORS,
    DISPLAY_SCREEN_IRRIGATION,
    DISPLAY_SCREEN_WIFI
} DisplayScreen_t;

static DisplayScreen_t current_screen = DISPLAY_SCREEN_STATUS;
static uint32_t last_update = 0;

#define DISPLAY_UPDATE_INTERVAL_MS 1000

void display_Update(void) {
    if (getSystemMilis() - last_update < DISPLAY_UPDATE_INTERVAL_MS) {
        return;  // No actualizar aún
    }

    lcd_Clear();

    switch (current_screen) {
        case DISPLAY_SCREEN_STATUS:
            display_ShowStatus();
            break;
        case DISPLAY_SCREEN_SENSORS:
            display_ShowSensors();
            break;
        case DISPLAY_SCREEN_IRRIGATION:
            display_ShowIrrigation();
            break;
        case DISPLAY_SCREEN_WIFI:
            display_ShowWiFi();
            break;
    }

    last_update = getSystemMilis();
}

void display_ShowStatus(void) {
    char buffer[21];

    // Línea 1: Título
    lcd_SetCursor(0, 0);
    lcd_Print("  Smart Irrigation  ");

    // Línea 2: Modo
    lcd_SetCursor(0, 1);
    if (irrigation_IsManualMode()) {
        lcd_Print("Mode: MANUAL        ");
    } else {
        lcd_Print("Mode: AUTO          ");
    }

    // Línea 3: Estado de riego
    lcd_SetCursor(0, 2);
    if (irrigation_IsActive()) {
        sprintf(buffer, "Irrigating: %d zones ", irrigation_GetActiveZones());
        lcd_Print(buffer);
    } else {
        lcd_Print("Status: IDLE        ");
    }

    // Línea 4: WiFi y SD
    lcd_SetCursor(0, 3);
    sprintf(buffer, "WiFi:%s SD:%s",
            wifi_IsConnected() ? "OK" : "X ",
            sd_IsReady() ? "OK" : "X ");
    lcd_Print(buffer);
}

void display_ShowSensors(void) {
    char buffer[21];

    // Línea 1: Temperatura y humedad ambiente
    lcd_SetCursor(0, 0);
    sprintf(buffer, "Air: %.1fC  %.0f%%    ",
            sensors_GetAirTemperature(),
            sensors_GetAirHumidity());
    lcd_Print(buffer);

    // Líneas 2-4: Humedad del suelo
    for (uint8_t i = 0; i < 3; i++) {
        lcd_SetCursor(0, i + 1);
        sprintf(buffer, "Zone %d: %.0f%%  ", i, sensors_GetSoilMoisture(i));
        lcd_Print(buffer);
    }
}
```

---

## Gestión de Recursos Compartidos

### Problema: Multiple Acceso a UART

**Escenario:**
- WiFi usa UART1
- Debug logging quiere usar UART1
- Ambos intentan enviar al mismo tiempo

**Solución: Semaphore Pattern**

```c
// resource_manager.c
typedef struct {
    bool is_busy;
    uint8_t owner_id;
    uint32_t lock_time;
} Resource_t;

static Resource_t uart1_resource = {false, 0, 0};

#define RESOURCE_TIMEOUT_MS 5000

bool resource_LockUART1(uint8_t owner_id) {
    // Verificar si está libre
    if (!uart1_resource.is_busy) {
        uart1_resource.is_busy = true;
        uart1_resource.owner_id = owner_id;
        uart1_resource.lock_time = getSystemMilis();
        return true;
    }

    // Verificar timeout (liberar si está bloqueado mucho tiempo)
    uint32_t elapsed = getSystemMilis() - uart1_resource.lock_time;
    if (elapsed > RESOURCE_TIMEOUT_MS) {
        LOG_WARNING_F("UART1 lock timeout (owner: %d)", uart1_resource.owner_id);
        resource_UnlockUART1(uart1_resource.owner_id);
        return resource_LockUART1(owner_id);
    }

    return false;
}

void resource_UnlockUART1(uint8_t owner_id) {
    if (uart1_resource.owner_id == owner_id) {
        uart1_resource.is_busy = false;
        uart1_resource.owner_id = 0;
    }
}

// Uso en WiFi module:
bool wifi_Send(const char* data) {
    if (resource_LockUART1(RESOURCE_OWNER_WIFI)) {
        uart1_WriteString(data);
        resource_UnlockUART1(RESOURCE_OWNER_WIFI);
        return true;
    }
    return false;  // Recurso ocupado
}
```

---

## Sincronización y Timing

### Problema: Múltiples Tareas Periódicas

```
Tarea 1: Leer sensores cada 5 segundos
Tarea 2: Actualizar display cada 1 segundo
Tarea 3: Enviar telemetría cada 60 segundos
Tarea 4: Guardar en SD cada 300 segundos
```

**Solución: Task Scheduler**

```c
typedef struct {
    void (*task_function)(void);
    uint32_t period_ms;
    uint32_t last_execution;
    bool enabled;
} Task_t;

#define MAX_TASKS 10
static Task_t tasks[MAX_TASKS];
static uint8_t task_count = 0;

void scheduler_RegisterTask(void (*function)(void), uint32_t period_ms) {
    if (task_count < MAX_TASKS) {
        tasks[task_count].task_function = function;
        tasks[task_count].period_ms = period_ms;
        tasks[task_count].last_execution = getSystemMilis();
        tasks[task_count].enabled = true;
        task_count++;
    }
}

void scheduler_Run(void) {
    uint32_t current_time = getSystemMilis();

    for (uint8_t i = 0; i < task_count; i++) {
        if (!tasks[i].enabled) {
            continue;
        }

        uint32_t elapsed = current_time - tasks[i].last_execution;

        if (elapsed >= tasks[i].period_ms) {
            tasks[i].task_function();
            tasks[i].last_execution = current_time;
        }
    }
}

// Uso:
void EMIC_INIT_USER(void) {
    scheduler_RegisterTask(task_ReadSensors, 5000);     // 5s
    scheduler_RegisterTask(task_UpdateDisplay, 1000);   // 1s
    scheduler_RegisterTask(task_SendTelemetry, 60000);  // 60s
    scheduler_RegisterTask(task_SaveToSD, 300000);      // 300s
}

void EMIC_LOOP_USER(void) {
    scheduler_Run();
}
```

---

## Manejo de Eventos

### Sistema de Eventos Completo

```c
// event.h
typedef enum {
    EVENT_SENSOR_READING,
    EVENT_THRESHOLD_EXCEEDED,
    EVENT_IRRIGATION_STARTED,
    EVENT_IRRIGATION_STOPPED,
    EVENT_WIFI_CONNECTED,
    EVENT_WIFI_DISCONNECTED,
    EVENT_SD_ERROR,
    EVENT_BUTTON_PRESSED,
    EVENT_MAX
} EventType_t;

typedef void (*EventHandler_t)(void* data);

void event_Init(void);
void event_Subscribe(EventType_t type, EventHandler_t handler);
void event_Publish(EventType_t type, void* data);
void event_Process(void);

// event.c
#define MAX_HANDLERS_PER_EVENT 5

typedef struct {
    EventHandler_t handlers[MAX_HANDLERS_PER_EVENT];
    uint8_t handler_count;
} EventHandlers_t;

static EventHandlers_t event_handlers[EVENT_MAX];

void event_Subscribe(EventType_t type, EventHandler_t handler) {
    if (type < EVENT_MAX) {
        EventHandlers_t* handlers = &event_handlers[type];
        if (handlers->handler_count < MAX_HANDLERS_PER_EVENT) {
            handlers->handlers[handlers->handler_count++] = handler;
        }
    }
}

void event_Publish(EventType_t type, void* data) {
    if (type < EVENT_MAX) {
        EventHandlers_t* handlers = &event_handlers[type];
        for (uint8_t i = 0; i < handlers->handler_count; i++) {
            handlers->handlers[i](data);
        }
    }
}

// Uso:
void OnIrrigationStarted(void* data) {
    IrrigationState_t* state = (IrrigationState_t*)data;
    LOG_INFO_F("Irrigation started (zones: %d)", state->active_zones);
    display_ShowNotification("Irrigating...");
    led_irrigation_On();
}

void EMIC_INIT_USER(void) {
    event_Subscribe(EVENT_IRRIGATION_STARTED, OnIrrigationStarted);
}
```

---

## Optimización de Memoria

### Análisis de Uso de RAM

```c
// memory_profile.h
typedef struct {
    uint16_t total_ram;
    uint16_t used_ram;
    uint16_t free_ram;
    uint16_t stack_usage;
    uint16_t heap_usage;
} MemoryProfile_t;

MemoryProfile_t memory_GetProfile(void);

// memory_profile.c
extern uint16_t __heap_start;
extern uint16_t __heap_end;
extern uint16_t __stack_start;

MemoryProfile_t memory_GetProfile(void) {
    MemoryProfile_t profile;

    // Total RAM (ejemplo PIC24FJ64GA002: 8KB)
    profile.total_ram = 8192;

    // Stack usage (aproximado)
    uint16_t sp;
    asm volatile ("mov w15, %0" : "=r" (sp));
    profile.stack_usage = (uint16_t)&__stack_start - sp;

    // Heap usage
    profile.heap_usage = (uint16_t)&__heap_end - (uint16_t)&__heap_start;

    profile.used_ram = profile.stack_usage + profile.heap_usage;
    profile.free_ram = profile.total_ram - profile.used_ram;

    return profile;
}

// Uso:
void EMIC_INIT_USER(void) {
    MemoryProfile_t mem = memory_GetProfile();
    LOG_INFO_F("RAM Total: %d bytes", mem.total_ram);
    LOG_INFO_F("RAM Used: %d bytes (%.1f%%)",
               mem.used_ram,
               (mem.used_ram * 100.0f) / mem.total_ram);
    LOG_INFO_F("RAM Free: %d bytes", mem.free_ram);
}
```

### Técnicas de Optimización

**1. Usar tipos de datos apropiados:**
```c
✅ BUENO:
uint8_t counter = 0;        // 1 byte
bool is_active = false;     // 1 byte

❌ MALO:
int counter = 0;            // 2 bytes (PIC24)
int is_active = 0;          // 2 bytes
```

**2. Compartir buffers:**
```c
✅ BUENO:
#define BUFFER_SIZE 128
static char shared_buffer[BUFFER_SIZE];

void function1(void) {
    sprintf(shared_buffer, "Data: %d", value);
    uart_Send(shared_buffer);
}

void function2(void) {
    sprintf(shared_buffer, "Temp: %.1f", temp);
    display_Print(shared_buffer);
}

❌ MALO:
void function1(void) {
    char buffer1[128];  // 128 bytes
    sprintf(buffer1, "Data: %d", value);
}

void function2(void) {
    char buffer2[128];  // Otros 128 bytes
    sprintf(buffer2, "Temp: %.1f", temp);
}
```

**3. Usar const para datos en Flash:**
```c
✅ BUENO:
const char* menu_items[] = {  // En Flash
    "Start Irrigation",
    "Stop Irrigation",
    "View Settings",
    "Exit"
};

❌ MALO:
char* menu_items[] = {  // En RAM
    "Start Irrigation",
    "Stop Irrigation",
    "View Settings",
    "Exit"
};
```

---

## Performance y Eficiencia

### Profiling de Ejecución

```c
#define PROFILE_START(name) \
    uint32_t profile_start_##name = getSystemMicros();

#define PROFILE_END(name) \
    uint32_t profile_duration_##name = getSystemMicros() - profile_start_##name; \
    LOG_INFO_F(#name " took %lu us", profile_duration_##name);

// Uso:
void ComplexFunction(void) {
    PROFILE_START(calculation);

    // Código complejo
    for (int i = 0; i < 1000; i++) {
        result += sqrt(i);
    }

    PROFILE_END(calculation);
}
```

### Optimización de Loops

```c
✅ BUENO:
uint8_t count = array_length;  // Calcular una vez
for (uint8_t i = 0; i < count; i++) {
    process(array[i]);
}

❌ MALO:
for (uint8_t i = 0; i < array_length; i++) {  // Calcula cada iteración
    process(array[i]);
}
```

---

## Caso Práctico: Gateway IoT Industrial

Sistema complejo con múltiples protocolos de comunicación.

### Especificaciones

**Protocolos:**
- Modbus RTU (RS485)
- MQTT (WiFi)
- HTTP REST API (WiFi)
- LoRaWAN
- SD Card logging

**Funcionalidad:**
- Leer datos de 10 sensores Modbus
- Publicar en MQTT broker
- Exponer REST API local
- Enviar datos críticos por LoRa
- Logging local en SD

### Arquitectura

```
┌─────────────────────────────────────────────────┐
│           Protocol Router                       │
│  - Recibe datos de todos los protocolos        │
│  - Enruta según destino                         │
└─────────────────────────────────────────────────┘
       ↓              ↓              ↓
┌────────────┐ ┌────────────┐ ┌────────────┐
│  Modbus    │ │   MQTT     │ │   LoRa     │
│  Handler   │ │  Handler   │ │  Handler   │
└────────────┘ └────────────┘ └────────────┘
```

(Por brevedad, solo se muestra la arquitectura conceptual)

---

## Buenas Prácticas

### 1. Diseño Modular

```c
✅ BUENO:
// Cada módulo es independiente
sensors_Init();
actuators_Init();
comm_Init();

❌ MALO:
// Todo mezclado
mega_InitEverything();
```

### 2. Interfaces Claras

```c
✅ BUENO:
// Interfaz bien definida
float sensor_GetValue(uint8_t sensor_id);

❌ MALO:
// Expone detalles internos
extern uint16_t sensor_raw_values[10];
```

### 3. Manejo de Errores

```c
✅ BUENO:
if (!sensor_Read()) {
    error_Handle(ERROR_SENSOR_FAIL);
    return false;
}

❌ MALO:
sensor_Read();  // ¿Y si falla?
```

---

## Anti-Patrones

### Anti-Patrón 1: God Object

```c
❌ MALO:
// Un objeto que hace TODO
typedef struct {
    float sensors[10];
    bool actuators[5];
    char wifi_buffer[256];
    char sd_buffer[512];
    // ... 50 campos más
} MegaSystem_t;

void megasystem_DoEverything(MegaSystem_t* sys);
```

### Anti-Patrón 2: Spaghetti Code

```c
❌ MALO:
void EMIC_LOOP_USER(void) {
    // 500 líneas de código sin estructura
    if (sensor1 > 10) {
        if (sensor2 < 20) {
            if (actuator1_state == ON) {
                // ...
                if (wifi_connected) {
                    // ... 200 líneas más
                }
            }
        }
    }
}
```

---

## Resumen del Capítulo

### Lo que Aprendiste

1. **Principios de integración**
   - Separation of Concerns
   - Loose Coupling
   - High Cohesion

2. **Patrones de integración**
   - Layered Architecture
   - Event-Driven
   - State Machine
   - Observer

3. **Arquitecturas escalables**
   - Monolítica (simple)
   - Modular (mediano)
   - Event-Driven + FSM (complejo)

4. **Sistema completo: Riego Inteligente**
   - 10+ componentes integrados
   - FSM completa
   - Gestión de recursos
   - Código funcional

5. **Optimización**
   - Memoria (RAM y Flash)
   - Performance (profiling)
   - Recursos compartidos

### Checklist de Integración

- ✅ Diseño modular (SoC)
- ✅ Interfaces claras
- ✅ Gestión de recursos compartidos
- ✅ Sincronización de tareas
- ✅ Sistema de eventos
- ✅ Manejo de errores robusto
- ✅ Optimización de memoria
- ✅ Profiling de performance
- ✅ Testing de integración

### Próximo Capítulo

**Capítulo 26: Deployment y Producción** (ÚLTIMO DE SECCIÓN 4)
- Publicar APIs en el SDK
- Versionado semántico
- Documentación completa
- Mantenimiento y soporte

---

**¡Felicitaciones!** Ahora dominas la integración de sistemas complejos en EMIC. Estas técnicas son esenciales para proyectos profesionales reales.

---

**Sección 4 - Capítulo 25**
Manual de Desarrollo EMIC SDK
Versión 1.0.0

---
