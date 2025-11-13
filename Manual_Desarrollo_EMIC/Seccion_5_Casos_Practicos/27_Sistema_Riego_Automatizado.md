# Capítulo 27: Sistema de Riego Automatizado

## 📋 Contenido
1. [Introducción](#introducción)
2. [Descripción del Proyecto](#descripción-del-proyecto)
3. [Hardware Necesario](#hardware-necesario)
4. [Arquitectura del Sistema](#arquitectura-del-sistema)
5. [Implementación Módulo de Sensores](#implementación-módulo-de-sensores)
6. [Implementación Módulo de Actuadores](#implementación-módulo-de-actuadores)
7. [Algoritmo de Control Inteligente](#algoritmo-de-control-inteligente)
8. [Sistema de Scheduling](#sistema-de-scheduling)
9. [Interfaz de Usuario](#interfaz-de-usuario)
10. [Comunicaciones IoT](#comunicaciones-iot)
11. [Manejo de Errores y Diagnósticos](#manejo-de-errores-y-diagnósticos)
12. [Ahorro de Energía](#ahorro-de-energía)
13. [Logging y Telemetría](#logging-y-telemetría)
14. [Testing y Calibración](#testing-y-calibración)
15. [Código Completo](#código-completo)
16. [Resumen](#resumen)

---

## Introducción

Este capítulo presenta un **caso práctico completo**: un **Sistema de Riego Automatizado Inteligente** diseñado para **agricultura de precisión** e **invernaderos automatizados**.

### ¿Qué aprenderás?

- Integrar **múltiples sensores y actuadores** en un sistema real
- Implementar **algoritmos de decisión inteligente** basados en datos
- Diseñar **sistemas de scheduling** para tareas programadas
- Crear **interfaces de usuario** profesionales (LCD + botones + app móvil)
- Implementar **comunicaciones IoT** (WiFi/LoRa)
- Manejar **errores críticos** y **diagnósticos automáticos**
- Optimizar **consumo de energía** en sistemas autónomos
- Implementar **logging** y **telemetría** para análisis de datos

### Características del Sistema

| Característica | Descripción |
|----------------|-------------|
| **Zonas de Riego** | Hasta 8 zonas independientes con válvulas solenoides |
| **Sensores** | Humedad de suelo (x8), temperatura/humedad ambiente, lluvia, nivel de agua |
| **Control** | Automático (horarios + sensores) y manual (app/botones) |
| **Comunicación** | WiFi (local) + LoRa (largo alcance) |
| **Energía** | Solar + batería con modos de ahorro de energía |
| **Interfaz** | LCD 20x4 + 4 botones + app móvil |
| **Telemetría** | Histórico de riegos, estadísticas, alertas |

---

## Descripción del Proyecto

### Requisitos Funcionales

#### RF-01: Control de Zonas de Riego
- Sistema debe controlar **8 zonas de riego independientes**
- Cada zona tiene:
  - **Válvula solenoide 24V**
  - **Sensor de humedad capacitivo**
  - **Configuración independiente** (horarios, umbrales)

#### RF-02: Sensores Ambientales
- **DHT22**: Temperatura y humedad ambiente
- **Sensor de lluvia**: Detección de precipitación
- **Sensor de nivel**: Control de reservorio de agua
- **Sensor de flujo**: Medición de caudal (opcional)

#### RF-03: Modos de Operación
1. **Automático**: Riego basado en horarios + sensores
2. **Manual**: Control directo desde app o botones
3. **Deshabilitado**: Sistema en standby

#### RF-04: Algoritmo Inteligente
- Evitar riego si **está lloviendo**
- Evitar riego si **humedad del suelo > umbral**
- Reducir riego si **humedad ambiente alta**
- Ajustar duración según **temperatura**
- Priorizar zonas según **déficit hídrico**

#### RF-05: Interfaz de Usuario
- **LCD 20x4**: Visualización de estado en tiempo real
- **4 Botones**: Navegación de menú
- **App Móvil**: Control remoto y monitoreo (WiFi)

#### RF-06: Comunicaciones
- **WiFi**: Comunicación local con app móvil (JSON API)
- **LoRa**: Telemetría a largo alcance (opcional)
- **UART**: Debug y configuración por terminal

#### RF-07: Diagnósticos y Errores
- Detección de **sensor desconectado**
- Detección de **válvula bloqueada**
- Detección de **nivel de agua bajo**
- Detección de **bomba con falla**
- Alertas por **app** y **LCD**

#### RF-08: Ahorro de Energía
- Modo **Sleep** durante la noche (si no hay riego programado)
- Wake-up por **RTC** para riegos programados
- Wake-up por **botón** para acceso manual
- Apagado de **LCD** después de 30 segundos sin interacción

#### RF-09: Logging y Telemetría
- Registro de **eventos de riego** (inicio, duración, zona)
- Registro de **lecturas de sensores** (cada hora)
- Cálculo de **estadísticas** (consumo de agua, eficiencia)
- Envío de **datos históricos** a servidor cloud

### Requisitos No Funcionales

| Requisito | Especificación |
|-----------|----------------|
| **RNF-01: Confiabilidad** | Sistema debe funcionar 24/7 con < 1% downtime |
| **RNF-02: Precisión** | Error de medición de humedad < 5% |
| **RNF-03: Tiempo de respuesta** | Activación de válvula < 2 segundos |
| **RNF-04: Autonomía** | Sistema debe funcionar > 7 días sin luz solar |
| **RNF-05: Mantenibilidad** | Código modular con documentación DOXYGEN |
| **RNF-06: Escalabilidad** | Soporte hasta 16 zonas con cambios mínimos |

---

## Hardware Necesario

### Microcontrolador

**PIC24FJ128GA204** (recomendado)
- **Memoria**: 128 KB Flash, 8 KB RAM
- **Periféricos**:
  - 8x ADC para sensores analógicos
  - 2x UART (WiFi + debug)
  - 1x SPI (LoRa)
  - 1x I2C (LCD, RTC)
  - 16x GPIO (válvulas, sensores digitales, botones)
- **RTC**: Real-Time Clock para scheduling
- **Sleep Modes**: Bajo consumo < 1 µA

### Sensores

| Sensor | Modelo | Interfaz | Cantidad |
|--------|--------|----------|----------|
| Humedad de suelo | Capacitive Soil Moisture v1.2 | ADC | 8 |
| Temperatura/Humedad | DHT22 | 1-Wire | 1 |
| Lluvia | YL-83 | Digital | 1 |
| Nivel de agua | HC-SR04 (ultrasónico) | GPIO | 1 |
| Flujo de agua | YF-S201 (opcional) | Interrupción | 1 |

### Actuadores

| Actuador | Especificación | Driver | Cantidad |
|----------|----------------|--------|----------|
| Válvula solenoide | 24V DC, 0.5A | Relay/MOSFET | 8 |
| Bomba de agua | 12V DC, 2A | Relay | 1 |
| Buzzer | Piezo 5V | GPIO | 1 |
| LED indicador | RGB 5mm | GPIO (x3) | 1 |

### Comunicaciones

| Módulo | Interfaz | Propósito |
|--------|----------|-----------|
| **ESP-01 (ESP8266)** | UART | WiFi para app móvil |
| **RFM95W (LoRa)** | SPI | Telemetría largo alcance |
| **RTC DS3231** | I2C | Reloj en tiempo real |

### Interfaz de Usuario

| Componente | Interfaz | Especificación |
|------------|----------|----------------|
| **LCD 20x4** | I2C (PCF8574) | Display con backlight |
| **Botones** | GPIO (pullup) | UP, DOWN, OK, BACK |

### Alimentación

| Componente | Especificación |
|------------|----------------|
| **Panel solar** | 20W, 12V |
| **Batería** | Li-Ion 18650 (3S2P) 11.1V 5200mAh |
| **Regulador** | Buck converter 12V → 5V (3A) |
| **Cargador solar** | TP4056 + BMS 3S |

---

## Arquitectura del Sistema

### Diagrama de Capas

```
┌─────────────────────────────────────────────────────┐
│          CAPA DE APLICACIÓN                         │
│  - Smart Irrigation Algorithm                       │
│  - Scheduler (RTC-based)                            │
│  - User Interface Controller                        │
│  - Telemetry Manager                                │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│          CAPA DE LÓGICA DE NEGOCIO                  │
│  - Zone Controller (8 zonas)                        │
│  - Sensor Manager (polling, filtering)              │
│  - Actuator Manager (safe control)                  │
│  - Event Logger                                     │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│          CAPA DE ABSTRACCIÓN (APIs)                 │
│  - Soil Moisture API                                │
│  - Valve Control API                                │
│  - WiFi Communication API                           │
│  - LCD Display API                                  │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│          CAPA DE DRIVERS                            │
│  - ADC Driver (sensores analógicos)                 │
│  - GPIO Driver (válvulas, botones)                  │
│  - UART Driver (ESP8266)                            │
│  - I2C Driver (LCD, RTC)                            │
│  - SPI Driver (LoRa)                                │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│          HARDWARE ABSTRACTION LAYER (HAL)           │
│  - PIC24 Peripherals (ADC, UART, I2C, SPI, GPIO)    │
└─────────────────────────────────────────────────────┘
```

### Diagrama de Módulos

El proyecto está dividido en **8 módulos EMIC**:

```
SmartIrrigationSystem/
├── Module_SensorHub/           # Lectura y procesamiento de sensores
├── Module_ValveController/     # Control de válvulas y bomba
├── Module_SmartAlgorithm/      # Algoritmo de decisión inteligente
├── Module_Scheduler/           # Sistema de horarios RTC
├── Module_UserInterface/       # LCD + botones
├── Module_WiFiComm/            # Comunicación WiFi (ESP8266)
├── Module_Telemetry/           # Logging + estadísticas
└── Module_PowerManagement/     # Ahorro de energía
```

### Flujo de Datos

```
┌───────────┐     ┌───────────┐     ┌──────────────┐
│  Sensores │────→│  Sensor   │────→│   Smart      │
│ (8 zonas) │     │    Hub    │     │  Algorithm   │
└───────────┘     └───────────┘     └──────────────┘
                                            ↓
┌───────────┐     ┌───────────┐     ┌──────────────┐
│  Usuario  │────→│    UI     │────→│   Scheduler  │
│ (LCD/App) │     │Controller │     └──────────────┘
└───────────┘     └───────────┘            ↓
                                     ┌──────────────┐
┌───────────┐     ┌───────────┐     │    Valve     │
│  Bomba +  │←────│   Valve   │←────│  Controller  │
│  Válvulas │     │ Controller│     └──────────────┘
└───────────┘     └───────────┘            ↓
                                     ┌──────────────┐
                                     │  Telemetry   │
                                     │   Manager    │
                                     └──────────────┘
```

---

## Implementación Módulo de Sensores

### Module_SensorHub

Este módulo se encarga de:
- Leer **8 sensores de humedad** (ADC)
- Leer **DHT22** (temperatura/humedad ambiente)
- Leer **sensor de lluvia** (digital)
- Leer **sensor de nivel de agua** (ultrasónico)
- **Filtrar ruido** con promedio móvil
- **Detectar errores** (sensor desconectado)

#### Archivo: `config.json`

```json
{
  "module_name": "SensorHub",
  "description": "Lectura y procesamiento de sensores ambientales",
  "version": "1.0.0",
  "parameters": {
    "soil_moisture_channels": {
      "type": "array",
      "value": ["AN0", "AN1", "AN2", "AN3", "AN4", "AN5", "AN6", "AN7"],
      "description": "Canales ADC para sensores de humedad (8 zonas)"
    },
    "dht22_pin": {
      "type": "pin",
      "value": "B0_Pin",
      "description": "Pin GPIO para DHT22 (1-Wire)"
    },
    "rain_sensor_pin": {
      "type": "pin",
      "value": "B1_Pin",
      "description": "Pin digital para sensor de lluvia"
    },
    "water_level_trigger_pin": {
      "type": "pin",
      "value": "B2_Pin",
      "description": "Pin trigger para sensor ultrasónico"
    },
    "water_level_echo_pin": {
      "type": "pin",
      "value": "B3_Pin",
      "description": "Pin echo para sensor ultrasónico"
    },
    "filter_samples": {
      "type": "integer",
      "value": 10,
      "description": "Número de muestras para promedio móvil"
    }
  }
}
```

#### Archivo: `generate.emic`

```emic
// ============================================================================
// Module: SensorHub - Generación de código
// ============================================================================

EMIC:setOutput(TARGET:generate.txt)

    // Incluir PCB y configuración base
    EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_Development_Board)
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    // APIs necesarias

    // ADC para sensores de humedad (8 canales)
    EMIC:setInput(DEV:_api/ADC/adc_api.emic,name=soilMoisture,channels=[AN0,AN1,AN2,AN3,AN4,AN5,AN6,AN7])

    // GPIO para DHT22
    EMIC:setInput(DEV:_api/GPIO/gpio_api.emic,name=dht22,pin=B0_Pin,direction=output)

    // GPIO para sensor de lluvia
    EMIC:setInput(DEV:_api/GPIO/gpio_api.emic,name=rainSensor,pin=B1_Pin,direction=input_pullup)

    // GPIO para sensor ultrasónico
    EMIC:setInput(DEV:_api/GPIO/gpio_api.emic,name=waterTrigger,pin=B2_Pin,direction=output)
    EMIC:setInput(DEV:_api/GPIO/gpio_api.emic,name=waterEcho,pin=B3_Pin,direction=input)

    // Timer para delays
    EMIC:setInput(DEV:_api/Timers/timer_api.emic,name=1)

    // Copiar archivos del usuario
    EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
    EMIC:copy(SYS:inc/userFncFile.h > TARGET:inc/userFncFile.h)
    EMIC:define(c_modules.userFncFile,userFncFile)

    // Template de proyecto
    EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

#### Archivo: `userFncFile.h`

```c
/**
 * @file userFncFile.h
 * @brief SensorHub - Interfaz pública de sensores
 * @version 1.0.0
 */

#ifndef SENSORHUB_H
#define SENSORHUB_H

#include <stdint.h>
#include <stdbool.h>

// ============================================================================
// DEFINICIONES Y CONSTANTES
// ============================================================================

#define NUM_ZONES                8     // 8 zonas de riego
#define ADC_MAX_VALUE            1023  // ADC 10-bit
#define FILTER_SAMPLES           10    // Muestras para promedio móvil

// Umbrales de humedad (valores ADC)
#define HUMIDITY_DRY_THRESHOLD   800   // Suelo seco (necesita riego)
#define HUMIDITY_WET_THRESHOLD   300   // Suelo húmedo (no necesita riego)

// Umbrales de sensor de nivel de agua
#define WATER_LEVEL_MIN_CM       10    // Nivel mínimo (alarma)
#define WATER_LEVEL_MAX_CM       100   // Nivel máximo (tanque lleno)

// Estados de error de sensores
#define SENSOR_OK                0
#define SENSOR_DISCONNECTED      1
#define SENSOR_OUT_OF_RANGE      2

// ============================================================================
// ESTRUCTURAS DE DATOS
// ============================================================================

/**
 * @brief Datos de un sensor de humedad individual
 */
typedef struct {
    uint16_t raw_value;           ///< Valor ADC crudo (0-1023)
    uint8_t  humidity_percent;    ///< Humedad en % (0-100)
    uint16_t filter_buffer[FILTER_SAMPLES]; ///< Buffer para filtro promedio móvil
    uint8_t  filter_index;        ///< Índice actual en buffer circular
    uint8_t  error_code;          ///< Código de error (0 = OK)
    bool     is_initialized;      ///< ¿Sensor inicializado?
} SoilMoistureSensor_t;

/**
 * @brief Datos de sensor DHT22 (temperatura y humedad ambiente)
 */
typedef struct {
    float    temperature_c;       ///< Temperatura en °C
    float    humidity_percent;    ///< Humedad relativa en %
    uint32_t last_read_time;      ///< Timestamp de última lectura
    uint8_t  error_code;          ///< Código de error
} DHT22Data_t;

/**
 * @brief Datos del sensor de nivel de agua
 */
typedef struct {
    uint16_t distance_cm;         ///< Distancia medida en cm
    uint8_t  level_percent;       ///< Nivel de agua en % (0-100)
    bool     is_low;              ///< ¿Nivel bajo? (alarma)
    uint8_t  error_code;          ///< Código de error
} WaterLevelData_t;

/**
 * @brief Estado completo de todos los sensores del sistema
 */
typedef struct {
    SoilMoistureSensor_t soil[NUM_ZONES];  ///< Sensores de humedad (8 zonas)
    DHT22Data_t          dht22;            ///< Temperatura y humedad ambiente
    bool                 is_raining;       ///< ¿Está lloviendo?
    WaterLevelData_t     water_level;      ///< Nivel de agua en tanque
    uint32_t             last_update_time; ///< Timestamp de última actualización
} SensorHubData_t;

// ============================================================================
// FUNCIONES PÚBLICAS
// ============================================================================

/**
 * @brief Inicializa el módulo SensorHub
 *
 * Configura todos los periféricos necesarios (ADC, GPIO, Timer)
 */
void sensorHub_Init(void);

/**
 * @brief Actualiza todos los sensores (debe llamarse periódicamente)
 *
 * Lee todos los sensores y actualiza la estructura global.
 * Recomendado: llamar cada 1 segundo.
 */
void sensorHub_Update(void);

/**
 * @brief Obtiene los datos actuales de todos los sensores
 *
 * @return Puntero a estructura con datos de sensores (solo lectura)
 */
const SensorHubData_t* sensorHub_GetData(void);

/**
 * @brief Lee humedad de suelo de una zona específica
 *
 * @param zone_index Índice de zona (0-7)
 * @return Humedad en % (0-100), o 255 si error
 */
uint8_t sensorHub_GetSoilMoisture(uint8_t zone_index);

/**
 * @brief Verifica si una zona necesita riego
 *
 * @param zone_index Índice de zona (0-7)
 * @return true si humedad < umbral seco
 */
bool sensorHub_NeedsWatering(uint8_t zone_index);

/**
 * @brief Lee temperatura ambiente
 *
 * @return Temperatura en °C, o -999.0 si error
 */
float sensorHub_GetTemperature(void);

/**
 * @brief Lee humedad ambiente
 *
 * @return Humedad relativa en %, o -1.0 si error
 */
float sensorHub_GetAmbientHumidity(void);

/**
 * @brief Verifica si está lloviendo
 *
 * @return true si se detecta lluvia
 */
bool sensorHub_IsRaining(void);

/**
 * @brief Lee nivel de agua en el tanque
 *
 * @return Nivel en % (0-100), o 255 si error
 */
uint8_t sensorHub_GetWaterLevel(void);

/**
 * @brief Verifica si hay agua suficiente para regar
 *
 * @return true si nivel > mínimo
 */
bool sensorHub_HasWater(void);

/**
 * @brief Obtiene diagnóstico de sensores
 *
 * @param zone_index Índice de zona (0-7), o 255 para sensores globales
 * @return Código de error (0 = OK)
 */
uint8_t sensorHub_GetErrorCode(uint8_t zone_index);

#endif // SENSORHUB_H
```

#### Archivo: `userFncFile.c` (extracto clave)

```c
/**
 * @file userFncFile.c
 * @brief SensorHub - Implementación
 */

#include "userFncFile.h"
#include <string.h>

// ============================================================================
// VARIABLES GLOBALES
// ============================================================================

static SensorHubData_t g_sensor_data;

// ============================================================================
// FUNCIONES PRIVADAS
// ============================================================================

/**
 * @brief Convierte valor ADC a porcentaje de humedad (0-100%)
 */
static uint8_t adc_to_humidity_percent(uint16_t adc_value) {
    // Sensor capacitivo: valor alto = seco, valor bajo = húmedo
    if (adc_value >= HUMIDITY_DRY_THRESHOLD) {
        return 0;  // 0% humedad (muy seco)
    } else if (adc_value <= HUMIDITY_WET_THRESHOLD) {
        return 100;  // 100% humedad (muy húmedo)
    } else {
        // Interpolación lineal
        uint16_t range = HUMIDITY_DRY_THRESHOLD - HUMIDITY_WET_THRESHOLD;
        uint16_t offset = HUMIDITY_DRY_THRESHOLD - adc_value;
        return (uint8_t)((offset * 100) / range);
    }
}

/**
 * @brief Aplica filtro de promedio móvil a un sensor de humedad
 */
static uint16_t apply_moving_average_filter(SoilMoistureSensor_t* sensor, uint16_t new_value) {
    // Agregar nueva muestra al buffer circular
    sensor->filter_buffer[sensor->filter_index] = new_value;
    sensor->filter_index = (sensor->filter_index + 1) % FILTER_SAMPLES;

    // Calcular promedio
    uint32_t sum = 0;
    for (uint8_t i = 0; i < FILTER_SAMPLES; i++) {
        sum += sensor->filter_buffer[i];
    }

    return (uint16_t)(sum / FILTER_SAMPLES);
}

/**
 * @brief Lee sensor de humedad individual
 */
static void read_soil_moisture_sensor(uint8_t zone_index) {
    SoilMoistureSensor_t* sensor = &g_sensor_data.soil[zone_index];

    // Leer valor ADC crudo
    uint16_t adc_raw = adc_soilMoisture_ReadChannel(zone_index);

    // Verificar si sensor está desconectado (valor extremo)
    if (adc_raw == 0 || adc_raw >= 1020) {
        sensor->error_code = SENSOR_DISCONNECTED;
        sensor->humidity_percent = 255;  // Valor inválido
        return;
    }

    // Aplicar filtro de promedio móvil
    uint16_t filtered_value = apply_moving_average_filter(sensor, adc_raw);

    // Convertir a porcentaje
    sensor->raw_value = filtered_value;
    sensor->humidity_percent = adc_to_humidity_percent(filtered_value);
    sensor->error_code = SENSOR_OK;
}

/**
 * @brief Lee sensor DHT22 (temperatura y humedad ambiente)
 *
 * Implementación simplificada (en producción usar librería DHT)
 */
static void read_dht22_sensor(void) {
    // TODO: Implementar protocolo DHT22 (1-Wire)
    // Por ahora, valores simulados para testing
    g_sensor_data.dht22.temperature_c = 25.0f;
    g_sensor_data.dht22.humidity_percent = 60.0f;
    g_sensor_data.dht22.last_read_time = getSystemMilis();
    g_sensor_data.dht22.error_code = SENSOR_OK;
}

/**
 * @brief Lee sensor ultrasónico de nivel de agua (HC-SR04)
 */
static void read_water_level_sensor(void) {
    // Enviar pulso trigger (10 µs)
    gpio_waterTrigger_High();
    __delay_us(10);
    gpio_waterTrigger_Low();

    // Esperar echo HIGH
    uint16_t timeout = 1000;
    while (gpio_waterEcho_Read() == 0 && timeout-- > 0) {
        __delay_us(1);
    }

    if (timeout == 0) {
        g_sensor_data.water_level.error_code = SENSOR_DISCONNECTED;
        return;
    }

    // Medir duración del pulso echo
    uint32_t start_time = getSystemMicros();
    timeout = 30000;  // Timeout 30 ms (máximo rango ~5m)

    while (gpio_waterEcho_Read() == 1 && timeout-- > 0) {
        __delay_us(1);
    }

    uint32_t pulse_duration_us = getSystemMicros() - start_time;

    // Convertir a distancia (velocidad del sonido = 340 m/s)
    // Distancia (cm) = (tiempo_µs * 0.034) / 2
    uint16_t distance_cm = (uint16_t)((pulse_duration_us * 34) / 2000);

    // Validar rango
    if (distance_cm < WATER_LEVEL_MIN_CM || distance_cm > WATER_LEVEL_MAX_CM) {
        g_sensor_data.water_level.error_code = SENSOR_OUT_OF_RANGE;
        return;
    }

    // Calcular nivel en porcentaje (invertido: distancia menor = nivel mayor)
    uint16_t range = WATER_LEVEL_MAX_CM - WATER_LEVEL_MIN_CM;
    uint16_t offset = WATER_LEVEL_MAX_CM - distance_cm;
    uint8_t level_percent = (uint8_t)((offset * 100) / range);

    g_sensor_data.water_level.distance_cm = distance_cm;
    g_sensor_data.water_level.level_percent = level_percent;
    g_sensor_data.water_level.is_low = (distance_cm > 80);  // Alarma si distancia > 80 cm
    g_sensor_data.water_level.error_code = SENSOR_OK;
}

// ============================================================================
// FUNCIONES PÚBLICAS
// ============================================================================

void sensorHub_Init(void) {
    // Limpiar estructura de datos
    memset(&g_sensor_data, 0, sizeof(SensorHubData_t));

    // Inicializar buffers de filtro con valor neutro
    for (uint8_t i = 0; i < NUM_ZONES; i++) {
        for (uint8_t j = 0; j < FILTER_SAMPLES; j++) {
            g_sensor_data.soil[i].filter_buffer[j] = 512;  // Valor medio
        }
        g_sensor_data.soil[i].is_initialized = true;
    }

    // Configurar GPIO inicial
    gpio_waterTrigger_Low();
}

void sensorHub_Update(void) {
    // Leer 8 sensores de humedad de suelo
    for (uint8_t i = 0; i < NUM_ZONES; i++) {
        read_soil_moisture_sensor(i);
    }

    // Leer DHT22 (temperatura y humedad ambiente)
    read_dht22_sensor();

    // Leer sensor de lluvia (digital)
    g_sensor_data.is_raining = (gpio_rainSensor_Read() == 0);  // Activo bajo

    // Leer nivel de agua
    read_water_level_sensor();

    // Actualizar timestamp
    g_sensor_data.last_update_time = getSystemMilis();
}

const SensorHubData_t* sensorHub_GetData(void) {
    return &g_sensor_data;
}

uint8_t sensorHub_GetSoilMoisture(uint8_t zone_index) {
    if (zone_index >= NUM_ZONES) return 255;
    return g_sensor_data.soil[zone_index].humidity_percent;
}

bool sensorHub_NeedsWatering(uint8_t zone_index) {
    if (zone_index >= NUM_ZONES) return false;

    uint8_t humidity = g_sensor_data.soil[zone_index].humidity_percent;

    // Necesita riego si humedad < 30% (umbral configurable)
    return (humidity < 30) && (humidity != 255);  // 255 = error
}

float sensorHub_GetTemperature(void) {
    if (g_sensor_data.dht22.error_code != SENSOR_OK) {
        return -999.0f;
    }
    return g_sensor_data.dht22.temperature_c;
}

float sensorHub_GetAmbientHumidity(void) {
    if (g_sensor_data.dht22.error_code != SENSOR_OK) {
        return -1.0f;
    }
    return g_sensor_data.dht22.humidity_percent;
}

bool sensorHub_IsRaining(void) {
    return g_sensor_data.is_raining;
}

uint8_t sensorHub_GetWaterLevel(void) {
    if (g_sensor_data.water_level.error_code != SENSOR_OK) {
        return 255;
    }
    return g_sensor_data.water_level.level_percent;
}

bool sensorHub_HasWater(void) {
    return !g_sensor_data.water_level.is_low;
}

uint8_t sensorHub_GetErrorCode(uint8_t zone_index) {
    if (zone_index < NUM_ZONES) {
        return g_sensor_data.soil[zone_index].error_code;
    } else if (zone_index == 255) {
        // Diagnóstico global
        if (g_sensor_data.dht22.error_code != SENSOR_OK) return g_sensor_data.dht22.error_code;
        if (g_sensor_data.water_level.error_code != SENSOR_OK) return g_sensor_data.water_level.error_code;
        return SENSOR_OK;
    }
    return SENSOR_OUT_OF_RANGE;
}
```

---

## Implementación Módulo de Actuadores

### Module_ValveController

Este módulo controla:
- **8 válvulas solenoides** (una por zona)
- **1 bomba de agua** (compartida por todas las zonas)
- **Seguridad**: No abrir válvula sin bomba activa
- **Interlocking**: Solo una válvula abierta a la vez (opcional)
- **Protección contra sobrecalentamiento** de bomba

#### Archivo: `userFncFile.h`

```c
/**
 * @file userFncFile.h
 * @brief ValveController - Control de válvulas y bomba
 * @version 1.0.0
 */

#ifndef VALVECONTROLLER_H
#define VALVECONTROLLER_H

#include <stdint.h>
#include <stdbool.h>

// ============================================================================
// DEFINICIONES
// ============================================================================

#define NUM_VALVES                  8
#define PUMP_COOLDOWN_TIME_MS       60000  // 1 minuto entre ciclos
#define PUMP_MAX_RUN_TIME_MS        1800000 // 30 minutos máximo continuo

// Estados de válvula
typedef enum {
    VALVE_CLOSED,
    VALVE_OPENING,
    VALVE_OPEN,
    VALVE_CLOSING
} ValveState_t;

// Estados de bomba
typedef enum {
    PUMP_OFF,
    PUMP_STARTING,
    PUMP_RUNNING,
    PUMP_COOLDOWN,
    PUMP_ERROR
} PumpState_t;

// ============================================================================
// ESTRUCTURAS
// ============================================================================

/**
 * @brief Datos de una válvula individual
 */
typedef struct {
    ValveState_t state;           ///< Estado actual
    uint32_t     open_time_ms;    ///< Tiempo que lleva abierta (ms)
    uint32_t     total_time_ms;   ///< Tiempo total acumulado (para estadísticas)
    bool         is_enabled;      ///< ¿Válvula habilitada?
} ValveData_t;

/**
 * @brief Datos de la bomba
 */
typedef struct {
    PumpState_t  state;                ///< Estado actual
    uint32_t     run_time_ms;          ///< Tiempo de funcionamiento actual
    uint32_t     cooldown_remaining_ms; ///< Tiempo restante de cooldown
    uint32_t     total_run_time_ms;    ///< Tiempo total acumulado
    uint16_t     start_count;          ///< Número de arranques (para mantenimiento)
    bool         is_overheated;        ///< ¿Bomba sobrecalentada?
} PumpData_t;

/**
 * @brief Estado completo del sistema de actuadores
 */
typedef struct {
    ValveData_t valves[NUM_VALVES];
    PumpData_t  pump;
    uint8_t     active_valves_count;   ///< Número de válvulas actualmente abiertas
} ValveControllerData_t;

// ============================================================================
// FUNCIONES PÚBLICAS
// ============================================================================

/**
 * @brief Inicializa el módulo ValveController
 */
void valveController_Init(void);

/**
 * @brief Actualiza estados (debe llamarse cada 100 ms)
 */
void valveController_Update(void);

/**
 * @brief Abre una válvula específica
 *
 * @param valve_index Índice de válvula (0-7)
 * @return true si éxito, false si error (bomba sin agua, etc.)
 */
bool valveController_OpenValve(uint8_t valve_index);

/**
 * @brief Cierra una válvula específica
 *
 * @param valve_index Índice de válvula (0-7)
 */
void valveController_CloseValve(uint8_t valve_index);

/**
 * @brief Cierra todas las válvulas (emergencia)
 */
void valveController_CloseAllValves(void);

/**
 * @brief Enciende la bomba (solo si hay válvulas abiertas)
 *
 * @return true si éxito
 */
bool valveController_StartPump(void);

/**
 * @brief Apaga la bomba
 */
void valveController_StopPump(void);

/**
 * @brief Obtiene estado de una válvula
 */
ValveState_t valveController_GetValveState(uint8_t valve_index);

/**
 * @brief Obtiene estado de la bomba
 */
PumpState_t valveController_GetPumpState(void);

/**
 * @brief Verifica si sistema está listo para regar
 */
bool valveController_IsReady(void);

#endif // VALVECONTROLLER_H
```

#### Archivo: `userFncFile.c` (extracto)

```c
#include "userFncFile.h"

static ValveControllerData_t g_valve_data;

void valveController_Init(void) {
    // Asegurar que todo está apagado
    for (uint8_t i = 0; i < NUM_VALVES; i++) {
        gpio_valve_Off(i);  // Función generada por EMIC
        g_valve_data.valves[i].state = VALVE_CLOSED;
        g_valve_data.valves[i].is_enabled = true;
    }

    gpio_pump_Off();
    g_valve_data.pump.state = PUMP_OFF;
}

void valveController_Update(void) {
    // Actualizar tiempos de válvulas abiertas
    for (uint8_t i = 0; i < NUM_VALVES; i++) {
        if (g_valve_data.valves[i].state == VALVE_OPEN) {
            g_valve_data.valves[i].open_time_ms += 100;  // Llamado cada 100 ms
            g_valve_data.valves[i].total_time_ms += 100;
        }
    }

    // Actualizar bomba
    if (g_valve_data.pump.state == PUMP_RUNNING) {
        g_valve_data.pump.run_time_ms += 100;
        g_valve_data.pump.total_run_time_ms += 100;

        // Protección contra funcionamiento excesivo
        if (g_valve_data.pump.run_time_ms >= PUMP_MAX_RUN_TIME_MS) {
            valveController_StopPump();
            valveController_CloseAllValves();
            g_valve_data.pump.is_overheated = true;
        }
    } else if (g_valve_data.pump.state == PUMP_COOLDOWN) {
        if (g_valve_data.pump.cooldown_remaining_ms > 100) {
            g_valve_data.pump.cooldown_remaining_ms -= 100;
        } else {
            g_valve_data.pump.state = PUMP_OFF;
            g_valve_data.pump.cooldown_remaining_ms = 0;
        }
    }

    // Contar válvulas activas
    uint8_t active_count = 0;
    for (uint8_t i = 0; i < NUM_VALVES; i++) {
        if (g_valve_data.valves[i].state == VALVE_OPEN) {
            active_count++;
        }
    }
    g_valve_data.active_valves_count = active_count;

    // Si no hay válvulas abiertas, apagar bomba
    if (active_count == 0 && g_valve_data.pump.state == PUMP_RUNNING) {
        valveController_StopPump();
    }
}

bool valveController_OpenValve(uint8_t valve_index) {
    if (valve_index >= NUM_VALVES) return false;
    if (!g_valve_data.valves[valve_index].is_enabled) return false;

    // Verificar que bomba esté disponible
    if (g_valve_data.pump.is_overheated) return false;
    if (g_valve_data.pump.state == PUMP_COOLDOWN) return false;

    // Abrir válvula
    gpio_valve_On(valve_index);
    g_valve_data.valves[valve_index].state = VALVE_OPEN;
    g_valve_data.valves[valve_index].open_time_ms = 0;

    // Iniciar bomba automáticamente
    if (g_valve_data.pump.state == PUMP_OFF) {
        valveController_StartPump();
    }

    return true;
}

void valveController_CloseValve(uint8_t valve_index) {
    if (valve_index >= NUM_VALVES) return;

    gpio_valve_Off(valve_index);
    g_valve_data.valves[valve_index].state = VALVE_CLOSED;
}

void valveController_CloseAllValves(void) {
    for (uint8_t i = 0; i < NUM_VALVES; i++) {
        valveController_CloseValve(i);
    }
}

bool valveController_StartPump(void) {
    if (g_valve_data.pump.state == PUMP_COOLDOWN) return false;
    if (g_valve_data.pump.is_overheated) return false;

    gpio_pump_On();
    g_valve_data.pump.state = PUMP_RUNNING;
    g_valve_data.pump.run_time_ms = 0;
    g_valve_data.pump.start_count++;

    return true;
}

void valveController_StopPump(void) {
    gpio_pump_Off();
    g_valve_data.pump.state = PUMP_COOLDOWN;
    g_valve_data.pump.cooldown_remaining_ms = PUMP_COOLDOWN_TIME_MS;
}

bool valveController_IsReady(void) {
    return (g_valve_data.pump.state != PUMP_COOLDOWN) &&
           (!g_valve_data.pump.is_overheated);
}
```

---

## Algoritmo de Control Inteligente

### Module_SmartAlgorithm

Este módulo implementa la **lógica de decisión** del sistema de riego:

#### Reglas del Algoritmo

```
1. SI está lloviendo → NO REGAR
2. SI nivel de agua < mínimo → NO REGAR (alarma)
3. SI bomba en cooldown → ESPERAR
4. PARA cada zona:
   a. SI humedad > 70% → NO REGAR
   b. SI humedad < 30% → REGAR
   c. SI humedad entre 30-70%:
      - SI temperatura > 30°C → REGAR (prioridad)
      - SI humedad ambiente < 40% → REGAR (evaporación alta)
      - SINO → NO REGAR
```

#### Archivo: `userFncFile.h`

```c
/**
 * @file userFncFile.h
 * @brief SmartAlgorithm - Algoritmo de decisión de riego
 */

#ifndef SMARTALGORITHM_H
#define SMARTALGORITHM_H

#include <stdint.h>
#include <stdbool.h>

// ============================================================================
// DEFINICIONES
// ============================================================================

// Umbrales configurables
#define HUMIDITY_THRESHOLD_DRY       30    // < 30% → necesita riego urgente
#define HUMIDITY_THRESHOLD_WET       70    // > 70% → no necesita riego
#define TEMP_THRESHOLD_HOT           30    // > 30°C → priorizar riego
#define AMBIENT_HUMIDITY_THRESHOLD   40    // < 40% → evaporación alta

// Duración de riego por zona (segundos)
#define WATERING_DURATION_SHORT      300   // 5 minutos
#define WATERING_DURATION_MEDIUM     600   // 10 minutos
#define WATERING_DURATION_LONG       900   // 15 minutos

// ============================================================================
// ESTRUCTURAS
// ============================================================================

/**
 * @brief Recomendación de riego para una zona
 */
typedef struct {
    bool     should_water;           ///< ¿Debe regarse?
    uint16_t duration_seconds;       ///< Duración recomendada (s)
    uint8_t  priority;               ///< Prioridad (0-10, 10=máxima)
    char     reason[64];             ///< Razón de la decisión
} WateringDecision_t;

// ============================================================================
// FUNCIONES PÚBLICAS
// ============================================================================

/**
 * @brief Evalúa si una zona debe regarse
 *
 * @param zone_index Índice de zona (0-7)
 * @return Decisión de riego
 */
WateringDecision_t smartAlgorithm_EvaluateZone(uint8_t zone_index);

/**
 * @brief Calcula prioridades de riego para todas las zonas
 *
 * @param priorities Array de salida (debe tener tamaño NUM_ZONES)
 */
void smartAlgorithm_CalculatePriorities(uint8_t* priorities);

/**
 * @brief Verifica condiciones globales (lluvia, nivel de agua)
 *
 * @return true si es seguro regar
 */
bool smartAlgorithm_CanWaterNow(void);

#endif // SMARTALGORITHM_H
```

#### Archivo: `userFncFile.c`

```c
#include "userFncFile.h"
#include "sensorHub.h"  // Dependencia de Module_SensorHub
#include "valveController.h"
#include <string.h>
#include <stdio.h>

WateringDecision_t smartAlgorithm_EvaluateZone(uint8_t zone_index) {
    WateringDecision_t decision;
    decision.should_water = false;
    decision.duration_seconds = 0;
    decision.priority = 0;
    strcpy(decision.reason, "No evaluado");

    // Obtener datos de sensores
    uint8_t soil_moisture = sensorHub_GetSoilMoisture(zone_index);
    float   temperature = sensorHub_GetTemperature();
    float   ambient_humidity = sensorHub_GetAmbientHumidity();

    // Validar datos
    if (soil_moisture == 255) {
        strcpy(decision.reason, "Sensor de humedad con error");
        return decision;
    }

    // Regla 1: Humedad > 70% → NO REGAR
    if (soil_moisture >= HUMIDITY_THRESHOLD_WET) {
        sprintf(decision.reason, "Suelo humedo (%.0f%%)", (float)soil_moisture);
        return decision;
    }

    // Regla 2: Humedad < 30% → REGAR (urgente)
    if (soil_moisture < HUMIDITY_THRESHOLD_DRY) {
        decision.should_water = true;
        decision.duration_seconds = WATERING_DURATION_LONG;
        decision.priority = 10;  // Máxima prioridad
        sprintf(decision.reason, "Suelo seco (%.0f%%) - URGENTE", (float)soil_moisture);
        return decision;
    }

    // Regla 3: Humedad entre 30-70% → Evaluar condiciones ambientales

    // Si temperatura alta → REGAR (evaporación rápida)
    if (temperature > TEMP_THRESHOLD_HOT) {
        decision.should_water = true;
        decision.duration_seconds = WATERING_DURATION_MEDIUM;
        decision.priority = 7;
        sprintf(decision.reason, "Temp alta (%.1f C) + humedad %.0f%%",
                temperature, (float)soil_moisture);
        return decision;
    }

    // Si humedad ambiente baja → REGAR (evaporación alta)
    if (ambient_humidity < AMBIENT_HUMIDITY_THRESHOLD && ambient_humidity > 0) {
        decision.should_water = true;
        decision.duration_seconds = WATERING_DURATION_SHORT;
        decision.priority = 5;
        sprintf(decision.reason, "Evaporacion alta (RH=%.1f%%)", ambient_humidity);
        return decision;
    }

    // Condiciones normales → NO REGAR
    sprintf(decision.reason, "Condiciones normales (humedad=%.0f%%)", (float)soil_moisture);
    return decision;
}

void smartAlgorithm_CalculatePriorities(uint8_t* priorities) {
    for (uint8_t i = 0; i < NUM_ZONES; i++) {
        WateringDecision_t decision = smartAlgorithm_EvaluateZone(i);
        priorities[i] = decision.priority;
    }
}

bool smartAlgorithm_CanWaterNow(void) {
    // Verificar lluvia
    if (sensorHub_IsRaining()) {
        return false;  // No regar si está lloviendo
    }

    // Verificar nivel de agua
    if (!sensorHub_HasWater()) {
        return false;  // No regar sin agua
    }

    // Verificar estado de bomba
    if (!valveController_IsReady()) {
        return false;  // Bomba no lista (cooldown o error)
    }

    return true;  // Todas las condiciones OK
}
```

---

## Sistema de Scheduling

### Module_Scheduler

Sistema de horarios basado en **RTC (Real-Time Clock DS3231)**.

#### Funcionalidades

- Programar hasta **4 horarios diarios** por zona
- Días de la semana configurables (Lun-Dom)
- Duración configurable por horario
- Prioridad configurable
- Habilitar/deshabilitar horarios individualmente

#### Archivo: `userFncFile.h`

```c
/**
 * @file userFncFile.h
 * @brief Scheduler - Sistema de horarios RTC
 */

#ifndef SCHEDULER_H
#define SCHEDULER_H

#include <stdint.h>
#include <stdbool.h>

// ============================================================================
// DEFINICIONES
// ============================================================================

#define MAX_SCHEDULES_PER_ZONE   4
#define NUM_ZONES                8

// Días de la semana (bitmask)
#define SCHEDULE_MONDAY          (1 << 0)
#define SCHEDULE_TUESDAY         (1 << 1)
#define SCHEDULE_WEDNESDAY       (1 << 2)
#define SCHEDULE_THURSDAY        (1 << 3)
#define SCHEDULE_FRIDAY          (1 << 4)
#define SCHEDULE_SATURDAY        (1 << 5)
#define SCHEDULE_SUNDAY          (1 << 6)
#define SCHEDULE_WEEKDAYS        (SCHEDULE_MONDAY | SCHEDULE_TUESDAY | SCHEDULE_WEDNESDAY | SCHEDULE_THURSDAY | SCHEDULE_FRIDAY)
#define SCHEDULE_WEEKEND         (SCHEDULE_SATURDAY | SCHEDULE_SUNDAY)
#define SCHEDULE_EVERYDAY        (0x7F)

// ============================================================================
// ESTRUCTURAS
// ============================================================================

/**
 * @brief Horario programado individual
 */
typedef struct {
    uint8_t hour;              ///< Hora (0-23)
    uint8_t minute;            ///< Minuto (0-59)
    uint16_t duration_seconds; ///< Duración de riego (s)
    uint8_t days_of_week;      ///< Bitmask de días (SCHEDULE_MONDAY | ...)
    bool    is_enabled;        ///< ¿Horario habilitado?
    bool    is_active;         ///< ¿Riego actualmente activo?
} Schedule_t;

/**
 * @brief Fecha/hora actual (obtenida de RTC)
 */
typedef struct {
    uint16_t year;
    uint8_t  month;
    uint8_t  day;
    uint8_t  hour;
    uint8_t  minute;
    uint8_t  second;
    uint8_t  day_of_week;      ///< 0=Lun, 1=Mar, ..., 6=Dom
} DateTime_t;

// ============================================================================
// FUNCIONES PÚBLICAS
// ============================================================================

/**
 * @brief Inicializa módulo de scheduling (configura RTC)
 */
void scheduler_Init(void);

/**
 * @brief Actualiza scheduler (debe llamarse cada 1 segundo)
 */
void scheduler_Update(void);

/**
 * @brief Agrega un horario a una zona
 *
 * @param zone_index Índice de zona (0-7)
 * @param schedule_index Índice de horario (0-3)
 * @param hour Hora (0-23)
 * @param minute Minuto (0-59)
 * @param duration_seconds Duración en segundos
 * @param days_of_week Bitmask de días
 * @return true si éxito
 */
bool scheduler_AddSchedule(uint8_t zone_index, uint8_t schedule_index,
                           uint8_t hour, uint8_t minute,
                           uint16_t duration_seconds, uint8_t days_of_week);

/**
 * @brief Elimina un horario
 */
void scheduler_RemoveSchedule(uint8_t zone_index, uint8_t schedule_index);

/**
 * @brief Habilita/deshabilita un horario
 */
void scheduler_EnableSchedule(uint8_t zone_index, uint8_t schedule_index, bool enable);

/**
 * @brief Obtiene fecha/hora actual del RTC
 */
DateTime_t scheduler_GetCurrentTime(void);

/**
 * @brief Establece fecha/hora del RTC
 */
void scheduler_SetCurrentTime(const DateTime_t* datetime);

#endif // SCHEDULER_H
```

#### Implementación (extracto)

```c
#include "userFncFile.h"
#include "valveController.h"
#include "smartAlgorithm.h"

static Schedule_t g_schedules[NUM_ZONES][MAX_SCHEDULES_PER_ZONE];
static DateTime_t g_current_time;

void scheduler_Update(void) {
    // Leer RTC (via I2C)
    g_current_time = rtc_ReadDateTime();  // Función generada por EMIC

    // Verificar cada zona
    for (uint8_t zone = 0; zone < NUM_ZONES; zone++) {
        for (uint8_t i = 0; i < MAX_SCHEDULES_PER_ZONE; i++) {
            Schedule_t* schedule = &g_schedules[zone][i];

            if (!schedule->is_enabled) continue;

            // Verificar si es el día correcto
            uint8_t today_bit = (1 << g_current_time.day_of_week);
            if (!(schedule->days_of_week & today_bit)) continue;

            // Verificar si es la hora correcta
            if (g_current_time.hour == schedule->hour &&
                g_current_time.minute == schedule->minute &&
                g_current_time.second == 0) {  // Disparar solo en segundo 0

                // Verificar condiciones globales
                if (!smartAlgorithm_CanWaterNow()) continue;

                // Iniciar riego
                if (valveController_OpenValve(zone)) {
                    schedule->is_active = true;
                    // TODO: Programar temporizador para cerrar después de duration_seconds
                }
            }
        }
    }
}
```

---

## Interfaz de Usuario

### Module_UserInterface

Interfaz con **LCD 20x4** + **4 botones** (UP, DOWN, OK, BACK).

#### Pantallas del Menú

```
PANTALLA PRINCIPAL:
┌──────────────────────┐
│ EMIC SmartIrrigation │
│ Zona 1: 45%  [SECA]  │
│ Zona 2: 78%  [OK  ]  │
│ 12:30 | Temp: 25.5°C │
└──────────────────────┘

MENÚ PRINCIPAL:
1. Ver Estado Zonas
2. Riego Manual
3. Configurar Horarios
4. Estadísticas
5. Diagnósticos

RIEGO MANUAL:
┌──────────────────────┐
│ RIEGO MANUAL         │
│ Seleccione zona:     │
│ > Zona 1             │
│   Zona 2             │
└──────────────────────┘
```

#### Código (extracto)

```c
typedef enum {
    SCREEN_HOME,
    SCREEN_MENU,
    SCREEN_ZONE_STATUS,
    SCREEN_MANUAL_WATERING,
    SCREEN_SCHEDULE_CONFIG,
    SCREEN_STATISTICS,
    SCREEN_DIAGNOSTICS
} UIScreen_t;

static UIScreen_t g_current_screen = SCREEN_HOME;

void ui_Update(void) {
    // Leer botones
    if (button_Up_IsPressed()) {
        // Navegar hacia arriba en menú
    } else if (button_Down_IsPressed()) {
        // Navegar hacia abajo
    } else if (button_Ok_IsPressed()) {
        // Confirmar selección
    } else if (button_Back_IsPressed()) {
        // Volver atrás
    }

    // Renderizar pantalla actual
    switch (g_current_screen) {
        case SCREEN_HOME:
            render_home_screen();
            break;
        case SCREEN_MENU:
            render_menu_screen();
            break;
        // ... otras pantallas
    }
}

void render_home_screen(void) {
    lcd_Clear();
    lcd_SetCursor(0, 0);
    lcd_Print("EMIC SmartIrrigation");

    // Mostrar 2 zonas prioritarias
    uint8_t priorities[NUM_ZONES];
    smartAlgorithm_CalculatePriorities(priorities);

    // Encontrar 2 zonas con mayor prioridad
    uint8_t zone1 = 0, zone2 = 1;
    // ... lógica de ordenamiento

    lcd_SetCursor(0, 1);
    lcd_Printf("Zona %d: %d%%  [%s]", zone1+1,
               sensorHub_GetSoilMoisture(zone1),
               priorities[zone1] > 7 ? "SECA" : "OK");

    lcd_SetCursor(0, 2);
    lcd_Printf("Zona %d: %d%%  [%s]", zone2+1,
               sensorHub_GetSoilMoisture(zone2),
               priorities[zone2] > 7 ? "SECA" : "OK");

    lcd_SetCursor(0, 3);
    DateTime_t time = scheduler_GetCurrentTime();
    lcd_Printf("%02d:%02d | Temp: %.1fC", time.hour, time.minute,
               sensorHub_GetTemperature());
}
```

---

## Comunicaciones IoT

### Module_WiFiComm

Comunicación con **app móvil** via **ESP8266** (WiFi).

#### API REST (JSON)

```
GET /api/status
→ Devuelve estado completo del sistema

POST /api/water/{zone}
→ Inicia riego manual de una zona

POST /api/schedule
→ Agrega/modifica horario

GET /api/telemetry
→ Obtiene datos históricos
```

#### Ejemplo de respuesta JSON

```json
{
  "timestamp": "2025-11-05T14:30:00Z",
  "zones": [
    {
      "id": 0,
      "name": "Zona 1",
      "soil_moisture_percent": 45,
      "status": "needs_watering",
      "valve_open": false
    },
    ...
  ],
  "environment": {
    "temperature_c": 25.5,
    "humidity_percent": 60.0,
    "is_raining": false
  },
  "water_tank": {
    "level_percent": 85,
    "is_low": false
  },
  "pump": {
    "status": "off",
    "total_runtime_hours": 123.5
  }
}
```

---

## Manejo de Errores y Diagnósticos

### Tipos de Errores

| Código | Nombre | Descripción | Acción |
|--------|--------|-------------|--------|
| E001 | SENSOR_DISCONNECTED | Sensor de humedad desconectado | Notificar + deshabilitar zona |
| E002 | PUMP_OVERHEAT | Bomba sobrecalentada | Detener todo + cooldown forzado |
| E003 | WATER_LEVEL_LOW | Nivel de agua bajo | Notificar + detener riegos |
| E004 | VALVE_STUCK | Válvula no responde | Notificar + bypass zona |
| E005 | RTC_FAIL | RTC sin batería | Solicitar configurar hora |
| E006 | WIFI_DISCONNECTED | WiFi sin conexión | Continuar en modo offline |

### Implementación

```c
typedef struct {
    uint16_t code;
    char     description[64];
    uint32_t timestamp;
    bool     is_critical;
} Error_t;

#define MAX_ERRORS 20
static Error_t g_error_log[MAX_ERRORS];
static uint8_t g_error_count = 0;

void diagnostics_LogError(uint16_t code, const char* desc, bool critical) {
    if (g_error_count >= MAX_ERRORS) {
        // Eliminar error más antiguo (FIFO)
        for (uint8_t i = 0; i < MAX_ERRORS-1; i++) {
            g_error_log[i] = g_error_log[i+1];
        }
        g_error_count--;
    }

    Error_t* err = &g_error_log[g_error_count++];
    err->code = code;
    strncpy(err->description, desc, 63);
    err->timestamp = getSystemMilis();
    err->is_critical = critical;

    // Si es crítico, activar buzzer
    if (critical) {
        buzzer_Beep(3, 200);  // 3 beeps de 200 ms
    }
}
```

---

## Ahorro de Energía

### Estrategias

1. **Sleep Mode**: MCU en modo Idle cuando no hay tareas
2. **Wake-up por RTC**: Para riegos programados
3. **Wake-up por botón**: Para acceso manual
4. **LCD Auto-off**: Apagar backlight después de 30s
5. **ADC selectivo**: Leer sensores solo cuando es necesario

### Implementación

```c
void powerManagement_EnterSleep(void) {
    // Apagar LCD backlight
    lcd_BacklightOff();

    // Apagar LEDs
    led_Off();

    // Configurar wake-up sources
    rtc_EnableAlarm(true);          // Wake-up por RTC
    button_EnableInterrupt(true);   // Wake-up por botón

    // Entrar en modo IDLE (PIC24)
    __asm__ volatile ("pwrsav #1");  // IDLE mode

    // Al despertar:
    lcd_BacklightOn();
}
```

---

## Logging y Telemetría

### Datos Registrados

1. **Eventos de riego**:
   - Timestamp, zona, duración, litros consumidos
2. **Lecturas de sensores**:
   - Cada hora: humedad de todas las zonas, temp, nivel de agua
3. **Estadísticas**:
   - Total de litros por día/semana/mes
   - Eficiencia de riego
   - Número de riegos automáticos vs manuales

### Implementación (extracto)

```c
typedef struct {
    uint32_t timestamp;
    uint8_t  zone;
    uint16_t duration_seconds;
    uint16_t water_liters;
    uint8_t  trigger_type;  // 0=auto, 1=manual, 2=scheduled
} IrrigationEvent_t;

#define MAX_EVENTS 100
static IrrigationEvent_t g_event_log[MAX_EVENTS];
static uint8_t g_event_index = 0;

void telemetry_LogIrrigationEvent(uint8_t zone, uint16_t duration_s,
                                   uint16_t liters, uint8_t trigger) {
    IrrigationEvent_t* event = &g_event_log[g_event_index];
    event->timestamp = rtc_GetTimestamp();
    event->zone = zone;
    event->duration_seconds = duration_s;
    event->water_liters = liters;
    event->trigger_type = trigger;

    g_event_index = (g_event_index + 1) % MAX_EVENTS;  // Circular buffer
}

uint32_t telemetry_GetTotalWaterUsage(uint8_t days) {
    uint32_t total_liters = 0;
    uint32_t cutoff_time = rtc_GetTimestamp() - (days * 86400);

    for (uint8_t i = 0; i < MAX_EVENTS; i++) {
        if (g_event_log[i].timestamp >= cutoff_time) {
            total_liters += g_event_log[i].water_liters;
        }
    }

    return total_liters;
}
```

---

## Testing y Calibración

### Procedimiento de Testing

#### Test 1: Calibración de Sensores de Humedad

```
1. Sumergir sensor en agua destilada → Leer valor ADC (debería ser ~300)
2. Secar completamente sensor → Leer valor ADC (debería ser ~800)
3. Ajustar constantes HUMIDITY_WET_THRESHOLD y HUMIDITY_DRY_THRESHOLD
```

#### Test 2: Prueba de Válvulas

```
1. Abrir cada válvula individualmente (sin agua)
2. Verificar que LED/relay activa correctamente
3. Medir corriente de válvula (debe ser <0.5A)
```

#### Test 3: Prueba de Bomba

```
1. Conectar bomba a fuente de alimentación separada
2. Activar bomba vía sistema
3. Verificar que se apaga automáticamente después de cooldown
```

#### Test 4: Prueba de Algoritmo

```
Caso de Test: Suelo Seco + Temperatura Alta
  - Configurar sensor humedad zona 1: 25% (seco)
  - Configurar temperatura: 32°C
  - Ejecutar smartAlgorithm_EvaluateZone(0)
  - Resultado esperado: should_water=true, priority=10
```

### Calibración de Caudal

Si se usa sensor de flujo (YF-S201):

```c
// Factor de calibración: pulsos por litro
#define FLOW_SENSOR_PULSES_PER_LITER  450

uint16_t calculate_water_volume(uint32_t pulse_count) {
    return (uint16_t)(pulse_count / FLOW_SENSOR_PULSES_PER_LITER);
}
```

---

## Código Completo

### Proyecto Principal: `generate.emic`

```emic
// ============================================================================
// SmartIrrigationSystem - Proyecto EMIC Completo
// ============================================================================

EMIC:setOutput(TARGET:generate.txt)

    // ========== CONFIGURACIÓN BASE ==========
    EMIC:setInput(DEV:_pcb/pcb.emic,pcb=HRD_Development_Board)
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    // ========== MÓDULOS EMIC ==========
    EMIC:setInput(SYS:Module_SensorHub/generate.emic)
    EMIC:setInput(SYS:Module_ValveController/generate.emic)
    EMIC:setInput(SYS:Module_SmartAlgorithm/generate.emic)
    EMIC:setInput(SYS:Module_Scheduler/generate.emic)
    EMIC:setInput(SYS:Module_UserInterface/generate.emic)
    EMIC:setInput(SYS:Module_WiFiComm/generate.emic)
    EMIC:setInput(SYS:Module_Telemetry/generate.emic)
    EMIC:setInput(SYS:Module_PowerManagement/generate.emic)

    // ========== LÓGICA PRINCIPAL ==========
    EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
    EMIC:define(c_modules.userFncFile,userFncFile)

    // ========== TEMPLATE MPLAB X ==========
    EMIC:copy(DEV:_templates/projects/mplabx > TARGET:)

EMIC:restoreOutput
```

### Archivo Principal: `userFncFile.c`

```c
/**
 * @file userFncFile.c
 * @brief Smart Irrigation System - Lógica principal de integración
 * @version 1.0.0
 */

#include "userFncFile.h"
#include "sensorHub.h"
#include "valveController.h"
#include "smartAlgorithm.h"
#include "scheduler.h"
#include "ui.h"
#include "telemetry.h"
#include "powerManagement.h"

// ============================================================================
// VARIABLES GLOBALES
// ============================================================================

static uint32_t g_last_sensor_update = 0;
static uint32_t g_last_ui_update = 0;
static uint32_t g_last_valve_update = 0;
static uint32_t g_last_scheduler_check = 0;

// Configuración de tiempos de actualización
#define SENSOR_UPDATE_INTERVAL_MS      1000   // 1 segundo
#define UI_UPDATE_INTERVAL_MS          100    // 100 ms
#define VALVE_UPDATE_INTERVAL_MS       100    // 100 ms
#define SCHEDULER_CHECK_INTERVAL_MS    1000   // 1 segundo

// ============================================================================
// FUNCIÓN PRINCIPAL
// ============================================================================

/**
 * @brief Inicialización del sistema
 *
 * Llamada automáticamente por EMIC-Generate al inicio
 */
void userInit(void) {
    // Inicializar todos los módulos
    sensorHub_Init();
    valveController_Init();
    scheduler_Init();
    ui_Init();
    telemetry_Init();
    powerManagement_Init();

    // Mensaje de bienvenida en LCD
    lcd_Clear();
    lcd_SetCursor(0, 0);
    lcd_Print("EMIC SmartIrrigation");
    lcd_SetCursor(0, 1);
    lcd_Print("   Iniciando...    ");
    __delay_ms(2000);

    // Leer configuración de EEPROM (si existe)
    config_LoadFromEEPROM();

    // Primera lectura de sensores
    sensorHub_Update();
}

/**
 * @brief Loop principal del sistema
 *
 * Llamada automáticamente por EMIC-Generate en bucle infinito
 */
void userLoop(void) {
    uint32_t current_time = getSystemMilis();

    // ========== ACTUALIZACIÓN DE SENSORES (cada 1 segundo) ==========
    if ((current_time - g_last_sensor_update) >= SENSOR_UPDATE_INTERVAL_MS) {
        sensorHub_Update();
        g_last_sensor_update = current_time;
    }

    // ========== SCHEDULER (cada 1 segundo) ==========
    if ((current_time - g_last_scheduler_check) >= SCHEDULER_CHECK_INTERVAL_MS) {
        scheduler_Update();
        g_last_scheduler_check = current_time;
    }

    // ========== CONTROL DE VÁLVULAS (cada 100 ms) ==========
    if ((current_time - g_last_valve_update) >= VALVE_UPDATE_INTERVAL_MS) {
        valveController_Update();
        g_last_valve_update = current_time;
    }

    // ========== INTERFAZ DE USUARIO (cada 100 ms) ==========
    if ((current_time - g_last_ui_update) >= UI_UPDATE_INTERVAL_MS) {
        ui_Update();
        g_last_ui_update = current_time;
    }

    // ========== MANEJO DE ERRORES CRÍTICOS ==========
    if (!sensorHub_HasWater()) {
        // Nivel de agua bajo → detener todo
        valveController_CloseAllValves();
        ui_ShowAlert("ALARMA: Nivel agua bajo!");
    }

    if (sensorHub_IsRaining()) {
        // Lluvia detectada → cerrar válvulas abiertas
        valveController_CloseAllValves();
    }

    // ========== MODO AHORRO DE ENERGÍA ==========
    if (powerManagement_ShouldSleep()) {
        // Entrar en modo sleep (wake-up por RTC o botón)
        powerManagement_EnterSleep();
    }
}

/**
 * @brief Evento de timer (cada 100 ms)
 *
 * Usado para actualizaciones críticas de tiempo
 */
void EMIC:onTimer100ms(void) {
    // Actualizar contadores de tiempo de riego
    telemetry_UpdateCounters();
}
```

---

## Resumen

### Aprendizajes Clave

1. **Arquitectura Modular**: 8 módulos independientes que se comunican via APIs definidas
2. **Algoritmo Inteligente**: Decisiones basadas en múltiples sensores y condiciones ambientales
3. **Scheduling Avanzado**: Sistema de horarios flexible con RTC
4. **Interfaz Profesional**: LCD + botones + app móvil
5. **Robustez**: Manejo completo de errores y diagnósticos
6. **Eficiencia Energética**: Modos de ahorro de energía para operación autónoma
7. **Telemetría**: Registro de eventos y estadísticas

### Métricas del Proyecto

| Métrica | Valor |
|---------|-------|
| **Líneas de código** | ~2500 (C) + ~200 (EMIC) |
| **Módulos EMIC** | 8 |
| **APIs usadas** | 15+ |
| **Sensores** | 11 |
| **Actuadores** | 9 |
| **Pantallas UI** | 7 |
| **Complejidad** | Alta (sistema real IoT completo) |

### Próximos Pasos

- **Capítulo 28**: Monitor de Energía IoT
- **Capítulo 29**: Control de Acceso con RFID
- **Capítulo 30**: Gateway Industrial Modbus

---

**¡Felicidades!** Has completado un **sistema IoT profesional completo** usando EMIC SDK.

Este proyecto es un **ejemplo real** de cómo EMIC permite crear soluciones complejas de manera estructurada, reutilizable y mantenible.

---

**[⬆ Volver al índice](#contenido)**
