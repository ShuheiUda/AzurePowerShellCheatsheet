Get-AzureVM -ServiceName "<クラウド サービス名>" -Name "<仮想マシン名>" | Add-AzureEndpoint -Name "RDP" -Protocol "tcp" -PublicPort 3389 -LocalPort 3389 | Update-AzureVM
Get-AzureVM -ServiceName "<クラウド サービス名>" -Name "<仮想マシン名>" | Add-AzureEndpoint -Name "PowerShell" -Protocol "tcp" -PublicPort 5986 -LocalPort 5986 | Update-AzureVM
 
Get-AzureVM -ServiceName "<クラウド サービス名>" -Name "<仮想マシン名>" | Remove-AzureEndpoint -Name "RDP" | Update-AzureVM
Get-AzureVM -ServiceName "<クラウド サービス名>" -Name "<仮想マシン名>" | Remove-AzureEndpoint -Name "PowerShell" | Update-AzureVM