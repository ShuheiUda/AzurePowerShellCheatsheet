# 各種変数を設定します
$ResourceGroupName = "<リソース グループ名>"
$IlbName = "<ロードバランサー名>"
$VnetName = "<仮想ネットワーク名>"
$SubnetName = "<サブネット名>"
$OldFrontendIpName = "<旧フロントエンド IP 名>"
$NewFrontendIpName = "<新フロントエンド IP 名>"
$NewFrontendIpAddress = "<新フロントエンド IP アドレス>"
$OldBackendAddressPoolName = "<旧バックエンド アドレス プール名>"
$NewBackendAddressPoolName = "<新バックエンド アドレス プール名>"
$LoadBalancingRuleName = "<負荷分散規則名>"
$NicNames = @("NIC 名 1","NIC 名 2")
$NicIpConfigName = "NIC の IpCOnfig 名"
 
# 既存のロードバランサーの構成を取得します
$Ilb = Get-AzureRmLoadBalancer -Name $IlbName -ResourceGroupName $ResourceGroupName
 
# フロントエンド IP を配置させる VNET の情報を取得します
$Vnet= Get-AzureRmVirtualNetwork -Name $VnetName -ResourceGroupName $ResourceGroupName
 
# フロントエンド IP を追加します
$Ilb = Add-AzureRmLoadBalancerFrontendIpConfig -Name $NewFrontendIpName -LoadBalancer $Ilb -PrivateIpAddress $NewFrontendIpAddress -SubnetId ($Vnet.subnets | where Name -eq $SubnetName).Id
 
# バックエンド アドレス プールを追加します
$Ilb = Add-AzureRmLoadBalancerBackendAddressPoolConfig -Name $NewBackendAddressPoolName -LoadBalancer $Ilb
 
# 設定を反映します
$Ilb = Set-AzureRmLoadBalancer -LoadBalancer $Ilb
 
# NIC の数だけループさせます
foreach($NicName in $NicNames){
    # バックエンド アドレス プールの構成を取得します
    $Backend = Get-AzureRmLoadBalancerBackendAddressPoolConfig -name $NewBackendAddressPoolName -LoadBalancer $Ilb
 
    # バックエンド アドレス プールに紐付ける既存の NIC の構成を取得します
    $Nic = Get-AzureRmNetworkInterface –name $NicName -resourcegroupname $ResourceGroupName
 
    # バックエンド アドレス プールに既存の VM の NIC を紐付けます
    ($Nic.IpConfigurations | where Name -eq $NicIpConfigName).LoadBalancerBackendAddressPools = $Backend
 
    # NIC の設定を反映します
    $Nic = Set-AzureRmNetworkInterface -NetworkInterface $Nic
}
 
# 既存の負荷分散規則に紐づくフロントエンド IPを変更します
($Ilb.LoadBalancingRules | where Name -eq $LoadBalancingRuleName).FrontendIPConfiguration.Id = ($Ilb.FrontendIpConfigurations | where Name -eq $NewFrontendIpName).Id
 
# 既存の負荷分散規則に紐づくバックエンド アドレス プールを変更します
($Ilb.LoadBalancingRules | where Name -eq $LoadBalancingRuleName).BackendAddressPool.Id = ($Ilb.BackendAddressPools | where Name -eq $NewBackendAddressPoolName).Id
 
# 不要になったフロントエンド IP を削除します
$Ilb = Remove-AzureRmLoadBalancerFrontendIpConfig -Name $OldFrontendIpName -LoadBalancer $ilb
 
# 不要になったバックエンド アドレス プールを削除します
$Ilb = Remove-AzureRmLoadBalancerBackendAddressPoolConfig -Name $OldBackendAddressPoolName -LoadBalancer $ilb
 
# 設定を反映します
$Ilb = Set-AzureRmLoadBalancer -LoadBalancer $Ilb