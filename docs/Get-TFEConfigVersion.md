---
external help file: tfe-help.xml
Module Name: tfe
online version:
schema: 2.0.0
---

# Get-TFEConfigVersion

## SYNOPSIS

Get a Configuration Version for a workspace

## SYNTAX

```PowerShell
Get-TFEConfigVersion [-TFEBaseURL] <String> [-ConfigVersionID] <String> [-Token] <SecureString>
 [<CommonParameters>]
```

## DESCRIPTION

Get a Configuration Version for a workspace

## EXAMPLES

### Example 1

```powershell
PS C:\> $TFEBaseURL = "https://app.terraform.io"
PS C:\> $Token = ConvertTo-SecureString -String 'your-api-token' -AsPlainText -Force
PS C:\> $configVersion = Get-TFEConfigVersion -TFEBaseURL $TFEBaseURL -ConfigVersionID $ConfigVersionID -Token $Token
```

Get a Configuration Version for a workspace. The ConfigVersionID can be retrieved from the output of New-TFEConfigVersion function.

## PARAMETERS

### -ConfigVersionID

The TFE configuration version Id.

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

The base URL for Terraform Enterprise.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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

### System.Object

## NOTES

## RELATED LINKS
