if(!(Get-Module PsConfluence))
{Install-Module PsConfluence}
Import-Module PsConfluence

$cred = Get-Credential

$user    = [System.Text.Encoding]::UTF8.GetBytes($cred.GetNetworkCredential().UserName +":"+$cred.GetNetworkCredential().Password)
$headers = @{Authorization = "Basic " + [System.Convert]::ToBase64String($user)}
$confluence = "<CONFLUENCE_URL>"

$usersTable = @{}
$groupsTable = @{}
Connect-Confluence -apiURi "https://$confluence/rpc/xmlrpc" -Credential $cred -ConnectionType "xmlrpc"

$spaces = Get-ConfluenceSpaces
foreach($space in $spaces)
{
    $pages = Get-ConfluencePage -SpaceKey $space.key

    foreach($page in $pages)
    {
        $pageID = $page.id

        $restr = curl -Uri "https://$confluence/rest/experimental/content/$pageID/restriction" -Headers $headers -Verbose -Debug
        $converted = ConvertFrom-Json -InputObject $restr

        $users  = $converted.results.restrictions.user.results  | select displayname
        $groups = $converted.results.restrictions.group.results | select name
 
        
        if(($users -eq $null) -and ($groups -eq $null)){continue}
        foreach($us in $users)
        {
             $usersTable[$page.title] += $us.displayName +", "
        }
       
        if($groups -eq $null){continue}
        foreach($group in $groups)
        {
             $groupsTable[$page.url] += $group.name +", "
        }
    }
}
$usersTable.GetEnumerator() | Export-Csv $env:USERPROFILE\Desktop\confluence_users_restrictions.csv
$groupsTable.GetEnumerator() | Export-Csv $env:USERPROFILE\Desktop\confluence_groups_restrictions.csv