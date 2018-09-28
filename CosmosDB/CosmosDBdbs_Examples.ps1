[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][String]
    $endPoint = "https://<URL>.documents.azure.com/",

    [Parameter(Mandatory=$true)][String]
    $databaseID = "dbID",

    [Parameter(Mandatory=$true)][String]
    $collectionId = "collID",
    
    [Parameter(Mandatory=$true)][String]
    $masterKey = "<Primary Key>"
)

Import-Module .\Deploy\CosmosDB.psm1

$ResourceType = "dbs"
$ResourceName = "testDB"

$query = '{
    "id": "testdb"
}'

# LIST Databases 
Query-CosmosDB -EndPoint $endPoint `
               -MasterKey $masterKey `
               -Verb "GET" `
               -ResourceType $ResourceType `
               -Verbose                             

Remove-Module CosmosDB


<# GET PARTICULAR Database
$dbName = "testDB"
Query-CosmosDB -EndPoint $endPoint `
               -MasterKey $masterKey `
               -Verb "GET" `
               -ResourceName $ResourceName `
               -ResourceType $ResourceType
#>


<# POST Database
$ResourceType = "dbs"
$query = '{ "id": "testdb" }'

Query-CosmosDB -EndPoint $endPoint `
               -MasterKey $masterKey `
               -Verb "POST" `
               -ResourceType $ResourceType `
               -Query $query `
               -QueryType "JSON"                   
#>

<# DELETE Database
Query-CosmosDB -EndPoint $endPoint `
               -MasterKey $masterKey `
               -Verb "DELETE" `
               -ResourceType $ResourceType `
               -ResourceName $ResourceName
#>


<# PUT method does not exist! #>
<# You cannot update database settings #>