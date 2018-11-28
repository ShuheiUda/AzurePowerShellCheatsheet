## 非管理ディスクの場合
#事前に仮想マシンの停止が必要
$VmConfig = Get-AzureRmVM -Name "<仮想マシン名>" -ResourceGroupName "<リソース グループ名>"
$VmConfig.StorageProfile[0].OSDisk[0].DiskSizeGB = 1023
Update-AzureRmVM -ResourceGroupName "<リソース グループ名>" -VM $VmConfig
 
## 管理ディスクの場合
#事前に仮想マシンの停止が必要
New-AzureRmDiskUpdateConfig -DiskSizeGB 1023 | Update-AzureRmDisk -ResourceGroupName "<リソース グループ名>" -DiskName "<ディスク名>"