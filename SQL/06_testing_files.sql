-- 1. ORPHAN RECORDS: fact → dim (el test más importante)
SELECT f.transaction_id, f.customer_key
FROM fact_sales f
LEFT JOIN dim_customer c ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;
-- Resultado esperado: 0 filas

-- 2. DUPLICATE GRAIN: detectar duplicados en fact
SELECT sale_date, customer_key, product_key, COUNT(*) AS cnt
FROM fact_sales
GROUP BY sale_date, customer_key, product_key
HAVING COUNT(*) > 1;

-- 3. NULL FKs en fact table
SELECT COUNT(*) AS null_customer_keys
FROM fact_sales
WHERE customer_key IS NULL;

-- 4. NEGATIVE AMOUNTS donde no aplica
SELECT transaction_id, amount
FROM fact_sales
WHERE amount < 0 AND transaction_type != 'REFUND';

-- 5. REFERENTIAL INTEGRITY completa (todos los FKs)
SELECT
  SUM(CASE WHEN c.customer_key IS NULL THEN 1 ELSE 0 END) AS bad_customer,
  SUM(CASE WHEN p.product_key  IS NULL THEN 1 ELSE 0 END) AS bad_product,
  SUM(CASE WHEN d.date_key     IS NULL THEN 1 ELSE 0 END) AS bad_date
FROM fact_sales f
LEFT JOIN dim_customer c ON f.customer_key = c.customer_key
LEFT JOIN dim_product  p ON f.product_key  = p.product_key
LEFT JOIN dim_date     d ON f.date_key     = d.date_key;

-- 6. FRESHNESS CHECK
SELECT
  MAX(load_timestamp) AS last_load,
  CURRENT_TIMESTAMP - MAX(load_timestamp) AS lag
FROM fact_sales;

-- 7. VOLUME ANOMALY: comparar con promedio 7 días
WITH daily AS (
  SELECT DATE(load_timestamp) AS dt, COUNT(*) AS rows
  FROM fact_sales
  WHERE load_timestamp >= CURRENT_DATE - 30
  GROUP BY 1
),
stats AS (SELECT AVG(rows) AS avg_rows, STDDEV(rows) AS std_rows FROM daily)
SELECT dt, rows, avg_rows,
  CASE WHEN ABS(rows - avg_rows) > 2 * std_rows THEN 'ANOMALY' ELSE 'OK' END AS status
FROM daily CROSS JOIN stats
ORDER BY dt DESC;

-- models/marts/fact_sales.sql
WITH orders AS (
  SELECT * FROM {{ ref('int_orders_enriched') }}
),
customers AS (
  SELECT * FROM {{ ref('dim_customer') }}
)
SELECT
  o.order_id,
  c.customer_key,
  o.order_date,
  o.amount,
  o.quantity
FROM orders o
LEFT JOIN customers c
  ON o.customer_id = c.customer_id
  AND c.is_current = true

-- schema.yml — tests declarativos
models:
  - name: fact_sales
    columns:
      - name: order_id
        tests:
          - unique
          - not_null
      - name: customer_key
        tests:
          - not_null
          - relationships:
              to: ref('dim_customer')
              field: customer_key
      - name: amount
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"


              -- Airflow DAG básico
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

with DAG('sales_pipeline', start_date=datetime(2024,1,1),
         schedule_interval='@daily', catchup=False) as dag:

    extract = PythonOperator(task_id='extract_raw', python_callable=run_extract)
    transform = PythonOperator(task_id='run_dbt', python_callable=run_dbt_build)
    validate = PythonOperator(task_id='run_tests', python_callable=run_dbt_test)


    -- schema.yml completo con todos los tests
models:
  - name: fact_transactions
    description: "Transacciones financieras limpias"
    columns:
      - name: transaction_id
        tests: [unique, not_null]

      - name: customer_key
        tests:
          - not_null
          - relationships:
              to: ref('dim_customer')
              field: customer_key     # orphan check

      - name: transaction_type
        tests:
          - accepted_values:
              values: ['PURCHASE','REFUND','TRANSFER','FEE']

      - name: amount
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "!= 0"

      - name: transaction_date
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "<= current_date"  # no future dates

    tests:
      # Test a nivel de modelo (combinación de columnas)
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns: [transaction_date, customer_key, transaction_type]

          # Great Expectations — ejemplo básico
import great_expectations as ge
df = ge.read_csv("transactions.csv")
df.expect_column_values_to_not_be_null("customer_id")
df.expect_column_values_to_be_between("amount", 0, 1_000_000)
df.expect_column_values_to_be_unique("transaction_id")
results = df.validate()  # retorna pass/fail por expectation