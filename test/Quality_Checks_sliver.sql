--Quality Checking 
--Check For Nulls or Duplicate in primary key 
--Expectation: No result 
/*=====================================================================================================

	Checking: [sliver].[crm_cust_info]

=======================================================================================================
*/

Select * From [sliver].[crm_cust_info]

--Check For Nulls or Duplicate in primary key 
Select cst_id,count(*) as countingPrimary From [sliver].[crm_cust_info]
Group by cst_id
having count(*) > 1 or cst_id is null


--Data_transformaction and data_Cleaning

Select * From [sliver].[crm_cust_info]
where cst_id in (29449,
29473,
29433,
NULL,
29483,
29466)

----------------------------------------------------------------------------------------------------
--Checking Duplicate 

Select cst_id,
Count(*)
FROM [sliver].[crm_cust_info]
gROUP BY cst_id
having count(*) > 1 or cst_id is null


Select *
From(
	Select *,
	ROW_NUMBER() over(partition by cst_id order by cst_create_date) as Flag_Checking
	From [sliver].[crm_cust_info]
)t where Flag_Checking !=1  ---no RESULT
-------------------------------------------------------------------------------------------------
---Checking Extra Space in Column 
--Expectation : NO Result 

Select [cst_firstname] ,[cst_lastname]
From [sliver].[crm_cust_info] 
where[cst_firstname]  != Trim([cst_firstname])  --no RESULT


Select [cst_lastname]
From [sliver].[crm_cust_info]
where [cst_lastname] != Trim([cst_lastname]) --no RESULT 


Select [cst_gndr]
From [sliver].[crm_cust_info] 
where  [cst_gndr]!= Trim([cst_gndr])  --no Extra Space


----------------------------------------------------------------------------------------------
--Data Standardization & Consistency

Select  distinct [cst_gndr]
From [sliver].[crm_cust_info]

Select distinct ([cst_marital_status])
From [sliver].[crm_cust_info]

--------------------------------------------------------------------------------------------------------------------------

/*=====================================================================================================

	Checking: [bronze].[crm_prd_info]

=======================================================================================================
*/
Select * From [bronze].[crm_prd_info]

---Checking  Duplicate in table 
--Expections : no result 

Select prd_id,
Count(*) as CountDuplicate
From [bronze].[crm_prd_info]
Group by prd_id
having count(*) >1 or prd_id is null ---no result


--Checking unwanted Spaces
--Expectation : no Result
SELECT prd_nm
From[bronze].[crm_prd_info]
where prd_nm !=TRIM(Prd_nm)  -- no Result


--Check for Nulls or Negative Numbers
--Expectation: No Result 

Select prd_cost
From bronze.crm_prd_info
where prd_cost < 0 or prd_cost is  null


--Data Stamdardization & Consistency 
Select  Distinct prd_line
From bronze.crm_prd_info


--Check for Invalid Date Orders

Select * 
From bronze.crm_prd_info
where prd_end_dt < prd_start_dt

---Check the Start date and End Date 

Select prd_id,
	   prd_key,
	   prd_nm,
	   prd_start_dt,
	   prd_end_dt,
	   LEAD(prd_start_dt) over(partition by prd_key order by prd_start_dt)-1 as prd_end_dt_test
fROM bronze.crm_prd_info
where prd_key in ('AC-HE-HL-U509-R', 'AC-HE-HL-U509')


SELECT prd_id,
       prd_key,
       prd_nm,
       CAST(prd_start_dt AS DATE) AS prd_start_dt,
        CAST (LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509');

-------------------------------------------------------------------------------------------------------------------------------
---Checking or Testing Data In  sLIVER.prd_info

---Checking  Duplicate in table 
--Expections : no result 

Select prd_id,
Count(*) as CountDuplicate
From [sliver].[crm_prd_info]
Group by prd_id
having count(*) >1 or prd_id is null ---no result

--Checking unwanted Spaces
--Expectation : no Result
SELECT prd_nm
From[sliver].[crm_prd_info]
where prd_nm !=TRIM(Prd_nm)  -- no Result


--Check for Nulls or Negative Numbers
--Expectation: No Result 

Select prd_cost
From sliver.crm_prd_info
where prd_cost < 0 or prd_cost is  null  --No Result 


--Data Stamdardization & Consistency 
Select  Distinct prd_line
From sliver.crm_prd_info  -- Perfect 


--Check for Invalid Date Orders

Select * 
From sliver.crm_prd_info
where prd_end_dt < prd_start_dt


--Checking Total Table 
Select * From sliver.crm_prd_info


---------------------------------------------------------------------------------------------------------------------


--Cleaning The data un the  'bronze.crm_sales_details'
/*=====================================================================================================

	Checking: [sliver].crm_sales_details

=======================================================================================================
*/

Select * From bronze.crm_sales_details

--Checking Extra Spaces 
Select      sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt ,
			sls_sales  ,
			sls_quantity,
			sls_price
From  bronze.crm_sales_details
where sls_ord_num  != TRIM(sls_ord_num)

--Checking Connections 
Select		sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt ,
			sls_sales  ,
			sls_quantity,
			sls_price
From bronze.crm_sales_details
Where sls_prd_key in (Select prd_key From sliver.crm_prd_info)


--Checking product integrity

Select		sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt ,
			sls_sales  ,
			sls_quantity,
			sls_price
From bronze.crm_sales_details
Where sls_cust_id in (Select cst_id From sliver.crm_cust_info)

--Changing integer into data 	sls_order_dt,sls_ship_dt,sls_due_dt
--Checking Bounders in the data 

--sls_order_dt
Select	
	nullif(sls_order_dt	,0) sls_order_dt	
From bronze.crm_sales_details
where sls_order_dt <= 0 or len(sls_order_dt) != 8 
	or sls_order_dt >20500101 or sls_order_dt <19000101


---sls_ship_dt
Select	
	nullif(sls_ship_dt	,0) sls_ship_dt	
From bronze.crm_sales_details
where sls_ship_dt <= 0 or len(sls_ship_dt) != 8 
	or sls_ship_dt >20500101 or sls_ship_dt <19000101

--sls_due_dt
Select	
	nullif(sls_due_dt	,0) sls_due_dt	
From bronze.crm_sales_details
where sls_due_dt <= 0 or len(sls_due_dt) != 8 
	or sls_due_dt >20500101 or sls_due_dt <19000101


--over modification on three date Column  to coverted into integer into Date 

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
			sls_sales  ,
			sls_quantity,
			sls_price
From bronze.crm_sales_details


---Checking order of date 

Select 
* 
From bronze.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt



--Rules 
--Sales = quantity * price 
--negative ,zero , Nulls , are Not Allowed 


--Sales = quantity * price 
Select sls_sales  ,
		sls_quantity,
		sls_price
From bronze.crm_sales_details
where sls_sales != sls_quantity * sls_price or sls_sales is null or sls_quantity is null or sls_price is null 
											or sls_sales <=0 or sls_quantity <=0 or sls_price <=0 
											order by sls_sales,sls_quantity,sls_price



 
 --
 Select sls_sales,
		sls_quantity,
		sls_price as old_sls_price,
		Case when sls_sales is null or sls_sales <=0  or sls_sales != sls_quantity * ABS(sls_price)
				Then sls_quantity * ABS(sls_price)
				Else sls_sales
		End as sls_sales,

		Case  when sls_price is null or sls_price <= 0 
				Then sls_sales /Nullif(sls_quantity,0)
				Else sls_price
		End as sls_price
From bronze.crm_sales_details
where sls_sales != sls_quantity * sls_price or sls_sales is null or sls_quantity is null or sls_price is null 
											or sls_sales <=0 or sls_quantity <=0 or sls_price <=0 
											order by sls_quantity,sls_price

											--EXEC sp_help 'sliver.crm_sales_details';
--------------------------------------------------------------------------------------------------------------------------------
---Testing at [bronze].[erp_cust_az12]
/*=====================================================================================================

	Checking: [sliver].[erp_cust_az12]

=======================================================================================================
*/

Select 
	cid,
	Case When cid Like 'NAS%' Then SUBSTRING(cid,4,Len(cid))
		Else  Cid
	End As cid,
	bdate,
	gen
From [bronze].[erp_cust_az12]
where Case When cid Like 'NAS%' Then SUBSTRING(cid,4,Len(cid))
		Else Cid
End Not in (Select Distinct cst_key From sliver.crm_cust_info)


---identify out of range dates 
Select Distinct 
bdate
From bronze.erp_cust_az12
where bdate < '1924-01-01' or BDATE > getdate()

---Data Standardizations  & Consistency 

Select Distinct gen
From bronze.erp_cust_az12


----Clean the data gen 
Select Distinct gen,
Case when Upper(Trim(gen)) In ('F' , 'Female') Then 'Female'
	 when Upper(Trim(gen)) In ('M' , 'Male') Then 'Male'
	 Else 'n/a'
End as gen
		
From bronze.erp_cust_az12


EXEC sp_help '[sliver].[erp_cust_az12]'


--Checking Data quality in [sliver].[erp_cust_az12]


Select 
	cid,
	Case When cid Like 'NAS%' Then SUBSTRING(cid,4,Len(cid))
		Else  Cid
	End As cid,
	bdate,
	gen
From [sliver].[erp_cust_az12]


---identify out of range dates 
Select Distinct 
bdate
From sliver.erp_cust_az12
where bdate < '1924-01-01' or BDATE > getdate()

---Data Standardizations  & Consistency 

Select Distinct gen
From sliver.erp_cust_az12

------------------------------------------------------------------------------

--Testing [bronze].[erp_loc_a101]

/*=====================================================================================================

	Checking: [sliver].[erp_loc_a101]

=======================================================================================================
*/

Select * From [bronze].[erp_loc_a101]

---Data Standardizations & Consisteency 

Select Distinct CNTRY
fROM [bronze].[erp_loc_a101]
order by cntry

Select cst_key From sliver.crm_cust_info

Select
	REPLACE(cid,'-','') cid,
	Case when Trim(cntry)= 'DE' Then 'Germany'
		 when Trim(cntry) IN ('US','USA') Then 'United States'
		 when Trim(cntry)= '' or CNTRY is null then 'n/a'
		 ELSE Trim(cntry)
	End cntry
From [bronze].[erp_loc_a101]


--Testing Data in [sliver].[erp_loc_a101]

Select Distinct cntry 
From [sliver].[erp_loc_a101]
order by cntry
-----------------------------------------------------------------------------------------------------------------------


---Testing [bronze].[erp_px_cat_g1v2]

/*=====================================================================================================

	Checking: [sliver].[erp_px_cat_g1v2]

=======================================================================================================
*/

Select * From [bronze].[erp_px_cat_g1v2]


--cHECCKING uNWANTED sPACES 
Select * From  [bronze].[erp_px_cat_g1v2]
where cat != Trim(Cat) or SUBCAT != TRIM(SUBCAT) or MAINTENANCE != trim(MAINTENANCE)


--Data Standardizations & Consistency

Select Distinct cat 
From [bronze].[erp_px_cat_g1v2]

Select Distinct  SUBCAT
From [bronze].[erp_px_cat_g1v2]

Select Distinct  MAINTENANCE
From [bronze].[erp_px_cat_g1v2]


--Testing [sliver].[erp_px_cat_g1v2]
Select * From [sliver].[erp_px_cat_g1v2]
