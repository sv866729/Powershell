# Import the Active Directory module
Import-Module ActiveDirectory

# Define the accounts to exclude
$ExcludedAccounts = @(
    "FakeAdmin1",
    "FakeAdmin2",
    "TestAdmin3",
    "TestUser1",
    "DemoUser2",
    "MockUser123",
    "SampleAdmin",
    "ExampleAccount",
    "TrialUser",
    "Placeholder",
    "ExampleSync"
)

# Get all AD users excluding the specified accounts
$ADUsers = Get-ADUser -Filter * -Property SamAccountName | Where-Object {
    -not ($ExcludedAccounts -contains $_.SamAccountName)
}

# Loop through users and update properties
foreach ($User in $ADUsers) {
    try {

        # Set PasswordNeverExpires to false
        Set-ADUser $User.SamAccountName -PasswordNeverExpires $false

        # Set UserCannotChangePassword to false
        Set-ADUser $User.SamAccountName -CannotChangePassword $false
        
        # Set PasswordLastSet to 0 (forces password change at next login)
        Set-ADUser $User.SamAccountName -ChangePasswordAtLogon $true


        
        Write-Host "Updated user: $($User.SamAccountName)" -ForegroundColor Green
    } catch {
        Write-Host "Failed to update user: $($User.SamAccountName). Error: $_" -ForegroundColor Red
    }
}

Write-Host "All users updated (excluding specified accounts)."
