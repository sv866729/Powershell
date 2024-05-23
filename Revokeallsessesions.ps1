# Used to revoke every user session on
Connect-MgGraph
$users = get-mguser
forEach($user in $users){Revoke-MgUserSignInSession -UserId $user.id }