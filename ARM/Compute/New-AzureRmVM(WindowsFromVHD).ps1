#設定項目
$SubscriptionId = "<サブスクリプション ID>"
$ResourceGroupName = "<リソースグループ名>"
$Location = "<リージョン>"
$VhdUri = "<VHD ファイルパス>"
$VmName = "<仮想マシン名>"
$VmSize = "Standard_D1"
$VnetName = "<仮想ネットワーク名>"
$SubnetName = "<サブネット名>"
$Nic1Name = "<NIC1 の名称>"
 
# ログインおよびサブスクリプションの指定
Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionId $SubscriptionId
 
#リソース グループを作成
New-AzureRmResourceGroup –Name $ResourceGroupName -Location $Location
 
#仮想ネットワークを作成
New-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Location "East Asia" -Name $VnetName -AddressPrefix "192.168.0.0/16"
$Vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VnetName
Add-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $Vnet -AddressPrefix "192.168.1.0/24" |  Set-AzureRmVirtualNetwork
$Subnet = (Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VnetName).Subnets[0]
 
# 仮想マシンの設定を定義
$VmConfig = New-AzureRmVMConfig -Name $VmName -VMSize $VmSize
$VmConfig = Set-AzureRmVMOSDisk -VM $VmConfig -VhdUri $VhdUri -Name "OSDisk" -CreateOption attach -Windows -Caching ReadWrite
 
# 対象のサブネット情報を取得
$Subnet = (Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VnetName).Subnets[0]
 
#NIC を作成、追加
$Nic1 = New-AzureRmNetworkInterface -Name $Nic1Name -ResourceGroupName $ResourceGroupName -Location $Location -Subnet $Subnet
$Nic1 = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName -Name $Nic1Name
$VmConfig = Add-AzureRmVMNetworkInterface -VM $VmConfig -NetworkInterface $Nic1
$VmConfig.NetworkProfile.NetworkInterfaces.Item(0).Primary = $true
 
#仮想マシンを作成
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VmConfig -Verbose