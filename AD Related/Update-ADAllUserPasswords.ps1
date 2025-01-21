# Import the Active Directory module
Import-Module ActiveDirectory

# Define the function to update AD user passwords
function Update-ADAllUserPasswords {
    [CmdletBinding()]
    param (
        # Path to the CSV output file where updated user passwords will be logged.
        [Parameter()]
        [string]$OutputFile = "C:\UpdatedUsersPasswords.csv",

        # Array of SAM account names to exclude from the update process.
        [Parameter()]
        [array]$ExcludedAccounts = @(),

        # Number of words to include in the generated passphrase.
        [Parameter()]
        [int]$WordCount = 4,

        # Switch to force users to change their password at next login.
        [Parameter()]
        [switch]$ChangeAtNextLogin,

        # Switch to enforce password expiration.
        [Parameter()]
        [switch]$EnforcePasswordExpiration,

        # Switch to allow users to change their password.
        [Parameter()]
        [switch]$AllowPasswordChanges,

        # Enable verbose logging for detailed processing information.
        [Parameter()]
        [switch]$v,

        # Display help message.
        [Parameter()]
        [switch]$h,

        # Test mode switch to simulate actions without performing them.
        [Parameter()]
        [switch]$t
    )

    # Display help if -h is passed
    if ($h) {
        $helpMessage = @"
Usage: 
1. Run script without option to load funtion
2. Update-ADAllUserPasswords [options]

Options:
-h                        Display this help message.
-OutputFile <path>         Path to the CSV output file where updated user passwords will be logged. Default is 'C:\UpdatedUsersPasswords.csv'.
-ExcludedAccounts          Array of SAM account names to exclude from the update process. Default is an empty array.
-WordCount <int>           Number of words to include in the generated passphrase. Default is 4.
-ChangeAtNextLogin        Forces users to change their password at next login. Default is $false.
-EnforcePasswordExpiration  Enforces password expiration by setting 'PasswordNeverExpires' to $false. Default is $false.
-AllowPasswordChanges     Allows users to change their passwords by setting 'CannotChangePassword' to $false. Default is $false.
-v                        Enables verbose output logging. Default is $false.
-t                        Test mode. Disables actual changes to user accounts. Only logs intended actions.

Example:
Update-ADAllUserPasswords -ChangeAtNextLogin -EnforcePasswordExpiration -AllowPasswordChanges -OutputFile 'C:\Logs\UpdatedPasswords.csv' -ExcludedAccounts @('user1', 'user2') -WordCount 5 -v -t
"@
        Write-Host $helpMessage
        return
    }

    # Word list for passphrase generation
    $WordList = @(
        "Oak", "Pine", "Maple", "Birch", "Ash", "Elm", "Cedar", "Spruce", "Fir", "Hickory",
        "Cherry", "Walnut", "Teak", "Mahogany", "Poplar", "Beech", "Sycamore", "Alder", "Bamboo", "Chestnut",
        "Willow", "Basswood", "Redwood", "Ebony", "Rosewood", "Acacia", "Juniper", "Aspen", "Hemlock", "Cypress",
        "Pecan", "Cottonwood", "Laurel", "Koa", "Eucalyptus", "Ironwood", "Sandalwood", "Boxwood", "Larch", "Sequoia",
        "Basil", "Oregano", "Mint", "Rosemary", "Thyme", "Sage", "Lavender", "Parsley", "Chamomile", "Dill",
        "Cilantro", "Tarragon", "Fennel", "Lemongrass", "Bay", "Chives", "Marjoram", "Echinacea", "Catnip", "Yarrow",
        "Feverfew", "LemonBalm", "LemonVerbena", "Comfrey", "Ginseng", "Valerian", "StJohnsWort", "Borage", "Angelica", "Horehound",
        "HolyBasil", "Lavandin", "Calendula", "GotuKola", "Ashwagandha", "Mullein", "RedClover", "Cabbage", "Elderberry", "Ginger",
        "Turmeric", "BlackCumin", "ChiliPepper", "Cumin", "Nutmeg", "Clove", "Cardamom", "Anise", "Allspice", "Ginseng",
        "Peppermint", "Spearmint", "Basil", "LemonGrass", "BitterMelon", "Burdock", "Chili", "Horseradish", "Curry", "Mustard",
        "Cranberry", "JuniperBerry", "Juniper", "Licorice", "Oregano", "Dandelion", "Rosehip", "Chicory", "WildGarlic", "GojiBerry",
        "Nettle", "Psyllium", "Pepper", "Cayenne", "SweetCicely", "Cranberry", "AloeVera", "Mulberry", "ChasteTree", "Elderflower",
        "YellowDock", "Schisandra", "Reishi", "Cordyceps", "Maitake", "Shiitake", "TurkeyTail", "LionsMane", "Chaga", "Chlorella"
    )

    # Function to generate a passphrase
    function Generate-Passphrase ([array]$wordlist, [int]$wordcount) {
        $passphrase = ""
        for ($i = 1; $i -le $wordcount; $i++) {
            [int]$randomnumber = Get-Random -Minimum 0 -Maximum $wordlist.Length
            [string]$randomword = $wordlist[$randomnumber]
            $passphrase += "$randomword$(Get-Random -Minimum 0 -Maximum 9)-"
        }
        $passphrase += (Get-Random -Minimum 0 -Maximum 1000)
        return $passphrase.Trim("-")
    }

    # Initialize the CSV file if it doesn't exist
    if (-not (Test-Path $OutputFile)) {
        "SamAccountName,Name,Password,Enabled,DistinguishedName" | Out-File -FilePath $OutputFile -Encoding UTF8
        if ($v) {
            Write-Host "CSV header written to $OutputFile." -ForegroundColor Green
        }
    }

    # Get all Active Directory users, excluding specified accounts
    $ADUsers = Get-ADUser -Filter * -Property SamAccountName, Name, Enabled, DistinguishedName | Where-Object {
        -not ($ExcludedAccounts -contains $_.SamAccountName)
    }

    if ($v) {
        Write-Host "Retrieved $($ADUsers.Count) users from Active Directory." -ForegroundColor Yellow
        Write-Host "Excluded accounts: $($ExcludedAccounts -join ', ')" -ForegroundColor Yellow
    }

    # Loop through each user to update properties or simulate actions in test mode
    foreach ($User in $ADUsers) {
        try {
            if ($v) {
                Write-Host "Processing user: $($User.SamAccountName)" -ForegroundColor Cyan
            }

            # Test Mode: Simulate changes without actually applying them
            if ($t) {
                if ($EnforcePasswordExpiration) {
                    Write-Host "[TEST MODE] Would enforce password expiration for user: $($User.SamAccountName)." -ForegroundColor DarkYellow
                }
                if ($AllowPasswordChanges) {
                    Write-Host "[TEST MODE] Would allow password changes for user: $($User.SamAccountName)." -ForegroundColor DarkYellow
                }
                if ($ChangeAtNextLogin) {
                    Write-Host "[TEST MODE] Would force password change at next login for user: $($User.SamAccountName)." -ForegroundColor DarkYellow
                }
                Write-Host "[TEST MODE] Would reset the password for user: $($User.SamAccountName)." -ForegroundColor DarkYellow

                # Use 'test' as the password in test mode
                $TestPassword = "test"

                # Log test user details to CSV
                "$($User.SamAccountName),$($User.Name),$TestPassword,$($User.Enabled),$($User.DistinguishedName -replace ',', ';')" |
                    Out-File -FilePath $OutputFile -Append -Encoding UTF8

                if ($v) {
                    Write-Host "Logged user $($User.SamAccountName) details with 'test' password to $OutputFile." -ForegroundColor Green
                }

            } else {
                # Apply actual changes if not in test mode
                if ($EnforcePasswordExpiration) {
                    Set-ADUser $User.SamAccountName -PasswordNeverExpires $false
                    if ($v) {
                        Write-Host "Enforcing password expiration for $($User.SamAccountName)." -ForegroundColor Cyan
                    }
                }
                if ($AllowPasswordChanges) {
                    Set-ADUser $User.SamAccountName -CannotChangePassword $false
                    if ($v) {
                        Write-Host "Allowing password changes for $($User.SamAccountName)." -ForegroundColor Cyan
                    }
                }
                if ($ChangeAtNextLogin) {
                    Set-ADUser $User.SamAccountName -ChangePasswordAtLogon $true
                    if ($v) {
                        Write-Host "Forcing password change at next login for $($User.SamAccountName)." -ForegroundColor Cyan
                    }
                }

                # Generate a new password
                $NewPassword = Generate-Passphrase -wordlist $WordList -wordcount $WordCount
                if ($v) {
                    Write-Host "Generated new password for $($User.SamAccountName)." -ForegroundColor Cyan
                }

                # Reset the user's password
                Set-ADAccountPassword -Identity $User.SamAccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $NewPassword -Force)
                if ($v) {
                    Write-Host "Password reset for $($User.SamAccountName)." -ForegroundColor Cyan
                }

                # Log user details with new password to CSV
                "$($User.SamAccountName),$($User.Name),$NewPassword,$($User.Enabled),$($User.DistinguishedName -replace ',', ';')" |
                    Out-File -FilePath $OutputFile -Append -Encoding UTF8

                if ($v) {
                    Write-Host "Logged user $($User.SamAccountName) details with new password to $OutputFile." -ForegroundColor Green
                }
            }
        } catch {
            Write-Host "Failed to update user: $($User.SamAccountName). Error: $_" -ForegroundColor Red
            "$($User.SamAccountName),$($User.Name),'ERROR',$($User.Enabled),$($User.DistinguishedName -replace ',', ';')" |
                Out-File -FilePath $OutputFile -Append -Encoding UTF8
            if ($v) {
                Write-Host "Error logging details for user: $($User.SamAccountName)." -ForegroundColor Red
            }
        }
    }

    # Log excluded users
    foreach ($Excluded in $ExcludedAccounts) {
        # Try to get the excluded user from AD
        $User = Get-ADUser -Filter { SamAccountName -eq $Excluded } -Property SamAccountName, Name, Enabled, DistinguishedName
        if ($null -ne $User) {
            # Log the found excluded user to CSV
            "$($User.SamAccountName),$($User.Name),'EXCLUDED',$($User.Enabled),$($User.DistinguishedName -replace ',', ';')" |
                Out-File -FilePath $OutputFile -Append -Encoding UTF8
            if ($v) {
                Write-Host "Excluded user: $($User.SamAccountName) logged as EXCLUDED." -ForegroundColor Blue
            }
        }
    }
}
