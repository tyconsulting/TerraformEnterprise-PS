function New-Tarball
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
    } else {
        #folder
        $parentDir = $fsObject.Parent
    }
    $childName = $fsObject.Name
    try{
        invoke-expression -Command "tar -C '$parentDir' -czf $output $childName"
    }
    catch{
        throw
        exit 1
    }
}
Function DecodeToken
{
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][securestring]$Token
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
    [CmdletBinding()]
    [OutputType([object])]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Enter the base URL for Terraform Enterprise.")][string]$TFEBaseURL,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the workspace Id.")][string]$WorkSpaceID,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token
    )

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
        Headers     = @{"Authorization" = "Bearer $(DecodeToken $Token)" } 
        ContentType = 'application/vnd.api+json'
        Method      = 'Post'
        Body        = $body
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

Function Get-TFEWorkspace
{
    [CmdletBinding()]
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
            Headers     = @{"Authorization" = "Bearer $(DecodeToken $Token)" } 
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

Function Add-TFEVariable
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL = "https://app.terraform.io",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the organization name.")][string]$Org,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the workspace name.")][string]$WorkspaceName,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token,
        [Parameter(Mandatory = $false)][hashtable]$TFVariables,
        [Parameter(Mandatory = $false)][hashtable]$TFSecrets,
        [Parameter(Mandatory = $false)][hashtable]$EnvVariables,
        [Parameter(Mandatory = $false)][hashtable]$EnvSecrets
    )
    
    Write-verbose "Getting Existing Variables in Workspace $WorkspaceName"
    
    try {
        $GetVariablesRequest = @{
            Uri         = "$TFEBaseURL/api/v2/vars?filter%5Borganization%5D%5Bname%5D=$Org&filter%5Bworkspace%5D%5Bname%5D=$WorkSpaceName"
            Headers     = @{"Authorization" = "Bearer $(DecodeToken $Token)" }
            ContentType = 'application/vnd.api+json'
            Method      = 'GET'
            ErrorAction = 'stop'
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
                        Headers     = @{"Authorization" = "Bearer $(DecodeToken $Token)" } 
                        ContentType = 'application/vnd.api+json'
                        Method      = 'Post'
                        Body        = $body
                        ErrorAction = 'stop'
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
                        Headers     = @{"Authorization" = "Bearer $(DecodeToken $Token)" }
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
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL = "https://app.terraform.io",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the organization name.")][string]$Org,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the workspace name.")][string]$WorkspaceName,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token,
        [Parameter(Mandatory = $false)][hashtable]$TFVariables,
        [Parameter(Mandatory = $false)][hashtable]$TFSecrets,
        [Parameter(Mandatory = $false)][hashtable]$EnvVariables,
        [Parameter(Mandatory = $false)][hashtable]$EnvSecrets
    )
    Write-verbose "Getting Existing Variables in Workspace $WorkspaceName"
    
    try {
        $GetVariablesRequest = @{
            Uri         = "$TFEBaseURL/api/v2/vars?filter%5Borganization%5D%5Bname%5D=$Org&filter%5Bworkspace%5D%5Bname%5D=$WorkSpaceName"
            Headers     = @{"Authorization" = "Bearer $(DecodeToken $Token)" }
            ContentType = 'application/vnd.api+json'
            Method      = 'GET'
            ErrorAction = 'stop'
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
            $VariableAction += New-Object psobject -Property @{"Variable" = $_; "Action" = "Remove"}
        }
    }
    If ($VariableAction.count -gt 0)
    {
        Write-verbose "Removing Variables"
    } else {
        Write-Verbose "No variables to remove"
    }
    
    
    foreach ($item in $VariableAction) {
        write-verbose "Removing $($item.variable.key)"
        
        try {    
            $DeleteRequest = @{
                Uri         = "$TFEBaseURL/api/v2/vars/$($VariableResult | Where-Object {$_.attributes.key -eq $item.variable.key -and $_.attributes.category -ieq $item.Variable.category -and $_.attributes.sensitive -eq $item.variable.sensitive} |Select-Object -exp id)"
                Headers     = @{"Authorization" = "Bearer $(DecodeToken $Token)" }
                ContentType = 'application/vnd.api+json'
                Method      = 'Delete'
                ErrorAction = 'stop'
            }
            (Invoke-RestMethod @DeleteRequest).data | out-null
        }
        catch {
            throw
            Exit 1
        }
    }
    Write-verbose "Finished removing variables from TFE workspace."
}
Function Add-TFEContent
{
    [CmdletBinding()]
    [OutputType([bool])]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL = "https://app.terraform.io",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the organization name.")][string]$Org,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the workspace name.")][string]$WorkspaceName,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token,
        [Parameter(Mandatory = $true, HelpMessage = "Enter path to the file or folder to be uploaded.")][ValidateScript({Test-Path $_})][System.IO.FileInfo]$ContentPath
    )

    Write-Verbose "Get TFE workspace"
    $workspace = Get-TFEWorkspace -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $WorkspaceName -Token $Token
    $workspaceId = $workspace.Id
    
    Write-Verbose "Creating new configuration version"
    $newConfig = New-TFEConfigVersion -TFEBaseURL $TFEBaseURL -WorkspaceId $workspaceId -Token $Token
    $uploadUrl = $newConfig.attributes.'upload-url'
    $newConfigId = $newConfig.id
    $tarballPath = Join-path $env:temp "$newConfigId.tar.gz"
    #process content
    
    If (Test-Path $ContentPath -PathType Container)
    {
        Write-Verbose "Adding directory '$ContentPath' to '$tarballPath'"
        New-Tarball -source $ContentPath -output $tarballPath
    } else {
        $UploadSource = get-item $ContentPath
        if ($UploadSource.name -imatch '.\.tar\.gz$')
        {
            Write-Verbose "'$ContentPath' is already a tarball. No need to create new tar.gz file"
        } else {
            Write-Verbose "Adding file '$ContentPath' to '$tarballPath'"
            New-Tarball -source $ContentPath -output $tarballPath
        }

    }
    $requestParams = @{
        Uri         = $uploadUrl
        Method      = 'Put'
        InFile      = $tarballPath
        ErrorAction = 'Stop'
        UseBasicParsing = $true
    }
    Write-verbose "Adding content to configuration version '$newConfigId'"
    try {
        $request = Invoke-WebRequest @requestParams
    }
    catch {
        Throw
        Exit 1
    }
    if ($request.StatusCode -ge 200 -and $request.statusCode -le 299)
    {
        Write-Verbose "Content uploaded successfully"
        $true
    } else {
        $false
    }

}

Function Get-TFERunStatus
{
    [CmdletBinding()]
    [OutputType([int])]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL = "https://app.terraform.io",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the TFE Run Id.")][string]$RunID,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the workspace name.")][string]$WorkspaceName,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token,
        [Parameter(Mandatory=$false, HelpMessage = "Wait for the TFE Run to complete.")][Switch]$WaitForCompletion
    )
        
    $GetRequest = @{
        Uri         = "$TFEBaseURL/api/v2/runs/$RunID"
        Headers     = @{"Authorization" = "Bearer $(DecodeToken $Token)" } 
        ContentType = 'application/vnd.api+json'
        Method      = 'Get'
        ErrorAction = 'stop'
    }
    $StatesToWaitFor = @("applying", "canceled", "confirmed", "pending", "planned", "planning", "policy_checked", "policy_checking", "policy_override")

    Write-verbose "Getting run status for Id '$RunID'"
    try {
        if ($WaitForCompletion)
        {
            do {
                $Result = (Invoke-RestMethod @GetRequest).data
                $Status = $Result.attributes.status
                Write-Verbose "Terraform Workspace Run '$RunID' in '$Status' state"
                Start-Sleep 10 
            }
            while ($Status -in $StatesToWaitFor)
        } else {
            $Result = (Invoke-RestMethod @GetRequest).data
            $Status = $Result.attributes.status
        }
    }
    catch {
        Throw
        Exit 1
    }
    $Status
}
Function New-TFEQueuePlan
{
    [CmdletBinding()]
    [OutputType([object])]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL = "https://app.terraform.io",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the organization name.")][string]$Org,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the workspace name.")][string]$WorkspaceName,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the TFE configuration version Id.")][string]$ConfigVersionID,
        [Parameter(Mandatory = $false, HelpMessage = "Enter the comment for the queue plan.")][string]$comment = "Run Requested",
        [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a Secure String.")][securestring]$Token
    )

    Write-Verbose "Get TFE workspace"
    $workspace = Get-TFEWorkspace -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $WorkspaceName -Token $Token
    $workspaceId = $workspace.Id    
    #Get Workspace Id
    $body = @{
        "data" = @{
            "attributes"    = @{
                "is-destroy" = $false
                "message"    = $Comment
            }
            "type"          = "runs"
            "relationships" = @{
                "workspace"             = @{
                    "data" = @{
                        "type" = "workspaces"
                        "id"   = "$workspaceId"
                    }
                }
                "configuration-version" = @{
                    "data" = @{
                        "type" = "configuration-versions"
                        "id"   = "$ConfigVersionID"
                    }
                }
            }
        }
    } | ConvertTo-Json -Depth 5
    
        $PostRequest = @{
            Uri         = "https://$TFEURL/api/v2/runs"
            Headers     = @{"Authorization" = "Bearer $(DecodeToken $Token)" } 
            ContentType = 'application/vnd.api+json'
            Method      = 'Post'
            Body        = $body
            ErrorAction = 'stop'
        }
    
        try {
            Write-verbose "Creating new queue plan for TFE"
            $Result = (Invoke-RestMethod @PostRequest).data

        }
        catch {
           THrow
            Exit 1
        }
        $Result
    
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