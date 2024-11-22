# Define the subnets
$subnets = @{
    "site1" = "192.168.1"
    "site2" = "192.222.1"
    "site3" = "192.121.3"
    "site4" = "2.2.2"
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
