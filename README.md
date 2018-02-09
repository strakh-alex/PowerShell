This script interactively find Active Directory user

 $UserOU = "OU=Users,DC=contoso,DC=com"

Import-Module .\Interactive-FindUser.psm1

 Start dynamic user search
 You don't need to enter a full name,
 just type a part of it and hit "Enter"
 then function retuns you full name

$userName = Interactive-UserFind -Users_OU $UserOU

pause
