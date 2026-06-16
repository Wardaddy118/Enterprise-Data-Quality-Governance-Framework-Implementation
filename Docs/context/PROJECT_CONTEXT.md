# Project Context – FieldOps Pro

## Platform
- **Compute**: Databricks Free Edition (serverless)
- **Catalog**: Unity Catalog, catálogo `workspace` (limitación Free Edition)
- **Python runtime**: 3.12 (matches 17.3 LTS serverless)

## Data Layer
- **Architecture**: Medallion (raw → staging → curated)
- **Schemas**: `workspace.fieldops_raw`, `workspace.fieldops_staging`, `workspace.fieldops_curated`, `workspace.fieldops_audit`
- **Catalog resolution**: Siempre desde `pipeline_config`, nunca hardcodeado
- **Idempotencia**: Delete-by-batch-id antes de cada insert
- **Schema definition**: Siempre StructType explícito

## DQ Framework
- **Reglas**: 62 en 7 dimensiones
- **Violation table**: `workspace.fieldops_audit.dq_violations`
- **Quarantine table**: `workspace.fieldops_audit.quarantine_log`
- **DQ score**: Threshold PASS ≥ 0.95, WARN 0.85–0.94, FAIL < 0.85

## Migration QA Layer
- **Source**: `workspace.fieldops_raw.cr_businesses_source` (~8,700 rows, CSV real)
- **Target**: `workspace.fieldops_raw.cr_businesses_target` (sintético con 6 defect classes)
- **Defect table**: `workspace.fieldops_audit.migration_defects`
- **Técnicas**: 6 (row count, schema drift, key-set, MD5, aggregate, datacompy)

## Modern Stack
- **dbt**: `dbt-databricks` en venv separado
- **datacompy**: `==0.16.*`, vía `%pip` con restart de kernel
- **External client**: `05_python_connection.py` con `databricks-sql-connector`

## Out of Scope
- MLflow / ML
- Streaming en tiempo real
- Airflow / Databricks Workflows
- Datos reales de IGT/gaming
- SaaS de pago
