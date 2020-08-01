[CmdletBinding()]
[OutputType([string])]
Param(
    [Parameter(Mandatory = $true, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL,
    [Parameter(Mandatory = $true, HelpMessage = "Enter the organization name.")][string]$Org,
    [Parameter(Mandatory = $true, HelpMessage = "Enter the workspace Name.")][string]$WorkSpaceName,
    [Parameter(Mandatory = $true, HelpMessage = "Enter the Terraform version of the workspace.")][string]$TerraformVersion,
    [Parameter(Mandatory = $true, HelpMessage = "Allow automatically apply changes when a Terraform plan is successful.")][string]$AutoApply,
    [Parameter(Mandatory = $true, HelpMessage = "Allow destroy plan.")][string]$AllowDestroyPlan,
    [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a String.")][string]$Token
)

#Convert string to boolean
$bAllowDestroyPlan = [boolean]::Parse($AllowDestroyPlan)
$bAutoApply = [boolean]::Parse($AutoApply)
#convert token to secure string since secure strings cannot be passed in as a parameter in Azure Pipeline
$secToken = new-object securestring
foreach ($char in [char[]]$Token)
{ $secToken.AppendChar($char) }
$secToken.MakeReadOnly()

#Check if the workspace is already created
try {
    $existingWorkspace = Get-TFEWorkspace -TFEBaseURL $TFEBaseURL -Org $org -WorkspaceName $WorkSpaceName -Token $secToken
} catch {
    $existingWorkspace = $null
}

if ($existingWorkspace)
{
    Write-Verbose "The workspace '$WorkSpaceName' already exists in TFE organisation '$org'"
    $workspaceId = $existingWorkspace.id
} else {
    Write-Verbose "Creating workspace '$workspaceName' in TFE organisation '$org'."
    $newWorkspace = New-TFEWorkspace -TFEBaseURL $TFEBaseURL -Org $org -WorkspaceName $WorkSpaceName -TerraformVersion $TerraformVersion -AutoApply $bAutoApply -AllowDestroyPlan $bAllowDestroyPlan -Token $secToken
    $workspaceId = $newWorkspace.id
}
Write-Output "$workspaceId"