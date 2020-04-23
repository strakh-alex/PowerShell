#########################################################################
#                                                                       #
# Base on the requirements the script whould work with cyrillic symbols #
# so you need Russian language pack installed                           #
#                                                                       #
#########################################################################

[CmdletBinding()]

param(
    [string]$ContentPath = "C:\DogsAndCats"
)

if(!(Test-Path $ContentPath)) {
    Write-Error("> Path was not found!")
    Exit(1)
}

$Substitutes = @{
    "Злая" = "Добрая"; 
    "кошка" = "собака";
    "мяу" = "гав"
}

$ContentItems = Get-ChildItem -Path $ContentPath -Recurse -Include "*.txt","*.log"

foreach($ContentItem in $ContentItems) {
    $Content = Get-Content $ContentItem -Encoding UTF8
    foreach($Key in $Substitutes.Keys) {
        if($Content.Contains($Key)) {
            Write-Verbose "Replace $Key with $($Substitutes.$Key) in file $ContentItem"
            $Content = $Content -replace $Key,$Substitutes.$Key
        }
    }

    Set-Content -Path $ContentItem.FullName -Value $Content -Encoding UTF8 -Force
}