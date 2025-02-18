/*
======================================================
Create Database And schema 
======================================================

Script purpose : 
      The script create  a new DataBase name "Datawarehouse" after checking if it already exists.
      if the database exists, it is dropped and recreated . additionally, the Script set up three Schemas
      within the database :  'bronze' , 'silver' , 'Gold'


Warning: 
      Running this Script will drop the entire  'datawarehouse' database if  it exists.
      All data in the database will be permanetly deleted.process with caution
      and ensure you have proper backup before running this script


*/


use master;
go


--Drop and recreate the 'Datwarehouse' DataBase 

if EXISTS (SELECT 1 From sys.databases where name = 'Datawarehouse')
Begin
	Alter Database Datawarehouse set single_user with RollBack immediate;
	Drop Database Datawarehouse
End;
Go




===================================
  -- Create DATABASE 'Datwarehouse'
====================================
Create Database Datawarehouse;

use Datawarehouse


===================================
  -- Create Schema 
====================================
  go 
  
create Schema bronze;
Go              
create Schema sliver;
Go
create Schema Gold;
Go





