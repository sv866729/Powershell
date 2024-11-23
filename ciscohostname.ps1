<#
Author: Samuel Valdez
Function: Install-ModuleIfNeeded

Description:
    Checks if a PowerShell module is installed and installs it if not already present.

Usage:
    1. Run the function:
        Install-ModuleIfNeeded -ModuleName "ModuleName"
    2. Specify the name of the module to check and install if necessary.

Parameters:
    - ModuleName (mandatory): The name of the PowerShell module to check and install if needed.

#>
function Install-ModuleIfNeeded {
    param (
        [string]$ModuleName
    )
    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        try {
            Install-Module -Name $ModuleName -Scope CurrentUser -Force
            Write-Host "Module $ModuleName installed successfully." -ForegroundColor Green
        } catch {
            Write-Host "Failed to install module $ModuleName. Error: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Module $ModuleName is already installed." -ForegroundColor Yellow
    }
}




# Script to get Device information for Cisco

# Install powershell
Install-ModuleIfNeeded -ModuleName POSH-SSH -Force

$hostlist = @("192.168.1.1", "192.168.1.2")  # Example of IPs or hostnames
$creds = Get-Credential  # Prompt for credentials (username and password)
$results = @()  

# Iterate through the list of hosts
foreach ($hosts in $hostlist) {
    $password = $creds.GetNetworkCredential().Password
    # Create the SSH session, passing the username and password
    try{
        $session = New-SSHSession -Host $hosts -credentials $creds -AcceptKey -Force
        # Going into enable mode
        Invoke-SSHCommand -SSHSession $session -Command "en" > $null
        Invoke-SSHCommand -SSHSession $session -Command $password > $null
        # Getting verison to array
        $output = Invoke-SSHCommand -SSHSession $session -Command "show version"
        $results += [PSCustomObject]@{
            Host = $output.Host
            Output = $output.output
            ExitStatus = if ($output.ExitStatus -eq 0) { "CommandExecutedSuccessfully" } else { "CommandFailed" }
        }


        # Optionally, close the session after completion
        Remove-SSHSession -SSHSession $session }
    catch{
        "Error-Host: $hosts "
        }
}

$results | export-csv  ".\show_versions.csv" -NoTypeInformation

