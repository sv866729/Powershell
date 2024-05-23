# This script is to be used in a setup to generate random passwords. It can also be used in the event of something happening.
# not this script has no mercu and once runned cant be undone use with caution !!!!!
# Use case is for m365 
# Connect to Microsoft Online Service
Connect-MsolService

# Retrieve a list of all users
$users = Get-MsolUser

# Define the admin account to exclude
$adminaccount = read-host -Prompt "Enter in the admin account to not reset"

# Function to generate a random password
function GeneratePassword {
    $length = 12
    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()'
    -join ((Get-Random -Count $length -InputObject $chars.ToCharArray()) -join '')
}

# List to hold the user data with generated passwords
$passwordobjectlist = @()
#WARNING
Write-Host -ForegroundColor Yellow -BackgroundColor Gray "!!!PRESS ENTER TO RESET PASSWORDS or Ctrl + C TO STOP!!!"
# Loop through each user and generate a password, excluding the admin account
foreach ($user in $users) {
    if ($user.UserPrincipalName -ne $adminaccount) {
        Write-Host -ForegroundColor DarkGreen -BackgroundColor DarkGray "$user.UserPrincipalName password was reset"
        $password = GeneratePassword
        $passwordobjectlist += [PSCustomObject]@{
            UserPrincipalName = $user.UserPrincipalName
            Password = $password
        
        }
        # Set the new password for the user
        Set-MsolUserPassword -ObjectId $user.ObjectId -NewPassword $password -ForceChangePassword $true
    }
}
$passwordobjectlist | Export-Csv -Path ".\passwordlist.csv"