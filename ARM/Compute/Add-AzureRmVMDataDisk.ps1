﻿Get-AzureRmVM -ResourceGroupName "<リソース グループ名>" -Name "<仮想マシン名>" | Add-AzureRmVMDataDisk -CreateOption empty -DiskSizeInGB "<ディスク サイズ>" -Name "<ディスク名>" -Lun "<LUN 番号>" -VhdUri "<VHD 配置先のフルパス>" | Update-AzureRmVM
Get-AzureRmVM -ResourceGroupName "<リソース グループ名>" -Name "<仮想マシン名>" | Remove-AzureRmVMDataDisk -DataDiskNames "<ディスク名>" | Update-AzureRmVM