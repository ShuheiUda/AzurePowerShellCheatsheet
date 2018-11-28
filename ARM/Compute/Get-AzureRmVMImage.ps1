#ImagePublisher 一覧の取得
Get-AzureRmVMImagePublisher -Location "East Asia"
 
#ImageOffer 一覧の取得
Get-AzureRmVMImageOffer -Location "East Asia" -PublisherName MicrosoftWindowsServer
 
#ImageSku 一覧の取得
Get-AzureRmVMImageSku -Location "East Asia" -PublisherName MicrosoftWindowsServer -Offer WindowsServer
 
#Image を取得
Get-AzureRmVMImage -Location "East Asia" -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-Datacenter
 
########################################
 
#VM の構成情報に OS イメージを指定 (詳細は後述)
$VmConfig = Set-AzureRmVMSourceImage -VM $Vm -PublisherName "OpenLogic" -Offer "CentOS" -Skus "6.7" -Version "latest"