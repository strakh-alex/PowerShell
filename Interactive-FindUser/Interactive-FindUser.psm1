function Interactive-UserFind()
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$Users_OU
         )

    # Get all AD users from selected OU
    $users = Get-ADUser -SearchBase $Users_OU -Filter *

    $match_user = $null
    Write-Host("Enter username: ")
    while($key.Key -ne "Enter")
    {   
        $key = [Console]::ReadKey($true)
        Clear-Host

        # Delete last entered character
        if($key.Key -eq "Backspace")
        {
            $key_massive = $key_massive.Remove($key_massive.length-1)
            Write-Host("Enter username: " + $key_massive)
        
        # Add entered character to find
        }else{
            $key_massive += $key.KeyChar
            Write-Host("Enter username: " + $key_massive)
        }
        
        # Display all matched users
        foreach($user in $users)
        {
           if($user.SamAccountName -imatch $key_massive)
           {
               Write-Host($user.SamAccountName)
               $match_user = $user.SamAccountName
           }
        }
    }
    Clear-Host

    return $match_user
}