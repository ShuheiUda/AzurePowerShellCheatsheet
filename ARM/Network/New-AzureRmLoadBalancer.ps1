# 定義
$SubscriptionId = "<サブスクリプション ID>"
$RgName = "<リソース グループ名>"
$Location = "Japan East"
 
# ログイン処理
Login-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId $SubscriptionId
New-AzureRmResourceGroup -Name $RgName -location $Location
 
# 仮想ネットワークの作成
$backendSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name LB-Subnet-BE -AddressPrefix 10.0.2.0/24
New-AzureRmvirtualNetwork -Name NRPVNet -ResourceGroupName $RgName -Location $Location -AddressPrefix 10.0.0.0/16 -Subnet $backendSubnet
 
# フロントエンド IP の作成
$publicIP1 = New-AzureRmPublicIpAddress -Name PublicIp1 -ResourceGroupName $RgName -Location $Location –AllocationMethod Static -DomainNameLabel loadbalancernrp1
$publicIP2 = New-AzureRmPublicIpAddress -Name PublicIp2 -ResourceGroupName $RgName -Location $Location –AllocationMethod Static -DomainNameLabel loadbalancernrp2
 
# フロントエンド IP を定義
$frontendIP1 = New-AzureRmLoadBalancerFrontendIpConfig -Name LB-Frontend1 -PublicIpAddress $publicIP1
$frontendIP2 = New-AzureRmLoadBalancerFrontendIpConfig -Name LB-Frontend2 -PublicIpAddress $publicIP2
 
# バックエンド アドレス プールを作成
$beaddresspool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name LB-backend
 
# プローブを定義
$healthProbe = New-AzureRmLoadBalancerProbeConfig -Name HealthProbe -RequestPath '/' -Protocol http -Port 80 -IntervalInSeconds 15 -ProbeCount 2
 
# 負荷分散ルールを定義
$lbrule1 = New-AzureRmLoadBalancerRuleConfig -Name HTTP1 -FrontendIpConfiguration $frontendIP1 -BackendAddressPool  $beAddressPool -Probe $healthProbe -Protocol Tcp -FrontendPort 80 -BackendPort 80
$lbrule2 = New-AzureRmLoadBalancerRuleConfig -Name HTTP2 -FrontendIpConfiguration $frontendIP2 -BackendAddressPool  $beAddressPool -Probe $healthProbe -Protocol Tcp -FrontendPort 80 -BackendPort 80
 
# LB を作成
$LB = New-AzureRmLoadBalancer -ResourceGroupName $RgName -Name NRP-LB -Location $Location -FrontendIpConfiguration $frontendIP1,$frontendIP2 -LoadBalancingRule $lbrule1,$lbrule2 -BackendAddressPool $beAddressPool -Probe $healthProbe