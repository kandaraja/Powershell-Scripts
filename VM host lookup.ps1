 
$erroractionpreference = "SilentlyContinue"
 
$a = New-Object -comobject Excel.Application
$a.visible = $True
 
$b = $a.Workbooks.Add()
$c = $b.Worksheets.item(1)
 
$c.name = "Host server info"
 
$c.Cells.Item(1,1)  = "Server Name"
$c.Cells.Item(1,2) = "Host Server"
 
 
$d = $c.UsedRange
$d.Interior.ColorIndex = 19
$d.Font.ColorIndex = 11
$d.Font.Bold = $True
 
$intRow = 2
 
$colComputers = get-content C:\ps\srv.txt
foreach ($strComputer in $colComputers)
{
 
$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $strcomputer)
$regKey = $reg.opensubkey("SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion", $true)
 
# Get virtual machine Physical Hostname
              $VMHost = $reg.opensubkey("SOFTWARE\\Microsoft\\Virtual Machine\\Guest\\Parameters", $true)
                           if ($VMHost -eq $NULL) {
                                  $VMHostname = "Not Found"
                                                 } else {
                                  if ($VMHost.GetValue("PhysicalHostName") -eq $NULL) {
                                         $VMHostname = $VMHost.GetValue("[PhysicalHostName]")
                                  } else {
                                         $VMHostname = $VMHost.GetValue("PhysicalHostName")
                                  }
                           $VMHost.Close()
 
}
$c.Cells.Item($intRow,1)  = $strComputer.Toupper()
$c.Cells.Item($intRow,2) = $VMHostname
 
$intRow = $intRow + 1
 
}
$d.EntireColumn.AutoFit()
cls