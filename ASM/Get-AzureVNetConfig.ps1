Set-AzureVNetConfig -ConfigurationPath "<netcfg ファイルのパス>" #ASM では VNET を直接作成出来ない
Get-AzureVNetConfig -ExportToFile "c:\temp\MyAzNets.netcfg"
Get-AzureVNetSite -VNetName "<VNET 名>"
Remove-AzureVNetConfig #試してないですが、設定を全部消しそうなので要注意