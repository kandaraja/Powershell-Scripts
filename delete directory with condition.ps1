$Path = Get-ChildItem "C:\ps\test1\*" -Force
$Date = Get-Date
$Array = @("The below Directories and its sub directories will be deleted", "Starting at $date","")
 
foreach($file in $path)
    {
    $Days = ($date - $file.CreationTime).Days
      
      if (($days -gt 2)-and $file.PsISContainer)
     
         {  $Dir = $file.fullname
            $Array += $Dir
            $file | Remove-Item -Force -Recurse
         }
      }
$date = Get-Date -Format "d-MMM-yyyy HH,mm"
$Array | Out-File "C:\PS\test\deletelog-$date.txt"
