 
---------------CLEANING DATA IN SUQEUL (SQL)-----------------

SELECT *
FROM NashvilleHousing

--Standardize Date Format
-->> ALTER TABLE >> Is used to add, delete, or modify columns in an existing table.
-->> ALTER TABLE table_name
-->> ADD column_name datatype;

ALTER TABLE NashvilleHousing 
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NashvilleHousing 


----------------------------------------------------------------------

--Populate Property Address Data, *that has same ParcelID, but has no Address

SELECT * 
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

-->> To Check
SELECT Atable.ParcelID, Atable.PropertyAddress, Btable.ParcelID
, Btable.PropertyAddress, ISNULL(Atable.PropertyAddress, Btable.PropertyAddress)
FROM NashvilleHousing Atable
JOIN NashvilleHousing Btable
 ON Atable.ParcelID = Btable.ParcelID
 AND Atable.[UniqueID ] <> Btable.[UniqueID ]
WHERE Atable.PropertyAddress is null

-->> Main Execution 
UPDATE Atable
SET PropertyAddress = ISNULL(Atable.PropertyAddress, Btable.PropertyAddress)
FROM NashvilleHousing Atable
JOIN NashvilleHousing Btable
 ON Atable.ParcelID = Btable.ParcelID
 AND Atable.[UniqueID ] <> Btable.[UniqueID ]
WHERE Atable.PropertyAddress is null

-->> If update has done, the 'To Check' will showing no data, because there is no NULL Value anymore

--------------------------------------------------------------------------------

--Breaking out Address into individual Columns (Address, City, State)

---->>> 1. Property Address

SELECT PropertyAddress
FROM NashvilleHousing

-->> Use "Substring" >> To extracts some characters from a string >> SUBSTRING(string, start, length)
-->>and "CharIndex" >> To searches for a substring in a string, and returns the position,
-->> CHARINDEX(substring, string, start(Optional))
-->> LEN(String) >> To returns the length of a string.

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as PropertySplitAddress
, SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as PropertyAddressCity
FROM NashvilleHousing
Order by PropertyAddressCity, PropertySplitAddress

-->> To Update Data , "EXECUTE ONE by ONE" CAN NOT EXECUTE together ALTER FIRST, then UPDATE

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertyAddressCity nvarchar(255);
UPDATE NashvilleHousing
SET PropertyAddressCity = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

/* >>To Delete One Column in Table 
ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddressCity
*/
-->> the new column is add in the end of table
SELECT *
FROM NashvilleHousing

---->>> 2. The Owner Address

SELECT OwnerAddress
FROM NashvilleHousing

-->> Usinge PARSENAME function to split delimited data, BUT BACKWARD 
-->> PARSENAME('object_name', object_piece)
-->> PARSENAME Only work in period(.), so you have to REPLACE with coma (,)
-->> REPLACE(string, from_string, new_string)

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM NashvilleHousing

-->> To Update Data , "EXECUTE ONE by ONE" CAN NOT EXECUTE together ALTER FIRST, then UPDATE

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,  ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,  ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,  ',', '.'), 1)


-----------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

-->> The count of Y, N, Yes, and No
SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------

--Remove Duplicates

-->> Used CTE and Partition by

--1. Identify the duplicate using CTE

WITH RowNumCTE AS 
(
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
FROM NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1

--2. Delete the Duplicate (Execute without 'select statement' above)

DELETE 
FROM RowNumCTE
WHERE row_num > 1

---------------------------------------------------------------------------------------

--DELETE Unused Column

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------