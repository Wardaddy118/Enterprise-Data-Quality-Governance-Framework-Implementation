# FieldOps Pro — Data Quality & Migration QA Framework

> **Enterprise-grade data quality governance and migration validation on Databricks Free Edition.**
> Built as a portfolio project targeting a Databricks QA Analyst role at IGT.

---

## What this project demonstrates

A full **data quality governance framework** combined with a **migration QA reconciliation engine** — implemented end-to-end on Databricks Lakehouse (Unity Catalog, serverless compute). All notebooks ran successfully and results are persisted in Delta tables.

| Capability | Proof |
| --- | --- |
| 62-rule DQ engine across 7 dimensions | Notebook 03 — violations logged to `dq_violations` |
| Quarantine workflow (non-destructive) | `fieldops_audit.quarantine_log` populated |
| Medallion pipeline (raw → staging → curated) | Notebook 04 — 428 records processed |
| Migration reconciliation — 6 techniques | Notebook 06 — 13 defects detected |
| **6/6 injected defect classes caught** | Detection rate: 100% (`MIG-20260518-031539-70BA48`) |
| Stakeholder reconciliation report | Persisted to `fieldops_dq.reconciliation_reports` |

---

## Reconciliation Results (Run `MIG-20260518-031539-70BA48`)

```text
Source rows : 100,000
Target rows :  99,598  (−402 net — rows lost AND rows duplicated)

Defects logged: 13
  CRITICAL : 2   ← rows lost in migration, data loss
  HIGH     : 5   ← duplicate keys, hash mismatches, aggregate drift, schema drop
  MEDIUM   : 4   ← field-level corruption (name, website, founded, industry)
  LOW      : 2   ← schema additions (migration metadata columns)

Defect scorecard:
  [✓] row_loss       CAUGHT — 502 rows dropped (id % 199 == 0)
  [✓] taxonomy       CAUGHT — 'Information Technology'→'IT', 'Tourism & Hospitality'→'Tourism'
  [✓] corruption     CAUGHT — name upper-cased + website truncated (id % 311 == 0)
  [✓] numeric_drift  CAUGHT — founded += 1 (id % 467 == 0), SUM delta = −996,535
  [✓] schema_drift   CAUGHT — linkedin_url dropped; migrated_at + source_system added
  [✓] duplicates     CAUGHT — 100 rows re-appended (id % 991 == 0)

Detection rate: 6/6
```

---

## Architecture

```text
01_setup          → Unity Catalog schemas, pipeline_config table
02_load (A + B)   → Synthetic dirty data — 428 records, 7 tables
03_validation     → 62-rule DQ engine → dq_violations + quarantine_log
04_pipeline       → Raw → Staging → Curated (Medallion)
05_migration_data → 100K source rows + 6-defect target dataset + manifest
06_reconciliation → 6-technique reconciliation engine → migration_defects
07_report         → Stakeholder report → reconciliation_reports
```

### Medallion layers

```text
workspace.fieldops_raw.*      ← raw ingest, no transformations
workspace.fieldops_staging.*  ← DQ-validated, scored
workspace.fieldops_curated.*  ← business-ready
workspace.fieldops_audit.*    ← violations, quarantine, defects, config
workspace.fieldops_dq.*       ← migration defects, reconciliation reports
```

---

## The 6 Reconciliation Techniques

| # | Technique | Defect class caught |
| --- | --- | --- |
| 1 | Row count comparison | Data loss (net delta) |
| 2 | Schema drift detection | Dropped / added / retyped columns |
| 3 | Key-set reconciliation | Lost keys, phantom keys, duplicate keys |
| 4 | Row-level MD5 hash | Any value mutation on matched keys |
| 5 | Aggregate reconciliation | Silent numeric drift (SUM/MIN/MAX/distinct) |
| 6 | datacompy field-level diff | Column-by-column diff on a 5K-row sample |

> **Key insight from the results:** The net row count (−402) understates the real damage — 502 rows were *lost* while 100 rows were *duplicated*, partially masking each other. Only the layered approach surfaces the true state of the migration.

---

## DQ Dimensions & Scoring

```text
Dimensions : Completeness · Uniqueness · Validity · Referential Integrity
             Consistency · Timeliness · Business Rules

Score formula:
  DQ Score = 1.0 − ( (CRITICAL×1.0 + HIGH×0.5 + MEDIUM×0.2 + LOW×0.05) / total_rows )

Thresholds:
  ≥ 0.95  → PASS (promote downstream)
  0.85–0.94 → WARN (flag in audit, proceed with caution)
  < 0.85  → FAIL (block downstream, alert)
```

---

## Databricks Free Edition — Key Constraints Solved

| Constraint | Solution applied |
| --- | --- |
| ANSI mode rejects `cast()` on dirty strings | `try_cast()` everywhere in raw layer |
| `.cache()` / `.persist()` not supported on serverless | Removed entirely |
| No metastore admin → can't create custom catalog | `workspace` catalog + `pipeline_config` for runtime resolution |
| Non-idempotent appends cause duplicates | Delete-by-batch-id before every INSERT |
| NULL-type inference crashes Spark Connect | Explicit `StructType` on every `spark.read.*` |
| `%pip install` scope lost after kernel restart | `%pip` + `dbutils.library.restartPython()` pattern |

---

## Project Structure

```text
├── Databricks/          ← Databricks notebooks (.ipynb) — import directly
│   ├── 01_setup_catalog_and_tables.ipynb
│   ├── 02_load_dirty_data_batch1.ipynb
│   ├── 02b_load_dirty_data_batch2.ipynb
│   ├── 03_validation_framework.ipynb
│   ├── 04_staging_and_curated_pipeline.ipynb
│   ├── 05_generate_migration_data.ipynb
│   ├── 06_migration_reconciliation.ipynb
│   └── 07_reconciliation_report.ipynb
│
├── Python/              ← Same logic as standalone PySpark scripts (.py)
│   ├── 01_setup_catalog_and_tables.py
│   ├── 02_load_dirty_data.py
│   ├── 02b_load_dirty_data_batch2.py
│   ├── 03_validation_framework.py
│   └── 04_staging_and_curated_pipeline.py
│
├── SQL/                 ← Reference SQL (DDL, validation queries, testing)
│   ├── 01_create_tables.sql
│   ├── 02_data_inserts.sql
│   ├── 03_remediation_staging.sql
│   ├── 04_validation_framework.sql
│   ├── 05_testing.sql
│   └── 06_testing_files.sql
│
├── Docs/                ← Governance documentation (PDF)
│   ├── 1_DQ_Case_Study_Governance.pdf
│   ├── 2_DQ_Governance.pdf
│   ├── 3_DQ_Test_Plan.pdf
│   ├── 4_DQ_Rules_Catalog.pdf
│   └── 5_DQ_Monitoring_DQS_Dashboard.pdf
│
├── docs/                ← ACE framework docs (ADRs, RCAs, context)
│   ├── adr/             ← Architecture Decision Records
│   ├── rca/             ← Root Cause Analyses + regression guards
│   └── context/         ← Active context + project context
│
└── .ace/                ← ACE Framework v2.6.2 configuration
    ├── roles/           ← BMAD roles (Architect, Developer, QA Engineer, etc.)
    ├── skills/          ← Skill files per domain (DQ, migration-qa, dbt, databricks)
    └── standards/       ← Coding, data quality, migration QA standards
```

---

## How to Run

### Option A — Databricks (recommended)

1. Import notebooks from `Databricks/` into your Databricks workspace
2. Run in order: `01 → 02 → 02b → 03 → 04 → 05 → 06 → 07`
3. Each notebook reads catalog config from `pipeline_config` at runtime — no hardcoded names needed

### Option B — PySpark scripts

The `Python/` folder contains the same pipeline logic as standalone `.py` scripts, adaptable to any PySpark environment (AWS EMR, Azure HDInsight, local PySpark, etc.):

```bash
pip install pyspark delta-spark
spark-submit Python/01_setup_catalog_and_tables.py
spark-submit Python/02_load_dirty_data.py
# ... continue in sequence
```

> Notebooks 05, 06, and 07 use Databricks-specific APIs (`dbutils`, `%pip`). For other PySpark environments, install `datacompy` in your environment beforehand and replace `dbutils.library.restartPython()` with a session restart.

---

## Stack

- **Platform**: Databricks Free Edition + Unity Catalog (serverless)
- **Language**: Python 3.12 / PySpark
- **Storage**: Delta Lake
- **QA library**: datacompy 0.16.x
- **AI development**: ACE Framework v2.6.2 + Claude Code

---

## Acknowledgements

This project was built using the **[ACE Framework](https://github.com/jonnabio/ace-framework)** by **Jonathan Herrera** ([@jonnabio](https://github.com/jonnabio)).

Jonathan's ACE framework introduced the BMAD methodology (Analyze → Discuss → Plan → Execute → Verify) that structured the entire development workflow — from architecture decisions and coding standards to Root Cause Analyses and regression guards. The framework made it possible to maintain consistency across 7 notebooks, document every architectural decision, and catch defect patterns before they became regressions.

If you are doing any data engineering project with AI pair programming, the ACE framework is worth adopting. Thank you, Jonathan.

---

## Author

**Jose Andres Araya**
Data Quality Engineer | Data Engineering | Databricks

[GitHub — Wardaddy118](https://github.com/Wardaddy118)
