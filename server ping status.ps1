
$erroractionpreference = "SilentlyContinue"
$a = New-Object -comobject Excel.Application
$a.visible = $True
$b = $a.Workbooks.Add()
$c = $b.Worksheets.item(1)
$c.name = "Ping test"
$c.Cells.Item(1,1)  = "Server Name"
$c.Cells.Item(1,2) = "Ping Status"
$c.Cells.Item(1,3) = "Server Uptime"
$d = $c.UsedRange
$d.Interior.ColorIndex = 4
$d.Font.ColorIndex = 11
$d.Font.Bold = $True
 
$intRow = 2
$colComputers = get-content "C:\PS\test.txt"
foreach ($strComputer in $colComputers)
{
$ping = Test-Connection -ComputerName $strComputer -Quiet -Count 2
 
if ( !$ping )
 
{
$wmi = Get-WmiObject -Class Win32_OperatingSystem -computername $strcomputer
$now = get-date
$LBTime = $wmi.ConvertToDateTime($wmi.Lastbootuptime)
[TimeSpan]$uptime = New-TimeSpan $LBTime $($now)
$dt =$uptime.days    
$h =$uptime.hours  
$m =$uptime.Minutes    
$s =$uptime.Seconds
$uptimer = "$dt Days $h Hours $m Min"
$c.Cells.Item($intRow,1)  = $strComputer.Toupper()
$c.Cells.Item($intRow,2) = $ping
$c.Cells.Item($intRow,3) = $uptimer
$c.Cells.Item($intRow,2).Font.ColorIndex = 3
$c.Cells.Item($intRow,1).Font.Bold = $True
$c.Cells.Item($intRow,2).Font.Bold = $True
$uptimer,$wmi,$uptime,$dt,$h,$m,$s = $null
}
else {
$c.Cells.Item($intRow,1)  = $strComputer.Toupper()
$c.Cells.Item($intRow,2) = $ping
$c.Cells.Item($intRow,3) = " 0 "
                  }
                  
$intRow = $intRow + 1
 
}
 
$Outnow = Get-Date -Format "d-MMM-yyyy HH,mm"
$intRow = $intRow + 2
$c.Cells.Item($intRow,1)  = "Finished  $Outnow"
$d.EntireColumn.AutoFit()
#$b.SaveAs("\\nicsrv10\tts\T\TCS\IS\SR Wintel\TISS\2013 Reports\ping\$Outnow")+ ".xls"
 
#$b.Save()
 
#$a.Quit()
 
#Send-MailMessage -From TTS-TCS-WINTEL-PROVISIONING@Target.com -To TTS-TCS-WINTEL-PROVISIONING@Target.com -Subject "Ping Report" -SmtpServer TCPSYTF.TGT.COM -Body "Hi Find the ping report for powered down servers in the path \\nicsrv10\tts\T\TCS\IS\SR Wintel\TISS\2013 Reports\ping"
 
cls