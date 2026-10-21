/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads raw data from local CSV files into the 'bronze' 
    schema tables (CRM and ERP source systems).
    
    Actions performed:
    - Truncates existing bronze tables (full load approach).
    - Ingests data via the PostgreSQL COPY command.
    - Measures and logs individual table execution durations.
    - Measures and logs the total batch run duration.
    - Catches and logs exceptions using PL/pgSQL error handling.

Parameters:
    None.

Usage Example:
    CALL bronze.load_bronze();
===============================================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_time        TIMESTAMP;
    v_end_time          TIMESTAMP;
    v_batch_start_time  TIMESTAMP;
    v_batch_end_time    TIMESTAMP;
BEGIN
    v_batch_start_time := clock_timestamp();

    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '===========================================';

    -- ========================================================================
    -- Loading CRM Tables
    -- ========================================================================
    RAISE NOTICE '-------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '-------------------------------------------';

    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;
    RAISE NOTICE '>> Inserting Into: bronze.crm_cust_info';
    COPY bronze.crm_cust_info
    FROM 'D:/Work/Projects/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration % seconds', ROUND(EXTRACT(EPOCH FROM(v_end_time - v_start_time))::numeric, 2);
    RAISE NOTICE '--------------------------------------------';
    
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;
    RAISE NOTICE '>> Inserting Into: bronze.crm_prd_info';
    COPY bronze.crm_prd_info
    FROM 'D:/Work/Projects/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration % seconds', ROUND(EXTRACT(EPOCH FROM(v_end_time - v_start_time))::numeric, 2);
    RAISE NOTICE '--------------------------------------------';
    
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;
    RAISE NOTICE '>> Inserting Into: bronze.crm_sales_details';
    COPY bronze.crm_sales_details
    FROM 'D:/Work/Projects/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration % seconds', ROUND(EXTRACT(EPOCH FROM(v_end_time - v_start_time))::numeric, 2);
    RAISE NOTICE '--------------------------------------------';
    
    -- ========================================================================
    -- Loading ERP Tables
    -- ========================================================================
    RAISE NOTICE '-------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '-------------------------------------------';
    
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';
    TRUNCATE TABLE bronze.erp_cust_az12;
    RAISE NOTICE '>> Inserting Into: bronze.erp_cust_az12';
    COPY bronze.erp_cust_az12
    FROM 'D:/Work/Projects/sql-data-warehouse-project/datasets/source_erp/cust_az12.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration % seconds', ROUND(EXTRACT(EPOCH FROM(v_end_time - v_start_time))::numeric, 2);
    RAISE NOTICE '--------------------------------------------';
    
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';
    TRUNCATE TABLE bronze.erp_loc_a101;
    RAISE NOTICE '>> Inserting Into: bronze.erp_loc_a101';
    COPY bronze.erp_loc_a101
    FROM 'D:/Work/Projects/sql-data-warehouse-project/datasets/source_erp/loc_a101.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration % seconds', ROUND(EXTRACT(EPOCH FROM(v_end_time - v_start_time))::numeric, 2);
    RAISE NOTICE '--------------------------------------------';
    
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    RAISE NOTICE '>> Inserting Into: bronze.erp_px_cat_g1v2';
    COPY bronze.erp_px_cat_g1v2
    FROM 'D:/Work/Projects/sql-data-warehouse-project/datasets/source_erp/px_cat_g1v2.csv'
    WITH (FORMAT csv, HEADER true, DELIMITER ',');
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration % seconds', ROUND(EXTRACT(EPOCH FROM(v_end_time - v_start_time))::numeric, 2);
    RAISE NOTICE '--------------------------------------------';

    -- ========================================================================
    -- Batch Summary
    -- ========================================================================
    v_batch_end_time := clock_timestamp();
    RAISE NOTICE '===============================================';
    RAISE NOTICE '>> Load Duration of Bronze layer % seconds', ROUND(EXTRACT(EPOCH FROM(v_batch_end_time - v_batch_start_time))::numeric, 2);
    RAISE NOTICE '===============================================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '--------------------------------------';
        RAISE NOTICE 'ERROR OCCURED DURING BRONZE LAYER';
        RAISE NOTICE 'Error Message: %', SQLERRM;
        RAISE NOTICE 'Error State: %', SQLSTATE;
        RAISE NOTICE '--------------------------------------';
        RAISE;

END;
$$;
