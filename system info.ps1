#$erroractionpreference = "SilentlyContinue"
# Create a New Excel Object for storing Data
$a = New-Object -comobject Excel.Application
$a.visible = $True  
$b = $a.Workbooks.Add()
$c = $b.Worksheets.Item(1) 
# Create the title row 
$Title = @("Server Name","Server Model","CPU Info","RAM size","Operating System","Drive info","Drive info","Serial Number")
$T = 0
foreach ($Name in $title){
$c.Cells.Item(1,$t+1) = $Name
$t = $t+1 }
$d = $c.UsedRange
$d.Interior.ColorIndex = 23
$d.Font.ColorIndex = 2
$d.Font.Bold = $True 
$R,$Cl = 2,0
$colComputers = get-content "C:\PS\srv.txt"
foreach ($strComputer in $colComputers) {
$OS = Get-WmiObject Win32_OperatingSystem -computername $Strcomputer
$Mem = Get-WmiObject Win32_ComputerSystem -computername $Strcomputer
$Hw = Get-WmiObject Win32_ComputerSystemProduct -ComputerName $Strcomputer
$CPU = Get-WmiObject win32_processor -ComputerName $Strcomputer
$Disk = get-wmiobject Win32_LogicalDisk -computername $strComputer
$D1 = $Disk | ? { $_.DeviceID -eq 'C:'}
$D2 = $Disk | ? { $_.DeviceID -eq 'D:'}
 
$c.Cells.Item($R,($Cl=+$Cl+1)) = $Mem.Name
$c.Cells.Item($R,($Cl=+$Cl+1)) = $Mem.Model
$c.Cells.Item($R,($Cl=+$Cl+1)) = $cpu.Name
$c.Cells.Item($R,($Cl=+$Cl+1)) = "{0:N2}" -f ($mem.TotalPhysicalMemory/1GB) + " GB"
$c.Cells.Item($R,($Cl=+$Cl+1)) = $OS.caption + ", Service Pack " + $OS.ServicePackMajorVersion
$c.Cells.Item($R,($Cl=+$Cl+1)) = $D1.DeviceID + " Drive Capacity: "+ "{0:N2}" -f ($D1.Size/1GB) + " GB," + " Free " + "{0:N2}" -f ($D1.FreeSpace/1GB)+"GB"+"("+"{0:P2}" -f ($D1.FreeSpace/$D1.Size) +")"
$c.Cells.Item($R,($Cl=+$Cl+1)) = $D2.DeviceID + " Drive Capacity: "+ "{0:N2}" -f ($D2.Size/1GB) + " GB," + " Free " + "{0:N2}" -f ($D2.FreeSpace/1GB)+"GB"+"("+"{0:P2}" -f ($D2.FreeSpace/$D2.Size) +")"
$c.Cells.Item($R,($Cl=+$Cl+1)) = $Hw.IdentifyingNumber
$OS,$Hw,$Mem,$CPU,$Disk,$Cl = $null
$R = $R + 1
}
$d.EntireColumn.AutoFit()
#END