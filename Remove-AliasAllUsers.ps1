<#T
Author: Samuel Valdez
This funtion will get all the users and remove a alias based on the on specified domain.

Usage:
    1. Run the funtion
    2. Remove-AliasAllUsers -domain "domain.com" -ou "OU=Users,DC=example,DC=com"

Note run this first to load the funtion. The you would perfrom the usage.

#>

 
function Remove-AliasAllUsers {
    param(
        [Parameter(Mandatory=$true)]
        [string]$domain, #This will be the alias domain,
        [Parameter(Mandatory=$true)]
        [string]$ou
    )
 
    # Import the Active Directory module
    Import-Module ActiveDirectory

    # Get all user objects
    $allADUsers = Get-ADUser -Filter * -SearchBase $ou -Property samAccountName, proxyAddresses
 
    foreach ($user in $allADUsers) {
        $username = $user.samAccountName
        $aliasToRemove = "smtp:" + $username + "@" + $domain

        # Check if the alias exists
        if ($user.proxyAddresses -contains $aliasToRemove) {
            # Remove the alias from the proxyAddresses attribute
            Set-ADUser -Identity $user -Remove @{proxyAddresses = $aliasToRemove}
        }
    }
}
