# Capitulo 02b: Arquitectura del Dashboard SDK

[<- Anterior: Arquitectura Embebida](02_Arquitectura.md) | [Siguiente: Glosario ->](03_Glosario.md)

---

## Contenido del Capitulo

1. [Vision General del Dashboard SDK](#1-vision-general-del-dashboard-sdk)
2. [Pipeline de Generacion Web](#2-pipeline-de-generacion-web)
3. [Capas de Abstraccion](#3-capas-de-abstraccion)
4. [Discovery Dual (discovery.emic + generate.emic)](#4-discovery-dual-discoveryemic--generateemic)
5. [Modelo de Ejecucion en Browser](#5-modelo-de-ejecucion-en-browser)
6. [Hosting Estatico sin Backend](#6-hosting-estatico-sin-backend)
7. [Tabla de Equivalencias Embebido vs Dashboard](#7-tabla-de-equivalencias-embebido-vs-dashboard)

---

## 1. Vision General del Dashboard SDK

El EMIC Dashboard SDK extiende el ecosistema EMIC al mundo web, permitiendo generar **dashboards estaticos** basados en **WebComponents** utilizando exactamente el mismo lenguaje EMIC-Codify, el mismo proceso de Discovery y el mismo sistema de Tags que el SDK embebido.

### Principios Fundamentales

1. **Mismo lenguaje, diferente target:**
   - El desarrollador escribe `.emic`, `.js`, `.html` en lugar de `.emic`, `.c`, `.h`
   - Los comandos EMIC-Codify (`setInput`, `copy`, `define`, macros) funcionan identicamente
   - El integrador usa el mismo EMIC-Editor visual

2. **Sin backend:**
   - El resultado de EMIC Generate es un proyecto web **puramente estatico**
   - No requiere servidor con logica de negocio
   - Hosting en GitHub Pages, Netlify, Vercel, S3 o cualquier CDN

3. **WebComponents como unidad base:**
   - Cada widget es un Custom Element estandar del browser
   - Encapsulacion via Shadow DOM
   - Interoperabilidad nativa entre widgets

4. **Equivalencias directas con el SDK embebido:**
   - **Widgets** = equivalente visual de las APIs
   - **Connectors** = equivalente de los Drivers (acceso a servicios externos)
   - **HAL** = abstraccion de APIs del browser (Fetch, WebSocket, Storage, etc.)

### Vision de Alto Nivel

```
+-------------------------------------------------------------+
|              ARQUITECTURA EMIC DASHBOARD SDK                 |
|                                                              |
|  +-------------------------------------------------------+  |
|  |        CAPA DE INTEGRACION (Integrador)                |  |
|  |             EMIC-Editor (Visual)                       |  |
|  +-------------------------+-----------------------------+  |
|                            |                                 |
|  +-------------------------v-----------------------------+  |
|  |     CAPA DE PROCESAMIENTO (Sistema EMIC)              |  |
|  |  Discovery -> Transcriptor -> Merge -> Deploy          |  |
|  +-------------------------+-----------------------------+  |
|                            |                                 |
|  +-------------------------v-----------------------------+  |
|  |   CAPA DE RECURSOS (Desarrollador - TU)               |  |
|  |     EMIC-Libraries (Widgets, Connectors, Modulos)      |  |
|  +-------------------------------------------------------+  |
|                                                              |
+-------------------------------------------------------------+
```

**Diferencia clave con el SDK embebido:** En lugar de generar codigo C compilable para un microcontrolador, el Dashboard SDK genera un **proyecto web estatico** que se despliega directamente en un servidor de archivos y se ejecuta en el browser del usuario.

---

## 2. Pipeline de Generacion Web

El pipeline del Dashboard SDK sigue la misma filosofia que el embebido, pero reemplaza la etapa de compilacion por un despliegue estatico.

### 2.1 Diagrama del Pipeline

```
INTEGRADOR (EMIC-Editor) --> Script (XML/JSON)
    |
    v
EMIC Generate (generate.emic) --> fusiona Script + SDK web
    |
    v
Proyecto Web estatico --> Deploy (GitHub Pages / CDN / S3)
    |
    v
Browser --> Carga dinamica WebComponents --> Dashboard funcional
```

### 2.2 Detalle de Cada Etapa

#### Etapa 1: Diseno (Integrador)

```
INPUT:                         PROCESO:                    OUTPUT:
+-------------+               +----------+              +-------------+
| Catalogo de |               |  EMIC    |              |   Script    |
| Widgets     |               |  Editor  |              | (XML/JSON)  |
|             |               |          |              |             |
| * Gauges    |               | Drag &   |              | Contiene:   |
| * Charts    |-------------->| Drop     |------------->| * Widgets   |
| * Controls  |               | Visual   |              | * Layout    |
| * Tables    |               |          |              | * Bindings  |
| * Maps      |               | Config   |              | * Config    |
+-------------+               +----------+              +-------------+
```

#### Etapa 2: Generacion (Automatico)

```
INPUTS:                        PROCESO:                    OUTPUT:
+-------------+               +----------+              +-------------+
| Script del  |               |          |              | Proyecto    |
| Integrador  |----------+    |  EMIC    |              | Web         |
|             |          |    |  Codify  |              | Estatico    |
+-------------+          +--->|  Engine  |------------->|             |
                         |    |          |              | * index.html|
+-------------+          |    | Procesa: |              | * app.js    |
| EMIC-       |          |    | * setInput              | * widgets/  |
| Libraries   |----------+    | * copy   |              | * config/   |
| (Tu codigo) |               | * define |              | * assets/   |
|             |               | * macros |              |             |
+-------------+               +----------+              +-------------+
```

#### Etapa 3: Despliegue

```
INPUT:                         PROCESO:                    OUTPUT:
+-------------+               +----------+              +-------------+
| Proyecto    |               | Deploy   |              | Dashboard   |
| Web         |               | estatico |              | Funcional   |
| (TARGET:)   |-------------->|          |------------->|             |
|             |               | * Upload |              | Accesible   |
| * HTML      |               | * CI/CD  |              | desde       |
| * JS        |               | * CDN    |              | cualquier   |
| * CSS       |               |          |              | browser     |
+-------------+               +----------+              +-------------+
```

### 2.3 Comparacion con Pipeline Embebido

| Etapa | SDK Embebido | Dashboard SDK |
|-------|-------------|---------------|
| Entrada | Script XML/JSON | Script XML/JSON |
| Motor | EMIC-Codify | EMIC-Codify |
| Fusion | Script + C libraries | Script + JS/HTML libraries |
| Salida | Codigo C compilable | Proyecto web estatico |
| Post-proceso | Compiler (GCC/XC) -> .hex | Deploy (upload) -> URL |
| Runtime | Microcontrolador | Browser |

---

## 3. Capas de Abstraccion

El Dashboard SDK implementa **6 capas de abstraccion** analogas a las del SDK embebido, adaptadas al entorno web.

### 3.1 Tabla de Capas

| Capa | Carpeta | Proposito | Depende de |
|------|---------|-----------|------------|
| Modules | `_modules/` | Dashboards completos (HW + Dashboard) | Widgets, Connectors, Layouts |
| Widgets | `_widgets/` | Componentes visuales interactivos | Connectors, HAL, _util |
| Connectors | `_connectors/` | Acceso a servicios externos | HAL, _util |
| HAL | `_hal/` | Abstraccion de APIs del browser | nada |
| Utilities | `_util/` | Funciones puras JS (sin dependencias) | nada |
| System | `_system/` | Motor core (loader, eventbus, state) | HAL |

### 3.2 Diagrama de Capas

```
+-------------------------------------------------------------+
|                                                               |
|    _modules/   Dashboards completos                          |
|    (Integracion de widgets + connectors + layout + config)    |
|                                                               |
+-------------------------------+-------------------------------+
                                |
                  +-------------+-------------+
                  |                           |
+------------------------------+  +----------------------------+
|                              |  |                            |
|  _widgets/                   |  |  _connectors/              |
|  Componentes visuales        |  |  Acceso a servicios        |
|                              |  |                            |
|  * Charts/LineChart          |  |  * MQTT/mqtt-client        |
|  * Indicators/Gauge          |  |  * REST/rest-client        |
|  * Controls/ToggleSwitch     |  |  * Firebase/firebase-rt    |
|  * Data/DataTable            |  |  * WebSocket/ws-client     |
|  * Maps/DeviceMap            |  |  * Supabase/supabase-db    |
|  * Layout/Card               |  |  * AWS/aws-iot-core        |
|                              |  |                            |
+-------------+----------------+  +-------------+--------------+
              |                                 |
              +----------------+----------------+
                               |
              +----------------v-----------------+
              |                                  |
              |  _hal/                           |
              |  Abstraccion de APIs del browser  |
              |                                  |
              |  * Fetch/           (HTTP)        |
              |  * WebSocket/       (WS)         |
              |  * Storage/         (localStorage)|
              |  * Notifications/   (Push API)    |
              |  * Geolocation/     (GPS)         |
              |  * WebBluetooth/    (BLE)         |
              |  * WebSerial/       (Serial API)  |
              |  * MediaDevices/    (Camera/Mic)  |
              |                                  |
              +----------------------------------+
                               |
              +----------------v-----------------+
              |                                  |
              |  _system/                        |
              |  Motor core del dashboard         |
              |                                  |
              |  * core/         (loader, base)   |
              |  * event-bus/    (comunicacion)    |
              |  * state/        (estado global)   |
              |  * persistence/  (guardado)        |
              |  * streams/      (flujo de datos)  |
              |                                  |
              +----------------------------------+
                               |
              +----------------v-----------------+
              |                                  |
              |  _util/                          |
              |  Funciones puras JS              |
              |                                  |
              |  * Formatters, Validators         |
              |  * Comparers, Operators           |
              |  * String utils, Math helpers     |
              |                                  |
              +----------------------------------+
```

### 3.3 Regla de Dependencia

Igual que en el SDK embebido, las dependencias **SIEMPRE fluyen hacia abajo**. Nunca una capa inferior puede referenciar una capa superior.

```
_modules  -->  _widgets + _connectors
_widgets  -->  _connectors + _hal + _util
_connectors -> _hal + _util
_hal      -->  (nada - abstrae APIs nativas del browser)
_system   -->  _hal
_util     -->  (nada - funciones puras)
```

**Violaciones prohibidas:**
- Un Connector NO puede importar un Widget
- Un Widget NO puede importar un Module
- La HAL NO puede depender de Connectors
- `_util` NO puede depender de nada

---

## 4. Discovery Dual (discovery.emic + generate.emic)

Esta es la **diferencia arquitectonica mas importante** entre el Dashboard SDK y el SDK embebido. Mientras que el SDK embebido usa un unico archivo `generate.emic` para Discovery y generacion, el Dashboard SDK separa estos procesos en dos archivos independientes.

### 4.1 El Problema

En el SDK embebido, `generate.emic` cumple doble funcion:

```
generate.emic (embebido):
    EMIC:setInput(DEV:_api/LEDs/led.emic, name=led1, pin=Led1)   <-- Discovery + Generate
    EMIC:setInput(DEV:_api/LEDs/led.emic, name=led2, pin=Led2)   <-- Discovery + Generate
```

Esto funciona porque el integrador embebido trabaja con hardware fijo: sabe desde el principio que tiene `led1` y `led2` conectados a pines especificos.

**Pero en el Dashboard**, los widgets se agregan **interactivamente**. El integrador:
1. Abre el Editor
2. Ve el catalogo de widgets disponibles
3. Arrastra un Gauge al canvas y le pone nombre `temperatura`
4. Arrastra otro Gauge y le pone nombre `presion`
5. Los nombres se eligen **en tiempo de diseno**, no estan predefinidos en el SDK

### 4.2 La Solucion: Discovery Dual

El Dashboard SDK usa **dos archivos** con responsabilidades separadas:

#### discovery.emic (para el catalogo)

```
// discovery.emic - Se ejecuta durante EMIC Discovery
// Usa _INSTANCE_ como placeholder generico

EMIC:tag(driverName = Gauge)

/**
* @fn void Gauge__INSTANCE__setValue(float value);
* @alias _INSTANCE_.setValue
* @brief Establece el valor mostrado en el gauge
* @param value Valor numerico a mostrar
* @return Nothing
*/

/**
* @fn extern void Gauge__INSTANCE__onThreshold(void);
* @alias _INSTANCE_.onThreshold
* @brief Se dispara cuando el valor cruza un umbral configurado
* @return Nothing
*/

EMIC:json(type = Configurator)
{
    "name": "gaugeStyle",
    "legend": "Estilo del gauge",
    "options": [
        {"legend": "Semicircular", "value": "semi"},
        {"legend": "Circular completo", "value": "full"},
        {"legend": "Lineal", "value": "linear"}
    ]
}
```

**Nota:** `_INSTANCE_` es un **placeholder**. Discovery lo usa para mostrar las funciones en el catalogo del Editor sin necesitar un nombre concreto.

#### generate.emic (para la generacion)

```
// generate.emic - Se ejecuta durante EMIC Generate
// Itera sobre todas las instancias creadas por el integrador

EMIC:setOutput(TARGET:generate.txt)

    // 1. Sistema core
    EMIC:setInput(DEV:_system/core/emic-dashboard-core.emic)
    EMIC:setInput(DEV:_system/event-bus/event-bus.emic)
    EMIC:setInput(DEV:_system/state/state-manager.emic)

    // 2. Funciones y eventos usados por el integrador
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    // 3. Instanciar widgets (foreach itera sobre instancias del integrador)
    // .{*}. = key (instance name), .{widgets.{*}}. = value (widget path)
    EMIC:foreach(widgets.*)
        EMIC:setInput(DEV:_widgets/.{widgets.{*}}., name=.{*}.)
    EMIC:endforeach

    // 4. Instanciar connectors
    EMIC:foreach(connectors.*)
        EMIC:setInput(DEV:_connectors/.{connectors.{*}}., name=.{*}.)
    EMIC:endforeach

    // 5. Codigo del usuario
    EMIC:copy(SYS:inc/userFncFile.js > TARGET:js/userFncFile.js)
    EMIC:copy(SYS:userStyles.css > TARGET:css/userStyles.css)

    // 6. Template del proyecto web
    EMIC:copy(DEV:_templates/projects/web-static > TARGET:)

EMIC:restoreOutput
```

### 4.3 Flujo Completo del Discovery Dual

```
FASE 1 - Registro del SDK:
+-------------------+
| Dashboard SDK     |
| _widgets/         |         +------------------+
|   Charts/         |-------->| EMIC Discovery   |
|     LineChart/     |         |                  |
|       discovery.   |         | Lee discovery.   |
|         emic      |         | emic de cada     |
|   Indicators/     |         | widget/connector |
|     Gauge/        |         |                  |
|       discovery.   |-------->| Extrae Tags con  |
|         emic      |         | _INSTANCE_       |
+-------------------+         +--------+---------+
                                       |
                                       v
                              +------------------+
                              | Catalogo de      |
                              | Templates        |
                              |                  |
                              | * Gauge          |
                              |   - setValue()   |
                              |   - onThreshold()|
                              | * LineChart      |
                              |   - addPoint()   |
                              |   - clear()      |
                              | * ToggleSwitch   |
                              |   - setState()   |
                              |   - onToggle()   |
                              +--------+---------+
                                       |
FASE 2 - Diseno (Editor):             v
                              +------------------+
                              | EMIC Editor      |
                              |                  |
                              | Integrador:      |
                              | 1. Ve catalogo   |
                              | 2. Arrastra Gauge|
                              |    nombre: temp  |
                              | 3. Arrastra Gauge|
                              |    nombre: pres  |
                              | 4. Configura     |
                              |    bindings      |
                              +--------+---------+
                                       |
                                       v
                              +------------------+
                              | Script           |
                              | (XML/JSON)       |
                              |                  |
                              | widgets:         |
                              |   temp: Gauge    |
                              |   pres: Gauge    |
                              +--------+---------+
                                       |
FASE 3 - Generacion:                  v
                              +------------------+
                              | EMIC Generate    |
                              |                  |
                              | Lee generate.emic|
                              | foreach(widgets.*) |
                              |   name=temp      |
                              |   name=pres      |
                              |                  |
                              | Sustituye macros |
                              | Copia archivos   |
                              +--------+---------+
                                       |
                                       v
                              +------------------+
                              | TARGET:          |
                              |                  |
                              | index.html       |
                              | js/gauge_temp.js |
                              | js/gauge_pres.js |
                              | js/app.js        |
                              | css/styles.css   |
                              +------------------+
```

### 4.4 Por Que No Funciona un Solo Archivo

| Aspecto | Solo generate.emic | discovery.emic + generate.emic |
|---------|-------------------|-------------------------------|
| Catalogo del Editor | Requiere nombres hardcodeados | Usa `_INSTANCE_` como placeholder |
| Agregar instancias | Editar generate.emic manualmente | Drag & drop en el Editor |
| Nombres de instancia | Predefinidos por el desarrollador | Elegidos por el integrador |
| Escalabilidad | Limitada al generate.emic inicial | Ilimitada (foreach dinamico) |
| Experiencia UX | Desarrollador define todo | Integrador tiene libertad creativa |

---

## 5. Modelo de Ejecucion en Browser

Una vez desplegado, el dashboard se ejecuta completamente en el browser del usuario. El modelo de ejecucion sigue una estructura analoga al loop principal del firmware embebido.

### 5.1 Ciclo de Vida del Dashboard

```
Page Load (Browser)
    |
    +-> loadCore()                    // Carga motor EMIC Dashboard
    |
    +-> loadConfig()                  // Lee configuracion (config.json)
    |
    +-> .{inits.*}.()                 // Inicializa todos los widgets y connectors
    |
    +-> onReady()                     // Callback post-inicializacion
    |
    +-> LOOP:
            .{polls.*}.()            // Polling de connectors y widgets
            +
            requestAnimationFrame()   // Ciclo de renderizado del browser
```

### 5.2 Comparacion con Modelo Embebido

```
EMBEBIDO:                              DASHBOARD:
+--------------------------+           +--------------------------+
| Power On                 |           | Page Load                |
|   |                      |           |   |                      |
|   +-> initSystem()       |           |   +-> loadCore()         |
|   |   (init MCU)         |           |   |   (carga engine JS)  |
|   |                      |           |   |                      |
|   +-> SystemConfig()     |           |   +-> loadConfig()       |
|   |   (fuses, clock)     |           |   |   (JSON config)      |
|   |                      |           |   |                      |
|   +-> .{inits.*}.()      |           |   +-> .{inits.*}.()      |
|   |   (init APIs)        |           |   |   (init widgets)     |
|   |                      |           |   |                      |
|   +-> onReset()          |           |   +-> onReady()          |
|   |   (post-init)        |           |   |   (post-init)        |
|   |                      |           |   |                      |
|   +-> LOOP:              |           |   +-> LOOP:              |
|       .{polls.*}.()      |           |       .{polls.*}.()      |
|       (super loop)       |           |       + rAF()            |
|                          |           |       (event loop)       |
+--------------------------+           +--------------------------+
```

### 5.3 Diferencias Clave en Runtime

| Aspecto | Embebido | Dashboard |
|---------|----------|-----------|
| Loop principal | `while(1)` super loop | `requestAnimationFrame` + Event Loop |
| Interrupciones | Hardware ISR | DOM Events + EventBus |
| Polling | Lectura directa de registros | Consulta a servicios (MQTT, REST) |
| Estado | Variables C en RAM | State Manager (JS objeto reactivo) |
| I/O | GPIO, ADC, UART | DOM, Fetch, WebSocket |
| Concurrencia | ISR + flag polling | Promises, async/await, Web Workers |
| Persistencia | EEPROM, Flash | localStorage, IndexedDB |

### 5.4 Flujo de Eventos en Dashboard

**Evento disparado por datos externos:**

```
[Mensaje MQTT recibido]
        |
[Connector MQTT procesa]
        |
[Publica en EventBus]
        |
[Widget Gauge recibe]
        |
[Actualiza Shadow DOM]
        |
[Browser renderiza]
```

**Evento disparado por interaccion del usuario:**

```
[Click en ToggleSwitch]
        |
[DOM Event capturado]
        |
[Widget procesa]
        |
[Publica en EventBus]
        |
[Connector envia comando]
        |
[Dispositivo IoT recibe]
```

---

## 6. Hosting Estatico sin Backend

Una decision arquitectonica fundamental del Dashboard SDK es que el resultado de la generacion es un **sitio web puramente estatico**. No existe logica server-side.

### 6.1 Que Significa "Sin Backend"

```
ARQUITECTURA TRADICIONAL:               ARQUITECTURA EMIC DASHBOARD:
+--------+    +--------+    +------+    +--------+    +--------+
| Browser|--->| Server |--->| DB   |    | Browser|--->| CDN    |
|        |<---|  (Node |<---|      |    |        |<---| (solo  |
|        |    |  PHP   |    |      |    |        |    | archivos
|        |    |  etc.) |    |      |    |        |    | estaticos)
+--------+    +--------+    +------+    +--------+    +--------+
                                             |
                                             +----------+----------+
                                             |          |          |
                                          +--v---+  +--v---+  +--v---+
                                          | MQTT |  | REST |  | Fire |
                                          |broker|  | API  |  | base |
                                          +------+  +------+  +------+
```

**El browser se comunica directamente** con los servicios externos a traves de los Connectors. No hay un servidor intermediario que procese logica de negocio.

### 6.2 Opciones de Hosting

| Plataforma | Costo | Configuracion | CI/CD |
|-----------|-------|---------------|-------|
| GitHub Pages | Gratis | Minima | GitHub Actions |
| Netlify | Gratis (tier basico) | Baja | Integrado |
| Vercel | Gratis (tier basico) | Baja | Integrado |
| AWS S3 + CloudFront | Bajo | Media | AWS CodePipeline |
| Azure Blob Storage | Bajo | Media | Azure DevOps |
| Servidor propio (nginx) | Variable | Alta | Manual o custom |

### 6.3 Flujo de Despliegue

```
[EMIC Generate]
      |
      v
[TARGET: proyecto web]
      |
      +-> git push (GitHub Pages)
      |
      +-> netlify deploy (Netlify)
      |
      +-> aws s3 sync (S3)
      |
      +-> scp / rsync (servidor propio)
      |
      v
[Dashboard accesible via URL]
```

### 6.4 Seguridad en Hosting Estatico

Al no tener backend, la seguridad requiere consideraciones especiales:

| Riesgo | Solucion |
|--------|---------|
| API keys expuestas en JS | Claves con permisos restringidos (read-only, dominio limitado) |
| Credenciales de servicios | Inyeccion via CI/CD (variables de entorno en build) |
| Operaciones sensibles | Serverless functions (Lambda, Cloud Functions) como proxy |
| Autenticacion de usuarios | Delegada a servicios (Firebase Auth, Supabase Auth, Auth0) |
| CORS | Configurado en los servicios externos, no en el dashboard |

**Ejemplo de inyeccion segura de claves via CI/CD:**

```
// En generate.emic, la clave se referencia como macro
EMIC:define(mqtt.apiKey, .{env.MQTT_API_KEY}.)

// En CI/CD (GitHub Actions):
// La variable MQTT_API_KEY se configura como secret
// EMIC Generate la sustituye durante el build
// El valor nunca esta en el repositorio de codigo
```

### 6.5 Ventajas del Hosting Estatico

1. **Costo minimo:** Hosting gratuito o de centavos por mes
2. **Escalabilidad infinita:** CDN distribuye globalmente
3. **Sin mantenimiento de servidor:** No hay patches, no hay uptime concerns
4. **Velocidad:** Archivos servidos desde edge nodes cercanos al usuario
5. **Seguridad simplificada:** Sin superficie de ataque server-side
6. **Disponibilidad:** CDNs ofrecen 99.99%+ uptime

---

## 7. Tabla de Equivalencias Embebido vs Dashboard

Esta tabla es la **referencia central** para entender como cada concepto del mundo embebido se traduce al mundo del Dashboard web.

### 7.1 Equivalencias de Arquitectura

| Concepto Embebido | Concepto Dashboard | Descripcion |
|-------------------|-------------------|-------------|
| MCU (Microcontrolador) | Browser | Entorno de ejecucion |
| Firmware (.hex/.bin) | Proyecto web estatico | Artefacto generado |
| GCC / XC Compiler | Deploy (upload) | Post-procesamiento |
| Flash / ROM | Archivos en CDN/servidor | Almacenamiento de programa |
| RAM | Memoria JS del browser | Estado en ejecucion |
| EEPROM | localStorage / IndexedDB | Persistencia local |
| Clock (FOSC) | requestAnimationFrame | Base de tiempo |
| Power On | Page Load | Inicio de ejecucion |
| Reset | Page Reload (F5) | Reinicio |

### 7.2 Equivalencias de Capas

| Capa Embebida | Carpeta Embebida | Capa Dashboard | Carpeta Dashboard |
|--------------|------------------|----------------|-------------------|
| Modules | `_modules/` | Modules | `_modules/` |
| APIs | `_api/` | Widgets | `_widgets/` |
| Drivers | `_drivers/` | Connectors | `_connectors/` |
| HAL | `_hal/` | HAL | `_hal/` |
| Hardware (_hard) | `_hard/` | (no aplica) | -- |
| Utilities | `_util/` | Utilities | `_util/` |
| System | `_system/` | System | `_system/` |

### 7.3 Equivalencias de I/O y Comunicacion

| Embebido | Dashboard | Funcion |
|----------|-----------|---------|
| GPIO (Digital I/O) | Data Binding (property) | Entrada/salida de datos |
| ADC (lectura analogica) | Fetch / REST GET | Lectura de valor externo |
| DAC (escritura analogica) | REST POST / MQTT publish | Escritura de valor hacia afuera |
| UART / Serial | WebSocket | Comunicacion bidireccional |
| SPI | REST API (request/response) | Comunicacion sinconica |
| I2C | MQTT (pub/sub) | Bus de mensajes compartido |
| Interrupt (ISR) | EventBus / DOM Event | Reaccion a evento asincrono |
| Timer | setInterval / setTimeout | Temporizacion periodica |
| PWM | CSS Animation / rAF | Control de actualizacion gradual |
| Watchdog | Heartbeat / keep-alive | Monitoreo de salud |

### 7.4 Equivalencias de Streams

| Embebido | Dashboard | Proposito |
|----------|-----------|-----------|
| `streamOut_t` (put, getAvailable) | `DataStream.write()` | Salida de datos |
| `streamIn_t` (get, count) | `DataStream.read()` | Entrada de datos |
| UART stream | WebSocket stream | Canal serie bidireccional |
| USB stream | HTTP/2 stream | Canal de alta velocidad |

### 7.5 Equivalencias de Patron de Codigo

| Patron Embebido | Patron Dashboard |
|-----------------|------------------|
| `#include "led.h"` | `import` / `<script src="...">` |
| `EMIC:define(inits.X, X_init)` | `EMIC:define(inits.X, X_init)` (identico) |
| `EMIC:define(polls.X, X_poll)` | `EMIC:define(polls.X, X_poll)` (identico) |
| `EMIC:define(c_modules.X, X)` | `EMIC:define(js_modules.X, X)` |
| `EMIC:define(main_includes.X, X)` | `EMIC:define(web_imports.X, X)` |
| `void X_init(void)` | `function X_init()` o `X.init()` |
| `void X_poll(void)` | `function X_poll()` o `X.poll()` |
| `while(1) { polls(); }` | `requestAnimationFrame(polls)` |
| `#ifndef _GUARD_` | `EMIC:ifndef _GUARD_` (identico) |

### 7.6 Equivalencias de Eventos

| Embebido | Dashboard | Ejemplo |
|----------|-----------|---------|
| Hardware Interrupt -> ISR | DOM Event -> Handler | Click, input change |
| Timer overflow -> callback | setInterval -> callback | Actualizacion periodica |
| UART Rx -> onReceive | WebSocket onmessage | Dato recibido |
| Pin change -> onChange | MutationObserver / EventBus | Cambio de estado |
| `extern void onEvent()` | `extern void onEvent()` (identico en .emic) | Evento usuario |

### 7.7 Equivalencias de Configuracion

| Embebido | Dashboard | Proposito |
|----------|-----------|-----------|
| `_pcb/inc/Board.h` (pin mapping) | `config/layout.json` (widget placement) | Mapeo fisico/visual |
| `#pragma config` (fuses) | `config/app.json` (settings) | Configuracion del sistema |
| `FOSC 240000000UL` | `pollInterval: 1000` | Parametros de timing |
| `systemConfig.h` | `theme.json` / `branding.json` | Apariencia |

### 7.8 Diagrama Comparativo de Arquitectura Completa

```
SDK EMBEBIDO:                          DASHBOARD SDK:

+-------------------+                  +-------------------+
|    _modules/      |                  |    _modules/      |
| (HW+FW completo)  |                  | (Dashboard compl.)|
+--------+----------+                  +--------+----------+
         |                                      |
    +----+----+                            +----+----+
    |         |                            |         |
+---v---+ +---v----+                  +----v--+ +---v-------+
| _api/ | |_drivers/|                  |_widgets| |_connectors|
| (APIs)| |(Drivers)|                  |(Visual)| |(Servicios)|
+---+---+ +---+----+                  +----+--+ +---+-------+
    |         |                            |         |
    +----+----+                            +----+----+
         |                                      |
    +----v----+                            +----v----+
    |  _hal/  |                            |  _hal/  |
    |  (MCU   |                            | (Browser|
    | periph.)|                            |  APIs)  |
    +----+----+                            +---------+
         |
    +----v----+
    | _hard/  |
    | (Regist-|                            (no aplica en
    |  ros)   |                             Dashboard)
    +---------+
```

---

## 8. Resumen del Capitulo

### Conceptos Clave Aprendidos

- **Dashboard SDK:** Genera sitios web estaticos usando el mismo EMIC-Codify que el SDK embebido
- **Pipeline:** Script -> EMIC Generate -> Proyecto Web -> Deploy -> Browser
- **6 Capas:** Modules, Widgets, Connectors, HAL, System, Utilities
- **Discovery Dual:** `discovery.emic` (catalogo con `_INSTANCE_`) + `generate.emic` (foreach sobre instancias)
- **Modelo de Ejecucion:** loadCore -> loadConfig -> inits -> onReady -> LOOP (polls + rAF)
- **Hosting Estatico:** Sin backend, deploy en CDN, connectors hablan directo con servicios
- **Equivalencias:** Cada concepto embebido tiene su analogo web (MCU=Browser, GPIO=DataBinding, ISR=EventBus)

### Proximo Paso

Ahora que comprendes tanto la arquitectura embebida como la del Dashboard, el siguiente capitulo te proporcionara un **glosario completo** que incluye terminologia de ambos mundos.

**Proximo capitulo:** [Cap 03 - Glosario y Vocabulario EMIC ->](03_Glosario.md)

---

[<- Anterior: Arquitectura Embebida](02_Arquitectura.md) | [Siguiente: Glosario ->](03_Glosario.md)

---

*Capitulo 02b - Manual de Desarrollo EMIC Dashboard SDK v1.0*
*Ultima actualizacion: Febrero 2026*
