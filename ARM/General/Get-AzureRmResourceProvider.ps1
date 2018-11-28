((Get-AzureRmResourceProvider -ProviderNamespace Microsoft.Compute).ResourceTypes | Where-Object ResourceTypeName -eq virtualMachines).Locations

<#
出力例: サブスクリプションによって利用可能な地域が異なる場合があります
East US
East US 2
West US
Central US
South Central US
North Europe
West Europe
East Asia
Southeast Asia
Japan East
Japan West
North Central US
Australia East
Australia Southeast
Brazil South
#>