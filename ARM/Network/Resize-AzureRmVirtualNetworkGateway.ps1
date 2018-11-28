$gw = Get-AzureRmVirtualNetworkGateway -Name "<仮想ネットワーク ゲートウェイ名>" -ResourceGroupName "<リソース グループ名>"
Resize-AzureRmVirtualNetworkGateway -VirtualNetworkGateway $gw -GatewaySku <Basic/Standard/HighPerformance>
# Set-AzureRmVirtualNetworkGateway -VirtualNetworkGateway $gw -GatewaySku <Basic/Standard/HighPerformance> でも同じ