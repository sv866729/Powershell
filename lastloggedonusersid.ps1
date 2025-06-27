#Get the local or domain user and converts the local user into full name if it begins with .\
# Attempts to execute if it fails it errors and displays a message
 
# Get the last logged-on user (e.g., "DOMAIN\UserName" or ".\UserName")
$user = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" -Name "LastLoggedOnUser" | Select-Object -ExpandProperty LastLoggedOnUser
 
# Handle .\Username (local accounts) by replacing '.' with actual computer name
if ($user -match '^\.\\') {
    $computerName = $env:COMPUTERNAME
    $user = $user -replace '^\.\\', "$computerName\"
}
 
try {
    # Convert user to SID
    $SID = (New-Object System.Security.Principal.NTAccount($user)).Translate([System.Security.Principal.SecurityIdentifier]).Value
} catch {
    Write-Warning "Could not resolve SID for user: ${user}"
    exit 1
}
