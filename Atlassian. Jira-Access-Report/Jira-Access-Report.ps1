# Connect to Jira
if(!(Get-Module JiraPS))
{Install-Module JiraPS}
Import-Module JiraPS

#########################################
# Define data to make Invoke-RestMethod #
#########################################
$cred = Get-Credential
$user    = [System.Text.Encoding]::UTF8.GetBytes($cred.GetNetworkCredential().UserName +":"+$cred.GetNetworkCredential().Password)
$headers = @{Authorization = "Basic " + [System.Convert]::ToBase64String($user)}
$jira = "<JIRA_LINK>"

#Set-JiraConfigServer $jira
New-JiraSession -Credential $cred

# Get list of All Jira projects
$projectsList = Invoke-RestMethod -Uri "$jira/rest/api/2/project" -Method GET -Headers $headers
$projectsList  = $projectsList| select name,key
$table = @{}

foreach($project in $projectsList)
{
    $projRoles = Get-JiraProject $project.key | select Roles
    $roleNames = $projRoles.Roles | Get-Member | where -Property MemberType -eq NoteProperty | select Name
 
    foreach($role in $roleNames)
    {
        $x = $role.Name
        # Get REST API url to Jira role
        $url = $projRoles.Roles.$x.ToString()
        $roleData = Invoke-RestMethod -Uri $url -Method GET -Headers $headers
        $roleParty = $roleData.actors #| select name
        
        # Filter Users
        foreach($actor in $roleParty)
        {
           #if($actor.type -eq "atlassian-group-role-actor") # List Groups access
            if($actor.type -ne "atlassian-group-role-actor") # List User access
            {
                if($table.Contains($project.name))
                {
                    if($table[$project.name].Contains($actor.name))
                    {
                        continue
                    }
                }
                $table[$project.name] += $actor.name + ","
            }
        } 
    }
}

########################
# Building HTML Report #
########################

$html_data = $null
$html_open = "
<table border='2'>
<col/>
<col/>
</colgroup>
<tr><th>Projects</th><th>Users</th></tr>
"
$html_close = "
</table>
"
$users = "<table border='10'>
<col/>
</colgroup>
<tr><th><b>Users</b></th></tr>
"

foreach($space in $table.Keys)
{
    $rowspan = $null
    $spaceUsers = $table[$space] -split ","
    $rowspan = $spaceUsers | Measure-Object
    $rowspan = ($rowspan.Count)

    $html_data += "<tr><td rowspan='$rowspan'>"+ $space +"</td></tr>"

    foreach($users in $spaceUsers)
    {
        $html_data += "<tr><td>"+ $users +"</td></tr>"
    }       
}
$report = $html_open + $html_data + $html_close
$report = $html_open + $html_data + $html_close
if(Test-Path -Path $env:USERPROFILE\Desktop\jira_access.html)
{Remove-Item -Path $env:USERPROFILE\Desktop\jira_access.html -Force -Confirm:$false}
$report | Out-File -FilePath $env:USERPROFILE\Desktop\jira_access.html


Get-JiraSession | Remove-JiraSession