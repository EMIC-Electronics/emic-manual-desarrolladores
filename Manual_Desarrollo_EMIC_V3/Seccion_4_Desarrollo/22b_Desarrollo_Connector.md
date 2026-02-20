# Capitulo 22b: Desarrollo de un Connector

[← Anterior: Desarrollo Widget](21b_Desarrollo_Widget_Paso_a_Paso.md) | [Siguiente: Generacion Web →](23b_Proceso_Generacion_Web.md)

## Tabla de Contenidos

### PARTE 1: DESARROLLO DEL CONNECTOR
1. [Que es un Connector](#1-que-es-un-connector)
2. [Diferencia Clave con Drivers Embebidos](#2-diferencia-clave-con-drivers-embebidos)
3. [Estructura del Connector](#3-estructura-del-connector)
4. [Integracion con el Sistema](#4-integracion-con-el-sistema)
5. [Patron Conexion/Reconexion](#5-patron-conexionreconexion)
6. [EventBus para Datos Entrantes](#6-eventbus-para-datos-entrantes)

### PARTE 2: EJEMPLOS COMPLETOS
7. [Ejemplo: MQTT Client](#7-ejemplo-mqtt-client)
8. [Ejemplo: REST Client](#8-ejemplo-rest-client)
9. [Tabla de Equivalencias Embebido vs Dashboard](#9-tabla-de-equivalencias-embebido-vs-dashboard)

---

## PARTE 1: DESARROLLO DEL CONNECTOR

---

## 1. Que es un Connector

Un **Connector** es un componente de software que gestiona la **comunicacion** entre el dashboard y fuentes de datos externas (brokers MQTT, APIs REST, WebSockets, bases de datos, etc.).

### 1.1 Ubicacion en la Arquitectura

```
Usuario (EMIC-Editor)
       |
       v
+-----------------+
|    Widgets      |  <-- Componentes visuales (con tags)
|  (Alto nivel)   |     Ej: Gauge, Chart, Switch
+--------+--------+
         |  EventBus
         v
+-----------------+
|   Connectors    |  <-- Comunicacion con backend (con tags)
|  (Medio nivel)  |     Ej: MQTTClient, RESTClient, WSClient
+--------+--------+
         |  fetch / WebSocket / MQTT.js
         v
+-----------------+
|    Backend      |  <-- Servidor, broker, API externa
|  (Externo)      |     Ej: Mosquitto, Express, Firebase
+-----------------+
```

### 1.2 Responsabilidades del Connector

| Responsabilidad | Descripcion |
|----------------|-------------|
| **Conexion** | Establecer y mantener la conexion con el backend |
| **Reconexion** | Auto-reconectar ante perdida de conexion |
| **Envio de datos** | Publicar/enviar datos al backend |
| **Recepcion de datos** | Recibir datos y emitir eventos al EventBus |
| **Configuracion** | Parametros de conexion (URL, credenciales, topics) |

---

## 2. Diferencia Clave con Drivers Embebidos

A diferencia de los drivers embebidos, los connectors del dashboard **SI tienen tags DOXYGEN** y **SI son visibles** en el EMIC-Editor. Esto es porque el usuario necesita configurar y usar los connectors directamente desde el editor visual.

### 2.1 Comparacion Detallada

```
+---------------------------------------------------------------+
|                  DRIVER vs CONNECTOR                            |
+---------------------------------------------------------------+
|                                                                 |
|  DRIVER (Embebido)                CONNECTOR (Dashboard)         |
|  =================                =====================         |
|  - SIN tags DOXYGEN               - CON tags DOXYGEN            |
|  - NO visible en Editor           - SI visible en Editor        |
|  - Usado solo por APIs            - Usado por el usuario        |
|  - Control de hardware            - Comunicacion con backend    |
|  - Include guard EMIC             - Include guard EMIC          |
|  - Usa HAL                        - Usa fetch/WebSocket/libs    |
|                                                                 |
|  EJEMPLO:                                                       |
|  Driver SPI <-- Driver LCD         MQTTClient <-- usuario       |
|  (interno)     (interno)           (visible en editor)          |
|                                                                 |
+---------------------------------------------------------------+
```

### 2.2 Tabla de Diferencias

| Aspecto | Driver Embebido | Connector Dashboard |
|---------|-----------------|---------------------|
| Tags DOXYGEN | NO | SI |
| `EMIC:tag()` | NO | SI |
| Visible en Editor | NO | SI |
| Include guard EMIC | REQUERIDO | REQUERIDO |
| Dependencias | HAL (SPI, I2C, GPIO) | _system (EventBus) |
| Funciones | `Driver_func()` | `Connector_.{name}._func()` |
| Instanciable | Generalmente NO | SI (con `.{name}.`) |
| Eventos | No emite al usuario | SI emite (onMessage, onConnect) |

---

## 3. Estructura del Connector

### 3.1 Organizacion de Carpetas

```
EMIC_Dashboard_SDK/
+-- _connectors/
    +-- {Categoria}/
        +-- {NombreConnector}/
            +-- {connector}.emic     # Archivo principal EMIC
            +-- src/
            |   +-- {connector}.js   # Implementacion JavaScript
            +-- lib/                 # Librerias externas (opcional)
                +-- mqtt.min.js      # Ej: cliente MQTT
```

### 3.2 Ejemplo: MQTT Client

```
_connectors/
+-- MQTT/
    +-- MQTTClient/
        +-- mqtt-client.emic
        +-- src/
        |   +-- mqtt-client.js
        +-- lib/
            +-- mqtt.min.js
```

### 3.3 Convenciones de Nombres

| Elemento | Convencion | Ejemplo |
|----------|-----------|---------|
| Categoria | PascalCase | `MQTT`, `REST`, `WebSocket` |
| Carpeta connector | PascalCase | `MQTTClient`, `RESTClient` |
| Archivo .emic | kebab-case | `mqtt-client.emic` |
| Archivo .js | kebab-case | `mqtt-client.js` |
| Funciones JS | `Connector_.{name}._func()` | `MQTTClient_broker1_connect()` |

---

## 4. Integracion con el Sistema

### 4.1 Diagrama de Integracion

```
+-------------------+      +-------------------+
|   MQTT Broker     |      |   REST API        |
+--------+----------+      +--------+----------+
         |                          |
         | WebSocket/MQTT           | HTTP/fetch
         |                          |
+--------v----------+      +--------v----------+
|   MQTTClient      |      |   RESTClient      |
|   Connector       |      |   Connector       |
+--------+----------+      +--------+----------+
         |                          |
         | emicBus.dispatchEvent    | emicBus.dispatchEvent
         |                          |
+--------v--------------------------v----------+
|              EventBus (emicBus)               |
+--------+------------------+------------------+
         |                  |
         v                  v
+--------+------+  +--------+------+
|   Gauge       |  |   Chart       |
|   Widget      |  |   Widget      |
+---------------+  +---------------+
```

### 4.2 EventBus como Puente

El **EventBus** (`window.emicBus`) es el mecanismo central que conecta connectors con widgets. Los connectors emiten eventos cuando reciben datos, y los widgets escuchan esos eventos para actualizar su visualizacion.

```javascript
// Connector emite (al recibir datos del broker)
window.emicBus.dispatchEvent(new CustomEvent(
    'MQTTClient_broker1_onMessage',
    { detail: { topic: 'sensors/temp', message: '23.5' } }
));

// Widget escucha (para actualizar su valor)
window.emicBus.addEventListener('MQTTClient_broker1_onMessage', (e) => {
    if (e.detail.topic === 'sensors/temp') {
        Gauge_tempGauge_setValue(parseFloat(e.detail.message));
    }
});
```

---

## 5. Patron Conexion/Reconexion

### 5.1 Maquina de Estados

Todo connector debe implementar un patron de conexion/reconexion robusto:

```
+----------+      connect()      +--------------+
|          |-------------------->|              |
|  IDLE    |                     | CONNECTING   |
|          |<-----------+        |              |
+----------+            |        +------+-------+
                        |               |
                  error/timeout    connected
                        |               |
                        |        +------v-------+
                        |        |              |
                        +--------|  CONNECTED   |
                        |        |              |
                        |        +------+-------+
                        |               |
                        |         disconnect/error
                        |               |
                   +----+-------+-------v-------+
                   |                             |
                   |       RECONNECTING          |
                   |   (setTimeout + retry)      |
                   |                             |
                   +-----------------------------+
```

### 5.2 Implementacion del Patron

```javascript
const ReconnectMixin = {
    _reconnectAttempts: 0,
    _maxReconnectAttempts: 10,
    _reconnectDelay: 1000,       // 1 segundo inicial
    _maxReconnectDelay: 30000,   // 30 segundos maximo
    _reconnectTimer: null,

    _scheduleReconnect() {
        if (this._reconnectAttempts >= this._maxReconnectAttempts) {
            this._emitEvent('onMaxRetriesReached');
            return;
        }

        // Backoff exponencial: 1s, 2s, 4s, 8s, 16s, 30s, 30s...
        const delay = Math.min(
            this._reconnectDelay * Math.pow(2, this._reconnectAttempts),
            this._maxReconnectDelay
        );

        this._reconnectAttempts++;

        this._reconnectTimer = setTimeout(() => {
            this.connect();
        }, delay);
    },

    _onConnected() {
        this._reconnectAttempts = 0;
        this._emitEvent('onConnect');
    },

    _onDisconnected(reason) {
        this._emitEvent('onDisconnect', { reason });
        this._scheduleReconnect();
    },

    _cancelReconnect() {
        if (this._reconnectTimer) {
            clearTimeout(this._reconnectTimer);
            this._reconnectTimer = null;
        }
        this._reconnectAttempts = 0;
    }
};
```

---

## 6. EventBus para Datos Entrantes

### 6.1 Patron de Emision de Eventos

Cada connector emite eventos con un nombre estandarizado:

```
Formato: {ConnectorType}_{instanceName}_{eventName}

Ejemplos:
  MQTTClient_broker1_onMessage
  MQTTClient_broker1_onConnect
  MQTTClient_broker1_onDisconnect
  RESTClient_api1_onResponse
  RESTClient_api1_onError
```

### 6.2 Funcion Helper para Emitir

```javascript
function _emitConnectorEvent(connectorName, eventName, detail) {
    if (window.emicBus) {
        window.emicBus.dispatchEvent(new CustomEvent(
            connectorName + '_' + eventName,
            { detail: detail || {} }
        ));
    }
}

// Uso:
_emitConnectorEvent('MQTTClient_.{name}.', 'onMessage', {
    topic: topic,
    message: payload
});
```

---

## PARTE 2: EJEMPLOS COMPLETOS

---

## 7. Ejemplo: MQTT Client

### 7.1 Archivo mqtt-client.emic

**Archivo: `_connectors/MQTT/MQTTClient/mqtt-client.emic`**

```emic
// Include guard
EMIC:ifndef _MQTT_CLIENT_EMIC_
EMIC:define(_MQTT_CLIENT_EMIC_, true)

// Identificacion
EMIC:tag(driverName = MQTTClient)

// Tags de publicacion

/**
* @fn void MQTTClient_.{name}._connect(const char* brokerUrl);
* @alias .{name}..connect
* @brief Connect to an MQTT broker via WebSocket
* @param brokerUrl WebSocket URL of the MQTT broker (wss://...)
* @return Nothing
*/

/**
* @fn void MQTTClient_.{name}._disconnect();
* @alias .{name}..disconnect
* @brief Disconnect from the MQTT broker
* @return Nothing
*/

/**
* @fn void MQTTClient_.{name}._subscribe(const char* topic);
* @alias .{name}..subscribe
* @brief Subscribe to an MQTT topic
* @param topic MQTT topic pattern (supports wildcards + and #)
* @return Nothing
*/

/**
* @fn void MQTTClient_.{name}._publish(const char* topic, const char* message);
* @alias .{name}..publish
* @brief Publish a message to an MQTT topic
* @param topic MQTT topic
* @param message Message payload (string)
* @return Nothing
*/

/**
* @fn extern void MQTTClient_.{name}._onMessage(const char* topic, const char* message);
* @alias .{name}..onMessage
* @brief Fires when a message is received on a subscribed topic
* @return Nothing
*/

/**
* @fn extern void MQTTClient_.{name}._onConnect();
* @alias .{name}..onConnect
* @brief Fires when successfully connected to the broker
* @return Nothing
*/

/**
* @fn extern void MQTTClient_.{name}._onDisconnect();
* @alias .{name}..onDisconnect
* @brief Fires when disconnected from the broker
* @return Nothing
*/

// Configurador
EMIC:json(type = Configurator)
{
    "name": "qos",
    "legend": "Quality of Service",
    "brief": "MQTT QoS level for subscriptions",
    "options": [
        {"legend": "QoS 0 (At most once)", "value": "0", "brief": "Fire and forget"},
        {"legend": "QoS 1 (At least once)", "value": "1", "brief": "Acknowledged delivery"},
        {"legend": "QoS 2 (Exactly once)", "value": "2", "brief": "Assured delivery"}
    ]
}

// Dependencias
EMIC:setInput(DEV:_system/system.emic)

// Copiar archivos al workspace (SYS:, no directamente a TARGET:)
EMIC:copy(src/mqtt-client.js > SYS:connectors/mqtt-client.js, name=.{name}.)
EMIC:copy(lib/mqtt.min.js > SYS:lib/mqtt.min.js)

// Registrar
EMIC:define(imports.mqtt_.{name}., mqtt-client_.{name}.)
EMIC:define(modules.mqtt_.{name}., mqtt-client_.{name}.)

EMIC:endif
```

### 7.2 Archivo src/mqtt-client.js

**Archivo: `_connectors/MQTT/MQTTClient/src/mqtt-client.js`**

```javascript
/**
 * EMIC MQTT Client Connector
 * Instance: .{name}.
 */

const MQTTClient_.{name}._ = {
    client: null,
    brokerUrl: null,
    subscriptions: [],
    _reconnectAttempts: 0,
    _maxReconnectAttempts: 10,
    _reconnectDelay: 1000,
    _reconnectTimer: null,

    // =========================================
    // FUNCIONES PUBLICAS
    // =========================================

    connect(brokerUrl) {
        this.brokerUrl = brokerUrl;
        this._reconnectAttempts = 0;

        try {
            this.client = mqtt.connect(brokerUrl, {
                reconnectPeriod: 0,  // Manejamos reconexion manualmente
                connectTimeout: 10000
            });

            this.client.on('connect', () => {
                this._reconnectAttempts = 0;

                // Re-suscribir a topics previos
                for (const topic of this.subscriptions) {
                    this.client.subscribe(topic, { qos: .{config.qos|0}. });
                }

                this._emit('onConnect');
            });

            this.client.on('message', (topic, payload) => {
                const message = payload.toString();
                this._emit('onMessage', { topic, message });
            });

            this.client.on('close', () => {
                this._emit('onDisconnect');
                this._scheduleReconnect();
            });

            this.client.on('error', (err) => {
                console.error('MQTT .{name}. error:', err.message);
            });

        } catch (err) {
            console.error('MQTT .{name}. connect failed:', err);
            this._scheduleReconnect();
        }
    },

    disconnect() {
        this._cancelReconnect();
        if (this.client) {
            this.client.end(true);
            this.client = null;
        }
    },

    subscribe(topic) {
        if (!this.subscriptions.includes(topic)) {
            this.subscriptions.push(topic);
        }
        if (this.client && this.client.connected) {
            this.client.subscribe(topic, { qos: .{config.qos|0}. });
        }
    },

    publish(topic, message) {
        if (this.client && this.client.connected) {
            this.client.publish(topic, message);
        }
    },

    // =========================================
    // RECONEXION
    // =========================================

    _scheduleReconnect() {
        if (this._reconnectAttempts >= this._maxReconnectAttempts) return;

        const delay = Math.min(
            this._reconnectDelay * Math.pow(2, this._reconnectAttempts),
            30000
        );
        this._reconnectAttempts++;

        this._reconnectTimer = setTimeout(() => {
            if (this.brokerUrl) this.connect(this.brokerUrl);
        }, delay);
    },

    _cancelReconnect() {
        if (this._reconnectTimer) {
            clearTimeout(this._reconnectTimer);
            this._reconnectTimer = null;
        }
    },

    // =========================================
    // EVENTBUS
    // =========================================

    _emit(eventName, detail) {
        if (window.emicBus) {
            window.emicBus.dispatchEvent(new CustomEvent(
                'MQTTClient_.{name}._' + eventName,
                { detail: detail || {} }
            ));
        }
    }
};

// =========================================
// FUNCIONES GLOBALES (registradas en EMICApp)
// =========================================

function MQTTClient_.{name}._init() {
    // Inicializacion (conexion se hace manualmente con connect())
}

function MQTTClient_.{name}._connect(brokerUrl) {
    MQTTClient_.{name}._.connect(brokerUrl);
}

function MQTTClient_.{name}._disconnect() {
    MQTTClient_.{name}._.disconnect();
}

function MQTTClient_.{name}._subscribe(topic) {
    MQTTClient_.{name}._.subscribe(topic);
}

function MQTTClient_.{name}._publish(topic, message) {
    MQTTClient_.{name}._.publish(topic, message);
}

// Registrar init
EMICApp.registerInit(MQTTClient_.{name}._init);
```

---

## 8. Ejemplo: REST Client

### 8.1 Archivo rest-client.emic

**Archivo: `_connectors/REST/RESTClient/rest-client.emic`**

```emic
EMIC:ifndef _REST_CLIENT_EMIC_
EMIC:define(_REST_CLIENT_EMIC_, true)

EMIC:tag(driverName = RESTClient)

/**
* @fn void RESTClient_.{name}._get(const char* url);
* @alias .{name}..get
* @brief Perform HTTP GET request
* @param url Full URL to request
* @return Nothing
*/

/**
* @fn void RESTClient_.{name}._post(const char* url, const char* body);
* @alias .{name}..post
* @brief Perform HTTP POST request with JSON body
* @param url Full URL to request
* @param body JSON string to send as body
* @return Nothing
*/

/**
* @fn void RESTClient_.{name}._setHeader(const char* key, const char* value);
* @alias .{name}..setHeader
* @brief Set a custom HTTP header for all requests
* @param key Header name (e.g. Authorization)
* @param value Header value (e.g. Bearer token123)
* @return Nothing
*/

/**
* @fn void RESTClient_.{name}._poll_start(const char* url, uint32_t intervalMs);
* @alias .{name}..pollStart
* @brief Start polling a URL at regular intervals
* @param url Full URL to poll
* @param intervalMs Interval in milliseconds between requests
* @return Nothing
*/

/**
* @fn void RESTClient_.{name}._poll_stop();
* @alias .{name}..pollStop
* @brief Stop the polling interval
* @return Nothing
*/

/**
* @fn extern void RESTClient_.{name}._onResponse(const char* data);
* @alias .{name}..onResponse
* @brief Fires when a response is received from any request
* @return Nothing
*/

/**
* @fn extern void RESTClient_.{name}._onError(const char* error);
* @alias .{name}..onError
* @brief Fires when a request fails
* @return Nothing
*/

// Dependencias
EMIC:setInput(DEV:_system/system.emic)

// Copiar archivos al workspace (SYS:, no directamente a TARGET:)
EMIC:copy(src/rest-client.js > SYS:connectors/rest-client.js, name=.{name}.)

// Registrar
EMIC:define(imports.rest_.{name}., rest-client_.{name}.)
EMIC:define(modules.rest_.{name}., rest-client_.{name}.)

EMIC:endif
```

### 8.2 Archivo src/rest-client.js

**Archivo: `_connectors/REST/RESTClient/src/rest-client.js`**

```javascript
/**
 * EMIC REST Client Connector
 * Instance: .{name}.
 */

const RESTClient_.{name}._ = {
    headers: {
        'Content-Type': 'application/json'
    },
    _pollTimer: null,

    // =========================================
    // FUNCIONES PUBLICAS
    // =========================================

    async get(url) {
        try {
            const resp = await fetch(url, {
                method: 'GET',
                headers: this.headers
            });

            if (!resp.ok) throw new Error('HTTP ' + resp.status);

            const data = await resp.text();
            this._emit('onResponse', { data, url, method: 'GET' });

        } catch (err) {
            this._emit('onError', { error: err.message, url, method: 'GET' });
        }
    },

    async post(url, body) {
        try {
            const resp = await fetch(url, {
                method: 'POST',
                headers: this.headers,
                body: body
            });

            if (!resp.ok) throw new Error('HTTP ' + resp.status);

            const data = await resp.text();
            this._emit('onResponse', { data, url, method: 'POST' });

        } catch (err) {
            this._emit('onError', { error: err.message, url, method: 'POST' });
        }
    },

    setHeader(key, value) {
        this.headers[key] = value;
    },

    pollStart(url, intervalMs) {
        this.pollStop();
        this._pollTimer = setInterval(() => {
            this.get(url);
        }, intervalMs);
        // Ejecutar inmediatamente la primera vez
        this.get(url);
    },

    pollStop() {
        if (this._pollTimer) {
            clearInterval(this._pollTimer);
            this._pollTimer = null;
        }
    },

    // =========================================
    // EVENTBUS
    // =========================================

    _emit(eventName, detail) {
        if (window.emicBus) {
            window.emicBus.dispatchEvent(new CustomEvent(
                'RESTClient_.{name}._' + eventName,
                { detail: detail || {} }
            ));
        }
    }
};

// =========================================
// FUNCIONES GLOBALES
// =========================================

function RESTClient_.{name}._init() {
    // REST client no necesita inicializacion especial
}

function RESTClient_.{name}._get(url) {
    RESTClient_.{name}._.get(url);
}

function RESTClient_.{name}._post(url, body) {
    RESTClient_.{name}._.post(url, body);
}

function RESTClient_.{name}._setHeader(key, value) {
    RESTClient_.{name}._.setHeader(key, value);
}

function RESTClient_.{name}._poll_start(url, intervalMs) {
    RESTClient_.{name}._.pollStart(url, intervalMs);
}

function RESTClient_.{name}._poll_stop() {
    RESTClient_.{name}._.pollStop();
}

EMICApp.registerInit(RESTClient_.{name}._init);
```

---

## 9. Tabla de Equivalencias Embebido vs Dashboard

| Aspecto | Driver Embebido | Connector Dashboard |
|---------|-----------------|---------------------|
| **Carpeta** | `_drivers/Categoria/Driver/` | `_connectors/Categoria/Connector/` |
| **Archivos** | `driver.emic`, `driver.h`, `driver.c` | `connector.emic`, `connector.js` |
| **Lenguaje** | C | JavaScript |
| **Tags DOXYGEN** | NO (no visible) | SI (visible en editor) |
| **`EMIC:tag()`** | NO | SI |
| **Include guard** | `EMIC:ifndef` (REQUERIDO) | `EMIC:ifndef` (REQUERIDO) |
| **Dependencias** | HAL (SPI, I2C, GPIO) | _system (EventBus) |
| **Comunicacion** | Registros del MCU via HAL | fetch / WebSocket / MQTT.js |
| **Datos entrantes** | ISR -> callback -> evento EMIC | onmessage -> EventBus -> widget |
| **Reconexion** | No aplica (hardware siempre presente) | Backoff exponencial con setTimeout |
| **Inicializacion** | `EMIC:define(inits.x, x_init)` | `EMICApp.registerInit(x_init)` |
| **Registro** | `EMIC:define(c_modules.x, x)` | `EMIC:define(modules.x, x)` |
| **Equivalencia directa** | `_drivers/UART/` | `_connectors/WebSocket/` |
| **Equivalencia directa** | `_drivers/SPI/` | `_connectors/REST/` |
| **Equivalencia directa** | `_drivers/I2C/` | `_connectors/MQTT/` |
| **Configurador** | No (no visible) | SI (EMIC:json) |
| **Polling** | `EMIC:define(polls.x, x_poll)` | `setInterval` o `EMICApp.registerPoll` |
| **Estado** | `static struct` (variables C) | Objeto JS con propiedades privadas |

### Patron de Flujo de Datos

```
EMBEBIDO:
  Hardware -> ISR -> Driver buffer -> API poll -> callback -> usuario
  (fisica)   (hw)   (ring buffer)   (main loop)  (evento)    (codigo)

DASHBOARD:
  Backend -> WebSocket/fetch -> Connector handler -> EventBus -> Widget
  (remoto)   (browser API)      (onmessage)          (emit)     (render)
```

---

## Resumen

### Checklist de Desarrollo de Connector

- [ ] **Carpetas**: Crear `_connectors/Categoria/NombreConnector/`
- [ ] **Include guard**: `EMIC:ifndef / EMIC:endif` en el .emic
- [ ] **Tags DOXYGEN**: `@fn`, `@alias` para funciones y eventos
- [ ] **Configurador**: `EMIC:json(type = Configurator)` si tiene opciones
- [ ] **Reconexion**: Implementar patron de backoff exponencial
- [ ] **EventBus**: Emitir eventos con `window.emicBus.dispatchEvent`
- [ ] **Funciones globales**: Registrar en EMICApp
- [ ] **Archivo .emic**: tag, dependencias, copy, registros

### Patron Tipico de Connector

```emic
// connector.emic
EMIC:ifndef _MI_CONNECTOR_EMIC_
EMIC:define(_MI_CONNECTOR_EMIC_, true)

EMIC:tag(driverName = MiConnector)

/**
* @fn void MiConnector_.{name}._connect(const char* url);
* @alias .{name}..connect
* @brief Connect to backend
* @param url Connection URL
* @return Nothing
*/

/**
* @fn extern void MiConnector_.{name}._onData(const char* data);
* @alias .{name}..onData
* @brief Fires when data is received
* @return Nothing
*/

EMIC:setInput(DEV:_system/system.emic)

EMIC:copy(src/connector.js > SYS:connectors/connector.js, name=.{name}.)

EMIC:define(imports.connector_.{name}., connector_.{name}.)
EMIC:define(modules.connector_.{name}., connector_.{name}.)

EMIC:endif
```

---

**Navegacion:**
- [← Capitulo 21b: Desarrollo de Widget](21b_Desarrollo_Widget_Paso_a_Paso.md)
- [→ Capitulo 23b: Proceso de Generacion Web](23b_Proceso_Generacion_Web.md)
