


####################################
# Determine if the device is  a DC #
####################################
function Determine-IfDeviceIsDC {
    param()
    
    # Import the Active Directory module if it's not already imported
    Import-Module ActiveDirectory -ErrorAction SilentlyContinue
    
    $currentServer = $env:COMPUTERNAME
    $dc = Get-ADDomainController -Filter { Name -eq $currentServer } -ErrorAction SilentlyContinue
    
    if ($dc) {
        Write-host "$currentServer is a domain controller." -ForegroundColor Green
        return $true
    } else {
        Write-host "$currentServer is not a domain controller." -ForegroundColor Red
        write-host "No action will be taken" -ForegroundColor Red
        return $false
    }
}
####################################

#####################
# Password Gernator #
#####################
$wordList = @(
    "apples", "banana", "cherry", "date", "eggs",
    "figs", "grapes", "honey", "kiwi", "lemon",
    "mango", "nectar", "orange", "peach", "quince",
    "rasp", "straw", "tanger", "ugli", "vanil",
    "water", "xigua", "yam", "zucchi",
    "berries", "cat", "dog", "elephant", "fox"
)

function GeneratePassphrase ([array]$wordlist, [int]$wordcount) {
    $passphrase = ""
    for ($i = 1; $i -le $wordcount; $i++){
        [int]$randomnumber = get-random -Minimum 0 -Maximum $wordlist.Length
        [string]$randomword = $wordlist[$randomnumber]
        [string]$randomnumber = get-random -Minimum 0 -Maximum 9
        $passphrase += [string]$randomword + $randomnumber + "-"
        
    }
    [string]$randomnumber = get-random -Minimum 0 -Maximum 1000
    $passphrase += $randomnumber
    return $passphrase.Trim()
}
#####################

#####################
# Copy On Prem User #
#####################
function Copy-DCUser {
    param(
        [Parameter(Mandatory=$true)]
        [string]$newUsername,
        [Parameter(Mandatory=$true)]
        [string]$newFirstname,
        [Parameter(Mandatory=$true)]
        [string]$newLastname,
        [Parameter(Mandatory=$true)]
        [string]$copyUsername
    )
    
    try {
        # Retrieve groups that the user is a member of
        $groups = Get-ADGroupMember -Identity $copyUsername -ErrorAction Stop
        
        # Retrieve the user object to copy
        $copiedUser = Get-ADUser -Identity $copyUsername -Properties DistinguishedName,UserPrincipalName -ErrorAction Stop
        
        # Extract the OU path from the copied user's DistinguishedName
        $OU = ($copiedUser.DistinguishedName -split ",", 2)[1]
        
        # Extract the domain name from the copied user's UserPrincipalName
        $domainName = $copiedUser.UserPrincipalName.Split('@')[1]
        
        # Generate a secure password (replace GeneratePassphrase with your own function)
        $password = GeneratePassphrase($wordList,4)
        
        # Create new user in the same OU
        $newUser = New-ADUser `
            -SamAccountName $newUsername `
            -UserPrincipalName "$newUsername@$domainName" `
            -Name "$newFirstname $newLastname" `
            -GivenName $newFirstname `
            -Surname $newLastname `
            -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force) `
            -Enabled $true `
            -Path "OU=$OU" `
            -PassThru -ErrorAction Stop
        
        Write-Output "New user $newUsername created in OU: $OU."
        
        # Add the new user to the same groups as the copied user
        foreach ($group in $groups) {
            Add-ADGroupMember -Identity $group -Members $newUser -ErrorAction Stop
            Write-Output "Added $newUsername to group $($group.Name)."
        }
        
        Write-Output "User creation and group membership update completed successfully."
        
    } catch {
        Write-Output "Error occurred: $_"
        throw $_  # Re-throw the error to propagate it further if needed
    }
}
#####################


##################
# Copy M365 User # 
##################
function Copy-M365UserWithGroups {
    param(
        [Parameter(Mandatory=$true)]
        [string]$newUserUPN,
        [Parameter(Mandatory=$true)]
        [string]$newUserDisplayName,
        [Parameter(Mandatory=$true)]
        [string]$copyUserUPN
    )
    Install-Module -Name Microsoft.Graph.Users -ErrorAction SilentlyContinue
    Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All"

    try {
        # Retrieve the existing user details
        $existingUser = Get-MgUser -UserPrincipalName $copyUserUPN -ErrorAction Stop
        
        # Generate a secure password (replace GeneratePassphrase with your own function)
        $password = GeneratePassphrase($wordList,4)
        
        # Create the new user
        $newUser = New-MgUser -UserPrincipalName $newUserUPN -DisplayName $newUserDisplayName `
                   -PasswordProfile @{ Password = $password; ForceChangePasswordNextSignIn = $false } `
                   -ErrorAction Stop
        
        Write-Output "New user $($newUser.UserPrincipalName) created successfully."
        
        # Copy user's group memberships
        $userGroups = Get-MgUserMemberOf -UserId $existingUser.Id -ErrorAction Stop
        
        foreach ($group in $userGroups) {
            Add-MgGroupMember -GroupId $group.Id -Members $newUser.Id -ErrorAction Stop
            Write-Output "Added $($newUser.UserPrincipalName) to group $($group.DisplayName)."
        }
        
        Write-Output "User creation and group membership update completed successfully."
        
    } catch {
        Write-Output "Error occurred: $_"
        throw $_  # Re-throw the error to propagate it further if needed
    }
    Disconnect-MgGraph
}
##################



########## Checking if Azure AD is installed
function Check-FolderWithAzureAD {
    param (
        [string]$FolderPath= "C:\Program Files\"
    )

    # Get all directories in the specified folder
    $folders = Get-ChildItem -Path $FolderPath -Directory

    # Check if any folder contains "Azure AD" in its name
    foreach ($folder in $folders) {
        if ($folder.Name -match "Azure AD") {
            return $true
        }
    }
    return $false
}



# Export your functions to make them available for import
Export-ModuleMember -Function *