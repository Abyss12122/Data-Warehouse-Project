/*
===============================================================================
Quality Checks: Gold Layer
===============================================================================
Script Purpose:
    This script validates the data integrity, uniqueness, and star schema 
    referential connectivity of the 'gold' schema views.

Checks:
    - Surrogate key uniqueness in dimensions
    - Referential integrity / foreign key match from Fact -> Dimensions
===============================================================================
*/

-- ============================================================================
-- 1. Check Dimension Uniqueness (Surrogate Key)
-- ============================================================================

-- Expectation: 0 rows (customer_key must be unique)
SELECT 
    customer_key, 
    COUNT(*) AS count_records
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- Expectation: 0 rows (product_key must be unique)
SELECT 
    product_key, 
    COUNT(*) AS count_records
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- ============================================================================
-- 2. Check Fact -> Dimension Referential Integrity (Foreign Keys)
-- ============================================================================

-- Expectation: 0 rows (Every sale must map to an existing customer)
SELECT 
    f.order_number,
    f.customer_key
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;

-- Expectation: 0 rows (Every sale must map to an existing product)
SELECT 
    f.order_number,
    f.product_key
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
WHERE p.product_key IS NULL;
