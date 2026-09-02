INSERT into silver.crm_cust_info (
cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date
)
select
cst_id,
cst_key,
trim(cst_firstname) as cst_firstname,
trim(cst_lastname) as cst_lastname,
case when upper(trim(cst_marital_status)) = 'S' then 'Single'
	 when upper(trim(cst_marital_status)) = 'M' then 'Married'	
	 else 'n/a' --'Handling Missing Data' Fills in the blanks by adding a default value
end as cst_marital_status, -- Normalize marital status values to readable format
case when upper(trim(cst_gndr)) = 'F' then 'Female'
	 when upper(trim(cst_gndr)) = 'M' then 'Male'	
	 else 'n/a' 
end as cst_gndr, -- Normalize gender values to readable format
cst_create_date
from (
	--'Remove Duplicates' Ensure only one record per entity by identifying and retaining the most relevant row.
	select
	*,
	row_number() over (partition by cst_id order by cst_create_date desc) as flag_last
	from bronze.crm_cust_info
	where cst_id is not NULL 
)t where flag_last = 1

--Checks for Nulls of Duplicates in Primary Key
--Expectation: No Results
SELECT 
cst_id,
count(*)
from silver.crm_cust_info 
group by cst_id 
having COUNT(*) > 1 or cst_id is null

--Check for unwanted Spaces
--Expectation: No Results
select cst_key
from silver.crm_cust_info
where cst_key != trim(cst_key)

--Data Standardization & Consistency
select distinct cst_gndr
from silver.crm_cust_info 

select * from silver.crm_cust_info 

--insert 된 시간 default 로 입력됨 
ALTER TABLE silver.crm_cust_info
ADD dwh_create_date DATETIME2 DEFAULT GETDATE();
