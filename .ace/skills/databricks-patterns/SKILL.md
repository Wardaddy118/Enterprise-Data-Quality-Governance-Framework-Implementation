# SKILL: Databricks Patterns – Free Edition

**Cuándo cargar**: Escribir cualquier notebook PySpark, troubleshoot errores de compute, workarounds de plataforma.

## Free Edition vs Paid
| Feature | Free Edition | Paid |
|---|---|---|
| `.cache()` / `.persist()` | ❌ No soportado | ✅ |
| ANSI mode | ❌ Enforced (strict) | Optional |
| Metastore admin | ❌ | ✅ |
| Scheduled Jobs | ❌ | ✅ |

## Patrones Requeridos

### Cast seguro
```python
# ❌ NUNCA – falla con ANSI mode en '$450,000'
F.col("revenue_raw").cast("double")

# ✅ SIEMPRE
F.col("revenue_raw").try_cast("double")
```

### Schema explícito
```python
# ❌ NUNCA
spark.read.csv(path, header=True, inferSchema=True)

# ✅ SIEMPRE
schema = StructType([StructField("id", StringType(), True), ...])
spark.read.schema(schema).csv(path, header=True)
```

### Idempotencia
```python
# ✅ Delete-then-insert
spark.sql(f"DELETE FROM {table} WHERE batch_id = '{BATCH_ID}'")
df.write.format("delta").mode("append").saveAsTable(table)
```

### Catálogo desde config
```python
config = spark.table("workspace.fieldops_audit.pipeline_config") \
    .filter(F.col("is_active") == True).orderBy(F.col("created_at").desc()).first()
CATALOG = config["catalog_name"]
```

### pip en notebooks
```python
# Cell 1 – siempre restart
%pip install datacompy==0.16.*
dbutils.library.restartPython()
```

## Metastore Fallback
```sql
-- ❌ Falla sin metastore admin
CREATE CATALOG fieldops_dq;

-- ✅ Usar workspace catalog
CREATE SCHEMA IF NOT EXISTS workspace.fieldops_raw;
CREATE SCHEMA IF NOT EXISTS workspace.fieldops_staging;
CREATE SCHEMA IF NOT EXISTS workspace.fieldops_curated;
CREATE SCHEMA IF NOT EXISTS workspace.fieldops_audit;
```
