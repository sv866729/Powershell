# This script processes DMARC XML reports to identify failed SPF, DKIM, and policy evaluations.
# It resolves source IPs to hostnames using Google's DNS (8.8.8.8) and exports the results to a CSV file.
# Ensure the script is placed in the same directory as the DMARC reports or adjust the $filepath accordingly.

$filepath = "C:\Path\To\Your\Directory"
$reports = Get-ChildItem -Path $filepath -Filter *.xml  # Processes only XML files
$failures = @()

foreach ($report in $reports) {
    try {
        $xmlData = [xml](Get-Content -Path $report.FullName -Encoding UTF8)
        
        # Identifies records with failures in disposition, SPF, or DKIM
        $failedRecords = $xmlData.feedback.record | Where-Object {
            $_.row.policy_evaluated.disposition -eq "reject" -or
            $_.auth_results.spf.result -ne "pass" -or
            $_.auth_results.dkim.result -ne "pass" -or
            $_.row.policy_evaluated.dkim -ne "pass" -or
            $_.row.policy_evaluated.spf -ne "pass"
        }
        
        foreach ($record in $failedRecords) {
            $sourceip = $record.row.source_ip
            $dispositionStatus = $record.row.policy_evaluated.disposition
            $spfResult = $record.auth_results.spf.result
            $dkimResult = $record.auth_results.dkim.result
            $spfPolicy = $record.row.policy_evaluated.spf
            $dkimPolicy = $record.row.policy_evaluated.dkim

            # DNS resolution with error handling
            try {
               $dnshostname = Resolve-DnsName $sourceip -Server 8.8.8.8 | Select-Object -ExpandProperty NameHost
            } catch {
                Write-Host "Error Processing DNS for IP: $sourceip"
                $dnshostname = "Failed to Resolve"
            }

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

            $failures += $failure
        }

    } catch {
        Write-Output "Error processing file $($report.FullName): $_"
    }
}

# Exports the final report to a CSV file
$failures | Export-Csv -LiteralPath '.\finalreport.csv' -NoTypeInformation

# Displays the results in a formatted table
$failures | Format-Table -AutoSize
