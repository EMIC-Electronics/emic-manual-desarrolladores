# Capitulo 12b: Carpeta `_layouts/` - Layouts y Temas del Dashboard

[← Anterior: Carpeta _pcb (Embebido)](12_Carpeta_PCB.md) | [Siguiente: Carpeta _templates Web →](13b_Carpeta_Templates_Web.md)

## Indice
1. [Que es un Layout](#1-que-es-un-layout)
2. [Analogia _pcb/ -> _layouts/](#2-analogia-_pcb---_layouts)
3. [Estructura de Carpeta](#3-estructura-de-carpeta)
4. [Layouts Disponibles](#4-layouts-disponibles)
5. [Sistema de Themes](#5-sistema-de-themes)
6. [CSS Grid y CSS Custom Properties](#6-css-grid-y-css-custom-properties)
7. [Creacion de Nuevos Layouts](#7-creacion-de-nuevos-layouts)
8. [Tabla de Equivalencias Embebido vs Dashboard](#8-tabla-de-equivalencias-embebido-vs-dashboard)

---

## 1. Que es un Layout

Un **layout** define la **disposicion visual** de los widgets dentro del dashboard. Asi como un archivo PCB define donde se ubica cada componente electronico en la placa, un layout define donde se posiciona cada widget en la pantalla.

### 1.1 Ubicacion en la Arquitectura EMIC Dashboard

```
+---------------------------------------------------------+
|    Modulo Dashboard (Logica de aplicacion)               |
|    - gauge1.setValue(75)                                  |
|    - chart1.addPoint(ts, val)                            |
+----------------------------+----------------------------+
                             |
                             v
+---------------------------------------------------------+
|    Layout (_layouts/)           <-- ESTE NIVEL           |
|    - gauge1 = grid-area A1                               |
|    - chart1 = grid-area B1                               |
|    - sidebar = fixed left                                |
+----------------------------+----------------------------+
                             |
                             v
+---------------------------------------------------------+
|    Navegador (Browser)                                   |
|    - CSS Grid renderiza las areas                        |
|    - Theme aplica colores y tipografia                   |
+---------------------------------------------------------+
```

### 1.2 Problema que Resuelve

**Sin `_layouts/`:**
```css
/* Posicionamiento hardcodeado para una pantalla especifica */
#gauge1 { position: absolute; top: 50px; left: 20px; width: 200px; }
#chart1 { position: absolute; top: 50px; left: 240px; width: 500px; }
```

**Problema**: Si cambias de pantalla o reorganizas los widgets, debes modificar todo el CSS.

**Con `_layouts/`:**
```emic
EMIC:setInput(DEV:_layouts/layouts.emic, layout=dashboard-grid)
```

**Solucion**: El layout asigna automaticamente cada widget a su area correspondiente en el grid.

### 1.3 Responsabilidades de `_layouts/`

| Responsabilidad | Descripcion |
|----------------|-------------|
| **Disposicion de widgets** | Definir la grilla donde se posicionan los widgets |
| **Theme visual** | Colores, tipografia, bordes, sombras |
| **Responsive design** | Adaptacion a diferentes tamanios de pantalla |
| **CSS Custom Properties** | Variables CSS reutilizables por todos los widgets |
| **Nombre del layout** | Identificador unico de la configuracion visual |

---

## 2. Analogia _pcb/ -> _layouts/

La relacion entre `_pcb/` (embebido) y `_layouts/` (dashboard) es directa y conceptualmente equivalente.

### 2.1 Diagrama Comparativo

```
EMBEBIDO (_pcb/)                      DASHBOARD (_layouts/)
=================                     =====================

  Pin fisico RB5                        Area CSS "header"
       |                                     |
       v                                     v
  setPin.emic                           grid-area: header
  pin=B5, name=Led1                     slot=header, widget=navbar
       |                                     |
       v                                     v
  HAL_GPIO_PinSet(Led1, 1)             document.querySelector('[slot=header]')
       |                                     |
       v                                     v
  _LATB5 = 1                           <emic-navbar slot="header">
  (registro del MCU)                    (elemento en el DOM)
```

### 2.2 Mapa de Correspondencias

| Concepto en _pcb/ | Concepto en _layouts/ |
|--------------------|-----------------------|
| Pin fisico (RB5) | Area CSS (grid-area) |
| Nombre logico (Led1) | Slot logico (header, main, sidebar) |
| Board.h (configuracion) | Layout.js (definicion del grid) |
| systemConfig.h (fuses del MCU) | Theme.css (variables CSS) |
| setPin.emic (mapeo pin->nombre) | grid-area CSS (mapeo area->widget) |
| system.boardName | system.layoutName |
| FOSC / FCY | breakpoints / media queries |

---

## 3. Estructura de Carpeta

### 3.1 Organizacion de `_layouts/`

```
_layouts/
+-- layouts.emic                    # Orquestador (copia el layout seleccionado)
+-- inc/
|   +-- dashboard-grid/             # Layout 1: Grid principal
|   |   +-- layout.js               # Definicion del grid
|   |   +-- layout.css              # Estilos del grid
|   |   +-- layout.emic             # Archivo EMIC del layout
|   |   +-- responsive.css          # Media queries
|   +-- sidebar-layout/             # Layout 2: Sidebar + contenido
|   |   +-- layout.js
|   |   +-- layout.css
|   |   +-- layout.emic
|   |   +-- responsive.css
+-- themes/
    +-- dark.css                    # Theme oscuro
    +-- light.css                   # Theme claro
    +-- industrial.css              # Theme industrial
    +-- themes.emic                 # Orquestador de themes
```

### 3.2 Archivo Orquestador: `layouts.emic`

**Archivo: `_layouts/layouts.emic`**

```emic
EMIC:copy(inc/.{layout}./layout.js > TARGET:layout.js, layout=.{layout}.)
EMIC:copy(inc/.{layout}./layout.css > TARGET:css/layout.css, layout=.{layout}.)
EMIC:copy(inc/.{layout}./responsive.css > TARGET:css/responsive.css)

EMIC:define(styles.layout, layout)
EMIC:define(modules.layout, layout)

EMIC:define(system.layoutName, .{layout}.)

EMIC:setInput(DEV:_layouts/themes/themes.emic, theme=.{theme}.)
```

**Ejemplo de uso desde generate.emic:**
```emic
EMIC:setInput(DEV:_layouts/layouts.emic, layout=dashboard-grid, theme=industrial)
```

---

## 4. Layouts Disponibles

### 4.1 Layout: dashboard-grid

El layout mas comun para dashboards industriales. Organiza los widgets en una grilla CSS de areas nombradas.

**Archivo: `_layouts/inc/dashboard-grid/layout.css`**

```css
:root {
    --grid-columns: 12;
    --grid-gap: 16px;
    --header-height: 64px;
    --footer-height: 48px;
}

.emic-dashboard {
    display: grid;
    grid-template-columns: repeat(var(--grid-columns), 1fr);
    grid-template-rows: var(--header-height) 1fr var(--footer-height);
    grid-template-areas:
        "header header header header header header header header header header header header"
        "main   main   main   main   main   main   main   main   main   side  side  side"
        "footer footer footer footer footer footer footer footer footer footer footer footer";
    gap: var(--grid-gap);
    height: 100vh;
    padding: var(--grid-gap);
}

[slot="header"] { grid-area: header; }
[slot="main"]   { grid-area: main; }
[slot="side"]   { grid-area: side; }
[slot="footer"] { grid-area: footer; }
```

**Archivo: `_layouts/inc/dashboard-grid/layout.emic`**

```emic
EMIC:tag(driverName = Layout)

/**
* @fn void Layout_.{name}._setArea(const char* widgetId, const char* area);
* @alias .{name}..setArea
* @brief Assign a widget to a named grid area
* @param widgetId ID of the widget element
* @param area Name of the grid area (header, main, side, footer)
* @return Nothing
*/

EMIC:copy(layout.css > TARGET:css/layout_.{name}..css, name=.{name}.)
EMIC:copy(layout.js > TARGET:layout_.{name}..js, name=.{name}.)

EMIC:define(styles.layout_.{name}., layout_.{name}.)
EMIC:define(modules.layout_.{name}., layout_.{name}.)
```

### 4.2 Layout: sidebar-layout

Layout con barra lateral fija y area de contenido desplazable.

```
+-------------+--------------------------------------+
|             |              Header                   |
|  Sidebar    +--------------------------------------+
|  (fixed)    |                                      |
|             |         Content Area                 |
|  - Nav      |         (scrollable)                 |
|  - Filters  |                                      |
|  - Status   |    +--------+  +--------+            |
|             |    | Widget |  | Widget |            |
|             |    +--------+  +--------+            |
|             |                                      |
+-------------+--------------------------------------+
```

---

## 5. Sistema de Themes

Los themes controlan la apariencia visual del dashboard sin modificar el layout ni los widgets.

### 5.1 Theme Industrial

**Archivo: `_layouts/themes/industrial.css`**

```css
:root {
    /* Colores primarios */
    --color-primary: #1B5E20;
    --color-primary-light: #4CAF50;
    --color-primary-dark: #0D3B0F;

    /* Colores de fondo */
    --color-bg: #1a1a2e;
    --color-bg-card: #16213e;
    --color-bg-header: #0f3460;

    /* Colores de texto */
    --color-text: #e0e0e0;
    --color-text-secondary: #a0a0a0;
    --color-text-accent: #00e676;

    /* Colores de estado */
    --color-success: #00c853;
    --color-warning: #ffd600;
    --color-danger: #ff1744;
    --color-info: #2979ff;

    /* Tipografia */
    --font-family: 'Roboto Mono', 'Courier New', monospace;
    --font-size-base: 14px;
    --font-size-title: 24px;
    --font-size-label: 12px;

    /* Bordes y sombras */
    --border-radius: 4px;
    --border-color: #2a2a4a;
    --shadow-card: 0 2px 8px rgba(0, 0, 0, 0.3);

    /* Gauge y graficos */
    --gauge-track-color: #2a2a4a;
    --gauge-fill-color: #00e676;
    --chart-grid-color: #2a2a4a;
    --chart-line-color: #2979ff;
}
```

### 5.2 Themes Disponibles

| Theme | Uso Tipico | Fondo | Acento |
|-------|-----------|-------|--------|
| **dark** | Uso general, oficinas | #121212 | #bb86fc |
| **light** | Presentaciones, impresion | #ffffff | #6200ee |
| **industrial** | Plantas industriales, SCADA | #1a1a2e | #00e676 |

### 5.3 Archivo Orquestador: `themes.emic`

```emic
EMIC:copy(.{theme}..css > TARGET:css/theme.css, theme=.{theme}.)
EMIC:define(styles.theme, theme)
```

---

## 6. CSS Grid y CSS Custom Properties

### 6.1 Como Funcionan las CSS Custom Properties

Las CSS Custom Properties (variables CSS) permiten que los widgets lean los valores del theme activo sin conocer el theme especifico.

```
+----------------------------+
|  Theme (industrial.css)    |
|  --color-primary: #1B5E20  |
|  --color-text: #e0e0e0     |
+-------------+--------------+
              |
              v
+----------------------------+       +----------------------------+
|  Widget Gauge              |       |  Widget Chart              |
|  color: var(--color-text)  |       |  stroke: var(--color-info) |
|  fill: var(--color-primary)|       |  bg: var(--color-bg-card)  |
+----------------------------+       +----------------------------+
```

### 6.2 Ejemplo de Widget Usando Theme

```css
/* emic-gauge.css (Shadow DOM del widget) */
:host {
    display: block;
    background: var(--color-bg-card, #16213e);
    border: 1px solid var(--color-border, #2a2a4a);
    border-radius: var(--border-radius, 4px);
    box-shadow: var(--shadow-card, 0 2px 8px rgba(0,0,0,0.3));
    padding: 16px;
    font-family: var(--font-family, monospace);
    color: var(--color-text, #e0e0e0);
}

.gauge-value {
    font-size: var(--font-size-title, 24px);
    color: var(--color-text-accent, #00e676);
}

.gauge-label {
    font-size: var(--font-size-label, 12px);
    color: var(--color-text-secondary, #a0a0a0);
}
```

### 6.3 Responsive Design con Media Queries

**Archivo: `_layouts/inc/dashboard-grid/responsive.css`**

```css
/* Tablet (< 1024px) */
@media (max-width: 1024px) {
    .emic-dashboard {
        grid-template-areas:
            "header header header header header header header header header header header header"
            "main   main   main   main   main   main   main   main   main   main   main   main"
            "side   side   side   side   side   side   side   side   side   side   side   side"
            "footer footer footer footer footer footer footer footer footer footer footer footer";
    }
}

/* Mobile (< 768px) */
@media (max-width: 768px) {
    .emic-dashboard {
        grid-template-columns: 1fr;
        grid-template-areas:
            "header"
            "main"
            "side"
            "footer";
        --grid-gap: 8px;
    }
}
```

---

## 7. Creacion de Nuevos Layouts

### 7.1 Pasos para Crear un Layout

#### Paso 1: Crear carpeta del layout

```
_layouts/inc/mi-layout/
+-- layout.js
+-- layout.css
+-- layout.emic
+-- responsive.css
```

#### Paso 2: Definir la grilla CSS

**Archivo: `layout.css`**

```css
.emic-dashboard {
    display: grid;
    grid-template-columns: 250px 1fr 1fr 300px;
    grid-template-rows: 60px 1fr 1fr 40px;
    grid-template-areas:
        "nav    header  header  alerts"
        "nav    top-l   top-r   alerts"
        "nav    bot-l   bot-r   alerts"
        "nav    footer  footer  alerts";
    gap: 12px;
    height: 100vh;
}

[slot="nav"]     { grid-area: nav; }
[slot="header"]  { grid-area: header; }
[slot="alerts"]  { grid-area: alerts; }
[slot="top-l"]   { grid-area: top-l; }
[slot="top-r"]   { grid-area: top-r; }
[slot="bot-l"]   { grid-area: bot-l; }
[slot="bot-r"]   { grid-area: bot-r; }
[slot="footer"]  { grid-area: footer; }
```

#### Paso 3: Usar en generate.emic

```emic
EMIC:setInput(DEV:_layouts/layouts.emic, layout=mi-layout, theme=industrial)
```

### 7.2 Checklist de Layout

- [ ] Archivo `layout.css` con grid-template-areas definidas
- [ ] Archivo `layout.js` con logica de inicializacion
- [ ] Archivo `layout.emic` con tags y registros
- [ ] Archivo `responsive.css` con media queries
- [ ] Probado en resoluciones 1920x1080, 1024x768, 375x667

---

## 8. Tabla de Equivalencias Embebido vs Dashboard

| Concepto Embebido (_pcb/) | Concepto Dashboard (_layouts/) | Descripcion |
|---------------------------|--------------------------------|-------------|
| `_pcb/` | `_layouts/` | Carpeta de configuracion de hardware/visual |
| Pin fisico (RB5, GPIO2) | Area CSS (grid-area: header) | Ubicacion fisica/visual |
| `pcb.emic` (orquestador) | `layouts.emic` (orquestador) | Archivo que selecciona la configuracion |
| `Board.h` (configuracion PCB) | `layout.js` + `layout.css` | Definicion del posicionamiento |
| `systemConfig.h` (fuses MCU) | `theme.css` (variables CSS) | Configuracion de bajo nivel / apariencia |
| `setPin.emic` (pin=B5, name=Led1) | `grid-area` CSS (slot=header) | Mapeo fisico/visual a nombre logico |
| `system.ucName` (pic24FJ64GA002) | `system.layoutName` (dashboard-grid) | Identificador del hardware/layout |
| `system.boardName` (HRD_V1.0) | `system.themeName` (industrial) | Nombre de la configuracion activa |
| `FOSC` / `FCY` (frecuencias) | `breakpoints` / `media queries` | Parametros del entorno de ejecucion |
| Linker script (.gld) | `responsive.css` | Mapeo de memoria / adaptacion de pantalla |

---

## Resumen

| Concepto | Descripcion |
|----------|-------------|
| **_layouts/** | Carpeta con configuraciones de disposicion visual y temas |
| **layouts.emic** | Orquestador que carga el layout seleccionado |
| **dashboard-grid** | Layout basado en CSS Grid de 12 columnas |
| **sidebar-layout** | Layout con barra lateral fija |
| **themes/** | Archivos CSS con variables de apariencia |
| **CSS Custom Properties** | Variables CSS que los widgets consumen del theme |
| **responsive.css** | Media queries para adaptacion a diferentes pantallas |

---

## Proximos Pasos

En el **Capitulo 13b** exploraremos la carpeta **`_templates/`** en su version web, donde se encuentran las configuraciones de deploy (GitHub Pages, Netlify, Vercel) y los plugins del editor para el dashboard.

---

**Navegacion:**
- [← Capitulo 12: Carpeta _pcb (Embebido)](12_Carpeta_PCB.md)
- [→ Capitulo 13b: Carpeta _templates Web](13b_Carpeta_Templates_Web.md)
