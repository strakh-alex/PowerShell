* This script interactively find Active Directory user

 $UserOU = "OU=Users,DC=contoso,DC=com"

Import-Module .\Interactive-FindUser.psm1

<<<<<<< HEAD:Interactive-FindUser/README.md
# Start dynamic user search
# You don't need to enter a full name,
# just type a part of it and hit "Enter"
# then function retuns you full name
=======
* Start dynamic user search
* You don't need to enter a full name,
* just type a part of it and hit "Enter"
* then function retuns you full name

>>>>>>> 43a0145e49688391f02d143255d10b5010a5fa48:README.md
$userName = Interactive-UserFind -Users_OU $UserOU

pause
