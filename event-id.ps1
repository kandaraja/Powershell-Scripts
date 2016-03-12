
$Servers = Get-Content 'c:\ps\srv.txt'
foreach ($Server in $servers)
{
get-eventlog -logname System -instanceID 19 -newest 1 -computername $server
$server
}
 
 