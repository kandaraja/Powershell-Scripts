$Erroractionpreference = "SilentlyContinue"
$Computer = Read-Host "Enter the Computer name"
$CN_Name,$OU = @()
$Forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$Domains= $Forest.Domains
$FQDN = $Domains.Name
$DN=$Domains.GetDirectoryEntry().distinguishedName
foreach ($doma in $FQDN)
{$OU = Get-ADComputer $Computer -Server "$doma"
  $CN_Name += $OU }
  if ($CN_Name -eq $null)
   { Write-Host "The AD object $Computer is not found in the following domains: $FQDN"}
   else {   
   foreach ($Domain_DN in $DN) {
   IF ($CN_Name -like "*$Domain_DN") {
   Move-ADObject -Identity $CN_Name -TargetPath (“OU=ScreenSaver,OU=Common,OU=ClientDevices," + "$Domain_DN”) -WhatIf
        }
     }
  }
# END