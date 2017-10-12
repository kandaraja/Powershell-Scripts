Net user Dcmigration Tcs@1234 /ADD /FULLNAME:"Dcmigration"
cmd.exe /C "WMIC USERACCOUNT WHERE Name='Dcmigration' SET PasswordExpires=FALSE"
 Net localgroup Administrators Dcmigration AMERICAS\XA-XAABB-PLTSPN_Serv /add
