<#

 .Synopsis
  Perform REST API methods with Azure CosmosDB.

 .Description
  Sent REST API requests (GET/POST/PUT/DELETE).
  Tested on Triggers only!

  MSDN documentation: https://docs.microsoft.com/en-us/rest/api/cosmos-db/access-control-on-cosmosdb-resources

 .Parameter EndPoint
  CosmosDB URL
  https://<db>.documents.azure.com/

 .Parameter DataBaseId
  Database Id

 .Parameter CollectionId
  Collection Id

 .Parameter MasterKey
  Use the Primary Key provided in CosmosDB account Keys!

 .Parameter Verb
  Type of request:
  GET/POST/PUT/DELETE supported only

 .Parameter ResourceType
 e.g. triggers

 .Parameter ResourceName
 e.g. <trigger_name>: "trigger1"

 .Parameter Query
 Hashtable like:
 $query = @{
    body="function foo(){text}";
    id="foo";
    triggerOperation="Create";
    triggerType="Pre";}

 .Parameter QueryType
 Define type of query.
 Could be in HashTable or JSON format.
 If in JSON convertation will be skipped.

 .Example
 <#EXAMPLE of GET trigger method
 $triggers = Query-CosmosDB -EndPoint "https://<link>.documents.azure.com/" `
                            -DataBaseId "<coll-id>" `
                            -CollectionId "<db-id>" `
                            -MasterKey "<Primary_Key==>" `
                            -Verb "GET" `
                            -ResourceType "triggers"
 $triggersList = $triggers | ConvertFrom-Json
 $triggersList.Triggers.id
 #>


Add-Type -AssemblyName System.Web
Function Generate-MasterKeyAuthorizationSignature
{
    [CmdletBinding()]
    Param
    (
        #  The HTTP verb: GET, POST, or PUT.
        [Parameter(Mandatory=$true)][String]$verb,

        # Identity property of the resource that the request is directed at.
        # ResourceLink must maintain its case for the ID of the resource.
        # Example, for a collection it looks like: "dbs/MyDatabase/colls/MyCollection".
        [String]$resourceLink,

        # Identifies the type of resource that the request is for, Eg. "dbs", "colls", "docs".
        [Parameter(Mandatory=$true)][String]$resourceType,

        # RFC 7231: Tue, 01 Nov 1994 08:12:31 GMT
        [Parameter(Mandatory=$true)][String]$dateTime,
        [Parameter(Mandatory=$true)][String]$key,
        [Parameter(Mandatory=$true)][String]$keyType,
        [Parameter(Mandatory=$true)][String]$tokenVersion
    )

    $hmacSha256 = New-Object System.Security.Cryptography.HMACSHA256
    $hmacSha256.Key = [System.Convert]::FromBase64String($key)

    If ($resourceLink -eq $resourceType) {
        $resourceLink = ""
    }

    $payLoad = "$($verb.ToLowerInvariant())`n$($resourceType.ToLowerInvariant())`n$resourceLink`n$($dateTime.ToLowerInvariant())`n`n"
    $hashPayLoad = $hmacSha256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($payLoad))
    $signature = [System.Convert]::ToBase64String($hashPayLoad);
    Write-Verbose "> Payload: $($payLoad | Out-String)"

    [System.Web.HttpUtility]::UrlEncode("type=$keyType&ver=$tokenVersion&sig=$signature")
}

function Query-CosmosDB {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [String]$EndPoint,

        [Parameter(Mandatory = $true)]
        [String]$MasterKey,

        [Parameter(Mandatory = $true)]
        [string]$Verb,

        [Parameter(Mandatory = $true)]
        [String]$ResourceType,

        [String]$DataBaseId,
        [String]$CollectionId,
        [string]$ResourceName,
        $Query,

        # JSON or HashTable
        $QueryType,
        $OfferThroughput #Optional The user specified throughput for the collection expressed in units of 100 request units per second.
        #It can be between 400 and 250, 000 (or higher by requesting a limit increase).
    )

    $dateTime = [DateTime]::UtcNow.ToString("r")

    # Generate Query URL
    switch ($ResourceType) {
        "dbs" {$ResourceLink = ""}
        "colls" {$ResourceLink = "dbs/$DataBaseId"}
        "triggers" {$ResourceLink = "dbs/$DataBaseId/colls/$CollectionId"}
        "docs" {$ResourceLink = "dbs/$DataBaseId/colls/$CollectionId"}
        #"attachments"   {$ResourceLink = "dbs/$DataBaseId/colls/$CollectionId/docs/{doc-name}"}
        "sprocs" {$ResourceLink = "dbs/$DataBaseId/colls/$CollectionId"}
        "udfs" {$ResourceLink = "dbs/$DataBaseId/colls/$CollectionId"}
        "users" {$ResourceLink = "dbs/$DataBaseId"}
        #"permissions"   {$ResourceLink = "dbs$/DataBaseId/users/{user-name}"}
        "offers" {$ResourceLink = ""}
    }

    switch ($Verb) {
        "GET" {
            $contentType = "application/json";
            $queryUri = $EndPoint + "$ResourceLink/$ResourceType"
        }

        "POST" {
            $contentType = "application/json";
            $queryUri = $EndPoint + "$ResourceLink/$ResourceType"
        }
        #$ResourceLink += "/$ResourceType"}

        "PUT" {
            $ResourceLink += "/$ResourceType/$ResourceName";
            $contentType = "application/query+json";
            $queryUri = $EndPoint + $ResourceLink
        }

        "DELETE" {
            $ResourceLink += "/$ResourceType/$ResourceName";
            $contentType = "application/query+json";
            $queryUri = $EndPoint + $ResourceLink
        }
    }

    if ($ResourceName -and ($verb -eq "GET")) {
        $queryUri += "/$ResourceName"
        if ($ResourceLink -ne "") {
            $ResourceLink += "/"
        }
        $ResourceLink += "$ResourceType/$ResourceName"
    }

    # Delete starting "/"
    if ($ResourceLink -match "^/") {
        $ResourceLink = $ResourceLink -replace "^/"
    }

    $authHeader = Generate-MasterKeyAuthorizationSignature -verb $Verb -resourceLink $ResourceLink  `
        -resourceType $ResourceType -key $MasterKey -keyType "master" -tokenVersion "1.0" -dateTime $dateTime

    $header = @{authorization = $authHeader; "x-ms-version" = "2017-02-22"; "x-ms-date" = $dateTime; }
    if ($OfferThroughput) {
        $header += @{'x-ms-offer-throughput' = $OfferThroughput}
    }
    Write-Verbose "> Headers: $($header | Out-String)"

    # Generate Invoke-RESTMethod arguments
    $RESTParam = @{'-Method' = $Verb; '-Headers' = $header}
    $RESTParam.Add("-Uri", $queryUri)

    if ($Query) {
        if ($QueryType -eq "HashTable") {
            Write-Verbose("Query is HashTable. Converting...")
            $queryJson = $Query | ConvertTo-Json
            Write-Verbose "> Query: $($queryJson | Out-String)"
        }
        else {
            $queryJson = $Query
            Write-Verbose("Query is in JSON format.")
        }
        $RESTParam.Add("-Body", $queryJson)
    }

    $result = Invoke-RestMethod @RESTParam -Verbose -Debug

    return $result | ConvertTo-Json -Depth 100
}