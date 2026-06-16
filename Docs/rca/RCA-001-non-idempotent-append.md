# RCA-001: Non-Idempotent Append Causó Filas Duplicadas

**Fecha**: 2024-01 | **Severity**: HIGH | **Status**: RESOLVED

## 5-Whys

1. Notebook usó `mode("append")` para escribir a staging.
2. Append sin deduplicación agrega una copia completa del batch en cada run.
3. Se asumió que batch_id único por run prevendría conflictos.
4. Durante desarrollo, notebooks se re-corren con BATCH_IDs fijos repetidamente.
5. Sin validación de row count post-write, los duplicados eran invisibles.

## Fix Aplicado
```python
spark.sql(f"DELETE FROM {target_table} WHERE batch_id = '{BATCH_ID}'")
df.write.format("delta").mode("append").saveAsTable(target_table)
```

## Prevención
- Todos los notebooks loader deben tener delete-before-insert (regression guard agregado)
- Standard documentado en `.ace/standards/coding.md`
