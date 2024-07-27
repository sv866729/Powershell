<#
Author: Samuel Valdez
Function: Reset-MFAForAllUsers

Description:
    Connects to Microsoft Online Services and resets the Multi-Factor Authentication (MFA) options for all users in Microsoft 365. This script retrieves all users and resets their MFA settings using `Reset-MsolStrongAuthenticationMethodByUpn`.

Usage:
    1. Ensure the MSOnline module is installed.
    2. Run the function:
        Reset-MFAForAllUsers

Notes:
    - This function uses the `MSOnline` module to manage MFA settings.
    - It will reset the MFA settings for every user, which may require re-enrollment in MFA.
    - Make sure to have appropriate permissions to perform this action.

#>

function Reset-MFAForAllUsers {
    
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

    # Install the MSOnline module if needed
    Install-ModuleIfNeeded -ModuleName "MSOnline"
    # Connect to Microsoft Online Services
    Connect-MsolService

    # Retrieve a list of all users
    $users = Get-MsolUser

    # Loop through each user and reset MFA settings
    foreach ($user in $users) {
        try {
            # Reset the MFA settings for the current user
            Reset-MsolStrongAuthenticationMethodByUpn -UserPrincipalName $user.UserPrincipalName
            Write-Output "Successfully reset MFA for user: $($user.UserPrincipalName)"
        } catch {
            Write-Error "Failed to reset MFA for user: $($user.UserPrincipalName). Error: $_"
        }
    }
}
