<#
Author: Samuel Valdez
Function: Reset-UserPasswords

Description:
    Connects to Microsoft Online Services, retrieves a list of all users, and resets the passwords for all users except the specified admin account. Generates random passwords and exports the list of users with their new passwords to a CSV file at the specified location.

Usage:
    1. Ensure the MSOnline module is installed.
    2. Run the function with the admin account to exclude and optionally specify a file path:
        Reset-UserPasswords -AdminAccount "admin@example.com" -FilePath "C:\Path\To\Save\passwordlist.csv"

Parameters:
    - AdminAccount (mandatory): The user principal name of the admin account to exclude from password reset.
    - FilePath (optional): The path where the CSV file with user passwords will be saved. Default is the current directory.

Notes:
    - This function uses the `MSOnline` module to manage user accounts.
    - The function will prompt for confirmation before resetting passwords.
    - The generated passwords will be 12 characters long and include a mix of letters, numbers, and special characters.

#>

function Reset-M365UserPasswords {
    param (
        [Parameter(Mandatory = $true)]
        [string]$AdminAccount,
        
        [string]$FilePath = ".\passwordlist.csv"
    )

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
    connect-msolservice -ErrorAction Stop

    # Retrieve a list of all users
    $users = Get-MsolUser

    # Function to generate a random password
    function GeneratePassword {
        $length = 12
        $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()'
        -join ((Get-Random -Count $length -InputObject $chars.ToCharArray()) -join '')
    }

    # List to hold the user data with generated passwords
    $passwordobjectlist = @()

    # WARNING
    Write-Host -ForegroundColor Yellow -BackgroundColor Gray "!!!PRESS ENTER TO RESET PASSWORDS or Ctrl + C TO STOP!!!"
    Read-Host "Press Enter to continue..."

    # Loop through each user and generate a password, excluding the admin account
    foreach ($user in $users) {
        if ($user.UserPrincipalName -ne $AdminAccount) {
            Write-Host -ForegroundColor DarkGreen -BackgroundColor DarkGray "$($user.UserPrincipalName) password was reset"
            $password = GeneratePassword
            $passwordobjectlist += [PSCustomObject]@{
                UserPrincipalName = $user.UserPrincipalName
                Password = $password
            }
            # Set the new password for the user
            Set-MsolUserPassword -ObjectId $user.ObjectId -NewPassword $password -ForceChangePassword $true
        }
    }

    # Export the password list to a CSV file
    $passwordobjectlist | Export-Csv -Path $FilePath -NoTypeInformation

    Write-Host "Password reset complete. Passwords are saved in $FilePath" -ForegroundColor Green
}
