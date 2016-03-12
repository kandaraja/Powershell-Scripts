### Powershell script to resolve the IP address for given hostname (list of hostname) forn a DNS server(AD).
# This script needs MS Excel application to produce the output  ###
 
$erroractionpreference = "SilentlyContinue"
$a = New-Object -comobject Excel.Application
$a.visible = $True
$b = $a.Workbooks.Add()
$c = $b.Worksheets.item(1)
$c.name = "NS Lookup"
$c.Cells.Item(1,1)  = "Server Name"
$c.Cells.Item(1,2) = "IP Address"
$c.Cells.Item(1,3) = "FQDN"
 
$d = $c.UsedRange
$d.Interior.ColorIndex = 4
$d.Font.ColorIndex = 11
$d.Font.Bold = $True
$Row = 2
 
$ns = "tedns01v.target.com"     ### Name Server which will do name resolution
$hosts = get-content "C:\PS\srv.txt"    ### input file(server list) to resolve IP
 
###### Two functions 1.Forward DNS, 2.Reverse DNS ####################
 
# FORWARD DNS RESOLUTON WITH NSLOOKUP
Function forward_dns
{
$cmd = "nslookup " + $args[0] + " " + $ns
$result = Invoke-Expression ($cmd)
trap
{
$global:controlladns = $true
$global:solved_ip = "No record found"
continue
}
$global:controlladns = $false
$global:solved_ip = $result.SyncRoot[4]
if (-not $global:controlladns)
{
$leng = $global:solved_ip.Length -10
$global:solved_ip =
$global:solved_ip.substring(10,$leng)
}
}
# REVERSE DNS RESOLUTON WITH NSLOOKUP
Function reverse_dns
{
$cmd2 = "nslookup " + $args[0] + " " + $ns
$result2 = Invoke-Expression ($cmd2)
$global:reverse_solved_ip = $result2.SyncRoot[3]
if ($result2.count -lt 4) # Integrity check
{
$global:reverse_solved_ip = "No record found"
}
else
{
$leng2 = $global:reverse_solved_ip.length - 9
$global:reverse_solved_ip =
$global:reverse_solved_ip.substring(9,$leng2)
}
}
##################### End funtions   #######################
 
foreach ($comp in $hosts)
{
forward_dns $comp
reverse_dns $global:solved_ip
$c.Cells.Item($Row,1)  = $comp.Tolower()
$c.Cells.Item($Row,2) = $global:solved_ip
$c.Cells.Item($Row,3) = $global:reverse_solved_ip
$global:solved_ip,$global:reverse_solved_ip = $null
$Row = $Row + 1
}
$Outnow = Get-Date -Format "d-MMM-yyyy HH,mm"
$Row = $Row + 2
$c.Cells.Item($Row,1)  = "Finished  $Outnow"
$d.EntireColumn.AutoFit()
#$b.SaveAs("C:\Users\a527529.DHC\Desktop\nslookup\nslp-$Outnow")+ ".xlsx"
#$b.Save()
#$a.Quit()
cls
 
####   END   ####