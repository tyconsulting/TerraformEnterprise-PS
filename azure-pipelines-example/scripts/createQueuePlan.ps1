[CmdletBinding()]
[OutputType([string])]
Param(
    [Parameter(Mandatory = $true, HelpMessage = "Enter the base URL for Terraform Enterprise. If not specified, the Terraform Cloud URL will be used.")][string]$TFEBaseURL,
    [Parameter(Mandatory = $true, HelpMessage = "Enter the organization name.")][string]$Org,
    [Parameter(Mandatory = $true, HelpMessage = "Enter the workspace Name.")][string]$WorkSpaceName,
    [Parameter(Mandatory = $true, HelpMessage = "Enter the Configuration Id.")][string]$ConfigVersionID,
    [Parameter(Mandatory = $true, HelpMessage = "Enter the API token as a String.")][string]$Token,
    [Parameter(Mandatory = $false, HelpMessage = "Cancel run after plan")][string]$CancelAfterPlan = "False"
)

#Convert string to boolean
$bCancelAfterPlan = [boolean]::Parse($CancelAfterPlan)

#Convert API to secure string
$secToken = new-object securestring
foreach ($char in [char[]]$Token)
{ $secToken.AppendChar($char) }
$secToken.MakeReadOnly()

try {
    Write-Output "Create Run"
    $Run = New-TFERun -TFEBaseURL $TFEBaseURL -Org $Org -WorkspaceName $workspaceName -Token $secToken -ConfigVersionID $ConfigVersionID
    Write-Output "Run Id: '$($Run.Id)'"

    Write-Output "Get Run status"
    Start-Sleep -Seconds 10
    $RunDetails = Get-TFERunDetails -TFEBaseURL $TFEBaseURL -RunID $Run.id -Token $secToken -WaitForCompletion -stopAtPlanned
    $RunDetails

    If($bCancelAfterPlan)
    {
        if ($RunDetails.attributes.status -ieq 'planed_and_finished')
        {
            write-output "no need to discard the run."
        } else {
            Write-output "Discard Run"
            Stop-TFERun -TFEBaseURL $TFEBaseURL -RunID $Run.id -Token $secToken -confirm:$false
        }
    } else {
        Write-Output "Approve Run"
        Approve-TFERun -TFEBaseURL $TFEBaseURL -RunID $Run.id -Token $secToken -Confirm:$false

        Write-Output "Wait for the run to finish"
        Get-TFERunDetails -TFEBaseURL $TFEBaseURL -RunID $Run.id -Token $secToken -WaitForCompletion

    }
} catch {
    Write-Output "Get Logs"
    $Plan = Get-TFEPlan -TFEBaseURL $TFEBaseURL -RunID $Run.id -Token $secToken
    $Log = Get-TFEPlanLog -TFEBaseURL $TFEBaseURL -PlanId $Plan.id -Token $secToken
    Write-Output $Log
    Throw $_
}


Write-Output "Get Logs"
$Plan = Get-TFEPlan -TFEBaseURL $TFEBaseURL -RunID $Run.id -Token $secToken
$Log = Get-TFEPlanLog -TFEBaseURL $TFEBaseURL -PlanId $Plan.id -Token $secToken
Write-Output $Log