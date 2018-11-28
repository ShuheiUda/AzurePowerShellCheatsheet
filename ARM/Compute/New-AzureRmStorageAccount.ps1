New-AzureRmStorageAccount –StorageAccountName "<ストレージ アカウント名>" -Location "East Asia" -Type Standard_GRS –ResourceGroupName "<リソース グループ名>"
<# ARM は –Type オプション必須
-- Standard_LRS
-- Standard_ZRS
-- Standard_GRS
-- Standard_RAGRS
-- Premium_LRS#>
 
Get-AzureRmStorageAccount –Name "<ストレージ アカウント名>" #cmdlet の挙動がちょっと怪しい
Remove-AzureRmStorageAccount –Name "<ストレージ アカウント名>" –ResourceGroupName "<リソース グループ名>"