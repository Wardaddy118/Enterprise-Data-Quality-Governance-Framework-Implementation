# ADR-001: Medallion Architecture (Raw → Staging → Curated)

**Fecha**: 2024-01 | **Status**: Accepted

## Contexto
Necesitamos separar ingesta raw de datos validados, soportar reprocesamiento idempotente, y demostrar prácticas enterprise para la entrevista IGT.

## Decisión
Medallion Architecture con tres capas: raw (sin transformaciones), staging (DQ-validado, DQ score), curated (business-ready).

## Consecuencias
- Lineage claro: cualquier fila curated se puede trazar a raw
- Cada capa reprocesable independientemente
- Alinea con Databricks Lakehouse docs y arquitectura probable de IGT
- Trade-off: 3x storage, pero con ~8,700 filas es insignificante
