---
external help file: tfe-help.xml
Module Name: tfe
online version:
schema: 2.0.0
---

# Get-TFERunDetails

## SYNOPSIS

Retrieve or monitor workspace run details (including status)

## SYNTAX

```PowerShell
Get-TFERunDetails [[-TFEBaseURL] <String>] [-RunID] <String> [-Token] <SecureString> [-WaitForCompletion]
 [-StopAtPlanned] [<CommonParameters>]
```

## DESCRIPTION

Retrieve or monitor workspace run details (including status)

## EXAMPLES

### Example 1

```powershell
PS C:\> $TFEBaseURL = "https://app.terraform.io"
PS C:\> $Token = ConvertTo-SecureString -String 'your-api-token' -AsPlainText -Force
PS C:\> Get-TFERunDetails -TFEBaseURL $TFEBaseURL -RunID $RunId -Token $Token -WaitForCompletion -Verbose
```

Retrieve or monitor workspace run details (including status). The RunID can be retrieved from the output of New-TFERun function.

## PARAMETERS

### -RunID

The TFE Run Id.

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

### -StopAtPlanned

When waiting for TFE Run to complete, exit when the status is Planned. This is useful when the Terraform Enterprise workspace is not configured to auto-apply (So the plan will stop at 'Planned' stage).

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WaitForCompletion

Wait for the TFE Run to complete.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
