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

