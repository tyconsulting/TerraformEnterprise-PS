---
external help file: tfe-help.xml
Module Name: tfe
online version:
schema: 2.0.0
---

# Add-TFEVariable

## SYNOPSIS

Add one or more variables to a workspace

## SYNTAX

```PowerShell
Add-TFEVariable [[-TFEBaseURL] <String>] [-Org] <String> [-WorkspaceName] <String> [-Token] <SecureString>
 [[-TFVariables] <Hashtable>] [[-TFSecrets] <Hashtable>] [[-EnvVariables] <Hashtable>]
 [[-EnvSecrets] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION

Add one or more variables to a workspace

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
PS C:\> Add-TFEVariable -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $workspaceName -Token $Token -TFVariables $TFVariables -TFSecrets $TFSecrets -EnvVariables $EnvVariables -EnvSecrets $EnvSecrets

```

Add variables to a workspace

## PARAMETERS

### -EnvSecrets

Sensitive Envrionment Variables in a hashtable

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnvVariables

Non-sensiitve environment variables in a hashtable

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Org

Terraform Enterprise organization name.

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

The base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.

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

Sensitive Terraform variables in a hashtable

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TFVariables

Non-sensitive Terraform variables in a hashtable

```yaml
Type: Hashtable
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

### -WorkspaceName

The Terraform Enterprise workspace name.

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
