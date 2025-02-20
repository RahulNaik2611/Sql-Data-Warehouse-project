/*
	===============================================================
	DDL Script : Create Bronze Table 
	===============================================================
	Script purpose 
		This Script create table in the 'bronze' schema ,dropping existing tables
		if they already exist.
		Run this Script to re-define the DDL Structure of 'bronze' Table

*/


if OBJECT_ID ('bronze.crm_cust_info' , 'U') IS NOT NULL
		Drop Table bronze.crm_cust_info;

Create Table  bronze.crm_cust_info (
cst_id INT,
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(50),
cst_lastname NVARCHAR(50),
cst_marital_status NVARCHAR(50),
cst_gndr NVARCHAR(50),
cst_create_date DATE
);

if OBJECT_ID ('bronze.crm_prd_info' , 'U') IS NOT NULL
		Drop Table bronze.crm_prd_info;

CREATE Table bronze.crm_prd_info(
prd_id INT ,
prd_key NVARCHAR(50),
prd_nm NVARCHAR(50),
prd_cost INT,
prd_line NVARCHAR(50),
prd_start_dt NVARCHAR(50),
prd_end_dt NVARCHAR(50)
);

if OBJECT_ID ('bronze.crm_sales_details' , 'U') IS NOT NULL
		Drop Table bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details(
sls_ord_num NVARCHAR(50),
sls_prd_key NVARCHAR(50),
sls_cust_id INT,
sls_order_dt INT,  
sls_ship_dt INT,
sls_due_dt INT,
sls_sales INT,
sls_quantity INT,
sls_price INT
);

if OBJECT_ID ('bronze.erp_loc_a101' , 'U') IS NOT NULL
		Drop Table bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101(
CID	 NVarchar(50),
CNTRY  NVarchar(50)
);

if OBJECT_ID ('bronze.erp_cust_az12' , 'U') IS NOT NULL
		Drop Table bronze.erp_cust_az12;

Create Table bronze.erp_cust_az12(
CID NVarchar(50),
BDATE DATE,
GEN NVarchar(50),

);

if OBJECT_ID ('bronze.erp_px_cat_g1v2' , 'U') IS NOT NULL
		Drop Table bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2(
ID   NVarchar(50),
CAT  NVarchar(50),
SUBCAT  NVarchar(50),
MAINTENANCE  NVarchar(50)
);
