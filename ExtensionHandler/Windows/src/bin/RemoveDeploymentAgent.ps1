param(
    [Parameter(Mandatory=$true)]
    [string]$patToken,
    [Parameter(Mandatory=$true)]
    [string]$workingFolder,
    [scriptblock]$logFunction    
)

$ErrorActionPreference = 'Stop'
$configCmdPath = ''

. "$PSScriptRoot\Constants.ps1"
. "$PSScriptRoot\AgentConfigurationManager.ps1"

function WriteConfigurationLog
{
    param(
    [string]$logMessage
    )
    
    $log = "[Configuration]: " + $logMessage
    if($logFunction -ne $null)
    {
        $logFunction.Invoke($log)
    }
    else
    {
        write-verbose $log
    }
}

function GetConfigCmdPath
{
     if([string]::IsNullOrEmpty($configCmdPath))
     {
        $configCmdPath = Join-Path $workingFolder $configCmd
        WriteConfigurationLog "`t`t Configuration cmd path: $configCmdPath"
     }
         
     return $configCmdPath
}

function ConfigCmdExists
{
    $configCmdExists = Test-Path $(GetConfigCmdPath)
    WriteConfigurationLog "`t`t Configuration cmd file exists: $configCmdExists"  
    
    return $configCmdExists    
}

try
{
    WriteConfigurationLog "Starting the Deployment agent removal script"
    
    if( ! $(ConfigCmdExists) )
    {
        throw "Unable to find the configuration cmd: $configCmdPath, ensure to download the agent using 'DownloadDeploymentAgent.ps1' before starting the agent configuration"
    }
    
    RemoveExistingAgent -patToken $patToken -configCmdPath $(GetConfigCmdPath)
    
    return $returnSuccess 
}
catch
{  
    WriteConfigurationLog $_.Exception
    throw $_.Exception
}