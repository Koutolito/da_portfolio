/*

Cleaning Data in SQL Queries

*/




--------------------------------------------------------------------------------------------------------------------------
--Create a function that retrieve an column value type



--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
SELECT CAST(SaleDate as date) SaleDate
FROM NashvilleHousing


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress 
FROM
NashvilleHousing a 
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
NashvilleHousing a 
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress ,
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1) Adress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2,LEN(PropertyAddress)) City
FROM
NashvilleHousing 

--ALTER TABLE NashvilleHousing
--ADD Address nvarchar(255), City nvarchar(255) 
UPDATE NashvilleHousing
SET Address = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1) ,
City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2,LEN(PropertyAddress)) ;

SELECT PropertyAddress, Address, City
FROM NashvilleHousing;

SELECT 
CASE
	WHEN OwnerAddress IS NULL THEN 'N/D' ELSE OwnerAddress
END OwnerAddress,  
CASE 
	WHEN OwnerAddress IS NULL THEN 'N/D' ELSE PARSENAME(REPLACE(OwnerAddress,',','.'),1)
END ST,
CASE
	WHEN OwnerAddress IS NULL THEN 'N/D' ELSE PARSENAME(REPLACE(OwnerAddress,',','.'),2)
END CITY,
CASE
	WHEN OwnerAddress IS NULL THEN 'N/D' ELSE PARSENAME(REPLACE(OwnerAddress,',','.'),3)
END ROAD
FROM
NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field
select DISTINCT(SoldAsVacant),COUNT(SoldAsVacant) from
NashvilleHousing
group by SoldAsVacant
order by 2;

UPDATE NashvilleHousing
SET 
SoldAsVacant = CASE 
					WHEN SoldAsVacant = 'Y' THEN 'Yes'
					WHEN SoldAsVacant = 'N' THEN 'No'
					ELSE SoldAsVacant
			   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT * FROM NashvilleHousing
-- Remove Duplicates
WITH ROWS_DUPLICATES AS (
SELECT * ,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
				UniqueID
			) AS row_num
FROM NashvilleHousing )
DELETE FROM ROWS_DUPLICATES
WHERE row_num > 1;

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress










-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO
