# NSG を作成
$Nsg = New-AzureRmNetworkSecurityGroup -Name "<NSG 名>" -ResourceGroupName "<リソース グループ名>" -Location "<リージョン>"
 
# NSG にルールを追加
$Nsg = Add-AzureRmNetworkSecurityRuleConfig  -Name "<ルール名>" -NetworkSecurityGroup $nsg -Description "<説明>" -Protocol <*/Tcp/Udp> -SourcePortRange "<接続元ポート>" -DestinationPortRange "<接続先ポート>" -SourceAddressPrefix "<接続元のアドレス レンジ>" -DestinationAddressPrefix "<接続先のアドレス レンジ>" -Access <Allow/Deny> -Priority "<優先度>" -Direction <Inbound/Outbound>
 
# NSG を NIC に紐づけ
$Nic = Get-AzureRmNetworkInterface -Name "<NIC 名>" -ResourceGroupName "<リソース グループ名>"
$Nic.NetworkSecurityGroup = $Nsg
Set-AzureRmNetworkInterface -NetworkInterface $Nic
 
# NSG を Subnet に紐づけ
$Vnet = Get-AzureRmVirtualNetwork -ResourceGroupName "<リソース グループ名>" -Name "<仮想ネットワーク名>"
Set-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $Vnet -Name "<サブネット名>" -AddressPrefix "<アドレス レンジ>" -NetworkSecurityGroup $Nsg
Set-AzureRmVirtualNetwork -VirtualNetwork $Vnet
 
# 以下追記予定 
 
# NSG を取得
# NIC から NSG の紐づけを削除
# Subnet から NSG の紐づけを削除
# NSG を削除