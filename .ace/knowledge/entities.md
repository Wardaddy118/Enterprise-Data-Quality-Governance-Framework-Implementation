# Knowledge: Entities – FieldOps Pro

## Core Entities

**Batch**: Ejecución única de un notebook loader. Identificado por `batch_id` (formato: `YYYY-MM-DD-NNN`).

**DQ Violation**: Falla de una regla DQ a nivel de registro. Vive en `fieldops_audit.dq_violations`. Campos: `rule_id`, `dimension`, `severity`, `batch_id`, `table_name`, `column_name`, `violation_detail`.

**Quarantine Record**: Registro que falló regla CRITICAL o HIGH, excluido de procesamiento downstream. Vive en `fieldops_audit.quarantine_log`. No-destructivo.

**DQ Score**: Float en [0,1]. Fórmula: `1.0 - (weighted_violation_count / total_rows)`. Thresholds: PASS ≥ 0.95, WARN 0.85–0.94, FAIL < 0.85.

**Migration Defect**: Discrepancia entre source y target detectada en reconciliación. Vive en `fieldops_audit.migration_defects`. Campos: `defect_id`, `technique`, `severity`, `root_cause_hypothesis`, `row_key`.

**Source Table**: `workspace.fieldops_raw.cr_businesses_source` – lado "on-prem", CSV Costa Rica (~8,700 rows).

**Target Table**: `workspace.fieldops_raw.cr_businesses_target` – target sintético con 6 defect classes inyectados: data loss, taxonomy rename, duplicates, schema additions, encoding corruption, casing differences.

**Pipeline Config**: `workspace.fieldops_audit.pipeline_config` – tabla de configuración en runtime escrita por notebook 01. Contiene `catalog_name`, `is_active`, `created_at`.

## Relaciones

```
pipeline_config → drive catalog reference en todos los notebooks

cr_businesses_source (raw)
  ├── validado por 03 → dq_violations, quarantine_log
  ├── transformado por 04 → fieldops_staging, fieldops_curated
  └── reconciliado contra cr_businesses_target en 06 → migration_defects
```

## Glossary

| Término | Definición |
|---|---|
| Medallion | Raw → staging → curated |
| Serverless | Compute sin cluster persistente, auto-scaling |
| ANSI mode | SQL estricto: cast() lanza error en vez de NULL |
| datacompy | Library Python para field-level diff de DataFrames |
| BMAD | Analyze → Discuss → Plan → Execute → Verify |
| ADR | Architecture Decision Record |
| RCA | Root Cause Analysis |
