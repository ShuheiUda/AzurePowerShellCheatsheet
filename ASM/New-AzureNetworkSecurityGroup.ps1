# NSG を作成
New-AzureNetworkSecurityGroup -Name "<NSG 名>" -Location "<リージョン>" -Label "<ラベル>"
 
# NSG にルールを追加
Get-AzureNetworkSecurityGroup -Name "<NSG 名>" | Set-AzureNetworkSecurityRule -Name "<ルール名>" -Action <Allow/Deny> -Protocol <*/TCP/UDP> -Type Inbound -Priority "<優先度>" -SourceAddressPrefix "<接続元のアドレス レンジ>" -SourcePortRange "<接続元ポート>" -DestinationAddressPrefix "<接続先のアドレス レンジ>" -DestinationPortRange "<接続先ポート>"
 
# NSG を VM に紐づけ
Get-AzureVM -ServiceName "<クラウド サービス名>" -Name "<仮想マシン名>" | Set-AzureNetworkSecurityGroupAssociation -Name "<NSG 名>"
 
# NSG を Subnet に紐づけ
Set-AzureNetworkSecurityGroupAssociation -Name "<仮想マシン名>" -VirtualNetworkName "<仮想ネットワーク名>" -SubnetName "<サブネット名>"
 
# NSG を取得
Get-AzureNetworkSecurityGroup -Name "<NSG 名>" -Detailed
 
# VM から NSG の紐づけを削除
Get-AzureVM -ServiceName "<クラウド サービス名>" -Name "<仮想マシン名>" | Remove-AzureNetworkSecurityGroupAssociation -Name "<NSG 名>"
 
# Subnet から NSG の紐づけを削除
Remove-AzureNetworkSecurityGroupAssociation -Name "shuda0903vnet" -VirtualNetworkName "<仮想ネットワーク名>" -SubnetName "<サブネット名>"
 
# NSG を削除
Remove-AzureNetworkSecurityGroup -Name "<NSG 名>"