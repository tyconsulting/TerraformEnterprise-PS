---
external help file: tfe-help.xml
Module Name: tfe
online version:
schema: 2.0.0
---

# Approve-TFERun

## SYNOPSIS

Approve (apply) a run

## SYNTAX

```PowerShell
Approve-TFERun [[-TFEBaseURL] <String>] [-RunID] <String> [[-comment] <String>] [-Token] <SecureString>
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Approve (apply) a run in a Terraform Enterprise workspace

## EXAMPLES

### Example 1

```powershell
PS C:\> $TFEBaseURL = "https://app.terraform.io"
PS C:\> $Token = ConvertTo-SecureString -String 'your-api-token' -AsPlainText -Force
PS C:\> Approve-TFERun -TFEBaseURL $TFEBaseURL -RunID $RunId -Token $Token -Confirm:$false -Verbose
```

Approve (apply) a run in a Terraform Enterprise workspace. The RunID can be retrieved from the output of New-TFERun function.

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

### -RunID

The Run ID.

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

### -comment

The comment for the queue plan.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
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

### System.Boolean

## NOTES

## RELATED LINKS
