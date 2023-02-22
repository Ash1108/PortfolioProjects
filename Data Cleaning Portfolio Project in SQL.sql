/*

Cleaning Data in SQL

*/

SELECT *
FROM [PortfolioProject].[dbo].[NashvilleHousing];

-----------------------------------------------------------------------------------------------------

--Standardize Date Format(currently it is in datetime format)

SELECT SaleDate, CONVERT(date, SaleDate)
FROM [PortfolioProject].[dbo].[NashvilleHousing];

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET SaleDate = CONVERT(date, SaleDate);

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
ADD SaleDateConverted Date;

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET SaleDateConverted = CONVERT(Date, SaleDate);

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM [PortfolioProject].[dbo].[NashvilleHousing];

----------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT PropertyAddress
FROM [PortfolioProject].[dbo].[NashvilleHousing];

SELECT *  -- Check for Null values
FROM [PortfolioProject].[dbo].[NashvilleHousing]
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) -- Parcel ID with same values has same property address. 
FROM [PortfolioProject].[dbo].[NashvilleHousing] a
JOIN [PortfolioProject].[dbo].[NashvilleHousing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [PortfolioProject].[dbo].[NashvilleHousing] a
JOIN [PortfolioProject].[dbo].[NashvilleHousing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns(Address, City, State)
-- PropertyAddress

SELECT PropertyAddress
FROM [PortfolioProject].[dbo].[NashvilleHousing];

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM [PortfolioProject].[dbo].[NashvilleHousing];

SELECT --returns position
CHARINDEX(',',PropertyAddress) -1
FROM [PortfolioProject].[dbo].[NashvilleHousing];

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing] --adding column PropertySpiltAddress
ADD PropertySplitAddress Nvarchar(255);

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing] --adding column PropertySplitCity
ADD PropertySplitCity Nvarchar(255);

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress));

SELECT *
FROM [PortfolioProject].[dbo].[NashvilleHousing];

-- OwnerAddress

SELECT OwnerAddress
FROM [PortfolioProject].[dbo].[NashvilleHousing];

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) AS OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) AS OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) AS OwnerSplitState
FROM [PortfolioProject].[dbo].[NashvilleHousing];

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing] --adding column OwnerSplitAddress
ADD OwnerSplitAddress Nvarchar(255);

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

ALTER TABLE [Portfolioproject].[dbo].[NashvilleHousing]  --adding column OwnerSplitCity
ADD OwnerSplitCity Nvarchar(255);

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing] --adding column OwnerSplitState
ADD OwnerSplitState Nvarchar(255);

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

SELECT *
FROM [PortfolioProject].[dbo].[NashvilleHousing];

-------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [PortfolioProject].[dbo].[NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'N' THEN 'No'
	 WHEN SoldAsVacant = 'Y' THEN 'YES'
	 ELSE SoldAsVacant
	 END
FROM [PortfolioProject].[dbo].[NashvilleHousing];

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'N' THEN 'No'
	 WHEN SoldAsVacant = 'Y' THEN 'YES'
	 ELSE SoldAsVacant
	 END
FROM [PortfolioProject].[dbo].[NashvilleHousing];

SELECT *
FROM [PortfolioProject].[dbo].[NashvilleHousing]
WHERE SoldAsVacant = 'N' OR SoldAsVacant = 'Y';

--------------------------------------------------------------------------------------

-- Remove duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) row_num
FROM [PortfolioProject].[dbo].[NashvilleHousing]
)
DELETE 
FROM RowNumCTE -- to use row_num, we need to a create a virtual table i.r CTE
WHERE row_num > 1;

SELECT *
FROM [PortfolioProject].[dbo].[NashvilleHousing];

--------------------------------------------------------------------------------------------------

--Delete Unused Columns

SELECT *
FROM [PortfolioProject].[dbo].[NashvilleHousing];

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing] -- deleting PropertyAddress, OwnerAddress, TaxDistrict, SaleDate
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict;

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
DROP COLUMN SaleDate;


