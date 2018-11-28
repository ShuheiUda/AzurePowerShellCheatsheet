$Location = "<リージョン名>"
$ResourceGroupName = "<リソース グループ名>"
$VNetName = "<仮想ネットワーク名>"
$VNetAddressPrefix = "10.0.0.0/16"
$GatewaySubnetAddressPrefix = "10.0.0.0/28"
$Subnet1AddressPrefix = "10.0.1.0/28"
$GatewayName = "<ゲートウェイ名>"
$GatewayPublicIpName = "<ゲートウェイのパブリック IP 名>"
$CircuitName = "<ExpressRoute サーキット名>"
$ConnectionName = "<接続名>"
 
# リソース グループを作成
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
 
# 仮想ネットワーク・サブネットを作成
$Subnet1 = New-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -AddressPrefix $GatewaySubnetAddressPrefix
$Subnet2 = New-AzureRmVirtualNetworkSubnetConfig -Name 'Subnet1' -AddressPrefix $Subnet1AddressPrefix
New-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $VNetAddressPrefix -Subnet $Subnet1, $Subnet2
 
# ゲートウェイ用のパブリック IP アドレスを作成
$GatewayPublicIp = New-AzureRmPublicIpAddress -Name $GatewayPublicIpName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic
 
# 作成したリソースを指定して、ゲートウェイを作成
$Vnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName
$Subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $Vnet
$GatewayIpConfig = New-AzureRmVirtualNetworkGatewayIpConfig -Name gwipconfig1 -SubnetId $subnet.Id -PublicIpAddressId $GatewayPublicIp.Id 
New-AzureRmVirtualNetworkGateway -Name $GatewayName -ResourceGroupName $ResourceGroupName -Location $Location -IpConfigurations $GatewayIpConfig -GatewayType Expressroute -GatewaySku Standard
 
# ExpressRoute Circuit と仮想ネットワークを接続
$Circuit = Get-AzureRmExpressRouteCircuit -Name $CircuitName -ResourceGroupName $ResourceGroupName
$VNetGateway1 = Get-AzureRmVirtualNetworkGateway -Name $GatewayName -ResourceGroupName $ResourceGroupName
$Connection = New-AzureRmVirtualNetworkGatewayConnection -Name $ConnectionName -ResourceGroupName $ResourceGroupName -Location $Location -VirtualNetworkGateway1 $VNetGateway1 -PeerId $Circuit.Id -ConnectionType ExpressRoute