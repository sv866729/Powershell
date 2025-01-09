# Define the subnets
$subnets = @{
#Note dont put last octect or it will break
}

# Define the Nmap path
$nmappath = "C:\Program Files (x86)\Nmap\nmap.exe"

# Define timestamp for output files
$timestamp = (Get-Date -Format "yyyyMMdd_HHmmss")

# Iterate through each subnet
foreach ($subnet in $subnets.GetEnumerator()) {
    try {
        # Log scanning progress
        Write-Host "Starting scan for subnet: $($subnet.Key) ($($subnet.Value).1-254)" -ForegroundColor Green

        # Create the IP range argument for Nmap
        $ipRange = "$($subnet.Value).1-254"

        # Set the output filename
        $filename = "$($subnet.Key)_$timestamp"

        # Define the Nmap arguments
        $arguments = @(
            "-sV",           # Service version detection
            "-O",            # OS detection
            "-p", "22,443,80", # Ports to scan (SSH, HTTPS, HTTP)
            "-sS",           # SYN scan
            $ipRange,        # IP range argument
            "-oA", $filename # Output file (basename without extension)
        )

        # Start the Nmap process
        Start-Process -FilePath $nmappath -ArgumentList $arguments -Wait
    } catch {
        Write-Warning "Failed to scan subnet: $($subnet.Key). Error: $_"
    }
}

# Initialize results array
$results = @()

# Process XML outputs
foreach ($subnet in $subnets.GetEnumerator()) {
    $xmlFile = "$($subnet.Key)_$timestamp.xml"

    if (!(Test-Path -Path $xmlFile)) {
        Write-Warning "XML file for subnet $($subnet.Key) not found. Skipping."
        continue
    }

    try {
        # Parse the XML file
        [xml]$xml = Get-Content -Path $xmlFile

        # Define the desired ports and their names
        $portMapping = @{
            "22"  = "ssh"
            "80"  = "http"
            "443" = "https"
        }

        # Loop through each host and check its ports
        foreach ($nmapHost in $xml.nmaprun.host) {
            # Create a hashtable to store the port states for the current host
            $portStates = @{"ssh" = "closed"; "http" = "closed"; "https" = "closed"}

            # Check ports and their states
            foreach ($port in $nmapHost.ports.port) {
                if ($portMapping.ContainsKey($port.portid) -and $port.state.state -eq "open") {
                    $portStates[$portMapping[$port.portid]] = "open"
                }
            }

            # Extract OS match name
            $osMatchName = $nmapHost.os.osmatch.name
            if (-not $osMatchName) { $osMatchName = "Unknown" }

            # Create a custom object for the current host
            $hostResult = [PSCustomObject]@{
                IPAddress   = $nmapHost.address.addr
                ssh         = $portStates["ssh"]
                http        = $portStates["http"]
                https       = $portStates["https"]
                os_match    = $osMatchName
            }

            # Add the object to the results array if any port is open
            if ($portStates.Values -contains "open") {
                $results += $hostResult
            }
        }
    } catch {
        Write-Warning "Error processing XML for subnet $($subnet.Key): $_"
    }
}

# Export the results to a timestamped CSV file
$outputFile = "$PWD\nmap_scan_results_$timestamp.csv"
$results | Export-Csv -Path $outputFile -NoTypeInformation
$results | Format-Table -AutoSize

Write-Host "Results exported to $outputFile in the current directory." -ForegroundColor Cyan
