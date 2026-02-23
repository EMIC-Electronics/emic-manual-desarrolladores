# Capitulo 13b: Carpeta `_templates/` - Templates de Deploy Web

[← Anterior: Carpeta _templates (Embebido)](13_Carpeta_Templates.md) | [Siguiente: Carpeta _system (Web) →](14b_Carpeta_System_Web.md)

## Indice
1. [Que son los Templates Web](#1-que-son-los-templates-web)
2. [Configuraciones de Deploy](#2-configuraciones-de-deploy)
3. [Plugins del Editor](#3-plugins-del-editor)
4. [Tab Widgets](#4-tab-widgets)
5. [Tab Services](#5-tab-services)
6. [Creacion de Templates Custom](#6-creacion-de-templates-custom)
7. [Tabla de Equivalencias Embebido vs Dashboard](#7-tabla-de-equivalencias-embebido-vs-dashboard)

---

## 1. Que son los Templates Web

La carpeta `_templates/` en el SDK Dashboard contiene **configuraciones de deploy** para diferentes plataformas de hosting y **definiciones de plugins** para el editor visual. Asi como en el SDK embebido `_templates/` genera un proyecto MPLAB X compilable, en el SDK Dashboard genera una aplicacion web lista para desplegar.

### 1.1 Ubicacion en el Proceso de Deploy

```
+--------------------------------------------------+
|   EMIC Generate procesa generate.emic             |
|   Fusiona SDK + codigo de usuario                 |
+----------------------------+---------------------+
                             |
                             v
+--------------------------------------------------+
|   Aplicacion web generada en TARGET:              |
|   - index.html                                    |
|   - emic-gauge.js                                 |
|   - mqtt-client.js                                |
|   - css/theme.css                                 |
+----------------------------+---------------------+
                             |
                             v
+--------------------------------------------------+
|   Templates (_templates/)    <-- ESTE NIVEL       |
|   Copia archivos de deploy:                       |
|   - .github/workflows/deploy.yml (GitHub Pages)   |
|   - netlify.toml (Netlify)                        |
|   - vercel.json (Vercel)                          |
+----------------------------+---------------------+
                             |
                             v
+--------------------------------------------------+
|   Proyecto web completo en TARGET:                |
|   Listo para hacer push y deploy automatico       |
+--------------------------------------------------+
```

### 1.2 Problema que Resuelve

**Sin `_templates/`:**
```bash
# Debes configurar manualmente:
1. Crear archivo de configuracion del hosting
2. Configurar rutas de build
3. Configurar cache y headers
4. Crear workflow de CI/CD

Tiempo: ~30 minutos por proyecto
```

**Con `_templates/`:**
```emic
// Una sola linea en generate.emic:
EMIC:copy(DEV:_templates/deploy/github-pages > TARGET:)

Tiempo: 0 segundos (automatico)
```

---

## 2. Configuraciones de Deploy

### 2.1 Estructura de la Carpeta

```
_templates/
+-- deploy/
|   +-- github-pages/               # Deploy en GitHub Pages
|   |   +-- .github/
|   |   |   +-- workflows/
|   |   |       +-- deploy.yml       # GitHub Actions workflow
|   |   +-- deploy.emic
|   +-- netlify/                     # Deploy en Netlify
|   |   +-- netlify.toml             # Configuracion Netlify
|   |   +-- _headers                 # Headers HTTP custom
|   |   +-- deploy.emic
|   +-- vercel/                      # Deploy en Vercel
|   |   +-- vercel.json              # Configuracion Vercel
|   |   +-- deploy.emic
|   +-- s3/                          # Deploy en AWS S3
|       +-- s3-sync.sh              # Script de sincronizacion
|       +-- deploy.emic
+-- plugins/
    +-- sidebar-tabs/                # Definiciones de tabs del editor
        +-- Widgets/                 # Tab de Widgets
        +-- Services/                # Tab de Services (Connectors)
        +-- Code/                    # Tab de Code (logica)
        +-- Data/                    # Tab de Data (variables)
        +-- Functions/               # Tab de Functions
        +-- User/                    # Tab personalizado
```

### 2.2 GitHub Pages

**Archivo: `_templates/deploy/github-pages/.github/workflows/deploy.yml`**

```yaml
name: Deploy EMIC Dashboard to GitHub Pages

on:
  push:
    branches: [ main ]

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Pages
        uses: actions/configure-pages@v4

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: './target'

      - name: Deploy to GitHub Pages
        uses: actions/deploy-pages@v4
```

### 2.3 Netlify

**Archivo: `_templates/deploy/netlify/netlify.toml`**

```toml
[build]
  publish = "target/"
  command = "echo 'Static site - no build needed'"

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    Cache-Control = "public, max-age=3600"

[[headers]]
  for = "/sw.js"
  [headers.values]
    Cache-Control = "no-cache"
```

### 2.4 Vercel

**Archivo: `_templates/deploy/vercel/vercel.json`**

```json
{
    "version": 2,
    "builds": [
        {
            "src": "target/**",
            "use": "@vercel/static"
        }
    ],
    "routes": [
        {
            "src": "/(.*)",
            "dest": "/target/$1"
        }
    ],
    "headers": [
        {
            "source": "/sw.js",
            "headers": [
                { "key": "Cache-Control", "value": "no-cache" }
            ]
        }
    ]
}
```

### 2.5 Uso en generate.emic

```emic
// Seleccionar plataforma de deploy
EMIC:copy(DEV:_templates/deploy/.{system.deployTarget}. > TARGET:)
```

Donde `.{system.deployTarget}.` puede ser `github-pages`, `netlify`, `vercel` o `s3`.

---

## 3. Plugins del Editor

Los plugins del editor definen las **pestanias laterales** (sidebar tabs) que el usuario ve en el EMIC-Editor al trabajar con un modulo dashboard.

### 3.1 Estructura de Plugins

```
_templates/plugins/sidebar-tabs/
+-- Widgets/                    # Catalogo de widgets disponibles
|   +-- index.xml               # Definicion del tab
+-- Services/                   # Catalogo de connectors/servicios
|   +-- index.xml               # Definicion del tab
+-- Code/                       # Bloques de logica
|   +-- index.xml
+-- Data/                       # Variables y bindings
|   +-- index.xml
+-- Functions/                  # Funciones del usuario
|   +-- index.xml
+-- User/                       # Tab personalizado
    +-- index.xml
```

### 3.2 Funcionamiento

El archivo `deploy.emic` de cada modulo copia estas definiciones al proyecto:

```emic
// En deploy.emic del modulo
EMIC:copy(DEV:_templates/plugins/sidebar-tabs > SYS:EMIC-TABS)
```

Despues del deploy, EMIC-Discovery genera el contenido real del tab **Resources** (que contiene las funciones y eventos de widgets/connectors) basandose en los tags DOXYGEN.

---

## 4. Tab Widgets

El tab **Widgets** muestra al usuario los componentes visuales disponibles para arrastrar al canvas del dashboard.

### 4.1 Estructura del Catalogo

**Archivo: `Widgets/index.xml`**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<tab name="Widgets" icon="grid">
    <category name="Indicators">
        <widget name="Gauge" icon="gauge"
                description="Radial or linear gauge for numeric values"
                template="emic-gauge" />
        <widget name="LED" icon="circle"
                description="Status indicator LED"
                template="emic-led" />
        <widget name="Label" icon="text"
                description="Text label with data binding"
                template="emic-label" />
    </category>
    <category name="Charts">
        <widget name="Line Chart" icon="chart-line"
                description="Real-time line chart"
                template="emic-chart" />
        <widget name="Bar Chart" icon="chart-bar"
                description="Bar chart for categories"
                template="emic-bar-chart" />
    </category>
    <category name="Controls">
        <widget name="Switch" icon="toggle"
                description="On/Off toggle switch"
                template="emic-switch" />
        <widget name="Slider" icon="sliders"
                description="Value slider control"
                template="emic-slider" />
        <widget name="Button" icon="button"
                description="Action button"
                template="emic-button" />
    </category>
</tab>
```

### 4.2 Flujo de Uso

```
1. Usuario abre el editor
2. Ve el tab "Widgets" en la sidebar
3. Arrastra "Gauge" al canvas
4. El editor pide un nombre: "tempGauge"
5. El sistema crea una instancia: <emic-gauge name="tempGauge">
6. Las funciones aparecen: tempGauge.setValue, tempGauge.setRange, etc.
```

---

## 5. Tab Services

El tab **Services** muestra los connectors (servicios de comunicacion) disponibles.

### 5.1 Estructura del Catalogo

**Archivo: `Services/index.xml`**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<tab name="Services" icon="plug">
    <category name="Communication">
        <service name="MQTT Client" icon="wifi"
                 description="MQTT broker connection for real-time data"
                 template="mqtt-client" />
        <service name="REST Client" icon="globe"
                 description="HTTP REST API client for data fetching"
                 template="rest-client" />
        <service name="WebSocket" icon="link"
                 description="WebSocket connection for bidirectional data"
                 template="ws-client" />
    </category>
    <category name="Storage">
        <service name="Local Storage" icon="database"
                 description="Browser local storage for persistence"
                 template="local-storage" />
    </category>
</tab>
```

### 5.2 Diferencia entre Widgets y Services

| Aspecto | Tab Widgets | Tab Services |
|---------|------------|--------------|
| **Que contiene** | Componentes visuales | Connectors de comunicacion |
| **Visible en pantalla** | Si (tiene renderizado) | No (trabaja en background) |
| **Ejemplo** | Gauge, Chart, Switch | MQTT, REST, WebSocket |
| **Equivalente embebido** | APIs (LEDs, Display) | Drivers (UART, SPI, I2C) |

---

## 6. Creacion de Templates Custom

### 6.1 Crear Template de Deploy

Para agregar soporte a una nueva plataforma de hosting:

#### Paso 1: Crear carpeta

```
_templates/deploy/mi-hosting/
+-- config.yaml           # Configuracion de la plataforma
+-- deploy.emic           # Orquestador EMIC
```

#### Paso 2: Crear deploy.emic

```emic
EMIC:copy(config.yaml > TARGET:config.yaml)
```

#### Paso 3: Usar en generate.emic

```emic
EMIC:copy(DEV:_templates/deploy/mi-hosting > TARGET:)
```

### 6.2 Crear Tab de Plugin

Para agregar una nueva pestania al editor:

#### Paso 1: Crear carpeta

```
_templates/plugins/sidebar-tabs/MiTab/
+-- index.xml
```

#### Paso 2: Definir el contenido

```xml
<?xml version="1.0" encoding="UTF-8"?>
<tab name="MiTab" icon="star">
    <category name="MiCategoria">
        <item name="MiElemento" icon="box"
              description="Descripcion del elemento"
              template="mi-elemento" />
    </category>
</tab>
```

---

## 7. Tabla de Equivalencias Embebido vs Dashboard

| Concepto Embebido | Concepto Dashboard | Descripcion |
|--------------------|---------------------|-------------|
| Template MPLAB X (`mplabx/`) | Template GitHub Pages (`github-pages/`) | Configuracion del entorno de build/deploy |
| Template ESP-IDF (`esp-idf/`) | Template Netlify (`netlify/`) | Alternativa de plataforma |
| `configurations.xml` con macros | `deploy.yml` / `netlify.toml` | Archivo de configuracion del proyecto |
| `.{c_modules.*}..c` en XML | Rutas de archivos en config de deploy | Lista de archivos del proyecto |
| `.{system.ucName}.` (PIC24) | `.{system.deployTarget}.` (github-pages) | Plataforma destino |
| Linker script (`.gld`) | `_headers` / `vercel.json` routes | Configuracion de bajo nivel |
| `_templates/plugins/sidebar-tabs/` | `_templates/plugins/sidebar-tabs/` | Misma ubicacion en ambos SDKs |
| Tab Resources (auto-generado) | Tab Resources (auto-generado) | Funciones/eventos via Discovery |
| (sin equivalente) | Tab **Widgets** | Catalogo de componentes visuales |
| (sin equivalente) | Tab **Services** | Catalogo de connectors |
| `make build` | `git push` + CI/CD | Proceso de build |
| `firmware.hex` | Sitio web estatico | Artefacto de salida |

---

## Resumen

| Concepto | Descripcion |
|----------|-------------|
| **_templates/deploy/** | Configuraciones de deploy para diferentes plataformas web |
| **github-pages** | Deploy automatico via GitHub Actions |
| **netlify** | Deploy con `netlify.toml` y headers HTTP |
| **vercel** | Deploy con `vercel.json` y routing |
| **_templates/plugins/** | Definiciones de tabs para el editor visual |
| **Tab Widgets** | Catalogo de componentes visuales arrastrables |
| **Tab Services** | Catalogo de connectors de comunicacion |

---

## Proximos Pasos

En el **Capitulo 14b** exploraremos la carpeta **`_system/`** en su version web, que incluye el EventBus, utilidades de binding y funciones de conversion para el entorno browser.

---

**Navegacion:**
- [← Capitulo 13: Carpeta _templates (Embebido)](13_Carpeta_Templates.md)
- [→ Capitulo 14b: Carpeta _system Web](14b_Carpeta_System_Web.md)
