# Used to reset every users MFA options in m365
Connect-MsolService
$users = Get-MsolUser
foreach ($user in $users){
    Reset-MsolStrongAuthenticationMethodByUpn -UserPrincipalName $user.UserPrincipalName
}