$Location = "<リージョン名>"
$ResourceGroupName = "<リソース グループ名>"
$VNetName1 = "<仮想ネットワーク名 1>"
$VNetAddressPrefix1 = "10.0.0.0/16"
$Subnet1AddressPrefix1 = "10.0.0.0/28"
$VNetName2 = "<仮想ネットワーク名 2>"
$VNetAddressPrefix2 = "10.1.0.0/16"
$Subnet1AddressPrefix2 = "10.1.0.0/28"
$PeerName1 = "<ピアリング名 1>"
$PeerName2 = "<ピアリング名 2>"
 
# リソース グループを作成
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
 
# 仮想ネットワーク・サブネットを作成
$Subnet1 = New-AzureRmVirtualNetworkSubnetConfig -Name 'Subnet1' -AddressPrefix $Subnet1AddressPrefix1
New-AzureRmVirtualNetwork -Name $VNetName1 -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $VNetAddressPrefix1 -Subnet $Subnet1
$Subnet1 = New-AzureRmVirtualNetworkSubnetConfig -Name 'Subnet1' -AddressPrefix $Subnet1AddressPrefix2
New-AzureRmVirtualNetwork -Name $VNetName2 -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $VNetAddressPrefix2 -Subnet $Subnet1
 
# 作成した VNet を取得
$VNet1 = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName1
$VNet2 = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName2
 
# VNetPeering を作成
Add-AzureRmVirtualNetworkPeering -name $PeerName1 -VirtualNetwork $VNet1 -RemoteVirtualNetworkId $VNet2.id
Add-AzureRmVirtualNetworkPeering -name $PeerName2 -VirtualNetwork $VNet2 -RemoteVirtualNetworkId $VNet1.id