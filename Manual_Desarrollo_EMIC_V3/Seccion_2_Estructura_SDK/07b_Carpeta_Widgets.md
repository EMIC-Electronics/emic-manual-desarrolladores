# Capitulo 07b: Carpeta `_widgets/` - Componentes Visuales WebComponent

[<- Anterior: Carpeta _api (Embebido)](07_Carpeta_API.md) | [Siguiente: Carpeta _connectors ->](08b_Carpeta_Connectors.md)

---

## Contenido del Capitulo

1. [Que es un Widget en EMIC](#1-que-es-un-widget-en-emic)
2. [Widget vs Connector: Diferencias Clave](#2-widget-vs-connector-diferencias-clave)
3. [Estructura de un Widget](#3-estructura-de-un-widget)
4. [Categorias de Widgets](#4-categorias-de-widgets)
5. [Ejemplo Completo: Widget Gauge](#5-ejemplo-completo-widget-gauge)
6. [Etiquetado con DOXYGEN](#6-etiquetado-con-doxygen)
7. [Gestion de Dependencias](#7-gestion-de-dependencias)
8. [Creacion de Nuevos Widgets](#8-creacion-de-nuevos-widgets)

---

## 1. Que es un Widget en EMIC

### 1.1 Definicion Conceptual

Un **Widget** en EMIC Dashboard es un **componente visual de alto nivel** (WebComponent) que el integrador utiliza para mostrar datos o interactuar con el dashboard. Es el equivalente directo de una API en el SDK embebido: asi como una API abstrae el hardware para el firmware, un Widget abstrae la complejidad del DOM y los estilos para la interfaz visual.

```
+----------------------------------------------------+
|               WIDGET EMIC                          |
|   Componente Visual de Alto Nivel (WebComponent)   |
+----------------------------------------------------+
           |
    +------+------+---------------+--------------+
    |             |               |              |
ENCAPSULACION  REACTIVIDAD   TEMATIZABLE   REUTILIZABLE
    |             |               |              |
Shadow DOM    Actualiza UI    CSS custom     Mismo widget
aislamiento   ante cambios    properties     en multiples
visual        de datos        desde tema     dashboards
```

### 1.2 Caracteristicas de un Widget EMIC

- **Basado en WebComponents:** Utiliza CustomElements + Shadow DOM del estandar web
- **Extiende EmicComponentBase:** Clase base que provee ciclo de vida, binding y eventos EMIC
- **Tiene tags DOXYGEN:** Visible en el Editor para que el integrador lo arrastre al canvas
- **Tiene EMIC:tag():** Registrado en Discovery para aparecer en la paleta de componentes
- **Tres archivos:** `.emic` (tags + dependencias) + `.js` (logica) + `.css` (estilos)
- **Tematizable:** Usa CSS custom properties para adaptarse al tema activo del dashboard
- **Parametrizable:** Acepta configuracion dinamica mediante atributos y propiedades

### 1.3 Proposito de los Widgets

```
SIN Widgets (codigo directo):
+-----------------------------------------+
|  Integrador escribe:                    |
|                                         |
|  const div = document.createElement(    |
|    'div');                              |
|  div.style.width = '200px';            |
|  div.innerHTML = '<svg>...</svg>';      |
|  // 150 lineas de SVG para un gauge... |
|  document.body.appendChild(div);        |
+-----------------------------------------+
  x Especifico de la implementacion
  x Dificil de mantener y tematizar
  x Requiere conocer SVG, CSS, DOM

CON Widgets (abstraccion):
+-----------------------------------------+
|  Integrador arrastra:                   |
|                                         |
|  <emic-gauge name="temp"               |
|    min="0" max="100"                    |
|    label="Temperatura">                 |
|  </emic-gauge>                          |
+-----------------------------------------+
  + Portable entre dashboards
  + Facil de configurar
  + No requiere conocer SVG ni DOM interno
```

### 1.4 Posicion en la Arquitectura del Dashboard

```
+----------------------------------------------------+
|                  INTEGRADOR                        |
|             (EMIC-Editor / Canvas visual)          |
+----------------------------------------------------+
                      |
+----------------------------------------------------+
|                  WIDGETS                           |  <- Componentes visuales
|  <emic-gauge>, <emic-chart>, <emic-toggle>        |     (alto nivel, con UI)
+----------------------------------------------------+
                      |
+----------------------------------------------------+
|                CONNECTORS                          |  <- Logica de servicio
|  MQTT_connect(), REST_fetch(), WS_subscribe()     |     (sin UI, datos)
+----------------------------------------------------+
                      |
+----------------------------------------------------+
|                  _system/                          |  <- Core del dashboard
|  event-bus, state-manager, theme-engine           |
+----------------------------------------------------+
                      |
+----------------------------------------------------+
|                   _util/                           |  <- Utilidades puras
|  formatters, validators, converters               |
+----------------------------------------------------+
```

---

## 2. Widget vs Connector: Diferencias Clave

### 2.1 Comparacion Conceptual

| Aspecto | Widget | Connector |
|---------|--------|-----------|
| **Visual** | SI (renderiza UI) | NO (logica de servicio) |
| **Tags DOXYGEN** | SI | SI |
| **EMIC:tag()** | SI | SI |
| **Include guard** | Opcional | OBLIGATORIO |
| **Depende de** | Connectors, _system, _util | _system, _util |
| **Nomenclatura** | `WidgetType_.{name}._func()` | `ConnectorType_.{name}._func()` |
| **Ubicacion Editor** | Tab "Widgets" | Tab "Services" |
| **Destino drag** | Canvas visual | Component Tray |
| **Shadow DOM** | SI (encapsulacion visual) | NO (sin renderizado) |
| **Archivo CSS** | SI (estilos propios) | NO |
| **Instanciacion** | Drag-and-drop en canvas | Asignacion en Services |

### 2.2 Diagrama de Capas

```
+----------------------------------------------------+
|                 INTEGRADOR                         |
|        (EMIC-Editor / Dashboard Designer)          |
+----------------------------------------------------+
                      |
+----------------------------------------------------+
|                  WIDGETS                           |  <- Abstraccion visual
|  Gauge_setValue(), Chart_addPoint(), Toggle_on()   |     (portable entre temas)
+----------------------------------------------------+
                      |
+----------------------------------------------------+
|                CONNECTORS                          |  <- Servicio de datos
|  MQTT_subscribe(), REST_get(), WS_onMessage()     |     (especifico del protocolo)
+----------------------------------------------------+
                      |
+----------------------------------------------------+
|                _system/ core                       |  <- Motor del dashboard
|  EventBus, StateManager, ThemeEngine              |
+----------------------------------------------------+
                      |
+----------------------------------------------------+
|                  _util/                            |  <- Utilidades sin dependencias
|  Formatters, Validators, Converters               |
+----------------------------------------------------+
```

### 2.3 Ejemplos Comparativos

**Ejemplo 1: Indicador de temperatura**
- **Widget:** `_widgets/Indicators/Gauge/` -> Muestra **cualquier valor numerico** como gauge visual
- **Connector:** `_connectors/Protocols/MQTT/` -> Obtiene **datos via MQTT** de un broker especifico

**Ejemplo 2: Control remoto**
- **Widget:** `_widgets/Controls/ToggleSwitch/` -> Renderiza **un switch visual** generico
- **Connector:** `_connectors/Protocols/REST/` -> Envia **comandos via REST API** a un endpoint

**Regla de oro:**
> Si **renderiza interfaz visual** para el usuario -> **Widget**
> Si **gestiona datos o comunicacion** sin UI propia -> **Connector**

---

## 3. Estructura de un Widget

### 3.1 Arbol de Directorios

```
_widgets/                            <- Raiz de Widgets
|
+-- {Category}/                      <- Categoria (ej: Indicators)
    +-- {WidgetName}/                <- Nombre del Widget (ej: Gauge)
        |
        +-- {widget}.emic           ** Script EMIC (recursos publicados)
        |
        +-- src/                     ** Implementacion
        |   +-- emic-{widget}.js     <- Clase WebComponent
        |   +-- emic-{widget}.css    <- Estilos Shadow DOM
        |
        +-- deps/                    <- Dependencias externas (opcional)
            +-- {lib}.js             <- Libs de terceros si las necesita
```

**Ejemplo real del Dashboard SDK:**
```
_widgets/Indicators/Gauge/
+-- gauge.emic                       <- Script con tags DOXYGEN
+-- src/
|   +-- emic-gauge.js                <- Clase del WebComponent
|   +-- emic-gauge.css               <- Estilos del gauge
+-- deps/                            <- (vacio en este caso)
```

### 3.2 Responsabilidad de Cada Archivo

| Archivo | Proposito | Contenido |
|---------|-----------|-----------|
| **{widget}.emic** | Define recursos publicados | Tags DOXYGEN, dependencias, configuradores, macros |
| **src/emic-{widget}.js** | Clase WebComponent | Logica del componente, render, bindings |
| **src/emic-{widget}.css** | Estilos Shadow DOM | CSS con custom properties, layout, animaciones |
| **deps/{lib}.js** | Librerias externas | Dependencias de terceros (chart.js, d3, etc.) |

### 3.3 Convencion de Nombres

| Elemento | Convencion | Ejemplo |
|----------|-----------|---------|
| Carpeta categoria | PascalCase | `Indicators`, `Controls` |
| Carpeta widget | PascalCase | `Gauge`, `ToggleSwitch` |
| Archivo .emic | lowercase | `gauge.emic` |
| Archivo .js | prefijo `emic-` | `emic-gauge.js` |
| Archivo .css | prefijo `emic-` | `emic-gauge.css` |
| Tag HTML | prefijo `emic-` | `<emic-gauge>` |
| Clase JS | PascalCase + prefijo Emic | `EmicGauge` |

---

## 4. Categorias de Widgets

### 4.1 Listado Completo del Dashboard SDK

| # | Categoria | Widgets | Descripcion |
|---|-----------|---------|-------------|
| 1 | **Indicators** | Gauge, ValueDisplay, StatusLed, ProgressBar, Sparkline | Indicadores visuales de valores y estados |
| 2 | **Charts** | LineChart, BarChart, PieChart, Heatmap | Graficos y visualizaciones de datos |
| 3 | **Controls** | ToggleSwitch, Slider, PushButton, Knob, ColorPicker | Controles de interaccion del usuario |
| 4 | **Data** | DataTable, LogViewer, AlarmList | Visualizacion de datos tabulares y registros |
| 5 | **Maps** | DeviceMap, FloorPlan | Mapas geograficos y planos interactivos |
| 6 | **Media** | CameraView, ImageViewer | Multimedia y visualizacion de imagenes |
| 7 | **Notifications** | ToastNotification, AlertBanner, NotificationCenter | Notificaciones y alertas al usuario |
| 8 | **Layout** | Card, TabPanel, Modal | Contenedores y estructura visual |

### 4.2 Distribucion por Funcion

```
+-----------------------------------------------------+
|         WIDGETS POR TIPO DE FUNCION                 |
+-----------------------------------------------------+

  VISUALIZACION DE DATOS (31%)
      +-- Indicators (Gauge, ValueDisplay, StatusLed...)
      +-- Charts (LineChart, BarChart, PieChart...)
      +-- Data (DataTable, LogViewer...)

  INTERACCION DE USUARIO (19%)
      +-- Controls (ToggleSwitch, Slider, Knob...)

  NOTIFICACIONES (12%)
      +-- Notifications (Toast, AlertBanner...)

  ESTRUCTURA Y LAYOUT (13%)
      +-- Layout (Card, TabPanel, Modal)

  UBICACION Y ESPACIO (13%)
      +-- Maps (DeviceMap, FloorPlan)

  MULTIMEDIA (12%)
      +-- Media (CameraView, ImageViewer)
```

---

## 5. Ejemplo Completo: Widget Gauge

### 5.1 Ubicacion

`_widgets/Indicators/Gauge/`

### 5.2 Archivo: gauge.emic

```emic
EMIC:tag(driverName = Gauge)

/**
* @fn void Gauge_.{name}._setValue(float value);
* @alias .{name}..setValue
* @brief Set the current value displayed by the gauge.
* @param value Numeric value to display (clamped to min/max range)
* @return Nothing
*/

/**
* @fn void Gauge_.{name}._setRange(float min, float max);
* @alias .{name}..setRange
* @brief Configure the minimum and maximum range of the gauge.
* @param min Minimum value of the scale
* @param max Maximum value of the scale
* @return Nothing
*/

/**
* @fn void Gauge_.{name}._setLabel(char* label);
* @alias .{name}..setLabel
* @brief Change the text label displayed below the gauge.
* @param label Text string for the label
* @return Nothing
*/

/**
* @fn extern void Gauge_.{name}._onThreshold(float value);
* @alias .{name}..onThreshold
* @brief Fires when the gauge value crosses a configured threshold.
* @param value The current value at the moment of crossing
* @return Nothing
*/

EMIC:json(type = configurator)
{
    "brief": "Define la apariencia visual del gauge",
    "legend": "Seleccione estilo",
    "name": "gaugeStyle",
    "options":
    [
        {
            "legend": "Semicircular",
            "value": "semicircle",
            "brief": "Gauge en forma de semicirculo (180 grados)"
        },
        {
            "legend": "Circular completo",
            "value": "full_circle",
            "brief": "Gauge circular completo (270 grados)"
        },
        {
            "legend": "Lineal",
            "value": "linear",
            "brief": "Barra de progreso lineal horizontal"
        }
    ]
}

// Dependencias del sistema
EMIC:setInput(DEV:_system/core/component-base.emic)
EMIC:setInput(DEV:_system/event-bus/event-bus.emic)

// Copiar archivos al target
EMIC:copy(src/emic-gauge.js > TARGET:src/emic-gauge_.{name}..js, name=.{name}., config.gaugeStyle=.{config.gaugeStyle}.)
EMIC:copy(src/emic-gauge.css > TARGET:src/emic-gauge_.{name}..css, name=.{name}.)

// Registrar para carga
EMIC:define(widget_modules.emic-gauge_.{name}., emic-gauge_.{name}.)
EMIC:define(widget_styles.emic-gauge_.{name}., emic-gauge_.{name}.)
```

### 5.3 Archivo: src/emic-gauge.js

```javascript
import { EmicComponentBase } from './core/emic-component-base.js';
import { EventBus } from './core/emic-event-bus.js';

const GAUGE_STYLES = {
    semicircle: { startAngle: -90, endAngle: 90, viewBox: '0 0 200 120' },
    full_circle: { startAngle: -135, endAngle: 135, viewBox: '0 0 200 200' },
    linear: { startAngle: 0, endAngle: 0, viewBox: '0 0 300 60' }
};

class EmicGauge_.{name}. extends EmicComponentBase {

    static get observedAttributes() {
        return ['value', 'min', 'max', 'label', 'thresholds'];
    }

    constructor() {
        super();
        this._value = 0;
        this._min = 0;
        this._max = 100;
        this._label = '.{name}.';
        this._style = '.{config.gaugeStyle}.';
        this._thresholds = [];
    }

    connectedCallback() {
        super.connectedCallback();
        this.attachShadow({ mode: 'open' });
        this._loadStyles();
        this.render();

        // Suscribirse al bus de eventos para recibir datos
        EventBus.subscribe('data:.{name}.', (payload) => {
            this.setValue(payload.value);
        });
    }

    disconnectedCallback() {
        super.disconnectedCallback();
        EventBus.unsubscribe('data:.{name}.');
    }

    attributeChangedCallback(name, oldValue, newValue) {
        if (oldValue === newValue) return;
        switch (name) {
            case 'value': this.setValue(parseFloat(newValue)); break;
            case 'min': this._min = parseFloat(newValue); this.render(); break;
            case 'max': this._max = parseFloat(newValue); this.render(); break;
            case 'label': this._label = newValue; this.render(); break;
            case 'thresholds': this._parseThresholds(newValue); break;
        }
    }

    async _loadStyles() {
        const response = await fetch('./src/emic-gauge_.{name}..css');
        const css = await response.text();
        const style = document.createElement('style');
        style.textContent = css;
        this.shadowRoot.appendChild(style);
    }

    // --- Funciones publicas (publicadas via DOXYGEN) ---

    setValue(value) {
        const clampedValue = Math.min(Math.max(value, this._min), this._max);
        const previousValue = this._value;
        this._value = clampedValue;
        this.render();

        // Verificar umbrales
        this._thresholds.forEach(threshold => {
            const crossedUp = previousValue < threshold && clampedValue >= threshold;
            const crossedDown = previousValue > threshold && clampedValue <= threshold;
            if (crossedUp || crossedDown) {
                this._fireOnThreshold(clampedValue);
            }
        });
    }

    setRange(min, max) {
        this._min = min;
        this._max = max;
        this.render();
    }

    setLabel(label) {
        this._label = label;
        this.render();
    }

    // --- Eventos (extern en DOXYGEN) ---

    _fireOnThreshold(value) {
        EventBus.publish('event:.{name}..onThreshold', { value: value });
        this.dispatchEvent(new CustomEvent('threshold', {
            detail: { value: value },
            bubbles: true,
            composed: true
        }));
    }

    // --- Renderizado ---

    render() {
        if (!this.shadowRoot) return;

        const container = this.shadowRoot.querySelector('.gauge-container')
            || document.createElement('div');
        container.className = 'gauge-container';

        const percentage = ((this._value - this._min) / (this._max - this._min)) * 100;
        const styleConfig = GAUGE_STYLES[this._style] || GAUGE_STYLES.semicircle;

        if (this._style === 'linear') {
            container.innerHTML = this._renderLinear(percentage);
        } else {
            container.innerHTML = this._renderArc(percentage, styleConfig);
        }

        if (!this.shadowRoot.querySelector('.gauge-container')) {
            this.shadowRoot.appendChild(container);
        }
    }

    _renderArc(percentage, config) {
        const radius = 80;
        const cx = 100;
        const cy = 100;
        const totalAngle = config.endAngle - config.startAngle;
        const currentAngle = config.startAngle + (totalAngle * percentage / 100);

        const startRad = (config.startAngle * Math.PI) / 180;
        const endRad = (currentAngle * Math.PI) / 180;

        const x1 = cx + radius * Math.cos(startRad);
        const y1 = cy + radius * Math.sin(startRad);
        const x2 = cx + radius * Math.cos(endRad);
        const y2 = cy + radius * Math.sin(endRad);

        const largeArc = (currentAngle - config.startAngle) > 180 ? 1 : 0;

        return `
            <svg viewBox="${config.viewBox}" class="gauge-svg">
                <path class="gauge-track"
                    d="M ${x1} ${y1} A ${radius} ${radius} 0 1 1 ${cx + radius * Math.cos((config.endAngle * Math.PI) / 180)} ${cy + radius * Math.sin((config.endAngle * Math.PI) / 180)}"
                    fill="none" stroke="var(--gauge-track-color, #e0e0e0)" stroke-width="12" stroke-linecap="round"/>
                <path class="gauge-fill"
                    d="M ${x1} ${y1} A ${radius} ${radius} 0 ${largeArc} 1 ${x2} ${y2}"
                    fill="none" stroke="var(--gauge-fill-color, #4caf50)" stroke-width="12" stroke-linecap="round"/>
                <text class="gauge-value" x="${cx}" y="${cy}" text-anchor="middle" dominant-baseline="middle">
                    ${this._value.toFixed(1)}
                </text>
                <text class="gauge-label" x="${cx}" y="${cy + 25}" text-anchor="middle">
                    ${this._label}
                </text>
            </svg>
        `;
    }

    _renderLinear(percentage) {
        return `
            <div class="gauge-linear">
                <div class="gauge-linear-track">
                    <div class="gauge-linear-fill" style="width: ${percentage}%"></div>
                </div>
                <div class="gauge-linear-info">
                    <span class="gauge-value">${this._value.toFixed(1)}</span>
                    <span class="gauge-label">${this._label}</span>
                </div>
            </div>
        `;
    }

    _parseThresholds(value) {
        try {
            this._thresholds = JSON.parse(value);
        } catch (e) {
            this._thresholds = value.split(',').map(Number);
        }
    }
}

customElements.define('emic-gauge-.{name}.', EmicGauge_.{name}.);

export { EmicGauge_.{name}. };
```

### 5.4 Archivo: src/emic-gauge.css

```css
:host {
    display: inline-block;
    width: var(--gauge-width, 200px);
    height: var(--gauge-height, auto);
    font-family: var(--emic-font-family, 'Segoe UI', Tahoma, sans-serif);
    contain: content;
}

:host([hidden]) {
    display: none;
}

/* --- Contenedor principal --- */

.gauge-container {
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: var(--gauge-padding, 8px);
    background: var(--emic-surface-color, #ffffff);
    border-radius: var(--emic-border-radius, 8px);
    box-shadow: var(--emic-shadow-sm, 0 1px 3px rgba(0,0,0,0.12));
}

/* --- Gauge SVG (semicircular y circular) --- */

.gauge-svg {
    width: 100%;
    max-width: var(--gauge-max-width, 200px);
}

.gauge-track {
    stroke: var(--gauge-track-color, #e0e0e0);
    transition: stroke 0.3s ease;
}

.gauge-fill {
    stroke: var(--gauge-fill-color, #4caf50);
    transition: all 0.5s ease-out;
}

.gauge-value {
    font-size: var(--gauge-value-font-size, 24px);
    font-weight: var(--gauge-value-font-weight, 700);
    fill: var(--emic-text-primary, #212121);
    color: var(--emic-text-primary, #212121);
}

.gauge-label {
    font-size: var(--gauge-label-font-size, 12px);
    fill: var(--emic-text-secondary, #757575);
    color: var(--emic-text-secondary, #757575);
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

/* --- Gauge lineal --- */

.gauge-linear {
    width: 100%;
    padding: 4px 0;
}

.gauge-linear-track {
    width: 100%;
    height: var(--gauge-linear-height, 12px);
    background: var(--gauge-track-color, #e0e0e0);
    border-radius: var(--gauge-linear-height, 12px);
    overflow: hidden;
}

.gauge-linear-fill {
    height: 100%;
    background: var(--gauge-fill-color, #4caf50);
    border-radius: inherit;
    transition: width 0.5s ease-out;
}

.gauge-linear-info {
    display: flex;
    justify-content: space-between;
    align-items: baseline;
    margin-top: 4px;
}

/* --- Umbrales (colores por rango) --- */

:host([level="warning"]) .gauge-fill,
:host([level="warning"]) .gauge-linear-fill {
    stroke: var(--emic-color-warning, #ff9800);
    background: var(--emic-color-warning, #ff9800);
}

:host([level="danger"]) .gauge-fill,
:host([level="danger"]) .gauge-linear-fill {
    stroke: var(--emic-color-danger, #f44336);
    background: var(--emic-color-danger, #f44336);
}

:host([level="success"]) .gauge-fill,
:host([level="success"]) .gauge-linear-fill {
    stroke: var(--emic-color-success, #4caf50);
    background: var(--emic-color-success, #4caf50);
}

/* --- Responsivo --- */

@media (max-width: 480px) {
    :host {
        width: var(--gauge-width-mobile, 150px);
    }
    .gauge-value {
        font-size: var(--gauge-value-font-size-mobile, 18px);
    }
}
```

### 5.5 Analisis del Widget Gauge

1. **Tag de driver:**
   ```emic
   EMIC:tag(driverName = Gauge)
   ```
   Identifica el widget como "Gauge" en Discovery.

2. **Funciones publicadas (tags DOXYGEN):**
   - `Gauge_.{name}._setValue(float value)` -> Establece el valor mostrado
   - `Gauge_.{name}._setRange(float min, float max)` -> Configura el rango
   - `Gauge_.{name}._setLabel(char* label)` -> Cambia la etiqueta

3. **Evento publicado:**
   - `Gauge_.{name}._onThreshold(float value)` -> Se dispara cuando el valor cruza un umbral

4. **Configurador JSON:**
   Permite al integrador elegir entre tres estilos: semicircular, circular completo y lineal.

5. **Shadow DOM:**
   El CSS se carga dentro del Shadow DOM, aislando completamente los estilos del resto de la pagina.

6. **CSS Custom Properties:**
   Variables como `--gauge-fill-color`, `--emic-surface-color` permiten tematizacion global sin modificar el widget.

**Uso desde generate.emic:**

```emic
EMIC:setInput(DEV:_widgets/Indicators/Gauge/gauge.emic,
              name=temp,
              config.gaugeStyle=semicircle)

EMIC:setInput(DEV:_widgets/Indicators/Gauge/gauge.emic,
              name=pressure,
              config.gaugeStyle=full_circle)
```

**Resultado:** Se generan `emic-gauge_temp.js`, `emic-gauge_temp.css`, `emic-gauge_pressure.js`, `emic-gauge_pressure.css`

**Uso desde el dashboard (integrador):**

```html
<emic-gauge-temp min="0" max="100" label="Temperatura" thresholds="[60,80]">
</emic-gauge-temp>

<emic-gauge-pressure min="0" max="300" label="Presion PSI">
</emic-gauge-pressure>
```

---

## 6. Etiquetado con DOXYGEN

### 6.1 Tags DOXYGEN en Widgets

Los Widgets utilizan el **mismo subset de DOXYGEN** que las APIs embebidas para publicar recursos en EMIC-Discovery.

**Tags soportados:**

| Tag | Proposito | Ejemplo |
|-----|-----------|---------|
| **@fn** | Prototipo de funcion | `@fn void Gauge_setValue(float value);` |
| **@alias** | Nombre simplificado en Editor | `@alias temp.setValue` |
| **@brief** | Descripcion breve | `@brief Set the current gauge value` |
| **@param** | Parametro de funcion | `@param value Numeric value to display` |
| **@return** | Valor de retorno | `@return Nothing` |

### 6.2 Sintaxis Completa

```c
/**
* @fn void WidgetType_.{name}._functionName(type1 param1, type2 param2);
* @alias .{name}..functionName
* @brief Descripcion corta de lo que hace la funcion.
* @param param1 Descripcion del parametro 1
* @param param2 Descripcion del parametro 2
* @return Descripcion del valor de retorno
*/
```

**Ejemplo real del Gauge:**

```c
/**
* @fn void Gauge_.{name}._setValue(float value);
* @alias .{name}..setValue
* @brief Set the current value displayed by the gauge.
* @param value Numeric value to display (clamped to min/max range)
* @return Nothing
*/
```

Cuando `name=temp`:
```c
/**
* @fn void Gauge_temp_setValue(float value);
* @alias temp.setValue
* @brief Set the current value displayed by the gauge.
* @param value Numeric value to display (clamped to min/max range)
* @return Nothing
*/
```

### 6.3 Funciones con `extern` (Eventos)

Las funciones marcadas con `extern` son **eventos** que el sistema dispara y el integrador implementa:

```c
/**
* @fn extern void Gauge_.{name}._onThreshold(float value);
* @alias .{name}..onThreshold
* @brief Fires when the gauge value crosses a configured threshold.
* @param value The current value at the moment of crossing
* @return Nothing
*/
```

El integrador NO llama a `onThreshold`, sino que **implementa** el callback:

```xml
<Event name="temp.onThreshold">
  <Call function="alertBanner.show" params="'Temperatura critica!'"/>
</Event>
```

### 6.4 Como los Tags Producen Recursos en el Editor

```
gauge.emic con tags DOXYGEN
          |
          v
   EMIC-Discovery procesa
          |
          v
+----------------------------------+
|  Editor - Paleta "Widgets"       |
|  +----------------------------+  |
|  |  [Gauge]                   |  |
|  |    temp.setValue(value)     |  |
|  |    temp.setRange(min,max)  |  |
|  |    temp.setLabel(label)    |  |
|  |    ** temp.onThreshold     |  |
|  +----------------------------+  |
+----------------------------------+
    ** = evento (el integrador lo implementa)
```

### 6.5 Modificadores Especiales

Los mismos modificadores del SDK embebido aplican a widgets:

**variadic:**
```c
/**
* @fn variadic LogViewer_.{name}._append(char* format,...);
* @alias .{name}..append(concat msg)
*/
```
Indica que acepta argumentos variables.

**concat:**
```c
@alias .{name}..send(concat tag, concat msg)
```
Los parametros se concatenan en strings.

---

## 7. Gestion de Dependencias

### 7.1 Tipos de Dependencias

Un Widget puede depender de:

```
Widget
 +-- _system/core         (EmicComponentBase, ciclo de vida)
 +-- _system/event-bus    (comunicacion entre componentes)
 +-- _connectors          (datos de servicios externos)
 +-- _util                (formateo, validacion)
```

### 7.2 Declaracion de Dependencias

**Sintaxis:**
```emic
EMIC:setInput(DEV:ruta/archivo.emic)
```

**Ejemplo del Gauge:**
```emic
EMIC:setInput(DEV:_system/core/component-base.emic)
EMIC:setInput(DEV:_system/event-bus/event-bus.emic)
```

**Ejemplo de un Chart que necesita datos:**
```emic
EMIC:setInput(DEV:_system/core/component-base.emic)
EMIC:setInput(DEV:_system/event-bus/event-bus.emic)
EMIC:setInput(DEV:_connectors/Protocols/MQTT/mqtt.emic, broker=.{broker}.)
EMIC:setInput(DEV:_util/Formatters/number-formatter.emic)
```

### 7.3 Diagrama de Dependencias

**Ejemplo: Widget LineChart**

```
LineChart Widget
    |
    +---> _system/core (EmicComponentBase)
    |
    +---> _system/event-bus (EventBus)
    |
    +---> _connectors/MQTT (datos en tiempo real)
    |         |
    |         +---> _system/core (conexion)
    |
    +---> _util/Formatters (formateo de ejes)
```

**En codigo:**
```emic
EMIC:setInput(DEV:_system/core/component-base.emic)
EMIC:setInput(DEV:_system/event-bus/event-bus.emic)
EMIC:setInput(DEV:_connectors/Protocols/MQTT/mqtt.emic, broker=.{broker}.)
EMIC:setInput(DEV:_util/Formatters/number-formatter.emic)
```

### 7.4 Reglas de Dependencias

Las dependencias siempre deben fluir **hacia abajo** en las capas:

```
Modulos/Dashboards --> Widgets --> Connectors --> _system --> _util
```

**Reglas estrictas:**

- Un Widget NUNCA depende de otro Widget
- Un Widget NUNCA depende de `_modules/`
- Un Widget PUEDE depender de `_connectors/` (para datos)
- Un Widget SIEMPRE depende de `_system/core` (clase base)
- Un Widget PUEDE depender de `_util/` (para formateo)

### 7.5 Evitar Dependencias Circulares

NO permitido:
```
Widget_A depende de Widget_B
Widget_B depende de Widget_A
```

Correcto:
```
Widget_A depende de Connector_C
Widget_B depende de Connector_C
(ambos comparten el mismo servicio de datos)
```

---

## 8. Creacion de Nuevos Widgets

### 8.1 Checklist de Creacion

**PASO 1: Planificacion**
- [ ] Definir nombre del Widget (ej: "Knob")
- [ ] Elegir categoria (ej: "Controls")
- [ ] Identificar funciones publicas y eventos
- [ ] Listar dependencias necesarias
- [ ] Definir CSS custom properties para tematizacion

**PASO 2: Estructura de Carpetas**
```
_widgets/{Categoria}/{NombreWidget}/
    {widget}.emic
    src/
        emic-{widget}.js
        emic-{widget}.css
```

**PASO 3: Crear {widget}.emic**
- [ ] Agregar `EMIC:tag(driverName = ...)`
- [ ] Documentar funciones con tags DOXYGEN
- [ ] Documentar eventos con `@fn extern void`
- [ ] Agregar configurador JSON si aplica
- [ ] Declarar dependencias con `EMIC:setInput`
- [ ] Definir macros y comandos `EMIC:copy`

**PASO 4: Crear src/emic-{widget}.js**
- [ ] Importar EmicComponentBase
- [ ] Definir `observedAttributes`
- [ ] Implementar `connectedCallback` (inicializacion, Shadow DOM)
- [ ] Implementar `disconnectedCallback` (limpieza)
- [ ] Implementar `render` (genera el HTML/SVG interno)
- [ ] Implementar funciones publicas
- [ ] Registrar con `customElements.define`

**PASO 5: Crear src/emic-{widget}.css**
- [ ] Estilos en `:host` para dimensiones base
- [ ] Usar CSS custom properties para tematizacion
- [ ] Respetar el prefijo `--emic-` para variables globales
- [ ] Agregar estilos responsivos con media queries

**PASO 6: Testing**
- [ ] Ejecutar EMIC-Discovery y verificar recursos publicados
- [ ] Probar instanciacion con diferentes parametros
- [ ] Verificar tematizacion cambiando CSS custom properties
- [ ] Probar responsividad en distintos tamanios

> Nota: El desarrollo paso a paso se detalla en el Capitulo 21b.

### 8.2 Tabla de Equivalencia: Dashboard Widget vs API Embebida

Esta tabla muestra la correspondencia directa entre los componentes de un Widget del Dashboard y los de una API del SDK embebido:

| Dashboard Widget | API Embebida | Descripcion |
|------------------|-------------|-------------|
| **emic-gauge.js** | **led.c** | Implementacion (logica del componente) |
| **emic-gauge.css** | *(no equivalente)* | Estilos visuales (exclusivo de widgets) |
| **gauge.emic** | **led.emic** | Tags + dependencias + registro |
| **connectedCallback()** | **_init()** | Inicializacion del componente |
| **disconnectedCallback()** | *(no equivalente)* | Limpieza al remover del DOM |
| **render()** | **_poll()** | Actualizacion del estado visual |
| **Shadow DOM** | *(no equivalente)* | Encapsulacion visual del componente |
| **CSS custom properties** | *(no equivalente)* | Tematizacion global |
| **EventBus.subscribe()** | **EMIC:define(polls.x)** | Recepcion de datos/eventos |
| **customElements.define()** | **EMIC:define(c_modules.x)** | Registro del componente en el sistema |

---

## Puntos Clave del Capitulo

| Concepto | Explicacion |
|----------|-------------|
| **Widget EMIC** | Componente visual WebComponent de alto nivel |
| **Widget vs Connector** | Widget = visual con UI, Connector = servicio sin UI |
| **Estructura** | {widget}.emic + src/emic-{widget}.js + src/emic-{widget}.css |
| **Tags DOXYGEN** | @fn, @alias, @brief, @param, @return (igual que APIs) |
| **Macros** | .{name}., .{config.gaugeStyle}. (reemplazadas en Generate) |
| **Dependencias** | EMIC:setInput() para _system, _connectors, _util |
| **8 categorias** | Desde Indicators hasta Layout |
| **Shadow DOM** | Encapsulacion visual que aisla estilos del widget |
| **CSS custom properties** | Mecanismo de tematizacion sin modificar el widget |

---

## Resumen Visual

```
+----------------------------------------------------+
|            WIDGET EMIC                             |
|    _widgets/{Category}/{WidgetName}/               |
+----------------------------------------------------+
            |
     +------+------+---------------+
     |             |               |
{widget}.emic  src/*.js         src/*.css
     |             |               |
     |             |               |
Tags DOXYGEN   Clase            Estilos
Dependencias   WebComponent     Shadow DOM
Configurador   Render           CSS Custom
Macros         EventBus         Properties
```

---

## Checklist de Comprension

Antes de continuar al Capitulo 08b, asegurate de entender:

- [ ] Que es un Widget en EMIC (componente visual WebComponent)
- [ ] La diferencia entre Widget y Connector
- [ ] La estructura de un Widget ({widget}.emic + src/js + src/css)
- [ ] Las 8 categorias de Widgets disponibles
- [ ] Los tags DOXYGEN y como producen recursos en el Editor
- [ ] Como funciona el Shadow DOM para encapsulacion visual
- [ ] El papel de las CSS custom properties en la tematizacion
- [ ] Como un Widget se comunica via EventBus
- [ ] La equivalencia entre Widget y API embebida
- [ ] Como crear un nuevo Widget desde cero

---

## Ejercicio Practico

**Exploracion del Dashboard SDK:**

```powershell
# Navega a _widgets/
cd _widgets\

# Lista todas las categorias
ls

# Explora el widget Gauge
cd Indicators\Gauge\
cat gauge.emic

# Cuenta las funciones publicadas (tags @fn)
Select-String "@fn" gauge.emic

# Verifica los CSS custom properties
Select-String "var(--" src\emic-gauge.css
```

**Pregunta de reflexion:**
Por que un Widget depende de `_system/event-bus` pero NUNCA de otro Widget?

<details>
<summary>Ver respuesta</summary>

**Respuesta:**
Porque los Widgets son componentes visuales **independientes** que se comunican a traves del **EventBus** (patron publicar/suscribir), no mediante referencias directas. Si Widget A dependiera de Widget B, se crearia un acoplamiento fuerte que impediria usarlos por separado.

El EventBus actua como intermediario: Widget A publica un evento y Widget B puede suscribirse si le interesa, pero ninguno necesita conocer la existencia del otro. Esto es identico al patron de las APIs embebidas donde los componentes se comunican mediante callbacks y no por referencia directa.

La regla:
- **Widget**: Independiente visualmente -> Se comunica via EventBus
- **Connector**: Independiente de datos -> Publica datos al EventBus
- **EventBus**: Desacopla widgets entre si y de los connectors

</details>

---

[<- Anterior: Carpeta _api (Embebido)](07_Carpeta_API.md) | [Siguiente: Carpeta _connectors ->](08b_Carpeta_Connectors.md)

---

*Capitulo 07b - Manual de Desarrollo EMIC Dashboard SDK v1.0*
*Ultima actualizacion: Febrero 2026*
