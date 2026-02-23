# Capitulo 23b: Proceso de Generacion Web (Discovery + Generate)

[← Anterior: Proceso de Generacion (Embebido)](23_Proceso_Generacion_Generate.md) | [Siguiente: Desarrollo Widget →](21b_Desarrollo_Widget_Paso_a_Paso.md)

## Indice
1. [Diferencia Fundamental con Embebido](#1-diferencia-fundamental-con-embebido)
2. [Discovery Dual: discovery.emic + generate.emic](#2-discovery-dual-discoveryemic--generateemic)
3. [discovery.emic con _INSTANCE_](#3-discoveryemic-con-_instance_)
4. [Catalogo XML Generado con Templates](#4-catalogo-xml-generado-con-templates)
5. [Instanciacion Dinamica Client-Side](#5-instanciacion-dinamica-client-side)
6. [generate.emic Completo con foreach](#6-generateemic-completo-con-foreach)
7. [Resultado: Proyecto Web Generado](#7-resultado-proyecto-web-generado)
8. [Contraste Embebido vs Dashboard](#8-contraste-embebido-vs-dashboard)
9. [Grupos de Registro Web](#9-grupos-de-registro-web)

---

## 1. Diferencia Fundamental con Embebido

En el SDK embebido, el archivo `generate.emic` cumple **dos roles**: Discovery (que funciones hay disponibles) y Generacion (producir el codigo C). En el SDK Dashboard, estos roles se **separan** en dos archivos distintos.

### 1.1 Por que la Separacion

La razon fundamental es que en un dashboard, **los widgets se eligen interactivamente**:

```
EMBEBIDO                                 DASHBOARD
========                                 =========

El desarrollador decide                  El USUARIO decide
que APIs incluir al                      que widgets incluir al
escribir generate.emic                   arrastrar al canvas

  generate.emic:                           Canvas del editor:
  setInput(led.emic, name=led1)            [Gauge "temp"] [Chart "flow"]
  setInput(timer.emic, name=1)             [Switch "pump"] [LED "status"]

  Nombres fijos en tiempo                  Nombres elegidos en tiempo
  de desarrollo                            de diseno (drag-time)
```

### 1.2 Consecuencias Arquitectonicas

| Aspecto | Embebido | Dashboard |
|---------|----------|-----------|
| Quien elige componentes | Desarrollador del modulo | Usuario en el editor |
| Cuando se elige | Al escribir generate.emic | Al arrastrar widgets al canvas |
| Nombres de instancia | Fijos (`name=led1`) | Dinamicos (usuario los escribe) |
| Cantidad de instancias | Fija en generate.emic | Variable segun el usuario |
| Discovery | Mismo archivo (generate.emic) | Archivo separado (discovery.emic) |
| Generacion | generate.emic con setInput fijos | generate.emic con foreach dinamico |

---

## 2. Discovery Dual: discovery.emic + generate.emic

### 2.1 Dos Archivos, Dos Momentos

| Archivo | Cuando se ejecuta | Que procesa | Output |
|---------|-------------------|-------------|--------|
| `discovery.emic` | Al registrar el SDK en el editor | TODOS los widgets y connectors | Catalogo XML con placeholder `_INSTANCE_` |
| `generate.emic` | Al hacer Deploy (generar proyecto) | Solo los seleccionados por el usuario | Proyecto web completo en TARGET: |

### 2.2 Diagrama de Flujo Temporal

```
TIEMPO 1: Registro del SDK                TIEMPO 2: Deploy del Proyecto
===========================                ============================

discovery.emic                             generate.emic
     |                                          |
     v                                          v
Procesa TODOS los                          Procesa SOLO los widgets
widgets con name=_INSTANCE_                que el usuario agrego
     |                                          |
     v                                          v
Genera catalogo XML                        foreach(widgets.*)
con templates                                 setInput(widget.emic,
     |                                             name=.{*}.,
     v                                             ...)
EMIC-TABS/Resources                             |
(funciones con _INSTANCE_                       v
 en los nombres)                           TARGET: proyecto web
                                           con nombres reales
```

### 2.3 Flujo de Datos entre Discovery y Generate

```
+--------------------------------------------------+
|  1. SDK contiene _widgets/ y _connectors/         |
+----------------------------+---------------------+
                             |
                             v
+--------------------------------------------------+
|  2. discovery.emic procesa todos con _INSTANCE_   |
|     Genera: Resources XML con templates           |
+----------------------------+---------------------+
                             |
                             v
+--------------------------------------------------+
|  3. Editor muestra catalogo al usuario            |
|     Usuario arrastra widgets al canvas            |
|     Elige nombres: "tempGauge", "flowChart"       |
+----------------------------+---------------------+
                             |
                             v
+--------------------------------------------------+
|  4. Editor genera estado:                         |
|     widgets.tempGauge = Gauge                     |
|     widgets.flowChart = Chart                     |
|     connectors.broker1 = MQTTClient               |
+----------------------------+---------------------+
                             |
                             v
+--------------------------------------------------+
|  5. generate.emic usa foreach para iterar         |
|     sobre widgets y connectors                    |
|     Reemplaza _INSTANCE_ por nombres reales       |
+----------------------------+---------------------+
                             |
                             v
+--------------------------------------------------+
|  6. TARGET: proyecto web generado                 |
+--------------------------------------------------+
```

---

## 3. discovery.emic con _INSTANCE_

El archivo `discovery.emic` lista **todos** los widgets y connectors disponibles en el modulo, usando el placeholder `_INSTANCE_` en lugar de un nombre concreto.

### 3.1 Ejemplo Completo

**Archivo: `_modules/Industrial/MonitorDashboard/System/discovery.emic`**

```emic
EMIC:setOutput(TARGET:discovery.txt)

    // ============================================
    // WIDGETS DISPONIBLES
    // Todos usan name=_INSTANCE_ como placeholder
    // ============================================

    // Indicadores
    EMIC:setInput(DEV:_widgets/Indicators/Gauge/gauge.emic, name=_INSTANCE_)
    EMIC:setInput(DEV:_widgets/Indicators/LED/led.emic, name=_INSTANCE_)
    EMIC:setInput(DEV:_widgets/Indicators/Label/label.emic, name=_INSTANCE_)

    // Graficos
    EMIC:setInput(DEV:_widgets/Charts/LineChart/lineChart.emic, name=_INSTANCE_)
    EMIC:setInput(DEV:_widgets/Charts/BarChart/barChart.emic, name=_INSTANCE_)

    // Controles
    EMIC:setInput(DEV:_widgets/Controls/Switch/switch.emic, name=_INSTANCE_)
    EMIC:setInput(DEV:_widgets/Controls/Slider/slider.emic, name=_INSTANCE_)
    EMIC:setInput(DEV:_widgets/Controls/Button/button.emic, name=_INSTANCE_)

    // ============================================
    // CONNECTORS DISPONIBLES
    // ============================================
    EMIC:setInput(DEV:_connectors/MQTT/mqtt-client.emic, name=_INSTANCE_)
    EMIC:setInput(DEV:_connectors/REST/rest-client.emic, name=_INSTANCE_)
    EMIC:setInput(DEV:_connectors/WebSocket/ws-client.emic, name=_INSTANCE_)

EMIC:restoreOutput
```

### 3.2 Que Produce

Cuando EMIC-Discovery procesa este archivo, extrae los tags DOXYGEN de cada widget/connector y genera el catalogo Resources con `_INSTANCE_` en todos los nombres:

```
Funciones generadas (ejemplo para Gauge):
- Gauge__INSTANCE__setValue(float value)
- Gauge__INSTANCE__setRange(float min, float max)
- extern void Gauge__INSTANCE__onThreshold(float value)

Alias generados:
- _INSTANCE_.setValue
- _INSTANCE_.setRange
- _INSTANCE_.onThreshold
```

---

## 4. Catalogo XML Generado con Templates

### 4.1 Formato del Catalogo

El catalogo XML generado por Discovery marca las entradas como **templates** que deben ser instanciadas antes de usarse:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<resources>
    <!-- Widget: Gauge (template) -->
    <group name="Gauge" template="true">
        <function>
            <fn>void Gauge__INSTANCE__setValue(float value);</fn>
            <alias>_INSTANCE_.setValue</alias>
            <brief>Set the current value of the gauge</brief>
            <param name="value">Numeric value to display</param>
        </function>
        <function>
            <fn>void Gauge__INSTANCE__setRange(float min, float max);</fn>
            <alias>_INSTANCE_.setRange</alias>
            <brief>Set the min and max range of the gauge</brief>
            <param name="min">Minimum value</param>
            <param name="max">Maximum value</param>
        </function>
        <event>
            <fn>extern void Gauge__INSTANCE__onThreshold(float value);</fn>
            <alias>_INSTANCE_.onThreshold</alias>
            <brief>Fires when the value crosses the threshold</brief>
        </event>
    </group>

    <!-- Widget: Switch (template) -->
    <group name="Switch" template="true">
        <function>
            <fn>void Switch__INSTANCE__setState(uint8_t state);</fn>
            <alias>_INSTANCE_.setState</alias>
            <brief>Set switch state: 1=on, 0=off</brief>
        </function>
        <event>
            <fn>extern void Switch__INSTANCE__onChange(uint8_t state);</fn>
            <alias>_INSTANCE_.onChange</alias>
            <brief>Fires when user toggles the switch</brief>
        </event>
    </group>

    <!-- Connector: MQTTClient (template) -->
    <group name="MQTTClient" template="true">
        <function>
            <fn>void MQTTClient__INSTANCE__connect(const char* broker);</fn>
            <alias>_INSTANCE_.connect</alias>
            <brief>Connect to MQTT broker</brief>
        </function>
        <function>
            <fn>void MQTTClient__INSTANCE__publish(const char* topic, const char* msg);</fn>
            <alias>_INSTANCE_.publish</alias>
            <brief>Publish message to topic</brief>
        </function>
        <event>
            <fn>extern void MQTTClient__INSTANCE__onMessage(const char* topic, const char* msg);</fn>
            <alias>_INSTANCE_.onMessage</alias>
            <brief>Fires when a message is received</brief>
        </event>
    </group>
</resources>
```

### 4.2 Atributo template="true"

El atributo `template="true"` indica al editor que este grupo **no es una instancia usable**, sino un **modelo** que debe ser instanciado. Cuando el usuario arrastra un widget del catalogo al canvas, el editor:

1. Pide un nombre al usuario (ej: "tempGauge")
2. Clona el template
3. Reemplaza `_INSTANCE_` por el nombre elegido
4. Agrega la instancia al estado del proyecto

---

## 5. Instanciacion Dinamica Client-Side

### 5.1 Proceso de Instanciacion en el Editor

Cuando el usuario arrastra un widget "Gauge" al canvas y lo nombra "tempGauge":

```
PASO 1: Usuario arrastra Gauge al canvas
PASO 2: Editor pide nombre -> "tempGauge"
PASO 3: Editor clona template y reemplaza _INSTANCE_:

  ANTES (template):                    DESPUES (instancia):
  _INSTANCE_.setValue                  tempGauge.setValue
  _INSTANCE_.setRange                  tempGauge.setRange
  _INSTANCE_.onThreshold               tempGauge.onThreshold

PASO 4: Editor registra en estado del proyecto:
  widgets.tempGauge = {
      type: "Gauge",
      config: { min: 0, max: 100 }
  }
```

### 5.2 Pseudo-codigo del Editor

```javascript
function instantiateWidget(templateGroup, instanceName) {
    const instance = JSON.parse(JSON.stringify(templateGroup));

    // Reemplazar _INSTANCE_ en todas las funciones y alias
    instance.name = instanceName;
    instance.template = false;

    for (const fn of instance.functions) {
        fn.fnSignature = fn.fnSignature.replaceAll('_INSTANCE_', instanceName);
        fn.alias = fn.alias.replaceAll('_INSTANCE_', instanceName);
    }

    for (const ev of instance.events) {
        ev.fnSignature = ev.fnSignature.replaceAll('_INSTANCE_', instanceName);
        ev.alias = ev.alias.replaceAll('_INSTANCE_', instanceName);
    }

    // Agregar al estado del proyecto
    projectState.widgets[instanceName] = instance;

    return instance;
}

// Ejemplo de uso:
instantiateWidget(gaugeTemplate, 'tempGauge');
instantiateWidget(gaugeTemplate, 'pressureGauge');
instantiateWidget(switchTemplate, 'pumpSwitch');
```

### 5.3 Resultado: Funciones Disponibles para el Usuario

```
Despues de instanciar tempGauge, pressureGauge y pumpSwitch:

tempGauge.setValue(float value)
tempGauge.setRange(float min, float max)
tempGauge.onThreshold -> evento

pressureGauge.setValue(float value)
pressureGauge.setRange(float min, float max)
pressureGauge.onThreshold -> evento

pumpSwitch.setState(uint8_t state)
pumpSwitch.onChange -> evento
```

---

## 6. generate.emic Completo con foreach

### 6.1 Estado del Canvas como Macros

Cuando el usuario presiona Deploy, el editor genera macros que representan el estado actual del canvas:

```emic
// Generado automaticamente por el editor
// Widgets agregados por el usuario
EMIC:define(widgets.tempGauge, Gauge)
EMIC:define(widgets.pressureGauge, Gauge)
EMIC:define(widgets.flowChart, LineChart)
EMIC:define(widgets.pumpSwitch, Switch)
EMIC:define(widgets.statusLed, LED)

// Connectors agregados por el usuario
EMIC:define(connectors.broker1, MQTTClient)
EMIC:define(connectors.api1, RESTClient)

// Configuraciones de cada instancia
EMIC:define(config.tempGauge.min, 0)
EMIC:define(config.tempGauge.max, 200)
EMIC:define(config.pressureGauge.min, 0)
EMIC:define(config.pressureGauge.max, 10)
EMIC:define(config.broker1.url, wss://broker.example.com)
```

### 6.2 generate.emic Completo

**Archivo: `_modules/Industrial/MonitorDashboard/System/generate.emic`**

```emic
EMIC:setOutput(TARGET:generate.txt)

    // ==========================================================
    // SECCION 1: LAYOUT Y THEME
    // ==========================================================
    EMIC:setInput(DEV:_layouts/layouts.emic, layout=dashboard-grid, theme=industrial)

    // ==========================================================
    // SECCION 2: FUNCIONES Y EVENTOS USADOS POR EL USUARIO
    // ==========================================================
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    // ==========================================================
    // SECCION 3: WIDGETS (iteracion dinamica)
    // El editor define el grupo "widgets" con las instancias
    // ==========================================================
    EMIC:foreach(widgets.*)
        EMIC:setInput(DEV:_widgets/.{widgets.{*}}./.{widgets.{*}}..emic, name=.{*}.)
    EMIC:endforeach

    // ==========================================================
    // SECCION 4: CONNECTORS (iteracion dinamica)
    // El editor define el grupo "connectors" con las instancias
    // ==========================================================
    EMIC:foreach(connectors.*)
        EMIC:setInput(DEV:_connectors/.{connectors.{*}}./.{connectors.{*}}..emic, name=.{*}.)
    EMIC:endforeach

    // ==========================================================
    // SECCION 5: SYSTEM (core, event bus, component base)
    // ==========================================================
    EMIC:setInput(DEV:_system/system.emic)

    // ==========================================================
    // SECCION 6: MAIN (entry point web)
    // ==========================================================
    EMIC:setInput(DEV:_main/webapp/main.emic)

    // ==========================================================
    // SECCION 7: CODIGO DEL USUARIO
    // ==========================================================
    EMIC:copy(SYS:userApp.js > TARGET:userApp.js)
    EMIC:define(modules.userApp, userApp)

    // ==========================================================
    // SECCION 8: TEMPLATE DE DEPLOY
    // ==========================================================
    EMIC:copy(DEV:_templates/deploy/.{system.deployTarget}. > TARGET:)

EMIC:restoreOutput
```

### 6.3 Expansion del foreach

Con el estado del canvas definido anteriormente, el `foreach(widgets.*)` se expande asi:

```emic
// foreach(widgets.*) se expande a:

// {*}=tempGauge, widgets.{*}=Gauge
EMIC:setInput(DEV:_widgets/Gauge/Gauge.emic, name=tempGauge)

// {*}=pressureGauge, widgets.{*}=Gauge
EMIC:setInput(DEV:_widgets/Gauge/Gauge.emic, name=pressureGauge)

// {*}=flowChart, widgets.{*}=LineChart
EMIC:setInput(DEV:_widgets/LineChart/LineChart.emic, name=flowChart)

// {*}=pumpSwitch, widgets.{*}=Switch
EMIC:setInput(DEV:_widgets/Switch/Switch.emic, name=pumpSwitch)

// {*}=statusLed, widgets.{*}=LED
EMIC:setInput(DEV:_widgets/LED/LED.emic, name=statusLed)
```

Y `foreach(connectors.*)`:

```emic
// {*}=broker1, connectors.{*}=MQTTClient
EMIC:setInput(DEV:_connectors/MQTTClient/MQTTClient.emic, name=broker1)

// {*}=api1, connectors.{*}=RESTClient
EMIC:setInput(DEV:_connectors/RESTClient/RESTClient.emic, name=api1)
```

---

## 7. Resultado: Proyecto Web Generado

### 7.1 Estructura de TARGET/

Despues de ejecutar EMIC Generate con el `generate.emic` anterior:

```
TARGET/
+-- index.html                      # Entry point (de _main/webapp)
+-- app-shell.js                    # Application shell
+-- sw.js                           # Service Worker
+-- manifest.json                   # PWA manifest
+-- config.json                     # Configuracion del usuario
+-- userApp.js                      # Codigo del usuario
+--
+-- css/
|   +-- layout.css                  # Grid layout (de _layouts)
|   +-- theme.css                   # Theme industrial (de _layouts/themes)
|   +-- responsive.css              # Media queries
+--
+-- js/
|   +-- emic-core.js                # EventBus y utilidades (de _system)
|   +-- emic-component-base.js      # Base class de WebComponents
+--
+-- emic-gauge_tempGauge.js         # Widget Gauge instancia "tempGauge"
+-- emic-gauge_pressureGauge.js     # Widget Gauge instancia "pressureGauge"
+-- emic-chart_flowChart.js         # Widget LineChart instancia "flowChart"
+-- emic-switch_pumpSwitch.js       # Widget Switch instancia "pumpSwitch"
+-- emic-led_statusLed.js           # Widget LED instancia "statusLed"
+--
+-- mqtt-client_broker1.js          # Connector MQTT instancia "broker1"
+-- rest-client_api1.js             # Connector REST instancia "api1"
+--
+-- .github/                        # Deploy config (si es GitHub Pages)
    +-- workflows/
        +-- deploy.yml
```

### 7.2 index.html Generado

```html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Monitor Industrial V2</title>

    <link rel="stylesheet" href="css/layout.css">
    <link rel="stylesheet" href="css/theme.css">
    <link rel="stylesheet" href="css/responsive.css">

    <link rel="manifest" href="manifest.json">
    <meta name="theme-color" content="#1a1a2e">
</head>
<body>
    <div class="emic-dashboard" id="app"></div>

    <script src="js/emic-core.js"></script>
    <script src="js/emic-component-base.js"></script>

    <!-- Expansion de .{imports.*}. -->
    <script type="module" src="emic-gauge_tempGauge.js"></script>
    <script type="module" src="emic-gauge_pressureGauge.js"></script>
    <script type="module" src="emic-chart_flowChart.js"></script>
    <script type="module" src="emic-switch_pumpSwitch.js"></script>
    <script type="module" src="emic-led_statusLed.js"></script>
    <script type="module" src="mqtt-client_broker1.js"></script>
    <script type="module" src="rest-client_api1.js"></script>

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

## 8. Contraste Embebido vs Dashboard

### 8.1 Tabla Comparativa Detallada

| Aspecto | Embebido | Dashboard |
|---------|----------|-----------|
| **Componentes** | APIs listadas explicitamente con setInput | Widgets iterados con foreach(widgets.*) |
| **Nombres** | Definidos por el desarrollador del modulo | Definidos por el usuario en el editor |
| **Discovery** | Mismo archivo (generate.emic en modo Discovery) | Archivo separado (discovery.emic) |
| **Placeholder** | No usa (nombres fijos) | Usa `_INSTANCE_` como placeholder |
| **Instanciacion** | En generate.emic con `name=valor` fijo | En el editor al arrastrar (client-side) |
| **Datos de entrada** | Solo del archivo .emic | .emic + estado del canvas/tray del editor |
| **Iteracion** | No necesaria (setInput explicitos) | `EMIC:foreach(widgets.*)` y `EMIC:foreach(connectors.*)` |
| **Output** | Archivos .c y .h | Archivos .js y .css |
| **Registro** | c_modules, main_includes, inits, polls | modules, imports, inits, polls, styles |
| **Compilador** | GCC / XC16 | Browser (no compila, interpreta) |
| **Artefacto** | firmware.hex | Sitio web estatico |

### 8.2 Ejemplo Lado a Lado

**Embebido (generate.emic):**
```emic
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=status, pin=Led1)
EMIC:setInput(DEV:_api/Indicators/LEDs/led.emic, name=error, pin=Led2)
EMIC:setInput(DEV:_api/Timers/timer_api.emic, name=1)
```

**Dashboard (generate.emic):**
```emic
EMIC:foreach(widgets.*)
    EMIC:setInput(DEV:_widgets/.{widgets.{*}}./.{widgets.{*}}..emic, name=.{*}.)
EMIC:endforeach
```

La diferencia clave: en embebido los nombres son fijos en el codigo fuente. En dashboard los nombres vienen del grupo `widgets` que fue definido dinamicamente por el editor segun las acciones del usuario.

---

## 9. Grupos de Registro Web

### 9.1 Grupos Principales

| Grupo | Proposito | Uso en index.html |
|-------|-----------|-------------------|
| `modules.*` | Scripts JS a cargar | Registro interno de modulos |
| `imports.*` | Scripts a importar | `<script src=".{imports.*}..js">` |
| `inits.*` | Funciones de inicializacion | `EMICApp.registerInit(.{inits.*}.)` |
| `polls.*` | Funciones de polling | `EMICApp.registerPoll(.{polls.*}.)` |
| `styles.*` | Archivos CSS | `<link href="css/.{styles.*}..css">` |
| `routes.*` | Rutas SPA | Configuracion del router |

### 9.2 Como se Registran

Cada widget registra sus recursos en los grupos correspondientes:

```emic
// En gauge.emic (despues de copiar archivos)
EMIC:define(imports.gauge_.{name}., emic-gauge_.{name}.)
EMIC:define(inits.gauge_.{name}., Gauge_.{name}._init)
EMIC:define(polls.gauge_.{name}., Gauge_.{name}._poll)
EMIC:define(styles.gauge, emic-gauge)
```

Con `name=tempGauge`:
```emic
EMIC:define(imports.gauge_tempGauge, emic-gauge_tempGauge)
EMIC:define(inits.gauge_tempGauge, Gauge_tempGauge_init)
EMIC:define(polls.gauge_tempGauge, Gauge_tempGauge_poll)
EMIC:define(styles.gauge, emic-gauge)
```

### 9.3 Expansion en index.html

```html
<!-- Expansion de .{styles.*}. -->
<link rel="stylesheet" href="css/layout.css">
<link rel="stylesheet" href="css/theme.css">
<link rel="stylesheet" href="css/emic-gauge.css">

<!-- Expansion de .{imports.*}. -->
<script type="module" src="emic-gauge_tempGauge.js"></script>
<script type="module" src="emic-gauge_pressureGauge.js"></script>
<script type="module" src="emic-chart_flowChart.js"></script>
```

### 9.4 Comparacion de Grupos

| Grupo Embebido | Grupo Dashboard | Funcion Equivalente |
|----------------|-----------------|---------------------|
| `c_modules.*` | `modules.*` | Registrar archivo para el proyecto |
| `main_includes.*` | `imports.*` | Importar/incluir en el entry point |
| `inits.*` | `inits.*` | Funciones de inicializacion (identico) |
| `polls.*` | `polls.*` | Funciones de polling (identico) |
| (no existe) | `styles.*` | Archivos CSS a cargar |
| (no existe) | `routes.*` | Rutas del router SPA |

---

## Resumen

| Concepto | Descripcion |
|----------|-------------|
| **discovery.emic** | Lista todos los widgets/connectors con `_INSTANCE_` |
| **generate.emic** | Usa `foreach` para iterar solo los seleccionados por el usuario |
| **_INSTANCE_** | Placeholder que se reemplaza por el nombre que elige el usuario |
| **template="true"** | Atributo XML que marca un recurso como plantilla instanciable |
| **foreach(widgets.*)** | Itera sobre el grupo `widgets` definido por el editor |
| **Estado del canvas** | Macros generadas por el editor con las instancias del usuario |
| **Grupos web** | modules, imports, inits, polls, styles, routes |

---

## Proximos Pasos

En el **Capitulo 21b** veremos paso a paso como desarrollar un widget completo, desde la creacion de carpetas hasta el testing en el navegador.

---

**Navegacion:**
- [← Capitulo 23: Proceso de Generacion (Embebido)](23_Proceso_Generacion_Generate.md)
- [→ Capitulo 21b: Desarrollo de Widget Paso a Paso](21b_Desarrollo_Widget_Paso_a_Paso.md)
