# Capitulo 08b: Carpeta `_connectors/` - Conectores a Servicios Externos

[<- Anterior: Carpeta _widgets](07b_Carpeta_Widgets.md) | [Siguiente: Carpeta _hal (Browser) ->](09b_Carpeta_HAL_Browser.md)

---

## Contenido del Capitulo

1. [Que es un Connector en EMIC](#1-que-es-un-connector-en-emic)
2. [Connector vs Widget: Diferencias Definitivas](#2-connector-vs-widget-diferencias-definitivas)
3. [Estructura de un Connector](#3-estructura-de-un-connector)
4. [Categorias de Connectors](#4-categorias-de-connectors)
5. [Ejemplo Completo: MQTT Client](#5-ejemplo-completo-mqtt-client)
6. [Dependencias de Connectors](#6-dependencias-de-connectors)
7. [Integracion con Widgets](#7-integracion-con-widgets)
8. [Creacion de Nuevos Connectors](#8-creacion-de-nuevos-connectors)

---

## 1. Que es un Connector en EMIC

### 1.1 Definicion Conceptual

Un **Connector** en el EMIC Dashboard SDK es una **biblioteca de acceso a servicios externos** que permite al dashboard comunicarse con brokers MQTT, APIs REST, plataformas cloud, bases de datos en tiempo real y otros servicios remotos. Es el equivalente funcional de un **Driver** en el SDK embebido, pero adaptado al entorno del navegador.

```
+----------------------------------------------------+
|              CONNECTOR EMIC DASHBOARD               |
|   Acceso a Servicios Externos desde el Navegador   |
+----------------------------------------------------+
           |
    +------+------+----------------+----------------+
    |             |                |                |
SERVICIO     PROTOCOLO       RECONEXION       NO VISUAL
 EXTERNO     ESPECIFICO      AUTOMATICA
    |             |                |                |
MQTT broker  WebSocket       Retry con          Vive en
REST API     HTTP/Fetch      backoff            Component
Firebase     SSE             exponencial        Tray
```

### 1.2 Caracteristicas de un Connector EMIC Dashboard

- **Acceso a servicios externos:** Conecta con brokers, APIs, plataformas cloud
- **Protocolo especifico:** Implementa el protocolo de comunicacion del servicio
- **Include guard OBLIGATORIO:** Evita instanciacion duplicada del connector
- **Tags DOXYGEN para Discovery:** A diferencia de los Drivers embebidos, los Connectors SI publican recursos en el Editor
- **EMIC:tag() para agrupacion:** Agrupa funciones y eventos bajo un nombre logico
- **Depende solo de HAL y _util:** Nunca de widgets ni de otros connectors
- **No visual:** No se renderiza en el Canvas; vive en el Component Tray del editor
- **Patron de auto-reconexion:** Maneja desconexiones y reintentos de forma transparente

### 1.3 Proposito de los Connectors

```
+----------------------------------------------------+
|  SIN Connector (codigo directo en el widget):       |
|                                                      |
|  const ws = new WebSocket('ws://broker:9001');      |
|  ws.onopen = () => {                                 |
|    ws.send(JSON.stringify({                          |
|      type: 'connect', protocolId: 'MQTT',           |
|      cleanSession: true, keepAlive: 60 ...          |
|    }));                                              |
|  };                                                  |
|  // ... 200 lineas mas de protocolo MQTT ...        |
+----------------------------------------------------+
  X Repetido en cada widget que necesita datos MQTT
  X Dificil de mantener
  X Sin reconexion automatica
  X Propenso a errores

+----------------------------------------------------+
|  CON Connector (abstraccion reutilizable):           |
|                                                      |
|  MQTT_.{name}._publish("sensor/temp", "23.5");     |
+----------------------------------------------------+
  OK Reutilizable en todos los widgets via EventBus
  OK Reconexion automatica transparente
  OK Testeado y confiable
```

### 1.4 Diferencia Clave con Drivers Embebidos

A diferencia de los **Drivers embebidos** (que NO tienen tags DOXYGEN ni EMIC:tag() y NO son visibles para el integrador), los **Connectors del Dashboard SI publican recursos** porque el integrador necesita configurar servicios externos directamente desde el Editor, en la pestana "Services".

```
+----------------------------------------------------+
|  DRIVER EMBEBIDO (Cap. 08)                          |
|  - Sin tags DOXYGEN                                 |
|  - Sin EMIC:tag()                                   |
|  - Invisible para el integrador                     |
|  - Solo las APIs lo usan internamente               |
+----------------------------------------------------+

+----------------------------------------------------+
|  CONNECTOR DASHBOARD (Cap. 08b)                     |
|  - CON tags DOXYGEN                                 |
|  - CON EMIC:tag()                                   |
|  - Visible en la pestana "Services" del Editor      |
|  - El integrador configura el servicio directamente |
+----------------------------------------------------+
```

---

## 2. Connector vs Widget: Diferencias Definitivas

### 2.1 Comparacion Completa

| Aspecto | Connector (Dashboard) | Widget (Dashboard) |
|---------|----------------------|-------------------|
| **Nivel de Abstraccion** | Bajo nivel (acceso a servicio) | Alto nivel (visualizacion) |
| **Servicio** | **Especifico** (MQTT, Firebase, REST) | **Generico** (cualquier fuente de datos) |
| **Visual** | **NO visual** (Component Tray) | **Visual** (Canvas) |
| **Protocolo** | Implementa protocolo del servicio | Consume datos procesados |
| **Dependencias** | HAL browser + _util | Connectors + HAL browser |
| **Ejemplo** | `MQTT_publish("topic", "data")` | `Gauge_setValue(23.5)` |
| **Cambio de servicio** | Requiere nuevo connector | NO requiere cambios |
| **Reconexion** | Maneja reconexion automatica | No aplica |

### 2.2 Comparacion con el Mundo Embebido

| Aspecto | Connector (Dashboard) | Driver (Embebido) |
|---------|----------------------|-------------------|
| **Tags DOXYGEN** | **SI** (visible en Editor) | **NO** (invisible) |
| **EMIC:tag()** | **SI** (agrupa en Services) | **NO** |
| **Visible en Editor** | **SI** (pestana Services) | **NO** |
| **Include guard** | **OBLIGATORIO** | **OBLIGATORIO** |
| **Depende de** | HAL browser, _util | HAL MCU, _util |
| **Lenguaje impl.** | JavaScript | C |
| **Archivos** | .emic + .js | .emic + .h + .c |

### 2.3 Diagrama de Capas del Dashboard

```
+----------------------------------------------------+
|                 INTEGRADOR                          |
|              (EMIC-Editor / Script)                 |
+----------------------------------------------------+
                      |
+----------------------------------------------------+
|                  WIDGETS                            |  <- Nivel ALTO
|  Gauge_setValue(), Chart_addPoint(), Table_setRow() |     (visual, generico)
|                                                      |
|  Caracteristicas:                                   |
|  - Genericos (cualquier fuente de datos)            |
|  - Visuales (Canvas)                                |
|  - Abstraen complejidad de renderizado              |
+----------------------------------------------------+
                      |
+----------------------------------------------------+
|                CONNECTORS                           |  <- Nivel BAJO
|  MQTT_publish(), Firebase_set(), REST_get()         |     (servicio especifico)
|                                                      |
|  Caracteristicas:                                   |
|  - Especificos del servicio/protocolo               |
|  - No visuales (Component Tray)                     |
|  - Implementan protocolo de comunicacion            |
|  - Reconexion automatica                            |
+----------------------------------------------------+
                      |
+----------------------------------------------------+
|                    HAL (Browser)                     |  <- Abstraccion de APIs browser
|  WebSocket, Fetch, EventSource, localStorage        |
+----------------------------------------------------+
                      |
+----------------------------------------------------+
|                 BROWSER APIs                        |  <- APIs nativas del navegador
|  window.WebSocket, window.fetch, navigator.*        |
+----------------------------------------------------+
```

### 2.4 Regla de Decision: Connector o Widget?

```
+-------------------------------------------+
|  DEBO CREAR CONNECTOR O WIDGET?           |
+-------------------------------------------+

  ? Accede a un servicio externo o protocolo?
      |
      +-- Si --> CONNECTOR
      |         Ejemplo: MQTT broker, Firebase, REST API
      |
      +-- No --> WIDGET
                Ejemplo: Gauge, Chart, Table

  ? Tiene interfaz visual?
      |
      +-- Si --> WIDGET
      |         Ejemplo: Boton, indicador, grafico
      |
      +-- No --> CONNECTOR
                Ejemplo: Conexion MQTT, autenticacion

  ? Cambiar el servicio requiere cambiar codigo?
      |
      +-- Si --> CONNECTOR
      |         Ejemplo: Cambiar de MQTT a AMQP
      |
      +-- No --> WIDGET
                Ejemplo: Cambiar de grafico de linea a barras
```

---

## 3. Estructura de un Connector

### 3.1 Arbol de Directorios

```
_connectors/                            <- Raiz de connectors
|
+-- {ConnectorCategory}/                <- Categoria (ej: IoT_Protocols)
    +-- {ConnectorName}/                <- Nombre del connector (ej: mqtt-client)
        |
        +-- {ConnectorName}.emic        * Script EMIC (tags + dependencias)
        |
        +-- src/                        * Implementacion JavaScript
        |   +-- {ConnectorName}.js      <- Logica del connector
        |
        +-- deps/                       (Opcional) Librerias de terceros
            +-- {library}.min.js        <- Dependencia externa empaquetada
```

**Ejemplo real del SDK:**
```
_connectors/IoT_Protocols/mqtt-client/
+-- mqtt-client.emic                    <- Script con tags DOXYGEN
+-- src/
|   +-- mqtt-client.js                  <- Implementacion del protocolo MQTT
+-- deps/
    +-- mqtt.min.js                     <- Libreria MQTT.js empaquetada
```

### 3.2 Diferencias Estructurales con Driver Embebido

| Aspecto | Connector (Dashboard) | Driver (Embebido) |
|---------|----------------------|-------------------|
| **Archivos fuente** | `src/{name}.js` | `inc/{name}.h` + `src/{name}.c` |
| **Headers** | No aplica (JavaScript) | `inc/{name}.h` obligatorio |
| **Dependencias externas** | `deps/` (librerias JS) | No aplica (todo en C) |
| **Tags DOXYGEN** | SI (en .emic) | NO |
| **Include guard** | OBLIGATORIO | OBLIGATORIO |

### 3.3 Responsabilidad de Cada Archivo

| Archivo | Proposito | Contenido |
|---------|-----------|-----------|
| **{name}.emic** | Define recursos publicados y dependencias | Tags DOXYGEN, EMIC:tag, configurator, dependencias HAL, EMIC:copy |
| **src/{name}.js** | Implementacion del protocolo/servicio | Conexion, reconexion, publish/subscribe, callbacks |
| **deps/{lib}.min.js** | Libreria de terceros (opcional) | Version minimizada de libreria externa |

---

## 4. Categorias de Connectors

### 4.1 Categoria 1: Protocolos IoT

Connectors para protocolos de comunicacion IoT en tiempo real.

| # | Connector | Protocolo | Caso de Uso |
|---|-----------|-----------|-------------|
| 1 | **mqtt-client** | MQTT sobre WebSocket | Telemetria IoT, comandos a dispositivos |
| 2 | **mqtt-sparkplug** | Sparkplug B sobre MQTT | IIoT industrial, metricas de planta |
| 3 | **ws-client** | WebSocket nativo | Comunicacion bidireccional en tiempo real |
| 4 | **sse-client** | Server-Sent Events | Flujo unidireccional servidor -> dashboard |
| 5 | **rest-client** | HTTP REST (Fetch) | CRUD de datos, APIs terceros |
| 6 | **graphql-client** | GraphQL sobre HTTP | Consultas flexibles a APIs |
| 7 | **webhook-sender** | HTTP POST saliente | Notificaciones a servicios externos |

### 4.2 Categoria 2: Backend-as-a-Service

Connectors para plataformas BaaS que proveen base de datos, autenticacion y mensajeria.

| # | Connector | Servicio | Caso de Uso |
|---|-----------|----------|-------------|
| 1 | **firebase-realtime** | Firebase Realtime DB | Datos en tiempo real sincronizados |
| 2 | **firebase-firestore** | Cloud Firestore | Consultas estructuradas |
| 3 | **firebase-auth** | Firebase Authentication | Login de usuarios en dashboard |
| 4 | **firebase-messaging** | Firebase Cloud Messaging | Notificaciones push |
| 5 | **supabase-db** | Supabase PostgreSQL | Base de datos relacional |
| 6 | **supabase-auth** | Supabase Auth | Autenticacion con providers |
| 7 | **supabase-realtime** | Supabase Realtime | Suscripcion a cambios en DB |

### 4.3 Categoria 3: Cloud IoT

Connectors para plataformas IoT de grandes proveedores cloud.

| # | Connector | Servicio | Caso de Uso |
|---|-----------|----------|-------------|
| 1 | **aws-iot-core** | AWS IoT Core | Device shadows, MQTT gestionado |
| 2 | **aws-api-gateway** | AWS API Gateway | Invocacion de Lambdas desde dashboard |
| 3 | **aws-cognito** | AWS Cognito | Autenticacion federada |
| 4 | **azure-iot-hub** | Azure IoT Hub | Telemetria y comandos cloud-to-device |
| 5 | **azure-signalr** | Azure SignalR Service | Comunicacion en tiempo real |

### 4.4 Categoria 4: Plataformas y Bases de Datos

Connectors para plataformas de datos, hojas de calculo y bases de datos de series temporales.

| # | Connector | Servicio | Caso de Uso |
|---|-----------|----------|-------------|
| 1 | **google-sheets** | Google Sheets API | Leer/escribir hojas de calculo |
| 2 | **thingsboard-client** | ThingsBoard REST+WS | Plataforma IoT open source |
| 3 | **influxdb-client** | InfluxDB HTTP API | Series temporales de sensores |

### 4.5 Categoria 5: Device Access

Connectors que acceden a hardware local del navegador a traves de APIs Web experimentales.

| # | Connector | API del Navegador | Caso de Uso |
|---|-----------|-------------------|-------------|
| 1 | **web-bluetooth** | Web Bluetooth API | Lectura directa de dispositivos BLE |
| 2 | **web-serial** | Web Serial API | Comunicacion serial USB desde el browser |

**Nota:** Estos connectors usan directamente las APIs HAL del navegador y pueden requerir permisos del usuario.

### 4.6 Clasificacion por Funcion

```
+-----------------------------------------------------+
|         CONNECTORS POR TIPO DE FUNCION              |
+-----------------------------------------------------+

  PROTOCOLOS IoT (32%)
      +-- mqtt-client (MQTT)
      +-- ws-client (WebSocket)
      +-- sse-client (SSE)
      +-- rest-client (REST)
      +-- graphql-client (GraphQL)
      +-- mqtt-sparkplug (Sparkplug B)
      +-- webhook-sender (HTTP POST)

  BACKEND-AS-A-SERVICE (32%)
      +-- firebase-realtime, firestore, auth, messaging
      +-- supabase-db, auth, realtime

  CLOUD IoT (23%)
      +-- aws-iot-core, api-gateway, cognito
      +-- azure-iot-hub, signalr

  PLATAFORMAS (14%)
      +-- google-sheets
      +-- thingsboard-client
      +-- influxdb-client

  DEVICE ACCESS (9%)
      +-- web-bluetooth
      +-- web-serial
```

---

## 5. Ejemplo Completo: MQTT Client

### 5.1 Archivo: mqtt-client.emic

```emic
/*****************************************************************************
  @file     mqtt-client.emic
  @brief    MQTT Client connector for EMIC Dashboard
  @version  v1.0.0
 ******************************************************************************/

EMIC:ifndef _MQTT_CLIENT_CONNECTOR_EMIC_
EMIC:define(_MQTT_CLIENT_CONNECTOR_EMIC_,true)

EMIC:tag(driverName = MQTT)

/**
* @fn void MQTT_.{name}._publish(char* topic, char* payload);
* @alias .{name}..publish
* @brief Publish a message to an MQTT topic.
* @param topic MQTT topic string
* @param payload Message content to publish
* @return Nothing
*/

/**
* @fn void MQTT_.{name}._subscribe(char* topic);
* @alias .{name}..subscribe
* @brief Subscribe to an MQTT topic.
* @param topic MQTT topic to subscribe to
* @return Nothing
*/

/**
* @fn void MQTT_.{name}._unsubscribe(char* topic);
* @alias .{name}..unsubscribe
* @brief Unsubscribe from an MQTT topic.
* @param topic MQTT topic to unsubscribe from
* @return Nothing
*/

/**
* @fn void MQTT_.{name}._disconnect(void);
* @alias .{name}..disconnect
* @brief Disconnect from the MQTT broker.
* @return Nothing
*/

/**
* @fn extern void MQTT_.{name}._onMessage(char* topic, char* payload);
* @alias .{name}..onMessage
* @brief Fires when a message is received on a subscribed topic.
* @param topic Topic where the message was received
* @param payload Message content
* @return Nothing
*/

/**
* @fn extern void MQTT_.{name}._onConnect(void);
* @alias .{name}..onConnect
* @brief Fires when the client connects (or reconnects) to the broker.
* @return Nothing
*/

/**
* @fn extern void MQTT_.{name}._onDisconnect(void);
* @alias .{name}..onDisconnect
* @brief Fires when the client loses connection to the broker.
* @return Nothing
*/

EMIC:json(type = Configurator)
{
    "name": "brokerUrl",
    "legend": "Broker URL",
    "brief": "URL del broker MQTT con WebSocket (ej: ws://broker.hivemq.com:8000/mqtt)",
    "inputType": "text",
    "default": "ws://broker.hivemq.com:8000/mqtt"
}

EMIC:json(type = Configurator)
{
    "name": "mqttQos",
    "legend": "Calidad de servicio",
    "brief": "Nivel de QoS para publicacion y suscripcion",
    "options": [
        {"legend": "QoS 0 (At most once)", "value": "0", "brief": "Entrega sin confirmacion, mas rapido"},
        {"legend": "QoS 1 (At least once)", "value": "1", "brief": "Entrega garantizada, puede duplicar"},
        {"legend": "QoS 2 (Exactly once)", "value": "2", "brief": "Entrega exacta, mas lento"}
    ]
}

// Dependencia de HAL browser (WebSocket)
EMIC:setInput(DEV:_hal/WebSocket/websocket.emic)

// Copiar implementacion al target
EMIC:copy(src/mqtt-client.js > TARGET:mqtt-client_.{name}..js, name=.{name}., brokerUrl=.{config.brokerUrl}., qos=.{config.mqttQos}.)

// Registrar para carga y ejecucion
EMIC:define(js_modules.mqtt-client_.{name}., mqtt-client_.{name}.)
EMIC:define(inits.MQTT_.{name}., MQTT_.{name}._init)

EMIC:endif
```

**Analisis del mqtt-client.emic:**

1. **Include guard obligatorio:**
   ```emic
   EMIC:ifndef _MQTT_CLIENT_CONNECTOR_EMIC_
   EMIC:define(_MQTT_CLIENT_CONNECTOR_EMIC_,true)
   ```
   Evita inclusion multiple del connector (identico al patron de Drivers).

2. **EMIC:tag() para Discovery (DIFERENCIA con Drivers):**
   ```emic
   EMIC:tag(driverName = MQTT)
   ```
   Agrupa todas las funciones bajo el nombre "MQTT" en la pestana Services del Editor. Los Drivers embebidos NO tienen esta linea.

3. **Tags DOXYGEN (DIFERENCIA con Drivers):**
   Los bloques `@fn`, `@alias`, `@brief`, `@param` publican funciones y eventos para que el integrador los use desde el Editor. Los Drivers embebidos NO publican estos tags.

4. **Eventos con `extern` (callbacks):**
   - `onMessage` -> se dispara al recibir un mensaje
   - `onConnect` -> se dispara al conectarse
   - `onDisconnect` -> se dispara al perder conexion

5. **Configurator JSON:**
   Permite al integrador configurar la URL del broker y el nivel de QoS desde el Editor, sin tocar codigo.

6. **Dependencia de HAL:**
   ```emic
   EMIC:setInput(DEV:_hal/WebSocket/websocket.emic)
   ```
   Depende del HAL de WebSocket del navegador (NO de HAL de MCU).

### 5.2 Archivo: src/mqtt-client.js

```javascript
// mqtt-client_.{name}..js
// MQTT Client Connector - Instancia: .{name}.

(function() {
    'use strict';

    // =====================================================
    // Configuracion (reemplazada por macros EMIC)
    // =====================================================
    const BROKER_URL = '.{brokerUrl}.';
    const QOS_LEVEL  = parseInt('.{qos}.') || 0;
    const CLIENT_ID  = 'emic-dashboard-' + Math.random().toString(16).substr(2, 8);

    // =====================================================
    // Estado interno
    // =====================================================
    let client = null;
    let connected = false;
    let subscriptions = new Set();
    let reconnectAttempts = 0;
    const MAX_RECONNECT_ATTEMPTS = 10;
    const BASE_RECONNECT_DELAY = 1000; // ms

    // =====================================================
    // Inicializacion
    // =====================================================
    function MQTT_.{name}._init() {
        _connect();
    }

    // =====================================================
    // Conexion con auto-reconexion
    // =====================================================
    function _connect() {
        try {
            client = HAL_WebSocket_create(BROKER_URL);

            client.onopen = function() {
                connected = true;
                reconnectAttempts = 0;

                // Enviar CONNECT MQTT (simplificado; en produccion usar mqtt.js)
                _sendMqttConnect(CLIENT_ID);

                // Re-suscribir a topics previos
                subscriptions.forEach(function(topic) {
                    _sendMqttSubscribe(topic, QOS_LEVEL);
                });

                // Disparar evento onConnect
                EMIC:ifdef usedFunction.MQTT_.{name}._onConnect
                MQTT_.{name}._onConnect();
                EMIC:endif
            };

            client.onmessage = function(event) {
                var parsed = _parseMqttMessage(event.data);
                if (parsed) {
                    // Emitir por EventBus para que los widgets escuchen
                    EventBus.emit('mqtt_.{name}..message', {
                        topic: parsed.topic,
                        payload: parsed.payload
                    });

                    // Disparar evento onMessage
                    EMIC:ifdef usedFunction.MQTT_.{name}._onMessage
                    MQTT_.{name}._onMessage(parsed.topic, parsed.payload);
                    EMIC:endif
                }
            };

            client.onclose = function() {
                connected = false;

                // Disparar evento onDisconnect
                EMIC:ifdef usedFunction.MQTT_.{name}._onDisconnect
                MQTT_.{name}._onDisconnect();
                EMIC:endif

                // Auto-reconexion con backoff exponencial
                _scheduleReconnect();
            };

            client.onerror = function(err) {
                console.error('MQTT_.{name}. connection error:', err);
                client.close();
            };

        } catch (e) {
            console.error('MQTT_.{name}. failed to connect:', e);
            _scheduleReconnect();
        }
    }

    function _scheduleReconnect() {
        if (reconnectAttempts >= MAX_RECONNECT_ATTEMPTS) {
            console.error('MQTT_.{name}. max reconnect attempts reached');
            return;
        }
        var delay = BASE_RECONNECT_DELAY * Math.pow(2, reconnectAttempts);
        reconnectAttempts++;
        console.log('MQTT_.{name}. reconnecting in ' + delay + 'ms (attempt ' + reconnectAttempts + ')');
        setTimeout(_connect, delay);
    }

    // =====================================================
    // Funciones publicas
    // =====================================================

    EMIC:ifdef usedFunction.MQTT_.{name}._publish
    function MQTT_.{name}._publish(topic, payload) {
        if (!connected) {
            console.warn('MQTT_.{name}. not connected, cannot publish');
            return;
        }
        _sendMqttPublish(topic, payload, QOS_LEVEL);
    }
    EMIC:endif

    EMIC:ifdef usedFunction.MQTT_.{name}._subscribe
    function MQTT_.{name}._subscribe(topic) {
        subscriptions.add(topic);
        if (connected) {
            _sendMqttSubscribe(topic, QOS_LEVEL);
        }
    }
    EMIC:endif

    EMIC:ifdef usedFunction.MQTT_.{name}._unsubscribe
    function MQTT_.{name}._unsubscribe(topic) {
        subscriptions.delete(topic);
        if (connected) {
            _sendMqttUnsubscribe(topic);
        }
    }
    EMIC:endif

    EMIC:ifdef usedFunction.MQTT_.{name}._disconnect
    function MQTT_.{name}._disconnect() {
        reconnectAttempts = MAX_RECONNECT_ATTEMPTS; // Evitar reconexion
        if (client) {
            _sendMqttDisconnect();
            client.close();
        }
        connected = false;
    }
    EMIC:endif

    // =====================================================
    // Protocolo MQTT sobre WebSocket (simplificado)
    // =====================================================

    function _sendMqttConnect(clientId) {
        // Construir paquete CONNECT (tipo 1)
        var payload = _buildConnectPacket(clientId, true, 60);
        client.send(payload);
    }

    function _sendMqttPublish(topic, message, qos) {
        // Construir paquete PUBLISH (tipo 3)
        var payload = _buildPublishPacket(topic, message, qos);
        client.send(payload);
    }

    function _sendMqttSubscribe(topic, qos) {
        // Construir paquete SUBSCRIBE (tipo 8)
        var payload = _buildSubscribePacket(topic, qos);
        client.send(payload);
    }

    function _sendMqttUnsubscribe(topic) {
        // Construir paquete UNSUBSCRIBE (tipo 10)
        var payload = _buildUnsubscribePacket(topic);
        client.send(payload);
    }

    function _sendMqttDisconnect() {
        // Construir paquete DISCONNECT (tipo 14)
        var payload = new Uint8Array([0xE0, 0x00]);
        client.send(payload);
    }

    function _parseMqttMessage(data) {
        // Parsear paquete PUBLISH recibido
        // Retorna { topic: string, payload: string } o null
        return _parsePublishPacket(data);
    }

    // Las funciones _build* y _parse* implementan el encoding
    // binario del protocolo MQTT v3.1.1
    // En produccion se recomienda usar la libreria mqtt.js en deps/

    function _buildConnectPacket(clientId, cleanSession, keepAlive) {
        // ... implementacion del paquete CONNECT ...
    }

    function _buildPublishPacket(topic, message, qos) {
        // ... implementacion del paquete PUBLISH ...
    }

    function _buildSubscribePacket(topic, qos) {
        // ... implementacion del paquete SUBSCRIBE ...
    }

    function _buildUnsubscribePacket(topic) {
        // ... implementacion del paquete UNSUBSCRIBE ...
    }

    function _parsePublishPacket(data) {
        // ... implementacion del parser PUBLISH ...
    }

    // =====================================================
    // Registrar funciones en el scope global
    // =====================================================
    window.MQTT_.{name}._init = MQTT_.{name}._init;

    EMIC:ifdef usedFunction.MQTT_.{name}._publish
    window.MQTT_.{name}._publish = MQTT_.{name}._publish;
    EMIC:endif

    EMIC:ifdef usedFunction.MQTT_.{name}._subscribe
    window.MQTT_.{name}._subscribe = MQTT_.{name}._subscribe;
    EMIC:endif

    EMIC:ifdef usedFunction.MQTT_.{name}._unsubscribe
    window.MQTT_.{name}._unsubscribe = MQTT_.{name}._unsubscribe;
    EMIC:endif

    EMIC:ifdef usedFunction.MQTT_.{name}._disconnect
    window.MQTT_.{name}._disconnect = MQTT_.{name}._disconnect;
    EMIC:endif

})();
```

**Analisis de la implementacion:**

1. **IIFE (Immediately Invoked Function Expression):** Todo el codigo vive dentro de un closure `(function() { ... })();` para evitar contaminar el scope global.

2. **Macros EMIC en JavaScript:** Las macros `.{name}.`, `.{brokerUrl}.`, `.{qos}.` se reemplazan durante la generacion, produciendo archivos concretos como `mqtt-client_broker1.js`.

3. **Auto-reconexion con backoff exponencial:**
   - Primer reintento: 1 segundo
   - Segundo reintento: 2 segundos
   - Tercer reintento: 4 segundos
   - Maximo 10 intentos antes de abandonar

4. **Compilacion condicional:** Las funciones solo se incluyen si el integrador las usa (`EMIC:ifdef usedFunction.*`), reduciendo el tamano del bundle.

5. **EventBus:** Ademas de los callbacks directos, el connector emite eventos a traves del EventBus para que los widgets puedan escuchar datos sin acoplamiento directo.

6. **Re-suscripcion automatica:** Al reconectarse, el connector re-suscribe automaticamente a todos los topics previos.

### 5.3 Uso desde generate.emic

```emic
// En _modules/MiDashboard/System/generate.emic

// Instancia 1: broker local para datos de sensores
EMIC:setInput(DEV:_connectors/IoT_Protocols/mqtt-client/mqtt-client.emic,
              name=sensors,
              config.brokerUrl=ws://192.168.1.100:9001/mqtt,
              config.mqttQos=1)

// Instancia 2: broker cloud para comandos remotos
EMIC:setInput(DEV:_connectors/IoT_Protocols/mqtt-client/mqtt-client.emic,
              name=cloud,
              config.brokerUrl=wss://broker.hivemq.com:8884/mqtt,
              config.mqttQos=2)
```

### 5.4 Uso desde el Integrador (program.xml)

```xml
<Init>
  <Call function="sensors.subscribe" params="'planta/sensor/#'"/>
  <Call function="cloud.subscribe" params="'comandos/dashboard'"/>
</Init>

<Event name="sensors.onMessage">
  <If condition="topic == 'planta/sensor/temp'">
    <Call function="gaugeTemp.setValue" params="parseFloat(payload)"/>
  </If>
</Event>

<Event name="cloud.onMessage">
  <Call function="processCommand" params="payload"/>
</Event>

<Event name="sensors.onDisconnect">
  <Call function="statusLed.setState" params="'error'"/>
</Event>

<Event name="sensors.onConnect">
  <Call function="statusLed.setState" params="'ok'"/>
</Event>
```

---

## 6. Dependencias de Connectors

### 6.1 Regla Fundamental

Los Connectors dependen **UNICAMENTE** de:

```
CONNECTOR
 +-- HAL (Browser)       (APIs del navegador absttraidas)
 +-- _util               (utilidades puras sin dependencia de entorno)
```

Los Connectors **NUNCA** dependen de:
- Widgets (capa superior)
- Otros Connectors (mismo nivel)
- Codigo especifico de plataforma (capa inferior directa)

### 6.2 Diagrama de Dependencias

```
Widget (Gauge)             Widget (Chart)
    |                          |
    +---------+    +-----------+
              |    |
              v    v
         EventBus (desacoplado)
              ^    ^
              |    |
    +---------+    +-----------+
    |                          |
Connector (MQTT)      Connector (REST)
    |                          |
    v                          v
HAL WebSocket            HAL Fetch
    |                          |
    v                          v
window.WebSocket         window.fetch
```

### 6.3 Dependencias Comunes por Tipo de Connector

| Connector | Depende de HAL | Protocolo |
|-----------|----------------|-----------|
| **mqtt-client** | WebSocket HAL | MQTT v3.1.1 sobre WS |
| **ws-client** | WebSocket HAL | WebSocket nativo |
| **sse-client** | EventSource HAL | Server-Sent Events |
| **rest-client** | Fetch HAL | HTTP REST |
| **firebase-realtime** | WebSocket HAL | Firebase Wire Protocol |
| **firebase-auth** | Fetch HAL | OAuth 2.0 / Firebase Auth REST |
| **aws-iot-core** | WebSocket HAL + Fetch HAL | MQTT sobre WSS + SigV4 |
| **web-bluetooth** | Bluetooth HAL | GATT Profile |
| **web-serial** | Serial HAL | Serial port nativo |

### 6.4 Ejemplo de Cadena de Dependencias

**Caso: MQTT Client**

```
Widget Gauge (temperatura)
    |
    +--- EventBus.on('mqtt_sensors.message', handler)
    |
Connector MQTT (instancia: sensors)
    |
    +---> HAL WebSocket
    |         |
    |         +---> window.WebSocket (API nativa)
    |
    +---> _util/EventBus
              |
              +---> (puro JavaScript, sin dependencia de entorno)
```

**En codigo:**
```emic
// mqtt-client.emic
EMIC:setInput(DEV:_hal/WebSocket/websocket.emic)

// websocket.emic (HAL)
// Abstrae window.WebSocket con reconexion y buffering
```

---

## 7. Integracion con Widgets

### 7.1 Patron EventBus

La comunicacion entre Connectors y Widgets se realiza a traves del **EventBus**, un sistema de publicacion/suscripcion que desacopla ambas capas. Ningun widget referencia directamente a un connector y viceversa.

```
+----------------------------------------------------+
|  FLUJO DE DATOS: Servicio -> Widget                 |
+----------------------------------------------------+
|                                                      |
|  1. Broker MQTT envia mensaje                       |
|  2. Connector MQTT recibe via WebSocket             |
|  3. Connector emite: EventBus.emit('mqtt.message')  |
|  4. Widget Gauge escucha: EventBus.on('mqtt.message')|
|  5. Widget actualiza su visualizacion               |
|                                                      |
+----------------------------------------------------+
```

### 7.2 Ejemplo: MQTT Connector + Gauge Widget

**Connector emite datos (mqtt-client.js):**

```javascript
// Dentro del handler onmessage del connector
client.onmessage = function(event) {
    var parsed = _parseMqttMessage(event.data);
    if (parsed) {
        // Emitir por EventBus (desacoplado del widget)
        EventBus.emit('mqtt_.{name}..message', {
            topic: parsed.topic,
            payload: parsed.payload
        });
    }
};
```

**Widget escucha datos (gauge.js):**

```javascript
// Dentro del init del widget Gauge
function Gauge_.{name}._init() {
    // Renderizar gauge en el canvas
    _renderGauge();

    // Escuchar datos del connector via EventBus
    EventBus.on('.{dataSource}.', function(data) {
        var value = parseFloat(data.payload);
        if (!isNaN(value)) {
            _updateNeedle(value);
        }
    });
}
```

**Configuracion desde generate.emic:**

```emic
// Connector MQTT
EMIC:setInput(DEV:_connectors/IoT_Protocols/mqtt-client/mqtt-client.emic,
              name=sensors,
              config.brokerUrl=ws://192.168.1.100:9001/mqtt,
              config.mqttQos=1)

// Widget Gauge que escucha al connector
EMIC:setInput(DEV:_widgets/Gauges/radial-gauge/radial-gauge.emic,
              name=tempGauge,
              dataSource=mqtt_sensors.message,
              min=0, max=100, unit=C)
```

### 7.3 Flujo Bidireccional

El flujo tambien funciona en direccion inversa: un Widget puede solicitar que un Connector envie datos al servicio externo.

```
+----------------------------------------------------+
|  FLUJO INVERSO: Widget -> Servicio                  |
+----------------------------------------------------+
|                                                      |
|  1. Usuario pulsa boton en Widget                   |
|  2. Widget emite: EventBus.emit('command.send')     |
|  3. Connector escucha: EventBus.on('command.send')  |
|  4. Connector publica via MQTT al broker            |
|  5. Dispositivo embebido recibe el comando          |
|                                                      |
+----------------------------------------------------+
```

**Widget boton emite comando:**

```javascript
function Button_.{name}._onClick() {
    EventBus.emit('.{commandEvent}.', {
        topic: '.{commandTopic}.',
        payload: '.{commandPayload}.'
    });
}
```

**Connector escucha y publica:**

```javascript
EventBus.on('command.send', function(data) {
    MQTT_.{name}._publish(data.topic, data.payload);
});
```

---

## 8. Creacion de Nuevos Connectors

### 8.1 Checklist de Creacion

**PASO 1: Investigacion del Servicio**
- [ ] Estudiar la documentacion del servicio/protocolo
- [ ] Identificar protocolo de transporte (WebSocket, HTTP, SSE)
- [ ] Listar operaciones necesarias (connect, publish, subscribe, etc.)
- [ ] Identificar dependencias de HAL del navegador
- [ ] Verificar si existe libreria JS de terceros para incluir en deps/

**PASO 2: Estructura de Carpetas**
```bash
mkdir -p _connectors/{Categoria}/{NombreConnector}/src
mkdir -p _connectors/{Categoria}/{NombreConnector}/deps   # solo si hay libs externas
```

**PASO 3: Crear {NombreConnector}.emic**
- [ ] Include guard (`EMIC:ifndef`)
- [ ] `EMIC:tag(driverName = ...)` para Discovery
- [ ] Tags DOXYGEN para funciones y eventos
- [ ] Configurator JSON para parametros del servicio
- [ ] Declarar dependencias de HAL con `EMIC:setInput`
- [ ] Comandos `EMIC:copy` para la implementacion JS
- [ ] Registrar en `js_modules` e `inits`

**PASO 4: Crear src/{NombreConnector}.js**
- [ ] IIFE para encapsulacion
- [ ] Logica de conexion al servicio
- [ ] Patron de auto-reconexion con backoff exponencial
- [ ] Funciones publicas (publish, subscribe, get, set, etc.)
- [ ] Emision de eventos via EventBus
- [ ] Compilacion condicional con `EMIC:ifdef`
- [ ] Registro de funciones en `window.*`

**PASO 5: Testing**
- [ ] Conectar con servicio real
- [ ] Verificar reconexion automatica (desconectar y reconectar servicio)
- [ ] Probar publicacion y suscripcion
- [ ] Verificar integracion con widgets via EventBus
- [ ] Probar multiples instancias simultaneas

El desarrollo paso a paso se detalla en el Capitulo 22b.

### 8.2 Tabla de Equivalencia Obligatoria: Connector vs Driver Embebido

| Dashboard Connector | Driver Embebido | Descripcion |
|---------------------|-----------------|-------------|
| `mqtt-client.js` | `MCP2200.c` | Implementacion del protocolo |
| `mqtt-client.emic` | `MCP2200.emic` | Tags, dependencias, configuracion |
| `EMIC:tag()` **SI** | **NO tiene** | **Diferencia clave:** connector es visible en Editor |
| `@fn / @alias` **SI** | **NO tiene** | **Diferencia clave:** connector publica recursos |
| Component Tray | (no equivalente) | Ubicacion en el Editor (no visual) |
| Auto-reconnect (patron estandar) | (responsabilidad del desarrollador) | Patron de reconexion incluido |
| `deps/` (librerias JS) | (no equivalente) | Dependencias de terceros empaquetadas |
| `EventBus.emit()` | (no equivalente) | Comunicacion desacoplada con widgets |
| `EMIC:ifdef usedFunction.*` | `EMIC:ifdef usedFunction.*` | Compilacion condicional (identico) |
| Include guard | Include guard | Proteccion contra inclusion multiple (identico) |

### 8.3 Ejemplo Rapido: Creando REST Client

**Ubicacion:** `_connectors/IoT_Protocols/rest-client/`

**1. rest-client.emic:**

```emic
EMIC:ifndef _REST_CLIENT_CONNECTOR_EMIC_
EMIC:define(_REST_CLIENT_CONNECTOR_EMIC_,true)

EMIC:tag(driverName = REST)

/**
* @fn void REST_.{name}._get(char* endpoint);
* @alias .{name}..get
* @brief Perform an HTTP GET request to the specified endpoint.
* @param endpoint URL path to request
* @return Nothing
*/

/**
* @fn void REST_.{name}._post(char* endpoint, char* body);
* @alias .{name}..post
* @brief Perform an HTTP POST request with a JSON body.
* @param endpoint URL path to request
* @param body JSON string to send
* @return Nothing
*/

/**
* @fn extern void REST_.{name}._onResponse(char* endpoint, char* data, uint16_t status);
* @alias .{name}..onResponse
* @brief Fires when a response is received from the server.
* @param endpoint The requested endpoint
* @param data Response body
* @param status HTTP status code
* @return Nothing
*/

/**
* @fn extern void REST_.{name}._onError(char* endpoint, char* error);
* @alias .{name}..onError
* @brief Fires when a request fails.
* @param endpoint The requested endpoint
* @param error Error description
* @return Nothing
*/

EMIC:json(type = Configurator)
{
    "name": "baseUrl",
    "legend": "Base URL",
    "brief": "URL base del servidor REST (ej: https://api.example.com)",
    "inputType": "text",
    "default": "https://api.example.com"
}

EMIC:setInput(DEV:_hal/Fetch/fetch.emic)

EMIC:copy(src/rest-client.js > TARGET:rest-client_.{name}..js, name=.{name}., baseUrl=.{config.baseUrl}.)

EMIC:define(js_modules.rest-client_.{name}., rest-client_.{name}.)
EMIC:define(inits.REST_.{name}., REST_.{name}._init)

EMIC:endif
```

**2. Uso desde generate.emic:**

```emic
EMIC:setInput(DEV:_connectors/IoT_Protocols/rest-client/rest-client.emic,
              name=api,
              config.baseUrl=https://api.miservidor.com/v1)
```

**3. Uso desde el integrador:**

```xml
<Init>
  <Call function="api.get" params="'/sensors/latest'"/>
</Init>

<Event name="api.onResponse">
  <If condition="status == 200">
    <Call function="table.setData" params="data"/>
  </If>
</Event>
```

---

## Puntos Clave del Capitulo

| Concepto | Explicacion |
|----------|-------------|
| **Connector EMIC** | Biblioteca de acceso a servicios externos para el Dashboard |
| **Connector vs Widget** | Connector = servicio especifico, Widget = visualizacion generica |
| **Connector vs Driver** | Connector tiene tags DOXYGEN y EMIC:tag; Driver embebido no |
| **Estructura** | {name}.emic + src/{name}.js + deps/ (opcional) |
| **5 categorias** | IoT Protocols, BaaS, Cloud IoT, Plataformas, Device Access |
| **Dependencias** | HAL browser + _util (NUNCA widgets ni otros connectors) |
| **EventBus** | Patron de comunicacion desacoplada con widgets |
| **Auto-reconexion** | Patron estandar con backoff exponencial |

---

## Resumen Visual

```
+----------------------------------------------------+
|           CONNECTOR EMIC DASHBOARD                  |
|    _connectors/{Category}/{ConnectorName}/          |
+----------------------------------------------------+
            |
     +------+------+------------------+
     |             |                  |
{name}.emic    src/{name}.js       deps/
     |             |                  |
     |             |                  |
Tags DOXYGEN   Protocolo del      Librerias
EMIC:tag       servicio           de terceros
Configurator   Auto-reconexion    (opcional)
Dependencias   EventBus emit
Include guard  Funciones publicas
```

---

## Checklist de Comprension

Antes de continuar al Capitulo 09b, asegurate de entender:

- [ ] Que es un Connector en EMIC Dashboard (acceso a servicios externos)
- [ ] La diferencia fundamental entre Connector y Widget
- [ ] Por que Connectors SI usan tags DOXYGEN (a diferencia de Drivers embebidos)
- [ ] La estructura de un Connector ({name}.emic + src/ + deps/)
- [ ] Las 5 categorias de Connectors disponibles
- [ ] El patron de auto-reconexion con backoff exponencial
- [ ] Como los Connectors dependen de HAL browser
- [ ] La integracion Connector -> EventBus -> Widget
- [ ] Como crear un connector nuevo desde cero

---

## Ejercicio Practico

**Exploracion del SDK Dashboard:**

```powershell
# Navega a _connectors/
cd C:\...\Dashboard\_connectors\

# Lista todas las categorias
ls

# Explora el connector MQTT
cd IoT_Protocols\mqtt-client\
cat mqtt-client.emic

# Cuenta las funciones publicadas (tags @fn)
Select-String "@fn" mqtt-client.emic

# Verifica el include guard
Select-String "EMIC:ifndef" mqtt-client.emic
```

**Pregunta de reflexion:**
Por que un Connector del Dashboard tiene tags DOXYGEN pero un Driver embebido no?

<details>
<summary>Ver respuesta</summary>

**Respuesta:**
Porque un **Driver embebido** es una capa **interna** que solo usan las APIs, nunca el integrador directamente. El integrador interactua con la API de alto nivel (`USB_Send()`), no con el driver (`MCP2200_SendByte()`).

En cambio, un **Connector del Dashboard** es un servicio que el integrador **si configura directamente** desde el Editor. El integrador necesita:
- Configurar la URL del broker MQTT
- Elegir el nivel de QoS
- Suscribirse a topics especificos
- Reaccionar a eventos de conexion/desconexion

Por lo tanto, el Connector DEBE publicar sus funciones y eventos con tags DOXYGEN para que EMIC-Discovery los muestre en la pestana "Services" del Editor.

La regla general:
- **Driver (embebido):** Capa interna -> Sin tags -> Solo APIs lo usan
- **Connector (dashboard):** Capa configurable -> Con tags -> Integrador lo usa directamente

</details>

---

[<- Anterior: Carpeta _widgets](07b_Carpeta_Widgets.md) | [Siguiente: Carpeta _hal (Browser) ->](09b_Carpeta_HAL_Browser.md)

---

*Capitulo 08b - Manual de Desarrollo EMIC Dashboard SDK v1.0*
*Ultima actualizacion: Febrero 2026*
