<#
.SYNOPSIS
UDR のルートを CSV から追加するサンプル

.DESCRIPTION
Name      : Add-AzureRmRouteConfigFromCSV
GitHub    : https://github.com/ShuheiUda/AzurePowerShellCheatsheet
Author    : Syuhei Uda
LastCheck : 2018/11/29 (Azure PowerShell 6.13.1)
Usage     :事前に以下のようなフォーマットで CSV ファイルを作成しておきます。

Name,AddressPrefix,NextHopType,NextHopIpAddress
route1,23.102.135.246/32,Internet,
route2,10.0.0.0/8,VirtualNetworkGateway,
route3,172.16.0.0/12,VnetLocal,
route4,192.168.0.0/16,VirtualAppliance,172.16.0.4

#>

# 既存の UDR の設定を取得します
$UDR = Get-AzureRmRouteTable -name "<UDR 名>" -ResourceGroupName "<リソース グループ名>"

# CSV ファイルを読み込みます 
$CSV = Get-Content "<CSV ファイルのパス>" -Encoding UTF8 -Raw | ConvertFrom-Csv

## CSV の各行について、追加処理を行います。
$CSV | foreach{
    Add-AzureRmRouteConfig -Name $_.Name -AddressPrefix $_.AddressPrefix -NextHopType $_.NextHopType -NextHopIpAddress $_.NextHopIpAddress -RouteTable $UDR
}

# 上記で設定した内容を反映します
Set-AzureRmRouteTable -routetable $UDR