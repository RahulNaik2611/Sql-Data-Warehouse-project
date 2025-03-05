
/*
============================================================================================================
DDL Script : Creeate Sliver Table

=============================================================================================================
Script purpose :
		This Script Create table in the 'sliver Schema ,Dropping Existing Table 
		if they Already exist
		Run this script to re-Define the DDl Structure of 'bronze' Table
===============================================================================================================
*/



if OBJECT_ID ('sliver.crm_cust_info' , 'U') IS NOT NULL
		Drop Table sliver.crm_cust_info;

Create Table  sliver.crm_cust_info (
cst_id INT,
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(50),
cst_lastname NVARCHAR(50),
cst_marital_status NVARCHAR(50),
cst_gndr NVARCHAR(50),
cst_create_date DATE,
dwh_create_date DATETIME2 DEFAULT GetDate()
);

if OBJECT_ID ('sliver.crm_prd_info' , 'U') IS NOT NULL
		Drop Table sliver.crm_prd_info;

CREATE Table sliver.crm_prd_info(
prd_id INT ,
cat_id NVarchar(50),
prd_key NVARCHAR(50),
prd_nm NVARCHAR(50),
prd_cost INT,
prd_line NVARCHAR(50),
prd_start_dt DATE,
prd_end_dt DATE,
dwh_create_date DATETIME2 DEFAULT GetDate()
);

if OBJECT_ID ('sliver.crm_sales_details' , 'U') IS NOT NULL
		Drop Table sliver.crm_sales_details;

CREATE TABLE sliver.crm_sales_details(
sls_ord_num NVARCHAR(50),
sls_prd_key NVARCHAR(50),
sls_cust_id INT,
sls_order_dt Date,  
sls_ship_dt Date,
sls_due_dt Date,
sls_sales INT,
sls_quantity INT,
sls_price INT,
dwh_create_date DATETIME2 DEFAULT GetDate()
);

if OBJECT_ID ('sliver.erp_loc_a101' , 'U') IS NOT NULL
		Drop Table sliver.erp_loc_a101;

CREATE TABLE sliver.erp_loc_a101(
CID	 NVarchar(50),
CNTRY  NVarchar(50),
dwh_create_date DATETIME2 DEFAULT GetDate()
);

if OBJECT_ID ('sliver.erp_cust_az12' , 'U') IS NOT NULL
		Drop Table sliver.erp_cust_az12;

Create Table sliver.erp_cust_az12(
CID NVarchar(50),
BDATE DATE,
GEN NVarchar(50),
dwh_create_date DATETIME2 DEFAULT GetDate()

);

if OBJECT_ID ('sliver.erp_px_cat_g1v2' , 'U') IS NOT NULL
		Drop Table sliver.erp_px_cat_g1v2;

CREATE TABLE sliver.erp_px_cat_g1v2(
ID   NVarchar(50),
CAT  NVarchar(50),
SUBCAT  NVarchar(50),
MAINTENANCE  NVarchar(50),
dwh_create_date DATETIME2 DEFAULT GetDate()
);
