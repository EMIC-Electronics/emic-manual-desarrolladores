# Capitulo 25b: Desarrollo de un Modulo Dashboard Completo

[← Anterior: Desarrollo Modulo (Embebido)](25_Desarrollo_Modulo_Completo.md) | [Siguiente: Plugins Editor →](26_Plugins_Editor.md)

## Indice
1. [Que es un Modulo Dashboard](#1-que-es-un-modulo-dashboard)
2. [m_description.json con type web-dashboard](#2-m_descriptionjson-con-type-web-dashboard)
3. [discovery.emic Completo](#3-discoveryemic-completo)
4. [generate.emic Completo con foreach](#4-generateemic-completo-con-foreach)
5. [deploy.emic](#5-deployemic)
6. [Resultado: Proyecto Web Generado](#6-resultado-proyecto-web-generado)
7. [Ejemplo: Industrial Monitoring Dashboard](#7-ejemplo-industrial-monitoring-dashboard)
8. [Tabla de Equivalencias Embebido vs Dashboard](#8-tabla-de-equivalencias-embebido-vs-dashboard)

---

## 1. Que es un Modulo Dashboard

Un **modulo dashboard** es una unidad de proyecto independiente que combina un **layout visual** con los **widgets y connectors** necesarios para crear una aplicacion web de monitoreo y control. Los modulos representan el nivel mas alto de abstraccion en el SDK Dashboard.

A diferencia de los modulos embebidos (que definen un PCB especifico con APIs fijas), un modulo dashboard:

- Define un **layout visual** y un **theme** predeterminados
- Lista los **widgets y connectors disponibles** para el usuario
- Genera un **proyecto web estatico** en lugar de firmware compilable
- Usa **foreach dinamico** en lugar de setInput fijos

### 1.1 Relacion con Otros Capitulos

| Capitulo | Relacion |
|----------|----------|
| **21b** | Como crear los widgets que usa el modulo |
| **22b** | Como crear los connectors que usa el modulo |
| **23b** | Como funciona el proceso de generacion con Discovery + Generate |
| **25** | Equivalente embebido de este capitulo |

---

## 2. m_description.json con type web-dashboard

### 2.1 Estructura del Archivo

**Archivo: `m_description.json`**

```json
{
    "type": "web-dashboard",
    "toolTip": "Industrial Monitoring Dashboard",
    "description": "Real-time monitoring dashboard with gauges, charts, and MQTT connectivity for industrial IoT applications.",
    "Sizes": "Responsive (1024px - 1920px)",

    "Table": [
        {"Name": "Framework", "Value": "EMIC Dashboard SDK"},
        {"Name": "Layout", "Value": "dashboard-grid (12 columnas)"},
        {"Name": "Theme", "Value": "industrial"},
        {"Name": "PWA", "Value": "Si (offline capable)"},
        {"Name": "Deploy", "Value": "GitHub Pages / Netlify / Vercel"}
    ],

    "HardwareDescription": [
        {"PinName": "Gauge", "PinType": "Widget", "PinDescription": "Radial/linear gauge indicator"},
        {"PinName": "LineChart", "PinType": "Widget", "PinDescription": "Real-time line chart"},
        {"PinName": "LED", "PinType": "Widget", "PinDescription": "Status LED indicator"},
        {"PinName": "Switch", "PinType": "Widget", "PinDescription": "On/Off toggle control"},
        {"PinName": "Button", "PinType": "Widget", "PinDescription": "Action button control"},
        {"PinName": "Label", "PinType": "Widget", "PinDescription": "Text label with binding"},
        {"PinName": "MQTTClient", "PinType": "Connector", "PinDescription": "MQTT broker connection"},
        {"PinName": "RESTClient", "PinType": "Connector", "PinDescription": "HTTP REST API client"}
    ],

    "features": [
        "Real-time data visualization",
        "MQTT connectivity for IoT devices",
        "REST API integration",
        "Responsive design (desktop + tablet)",
        "PWA: installable and offline capable",
        "Industrial dark theme",
        "CSS Grid layout with 12 columns"
    ],

    "applications": [
        "Industrial process monitoring (SCADA-lite)",
        "IoT sensor dashboards",
        "Equipment status panels",
        "Factory floor displays",
        "Remote monitoring stations"
    ],

    "keyWord": [
        "dashboard", "monitoring", "industrial", "iot",
        "mqtt", "gauge", "chart", "scada", "web"
    ]
}
```

### 2.2 Campos Especificos de Dashboard

| Campo | Valor Embebido | Valor Dashboard | Descripcion |
|-------|---------------|-----------------|-------------|
| `type` | `"gcc"` | `"web-dashboard"` | Tipo de modulo |
| `HardwareDescription.PinType` | `"Led"`, `"I2C"`, `"Analog"` | `"Widget"`, `"Connector"` | Tipo de recurso |
| `Table` | Specs electricas (Vcc, Icc) | Specs de plataforma (layout, theme) | Metadatos |

---

## 3. discovery.emic Completo

El archivo `discovery.emic` lista **todos** los widgets y connectors que el modulo pone a disposicion del usuario.

### 3.1 Ejemplo Completo

**Archivo: `_modules/Industrial/MonitorDashboard/System/discovery.emic`**

```emic
EMIC:setOutput(SYS:discovery.txt)

    // ==========================================================
    // WIDGETS DISPONIBLES
    // Cada setInput usa name=_INSTANCE_ como placeholder
    // Discovery extrae los tags DOXYGEN de cada widget
    // ==========================================================

    // --- Indicadores ---
    EMIC:setInput(DEV:_widgets/Indicators/Gauge/gauge.emic, name=_INSTANCE_)
    EMIC:setInput(DEV:_widgets/Indicators/LED/led.emic, name=_INSTANCE_)
    EMIC:setInput(DEV:_widgets/Indicators/Label/label.emic, name=_INSTANCE_)

    // --- Graficos ---
    EMIC:setInput(DEV:_widgets/Charts/LineChart/lineChart.emic, name=_INSTANCE_)
    EMIC:setInput(DEV:_widgets/Charts/BarChart/barChart.emic, name=_INSTANCE_)

    // --- Controles ---
    EMIC:setInput(DEV:_widgets/Controls/Switch/switch.emic, name=_INSTANCE_)
    EMIC:setInput(DEV:_widgets/Controls/Slider/slider.emic, name=_INSTANCE_)
    EMIC:setInput(DEV:_widgets/Controls/Button/button.emic, name=_INSTANCE_)

    // ==========================================================
    // CONNECTORS DISPONIBLES
    // ==========================================================
    EMIC:setInput(DEV:_connectors/MQTT/MQTTClient/mqtt-client.emic, name=_INSTANCE_)
    EMIC:setInput(DEV:_connectors/REST/RESTClient/rest-client.emic, name=_INSTANCE_)
    EMIC:setInput(DEV:_connectors/WebSocket/WSClient/ws-client.emic, name=_INSTANCE_)

EMIC:restoreOutput
```

### 3.2 Resultado del Discovery

Despues de ejecutar Discovery, el editor genera el catalogo Resources con todas las funciones y eventos de todos los widgets/connectors, usando `_INSTANCE_` como placeholder en los nombres. Este catalogo permite al usuario ver que funciones estaran disponibles para cada tipo de componente antes de instanciarlo.

---

## 4. generate.emic Completo con foreach

### 4.1 Ejemplo Completo

**Archivo: `_modules/Industrial/MonitorDashboard/System/generate.emic`**

```emic
EMIC:setOutput(TARGET:generate.txt)

    // ==========================================================
    // SECCION 1: LAYOUT Y THEME
    // El layout define la grilla CSS, el theme define colores
    // ==========================================================
    EMIC:setInput(DEV:_layouts/layouts.emic, layout=dashboard-grid, theme=industrial)

    // ==========================================================
    // SECCION 2: FUNCIONES Y EVENTOS USADOS
    // Generados por el editor segun el codigo del usuario
    // ==========================================================
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    // ==========================================================
    // SECCION 3: WIDGETS SELECCIONADOS POR EL USUARIO
    // El grupo "widgets" es definido por el editor con las
    // instancias que el usuario arrastro al canvas
    //
    // Ejemplo de estado del editor:
    //   EMIC:define(widgets.tempGauge, Gauge)
    //   EMIC:define(widgets.pressGauge, Gauge)
    //   EMIC:define(widgets.flowChart, LineChart)
    //   EMIC:define(widgets.pumpSwitch, Switch)
    //   EMIC:define(widgets.statusLed, LED)
    //   EMIC:define(widgets.alarmLabel, Label)
    // ==========================================================
    EMIC:foreach(widgets.*)
        EMIC:setInput(DEV:_widgets/.{widgets.{*}}./.{widgets.{*}}..emic, name=.{*}.)
    EMIC:endforeach

    // ==========================================================
    // SECCION 4: CONNECTORS SELECCIONADOS POR EL USUARIO
    //
    // Ejemplo de estado del editor:
    //   EMIC:define(connectors.broker1, MQTTClient)
    //   EMIC:define(connectors.dataApi, RESTClient)
    // ==========================================================
    EMIC:foreach(connectors.*)
        EMIC:setInput(DEV:_connectors/.{connectors.{*}}./.{connectors.{*}}..emic, name=.{*}.)
    EMIC:endforeach

    // ==========================================================
    // SECCION 5: SYSTEM CORE
    // EventBus, Component Base, utilidades
    // ==========================================================
    EMIC:setInput(DEV:_system/system.emic)

    // ==========================================================
    // SECCION 6: ENTRY POINT WEB
    // index.html, app-shell.js, sw.js
    // ==========================================================
    EMIC:setInput(DEV:_main/webapp/main.emic)

    // ==========================================================
    // SECCION 7: CODIGO DEL USUARIO
    // Logica de la aplicacion (conectar widgets con connectors)
    // ==========================================================
    EMIC:copy(SYS:userApp.js > TARGET:userApp.js)
    EMIC:define(modules.userApp, userApp)

    // ==========================================================
    // SECCION 8: DEPLOY TEMPLATE
    // Configuracion de hosting (GitHub Pages, Netlify, etc.)
    // ==========================================================
    EMIC:copy(DEV:_templates/deploy/github-pages > TARGET:)

EMIC:restoreOutput
```

### 4.2 Orden Obligatorio

El orden de las secciones en `generate.emic` es **critico**, igual que en el SDK embebido:

```
1. Layout/Theme     (equivale a PCB en embebido)
2. usedFunction     (funciones que usa el integrador)
3. usedEvent        (eventos que implementa el integrador)
4. Widgets          (equivale a APIs en embebido)
5. Connectors       (equivale a Drivers explicitos en embebido)
6. System           (core del framework)
7. Main             (entry point)
8. Codigo usuario   (logica del integrador)
9. Deploy template  (equivale a template MPLAB X)
```

---

## 5. deploy.emic

El archivo `deploy.emic` se ejecuta cuando el usuario crea una nueva instancia del modulo en el editor.

### 5.1 Ejemplo Completo

**Archivo: `_modules/Industrial/MonitorDashboard/System/deploy.emic`**

```emic
EMIC:setOutput(SYS:deploy.txt)

    // ==========================================================
    // 1. CREAR ARCHIVOS DE USUARIO VACIOS
    // ==========================================================
    EMIC:setOutput(SYS:userApp.js)
    // EMIC Dashboard - User Application Code
    // Write your application logic here

    function onReady() {
        // Called when all widgets and connectors are initialized
        // Example: connect to MQTT broker
        // broker1.connect('wss://broker.example.com:8084/mqtt');
    }
    EMIC:restoreOutput

    // ==========================================================
    // 2. CREAR CARPETA inc/ (para headers/configs)
    // ==========================================================
    EMIC:setOutput(SYS:inc/userConfig.json)
    {
        "dashboardName": ".{module.name}.",
        "version": "1.0.0"
    }
    EMIC:restoreOutput

    // ==========================================================
    // 3. COPIAR PLUGINS DEL EDITOR (sidebar tabs)
    // Incluye: Widgets, Services, Code, Data, Functions, User
    // ==========================================================
    EMIC:copy(DEV:_templates/plugins/sidebar-tabs > SYS:EMIC-TABS)

    // ==========================================================
    // 4. GENERAR MANIFEST.JSON PARA PWA
    // ==========================================================
    EMIC:setOutput(TARGET:manifest.json)
    {
        "name": ".{module.name}.",
        "short_name": ".{module.name}.",
        "start_url": "/",
        "display": "standalone",
        "background_color": "#1a1a2e",
        "theme_color": "#1a1a2e",
        "icons": [
            {
                "src": "icon-192.png",
                "sizes": "192x192",
                "type": "image/png"
            }
        ]
    }
    EMIC:restoreOutput

EMIC:restoreOutput
```

### 5.2 Resultado del Deploy + Discovery

Despues del deploy, la estructura del modulo queda:

```
MonitorDashboard/
+-- m_description.json
+-- System/
    +-- discovery.emic
    +-- generate.emic
    +-- deploy.emic
    +-- userApp.js                   # Creado por deploy
    +-- inc/
    |   +-- userConfig.json          # Creado por deploy
    +-- EMIC-TABS/                   # Copiado de templates
        +-- Widgets/                 # Catalogo de widgets
        +-- Services/                # Catalogo de connectors
        +-- Code/                    # Bloques de logica
        +-- Data/                    # Variables
        +-- Functions/               # Funciones usuario
        +-- User/                    # Tab personalizado
        +-- Resources                # GENERADO por EMIC-Discovery
```

El archivo `Resources` es generado **automaticamente** por EMIC-Discovery basandose en los tags DOXYGEN de los widgets y connectors listados en `discovery.emic`.

---

## 6. Resultado: Proyecto Web Generado

### 6.1 Estructura de TARGET/

Asumiendo que el usuario agrego los siguientes componentes:

- Widgets: tempGauge (Gauge), pressGauge (Gauge), flowChart (LineChart), pumpSwitch (Switch), statusLed (LED), alarmLabel (Label)
- Connectors: broker1 (MQTTClient), dataApi (RESTClient)

```
TARGET/
+-- index.html                       # Entry point con todos los imports
+-- app-shell.js                     # Application shell (inits + polls)
+-- sw.js                            # Service Worker (PWA)
+-- manifest.json                    # PWA manifest
+-- userApp.js                       # Codigo del usuario
+--
+-- css/
|   +-- layout.css                   # CSS Grid (dashboard-grid)
|   +-- theme.css                    # Theme (industrial)
|   +-- responsive.css               # Media queries
|   +-- emic-gauge.css               # Estilos del widget Gauge
|   +-- emic-chart.css               # Estilos del widget Chart
|   +-- emic-switch.css              # Estilos del widget Switch
|   +-- emic-led.css                 # Estilos del widget LED
|   +-- emic-label.css               # Estilos del widget Label
+--
+-- js/
|   +-- emic-core.js                 # EventBus y utilidades
|   +-- emic-component-base.js       # Base class WebComponents
+--
+-- emic-gauge_tempGauge.js          # Gauge instancia "tempGauge"
+-- emic-gauge_pressGauge.js         # Gauge instancia "pressGauge"
+-- emic-chart_flowChart.js          # LineChart instancia "flowChart"
+-- emic-switch_pumpSwitch.js        # Switch instancia "pumpSwitch"
+-- emic-led_statusLed.js            # LED instancia "statusLed"
+-- emic-label_alarmLabel.js         # Label instancia "alarmLabel"
+--
+-- mqtt-client_broker1.js           # MQTT connector "broker1"
+-- rest-client_dataApi.js           # REST connector "dataApi"
+-- lib/
|   +-- mqtt.min.js                  # Libreria MQTT
+--
+-- .github/
    +-- workflows/
        +-- deploy.yml               # GitHub Actions deploy
```

### 6.2 index.html Generado

```html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Industrial Monitoring Dashboard</title>

    <!-- Expansion de .{styles.*}. -->
    <link rel="stylesheet" href="css/layout.css">
    <link rel="stylesheet" href="css/theme.css">
    <link rel="stylesheet" href="css/responsive.css">
    <link rel="stylesheet" href="css/emic-gauge.css">
    <link rel="stylesheet" href="css/emic-chart.css">
    <link rel="stylesheet" href="css/emic-switch.css">
    <link rel="stylesheet" href="css/emic-led.css">
    <link rel="stylesheet" href="css/emic-label.css">

    <link rel="manifest" href="manifest.json">
    <meta name="theme-color" content="#1a1a2e">
</head>
<body>
    <div class="emic-dashboard" id="app"></div>

    <script src="js/emic-core.js"></script>
    <script src="js/emic-component-base.js"></script>
    <script src="lib/mqtt.min.js"></script>

    <!-- Expansion de .{imports.*}. -->
    <script type="module" src="emic-gauge_tempGauge.js"></script>
    <script type="module" src="emic-gauge_pressGauge.js"></script>
    <script type="module" src="emic-chart_flowChart.js"></script>
    <script type="module" src="emic-switch_pumpSwitch.js"></script>
    <script type="module" src="emic-led_statusLed.js"></script>
    <script type="module" src="emic-label_alarmLabel.js"></script>
    <script type="module" src="mqtt-client_broker1.js"></script>
    <script type="module" src="rest-client_dataApi.js"></script>

    <script src="app-shell.js"></script>
    <script src="userApp.js"></script>

    <script>
        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.register('sw.js');
        }
    </script>
</body>
</html>
```

---

## 7. Ejemplo: Industrial Monitoring Dashboard

### 7.1 Escenario

Crear un dashboard para monitorear una planta industrial con:
- 2 gauges (temperatura y presion)
- 1 grafico de linea (flujo en tiempo real)
- 1 switch (control de bomba)
- 1 LED (estado del sistema)
- 1 label (alarmas)
- 1 conexion MQTT (datos de sensores)
- 1 conexion REST (API de configuracion)

### 7.2 Codigo del Usuario (userApp.js)

```javascript
// Industrial Monitoring Dashboard - User Application

function onReady() {
    // Conectar al broker MQTT
    broker1.connect('wss://mqtt.factory.local:8084/mqtt');

    // Configurar gauges
    tempGauge.setRange(0, 200);
    tempGauge.setThreshold(150);
    pressGauge.setRange(0, 10);
    pressGauge.setThreshold(8);

    // Suscribirse a topics de sensores
    broker1.subscribe('factory/sensors/temperature');
    broker1.subscribe('factory/sensors/pressure');
    broker1.subscribe('factory/sensors/flow');
    broker1.subscribe('factory/alarms/#');

    // Cargar configuracion del servidor
    dataApi.setHeader('Authorization', 'Bearer my-token');
    dataApi.get('https://api.factory.local/config');
}

// Manejar mensajes MQTT
function broker1_onMessage(topic, message) {
    var value = parseFloat(message);

    if (topic === 'factory/sensors/temperature') {
        tempGauge.setValue(value);
    }
    else if (topic === 'factory/sensors/pressure') {
        pressGauge.setValue(value);
    }
    else if (topic === 'factory/sensors/flow') {
        flowChart.addPoint(Date.now(), value);
    }
    else if (topic.startsWith('factory/alarms/')) {
        alarmLabel.setText(message);
        statusLed.setState(2);  // Parpadeo
    }
}

// Manejar threshold de temperatura
function tempGauge_onThreshold(value) {
    alarmLabel.setText('ALTA TEMPERATURA: ' + value + ' C');
    statusLed.setState(1);  // Encendido (alarma)
}

// Manejar control de bomba
function pumpSwitch_onChange(state) {
    broker1.publish('factory/control/pump', state ? 'ON' : 'OFF');
    statusLed.setState(state ? 1 : 0);
}

// Manejar respuesta de configuracion
function dataApi_onResponse(data) {
    var config = JSON.parse(data);
    if (config.tempMax) tempGauge.setRange(0, config.tempMax);
    if (config.pressMax) pressGauge.setRange(0, config.pressMax);
}
```

### 7.3 Flujo de Datos del Ejemplo

```
+-------------------+          +-------------------+
|   Sensores IoT    |          |   API Servidor    |
|   (ESP32 + EMIC)  |          |   (REST)          |
+--------+----------+          +--------+----------+
         |                              |
         | MQTT publish                 | HTTP GET
         | factory/sensors/*            | /config
         |                              |
+--------v----------+          +--------v----------+
|   Mosquitto       |          |   Express.js      |
|   MQTT Broker     |          |   API Server      |
+--------+----------+          +--------+----------+
         |                              |
         | WSS                          | JSON
         |                              |
+--------v--------------------------v---v----------+
|                                                   |
|            Dashboard (Browser)                    |
|                                                   |
|  +--------+  +--------+  +-----------+            |
|  | broker1|  | dataApi|  |           |            |
|  | (MQTT) |  | (REST) |  | EventBus  |            |
|  +---+----+  +---+----+  +-----+-----+            |
|      |           |              |                  |
|      v           v              v                  |
|  +---------+ +---------+ +---------+ +---------+  |
|  |tempGauge| |pressGauge| |flowChart| |pumpSwitch|  |
|  | 175.3 C | | 6.2 bar | |  ~~~~   | | [ON]    |  |
|  +---------+ +---------+ +---------+ +---------+  |
|                                                   |
+---------------------------------------------------+
```

---

## 8. Tabla de Equivalencias Embebido vs Dashboard

| Aspecto | Modulo Embebido | Modulo Dashboard |
|---------|-----------------|-------------------|
| **Carpeta** | `_modules/Categoria/Modulo/` | `_modules/Categoria/Modulo/` (identica) |
| **type en m_description** | `"gcc"` | `"web-dashboard"` |
| **HardwareDescription** | Pines fisicos (Led, I2C, Analog) | Widget slots (Widget, Connector) |
| **discovery.emic** | No existe (integrado en generate) | Archivo separado con `_INSTANCE_` |
| **generate.emic** | setInput fijos para cada API | foreach dinamico sobre widgets/connectors |
| **deploy.emic** | Crea userFncFile.c/.h + plugins | Crea userApp.js + plugins + manifest.json |
| **PCB / Layout** | `_pcb/pcb.emic` con pin mapping | `_layouts/layouts.emic` con CSS Grid |
| **APIs / Widgets** | `setInput(led.emic, name=led1)` fijo | `foreach(widgets.*) setInput(...)` dinamico |
| **Drivers / Connectors** | Cargados implicitamente por APIs | `foreach(connectors.*) setInput(...)` dinamico |
| **Main** | `_main/baremetal/main.emic` | `_main/webapp/main.emic` |
| **User code** | `userFncFile.c` / `userFncFile.h` | `userApp.js` |
| **Template** | `_templates/projects/mplabx` | `_templates/deploy/github-pages` |
| **Output** | `TARGET/` con .c, .h, Makefile | `TARGET/` con .js, .css, .html |
| **Compilacion** | `make build` -> firmware.hex | `git push` -> sitio web estatico |
| **Resources** | Auto-generado por Discovery | Auto-generado por Discovery (identico) |
| **Plugins Editor** | Code, Data, Functions, User | Widgets, Services, Code, Data, Functions, User |

---

## Resumen

### Archivos de un Modulo Dashboard

| Archivo | Proposito |
|---------|-----------|
| `m_description.json` | Metadatos con `type: "web-dashboard"` |
| `discovery.emic` | Lista todos los widgets/connectors con `_INSTANCE_` |
| `generate.emic` | foreach sobre widgets y connectors seleccionados |
| `deploy.emic` | Crea userApp.js, plugins, manifest.json |

### Flujo de Desarrollo de un Modulo Dashboard

1. **Definir el proposito** del dashboard y seleccionar widgets/connectors necesarios
2. **Crear la estructura** de carpetas en `_modules/Categoria/`
3. **Escribir m_description.json** con `type: "web-dashboard"`
4. **Escribir discovery.emic** listando todos los widgets/connectors con `_INSTANCE_`
5. **Escribir generate.emic** con foreach sobre widgets y connectors
6. **Escribir deploy.emic** para crear archivos iniciales y copiar plugins
7. **Probar en el editor** creando un proyecto, arrastrando widgets, haciendo Deploy
8. **Verificar en browser** abriendo TARGET/index.html

### Diferencia Clave con Modulo Embebido

```
EMBEBIDO:                               DASHBOARD:
  generate.emic tiene                     generate.emic tiene
  setInput FIJOS:                         foreach DINAMICOS:

  setInput(led.emic, name=led1)           foreach(widgets.*)
  setInput(led.emic, name=led2)             setInput(..., name=.{*}.)
  setInput(timer.emic, name=1)            endforeach
```

La dinamicidad es la diferencia arquitectonica fundamental: en dashboard, la cantidad y nombres de los componentes los decide el usuario en tiempo de diseno, no el desarrollador del modulo.

---

**Navegacion:**
- [← Capitulo 25: Desarrollo Modulo (Embebido)](25_Desarrollo_Modulo_Completo.md)
- [→ Capitulo 26: Plugins del Editor](26_Plugins_Editor.md)
