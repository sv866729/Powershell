# Connect to Microsoft Graph with the necessary scopes
 Connect-MgGraph -Scopes "User.ReadWrite.All", "Policy.ReadWrite.AuthenticationMethod"

# Retrieve all users
$users = Get-MgUser

# Loop through each user
foreach ($user in $users) {
    # Set the API endpoint URL for the current user
    $url = "https://graph.microsoft.com/beta/users/$($user.Id)/authentication/requirements"

    # Define the headers for the request
    $headers = @{
        "Content-Type" = "application/json"
    }

    # Define the body of the request
    $body = @{
        "perUserMfaState" = "enforced"
    } | ConvertTo-Json

    # Try to send the PATCH request and handle any errors
    try {
        # Send the PATCH request
        Invoke-MgGraphRequest -Method PATCH -Uri $url -Headers $headers -Body $body

        # Output success message
        Write-Output "Successfully enforced MFA for user: $($user.UserPrincipalName)"
    }
    catch {
        # Output error message
        Write-Error "Failed to enforce MFA for user: $($user.UserPrincipalName). Error: $_"
    }
}
