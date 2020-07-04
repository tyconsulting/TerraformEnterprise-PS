# PowerShell module for Terraform Enterprise

PowerShell module for Terraform Enterprise APIs

## Functions

The following functions are included in this PowerShell module:

* **Add-TFEContent**: Add content to a Configuration Version of a Workspace
* **Get-TFEWorkspace**: Retrieve a workspace
* **Set-TFEWorkspace**: Set workspace attributes
* **New-TFEConfigVersion**: Create a new Configuration Version in a workspace
* **Get-TFEConfigVersion**: Get a Configuration Version for a workspace
* **Add-TFEVariable**: Add one or more variables to a workspace
* **Remove-TFEVariable**: Delete one or more variables from a workspace
* **New-TFEQueuePlan**: Start a new workspace run (queue plan)
* **Get-TFERunStatus**: Retrieve or monitor workspace run status
* **New-TFEDestroyPlan**: Create a destroy plan for the workspace

## Sample Code

### Set Variables

```powershell
$TFEBaseURL = "https://app.terraform.io"
$Org = "my-org"
$workspaceName = "myworkspace"
$Token = ConvertTo-SecureString -String 'my-tfe-token' -AsPlainText -Force

$TFVariables = @{
    variable-name = "variable-value"
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

### Set Workspace

```powershell
Set-TFEWorkspace -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $workspaceName -Token $Token -WorkspaceDescription "Tao's test workspace for TFE API dev work" -TerraformVersion '0.12.28' -AutoApply $true -AllowDestroyPlan $true -Verbose
```

### Add variables

```powershell
Add-TFEVariable -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $workspaceName -Token $Token -TFVariables $TFVariables -EnvVariables $EnvVariables -EnvSecrets $EnvSecrets -verbose
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
$Run = New-TFEQueuePlan -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $workspaceName -Token $Token -ConfigVersionID $config.id -verbose

#Get Run status
Get-TFERunStatus -TFEBaseURL $TFEBaseURL -RunID $Run.id -Token $Token -WaitForCompletion -Verbose
```

### Create Destroy Plan & wait for it to complete

```powershell
#Create Destroy plan
$destroy = New-TFEDestroyPlan -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $workspaceName -Token $Token -Verbose -confirm:$false

#Get Run status
Get-TFERunStatus -TFEBaseURL $TFEBaseURL -RunID $destroy.id -Token $Token -WaitForCompletion -Verbose
```

### Remove secret

```powershell
Remove-TFEVariable -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $workspaceName -Token $Token -EnvSecrets @('ARM_CLIENT_SECRET') -verbose
```
