param ([String]$patToken,
        [string]$devopsUrl,
        [string]$agentPool,
        [string]$agentName)

mkdir c:\agent ; 
Set-Location c:\agent

$ProgressPreference = "SilentlyContinue"
# Invoke-WebRequest "https://vstsagentpackage.azureedge.net/agent/2.165.0/vsts-agent-win-x64-2.165.0.zip" -OutFile "c:\agent\vsts-agent-win-x64-2.165.0.zip"
$AZP_AGENT_VERSION = ((Invoke-WebRequest https://api.github.com/repos/Microsoft/azure-pipelines-agent/releases/latest | ConvertFrom-Json)[0].tag_name).Substring(1)

Invoke-WebRequest https://vstsagentpackage.azureedge.net/agent/$AZP_AGENT_VERSION/vsts-agent-win-x64-$AZP_AGENT_VERSION.zip -OutFile "c:\agent\vsts-agent-win-x64-$AZP_AGENT_VERSION.zip"

Add-Type -AssemblyName System.IO.Compression.FileSystem ; 

[System.IO.Compression.ZipFile]::ExtractToDirectory("c:\agent\vsts-agent-win-x64-$AZP_AGENT_VERSION.zip", "$PWD")

# &"c:\agent\config.cmd" --unattended --url $devopsUrl --auth pat --token $patToken --pool $agentPool --agent $agentName --runAsService
&"c:\agent\config.cmd" --unattended --url $devopsUrl --auth pat --token $patToken --pool $agentPool --runAsService

# powershell.exe -ExecutionPolicy Unrestricted -File $PSScriptRoot\Initialize-VM.ps1
# powershell.exe -ExecutionPolicy Unrestricted -File $PSScriptRoot\Install-VS2019.ps1