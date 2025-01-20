# Import the Active Directory module
Import-Module ActiveDirectory

# Define the function
function Update-ADUserPasswords {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$OutputFile = "C:\UpdatedUsersPasswords.csv", # Path to the CSV output file where updated user passwords will be logged.
        
        [Parameter()]
        [array]$ExcludedAccounts = @(), # Array of SAM account names to exclude from the update process. Defaults to an empty array, meaning no accounts are excluded.
    
        [Parameter()]
        [int]$WordCount = 4, # Number of words to include in the generated passphrase. Default is 3 for a total of 1 Quadrillion different combinations.
    
        [Parameter()]
        [bool]$ChangeAtNextLogin = $true, # Specifies whether to force users to change their password at their next login. Default is $true.
    
        [Parameter()]
        [bool]$EnforcePasswordExpiration = $true, # Specifies whether to enforce password expiration by setting 'PasswordNeverExpires' to $false. Default is $true.
    
        [Parameter()]
        [bool]$AllowPasswordChanges = $true # Specifies whether users are allowed to change their passwords by setting 'CannotChangePassword' to $false. Default is $true.
    )

    # Define the word list
    $WordList = @(
        "Oak","Pine","Maple","Birch","Ash","Elm","Cedar","Spruce","Fir","Hickory",
        "Cherry","Walnut","Teak","Mahogany","Poplar","Beech","Sycamore","Alder","Bamboo","Chestnut",
        "Willow","Basswood","Redwood","Ebony","Rosewood","Acacia","Juniper","Aspen","Hemlock","Cypress",
        "Pecan","Cottonwood","Laurel","Koa","Eucalyptus","Ironwood","Sandalwood","Boxwood","Larch","Sequoia",
        "Mulberry","Linden","Yew","Zebrawood","Magnolia","Padauk","Purpleheart","Kingwood","Tulipwood","Osage",
        "Orange","Wenge","Sapele","Iroko","Bubinga","GoncaloAlves","Ziricote","Tigerwood","Leopardwood","Camphorwood",
        "Manzanita","Blackwood","Katalox","Cocobolo","Snakewood","Angelim","Amaranth","Amboina","Anigre","Avodire",
        "Chechen","ChakteViga","Courbaril","Gidgee","Jatoba","Jarrah","Karri","Marblewood","Mopane","Muninga",
        "Okoume","Peroba","Ramin","Shedua","SilvertopAsh","Sugi","Tallowwood","TassieOak","Vitex","Whitewood"
    )

    # Function to generate passphrase
    function Generate-Passphrase ([array]$wordlist, [int]$wordcount) {
        $passphrase = ""
        for ($i = 1; $i -le $wordcount; $i++) {
            [int]$randomnumber = Get-Random -Minimum 0 -Maximum $wordlist.Length
            [string]$randomword = $wordlist[$randomnumber]
            [string]$randomnumber = Get-Random -Minimum 0 -Maximum 9
            $passphrase += [string]$randomword + $randomnumber + "-"
        }
        [string]$randomnumber = Get-Random -Minimum 0 -Maximum 1000
        $passphrase += $randomnumber
        return $passphrase.Trim("-")
    }

    # Create CSV file and write header if it doesn't exist
    if (-not (Test-Path $OutputFile)) {
        "SamAccountName,Name,Password,Enabled" | Out-File -FilePath $OutputFile -Encoding UTF8
    }

    # Get all AD users excluding the specified accounts
    $ADUsers = Get-ADUser -Filter * -Property SamAccountName, Name, Enabled | Where-Object {
        -not ($ExcludedAccounts -contains $_.SamAccountName)
    }

    # Loop through users and update properties
    foreach ($User in $ADUsers) {
        try {

            # Apply optional parameters based on user input
            if ($EnforcePasswordExpiration) {
                Set-ADUser $User.SamAccountName -PasswordNeverExpires $false
            }
            if ($AllowPasswordChanges) {
                Set-ADUser $User.SamAccountName -CannotChangePassword $false
            }
            if ($ChangeAtNextLogin) {
                Set-ADUser $User.SamAccountName -ChangePasswordAtLogon $true
            }

            # Generate a new password
            $NewPassword = Generate-Passphrase -wordlist $WordList -wordcount $WordCount

            # Reset the user's password
            Set-ADAccountPassword -Identity $User.SamAccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $NewPassword -Force)

            # Append user details to CSV
            "$($User.SamAccountName),$($User.Name),$NewPassword,$($User.Enabled)" | Out-File -FilePath $OutputFile -Append -Encoding UTF8

            Write-Host "Updated user: $($User.SamAccountName). New password logged." -ForegroundColor Green
        } catch {
            Write-Host "Failed to update user: $($User.SamAccountName). Error: $_" -ForegroundColor Red
            "$($User.SamAccountName),$($User.Name),'ERROR',$($User.Enabled)" | Out-File -FilePath $OutputFile -Append -Encoding UTF8
        }
    }

    Write-Host "All users updated and passwords logged to $OutputFile (SamAccountName, Name, Password, Enabled)." -ForegroundColor Cyan
}
