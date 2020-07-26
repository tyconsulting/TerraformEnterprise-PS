function NewTarballFile
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    Param
    (
        # The input file(s)
        [Parameter(Mandatory=$true)][ValidateScript({Test-Path $_})][String]$source,
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][String]$output,
        [Parameter(Mandatory=$false)][Switch]$overwrite
    )
    if ($overwrite)
    {
        if (test-path $output)
        {
            write-verbose "output file '$output' already exists. It will be deleted."
            Remove-Item $output
        }
    }
    #Get the source from file system
    $fsObject = Get-item $source
    If (test-path $source -PathType Leaf)
    {
        #individual file
        $parentDir = $fsObject.Directory
        $childName = $fsObject.Name
        & tar -C "$parentDir" -czf $output $childName
    } else {
        #folder
        & tar -C "$source" -czf $output *.*
    }

    try{

    }
    catch{
        throw
        exit 1
    }
}
Function DecodeToken
{
    Param(
        [Parameter(Mandatory = $true)][securestring]$Token
    )
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Token);
    try
    {
        $strToken = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr);
    }
    finally
    {
        [Runtime.InteropServices.Marshal]::FreeBSTR($bstr);
    }
    $strToken
}
Function New-TFEConfigVersion
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium', HelpUri='https://github.com/tyconsulting/TerraformEnterprise-PS/wiki/Get-TFEConfigVersion')]
    [OutputType([object])]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the organization name.")][string]$Org,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the workspace Name.")][string]$WorkSpaceName,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token
    )
    begin {
        Write-Verbose "Get workspace"
        try {
            $workspace = Get-TFEWorkspace -TFEBaseURL $TFEBaseURL -Org $org -WorkspaceName $WorkSpaceName -Token $Token
            $WorkSpaceID = $workspace.id
            Write-verbose "workspace Id for workspace $WorkspaceName is $WorkSpaceID"
        } catch {
            throw
            Exit 1
        }

        Write-verbose "Create a new Terraform Enterprise configuration version"

        $body = @{
            "data" = @{
                "type"       = "configuration-version"
                "attributes" = @{
                    "auto-queue-runs" = $false
                }
            }
        } | ConvertTo-Json

        $requestParams = @{
            Uri         = "$TFEBaseURL/api/v2/workspaces/$WorkSpaceID/configuration-versions"
            Headers     = @{"Authorization" = "Bearer $(DecodeToken -Token $Token)" }
            ContentType = 'application/vnd.api+json'
            Method      = 'Post'
            Body        = $body
            ErrorAction = 'stop'
            UseBasicParsing = $true
        }
    } Process {
        Write-Verbose "requesting new config via URI '$($requestParams.Uri)'"
        try {
            if ($PSCmdlet.ShouldProcess($WorkspaceName))
            {
                $ReturnedData = (Invoke-RestMethod @requestParams).data
            }
        } catch {
            throw
            Exit 1
        }
    } End {
        $ReturnedData
    }
}

Function Get-TFEWorkspace
{
    [CmdletBinding(HelpUri='https://github.com/tyconsulting/TerraformEnterprise-PS/wiki/Get-TFEWorkspace')]
    [OutputType([object])]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL = "https://app.terraform.io",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the organization name.")][string]$Org,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the workspace name.")][string]$WorkspaceName,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token
    )

    try {
        $GetRequest = @{
            Uri         = "$TFEBaseURL/api/v2/organizations/$Org/workspaces/$WorkSpaceName"
            Headers     = @{"Authorization" = "Bearer $(DecodeToken -Token $Token)" }
            ContentType = 'application/vnd.api+json'
            Method      = 'Get'
            ErrorAction = 'stop'
            UseBasicParsing = $true
        }

        $Result = (Invoke-RestMethod @GetRequest).data
    }
    catch {
        throw
        exit 1
    }
    $Result
}

Function Set-TFEWorkspace
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium', HelpUri='https://github.com/tyconsulting/TerraformEnterprise-PS/wiki/Set-TFEWorkspace')]
    [OutputType([object])]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL = "https://app.terraform.io",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the organization name.")][string]$Org,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the workspace name.")][string]$WorkspaceName,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token,
        [Parameter(Mandatory = $false, HelpMessage = "Enter the new name of the workspace.")][string]$NewWorkspaceName,
        [Parameter(Mandatory = $false, HelpMessage = "Enter the description of the workspace.")][string]$WorkspaceDescription,
        [Parameter(Mandatory = $false, HelpMessage = "Enter the Terraform version of the workspace.")][string]$TerraformVersion,
        [Parameter(Mandatory = $false, HelpMessage = "Enter the Terraform working Directory of the workspace.")][string]$TerraformWorkingDir,
        [Parameter(Mandatory = $false, HelpMessage = "Allow automatically apply changes when a Terraform plan is successful.")][boolean]$AutoApply,
        [Parameter(Mandatory = $false, HelpMessage = "Allow destroy plan.")][boolean]$AllowDestroyPlan,
        [Parameter(Mandatory = $false, HelpMessage = "Whether to use remote execution mode. When set to false, the workspace will be used for state storage only.")][boolean]$UseRemoteExecution
    )
    begin {
        #Process input
        $attributes = @{}
        If ($PSBoundParameters.ContainsKey('NewWorkspaceName'))
        {
            $attributes.add('name', $NewWorkspaceName)
        }
        If ($PSBoundParameters.ContainsKey('WorkspaceDescription'))
        {
            $attributes.add('description', $WorkspaceDescription)
        }
        If ($PSBoundParameters.ContainsKey('TerraformVersion'))
        {
            $attributes.add('terraform-version', $TerraformVersion)
        }
        If ($PSBoundParameters.ContainsKey('TerraformWorkingDir'))
        {
            $attributes.add('working-directory', $TerraformWorkingDir)
        }
        If ($PSBoundParameters.ContainsKey('AutoApply'))
        {
            $attributes.add('auto-apply', $AutoApply)
        }
        If ($PSBoundParameters.ContainsKey('AllowDestroyPlan'))
        {
            $attributes.add('allow-destroy-plan', $AllowDestroyPlan)
        }
        If ($PSBoundParameters.ContainsKey('UseRemoteExecution'))
        {
            $attributes.add('operations', $UseRemoteExecution)
        }
        If ($attributes.Keys.count -eq 0)
        {
            Throw "No workspace attributes specified. Nothing to set."
            Exit 1
        }

        $body = @{
            "data" = @{
                "attributes"    = $attributes
                "type" = "workspaces"
                }
        } | ConvertTo-Json -Depth 5
        $PatchRequest = @{
            Uri         = "$TFEBaseURL/api/v2/organizations/$Org/workspaces/$WorkSpaceName"
            Headers     = @{"Authorization" = "Bearer $(DecodeToken -Token $Token)" }
            ContentType = 'application/vnd.api+json'
            Method      = 'Patch'
            ErrorAction = 'stop'
            Body = $body
            UseBasicParsing = $true
        }
    } Process {
        try {
            if ($PSCmdlet.ShouldProcess($WorkspaceName))
            {
                $Result = (Invoke-RestMethod @PatchRequest).data
            }
        }
        catch {
            throw
            exit 1
        }
    } End {
        $Result
    }
}

Function New-TFEWorkspace
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium', HelpUri='https://github.com/tyconsulting/TerraformEnterprise-PS/wiki/New-TFEWorkspace')]
    [OutputType([object])]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL = "https://app.terraform.io",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the organization name.")][string]$Org,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the workspace name.")][string]$WorkspaceName,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token,
        [Parameter(Mandatory = $false, HelpMessage = "Enter the description of the workspace.")][string]$WorkspaceDescription,
        [Parameter(Mandatory = $false, HelpMessage = "Enter the Terraform version of the workspace.")][string]$TerraformVersion,
        [Parameter(Mandatory = $false, HelpMessage = "Enter the Terraform working Directory of the workspace.")][string]$TerraformWorkingDir,
        [Parameter(Mandatory = $false, HelpMessage = "Allow automatically apply changes when a Terraform plan is successful.")][boolean]$AutoApply,
        [Parameter(Mandatory = $false, HelpMessage = "Allow destroy plan.")][boolean]$AllowDestroyPlan,
        [Parameter(Mandatory = $false, HelpMessage = "Whether to use remote execution mode. When set to false, the workspace will be used for state storage only.")][boolean]$UseRemoteExecution
    )
    begin {
        #Process input
        $attributes = @{}
        $attributes.add('name', $WorkspaceName)
        If ($PSBoundParameters.ContainsKey('WorkspaceDescription'))
        {
            $attributes.add('description', $WorkspaceDescription)
        }
        If ($PSBoundParameters.ContainsKey('TerraformVersion'))
        {
            $attributes.add('terraform-version', $TerraformVersion)
        }
        If ($PSBoundParameters.ContainsKey('TerraformWorkingDir'))
        {
            $attributes.add('working-directory', $TerraformWorkingDir)
        }
        If ($PSBoundParameters.ContainsKey('AutoApply'))
        {
            $attributes.add('auto-apply', $AutoApply)
        }
        If ($PSBoundParameters.ContainsKey('AllowDestroyPlan'))
        {
            $attributes.add('allow-destroy-plan', $AllowDestroyPlan)
        }
        If ($PSBoundParameters.ContainsKey('UseRemoteExecution'))
        {
            $attributes.add('operations', $UseRemoteExecution)
        }
        $body = @{
            "data" = @{
                "attributes"    = $attributes
                "type" = "workspaces"
                }
        } | ConvertTo-Json -Depth 5
        $PostRequest = @{
            Uri         = "$TFEBaseURL/api/v2/organizations/$Org/workspaces"
            Headers     = @{"Authorization" = "Bearer $(DecodeToken -Token $Token)" }
            ContentType = 'application/vnd.api+json'
            Method      = 'POST'
            ErrorAction = 'stop'
            Body = $body
            UseBasicParsing = $true
        }
    } Process {
        try {
            Write-verbose "Creating workspace $Workspace in Organisation $org"
            if ($PSCmdlet.ShouldProcess($WorkspaceName))
            {
                $Result = (Invoke-RestMethod @PostRequest).data
            }
        }
        catch {
            throw
            exit 1
        }
    } End {
        $Result
    }
}

Function Remove-TFEWorkspace
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High', HelpUri='https://github.com/tyconsulting/TerraformEnterprise-PS/wiki/Remove-TFEWorkspace')]
    [OutputType([boolean])]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL = "https://app.terraform.io",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the organization name.")][string]$Org,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the workspace name.")][string]$WorkspaceName,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token
    )
    begin {
        #Process input

        $DeleteRequest = @{
            Uri         = "$TFEBaseURL/api/v2/organizations/$Org/workspaces/$WorkspaceName"
            Headers     = @{"Authorization" = "Bearer $(DecodeToken -Token $Token)" }
            ContentType = 'application/vnd.api+json'
            Method      = 'DELETE'
            ErrorAction = 'stop'
            UseBasicParsing = $true
        }
    } Process {
        try {
            Write-verbose "Delete workspace $Workspace from Organisation $org"
            if ($PSCmdlet.ShouldProcess($WorkspaceName))
            {
                Invoke-RestMethod @DeleteRequest
            }
        }
        catch {
            throw
            exit 1
        }
    } End {
        $true
    }
}
Function Add-TFEVariable
{
    [CmdletBinding(HelpUri='https://github.com/tyconsulting/TerraformEnterprise-PS/wiki/Add-TFEVariable')]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL = "https://app.terraform.io",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the organization name.")][string]$Org,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the workspace name.")][string]$WorkspaceName,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token,
        [Parameter(Mandatory = $false, HelpMessage = "Non-sensitive Terraform variables in a hashtable")][hashtable]$TFVariables,
        [Parameter(Mandatory = $false, HelpMessage = "Sensitive Terraform Variables in a hashtable")][hashtable]$TFSecrets,
        [Parameter(Mandatory = $false, HelpMessage = "Non-sensitive environment variables in a hashtable")][hashtable]$EnvVariables,
        [Parameter(Mandatory = $false, HelpMessage = "Sensitive Envrionment Variables in a hashtable")][hashtable]$EnvSecrets
    )

    Write-verbose "Getting Existing Variables in Workspace $WorkspaceName"

    try {
        $GetVariablesRequest = @{
            Uri         = "$TFEBaseURL/api/v2/vars?filter%5Borganization%5D%5Bname%5D=$Org&filter%5Bworkspace%5D%5Bname%5D=$WorkSpaceName"
            Headers     = @{"Authorization" = "Bearer $(DecodeToken -Token $Token)" }
            ContentType = 'application/vnd.api+json'
            Method      = 'GET'
            ErrorAction = 'stop'
            UseBasicParsing = $true
        }

        $VariableResult = (Invoke-RestMethod @GetVariablesRequest).data
        $ExistingVariables = @()
        foreach ($item in $variableResult)
        {
            $ExistingVariables += New-Object psobject -Property @{"key" = $item.attributes.key; "sensitive" = [bool]$item.attributes.sensitive; "category" = $item.attributes.category}
        }

    } Catch {
        Throw
        Exit 1
    }

    $SourceVariables = @()

    If ($PSBoundParameters.containskey('TFVariables'))
    {
        Foreach ($key in $TFVariables.keys)
        {
            Write-verbose "Processing Terraform variable $key"
            $SourceVariables += New-Object psobject -Property @{"key" = $key; "value" = $TFVariables.$key; "sensitive" = $false; "category" = "terraform"}
        }
    }

    if ($PSBoundParameters.containskey('TFSecrets'))
    {
        Foreach ($key in $TFSecrets.keys)
        {
            Write-verbose "Processing Terraform secret $key"
            $SourceVariables += New-Object psobject -Property @{"key" = $key; "value" = $TFSecrets.$key; "sensitive" = $true; "category" = "terraform"}
        }
    }

    If ($PSBoundParameters.containskey('EnvVariables'))
    {
        Foreach ($key in $EnvVariables.keys)
        {
            Write-verbose "Processing Environment variable $key"
            $SourceVariables += New-Object psobject -Property @{"key" = $key; "value" = $EnvVariables.$key; "sensitive" = $false; "category" = "env"}
        }
    }

    if ($PSBoundParameters.containskey('EnvSecrets'))
    {
        Foreach ($key in $EnvSecrets.keys)
        {
            Write-verbose "Processing Environment secret $key"
            $SourceVariables += New-Object psobject -Property @{"key" = $key; "value" = $EnvSecrets.$key; "sensitive" = $true; "category" = "env"}
        }
    }

    If ($SourceVariables.count -eq 0)
    {
        Throw "No Terraform or Environment variables & secrets have been passed into the function."
        Exit 1
    } else {
        Write-verbose "The following variables have been passed into the function"
        foreach ($item in $SourceVariables)
        {
            Write-verbose "key = $($item.key); sensitive = '$($item.sensitive)'; category = '$($item.category)'"
        }
    }

    Write-verbose "Comparing Source Variables With Existing Variables"
    $VariableAction = @()

    Compare-Object $SourceVariables $ExistingVariables -Property key, sensitive, category -IncludeEqual | Where-Object {$_.key -ne "CONFIRM_DESTROY"} | ForEach-Object {
        if ($_.sideindicator -eq "==") {
            $VariableAction += New-Object psobject -Property @{"Variable" = $_; "Action" = "Modify"}
        }
        elseif ($_.sideindicator -eq "<=") {
            $VariableAction += New-Object psobject -Property @{"Variable" = $_; "Action" = "Add"}
        }
        elseif ($_.sideindicator -eq "=>") {
            $VariableAction += New-Object psobject -Property @{"Variable" = $_; "Action" = "Remove"}
        }
    }

    Write-verbose "Updating Variables"
    if ($VariableAction.action -contains "add") {
        $Workspace = Get-TFEWorkspace -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $WorkspaceName -Token $Token
        $WorkspaceID = $Workspace.Id
    }

    foreach ($item in $VariableAction) {

        try {
            if ($item.action -ieq "add") {
                write-verbose "Adding variable $($item.variable.key)"
                try {
                    $body = @{
                        "data" = @{
                            "type"          = "vars"
                            "attributes"    = @{
                                "key"       = $($item.Variable.key)
                                "value"     = $($SourceVariables.GetEnumerator() | Where-Object {$_.key -eq $item.variable.key -and $_.category -ieq $item.variable.category -and $_.sensitive -eq $item.variable.sensitive} |Select-Object -ExpandProperty Value)
                                "category"  = $($item.variable.category)
                                "hcl"       = "false"
                                "sensitive" = $($item.Variable.sensitive)
                            }
                            "relationships" = @{
                                "workspace" = @{
                                    "data" = @{
                                        "id"   = "$WorkSpaceID"
                                        "type" = "workspaces"
                                    }
                                }
                            }
                        }
                    } | ConvertTo-Json -Depth 5

                    $AddRequest = @{
                        Uri         = "$TFEBaseURL/api/v2/vars"
                        Headers     = @{"Authorization" = "Bearer $(DecodeToken -Token $Token)" }
                        ContentType = 'application/vnd.api+json'
                        Method      = 'Post'
                        Body        = $body
                        ErrorAction = 'stop'
                        UseBasicParsing = $true
                    }

                    (Invoke-RestMethod @AddRequest).data | out-null
                }
                catch {
                    Throw
                    Exit 1
                }
            } elseif ($item.action -ieq "modify") {
                write-verbose "Modifying $($item.variable.key)"

                try {
                    $body = @{
                        "data" = @{
                            "type"       = "vars"
                            "id"         = $($VariableResult | Where-Object {$_.attributes.key -eq $item.variable.key -and $_.attributes.category -ieq $item.Variable.category -and $_.attributes.sensitive -eq $item.variable.sensitive} |Select-Object -exp id)
                            "attributes" = @{
                                "key"       = $($item.variable.key)
                                "value"     = $($SourceVariables.GetEnumerator() | Where-Object {$_.key -eq $item.Variable.key -and $_.category -ieq $item.Variable.category -and $_.sensitive -eq $item.variable.sensitive} |Select-Object -ExpandProperty Value)
                                "category"  = $($item.variable.category)
                                "hcl"       = "false"
                                "sensitive" = $($item.Variable.sensitive)
                            }
                        }
                    } | ConvertTo-Json

                    $PatchRequest = @{
                        Uri         = "$TFEBaseURL/api/v2/vars/$($VariableResult | Where-Object {$_.attributes.key -eq $item.variable.key -and $_.attributes.category -ieq $item.Variable.category -and $_.attributes.sensitive -eq $item.variable.sensitive} |Select-Object -exp id)"
                        Headers     = @{"Authorization" = "Bearer $(DecodeToken -Token $Token)" }
                        ContentType = 'application/vnd.api+json'
                        Method      = 'Patch'
                        Body        = $body
                        ErrorAction = 'stop'
                    }
                    (Invoke-RestMethod @PatchRequest).data | out-null

                }
                catch {
                    throw
                    Exit 1
                }
            }

        }
        catch {
            throw
            Exit 1
        }
    }
    Write-verbose "Finished adding variables to TFE workspace."
}

Function Remove-TFEVariable
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium', HelpUri='https://github.com/tyconsulting/TerraformEnterprise-PS/wiki/Remove-TFEVariable')]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL = "https://app.terraform.io",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the organization name.")][string]$Org,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the workspace name.")][string]$WorkspaceName,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token,
        [Parameter(Mandatory = $false, HelpMessage = "list of names of the non-sensitive Terraform variables to be deleted")][string[]]$TFVariables,
        [Parameter(Mandatory = $false, HelpMessage = "list of names of the sensitive Terraform variables to be deleted")][string[]]$TFSecrets,
        [Parameter(Mandatory = $false, HelpMessage = "list of names of the non-sensitive Environment variables to be deleted")][string[]]$EnvVariables,
        [Parameter(Mandatory = $false, HelpMessage = "list of names of the sensitive Environment variables to be deleted")][string[]]$EnvSecrets
    )
    Begin {
        Write-verbose "Getting Existing Variables in Workspace $WorkspaceName"
        try {
            $GetVariablesRequest = @{
                Uri         = "$TFEBaseURL/api/v2/vars?filter%5Borganization%5D%5Bname%5D=$Org&filter%5Bworkspace%5D%5Bname%5D=$WorkSpaceName"
                Headers     = @{"Authorization" = "Bearer $(DecodeToken -Token $Token)" }
                ContentType = 'application/vnd.api+json'
                Method      = 'GET'
                ErrorAction = 'stop'
                UseBasicParsing = $true
            }

            $VariableResult = (Invoke-RestMethod @GetVariablesRequest).data
            $ExistingVariables = @()
            foreach ($item in $variableResult)
            {
                $ExistingVariables += New-Object psobject -Property @{"key" = $item.attributes.key; "sensitive" = [bool]$item.attributes.sensitive; "category" = $item.attributes.category}
            }

        } Catch {
            Throw
            Exit 1
        }

        $SourceVariables = @()

        If ($PSBoundParameters.containskey('TFVariables'))
        {
            Foreach ($item in $TFVariables)
            {
                Write-verbose "Processing Terraform variable $item"
                $SourceVariables += New-Object psobject -Property @{"key" = $item; "sensitive" = $false; "category" = "terraform"}
            }
        }
        if ($PSBoundParameters.containskey('TFSecrets'))
        {
            Foreach ($item in $TFSecrets)
            {
                Write-verbose "Processing Terraform secret $item"
                $SourceVariables += New-Object psobject -Property @{"key" = $item; "sensitive" = $true; "category" = "terraform"}
            }
        }
        If ($PSBoundParameters.containskey('EnvVariables'))
        {
            Foreach ($item in $EnvVariables)
            {
                Write-verbose "Processing Environment variable $item"
                $SourceVariables += New-Object psobject -Property @{"key" = $item; "sensitive" = $false; "category" = "env"}
            }
        }
        if ($PSBoundParameters.containskey('EnvSecrets'))
        {
            Foreach ($item in $EnvSecrets)
            {
                Write-verbose "Processing Environment secret $item"
                $SourceVariables += New-Object psobject -Property @{"key" = $item; "sensitive" = $true; "category" = "env"}
            }
        }
    } Process {
        If ($SourceVariables.count -eq 0)
        {
            Throw "No Terraform or Environment variables & secrets have been passed into the function."
            Exit 1
        } else {
            Write-verbose "The following variables have been passed into the function"
            foreach ($item in $SourceVariables)
            {
                Write-verbose "key = $($item.key); sensitive = '$($item.sensitive)'; category = '$($item.category)'"
            }
        }

        Write-verbose "Comparing Source Variables With Existing Variables"
        $VariableAction = @()

        Compare-Object $SourceVariables $ExistingVariables -Property key, sensitive, category -IncludeEqual | Where-Object {$_.key -ne "CONFIRM_DESTROY"} | ForEach-Object {
            if ($_.sideindicator -eq "==") {
                $VariableAction += New-Object psobject -Property @{"Variable" = $_; "Action" = "Remove"}
            }
        }
        If ($VariableAction.count -gt 0)
        {
            Write-verbose "Removing Variables"
        } else {
            Write-Verbose "No variables to remove"
        }

        if ($PSCmdlet.ShouldProcess($WorkspaceName))
        {
            foreach ($item in $VariableAction) {
                write-verbose "Removing $($item.variable.key)"

                try {
                    $DeleteRequest = @{
                        Uri         = "$TFEBaseURL/api/v2/vars/$($VariableResult | Where-Object {$_.attributes.key -eq $item.variable.key -and $_.attributes.category -ieq $item.Variable.category -and $_.attributes.sensitive -eq $item.variable.sensitive} |Select-Object -exp id)"
                        Headers     = @{"Authorization" = "Bearer $(DecodeToken -Token $Token)" }
                        ContentType = 'application/vnd.api+json'
                        Method      = 'Delete'
                        ErrorAction = 'stop'
                        UseBasicParsing = $true
                    }
                    (Invoke-RestMethod @DeleteRequest).data | out-null
                }
                catch {
                    throw
                    Exit 1
                }
            }
        }
    } End {
        Write-verbose "Finished removing variables from TFE workspace."
    }
}

Function Get-TFEConfigVersion
{
    [CmdletBinding(HelpUri='https://github.com/tyconsulting/TerraformEnterprise-PS/wiki/Get-TFEConfigVersion')]
    [OutputType([object])]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Enter the base URL for Terraform Enterprise.")][string]$TFEBaseURL,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the TFE configuration version Id.")][string]$ConfigVersionID,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token
    )


    Write-verbose "Get Terraform Enterprise configuration version $ConfigVersionID"

    $requestParams = @{
        Uri         = "$TFEBaseURL/api/v2/configuration-versions/$ConfigVersionID"
        Headers     = @{"Authorization" = "Bearer $(DecodeToken -Token $Token)" }
        ContentType = 'application/vnd.api+json'
        Method      = 'Get'
        ErrorAction = 'stop'
        UseBasicParsing = $true
    }
    Write-Verbose "requesting new config via URI '$($requestParams.Uri)'"
    try {
        $ReturnedData = (Invoke-RestMethod @requestParams).data
    } catch {
        throw
        Exit 1
    }
    $ReturnedData
}
Function Add-TFEContent
{
    [CmdletBinding(HelpUri='https://github.com/tyconsulting/TerraformEnterprise-PS/wiki/Add-TFEContent')]
    [OutputType([bool])]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL = "https://app.terraform.io",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the TFE configuration version Id.")][string]$ConfigVersionID,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token,
        [Parameter(Mandatory = $true, HelpMessage = "Enter path to the file or folder to be uploaded.")][ValidateScript({Test-Path $_})][System.IO.FileInfo]$ContentPath
    )

    Write-Verbose "Get configuration version $ConfigVersionID"
    $configVersion = Get-TFEConfigVersion -TFEBaseURL $TFEBaseURL -ConfigVersionID $ConfigVersionID -Token $Token
    $uploadUrl = $configVersion.attributes.'upload-url'
    $tarballPath = Join-path $env:temp "$ConfigVersionID.tar.gz"
    #process content

    If (Test-Path $ContentPath -PathType Container)
    {
        Write-Verbose "Adding directory '$ContentPath' to '$tarballPath'"
        NewTarballFile -source $ContentPath -output $tarballPath
    } else {
        $UploadSource = get-item $ContentPath
        if ($UploadSource.name -imatch '.\.tar\.gz$')
        {
            Write-Verbose "'$ContentPath' is already a tarball. No need to create new tar.gz file"
        } else {
            Write-Verbose "Adding file '$ContentPath' to '$tarballPath'"
            NewTarballFile -source $ContentPath -output $tarballPath
        }

    }
    $requestParams = @{
        Uri         = $uploadUrl
        Method      = 'Put'
        InFile      = $tarballPath
        ContentType = "application/octet-stream"
        ErrorAction = 'Stop'
        UseBasicParsing = $true
    }
    Write-verbose "Adding content to configuration version '$ConfigVersionID'"
    try {
        $request = Invoke-WebRequest @requestParams
    }
    catch {
        Throw
        Exit 1
    }
    #Delete tarball from temp directory
    #Remove-Item -path $tarballPath -Force | Out-Null

    if ($request.StatusCode -ge 200 -and $request.statusCode -le 299)
    {
        Write-Verbose "Content uploaded successfully"
        $true
    } else {
        $false
    }

}

Function Get-TFERunDetails
{
    [CmdletBinding(HelpUri='https://github.com/tyconsulting/TerraformEnterprise-PS/wiki/Get-TFERunDetails')]
    [OutputType([Object])]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL = "https://app.terraform.io",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the TFE Run Id.")][string]$RunID,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token,
        [Parameter(Mandatory=$false, HelpMessage = "Wait for the TFE Run to complete.")][Switch]$WaitForCompletion,
        [Parameter(Mandatory=$false, HelpMessage = "When waiting for TFE Run to complete, exit when the status is Planned.")][Switch]$StopAtPlanned
    )

    $GetRequest = @{
        Uri         = "$TFEBaseURL/api/v2/runs/$RunID"
        Headers     = @{"Authorization" = "Bearer $(DecodeToken -Token $Token)" }
        ContentType = 'application/vnd.api+json'
        Method      = 'Get'
        ErrorAction = 'stop'
        UseBasicParsing = $true
    }
    $StatesToWaitFor = @("applying", "canceled", "confirmed", "pending", "planning", "policy_checked", "policy_checking", "policy_override")
    If (!$StopAtPlanned)
    {
        $StatesToWaitFor += 'planned'
    }
    Write-verbose "Getting run details for Id '$RunID'"
    try {
        if ($WaitForCompletion)
        {
            $bFirstRequest = $true
            do {
                if (!$bFirstRequest)
                {
                    Start-Sleep 10
                }
                $Result = Invoke-RestMethod @GetRequest
                $bFirstRequest = $false
                $Status = $Result.data.attributes.status
                Write-Verbose "Terraform Workspace Run '$RunID' in '$Status' state"
            }
            while ($Status -in $StatesToWaitFor)
        } else {
            $Result = Invoke-RestMethod @GetRequest
            $Status = $Result.data.attributes.status
        }
    }
    catch {
        Throw
        Exit 1
    }
    $Result.data
}

Function Get-TFEPlan
{
    [CmdletBinding(HelpUri='https://github.com/tyconsulting/TerraformEnterprise-PS/wiki/Get-TFEPlan')]
    [OutputType([Object])]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL = "https://app.terraform.io",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the TFE Run Id.")][string]$RunID,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token
    )

    $GetRunRequest = @{
        Uri         = "$TFEBaseURL/api/v2/runs/$RunID"
        Headers     = @{"Authorization" = "Bearer $(DecodeToken -Token $Token)" }
        ContentType = 'application/vnd.api+json'
        Method      = 'Get'
        ErrorAction = 'stop'
        UseBasicParsing = $true
    }
    try {
        Write-verbose "Getting run status for Id '$RunID'"
        $RunResponse = Invoke-RestMethod @GetRunRequest
        $PlanId = $RunResponse.data.relationships.plan.data.id
        Write-verbose "Plan Id for the run is $PlanId"
        $GetPlanRequest = @{
            Uri         = "$TFEBaseURL/api/v2/plans/$PlanId"
            Headers     = @{"Authorization" = "Bearer $(DecodeToken -Token $Token)" }
            ContentType = 'application/vnd.api+json'
            Method      = 'Get'
            ErrorAction = 'stop'
            UseBasicParsing = $true
        }
        $PlanResponse = (Invoke-RestMethod @GetPlanRequest).data
    }
    catch {
        Throw
        Exit 1
    }
    $PlanResponse
}

Function Get-TFEPlanLog
{
    [CmdletBinding(HelpUri='https://github.com/tyconsulting/TerraformEnterprise-PS/wiki/Get-TFEPlanLog')]
    [OutputType([string])]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL = "https://app.terraform.io",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the TFE Plan Id.")][string]$PlanId,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token
    )

    $GetPlanRequest = @{
        Uri         = "$TFEBaseURL/api/v2/plans/$PlanId"
        Headers     = @{"Authorization" = "Bearer $(DecodeToken -Token $Token)" }
        ContentType = 'application/vnd.api+json'
        Method      = 'Get'
        ErrorAction = 'stop'
        UseBasicParsing = $true
    }
    try {
        Write-verbose "Getting details ofr Plan Id $PlanId"
        $PlanResponse = (Invoke-RestMethod @GetPlanRequest).data
        $LogReadURI = $PlanResponse.attributes.'log-read-url'
        $LogRequest = @{
            Uri = $LogReadURI
            Method      = 'Get'
            ErrorAction = 'stop'
            UseBasicParsing = $true
        }
        $LogContent = Invoke-RestMethod @LogRequest
    }
    catch {
        Throw
        Exit 1
    }
    $LogContent
}
Function New-TFERun
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low', HelpUri='https://github.com/tyconsulting/TerraformEnterprise-PS/wiki/New-TFERun')]
    [OutputType([object])]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL = "https://app.terraform.io",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the organization name.")][string]$Org,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the workspace name.")][string]$WorkspaceName,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the TFE configuration version Id.")][string]$ConfigVersionID,
        [Parameter(Mandatory = $false, HelpMessage = "Enter the comment for the queue plan.")][string]$comment = "Run Requested",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token
    )
    Begin {
        Write-Verbose "Get TFE workspace"
        $workspace = Get-TFEWorkspace -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $WorkspaceName -Token $Token
        $workspaceId = $workspace.Id

        $body = @{
            "data" = @{
                "attributes"    = @{
                    "is-destroy" = $false
                    "message"    = $Comment
                    "target-addrs" = @()
                }
                "type" = "runs"
                "relationships" = @{
                    "workspace" = @{
                        "data" = @{
                            "type" = "workspaces"
                            "id" = $workspaceId
                        }
                    }
                    "configuration-version" = @{
                        "data" = @{
                            "type" = "configuration-versions"
                            "id"   = $ConfigVersionID
                        }
                    }
                }
            }
        } | ConvertTo-Json -Depth 5
        write-verbose "requesty body $body"
        $PostRequest = @{
            Uri         = "$TFEBaseURL/api/v2/runs"
            Headers     = @{"Authorization" = "Bearer $(DecodeToken -Token $Token)" }
            ContentType = 'application/vnd.api+json'
            Method      = 'Post'
            Body        = $body
            ErrorAction = 'stop'
            UseBasicParsing = $true
        }
    } Process {
        try {
            Write-verbose "Creating new queue plan for TFE"
            if ($PSCmdlet.ShouldProcess($WorkspaceName))
            {
                $Result = (Invoke-RestMethod @PostRequest).data
            }
        }
        catch {
            THrow
            Exit 1
        }
    } End {
        $Result
    }
}

Function Approve-TFERun
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High', HelpUri='https://github.com/tyconsulting/TerraformEnterprise-PS/wiki/Approve-TFERun')]
    [OutputType([boolean])]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL = "https://app.terraform.io",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the Run ID.")][string]$RunID,
        [Parameter(Mandatory = $false, HelpMessage = "Enter the comment for the queue plan.")][string]$comment = "Appy Run via REST API",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token
    )
    Begin {
        $body = @{
            "comment" = $Comment
        } | ConvertTo-Json -Depth 5
        write-verbose "requesty body $body"
        $PostRequest = @{
            Uri         = "$TFEBaseURL/api/v2/runs/$RunID/actions/apply"
            Headers     = @{"Authorization" = "Bearer $(DecodeToken -Token $Token)" }
            ContentType = 'application/vnd.api+json'
            Method      = 'Post'
            Body        = $body
            ErrorAction = 'stop'
            UseBasicParsing = $true
        }
    } Process {
        try {
            Write-verbose "Apply Run Id $RunID"
            if ($PSCmdlet.ShouldProcess($WorkspaceName))
            {
                Invoke-RestMethod @PostRequest
            }
        }
        catch {
            THrow
            Exit 1
        }
    } End {
        $true
    }
}

Function Stop-TFERun
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High', HelpUri='https://github.com/tyconsulting/TerraformEnterprise-PS/wiki/Stop-TFERun')]
    [OutputType([boolean])]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL = "https://app.terraform.io",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the Run ID.")][string]$RunID,
        [Parameter(Mandatory = $false, HelpMessage = "Enter the comment for the queue plan.")][string]$comment = "Discard Run via REST API",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token
    )
    Begin {
        $body = @{
            "comment" = $Comment
        } | ConvertTo-Json -Depth 5
        write-verbose "requesty body $body"
        $PostRequest = @{
            Uri         = "$TFEBaseURL/api/v2/runs/$RunID/actions/discard"
            Headers     = @{"Authorization" = "Bearer $(DecodeToken -Token $Token)" }
            ContentType = 'application/vnd.api+json'
            Method      = 'Post'
            Body        = $body
            ErrorAction = 'stop'
            UseBasicParsing = $true
        }
    } Process {
        try {
            Write-verbose "Disgard Run Id $RunID"
            if ($PSCmdlet.ShouldProcess($WorkspaceName))
            {
                Invoke-RestMethod @PostRequest
            }
        }
        catch {
            THrow
            Exit 1
        }
    } End {
        $true
    }
}
Function New-TFEDestroyPlan
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High', HelpUri='https://github.com/tyconsulting/TerraformEnterprise-PS/wiki/New-TFEDestroyPlan')]
    [OutputType([object])]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL = "https://app.terraform.io",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the organization name.")][string]$Org,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the workspace name.")][string]$WorkspaceName,
        [Parameter(Mandatory = $false, HelpMessage = "Enter the comment for the queue plan.")][string]$comment = "Destroy Plan Requested",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token
    )
    Begin {
        Write-Verbose "Get TFE workspace"
        $workspace = Get-TFEWorkspace -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $WorkspaceName -Token $Token
        $workspaceId = $workspace.Id

        $body = @{
            "data" = @{
                "attributes"    = @{
                    "is-destroy" = $true
                    "message"    = $Comment
                }
                "type" = "runs"
                "relationships" = @{
                    "workspace" = @{
                        "data" = @{
                            "type" = "workspaces"
                            "id" = $workspaceId
                        }
                    }
                }
            }
        } | ConvertTo-Json -Depth 5
        write-verbose "requesty body $body"
        $PostRequest = @{
            Uri         = "$TFEBaseURL/api/v2/runs"
            Headers     = @{"Authorization" = "Bearer $(DecodeToken -Token $Token)" }
            ContentType = 'application/vnd.api+json'
            Method      = 'Post'
            Body        = $body
            ErrorAction = 'stop'
            UseBasicParsing = $true
        }
    } Process {
        try {
            Write-verbose "Creating new destroy plan for TFE"
            if ($PSCmdlet.ShouldProcess($WorkspaceName))
            {
                $Result = (Invoke-RestMethod @PostRequest).data
            }
        }
        catch {
            THrow
            Exit 1
        }
    } End {
        $Result
    }
}
#Set TLS version
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Make sure the tar command is part of the operating system
Try {
    get-command tar -ErrorAction SilentlyContinue -ErrorVariable GetTarError | Out-Null
    If ($GetTarError)
    {
        throw "Unable to locate tar command. Unable to continue."
    }
} catch {
    throw
    Exit 1
}