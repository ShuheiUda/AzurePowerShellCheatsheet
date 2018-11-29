#設定項目
$SubscriptionId = "<サブスクリプション ID>"
$StorageAccountName = "<ストレージ アカウント名>"
$DiskName = "<ディスク名>"
$ServiceName = "<クラウド サービス名>"
$Location = "<リージョン>"
$VmName = "<仮想マシン名>"
$VmSize = "Standard_D1"
 
#ログイン、サブスクリプション指定 (事前に設定していれば省略可能)
Add-AzureAccount
Select-AzureSubscription -SubscriptionId $SubscriptionId
Set-AzureSubscription –SubscriptionId $SubscriptionId –CurrentStorageAccountName $StorageAccountName
  
#仮想マシンの設定を定義
$VmConfig = New-AzureVMConfig -Name $VmName -InstanceSize $VmSize -DiskName $DiskName
  
#クラウド サービスを作成
New-AzureService -ServiceName $ServiceName -Location $Location
  
#仮想マシンを作成
New-AzureVM –ServiceName $ServiceName -VMs $VmConfig
 
#RDP 用のエンドポイントを作成
Get-AzureVM -ServiceName $ServiceName -Name $VmName | Add-AzureEndpoint -Name "Remote Desktop" -Protocol "tcp" -PublicPort 3389 -LocalPort 3389 | Update-AzureVM