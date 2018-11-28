# 既存の "接続" を削除します
Remove-AzureRmVirtualNetworkGatewayConnection -Name "<接続名>" -ResourceGroupName "<リソース グループ名>"
 
# 既存の設定を取得します
$LocalGW = Get-AzureRmLocalNetworkGateway -Name "<ローカル ネットワーク ゲートウェイ名>" -ResourceGroupName "<リソース グループ名>"
 
# アドレス レンジを追加します
$AddressPrefix = $LocalGW.LocalNetworkAddressSpace.AddressPrefixes
$AddressPrefix += "192.168.0.0/24"
$AddressPrefix += "192.168.1.0/24"
$AddressPrefix += "192.168.2.0/24"
$AddressPrefix += "192.168.3.0/24"
 
# 設定を反映します
Set-AzureRmLocalNetworkGateway -LocalNetworkGateway $LocalGW -AddressPrefix $AddressPrefix
 
# "接続" を再作成します
$GW = Get-AzureRmVirtualNetworkGateway -Name "<仮想ネットワーク ゲートウェイ名>" -ResourceGroupName "<リソース グループ名>"
New-AzureRmVirtualNetworkGatewayConnection -Name "<接続名>" -ResourceGroupName "<リソース グループ名>" -Location "<リージョン名>" -VirtualNetworkGateway1 $GW -LocalNetworkGateway2 $LocalGW -ConnectionType IPsec -RoutingWeight 10 -SharedKey "<事前共有キー>"