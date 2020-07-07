---
external help file: tfe-help.xml
Module Name: tfe
online version:
schema: 2.0.0
---

# Remove-TFEVariable

## SYNOPSIS

Delete one or more variables from a Terraform Enterprise workspace.

## SYNTAX

```PowerShell
Remove-TFEVariable [[-TFEBaseURL] <String>] [-Org] <String> [-WorkspaceName] <String> [-Token] <SecureString>
 [[-TFVariables] <String[]>] [[-TFSecrets] <String[]>] [[-EnvVariables] <String[]>] [[-EnvSecrets] <String[]>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Delete one or more variables from a Terraform Enterprise workspace.

## EXAMPLES

### Example 1

```powershell
PS C:\> $TFVariables = @{
            tf_var_1 = "value-1"
            tf_var_2 = "value-2"
        }
PS C:\> $TFSecrets = @{
            secret1 = "sec 1"
            secret2 = "sec 2"
        }
PS C:\> $EnvVariables = @{
            ARM_SUBSCRIPTION_ID = "sub-id"
            ARM_CLIENT_ID = "client-id"
            ARM_TENANT_ID = "tenant-id"
        }
PS C:\> $EnvSecrets = @{
            ARM_CLIENT_SECRET = "secret-value-1"
        }
PS C:\> $TFEBaseURL = "https://app.terraform.io"
PS C:\> $Org = "tfe-organization-name"
PS C:\> $workspaceName = "workspace-name"
PS C:\> $Token = ConvertTo-SecureString -String 'your-api-token' -AsPlainText -Force
PS C:\> Remove-TFEVariable -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $workspaceName -Token $Token -TFVariables $TFVariables.keys -EnvVariables $EnvVariables.keys -EnvSecrets $EnvSecrets.keys
```

{{ Add example description here }}

## PARAMETERS

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

### -EnvSecrets

list of names of the sensitive Environment variables to be deleted

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnvVariables

list of names of the non-sensitive Environment variables to be deleted

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
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

### -TFSecrets

list of names of the sensitive Terraform variables to be deleted

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TFVariables

list of names of the non-sensitive Terraform variables to be deleted

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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
