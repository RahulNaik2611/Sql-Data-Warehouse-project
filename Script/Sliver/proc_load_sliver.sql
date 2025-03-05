/*
	==========================================================================================
	
		Stored procedure: Load Sliver Layer (Bronze --> Sliver)
	
	==========================================================================================
	Script purpose :
			This stored procedure performs the ETL (Extract ,Transform,Load) process to 
			populate the 'sliver' Schema From the 'bronze' Schema.
	Action performed :
			-Truncate Sliver Tables 
			-Insert transformed and cleansed data from Bronze into sliver Tables.




	parameters :
		None.
		This Stored procedure does not accept any parameters or return any values
		
		
	usage Example:
	Exec Sliver.load_sliver;
	==========================================================================================

*/

Create or alter procedure sliver.load_sliver As
Begin 
	DECLARE @Start_time DateTime, @end_time DateTime , @batch_start_time datetime, @batch_end_time DATETIME;

	Begin Try
	SET @batch_start_time = GETDATE();
--Refreshing 
---Message
		print '=====================================================================';
		print 'Loading sliver layer '
		print '=====================================================================';
		
--Refreshing 
---Bulk insert 
		print '----------------------------------------------------------------------';
		print ' Loading CRM Tables'
		print '----------------------------------------------------------------------';
		
		set @Start_time = GETDATE();

	print '>> TRUNCATING Table:[sliver].[crm_cust_info]'
	Truncate Table [sliver].[crm_cust_info];
	PRINT '>>Inserting Data into :[sliver].[crm_cust_info]'
	insert into [sliver].[crm_cust_info] 
	([cst_id],[cst_key],[cst_firstname],[cst_lastname],[cst_marital_status],[cst_gndr],[cst_create_date])
	SELECT 
		[cst_id],
		[cst_key],
		TRIM([cst_firstname]) AS cst_firstname,
		TRIM([cst_lastname]) AS cst_lastname,
		  CASE 
			WHEN UPPER(TRIM([cst_marital_status])) = 'S' THEN 'Single'
			WHEN UPPER(TRIM([cst_marital_status])) = 'M' THEN 'Married'
			ELSE 'n/a'
		END AS marital_status ,
		CASE 
			WHEN UPPER(TRIM([cst_gndr])) = 'F' THEN 'Female'
			WHEN UPPER(TRIM([cst_gndr])) = 'M' THEN 'Male'
			ELSE 'n/a'
		END AS Gender,  -- Added alias for the CASE statement
		[cst_create_date]
	FROM (
		SELECT *,
			ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS Flag_last
		FROM [bronze].[crm_cust_info]
	) t WHERE Flag_last = 1;

		set @end_time = GETDATE();
		print '>> Load Duration : ' + cast( DateDiff(Second,@Start_time,@end_time) as nvarchar) + 'Seconds';
		print '---------------------------'

	-------------------------------------------------------------------------------------------------------------------------------------
	--TRANSFORMATIONS  sliver.PRD_INFO TABLE 
	set @Start_time = GETDATE();
	print '>> TRUNCATING Table:[sliver].[crm_prd_info] '
	Truncate Table [sliver].[crm_prd_info];
	PRINT '>>Inserting Data into :[sliver].[crm_prd_info]'
	INSERT INTO sliver.crm_prd_info (prd_id, prd_key, cat_id, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
	SELECT 
		[prd_id],
		SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,  -- Adjusted to match the INSERT column
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
		[prd_nm],
		ISNULL([prd_cost], 0) AS prd_cost,
		CASE UPPER(TRIM(prd_line)) 
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road'
			WHEN 'S' THEN 'Other sales'
			WHEN 'T' THEN 'Touring'
			ELSE 'n/a'
		END AS prd_line,
		CAST(prd_start_dt AS DATE) AS prd_start_dt,
		DATEADD(DAY, -1, LEAD(CAST(prd_start_dt AS DATE)) OVER (PARTITION BY prd_key ORDER BY CAST(prd_start_dt AS DATE))) AS prd_end_dt
	FROM [bronze].[crm_prd_info];
	--where Replace(substring(prd_key,1,5),'-','_') NOT IN (select distinct id from [bronze].[erp_px_cat_g1v2]) --Find for its not matching caterioges
	--where SUBSTRING(prd_key,7,len(prd_key))  in (Select sls_prd_key From [bronze].[crm_sales_details])

	
		set @end_time = GETDATE();
		print '>> Load Duration : ' + cast( DateDiff(Second,@Start_time,@end_time) as nvarchar) + 'Seconds';
		print '---------------------------'



	------------------------------------------------------------------------------------------------------------------------------------


	--Tranformation of Sliver.crm_sales_details
	set @Start_time = GETDATE();
	print '>> TRUNCATING Table:[sliver].[crm_sales_details] '
	Truncate Table [sliver].[crm_sales_details];
	PRINT '>>Inserting Data into :[sliver].[crm_sales_details]'
	insert into sliver.crm_sales_details(
											sls_ord_num,
											sls_prd_key,
											sls_cust_id,
											sls_order_dt,
											sls_ship_dt,
											sls_due_dt,
											sls_sales,
											sls_quantity,
											sls_price
										)

	Select		sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				case when sls_order_dt= 0 or LEN(sls_order_dt)!=8 Then Null
					Else Cast(cast(sls_order_dt as varchar) as date)
				End as sls_order_dt,
				case when sls_ship_dt= 0 or LEN(sls_ship_dt)!=8 Then Null
					Else Cast(cast(sls_ship_dt as varchar) as date)
				End as sls_ship_dt,
				case when sls_due_dt= 0 or LEN(sls_due_dt)!=8 Then Null
					Else Cast(cast(sls_due_dt as varchar) as date)
				End as sls_due_dt,
				Case when sls_sales is null or sls_sales <=0  or sls_sales != sls_quantity * ABS(sls_price)
					Then sls_quantity * ABS(sls_price)
					Else sls_sales
				End as sls_sales,
				sls_quantity,
				Case  when sls_price is null or sls_price <= 0 
					Then sls_sales /Nullif(sls_quantity,0)
					Else sls_price
				End as sls_price
	From bronze.crm_sales_details
	
		set @end_time = GETDATE();
		print '>> Load Duration : ' + cast( DateDiff(Second,@Start_time,@end_time) as nvarchar) + 'Seconds';
		print '---------------------------'



	---------------------------------------------------------------------------------------------------------------------------------


	---Transformation ([bronze].[erp_cust_az12] into [sliver].[erp_cust_az12] )
	set @Start_time = GETDATE();
	print '>> TRUNCATING Table:[sliver].[erp_cust_az12]'
	Truncate Table [sliver].[erp_cust_az12];
	PRINT '>>Inserting Data into :[sliver].[erp_cust_az12]'
	insert into sliver.erp_cust_az12(CID,BDATE,GEN)
	Select 
		Case When cid Like 'NAS%' Then SUBSTRING(cid,4,Len(cid))
			Else  Cid
		End As cid,
		Case when bdate > GETDATE()  Then Null 
			Else bdate
		End as bdate,
		Case when Upper(Trim(gen)) In ('F' , 'Female') Then 'Female'
			 when Upper(Trim(gen)) In ('M' , 'Male') Then 'Male'
			 Else 'n/a'
		End as gen
	From [bronze].[erp_cust_az12]

	
		set @end_time = GETDATE();
		print '>> Load Duration : ' + cast( DateDiff(Second,@Start_time,@end_time) as nvarchar) + 'Seconds';
		print '---------------------------'



	--------------------------------------------------------------------------------------------------------------------------------


	---Transformations [sliver].[erp_loc_a101]
	set @Start_time = GETDATE();
	print '>> TRUNCATING Table:[sliver].[erp_loc_a101]'
	Truncate Table [sliver].[erp_loc_a101];
	PRINT '>>Inserting Data into :[sliver].[erp_loc_a101]'
	insert into sliver.erp_loc_a101(CID,CNTRY)
	Select
		REPLACE(cid,'-','') cid,
		Case when Trim(cntry)= 'DE' Then 'Germany'
			 when Trim(cntry) IN ('US','USA') Then 'United States'
			 when Trim(cntry)= '' or CNTRY is null then 'n/a'
			 ELSE Trim(cntry)
		End cntry
	From [bronze].[erp_loc_a101]

	
		set @end_time = GETDATE();
		print '>> Load Duration : ' + cast( DateDiff(Second,@Start_time,@end_time) as nvarchar) + 'Seconds';
		print '---------------------------'



	
	------------------------------------------------------------------------------------------------------------------------------
	set @Start_time = GETDATE();
	print '>> TRUNCATING Table:[sliver].[erp_px_cat_g1v2]'
	Truncate Table [sliver].[erp_px_cat_g1v2];
	PRINT '>>Inserting Data into :[sliver].[erp_px_cat_g1v2]'
	insert into sliver.erp_px_cat_g1v2 (id,CAT,SUBCAT,MAINTENANCE)
	Select 
			id,CAT,SUBCAT,MAINTENANCE
	From [bronze].[erp_px_cat_g1v2]
	
		set @end_time = GETDATE();
		print '>> Load Duration : ' + cast( DateDiff(Second,@Start_time,@end_time) as nvarchar) + 'Seconds';
		print '---------------------------'


		
		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading sliver Layer is Completed';
        PRINT '- Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='


		End Try
			Begin  Catch 
			print '===============================================================';
			print 'Error Occured During Loading Bronze Layer ';
			print 'Error Message ' + ERROR_MESSAGE();
			print 'Error Message ' +cast( ERROR_Number() as NVarchar);
			PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
			print '===============================================================';
			  End catch

End
