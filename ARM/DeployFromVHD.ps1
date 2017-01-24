# Initialize
$VerbosePreference = "Continue"
  
# Import Module
Import-Module Azure
Import-Module AzureRm.Compute
Import-Module AzureRm.Network
Import-Module AzureRm.Storage
  
# Login
Login-AzureRmAccount
  
# Select Azure Subscription 
$subscriptionId = (Get-AzureRmSubscription | Out-GridView -Title "Select an Azure Subscription ..." -PassThru).SubscriptionId 
Select-AzureRmSubscription -SubscriptionId $subscriptionId
  
# Select Source VHD
$VhdUri = Read-Host -Prompt "Please input VHD Path"
 
# Select Additional Data Disks
$DataDisks = @()
$DataDiskCount = Read-Host -Prompt "Input Data Disk count"
for($i = 0; $i -lt $DataDiskCount; $i++){
    $DataDiskVhdUri = Read-Host -Prompt "Please input VHD Path for Data Disk $($i+1)"
    $DataDiskSizeInGB = Read-Host -Prompt "Please input VHD Size for Data Disk $($i+1)"
    $DataDisks += [PSCustomObject]@{"VhdUri" = $DataDiskVhdUri;"DiskSizeInGB" = $DataDiskSizeInGB;}
}
  
# Select Location
$Location = (Get-AzureRmLocation | Out-GridView -Title "Select Location ..." -PassThru).Location
  
# Select Resource Group
$ResourceGroups = @([PSCustomObject]@{"ResourceGroupName" = "Create New"; "Location" = "n/a"; "ResourceId" = "n/a";})
$ResourceGroups +=  (Get-AzureRmResourceGroup | Select-Object -Property ResourceGroupName, Location, ResourceId)
$ResourceGroup = $ResourceGroups | Out-GridView -Title "Select an Azure Resource Group ..." -PassThru
if($ResourceGroup.ResourceGroupName -eq "Create New"){
    $ResourceGroup.ResourceGroupName = Read-Host -Prompt "Please input Resource Group name"
    Write-Verbose "Creating new Availability Set `"$($ResourceGroup.ResourceGroupName)`""
    $ResourceGroup = New-AzureRmResourceGroup -Name $ResourceGroup.ResourceGroupName -Location $Location
}
  
# Select Deploy Type (Generalize / Specialize)
$DeploymentTypes = @(
    [PSCustomObject]@{"DeploymentType" = "Generalize"; "Description" = "Deploy from syspreped VHD file";}
    [PSCustomObject]@{"DeploymentType" = "Specialize"; "Description" = "Deploy from non-syspreped VHD file";}
)
$DeploymentType = ($DeploymentTypes | Out-GridView -Title "Select deployment type..." -PassThru).DeploymentType
  
# Selct OS Type
$OsTypes = @(
    [PSCustomObject]@{"OSType" = "Windows";}
    [PSCustomObject]@{"OSType" = "Linux";}
)
$OsType = ($OsTypes | Out-GridView -Title "Select OS type..." -PassThru).OSType
  
# Select Avaiability Set
$AvailabilitySets = @([PSCustomObject]@{"Name" = "Create New"; "Location" = "n/a"; "ResourceGroupName" = "n/a"; "Id" = "n/a"; })
$AvailabilitySets += (Get-AzureRmResourceGroup | Get-AzureRmAvailabilitySet | Select-Object -Property Name,  Location, ResourceGroupName, Id)
$AvailabilitySet = ($AvailabilitySets | Out-GridView -Title "Select Availability Set..." -PassThru).Name
if($AvailabilitySet -eq "Create New"){
    $AvailabilitySet = Read-Host -Prompt "Please input Availability Set name"
    Write-Verbose "Creating new Availability Set `"$AvailabilitySet`""
    $AvailabilitySet = New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroup.ResourceGroupName -Name $AvailabilitySet -Location $Location
}
  
# Select VM Size
$VmSize = (Get-AzureRmVMSize -Location $Location | Select-Object -Property Name, NumberOfCores, MemoryInMB, MaxDataDiskCount | Out-GridView -Title "Slect VM Size..." -PassThru)
  
# Select NIC Type
$NicTypes = @(
    [PSCustomObject]@{"NicType" = "Single NIC";}
    [PSCustomObject]@{"NicType" = "Multiple NIC";}
)
$NicType = ($NicTypes | Out-GridView -Title "Select NIC type..." -PassThru).NicType
  
# Select Virtual Network
$EmptySubnet = (New-Object -TypeName "Microsoft.Azure.Commands.Network.Models.PSSubnet")
$EmptySubnet = "n/a"
$VirtualNetworks = @([PSCustomObject]@{"Name" = "Create New"; "AddressSpace" = "n/a"; "Subnets" = $EmptySubnet; "Location" = "n/a"; "ResourceGroupName" = "n/a"; "Id" = "n/a"; })
$VirtualNetworks += (Get-AzureRmVirtualNetwork | Select-Object -Property Name, @{Name = "AddressSpace"; Expression = {$_.AddressSpace.AddressPrefixes -join ", "}}, Subnets, Location, ResourceGroupName, Id)
$VirtualNetwork = $VirtualNetworks | Out-GridView -Title "Select Virtual Network..." -PassThru
if($VirtualNetwork.Name -eq "Create New"){
    $VirtualNetwork.Name = Read-Host -Prompt "Please input Virtual Network name"
    $AddressPrefix = Read-Host -Prompt "Please input AddressPrefix"
    Write-Verbose "Creating new Virtual Network `"$($VirtualNetwork.Name)`""
    $VirtualNetwork = New-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroup.ResourceGroupName -Name $VirtualNetwork.Name -Location $Location -AddressPrefix $AddressPrefix
    $SubnetCount = Read-Host -Prompt "Please input Subnet Count"
    if($SubnetCount -lt 1){Write-Error "Please input value greater equal 1."}
    for($i = 0; $i -lt $SubnetCount; $i++){
        $SubnetName = Read-Host -Prompt "Please input Subnet name"
        $SubnetAddressPrefix = Read-Host -Prompt "Please input address prefix"
        $VirtualNetwork = $VirtualNetwork | Add-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressPrefix
    }
      
    Write-Verbose "Updating Virtual Network `"$($VirtualNetwork.Name)`""
    $VirtualNetwork = Set-AzureRmVirtualNetwork -VirtualNetwork $VirtualNetwork
}
  
# Select Subnet
$Subnet = $VirtualNetwork.Subnets | Select-Object -Property Name, AddressPrefix, NetworkSecurityGroupText, RouteTableText, Id | Out-GridView -Title "Select Subnet..." -PassThru
if($Subnet.Name -eq "GatewaySubnet"){Write-Error "Can't select `"GatewaySubnet`"."}
  
# Select Public IP
$PublicIPs = @(
    [PSCustomObject]@{"Name" = "Create New"; "IpAddress" = "n/a"; "PublicIpAllocationMethod" = "n/a"; "Location" = "n/a"; "ResourceGroupName" = "n/a"; "Id" = "n/a"; }
    [PSCustomObject]@{"Name" = "None"; "IpAddress" = "n/a"; "PublicIpAllocationMethod" = "n/a"; "Location" = "n/a"; "ResourceGroupName" = "n/a"; "Id" = "n/a"; }
)
$PublicIPs += (Get-AzureRmPublicIpAddress | Where-Object {$_.IpConfiguration.Id -eq $null} | Select-Object -Property Name, IpAddress, PublicIpAllocationMethod, Location, ResourceGroupName, Id)
$PublicIP = $PublicIPs | Out-GridView -Title "Select Public IP..." -PassThru
if($PublicIP.Name -eq "Create New"){
    $PublicIP.Name = Read-Host -Prompt "Please input Public IP name"
    Write-Verbose "Creating new Public IP `"$($PublicIP.Name)`""
    $PublicIP = New-AzureRmPublicIpAddress -Name $PublicIp.Name -ResourceGroupName $ResourceGroup.ResourceGroupName -Location $Location -AllocationMethod Dynamic
}elseif($PubliIP.Name -eq "None"){
    $PublicIP.Name = $null
}
  
# Select NIC
$Nics = @([PSCustomObject]@{"Name" = "Create New"; "Location" = "n/a"; "ResourceGroupName" = "n/a"; "Id" = "n/a"; })
$Nics += (Get-AzureRmNetworkInterface | Where-Object {$_.IpConfigurations.Subnet.Id -eq $Subnet.Id} | Select-Object -Property Name, Location, ResourceGroupName, Id)
$Nic = $Nics | Out-GridView -Title "Select primary NIC..." -PassThru
if($Nic.Name -eq "Create New"){
    $Nic.Name = Read-Host -Prompt "Please input NIC name"
    Write-Verbose "Creating new NIC `"$($Nic.Name)`""
    if($PublicIP -eq $null){
        $Nic = New-AzureRmNetworkInterface -Name $Nic.Name -ResourceGroupName $ResourceGroup.ResourceGroupName -Location $Location -SubnetId $Subnet.Id
    }else{
        $Nic = New-AzureRmNetworkInterface -Name $Nic.Name -ResourceGroupName $ResourceGroup.ResourceGroupName -Location $Location -SubnetId $Subnet.Id -PublicIpAddressId $PublicIP.Id
    }
}
  
# Select Secondary Subnet / NIC
if($NicType -eq "Multiple NIC"){
    $SecondarySubnet = $VirtualNetwork.Subnets | Select-Object -Property Name, AddressPrefix, NetworkSecurityGroupText, RouteTableText, Id | Out-GridView -Title "Select secondary Subnet..." -PassThru
    if($SecondarySubnet.Name -eq "GatewaySubnet"){Write-Error "Can't select `"GatewaySubnet`"."}
      
    $SecondaryNics = @([PSCustomObject]@{"Name" = "Create New"; "Location" = "n/a"; "ResourceGroupName" = "n/a"; "Id" = "n/a"; })
    $SecondaryNics += (Get-AzureRmNetworkInterface | Where-Object {$_.IpConfigurations.Subnet.Id -eq $SecondarySubnet.Id} | Select-Object -Property Name, Location, ResourceGroupName, Id)
    $SecondaryNic = $SecondaryNics | Out-GridView -Title "Select secondary NIC..." -PassThru
    if($SecondaryNic.Name -eq "Create New"){
        $SecondaryNic.Name = Read-Host -Prompt "Please input secondary NIC name"
        Write-Verbose "Creating new NIC `"$($SecondaryNic.Name)`""
        New-AzureRmNetworkInterface -Name $SecondaryNic.Name -ResourceGroupName $ResourceGroup.ResourceGroupName -Location $Location -SubnetId $SecondarySubnet.Id
    }
}
  
# Create VM
$Vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroup.ResourceGroupName -Name $VirtualNetwork.Name
$Subnet = $Vnet.Subnets | Where-Object {$_.Id -eq $Subnet.Id}
   
$VmName = Read-Host -Prompt "Please input VM name"
$VmConfig = New-AzureRmVMConfig -Name $VmName -VMSize $VmSize.Name
  
$Nic1 = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroup.ResourceGroupName -Name $Nic.Name
$VmConfig = Add-AzureRmVMNetworkInterface -VM $VmConfig -Id $nic1.Id -Primary
  
if($NicType -eq "Multiple NIC"){
    $Nic2 = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroup.ResourceGroupName -Name $SecondaryNic.Name
    $VmConfig = Add-AzureRmVMNetworkInterface -VM $VmConfig -Id $nic2.Id
}
   
  
if($DeploymentType -eq "Generalize"){
    $Credential = Get-Credential
    if($OsType -eq "Windows"){
        $VmConfig = Set-AzureRmVMOperatingSystem -VM $VmConfig -Windows -ComputerName $VmName -Credential $Credential
    }elseif($OsType -eq "Linux"){
        $VmConfig = Set-AzureRmVMOperatingSystem -VM $VmConfig -Linux -ComputerName $VmName -Credential $Credential
    }
    $OsDiskUri = ((Split-Path $VhdUri -Parent) -replace "\\","/") + "/$($VmName)OSDisk.vhd"
    if($OsType -eq "Windows"){
        $VmConfig = Set-AzureRmVMOSDisk -VM $VmConfig -Name "OSDisk" -VhdUri $OsDiskUri -CreateOption fromImage -SourceImageUri $VhdUri -Windows
    }elseif($OsType -eq "Linux"){
        $VmConfig = Set-AzureRmVMOSDisk -VM $VmConfig -Name "OSDisk" -VhdUri $OsDiskUri -CreateOption fromImage -SourceImageUri $VhdUri -Linux
    }
}elseif($DeploymentType -eq "Specialize"){
    if($OsType -eq "Windows"){
    $VmConfig = Set-AzureRmVMOSDisk -VM $VmConfig -Name "OSDisk" -VhdUri $VhdUri -CreateOption attach -Windows
    }elseif($OsType -eq "Linux"){
    $VmConfig = Set-AzureRmVMOSDisk -VM $VmConfig -Name "OSDisk" -VhdUri $VhdUri -CreateOption attach -Linux
    }
}
if($DataDiskCount -ge 1){
    for($i = 0; $i -lt $DataDiskCount; $i++){
        $VmConfig = Add-AzureRmVMDataDisk -VM $VmConfig -VhdUri $DataDisks[$i].VhdUri -Name "DataDisk$($i+1)" -CreateOption Attach -Lun $i -DiskSizeInGB $DataDisks[$i].DiskSizeInGB
    }
}
if($AvailabilitySet.Id -ne $null){
    $VmConfig.AvailabilitySetReference = $AvailabilitySet.Id
}
New-AzureRmVM -ResourceGroupName $ResourceGroup.ResourceGroupName -Location $Location -VM $VmConfig -Verbose