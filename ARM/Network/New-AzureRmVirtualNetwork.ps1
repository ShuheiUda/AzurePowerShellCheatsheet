New-AzureRmVirtualNetwork -ResourceGroupName "<リソース グループ名>" -Location "East Asia" -Name "<VNET 名>" -AddressPrefix "192.168.0.0/16"
$Vnet = Get-AzureRmVirtualNetwork -ResourceGroupName "<リソース グループ名>" -Name "<VNET 名>"
Remove-AzureRmVirtualNetwork -ResourceGroupName "<リソース グループ名>" -Name "<VNET 名>"
 
Add-AzureRmVirtualNetworkSubnetConfig -Name "<サブネット名>" -VirtualNetwork $Vnet -AddressPrefix "192.168.1.0/24"
Get-AzureRmVirtualNetworkSubnetConfig -Name "<サブネット名>" -VirtualNetwork $Vnet
Remove-AzureRmVirtualNetworkSubnetConfig -Name "<サブネット名>" -VirtualNetwork $Vnet