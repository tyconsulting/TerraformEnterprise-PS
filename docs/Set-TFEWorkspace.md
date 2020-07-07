---
external help file: tfe-help.xml
Module Name: tfe
online version:
schema: 2.0.0
---

# Set-TFEWorkspace

## SYNOPSIS

Set attributes of a Terraform Enterprise workspace.

## SYNTAX

```PowerShell
Set-TFEWorkspace [[-TFEBaseURL] <String>] [-Org] <String> [-WorkspaceName] <String> [-Token] <SecureString>
 [[-NewWorkspaceName] <String>] [[-WorkspaceDescription] <String>] [[-TerraformVersion] <String>]
 [[-TerraformWorkingDir] <String>] [[-AutoApply] <Boolean>] [[-AllowDestroyPlan] <Boolean>]
 [[-UseRemoteExecution] <Boolean>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Set attributes of a Terraform Enterprise workspace.

## EXAMPLES

### Example 1

```powershellPS C:\> $TFEBaseURL = "https://app.terraform.io"
PS C:\> $Org = "tfe-organization-name"
PS C:\> $workspaceName = "workspace-name"
PS C:\> $Token = ConvertTo-SecureString -String 'your-api-token' -AsPlainText -Force
PS C:\> Set-TFEWorkspace -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $workspaceName -Token $Token -WorkspaceDescription "Tao's test workspace for TFE API dev work" -TerraformVersion '0.12.28' -AutoApply $false -AllowDestroyPlan $true
```

Set the description, Terraform version of a Terraform workspace. Disable auto-apply for the workspace and allow destroy plan for the workspace.

## PARAMETERS

### -AllowDestroyPlan

Allow destroy plan.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AutoApply

Allow automatically apply changes when a Terraform plan is successful.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NewWorkspaceName

The new name of the workspace. This is used to rename the workspace.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Org

The organization name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TFEBaseURL

Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TerraformVersion

The Terraform version of the workspace. This can be used to change the Terraform version that the workspace should use.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TerraformWorkingDir

The Terraform working Directory of the workspace.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Token

The Terraform Enterprise API token as a Secure String.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseRemoteExecution

Whether to use remote execution mode. When set to false, the workspace will be used for state storage only.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs. The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkspaceDescription

The description of the workspace.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkspaceName

The workspace name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
