Script to perform that action:
# Connect to Exchange Online
Connect-ExchangeOnline -UserPrincipalName youradmin@domain.com -ShowProgress $true
 
# Get all user mailboxes
$mailboxes = Get-Mailbox -ResultSize Unlimited
 
foreach ($mailbox in $mailboxes) {
    try {
        # Get the inbox rules for the current mailbox
        $rules = Get-InboxRule -Mailbox $mailbox.Alias
        foreach ($rule in $rules) {
            # Check if the rule name contains "(Migrated)"
            if ($rule.Name -contains "(Migrated)") {
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
