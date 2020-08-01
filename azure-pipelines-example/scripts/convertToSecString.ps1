[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, HelpMessage = "Enter the string value.")][string]$stringValue,
    [Parameter(Mandatory = $true, HelpMessage = "Enter the pipeline variable name for the securestring.")][string]$secStringVariableName
)

#Convert string to securestring
$secStringValue = new-object securestring
foreach ($char in [char[]]$stringValue)
{ $secStringValue.AppendChar($char) }
$secStringValue.MakeReadOnly()

#Create pipeline variable
Write-Output ("##vso[task.setvariable variable=$secStringVariableName]$secStringValue")
