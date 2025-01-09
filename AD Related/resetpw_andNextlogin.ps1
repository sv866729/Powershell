# Import the Active Directory module
Import-Module ActiveDirectory

# Define the accounts to exclude
$ExcludedAccounts = @(
#sam account names in a list
)

# Define the word list
$WordList = @(
"apple", "banana", "cherry", "date", "elderberry", "fig", "grape", "honeydew", "kiwi", "lemon",
"mango", "nectarine", "orange", "papaya", "quince", "raspberry", "strawberry", "tangerine", "ugli", "watermelon",
"apricot", "blueberry", "cantaloupe", "durian", "guava", "lychee", "mulberry", "peach", "pear", "pineapple",
"plum", "pomegranate", "currant", "blackcurrant", "gooseberry", "cranberry", "coconut", "persimmon", "avocado", "blackberry",
"clementine", "grapefruit", "lime", "melon", "kumquat", "blood orange", "sapodilla", "starfruit", "dragonfruit", "rambutan",
"jackfruit", "cherimoya", "jujube", "passionfruit", "cactus pear", "soursop", "langsat", "olive", "tamarind", "bilberry",
"loquat", "medlar", "salak", "boysenberry", "dewberry", "elderflower", "feijoa", "genip", "huckleberry", "indian fig",
"jabuticaba", "kiwano", "lucuma", "mamoncillo", "naranjilla", "orangelo", "physalis", "quenepa", "rambai", "salmonberry",
"santol", "tangelo", "umbu", "voavanga", "wax apple", "ximenia", "yellow passionfruit", "zinfandel grape", "ackee", "bignay",
"cempedak", "dabai", "eggnog plant", "fairchild tangerine", "grumichama", "horned melon", "ilama", "jatoba", "kousa dogwood", "lucuma"
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

# Output CSV file path
$OutputFile = "C:\UpdatedUsersPasswords.csv"

# Create CSV file and write header
if (-not (Test-Path $OutputFile)) {
    "SamAccountName,NewPassword" | Out-File -FilePath $OutputFile -Encoding UTF8
}

# Get all AD users excluding the specified accounts
$ADUsers = Get-ADUser -Filter * -Property SamAccountName | Where-Object {
    -not ($ExcludedAccounts -contains $_.SamAccountName)
}

# Loop through users and update properties
foreach ($User in $ADUsers) {
    try {
        # Generate a new password
        $NewPassword = Generate-Passphrase -wordlist $WordList -wordcount 3

        # Reset the user's password
        Set-ADAccountPassword -Identity $User.SamAccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $NewPassword -Force)

        # Set PasswordNeverExpires to false
        Set-ADUser $User.SamAccountName -PasswordNeverExpires $false

        # Set UserCannotChangePassword to false
        Set-ADUser $User.SamAccountName -CannotChangePassword $false

        # Force the user to change their password at next login
        Set-ADUser $User.SamAccountName -ChangePasswordAtLogon $true

        # Append user and new password to CSV
        "$($User.SamAccountName),$NewPassword" | Out-File -FilePath $OutputFile -Append -Encoding UTF8

        Write-Host "Updated user: $($User.SamAccountName). New password logged." -ForegroundColor Green
    } catch {
        Write-Host "Failed to update user: $($User.SamAccountName). Error: $_" -ForegroundColor Red
    }
}

Write-Host "All users updated and passwords logged to $OutputFile (excluding specified accounts)." -ForegroundColor Cyan
