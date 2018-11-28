<# Public IP を付与しないと RDP 出来ないので、要追加 (以降すべて) #>
 
#設定項目
$SubscriptionId = "<サブスクリプション ID>"
$ResourceGroupName = "<リソースグループ名>"
$StorageAccountName = "<ストレージ アカウント名>"
$Location = "<リージョン>"
$VmName = "<仮想マシン名>"
$VmSize = "Standard_D1"
$VnetName = "<仮想ネットワーク名>"
$SubnetName = "<サブネット名>"
$Nic1Name = "<NIC1 の名称>"
 
#ログイン、サブスクリプション指定 (事前に設定していれば省略可能)
Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionId $SubscriptionId
 
#ユーザー名・パスワードを設定
$Credential = Get-Credential
 
#リソース グループを作成
New-AzureRmResourceGroup –Name $ResourceGroupName -Location $Location
 
#ストレージ アカウントを作成
New-AzureRmStorageAccount –StorageAccountName $StorageAccountName -Location "East Asia" -Type Standard_GRS –ResourceGroupName $ResourceGroupName
$StorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
 
#仮想ネットワークを作成
New-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Location "East Asia" -Name $VnetName -AddressPrefix "192.168.0.0/16"
$Vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VnetName
Add-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $Vnet -AddressPrefix "192.168.1.0/24" |  Set-AzureRmVirtualNetwork
$Subnet = (Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VnetName).Subnets[0]
 
#仮想マシンの設定を定義
$VmConfig = New-AzureRmVMConfig -Name $VmName -VMSize $VmSize
$VmConfig = Set-AzureRmVMOperatingSystem -VM $VmConfig -Windows -ComputerName $VmName -Credential $Credential
$VmConfig = Set-AzureRmVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2012-R2-Datacenter" -VM $VmConfig -Version "latest"
$VhdUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $VmName + "_OSDisk.vhd"
$VmConfig = Set-AzureRmVMOSDisk -VM $VmConfig -Name "OSDisk" -VhdUri $VhdUri -CreateOption fromImage
 
#NIC を作成、追加
$Nic1 = New-AzureRmNetworkInterface -Name $Nic1Name -ResourceGroupName $ResourceGroupName -Location $Location -Subnet $Subnet
$Nic1 = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName -Name $Nic1Name
$VmConfig = Add-AzureRmVMNetworkInterface -VM $VmConfig -NetworkInterface $Nic1
$VmConfig.NetworkProfile.NetworkInterfaces.Item(0).Primary = $true
 
#仮想マシンを作成
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VmConfig -Verbose