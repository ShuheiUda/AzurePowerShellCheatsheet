$Location = "<リージョン名>"
$ResourceGroupName = "<リソース グループ名>"
$VNetName1 = "<仮想ネットワーク名 1>"
$VNetAddressPrefix1 = "10.0.0.0/16"
$GatewaySubnetAddressPrefix1 = "10.0.0.0/28"
$Subnet1AddressPrefix1 = "10.0.1.0/28"
$GatewayName1 = "<ゲートウェイ名 1>"
$GatewayPublicIpName1 = "<ゲートウェイのパブリック IP 名 1>"
$VNetName2 = "<仮想ネットワーク名 2>"
$VNetAddressPrefix2 = "10.1.0.0/16"
$GatewaySubnetAddressPrefix2 = "10.1.0.0/28"
$Subnet1AddressPrefix2 = "10.1.1.0/28"
$GatewayName2 = "<ゲートウェイ名 2>"
$GatewayPublicIpName2 = "<ゲートウェイのパブリック IP 名 2>"
$ConnectionName1 = "<接続名 1>"
$ConnectionName2 = "<接続名 2>"
$PreSharedKey = "<事前共有キー>"
 
# リソース グループを作成
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
 
# 仮想ネットワーク・サブネットを作成
$Subnet1 = New-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -AddressPrefix $GatewaySubnetAddressPrefix1
$Subnet2 = New-AzureRmVirtualNetworkSubnetConfig -Name 'Subnet1' -AddressPrefix $Subnet1AddressPrefix1
New-AzureRmVirtualNetwork -Name $VNetName1 -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $VNetAddressPrefix1 -Subnet $Subnet1, $Subnet2
$Subnet1 = New-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -AddressPrefix $GatewaySubnetAddressPrefix2
$Subnet2 = New-AzureRmVirtualNetworkSubnetConfig -Name 'Subnet1' -AddressPrefix $Subnet1AddressPrefix2
New-AzureRmVirtualNetwork -Name $VNetName2 -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $VNetAddressPrefix2 -Subnet $Subnet1, $Subnet2
 
# ゲートウェイ用のパブリック IP アドレスを作成
$GatewayPublicIp1 = New-AzureRmPublicIpAddress -Name $GatewayPublicIpName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic
$GatewayPublicIp2 = New-AzureRmPublicIpAddress -Name $GatewayPublicIpName2 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic
 
# 作成したリソースを指定して、ゲートウェイを作成
$Vnet1 = Get-AzureRmVirtualNetwork -Name $VNetName1 -ResourceGroupName $ResourceGroupName
$Subnet1 = Get-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $Vnet1
$GatewayIpConfig1 = New-AzureRmVirtualNetworkGatewayIpConfig -Name gwipconfig1 -SubnetId $Subnet1.Id -PublicIpAddressId $GatewayPublicIp1.Id 
New-AzureRmVirtualNetworkGateway -Name $GatewayName1 -ResourceGroupName $ResourceGroupName -Location $Location -IpConfigurations $GatewayIpConfig1 -GatewayType Vpn -VpnType RouteBased -GatewaySku Basic
$Vnet2 = Get-AzureRmVirtualNetwork -Name $VNetName2 -ResourceGroupName $ResourceGroupName
$Subnet2 = Get-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $Vnet2
$GatewayIpConfig2 = New-AzureRmVirtualNetworkGatewayIpConfig -Name gwipconfig2 -SubnetId $Subnet2.Id -PublicIpAddressId $GatewayPublicIp2.Id 
New-AzureRmVirtualNetworkGateway -Name $GatewayName2 -ResourceGroupName $ResourceGroupName -Location $Location -IpConfigurations $GatewayIpConfig2 -GatewayType Vpn -VpnType RouteBased -GatewaySku Basic
 
# Vnet間接続を作成
$VNetGateway1 = Get-AzureRmVirtualNetworkGateway -Name $GatewayName1 -ResourceGroupName $ResourceGroupName
$VNetGateway2 = Get-AzureRmVirtualNetworkGateway -Name $GatewayName2 -ResourceGroupName $ResourceGroupName
New-AzureRmVirtualNetworkGatewayConnection -Name $ConnectionName1 -ResourceGroupName $ResourceGroupName -Location $Location -VirtualNetworkGateway1 $VNetGateway1 -VirtualNetworkGateway2 $VNetGateway2 -ConnectionType Vnet2Vnet -SharedKey $PreSharedKey
New-AzureRmVirtualNetworkGatewayConnection -Name $ConnectionName2 -ResourceGroupName $ResourceGroupName -Location $Location -VirtualNetworkGateway1 $VNetGateway2 -VirtualNetworkGateway2 $VNetGateway1 -ConnectionType Vnet2Vnet -SharedKey $PreSharedKey