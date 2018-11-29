#事前に仮想マシンの停止が必要
$VmConfig = Get-AzureVM -ServiceName "<クラウド サービス名>" -Name "<仮想マシン名>"
$VmConfig.VM.OSVirtualHardDisk.ResizedSizeInGB = 1023
$VmConfig.VM.OSVirtualHardDisk | Update-AzureDisk -Label "OS Disk"