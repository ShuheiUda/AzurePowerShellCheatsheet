#設定項目
$SubscriptionId = "<サブスクリプション ID>"
$StorageAccountName = "<ストレージ アカウント名>"
$ServiceName = "<クラウド サービス名>"
$Location = "<リージョン>"
$VmName = "<仮想マシン名>"
$VmSize = "Standard_D1"
$ImageLabel = "OpenLogic 7.1"
  
#ログイン、サブスクリプション指定 (事前に設定していれば省略可能)
Add-AzureAccount
Select-AzureSubscription -SubscriptionId $SubscriptionId
 
#ストレージアカウントの作成、指定 (事前に設定していれば省略可能)
New-AzureStorageAccount -StorageAccountName $StorageAccountName -Location $Location -Type Standard_GRS
Set-AzureSubscription –SubscriptionId $SubscriptionId –CurrentStorageAccountName $StorageAccountName
 
#ユーザー名・パスワードを設定
$Credential = Get-Credential -Message "Type the name and password of the local administrator account."
  
#仮想マシンの設定を定義
$Image = Get-AzureVMImage | Where-Object {$_.Label –eq $ImageLabel}| Sort-Object PublishedDate -Descending | Select-Object -ExpandProperty ImageName -First 1
$VmConfig = New-AzureVMConfig -Name $VmName -InstanceSize $VmSize -ImageName $Image
$VmConfig | Add-AzureProvisioningConfig -Linux -LinuxUser $Credential.UserName -Password $Credential.Password
  
#クラウド サービスを作成
New-AzureService -ServiceName $ServiceName -Location $Location
  
#仮想マシンを作成
New-AzureVM –ServiceName $ServiceName -VMs $VmConfig