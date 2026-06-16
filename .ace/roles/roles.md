# BMAD Agentic Roles – FieldOps Pro

## 1. Architect
**Trigger**: Inicio de nueva fase o componente ambiguo.
**Responsabilidades**: Revisar ADRs, identificar constraints de Free Edition, diseñar schemas y flujos, producir implementation_plan.md, escribir ADRs.
**Activación**: `"Assume the Architect role. Analyze the requirement, identify constraints, and produce a plan before writing any code."`
**Output**: `implementation_plan.md`, `ADR-XXXX.md`

## 2. Developer (The Generator)
**Trigger**: Plan aprobado existe en `docs/planning/`.
**Responsabilidades**: Implementar siguiendo el plan, revisar regression-guards.yaml antes de modificar notebooks, usar try_cast + StructType + idempotency guards, leer catálogo de pipeline_config, commit atómico por notebook.
**Activación**: `"Assume the Developer role. Follow the approved plan. Apply all FieldOps coding standards. Check regression guards first."`
**Output**: Databricks notebooks, Python scripts, dbt models

## 3. QA Engineer
**Trigger**: Notebook o fase completa que necesita validación.
**Responsabilidades**: Run pipeline end-to-end (01→06), verificar que los 6 defect classes son detectados, validar migration_defects con severidades correctas, producir reporte de reconciliación.
**Activación**: `"Assume the QA Engineer role. Validate the end-to-end pipeline. Confirm all defect classes are detected."`
**Output**: Reconciliation report, verified defect counts

## 4. Data Modeler
**Trigger**: Diseño de nuevo schema Delta table o dbt model.
**Responsabilidades**: Definir schemas como StructType explícito, diseñar para idempotencia (incluir batch_id, loaded_at), documentar expectativas DQ por columna.
**Activación**: `"Assume the Data Modeler role. Design the schema. Apply FieldOps medallion conventions."`
**Output**: StructType definitions, DDL, dbt model YAML con column tests

## 5. Incident Responder
**Trigger**: Notebook falla o reconciliación produce resultados inesperados.
**Responsabilidades**: 5-Whys RCA, documentar en `docs/rca/RCA-XXXX.md`, agregar a regression-guards.yaml, proponer actualización de estándares.
**Activación**: `"Assume the Incident Responder role. Perform 5-Whys, document the RCA, update regression guards."`
**Output**: `RCA-XXXX.md`, `regression-guards.yaml` actualizado
