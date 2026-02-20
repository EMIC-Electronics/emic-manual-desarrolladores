[← Anterior: Carpeta _system](14_Carpeta_System.md) | [Siguiente: Carpeta _util →](15_Carpeta_Util.md)

# Capitulo 14b: Carpeta `_system/` - Sistema Core Web Dashboard

## Indice
1. [Que es `_system/` en el Dashboard SDK](#1-que-es-_system-en-el-dashboard-sdk)
2. [Estructura de la Carpeta](#2-estructura-de-la-carpeta)
3. [Core (Loader, EmicComponentBase, Lifecycle)](#3-core-loader-emiccomponentbase-lifecycle)
4. [EventBus (emit/on, Analogia con Bus I2C/SPI)](#4-eventbus-emiton-analogia-con-bus-i2cspi)
5. [StateManager (Proxy Reactivo, getState/setState)](#5-statemanager-proxy-reactivo-getstatesetstate)
6. [Persistence (saveVar/loadVar, Analogia EEPROM)](#6-persistence-savevarloadvar-analogia-eeprom)
7. [DataStreams (Observable, Browser I/O)](#7-datastreams-observable-browser-io)
8. [Tabla de Equivalencias Embebido vs Dashboard](#8-tabla-de-equivalencias-embebido-vs-dashboard)

---

## 1. Que es `_system/` en el Dashboard SDK

La carpeta `_system/` contiene los **servicios core del motor Dashboard**. En el SDK embebido provee Streams y Conversiones; en el Dashboard provee: **Core loader**, **EventBus**, **StateManager**, **Persistence** y **DataStreams**.

```
+---------------------------------------------------+
|          Integrador (EMIC-Editor)                  |
+------------------------+--------------------------+
                         v
+---------------------------------------------------+
|     APIs (_api/)       | usa                       |
|     System (_system/)  <-- ESTE NIVEL              |
|     - Core (loader + base class)                   |
|     - EventBus, State, Persistence, DataStreams     |
+------------------------+--------------------------+
                         v
+---------------------------------------------------+
|     HAL (_hal/) - localStorage, fetch, WebSocket   |
+---------------------------------------------------+
```

| Responsabilidad | Descripcion |
|----------------|-------------|
| **Core / Loader** | Carga dinamica de widgets y conectores via `import()` |
| **EmicComponentBase** | Clase base para todos los WebComponents |
| **EventBus** | Comunicacion pub/sub entre componentes |
| **StateManager** | Estado global reactivo con notificacion automatica |
| **Persistence** | Almacenamiento no-volatil de variables de usuario |
| **DataStreams** | Abstraccion de flujo de datos (patron Observable) |

---

## 2. Estructura de la Carpeta

```
_system/
|-- core/
|   |-- emic-dashboard-core.emic       # Tags + dependencias + copy
|   +-- src/
|       |-- emic-dashboard-core.js     # Loader + lifecycle manager
|       +-- emic-component-base.js     # Clase base para widgets
|-- event-bus/
|   |-- event-bus.emic
|   +-- src/event-bus.js               # Sistema pub/sub global
|-- state/
|   |-- state-manager.emic
|   +-- src/state-manager.js           # Estado reactivo con Proxy
|-- persistence/
|   |-- persistence.emic
|   +-- src/persistence.js             # saveVar/loadVar sobre HAL Storage
+-- streams/
    |-- data-stream.emic
    +-- src/data-stream.js             # Flujo de datos Observable
```

Cada subcarpeta sigue el patron: un `.emic` (orquestador EMIC-Codify con tags y `EMIC:copy()`) y un `src/` con la implementacion JavaScript.

---

## 3. Core (Loader, EmicComponentBase, Lifecycle)

### 3.1 DashboardCore - Cargador Dinamico

Registra componentes y los carga bajo demanda con `import()` dinamico:

```javascript
class DashboardCore {
    constructor() {
        this._registry = new Map();   // tagName -> modulePath
        this._loaded = new Set();
    }
    register(tagName, modulePath) {
        this._registry.set(tagName, modulePath);
    }
    async load(tagName) {
        if (this._loaded.has(tagName)) return;
        const path = this._registry.get(tagName);
        if (!path) return;
        await import(path);
        this._loaded.add(tagName);
    }
    async init() {
        for (const el of document.querySelectorAll('[data-emic]')) {
            await this.load(el.tagName.toLowerCase());
        }
    }
}
export const dashboardCore = new DashboardCore();
```

### 3.2 EmicComponentBase - Clase Base

Extiende `HTMLElement` e integra automaticamente EventBus, StateManager y DataStreams:

```javascript
export class EmicComponentBase extends HTMLElement {
    constructor() {
        super();
        this._subscriptions = [];   // EventBus
        this._bindings = [];        // StateManager
        this.attachShadow({ mode: 'open' });
    }
    connectedCallback() { /* init del componente */ }
    disconnectedCallback() {
        this._subscriptions.forEach(unsub => unsub());
        this._bindings.forEach(unbind => unbind());
    }
    emit(eventName, data)    { eventBus.emit(eventName, data); }
    on(eventName, handler)   { /* suscribe + guarda unsub */ }
    getState(key)            { return stateManager.getState(key); }
    setState(key, value)     { stateManager.setState(key, value); }
    bindToSource(id, cb)     { /* subscribe + guarda unbind */ }
    publishToSink(id, value) { stateManager.setState(id, value); }
}
```

### 3.3 Lifecycle

| Embebido | Dashboard | Descripcion |
|----------|-----------|-------------|
| `initSystem()` | `DashboardCore.init()` | Inicializacion del motor |
| `inits.*()` | `connectedCallback()` | Init del componente |
| `polls.*()` | `requestAnimationFrame` / eventos | Actualizacion ciclica |
| *(destruccion)* | `disconnectedCallback()` | Limpieza de recursos |

---

## 4. EventBus (emit/on, Analogia con Bus I2C/SPI)

Sistema pub/sub global. Analogia: en I2C un dispositivo escribe al bus y otro lee por direccion; en EventBus un widget emite un evento y otro lo escucha por nombre. Ambos desacoplan emisor de receptor.

```
Embebido (I2C):                  Dashboard (EventBus):
+--------+   +--------+         +--------+   +--------+
| Sensor |   |Display |         | Widget |   | Widget |
+---+----+   +---+----+         +---+----+   +---+----+
====+============+====           ====+============+====
    Bus I2C compartido               EventBus compartido
```

```javascript
class EventBus {
    constructor() { this._listeners = new Map(); }
    emit(eventName, data) {
        const handlers = this._listeners.get(eventName);
        if (handlers) handlers.forEach(h => h(data));
    }
    on(eventName, handler) {
        if (!this._listeners.has(eventName)) this._listeners.set(eventName, new Set());
        this._listeners.get(eventName).add(handler);
        return () => this.off(eventName, handler);
    }
    off(eventName, handler) {
        const s = this._listeners.get(eventName);
        if (s) s.delete(handler);
    }
}
export const eventBus = new EventBus();
```

**Convencion de nombres:** `componente:accion` (ej. `sensor:temperature`), `system:ready`, `data:mqtt_in`.

---

## 5. StateManager (Proxy Reactivo, getState/setState)

Estado global reactivo compartido. Analogia: variables globales `volatile` en embebido, pero con **reactividad** -- los suscriptores se notifican automaticamente al cambiar un valor (sin polling).

```javascript
class StateManager {
    constructor() { this._state = {}; this._subscribers = new Map(); }
    getState(key) { return this._state[key]; }
    setState(key, value) {
        const old = this._state[key];
        this._state[key] = value;
        if (old !== value) {
            const subs = this._subscribers.get(key);
            if (subs) subs.forEach(cb => cb(value, old));
        }
    }
    subscribe(key, callback) {
        if (!this._subscribers.has(key)) this._subscribers.set(key, new Set());
        this._subscribers.get(key).add(callback);
        return () => this._subscribers.get(key).delete(callback);
    }
}
export const stateManager = new StateManager();
```

```
setState('temperature', 25.3) --> StateManager --> Notifica suscriptores
                                                      |
                                           +----------+----------+
                                           v          v          v
                                        Display    Chart      Logger
```

---

## 6. Persistence (saveVar/loadVar, Analogia EEPROM)

Almacenamiento no-volatil de variables. Usa HAL Storage (localStorage) como capa de abstraccion, igual que el embebido usa EEPROM a traves de HAL.

**Archivo `persistence.emic` con tags DOXYGEN:**

```
EMIC:tag(driverName = Persistence)

/**
* @fn void Persistence_saveVar(void);
* @alias persistence.saveVar
* @brief Guarda todas las variables de usuario en almacenamiento no-volatil
*/

/**
* @fn void Persistence_loadVar(void);
* @alias persistence.loadVar
* @brief Restaura todas las variables de usuario desde almacenamiento
*/

/**
* @fn void Persistence_saveKey(char* key, char* value);
* @alias persistence.saveKey
* @brief Guarda un par clave-valor individual
* @param key Nombre de la variable
* @param value Valor a guardar
*/

/**
* @fn char* Persistence_loadKey(char* key);
* @alias persistence.loadKey
* @brief Lee un valor individual por clave
* @param key Nombre de la variable a leer
*/

/**
* @fn extern void Persistence_onLoaded(void);
* @alias persistence.onLoaded
* @brief Evento: se dispara cuando loadVar() completa la carga
*/

EMIC:copy(src/persistence.js > TARGET:persistence.js)
EMIC:define(js_modules.persistence, persistence)
```

**Implementacion clave:**

```javascript
class Persistence {
    constructor(storage) { this._storage = storage; this._namespace = 'emic_'; }
    saveVar()          { /* serializa todo el StateManager a storage */ }
    loadVar()          { /* restaura desde storage al StateManager, dispara onLoaded */ }
    saveKey(key, val)  { this._storage.setItem(this._namespace + key, JSON.stringify(val)); }
    loadKey(key)       { const r = this._storage.getItem(this._namespace + key);
                         return r ? JSON.parse(r) : null; }
}
export const persistence = new Persistence(localStorage);
```

---

## 7. DataStreams (Observable, Browser I/O)

Flujo de datos basado en el patron Observable. Equivalente web de `streamIn_t` / `streamOut_t`.

| Embebido | Dashboard | Operacion |
|----------|-----------|-----------|
| `streamOut.put(c)` | `stream.emit(value)` | Escribir dato |
| `streamIn.get()` | `stream.subscribe(handler)` | Leer dato |
| `streamIn.count()` | `stream.getCount()` | Datos disponibles |

```javascript
class DataStream {
    constructor(name) { this._subscribers = new Set(); this._buffer = []; }
    emit(value) {
        this._buffer.push(value);
        this._subscribers.forEach(h => h(value));
    }
    subscribe(handler) {
        this._subscribers.add(handler);
        return () => this._subscribers.delete(handler);
    }
    getCount() { return this._buffer.length; }
    pipe(fn)   { /* retorna nuevo DataStream con transformacion encadenada */ }
    filter(fn) { return this.pipe(v => fn(v) ? v : undefined); }
    map(fn)    { return this.pipe(fn); }
}
export function createStream(name) { return new DataStream(name); }
```

**Ejemplo con pipe/filter:**

```javascript
const tempStream = createStream('temperature');
const alertStream = tempStream
    .filter(t => t > 50)
    .map(t => ({ alert: true, temp: t }));

alertStream.subscribe(a => console.log(`ALERTA: ${a.temp}`));
tempStream.emit(23.5);   // Solo tempStream
tempStream.emit(55.0);   // Ambos: tempStream + alertStream
```

---

## 8. Tabla de Equivalencias Embebido vs Dashboard

### 8.1 Componentes

| Dashboard | Embebido | Descripcion |
|-----------|----------|-------------|
| **DashboardCore** | *(no equivalente)* | Cargador dinamico de componentes |
| **EmicComponentBase** | *(no equivalente)* | Clase base HTMLElement para widgets |
| **EventBus** | Bus I2C / SPI | Comunicacion desacoplada entre componentes |
| **StateManager** | Variables globales (`volatile`) | Estado compartido con notificacion |
| **Persistence** | EEPROM | Almacenamiento no-volatil |
| **DataStream** | Stream (`streamIn_t`/`streamOut_t`) | Flujo de datos I/O |

### 8.2 Operaciones

| Operacion | Embebido | Dashboard |
|-----------|----------|-----------|
| Inicializar motor | `initSystem()` | `DashboardCore.init()` |
| Inicializar componente | `inits.*()` | `connectedCallback()` |
| Actualizar ciclicamente | `polls.*()` | `requestAnimationFrame` / eventos |
| Enviar dato | `streamOut.put(c)` | `dataStream.emit(value)` |
| Recibir dato | `streamIn.get()` | `dataStream.subscribe(handler)` |
| Leer estado | `g_variable` | `stateManager.getState(key)` |
| Escribir estado | `g_variable = val` | `stateManager.setState(key, val)` |
| Guardar no-volatil | `EEPROM_write(addr, val)` | `persistence.saveKey(key, val)` |
| Leer no-volatil | `EEPROM_read(addr)` | `persistence.loadKey(key)` |
| Inter-modulo | Interrupcion / callback | `eventBus.emit()` / `.on()` |
| Limpiar recursos | *(reset)* | `disconnectedCallback()` |

### 8.3 Patrones

| Patron | Embebido | Dashboard |
|--------|----------|-----------|
| Polling | `while(1) { polls.*(); }` | `setInterval` / `requestAnimationFrame` |
| Interrupcion | ISR -> flag -> poll | `eventBus.emit()` -> handler |
| Buffer circular | FIFO en RAM | `DataStream._buffer[]` |
| Conversion tipos | `uint16_t_to_ascii()` | `JSON.stringify()` / `JSON.parse()` |
| Include guard | `EMIC:ifndef _X_EMIC_` | Singleton pattern (export unico) |
| Registro en main | `EMIC:define(inits.x, x_init)` | `customElements.define('tag', Class)` |

---

## Resumen

| Concepto | Descripcion |
|----------|-------------|
| **_system/** | Servicios core: carga, eventos, estado, persistencia, streams |
| **DashboardCore** | Registro y carga dinamica de WebComponents |
| **EmicComponentBase** | Clase base con lifecycle, EventBus, State y Streams integrados |
| **EventBus** | Pub/sub desacoplado (analogia: bus I2C/SPI) |
| **StateManager** | Estado reactivo global (analogia: variables globales) |
| **Persistence** | Almacenamiento no-volatil via HAL Storage (analogia: EEPROM) |
| **DataStream** | Observable con pipe/filter/map (analogia: streamIn/streamOut) |

---

**Nota:** `_system/` del Dashboard mantiene la misma filosofia que su contraparte embebida: servicios centralizados que las capas superiores utilizan. La diferencia es el medio -- donde el embebido opera sobre registros de hardware y buses fisicos, el Dashboard opera sobre el DOM, eventos JavaScript y almacenamiento del navegador. La arquitectura por capas y la regla de dependencia descendente se mantienen identicas.
