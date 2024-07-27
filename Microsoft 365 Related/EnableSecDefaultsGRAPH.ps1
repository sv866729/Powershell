<#
Author: Samuel Valdez

Description:
    This script installs the Microsoft.Graph.Identity.SignIns module, connects to Microsoft Graph with specific scopes, and ensures that Security Defaults are enabled. 
    If Security Defaults is not enabled, it will be enabled by the script. It handles authentication, checks the current status of Security Defaults, and reports any 
    errors encountered during the process. Finally, it disconnects from Microsoft Graph.
#>

# Install the required module
Install-Module Microsoft.Graph.Identity.SignIns -Scope CurrentUser -Force

# Connect to Microsoft Graph
try {
    Connect-MgGraph -Scopes Policy.ReadWrite.ConditionalAccess, Policy.Read.All
    Write-Host "Authentication Successful"
} catch {
    Write-Host "Error Authenticating"
    exit
}

# Check and enable Security Defaults
try {
    $status = Get-MgPolicyIdentitySecurityDefaultEnforcementPolicy | Select-Object -ExpandProperty IsEnabled
    Write-Host "Security Defaults status: $status"
    
    if ($status) {
        Write-Host "Security Defaults is already Enabled"
    } else {
        $params = @{
            IsEnabled = $true
        }
        Update-MgPolicyIdentitySecurityDefaultEnforcementPolicy -BodyParameter $params -ErrorAction Stop
        Write-Host "Security Defaults was disabled but has been Enabled"
    }
} catch {
    Write-Host "Error with Security Defaults: $($_.Exception.Message)"
    Disconnect-MgGraph
    Write-Host -ForegroundColor Red "ERROR"
    exit
    
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph