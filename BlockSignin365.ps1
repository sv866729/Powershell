# This will block all sign ins for all accounts execpt that running the script
connect-msolservice
$users = get-msoluser
forEach($user in $users){Set-MsolUser -UserPrincipalName $user.UserPrincipalName -BlockCredential $true}