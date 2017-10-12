$ErrorActionPreference = 'SilentlyContinue'
$disk = Get-wmiobject Win32_LogicalDisk -Filter 'DriveType=3' 
$Path = "C:\DCM"
if((Test-Path $Path) -eq 0) 
    {
        New-Item -ItemType Directory -Force -Path $path
    }
if ($disk) { $disk | Foreach {
$ID =  ($_.DeviceID)
$Totalfiles = robocopy ($ID +'\') NUL0L /V /L /NC /TS /E /XJ /R:0 /W:0 /XD "System Volume Information" "*Recycle.Bin" "C:\Program Files\Common Files\VMware" "C:\Program Files (x86)\PlateSpin Migrate Server" "C:\ProgramData\PlateSpin" "C:\ProgramData\VMware" "C:\Users\dcmcloud" "C:\Windows\CCM" "C:\Windows\PlateSpin"
$ID = $ID -replace ".$"  
$date = Get-Date -Format "d-MMM-yyyy HH,mm,ss"
$Totalfiles | Out-File -FilePath ("$Path\$env:computername" + "_$ID"+"_Totalfiles_$date"+".txt") 
 $Totalfiles = $null }
 }