$ErrorActionPreference = 'SilentlyContinue'
#Login-AzureRmAccount
net use \\10.16.99.18\Script
$csv = Import-Csv "\\10.16.99.18\Script\input.csv"

Foreach ($In in $csv) {
$SubscriptionId = $In.SubscriptionID
$ResourceGroupName = $In.ResourceGroupName
$VirtualMachineSize = $In.VMSize
$VMName = $In.TargetServer
$MigrationVMname = $In.MigrationVMname

Select-AzureRmSubscription -SubscriptionId $SubscriptionId

$getVM = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName
If($getVM.Name -ne $VMName) {
$Nic = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName -Name ($VMName + '-nic01')
  If($Nic.Name -eq $VMName+'-nic01') {

$ManagedDisks = Get-AzureRmDisk -ResourceGroupName $ResourceGroupName
$ManagedDisk = $ManagedDisks | where{$_.Name -like "*$MigrationVMname*"} 
$ManagedDisk.Name | sort -Unique
$Count = 0
$VMConfig = New-AzureRmVMConfig -VMName $VMName -VMSize $VirtualMachineSize
Foreach ($disk in $ManagedDisk) {
If (($disk.Name -like "*osdisk*") -or ($disk.Name -like "*DRIVE0*") ) {
$diskConfig = New-AzureRmDiskConfig -SourceResourceId $disk.Id -Location $disk.Location -CreateOption Copy
$Osdisk = New-AzureRmDisk -Disk $diskConfig -ResourceGroupName $ResourceGroupName -DiskName ($VMName + '-osdisk')
$VMConfig = Set-AzureRmVMOSDisk -VM $VMConfig -ManagedDiskId $Osdisk.Id -CreateOption Attach -Windows
$diskConfig=$disk=$null }
 else {
$Count++ 
$diskConfig = New-AzureRmDiskConfig -SourceResourceId $disk.Id -Location $disk.Location -CreateOption Copy
$dataDisk = New-AzureRmDisk -Disk $diskConfig -ResourceGroupName $ResourceGroupName -DiskName ($VMName + '-datadisk' + "{0:D2}" -f ($Count))
$VMConfig = Add-AzureRmVMDataDisk -Lun ($Count - 1) -Caching ReadWrite -VM $VMConfig -ManagedDiskId $dataDisk.Id -CreateOption Attach
$diskConfig=$dataDisk=$disk=$null }
   } 

$VMConfig = Add-AzureRmVMNetworkInterface -VM $VMConfig -Id $Nic.Id
New-AzureRmVM -VM $VMConfig -ResourceGroupName $ResourceGroupName -Location $Osdisk.Location

$VMConfig=$VM=$SubscriptionId=$ResourceGroupName=$Osdisk=$null  }

      else {Write-Host ("NIC " + "$VMName"+"-nic01 is not exist in ResourceGroup $ResourceGroupName") -ForegroundColor Yellow}
    } 
 else {Write-Host "Check the VM $VMName is already exist in ResourceGroup $ResourceGroupName " -ForegroundColor Yellow}
 }

#END