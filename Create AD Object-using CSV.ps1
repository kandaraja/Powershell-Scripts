$ErrorActionPreference = 'SilentlyContinue'
$csv = Import-Csv \\10.16.99.18\Script\input.csv
Foreach ($Input in $csv) {
$comp = $Input.TargetServer
$desc = $Input.Description
$Region = $Input.Region
$substr = $comp.Substring($comp.Length - 3)
$GP = 'U-XC-ServerAdmins-XC-S-ZW08' + $substr
$ADC = Get-ADComputer -Identity $comp -Server abb.com
If($ADC.Name -ne $comp) { 
    If ($Region -eq "Europe") {        
$ECompOU = 'OU=AD,OU=Servers,OU=XCEUR,OU=XC,DC=abb,DC=com'
$EGpOU = 'OU=ServerAdmins,OU=$Customer,OU=Operational,OU=Groups,OU=XCEUR,OU=XC,DC=abb,DC=com'
New-ADComputer -Name $comp -SamAccountName $comp -Server abb.com -Path $ECompOU -Description $desc
New-ADGroup -Name $GP -SamAccountName $GP -GroupCategory Security -GroupScope Universal -Path $EGpOU -Server abb.com
 }
    If ($Region -eq "US") {
$ACompOU = 'OU=AD,OU=Servers,OU=XCAME,OU=XC,DC=abb,DC=com' 
$AGPOU = 'OU=ServerAdmins,OU=$Customer,OU=Operational,OU=Groups,OU=XCAME,OU=XC,DC=abb,DC=com' 
New-ADComputer -Name $comp -SamAccountName $comp -Server abb.com -Path $ACompOU -Description $desc
New-ADGroup -Name $GP -SamAccountName $GP -GroupCategory Security -GroupScope Universal -Path $AGPOU -Server abb.com
 }      
Get-ADComputer -Identity $comp -Server abb.com
Get-ADGroup -Identity $GP -Server abb.com 
$ADC,$comp,$Region = $null
   }
else { Write-Host "$comp Already exist in ABB.COM" -ForegroundColor Yellow }
 }
