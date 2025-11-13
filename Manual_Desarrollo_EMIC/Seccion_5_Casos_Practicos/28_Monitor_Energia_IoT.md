# Capítulo 28: Monitor de Energía IoT

## 📋 Contenido
1. [Introducción](#introducción)
2. [Descripción del Proyecto](#descripción-del-proyecto)
3. [Hardware Necesario](#hardware-necesario)
4. [Arquitectura del Sistema](#arquitectura-del-sistema)
5. [Medición de Parámetros Eléctricos](#medición-de-parámetros-eléctricos)
6. [Módulo de Adquisición de Datos](#módulo-de-adquisición-de-datos)
7. [Módulo de Procesamiento](#módulo-de-procesamiento)
8. [Comunicaciones IoT](#comunicaciones-iot)
9. [Dashboard Web](#dashboard-web)
10. [Almacenamiento de Datos](#almacenamiento-de-datos)
11. [Sistema de Alertas](#sistema-de-alertas)
12. [Integración Cloud](#integración-cloud)
13. [Calibración y Testing](#calibración-y-testing)
14. [Código Completo](#código-completo)
15. [Caso de Uso Real](#caso-de-uso-real)
16. [Resumen](#resumen)

---

## Introducción

Este capítulo presenta un **Monitor de Energía Eléctrica IoT** profesional para aplicaciones residenciales e industriales. El sistema permite **monitorear en tiempo real** el consumo de energía, detectar anomalías y optimizar el uso de electricidad.

### ¿Qué aprenderás?

- Medir **parámetros eléctricos** (voltaje, corriente, potencia, factor de potencia)
- Implementar **algoritmos de cálculo RMS** para señales AC
- Crear **dashboards web** interactivos con gráficos en tiempo real
- Integrar con **plataformas cloud** (AWS IoT, Azure IoT Hub, ThingSpeak)
- Almacenar **datos históricos** en SD Card y bases de datos
- Implementar **sistema de alertas** inteligente
- Desarrollar **APIs REST** para integración con apps móviles

### Características del Sistema

| Característica | Descripción |
|----------------|-------------|
| **Mediciones** | Voltaje RMS, corriente RMS, potencia (activa/reactiva/aparente), factor de potencia, frecuencia, energía acumulada (kWh) |
| **Canales** | Hasta 4 canales independientes (monitoreo multi-circuito) |
| **Precisión** | ±1% en voltaje, ±2% en corriente, ±3% en potencia |
| **Frecuencia de muestreo** | 2 kHz por canal (100 muestras por ciclo a 50/60 Hz) |
| **Comunicación** | WiFi (dashboard local) + MQTT (cloud) + HTTP REST API |
| **Dashboard** | Web responsive con gráficos en tiempo real (Chart.js) |
| **Almacenamiento** | SD Card (CSV) + cloud database (InfluxDB/Firebase) |
| **Alertas** | Email, SMS, push notification, buzzer local |
| **Autonomía** | Backup con batería (continuar logging durante cortes) |

---

## Descripción del Proyecto

### Requisitos Funcionales

#### RF-01: Medición de Parámetros Eléctricos
- **Voltaje RMS**: 0-300V AC con precisión ±1%
- **Corriente RMS**: 0-30A AC con precisión ±2%
- **Potencia activa**: Cálculo P = V × I × cos(φ)
- **Potencia reactiva**: Cálculo Q = V × I × sin(φ)
- **Potencia aparente**: Cálculo S = V × I
- **Factor de potencia**: cos(φ) = P / S
- **Frecuencia**: Detección 50/60 Hz con precisión ±0.1 Hz
- **Energía acumulada**: kWh con resolución 0.001 kWh

#### RF-02: Adquisición de Datos Multi-Canal
- Soporte para **4 canales independientes**
- Muestreo simultáneo a **2 kHz por canal**
- **Filtrado digital** (promedio móvil + paso bajo)
- **Calibración por software** (offset, ganancia)
- **Detección de fase** para cálculo de factor de potencia

#### RF-03: Dashboard Web
- **Visualización en tiempo real** (actualización cada 1 segundo)
- **Gráficos históricos** (última hora, día, semana, mes)
- Gráficos de:
  - Voltaje, corriente, potencia (líneas)
  - Consumo energético (barras)
  - Factor de potencia (gauge)
  - Costo estimado (calculado)
- **Responsive design** (PC, tablet, móvil)
- **Multi-usuario** con autenticación

#### RF-04: Almacenamiento de Datos
- **Local (SD Card)**:
  - Archivo CSV con timestamp
  - Rotación automática diaria
  - Compresión de archivos antiguos
- **Cloud**:
  - Envío vía MQTT a broker cloud
  - Base de datos time-series (InfluxDB)
  - Retención configurable (90 días por defecto)

#### RF-05: Sistema de Alertas
Detectar y notificar:
- **Sobretensión**: V > 250V (configurable)
- **Subtensión**: V < 190V (configurable)
- **Sobrecarga**: I > 25A (configurable)
- **Consumo excesivo**: kWh/día > umbral
- **Factor de potencia bajo**: cos(φ) < 0.85
- **Fallo de comunicación**: Pérdida de conectividad > 5 min

#### RF-06: Integración Cloud
- **Protocolo MQTT** con TLS/SSL
- **Topics estructurados**:
  ```
  emic/energy/{device_id}/voltage
  emic/energy/{device_id}/current
  emic/energy/{device_id}/power
  emic/energy/{device_id}/energy
  ```
- **AWS IoT Core** / **Azure IoT Hub** / **ThingSpeak**
- **HTTP REST API** para consultas

### Requisitos No Funcionales

| Requisito | Especificación |
|-----------|----------------|
| **RNF-01: Tiempo real** | Latencia < 500 ms entre medición y visualización |
| **RNF-02: Disponibilidad** | Uptime > 99.5% (máximo 3.6 horas downtime/mes) |
| **RNF-03: Seguridad** | Comunicaciones cifradas (TLS), autenticación OAuth |
| **RNF-04: Escalabilidad** | Soporte hasta 100 dispositivos en un dashboard |
| **RNF-05: Eficiencia** | Consumo del monitor < 2W |
| **RNF-06: Confiabilidad** | MTBF > 10,000 horas |

---

## Hardware Necesario

### Microcontrolador

**dsPIC33EP256MC506** (recomendado para cálculos DSP)
- **Core**: 16-bit, 70 MIPS con DSP engine
- **Memoria**: 256 KB Flash, 32 KB RAM
- **ADC**: 12-bit, 10 MSPS, 16 canales (clave para muestreo rápido)
- **DMA**: 8 canales (transferencia ADC sin CPU)
- **Periféricos**:
  - 2x UART (ESP32 + debug)
  - 1x SPI (SD Card)
  - 1x I2C (RTC, EEPROM)
  - PWM, Timers

**Alternativa**: **PIC32MZ** (32-bit, más potencia para FFT)

### Sensores de Energía

#### Sensor de Voltaje
**ZMPT101B** (transformador de voltaje AC)
- Rango: 0-250V AC
- Salida: 0-5V DC (proporcional a voltaje de entrada)
- Precisión: ±1%
- Aislamiento galvánico: Sí
- Conexión: ADC del MCU

**Alternativa**: Divisor resistivo con optoacoplador (para prototipado)

#### Sensor de Corriente
**ACS712-30A** (sensor Hall efecto)
- Rango: -30A a +30A
- Salida: 2.5V ±66 mV/A
- Precisión: ±1.5%
- Aislamiento galvánico: Sí
- Ancho de banda: 80 kHz

**Alternativa avanzada**: **INA219** (sensor I2C, mayor precisión)

### Módulo de Comunicación

**ESP32-WROOM-32** (WiFi + Bluetooth)
- **WiFi**: 802.11 b/g/n
- **Comunicación con MCU**: UART (115200 baud)
- **Funcionalidad**:
  - Web server para dashboard
  - Cliente MQTT para cloud
  - OTA updates
- **Consumo**: ~160 mA activo, ~20 µA deep sleep

### Almacenamiento

**Módulo SD Card** (SPI)
- **Capacidad**: 8-32 GB
- **Formato**: FAT32
- **Velocidad**: Clase 10 (mínimo)

### Otros Componentes

| Componente | Especificación |
|------------|----------------|
| **RTC** | DS3231 (I2C) con batería backup |
| **Display** | LCD 20x4 I2C (opcional, para visualización local) |
| **LEDs** | RGB para indicadores de estado |
| **Buzzer** | Piezo 5V para alertas locales |
| **Botones** | 3 botones (Menu, Up, Down) |
| **Relé** | 1 canal 10A (desconexión automática de carga en emergencia) |
| **Fuente** | 5V 2A (aislada de la red eléctrica medida) |

---

## Arquitectura del Sistema

### Diagrama de Bloques

```
┌─────────────────────────────────────────────────────────────┐
│                    RED ELÉCTRICA AC                         │
│                    (110-240V, 50/60Hz)                      │
└──────────────┬──────────────────────┬───────────────────────┘
               │                      │
         ┌─────▼─────┐         ┌─────▼─────┐
         │  ZMPT101B │         │  ACS712   │
         │  (Voltaje)│         │(Corriente)│
         └─────┬─────┘         └─────┬─────┘
               │                     │
               │ ADC (2kHz)          │ ADC (2kHz)
               │                     │
         ┌─────▼─────────────────────▼─────┐
         │     dsPIC33EP256MC506           │
         │  - Muestreo ADC con DMA         │
         │  - Cálculo RMS                  │
         │  - Cálculo potencia             │
         │  - Detección fase               │
         └──────────┬──────────────────────┘
                    │ UART
         ┌──────────▼──────────┐
         │      ESP32          │
         │  - Web Server       │
         │  - MQTT Client      │
         │  - HTTP REST API    │
         └──┬─────────┬────────┘
            │         │
     ┌──────▼───┐   ┌─▼────────────┐
     │ Dashboard│   │ MQTT Broker  │
     │   Web    │   │   (Cloud)    │
     └──────────┘   └──┬───────────┘
                       │
                 ┌─────▼──────┐
                 │  InfluxDB  │
                 │  (Time DB) │
                 └────────────┘
```

### Diagrama de Capas

```
┌─────────────────────────────────────────────────────────┐
│          CAPA DE PRESENTACIÓN                           │
│  - Dashboard Web (HTML5 + JS + Chart.js)               │
│  - Mobile App (React Native)                           │
│  - LCD local                                            │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│          CAPA DE APLICACIÓN                             │
│  - Energy Monitor Manager                               │
│  - Alert System                                         │
│  - Data Logger                                          │
│  - Cost Calculator                                      │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│          CAPA DE LÓGICA DE NEGOCIO                      │
│  - RMS Calculator                                       │
│  - Power Factor Calculator                              │
│  - Energy Accumulator                                   │
│  - Anomaly Detector                                     │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│          CAPA DE COMUNICACIONES                         │
│  - MQTT Handler                                         │
│  - HTTP REST API                                        │
│  - WebSocket Server                                     │
│  - SD Card Logger                                       │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│          CAPA DE ADQUISICIÓN                            │
│  - ADC Sampler (DMA-based)                             │
│  - Digital Filter                                       │
│  - Calibration Engine                                   │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│          HARDWARE                                       │
│  - Voltage Sensor (ZMPT101B)                           │
│  - Current Sensor (ACS712)                             │
│  - dsPIC33 + ESP32 + SD + RTC                          │
└─────────────────────────────────────────────────────────┘
```

### Módulos EMIC

```
EnergyMonitor_Project/
├── Module_DataAcquisition/        # Muestreo ADC con DMA
├── Module_SignalProcessing/       # Cálculos RMS, FFT
├── Module_PowerCalculator/        # Potencia, factor potencia
├── Module_EnergyAccumulator/      # kWh acumulado
├── Module_WiFiComm/               # ESP32 communication
├── Module_WebServer/              # Dashboard HTTP
├── Module_MQTTClient/             # Cloud MQTT
├── Module_DataLogger/             # SD Card logging
├── Module_AlertSystem/            # Detección anomalías
└── Module_Display/                # LCD local (opcional)
```

---

## Medición de Parámetros Eléctricos

### Fundamentos Teóricos

#### Voltaje y Corriente RMS

Para una señal AC periódica, el valor **RMS (Root Mean Square)** es:

```
V_rms = sqrt( (1/N) * Σ(v[i]²) )
I_rms = sqrt( (1/N) * Σ(i[i]²) )
```

Donde:
- `N` = número de muestras por ciclo (ej: 100 muestras a 50 Hz con fs=5 kHz)
- `v[i]`, `i[i]` = muestras instantáneas de voltaje y corriente

#### Potencia Activa

```
P = (1/N) * Σ(v[i] * i[i])    [Watts]
```

#### Potencia Aparente

```
S = V_rms * I_rms              [VA]
```

#### Potencia Reactiva

```
Q = sqrt(S² - P²)              [VAR]
```

#### Factor de Potencia

```
cos(φ) = P / S
```

#### Energía Acumulada

```
E(t) = ∫ P(t) dt               [Wh]
```

Aproximación discreta:
```
E += P * Δt                    (Δt en horas)
```

### Desafíos de Implementación

| Desafío | Solución |
|---------|----------|
| **Frecuencia de muestreo** | Usar ADC con DMA para muestreo a 2 kHz sin carga CPU |
| **Sincronización V-I** | Muestrear voltaje y corriente simultáneamente (2 canales ADC) |
| **Ruido en mediciones** | Filtro digital paso bajo + promedio de múltiples ciclos |
| **Offset DC** | Calibración automática de offset (medir valor medio cuando I=0) |
| **No linealidad de sensores** | Tabla de lookup o polinomio de corrección |
| **Detección de cruce por cero** | Para sincronizar ventana de muestreo con fase de AC |

---

## Módulo de Adquisición de Datos

### Module_DataAcquisition

#### Archivo: `config.json`

```json
{
  "module_name": "DataAcquisition",
  "description": "Adquisicion de datos ADC con DMA para sensores de energia",
  "version": "1.0.0",
  "parameters": {
    "voltage_channel": {
      "type": "adc_channel",
      "value": "AN0",
      "description": "Canal ADC para sensor de voltaje (ZMPT101B)"
    },
    "current_channel": {
      "type": "adc_channel",
      "value": "AN1",
      "description": "Canal ADC para sensor de corriente (ACS712)"
    },
    "sampling_frequency": {
      "type": "integer",
      "value": 2000,
      "description": "Frecuencia de muestreo en Hz (2 kHz recomendado)"
    },
    "samples_per_cycle": {
      "type": "integer",
      "value": 100,
      "description": "Muestras por ciclo AC (100 para 50Hz, 120 para 60Hz)"
    },
    "voltage_calibration_gain": {
      "type": "float",
      "value": 0.2354,
      "description": "Ganancia de calibracion para voltaje (V/LSB)"
    },
    "voltage_calibration_offset": {
      "type": "integer",
      "value": 2048,
      "description": "Offset de calibracion (ADC midpoint a 0V)"
    },
    "current_calibration_gain": {
      "type": "float",
      "value": 0.0293,
      "description": "Ganancia de calibracion para corriente (A/LSB)"
    },
    "current_calibration_offset": {
      "type": "integer",
      "value": 2048,
      "description": "Offset de calibracion (ADC midpoint a 0A)"
    }
  }
}
```

#### Archivo: `userFncFile.h`

```c
/**
 * @file userFncFile.h
 * @brief DataAcquisition - Sistema de muestreo ADC con DMA
 * @version 1.0.0
 */

#ifndef DATAACQUISITION_H
#define DATAACQUISITION_H

#include <stdint.h>
#include <stdbool.h>

// ============================================================================
// DEFINICIONES
// ============================================================================

#define SAMPLING_FREQ_HZ         2000    // 2 kHz
#define SAMPLES_PER_CYCLE        100     // Para 50 Hz (100 samples/cycle)
#define NUM_CHANNELS             2       // Voltaje + Corriente
#define BUFFER_SIZE              (SAMPLES_PER_CYCLE * 2)  // Double buffer

#define ADC_RESOLUTION           4096    // 12-bit ADC
#define ADC_VREF                 3.3     // Voltaje de referencia ADC (V)

// Calibración (valores por defecto, ajustar según hardware)
#define VOLTAGE_GAIN             0.2354  // V/LSB (220V peak → ~2048 LSB)
#define VOLTAGE_OFFSET           2048    // ADC midpoint
#define CURRENT_GAIN             0.0293  // A/LSB (30A → ~2048 LSB)
#define CURRENT_OFFSET           2048    // ADC midpoint

// ============================================================================
// ESTRUCTURAS
// ============================================================================

/**
 * @brief Buffer de muestras ADC
 */
typedef struct {
    uint16_t voltage[BUFFER_SIZE];     ///< Muestras de voltaje (raw ADC)
    uint16_t current[BUFFER_SIZE];     ///< Muestras de corriente (raw ADC)
    uint16_t sample_count;             ///< Número de muestras válidas
    uint32_t timestamp;                ///< Timestamp de captura (ms)
    bool     is_ready;                 ///< ¿Buffer listo para procesar?
} ADC_Buffer_t;

/**
 * @brief Parámetros de calibración
 */
typedef struct {
    float    voltage_gain;             ///< Ganancia voltaje (V/LSB)
    int16_t  voltage_offset;           ///< Offset voltaje (LSB)
    float    current_gain;             ///< Ganancia corriente (A/LSB)
    int16_t  current_offset;           ///< Offset corriente (LSB)
} Calibration_t;

// ============================================================================
// FUNCIONES PÚBLICAS
// ============================================================================

/**
 * @brief Inicializa módulo de adquisición de datos
 *
 * Configura ADC con DMA para muestreo automático a 2 kHz
 */
void dataAcquisition_Init(void);

/**
 * @brief Inicia muestreo continuo
 */
void dataAcquisition_Start(void);

/**
 * @brief Detiene muestreo
 */
void dataAcquisition_Stop(void);

/**
 * @brief Verifica si hay buffer listo para procesar
 *
 * @return true si hay buffer completo disponible
 */
bool dataAcquisition_IsBufferReady(void);

/**
 * @brief Obtiene buffer de muestras
 *
 * @return Puntero a buffer (solo lectura), NULL si no hay buffer listo
 */
const ADC_Buffer_t* dataAcquisition_GetBuffer(void);

/**
 * @brief Marca buffer como procesado (libera para siguiente captura)
 */
void dataAcquisition_ReleaseBuffer(void);

/**
 * @brief Calibra offset automáticamente (sin carga conectada)
 *
 * Debe llamarse con I=0 (sin carga) para calibrar offset de corriente
 */
void dataAcquisition_CalibrateOffset(void);

/**
 * @brief Establece parámetros de calibración
 */
void dataAcquisition_SetCalibration(const Calibration_t* calib);

/**
 * @brief Obtiene parámetros de calibración actuales
 */
void dataAcquisition_GetCalibration(Calibration_t* calib);

/**
 * @brief Callback de DMA (llamado cuando buffer está lleno)
 *
 * NOTA: Esta función es llamada automáticamente por hardware
 */
void __attribute__((interrupt, auto_psv)) _DMA0Interrupt(void);

#endif // DATAACQUISITION_H
```

#### Archivo: `userFncFile.c` (extracto clave)

```c
/**
 * @file userFncFile.c
 * @brief DataAcquisition - Implementación
 */

#include "userFncFile.h"
#include <string.h>
#include <math.h>

// ============================================================================
// VARIABLES GLOBALES
// ============================================================================

// Double buffering para procesamiento en paralelo con captura
static ADC_Buffer_t g_buffer[2];
static uint8_t g_active_buffer = 0;      // Buffer siendo llenado por DMA
static uint8_t g_ready_buffer = 0xFF;    // Buffer listo para procesar (0xFF = ninguno)

static Calibration_t g_calibration = {
    .voltage_gain = VOLTAGE_GAIN,
    .voltage_offset = VOLTAGE_OFFSET,
    .current_gain = CURRENT_GAIN,
    .current_offset = CURRENT_OFFSET
};

// ============================================================================
// FUNCIONES PRIVADAS
// ============================================================================

/**
 * @brief Configura ADC para muestreo simultáneo de 2 canales
 */
static void configure_adc(void) {
    // Configuración ADC para dsPIC33EP
    // ADC1: 12-bit, simultaneous sampling, auto-convert

    AD1CON1bits.FORM = 0;      // Integer output (0-4095)
    AD1CON1bits.SSRC = 2;      // Timer3 trigger (para fs=2kHz)
    AD1CON1bits.ASAM = 1;      // Auto-sampling
    AD1CON1bits.SIMSAM = 1;    // Simultaneous sampling (CH0 y CH1)

    AD1CON2bits.CHPS = 1;      // Converts CH0 y CH1
    AD1CON2bits.SMPI = 0;      // Interrupt cada conversión
    AD1CON2bits.BUFM = 0;      // Single buffer mode

    AD1CON3bits.ADRC = 0;      // Clock from system clock
    AD1CON3bits.SAMC = 15;     // 15 Tad auto-sample time
    AD1CON3bits.ADCS = 2;      // Tad = 3 * Tcy

    // Seleccionar canales AN0 (voltaje) y AN1 (corriente)
    AD1CHS0bits.CH0SA = 0;     // CH0 positive input = AN0
    AD1CHS0bits.CH0NA = 0;     // CH0 negative input = Vref-
    AD1CHS123bits.CH123SA = 0; // CH1 positive input = AN1
    AD1CHS123bits.CH123NA = 0; // CH1 negative input = Vref-

    // Habilitar ADC
    AD1CON1bits.ADON = 1;
}

/**
 * @brief Configura Timer3 para trigger ADC a 2 kHz
 */
static void configure_timer3(void) {
    T3CONbits.TON = 0;         // Timer3 off
    T3CONbits.TCS = 0;         // Internal clock (Fcy)
    T3CONbits.TGATE = 0;       // Gated time disabled
    T3CONbits.TCKPS = 0;       // Prescaler 1:1

    // Calcular PR3 para fs = 2 kHz
    // PR3 = (Fcy / fs) - 1
    // Asumiendo Fcy = 70 MHz: PR3 = (70000000 / 2000) - 1 = 34999
    PR3 = 34999;

    TMR3 = 0;                  // Reset timer
    T3CONbits.TON = 1;         // Start timer
}

/**
 * @brief Configura DMA para transferir datos ADC a buffer
 */
static void configure_dma(void) {
    // DMA Channel 0 para ADC1
    DMA0CONbits.SIZE = 0;      // Word transfer (16-bit)
    DMA0CONbits.DIR = 0;       // Peripheral to RAM
    DMA0CONbits.MODE = 2;      // Continuous ping-pong mode

    // Peripheral: ADC1 buffer
    DMA0PAD = (volatile unsigned int)&ADC1BUF0;

    // Primary buffer (voltaje)
    DMA0STA = __builtin_dmaoffset(&g_buffer[0].voltage[0]);
    DMA0CNT = BUFFER_SIZE - 1; // Número de transfers - 1

    // Secondary buffer (voltaje)
    DMA0STB = __builtin_dmaoffset(&g_buffer[1].voltage[0]);

    // Interrupt when buffer full
    IFS0bits.DMA0IF = 0;       // Clear interrupt flag
    IEC0bits.DMA0IE = 1;       // Enable interrupt
    IPC1bits.DMA0IP = 6;       // Priority 6

    DMA0CONbits.CHEN = 1;      // Enable DMA channel

    // DMA Channel 1 para canal de corriente (similar configuración)
    // ... (código similar para CH1)
}

// ============================================================================
// FUNCIONES PÚBLICAS
// ============================================================================

void dataAcquisition_Init(void) {
    // Limpiar buffers
    memset(g_buffer, 0, sizeof(g_buffer));
    g_active_buffer = 0;
    g_ready_buffer = 0xFF;

    // Configurar periféricos
    configure_adc();
    configure_timer3();
    configure_dma();
}

void dataAcquisition_Start(void) {
    // Habilitar conversiones ADC
    AD1CON1bits.SAMP = 1;
    T3CONbits.TON = 1;
}

void dataAcquisition_Stop(void) {
    T3CONbits.TON = 0;
    AD1CON1bits.SAMP = 0;
}

bool dataAcquisition_IsBufferReady(void) {
    return (g_ready_buffer != 0xFF);
}

const ADC_Buffer_t* dataAcquisition_GetBuffer(void) {
    if (g_ready_buffer == 0xFF) {
        return NULL;
    }
    return &g_buffer[g_ready_buffer];
}

void dataAcquisition_ReleaseBuffer(void) {
    if (g_ready_buffer != 0xFF) {
        g_buffer[g_ready_buffer].is_ready = false;
        g_ready_buffer = 0xFF;
    }
}

void dataAcquisition_CalibrateOffset(void) {
    // Capturar múltiples ciclos para promediar offset
    uint32_t voltage_sum = 0;
    uint32_t current_sum = 0;
    uint16_t sample_count = 0;

    // Esperar buffer listo
    while (!dataAcquisition_IsBufferReady()) {
        __delay_ms(1);
    }

    const ADC_Buffer_t* buffer = dataAcquisition_GetBuffer();

    // Promediar todas las muestras
    for (uint16_t i = 0; i < buffer->sample_count; i++) {
        voltage_sum += buffer->voltage[i];
        current_sum += buffer->current[i];
        sample_count++;
    }

    // Calcular offset (valor medio)
    g_calibration.voltage_offset = (int16_t)(voltage_sum / sample_count);
    g_calibration.current_offset = (int16_t)(current_sum / sample_count);

    dataAcquisition_ReleaseBuffer();
}

void dataAcquisition_SetCalibration(const Calibration_t* calib) {
    g_calibration = *calib;
}

void dataAcquisition_GetCalibration(Calibration_t* calib) {
    *calib = g_calibration;
}

// ============================================================================
// INTERRUPCIÓN DMA
// ============================================================================

/**
 * @brief Interrupción DMA cuando buffer está lleno
 */
void __attribute__((interrupt, auto_psv)) _DMA0Interrupt(void) {
    // Marcar buffer actual como listo
    g_buffer[g_active_buffer].sample_count = BUFFER_SIZE;
    g_buffer[g_active_buffer].timestamp = getSystemMilis();
    g_buffer[g_active_buffer].is_ready = true;
    g_ready_buffer = g_active_buffer;

    // Cambiar al otro buffer (ping-pong)
    g_active_buffer = (g_active_buffer == 0) ? 1 : 0;

    // Clear interrupt flag
    IFS0bits.DMA0IF = 0;
}
```

---

## Módulo de Procesamiento

### Module_SignalProcessing

Este módulo calcula los parámetros eléctricos RMS a partir de las muestras ADC.

#### Archivo: `userFncFile.h`

```c
/**
 * @file userFncFile.h
 * @brief SignalProcessing - Cálculos RMS y procesamiento de señales
 */

#ifndef SIGNALPROCESSING_H
#define SIGNALPROCESSING_H

#include <stdint.h>
#include <stdbool.h>
#include "dataAcquisition.h"  // Para acceso a ADC_Buffer_t

// ============================================================================
// ESTRUCTURAS
// ============================================================================

/**
 * @brief Parámetros eléctricos calculados
 */
typedef struct {
    float voltage_rms;         ///< Voltaje RMS (V)
    float current_rms;         ///< Corriente RMS (A)
    float power_active;        ///< Potencia activa (W)
    float power_reactive;      ///< Potencia reactiva (VAR)
    float power_apparent;      ///< Potencia aparente (VA)
    float power_factor;        ///< Factor de potencia (cos φ)
    float frequency;           ///< Frecuencia de red (Hz)
    float energy_kwh;          ///< Energía acumulada (kWh)
    uint32_t timestamp;        ///< Timestamp de cálculo (ms)
} ElectricalParams_t;

// ============================================================================
// FUNCIONES PÚBLICAS
// ============================================================================

/**
 * @brief Inicializa módulo de procesamiento
 */
void signalProcessing_Init(void);

/**
 * @brief Procesa buffer ADC y calcula parámetros eléctricos
 *
 * @param buffer Buffer de muestras ADC (de dataAcquisition)
 * @return Parámetros eléctricos calculados
 */
ElectricalParams_t signalProcessing_Process(const ADC_Buffer_t* buffer);

/**
 * @brief Obtiene últimos parámetros calculados
 */
const ElectricalParams_t* signalProcessing_GetParams(void);

/**
 * @brief Resetea acumulador de energía
 */
void signalProcessing_ResetEnergy(void);

#endif // SIGNALPROCESSING_H
```

#### Archivo: `userFncFile.c`

```c
#include "userFncFile.h"
#include <math.h>

static ElectricalParams_t g_params;
static uint32_t g_last_calc_time = 0;

void signalProcessing_Init(void) {
    memset(&g_params, 0, sizeof(g_params));
}

ElectricalParams_t signalProcessing_Process(const ADC_Buffer_t* buffer) {
    ElectricalParams_t result;

    // Obtener calibración
    Calibration_t calib;
    dataAcquisition_GetCalibration(&calib);

    // Variables para cálculo
    float v_sum_sq = 0.0f;
    float i_sum_sq = 0.0f;
    float vi_sum = 0.0f;
    uint16_t zero_crossings = 0;
    int16_t last_v_sign = 0;

    // Procesar muestras
    for (uint16_t i = 0; i < buffer->sample_count; i++) {
        // Convertir ADC a valores reales con calibración
        int16_t v_raw = (int16_t)buffer->voltage[i] - calib.voltage_offset;
        int16_t i_raw = (int16_t)buffer->current[i] - calib.current_offset;

        float v = v_raw * calib.voltage_gain;
        float i = i_raw * calib.current_gain;

        // Acumular para RMS
        v_sum_sq += v * v;
        i_sum_sq += i * i;

        // Acumular para potencia activa (V * I)
        vi_sum += v * i;

        // Detectar cruces por cero para frecuencia
        int16_t v_sign = (v >= 0) ? 1 : -1;
        if (last_v_sign < 0 && v_sign > 0) {
            zero_crossings++;
        }
        last_v_sign = v_sign;
    }

    // Calcular RMS
    float N = (float)buffer->sample_count;
    result.voltage_rms = sqrtf(v_sum_sq / N);
    result.current_rms = sqrtf(i_sum_sq / N);

    // Calcular potencias
    result.power_active = vi_sum / N;  // P = (1/N) * Σ(v*i)
    result.power_apparent = result.voltage_rms * result.current_rms;  // S = Vrms * Irms

    // Calcular potencia reactiva: Q = sqrt(S² - P²)
    float S_sq = result.power_apparent * result.power_apparent;
    float P_sq = result.power_active * result.power_active;
    result.power_reactive = sqrtf(fabs(S_sq - P_sq));

    // Calcular factor de potencia: cos(φ) = P / S
    if (result.power_apparent > 0.1f) {  // Evitar división por cero
        result.power_factor = result.power_active / result.power_apparent;
    } else {
        result.power_factor = 1.0f;  // Sin carga
    }

    // Calcular frecuencia
    // frecuencia = (zero_crossings / 2) / tiempo_captura
    float capture_time_s = (float)buffer->sample_count / SAMPLING_FREQ_HZ;
    result.frequency = ((float)zero_crossings / 2.0f) / capture_time_s;

    // Acumular energía (kWh)
    uint32_t current_time = buffer->timestamp;
    if (g_last_calc_time > 0) {
        float delta_time_h = (float)(current_time - g_last_calc_time) / 3600000.0f;  // ms → h
        float energy_wh = result.power_active * delta_time_h * 1000.0f;  // W → Wh
        g_params.energy_kwh += energy_wh / 1000.0f;  // Wh → kWh
    }
    g_last_calc_time = current_time;

    result.energy_kwh = g_params.energy_kwh;
    result.timestamp = current_time;

    // Guardar últimos valores
    g_params = result;

    return result;
}

const ElectricalParams_t* signalProcessing_GetParams(void) {
    return &g_params;
}

void signalProcessing_ResetEnergy(void) {
    g_params.energy_kwh = 0.0f;
    g_last_calc_time = 0;
}
```

---

## Comunicaciones IoT

### Module_WiFiComm

Comunicación con ESP32 via UART para servidor web y MQTT.

#### Protocolo UART MCU ↔ ESP32

**Formato de mensaje:**
```
[STX][CMD][LEN_H][LEN_L][DATA...][CHECKSUM][ETX]

STX      = 0x02 (Start of Text)
CMD      = Comando (1 byte)
LEN_H/L  = Longitud de DATA (2 bytes, big-endian)
DATA     = Payload (N bytes)
CHECKSUM = XOR de todos los bytes
ETX      = 0x03 (End of Text)
```

**Comandos:**
```c
#define CMD_SEND_PARAMS     0x10  // MCU → ESP32: Enviar parámetros eléctricos
#define CMD_GET_CONFIG      0x20  // ESP32 → MCU: Solicitar configuración
#define CMD_SET_CONFIG      0x21  // ESP32 → MCU: Establecer configuración
#define CMD_ALERT           0x30  // MCU → ESP32: Enviar alerta
#define CMD_HEARTBEAT       0xFF  // Keepalive
```

#### Payload CMD_SEND_PARAMS (JSON)

```json
{
  "v": 220.5,
  "i": 5.2,
  "p": 1100.0,
  "q": 250.0,
  "s": 1146.0,
  "pf": 0.96,
  "f": 50.1,
  "e": 125.34,
  "t": 1704470400
}
```

#### Código ESP32 (Arduino)

```cpp
// ESP32: Web Server + MQTT Client
#include <WiFi.h>
#include <WebServer.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>

const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

const char* mqtt_server = "mqtt.example.com";
const int mqtt_port = 1883;
const char* mqtt_user = "user";
const char* mqtt_pass = "pass";

WebServer server(80);
WiFiClient espClient;
PubSubClient mqtt(espClient);

// Últimos datos recibidos del MCU
struct {
  float voltage;
  float current;
  float power;
  float energy;
  float pf;
  float frequency;
  unsigned long timestamp;
} lastData;

void setup() {
  Serial.begin(115200);  // UART para MCU

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }

  mqtt.setServer(mqtt_server, mqtt_port);

  // Web server endpoints
  server.on("/api/current", HTTP_GET, handleGetCurrent);
  server.on("/api/history", HTTP_GET, handleGetHistory);
  server.on("/", HTTP_GET, handleRoot);
  server.begin();
}

void loop() {
  server.handleClient();

  if (!mqtt.connected()) {
    reconnectMQTT();
  }
  mqtt.loop();

  // Leer datos del MCU por UART
  if (Serial.available()) {
    readFromMCU();
  }
}

void readFromMCU() {
  // Leer mensaje con protocolo definido
  if (Serial.read() == 0x02) {  // STX
    uint8_t cmd = Serial.read();

    if (cmd == CMD_SEND_PARAMS) {
      // Leer payload JSON
      StaticJsonDocument<512> doc;
      deserializeJson(doc, Serial);

      lastData.voltage = doc["v"];
      lastData.current = doc["i"];
      lastData.power = doc["p"];
      lastData.energy = doc["e"];
      lastData.pf = doc["pf"];
      lastData.frequency = doc["f"];
      lastData.timestamp = doc["t"];

      // Publicar a MQTT
      publishToMQTT();
    }
  }
}

void handleGetCurrent() {
  StaticJsonDocument<256> doc;
  doc["voltage"] = lastData.voltage;
  doc["current"] = lastData.current;
  doc["power"] = lastData.power;
  doc["energy"] = lastData.energy;
  doc["pf"] = lastData.pf;
  doc["frequency"] = lastData.frequency;
  doc["timestamp"] = lastData.timestamp;

  String response;
  serializeJson(doc, response);

  server.send(200, "application/json", response);
}

void publishToMQTT() {
  String topic = "emic/energy/" + WiFi.macAddress() + "/data";

  StaticJsonDocument<256> doc;
  doc["v"] = lastData.voltage;
  doc["i"] = lastData.current;
  doc["p"] = lastData.power;
  doc["e"] = lastData.energy;

  String payload;
  serializeJson(doc, payload);

  mqtt.publish(topic.c_str(), payload.c_str());
}

void handleRoot() {
  // Servir dashboard HTML (ver sección Dashboard Web)
  server.send(200, "text/html", DASHBOARD_HTML);
}

void reconnectMQTT() {
  while (!mqtt.connected()) {
    if (mqtt.connect("EnergyMonitor", mqtt_user, mqtt_pass)) {
      mqtt.subscribe("emic/energy/config");
    } else {
      delay(5000);
    }
  }
}
```

---

## Dashboard Web

### Interfaz HTML5 + Chart.js

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>EMIC Energy Monitor</title>
  <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      padding: 20px;
    }

    .container {
      max-width: 1400px;
      margin: 0 auto;
    }

    h1 {
      color: white;
      text-align: center;
      margin-bottom: 30px;
      font-size: 2.5em;
    }

    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 20px;
      margin-bottom: 30px;
    }

    .stat-card {
      background: white;
      border-radius: 15px;
      padding: 25px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.2);
      transition: transform 0.3s;
    }

    .stat-card:hover {
      transform: translateY(-5px);
    }

    .stat-label {
      font-size: 0.9em;
      color: #666;
      margin-bottom: 10px;
    }

    .stat-value {
      font-size: 2.5em;
      font-weight: bold;
      color: #667eea;
    }

    .stat-unit {
      font-size: 0.5em;
      color: #999;
    }

    .chart-container {
      background: white;
      border-radius: 15px;
      padding: 25px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.2);
      margin-bottom: 20px;
    }

    .alert {
      background: #ff6b6b;
      color: white;
      padding: 15px;
      border-radius: 10px;
      margin-bottom: 20px;
      animation: pulse 2s infinite;
    }

    @keyframes pulse {
      0%, 100% { opacity: 1; }
      50% { opacity: 0.7; }
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>⚡ EMIC Energy Monitor</h1>

    <div id="alerts"></div>

    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-label">Voltaje</div>
        <div class="stat-value" id="voltage">---<span class="stat-unit">V</span></div>
      </div>

      <div class="stat-card">
        <div class="stat-label">Corriente</div>
        <div class="stat-value" id="current">---<span class="stat-unit">A</span></div>
      </div>

      <div class="stat-card">
        <div class="stat-label">Potencia</div>
        <div class="stat-value" id="power">---<span class="stat-unit">W</span></div>
      </div>

      <div class="stat-card">
        <div class="stat-label">Factor de Potencia</div>
        <div class="stat-value" id="pf">---</div>
      </div>

      <div class="stat-card">
        <div class="stat-label">Energía Consumida</div>
        <div class="stat-value" id="energy">---<span class="stat-unit">kWh</span></div>
      </div>

      <div class="stat-card">
        <div class="stat-label">Costo Estimado</div>
        <div class="stat-value" id="cost">---<span class="stat-unit">$</span></div>
      </div>
    </div>

    <div class="chart-container">
      <canvas id="powerChart"></canvas>
    </div>

    <div class="chart-container">
      <canvas id="voltageCurrentChart"></canvas>
    </div>
  </div>

  <script>
    const COST_PER_KWH = 0.12;  // USD por kWh (ajustar según tarifa local)

    // Datos históricos
    let powerHistory = [];
    let voltageHistory = [];
    let currentHistory = [];
    let timeLabels = [];
    const MAX_HISTORY = 60;  // Últimos 60 segundos

    // Chart.js - Gráfico de potencia
    const powerCtx = document.getElementById('powerChart').getContext('2d');
    const powerChart = new Chart(powerCtx, {
      type: 'line',
      data: {
        labels: timeLabels,
        datasets: [{
          label: 'Potencia (W)',
          data: powerHistory,
          borderColor: '#667eea',
          backgroundColor: 'rgba(102, 126, 234, 0.1)',
          tension: 0.4,
          fill: true
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: { display: true },
          title: { display: true, text: 'Potencia en Tiempo Real' }
        },
        scales: {
          y: { beginAtZero: true, title: { display: true, text: 'Watts' } }
        }
      }
    });

    // Chart.js - Gráfico de voltaje y corriente
    const vcCtx = document.getElementById('voltageCurrentChart').getContext('2d');
    const vcChart = new Chart(vcCtx, {
      type: 'line',
      data: {
        labels: timeLabels,
        datasets: [
          {
            label: 'Voltaje (V)',
            data: voltageHistory,
            borderColor: '#f093fb',
            yAxisID: 'y-voltage'
          },
          {
            label: 'Corriente (A)',
            data: currentHistory,
            borderColor: '#4facfe',
            yAxisID: 'y-current'
          }
        ]
      },
      options: {
        responsive: true,
        plugins: {
          title: { display: true, text: 'Voltaje y Corriente' }
        },
        scales: {
          'y-voltage': { type: 'linear', position: 'left', title: { display: true, text: 'Voltaje (V)' } },
          'y-current': { type: 'linear', position: 'right', title: { display: true, text: 'Corriente (A)' }, grid: { drawOnChartArea: false } }
        }
      }
    });

    // Actualizar datos cada 1 segundo
    async function updateData() {
      try {
        const response = await fetch('/api/current');
        const data = await response.json();

        // Actualizar stats
        document.getElementById('voltage').innerHTML = `${data.voltage.toFixed(1)}<span class="stat-unit">V</span>`;
        document.getElementById('current').innerHTML = `${data.current.toFixed(2)}<span class="stat-unit">A</span>`;
        document.getElementById('power').innerHTML = `${data.power.toFixed(0)}<span class="stat-unit">W</span>`;
        document.getElementById('pf').textContent = data.pf.toFixed(2);
        document.getElementById('energy').innerHTML = `${data.energy.toFixed(3)}<span class="stat-unit">kWh</span>`;

        const cost = data.energy * COST_PER_KWH;
        document.getElementById('cost').innerHTML = `${cost.toFixed(2)}<span class="stat-unit">$</span>`;

        // Actualizar gráficos
        const now = new Date().toLocaleTimeString();
        timeLabels.push(now);
        powerHistory.push(data.power);
        voltageHistory.push(data.voltage);
        currentHistory.push(data.current);

        if (timeLabels.length > MAX_HISTORY) {
          timeLabels.shift();
          powerHistory.shift();
          voltageHistory.shift();
          currentHistory.shift();
        }

        powerChart.update();
        vcChart.update();

        // Verificar alertas
        checkAlerts(data);

      } catch (error) {
        console.error('Error fetching data:', error);
      }
    }

    function checkAlerts(data) {
      const alertsDiv = document.getElementById('alerts');
      alertsDiv.innerHTML = '';

      if (data.voltage > 250) {
        alertsDiv.innerHTML += '<div class="alert">⚠️ ALERTA: Sobretensión detectada!</div>';
      }
      if (data.voltage < 190) {
        alertsDiv.innerHTML += '<div class="alert">⚠️ ALERTA: Subtensión detectada!</div>';
      }
      if (data.current > 25) {
        alertsDiv.innerHTML += '<div class="alert">⚠️ ALERTA: Sobrecarga detectada!</div>';
      }
      if (data.pf < 0.85) {
        alertsDiv.innerHTML += '<div class="alert">⚠️ Factor de potencia bajo (< 0.85)</div>';
      }
    }

    // Iniciar actualización automática
    updateData();
    setInterval(updateData, 1000);
  </script>
</body>
</html>
```

---

## Almacenamiento de Datos

### SD Card Logger (CSV)

```c
/**
 * @brief Guarda datos en SD Card (formato CSV)
 */
void dataLogger_LogToSD(const ElectricalParams_t* params) {
    static FIL file;
    static bool file_open = false;

    // Crear nombre de archivo con fecha (ejemplo: 2025-01-05.csv)
    char filename[32];
    DateTime_t dt = rtc_GetDateTime();
    sprintf(filename, "%04d-%02d-%02d.csv", dt.year, dt.month, dt.day);

    // Abrir archivo (crear si no existe)
    if (!file_open) {
        FRESULT res = f_open(&file, filename, FA_WRITE | FA_OPEN_APPEND);
        if (res != FR_OK) {
            return;  // Error abriendo archivo
        }
        file_open = true;

        // Escribir header si es archivo nuevo
        if (f_size(&file) == 0) {
            f_printf(&file, "timestamp,voltage,current,power,energy,pf,frequency\n");
        }
    }

    // Escribir datos
    f_printf(&file, "%lu,%.2f,%.2f,%.2f,%.3f,%.2f,%.1f\n",
             params->timestamp,
             params->voltage_rms,
             params->current_rms,
             params->power_active,
             params->energy_kwh,
             params->power_factor,
             params->frequency);

    // Sync cada 10 escrituras (para no desgastar SD)
    static uint8_t sync_counter = 0;
    if (++sync_counter >= 10) {
        f_sync(&file);
        sync_counter = 0;
    }
}
```

### Cloud Database (InfluxDB via MQTT)

El ESP32 publica datos a MQTT, y un script de servidor suscrito los guarda en InfluxDB:

```python
# server_mqtt_to_influxdb.py
import paho.mqtt.client as mqtt
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS
import json

# Configuración InfluxDB
influx_client = InfluxDBClient(url="http://localhost:8086", token="YOUR_TOKEN", org="emic")
write_api = influx_client.write_api(write_options=SYNCHRONOUS)

def on_message(client, userdata, msg):
    try:
        data = json.loads(msg.payload.decode())

        # Crear punto de datos
        point = Point("energy_monitor") \
            .tag("device", "device_001") \
            .field("voltage", data['v']) \
            .field("current", data['i']) \
            .field("power", data['p']) \
            .field("energy", data['e'])

        # Escribir a InfluxDB
        write_api.write(bucket="energy_data", record=point)
        print(f"Data saved: {data}")

    except Exception as e:
        print(f"Error: {e}")

mqtt_client = mqtt.Client()
mqtt_client.on_message = on_message
mqtt_client.connect("mqtt.example.com", 1883, 60)
mqtt_client.subscribe("emic/energy/+/data")
mqtt_client.loop_forever()
```

---

## Sistema de Alertas

### Module_AlertSystem

```c
/**
 * @file userFncFile.h
 * @brief AlertSystem - Detección y notificación de anomalías
 */

#ifndef ALERTSYSTEM_H
#define ALERTSYSTEM_H

#include "signalProcessing.h"

// ============================================================================
// TIPOS DE ALERTAS
// ============================================================================

typedef enum {
    ALERT_NONE = 0,
    ALERT_OVERVOLTAGE,        // V > umbral
    ALERT_UNDERVOLTAGE,       // V < umbral
    ALERT_OVERCURRENT,        // I > umbral
    ALERT_LOW_POWER_FACTOR,   // cos(φ) < umbral
    ALERT_HIGH_CONSUMPTION,   // kWh/día > umbral
    ALERT_COMM_FAILURE        // Pérdida de comunicación
} AlertType_t;

typedef struct {
    AlertType_t type;
    float value;              ///< Valor que disparó la alerta
    uint32_t timestamp;
    bool is_active;
} Alert_t;

// ============================================================================
// FUNCIONES PÚBLICAS
// ============================================================================

void alertSystem_Init(void);
void alertSystem_Check(const ElectricalParams_t* params);
bool alertSystem_HasActiveAlerts(void);
const Alert_t* alertSystem_GetAlerts(uint8_t* count);
void alertSystem_ClearAlert(AlertType_t type);

#endif // ALERTSYSTEM_H
```

#### Implementación

```c
#include "userFncFile.h"

// Umbrales configurables
static float g_overvoltage_threshold = 250.0f;   // V
static float g_undervoltage_threshold = 190.0f;  // V
static float g_overcurrent_threshold = 25.0f;    // A
static float g_low_pf_threshold = 0.85f;
static float g_high_consumption_kwh = 50.0f;     // kWh/día

static Alert_t g_alerts[10];
static uint8_t g_alert_count = 0;

void alertSystem_Check(const ElectricalParams_t* params) {
    // Limpiar alertas anteriores
    g_alert_count = 0;

    // Verificar sobretensión
    if (params->voltage_rms > g_overvoltage_threshold) {
        Alert_t alert = {
            .type = ALERT_OVERVOLTAGE,
            .value = params->voltage_rms,
            .timestamp = params->timestamp,
            .is_active = true
        };
        g_alerts[g_alert_count++] = alert;

        // Activar buzzer local
        buzzer_Beep(3, 200);

        // Notificar vía WiFi
        wifiComm_SendAlert("OVERVOLTAGE", params->voltage_rms);
    }

    // Verificar subtensión
    if (params->voltage_rms < g_undervoltage_threshold) {
        Alert_t alert = {
            .type = ALERT_UNDERVOLTAGE,
            .value = params->voltage_rms,
            .timestamp = params->timestamp,
            .is_active = true
        };
        g_alerts[g_alert_count++] = alert;

        buzzer_Beep(2, 300);
        wifiComm_SendAlert("UNDERVOLTAGE", params->voltage_rms);
    }

    // Verificar sobrecarga
    if (params->current_rms > g_overcurrent_threshold) {
        Alert_t alert = {
            .type = ALERT_OVERCURRENT,
            .value = params->current_rms,
            .timestamp = params->timestamp,
            .is_active = true
        };
        g_alerts[g_alert_count++] = alert;

        buzzer_Beep(5, 100);  // Beep rápido
        wifiComm_SendAlert("OVERCURRENT", params->current_rms);

        // ACCIÓN CRÍTICA: Desconectar carga con relé
        relay_Off();
    }

    // Verificar factor de potencia bajo
    if (params->power_factor < g_low_pf_threshold) {
        Alert_t alert = {
            .type = ALERT_LOW_POWER_FACTOR,
            .value = params->power_factor,
            .timestamp = params->timestamp,
            .is_active = true
        };
        g_alerts[g_alert_count++] = alert;

        // Notificación sin alarma sonora (no es crítico)
        wifiComm_SendAlert("LOW_PF", params->power_factor);
    }
}

bool alertSystem_HasActiveAlerts(void) {
    return (g_alert_count > 0);
}

const Alert_t* alertSystem_GetAlerts(uint8_t* count) {
    *count = g_alert_count;
    return g_alerts;
}
```

---

## Integración Cloud

### AWS IoT Core

```c
// Configuración MQTT para AWS IoT
#define AWS_IOT_ENDPOINT    "a1b2c3d4e5f6g7-ats.iot.us-east-1.amazonaws.com"
#define AWS_IOT_PORT        8883  // MQTT over TLS
#define AWS_IOT_TOPIC       "emic/energy/device001/data"
```

### Código ESP32 con AWS IoT

```cpp
#include <WiFiClientSecure.h>
#include <PubSubClient.h>

WiFiClientSecure net;
PubSubClient client(net);

// Certificados AWS IoT (almacenar en SPIFFS)
const char AWS_CERT_CA[] PROGMEM = R"EOF(
-----BEGIN CERTIFICATE-----
... (Amazon Root CA 1)
-----END CERTIFICATE-----
)EOF";

const char AWS_CERT_CRT[] PROGMEM = R"EOF(
-----BEGIN CERTIFICATE-----
... (Device Certificate)
-----END CERTIFICATE-----
)EOF";

const char AWS_CERT_PRIVATE[] PROGMEM = R"EOF(
-----BEGIN RSA PRIVATE KEY-----
... (Private Key)
-----END RSA PRIVATE KEY-----
)EOF";

void connectAWS() {
  net.setCACert(AWS_CERT_CA);
  net.setCertificate(AWS_CERT_CRT);
  net.setPrivateKey(AWS_CERT_PRIVATE);

  client.setServer(AWS_IOT_ENDPOINT, AWS_IOT_PORT);

  while (!client.connected()) {
    if (client.connect("EnergyMonitor")) {
      Serial.println("AWS IoT Connected!");
    } else {
      delay(2000);
    }
  }
}

void publishAWS(const ElectricalParams_t* params) {
  StaticJsonDocument<512> doc;
  doc["deviceId"] = "device001";
  doc["timestamp"] = params->timestamp;
  doc["voltage"] = params->voltage_rms;
  doc["current"] = params->current_rms;
  doc["power"] = params->power_active;
  doc["energy"] = params->energy_kwh;
  doc["powerFactor"] = params->power_factor;

  String payload;
  serializeJson(doc, payload);

  client.publish(AWS_IOT_TOPIC, payload.c_str());
}
```

---

## Calibración y Testing

### Procedimiento de Calibración

#### Paso 1: Calibración de Offset (sin carga)

```
1. Desconectar toda carga del monitor
2. Alimentar el sistema
3. Ejecutar función: dataAcquisition_CalibrateOffset()
4. Sistema calcula valor medio de ADC cuando I=0
5. Guardar offset en EEPROM
```

#### Paso 2: Calibración de Ganancia de Voltaje

```
1. Conectar fuente de voltaje conocida (ej: 220V de la red)
2. Medir voltaje real con multímetro de precisión: V_real
3. Leer voltaje medido por sistema: V_measured
4. Calcular ganancia: gain = V_real / V_measured_raw
5. Actualizar: g_calibration.voltage_gain = gain
6. Guardar en EEPROM
```

#### Paso 3: Calibración de Ganancia de Corriente

```
1. Conectar carga conocida (ej: bombilla 100W)
2. Medir corriente real con pinza amperimétrica: I_real
3. Leer corriente medida por sistema: I_measured
4. Calcular ganancia: gain = I_real / I_measured_raw
5. Actualizar: g_calibration.current_gain = gain
6. Guardar en EEPROM
```

### Testing de Precisión

```c
/**
 * @brief Test de precisión con cargas conocidas
 */
void test_accuracy(void) {
    // Test 1: Carga resistiva pura (bombilla 100W)
    // Esperado: V=220V, I=0.45A, P=100W, PF=1.0
    float error_v = fabs(params.voltage_rms - 220.0f) / 220.0f * 100.0f;
    float error_i = fabs(params.current_rms - 0.45f) / 0.45f * 100.0f;
    float error_p = fabs(params.power_active - 100.0f) / 100.0f * 100.0f;

    printf("Error Voltaje: %.2f%%\n", error_v);
    printf("Error Corriente: %.2f%%\n", error_i);
    printf("Error Potencia: %.2f%%\n", error_p);

    // Verificar precisión < 3%
    assert(error_v < 3.0f);
    assert(error_i < 3.0f);
    assert(error_p < 3.0f);

    // Test 2: Carga inductiva (motor)
    // Esperado: PF ~ 0.7-0.8
    // ... similar verificación
}
```

---

## Código Completo

### Proyecto Principal: `generate.emic`

```emic
// ============================================================================
// EnergyMonitor - Proyecto EMIC Completo
// ============================================================================

EMIC:setOutput(TARGET:generate.txt)

    // ========== CONFIGURACIÓN BASE ==========
    EMIC:setInput(DEV:_pcb/pcb.emic,pcb=dsPIC33_DevBoard)
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    // ========== MÓDULOS EMIC ==========
    EMIC:setInput(SYS:Module_DataAcquisition/generate.emic)
    EMIC:setInput(SYS:Module_SignalProcessing/generate.emic)
    EMIC:setInput(SYS:Module_PowerCalculator/generate.emic)
    EMIC:setInput(SYS:Module_EnergyAccumulator/generate.emic)
    EMIC:setInput(SYS:Module_WiFiComm/generate.emic)
    EMIC:setInput(SYS:Module_DataLogger/generate.emic)
    EMIC:setInput(SYS:Module_AlertSystem/generate.emic)

    // ========== LÓGICA PRINCIPAL ==========
    EMIC:copy(SYS:userFncFile.c > TARGET:userFncFile.c)
    EMIC:define(c_modules.userFncFile,userFncFile)

    // ========== TEMPLATE MPLAB X ==========
    EMIC:copy(DEV:_templates/projects/mplabx_dspic33 > TARGET:)

EMIC:restoreOutput
```

### Archivo Principal: `userFncFile.c`

```c
/**
 * @file userFncFile.c
 * @brief Energy Monitor - Lógica principal
 */

#include "userFncFile.h"
#include "dataAcquisition.h"
#include "signalProcessing.h"
#include "wifiComm.h"
#include "dataLogger.h"
#include "alertSystem.h"

// ============================================================================
// VARIABLES GLOBALES
// ============================================================================

static uint32_t g_last_process_time = 0;
static uint32_t g_last_log_time = 0;
static uint32_t g_last_wifi_send_time = 0;

#define PROCESS_INTERVAL_MS      100    // Procesar cada 100 ms
#define LOG_INTERVAL_MS          10000  // Log SD cada 10 segundos
#define WIFI_SEND_INTERVAL_MS    1000   // Enviar WiFi cada 1 segundo

// ============================================================================
// INICIALIZACIÓN
// ============================================================================

void userInit(void) {
    // Inicializar módulos
    dataAcquisition_Init();
    signalProcessing_Init();
    wifiComm_Init();
    dataLogger_Init();
    alertSystem_Init();

    // Iniciar adquisición continua
    dataAcquisition_Start();

    // Mensaje inicial
    lcd_Clear();
    lcd_Print("EMIC Energy Monitor");
    lcd_SetCursor(0, 1);
    lcd_Print("Iniciando...");
    __delay_ms(2000);
}

// ============================================================================
// LOOP PRINCIPAL
// ============================================================================

void userLoop(void) {
    uint32_t current_time = getSystemMilis();

    // ========== PROCESAMIENTO DE DATOS (cada 100 ms) ==========
    if ((current_time - g_last_process_time) >= PROCESS_INTERVAL_MS) {

        // Verificar si hay buffer ADC listo
        if (dataAcquisition_IsBufferReady()) {
            const ADC_Buffer_t* buffer = dataAcquisition_GetBuffer();

            // Procesar señales y calcular parámetros
            ElectricalParams_t params = signalProcessing_Process(buffer);

            // Verificar alertas
            alertSystem_Check(&params);

            // Liberar buffer para siguiente captura
            dataAcquisition_ReleaseBuffer();

            // Actualizar display local (opcional)
            updateLocalDisplay(&params);
        }

        g_last_process_time = current_time;
    }

    // ========== ENVÍO WiFi (cada 1 segundo) ==========
    if ((current_time - g_last_wifi_send_time) >= WIFI_SEND_INTERVAL_MS) {
        const ElectricalParams_t* params = signalProcessing_GetParams();
        wifiComm_SendParams(params);
        g_last_wifi_send_time = current_time;
    }

    // ========== LOG A SD CARD (cada 10 segundos) ==========
    if ((current_time - g_last_log_time) >= LOG_INTERVAL_MS) {
        const ElectricalParams_t* params = signalProcessing_GetParams();
        dataLogger_LogToSD(params);
        g_last_log_time = current_time;
    }

    // ========== MANEJO DE ALERTAS CRÍTICAS ==========
    if (alertSystem_HasActiveAlerts()) {
        uint8_t alert_count;
        const Alert_t* alerts = alertSystem_GetAlerts(&alert_count);

        for (uint8_t i = 0; i < alert_count; i++) {
            if (alerts[i].type == ALERT_OVERCURRENT) {
                // EMERGENCIA: Desconectar carga
                relay_Off();
                lcd_Clear();
                lcd_Print("EMERGENCIA: SOBRECARGA");
                buzzer_BeepContinuous();
            }
        }
    }
}

/**
 * @brief Actualiza display LCD local (opcional)
 */
void updateLocalDisplay(const ElectricalParams_t* params) {
    lcd_Clear();

    lcd_SetCursor(0, 0);
    lcd_Printf("V: %.1fV  I: %.2fA", params->voltage_rms, params->current_rms);

    lcd_SetCursor(0, 1);
    lcd_Printf("P: %.0fW  PF: %.2f", params->power_active, params->power_factor);

    lcd_SetCursor(0, 2);
    lcd_Printf("E: %.3f kWh", params->energy_kwh);

    lcd_SetCursor(0, 3);
    DateTime_t dt = rtc_GetDateTime();
    lcd_Printf("%02d:%02d:%02d  %.1fHz", dt.hour, dt.minute, dt.second, params->frequency);
}
```

---

## Caso de Uso Real

### Caso 1: Monitor Residencial

**Escenario:**
- Casa familiar de 3 habitaciones
- Consumo promedio: 500 kWh/mes
- **Objetivo**: Reducir consumo 20% identificando desperdicios

**Implementación:**
1. Instalar monitor en tablero principal
2. Configurar alertas:
   - Consumo diario > 20 kWh
   - Factor de potencia < 0.9
   - Voltaje fuera de rango 200-240V
3. Monitorear durante 1 mes
4. Analizar dashboard web:
   - Picos de consumo (horarios)
   - Identificar electrodomésticos ineficientes
   - Detectar consumo fantasma (standby)

**Resultados:**
- Identificado: aire acondicionado antiguo (60% del consumo)
- Detectado: calentador de agua encendido 24/7
- **Ahorro logrado**: 22% reducción (110 kWh/mes)
- **ROI**: 6 meses

### Caso 2: Monitor Industrial

**Escenario:**
- Fábrica con 10 líneas de producción
- Consumo: 5000 kWh/mes (~$600/mes)
- **Objetivo**: Optimizar consumo de maquinaria

**Implementación:**
1. Instalar 10 monitores (uno por línea)
2. Dashboard centralizado con InfluxDB + Grafana
3. Alertas configuradas:
   - Consumo anormal (±20% del promedio)
   - Factor de potencia < 0.85 (penalización)
   - Sobrecarga (protección de equipos)
4. Integración con sistema SCADA

**Resultados:**
- Detectado: motor con rodamiento defectuoso (consumo +40%)
- Identificado: línea 3 con bajo PF (penalización $50/mes)
- Optimizado: horarios de operación (tarifa valle/punta)
- **Ahorro total**: $180/mes (30%)

---

## Resumen

### Aprendizajes Clave

1. **Medición de energía AC**: Implementar algoritmos RMS y cálculo de potencia
2. **ADC con DMA**: Muestreo de alta velocidad sin carga de CPU
3. **Procesamiento digital de señales**: Filtros, FFT, detección de fase
4. **Comunicaciones IoT**: WiFi, MQTT, HTTP REST API
5. **Dashboard web**: HTML5 + Chart.js para visualización en tiempo real
6. **Cloud integration**: AWS IoT, InfluxDB, time-series databases
7. **Sistema de alertas**: Detección inteligente de anomalías
8. **Calibración**: Técnicas de calibración por software

### Métricas del Proyecto

| Métrica | Valor |
|---------|-------|
| **Líneas de código** | ~3000 (C) + ~500 (ESP32) + ~300 (HTML/JS) |
| **Módulos EMIC** | 7 |
| **Precisión** | ±1% (V), ±2% (I), ±3% (P) |
| **Frecuencia muestreo** | 2 kHz |
| **Latencia** | < 500 ms (adquisición → dashboard) |
| **Costo hardware** | ~$80 (componentes) |
| **ROI típico** | 6-12 meses (residencial), 2-4 meses (industrial) |

### Próximos Pasos

- **Capítulo 29**: Control de Acceso con RFID
- **Capítulo 30**: Gateway Industrial Modbus

---

**¡Felicidades!** Has implementado un **Monitor de Energía IoT profesional** completo con comunicaciones cloud, dashboard web y sistema de alertas.

---

**[⬆ Volver al índice](#contenido)**
