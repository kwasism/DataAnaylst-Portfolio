use p1
select * 
from NashvilleHousing

-- Standardize Data Format


select SaleDate, CONVERT(date,SaleDate)
from NashvilleHousing


Alter Table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)

---Populate Property Address Data

select * 
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID =b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where PropertyAddress is null

-- isnull checks to see if it is null and if it is it will populate an address

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID =b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)


select PropertyAddress
from NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, 
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, len(PropertyAddress)) as Address
from NashvilleHousing


Alter Table NashvilleHousing
add PropertySplitAddress Varchar(255);

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter Table NashvilleHousing
add PropertySplitCity varchar(255);

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, len(PropertyAddress)) 

Select *
from NashvilleHousing




Select OwnerAddress
from NashvilleHousing


select 
PARSENAME(replace(OwnerAddress,',','.'),3), 
	PARSENAME(replace(OwnerAddress,',','.'),2),
	PARSENAME(replace(OwnerAddress,',','.'),1)
from NashvilleHousing





Alter Table NashvilleHousing
add OwnerSplitAddress Varchar(255);

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)


Alter Table NashvilleHousing
add OwnerSplitCity varchar(255);

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
add OwnerSplitState varchar(255);

Update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)


--- OR ----

Alter Table NashvilleHousing
add OwnerSplitAddress varchar(255), 
OwnerSplitCity varchar(255), 
OwnerSplitState varchar(255);

Update NashvilleHousing
set
OwnerSplitAddress =PARSENAME(replace(OwnerAddress,',','.'),3),
OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2),
OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)




Select *
from NashvilleHousing








--- Change Y and N to Yes and No in Sold as Vacant column 

Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case When SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'NO'
	   else SoldAsVacant
	   end
from NashvilleHousing



update NashvilleHousing
set SoldAsVacant =
case When SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'NO'
	   else SoldAsVacant
	   end







-- Remove Duplicates
With RowNumCTE as (
select *,
	ROW_NUMBER() Over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) row_num
from NashvilleHousing
) delete
From RowNumCTE
Where row_num >1





--Delete Unused Columns

select*
from NashvilleHousing


alter table NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress


alter table NashvilleHousing
Drop column SaleDate