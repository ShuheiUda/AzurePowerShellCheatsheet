<#
.SYNOPSIS
NSG のルールを CSV から追加するサンプル

.DESCRIPTION
Name      : Add-AzureRmNetworkSecurityRuleConfigFromCSV
GitHub    : https://github.com/ShuheiUda/AzurePowerShellCheatsheet
Author    : Syuhei Uda
LastCheck : 2018/11/29 (Azure PowerShell 6.13.1)
Usage     :事前に以下のようなフォーマットで CSV ファイルを作成しておきます。

Name,Description,Protocol,SourcePortRange,DestinationPortRange,SourceAddressPrefix,DestinationAddressPrefix,Access,Priority,Direction
rule1,rule1,TCP,*,80,*,*,Allow,100,Inbound
rule2,rule2,TCP,*,8080,*,*,Deny,110,Inbound
rule3,rule3,TCP,*,3389,*,*,Allow,120,Inbound
rule4,rule4,UDP,*,3389,*,*,Allow,130,Inbound

#>

# ログイン等
Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionId "<サブスクリプション ID>"

# 既存の NSG を取得
$NSG = Get-AzureRmNetworkSecurityGroup -Name "<NSG の名前>" -ResourceGroupName "<リソース グループ名>"

# CSV ファイルを取得
$CSV = Import-CSV "<CSV ファイルのパス>" -Encoding UTF8

# 各行のルールを追加
$CSV | foreach{
    Add-AzureRmNetworkSecurityRuleConfig `
    -Name $_.Name `
    -NetworkSecurityGroup $NSG `
    -Description $_.Description `
    -Protocol $_.Protocol `
    -SourcePortRange $_.SourcePortRange `
    -DestinationPortRange $_.DestinationPortRange `
    -SourceAddressPrefix $_.SourceAddressPrefix `
    -DestinationAddressPrefix $_.DestinationAddressPrefix `
    -Access $_.Access `
    -Priority $_.Priority `
    -Direction $_.Direction
}

# 設定を反映
Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $NSG