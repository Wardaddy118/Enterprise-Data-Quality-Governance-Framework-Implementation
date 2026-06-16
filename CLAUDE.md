# CLAUDE.md – FieldOps Pro

> Instrucciones para agentes AI. Lee este archivo primero antes de cualquier tarea.

---

## Project Identity

**FieldOps Pro** es un proyecto de portfolio en Databricks Free Edition que demuestra
data quality governance y migration QA – construido para una posición de Databricks QA Analyst en IGT.

- **Owner**: Jose Araya – Data Engineering @ Infinite Computer Solutions / Fiserv
- **Platform**: Databricks Free Edition + Unity Catalog (serverless compute)
- **Migration scenario**: Costa Rica business registry, on-prem → Databricks Lakehouse
- **Repo**: `github.com/Wardaddy118/Enterprise-Data-Quality-Governance-Framework-Implementation`

---

## Orden de ejecución de notebooks

```
01_setup_catalog          → Catalog, schemas, pipeline_config table
02_load_dirty_data_a      → Synthetic dirty dataset A
02b_load_dirty_data_b     → Synthetic dirty dataset B
03_validation_framework   → 62-rule DQ engine, quarantine, scoring
04_staging_curated        → Medallion pipeline raw → staging → curated
05_python_connection.py   → External client (databricks-sql-connector)
06_migration_reconciliation → Reconciliation engine (IGT centerpiece)
```

---

## Arquitectura

### Medallion layers
- `workspace.fieldops_raw.*`     → Raw ingest, sin transformaciones
- `workspace.fieldops_staging.*` → Limpio, validado, DQ-scored
- `workspace.fieldops_curated.*` → Business-ready, reconciliado

### Tablas clave
| Tabla | Propósito |
|---|---|
| `fieldops_audit.pipeline_config` | Catalog config en runtime (elimina hardcoded refs) |
| `fieldops_raw.cr_businesses_source` | Fuente migración – CSV Costa Rica |
| `fieldops_raw.cr_businesses_target` | Target sintético con drift inyectado |
| `fieldops_audit.dq_violations` | Todas las fallas de reglas DQ |
| `fieldops_audit.quarantine_log` | Registros en cuarentena |
| `fieldops_audit.migration_defects` | Defectos de reconciliación con root cause |

---

## Databricks Free Edition – Gotchas Críticos

| Problema | Workaround |
|---|---|
| ANSI mode rechaza `cast('$450k' as double)` | Usar `F.col("x").try_cast("double")` |
| Spark Connect NULL-type inference falla | Siempre `StructType` explícito |
| `.cache()` / `.persist()` no soportado | Remover completamente |
| `GENERATED ALWAYS AS IDENTITY` en INSERT | Usar lista de columnas explícita |
| Append mode no es idempotente | Delete-by-batch-id antes de cada insert |
| `databricks-connect` y `dbt-databricks` conflicto SDK | Venvs separados |
| pip install en notebooks necesita restart | `%pip install` + `dbutils.library.restartPython()` |
| Sin metastore admin en Free Edition | Usar catálogo `workspace` como fallback |

---

## BMAD Methodology

1. **ANALYZE** (Architect): Leer ADRs, revisar regression-guards.yaml
2. **DISCUSS** (Architect): Clarificar scope, identificar gotchas
3. **PLAN** (Architect): Actualizar `docs/planning/implementation_plan.md`
4. **EXECUTE** (Developer): Implementar; commit atómico por notebook
5. **VERIFY** (QA Engineer): Run end-to-end, validar detección de defectos

---

## Archivos clave al iniciar sesión

1. `.aceconfig` – reglas, skill routing, standards
2. `docs/context/ACTIVE_CONTEXT.md` – último estado trabajado
3. `docs/context/PROJECT_CONTEXT.md` – decisiones arquitectónicas estables
4. `docs/rca/regression-guards.yaml` – antes de tocar cualquier notebook
