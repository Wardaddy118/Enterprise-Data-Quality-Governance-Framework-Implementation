# Standard: Data Quality – FieldOps Pro

## DQ Score Thresholds
| Score | Status | Acción |
|---|---|---|
| ≥ 0.95 | ✅ PASS | Permitir carga downstream |
| 0.85–0.94 | ⚠️ WARN | Cargar con flag en audit table |
| < 0.85 | ❌ FAIL | Bloquear downstream, alertar |

## Quarantine Rules
- CRITICAL siempre cuarentena
- HIGH cuarentena por defecto (override via pipeline_config)
- Cuarentena es no-destructiva – disponible para reprocesamiento
- Cada registro en quarantine_log debe incluir: rule_id, violation_detail, original_values

## Registro de Violaciones – Campos Requeridos
- `batch_id`, `rule_id`, `dimension`, `severity`
- `table_name`, `column_name` (NULL si es row-level)
- `violation_detail` (descripción específica del fallo)
- `detected_at`

## Enhancement vs Bug Fix
- **Enhancement**: nueva regla, cambio de threshold, nueva dimensión
- **Bug fix**: regla que debería disparar no lo hace – requiere RCA en `docs/rca/`
