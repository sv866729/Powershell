# Import the Active Directory module
Import-Module ActiveDirectory

# Get a list of all users with the specified attributes
Get-ADUser -Filter * -Property SamAccountName, Name, EmailAddress, Enabled | 
Select-Object SamAccountName, Name, EmailAddress, Enabled |
Export-Csv -Path "ADUsers.csv" -NoTypeInformation -Encoding UTF8

Write-Host "The list has been exported to ADUsers.csv"
