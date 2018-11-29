#ImageFamily 一覧の取得
Get-AzureVMImage | Select-Object ImageFamily -Unique | Sort-Object ImageFamily
 
#ImageFamily をもとに最新のイメージを指定
$Image = Get-AzureVMImage | Where-Object {$_.ImageFamily –eq "Windows Server 2012 R2 Datacenter"}| Sort-Object PublishedDate -Descending | Select-Object -ExpandProperty ImageName -First 1
 
########################################
 
#一覧からイメージを手動選択
$ImageFamily = Get-AzureVMImage | Select-Object ImageFamily -Unique | Sort-Object ImageFamily | Out-GridView -Title "Select OS Family" -PassThru
$Image = Get-AzureVMImage | Where-Object { $_.ImageFamily -eq $ImageFamily.ImageFamily } | Select-Object PublishedDate, OS, ImageFamily, Label, LogicalSizeInGB, ImageName | Sort-Object PublishedDate -Descending | Out-GridView -Title "Select VM Image" -PassThru