/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
ROW_NUMBER() OVER(ORDER BY ci.cst_id) customer_key,
ci.cst_id customer_id,
ci.cst_key,
ci.cst_firstname first_name,
ci.cst_lastname last_name,
la.cntry country,
ci.cst_marital_status marital_status,
CASE 
    WHEN ci.cst_gndr != 'Unknown' THEN ci.cst_gndr
    ELSE COALESCE(ca.gen,'n/a')
END gender,
ca.bdate birthdate,
ci.cst_create_date create_date
FROM silver.crm_cust_info ci LEFT JOIN silver.erp_cust_az12 ca 
ON ci.cst_key=ca.cid
LEFT JOIN silver.erp_loc_a101 la 
ON ci.cst_key=la.cid
GO

SELECT * FROM gold.dim_customers
-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt,pn.prd_key) AS product_key,
    pn.prd_id product_id,
    pn.prd_key product_number,
    pn.prd_nm product_name,
    pn.cat_id category_id,
    pc.cat category,
    pc.subcat subcategory,
    pc.maintenance,
    pn.prd_cost cost,
    pn.prd_line product_line,
    pn.prd_start_dt start_date
FROM silver.crm_prd_info pn LEFT JOIN silver.erp_px_cat_g1v2 pc 
ON pn.cat_id=pc.id
WHERE prd_end_dt IS NULL 
GO

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT 
    sls_ord_num order_number,
    pr.product_key,
    cu.customer_key,
    sls_order_dt order_date,
    sls_ship_dt shipping_date,
    sls_due_dt due_date,
    sls_sales sales_amount,
    sls_quantity quantity,
    sls_price price 
FROM silver.crm_sales_details sd LEFT JOIN gold.dim_products pr 
ON sd.sls_prd_key=pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id=cu.customer_id
GO


