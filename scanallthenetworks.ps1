#################Scan#################################

$subnets = @{
    alphaoffice          = "10.100.1"
    betaoffice           = "10.100.2"
    gammaoffice          = "10.100.3"
    deltastore           = "10.100.4"
    epsilonwarehouse     = "10.100.5"
    zetaoffice           = "10.100.6"
    etastore             = "10.100.7"
    thetaoffice          = "10.100.8"
    iotawarehouse        = "10.100.9"
    kappastore           = "10.100.10"
    lambdaoffice         = "10.100.11"
    muwarehouse          = "10.100.12"
    nuoffice             = "10.100.13"
    xioffice             = "10.100.14"
    omicronstore         = "10.100.15"
    pioffice             = "10.100.16"
    rhooffice            = "10.100.17"
    sigmastore           = "10.100.18"
    tauwarehouse         = "10.100.19"
    upsilonoffice        = "10.100.20"
    phioffice            = "10.100.21"
    chiwarehouse         = "10.100.22"
    psiwarehouse         = "10.100.23"
    omegaoffice          = "10.100.24"
    charliestore         = "10.101.1"
    deltaheadquarters    = "10.101.2"
    echohub              = "10.101.3"
    foxtrotoffice        = "10.101.4"
    golfstore            = "10.101.5"
    hotelwarehouse       = "10.101.6"
    indiawarehouse       = "10.101.7"
    julietstore          = "10.101.8"
    kilooffice           = "10.101.9"
    limawarehouse        = "10.101.10"
    mikeoffice           = "10.101.11"
    novemberwarehouse    = "10.101.12"
    oscarstore           = "10.101.13"
    papahub             = "10.101.14"
    quebecwarehouse      = "10.101.15"
    romeostore           = "10.101.16"
    sierraoffice         = "10.101.17"
    tangooffice          = "10.101.18"
    uniformwarehouse     = "10.101.19"
    victorstore          = "10.101.20"
}


# Define the Nmap path
$nmappath = "C:\Program Files (x86)\Nmap\nmap.exe"

# Iterate through each subnet
foreach ($subnet in $subnets.GetEnumerator()) {
    # Create the IP range argument for Nmap
    $ipRange = "$($subnet.Value).200-205"

    # Set the output filename
    $filename = $subnet.Key

    # Define the Nmap arguments
    $arguments = @(
        "-sV",         # Service version detection
        "-O",          # OS detection
        "-p", "22,443,80", # Ports to scan (SSH, HTTPS, HTTP)
        "-sS",         # SYN scan
        $ipRange,      # IP range argument
        "-oA", $filename # Output file (basename without extension)
    )

    # Start the Nmap process
    Start-Process -FilePath $nmappath -ArgumentList $arguments -Wait
}

#################End Scan #################################

$results = @()
##########Filter Scan####################################
foreach ($location in $subnets.Keys){
    [xml]$xml = Get-Content -Path ".\$location.xml"
    # Define the desired ports and their names
    $portMapping = @{
        "22"  = "ssh"
        "80"  = "http"
        "443" = "https"
    } 
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
            Location    = $location
            IPAddress   = $nmapHost.address.addr
            ssh         = $portStates["ssh"]
            http        = $portStates["http"]
            https       = $portStates["https"]
            os_match    = $osMatchName.ToString()
        }

        # Add the object to the results array if any port is open
        if ($portStates.Values -contains "open") {
            $results += $hostResult
        }
    }
}
##########End Filter Scan####################################

##########Output#############################################
$results | Export-Csv -Path "$PWD\nmap_scan_results.csv" -NoTypeInformation
$results | ft
##########Output#############################################
