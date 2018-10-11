$GIP = get-WmiObject Win32_NetworkAdapterConfiguration | Where {$_.IPAddress -like "10.*"}
$LIP = $GIP.IPAddress[0]
if ($LIP -ne $null) {
$Localhost = $Env:COMPUTERNAME
net use \\10.16.99.18\Script
$csv = Import-Csv \\10.16.99.18\Script\input.csv
net use * /delete /Y
Foreach ($In in $csv) {
$Comp = $In.TargetServer
$TIP = $In.TargetIP
  If($Localhost -eq $comp) {
  $Region = $In.Region
$Env = $In.Environment
$Mwd = $In.MaintenanceWindow
$SourceSrv = $In.SourceServer
$SourceFQDN = $In.SourceServerFQDN 
Write-Host  "Uninstall of McAfee, SCCM and SCOM will be done please wait" -ForegroundColor yellow
$MPath = Get-ChildItem -Path "C:\Program*" | % { Gci -Path $_ -Filter FrmInst.exe -Recurse -EA SilentlyContinue } | where {$_.name -eq "FrmInst.exe"} | % { $_.FullName }
    iF ($MPath -ne $null) {cmd.exe /C "$MPath" /forceuninstall /s }
cmd.exe /C "C:\Windows\ccmsetup\ccmsetup.exe" /uninstall
$app = Get-WmiObject -Class Win32_Product | Where-Object {$_.name -match "Microsoft Monitoring Agent"}
    IF ($app -ne $null) { $app.Uninstall() }
Net user Infraops Welcome@ABB123 /ADD /FULLNAME:"Infraops"
Net user OpsDesk Welcome@ABB123 /ADD /FULLNAME:"OpsDesk"
cmd.exe /C "WMIC USERACCOUNT WHERE Name='Infraops' SET PasswordExpires=FALSE"
cmd.exe /C "WMIC USERACCOUNT WHERE Name='OpsDesk' SET PasswordExpires=FALSE"
Net localgroup Administrators Infraops OpsDesk /add
$registryPath = "HKLM:\Software"
New-Item -Path $registryPath -Name PLABB | Out-Null
New-Item -Path "$registryPath\PLABB" -Name OSFootprint | Out-Null
New-ItemProperty -Path "$registryPath\PLABB\OSFootprint" -Name "HostingProvider" -Value Azure -PropertyType String -Force | Out-Null
$Condition = (( $env -ceq 'PROD') -or ( $env -ceq 'TEST') -or ( $env -ceq 'STAGE') -or ( $env -ceq 'DEV') )
while ($Condition -ne $true)
 { 
  Write-Host "Environment value is case sensitive, Enter the Value in Block letter" -ForegroundColor Yellow
 $env = Read-Host ":"
$Condition = (( $env -ceq 'PROD') -or ( $env -ceq 'TEST') -or ( $env -ceq 'STAGE') -or ( $env -ceq 'DEV') )
 }
New-ItemProperty -Path "$registryPath\PLABB\OSFootprint" -Name "ENV" -Value $env -PropertyType String -Force | Out-Null
$Condition = (( $Mwd -ceq 'W22') -or ( $Mwd -ceq 'W15') -or ( $Mwd -ceq 'W23') )
while ($Condition -ne $true)
 {
 Write-Host  "Maintenance Window value is case sensitive, Enter the Value in Block letter" -ForegroundColor yellow
 $Mwd = Read-Host ":"
$Condition = (( $Mwd -ceq 'W22') -or ( $Mwd -ceq 'W15') -or ( $Mwd -ceq 'W23') )
 }
New-ItemProperty -Path "$registryPath\PLABB\OSFootprint" -Name "MaintenanceWindow" -Value $Mwd -PropertyType String -Force | Out-Null
$hostsPath = "C:\WINDOWS\System32\drivers\etc\hosts"
$date = Get-Date -Format "d-MMM-yyyy HH,mm,ss"
Copy-Item -Path $hostsPath -Destination ("$hostsPath" + "-old-$date")
Add-Content -Encoding Ascii -Path $hostsPath "$TIP  $SourceSrv"
Add-Content -Encoding Ascii -Path $hostsPath "$TIP  $SourceFQDN"
Set-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters" -Name "SyncDomainWithMembership" -Value 0 -Force | Out-Null
Set-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Tcpip\Parameters" -Name "NV Domain" -Value xc.abb.com -Force | Out-Null
netdom join $Comp /domain:abb.com #/userd:abb\ch-admin-ks2 /passwordd:*
$Process = Get-WmiObject -class win32_process -comp $comp -filter "name='msiexec.exe'"
$Condition = ($Process -eq $null)  
  While ($Condition -ne $true) {
     Write-Host  "Still Uninstall inprogress please wait" -ForegroundColor yellow
     sleep 15
     $Process = Get-WmiObject -class win32_process -comp $comp -filter "name='msiexec.exe'"
     $Condition = !($Process -ne $null)  } 
  }
  else {
    If ($LIP -eq $TIP) {
    $sysInfo = Get-WmiObject -Class Win32_ComputerSystem
    $sysInfo.Rename("$comp") 
    Write-Host "This Computer name changed to $Comp and it will be reboot now"  -ForegroundColor Yellow
    Write-Host "No action performed, Run this Script again"  -ForegroundColor Yellow
    shutdown /r /t 020
     }
       }
 }
}
else { Write-Host "Please check the local server IP Address is correct one" -ForegroundColor Yellow
       Write-Host "Not performed any Action" -ForegroundColor Yellow}
