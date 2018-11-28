$Location = "<リージョン名>"
$ResourceGroupName = "<リソース グループ名>"
$VNetName = "<仮想ネットワーク名>"
$VNetAddressPrefix = "10.0.0.0/16"
$GatewaySubnetAddressPrefix = "10.0.0.0/28"
$Subnet1AddressPrefix = "10.0.1.0/28"
$GatewayName = "<ゲートウェイ名>"
$GatewayPublicIpName1 = "<ゲートウェイのパブリック IP 名 1>"
$GatewayPublicIpName2 = "<ゲートウェイのパブリック IP 名 2>"
$ASNumber = "<AS 番号>"
$LocalNetworkGatewayName = "<ローカル ネットワーク ゲートウェイ名>"
$LocalNetworkGatewayIp = "<オンプレミスの VPN 機器が持つグローバル IP>"
$OnpremiseAddressPrefix = "<ローカルのアドレス レンジ>"
$ConnectionName = "<接続名>"
$PreSharedKey = "<事前共有キー>"
 
# リソース グループを作成
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
 
# 仮想ネットワーク・サブネットを作成
$Subnet1 = New-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -AddressPrefix $GatewaySubnetAddressPrefix
$Subnet2 = New-AzureRmVirtualNetworkSubnetConfig -Name 'Subnet1' -AddressPrefix $Subnet1AddressPrefix
New-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $VNetAddressPrefix -Subnet $Subnet1, $Subnet2
 
# ローカル ネットワーク ゲートウェイを作成
New-AzureRmLocalNetworkGateway -Name $LocalNetworkGatewayName -ResourceGroupName $ResourceGroupName -Location $Location -GatewayIpAddress $LocalNetworkGatewayIp -AddressPrefix $OnpremiseAddressPrefix
 
# ゲートウェイ用のパブリック IP アドレスを作成
$GatewayPublicIp1 = New-AzureRmPublicIpAddress -Name $GatewayPublicIpName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic
$GatewayPublicIp2 = New-AzureRmPublicIpAddress -Name $GatewayPublicIpName2 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic
 
# 作成したリソースを指定して、ゲートウェイを作成
$Vnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName
$Subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $Vnet
$GatewayIpConfig1 = New-AzureRmVirtualNetworkGatewayIpConfig -Name gwipconfig1 -SubnetId $Subnet.Id -PublicIpAddressId $GatewayPublicIp1.Id 
$GatewayIpConfig2 = New-AzureRmVirtualNetworkGatewayIpConfig -Name gwipconfig2 -SubnetId $Subnet.Id -PublicIpAddressId $GatewayPublicIp2.Id 
New-AzureRmVirtualNetworkGateway -Name $GatewayName -ResourceGroupName $ResourceGroupName -Location $Location -IpConfigurations $GatewayIpConfig1,$GatewayIpConfig2 -GatewayType Vpn -VpnType RouteBased -GatewaySku HighPerformance -Asn $ASNumber -ActiveActive $True
 
# VPN Gateway のパブリック IP を取得 (こちらをオンプレミスのルーターで設定)
Get-AzureRmPublicIpAddress -Name $GatewayPublicIpName1 -ResourceGroupName $ResourceGroupName
Get-AzureRmPublicIpAddress -Name $GatewayPublicIpName2 -ResourceGroupName $ResourceGroupName
 
# オンプレミスとの接続オブジェクトを作成
$VNetGateway1 = Get-AzureRmVirtualNetworkGateway -Name $GatewayName -ResourceGroupName $ResourceGroupName
$LocalNetworkGateway2 = Get-AzureRmLocalNetworkGateway -Name $LocalNetworkGatewayName -ResourceGroupName $ResourceGroupName
New-AzureRmVirtualNetworkGatewayConnection -Name $ConnectionName -ResourceGroupName $ResourceGroupName -Location $Location -VirtualNetworkGateway1 $VNetGateway1 -LocalNetworkGateway2 $LocalNetworkGateway2 -ConnectionType IPsec -RoutingWeight 10 -SharedKey $PreSharedKey