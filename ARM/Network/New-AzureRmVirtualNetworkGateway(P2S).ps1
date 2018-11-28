$Location = "<リージョン名>"
$ResourceGroupName = "<リソース グループ名>"
$VNetName = "<仮想ネットワーク名>"
$VNetAddressPrefix = "10.0.0.0/16"
$GatewaySubnetAddressPrefix = "10.0.0.0/28"
$Subnet1AddressPrefix = "10.0.1.0/28"
$GatewayName = "<ゲートウェイ名>"
$GatewayPublicIpName = "<ゲートウェイのパブリック IP 名>"
$ClientAddressPool = "192.168.0.0/24"
$RootCertName = "VpnRootCert.cer"
$RootCertPath = "C:\Users\Administrator\Desktop\VpnRootCert.cer"
 
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
New-AzureRmVirtualNetworkGateway -Name $GatewayName -ResourceGroupName $ResourceGroupName -Location $Location -IpConfigurations $GatewayIpConfig -GatewayType Vpn -VpnType RouteBased -GatewaySku Basic
 
# makecert (要インストール) で証明書を作成
"C:\Program Files (x86)\Windows Kits\10\bin\x64\makecert.exe" -sky exchange -r -n "CN=VpnRootCert" -pe -a sha1 -len 2048 -ss My "VpnRootCert.cer"
"C:\Program Files (x86)\Windows Kits\10\bin\x64\makecert.exe" -n "CN=VpnClientCert" -pe -sky exchange -m 96 -ss My -in "VpnRootCert" -is my -a sha1
  
# 事前にクライアント アドレス プール (クライアント端末に払い出す IP レンジ) を追加
$VNetGateway = Get-AzureRmVirtualNetworkGateway -Name $GatewayName -ResourceGroupName $ResourceGroupName
Set-AzureRmVirtualNetworkGatewayVpnClientConfig -VirtualNetworkGateway $VNetGateway -VpnClientAddressPool $ClientAddressPool
  
# ルート証明書を追加
$RootCertBase64 = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($RootCertPath))
Add-AzureRmVpnClientRootCertificate -VpnClientRootCertificateName $RootCertName -VirtualNetworkGatewayname $VNetGateway.Name -ResourceGroupName $VNetGateway.ResourceGroupName -PublicCertData $RootCertBase64
  
# VPN クライアントのダウンロード (ダウンロード可能になるまで若干時間がかかる)
$ClientUrl = Get-AzureRmVpnClientPackage -ResourceGroupName $VNetGateway.ResourceGroupName -VirtualNetworkGatewayName $VNetGateway.Name -ProcessorArchitecture Amd64
Invoke-WebRequest $ClientUrl
 
# 別途、クライアント端末にはクライアント証明書を配布が必要