#設定項目
#設定項目
$SubscriptionId = "<サブスクリプション ID>"
$ResourceGroupName = "<リソースグループ名>"
$Location = "<リージョン>"
$VhdUri = "<VHD ファイルパス>"
$VmName = "<仮想マシン名>"
$VmSize = "Standard_D1"
$VnetName = "<仮想ネットワーク名>"
$VnetPrefix = "<仮想ネットワークのアドレス帯>" #192.168.0.0/16 など
$SubnetName = "<サブネット名>"
$SubnetPrefix = "<サブネットのアドレス帯>" #192.168.1.0/24 など
$PublicIpName = "<パブリック IP の名称>"
$Nic1Name = "<NIC の名称>"
 
#ログイン、サブスクリプション指定 (事前に設定していれば省略可能)
#Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionId $SubscriptionId
  
#リソース グループを作成
New-AzureRmResourceGroup –Name $ResourceGroupName -Location $Location
  
#仮想ネットワークを作成
New-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Location $Location -Name $VnetName -AddressPrefix $VnetPrefix
$Vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VnetName
Add-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $Vnet -AddressPrefix $SubnetPrefix |  Set-AzureRmVirtualNetwork
$Subnet = (Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VnetName).Subnets[0]
  
#仮想マシンの設定を定義
$VmConfig = New-AzureRmVMConfig -Name $VmName -VMSize $VmSize
$VmConfig = Set-AzureRmVMOSDisk -VM $VmConfig -VhdUri $VhdUri -Name "OSDisk" -CreateOption attach -Linux -Caching ReadWrite
  
#対象のサブネット情報を取得
$Subnet = (Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VnetName).Subnets[0]
 
#パブリック IP の作成
New-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroupName -Name $PublicIpName -AllocationMethod Dynamic -Location $Location
$PublicIp = Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroupName -Name $PublicIpName
 
#NIC を作成、追加
$Nic1 = New-AzureRmNetworkInterface -Name $Nic1Name -ResourceGroupName $ResourceGroupName -Location $Location -Subnet $Subnet -PublicIpAddress $PublicIp
$Nic1 = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName -Name $Nic1Name
$VmConfig = Add-AzureRmVMNetworkInterface -VM $VmConfig -NetworkInterface $Nic1
$VmConfig.NetworkProfile.NetworkInterfaces.Item(0).Primary = $true
  
#仮想マシンを作成
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VmConfig