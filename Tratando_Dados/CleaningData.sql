
SELECT *
FROM PortifolioProject..Nashville



-- Padronizando formato de data ----------------------

SELECT SaleDate
, CONVERT(DATE, SaleDate)
, SaleDateConverted
FROM PortifolioProject..Nashville

ALTER TABLE Nashville
ADD SaleDateConverted DATE;

UPDATE Nashville
SET SaleDateConverted = CONVERT(DATE, SaleDate)



-- Preencheendo dados de endereço -------------------------------------

SELECT *
FROM PortifolioProject..Nashville
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT nash1.ParcelID
, nash1.PropertyAddress
, nash2.ParcelID
, nash2.PropertyAddress
, ISNULL(nash1.PropertyAddress, nash2.PropertyAddress)
FROM PortifolioProject..Nashville nash1
JOIN PortifolioProject..Nashville nash2
	ON nash1.ParcelID = nash2.ParcelID
	AND nash1.[UniqueID ] <> nash2.[UniqueID ]
WHERE nash1.PropertyAddress IS NULL


UPDATE nash1
SET PropertyAddress = ISNULL(nash1.PropertyAddress, nash2.PropertyAddress)
FROM PortifolioProject..Nashville nash1
JOIN PortifolioProject..Nashville nash2
	ON nash1.ParcelID = nash2.ParcelID
	AND nash1.[UniqueID ] <> nash2.[UniqueID ]
WHERE nash1.PropertyAddress IS NULL



-- Separando endereço em colunas ----------------------------------------------------

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM PortifolioProject..Nashville

ALTER TABLE Nashville
ADD Address NVARCHAR(255);

ALTER TABLE Nashville
ADD City NVARCHAR(255);

ALTER TABLE Nashville
ADD State NVARCHAR(255);

UPDATE Nashville
SET Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE Nashville
SET City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE Nashville
SET State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-- Alterando SoldAsVacant -> Y e N para Yes e No ----------------------------------------

SELECT DISTINCT(SoldAsVacant)
, COUNT(SoldAsVacant)
FROM PortifolioProject..Nashville
GROUP BY SoldAsVacant


SELECT SoldAsVacant
, CASE	WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
FROM PortifolioProject..Nashville

UPDATE Nashville
SET SoldAsVacant = CASE	WHEN SoldAsVacant = 'Y' THEN 'YES'
						WHEN SoldAsVacant = 'N' THEN 'NO'
						ELSE SoldAsVacant
						END



-- Removendo duplicatas -------------------------------------------

WITH RowNumCTE AS (
SELECT *
, ROW_NUMBER() OVER(
				PARTITION BY ParcelID
							, PropertyAddress
							, SalePrice
							, SaleDate
							, LegalReference
				ORDER BY UniqueID
				) RowNum
FROM PortifolioProject..Nashville
)
DELETE
FROM RowNumCTE
WHERE RowNum > 1



-- Removendo colunas ------------------------------------------------

ALTER TABLE PortifolioProject..Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT *
FROM PortifolioProject..Nashville