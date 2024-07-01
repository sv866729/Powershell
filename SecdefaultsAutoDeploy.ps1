#########################
# Connecting to Mggraph #
#########################

# Validate if a module has been installed and install if it hasnt
function Install-ModuleIfNeeded {
    param (
        [string]$ModuleName
    )
    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        try {
            Install-Module -Name $ModuleName -Scope CurrentUser -Force
            Write-Host "Module $ModuleName installed successfully." -ForegroundColor Green
        } catch {
            Write-Host "Failed to install module $ModuleName. Error: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Module $ModuleName is already installed." -ForegroundColor Yellow
    }
}


# Installing modules
Install-ModuleIfNeeded -ModuleName "Microsoft.Graph.Identity.DirectoryManagement"
Install-ModuleIfNeeded -ModuleName "Microsoft.Graph.Users"
Install-ModuleIfNeeded -ModuleName "Microsoft.Graph.Users.Actions"
Install-ModuleIfNeeded -ModuleName "Microsoft.Graph.Identity.SignIns"

# Connecting with permissions needed
try {
    Connect-MgGraph -Scopes Directory.Read.All, Directory.ReadWrite.All, RoleManagement.Read.Directory, `
                    RoleManagement.ReadWrite.Directory, User.ReadWrite.All, `
                    User.RevokeSessions.All , Policy.ReadWrite.ConditionalAccess, Policy.Read.All
    Write-Host "Connected to Microsoft Graph successfully." -ForegroundColor Green
} catch {
    Write-Host "Failed to connect to Microsoft Graph. Error: $_" -ForegroundColor Red
    exit
}


#######################################
# Attempt to enable security defaults #
#######################################
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

##########################
# Enforcing all user mFA #
##########################

# Retrieve all users
$users = Get-MgUser

$countmfa = 0
# Loop through each user
foreach ($user in $users) {
    # Set the API endpoint URL for the current user
    $url = "https://graph.microsoft.com/beta/users/$($user.Id)/authentication/requirements"

    # Define the headers for the request
    $headers = @{
        "Content-Type" = "application/json"
    }

    # Define the body of the request
    $body = @{
        "perUserMfaState" = "enforced"
    } | ConvertTo-Json

    # Try to send the PATCH request and handle any errors
    try {
        # Send the PATCH request
        Invoke-MgGraphRequest -Method PATCH -Uri $url -Headers $headers -Body $body

        # Output success message
        Write-Output "Successfully enforced MFA for user: $($user.UserPrincipalName)"
        $countmfa++
    }
    catch {
        # Output error message
        Write-Error "Failed to enforce MFA for user: $($user.UserPrincipalName). Error: $_"
    }
}
# Output
Write-Host "Total users: $($users.Count)"
Write-Host "Total user MFA's Enforced: $countmfa"

##############################
# revoking all user sessions #
##############################

# Initialize a counter for revoked sessions
$countrs = 0

# Loop through each user
foreach ($user in $users) {
    try {
        # Output the action being performed
        Write-Host "Revoking sessions for: $($user.DisplayName)" -ForegroundColor Green

        # Revoke the user's sign-in sessions
        Revoke-MgUserSignInSession -UserId $user.Id

        # Increment the counter for successfully revoked sessions
        $countrs++
    } catch {
        # Output an error message if the session revocation fails
        Write-Host "Failed to revoke session for user: $($user.DisplayName). Error: $_" -ForegroundColor Red
    }
}

# Output summary of the operation
Write-Host "Total users processed when revoking sessions: $($users.Count)"
Write-Host "Total sessions revoked: $countrs" -ForegroundColor Cyan


# Disconnect
Disconnect-Graph

# Write-host output
1..8 | ForEach-Object { Write-Host "" }
Write-Host "Total users process when enforcing MFA: $($users.Count)" -ForegroundColor Cyan
Write-Host "Total user MFA's Enforced: $countmfa" -ForegroundColor Cyan
Write-Host "Total users processed when revoking sessions: $($users.Count)" -ForegroundColor Cyan
Write-Host "Total sessions revoked: $countrs" -ForegroundColor Cyan


