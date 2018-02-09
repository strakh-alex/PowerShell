#region Format HTML message table
$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"
#endregion

#region Define Variables
$smtpServer = "MAIL_SERVER"
$to     = "MAIL_TO"

$OUs = "OU=USER,DC=CONTOSO,DC=COM"
$emailPattern = "^[a-zA-Z0-9.!£#$%&'^_`{}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$"
# Alex N. Strakh or Alex Strakh
$userNamePattern = "[A-Z][a-z]+\s([A-Z]\.\s){0,1}[A-Z][a-z]+"
$accountPatern = "\b[a-z]+\b"
#endregion

$adUsers = $OUs | foreach {Get-ADUser -Filter * -SearchBase $_ -Properties EmailAddress,Name,SamAccountName | select EmailAddress,Name,SamAccountName}

function Get-MisspelledAccounts()
{
    $accountsCollection = @()
    foreach($adUser in $adUsers)
    {
        $misspelledUser = @{}


        # Test Display Name
        if($adUser.Name -notmatch $userNamePattern)
            {$misspelledUser.Name = $adUser.Name}
        else
            {$misspelledUser.Name = $null}
        # Test Account Name
        if($adUser.SamAccountName -notmatch $accountPatern)
            {$misspelledUser.Account = $adUser.SamAccountName}
        else
            {$misspelledUser.Account = $null}
        # Test Email
        if($adUser.EmailAddress -notmatch $emailPattern)
            {$misspelledUser.Email = $adUser.EmailAddress}
        else
            {$misspelledUser.Email = $null}
    
        if($misspelledUser.Email -eq $null -and `
           $misspelledUser.Name -eq $null -and `
           $misspelledUser.Account -eq $null)
            {continue}

        $obj = New-Object -TypeName psobject -Property $misspelledUser
        $accountsCollection += $obj
    }
    return $accountsCollection
}

$misspelledUsers = Get-MisspelledAccounts

$body = "
The table has bin filled with E-mail/Display Name/Account Name field that was misspelled. <br>
Error considered: 
- non-latin symbol <br>
- regular expression missmatch <br>
<b>Total checked: $($adUsers.Count)  <br>
<b>Errors count:  $($misspelledUsers.Count) <br><br>
"

$body += $misspelledUsers | ConvertTo-Html -Head $style

Send-MailMessage -SmtpServer $smtpServer -From $to -to $to `
                 -Subject "Misspelled Accounts" -Body $body -BodyAsHtml -Encoding UTF8