# Standard: Migration QA – FieldOps Pro

## Las 6 Técnicas (todas requeridas en notebook 06)
| # | Técnica | Defect class detectado |
|---|---|---|
| 1 | Row count comparison | Data loss (rows dropped) |
| 2 | Schema drift detection | Columns added/removed/type changes |
| 3 | Key-set reconciliation | Orphan keys |
| 4 | Row-level MD5 hash | Cualquier mutación de datos |
| 5 | Aggregate reconciliation | Numeric drift (SUM/MIN/MAX/COUNT DISTINCT) |
| 6 | Field-level diff (datacompy) | Comparación columna-por-columna en muestra |

## Severity Mapping
| Condición | Severity |
|---|---|
| Row count delta > 1% | CRITICAL |
| Orphan key en source (data loss) | CRITICAL |
| Orphan key en target (phantom record) | HIGH |
| MD5 hash mismatch | HIGH |
| Column removida del schema | HIGH |
| Aggregate delta > 5% | HIGH |
| Column agregada nullable | MEDIUM |
| Type widening (INT→BIGINT) | MEDIUM |
| Casing / encoding difference | LOW |
| Taxonomy rename | MEDIUM |

## Root Cause Hypothesis Templates
```python
ROOT_CAUSES = {
    "DATA_LOSS":       "Row en source no está en target. Posiblemente dropped durante ETL o filtrado por predicado incorrecto.",
    "PHANTOM_RECORD":  "Row en target no está en source. Posible insert duplicado o scope incorrecto en query.",
    "TAXONOMY_DRIFT":  "Valor de industry difiere entre source y target. Posible rename de taxonomía durante migración.",
    "ENCODING_DRIFT":  "Diferencia de encoding detectada. Posible corrupción UTF-8 durante transferencia.",
    "NUMERIC_DRIFT":   "Delta de agregado supera threshold 5%. Posible pérdida de precisión o transformación de escala.",
    "SCHEMA_ADDITION": "Columna en target no presente en source. Confirmar si es enrichment column esperado.",
    "SCHEMA_REMOVAL":  "Columna en source no presente en target. Posible column drop inadvertido.",
    "DUPLICATE":       "business_id aparece múltiples veces en target. Load no-deduplicado o duplicate injection.",
}
```

## Sign-off Criteria
- [ ] 0 defectos CRITICAL sin resolver
- [ ] Todos los HIGH con root_cause_hypothesis documentado
- [ ] Row count delta < 0.1%
- [ ] Hash match rate > 99.5%
- [ ] Todos los aggregate deltas < 1%
- [ ] Reconciliation report generado y commiteado
