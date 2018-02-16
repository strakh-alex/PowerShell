**This script interactively find Active Directory user**

 $UserOU = "OU=Users,DC=contoso,DC=com"

Import-Module .\Interactive-FindUser.psm1

<<<<<<< HEAD
* Start dynamic user search
* You don't need to enter a full name,
* just type a part of it and hit "Enter"
* then function retuns you full name
=======
**Start dynamic user search**
**You don't need to enter a full name,**
**just type a part of it and hit "Enter"**
**then function retuns you full name**
>>>>>>> 98894393bff24a77152f0665d3ae4df98ec68e13

$userName = Interactive-UserFind -Users_OU $UserOU

pause
