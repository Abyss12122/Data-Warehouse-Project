/*
===============================================================================
Quality Checks: Silver Layer
===============================================================================
Script Purpose:
    This script verifies the data quality, integrity, and consistency of 
    the 'silver' schema tables after running the ingestion pipeline.
    
    Checks Performed:
    - Primary key uniqueness and nullability
    - Unwanted leading/trailing whitespace in string columns
    - Categorical/domain value standardization
    - Logical date order and boundary validations
    - Mathematical consistency across financial/sales metrics

Expectation:
    All validation queries should return 0 rows (unless checking distinct 
    domain values, which should only display standard, cleaned categories).
===============================================================================
*/

-- ============================================================================
-- 1. Checking 'silver.crm_cust_info'
-- ============================================================================

-- Primary Key Validation: Uniqueness & Non-nullability (Expectation: 0 rows)
SELECT 
    cst_id, 
    COUNT(*) AS duplicate_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Whitespace Check: Leading or trailing spaces in text fields (Expectation: 0 rows)
SELECT cst_firstname 
FROM silver.crm_cust_info
WHERE cst_firstname <> TRIM(cst_firstname);

SELECT cst_lastname 
FROM silver.crm_cust_info
WHERE cst_lastname <> TRIM(cst_lastname);

-- Data Consistency: Domain values for marital status (Expectation: Only 'Single', 'Married', 'n/a')
SELECT DISTINCT cst_marital_status 
FROM silver.crm_cust_info;

-- Data Consistency: Domain values for gender (Expectation: Only 'Female', 'Male', 'n/a')
SELECT DISTINCT cst_gndr 
FROM silver.crm_cust_info;


-- ============================================================================
-- 2. Checking 'silver.crm_prd_info'
-- ============================================================================

-- Primary Key Validation: Uniqueness & Non-nullability (Expectation: 0 rows)
SELECT 
    prd_id, 
    COUNT(*) AS duplicate_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Whitespace Check: Product names (Expectation: 0 rows)
SELECT prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm <> TRIM(prd_nm);

-- Numerical Quality: Check for negative costs (Expectation: 0 rows)
SELECT * 
FROM silver.crm_prd_info
WHERE prd_cost < 0;

-- Data Consistency: Domain values for product line (Expectation: 'Mountain', 'Road', 'Other Sales', 'Touring', 'n/a')
SELECT DISTINCT prd_line 
FROM silver.crm_prd_info;

-- Logical Date Order: End date must be on or after start date (Expectation: 0 rows)
SELECT * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- ============================================================================
-- 3. Checking 'silver.crm_sales_details'
-- ============================================================================

-- Referential / Foreign Key Integrity: Product key exists in silver.crm_prd_info (Expectation: 0 rows)
SELECT sls_prd_key 
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

-- Referential / Foreign Key Integrity: Customer ID exists in silver.crm_cust_info (Expectation: 0 rows)
SELECT sls_cust_id 
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

-- Logical Date Order: Order date must be on or before ship date and due date (Expectation: 0 rows)
SELECT * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Business Rule Validation: Sales = Quantity * Price, with no nulls, zeros, or negatives (Expectation: 0 rows)
SELECT 
    sls_ord_num,
    sls_sales, 
    sls_quantity, 
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales <> (sls_quantity * sls_price)
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL;


-- ============================================================================
-- 4. Checking 'silver.erp_cust_az12'
-- ============================================================================

-- Boundary Validation: Future birthdates (Expectation: 0 rows)
SELECT * 
FROM silver.erp_cust_az12
WHERE bdate > CURRENT_DATE;

-- Data Consistency: Domain values for gender (Expectation: Only 'Female', 'Male', 'n/a')
SELECT DISTINCT gen 
FROM silver.erp_cust_az12;


-- ============================================================================
-- 5. Checking 'silver.erp_loc_a101'
-- ============================================================================

-- Referential / Foreign Key Integrity: Normalized CID matches customer key (Expectation: 0 rows)
SELECT cid 
FROM silver.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);

-- Data Consistency: Domain values for country (Expectation: Clean country names, no 'DE', 'US', 'USA', or empty strings)
SELECT DISTINCT cntry 
FROM silver.erp_loc_a101;


-- ============================================================================
-- 6. Checking 'silver.erp_px_cat_g1v2'
-- ============================================================================

-- Whitespace Check: Unwanted spaces in categories, subcategories, or maintenance (Expectation: 0 rows)
SELECT * 
FROM silver.erp_px_cat_g1v2
WHERE cat <> TRIM(cat) 
   OR subcat <> TRIM(subcat) 
   OR maintenance <> TRIM(maintenance);

-- Data Consistency: Domain values for maintenance (Expectation: Only 'Yes', 'No')
SELECT DISTINCT maintenance 
FROM silver.erp_px_cat_g1v2;
