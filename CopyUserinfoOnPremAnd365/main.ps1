

# import funtions
# Import the module containing your functions
Import-Module -Name ".\Copy-User.psm1" -Force

if (Determine-IfDeviceIsDC){
    # Prompt user for input for DC
    $newUsername = Read-Host "Enter the username for the new user"
    $newFirstname = Read-Host "Enter the first name for the new user"
    $newLastname = Read-Host "Enter the last name for the new user"
    $copyUsername = Read-Host "Enter the username of the existing user to copy"
    if(Check-FolderWithAzureAD){
         Copy-DCUser -newUsername $newUsername -newFirstname $newFirstname -newLastname $newLastname -copyUsername $copyUsername
    }
    else(
        $newUserUPN = Read-Host "Enter the UPN for the new user (e.g., john.smith@contoso.com)"
        $newUserDisplayName = Read-Host "Enter the display name for the new user"
        $copyUserUPN = Read-Host "Enter the UPN of the existing user to copy"
        Copy-M365UserWithGroups -newUserUPN $newUserUPN -newUserDisplayName $newUserDisplayName -copyUserUPN $copyUserUPN
        Copy-DCUser -newUsername $newUsername -newFirstname $newFirstname -newLastname $newLastname -copyUsername $copyUsername

    )

}
else(
    # Ending program
    Exit-PSHostProcess
)
