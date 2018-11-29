New-AzureStorageAccount -StorageAccountName "<ストレージ アカウント名>" -Location "East Asia"
<# –Type でレプリケーションの種類を指定可
-- Standard_LRS
-- Standard_ZRS
-- Standard_GRS
-- Standard_RAGRS
-- Premium_LRS#>
 
Get-AzureStorageAccount -StorageAccountName "<ストレージ アカウント名>"
Remove-AzureStorageAccount -StorageAccountName "<ストレージ アカウント名>"