<#
Author: Samuel Valdez

Description:
    Connects to Microsoft Online Services and blocks credentials for all users.

Usage:
    1. Run the following commands sequentially:
        - connect-msolservice
        - $users = get-msoluser
        - forEach($user in $users){Set-MsolUser -UserPrincipalName $user.UserPrincipalName -BlockCredential $true}

Notes:
    - Ensure you have the necessary permissions to perform these actions.
    - This script assumes you are using the Microsoft Online Services PowerShell module.

#>
$adminaccount = "EnterADMINACCOUNT"


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

Install-ModuleIfNeeded -ModuleName "MSOnline"

connect-msolservice -ErrorAction Stop
$users = get-msoluser
forEach($user in $users){
    if($user.UserPrincipalName -ne $adminaccount){
        Set-MsolUser -UserPrincipalName $user.UserPrincipalName -BlockCredential $true
    }
}
$blockedUsers = Get-MsolUser | Where-Object { $_.BlockCredential -eq $true }

Write-Host "All Blocked Users" -ForegroundColor Cyan
Write-Host $blockedUsers

Disconnect-msolservice
