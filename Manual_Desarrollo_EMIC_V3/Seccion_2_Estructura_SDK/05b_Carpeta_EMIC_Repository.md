# Capítulo 05b: Carpeta `.emic` y Archivo `repository.json`

[← Anterior: Visión General SDK](05_Vision_General_SDK.md) | [Siguiente: Carpeta _modules →](06_Carpeta_Modules.md)

---

## 📋 Contenido del Capítulo

1. [Introducción](#1-introducción)
2. [Estructura de la Carpeta .emic](#2-estructura-de-la-carpeta-emic)
3. [Archivo repository.json](#3-archivo-repositoryjson)
4. [Campos Obligatorios](#4-campos-obligatorios)
5. [Campos Opcionales y Extensiones](#5-campos-opcionales-y-extensiones)
6. [Casos de Uso](#6-casos-de-uso)
7. [Validación del Repositorio](#7-validación-del-repositorio)
8. [Ejemplos Completos](#8-ejemplos-completos)

---

## 1. Introducción

### 1.1 ¿Por qué es Necesaria la Carpeta `.emic`?

La carpeta `.emic` es un **directorio de metadatos** obligatorio que debe existir en la raíz de cada EMIC SDK. Esta carpeta permite al sistema EMIC:

- **Identificar** el repositorio como un SDK válido
- **Indexar** el repositorio en el catálogo de SDKs disponibles
- **Mostrar** información descriptiva en interfaces de usuario (EMIC-Editor, CLI, Web)
- **Filtrar** repositorios por tags, autor, tipo, etc.
- **Gestionar** dependencias entre repositorios

```
┌─────────────────────────────────────────────────────────┐
│  ⚠️ IMPORTANTE                                          │
│                                                          │
│  Sin la carpeta .emic y el archivo repository.json,     │
│  el sistema EMIC NO reconocerá el directorio como       │
│  un SDK válido y no podrá indexarlo ni mostrarlo        │
│  en las interfaces de usuario.                          │
└─────────────────────────────────────────────────────────┘
```

### 1.2 Convención del Punto Inicial

El nombre `.emic` comienza con un punto (`.`) siguiendo la convención de Unix/Linux para directorios ocultos de configuración:

| Convención | Ejemplos | Propósito |
|------------|----------|-----------|
| **Directorios ocultos** | `.git`, `.vscode`, `.emic` | Configuración del proyecto |
| **Archivos de config** | `.gitignore`, `.eslintrc` | Configuración de herramientas |

> **📌 Nota:** En Windows, las carpetas que comienzan con punto no se ocultan automáticamente, pero la convención se mantiene por compatibilidad multiplataforma.

---

## 2. Estructura de la Carpeta .emic

### 2.1 Estructura Mínima

```
EMIC_SDK/
├── .emic/                          ← Carpeta de metadatos (OBLIGATORIA)
│   └── repository.json             ← Descriptor del repositorio (OBLIGATORIO)
├── _api/
├── _drivers/
├── _hal/
├── _hard/
├── _modules/
└── ...
```

### 2.2 Estructura Extendida (Futuro)

La carpeta `.emic` está diseñada para contener metadatos adicionales en el futuro:

```
.emic/
├── repository.json                 ← Descriptor principal (obligatorio)
├── dependencies.json               ← Dependencias entre SDKs (futuro)
├── changelog.json                  ← Historial de cambios (futuro)
├── contributors.json               ← Lista de contribuidores (futuro)
├── assets/                         ← Recursos visuales (futuro)
│   ├── logo.png                    ← Logo del SDK
│   ├── banner.png                  ← Banner para catálogo
│   └── screenshots/                ← Capturas de pantalla
└── schemas/                        ← Esquemas de validación (futuro)
    └── module.schema.json          ← Esquema para validar módulos
```

---

## 3. Archivo repository.json

### 3.1 Propósito

El archivo `repository.json` es el **descriptor principal** del SDK. Contiene metadatos que permiten:

1. **Identificación**: Nombre único y descripción del SDK
2. **Clasificación**: Tipo de repositorio y tags de búsqueda
3. **Autoría**: Información del autor y licencia
4. **Trazabilidad**: Fecha de creación y versión

### 3.2 Formato

El archivo debe ser un JSON válido con codificación UTF-8.

```json
{
  "name": "NOMBRE_DEL_SDK",
  "description": "Descripción completa del SDK...",
  "type": "SDK",
  "tags": ["tag1", "tag2", "tag3"],
  "created": "2026-01-01T00:00:00.0000000Z",
  "author": "Nombre del Autor",
  "email": "autor@ejemplo.com",
  "company": "Nombre de la Empresa",
  "license": "Proprietary"
}
```

---

## 4. Campos Obligatorios

### 4.1 `name` (string)

**Propósito**: Identificador único del SDK.

**Reglas**:
- Debe coincidir con el nombre del directorio raíz del SDK
- Solo caracteres alfanuméricos, guiones (`-`) y guiones bajos (`_`)
- Sin espacios
- Case-sensitive

**Uso potencial**:
- Identificación en el catálogo de SDKs
- Referencia en dependencias entre SDKs
- Nombre mostrado en EMIC-Editor

```json
"name": "EMIC-ESP-IDF"
```

---

### 4.2 `description` (string)

**Propósito**: Descripción detallada del SDK y su propósito.

**Reglas**:
- Máximo recomendado: 500 caracteres
- Debe describir claramente el alcance del SDK
- Incluir palabras clave relevantes para búsqueda

**Uso potencial**:
- Tooltip en interfaces gráficas
- Descripción en catálogo de SDKs
- Resultados de búsqueda

```json
"description": "Repositorio EMIC adaptado para microcontroladores ESP32 de Espressif compilado con ESP-IDF. Incluye módulos, drivers, APIs y HAL para aplicaciones IoT, WiFi, Bluetooth, automatización y sistemas embebidos."
```

---

### 4.3 `type` (string)

**Propósito**: Clasificación del tipo de repositorio.

**Valores válidos**:

| Valor | Descripción |
|-------|-------------|
| `"SDK"` | Software Development Kit completo |
| `"Library"` | Biblioteca de componentes (solo APIs/Drivers) |
| `"Module"` | Módulo individual exportado |
| `"Template"` | Plantilla de proyecto |
| `"Extension"` | Extensión para otro SDK |

**Uso potencial**:
- Filtrado en catálogo por tipo
- Validación de estructura según tipo
- Iconos diferenciados en UI

```json
"type": "SDK"
```

---

### 4.4 `tags` (array of strings)

**Propósito**: Palabras clave para clasificación y búsqueda.

**Reglas**:
- Mínimo recomendado: 5 tags
- Máximo recomendado: 25 tags
- Lowercase preferido
- Sin espacios (usar guiones)

**Categorías sugeridas de tags**:

| Categoría | Ejemplos |
|-----------|----------|
| **MCU/Plataforma** | `esp32`, `pic24`, `stm32`, `arduino` |
| **Conectividad** | `wifi`, `bluetooth`, `ble`, `lora`, `zigbee` |
| **Aplicación** | `iot`, `industrial`, `home-automation` |
| **Periféricos** | `gpio`, `adc`, `uart`, `spi`, `i2c` |
| **Framework** | `esp-idf`, `freertos`, `cmsis` |
| **Industria** | `oil-gas`, `agriculture`, `automotive` |

**Uso potencial**:
- Búsqueda por palabras clave
- Filtrado en catálogo
- Sugerencias de SDKs relacionados
- Nube de tags en UI

```json
"tags": [
  "esp32",
  "esp-idf",
  "espressif",
  "iot",
  "wifi",
  "bluetooth",
  "ble",
  "freertos",
  "automatizacion",
  "sensores",
  "actuadores",
  "gpio",
  "comunicacion",
  "embedded",
  "industrial"
]
```

---

### 4.5 `created` (string - ISO 8601)

**Propósito**: Fecha de creación del SDK.

**Formato**: ISO 8601 con zona horaria
```
YYYY-MM-DDTHH:MM:SS.fffffffZ
```

**Uso potencial**:
- Ordenamiento por antigüedad
- Histórico de versiones
- Auditoría

```json
"created": "2026-02-02T00:00:00.0000000Z"
```

---

### 4.6 `author` (string)

**Propósito**: Nombre del autor o mantenedor principal.

**Uso potencial**:
- Créditos en UI
- Filtrado por autor
- Contacto para soporte

```json
"author": "Mariano Hunkeler"
```

---

### 4.7 `email` (string)

**Propósito**: Email de contacto del autor.

**Uso potencial**:
- Reporte de bugs
- Contacto para contribuciones
- Notificaciones de actualizaciones

```json
"email": "mariano.hunkeler@rfindustrial.com"
```

---

### 4.8 `company` (string)

**Propósito**: Organización o empresa propietaria/mantenedora.

**Uso potencial**:
- Filtrado por empresa
- Branding en catálogo
- Licenciamiento

```json
"company": "RF Industrial"
```

---

### 4.9 `license` (string)

**Propósito**: Tipo de licencia del SDK.

**Valores comunes**:

| Valor | Descripción |
|-------|-------------|
| `"Proprietary"` | Software propietario, todos los derechos reservados |
| `"MIT"` | Licencia MIT (permisiva) |
| `"Apache-2.0"` | Licencia Apache 2.0 |
| `"GPL-3.0"` | GNU General Public License v3 |
| `"BSD-3-Clause"` | Licencia BSD de 3 cláusulas |
| `"LGPL-3.0"` | GNU Lesser General Public License v3 |
| `"CC-BY-4.0"` | Creative Commons Attribution 4.0 |

**Uso potencial**:
- Filtrado por licencia
- Advertencias de compatibilidad
- Validación de uso en proyectos comerciales

```json
"license": "Proprietary"
```

---

## 5. Campos Opcionales y Extensiones

### 5.1 Campos Opcionales Sugeridos

Los siguientes campos no son obligatorios actualmente pero se recomienda incluirlos para mayor compatibilidad futura:

```json
{
  "name": "EMIC-ESP-IDF",
  "description": "...",
  "type": "SDK",
  "tags": ["..."],
  "created": "2026-02-02T00:00:00.0000000Z",
  "author": "Mariano Hunkeler",
  "email": "mariano.hunkeler@rfindustrial.com",
  "company": "RF Industrial",
  "license": "Proprietary",

  // ═══════════════════════════════════════════════════
  // CAMPOS OPCIONALES (uso potencial futuro)
  // ═══════════════════════════════════════════════════

  "version": "1.0.0",
  "minEmicVersion": "4.0.0",
  "homepage": "https://github.com/empresa/emic-esp-idf",
  "repository": "https://github.com/empresa/emic-esp-idf.git",
  "documentation": "https://docs.empresa.com/emic-esp-idf",
  "icon": "assets/icon.png",
  "banner": "assets/banner.png",
  "updated": "2026-02-02T00:00:00.0000000Z",
  "deprecated": false,
  "deprecationMessage": "",
  "keywords": ["alternativa", "a", "tags"],
  "contributors": [
    {
      "name": "Colaborador 1",
      "email": "colab1@ejemplo.com",
      "role": "developer"
    }
  ],
  "funding": {
    "type": "github",
    "url": "https://github.com/sponsors/empresa"
  },
  "bugs": {
    "url": "https://github.com/empresa/emic-esp-idf/issues",
    "email": "bugs@empresa.com"
  },
  "platforms": ["esp32", "esp32-s2", "esp32-s3", "esp32-c3"],
  "frameworks": ["esp-idf"],
  "compilers": ["xtensa-esp32-elf-gcc"],
  "dependencies": {
    "EMIC_Core": ">=1.0.0"
  },
  "devDependencies": {
    "EMIC_TestFramework": ">=1.0.0"
  }
}
```

### 5.2 Descripción de Campos Opcionales

| Campo | Tipo | Uso Potencial |
|-------|------|---------------|
| `version` | string (semver) | Versionado semántico del SDK |
| `minEmicVersion` | string | Versión mínima de EMIC requerida |
| `homepage` | URL | Página web del proyecto |
| `repository` | URL | Repositorio de código fuente |
| `documentation` | URL | Documentación online |
| `icon` | path | Icono del SDK (32x32 o 64x64) |
| `banner` | path | Banner para catálogo (800x200) |
| `updated` | ISO 8601 | Última fecha de actualización |
| `deprecated` | boolean | Indica si el SDK está deprecado |
| `deprecationMessage` | string | Mensaje de deprecación |
| `contributors` | array | Lista de contribuidores |
| `funding` | object | Información de financiamiento |
| `bugs` | object | Información para reportar bugs |
| `platforms` | array | Plataformas soportadas |
| `frameworks` | array | Frameworks compatibles |
| `compilers` | array | Compiladores soportados |
| `dependencies` | object | SDKs requeridos |
| `devDependencies` | object | SDKs para desarrollo |

---

## 6. Casos de Uso

### 6.1 Indexación en Catálogo

```
┌─────────────────────────────────────────────────────────┐
│  EMIC SDK Catalog                                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  🔍 Buscar: [esp32________]  [Tipo: SDK ▼]  [Buscar]   │
│                                                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │ 📦 EMIC-ESP-IDF                                 │    │
│  │    Repositorio EMIC para ESP32 con ESP-IDF...   │    │
│  │    Tags: esp32, wifi, bluetooth, iot            │    │
│  │    Autor: Mariano Hunkeler | RF Industrial      │    │
│  │    Licencia: Proprietary                        │    │
│  └─────────────────────────────────────────────────┘    │
│                                                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │ 📦 EMIC_IA_M                                    │    │
│  │    Repositorio principal para PIC24...          │    │
│  │    Tags: pic24, microchip, industrial           │    │
│  │    Autor: Mariano Hunkeler | RF Industrial      │    │
│  │    Licencia: Proprietary                        │    │
│  └─────────────────────────────────────────────────┘    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### 6.2 Selección de SDK en EMIC-Editor

```
┌─────────────────────────────────────────────────────────┐
│  Nuevo Proyecto - Seleccionar SDK                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  SDKs Disponibles:                                       │
│                                                          │
│  ○ EMIC_IA_M                                            │
│    PIC24 | Microchip | Industrial                        │
│                                                          │
│  ● EMIC-ESP-IDF                        ← Seleccionado   │
│    ESP32 | Espressif | IoT, WiFi, BLE                   │
│                                                          │
│  ○ EMIC-STM32                                           │
│    STM32 | ARM Cortex-M | Industrial                    │
│                                                          │
│  [Cancelar]                              [Siguiente →]  │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### 6.3 Gestión de Dependencias

```
┌─────────────────────────────────────────────────────────┐
│  Dependencias del Proyecto                               │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  SDK Principal: EMIC-ESP-IDF v1.0.0                     │
│                                                          │
│  Dependencias:                                           │
│  ├── EMIC_Core v1.0.0          ✅ Instalado            │
│  └── EMIC_WiFi_Stack v2.1.0    ⚠️ Requiere descarga    │
│                                                          │
│  [Resolver Dependencias]                                 │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## 7. Validación del Repositorio

### 7.1 Checklist de Validación

Para que un repositorio sea reconocido como SDK válido:

```
✅ Existe la carpeta .emic/ en la raíz
✅ Existe el archivo .emic/repository.json
✅ El archivo JSON es sintácticamente válido
✅ Contiene todos los campos obligatorios:
   ✅ name (string, no vacío)
   ✅ description (string, no vacío)
   ✅ type (string, valor válido)
   ✅ tags (array, al menos 1 elemento)
   ✅ created (string, formato ISO 8601)
   ✅ author (string, no vacío)
   ✅ email (string, formato email válido)
   ✅ company (string, no vacío)
   ✅ license (string, no vacío)
```

### 7.2 Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| SDK no aparece en catálogo | Falta `.emic/repository.json` | Crear el archivo |
| "Invalid JSON" | Sintaxis JSON incorrecta | Validar JSON online |
| "Missing required field" | Campo obligatorio ausente | Agregar campo faltante |
| "Invalid date format" | Formato de fecha incorrecto | Usar ISO 8601 |
| "Invalid email format" | Email mal formado | Corregir formato email |

### 7.3 Herramienta de Validación (Futuro)

```bash
# Comando futuro para validar repositorio
emic validate-sdk ./EMIC-ESP-IDF

# Salida esperada:
✅ .emic/repository.json found
✅ JSON syntax valid
✅ All required fields present
✅ Field types valid
✅ SDK is valid and ready for indexing
```

---

## 8. Ejemplos Completos

### 8.1 SDK para ESP32 (ESP-IDF)

```json
{
  "name": "EMIC-ESP-IDF",
  "description": "Repositorio EMIC adaptado para microcontroladores ESP32 de Espressif compilado con ESP-IDF. Incluye módulos, drivers, APIs y HAL para aplicaciones IoT, WiFi, Bluetooth, automatización y sistemas embebidos.",
  "type": "SDK",
  "tags": [
    "esp32",
    "esp-idf",
    "espressif",
    "iot",
    "wifi",
    "bluetooth",
    "ble",
    "freertos",
    "automatizacion",
    "sensores",
    "actuadores",
    "gpio",
    "comunicacion",
    "embedded",
    "industrial",
    "home-automation",
    "wearables",
    "wireless"
  ],
  "created": "2026-02-02T00:00:00.0000000Z",
  "author": "Mariano Hunkeler",
  "email": "mariano.hunkeler@rfindustrial.com",
  "company": "RF Industrial",
  "license": "Proprietary"
}
```

### 8.2 SDK para PIC24 (Microchip)

```json
{
  "name": "EMIC_IA_M",
  "description": "Repositorio principal de EMIC con módulos, drivers, APIs y HAL para microcontroladores PIC24 de Microchip. Incluye componentes para IoT, automatización industrial, sensores, actuadores, comunicaciones y sistemas de control.",
  "type": "SDK",
  "tags": [
    "pic24",
    "microchip",
    "iot",
    "automatizacion",
    "sensores",
    "actuadores",
    "comunicacion",
    "i2c",
    "usb",
    "displays",
    "adc",
    "power-supply",
    "oil-gas",
    "indoor-crops",
    "tecnocrom",
    "wireless",
    "wired",
    "storage",
    "industrial"
  ],
  "created": "2024-01-01T00:00:00.0000000Z",
  "author": "Mariano Hunkeler",
  "email": "mariano.hunkeler@rfindustrial.com",
  "company": "RF Industrial",
  "license": "Proprietary"
}
```

### 8.3 Biblioteca de Componentes (Library)

```json
{
  "name": "EMIC-Sensors-Library",
  "description": "Biblioteca de drivers para sensores comunes: temperatura, humedad, presión, acelerómetros, giroscopios. Compatible con múltiples SDKs EMIC.",
  "type": "Library",
  "tags": [
    "sensors",
    "temperature",
    "humidity",
    "pressure",
    "accelerometer",
    "gyroscope",
    "i2c",
    "spi",
    "portable"
  ],
  "created": "2025-06-15T00:00:00.0000000Z",
  "author": "EMIC Community",
  "email": "community@emic.dev",
  "company": "EMIC Open Source",
  "license": "MIT"
}
```

---

## 🎯 Puntos Clave del Capítulo

| Concepto | Explicación |
|----------|-------------|
| **Carpeta `.emic`** | Directorio obligatorio de metadatos en la raíz del SDK |
| **`repository.json`** | Archivo descriptor principal con información del SDK |
| **9 campos obligatorios** | name, description, type, tags, created, author, email, company, license |
| **Uso principal** | Indexación, búsqueda, filtrado y visualización en UI |
| **Campos opcionales** | version, homepage, repository, dependencies, etc. |
| **Validación** | JSON válido + todos los campos obligatorios presentes |

---

## ✅ Checklist de Comprensión

Antes de continuar, asegúrate de entender:

- [ ] Por qué es necesaria la carpeta `.emic`
- [ ] El propósito del archivo `repository.json`
- [ ] Los 9 campos obligatorios y su formato
- [ ] Los valores válidos para el campo `type`
- [ ] Cómo estructurar los tags para mejor búsqueda
- [ ] Los campos opcionales disponibles para el futuro
- [ ] Los casos de uso (catálogo, selección, dependencias)

---

[← Anterior: Visión General SDK](05_Vision_General_SDK.md) | [Siguiente: Carpeta _modules →](06_Carpeta_Modules.md)

---

*Capítulo 05b - Manual de Desarrollo EMIC SDK v1.0*
*Última actualización: Febrero 2026*
