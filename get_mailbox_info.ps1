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

function Confirm-ExchangeLogin{
    #checking if you are logged in to exhcange center
    $logininfo = Get-ConnectionInformation
    if ($logininfo){
        $loginuser = $logininfo.UserPrincipalName
        Write-Host "Logged in as $loginuser"
    }else {
        Write-Error "Not Logged in"
        exit 1
    }
}

function Get-AllMailboxPermissions {
    param(
        $csv = (Join-Path -path $PWD -ChildPath "AllMailBoxPermissions.csv"),  
        [Parameter(Mandatory=$true)]
        $mailboxes,
        [switch]$v #Verbose
    )
    if ($v){
        Write-Host "Executing All Mailbox Permissions function"
    }

    # Confirm Exchange login (Uncomment when necessary)
    Confirm-ExchangeLogin

    # Initialize variable to store results
    $results = @()

    # Loop through each mailbox
    foreach ($mail in $mailboxes) {
        # Get the permissions for the current mailbox
        $mailboxPermissions = Get-MailboxPermission -Identity $mail
        $mailboxRecipientPermissions = Get-RecipientPermission -Identity $mail.Identity
        
        # Collect SendAs Permissions and exclude NT AUTHORITY\SELF
        $sendAsPermissions = $mailboxRecipientPermissions | Where-Object { $_.AccessRights -contains "SendAs" -and $_.Trustee -ne "NT AUTHORITY\SELF" } | ForEach-Object { $_.Trustee }

        # Get SendOnBehalfTo, filter out NT AUTHORITY\SELF
        $sendOnBehalfOf = $mail.GrantSendOnBehalfTo | Where-Object { $_ -ne "NT AUTHORITY\SELF" }

        # Format Mailbox Permissions in {user:permission} format
        $permissionsList = $mailboxPermissions | Where-Object { $_.User -ne "NT AUTHORITY\SELF" } | ForEach-Object { "$($_.User)-$($_.AccessRights -join ":")" }

        # Create a formatted string for the permissions and send-as/send-on-behalf
        $formattedPermissions = ($permissionsList -join "; ")
        $formattedSendAs = ($sendAsPermissions -join "; ")
        $formattedSendOnBehalfOf = ($sendOnBehalfOf -join "; ")

        # Only add to results if at least one field is populated
        if ($formattedPermissions -or $formattedSendAs -or $formattedSendOnBehalfOf) {
            $permissionsObject = [PSCustomObject]@{
                Mailbox                = $mail
                MailboxPermissions     = $formattedPermissions
                SendAsPermissions      = $formattedSendAs
                SendOnBehalfOf         = $formattedSendOnBehalfOf
            }

            $results += $permissionsObject
        }
    }

    # Export results to a CSV file
    $results | Export-Csv -Path $csv -NoTypeInformation

    # Optional: Output results to the console
    if ($v) {
        $results | Format-Table -AutoSize
    }
}


function Get-AllInboxRules {
    param(
        [Parameter(Mandatory=$true)]
        [array]$mailboxes,                        # Accepts an array of mailboxes as input
        [switch]$v,                         # Verbose switch for extra output
        [string]$csvPath = (Join-Path -path $PWD -ChildPath "AllInboxRules.csv")  # Default path for CSV
    )
    #confirming login to exhcange
    Confirm-ExchangeLogin 

    if ($v) {
        Write-Host "Collecting inbox rules for provided mailboxes..."
    }

    # Initialize an array to hold all rules
    $allRules = @()

    foreach ($mailbox in $mailboxes) {
        
        # Get inbox rules for each mailbox
        $rules = Get-InboxRule -Mailbox $mailbox.PrimarySmtpAddress
        
        if ($rules) {
            # Add mailbox alias to each rule
            foreach ($rule in $rules) {
                $rule | Add-Member -MemberType NoteProperty -Name MailboxAlias -Value $mailbox.Alias
                $allRules += $rule
            }

            if ($v) {
                Write-Host "Collected rules for $($mailbox.PrimarySmtpAddress)"
            }
        } 
    }

    # Export all rules to a single CSV file
    if ($allRules.Count -gt 0) {
        $allRules | Export-Csv -Path $csvPath -NoTypeInformation
        Write-Host "Exported all inbox rules to $csvPath"
        # Optional: Output results to the console
        if ($v) {
            $allRules | Format-Table -AutoSize
        }
    } else {
        Write-Host "No inbox rules were collected. No File was created" -ForegroundColor Red
    }

}

function Get-AllForwardingRules {
    param (
        [Parameter(Mandatory=$true)]
        [array]$mailboxes,                        # Accepts an array of mailboxes as input
        
        [switch]$v,                                # Custom verbose switch for extra output
        
        [string]$csvPath = (Join-Path -path $PWD -ChildPath "AllForwardingRules.csv")  # Default path for CSV
    )

    # Confirm login to Exchange
    Confirm-ExchangeLogin

    $result = @()

    foreach ($mailbox in $mailboxes) {
        # Extract forwarding address
        $forwarding = $mailbox.ForwardingSmtpAddress
        
        if ($forwarding -ne $null) {
            if ($v) {
                Write-Host "Processing mailbox: $($mailbox.Name) with forwarding address: $forwarding"
            }
            $result += [PSCustomObject]@{
                MailBoxName           = $mailbox.Name
                MailBoxAlias          = $mailbox.Alias
                ForwardingSmtpAddress = $forwarding
            }
        } elseif ($v) {
            Write-Host "No forwarding address found for mailbox: $($mailbox.Name)"
        }
    }

    # Export the results to CSV
    $result | Export-Csv -Path $csvPath -NoTypeInformation

    if ($v) {
        Write-Host "Forwarding rules have been exported to: $csvPath"
    }
    # Optional: Output results to the console
    if ($v) {
        $result | Format-Table -AutoSize
    }
}

function main {
    # Ensure that the required modules are installed
    Install-ModuleIfNeeded -ModuleName "ExchangeOnlineManagement"

    #Import Module
    Import-Module -Name "ExchangeOnlineManagement"

    # Logging into Exchange Online
    try {
        Write-Host "Logging into Exchange Online..." -ForegroundColor Green
        Connect-ExchangeOnline
    }
    catch {
        Write-Error "Error logging into Exchange Online. Please check credentials and try again."
        exit 1
    }

    # Retrieve all mailboxes in the tenant
    Write-Host "Retrieving all mailboxes..." -ForegroundColor Green
    $mailboxes = Get-Mailbox -ResultSize Unlimited

    # Get mailbox permissions
    Write-Host "Collecting mailbox permissions..." -ForegroundColor Green
    Get-AllMailboxPermissions -mailboxes $mailboxes -v

    # Get inbox rules for all mailboxes
    Write-Host "Collecting inbox rules..." -ForegroundColor Green
    Get-AllInboxRules -mailboxes $mailboxes -v

    # Get forwarding rules for all mailboxes
    Write-Host "Collecting forwarding rules..." -ForegroundColor Green
    Get-AllForwardingRules -mailboxes $mailboxes -v

    # Log out from Exchange Online
    try {
        Write-Host "Logging out of Exchange Online..." -ForegroundColor Green
        Disconnect-ExchangeOnline -Confirm:$false
    }
    catch {
        Write-Error "Error logging out of Exchange Online."
        exit 1
    }

    Write-Host "Operation completed successfully!" -ForegroundColor Green
}


main
