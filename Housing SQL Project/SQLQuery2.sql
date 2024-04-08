Select *
From Portafolioproject.dbo.Nashhousing

--Standardize Data Formart

Select SaleDateConverted, CONVERT(Date,SaleDate) 
From Portafolioproject.dbo.Nashhousing

Update Nashhousing
Set SaleDate = CONVERT(Date,SaleDate)

Alter Table Nashhousing
Add SaleDateConverted Date

Update Nashhousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address Data in null Values

Select PropertyAddress
From Portafolioproject.dbo.Nashhousing
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portafolioproject.dbo.Nashhousing a
join Portafolioproject.dbo.Nashhousing b
    On a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portafolioproject.dbo.Nashhousing a
join Portafolioproject.dbo.Nashhousing b
    On a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



--Splitting Address into individual Columns (Address,City,State)


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

Alter Table Nashhousing
Add PropertySplitAddress Nvarchar(255)

Update Nashhousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

Alter Table Nashhousing
Add PropertySplitCity Nvarchar(255)

Update Nashhousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

From Portafolioproject.dbo.Nashhousing




Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)

From Portafolioproject.dbo.Nashhousing


Alter Table Nashhousing
Add OwnerSplitAddress Nvarchar(255)

Update Nashhousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter Table Nashhousing
Add OwnerSplitCity Nvarchar(255)

Update Nashhousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table Nashhousing
Add OwnerSplitState Nvarchar(255)

Update Nashhousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



--Update Y and N to "Yes" and "No" on "Sold as Vacant" field

Select Distinct(Soldasvacant), count(SoldAsVacant)
From Portafolioproject.dbo.Nashhousing
Group by SoldAsVacant
order by 2



Select Soldasvacant,
CASE When SoldAsVacant = 'N' then 'No' 
     When SoldAsVacant = 'Y' then 'Yes'
	 Else SoldAsVacant
	 END
From Portafolioproject.dbo.Nashhousing

Update Nashhousing
Set SoldAsVacant = CASE When SoldAsVacant = 'N' then 'No' 
     When SoldAsVacant = 'Y' then 'Yes'
	 Else SoldAsVacant
	 END


--Remove Duplicates


With RowNumCTE as(
Select *,
    ROW_NUMBER() OVER(
	Partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
				     UniqueID
					 ) row_num
	                               
From Portafolioproject.dbo.Nashhousing
--Order by ParcelID
)

--Delete
--From RowNumCTE
--Where row_num > 1
--Order by PropertyAddress
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



--Remove Unused Columns


Select *
From Portafolioproject.dbo.Nashhousing


Alter Table Portafolioproject.dbo.Nashhousing
Drop Column TaxDistrict