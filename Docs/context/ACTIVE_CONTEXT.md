# Active Context: FieldOps Pro

## Session Metadata
- **Last Updated:** 2026-06-15
- **Active Role:** Developer
- **Current Phase:** Phase 5 – Migration QA Layer

## Current Objective
Construir y validar `06_migration_reconciliation.ipynb` – el motor de reconciliación de 6 técnicas que compara `cr_businesses_source` vs `cr_businesses_target` y popula `migration_defects`.

## Current State

### ✅ Working
- Notebooks 01 → 04 corren end-to-end
- `pipeline_config` table elimina referencias hardcodeadas
- 62-rule DQ framework operacional (notebook 03)
- Quarantine workflow loggeando a `fieldops_audit.quarantine_log`
- `cr_businesses_source` cargado desde CSV Costa Rica (~8,700 rows)
- `cr_businesses_target` generado con 6 defect classes inyectados
- Catálogo fallback `workspace.fieldops_*` confirmado funcionando

### 🔄 In Progress
- Notebook 06: migration_reconciliation (Phase 5)
- dbt project scaffold (Phase 6) – no iniciado

### ❌ Blocked
- Ninguno

## Gotchas Resueltos
| Problema | Fix Aplicado |
|---|---|
| ANSI cast error en `$450000` | Cambiado a `try_cast` |
| NULL-type inference en Spark Connect | `StructType` explícito everywhere |
| `.cache()` en serverless | Removido completamente |
| IDENTITY column INSERT error | Lista explícita de columnas |
| Append mode duplicates | Delete-by-batch-id + insert |
| pip install kernel scope | `%pip` + `dbutils.library.restartPython()` |
| SDK conflict connect/dbt | Venvs separados |

## Next Steps
1. [ ] Completar notebook 06 – las 6 técnicas
2. [ ] Verificar detección de los 6 defect classes
3. [ ] Generar reconciliation report markdown
4. [ ] Scaffold dbt project (Phase 6)
5. [ ] Test Plan document (Phase 7)
6. [ ] Snowflake cross-platform (Phase 8)
