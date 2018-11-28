# 接続する VNet を取得
$vnet1 = Get-AzureRmVirtualNetwork -ResourceGroupName "<リソース グループ名>" -Name "<VNet 名 1>"
$vnet2 = Get-AzureRmVirtualNetwork -ResourceGroupName "<リソース グループ名>" -Name "<VNet 名 2>"
 
# 双方向で接続
Add-AzureRmVirtualNetworkPeering -name "<VNet Peering 名 1>" -VirtualNetwork "<リソース グループ名>" -RemoteVirtualNetworkId $vnet2.id 
Add-AzureRmVirtualNetworkPeering -name "<VNet Peering 名 2>" -VirtualNetwork "<リソース グループ名>" -RemoteVirtualNetworkId $vnet1.id 
 
# VNet Peering の状態を取得
Get-AzureRmVirtualNetworkPeering -VirtualNetworkName "<VNet 名 1>" -ResourceGroupName "<リソース グループ名>" -Name "<VNet Peering 名 1>"
Get-AzureRmVirtualNetworkPeering -VirtualNetworkName "<VNet 名 2>" -ResourceGroupName "<リソース グループ名>" -Name "<VNet Peering 名 2>"
 
# VNet Peering を削除
Remove-AzureRmVirtualNetworkPeering -ResourceGroupName "<リソース グループ名>" -VirtualNetworkName "<VNet 名 1>" -Name "<VNet Peering 名 1>"
Remove-AzureRmVirtualNetworkPeering -ResourceGroupName "<リソース グループ名>" -VirtualNetworkName "<VNet 名 2>" -Name "<VNet Peering 名 2>"