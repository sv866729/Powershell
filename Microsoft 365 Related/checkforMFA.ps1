
#Install-Module Microsoft.Graph -Scope CurrentUser -Force
#Install-Module Microsoft.Graph.Users -Scope CurrentUser -Force
#Install-Module Microsoft.Graph.Identity.SignIns -Scope CurrentUser -Force
# Import Microsoft Graph Module
Import-Module Microsoft.Graph
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Identity.SignIns
# Connect to Microsoft Graph with required permissions
# Define the scopes
$scopes = @(
    "UserAuthenticationMethod.Read.All",
    "UserAuthenticationMethod.ReadWrite.All",
    "UserAuthenticationMethod.ReadWrite",
    "User.Read.All"
)

# Connect to Microsoft Graph with the specified scopes
Connect-Graph -Scopes $scopes


# Fetch all users
$users = Get-MgUser -All

# Loop through each user to check their MFA status
$mfaStatusReport = $users | ForEach-Object {
    $authMethods = Get-MgUserAuthenticationMethod -UserId $_.Id -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        DisplayName       = $_.DisplayName
        UserPrincipalName = $_.UserPrincipalName
        MFAEnabled        = if ($authMethods | Where-Object { $_.AdditionalProperties['@odata.type'] -eq "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod" }) { "Enabled" } else { "Disabled" }
    }
}

# Display the report
$mfaStatusReport | Export-Csv "Usersmfa.csv" -NoTypeInformation

# Optional: Disconnect from Microsoft Graph
Disconnect-MgGraph


