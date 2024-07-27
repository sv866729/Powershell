# Function to check if a module is installed
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
 
# Check and install necessary modules
Install-ModuleIfNeeded -ModuleName "Microsoft.Graph.Identity.DirectoryManagement"
Install-ModuleIfNeeded -ModuleName "Microsoft.Graph.Users"
Install-ModuleIfNeeded -ModuleName "Microsoft.Graph.Users.Actions"
 
# Connect to Microsoft Graph with required scopes
try {
    Connect-MgGraph -Scopes Directory.Read.All, Directory.ReadWrite.All, RoleManagement.Read.Directory, `
                    RoleManagement.ReadWrite.Directory, User.Read.All, User.RevokeSessions.All
    Write-Host "Connected to Microsoft Graph successfully." -ForegroundColor Green
} catch {
    Write-Host "Failed to connect to Microsoft Graph. Error: $_" -ForegroundColor Red
    exit
}
 
# Get the ID for the Global Administrator role
try {
    $globalAdminRole = Get-MgDirectoryRole -Filter "DisplayName eq 'Global Administrator'" | Select-Object -First 1
    if ($globalAdminRole -eq $null) {
        Write-Host "Global Administrator role not found." -ForegroundColor Red
        exit
    }
} catch {
    Write-Host "Failed to retrieve Global Administrator role. Error: $_" -ForegroundColor Red
    exit
}
 
# Retrieve the IDs of the members of the Global Administrator role
try {
    $globalAdminUserIds = Get-MgDirectoryRoleMember -DirectoryRoleId $globalAdminRole.Id | Select-Object -ExpandProperty Id
} catch {
    Write-Host "Failed to retrieve Global Administrator members. Error: $_" -ForegroundColor Red
    exit
}
 
# Retrieve all users and filter out those who are Global Administrators
try {
    $nonGlobalUsers = Get-MgUser | Where-Object { $globalAdminUserIds -notcontains $_.Id }
} catch {
    Write-Host "Failed to retrieve users. Error: $_" -ForegroundColor Red
    exit
}
 
# Output the non-global users and revoke their sessions
$count = 0
foreach ($user in $nonGlobalUsers) {
    try {
        $count++
        Write-Host "Revoking sessions for: $user.DisplayName" -ForegroundColor Green
        Revoke-MgUserSignInSession -UserId $user.Id
    } catch {
        Write-Host "Failed to revoke session for user: $user.DisplayName. Error: $_" -ForegroundColor Red
    }
}
 
# Output summary
Write-Host "Total non-admin users: $($nonGlobalUsers.Count)"
Write-Host "Total sessions revoked: $count"
