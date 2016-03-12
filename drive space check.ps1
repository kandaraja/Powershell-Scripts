 
$Excel = New-Object -Com Excel.Application
$Excel.visible = $True
$Excel = $Excel.Workbooks.Add()
$Sheet = $Excel.WorkSheets.Item(1)
 
$Sheet.Cells.Item(1,1)  = "Server Name"
$Sheet.Cells.Item(1,2) = "Drive"
$Sheet.Cells.Item(1,3) = "Total size (GB)"
$Sheet.Cells.Item(1,4) = "Free Space (GB)"
$Sheet.Cells.Item(1,5) = "Free Space (%)"
$Sheet.Cells.Item(1,6) = "Drive"
$Sheet.Cells.Item(1,7) = "Total size (GB)"
$Sheet.Cells.Item(1,8) = "Free Space (GB)"
$Sheet.Cells.Item(1,9) = "Free Space (%)"
 
$WorkBook = $Sheet.UsedRange
$WorkBook.Interior.ColorIndex = 8
$WorkBook.Font.ColorIndex = 11
$WorkBook.Font.Bold = $True
$Row = 2
 
$colComputers = get-content 'C:\ps\srv.txt'
 
foreach ($strComputer in $colComputers)
{
$Sheet.Cells.Item($Row, 1) = $strComputer.ToUpper()
if (test-connection -computername $strcomputer -quiet -count 1)
{
$DiskD = get-wmiobject Win32_LogicalDisk -computername $strComputer -Filter "DeviceID = 'D:'"
$DiskE = get-wmiobject Win32_LogicalDisk -computername $strComputer -Filter "DeviceID = 'E:'"
$Sheet.Cells.Item($Row,2) = $DiskD.DeviceID
$Sheet.Cells.Item($Row,3) = "{0:N0}" -f ($DiskD.Size/1GB)
$Sheet.Cells.Item($Row,4) = "{0:N0}" -f ($DiskD.FreeSpace/1GB)
$Sheet.Cells.Item($Row,5) = "{0:P0}" -f ([double]$DiskD.FreeSpace/[double]$DiskD.Size)
$Sheet.Cells.Item($Row,6) = $DiskE.DeviceID
$Sheet.Cells.Item($Row,7) = "{0:N0}" -f ($DiskE.Size/1GB)
$Sheet.Cells.Item($Row,8) = "{0:N0}" -f ($DiskE.FreeSpace/1GB)
$Sheet.Cells.Item($Row,9) = "{0:P0}" -f ([double]$DiskE.FreeSpace/[double]$DiskE.Size)
$DiskD, $DiskE = $null
}
$Row = $Row + 1
}
$WorkBook.EntireColumn.AutoFit()
Clear
