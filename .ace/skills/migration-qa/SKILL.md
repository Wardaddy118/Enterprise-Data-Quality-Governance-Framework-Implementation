# SKILL: Migration QA & Reconciliation

**Cuándo cargar**: Trabajar en notebook 06, diseñar migration_defects schema, agregar técnica de reconciliación, preparar entrevista IGT.

## Las 6 Técnicas
| # | Técnica | Defect class |
|---|---|---|
| 1 | Row count comparison | Data loss |
| 2 | Schema drift detection | Schema changes |
| 3 | Key-set reconciliation | Orphan keys |
| 4 | Row-level MD5 hash | Data mutations |
| 5 | Aggregate reconciliation | Numeric drift |
| 6 | Field-level diff (datacompy) | Column-level diffs |

## migration_defects Schema
```python
from pyspark.sql.types import StructType, StructField, StringType, TimestampType

migration_defects_schema = StructType([
    StructField("defect_id",             StringType(),    False),
    StructField("batch_id",              StringType(),    False),
    StructField("table_name",            StringType(),    False),
    StructField("column_name",           StringType(),    True),
    StructField("technique",             StringType(),    False),
    StructField("source_value",          StringType(),    True),
    StructField("target_value",          StringType(),    True),
    StructField("severity",              StringType(),    False),
    StructField("root_cause_hypothesis", StringType(),    True),
    StructField("detected_at",           TimestampType(), False),
    StructField("row_key",               StringType(),    True),
])
```

## datacompy Pattern
```python
# Cell 1 – SIEMPRE restart después de pip install
%pip install datacompy==0.16.*
dbutils.library.restartPython()

import datacompy
N_SAMPLE = 5000
source_sample = source_df.orderBy(F.rand()).limit(N_SAMPLE).toPandas()
target_sample = target_df.orderBy(F.rand()).limit(N_SAMPLE).toPandas()

compare = datacompy.Compare(
    source_sample, target_sample,
    join_columns="business_id",
    df1_name="source", df2_name="target",
    ignore_spaces=True, ignore_case=True,
)
print(compare.report())
```

## Interview Talking Points (IGT)
- **"¿Cómo validarías una migración?"**: "Aplico 6 técnicas en capas: estructural primero (row counts, schema), luego integridad de claves, luego comparación hash, luego reconciliación de agregados en columnas numéricas, y finalmente diff field-level en una muestra estadísticamente significativa."
- **"¿Qué haces con schema drift?"**: "Detectar primero comparando column sets y tipos. Clasificar: column removida = HIGH, column agregada nullable = MEDIUM, type narrowing = CRITICAL por posible truncamiento silencioso."
- **"¿Cómo manejas taxonomy changes?"**: "Construimos un crosswalk de vocabulario controlado antes de la migración. Durante reconciliación, cualquier valor que no esté en source NI en el crosswalk aprobado es un defecto."
