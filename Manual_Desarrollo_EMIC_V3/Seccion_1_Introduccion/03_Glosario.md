# Capítulo 03: Glosario y Vocabulario EMIC

[← Anterior: Arquitectura](02_Arquitectura.md) | [Siguiente: Ventajas →](04_Ventajas_EMIC.md)

---

## 📋 Contenido del Capítulo

1. [Conceptos Fundamentales](#1-conceptos-fundamentales)
2. [Componentes del SDK](#2-componentes-del-sdk)
3. [Procesos y Herramientas](#3-procesos-y-herramientas)
4. [Términos de Archivos y Volúmenes](#4-términos-de-archivos-y-volúmenes)
5. [Acrónimos Comunes](#5-acrónimos-comunes)
6. [Términos del Dashboard SDK](#6-términos-del-dashboard-sdk)

---

## 1. Conceptos Fundamentales

Para navegar con éxito por el desarrollo en EMIC, es esencial dominar el siguiente vocabulario. Estos términos se utilizan extensivamente en toda la documentación y herramientas.

### EMIC (Ecosystem for Modular Integrated Creation)
Es el ecosistema completo que abarca una **metodología**, un **estándar** y un conjunto de **herramientas** para el desarrollo de sistemas embebidos. Su objetivo es transformar el código artesanal en bloques industriales reutilizables.

### Modularidad
El principio de diseño donde el sistema se divide en partes más pequeñas (módulos, drivers, APIs) que pueden ser creadas, modificadas o reemplazadas de forma independiente.

### Abstracción
La práctica de ocultar los detalles complejos de implementación (cómo funciona el hardware exacto) y exponer solo las operaciones necesarias (qué hace). EMIC utiliza múltiples capas de abstracción (HAL, Driver, API).

---

## 2. Componentes del SDK

### SDK (Software Development Kit)
La carpeta raíz que contiene todos los recursos de desarrollo. En EMIC, el SDK no es estático; evoluciona con las contribuciones de la comunidad. Es la "biblioteca maestra" de donde se extraen los componentes.

### Carpeta `.emic`
Directorio de metadatos **obligatorio** ubicado en la raíz de cada SDK. Contiene el archivo `repository.json` que identifica y describe el SDK. Sin esta carpeta, el sistema EMIC no reconocerá el directorio como un SDK válido.
*   *Ubicación:* `SDK_ROOT/.emic/`
*   *Contenido principal:* `repository.json`

### repository.json
Archivo descriptor principal del SDK ubicado en la carpeta `.emic/`. Define metadatos como nombre, descripción, tipo, tags de búsqueda, autor, licencia y fecha de creación. Este archivo permite al sistema indexar, buscar y mostrar el SDK en catálogos e interfaces de usuario.
*   *Ubicación:* `SDK_ROOT/.emic/repository.json`
*   *Formato:* JSON con campos obligatorios (name, description, type, tags, created, author, email, company, license)

### API (Application Programming Interface)
En el contexto EMIC, una API es una **librería de alto nivel** (ubicada en `_api/`) que encapsula lógica de negocio o funcionalidad abstracta.
*   *Ejemplo:* Una librería para controlar un LED RGB, o para gestionar un protocolo de comunicación complejo.
*   *Característica:* No accede directamente a registros del microcontrolador; usa Drivers o HAL.

### Driver (Controlador)
Un componente de software (ubicado en `_drivers/`) diseñado para controlar un periférico específico o un dispositivo de hardware externo.
*   *Ejemplo:* Driver para un sensor I2C, o para el controlador UART.
*   *Característica:* Gestiona la comunicación directa con el hardware, pero idealmente a través del HAL para mantener portabilidad.

### HAL (Hardware Abstraction Layer)
La Capa de Abstracción de Hardware (ubicada en `_hal/`). Es una interfaz unificada que estandariza el acceso a los periféricos del microcontrolador.
*   *Objetivo:* Que `GPIO_Write(PIN_A, 1)` funcione igual en un PIC18, un AVR o un ARM Cortex.
*   *Implementación:* Las funciones del HAL se traducen a código específico en la carpeta `_hard/`.

### Módulo (Module)
La unidad funcional más completa (ubicada en `_modules/`). Un Módulo empaqueta **Hardware** (diseño de PCB), **Firmware** (lógica + drivers necesarios) y **Configuración**.
*   *Uso:* Los integradores seleccionan "Módulos", no archivos sueltos.
*   *Ejemplo:* "Módulo Sensor de Temperatura" (incluye el PCB del sensor, el driver I2C y la API de lectura).

---

## 3. Procesos y Herramientas

### EMIC-Codify
El lenguaje de scripting especializado de EMIC. Se utiliza dentro de archivos `.emic` para controlar cómo se genera, copia y transforma el código C.
*   *Comandos típicos:* `EMIC:copy`, `EMIC:setInput`, `EMIC:define`.

### Tags (Etiquetas)
Anotaciones especiales en el código (estilo DOXYGEN o JSON) que permiten a las herramientas de EMIC "descubrir" y catalogar las funciones y variables.
*   *Ejemplo:* `@fn`, `@alias`, `@brief`.
*   *Función:* Hacen que tu código C sea visible en las herramientas visuales del integrador.

### Los 4 Procesos del Core
1.  **Discovery:** Escanea el SDK buscando Tags y crea un catálogo de recursos disponibles.
2.  **Transcriptor:** Convierte el diseño visual del integrador en un script lógico intermedio.
3.  **Merge (Generate):** Fusiona el script del integrador con el código fuente del desarrollador (usando EMIC-Codify) para producir código C estándar.
4.  **Compiler:** Invoca al compilador tradicional (XC8, XC16, GCC) para generar el binario final (.hex).

---

## 4. Términos de Archivos y Volúmenes

### Extensiones de Archivo
*   **`.c` / `.h`:** Archivos de código fuente C estándar.
*   **`.emic`:** Archivo que contiene instrucciones EMIC-Codify. Acompaña a los `.c` para indicar cómo deben procesarse.
*   **`.json`:** Usado para configuración (`config.json`) y metadata (`module.json`, `repository.json`, `m_description.json`).
*   **`.xml`:** Usado a veces para describir la estructura visual de un programa (`program.xml`).

### Volúmenes Lógicos
EMIC utiliza "unidades virtuales" para referirse a ubicaciones de archivos, independizando el código de la ruta absoluta en tu disco duro.

| Volumen | Significado | Ubicación Típica | Uso |
| :--- | :--- | :--- | :--- |
| **`DEV:`** | Developer | Raíz del SDK (`EMIC_SDK/`) | Donde vive tu código fuente original. |
| **`TARGET:`** | Target | Carpeta de salida (`Module/Target/`) | Donde se genera el código final para compilar. |
| **`SYS:`** | System | Carpeta de sistema del módulo (`Module/System/`) | Configuración y scripts locales. |
| **`USER:`** | User | Carpeta de usuario | Archivos propios del integrador. |

---

## 5. Acrónimos Comunes

| Acrónimo | Significado | Contexto EMIC |
| :--- | :--- | :--- |
| **MCU** | Microcontroller Unit | El chip cerebro (PIC, AVR, ARM). EMIC abstrae sus diferencias. |
| **GPIO** | General Purpose Input/Output | Pines digitales básicos. El HAL de GPIO es el más usado. |
| **I2C/SPI** | Protocolos de comunicación serie | Drivers comunes que conectan sensores y actuadores. |
| **UART** | Universal Asynchronous Receiver-Transmitter | Usado para debug y comunicación con PC. |
| **ADC** | Analog-to-Digital Converter | Lectura de sensores analógicos. |
| **PWM** | Pulse Width Modulation | Control de potencia (LEDs, Motores). |
| **ISR** | Interrupt Service Routine | Rutinas de interrupción. En EMIC, suelen estar en `_hard` o `_hal`. |
| **RTOS** | Real-Time Operating System | Sistema operativo tiempo real. EMIC puede correr sobre Baremetal o RTOS. |

---

## 6. Términos del Dashboard SDK

### Widget
Componente visual interactivo basado en WebComponents (ubicado en `_widgets/`). Equivalente a una API en el SDK embebido. Los widgets se arrastran al canvas del editor y muestran datos o permiten interacción del usuario.
*   *Ejemplo:* Gauge, LineChart, ToggleSwitch, DataTable
*   *Característica:* Hereda de EmicComponentBase, usa Shadow DOM, tiene tags DOXYGEN

### Connector (Conector)
Componente de acceso a servicios externos (ubicado en `_connectors/`). Equivalente a un Driver en el SDK embebido, pero CON tags DOXYGEN (a diferencia del embebido).
*   *Ejemplo:* mqtt-client, rest-client, firebase-realtime
*   *Característica:* Include guard obligatorio, no visual, aparece en Component Tray

### EventBus
Sistema de comunicación global entre componentes, análogo al bus I2C/SPI del mundo embebido. Permite que widgets y conectores se comuniquen de forma desacoplada mediante eventos con nombre.
*   *Métodos:* `emit(event, data)`, `on(event, handler)`

### StateManager
Gestor de estado reactivo global basado en Proxy de JavaScript. Permite compartir estado entre componentes con actualización automática.
*   *Métodos:* `getState(key)`, `setState(key, value)`

### EmicComponentBase
Clase base JavaScript que extiende HTMLElement. Todos los widgets heredan de esta clase que provee lifecycle hooks, integración con EventBus y StateManager.
*   *Equivalente embebido:* No tiene equivalente directo (el firmware no tiene clase base)

### DataStream
Abstracción de flujo de datos para el browser, equivalente a los Streams (`streamIn_t`/`streamOut_t`) del SDK embebido. Patrón Observable para I/O portable.

### Component Tray
Barra horizontal en el editor donde se colocan los servicios no-visuales (conectores, timers). Análogo al concepto de "Component Tray" de Visual Basic.

### Layout
Definición de posicionamiento y estructura visual del dashboard (ubicado en `_layouts/`). Equivalente a la definición de PCB (`_pcb/`) en el SDK embebido.
*   *Ejemplo:* dashboard-grid, sidebar-layout

### Theme (Tema)
Archivo CSS que define variables de estilo (colores, tipografía, bordes) mediante CSS custom properties. Los widgets leen estas variables para adaptarse al tema.
*   *Ejemplo:* dark-theme.css, industrial-theme.css

### Discovery Dual
Separación del proceso Discovery en dos archivos: `discovery.emic` (catálogo de templates con `_INSTANCE_`) y `generate.emic` (generación con foreach). Necesario porque los widgets se eligen interactivamente.

### _INSTANCE_ (Placeholder)
Marcador especial usado en `discovery.emic` como nombre de instancia temporal. El editor lo reemplaza client-side por el nombre real que elige el usuario (ej: "temperature", "broker1").

### Static Hosting (Hosting Estático)
Modelo de despliegue donde el dashboard se sirve como archivos estáticos sin procesamiento server-side. Compatible con GitHub Pages, Netlify, Vercel, S3.

### PWA (Progressive Web App)
Tecnología que permite al dashboard funcionar offline mediante Service Workers. El SDK incluye `sw.js` para cache y `manifest.json`.

### Persistence API
API simplificada de persistencia (`saveVar`/`loadVar`/`saveKey`/`loadKey`) que abstrae localStorage/IndexedDB. Equivalente a EEPROM read/write en el mundo embebido.

---
