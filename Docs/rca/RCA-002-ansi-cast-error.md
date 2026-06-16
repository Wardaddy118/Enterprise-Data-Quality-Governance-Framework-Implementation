# RCA-002: ANSI Mode Cast Failure en Columna Revenue

**Fecha**: 2024-01 | **Severity**: HIGH | **Status**: RESOLVED

## 5-Whys

1. Columna revenue contenía valores como `'$450,000'` – strings con símbolos de moneda.
2. Databricks Free Edition serverless enforces ANSI SQL mode por defecto.
3. ANSI mode hace que `cast()` lance error en input inválido en vez de retornar NULL.
4. Developer usó `.cast("double")` sin saber que ANSI mode estaba activo.
5. La mayoría de entornos Spark tienen ANSI mode como opt-in; en Free Edition es default.

## Fix Aplicado
```python
# Antes (roto bajo ANSI mode)
F.col("revenue_raw").cast("double")

# Después (ANSI-safe)
F.col("revenue_raw").try_cast("double")
```

## Prevención
- `try_cast` es standard obligatorio para todos los casts numéricos en raw layer
- Regression guard en notebook 03: inyectar `'$450,000'` y verificar V-003 loggeado
- Documentado en `.ace/standards/coding.md` y `.ace/skills/databricks-patterns/SKILL.md`
