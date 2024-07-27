# Simple script to remove all email rules for all users
Connect-ExchangeOnline
$user = Get-Mailbox
foreach ($i in $user){
    Get-InboxRule -Mailbox $i | Remove-InboxRule
}
