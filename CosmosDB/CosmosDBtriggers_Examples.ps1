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

$ResourceType = "triggers"
$ResourceName = "triggerX"

# LIST TRIGGERS
Query-CosmosDB -EndPoint $endPoint `
               -DataBaseId $databaseID `
               -CollectionId $collectionId `
               -MasterKey $masterKey `
               -Verb "GET" `
               -ResourceType $ResourceType
$triggersList = $triggers | ConvertFrom-Json

Remove-Module CosmosDB

<# GET PARTICULAR TRIGGER. (Same as LIST just specify -ResourceName)
Query-CosmosDB ...
               -ResourceName $ResourceName
#>

<# POST TRIGGER 
$query =  @{
body="function foo(){var i = 3}";
id="foo";
triggerOperation="Create";
triggerType="Pre";
}

Query-CosmosDB -EndPoint $endPoint `
               -DataBaseId $databaseID `
               -CollectionId $collectionId `
               -MasterKey $masterKey `
               -Verb "POST" `
               -ResourceType $ResourceType `
               -ResourceName $ResourceName `
               -Query $query `
               -QueryType "HashTable"
#>

<# PUT TRIGGER. (Same as POST just specify -ResourceName and change $query data)
Query-CosmosDB ...
               -Verb "PUT"
               ...
               -Query $query `
               -QueryType "HashTable"
#>

<# DELETE TRIGGER  
Query-CosmosDB -EndPoint $endPoint `
               -DataBaseId $databaseID `
               -CollectionId $collectionId `
               -MasterKey $masterKey `
               -Verb "DELETE" `
               -ResourceType $ResourceType `
               -ResourceName $ResourceName
#>