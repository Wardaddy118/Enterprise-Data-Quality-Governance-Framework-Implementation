# SKILL: Data Quality Framework

**Cuándo cargar**: Modificar notebook 03, agregar reglas DQ, cambiar severity scoring, modificar quarantine workflow.

## Framework Overview
62 reglas DQ en 7 dimensiones. Violaciones → `fieldops_audit.dq_violations`. Registros CRITICAL/HIGH → `fieldops_audit.quarantine_log`.

## DQ Score Formula
```python
score = 1.0 - (
    (critical_count * 1.0 + high_count * 0.5 + medium_count * 0.2 + low_count * 0.05)
    / total_rows
)
```

## Patrón para agregar nueva regla
```python
def check_business_id_format(df, batch_id):
    """
    BR-015: Costa Rica business IDs → 10 dígitos numéricos.
    Dimension: Validity | Severity: HIGH
    """
    violations = df.filter(
        ~F.col("business_id").rlike(r"^\d{10}$")
    ).withColumn("rule_id", F.lit("BR-015")) \
     .withColumn("dimension", F.lit("validity")) \
     .withColumn("severity", F.lit("HIGH")) \
     .withColumn("batch_id", F.lit(batch_id))
    log_violations(violations)
    return df.filter(F.col("business_id").rlike(r"^\d{10}$"))
```

## Idempotency Guard (requerido en todo loader)
```python
spark.sql(f"DELETE FROM {target_table} WHERE batch_id = '{BATCH_ID}'")
```

## Interview Talking Points (IGT)
- "Separamos detección (reglas DQ) de disposición (quarantine vs flag vs pass) – downstream consumers deciden su propio tolerance."
- "El score pondera severidad para que una sola violación CRITICAL baje el batch score aunque el 99% de filas sean limpias."
- "Quarantine es no-destructivo – los registros están disponibles para reprocesamiento después de correcciones."
