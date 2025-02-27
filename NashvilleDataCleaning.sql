----------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

----------------------------------------------------------------------------------------------------------------------------------------------------------


--Standardize Sale Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate);

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);


----------------------------------------------------------------------------------------------------------------------------------------------------------


-- Standardize Property Address 

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL;
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


----------------------------------------------------------------------------------------------------------------------------------------------------------


-- Breaking PropertyAddress into Individual Columns (ex: Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing;

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));


----------------------------------------------------------------------------------------------------------------------------------------------------------


-- Breaking OwnerAddress into Individual Columns (ex: Address, City, State)
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing;

SELECT 
PARSENAME (REPLACE(OwnerAddress, ',','.'), 3)
,PARSENAME (REPLACE(OwnerAddress, ',','.'), 2)
,PARSENAME (REPLACE(OwnerAddress, ',','.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing;


ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing 
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',','.'), 3);


ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing 
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',','.'), 2);


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',','.'), 1);


----------------------------------------------------------------------------------------------------------------------------------------------------------


--Change Y and N to Yes and No in "Sold as Vacant" columnn 

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END;


----------------------------------------------------------------------------------------------------------------------------------------------------------


--Remove Duplicates 
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER()OVER (
	PARTITION BY ParcelID, 
				PropertyAddress, 
				SalePrice, 
				SaleDate, 
				LegalReference
	ORDER BY UniqueID) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1;


----------------------------------------------------------------------------------------------------------------------------------------------------------


--Delete Unused Columns 
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,
			TaxDistrict,
			PropertyAddress,
			SaleDate;


----------------------------------------------------------------------------------------------------------------------------------------------------------