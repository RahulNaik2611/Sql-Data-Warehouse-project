/*
	===========================================================================
	Stored procedure : load Bronze Layer (Source---> Bronze )
	===========================================================================
	Script purpose 
		This Stored procedure loads data into the 'bronze' schema from external CSV file
		it perform the following Actions:
		--Truncatethe bronze table before loading data 
		--uses the 'Bulk Insert' command to load data for csv File to bronze tables.


	parameters
		None.
	This Store procedure does not accept any parameters or return any values 

	usage Example:
		Exec bronze.load_bronze

	===========================================================================

*/

--Store procedure
Create or alter procedure bronze.load_bronze as 
Begin
	DECLARE @Start_time DateTime, @end_time DateTime , @batch_start_time datetime, @batch_end_time DATETIME;

	Begin Try
	SET @batch_start_time = GETDATE();
--Refreshing 
---Message
		print '=====================================================================';
		print 'Loading Bronze layer '
		print '=====================================================================';
		
--Refreshing 
---Bulk insert 
		print '----------------------------------------------------------------------';
		print ' Loading CRM Tables'
		print '----------------------------------------------------------------------';
		
		set @Start_time = GETDATE();

		print '>> Truncating Table : [bronze].[crm_cust_info]';

		Truncate Table [bronze].[crm_cust_info]

		BULK INSERT [bronze].[crm_cust_info] 
		FROM 
		'C:\Users\rahul\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
	
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK

		);

		set @end_time = GETDATE();
		print '>> Load Duration : ' + cast( DateDiff(Second,@Start_time,@end_time) as nvarchar) + 'Seconds';
		print '---------------------------'

		------------------------------------------------------------------------------------------------------------------------------
		set @Start_time = GETDATE();
		print '>> Truncating Table : [bronze].[crm_prd_info]';

		

		Truncate Table [bronze].[crm_prd_info]

		BULK INSERT [bronze].[crm_prd_info]
		FROM 
		'C:\Users\rahul\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
	
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK

		);

		set @end_time = GETDATE();
		print '>> Load Duration : ' + cast( DateDiff(Second,@Start_time,@end_time) as nvarchar) + 'Seconds';
		print '---------------------------'



	

		---------------------------------------------------------------------------------------------------------------------------------
		set @Start_time = GETDATE();
		print '>> Truncating Table : [bronze].[crm_sales_details]';

		Truncate Table [bronze].[crm_sales_details]

		BULK INSERT  [bronze].[crm_sales_details]
		FROM 
		'C:\Users\rahul\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
	
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK

		);


		set @end_time = GETDATE();
		print '>> Load Duration : ' + cast( DateDiff(Second,@Start_time,@end_time) as nvarchar) + 'Seconds';
		print '---------------------------'

		--------------------------------------------------------------------------------------------------------------------------
		print '----------------------------------------------------------------------';
		print 'Loading ERP Tables'
		print '----------------------------------------------------------------------';

		set @Start_time = GETDATE();
		print '>> Truncating Table : [bronze].[erp_cust_az12] ';
		Truncate Table [bronze].[erp_cust_az12]

		BULK INSERT [bronze].[erp_cust_az12]
		FROM 
		'C:\Users\rahul\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
	
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK

		);


		set @end_time = GETDATE();
		print '>> Load Duration : ' + cast( DateDiff(Second,@Start_time,@end_time) as nvarchar) + 'Seconds';
		print '---------------------------'

		----------------------------------------------------------------------------------------------------------------------
		print '>> Truncating Table : [bronze].[erp_loc_a101]';

		set @Start_time = GETDATE();
		Truncate Table [bronze].[erp_loc_a101]

		BULK INSERT [bronze].[erp_loc_a101]
		FROM 
		'C:\Users\rahul\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
	
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK

		);

		set @end_time = GETDATE();
		print '>> Load Duration : ' + cast( DateDiff(Second,@Start_time,@end_time) as nvarchar) + 'Seconds';
		print '---------------------------'

		--------------------------------------------------------------------------------------------------------------------------
		print '>> Truncating Table : [bronze].[erp_px_cat_g1v2]';

		set @Start_time = GETDATE();

		Truncate Table [bronze].[erp_px_cat_g1v2]

		BULK INSERT [bronze].[erp_px_cat_g1v2]
		FROM 
		'C:\Users\rahul\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
	
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK

		);
		set @end_time = GETDATE();
		print '>> Load Duration : ' + cast( DateDiff(Second,@Start_time,@end_time) as nvarchar) + 'Seconds';
		print '---------------------------'



		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Bronze Layer is Completed';
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

