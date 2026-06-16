# Standard: Coding – FieldOps Pro

## PySpark Rules
1. **`try_cast` no `cast`** en raw layer – sin excepciones
2. **`StructType` explícito** en todo `spark.read.*` – sin `inferSchema=True`
3. **Sin `.cache()` o `.persist()`** – serverless no lo soporta
4. **Idempotency guard** al inicio de cada notebook loader (delete-by-batch-id)
5. **Comentarios por celda** explican el intent DQ, no solo qué hace el código

## SQL Rules
1. Siempre calificar tabla completa: `workspace.fieldops_staging.cr_businesses`
2. `MERGE INTO` para upsert en curated layer
3. SQL para operaciones de conjunto (JOINs, agregaciones, window functions)

## Naming
| Objeto | Convención | Ejemplo |
|---|---|---|
| Delta tables | snake_case | `cr_businesses_source` |
| Variables de notebook | UPPER_SNAKE para constantes | `BATCH_ID`, `CATALOG` |
| DQ rule IDs | `DIM-NNN` | `C-001`, `V-003` |
| dbt models | prefijo por capa | `stg_cr_businesses`, `mart_by_industry` |

## Git Commits
Formato: `[phaseN] verb: object`
```
[phase5] feat: add key-set reconciliation to notebook 06
[phase3] fix: apply try_cast to revenue column
[ace] docs: integrate ACE framework v2.6.2
```

## Prohibido
- Hardcodear `workspace.fieldops_*` en notebooks
- Fallar silenciosamente en violaciones DQ
- Drop-and-recreate tables para idempotencia
- `inferSchema=True` en cualquier read
- Mezclar databricks-connect y dbt-databricks en el mismo venv
