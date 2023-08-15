SELECT TOP (1000) [UniqueID]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousingData]

select *
from NashvilleHousingData

-- Standardize Sale Date

select SaleDate, convert(Date, SaleDate) as UpdatedSalesDate
from NashvilleHousingData

update NashvilleHousingData
set SaleDate = CONVERT(Date, SaleDate)

select SaleDate
from NashvilleHousingData -- Not working, trying to use Alter instead

alter table NashvilleHousingData
add SaleDateConverted date

update NashvilleHousingData
set SaleDateConverted = convert(date, SaleDate)

select SaleDateConverted
from NashvilleHousingData

-- Populate property address data

select *
from NashvilleHousingData
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from NashvilleHousingData a
join NashvilleHousingData b -- Joining table on itself to compare these values
on a.ParcelID = b.ParcelID -- Parcel ID for property will always be the same
and a.UniqueID <> b.UniqueID -- Each ID is unique
where a.PropertyAddress is null -- Want to find the null values for property address

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyAddress, b.PropertyAddress) -- if first value is null, we want to populat with second value
from NashvilleHousingData a
join NashvilleHousingData b
on a.ParcelID = b.ParcelID 
and a.UniqueID <> b.UniqueID 
where a.PropertyAddress is null

update a -- Now let's update
set PropertyAddress = isnull(a.propertyaddress, b.propertyaddress)
from NashvilleHousingData a
join NashvilleHousingData b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyAddress, b.PropertyAddress) -- We can see this update worked by running the search again
from NashvilleHousingData a
join NashvilleHousingData b
on a.ParcelID = b.ParcelID 
and a.UniqueID <> b.UniqueID 
where a.PropertyAddress is null

-- Break up address into individual columns (Address, City, State)

select PropertyAddress
from NashvilleHousingData

select substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) as address --selecting substring up to the comma, and then minusing one to remove the comma from the output
from NashvilleHousingData

select substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) as address,
substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) as Address  --now selecting the values after the comma through end of string
from NashvilleHousingData

alter table NashvilleHousingData -- Create column for new split address value
add PropertySplitAddress nvarchar(255)

update NashvilleHousingData -- Update our table with split address values
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1)

alter table NashvilleHousingData -- Create column for new split city value
add PropertySplitCity nvarchar(255)

update NashvilleHousingData -- Update our table with split city values
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress))

select PropertySplitAddress, PropertySplitCity
from NashvilleHousingData

select owneraddress -- Let's do this using the parsename function instead
from NashvilleHousingData

select parsename(owneraddress, 1) --This does nothing because parsename works with '.' values
from NashvilleHousingData

select parsename(replace(owneraddress, ',', '.'), 1) -- Replaces the comma with period. Parse works backwards though, so state values are returned
from NashvilleHousingData

select parsename(replace(owneraddress, ',', '.'), 3) as Address, -- Let's get all our parsed values
parsename(replace(owneraddress, ',', '.'), 2) as City,
parsename(replace(owneraddress, ',', '.'), 1) as State
from NashvilleHousingData

alter table NashvilleHousingData -- Add column for parsed address
add ParseAddress varchar(255)

update NashvilleHousingData -- Insert parsed address 
set ParseAddress = parsename(replace(owneraddress, ',', '.'), 3)

alter table NashvilleHousingData -- Add column for parsed city
add ParseCity varchar(255)

update NashvilleHousingData -- Insert parsed city
set ParseCity = parsename(replace(owneraddress, ',', '.'), 2)

alter table NashvilleHousingData -- Add collumn for parsed state
add ParseState varchar(10)

update NashvilleHousingData -- Insert parsed state
set ParseState = parsename(replace(owneraddress, ',', '.'), 1)

select ParseAddress, ParseCity, ParseState -- See results
from NashvilleHousingData

-- Change Y and N to Yes and No in 'Sold as Vacant' field

select SoldAsVacant,
case
	when SoldAsVacant = 'Y' then 'Yes' -- Change 'Y' to 'Yes'
	when SoldAsVacant = 'N' then 'No' -- Change 'N' to 'No'
	else SoldAsVacant -- Else we do nothing
end
from NashvilleHousingData

update NashvilleHousingData -- Update our values with the formula
set SoldAsVacant = case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end

select SoldAsVacant
from NashvilleHousingData
group by SoldAsVacant