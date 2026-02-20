# Manual de Desarrollo EMIC SDK
## Módulos y APIs

```
███████╗███╗   ███╗██╗ ██████╗    ███████╗██████╗ ██╗  ██╗
██╔════╝████╗ ████║██║██╔════╝    ██╔════╝██╔══██╗██║ ██╔╝
█████╗  ██╔████╔██║██║██║         ███████╗██║  ██║█████╔╝
██╔══╝  ██║╚██╔╝██║██║██║         ╚════██║██║  ██║██╔═██╗
███████╗██║ ╚═╝ ██║██║╚██████╗    ███████║██████╔╝██║  ██╗
╚══════╝╚═╝     ╚═╝╚═╝ ╚═════╝    ╚══════╝╚═════╝ ╚═╝  ╚═╝
```

### Guía Completa para Desarrolladores de Recursos EMIC

**Versión:** 1.0
**Fecha:** Noviembre 2025
**Autor:** EMIC Development Team

---

## 📖 Acerca de este Manual

Este manual está diseñado para **desarrolladores de recursos EMIC** que desean crear:
- APIs de alto nivel
- Drivers de hardware
- Módulos completos (Hardware + Firmware)
- Componentes reutilizables para la comunidad EMIC

---

## 👥 Audiencia Objetivo

Este manual es para ti si:

- ✅ Tienes conocimientos de **programación en C**
- ✅ Conoces **microcontroladores embebidos** (PIC, ARM, AVR, etc.)
- ✅ Entiendes conceptos de **sistemas embebidos**
- ✅ Quieres crear componentes **reutilizables y modulares**
- ✅ Deseas contribuir al **ecosistema EMIC**

**No necesitas:**
- ❌ Ser experto en GitHub (no se cubre la gestión de repositorios)
- ❌ Conocer todas las familias de microcontroladores
- ❌ Experiencia previa con EMIC (comenzamos desde cero)

---

## 🎯 Requisitos Previos

### Conocimientos Técnicos:
1. **Lenguaje C** (nivel intermedio)
2. **Sistemas embebidos** (conceptos básicos)
3. **Microcontroladores** (familiaridad con al menos una familia: PIC, ARM, AVR, etc.)
4. **Periféricos comunes** (UART, I2C, SPI, GPIO, ADC, etc.)

### Herramientas:
- Editor de texto (cualquiera)
- Compilador XC8/XC16/XC32 (Microchip)
- MPLAB X IDE (opcional pero recomendado)

---

## 📚 Estructura del Manual

Este manual está organizado en **7 secciones** con **38 capítulos**:

### **Sección 1: Introducción y Fundamentos** 📘
- [Cap 00 - Portada y Tabla de Contenidos](#tabla-de-contenidos) *(este documento)*
- [Cap 01 - Introducción al Desarrollo EMIC](01_Introduccion.md)
- [Cap 02 - Arquitectura y Conceptos Fundamentales](02_Arquitectura.md)
- [Cap 03 - Glosario y Vocabulario EMIC](03_Glosario.md)
- [Cap 04 - Ventajas de EMIC vs Otros Métodos](04_Ventajas.md)

### **Sección 2: Estructura del EMIC SDK** 📂
- [Cap 05 - Anatomía de un EMIC SDK (Visión General)](../Seccion_2_Estructura_SDK/05_Vision_General_SDK.md)
- [Cap 06 - Carpeta `_modules/` - Módulos Hardware + Firmware](../Seccion_2_Estructura_SDK/06_Carpeta_Modules.md)
- [Cap 07 - Carpeta `_api/` - APIs de Alto Nivel](../Seccion_2_Estructura_SDK/07_Carpeta_API.md)
- [Cap 08 - Carpeta `_drivers/` - Drivers de Hardware](../Seccion_2_Estructura_SDK/08_Carpeta_Drivers.md)
- [Cap 09 - Carpeta `_hal/` - Hardware Abstraction Layer](../Seccion_2_Estructura_SDK/09_Carpeta_HAL.md)
- [Cap 10 - Carpeta `_hard/` - Código Específico de MCU](../Seccion_2_Estructura_SDK/10_Carpeta_Hard.md)
- [Cap 11 - Carpeta `_main/` - Punto de Entrada](../Seccion_2_Estructura_SDK/11_Carpeta_Main.md)
- [Cap 12 - Carpeta `_pcb/` - Configuración de Hardware](../Seccion_2_Estructura_SDK/12_Carpeta_PCB.md)
- [Cap 13 - Carpeta `_templates/` - Templates de Proyectos](../Seccion_2_Estructura_SDK/13_Carpeta_Templates.md)
- [Cap 14 - Carpeta `_system/` - Sistema Core EMIC](../Seccion_2_Estructura_SDK/14_Carpeta_System.md)
- [Cap 15 - Carpeta `_util/` - Utilidades Generales](../Seccion_2_Estructura_SDK/15_Carpeta_Util.md)

### **Sección 3: EMIC-Codify para Desarrolladores** 💻
- [Cap 16 - Fundamentos de EMIC-Codify para Desarrollo](../Seccion_3_EMIC_Codify/16_Fundamentos_Codify_Desarrollo.md)
- [Cap 17 - Comandos de Gestión de Archivos y Recursos](../Seccion_3_EMIC_Codify/17_Comandos_Gestion_Archivos.md)
- [Cap 18 - Sistema de Macros y Sustitución](../Seccion_3_EMIC_Codify/18_Sistema_Macros_Sustitucion.md)
- [Cap 19 - Control de Flujo y Condicionales](../Seccion_3_EMIC_Codify/19_Control_Flujo_Condicionales.md)
- [Cap 20 - Etiquetado de Recursos (Tags DOXYGEN y JSON)](../Seccion_3_EMIC_Codify/20_Etiquetado_Recursos_Tags.md)

### **Sección 4: Desarrollo de Componentes SDK** 🛠️
- [Cap 21 - Desarrollo de una API EMIC - Paso a Paso](../Seccion_4_Desarrollo/21_Desarrollo_API_Paso_a_Paso.md)
- [Cap 22 - Desarrollo de un Driver EMIC](../Seccion_4_Desarrollo/22_Desarrollo_Driver.md)
- [Cap 23 - Proceso de Generación (EMIC Generate)](../Seccion_4_Desarrollo/23_Proceso_Generacion_Generate.md)
- [Cap 24 - Proceso de Deploy - Instanciación de Módulo](../Seccion_4_Desarrollo/24_Proceso_Deploy_Instanciacion_Modulo.md)
- [Cap 25 - Desarrollo de un Módulo EMIC Completo](../Seccion_4_Desarrollo/25_Desarrollo_Modulo_Completo.md)
- [Cap 26 - Plugins del Editor](../Seccion_4_Desarrollo/26_Plugins_Editor.md)

### **Sección 5: Casos Prácticos de Desarrollo-Integración** 🎓
- [Cap 27 - Caso Práctico - API de LEDs Desde Cero](../Seccion_5_Casos_Practicos/27_Caso_API_LEDs_Completo.md)
- [Cap 28 - Caso Práctico - Driver I2C + Sensor](../Seccion_5_Casos_Practicos/28_Caso_Driver_I2C_Sensor.md)
- [Cap 29 - Caso Práctico - Módulo de Control con USB](../Seccion_5_Casos_Practicos/29_Caso_Modulo_Control_USB.md)
- [Cap 30 - Caso Práctico - Sistema Multi-Módulo (Gateway Industrial)](../Seccion_5_Casos_Practicos/30_Caso_Gateway_Industrial_Multimodulo.md)

### **Sección 6: Testing, Validación y Troubleshooting** 🚀
- [Cap 31 - Buenas Prácticas de Desarrollo de Componentes SDK](../Seccion_6_Avanzado/31_Buenas_Practicas_Desarrollo.md)
- [Cap 32 - Testing y Validación de Componentes](../Seccion_6_Avanzado/32_Testing_Validacion_Componentes.md)
- [Cap 33 - Troubleshooting y Debugging de Desarrollos](../Seccion_6_Avanzado/33_Troubleshooting_Debugging.md)
- [Cap 34 - Optimización y Performance de Componentes](../Seccion_6_Avanzado/34_Optimizacion_Performance.md)

### **Sección 7: Referencias para Desarrolladores** 📚
- [Cap 35 - Referencia Rápida de Comandos EMIC-Codify](../Seccion_7_Referencias/35_Referencia_Comandos_Codify.md)
- [Cap 36 - Referencia Rápida de Tags (DOXYGEN y JSON)](../Seccion_7_Referencias/36_Referencia_Tags.md)
- [Cap 37 - Plantillas de Código para Desarrolladores](../Seccion_7_Referencias/37_Plantillas_Codigo.md)
- [Cap 38 - Recursos y Comunidad de Desarrolladores](../Seccion_7_Referencias/38_Recursos_Comunidad.md)

---

## 🗺️ Rutas de Aprendizaje Recomendadas

### 🟢 **Ruta Principiante** (Si eres nuevo en EMIC)
Tiempo estimado: 4-6 semanas

1. ➡️ **Fundamentos** (Caps 01-04)
2. ➡️ **Visión General SDK** (Cap 05)
3. ➡️ **EMIC-Codify Básico** (Caps 16-17)
4. ➡️ **Etiquetado** (Cap 20)
5. ➡️ **Desarrollo de API** (Cap 21)
6. ➡️ **Caso Práctico LEDs** (Cap 27)
7. ➡️ **Buenas Prácticas** (Cap 31)

### 🟡 **Ruta Intermedia** (Ya conoces EMIC o sistemas embebidos)
Tiempo estimado: 2-3 semanas

1. ➡️ **Repaso rápido** (Caps 01-02)
2. ➡️ **Estructura SDK** (Caps 05-07)
3. ➡️ **EMIC-Codify Completo** (Caps 16-20)
4. ➡️ **Desarrollo API + Driver** (Caps 21-22)
5. ➡️ **Procesos Generate y Deploy** (Caps 23-24)
6. ➡️ **Desarrollo Módulo** (Cap 25)
7. ➡️ **Casos Prácticos** (Caps 27-29)
8. ➡️ **Testing** (Cap 32)

### 🔴 **Ruta Avanzada** (Dominas el desarrollo embebido)
Tiempo estimado: 1-2 semanas

1. ➡️ **Lectura rápida de Fundamentos** (Caps 01-05)
2. ➡️ **Estructura SDK completa** (Caps 06-15)
3. ➡️ **EMIC-Codify avanzado** (Caps 16-20)
4. ➡️ **Desarrollo completo** (Caps 21-26)
5. ➡️ **Casos complejos** (Caps 28-30)
6. ➡️ **Optimización** (Cap 34)
7. ➡️ **Referencias** (Caps 35-37)

### 📖 **Ruta de Referencia** (Consulta rápida)

Para consultas específicas:
- **Comandos EMIC-Codify** → Cap 35
- **Sintaxis de Tags** → Cap 36
- **Templates de código** → Cap 37
- **Glosario** → Cap 03
- **Troubleshooting** → Cap 33

---

## 📝 Convenciones Usadas en este Manual

### Bloques de Código

```c
// Código C se muestra así
void ejemplo(void) {
    // Comentarios en español
}
```

```markdown
EMIC:comando(parametros)
```

### Iconos y Símbolos

- ✅ **Correcto / Recomendado**
- ❌ **Incorrecto / No recomendado**
- ⚠️ **Advertencia importante**
- 💡 **Tip o consejo útil**
- 📝 **Nota informativa**
- 🔍 **Ejemplo detallado**
- 🚀 **Característica avanzada**

### Bloques de Información

> **📝 Nota:** Información adicional relevante

> **⚠️ Advertencia:** Algo importante que debes saber

> **💡 Tip:** Sugerencia para mejorar tu código

> **🔍 Ejemplo:** Caso práctico ilustrativo

### Referencias Cruzadas

Los enlaces internos aparecen así: [Ver Cap 05](../Seccion_2_Estructura_SDK/05_Vision_General_SDK.md)

### Estructura de Comandos

La sintaxis de comandos EMIC se muestra así:

```
EMIC:comando([parámetro_opcional], parámetro_requerido)
```

- `[opcional]`: Entre corchetes, puede omitirse
- `parámetro`: Sin corchetes, es obligatorio

### Rutas y Volúmenes

Las rutas del sistema de archivos EMIC usan volúmenes lógicos:

- `DEV:` - Archivos del EMIC SDK
- `TARGET:` - Código generado
- `SYS:` - Configuración del sistema
- `USER:` - Archivos del usuario

Ejemplo: `DEV:_api/Indicators/LEDs/led.emic`

---

## 🛠️ Cómo Usar Este Manual

### Para Lectura Secuencial:

1. Comienza por el **Cap 01 - Introducción**
2. Lee los capítulos **en orden numérico**
3. Completa los **ejercicios prácticos** de la Sección 5
4. Consulta las **referencias** cuando necesites recordar sintaxis

### Para Consulta Rápida:

1. Usa el **Cap 03 - Glosario** para términos específicos
2. Consulta los **Apéndices (Caps 35-37)** para sintaxis rápida
3. Revisa el **Cap 33 - Troubleshooting** para solucionar problemas
4. Busca en el **índice de capítulos** arriba

### Para Desarrollo Práctico:

1. Lee los **conceptos fundamentales** (Sección 1)
2. Estudia la **estructura del SDK** (Sección 2)
3. Aprende **EMIC-Codify** (Sección 3)
4. Sigue los **tutoriales paso a paso** (Sección 4)
5. Implementa los **casos prácticos** (Sección 5)
6. Usa las **plantillas** (Cap 37) como punto de partida

---

## 📊 Alcance del Manual

### ✅ **Lo que SÍ cubre este manual:**

- Desarrollo de APIs EMIC
- Desarrollo de Drivers EMIC
- Desarrollo de Módulos completos
- Lenguaje EMIC-Codify completo
- Etiquetado de recursos (Tags)
- Estructura del EMIC SDK
- Casos prácticos completos
- Buenas prácticas de desarrollo
- Testing y debugging
- Optimización de código

### ❌ **Lo que NO cubre este manual:**

- **Gestión de repositorios Git/GitHub** (fuera del alcance)
- **Uso del EMIC-Editor** (para integradores, no desarrolladores)
- **Creación de proyectos IIoT completos** (eso es para integradores)
- **Administración de la plataforma EMIC.io**
- **Despliegue en producción de dispositivos**
- **Diseño de PCBs** (solo configuración)
- **Programación de microcontroladores desde cero** (se asume conocimiento previo)

---

## 🎯 Objetivos de Aprendizaje

Al finalizar este manual, serás capaz de:

1. ✅ **Entender** la arquitectura completa de EMIC
2. ✅ **Crear APIs** reutilizables de alto nivel
3. ✅ **Desarrollar Drivers** para hardware específico
4. ✅ **Construir Módulos** completos (Hardware + Firmware)
5. ✅ **Usar EMIC-Codify** con fluidez
6. ✅ **Etiquetar recursos** correctamente para EMIC Discovery
7. ✅ **Escribir generate.emic** complejos
8. ✅ **Aplicar buenas prácticas** de desarrollo
9. ✅ **Debuggear y optimizar** tu código
10. ✅ **Contribuir** al ecosistema EMIC con componentes de calidad

---

## 📞 Soporte y Comunidad

### Documentación Oficial:
- **Este manual** (la guía más completa para desarrolladores)
- **EMIC.md** (visión general del ecosistema)
- **README.md** (introducción rápida al SDK)

### Manuales Relacionados:
- **EMIC-Manual-V4.1.1.md** (comandos EMIC-Codify)
- **EMIC_Module_Debugging_Guide_for_AI.md** (troubleshooting)
- **Guía para la Creación de Módulos en EMIC.md** (guía resumida)

### Recursos Adicionales:
- Ver **Cap 38 - Recursos Adicionales** para más información

---

## 📈 Versión del Manual

| Versión | Fecha | Cambios |
|---------|-------|---------|
| 1.0 | Nov 2025 | Versión inicial completa |

---

## 🚀 ¡Comencemos!

Estás a punto de adentrarte en el ecosistema EMIC, una plataforma que revoluciona el desarrollo de sistemas embebidos para IoT e IIoT.

**Próximo paso:** [Cap 01 - Introducción al Desarrollo EMIC →](01_Introduccion.md)

---

## 📄 Licencia y Uso

Este manual es parte del ecosistema **EMIC** (Electrónica Modular Inteligente Colaborativa).

**Derechos reservados © 2025 EMIC Development Team**

---

*Manual generado para el desarrollo de recursos EMIC SDK*
*Última actualización: Noviembre 2025*
