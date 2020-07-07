---
external help file: tfe-help.xml
Module Name: tfe
online version:
schema: 2.0.0
---

# New-TFERun

## SYNOPSIS

Start a new workspace run (queue plan)

## SYNTAX

```PowerShell
New-TFERun [[-TFEBaseURL] <String>] [-Org] <String> [-WorkspaceName] <String> [-ConfigVersionID] <String>
 [[-comment] <String>] [-Token] <SecureString> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Start a new workspace run (queue plan)

## EXAMPLES

### Example 1

```powershell
PS C:\> $TFEBaseURL = "https://app.terraform.io"
PS C:\> $Org = "tfe-organization-name"
PS C:\> $workspaceName = "workspace-name"
PS C:\> $Token = ConvertTo-SecureString -String 'your-api-token' -AsPlainText -Force
PS C:\> $Config = New-TFEConfigVersion -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $workspaceName -Token $Token
PS C:\> $Add-TFEContent -TFEBaseURL $TFEBaseURL -ConfigVersionID $config.id -Token $Token -contentPath "C:\terraform\terraform-code-dir\"
PS C:\> $Run = New-TFERun -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $workspaceName -Token $Token -ConfigVersionID $config.id
```

Firstly create a new configuration version, then upload content to the workspace. Finally create a new Run (Queue Plan) for the workspace.

## PARAMETERS

### -ConfigVersionID

The TFE configuration version Id.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
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
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

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

### -comment

Enter the comment for the queue plan.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
