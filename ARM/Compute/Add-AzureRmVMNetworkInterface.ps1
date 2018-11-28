#同一リソース グループ内にシングル NIC とマルチ NIC の環境混在は不可
#(シングル -> マルチ、マルチ -> シングルの変更不可、NIC 差し替えは可)
$SubscriptionId = "<サブスクリプション ID>"
$VmName = "仮想マシン名"
$VnetName = "仮想ネットワーク名"
$ResourceGroupName = "リソースグループ名"
$Location = "<リージョン>"
$Nic2Name = "NIC2 の名称"
 
$VmConfig = Get-AzureRmVM -Name $VmName -ResourceGroupName $ResourceGroupName
$Subnet = (Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VnetName).Subnets[0]
$Nic2 = New-AzureRmNetworkInterface -Name $Nic2Name -ResourceGroupName $ResourceGroupName -Location $Location -Subnet $Subnet
$Nic2 = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName -Name $Nic2Name
$VmConfig = Add-AzureRmVMNetworkInterface -VM $VmConfig -NetworkInterface $Nic2