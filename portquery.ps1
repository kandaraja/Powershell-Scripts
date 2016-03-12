$erroractionpreference = "SilentlyContinue"
 
$a = New-Object -comobject Excel.Application
$a.visible = $True
$b = $a.Workbooks.Add()
$c = $b.Worksheets.Item(1)
 
 
 
$c.Cells.Item(1,1)  = "Server Name"
$c.Cells.Item(1,2) = "Ping Status"
$c.Cells.Item(1,3)  = "IMA Status"
$c.Cells.Item(1,4)  = "ICA Port Status"
 
 
 
$d = $c.UsedRange
$d.Interior.ColorIndex = 19
$d.Font.ColorIndex = 11
$d.Font.Bold = $True
$d.EntireColumn.AutoFit()
 
$intRow = 2
 
$colComputers = get-content "C:\PS\srv.txt"
 
foreach ($strComputer in $colComputers)
 
{
 
#$pingstatus = Test-connection -computername $strcomputer -quiet -count 2
$IMA = get-wmiobject win32_service -filter "name='BGS_SDService'" -computername  $strComputer
$portinfo = .\Portqry.exe -n $strComputer -e 1494 | Select-String -Pattern "Listening" | %{$_ -replace '  *', ' '}
 
 
$c.Cells.Item($intRow,1)  = $strComputer.Toupper()
#$c.Cells.Item($intRow,2) = $Pingstatus
$c.Cells.Item($intRow,3) = $IMA.State
$c.Cells.Item($IntRow,4) = $portinfo
 
 
$intRow = $intRow + 1
 
}
 
$d.EntireColumn.AutoFit()
 
$Outnow = Get-Date -Format yyyy-MM-dd-HH
 
#$b.SaveAs("\\nicsrv10\tts\T\TCS\IS\SR Wintel\Peak_Season_2012\Verification-CITRIX\$Outnow")+ ".xls"
 
#$b.Save()
 
#$a.Quit()
 
#Send-MailMessage -From Wintel.Support@target.com -To TTS-ISS-TCS-WINTEL-ALL@target.com -Subject "CITRIX Service Report" -Attachments "\\nicsrv10\tts\T\TCS\IS\SR Wintel\Peak_Season_2012\Verification-CITRIX\$outnow.xlsx" -SmtpServer TCPSYTF.TGT.COM -Body "Please find the CITRIX Service report for all the servers and perform Manual Verification to confirm all servers are fine"
 
 
cls