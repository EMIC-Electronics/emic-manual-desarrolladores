# Capítulo 24: Debugging y Testing

## Índice
1. [Introducción](#introducción)
2. [Niveles de Debugging en EMIC](#niveles-de-debugging-en-emic)
3. [Herramientas de Debugging](#herramientas-de-debugging)
4. [Debugging de EMIC-Generate](#debugging-de-emic-generate)
5. [Análisis de generate.txt](#análisis-de-generatetxt)
6. [Debugging con UART](#debugging-con-uart)
7. [Debugging con LEDs](#debugging-con-leds)
8. [MPLAB X Debugger](#mplab-x-debugger)
9. [Testing de APIs](#testing-de-apis)
10. [Testing de Módulos](#testing-de-módulos)
11. [Testing de Integración](#testing-de-integración)
12. [Errores Comunes EMIC](#errores-comunes-emic)
13. [Casos Prácticos de Debugging](#casos-prácticos-de-debugging)
14. [Buenas Prácticas](#buenas-prácticas)
15. [Resumen del Capítulo](#resumen-del-capítulo)

---

## Introducción

El debugging y testing son **habilidades críticas** en el desarrollo de sistemas embebidos. En EMIC, el debugging se complica porque hay múltiples capas:
- Generación de código (EMIC-Generate)
- Compilación (XC8/XC16/XC32)
- Ejecución en hardware (microcontrolador)

Este capítulo te enseñará técnicas y herramientas para **identificar y resolver problemas** en cada una de estas capas.

### ¿Por qué es Importante?

```
⏱️ Tiempo promedio de desarrollo:
- Sin debugging sistemático: 80% debugging, 20% codificación
- Con debugging sistemático: 30% debugging, 70% codificación
```

### Tipos de Problemas

1. **Errores de generación** (EMIC-Generate)
   - Archivos no encontrados
   - Variables no sustituidas
   - Dependencias faltantes

2. **Errores de compilación** (XC Compiler)
   - Errores de sintaxis C
   - Tipos incompatibles
   - Funciones no declaradas

3. **Errores de runtime** (Hardware)
   - Comportamiento inesperado
   - Crashes o resets
   - Hardware no responde

---

## Niveles de Debugging en EMIC

### Nivel 1: Debugging de EMIC-Generate

```
generate.emic → EMIC-Generate → Target/*.c
                      ↑
                   ¿Error aquí?
```

**Síntomas:**
- No se generan archivos en Target/
- Variables .{name}. sin sustituir
- Archivos generados incompletos

**Herramientas:**
- generate.txt (log detallado)
- EMIC-CLI con modo verbose
- Inspección manual de archivos

### Nivel 2: Debugging de Compilación

```
Target/*.c → XC Compiler → firmware.hex
                   ↑
               ¿Error aquí?
```

**Síntomas:**
- Errores de compilación
- Warnings excesivos
- Linking errors

**Herramientas:**
- MPLAB X IDE (mensajes de error)
- Compilador en línea de comandos
- Análisis de Makefile

### Nivel 3: Debugging de Runtime

```
firmware.hex → Microcontrolador → Ejecución
                         ↑
                    ¿Error aquí?
```

**Síntomas:**
- Programa no funciona como esperado
- MCU se resetea
- Periféricos no responden
- Comportamiento errático

**Herramientas:**
- MPLAB X Debugger (PICkit, ICD)
- UART para logs
- LEDs de diagnóstico
- Osciloscopio / Analizador lógico

---

## Herramientas de Debugging

### Tabla de Herramientas

| Herramienta | Tipo | Costo | Uso | Efectividad |
|-------------|------|-------|-----|-------------|
| **generate.txt** | Log file | Gratis | Debugging EMIC-Generate | ⭐⭐⭐⭐⭐ |
| **UART Serial** | Hardware | Bajo | Runtime debugging | ⭐⭐⭐⭐⭐ |
| **LEDs** | Hardware | Muy bajo | Visual debugging | ⭐⭐⭐⭐ |
| **MPLAB X Debugger** | Software + HW | Medio | Breakpoints, step-by-step | ⭐⭐⭐⭐⭐ |
| **printf debugging** | Software | Gratis | Quick debugging | ⭐⭐⭐ |
| **Osciloscopio** | Hardware | Alto | Señales digitales/analógicas | ⭐⭐⭐⭐ |
| **Analizador lógico** | Hardware | Medio | Protocolos digitales | ⭐⭐⭐⭐ |

---

## Debugging de EMIC-Generate

### Problema: Variables No Sustituidas

**Síntoma:**
```c
// En archivo generado aparece:
void led_.{name}._Init(void) {
    HAL_GPIO_PinCfg(.{pin}., GPIO_OUTPUT);
}
```

**Diagnóstico:**
```bash
# Revisar generate.txt
cat Target/generate.txt | grep "ERROR"
cat Target/generate.txt | grep "WARNING"
```

**Posibles causas:**
1. Parámetro no definido en generate.emic
2. Sintaxis incorrecta (.{name} vs .{name}.)
3. Scope de variables incorrecto

**Solución:**
```emic
# ANTES (mal):
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic)

# DESPUÉS (bien):
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led1,pin=A0_Pin)
```

### Problema: Archivo No Encontrado

**Síntoma en generate.txt:**
```
[ERROR] File not found: DEV:_api/Indicators/LED/led.emic
[ERROR] Generation aborted
```

**Diagnóstico:**
```bash
# Verificar que el archivo existe
ls DEV:_api/Indicators/LEDs/led.emic

# Revisar ruta en generate.emic
grep "LED" System/generate.emic
```

**Solución:**
```emic
# ANTES (mal - ruta incorrecta):
EMIC:setInput(DEV:_api/Indicators/LED/led.emic,name=led1,pin=A0_Pin)
                                    ^^^
                                  falta 's'

# DESPUÉS (bien):
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led1,pin=A0_Pin)
                                    ^^^^
```

### Problema: Dependencias Circulares

**Síntoma:**
```
[ERROR] Circular dependency detected:
  module_a.emic → module_b.emic → module_a.emic
[ERROR] Generation aborted
```

**Diagnóstico:**
```bash
# Revisar cadena de dependencias
grep "setInput" System/generate.emic
grep "setInput" DEV:_api/module_a.emic
grep "setInput" DEV:_api/module_b.emic
```

**Solución:**
- Refactorizar para eliminar dependencia circular
- Extraer funcionalidad común a un tercer módulo

---

## Análisis de generate.txt

El archivo `generate.txt` es tu **mejor amigo** para debugging de EMIC-Generate.

### Estructura de generate.txt

```
[INFO] ============================================
[INFO] EMIC-Generate v4.1.0
[INFO] Starting generation process...
[INFO] ============================================

[INFO] Processing: System/generate.emic
[INFO] Output redirected to: TARGET:generate.txt

[INFO] Including PCB: DEV:_pcb/pcb.emic (pcb=HRD_Development_Board)
[INFO]   - MCU: PIC24FJ64GA002
[INFO]   - Clock: 32 MHz (PLL enabled)
[INFO]   - Pins configured: 24

[INFO] Processing: SYS:usedFunction.emic
[INFO]   - Functions registered: 12

[INFO] Including API: DEV:_api/Indicators/LEDs/led.emic
[INFO]   Parameters: name=led1, pin=A0_Pin
[INFO]   - Copying: inc/led.h → TARGET:inc/led_led1.h
[INFO]   - Substituting: .{name}. → led1
[INFO]   - Substituting: .{pin}. → A0_Pin
[INFO]   - Copying: src/led.c → TARGET:led_led1.c
[INFO]   - Registered init: led1_Init
[INFO]   - Registered module: led_led1.c

[INFO] Including API: DEV:_api/Timers/timer_api.emic
[INFO]   Parameters: name=1
[INFO]   - Copying: inc/timer_api.h → TARGET:inc/timer_api1.h
[INFO]   - Substituting: .{name}. → 1
[INFO]   - Copying: src/timer_api.c → TARGET:timer_api1.c
[INFO]   - Registered init: timer1_Init
[INFO]   - Registered module: timer_api1.c

[INFO] Including: DEV:_main/baremetal/main.emic
[INFO]   - Generating main.c
[INFO]   - Init functions: 5
[INFO]   - Poll functions: 2

[INFO] Copying: SYS:userFncFile.c → TARGET:userFncFile.c
[INFO] Registered module: userFncFile.c

[INFO] Copying project template: DEV:_templates/projects/mplabx → TARGET:
[INFO]   - Copying: Makefile
[INFO]   - Copying: nbproject/configurations.xml
[INFO]   - Generating: nbproject/Makefile-default.mk
[INFO]   - C modules registered: 8

[INFO] ============================================
[INFO] Generation completed successfully!
[INFO] Files generated: 24
[INFO] Time: 1.245 seconds
[INFO] ============================================
```

### Leer generate.txt Eficientemente

```bash
# Ver solo errores
grep "ERROR" Target/generate.txt

# Ver solo warnings
grep "WARNING" Target/generate.txt

# Ver archivos generados
grep "Copying:" Target/generate.txt

# Ver sustituciones de variables
grep "Substituting:" Target/generate.txt

# Ver módulos registrados
grep "Registered module:" Target/generate.txt

# Ver resumen final
tail -10 Target/generate.txt
```

### Interpretar Mensajes Comunes

| Mensaje | Significado | Acción |
|---------|-------------|--------|
| `[INFO] Generation completed successfully!` | Todo OK | Proceder a compilar |
| `[ERROR] File not found: ...` | Archivo no existe | Verificar ruta |
| `[WARNING] Variable not defined: .{xxx}.` | Variable sin valor | Añadir parámetro |
| `[ERROR] Circular dependency detected` | Dependencias circulares | Refactorizar |
| `[WARNING] Function already registered: xxx_Init` | Init duplicado | Renombrar instancia |

---

## Debugging con UART

UART es la **herramienta más poderosa** para debugging en runtime.

### Setup Básico

**Hardware:**
```
PIC24 TX → USB-Serial RX
PIC24 RX → USB-Serial TX
PIC24 GND → USB-Serial GND
```

**Software:**
- PuTTY, Tera Term, o Arduino Serial Monitor
- Baudrate: 9600 (o el configurado)
- 8 bits, No parity, 1 stop bit (8N1)

### Implementar Debug Logger

**debug.h:**
```c
#ifndef DEBUG_H
#define DEBUG_H

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>

// Niveles de log
typedef enum {
    LOG_LEVEL_DEBUG,
    LOG_LEVEL_INFO,
    LOG_LEVEL_WARNING,
    LOG_LEVEL_ERROR
} LogLevel_t;

// Macros de logging
#define LOG_DEBUG(msg)    debug_Log(LOG_LEVEL_DEBUG, __FILE__, __LINE__, msg)
#define LOG_INFO(msg)     debug_Log(LOG_LEVEL_INFO, __FILE__, __LINE__, msg)
#define LOG_WARNING(msg)  debug_Log(LOG_LEVEL_WARNING, __FILE__, __LINE__, msg)
#define LOG_ERROR(msg)    debug_Log(LOG_LEVEL_ERROR, __FILE__, __LINE__, msg)

// Con formato
#define LOG_DEBUG_F(fmt, ...)    debug_LogF(LOG_LEVEL_DEBUG, __FILE__, __LINE__, fmt, __VA_ARGS__)
#define LOG_INFO_F(fmt, ...)     debug_LogF(LOG_LEVEL_INFO, __FILE__, __LINE__, fmt, __VA_ARGS__)
#define LOG_WARNING_F(fmt, ...)  debug_LogF(LOG_LEVEL_WARNING, __FILE__, __LINE__, fmt, __VA_ARGS__)
#define LOG_ERROR_F(fmt, ...)    debug_LogF(LOG_LEVEL_ERROR, __FILE__, __LINE__, fmt, __VA_ARGS__)

// Funciones
void debug_Init(void);
void debug_Log(LogLevel_t level, const char* file, int line, const char* msg);
void debug_LogF(LogLevel_t level, const char* file, int line, const char* fmt, ...);
void debug_SetLevel(LogLevel_t min_level);

#endif
```

**debug.c:**
```c
#include "debug.h"
#include "uart_uart1.h"  // UART del proyecto
#include <stdarg.h>

static LogLevel_t min_log_level = LOG_LEVEL_DEBUG;

void debug_Init(void) {
    uart1_WriteString("\r\n");
    uart1_WriteString("===========================================\r\n");
    uart1_WriteString("  DEBUG LOGGER INITIALIZED\r\n");
    uart1_WriteString("===========================================\r\n");
}

void debug_SetLevel(LogLevel_t min_level) {
    min_log_level = min_level;
}

void debug_Log(LogLevel_t level, const char* file, int line, const char* msg) {
    if (level < min_log_level) {
        return;  // Filtrar logs por nivel
    }

    char buffer[128];
    const char* level_str;

    // Determinar string del nivel
    switch (level) {
        case LOG_LEVEL_DEBUG:   level_str = "DEBUG"; break;
        case LOG_LEVEL_INFO:    level_str = "INFO "; break;
        case LOG_LEVEL_WARNING: level_str = "WARN "; break;
        case LOG_LEVEL_ERROR:   level_str = "ERROR"; break;
        default:                level_str = "?????"; break;
    }

    // Formatear mensaje
    sprintf(buffer, "[%s] %s:%d - %s\r\n", level_str, file, line, msg);
    uart1_WriteString(buffer);
}

void debug_LogF(LogLevel_t level, const char* file, int line, const char* fmt, ...) {
    if (level < min_log_level) {
        return;
    }

    char msg_buffer[128];
    char full_buffer[196];
    const char* level_str;

    // Determinar string del nivel
    switch (level) {
        case LOG_LEVEL_DEBUG:   level_str = "DEBUG"; break;
        case LOG_LEVEL_INFO:    level_str = "INFO "; break;
        case LOG_LEVEL_WARNING: level_str = "WARN "; break;
        case LOG_LEVEL_ERROR:   level_str = "ERROR"; break;
        default:                level_str = "?????"; break;
    }

    // Formatear mensaje con argumentos variables
    va_list args;
    va_start(args, fmt);
    vsprintf(msg_buffer, fmt, args);
    va_end(args);

    // Formatear mensaje completo
    sprintf(full_buffer, "[%s] %s:%d - %s\r\n", level_str, file, line, msg_buffer);
    uart1_WriteString(full_buffer);
}
```

### Ejemplo de Uso

```c
#include "debug.h"

void EMIC_INIT_USER(void) {
    debug_Init();

    LOG_INFO("System initialization started");

    // Inicializar sensor
    if (temp_sensor_Init()) {
        LOG_INFO("Temperature sensor initialized");
    } else {
        LOG_ERROR("Failed to initialize temperature sensor");
    }

    LOG_INFO_F("System clock: %lu Hz", FCY);
    LOG_INFO_F("UART baud rate: %d", 9600);
}

void EMIC_LOOP_USER(void) {
    if (timer1_HasElapsed()) {
        LOG_DEBUG("Timer1 elapsed, reading sensor...");

        if (temp_sensor_Read()) {
            float temp = temp_sensor_GetTemperature();
            LOG_INFO_F("Temperature: %.1f C", temp);

            if (temp > 30.0f) {
                LOG_WARNING_F("High temperature detected: %.1f C", temp);
            }
        } else {
            LOG_ERROR("Sensor read failed");
        }

        timer1_Restart();
    }
}
```

### Salida en Terminal Serial

```
===========================================
  DEBUG LOGGER INITIALIZED
===========================================
[INFO ] userFncFile.c:45 - System initialization started
[INFO ] userFncFile.c:50 - Temperature sensor initialized
[INFO ] userFncFile.c:54 - System clock: 16000000 Hz
[INFO ] userFncFile.c:55 - UART baud rate: 9600
[DEBUG] userFncFile.c:61 - Timer1 elapsed, reading sensor...
[INFO ] userFncFile.c:65 - Temperature: 22.3 C
[DEBUG] userFncFile.c:61 - Timer1 elapsed, reading sensor...
[INFO ] userFncFile.c:65 - Temperature: 22.4 C
[DEBUG] userFncFile.c:61 - Timer1 elapsed, reading sensor...
[INFO ] userFncFile.c:65 - Temperature: 30.5 C
[WARN ] userFncFile.c:68 - High temperature detected: 30.5 C
```

### Técnicas Avanzadas de UART Debugging

**1. Dump de Variables:**
```c
void debug_DumpState(void) {
    LOG_INFO("=== SYSTEM STATE DUMP ===");
    LOG_INFO_F("Current temp: %.1f C", current_temp);
    LOG_INFO_F("Target temp: %.1f C", target_temp);
    LOG_INFO_F("Heater: %s", heater_IsOn() ? "ON" : "OFF");
    LOG_INFO_F("Fan speed: %d%%", fan_GetSpeed());
    LOG_INFO_F("Uptime: %lu seconds", getSystemMilis() / 1000);
    LOG_INFO("========================");
}
```

**2. Profiling Básico:**
```c
void debug_ProfileFunction(void) {
    uint32_t start_time = getSystemMilis();

    // Función a perfilar
    ComplexCalculation();

    uint32_t end_time = getSystemMilis();
    LOG_INFO_F("ComplexCalculation took %lu ms", end_time - start_time);
}
```

**3. Tracing de Flujo:**
```c
#define TRACE_ENTER() LOG_DEBUG(">>> ENTER")
#define TRACE_EXIT()  LOG_DEBUG("<<< EXIT")

void MyFunction(void) {
    TRACE_ENTER();

    // ... código ...

    TRACE_EXIT();
}
```

---

## Debugging con LEDs

Los LEDs son una forma **simple y efectiva** de debugging sin hardware adicional.

### Patrón: LEDs de Estado

```c
// LEDs de debugging
#define DEBUG_LED_ERROR     led_red
#define DEBUG_LED_WARNING   led_yellow
#define DEBUG_LED_OK        led_green

void debug_ShowError(void) {
    DEBUG_LED_ERROR_On();
    DEBUG_LED_WARNING_Off();
    DEBUG_LED_OK_Off();
}

void debug_ShowWarning(void) {
    DEBUG_LED_ERROR_Off();
    DEBUG_LED_WARNING_On();
    DEBUG_LED_OK_Off();
}

void debug_ShowOK(void) {
    DEBUG_LED_ERROR_Off();
    DEBUG_LED_WARNING_Off();
    DEBUG_LED_OK_On();
}
```

### Patrón: LED de Heartbeat

```c
// Heartbeat para verificar que el programa no se colgó
void EMIC_LOOP_USER(void) {
    static uint32_t last_heartbeat = 0;

    // Toggle LED cada 500ms
    if (getSystemMilis() - last_heartbeat > 500) {
        led_heartbeat_Toggle();
        last_heartbeat = getSystemMilis();
    }

    // Resto del código...
}
```

Si el LED deja de parpadear → **el MCU se colgó**

### Patrón: Códigos de Parpadeo

```c
typedef enum {
    ERROR_CODE_NONE = 0,
    ERROR_CODE_SENSOR_FAIL = 1,     // 1 parpadeo
    ERROR_CODE_COMM_FAIL = 2,       // 2 parpadeos
    ERROR_CODE_HARDWARE_FAIL = 3,   // 3 parpadeos
    ERROR_CODE_CONFIG_FAIL = 4      // 4 parpadeos
} ErrorCode_t;

void debug_BlinkError(ErrorCode_t code) {
    for (uint8_t i = 0; i < code; i++) {
        led_error_On();
        __delay_ms(200);
        led_error_Off();
        __delay_ms(200);
    }
    __delay_ms(1000);  // Pausa larga entre repeticiones
}

// Uso:
if (!sensor_Init()) {
    while(1) {
        debug_BlinkError(ERROR_CODE_SENSOR_FAIL);
    }
}
```

---

## MPLAB X Debugger

MPLAB X con un **PICkit 3/4 o ICD** permite debugging profesional.

### Configuración del Debugger

**1. Conectar Hardware:**
```
PICkit 4:
  Pin 1 (MCLR) → MCU MCLR
  Pin 2 (VDD)  → MCU VDD
  Pin 3 (VSS)  → MCU VSS
  Pin 4 (PGD)  → MCU PGD
  Pin 5 (PGC)  → MCU PGC
```

**2. Configurar MPLAB X:**
```
Project Properties → Conf: [default] → PICkit 4
  ✅ Power target circuit from PICkit 4
  Voltage: 3.3V
  Communication speed: Medium
```

**3. Build para Debug:**
```bash
# En MPLAB X
Production → Build for Debugging

# O desde línea de comandos
make TYPE=DEBUG
```

### Funciones del Debugger

**1. Breakpoints:**
```c
void EMIC_LOOP_USER(void) {
    if (timer1_HasElapsed()) {
        // Colocar breakpoint aquí (F9)
        float temp = temp_sensor_GetTemperature();

        if (temp > threshold) {
            heater_Off();  // Breakpoint aquí para verificar
        }

        timer1_Restart();
    }
}
```

**2. Step Execution:**
- **F7**: Step Into (entra en funciones)
- **F8**: Step Over (ejecuta función completa)
- **Ctrl+F7**: Step Out (sale de función actual)
- **F5**: Continue (hasta próximo breakpoint)

**3. Watch Variables:**
```
Window → Debugging → Variables

Añadir a Watch:
- current_temp
- target_temp
- heater_state
- fan_speed
```

**4. Memory View:**
```
Window → PIC Memory Views → File Registers

Inspeccionar:
- Stack Pointer (SP)
- Program Counter (PC)
- Registros periféricos (TRISA, LATA, etc.)
```

### Ejemplo de Sesión de Debugging

**Problema:** El heater no se apaga cuando la temperatura supera el umbral.

**Debugging:**
```c
void UpdateThermostatState(void) {
    // Breakpoint 1: Verificar valores
    float temp_high = target_temp + HYSTERESIS;

    // Breakpoint 2: Verificar condición
    if (current_temp > temp_high) {
        // Breakpoint 3: Verificar que se ejecuta
        heater_Off();

        // Breakpoint 4: Verificar llamada
        led_hot_On();
    }
}
```

**Watch:**
```
current_temp = 32.5
target_temp = 22.0
HYSTERESIS = 2.0
temp_high = 24.0

✅ current_temp (32.5) > temp_high (24.0)  → Condición TRUE
```

**Hallazgo:** El código se ejecuta, pero `heater_Off()` no funciona.

**Siguiente paso:** Step Into `heater_Off()` para ver qué pasa dentro.

---

## Testing de APIs

### Testing Manual

**Crear proyecto de testing:**
```c
// test_button_api.c
#include "button_test_btn.h"
#include "uart_uart1.h"

void EMIC_INIT_USER(void) {
    uart1_WriteString("=== Button API Test ===\r\n");
}

void EMIC_LOOP_USER(void) {
    // Test 1: IsPressed
    if (test_btn_IsPressed()) {
        uart1_WriteString("[TEST] Button is pressed\r\n");
    }

    // Test 2: WasPressed (edge detection)
    if (test_btn_WasPressed()) {
        uart1_WriteString("[TEST] Button WAS pressed (edge)\r\n");
    }
}
```

**Checklist de Testing:**
- ✅ Presionar y mantener → IsPressed retorna true
- ✅ Presionar y soltar → WasPressed retorna true UNA vez
- ✅ Debounce funciona (presiones rápidas no generan múltiples eventos)
- ✅ Múltiples instancias funcionan independientemente

### Testing Automatizado (Concept)

```c
// test_framework.h
typedef bool (*TestFunction)(void);

typedef struct {
    const char* name;
    TestFunction function;
} TestCase_t;

bool test_runner_Run(const TestCase_t* tests, uint8_t count);

// test_button.c
bool test_ButtonInit(void) {
    // Test que la inicialización funciona
    test_btn_Init();
    return true;  // Verificar que no crashea
}

bool test_ButtonIsPressed(void) {
    // Simular presión (si es posible)
    // Verificar que IsPressed retorna true
    // ...
    return true;
}

const TestCase_t button_tests[] = {
    {"Button Init", test_ButtonInit},
    {"Button IsPressed", test_ButtonIsPressed},
    // ...
};

void EMIC_INIT_USER(void) {
    uart1_WriteString("=== Running Button Tests ===\r\n");
    bool success = test_runner_Run(button_tests, 2);

    if (success) {
        uart1_WriteString("✅ All tests passed!\r\n");
    } else {
        uart1_WriteString("❌ Some tests failed!\r\n");
    }
}
```

---

## Testing de Módulos

### Testing de Módulo Completo

**Caso:** Testing del módulo SmartThermostat

**Test Plan:**
```
1. Verificar inicialización
   - Todos los componentes inician correctamente
   - Display muestra mensaje inicial
   - UART envía log de inicio

2. Verificar lectura de sensor
   - Sensor responde
   - Temperatura se lee correctamente
   - Logs se envían

3. Verificar control de temperatura
   - Modo COOLING: ventilador ON cuando temp > threshold
   - Modo HEATING: heater ON cuando temp < threshold
   - Modo NORMAL: todo OFF cuando temp dentro de rango

4. Verificar interfaz usuario
   - Botones funcionan
   - Display actualiza correctamente
   - LEDs indican estado correcto

5. Testing de límites
   - Temperatura muy alta (>50°C)
   - Temperatura muy baja (<0°C)
   - Cambios bruscos de temperatura
```

### Test Harness

```c
// test_thermostat.c

typedef enum {
    TEST_RESULT_PASS,
    TEST_RESULT_FAIL,
    TEST_RESULT_SKIP
} TestResult_t;

TestResult_t test_Initialization(void) {
    LOG_INFO("TEST: Initialization");

    // Verificar sensor
    if (!temp_sensor_IsReady()) {
        LOG_ERROR("TEST FAIL: Sensor not ready");
        return TEST_RESULT_FAIL;
    }

    // Verificar display
    display_Clear();
    display_Print("TEST");
    __delay_ms(1000);

    // Verificar UART
    uart1_WriteString("TEST\r\n");

    LOG_INFO("TEST PASS: Initialization");
    return TEST_RESULT_PASS;
}

TestResult_t test_TemperatureReading(void) {
    LOG_INFO("TEST: Temperature Reading");

    // Leer sensor 10 veces
    for (uint8_t i = 0; i < 10; i++) {
        if (!temp_sensor_Read()) {
            LOG_ERROR_F("TEST FAIL: Read failed (attempt %d)", i);
            return TEST_RESULT_FAIL;
        }

        float temp = temp_sensor_GetTemperature();
        LOG_INFO_F("Reading %d: %.1f C", i, temp);

        // Verificar rango razonable
        if (temp < -20.0f || temp > 60.0f) {
            LOG_ERROR_F("TEST FAIL: Temperature out of range: %.1f", temp);
            return TEST_RESULT_FAIL;
        }

        __delay_ms(500);
    }

    LOG_INFO("TEST PASS: Temperature Reading");
    return TEST_RESULT_PASS;
}

TestResult_t test_HeatingMode(void) {
    LOG_INFO("TEST: Heating Mode");

    // Simular temperatura baja
    // (requiere sensor mock o ambiente frío)

    // Verificar que heater se activa
    __delay_ms(5000);

    if (!heater_IsOn()) {
        LOG_ERROR("TEST FAIL: Heater should be ON");
        return TEST_RESULT_FAIL;
    }

    LOG_INFO("TEST PASS: Heating Mode");
    return TEST_RESULT_PASS;
}

void EMIC_INIT_USER(void) {
    debug_Init();

    LOG_INFO("========================================");
    LOG_INFO("  THERMOSTAT MODULE TEST SUITE");
    LOG_INFO("========================================");

    uint8_t passed = 0;
    uint8_t failed = 0;

    // Test 1
    if (test_Initialization() == TEST_RESULT_PASS) {
        passed++;
    } else {
        failed++;
    }

    // Test 2
    if (test_TemperatureReading() == TEST_RESULT_PASS) {
        passed++;
    } else {
        failed++;
    }

    // Test 3
    if (test_HeatingMode() == TEST_RESULT_PASS) {
        passed++;
    } else {
        failed++;
    }

    // Resumen
    LOG_INFO("========================================");
    LOG_INFO_F("TESTS PASSED: %d", passed);
    LOG_INFO_F("TESTS FAILED: %d", failed);
    LOG_INFO("========================================");
}
```

---

## Testing de Integración

Testing de **múltiples módulos** trabajando juntos.

### Caso: Sistema IoT con 3 Módulos

```
SensorModule + CommunicationModule + DisplayModule
```

**Test de Integración:**
```c
void test_Integration_SensorToDisplay(void) {
    LOG_INFO("TEST: Sensor → Display");

    // Leer sensor (SensorModule)
    float temp = sensor_GetTemperature();

    // Mostrar en display (DisplayModule)
    char buffer[32];
    sprintf(buffer, "Temp: %.1f C", temp);
    display_Print(buffer);

    // Verificar que se muestra correctamente
    __delay_ms(2000);

    LOG_INFO("TEST PASS: Sensor → Display");
}

void test_Integration_SensorToCommunication(void) {
    LOG_INFO("TEST: Sensor → Communication");

    // Leer sensor
    float temp = sensor_GetTemperature();

    // Enviar por comunicación (CommunicationModule)
    char message[64];
    sprintf(message, "{\"temperature\":%.1f}", temp);
    comm_SendMessage(message);

    // Verificar respuesta
    __delay_ms(1000);
    if (comm_HasResponse()) {
        const char* response = comm_GetResponse();
        LOG_INFO_F("Response: %s", response);
    }

    LOG_INFO("TEST PASS: Sensor → Communication");
}

void test_Integration_FullPipeline(void) {
    LOG_INFO("TEST: Full Pipeline (Sensor → Processing → Display + Comm)");

    // Pipeline completo
    float temp = sensor_GetTemperature();

    // Procesar
    if (temp > 30.0f) {
        alert_Trigger(ALERT_HIGH_TEMP);
    }

    // Mostrar
    display_ShowTemperature(temp);

    // Comunicar
    comm_SendTelemetry(temp);

    // Verificar consistencia
    LOG_INFO("TEST PASS: Full Pipeline");
}
```

---

## Errores Comunes EMIC

### Error 1: Variable No Sustituida

**Síntoma:**
```c
void led_.{name}._Init(void) { ... }
```

**Causa:** Parámetro no definido

**Solución:**
```emic
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led1,pin=A0_Pin)
```

### Error 2: Multiple Definition

**Síntoma:**
```
error: multiple definition of 'led_Init'
```

**Causa:** Dos instancias con el mismo nombre

**Solución:**
```emic
# ANTES:
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led,pin=A0_Pin)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led,pin=A1_Pin)

# DESPUÉS:
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led1,pin=A0_Pin)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic,name=led2,pin=A1_Pin)
```

### Error 3: Implicit Declaration

**Síntoma:**
```
warning: implicit declaration of function 'led1_Toggle'
```

**Causa:** Falta include

**Solución:**
```c
// userFncFile.h
#include "led_led1.h"
```

### Error 4: MCU Resetea Constantemente

**Síntoma:** MCU se resetea cada pocos segundos

**Posibles causas:**
1. **Watchdog Timer** no deshabilitado
2. **Stack overflow**
3. **Voltage brownout**

**Diagnóstico:**
```c
// Verificar causa de reset
if (RCONbits.SWR) {
    LOG_WARNING("Reset: Software");
}
if (RCONbits.WDTO) {
    LOG_WARNING("Reset: Watchdog Timeout");
}
if (RCONbits.BOR) {
    LOG_WARNING("Reset: Brown-out");
}

// Clear flags
RCON = 0;
```

**Solución:**
```c
// Deshabilitar watchdog en config bits
#pragma config FWDTEN = OFF
```

---

## Casos Prácticos de Debugging

### Caso 1: Sensor No Responde

**Problema:** Sensor DHT22 no responde, siempre retorna false.

**Debugging:**
```c
bool temp_sensor_Read(void) {
    LOG_DEBUG("Attempting to read DHT22...");

    // Verificar pin
    LOG_DEBUG_F("Pin state: %d", HAL_GPIO_PinGet(DHT22_PIN));

    // Enviar start signal
    HAL_GPIO_PinSet(DHT22_PIN, GPIO_LOW);
    LOG_DEBUG("Start signal sent (LOW)");
    __delay_ms(18);

    HAL_GPIO_PinSet(DHT22_PIN, GPIO_HIGH);
    LOG_DEBUG("Start signal released (HIGH)");
    __delay_us(40);

    // Esperar respuesta
    uint16_t timeout = 0;
    while (HAL_GPIO_PinGet(DHT22_PIN) == GPIO_HIGH) {
        __delay_us(1);
        timeout++;
        if (timeout > 100) {
            LOG_ERROR("Timeout waiting for sensor response");
            return false;
        }
    }

    LOG_DEBUG("Sensor responded!");
    // ...
}
```

**Hallazgo:** Timeout siempre ocurre → Sensor no responde

**Verificación de hardware:**
- ✅ Sensor conectado correctamente
- ✅ Alimentación (3.3V o 5V)
- ❌ Pull-up resistor faltante (4.7kΩ)

**Solución:** Añadir resistor pull-up de 4.7kΩ entre DATA y VDD

### Caso 2: Display LCD Muestra Caracteres Extraños

**Problema:** LCD muestra basura en lugar de texto legible.

**Debugging:**
```c
void lcd_Init(void) {
    LOG_DEBUG("Initializing LCD...");

    // Verificar pines
    LOG_DEBUG_F("RS pin: %d", LCD_RS_PIN);
    LOG_DEBUG_F("EN pin: %d", LCD_EN_PIN);

    // Delay inicial
    __delay_ms(50);
    LOG_DEBUG("Initial delay done");

    // Secuencia de inicialización
    lcd_SendCommand(0x33);
    LOG_DEBUG("CMD: 0x33");
    __delay_ms(5);

    lcd_SendCommand(0x32);
    LOG_DEBUG("CMD: 0x32");
    __delay_ms(5);

    // ...
}
```

**Hallazgo:** Los comandos se envían muy rápido

**Solución:** Aumentar delays entre comandos
```c
__delay_ms(5);  // ANTES: __delay_us(100)
```

### Caso 3: UART No Envía Datos

**Problema:** Terminal serial no muestra nada.

**Debugging:**
```c
void uart1_Init(void) {
    // Verificar baudrate
    uint16_t brg = (FCY / (16UL * 9600UL)) - 1;
    LOG_DEBUG_F("UART BRG calculated: %d", brg);
    U1BRG = brg;

    // Verificar pines
    LOG_DEBUG_F("TX pin: %d", UART_TX_PIN);
    LOG_DEBUG_F("RX pin: %d", UART_RX_PIN);

    // Habilitar UART
    U1MODEbits.UARTEN = 1;
    U1STAbits.UTXEN = 1;

    LOG_DEBUG("UART initialized");

    // Test de transmisión
    uart1_WriteString("TEST\r\n");
}
```

**Verificaciones:**
- ✅ Baudrate correcto
- ✅ Pines mapeados correctamente
- ❌ FCY mal configurado (8MHz en lugar de 16MHz)

**Solución:** Configurar correctamente el clock
```c
// config_bits.h
#pragma config POSCMOD = HS      // HS Oscillator
#pragma config FNOSC = PRIPLL    // Primary Oscillator with PLL
#pragma config FPLLMUL = MUL_4   // 8MHz * 4 = 32MHz
#pragma config FPLLIDIV = DIV_2  // 32MHz / 2 = 16MHz
```

---

## Buenas Prácticas

### 1. Logging Estructurado

```c
✅ BUENO:
LOG_INFO_F("[SENSOR] Temperature: %.1f C", temp);
LOG_ERROR_F("[COMM] Failed to send (error code: %d)", error_code);

❌ MALO:
uart1_WriteString("temp is ");
uart1_WriteString(temp_str);
```

### 2. Assert para Verificar Invariantes

```c
#define ASSERT(condition, msg) \
    if (!(condition)) { \
        LOG_ERROR_F("ASSERTION FAILED: %s", msg); \
        while(1) { led_error_Toggle(); __delay_ms(100); } \
    }

// Uso:
void SetTemperature(float temp) {
    ASSERT(temp >= -40.0f && temp <= 85.0f, "Temperature out of valid range");
    current_temp = temp;
}
```

### 3. Versionado de Firmware

```c
#define FIRMWARE_VERSION "1.2.3"
#define BUILD_DATE __DATE__
#define BUILD_TIME __TIME__

void EMIC_INIT_USER(void) {
    LOG_INFO("========================================");
    LOG_INFO_F("Firmware: %s", FIRMWARE_VERSION);
    LOG_INFO_F("Build: %s %s", BUILD_DATE, BUILD_TIME);
    LOG_INFO("========================================");
}
```

### 4. Estado del Sistema Persistente

```c
// Guardar estado antes de reset
void SaveSystemState(void) {
    eeprom_Write(ADDR_LAST_TEMP, current_temp);
    eeprom_Write(ADDR_UPTIME, uptime_seconds);
    eeprom_Write(ADDR_ERROR_COUNT, error_count);
}

// Recuperar estado después de reset
void RestoreSystemState(void) {
    current_temp = eeprom_Read(ADDR_LAST_TEMP);
    uptime_seconds = eeprom_Read(ADDR_UPTIME);
    error_count = eeprom_Read(ADDR_ERROR_COUNT);

    LOG_INFO("System state restored from EEPROM");
}
```

### 5. Telemetría para Debugging Remoto

```c
typedef struct {
    float temperature;
    bool heater_on;
    uint8_t fan_speed;
    uint32_t uptime;
    uint16_t error_count;
    uint16_t reset_count;
} Telemetry_t;

void SendTelemetry(void) {
    Telemetry_t data = {
        .temperature = current_temp,
        .heater_on = heater_IsOn(),
        .fan_speed = fan_GetSpeed(),
        .uptime = getSystemSeconds(),
        .error_count = error_count,
        .reset_count = reset_count
    };

    // Enviar como JSON
    char json[256];
    sprintf(json,
        "{\"temp\":%.1f,\"heater\":%d,\"fan\":%d,\"uptime\":%lu,\"errors\":%d}",
        data.temperature,
        data.heater_on,
        data.fan_speed,
        data.uptime,
        data.error_count
    );

    comm_SendMessage(json);
}
```

---

## Resumen del Capítulo

### Lo que Aprendiste

1. **Tres niveles de debugging**
   - Generación (EMIC-Generate)
   - Compilación (XC Compiler)
   - Runtime (Hardware)

2. **Herramientas esenciales**
   - generate.txt (log de generación)
   - UART (logging en runtime)
   - LEDs (debugging visual)
   - MPLAB X Debugger (breakpoints, step)

3. **Técnicas de debugging**
   - Logger estructurado con niveles
   - Heartbeat LED
   - Códigos de error con parpadeos
   - Assert para invariantes
   - Profiling básico

4. **Testing**
   - Testing manual de APIs
   - Testing de módulos completos
   - Testing de integración
   - Test harness y automation

5. **Errores comunes**
   - Variables no sustituidas
   - Multiple definitions
   - Implicit declarations
   - MCU resets (watchdog, stack overflow)

### Herramientas por Nivel

| Nivel | Herramienta | Propósito |
|-------|-------------|-----------|
| **Generación** | generate.txt | Log de EMIC-Generate |
| **Compilación** | MPLAB X | Mensajes de compilador |
| **Runtime** | UART | Logging estructurado |
| **Runtime** | LEDs | Debugging visual |
| **Runtime** | MPLAB X Debugger | Breakpoints, step, watch |
| **Hardware** | Osciloscopio | Señales digitales/analógicas |

### Checklist de Debugging

**Antes de pedir ayuda:**
- ✅ Revisar generate.txt
- ✅ Compilar sin warnings
- ✅ Verificar que el código se ejecuta (heartbeat LED)
- ✅ Añadir logs UART para diagnosticar
- ✅ Verificar conexiones de hardware
- ✅ Verificar alimentación y voltajes
- ✅ Probar componentes individualmente

### Próximos Pasos

En los siguientes capítulos aprenderás:
- **Cap 25**: Integración de Componentes (sistemas complejos)
- **Cap 26**: Deployment y Producción (publicar y mantener)

---

**¡Felicitaciones!** Ahora dominas técnicas profesionales de debugging y testing para sistemas embebidos EMIC. Estas habilidades son **críticas** para el éxito en proyectos reales.

**Recuerda**: Un buen desarrollador pasa 30% del tiempo coding y 70% debugging. **Un excelente desarrollador** invierte tiempo en herramientas de debugging que reducen ese 70% a 30%.

---

**Sección 4 - Capítulo 24**
Manual de Desarrollo EMIC SDK
Versión 1.0.0

---
