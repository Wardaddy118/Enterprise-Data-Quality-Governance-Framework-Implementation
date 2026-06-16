# Knowledge: Business Rules – DQ Framework

## Completeness (C-*)
- **C-001** CRITICAL: `name IS NOT NULL AND trim(name) != ''`
- **C-002** CRITICAL: `id IS NOT NULL AND trim(id) != ''`
- **C-003** HIGH: `industry IS NOT NULL`
- **C-004** HIGH: `country IS NOT NULL`

## Uniqueness (U-*)
- **U-001** CRITICAL: No duplicate `id` within same `batch_id`

## Validity (V-*)
- **V-001** HIGH: `size IN ('1-10','11-50','51-200','201-500','501-1000','1001-5000','5001-10000','10001+')`
- **V-002** MEDIUM: `founded >= 1800 AND founded <= YEAR(CURRENT_DATE())`
- **V-003** HIGH: `try_cast(revenue_raw as double) IS NOT NULL` – valores como `$450,000` son inválidos
- **V-004** LOW: `website RLIKE '^https?://.+'` OR NULL
- **V-005** HIGH: `country = 'Costa Rica'`

## Referential Integrity (R-*)
- **R-001** MEDIUM: `industry` debe existir en tabla de referencia de industrias

## Consistency (CO-*)
- **CO-001** HIGH: `founded <= YEAR(CURRENT_DATE())`
- **CO-002** MEDIUM: Si `region IS NOT NULL` entonces `locality IS NOT NULL`

## Business Rules (BR-*)
- **BR-001** LOW: `linkedin_url IS NULL OR linkedin_url RLIKE '^https://www.linkedin.com/.+'`
- **BR-002** MEDIUM: Si `region IS NOT NULL` entonces `locality IS NOT NULL`
