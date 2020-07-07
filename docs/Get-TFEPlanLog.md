---
external help file: tfe-help.xml
Module Name: tfe
online version:
schema: 2.0.0
---

# Get-TFEPlanLog

## SYNOPSIS

 Download the log from a plan

## SYNTAX

```PowerShell
Get-TFEPlanLog [[-TFEBaseURL] <String>] [-PlanId] <String> [-Token] <SecureString> [<CommonParameters>]
```

## DESCRIPTION

Download the log from a plan

## EXAMPLES

### Example 1

```powershell
PS C:\> $Token = ConvertTo-SecureString -String 'your-api-token' -AsPlainText -Force
PS C:\> $Log = Get-TFEPlanLog -TFEBaseURL $TFEBaseURL -PlanId $PlanId -Token $Token
PS C:\> Write-Output $Log
```

Download and display the log from a plan. The PlanId can be retrieved from the Get-TFEPlan function.

## PARAMETERS

### -PlanId

The TFE Plan Id.

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

### System.String

## NOTES

## RELATED LINKS
