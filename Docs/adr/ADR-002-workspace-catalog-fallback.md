# ADR-002: Usar Catálogo `workspace` como Fallback (Constraint Free Edition)

**Fecha**: 2024-01 | **Status**: Accepted

## Contexto
Plan original era crear catálogo `fieldops_dq`. `CREATE CATALOG fieldops_dq` falló: workspace admins en Free Edition no tienen derechos de metastore admin de Unity Catalog.

## Decisión
Usar el catálogo `workspace` que Databricks auto-provisiona. Para evitar hardcodear `workspace` en notebooks, todos leen el nombre de catálogo desde `pipeline_config`.

## Consecuencias
- Desbloquea todo el desarrollo sin necesitar metastore admin
- `pipeline_config` pattern hace el código catalog-agnostic
- Documentado en README como limitación conocida de Free Edition, no defecto de diseño
