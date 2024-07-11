<#
# Determine if the device is a Domain Controller (DC)
if determine_if_device_is_DC():
    # Determine if the device is Entra connected
    if determine_if_device_is_Entra_connected():
        # Copy DC user
        copy_DC_user()
        # Compare DC users
        compare_users_DC()
        # Compare 365 users
        compare_users_365()
    else:
        # Copy DC user
        copy_DC_user()
        # Copy 365 user
        copy_365_user()
        # Compare DC users
        compare_users_DC()
        # Compare 365 users
        compare_users_365()
    # Output results
    output_results()
else:
    # Throw error for local user
    throw_error("Local user detected")
    # Output results
    output_results()
#>


function Determine-IfDeviceIsDC {
    param()
    
    # Import the Active Directory module if it's not already imported
    Import-Module ActiveDirectory -ErrorAction SilentlyContinue
    
    $currentServer = $env:COMPUTERNAME
    $dc = Get-ADDomainController -Filter { Name -eq $currentServer } -ErrorAction SilentlyContinue
    
    if ($dc) {
        Write-Output "$currentServer is a domain controller." 
        return $true
    } else {
        Write-Output "$currentServer is not a domain controller."
        return $false
    }
}


function copy-DCuser{
    param(
        [Parameter(Mandatory=$true)]
        [string]
    )
}


