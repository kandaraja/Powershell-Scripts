 
#$erroractionpreference = "SilentlyContinue"
$Array1= @()
$Array2= @()
$Array3= @()
$Servers = Get-Content "\\nicsrv10\tts\CM\Hung console log\BPA servers.txt"
foreach ($comp in $Servers) {
  if (Test-Connection $comp -Count 2 -Quiet) {
   $Process = Get-WmiObject -class win32_process -comp $comp -filter "name='visscr32.exe'"
     if($Process -ne $null) {
       foreach ($b in $Process){
       $StartTime = $b.ConvertToDateTime($b.CreationDate)
       $T = (Get-Date) - $StartTime
       $S = "{0:N0}" -f ($t.Totalseconds)
       $Z = $b | ft __SERVER,ProcessName,ProcessId,@{n='Process start time';e={$StartTime}},@{n="TotalTime(s)"; e={$S}},CommandLine -autosize
       $array1 += $Z
       $b,$StartTime,$T,$S,$Z=$null } }
     else{ $No = "Currently no visscr32 process is running on $comp"  
      $array2 += $No    }  }
else {$Not = "The server $comp is not reachable"
       $array3 += $Not  } }
$date = Get-Date -Format "d-MMM-yyyy HH,mm"
$Array = $Array3+$Array2+$Array1 | Out-File "\\nicsrv10\tts\CM\Hung console log\Process status $date.txt"
$Array = $null
