<#
Author: Samuel Valdez
Date: 06/09/2024

Assisted with ChatGbt and a stackoverflow
https://stackoverflow.com/questions/23260656/modify-local-security-policy-using-powershell
https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/secedit

This is a program the is used to set local password policy and simple auditing for accounts
using the Secedit Command

Modifcations needed:
    1. Set each setting value

Usage:
    1. Make modifications
    2. Run
    3. Validate output and valdiate backup


#>
# Define the security settings
$settings = @{
    "MinimumPasswordAge" = 0
    "MaximumPasswordAge" = 60
    "MinimumPasswordLength" = 8
    "PasswordComplexity" = 1
    "PasswordHistorySize" = 5
    "LockoutBadCount" = 5
    "ResetLockoutCount" = 10
    "LockoutDuration" = 15
    "AllowAdministratorLockout" = 1
    "RequireLogonToChangePassword" = 0
    "EnableAdminAccount" = 1
    "EnableGuestAccount" = 0
    "AuditSystemEvents" = 1
    "AuditLogonEvents" = 1
    "AuditObjectAccess" = 0
    "AuditPrivilegeUse" = 1
    "AuditPolicyChange" = 1
    "AuditAccountManage" = 1
    "AuditProcessTracking" = 0
    "AuditDSAccess" = 1
    "AuditAccountLogon" = 1
}

# Backup current security policy
$backupPath = "c:\security_policy_backup.cfg"
secedit /export /cfg $backupPath

# Export the current security policy
$exportPath = "c:\security_policy.cfg"
secedit /export /cfg $exportPath

# Read the current security policy
$securityPolicy = Get-Content $exportPath

# Update the security policy with the new settings
foreach ($setting in $settings.GetEnumerator()) {
    $key = $setting.Key
    $value = $setting.Value
    $pattern = "^\s*($key\s*=\s*).*"
    $replacement = "$key = $value"
    
    if ($securityPolicy -match $pattern) {
        # Replace the existing setting
        $securityPolicy = $securityPolicy -replace $pattern, $replacement
    } else {
        # Add the new setting if it doesn't exist
        $securityPolicy += "`r`n$replacement"
    }
}

# Write the updated security policy back to the file
$securityPolicy | Set-Content $exportPath

# Apply the updated security policy
secedit /configure /db secedit.sdb /cfg $exportPath

#Updating 
$exportPath = "c:\security_policy.cfg"
secedit /export /cfg $exportPath


Write-Host "Updated Security Policy"
write-host ""
& type $exportPath

# Removing file
Remove-Item -Path $exportPath

write-host ""
write-host ""
Write-Host "Security policy updated and applied. Backup saved to $backupPath."
