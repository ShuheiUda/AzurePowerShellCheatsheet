# !!! NSG との併用は NG !!!
 
# 空の ACL オブジェクトを作成して、ルールを追加
$Acl = New-AzureAclConfig
Set-AzureAclConfig -AddRule -ACL $Acl -Order "<優先度>" -Action <Permit/Deny> -RemoteSubnet "<アドレス レンジ>" -Description "<説明>"
 
# 新規のエンドポイントを作成する場合
Get-AzureVM -ServiceName "<クラウド サービス名>" -Name "<仮想マシン名>" | Add-AzureEndpoint -Name "<エンドポイント名>" -Protocol tcp -Localport "<ローカル ポート>" -PublicPort "<パブリック ポート>" -ACL $Acl | Update-AzureVM
# 既存のエンドポイントを上書きする場合
Get-AzureVM -ServiceName "<クラウド サービス名>" -Name "<仮想マシン名>" | Set-AzureEndpoint -Name "<エンドポイント名>" -Protocol tcp -Localport "<ローカル ポート>" -PublicPort "<パブリック ポート>" -ACL $Acl | Update-AzureVM
 
# エンドポイントを取得して、ACL を参照
$Endpoint = Get-AzureVM -ServiceName "<クラウド サービス名>" -Name "<仮想マシン名>" | Get-AzureEndpoint
$Endpoint[0].ACL
 
# エンドポイントごと削除
Get-AzureVM -ServiceName "<クラウド サービス名>" -Name "<仮想マシン名>" | Remove-AzureEndpoint -Name "<エンドポイント名>"