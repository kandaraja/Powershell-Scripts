 
$servers= get-content "C:\PS\srv.txt"
$output = "C:\PS\servers.csv"
 
$results = @()
 
foreach($server in $servers)
{
$group =[ADSI]"WinNT://$server/Administrators"
 $members = $group.Members() | foreach {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null) }
 $results += New-Object PsObject -Property @{
  Server = $server
  LocalAdminGroupMembers = $members -join ";"
  }
}
 
$results #| Export-Csv $Output -NoTypeInformation