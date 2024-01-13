--____________________________CLEANING DATA IN SQL____________________________

*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--STANDARDIZE DATE FORMAT

Select *
From PortfolioProject.dbo.NatsvilleHousing

Update NatsvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NatsvilleHousing
Add SaleDateConverted Date;

Update NatsvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Execute to confirm that the syntax above were sucuessfully executed 

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NatsvilleHousing


-------------------------------------------------------------------------------------------------------------------------------------------------------------
--POPULATE PROPERTY ADDRESS DATA

Select *
From PortfolioProject.dbo.NatsvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select *
From PortfolioProject.dbo.NatsvilleHousing a
join PortfolioProject.dbo.NatsvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

--generate a table to vizualize the four columns "a.ParcelID, a.PropertyAddress, b.ParcelID and b.ParcelAddress"

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NatsvilleHousing a
join PortfolioProject.dbo.NatsvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

--then transfer b.PropertyAddress to a.PropertyAddress (into the null spaces i.e. the ISNULL coulumn). There should be no more null left on completion. 
--To update the table:  

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NatsvilleHousing a
join PortfolioProject.dbo.NatsvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

--*There should be no more NULL left in the PropertyAddress column*

---------------------------------------------------------------------------------------------------------------------------------------------------------------

---BREAKING OUT INTO INDIVIDUAL COLUMNS (Address, City, State)---

Select PropertyAddress 
From PortfolioProject.dbo.NatsvilleHousing 


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NatsvilleHousing 


ALTER TABLE NatsvilleHousing 
Add PropertySplitAddress Nvarchar(255);


Update NatsvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )


ALTER TABLE NatsvilleHousing
Add PropertySplitCity Nvarchar(255);


Update NatsvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress) )

--vizualize outcome:

Select *
From PortfolioProject.dbo.NatsvilleHousing

-------------here's an alternative method-------------


Select OwnerAddress
From PortfolioProject.dbo.NatsvilleHousing


Select PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)
, PARSENAME(REPLACE(OwnerAddress, ',','.') , 2)
, PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)
From PortfolioProject.dbo.NatsvilleHousing

ALTER TABLE PortfolioProject.dbo.NatsvilleHousing 
Add OwnerSplitAddress Nvarchar(255);


Update PortfolioProject.dbo.NatsvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)


ALTER TABLE PortfolioProject.dbo.NatsvilleHousing
Add OwnerSplitCity Nvarchar(255);


Update PortfolioProject.dbo.NatsvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.') , 2)


ALTER TABLE PortfolioProject.dbo.NatsvilleHousing
Add OwnerSplitState Nvarchar(255);


Update PortfolioProject.dbo.NatsvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)

--vizualize outcome:

Select *
From PortfolioProject.dbo.NatsvilleHousing 

------------------------------------------------------------------------------------------------------------------------------------------------------------------

--CHANGE Y and N to Yes and NO in "SOLD AS VACANT" FIELD

--visulize the current status:

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NatsvilleHousing
Group by SoldAsVacant
order by 2

--then change to:

Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant  = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject.dbo.NatsvilleHousing

--then update:

Update PortfolioProject.dbo.NatsvilleHousing 
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

	--vizualize outcome:

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NatsvilleHousing
Group by SoldAsVacant
order by 2

Select *
From PortfolioProject.dbo.NatsvilleHousing

------------------------------------------------------------------------------------------------------------------------------------------------------------------

--REMOVE DUPLICATES--

WITH RowNumCTE AS(
Select *,
    ROW_NUMBER() OVER (
	Partition by ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by
						UniqueID
						) row_num

From PortfolioProject.dbo.NatsvilleHousing
--order by ParcelID
)

Select * 
From RowNumCTE
Where row_num > 1
order by PropertyAddress

---then delete the douplicates:

WITH RowNumCTE AS(
Select *,
    ROW_NUMBER() OVER (
	Partition by ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by
						UniqueID
						) row_num

From PortfolioProject.dbo.NatsvilleHousing
--order by ParcelID
)

DELETE 
From RowNumCTE
Where row_num > 1

--vizualize outcome

WITH RowNumCTE AS(
Select *,
    ROW_NUMBER() OVER (
	Partition by ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by
						UniqueID
						) row_num

From PortfolioProject.dbo.NatsvilleHousing
--order by ParcelID
)

Select * 
From RowNumCTE
Where row_num > 1
order by PropertyAddress

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
----DELETE USELESS COLUMNS----

Select *
From PortfolioProject.dbo.NatsvilleHousing

ALTER TABLE PortfolioProject.dbo.NatsvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NatsvilleHousing
Drop Column SaleDate