*********Cleaning Data in SQL Queries**************************

SELECT*
FROM Portafolio_Project..Nash_Housing

**********************************************************************************************************************
-- Standardize Data Format
SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM Portafolio_Project..Nash_Housing

UPDATE Nash_Housing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE Nash_Housing
ADD SaleDateConverted  Date;

UPDATE Nash_Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)




**********************************************************************************************************************
-- Populating property Address data
SELECT *
FROM Portafolio_Project..Nash_Housing
--Where PropertyAddress IS null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portafolio_Project..Nash_Housing a
JOIN Portafolio_Project..Nash_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> B.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portafolio_Project..Nash_Housing a
JOIN Portafolio_Project..Nash_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> B.[UniqueID ]
WHERE a.PropertyAddress IS NULL





**********************************************************************************************************************
-- Breaking out Address into Individual Columns (Address, City) using SUBSTRING & CHARINDEX

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM Portafolio_Project..Nash_Housing

ALTER TABLE Nash_Housing
ADD PropertySplitAddress Nvarchar(255);

UPDATE Nash_Housing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nash_Housing
ADD PropertySplitCity Nvarchar(255);

UPDATE Nash_Housing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT OwnerAddress
FROM Portafolio_Project..Nash_Housing




**********************************************************************************************************************
-- Breaking out OwnerAddress into Individual Columns (Address, City, State) using a PARSENAME

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) 
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) 
FROM Portafolio_Project..Nash_Housing 

ALTER TABLE Nash_Housing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Nash_Housing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 


ALTER TABLE Nash_Housing
ADD OwnerSplitCity Nvarchar(255);

UPDATE Nash_Housing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Nash_Housing
ADD OwnerSplitState Nvarchar(255);

UPDATE Nash_Housing 
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


--- ALTER TABLE Nash_Housing
---DROP COLUMN OwnerSplitState, OwnerSplitCity, OwnerSplitAddress

SELECT*
FROM Portafolio_Project..Nash_Housing





**********************************************************************************************************************
-- Changing Y and N to Yes and No in 'Sold as Vacant' field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM Portafolio_Project..Nash_Housing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM Portafolio_Project..Nash_Housing

Update Nash_Housing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



**********************************************************************************************************************
-- Removing Duplicates Values
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

FROM Portafolio_Project..Nash_Housing
--ORDER BY ParcelID
)
--DELETE
SELECT*
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress




**********************************************************************************************************************
-- Removing  Unused Columns
SELECT*
FROM Portafolio_Project..Nash_Housing

ALTER TABLE Nash_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, 

ALTER TABLE Nash_Housing
DROP COLUMN SaleDate