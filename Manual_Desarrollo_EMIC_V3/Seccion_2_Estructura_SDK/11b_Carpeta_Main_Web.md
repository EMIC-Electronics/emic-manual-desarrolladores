# Capitulo 11b: Carpeta `_main/` - Entry Point Web (Dashboard)

[← Anterior: Carpeta _main (Embebido)](11_Carpeta_Main.md) | [Siguiente: Carpeta _layouts →](12b_Carpeta_Layouts.md)

## Indice
1. [Que es _main/ en Dashboard](#1-que-es-_main-en-dashboard)
2. [SPA vs Multi-Page](#2-spa-vs-multi-page)
3. [index.html con Macros EMIC](#3-indexhtml-con-macros-emic)
4. [app-shell.js](#4-app-shelljs)
5. [sw.js - Service Worker / PWA](#5-swjs---service-worker--pwa)
6. [main.emic - Orquestador Web](#6-mainemic---orquestador-web)
7. [Flujo de Ejecucion del Dashboard](#7-flujo-de-ejecucion-del-dashboard)
8. [Tabla de Equivalencias Embebido vs Dashboard](#8-tabla-de-equivalencias-embebido-vs-dashboard)

---

## 1. Que es _main/ en Dashboard

La carpeta `_main/` contiene el **punto de entrada principal** de la aplicacion web del dashboard. Es el equivalente web del `main.c` del firmware: el archivo que el navegador carga primero y desde el cual se inicializan todos los componentes.

### 1.1 Ubicacion en la Arquitectura EMIC Dashboard

```
+--------------------------------------------------+
|    DEPLOY FINAL -> Aplicacion Web Estatica        |
+----------------------------+---------------------+
                             |
                             v
+--------------------------------------------------+
|         index.html (TARGET:index.html)            |  <-- ESTE NIVEL
|         Generado desde _main/webapp/              |
+--------------------------------------------------+
|  Integra:                                         |
|  - Layout (_layouts/)                             |
|  - Widgets (_widgets/)                            |
|  - Connectors (_connectors/)                      |
|  - Codigo de usuario (userApp.js)                 |
+--------------------------------------------------+
```

### 1.2 Contenido de `_main/`

```
_main/
+-- webapp/
    +-- index.html          # Template del entry point con macros EMIC-Codify
    +-- app-shell.js        # Application shell (carga modular)
    +-- sw.js               # Service Worker para PWA/offline
    +-- main.emic           # Archivo de integracion EMIC
```

### 1.3 Responsabilidades de `_main/`

| Responsabilidad | Descripcion |
|----------------|-------------|
| **Punto de entrada** | Define el index.html que carga el navegador |
| **Carga de modulos** | Importa todos los widgets y connectors registrados |
| **Inicializacion** | Ejecuta todas las funciones `.{inits.*}.` al cargar |
| **Loop de actualizacion** | Ejecuta `.{polls.*}.` mediante requestAnimationFrame |
| **PWA / Offline** | Service Worker para funcionamiento sin conexion |

---

## 2. SPA vs Multi-Page

El dashboard EMIC usa una arquitectura **SPA (Single Page Application)** donde toda la aplicacion vive en un unico `index.html`.

### 2.1 Comparacion

```
MULTI-PAGE (tradicional)              SPA (EMIC Dashboard)
========================              ====================

  index.html                            index.html
  config.html                              |
  status.html                              +-- <emic-router>
  alerts.html                              |     route "/" -> dashboard-view
     |                                     |     route "/config" -> config-view
     v                                     |     route "/alerts" -> alerts-view
  Cada pagina recarga                      |
  todo el HTML/CSS/JS                      v
                                        Solo cambia el contenido
                                        del <emic-router>
```

### 2.2 Ventajas de SPA para Dashboard

| Ventaja | Descripcion |
|---------|-------------|
| **Sin recargas** | Navegacion instantanea entre vistas |
| **Estado persistente** | Conexiones WebSocket/MQTT se mantienen |
| **Menor trafico** | Solo se cargan datos, no paginas completas |
| **PWA nativo** | Service Worker cache la aplicacion completa |

---

## 3. index.html con Macros EMIC

El archivo `index.html` es un **template** que EMIC procesa para generar el punto de entrada final.

### 3.1 Codigo Completo del index.html

**Archivo: `_main/webapp/index.html`**

```html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>.{system.dashboardName}.</title>

    <!-- Theme CSS -->
    <link rel="stylesheet" href="css/.{styles.*}..css">

    <!-- PWA Manifest -->
    <link rel="manifest" href="manifest.json">
    <meta name="theme-color" content=".{system.themeColor}.">
</head>
<body>
    <div class="emic-dashboard" id="app">
        <!-- El layout define las areas disponibles -->
        <!-- Los widgets se insertan en los slots correspondientes -->
    </div>

    <!-- Core: Event Bus y utilidades -->
    <script src="js/emic-core.js"></script>
    <script src="js/emic-component-base.js"></script>

    <!-- Imports: Todos los modulos registrados -->
    <script type="module" src=".{imports.*}..js"></script>

    <!-- Application Shell -->
    <script src="app-shell.js"></script>

    <!-- User Application Code -->
    <script src="userApp.js"></script>

    <!-- Service Worker Registration -->
    <script>
        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.register('sw.js');
        }
    </script>
</body>
</html>
```

### 3.2 Analisis de las Macros

| Macro | Descripcion | Ejemplo de Expansion |
|-------|-------------|----------------------|
| `.{system.dashboardName}.` | Titulo del dashboard | `Monitor Industrial V2` |
| `.{styles.*}.` | Archivos CSS registrados | `layout.css`, `theme.css` |
| `.{system.themeColor}.` | Color del theme para PWA | `#1a1a2e` |
| `.{imports.*}.` | Scripts de widgets/connectors | `emic-gauge.js`, `mqtt-client.js` |

### 3.3 Expansion de `.{imports.*}.`

**Antes (template):**
```html
<script type="module" src=".{imports.*}..js"></script>
```

**Despues (generado):**
```html
<script type="module" src="emic-gauge.js"></script>
<script type="module" src="emic-chart.js"></script>
<script type="module" src="emic-switch.js"></script>
<script type="module" src="mqtt-client.js"></script>
<script type="module" src="rest-client.js"></script>
```

---

## 4. app-shell.js

El Application Shell es el nucleo de ejecucion del dashboard. Gestiona la carga, inicializacion y el loop de actualizacion.

### 4.1 Estructura del app-shell.js

**Archivo: `_main/webapp/app-shell.js`**

```javascript
/**
 * EMIC Dashboard - Application Shell
 * Equivalente al main() del firmware embebido
 */
const EMICApp = {
    _inits: [],
    _polls: [],
    _running: false,

    /** Registrar funcion de inicializacion */
    registerInit(fn) {
        this._inits.push(fn);
    },

    /** Registrar funcion de polling */
    registerPoll(fn) {
        this._polls.push(fn);
    },

    /** Punto de entrada principal (equivalente a main()) */
    async start() {
        // 1. loadCore - cargar dependencias base
        await this._loadCore();

        // 2. loadConfig - cargar configuracion del usuario
        await this._loadConfig();

        // 3. inits - ejecutar todas las inicializaciones
        for (const init of this._inits) {
            await init();
        }

        // 4. onReady - evento post-inicializacion
        if (typeof onReady === 'function') {
            onReady();
        }

        // 5. LOOP - iniciar polling
        this._running = true;
        this._loop();
    },

    /** Loop principal (equivalente a while(1) { polls(); }) */
    _loop() {
        if (!this._running) return;

        for (const poll of this._polls) {
            poll();
        }

        requestAnimationFrame(() => this._loop());
    },

    async _loadCore() {
        // Inicializar EventBus global
        window.emicBus = new EventTarget();
    },

    async _loadConfig() {
        // Cargar configuracion desde config.json si existe
        try {
            const resp = await fetch('config.json');
            if (resp.ok) window.emicConfig = await resp.json();
        } catch(e) { /* config opcional */ }
    }
};

// Iniciar cuando el DOM este listo
document.addEventListener('DOMContentLoaded', () => EMICApp.start());
```

### 4.2 Registro de Inits y Polls

Los widgets y connectors se registran de la misma forma que las APIs embebidas:

```javascript
// En emic-gauge.js
EMICApp.registerInit(function Gauge_myGauge_init() {
    // Configurar el gauge al iniciar
    const el = document.querySelector('emic-gauge[name="myGauge"]');
    el.setAttribute('min', '0');
    el.setAttribute('max', '100');
});

EMICApp.registerPoll(function Gauge_myGauge_poll() {
    // Actualizar el gauge en cada frame (si hay datos nuevos)
    // DEBE ser no-bloqueante
});
```

---

## 5. sw.js - Service Worker / PWA

El Service Worker permite que el dashboard funcione **offline** como una Progressive Web App.

### 5.1 Estructura del sw.js

**Archivo: `_main/webapp/sw.js`**

```javascript
const CACHE_NAME = 'emic-dashboard-v.{system.version}.';
const ASSETS = [
    '/',
    '/index.html',
    '/app-shell.js',
    '/css/.{styles.*}..css',
    '/js/emic-core.js',
    '/js/emic-component-base.js',
    '.{imports.*}..js',
    '/userApp.js'
];

self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(cache => cache.addAll(ASSETS))
    );
});

self.addEventListener('fetch', event => {
    event.respondWith(
        caches.match(event.request)
            .then(cached => cached || fetch(event.request))
    );
});
```

### 5.2 Beneficios PWA para Dashboards Industriales

| Beneficio | Descripcion |
|-----------|-------------|
| **Offline** | Funciona sin conexion a internet |
| **Instalable** | Se puede instalar como app en el dispositivo |
| **Cache inteligente** | Carga instantanea despues de la primera visita |
| **Actualizacion** | El versionado fuerza recarga cuando hay cambios |

---

## 6. main.emic - Orquestador Web

El archivo `main.emic` orquesta la copia y procesamiento de los archivos del entry point.

### 6.1 Contenido de main.emic

**Archivo: `_main/webapp/main.emic`**

```emic
EMIC:tag(driverName = SYSTEM)

/**
* @fn extern void onReady();
* @alias onReady
* @brief When the dashboard and all widgets are initialized and ready.
* @return Nothing
*/

/**
* @fn extern void onConfigLoaded();
* @alias onConfigLoaded
* @brief Before initializing widgets, after loading configuration.
* @return Nothing
*/

EMIC:copy(DEV:_main/webapp/index.html > TARGET:index.html)
EMIC:copy(DEV:_main/webapp/app-shell.js > TARGET:app-shell.js)
EMIC:copy(DEV:_main/webapp/sw.js > TARGET:sw.js)

EMIC:define(modules.main, app-shell)
```

### 6.2 Eventos del Sistema Web

| Evento | Cuando se ejecuta | Equivalente Embebido |
|--------|-------------------|----------------------|
| `onConfigLoaded` | Despues de cargar config, antes de inits | `SystemConfig()` |
| `onReady` | Despues de todas las inits, antes del loop | `onReset()` |

---

## 7. Flujo de Ejecucion del Dashboard

### 7.1 Diagrama de Flujo Completo

```
+--------------------------------------------------+
|   Navegador carga index.html                      |
|   (Page Load)                                     |
+----------------------------+---------------------+
                             |
                             v
+--------------------------------------------------+
|   1. loadCore()                                   |
|   - Inicializar EventBus global                   |
|   - Cargar emic-core.js                           |
|   - Registrar Custom Elements base                |
+----------------------------+---------------------+
                             |
                             v
+--------------------------------------------------+
|   2. loadConfig()                                 |
|   - Fetch config.json                             |
|   - onConfigLoaded() [OPCIONAL]                   |
+----------------------------+---------------------+
                             |
                             v
+--------------------------------------------------+
|   3. Ejecutar todas las funciones .{inits.*}.     |
|   - Gauge_temp_init()                             |
|   - Chart_pressure_init()                         |
|   - MQTTClient_init()                             |
|   - RESTClient_init()                             |
+----------------------------+---------------------+
                             |
                             v
+--------------------------------------------------+
|   4. onReady() [OPCIONAL]                         |
|   - Logica de startup del usuario                 |
|   - Ej: conectar MQTT, cargar datos iniciales     |
+----------------------------+---------------------+
                             |
                             v
+--------------------------------------------------+
|   5. LOOP (requestAnimationFrame)                 |
|                                                   |
|   Ejecutar todas las funciones .{polls.*}.:       |
|   - Gauge_temp_poll()                             |
|   - Chart_pressure_poll()                         |
|   - MQTTClient_poll()                             |
|                                                   |
|   Repetir a ~60 FPS                               |
+--------------------------------------------------+
```

### 7.2 Tiempos de Ejecucion Tipicos

| Fase | Tiempo Aproximado | Descripcion |
|------|-------------------|-------------|
| **Page Load** | ~100-500 ms | Carga de HTML/CSS/JS |
| **loadCore()** | ~10-50 ms | Inicializar EventBus y core |
| **loadConfig()** | ~50-200 ms | Fetch config.json (puede ser async) |
| **Todas las inits** | ~50-300 ms | Inicializar widgets y connectors |
| **onReady()** | Variable | Depende del usuario |
| **Loop (1 frame)** | ~1-16 ms | Debe completarse en < 16ms para 60 FPS |

### 7.3 Comparacion con el Loop Embebido

```
EMBEBIDO                              DASHBOARD
========                              =========

do {                                  function _loop() {
    LEDs_Status_poll();                   Gauge_temp_poll();
    Timer1_poll();                        Chart_pressure_poll();
    UART2_poll();                         MQTTClient_poll();
} while(1);                               requestAnimationFrame(_loop);
                                      }

Frecuencia: ~10 kHz                   Frecuencia: ~60 Hz (60 FPS)
Bloqueante: NO (critico)              Bloqueante: NO (critico)
CPU: 100%                             CPU: solo cuando hay trabajo
```

---

## 8. Tabla de Equivalencias Embebido vs Dashboard

| Concepto Embebido | Concepto Dashboard | Descripcion |
|--------------------|---------------------|-------------|
| `main.c` | `index.html` | Punto de entrada principal |
| `main.emic` | `main.emic` | Orquestador EMIC (misma estructura) |
| `int main(void)` | `EMICApp.start()` | Funcion de arranque |
| `initSystem()` | `loadCore()` | Inicializacion del sistema base |
| `SystemConfig()` | `onConfigLoaded()` | Hook pre-inicializacion |
| `.{inits.*}.()` | `.{inits.*}.()` | Funciones de inicializacion registradas |
| `onReset()` | `onReady()` | Hook post-inicializacion |
| `do { .{polls.*}.(); } while(1)` | `requestAnimationFrame(_loop)` | Loop principal |
| `.{polls.*}.()` | `.{polls.*}.()` | Funciones de polling registradas |
| `#include "inc/.{main_includes.*}..h"` | `<script src=".{imports.*}..js">` | Importacion de modulos |
| `GCC / XC16 compiler` | `Browser (V8/SpiderMonkey)` | Motor de ejecucion |
| `firmware.hex` | `static web app (HTML/CSS/JS)` | Artefacto de salida |
| `EMIC:define(c_modules.x, x)` | `EMIC:define(modules.x, x)` | Registro de modulo para compilacion |
| `EMIC:define(main_includes.x, x)` | `EMIC:define(imports.x, x)` | Registro de import/include |
| `10 kHz polling` | `60 FPS polling` | Frecuencia del loop |
| `Watchdog Timer` | `Service Worker` | Mecanismo de recuperacion |

---

## Resumen

| Concepto | Descripcion |
|----------|-------------|
| **_main/webapp/** | Carpeta con el punto de entrada del dashboard |
| **index.html** | Template con macros EMIC-Codify para imports y estilos |
| **app-shell.js** | Application shell con sistema de inits/polls |
| **sw.js** | Service Worker para PWA y funcionamiento offline |
| **main.emic** | Orquestador que copia archivos y publica eventos |
| **EMICApp.start()** | Equivalente a main() del firmware |
| **requestAnimationFrame** | Equivalente al while(1) del loop embebido |

---

## Proximos Pasos

En el **Capitulo 12b** exploraremos la carpeta **`_layouts/`**, donde se definen los layouts y temas visuales del dashboard, equivalentes a la configuracion PCB del mundo embebido.

---

**Navegacion:**
- [← Capitulo 11: Carpeta _main (Embebido)](11_Carpeta_Main.md)
- [→ Capitulo 12b: Carpeta _layouts](12b_Carpeta_Layouts.md)
