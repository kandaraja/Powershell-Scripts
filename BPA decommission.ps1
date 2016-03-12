<#
Requires - Powershell version 3.0 or above
To check the version, type <$Host> and enter in powershell window and verify.
 
$Node variable is input of nodes(servers) which need to be removed from collection (Plc file).
save list of removing servers(nodes) in a text file and replace the path in below script like 'C:\PS\plc\node.txt'
 
$Console variable is the list of windows BPA console servers saved in text file 'C:\PS\plc\bpa.txt'
we have to give BPA servers as we required and type the file path for the same.
 
Replace "C:\ps\plc\log\" path last two lines in below script as you require where you want to output files.
#>
#$erroractionpreference = "SilentlyContinue"
$Node = Get-Content C:\PS\plc\node.txt
$Console = Get-Content C:\PS\plc\bpa.txt
$Removed = @()
$NotFound = @()  
   foreach ($server in $console) {    
     if (Test-Connection $server -Count 2 -Quiet) {      
     foreach ($RemoveNode in $Node) {         
    $findFile = Get-ChildItem -path "\\$server\d$\bmc\scripts\*.plc" | select-string -pattern "$RemoveNode" | group path | % {$_.name}
    $date = Get-Date -Format "ddMMyyyy mmssfff"
    $findFile | % { gci $_ } | % { Copy-Item $_ ("\\$server\D$\BMC\scripts\Plcbackup\" + $_.basename + "_$date" + ".plc") }
        if($findFile -eq $null) 
           {$NotFound += "Policy file not found for the Node $RemoveNode on $server"}
        else {  
        foreach ($plcfile in $findFile)  
          { $file = Get-Content $plcfile -Raw
            $result = $file | Select-String -Pattern "(?smi)(\s+NODE\s+NODE_NAME = `"$RemoveNode`".*?END_NODE)"
            $removed += $result.Matches.Value
            $file -replace "(?smi)(\s+NODE\s+NODE_NAME = `"$RemoveNode`".*?END_NODE)" | Out-File -FilePath $plcfile  
             }
              }
                  }
                     }   
     else { Write-Host "The console $server is not reachable"} 
   }
   $date = Get-Date -Format "d-MMM-yyyy"
   $removed | Out-File -FilePath ("C:\ps\plc\log\Removed contant"+" $date"+".txt")
   $NotFound | Out-File -FilePath "C:\PS\plc\log\Node not found $date.txt"
   # END
 
 