# Capitulo 21b: Desarrollo de un Widget Paso a Paso

[← Anterior: Desarrollo API (Embebido)](21_Desarrollo_API_Paso_a_Paso.md) | [Siguiente: Desarrollo Connector →](22b_Desarrollo_Connector.md)

## Tabla de Contenidos

### PARTE 1: DESARROLLO
1. [Paso 1: Crear Carpetas](#1-paso-1-crear-carpetas)
2. [Paso 2: Escribir el WebComponent JS](#2-paso-2-escribir-el-webcomponent-js)
3. [Paso 3: Escribir CSS (Shadow DOM)](#3-paso-3-escribir-css-shadow-dom)
4. [Paso 4: Escribir Tags DOXYGEN en el .emic](#4-paso-4-escribir-tags-doxygen-en-el-emic)
5. [Paso 5: Escribir Archivo .emic Completo](#5-paso-5-escribir-archivo-emic-completo)

### PARTE 2: VALIDACION
6. [Paso 6: Crear Modulo de Prueba](#6-paso-6-crear-modulo-de-prueba)
7. [Paso 7: Testing en Browser](#7-paso-7-testing-en-browser)
8. [Tabla de Equivalencias con API Embebida](#8-tabla-de-equivalencias-con-api-embebida)

---

## PARTE 1: DESARROLLO

---

## 1. Paso 1: Crear Carpetas

### 1.1 Ubicacion en el SDK

```
EMIC_Dashboard_SDK/
+-- _widgets/
    +-- {Categoria}/
        +-- {NombreWidget}/
            +-- {widget}.emic        # Archivo principal EMIC
            +-- src/
            |   +-- {widget}.js      # WebComponent (logica + render)
            +-- css/
                +-- {widget}.css     # Estilos (Shadow DOM)
```

### 1.2 Ejemplo: Widget Gauge

```
EMIC_Dashboard_SDK/
+-- _widgets/
    +-- Indicators/                  # Categoria
        +-- Gauge/                   # Nombre del widget
            +-- gauge.emic           # Archivo EMIC-Codify
            +-- src/
            |   +-- emic-widget-gauge.js    # WebComponent
            +-- css/
                +-- emic-widget-gauge.css   # Estilos
```

### 1.3 Convenciones de Nombres

| Elemento | Convencion | Ejemplo |
|----------|-----------|---------|
| Categoria | PascalCase | `Indicators`, `Charts`, `Controls` |
| Carpeta widget | PascalCase | `Gauge`, `LineChart`, `Switch` |
| Archivo .emic | minusculas | `gauge.emic` |
| Archivo .js | prefijo emic-widget- | `emic-widget-gauge.js` |
| Archivo .css | prefijo emic-widget- | `emic-widget-gauge.css` |
| Custom Element | emic-nombre | `<emic-widget-gauge>` |
| Funciones JS | Widget_.{name}._func() | `Gauge_temp_setValue()` |

---

## 2. Paso 2: Escribir el WebComponent JS

### 2.1 Estructura Base del WebComponent

**Archivo: `_widgets/Indicators/Gauge/src/emic-widget-gauge.js`**

```javascript
/**
 * EMIC Gauge Widget
 * Displays a radial or linear gauge for numeric values
 */
class EmicGauge extends HTMLElement {

    constructor() {
        super();
        this.attachShadow({ mode: 'open' });

        // Estado interno
        this._value = 0;
        this._min = 0;
        this._max = 100;
        this._threshold = null;
        this._mode = 'radial';  // 'radial' o 'linear'
    }

    connectedCallback() {
        this._render();
    }

    // =========================================
    // FUNCIONES PUBLICAS (expuestas via .emic)
    // =========================================

    /** Establecer el valor actual del gauge */
    setValue(value) {
        const numValue = parseFloat(value);
        if (isNaN(numValue)) return;

        this._value = Math.max(this._min, Math.min(this._max, numValue));
        this._updateDisplay();

        // Verificar threshold
        if (this._threshold !== null && this._value >= this._threshold) {
            this._fireThresholdEvent(this._value);
        }
    }

    /** Establecer rango min/max */
    setRange(min, max) {
        this._min = parseFloat(min);
        this._max = parseFloat(max);
        this._updateDisplay();
    }

    /** Establecer valor de threshold para evento */
    setThreshold(value) {
        this._threshold = parseFloat(value);
    }

    /** Establecer modo de visualizacion */
    setMode(mode) {
        this._mode = mode;
        this._render();
    }

    // =========================================
    // RENDER (Shadow DOM)
    // =========================================

    _render() {
        const cssUrl = this.getAttribute('css-url') || 'css/emic-widget-gauge.css';

        this.shadowRoot.innerHTML = `
            <link rel="stylesheet" href="${cssUrl}">
            <div class="gauge-container gauge-${this._mode}">
                <div class="gauge-label">${this.getAttribute('label') || ''}</div>
                ${this._mode === 'radial' ? this._renderRadial() : this._renderLinear()}
                <div class="gauge-value">
                    <span class="value-number">${this._value}</span>
                    <span class="value-unit">${this.getAttribute('unit') || ''}</span>
                </div>
            </div>
        `;
    }

    _renderRadial() {
        const percent = this._getPercent();
        const angle = (percent / 100) * 270;  // 270 grados de arco

        return `
            <svg class="gauge-svg" viewBox="0 0 200 200">
                <circle class="gauge-track"
                    cx="100" cy="100" r="80"
                    fill="none" stroke-width="12"
                    stroke-dasharray="340" stroke-dashoffset="0"
                    transform="rotate(135 100 100)" />
                <circle class="gauge-fill"
                    cx="100" cy="100" r="80"
                    fill="none" stroke-width="12"
                    stroke-dasharray="340"
                    stroke-dashoffset="${340 - (percent / 100) * 340}"
                    transform="rotate(135 100 100)" />
            </svg>
        `;
    }

    _renderLinear() {
        const percent = this._getPercent();

        return `
            <div class="gauge-bar">
                <div class="gauge-bar-track">
                    <div class="gauge-bar-fill" style="width: ${percent}%"></div>
                </div>
            </div>
        `;
    }

    // =========================================
    // UTILIDADES INTERNAS
    // =========================================

    _getPercent() {
        if (this._max === this._min) return 0;
        return ((this._value - this._min) / (this._max - this._min)) * 100;
    }

    _updateDisplay() {
        const valueEl = this.shadowRoot.querySelector('.value-number');
        if (valueEl) valueEl.textContent = this._value.toFixed(1);

        if (this._mode === 'radial') {
            const fill = this.shadowRoot.querySelector('.gauge-fill');
            if (fill) {
                const percent = this._getPercent();
                fill.setAttribute('stroke-dashoffset', 340 - (percent / 100) * 340);
            }
        } else {
            const fill = this.shadowRoot.querySelector('.gauge-bar-fill');
            if (fill) fill.style.width = this._getPercent() + '%';
        }
    }

    _fireThresholdEvent(value) {
        this.dispatchEvent(new CustomEvent('threshold', {
            detail: { value },
            bubbles: true,
            composed: true
        }));

        // Emitir al EventBus global
        if (window.emicBus) {
            window.emicBus.dispatchEvent(new CustomEvent(
                'Gauge_.{name}._onThreshold',
                { detail: { value } }
            ));
        }
    }
}

// Registrar Custom Element
customElements.define('emic-widget-gauge', EmicGauge);

// =========================================
// FUNCIONES GLOBALES (registradas en EMICApp)
// =========================================

function Gauge_.{name}._init() {
    const el = document.querySelector('emic-widget-gauge[name=".{name}."]');
    if (el) {
        el.setRange(.{defaultValue|config..{name}..min}., .{defaultValue|config..{name}..max}.);
    }
}

function Gauge_.{name}._setValue(value) {
    const el = document.querySelector('emic-widget-gauge[name=".{name}."]');
    if (el) el.setValue(value);
}

function Gauge_.{name}._setRange(min, max) {
    const el = document.querySelector('emic-widget-gauge[name=".{name}."]');
    if (el) el.setRange(min, max);
}

function Gauge_.{name}._setThreshold(value) {
    const el = document.querySelector('emic-widget-gauge[name=".{name}."]');
    if (el) el.setThreshold(value);
}

// Registrar init
EMICApp.registerInit(Gauge_.{name}._init);
```

### 2.2 Elementos Clave del WebComponent

| Elemento | Proposito |
|----------|-----------|
| `class EmicGauge extends HTMLElement` | Define el Custom Element |
| `this.attachShadow({ mode: 'open' })` | Crea Shadow DOM encapsulado |
| `connectedCallback()` | Se ejecuta al insertar en el DOM |
| `setValue()`, `setRange()` | Funciones publicas expuestas |
| `_render()`, `_updateDisplay()` | Funciones internas de renderizado |
| `customElements.define('emic-widget-gauge', EmicGauge)` | Registra el tag HTML |
| `Gauge_.{name}._init()` | Funcion global registrada en EMICApp |

---

## 3. Paso 3: Escribir CSS (Shadow DOM)

### 3.1 Estilos del Widget

**Archivo: `_widgets/Indicators/Gauge/css/emic-widget-gauge.css`**

```css
/* emic-widget-gauge.css - Estilos Shadow DOM del Gauge */

:host {
    display: block;
    width: 100%;
    height: 100%;
    background: var(--color-bg-card, #16213e);
    border: 1px solid var(--color-border, #2a2a4a);
    border-radius: var(--border-radius, 4px);
    box-shadow: var(--shadow-card, 0 2px 8px rgba(0,0,0,0.3));
    padding: 16px;
    font-family: var(--font-family, monospace);
    color: var(--color-text, #e0e0e0);
    box-sizing: border-box;
    overflow: hidden;
}

.gauge-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100%;
}

/* Label */
.gauge-label {
    font-size: var(--font-size-label, 12px);
    color: var(--color-text-secondary, #a0a0a0);
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 8px;
}

/* Radial gauge */
.gauge-svg {
    width: 80%;
    max-width: 200px;
}

.gauge-track {
    stroke: var(--gauge-track-color, #2a2a4a);
}

.gauge-fill {
    stroke: var(--gauge-fill-color, #00e676);
    transition: stroke-dashoffset 0.5s ease;
    stroke-linecap: round;
}

/* Linear gauge */
.gauge-bar {
    width: 100%;
    padding: 0 16px;
}

.gauge-bar-track {
    width: 100%;
    height: 12px;
    background: var(--gauge-track-color, #2a2a4a);
    border-radius: 6px;
    overflow: hidden;
}

.gauge-bar-fill {
    height: 100%;
    background: var(--gauge-fill-color, #00e676);
    border-radius: 6px;
    transition: width 0.5s ease;
}

/* Value display */
.gauge-value {
    margin-top: 12px;
    text-align: center;
}

.value-number {
    font-size: var(--font-size-title, 24px);
    font-weight: bold;
    color: var(--color-text-accent, #00e676);
}

.value-unit {
    font-size: var(--font-size-label, 12px);
    color: var(--color-text-secondary, #a0a0a0);
    margin-left: 4px;
}
```

### 3.2 Uso de CSS Custom Properties del Theme

El widget **no hardcodea colores**. Usa `var(--variable, fallback)` para leer los valores del theme activo:

```
Theme CSS (industrial.css)           Widget CSS (emic-widget-gauge.css)
===========================          ==========================

--color-bg-card: #16213e     --->    background: var(--color-bg-card)
--color-text-accent: #00e676 --->    color: var(--color-text-accent)
--gauge-fill-color: #00e676  --->    stroke: var(--gauge-fill-color)
```

Si el usuario cambia de theme (ej: de `industrial` a `light`), los widgets se adaptan automaticamente sin cambiar su CSS.

---

## 4. Paso 4: Escribir Tags DOXYGEN en el .emic

### 4.1 Tag para Funcion setValue

```c
/**
* @fn void Gauge_.{name}._setValue(float value);
* @alias .{name}..setValue
* @brief Set the current value displayed by the gauge
* @param value Numeric value to display (clamped to min/max range)
* @return Nothing
*/
```

### 4.2 Tag para Funcion setRange

```c
/**
* @fn void Gauge_.{name}._setRange(float min, float max);
* @alias .{name}..setRange
* @brief Set the minimum and maximum range of the gauge
* @param min Minimum value of the scale
* @param max Maximum value of the scale
* @return Nothing
*/
```

### 4.3 Tag para Funcion setThreshold

```c
/**
* @fn void Gauge_.{name}._setThreshold(float value);
* @alias .{name}..setThreshold
* @brief Set the threshold value that triggers the onThreshold event
* @param value Threshold value
* @return Nothing
*/
```

### 4.4 Tag para Evento onThreshold

```c
/**
* @fn extern void Gauge_.{name}._onThreshold(float value);
* @alias .{name}..onThreshold
* @brief Fires when the gauge value crosses the threshold
* @return Nothing
*/
```

### 4.5 Tag para Configurador

```c
EMIC:json(type = Configurator)
{
    "name": "mode",
    "legend": "Display mode",
    "brief": "Visual style of the gauge",
    "options": [
        {"legend": "Radial", "value": "radial", "brief": "Circular arc gauge"},
        {"legend": "Linear", "value": "linear", "brief": "Horizontal bar gauge"}
    ]
}
```

### 4.6 Estructura del Alias

```
.{name}..setValue
  |       |
  |       +-- Nombre de la funcion
  +-- Parametro name (se sustituye por el nombre del usuario)

Resultado: tempGauge.setValue, pressureGauge.setValue
```

---

## 5. Paso 5: Escribir Archivo .emic Completo

### 5.1 Archivo gauge.emic Completo

**Archivo: `_widgets/Indicators/Gauge/gauge.emic`**

```emic
// 1. IDENTIFICACION
EMIC:tag(driverName = Gauge)

// 2. TAGS DE PUBLICACION

/**
* @fn void Gauge_.{name}._setValue(float value);
* @alias .{name}..setValue
* @brief Set the current value displayed by the gauge
* @param value Numeric value to display
* @return Nothing
*/

/**
* @fn void Gauge_.{name}._setRange(float min, float max);
* @alias .{name}..setRange
* @brief Set the min and max range of the gauge
* @param min Minimum value
* @param max Maximum value
* @return Nothing
*/

/**
* @fn void Gauge_.{name}._setThreshold(float value);
* @alias .{name}..setThreshold
* @brief Set threshold that triggers onThreshold event
* @param value Threshold value
* @return Nothing
*/

/**
* @fn extern void Gauge_.{name}._onThreshold(float value);
* @alias .{name}..onThreshold
* @brief Fires when the value crosses the threshold
* @return Nothing
*/

// 3. CONFIGURADOR
EMIC:json(type = Configurator)
{
    "name": "mode",
    "legend": "Display mode",
    "brief": "Visual style of the gauge",
    "options": [
        {"legend": "Radial", "value": "radial", "brief": "Circular arc gauge"},
        {"legend": "Linear", "value": "linear", "brief": "Horizontal bar gauge"}
    ]
}

// 4. DEPENDENCIAS
EMIC:setInput(DEV:_system/system.emic)

// 5. COPIAR ARCHIVOS AL WORKSPACE (SYS:, no directamente a TARGET:)
// Un solo archivo JS por tipo de widget - las instancias comparten el mismo JS
EMIC:copy(src/emic-widget-gauge.js > SYS:widgets/emic-widget-gauge.js, name=.{name}.)
EMIC:copy(css/emic-widget-gauge.css > SYS:widgets/emic-widget-gauge.css)

// 6. REGISTRAR PARA EL PROYECTO
EMIC:define(imports.gauge_.{name}., emic-widget-gauge_.{name}.)
EMIC:define(modules.gauge_.{name}., emic-widget-gauge_.{name}.)
EMIC:define(styles.gauge, emic-widget-gauge)
```

### 5.2 Secciones Explicadas

| Seccion | Proposito |
|---------|-----------|
| `EMIC:tag(driverName = Gauge)` | Agrupa recursos bajo "Gauge" en el editor |
| Tags DOXYGEN | Definen funciones y eventos visibles en el editor |
| `EMIC:json(type = Configurator)` | Opciones configurables por el usuario |
| `EMIC:setInput(DEV:_system/system.emic)` | Dependencia del core (EventBus) |
| `EMIC:copy(src/... > SYS:...)` | Copia JS/CSS al workspace editable con sustitucion de macros |
| `EMIC:define(imports.*, *)` | Registra el script para import en index.html |

---

## PARTE 2: VALIDACION

---

## 6. Paso 6: Crear Modulo de Prueba

### 6.1 Estructura del Modulo de Prueba

```
_modules/Test/GaugeTest/
+-- m_description.json
+-- System/
    +-- discovery.emic
    +-- generate.emic
```

### 6.2 m_description.json

```json
{
    "type": "web-dashboard",
    "toolTip": "Gauge Widget Test Module",
    "description": "Test module for validating the Gauge widget",
    "HardwareDescription": [
        {"PinName": "Gauge", "PinType": "Widget", "PinDescription": "Radial/linear gauge"}
    ],
    "features": ["Gauge display", "Threshold events"],
    "keyWord": ["gauge", "test", "indicator"]
}
```

### 6.3 discovery.emic

```emic
EMIC:setOutput(SYS:discovery.txt)

    // Widget bajo prueba
    EMIC:setInput(DEV:_widgets/Indicators/Gauge/gauge.emic, name=_INSTANCE_)

    // Connector para datos de prueba
    EMIC:setInput(DEV:_connectors/REST/rest-client.emic, name=_INSTANCE_)

EMIC:restoreOutput
```

### 6.4 generate.emic

```emic
EMIC:setOutput(TARGET:generate.txt)

    // Layout y theme
    EMIC:setInput(DEV:_layouts/layouts.emic, layout=dashboard-grid, theme=dark)

    // Funciones/eventos usados
    EMIC:setInput(SYS:usedFunction.emic)
    EMIC:setInput(SYS:usedEvent.emic)

    // Widgets del usuario
    EMIC:foreach(widgets.*)
        EMIC:setInput(DEV:_widgets/.{widgets.{*}}./.{widgets.{*}}..emic, name=.{*}.)
    EMIC:endforeach

    // Connectors del usuario
    EMIC:foreach(connectors.*)
        EMIC:setInput(DEV:_connectors/.{connectors.{*}}./.{connectors.{*}}..emic, name=.{*}.)
    EMIC:endforeach

    // System y main
    EMIC:setInput(DEV:_system/system.emic)
    EMIC:setInput(DEV:_main/webapp/main.emic)

    // Codigo del usuario
    EMIC:copy(SYS:userApp.js > TARGET:userApp.js)
    EMIC:define(modules.userApp, userApp)

    // Deploy
    EMIC:copy(DEV:_templates/deploy/github-pages > TARGET:)

EMIC:restoreOutput
```

---

## 7. Paso 7: Testing en Browser

### 7.1 Abrir el Proyecto Generado

```bash
# Navegar a la carpeta TARGET
cd target/

# Servir con cualquier servidor HTTP local
npx serve .
# o
python -m http.server 8080
```

### 7.2 Verificar en DevTools del Navegador

**Console (F12):**
```javascript
// Verificar que el Custom Element esta registrado
customElements.get('emic-widget-gauge');
// Debe retornar: class EmicGauge

// Verificar instancia
const gauge = document.querySelector('emic-widget-gauge[name="testGauge"]');
gauge.setValue(75);
gauge.setRange(0, 200);
```

### 7.3 Plan de Pruebas

| Test | Accion | Resultado Esperado |
|------|--------|-------------------|
| T1 | Cargar pagina | Gauge se renderiza en el grid |
| T2 | `testGauge.setValue(50)` | Valor muestra "50.0", arco al 50% |
| T3 | `testGauge.setRange(0, 200)` | Escala cambia, arco se ajusta |
| T4 | `testGauge.setThreshold(80)` | Threshold configurado |
| T5 | `testGauge.setValue(85)` | Evento onThreshold se dispara |
| T6 | Cambiar theme a "light" | Colores cambian automaticamente |
| T7 | Reducir ventana a 768px | Layout pasa a modo responsive |

### 7.4 Errores Comunes

| Error | Causa | Solucion |
|-------|-------|----------|
| Widget no se muestra | Custom Element no registrado | Verificar que el .js se importa en index.html |
| Estilos no aplican | CSS fuera del Shadow DOM | Verificar que el link al CSS esta en el template del Shadow DOM |
| Theme no funciona | Variables CSS no definidas | Verificar que theme.css se carga antes del widget |
| Macro `.{name}.` visible | Parametro no sustituido | Verificar `copy` con parametro `name=.{name}.` |
| Archivo `emic-widget-gauge_testc.js` | Punto simple en vez de doble | Usar `emic-widget-gauge_.{name}..js` (doble punto) |

---

## 8. Tabla de Equivalencias con API Embebida

| Aspecto | API Embebida (LEDs) | Widget Dashboard (Gauge) |
|---------|---------------------|--------------------------|
| **Carpeta** | `_api/Indicators/LEDs/` | `_widgets/Indicators/Gauge/` |
| **Archivos** | `led.emic`, `led.h`, `led.c` | `gauge.emic`, `emic-widget-gauge.js`, `emic-widget-gauge.css` |
| **Lenguaje** | C (compilado) | JavaScript (interpretado) |
| **Componente base** | funciones C + HAL | class extends HTMLElement (WebComponent) |
| **Encapsulacion** | `static` variables + `#ifndef` | Shadow DOM + CSS scope |
| **EMIC:tag** | `EMIC:tag(driverName = LEDs)` | `EMIC:tag(driverName = Gauge)` |
| **Funciones** | `LEDs_.{name}._state()` | `Gauge_.{name}._setValue()` |
| **Eventos** | `@fn extern void onEvent()` | `@fn extern void onThreshold()` |
| **Init** | `EMIC:define(inits.x, x_init)` | `EMICApp.registerInit(x_init)` |
| **Poll** | `EMIC:define(polls.x, x_poll)` | `EMICApp.registerPoll(x_poll)` |
| **Copy** | `EMIC:copy(src/led.c > TARGET:led_.{name}..c)` | `EMIC:copy(src/emic-widget-gauge.js > SYS:widgets/emic-widget-gauge.js)` |
| **Registro** | `EMIC:define(c_modules.x, x)` | `EMIC:define(modules.x, x)` |
| **Include** | `EMIC:define(main_includes.x, x)` | `EMIC:define(imports.x, x)` |
| **HAL** | `HAL_GPIO_PinSet(pin, val)` | `document.querySelector(selector)` |
| **Configurador** | `EMIC:json(type = Configurator)` | `EMIC:json(type = Configurator)` (identico) |
| **Doble punto** | `led_.{name}..c` | `emic-widget-gauge_.{name}..js` (misma regla) |
| **Validacion** | Compilar en MPLAB X | Abrir en browser + DevTools |

---

## Resumen

### Checklist de Desarrollo de Widget

- [ ] **Carpetas**: Crear `_widgets/Categoria/NombreWidget/`
- [ ] **WebComponent (.js)**: Class con Shadow DOM, connectedCallback, funciones publicas
- [ ] **CSS**: Estilos con `:host` y CSS Custom Properties del theme
- [ ] **Tags DOXYGEN**: `@fn`, `@alias`, `@brief`, `@param` para funciones y eventos
- [ ] **Configurador**: `EMIC:json(type = Configurator)` para opciones del usuario
- [ ] **Archivo .emic**: tag, dependencias, copy, registros (imports, modules, styles)
- [ ] **Modulo de prueba**: discovery.emic con `_INSTANCE_`, generate.emic con foreach
- [ ] **Testing**: Abrir en browser, verificar en DevTools, probar funciones

### Patron Tipico de Widget

```emic
// widget.emic
EMIC:tag(driverName = MiWidget)

/**
* @fn void MiWidget_.{name}._funcion(tipo param);
* @alias .{name}..funcion
* @brief Descripcion
* @param param Descripcion del parametro
* @return Nothing
*/

EMIC:setInput(DEV:_system/system.emic)

EMIC:copy(src/emic-widget.js > SYS:widgets/emic-widget.js, name=.{name}.)
EMIC:copy(css/emic-widget.css > SYS:widgets/emic-widget.css)

EMIC:define(imports.widget_.{name}., emic-widget_.{name}.)
EMIC:define(modules.widget_.{name}., emic-widget_.{name}.)
EMIC:define(styles.widget, emic-widget)
```

---

**Navegacion:**
- [← Capitulo 21: Desarrollo de API (Embebido)](21_Desarrollo_API_Paso_a_Paso.md)
- [→ Capitulo 22b: Desarrollo de un Connector](22b_Desarrollo_Connector.md)
