# SKILL: dbt-databricks Models

**Cuándo cargar**: Fase 6 (integración dbt), escribir modelos, definir tests, troubleshoot configuración.

## Cuándo usar dbt vs notebooks
- **dbt**: transformaciones SQL puras (staging→curated), lineage, tests declarativos
- **notebooks**: ingest raw (necesita Python), DQ framework (PySpark complejo), reconciliation engine (datacompy es Python-only)

## Estructura del proyecto
```
dbt_fieldops/
├── dbt_project.yml
├── profiles.yml          → NO commitear al repo
├── models/
│   ├── staging/
│   │   ├── stg_cr_businesses.sql
│   │   └── stg_cr_businesses.yml
│   ├── marts/
│   │   └── mart_businesses_by_industry.sql
│   └── reconciliation/
│       └── recon_source_target_summary.sql
└── tests/
    └── assert_no_critical_dq_violations.sql
```

## profiles.yml (local, ~/.dbt/profiles.yml)
```yaml
fieldops:
  target: dev
  outputs:
    dev:
      type: databricks
      catalog: workspace
      schema: fieldops_staging
      host: <workspace>.azuredatabricks.net
      http_path: /sql/1.0/warehouses/<warehouse-id>
      token: "{{ env_var('DATABRICKS_TOKEN') }}"
      threads: 4
```

## dbt_project.yml
```yaml
name: 'fieldops'
version: '1.0.0'
config-version: 2
profile: 'fieldops'
models:
  fieldops:
    staging:
      +materialized: view
    marts:
      +materialized: table
```

## Custom test
```sql
-- tests/assert_no_critical_dq_violations.sql
select count(*) as critical_count
from workspace.fieldops_audit.dq_violations
where severity = 'CRITICAL'
  and batch_id = (select max(batch_id) from workspace.fieldops_audit.dq_violations)
having count(*) > 0
```

## Comandos
```bash
dbt debug       # test conexión
dbt run         # ejecutar todos los modelos
dbt test        # ejecutar todos los tests
dbt docs generate && dbt docs serve
```
