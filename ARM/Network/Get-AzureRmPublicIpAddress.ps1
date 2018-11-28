# 既存の設定を取得
$PublicIP = Get-AzureRmPublicIpAddress -Name "<Public IP 名>" -ResourceGroupName "<リソース グループ名>"
 
# 正引き名を追加
$PublicIP.DnsSettings += @{DomainNameLabel = "<DNS 名>"}
 
# 設定を反映
Set-AzureRmPublicIpAddress -PublicIpAddress $PublicIP
 
# 実行結果抜粋
# DnsSettings              : {
#                             "DomainNameLabel": "shuda1219",
#                             "Fqdn": "xxx.japaneast.cloudapp.azure.com", <== これをコピー
#                             "ReverseFqdn": 
#                           }
 
# 逆引き名を追加
$PublicIP.DnsSettings.ReverseFqdn = "xxx.japaneast.cloudapp.azure.com"
$PublicIP.DnsSettings.ReverseFqdn = "xxx.contoso.com" <== xxx.contoso.com を正引きして検証できればカスタム ドメインも設定可能
 
# 設定を反映
Set-AzureRmPublicIpAddress -PublicIpAddress $PublicIP
 
# 実行結果抜粋
# DnsSettings              : {
#                             "DomainNameLabel": "shuda1219",
#                             "Fqdn": "xxx.japaneast.cloudapp.azure.com",
#                             "ReverseFqdn": "xxx.japaneast.cloudapp.azure.com"
#                           }