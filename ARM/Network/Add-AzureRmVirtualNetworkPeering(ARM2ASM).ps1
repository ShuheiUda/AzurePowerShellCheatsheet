$Location = "<リージョン名>"
$ResourceGroupName = "<リソース グループ名>"
$VNetName = "shuda100709a"
$VNetAddressPrefix = "10.0.0.0/16"
$Subnet1AddressPrefix = "10.0.0.0/28"
$ClassicVNetId = "<クラシック環境の VNet リソース Id>"
$PeerName = "shuda100709a2b"
 
# リソース グループを作成
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
 
# 仮想ネットワーク・サブネットを作成
$Subnet = New-AzureRmVirtualNetworkSubnetConfig -Name 'Subnet1' -AddressPrefix $Subnet1AddressPrefix
New-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $VNetAddressPrefix -Subnet $Subnet
 
# 作成した VNet を取得
$VNet = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName
 
# VNetPeering を作成
Add-AzureRmVirtualNetworkPeering -name $PeerName -VirtualNetwork $VNet -RemoteVirtualNetworkId $ClassicVNetId