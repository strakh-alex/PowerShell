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

$ResourceType = "colls"
$ResourceName = "testcoll"

$query = '{ "id": "testcoll" }'

# POST COLLECTION
Query-CosmosDB -EndPoint $endPoint `
               -MasterKey $masterKey `
               -Verb "POST" `
               -ResourceType $ResourceType `
               -ResourceName $ResourceName `
               -DataBaseId $databaseID `
               -Query $query `
               -QueryType "JSON" `
               -Verbose                             

Remove-Module CosmosDB


<# LIST COLLECTIONS
$ResourceType = "colls"
Query-CosmosDB -EndPoint $endPoint `
               -MasterKey $masterKey `
               -Verb GET `
               -ResourceType $ResourceType `
               -DataBaseId $databaseID  
#>

<# GET PARTICULAR COLLECTION. (Same as LIST just specify -ResourceName)
$ResourceName = "testcoll"
Query-CosmosDB ...
               -ResourceName $ResourceName `
               ...
#>

<# UPDATE COLLECTION. (Same as POST)
Query-CosmosDB ...`
               -Verb PUT `
               ...
               
#>

<# DELETE COLLECTIONS
Query-CosmosDB -EndPoint $endPoint `
               -MasterKey $masterKey `
               -Verb DELETE `
               -ResourceType $ResourceType `
               -ResourceName $ResourceName `
               -DataBaseId $databaseID
#>