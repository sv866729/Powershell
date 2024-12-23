function Get-NetworkInfo {
    param (
        [string]$networkFolder = "C:\forensics\NetworkInfo"
    )

    # Create the NetworkInfo folder if it doesn't exist
    if (-not (Test-Path -Path $networkFolder)) {
        New-Item -Path $networkFolder -ItemType Directory
    }

    # Route Table
    route print > "$networkFolder\RouteTable.txt"

    # Network Neighbors
    Get-NetNeighbor | Export-Csv -Path "$networkFolder\NetworkNeighbors.csv" -NoTypeInformation

    # Network Configuration (ipconfig)
    ipconfig /all > "$networkFolder\NetworkConfiguration.txt"

    # ARP Table
    arp -a > "$networkFolder\ARPTable.txt"

    # Connections to Process ID (netstat)
    Start-Process "netstat" -ArgumentList "-anob" -RedirectStandardOutput "$networkFolder\NetstatConnections.txt" -RedirectStandardError "$networkFolder\NetstatErrors.txt" -Wait

    # DNS Cache
    Get-DnsClientCache | Format-Table -AutoSize | Out-String > "$networkFolder\DNSCache.txt"

    # Hostfile
    Copy-Item -Path "C:\Windows\System32\drivers\etc\hosts" -Destination "$networkFolder\Hostfile.txt"

    # WIFI Connected to (Registry query)
    reg query HKLM\system\CurrentControlSet\Services\Dnscache\Parameters\DnsActiveIfs\ /s > "$networkFolder\WIFIConnections.txt"
}