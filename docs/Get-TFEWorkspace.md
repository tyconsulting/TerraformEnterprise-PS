---
external help file: tfe-help.xml
Module Name: tfe
online version:
schema: 2.0.0
---

# Get-TFEWorkspace

## SYNOPSIS

Retrieve a Terraform Enterprise workspace.

## SYNTAX

```PowerShell
Get-TFEWorkspace [[-TFEBaseURL] <String>] [-Org] <String> [-WorkspaceName] <String> [-Token] <SecureString>
 [<CommonParameters>]
```

## DESCRIPTION

Retrieve a Terraform Enterprise workspace.

## EXAMPLES

### Example 1

```powershell
PS C:\> $TFEBaseURL = "https://app.terraform.io"
PS C:\> $Org = "tfe-organization-name"
PS C:\> $workspaceName = "workspace-name"
PS C:\> $Token = ConvertTo-SecureString -String 'your-api-token' -AsPlainText -Force
PS C:\> $workspace = Get-TFEWorkspace -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $WorkspaceName -Token $Token
```

Retrieve a Terraform Enterprise workspace.

## PARAMETERS

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
