


<#
Author: Samuel Valdez
This funtion will get all the users and set a new alias based on the on specified.

Usage:
    1. Run the funtion
    2. Set-NewAliasAllUsers -domain "domain.com" -ou "OU=Users,DC=example,DC=com"
#>

 
function Set-NewAliasAllUsers {
    param(
        [Parameter(Mandatory=$true)]
        [string]$domain, #This will be the alias domain
        [Parameter(Mandatory=$true)]
        [string]$ou
    )
 
    # Import the Active Directory module
    Import-Module ActiveDirectory

    # Get all user objects
    $allADUsers = Get-ADUser -Filter * -SearchBase $ou -Property samAccountName, proxyAddresses
 
    foreach ($user in $allADUsers) {
        $username = $user.samAccountName
        $newAlias = "smtp:" + $username + "@" + $domain

        # Add the new alias to the proxyAddresses attribute
        Set-ADUser -Identity $user -Add @{proxyAddresses = $newAlias}
    }
}


