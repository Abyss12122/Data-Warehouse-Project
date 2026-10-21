/*
===============================================================================
Database Initialization Script
===============================================================================
Script Purpose:
    This script initializes the DataWarehouse database environment.
    - Drops and recreates the "DataWarehouse" database if it already exists.
    - Creates the Medallion Architecture schemas: bronze, silver, and gold.

WARNING:
    Running this script will drop the existing "DataWarehouse" database.
    All data inside will be permanently deleted.
===============================================================================
*/

-- ----------------------------------------------------------------------------
-- 1. Database Creation
-- Note: Run these commands while connected to the default 'postgres' database.
-- ----------------------------------------------------------------------------

-- Disconnect any active connections to "DataWarehouse" to allow dropping
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'DataWarehouse'
  AND pid <> pg_backend_pid();

-- Drop existing database if present
DROP DATABASE IF EXISTS "DataWarehouse";

-- Create database
CREATE DATABASE "DataWarehouse";


-- ----------------------------------------------------------------------------
-- 2. Schema Creation
-- Note: Switch your connection to "DataWarehouse" before running these lines.
-- ----------------------------------------------------------------------------

-- Create Medallion Architecture schemas
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
