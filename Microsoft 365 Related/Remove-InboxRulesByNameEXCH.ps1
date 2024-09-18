<#
Author: Samuel Valdez
Function: Remove-InboxRulesByName

Description:
    Connects to Exchange Online, retrieves all user mailboxes, and removes any inbox rules that contain a specified string in their name. The script installs the required module if not already installed, connects to Exchange Online, processes each mailbox, and disconnects from Exchange Online.

Usage:
    1. Run the function with the desired string to match against inbox rule names:
        Remove-InboxRulesByName -RuleNameSubstring "(Migrated)"

Parameters:
    - RuleNameSubstring (mandatory): The substring to search for in inbox rule names. Rules containing this substring will be removed.

Notes:
    - Ensure the ExchangeOnlineManagement module is installed and available.
    - This function connects to Exchange Online, processes each mailbox to remove specific inbox rules, and then disconnects from the session.
    - The function uses the `-Confirm:$false` parameter to avoid prompting for confirmation during disconnection.

#>
##################################################
ERRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRORRRRRRRRRRRRRRR
This script is not working due to a error when  attempting to delete a rule it may be a syntax issue




function Remove-InboxRulesByName {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RuleNameSubstring
    )

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
    
    # Install the ExchangeOnlineManagement module if needed
    Install-ModuleIfNeeded -ModuleName "ExchangeOnlineManagement"

    # Connect to Exchange Online
    Connect-ExchangeOnline 

    # Get all user mailboxes
    $mailboxes = Get-Mailbox -ResultSize Unlimited

    foreach ($mailbox in $mailboxes) {
        try {
            # Get the inbox rules for the current mailbox
            $rules = Get-InboxRule -Mailbox $mailbox.Alias
            foreach ($rule in $rules) {
                # Check if the rule name contains the specified substring
                if ($rule.Name -contains $RuleNameSubstring) {
                    # Remove the rule
                    Remove-InboxRule -Mailbox $mailbox.Alias -Identity $rule.Identity
                    Write-Output "Removed rule '$($rule.Name)' from mailbox '$($mailbox.Alias)'"
                }
            }
        } catch {
            Write-Error "Failed to process mailbox '$($mailbox.Alias)': $_"
        }
    }

    # Disconnect from Exchange Online
    Disconnect-ExchangeOnline -Confirm:$false
}
