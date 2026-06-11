# Manual de Desarrollo EMIC

Manual para **desarrolladores** de SDKs EMIC (EMIC-Codify, estructura del SDK, drivers, APIs).

## ⭐ Versión vigente: `Manual_Desarrollo_EMIC_V3/`

Toda lectura, corrección o ampliación del manual se hace **únicamente sobre V3**.

| Carpeta | Estado |
|---|---|
| `Manual_Desarrollo_EMIC_V3/` | ✅ **VIGENTE** — única versión mantenida |
| `Manual_Desarrollo_EMIC_V2/` | ⚠️ DEPRECADA — solo referencia histórica, no editar |
| `Manual_Desarrollo_EMIC/` (V1) | ⚠️ DEPRECADA — solo referencia histórica, no editar |

## Estructura de V3

```
Manual_Desarrollo_EMIC_V3/
├── Seccion_1_Introduccion/
├── Seccion_2_Estructura_SDK/
├── Seccion_3_EMIC_Codify/        ← el lenguaje (directivas EMIC:*)
│   ├── 16_Fundamentos_Codify_Desarrollo.md
│   ├── 17_Comandos_Gestion_Archivos.md     (copy, setInput, setOutput, restoreOutput)
│   ├── 18_Sistema_Macros_Sustitucion.md    (define/unDefine, .{...}., comodines, foreach)
│   ├── 19_Control_Flujo_Condicionales.md   (ifdef/ifndef/if/elif/else/endif)
│   └── 20_Etiquetado_Recursos_Tags.md      (EMIC:tag, doxygen @fn/@alias, EMIC:json)
└── Seccion_4_Desarrollo/
```

La implementación de referencia del lenguaje es `TreeMaker.cs` (repo CircuitEMIC,
`EMIC.Shared/Services/Emic/`); los tests de regresión del lenguaje viven en
`EMIC.Shared.Tests/Emic/MacroExpansionTests.cs`. Ante discrepancia manual ↔ código,
manda el código — y se corrige el manual.
