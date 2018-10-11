$Localhost = $Env:COMPUTERNAME
$Dir = @("C:\temp", "C:\InfraOps")
net use \\10.16.99.18\Script
$csv = Import-Csv \\10.16.99.18\Script\input.csv
Foreach ($In in $csv) {
$Comp = $In.TargetServer
$NetworkZone = $In.Zone


  If($Localhost -eq $comp) {
    If ($NetworkZone -eq "Intranet") { Net localgroup Administrators abb\XC-VULNSCAN_Service /add }
else
    {
        Net user XC-VulnScan_Service Welcome@ABB123 /ADD /FULLNAME:"XC-VulnScan_Service"
        cmd.exe /C "WMIC USERACCOUNT WHERE Name='XC-VulnScan_Service' SET PasswordExpires=FALSE"
        Net localgroup Administrators XC-VulnScan_Service /add
     }

  foreach ( $Create in $Dir) {
    if((Test-Path $Create) -eq 0) {
        New-Item -ItemType Directory -Force -Path $Create }    } 
robocopy \\10.16.99.18\script\soft C:\temp /V /NC /E /R:2 /W:3
Write-Host  "Installation of SCCM, SCOM,Azure agent and McAfee will be done please wait" -ForegroundColor yellow
sleep 2
cmd.exe /C C:\temp\SCCM\ccmsetup.exe /mp:plpia-v-sccm001.pl.abb.com SMSMP=PLPIA-V-SCCM001.pl.abb.com SMSSITECODE=6MG DNSSUFFIX=pl.abb.com
sleep 2
cmd.exe /C msiexec.exe /qn /i C:\temp\SCOM\MOMAgent.msi /l*v C:\InfraOps\MOMAgentinstall.log USE_SETTINGS_FROM_AD=0 MANAGEMENT_GROUP=ABBCLOUD MANAGEMENT_SERVER_DNS=XC-S-ZWOMGW1.XC.ABB.COM SECURE_PORT=5723 ACTIONS_USE_COMPUTER_ACCOUNT=1 USE_MANUALLY_SPECIFIED_SETTINGS=1 AcceptEndUserLicenseAgreement=1 NoAPM=1
sleep 2
cmd.exe /C msiexec.exe /qn /i C:\temp\WindowsAzureVmAgent.2.7.1198.802.rd_art_stable.170327-1033.fre.msi /l*v C:\temp\Azureinstall.log
sleep 2
cmd.exe /C C:\temp\FramePkg.exe /install=Agent /ForceInstall /silent


$substr = $comp.Substring($comp.Length - 3)
$GP = 'U-XC-ServerAdmins-XC-S-ZW08' + $substr
Net localgroup Administrators OpsDesk abb\$GP /add
$RUs = Get-Content \\10.16.99.18\Script\RemoveUsers.txt
foreach ($RU in $RUs) { Net localgroup Administrators $RU /DELETE }
Write-Host ""
Write-Host "Searching for Hidden NIC's" -Foreground Yellow
$Gnics = gwmi win32_NetworkAdapter | ?{$_.Description -like ("vm*") -or $_.Description -like ("intel*") -or $_.Description -like ("*Hyper-v*") -or $_.Description -like ("*Virtual*") -and $_.Installed -like "True" -and $_.MACAddress -eq $null}
$Gnics | Select-Object Name,DeviceID 


If ($Gnics -NE $NULL)
  {
  Write-Host "One or more Hidden NIC'S do exist on this machine. Script will continue..." -foreground RED
  Write-Host ""    
foreach ($_ in $Gnics) {    
  $DID = $_.DeviceID  
  if($DID -NOTLIKE "1*") {  
  $NICREG = Get-ItemProperty "hklm:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\000$DID"
   }
  else {
   $NICREG = Get-ItemProperty "hklm:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\00$DID"
         }
  $GUID = $NICREG.NetCfgInstanceId
  $PNPDID = $NICREG.DeviceInstanceID
  $PNPDID = $PNPDID.Trimstart("PCI\VEN_15AD&DEV_07B0&SUBSYS_07B015AD&REV_01\")
  $NICREGPATH = @(1..50)
  foreach ($_ in $NICREGPATH) {
   $TESTREG = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkCards\$_" -Verbose
   if($TESTREG -EQ $true) {     
    $SubPath1 = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkCards\$_"
    $SubPath2 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\NetworkCards\$_"
    $NICProperties = Get-ItemProperty $SubPath1
    $Match = $NICProperties.ServiceName         
    foreach ($_ in $Match) {
    if($_ -Eq $GUID)    {
    Write-Host "$_ - Registry Entries for this NIC will be DELETED" -Foreground RED  
    Remove-Item $SubPath1 -Recurse  -ErrorAction SilentlyContinue
    Remove-Item $SubPath2 -Recurse  -ErrorAction SilentlyContinue  
    $CCS = @("ControlSet001", "ControlSet002")
    foreach ($_ in $CCS) {
     $CCS = $_
     $reg1 = 'HKLM:\SYSTEM\' + $CCS + '\Services\'+$GUID
     Remove-Item $reg1 -Recurse  -ErrorAction SilentlyContinue -verbose 
       
     $reg1 = 'HKLM:\SYSTEM\' + $CCS + '\Services\Tcpip\Parameters\Adapters\'+$GUID
     Remove-Item $reg1 -Recurse  -ErrorAction SilentlyContinue -verbose
     
     $reg1 = 'HKLM:\SYSTEM\' + $CCS + '\Control\DeviceClasses\{ad498944-762f-11d0-8dcb-00c04fc3358c}\##?#PCI#VEN_15AD&DEV_07B0&SUBSYS_07B015AD&REV_01#$PNPDID#{ad498944-762f-11d0-8dcb-00c04fc3358c}\#'+$GUID
     Remove-Item $reg1 -Recurse  -ErrorAction SilentlyContinue -verbose
    
     $reg1 = 'HKLM:\SYSTEM\' + $CCS + '\Control\Network\{4D36E972-E325-11CE-BFC1-08002BE10318}\'+$GUID
     Remove-Item $reg1 -Recurse  -ErrorAction SilentlyContinue -verbose

     $reg1 = 'HKLM:\SYSTEM\' + $CCS + '\services\JNPRNA\Parameters\Adapters\' + $GUID
     Remove-Item $reg1 -Recurse  -ErrorAction SilentlyContinue -verbose
     $reg1 = 'HKLM:\SYSTEM\' + $CCS + '\services\NetBT\Parameters\Interfaces\Tcpip_' + $GUID
     Remove-Item $reg1 -Recurse  -ErrorAction SilentlyContinue -verbose
     $reg1 = 'HKLM:\SYSTEM\' + $CCS + '\services\Psched\Parameters\NdisAdapters\' + $GUID
     Remove-Item $reg1 -Recurse  -ErrorAction SilentlyContinue -verbose

     $reg1 = 'HKLM:\SYSTEM\' + $CCS + '\services\Tcpip\Parameters\Adapters\' + $GUID
     Remove-Item $reg1 -Recurse  -ErrorAction SilentlyContinue -verbose
     $reg1 = 'HKLM:\SYSTEM\' + $CCS + '\services\Tcpip\Parameters\DNSRegisteredAdapters\' + $GUID
     Remove-Item $reg1 -Recurse  -ErrorAction SilentlyContinue -verbose

     $reg1 = 'HKLM:\SYSTEM\' + $CCS + '\services\Tcpip\Parameters\Interfaces\' + $GUID
     Remove-Item $reg1 -Recurse  -ErrorAction SilentlyContinue -verbose

     $reg1 = 'HKLM:\SYSTEM\' + $CCS + '\services\WfpLwf\Parameters\NdisAdapters\' + $GUID
     Remove-Item $reg1 -Recurse  -ErrorAction SilentlyContinue -verbose
       if($DID -NOTLIKE "1*")
           {
              $reg1 = 'HKLM:\SYSTEM\' + $CCS + '\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\000' + $DID
                         Remove-Item $reg1 -Recurse  -ErrorAction SilentlyContinue -verbose
       }
       ELSE
           {
       $reg1 = 'HKLM:\SYSTEM\' + $CCS + '\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\00' + $DID
       Remove-Item $reg1 -Recurse  -ErrorAction SilentlyContinue -verbose
       }
     $reg1 = 'HKLM:\SYSTEM\' + $CCS + '\Enum\PCI\VEN_15AD&DEV_07B0&SUBSYS_07B015AD&REV_01\' + $PNPDID
     Remove-Item $reg1 -Recurse  -ErrorAction SilentlyContinue -verbose
      }
     }
    }
   }
  }
 }
} 
else
  {
  Write-Host "No Hidden NIC's Found  - Exiting..." -Foreground Green
  Write-Host ""    
   }
Configure-SMRemoting -ENABLE
icacls c:\packages /reset
icacls c:\windowsazure /reset
net stop windowsazureguestagent
net start windowsazureguestagent
$Process = Get-WmiObject -class win32_process -comp $comp -filter "name='msiexec.exe'"
$Condition = !($Process -ne $null)  
  While ($Condition -ne $true) {
     Write-Host  "Still SCCM Installation inprogress please wait" -ForegroundColor yellow
     sleep 15
     $Process = Get-WmiObject -class win32_process -comp $comp -filter "name='msiexec.exe'"
     $Condition = ($Process -eq $null)  }  
 }
}