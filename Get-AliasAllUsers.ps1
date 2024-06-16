<#
Author: Samuel Valdez
Used to get all Ad users and the proxyaddress

Usage:
    1. Run the funtion 
    2. Get-AliasAllUsers -ou "OU=Users,DC=example,DC=com"

#>
function Get-AliasAllUsers {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ou
    )
 
    # Import the Active Directory module
    Import-Module ActiveDirectory

    # Get all user objects
    $allADUsers = Get-ADUser -Filter * -SearchBase $ou -Property samAccountName, proxyAddresses
 
    return $allADUsers
}
