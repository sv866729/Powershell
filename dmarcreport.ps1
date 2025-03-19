# Initialize Outlook application object
$Outlook = New-Object -ComObject Outlook.Application

# Set folder paths for saving attachments and extracted reports
$saveFolder = "C:\Path\To\Save\Attachments"
$Namespace = $Outlook.GetNamespace("MAPI")

# Access the specific mailbox (replace with your email address)
$Mailbox = $Namespace.Folders.Item("your-email@example.com")

# Navigate to the specific folder: Inbox > Dmarc > Reports Folder
$Inbox = $Mailbox.Folders.Item("Inbox")
$DmarcFolder = $Inbox.Folders.Item("Dmarc")
$ReportFolder = $DmarcFolder.Folders.Item("Reports")

# Clear existing files in the Reports folder
Remove-Item "C:\Path\To\Reports\*" -Recurse -Force

# Iterate through emails in the Reports folder
foreach ($Email in $ReportFolder.Items) {
    # Check for attachments
    if ($Email.Attachments.Count -gt 0) {
        foreach ($Attachment in $Email.Attachments) {
            # Set file path to save attachment
            $FilePath = Join-Path -Path $saveFolder -ChildPath $Attachment.FileName

            # Skip saving if the file already exists
            if (Test-Path $FilePath) {
                Write-Host "File already exists, skipping: $FilePath"
            } else {
                # Save new attachment
                $Attachment.SaveAsFile($FilePath)
                Write-Host "Saved new attachment: $FilePath"

                # Check if the file is a .gz or .zip file and extract it
                if ($FilePath.EndsWith(".gz")) {
                    Start-Process -FilePath "C:\Path\To\7zip\7z.exe" -ArgumentList "x `"$FilePath`" -o'C:\Path\To\Reports'" -NoNewWindow -Wait
                } elseif ($FilePath.EndsWith(".zip")) {
                    Start-Process -FilePath "C:\Path\To\7zip\7z.exe" -ArgumentList "x `"$FilePath`" -o'C:\Path\To\Reports'" -NoNewWindow -Wait
                }
            }
        }
    }
}

# Process the extracted XML files
$filepath = "C:\Path\To\Reports"
$reports = Get-ChildItem -Path $filepath -Filter *.xml  # Only process XML files
$failures = @()

foreach ($report in $reports) {
    try {
        # Parse the XML report
        $xmlData = [xml](Get-Content -Path $report.FullName -Encoding UTF8)

        # Identify failed records based on specific conditions (e.g., SPF, DKIM, disposition)
        $failedRecords = $xmlData.feedback.record | Where-Object {
            $_.row.policy_evaluated.disposition -eq "reject" -or
            $_.auth_results.spf.result -ne "pass" -or
            $_.auth_results.dkim.result -ne "pass" -or
            $_.row.policy_evaluated.dkim -ne "pass" -or
            $_.row.policy_evaluated.spf -ne "pass"
        }

        foreach ($record in $failedRecords) {
            # Extract relevant information from failed records
            $sourceip = $record.row.source_ip
            $dispositionStatus = $record.row.policy_evaluated.disposition
            $spfResult = $record.auth_results.spf.result
            $dkimResult = $record.auth_results.dkim.result
            $spfPolicy = $record.row.policy_evaluated.spf
            $dkimPolicy = $record.row.policy_evaluated.dkim

            # Attempt DNS resolution for the source IP
            try {
                $dnshostname = Resolve-DnsName $sourceip -Server 8.8.8.8 | Select-Object -ExpandProperty NameHost
            } catch {
                Write-Host "Error Processing DNS for IP: $sourceip"
                $dnshostname = "Failed to Resolve"
            }

            # Store failure details in a custom object
            $failure = [PSCustomObject]@{
                Filename           = $report.Name
                DispositionStatus  = $dispositionStatus
                SPFResult          = $spfResult
                DKIMResult         = $dkimResult
                SPFPolicyStatus    = $spfPolicy
                DKIMPolicyStatus   = $dkimPolicy
                IP                 = $sourceip
                DNSName            = $dnshostname
            }

            # Add the failure record to the list
            $failures += $failure
        }

    } catch {
        Write-Output "Error processing file $($report.FullName): $_"
    }
}

# Export the failure report to a CSV file (appending if file exists)
$failures | Export-Csv -LiteralPath "C:\Path\To\FinalReport.csv" -NoTypeInformation -Append
