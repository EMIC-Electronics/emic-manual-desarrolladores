# Capitulo 09b: Carpeta `_hal/` - Abstraccion de APIs del Browser

[<- Anterior: Carpeta _hal (Embebido)](09_Carpeta_HAL.md) | [Siguiente: Carpeta _hard ->](10_Carpeta_Hard.md)

---

## Contenido del Capitulo

1. [Que es el HAL en el Dashboard SDK](#1-que-es-el-hal-en-el-dashboard-sdk)
2. [Por que no existe _hard/ en Dashboard](#2-por-que-no-existe-_hard-en-dashboard)
3. [Las 8 Browser APIs Abstraidas](#3-las-8-browser-apis-abstraidas)
4. [Estructura de un HAL de Browser](#4-estructura-de-un-hal-de-browser)
5. [HAL vs Connector vs Widget](#5-hal-vs-connector-vs-widget)
6. [Ejemplos de HAL Reales](#6-ejemplos-de-hal-reales)
7. [Creacion de Nuevos HALs](#7-creacion-de-nuevos-hals)
8. [Tabla de Equivalencias Embebido vs Dashboard](#8-tabla-de-equivalencias-embebido-vs-dashboard)

---

## 1. Que es el HAL en el Dashboard SDK

### 1.1 Definicion Conceptual

En el SDK embebido, el HAL (Hardware Abstraction Layer) abstrae **perifericos internos del microcontrolador** (GPIO, SPI, I2C, UART). En el Dashboard SDK, el HAL cumple el **mismo proposito arquitectonico** pero abstrae **APIs nativas del navegador** en lugar de registros de hardware.

```
EMBEBIDO                              DASHBOARD
=========                             =========

HAL abstrae                           HAL abstrae
perifericos del MCU                   APIs del Browser
      |                                     |
GPIO, SPI, I2C, UART                 Fetch, WebSocket, Storage
Timer, ADC, PWM                       Notifications, Geolocation
      |                                     |
Delega a _hard/{MCU}/                 NO delega (browser ES el hardware)
```

### 1.2 Proposito: Interfaz Uniforme

El HAL del Dashboard proporciona wrappers simplificados y consistentes sobre las APIs del navegador. Esto permite que los **Connectors** (capa media) y **Widgets** (capa alta) no dependan directamente de las APIs nativas, facilitando:

- **Consistencia**: Todas las llamadas HTTP pasan por el mismo wrapper, con manejo de errores uniforme
- **Reusabilidad**: Logica comun (reintentos, timeouts, reconexion) centralizada en el HAL
- **Testabilidad**: Facil de mockear en pruebas unitarias
- **Evolucion**: Si una API del navegador cambia o se depreca, solo se actualiza el HAL

### 1.3 Analogia Visual

```
+----------------------------------------------------+
|  EMBEBIDO: HAL oculta diferencias entre MCUs        |
|                                                      |
|  HAL_GPIO_PinSet(LED, HIGH)                          |
|      -> PIC24: LATAbits.LATA0 = 1                   |
|      -> STM32: GPIOA->BSRR = (1 << 0)               |
|      -> AVR:   PORTA |= (1 << 0)                    |
+----------------------------------------------------+

+----------------------------------------------------+
|  DASHBOARD: HAL oculta complejidad de Browser APIs  |
|                                                      |
|  HAL_Fetch_get(url, callback)                        |
|      -> fetch(url, { method: 'GET', ... })           |
|         .then(r => r.json())                         |
|         .then(callback)                              |
|         .catch(errorHandler)                         |
+----------------------------------------------------+
```

En embebido, el HAL oculta **diferencias entre MCUs**. En Dashboard, el HAL oculta **complejidad de las APIs nativas** del navegador, agregando manejo de errores, reintentos y configuracion uniforme.

---

## 2. Por que no existe _hard/ en Dashboard

### 2.1 El Rol de _hard/ en Embebido

En el SDK embebido, `_hard/` contiene **codigo especifico de cada familia de microcontrolador**:

```
_hard/
  pic24FJ64GA002/       <-- Registros de PIC24
  PIC32MZ2048EFM064/    <-- Registros de PIC32
  dsPIC33EP512MC806/    <-- Registros de dsPIC33
  STM32F407VG/          <-- Registros de ARM Cortex-M4
```

El HAL embebido **delega** a `_hard/` segun la macro `system.ucName`:

```emic
EMIC:setInput(DEV:_hard/.{system.ucName}./GPIO/gpio.emic)
```

### 2.2 Por que Dashboard no necesita _hard/

```
+------------------------------------------------------+
|  EMBEBIDO: Multiples "hardwares" (MCUs)               |
|                                                        |
|  PIC24        PIC32       dsPIC33      STM32           |
|  16-bit       32-bit      16-bit+DSP   ARM Cortex     |
|  XC16         XC32        XC16         GCC ARM         |
|  Registros    Registros   Registros    Registros       |
|  diferentes   diferentes  diferentes   diferentes      |
|                                                        |
|  --> NECESITA _hard/ para aislar diferencias           |
+------------------------------------------------------+

+------------------------------------------------------+
|  DASHBOARD: UN solo "hardware" (el Browser)            |
|                                                        |
|  Chrome       Firefox     Safari       Edge            |
|  V8           SpiderMonkey JavaScriptCore V8            |
|                                                        |
|  Todos implementan las MISMAS Web APIs estandar:       |
|  - Fetch API                                           |
|  - WebSocket API                                       |
|  - localStorage / IndexedDB                            |
|  - Notification API                                    |
|  - Geolocation API                                     |
|                                                        |
|  --> NO NECESITA _hard/ (APIs ya son estandar)         |
+------------------------------------------------------+
```

**Razones concretas:**

| Aspecto | Embebido | Dashboard |
|---------|----------|-----------|
| **Plataformas** | Multiples MCUs con registros diferentes | Un browser con APIs estandar |
| **Variabilidad** | Alta (PIC vs ARM vs AVR) | Baja (todos siguen W3C/WHATWG) |
| **Compiladores** | Diferentes (XC16, XC32, GCC) | Uno (JavaScript engine) |
| **Abstraccion necesaria** | Ocultar registros de MCU | Simplificar APIs complejas |
| **Carpeta _hard/** | NECESARIA | NO NECESARIA |

### 2.3 Estructura Resultante del Dashboard

```
EMBEBIDO                        DASHBOARD
========                        =========

_hal/GPIO/                      _hal/Fetch/
  gpio.emic                       fetch.emic
  (delega a _hard/)                src/hal-fetch.js

_hard/PIC24/GPIO/               (no existe _hard/)
  inc/gpio.h
  gpio.emic
```

En el Dashboard SDK, el HAL **implementa directamente** el wrapper en JavaScript. No existe una segunda capa de delegacion porque no hay variabilidad de "hardware" que abstraer.

---

## 3. Las 8 Browser APIs Abstraidas

### 3.1 Listado Completo

El Dashboard SDK abstrae las siguientes APIs nativas del navegador:

| # | HAL | Browser API Nativa | Analogia Embebida | Uso Tipico |
|---|-----|-------------------|-------------------|------------|
| 1 | **Fetch** | Fetch API / XMLHttpRequest | UART/SPI (request-response) | HTTP requests a APIs REST |
| 2 | **WebSocket** | WebSocket API | UART (full-duplex streaming) | Conexion bidireccional real-time |
| 3 | **Storage** | localStorage / IndexedDB | EEPROM / Flash NVS | Persistencia local de datos |
| 4 | **Notifications** | Notification API + Push | GPIO output (alertas) | Notificaciones del sistema |
| 5 | **Geolocation** | Geolocation API | Modulo GPS | Ubicacion del dispositivo |
| 6 | **WebBluetooth** | Web Bluetooth API | HAL Bluetooth / BLE | Conexion directa a dispositivos BT |
| 7 | **WebSerial** | Web Serial API | HAL UART | Conexion directa a puerto serial USB |
| 8 | **MediaDevices** | MediaDevices API | Modulo Camera | Acceso a camara/microfono |

### 3.2 Clasificacion por Funcion

```
+-----------------------------------------------------+
|         HALs POR TIPO DE FUNCION                     |
+-----------------------------------------------------+

  COMUNICACION REMOTA (25%)
      +-- Fetch (HTTP request-response)
      +-- WebSocket (streaming bidireccional)

  COMUNICACION LOCAL (25%)
      +-- WebBluetooth (BLE con dispositivos cercanos)
      +-- WebSerial (puerto serial USB)

  PERSISTENCIA Y SISTEMA (25%)
      +-- Storage (almacenamiento local)
      +-- Notifications (alertas al usuario)

  SENSORES Y MULTIMEDIA (25%)
      +-- Geolocation (posicion GPS)
      +-- MediaDevices (camara y microfono)
```

### 3.3 Que Agrega el HAL sobre la API Nativa

| HAL | Lo que agrega sobre la API nativa del browser |
|-----|-----------------------------------------------|
| **Fetch** | Reintentos automaticos, timeout configurable, headers por defecto, manejo de errores unificado |
| **WebSocket** | Reconexion automatica, heartbeat/ping, cola de mensajes offline, eventos EMIC |
| **Storage** | API unificada localStorage/IndexedDB, serialization/deserialization automatica, namespacing |
| **Notifications** | Solicitud de permisos simplificada, fallback a in-app si el browser lo deniega |
| **Geolocation** | Cache de ultima posicion, conversion de formatos, timeout simplificado |
| **WebBluetooth** | Escaneo simplificado, reconexion, lectura/escritura de caracteristicas con Promises |
| **WebSerial** | Parseo de lineas, buffer configurable, eventos de conexion/desconexion |
| **MediaDevices** | Seleccion de dispositivo simplificada, manejo de permisos, fallback a resolucion menor |

---

## 4. Estructura de un HAL de Browser

### 4.1 Estructura de Archivos

Cada HAL del Dashboard sigue esta estructura:

```
_hal/{BrowserAPI}/
    {api}.emic          <-- Registro, dependencias, copia a TARGET
    src/hal-{api}.js    <-- Implementacion del wrapper JavaScript
```

**Comparacion con embebido:**

```
EMBEBIDO                            DASHBOARD
========                            =========

_hal/GPIO/                          _hal/Fetch/
    gpio.emic                           fetch.emic
    (sin implementacion propia)         src/hal-fetch.js

_hard/PIC24/GPIO/                   (no existe _hard/)
    gpio.emic
    inc/gpio.h
    src/gpio.c
```

### 4.2 Contenido del Archivo .emic

El archivo `.emic` de cada HAL registra el componente y copia los archivos al TARGET:

```emic
EMIC:ifndef _HAL_FETCH_EMIC_
EMIC:define(_HAL_FETCH_EMIC_, true)

// Copiar implementacion a TARGET
EMIC:copy(src/hal-fetch.js > TARGET:js/hal/hal-fetch.js)

// Registrar modulo JavaScript
EMIC:define(js_modules.hal_fetch, hal-fetch)

EMIC:endif
```

**Elementos clave:**

| Elemento | Proposito |
|----------|-----------|
| `EMIC:ifndef` / `EMIC:endif` | Include guard (evita inclusion duplicada) |
| `EMIC:copy` | Copia el wrapper .js al directorio TARGET |
| `EMIC:define(js_modules.*)` | Registra el modulo para inclusion en el bundle |

### 4.3 Contenido del Archivo .js

El archivo JavaScript implementa el wrapper sobre la API nativa:

```javascript
// hal-fetch.js - Abstraccion de la Fetch API

const HAL_Fetch = {

    _defaultHeaders: {
        'Content-Type': 'application/json'
    },
    _timeout: 30000,
    _retries: 3,

    async get(url, options = {}) {
        return this._request('GET', url, null, options);
    },

    async post(url, body, options = {}) {
        return this._request('POST', url, body, options);
    },

    async _request(method, url, body, options) {
        const config = {
            method,
            headers: { ...this._defaultHeaders, ...options.headers },
            signal: AbortSignal.timeout(options.timeout || this._timeout)
        };
        if (body) config.body = JSON.stringify(body);

        for (let attempt = 0; attempt < (options.retries || this._retries); attempt++) {
            try {
                const response = await fetch(url, config);
                if (!response.ok) throw new Error(`HTTP ${response.status}`);
                return await response.json();
            } catch (error) {
                if (attempt === (options.retries || this._retries) - 1) throw error;
                await new Promise(r => setTimeout(r, 1000 * (attempt + 1)));
            }
        }
    }
};
```

---

## 5. HAL vs Connector vs Widget

### 5.1 Tabla Comparativa

| Aspecto | HAL | Connector | Widget |
|---------|-----|-----------|--------|
| **Nivel** | Bajo (abstraccion de plataforma) | Medio (logica de servicio) | Alto (interfaz visual) |
| **Visible al usuario** | NO | SI (pestana Services) | SI (pestana Widgets) |
| **DOXYGEN tags** | NO | SI (@fn, @alias) | SI (@fn, @alias) |
| **EMIC:tag()** | NO | SI | SI |
| **Accede a** | Browser API nativa | HAL | Connectors + HAL |
| **Implementacion** | JavaScript puro | JavaScript + HAL | HTML + CSS + JavaScript |
| **Ejemplo** | `hal-fetch.js` | `mqtt-client.js` | `emic-gauge.js` |

### 5.2 Diagrama de Relaciones

```
+----------------------------------------------------+
|                    WIDGETS                           |
|  Nivel mas alto: Componentes visuales               |
|                                                      |
|  Ejemplo: <emic-gauge value="25.3">                 |
|  - Componente visual interactivo                    |
|  - Visible en el editor, pestana Widgets            |
|  - Usa Connectors para obtener datos                |
+----------------------------------------------------+
                      | usa
                      v
+----------------------------------------------------+
|                  CONNECTORS                          |
|  Nivel medio: Logica de servicios                   |
|                                                      |
|  Ejemplo: MQTT_subscribe("sensor/temp", callback)   |
|  - Especifico del protocolo (MQTT, HTTP, etc.)      |
|  - Visible en el editor, pestana Services           |
|  - Usa HAL para comunicacion                        |
+----------------------------------------------------+
                      | usa
                      v
+----------------------------------------------------+
|                    HAL                               |
|  Nivel bajo: Wrappers de Browser APIs               |
|                                                      |
|  Ejemplo: HAL_WebSocket.connect(url)                |
|  - Generico (cualquier browser moderno)             |
|  - NO visible en el editor                          |
|  - Accede directamente a APIs nativas               |
+----------------------------------------------------+
                      | usa
                      v
+----------------------------------------------------+
|              BROWSER APIs NATIVAS                    |
|  fetch(), WebSocket(), localStorage, etc.           |
|                                                      |
|  Estandar W3C / WHATWG                              |
+----------------------------------------------------+
```

### 5.3 Ejemplo Completo: Leer un Sensor por MQTT

```
Widget (emic-gauge):
    Muestra valor del sensor en un indicador grafico
         |
    Escucha evento onMessage del Connector
         v
Connector (mqtt-client):
    MQTT_subscribe("sensor/temp", callback)
         |
    Necesita conexion WebSocket al broker MQTT
         v
HAL (hal-websocket):
    HAL_WebSocket.connect("wss://broker.example.com")
         |
    Wrapper sobre la API nativa WebSocket
         v
Browser API nativa:
    new WebSocket("wss://broker.example.com")
```

### 5.4 Comparacion con la Pila Embebida

```
EMBEBIDO                    DASHBOARD
========                    =========

Modulo                      Widget
  (solucion completa)         (componente visual)
        |                          |
API                         Connector
  (abstraccion funcional)     (logica de servicio)
        |                          |
Driver                      (no aplica)
  (chip externo)
        |                          |
HAL                         HAL
  (periferico MCU)            (Browser API)
        |                          |
_hard                       (no existe)
  (registros MCU)
        |                          |
MCU fisico                  Browser
```

---

## 6. Ejemplos de HAL Reales

### 6.1 Ejemplo 1: Fetch HAL (Comunicacion HTTP)

**Ubicacion:** `_hal/Fetch/`

**Archivo: fetch.emic**

```emic
EMIC:ifndef _HAL_FETCH_EMIC_
EMIC:define(_HAL_FETCH_EMIC_, true)

// Copiar wrapper a TARGET
EMIC:copy(src/hal-fetch.js > TARGET:js/hal/hal-fetch.js)

// Registrar modulo
EMIC:define(js_modules.hal_fetch, hal-fetch)

EMIC:endif
```

**Archivo: src/hal-fetch.js** (estructura esperada)

```javascript
// HAL Fetch - Abstraccion de HTTP requests
// Agrega: reintentos, timeout, headers por defecto, manejo de errores

const HAL_Fetch = {
    _defaultHeaders: { 'Content-Type': 'application/json' },
    _timeout: 30000,
    _retries: 3,

    async get(url, options = {}) { /* ... */ },
    async post(url, body, options = {}) { /* ... */ },
    async put(url, body, options = {}) { /* ... */ },
    async delete(url, options = {}) { /* ... */ },

    // Configuracion global
    setDefaultHeaders(headers) { /* ... */ },
    setTimeout(ms) { /* ... */ },
    setRetries(count) { /* ... */ }
};
```

**Analogia embebida:**

| Fetch HAL (Dashboard) | UART HAL (Embebido) |
|------------------------|---------------------|
| `HAL_Fetch.get(url)` | `UART1_Read()` |
| `HAL_Fetch.post(url, data)` | `UART1_Write(data)` |
| `_timeout = 30000` | `BufferSize = 128` |
| Reintentos automaticos | Buffer circular FIFO |

---

### 6.2 Ejemplo 2: Storage HAL (Persistencia Local)

**Ubicacion:** `_hal/Storage/`

**Archivo: storage.emic**

```emic
EMIC:ifndef _HAL_STORAGE_EMIC_
EMIC:define(_HAL_STORAGE_EMIC_, true)

// Copiar wrapper a TARGET
EMIC:copy(src/hal-storage.js > TARGET:js/hal/hal-storage.js)

// Registrar modulo
EMIC:define(js_modules.hal_storage, hal-storage)

EMIC:endif
```

**Archivo: src/hal-storage.js** (estructura esperada)

```javascript
// HAL Storage - Abstraccion de almacenamiento local
// Unifica localStorage y IndexedDB bajo una sola interfaz

const HAL_Storage = {
    _namespace: 'emic_',

    set(key, value) {
        const fullKey = this._namespace + key;
        localStorage.setItem(fullKey, JSON.stringify(value));
    },

    get(key, defaultValue = null) {
        const fullKey = this._namespace + key;
        const raw = localStorage.getItem(fullKey);
        return raw ? JSON.parse(raw) : defaultValue;
    },

    remove(key) {
        localStorage.removeItem(this._namespace + key);
    },

    clear() {
        // Solo limpia claves con el namespace EMIC
        Object.keys(localStorage)
            .filter(k => k.startsWith(this._namespace))
            .forEach(k => localStorage.removeItem(k));
    }
};
```

**Analogia embebida:**

| Storage HAL (Dashboard) | EEPROM/Flash HAL (Embebido) |
|--------------------------|----------------------------|
| `HAL_Storage.set(key, val)` | `Flash_Write(addr, data)` |
| `HAL_Storage.get(key)` | `Flash_Read(addr)` |
| `HAL_Storage.remove(key)` | `Flash_Erase(sector)` |
| Serialization JSON automatica | Serialization manual a bytes |

---

### 6.3 Ejemplo 3: WebSocket HAL (Comunicacion Bidireccional)

**Ubicacion:** `_hal/WebSocket/`

**Archivo: websocket.emic**

```emic
EMIC:ifndef _HAL_WEBSOCKET_EMIC_
EMIC:define(_HAL_WEBSOCKET_EMIC_, true)

// Copiar wrapper a TARGET
EMIC:copy(src/hal-websocket.js > TARGET:js/hal/hal-websocket.js)

// Registrar modulo
EMIC:define(js_modules.hal_websocket, hal-websocket)

EMIC:endif
```

**Archivo: src/hal-websocket.js** (estructura esperada)

```javascript
// HAL WebSocket - Abstraccion de conexion bidireccional
// Agrega: reconexion automatica, heartbeat, cola offline

const HAL_WebSocket = {
    _socket: null,
    _url: null,
    _reconnectInterval: 5000,
    _heartbeatInterval: 30000,

    connect(url, options = {}) {
        this._url = url;
        this._socket = new WebSocket(url);
        this._socket.onopen = () => this._startHeartbeat();
        this._socket.onclose = () => this._scheduleReconnect();
        this._socket.onmessage = (e) => this._onMessage(e);
    },

    send(data) {
        if (this._socket && this._socket.readyState === WebSocket.OPEN) {
            this._socket.send(JSON.stringify(data));
        }
    },

    disconnect() {
        if (this._socket) this._socket.close();
    },

    _scheduleReconnect() { /* ... */ },
    _startHeartbeat() { /* ... */ },
    _onMessage(event) { /* ... */ }
};
```

**Analogia embebida:**

| WebSocket HAL (Dashboard) | UART HAL (Embebido, streaming) |
|---------------------------|-------------------------------|
| `connect(url)` | `UART1_init()` / `UART1_ON()` |
| `send(data)` | `UART1_OUT_push(char)` |
| `onmessage` callback | `UART1_RxCallback(data)` |
| Reconexion automatica | No aplica (conexion fisica) |
| Heartbeat/ping | No aplica |

---

## 7. Creacion de Nuevos HALs

### 7.1 Cuando Crear un HAL

Crear un HAL nuevo cuando:
- Se necesita abstraer una **API nativa del browser** que no tiene wrapper
- Multiples Connectors necesitarian acceder a la misma API de forma repetitiva
- La API nativa requiere logica comun (permisos, reintentos, fallbacks)

NO crear HAL para:
- Logica de protocolo especifico (eso es Connector)
- Componentes visuales (eso es Widget)
- Utilidades puras sin dependencia del browser (eso va en `_util/`)

### 7.2 Checklist de Creacion

**PASO 1: Identificar la Browser API**
- [ ] La API es estandar W3C / WHATWG
- [ ] Esta soportada en navegadores modernos (Chrome, Firefox, Safari, Edge)
- [ ] Sera utilizada por al menos un Connector

**PASO 2: Disenar la interfaz del wrapper**
- [ ] Definir funciones publicas (init, operaciones, cleanup)
- [ ] Definir opciones de configuracion
- [ ] Definir eventos/callbacks
- [ ] Documentar que valor agrega sobre la API nativa

**PASO 3: Crear estructura de archivos**

```
_hal/{NuevoHAL}/
    {nuevo-hal}.emic
    src/hal-{nuevo-hal}.js
```

**PASO 4: Escribir el archivo .emic**

```emic
EMIC:ifndef _HAL_NUEVOHAL_EMIC_
EMIC:define(_HAL_NUEVOHAL_EMIC_, true)

// Copiar wrapper a TARGET
EMIC:copy(src/hal-nuevo-hal.js > TARGET:js/hal/hal-nuevo-hal.js)

// Registrar modulo
EMIC:define(js_modules.hal_nuevo_hal, hal-nuevo-hal)

EMIC:endif
```

**PASO 5: Implementar el wrapper JavaScript**

```javascript
const HAL_NuevoHal = {
    // Configuracion interna
    _config: {},

    // Inicializacion
    init(options = {}) {
        this._config = { ...this._config, ...options };
    },

    // Operaciones publicas
    doSomething(params) {
        // Llamada a la API nativa del browser
        // con manejo de errores y valor agregado
    },

    // Cleanup
    destroy() {
        // Liberar recursos
    }
};
```

### 7.3 Ejemplo: Crear un HAL para Web Workers

**Supongamos** que necesitamos abstraer la Web Workers API para ejecutar tareas pesadas sin bloquear el hilo principal.

**Archivo: `_hal/WebWorker/web-worker.emic`**

```emic
EMIC:ifndef _HAL_WEBWORKER_EMIC_
EMIC:define(_HAL_WEBWORKER_EMIC_, true)

EMIC:copy(src/hal-web-worker.js > TARGET:js/hal/hal-web-worker.js)
EMIC:define(js_modules.hal_web_worker, hal-web-worker)

EMIC:endif
```

**Archivo: `_hal/WebWorker/src/hal-web-worker.js`**

```javascript
const HAL_WebWorker = {
    _workers: {},

    create(name, scriptUrl) {
        if (this._workers[name]) this.terminate(name);
        this._workers[name] = new Worker(scriptUrl);
        return this._workers[name];
    },

    postMessage(name, data) {
        if (this._workers[name]) {
            this._workers[name].postMessage(data);
        }
    },

    onMessage(name, callback) {
        if (this._workers[name]) {
            this._workers[name].onmessage = (e) => callback(e.data);
        }
    },

    terminate(name) {
        if (this._workers[name]) {
            this._workers[name].terminate();
            delete this._workers[name];
        }
    }
};
```

---

## 8. Tabla de Equivalencias Embebido vs Dashboard

### 8.1 Tabla de Correspondencias

Esta tabla es la referencia fundamental para entender como los conceptos del SDK embebido se mapean al Dashboard:

| Dashboard HAL | Embebido HAL | Patron de Comunicacion | Descripcion |
|---------------|-------------|------------------------|-------------|
| **Fetch** | UART / SPI | Request-Response | Enviar solicitud, esperar respuesta. En embebido: comando serial o transaccion SPI. En Dashboard: HTTP GET/POST |
| **WebSocket** | UART (streaming) | Full-Duplex continuo | Canal abierto bidireccional. En embebido: UART con interrupciones RX/TX. En Dashboard: WebSocket con eventos |
| **Storage** | EEPROM / Flash NVS | Lectura-Escritura persistente | Datos que sobreviven al reinicio. En embebido: escritura a Flash/EEPROM. En Dashboard: localStorage/IndexedDB |
| **Notifications** | GPIO (output) | Salida de alerta | Senalizar un evento al usuario. En embebido: encender LED o buzzer. En Dashboard: notificacion del sistema |
| **Geolocation** | Modulo GPS | Lectura de sensor | Obtener posicion geografica. En embebido: parsear NMEA del GPS. En Dashboard: Geolocation API |
| **WebBluetooth** | HAL BLE | Comunicacion inalambrica corto alcance | Conectar a dispositivos Bluetooth cercanos. En embebido: BLE stack. En Dashboard: Web Bluetooth API |
| **WebSerial** | HAL UART | Puerto serie | Comunicacion con dispositivo USB conectado. En embebido: UART directo al pin. En Dashboard: Web Serial API |
| **MediaDevices** | Modulo Camera | Captura multimedia | Acceso a camara/microfono. En embebido: driver de camara (OV2640, etc.). En Dashboard: MediaDevices API |

### 8.2 Diagrama de Correspondencias

```
     EMBEBIDO                          DASHBOARD
     ========                          =========

 +-- GPIO (output) .................. Notifications --+
 |   [LED, buzzer]                   [alertas OS]     |
 |                                                     |
 +-- UART (req-resp) ................ Fetch ----------+
 |   [enviar comando, recibir resp]  [HTTP GET/POST]  |
 |                                                     |
 +-- UART (streaming) ............... WebSocket ------+
 |   [RX/TX continuo con ISR]       [full-duplex WS]  |
 |                                                     |
 +-- SPI/I2C ........................ Fetch -----------+
 |   [transaccion master-slave]      [request-response]|
 |                                                     |
 +-- EEPROM/Flash ................... Storage ---------+
 |   [persistencia NVS]             [localStorage/IDB] |
 |                                                     |
 +-- GPS module ..................... Geolocation -----+
 |   [NMEA parsing]                  [Geolocation API] |
 |                                                     |
 +-- BLE stack ....................... WebBluetooth ---+
 |   [GATT client/server]            [Web Bluetooth]   |
 |                                                     |
 +-- UART (USB) ..................... WebSerial -------+
 |   [conexion serial USB]           [Web Serial API]  |
 |                                                     |
 +-- Camera driver .................. MediaDevices ----+
     [OV2640, OV7670]               [getUserMedia()]
```

### 8.3 Patrones Compartidos

A pesar de las diferencias de plataforma, ambos HALs comparten los mismos patrones arquitectonicos:

| Patron | Embebido | Dashboard |
|--------|----------|-----------|
| **Include guard** | `EMIC:ifndef _PIC_GPIO_EMIC_` | `EMIC:ifndef _HAL_FETCH_EMIC_` |
| **Copia a TARGET** | `EMIC:copy(src/gpio.c > TARGET:gpio.c)` | `EMIC:copy(src/hal-fetch.js > TARGET:js/hal/hal-fetch.js)` |
| **Registro de modulo** | `EMIC:define(c_modules.gpio, gpio)` | `EMIC:define(js_modules.hal_fetch, hal-fetch)` |
| **NO tiene DOXYGEN tags** | Correcto (HAL no es visible al integrador) | Correcto (HAL no es visible al integrador) |
| **NO tiene EMIC:tag()** | Correcto | Correcto |
| **Dependencias hacia abajo** | HAL depende de _hard | HAL depende de Browser API nativa |

---

## Puntos Clave del Capitulo

| Concepto | Explicacion |
|----------|-------------|
| **HAL en Dashboard** | Abstrae APIs nativas del browser (no perifericos de MCU) |
| **No existe _hard/** | El browser es estandar, no hay variabilidad de hardware que aislar |
| **8 HALs** | Fetch, WebSocket, Storage, Notifications, Geolocation, WebBluetooth, WebSerial, MediaDevices |
| **Valor agregado** | Reintentos, reconexion, manejo de errores, configuracion uniforme |
| **Nivel bajo** | NO visible al integrador, usado internamente por Connectors |
| **Mismos patrones** | Include guards, copia a TARGET, registro de modulos, sin DOXYGEN |
| **Equivalencia** | Cada HAL de Dashboard tiene un analogo conceptual en el SDK embebido |

---

## Checklist de Comprension

Antes de continuar al Capitulo 10, asegurate de entender:

- [ ] Que abstrae el HAL en Dashboard (Browser APIs, no perifericos MCU)
- [ ] Por que no existe la carpeta _hard/ en el Dashboard SDK
- [ ] Los 8 HALs disponibles y su Browser API nativa correspondiente
- [ ] La estructura de archivos de un HAL (.emic + src/hal-*.js)
- [ ] La diferencia entre HAL, Connector y Widget
- [ ] Como el HAL de Dashboard se compara con el HAL embebido
- [ ] Cuando crear un nuevo HAL y cuando no
- [ ] La tabla de equivalencias Embebido vs Dashboard

---

[<- Anterior: Carpeta _hal (Embebido)](09_Carpeta_HAL.md) | [Siguiente: Carpeta _hard ->](10_Carpeta_Hard.md)

---

*Capitulo 09b - Manual de Desarrollo EMIC Dashboard SDK v1.0*
*Ultima actualizacion: Febrero 2026*
