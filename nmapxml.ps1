[xml]$xml = Get-Content -Path ".\file.xml"
# Define the desired ports and their names
$portMapping = @{
    "22"  = "ssh"
    "80"  = "http"
    "443" = "https"
}

# Initialize an empty array to store the results
$results = @()

# Loop through each host and check its ports
foreach ($nmapHost in $xml.nmaprun.host) {
    # Create a hashtable to store the port states for the current host
    $portStates = @{
        "ssh"  = "closed"  # Default state
        "http" = "closed"  # Default state
        "https" = "closed" # Default state
    }

    # Loop through each port in the host
    foreach ($port in $nmapHost.ports.port) {
        # Check if the port is in the desired list and is open
        if ($portMapping.ContainsKey($port.portid)) {
            if ($port.state.state -eq "open") {
                # Set the corresponding port state to 'open'
                $portStates[$portMapping[$port.portid]] = "open"
            }
        }
    }

    # Extract the OS match name, if available
    $osMatchName = $nmapHost.os.osmatch.name
    if (-not $osMatchName) {
        $osMatchName = "Unknown"
    }

    # Create a custom object for the current host with port states and OS match name
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

# Export the results to a CSV file in the current directory
$results | Export-Csv -Path "$PWD\nmap_scan_results.csv" -NoTypeInformation
$results | ft


Write-Host "Results exported to nmap_scan_results.csv in the current directory."
