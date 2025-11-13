# Guía de Versionado con Git - Manual para Desarrolladores EMIC

**Fecha:** 2025-11-13
**Versión:** 1.0

---

## 🎯 Objetivo

Versionar el **Manual para Desarrolladores EMIC** de forma **independiente** del SDK principal, permitiendo:

- Releases independientes del manual
- Historial de cambios específico de la documentación
- Colaboración enfocada en documentación
- Posibilidad de publicar el manual en GitHub Pages

---

## 📋 Opción Recomendada: Git Submodule

### Estructura Propuesta

```
EMIC_IA_M/                          # Repositorio principal del SDK
├── _api/
├── _drivers/
├── _modules/
├── _hal/
├── _hard/
├── ...
├── Manual_para_desarrolladores/    # Submódulo → repo independiente
│   ├── Manual_Desarrollo_EMIC/
│   ├── PLAN_MAESTRO_DESARROLLADORES_V2.md
│   └── README.md
└── Manual_para_Integradores/        # Submódulo → repo independiente
    ├── Manual_Desarrollo_EMIC/
    ├── PLAN_MAESTRO_MANUAL_DESARROLLO_EMIC.md
    └── README.md
```

---

## 🚀 Paso a Paso: Implementación

### **Paso 1: Crear Repositorio del Manual en GitHub**

1. Ir a GitHub y crear nuevo repositorio:
   - Nombre: `emic-manual-desarrolladores`
   - Descripción: "Manual completo para desarrolladores de recursos EMIC SDK"
   - Visibilidad: Público o Privado (según necesidad)
   - ✅ Agregar README.md
   - ✅ Agregar .gitignore (ninguno o "None")
   - ✅ Agregar licencia (MIT, Apache, etc.)

2. URL resultante:
   ```
   https://github.com/EMIC-Team/emic-manual-desarrolladores.git
   ```

---

### **Paso 2: Inicializar Git en la Carpeta del Manual**

```bash
# Navegar a la carpeta del manual
cd "C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_para_desarrolladores"

# Inicializar repositorio git
git init

# Agregar remote al repositorio creado
git remote add origin https://github.com/EMIC-Team/emic-manual-desarrolladores.git

# Agregar todos los archivos
git add .

# Commit inicial
git commit -m "Initial commit: Manual para Desarrolladores EMIC v2.0"

# Push al repositorio remoto
git push -u origin main
```

---

### **Paso 3: Convertir la Carpeta en Submódulo del SDK**

```bash
# Navegar al repositorio principal del SDK
cd "C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M"

# IMPORTANTE: Primero eliminar la carpeta actual (hacer backup si no está commiteada)
# El submódulo la reemplazará
mv Manual_para_desarrolladores Manual_para_desarrolladores_backup

# Agregar como submódulo
git submodule add https://github.com/EMIC-Team/emic-manual-desarrolladores.git Manual_para_desarrolladores

# Git creará automáticamente:
# - .gitmodules (archivo de configuración)
# - Manual_para_desarrolladores/ (clonado del repo remoto)

# Commit del submódulo
git add .gitmodules Manual_para_desarrolladores
git commit -m "Add Manual para Desarrolladores as git submodule"
git push
```

---

### **Paso 4: Trabajar con el Submódulo**

#### **A) Clonar el SDK con el Submódulo (Para otros desarrolladores)**

```bash
# Clonar el SDK
git clone https://github.com/EMIC-Team/emic-sdk.git
cd emic-sdk

# Inicializar y actualizar submódulos
git submodule init
git submodule update

# O todo en un comando:
git clone --recurse-submodules https://github.com/EMIC-Team/emic-sdk.git
```

---

#### **B) Actualizar el Manual (Hacer cambios)**

```bash
# Entrar al submódulo
cd "C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M\Manual_para_desarrolladores"

# El submódulo es un repositorio git normal
git status

# Agregar cambios
git add .

# Commit
git commit -m "docs: Update Cap 21 - Desarrollo de API"

# Push al repositorio del manual
git push origin main
```

---

#### **C) Actualizar el SDK para Apuntar a la Nueva Versión del Manual**

```bash
# Volver al repositorio principal
cd "C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M"

# Actualizar referencia del submódulo
git add Manual_para_desarrolladores

# Commit en el SDK
git commit -m "chore: Update Manual para Desarrolladores to latest version"
git push
```

---

#### **D) Obtener Última Versión del Manual**

```bash
# Desde el repositorio del SDK
cd "C:\Users\franc\Dropbox\EMIC\DevCommunity\mariano.hunkeler@rfindustrial.com\DEV\EMIC_IA_M"

# Actualizar todos los submódulos
git submodule update --remote --merge

# O específicamente el manual
cd Manual_para_desarrolladores
git pull origin main
```

---

### **Paso 5: Hacer lo Mismo con Manual para Integradores (Opcional)**

```bash
# Crear repo: emic-manual-integradores
# Repetir pasos 2-4 para Manual_para_Integradores/
```

---

## 📦 Gestión de Releases

### **A) Releases del Manual**

```bash
# En el repositorio del manual
cd Manual_para_desarrolladores

# Crear tag de versión
git tag -a v1.0.0 -m "Release 1.0.0: Manual completo 38 capítulos"
git push origin v1.0.0

# En GitHub, crear Release desde el tag
# https://github.com/EMIC-Team/emic-manual-desarrolladores/releases
```

### **B) Releases del SDK apuntando a Versión Específica del Manual**

```bash
# En el SDK, apuntar a tag específico del manual
cd Manual_para_desarrolladores
git checkout v1.0.0

cd ..
git add Manual_para_desarrolladores
git commit -m "chore: Pin Manual para Desarrolladores to v1.0.0"
git push
```

---

## 🔧 Comandos Útiles

### Ver Estado de Submódulos

```bash
git submodule status
```

### Actualizar Todos los Submódulos

```bash
git submodule update --init --recursive
```

### Ejecutar Comando en Todos los Submódulos

```bash
git submodule foreach 'git pull origin main'
```

### Ver Diferencias en Submódulos

```bash
git diff --submodule
```

### Remover Submódulo (si es necesario)

```bash
# 1. Eliminar entrada en .gitmodules
# 2. Eliminar entrada en .git/config
# 3. Remover carpeta
git rm --cached Manual_para_desarrolladores
rm -rf Manual_para_desarrolladores
rm -rf .git/modules/Manual_para_desarrolladores
git commit -m "Remove submodule"
```

---

## 📋 Archivo .gitmodules (Generado Automáticamente)

```ini
[submodule "Manual_para_desarrolladores"]
    path = Manual_para_desarrolladores
    url = https://github.com/EMIC-Team/emic-manual-desarrolladores.git
    branch = main

[submodule "Manual_para_Integradores"]
    path = Manual_para_Integradores
    url = https://github.com/EMIC-Team/emic-manual-integradores.git
    branch = main
```

---

## 🌐 Publicar Manual en GitHub Pages (Opcional)

### Configurar GitHub Pages para el Manual

1. En el repositorio del manual, ir a **Settings → Pages**
2. Seleccionar **Source**: Deploy from a branch
3. Seleccionar **Branch**: `main`, carpeta `/` o `/docs`
4. Guardar

El manual estará disponible en:
```
https://emic-team.github.io/emic-manual-desarrolladores/
```

### Mejorar con MkDocs (Opcional)

```bash
# Instalar MkDocs
pip install mkdocs mkdocs-material

# Crear configuración
# Archivo: mkdocs.yml
site_name: Manual para Desarrolladores EMIC
theme:
  name: material
nav:
  - Inicio: index.md
  - Sección 1 Introducción:
    - 00 Portada: Seccion_1_Introduccion/00_Portada.md
    - 01 Introducción: Seccion_1_Introduccion/01_Introduccion.md
    # ... más secciones

# Servir localmente
mkdocs serve

# Publicar a GitHub Pages
mkdocs gh-deploy
```

---

## ✅ Ventajas de este Enfoque

1. **Versionado Independiente**
   - Manual v1.0 puede corresponder a SDK v2.5
   - Releases del manual no dependen del SDK

2. **Historial Limpio**
   - Commits del manual separados del SDK
   - Fácil ver evolución de la documentación

3. **Colaboración Específica**
   - Gente puede contribuir solo al manual
   - Issues/PRs específicos de documentación

4. **CI/CD Independiente**
   - GitHub Actions para validar markdown
   - Publicación automática a GitHub Pages
   - Tests de enlaces rotos

5. **Reutilización**
   - Otros proyectos pueden usar el manual como submódulo
   - Forks independientes del manual

---

## 🚨 Consideraciones Importantes

### Para Desarrolladores Nuevos

```bash
# Documentar en README.md del SDK:

# Clonar SDK con manuales
git clone --recurse-submodules https://github.com/EMIC-Team/emic-sdk.git

# Si ya clonaste sin --recurse-submodules:
git submodule update --init --recursive
```

### Para CI/CD

```yaml
# .github/workflows/build.yml
- name: Checkout with submodules
  uses: actions/checkout@v3
  with:
    submodules: recursive
```

---

## 📝 Flujo de Trabajo Recomendado

### Desarrollo del Manual

1. **Feature Branch en el Manual**
   ```bash
   cd Manual_para_desarrolladores
   git checkout -b feature/cap-21-mejoras
   # Editar archivos
   git add .
   git commit -m "docs: Improve Cap 21 examples"
   git push origin feature/cap-21-mejoras
   ```

2. **Pull Request** en GitHub del manual

3. **Review y Merge** a `main`

4. **Actualizar SDK** para apuntar a la nueva versión
   ```bash
   cd ..
   git submodule update --remote Manual_para_desarrolladores
   git add Manual_para_desarrolladores
   git commit -m "chore: Update manual to latest"
   git push
   ```

---

## 🎯 Resumen

| Aspecto | Con Submódulo | Sin Submódulo |
|---------|---------------|---------------|
| **Versionado** | Independiente | Mezclado con SDK |
| **Historial** | Limpio | Mezclado |
| **Releases** | Separados | Acoplados |
| **Colaboración** | Específica docs | Todo o nada |
| **Complejidad** | Media | Baja |
| **Flexibilidad** | Alta | Baja |

---

**Recomendación Final:** ✅ **Usar Git Submodule para ambos manuales**

---

**Fecha de Creación:** 2025-11-13
**Autor:** EMIC Development Team
**Versión:** 1.0
