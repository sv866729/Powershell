<#
Author: Samuel Valdez
Function: Revoke-SessionsForAllUsers

Description:
    Connects to Microsoft Graph and revokes the sign-in sessions for all users. This script retrieves all users and revokes their sign-in sessions using the `Revoke-MgUserSignInSession` command.

Usage:
    1. Ensure the Microsoft.Graph module is installed and connected.
    2. Run the function:
        Revoke-SessionsForAllUsers

Notes:
    - This function uses the Microsoft Graph PowerShell SDK to manage user sessions.
    - Revoking sign-in sessions will force users to sign in again, which can help in scenarios where you need to invalidate existing sessions.

#>

function Revoke-SessionsForAllUsers {
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
    Install-ModuleIfNeeded -ModuleName "Microsoft.Graph"
    # Connect to Microsoft Graph
    Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All"
    # Retrieve a list of all users
    $users = Get-MgUser

    # Loop through each user and revoke their sign-in session
    foreach ($user in $users) {
        try {
            # Revoke the sign-in session for the current user
            Revoke-MgUserSignInSession -UserId $user.Id
            Write-Output "Successfully revoked session for user: $($user.UserPrincipalName)"
        } catch {
            Write-Error "Failed to revoke session for user: $($user.UserPrincipalName). Error: $_"
        }
    }
}
