 
$erroractionpreference = "SilentlyContinue"
#  ***** Creating Excel sheet ********
$a = New-Object -comobject Excel.Application
$a.visible = $True
$b = $a.Workbooks.Add()
$c = $b.Worksheets.item(1)
 
$c.name = "Agent"
$title = @("Server Name","SCCM start mode","SCCM status","SCOM start mode","SCOM Status","Networker start mode","Networker Status","Win Update start mode", "Win Update status","Symantec Mgmnt start mode","Symantec Mgmnt Client status","Symantec Endpoint Protection start mode","Symantec Endpoint Protection status","WMI start mode","WMI Status","CONTROL-M start mode","CONTROL-M status","dynaTrace start mode","dynaTrace status","Splunk start mode","Splumk status")
$x = 0
foreach ($tit in $title){
$c.Cells.Item(1,$x+1)  = $tit
$x = $x+1 }
 
$d = $c.UsedRange
$d.Interior.ColorIndex = 4
$d.Font.ColorIndex = 11
$d.Font.Bold = $True
$intRow = 2
 
$Computers = get-content "C:\PS\sim.txt"
foreach ($strComputer in $Computers)
{
$c.Cells.Item($intRow,1)  = $strComputer.Toupper()
$wmi = get-wmiobject win32_service -comp $strComputer
$services = @("CcmExec","HealthService","nsrexecd","wuauserv","SmcService","SepMasterService","Winmgmt","ctmag","dynaTrace Web Server Agent 4.2.0","SplunkForwarder")
$y = 1
foreach ($str in $services)
{
$srv = $wmi | Where-Object {$_.name -like $str}
$c.Cells.Item($intRow,$y+1)  = $srv.StartMode
$c.Cells.Item($intRow,$y+2)  = $srv.State
$Srv = $null
$y = $y+2
}
$intRow = $intRow + 1
}
$Outnow = Get-Date -Format "dd-MMM-yyyy"
$intRow = $intRow + 2
$c.Cells.Item($intRow,1)  = "Finished  $Outnow"
$b.SaveAs("\\nicsrv10\tts\T\TCS\IS\Performance Management\Agent status\Sign-$Outnow")+ ".xlsx"
$b.Save()
$a.Quit()
 
Send-MailMessage -From TTS-PfM-Contractors@Target.com -To Kandaraja.Sundaramoothy@target.com -Subject "Agent Status" -SmtpServer TCPSYTF.TGT.COM -Body "Hi All,
 
Please find the Agent status in the below path
\\nicsrv10\tts\T\TCS\IS\Performance Management\Agent status\
 
Thanks "
 
cls
 
