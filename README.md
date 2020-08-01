# PowerShell module for Terraform Enterprise

PowerShell module for Terraform Enterprise APIs

## Functions

The following functions are included in this PowerShell module:

* **Set-TFEWorkspace**: Set workspace attributes
* **New-TFEWorkspace**: Create a new workspace
* **Add-TFEContent**: Add content to a Configuration Version of a Workspace
* **Get-TFEWorkspace**: Retrieve a workspace
* **Remove-TFEWorkspace**: Delete a workspace
* **New-TFEConfigVersion**: Create a new Configuration Version in a workspace
* **Get-TFEConfigVersion**: Get a Configuration Version for a workspace
* **Add-TFEVariable**: Add one or more variables to a workspace
* **Remove-TFEVariable**: Delete one or more variables from a workspace
* **New-TFERun**: Start a new workspace run (queue plan)
* **Approve-TFERun**: Approve (apply) a run
* **Stop-TFERun**: Disgard a run - It  can be used to skip any remaining work on runs that are paused waiting for confirmation or priority. This includes runs in the "pending," "needs confirmation," "policy checked," and "policy override" states.
* **Get-TFERunDetails**: Retrieve or monitor workspace run details (including status)
* **New-TFEDestroyPlan**: Create a destroy plan for the workspace
* **Get-TFEPlan**: Get plan for the run (A plan represents the execution plan of a Run in a Terraform workspace.)
* **Get-TFEPLanLog**: Download the log from a plan

## Folder Structure

* [**tfe**](./tfe): Contains the code for the tfe PowerShell module
* [**azure-pipelines-example**](./azure-pipelines-example): Contains a sample pipeline to deploy an compiled C# Azure Function app end-to-end.

## Sample Code

### Common variables

```powershell
# Set variables that will used by the following code samples
$TFEBaseURL = "https://app.terraform.io"
$Org = "my-org"
$workspaceName = "myworkspace"
$Token = ConvertTo-SecureString -String 'my-tfe-token' -AsPlainText -Force

$TFVariables = @{
    variable-name = "variable-value"
}

$TFSecrets = @{
    secret1 = "sec 1"
    secret2 = "sec 2"
}

$EnvVariables = @{
    ARM_SUBSCRIPTION_ID = "azure-sub-id"
    ARM_CLIENT_ID = "azure-ad-app-client-id"
    ARM_TENANT_ID = "azure-ad-tenant-id"
}

$EnvSecrets = @{
    ARM_CLIENT_SECRET = "azure-service-principal-secret"
}
```

### Create a Workspace

```powershell
New-TFEWorkspace Set-TFEWorkspace -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $workspaceName -Token $Token -WorkspaceDescription "Tao's lab workspace for TFE API dev work" -TerraformVersion '0.12.28' -AutoApply $false -AllowDestroyPlan $true -Verbose

```

### Set Workspace

```powershell
Set-TFEWorkspace -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $workspaceName -Token $Token -WorkspaceDescription "Tao's test workspace for TFE API dev work" -TerraformVersion '0.12.28' -AutoApply $true -AllowDestroyPlan $true -Verbose
```

### Add variables

```powershell
Add-TFEVariable -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $workspaceName -Token $Token -TFVariables $TFVariables -TFSecrets $TFSecrets -EnvVariables $EnvVariables -EnvSecrets $EnvSecrets
```

### Create new configuration version

```powershell
$Config = New-TFEConfigVersion -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $workspaceName -Token $Token -verbose

```

### Add content

```powershell
Add-TFEContent -TFEBaseURL $TFEBaseURL -ConfigVersionID $config.id -Token $Token -contentPath "C:\Documents\git\TerraformEnterprise-PS\examples\deploy-vm-shutdown-schedule-to-sub" -verbose

```

### Create a queue plan & wait for it to complete

```powershell
#Create Run
$Run = New-TFERun -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $workspaceName -Token $Token -ConfigVersionID $config.id -verbose

#Get Run status (when the workspace is set to auto-apply)
Get-TFERunDetails -TFEBaseURL $TFEBaseURL -RunID $Run.id -Token $Token -WaitForCompletion -Verbose

#If the workspace is not configured to auto-apply, Set Get-TFERunDetails to exit when the run status is planned
Get-TFERunDetails -TFEBaseURL $TFEBaseURL -RunID $Run.id -Token $Token -WaitForCompletion -StopAtPlanned -Verbose
```

### Create Destroy Plan & wait for it to complete

```powershell
#Create Destroy plan
$destroy = New-TFEDestroyPlan -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $workspaceName -Token $Token -Verbose -confirm:$false

#Get Run status (when the workspace is set to auto-apply)
Get-TFERunDetails -TFEBaseURL $TFEBaseURL -RunID $destroy.id -Token $Token -WaitForCompletion -Verbose

#If the workspace is not configured to auto-apply, Set Get-TFERunDetails to exit when the run status is planned
Get-TFERunDetails -TFEBaseURL $TFEBaseURL -RunID $destroy.id -Token $Token -WaitForCompletion -StopAtPlanned -Verbose
```

### Approve a Run or destroy and wait for it to complete

```powershell
#Approve Run
Approve-TFERun -TFEBaseURL $TFEBaseURL -RunID $Run.id -Token $Token -Confirm:$false -Verbose

#Get Run status
Get-TFERunDetails -TFEBaseURL $TFEBaseURL -RunID $Run.id -Token $Token -WaitForCompletion -Verbose

#Approve Destroy
Approve-TFERun -TFEBaseURL $TFEBaseURL -RunID $destroy.id -Token $Token -Confirm:$false -Verbose

#Get Destroy status
Get-TFERunDetails -TFEBaseURL $TFEBaseURL -RunID $destroy.id -Token $Token -WaitForCompletion -Verbose
```

### Get Logs for a plan

```powershell
$RunDetails = Get-TFERunDetails -TFEBaseURL $TFEBaseURL -RunID $Run.id -Token $Token -WaitForCompletion -stopAtPlanned -Verbose
$Plan = Get-TFEPlan -TFEBaseURL $TFEBaseURL -RunID $Run.id -Token $Token
$Log = Get-TFEPlanLog -TFEBaseURL $TFEBaseURL -PlanId $Plan.id -Token $Token
Write-Output $Log
```

### Discard Run

```PowerShell
Stop-TFERun -TFEBaseURL $TFEBaseURL -RunID $Run.id -Token $Token -confirm:$false
```


### Remove secret

```powershell
Remove-TFEVariable -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $workspaceName -Token $Token -EnvSecrets @('ARM_CLIENT_SECRET') -verbose
```

### Delete the workspace

```powershell
Remove-TFEWorkspace -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $workspaceName -Token $Token -confirm:$false -verbose
```
