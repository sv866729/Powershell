# NOTE: This script has not been tested and is theoretical. Use at your own risk.

# Description:
# The PowerShell script is designed to configure Windows Event Forwarding (WEF) for centralized event
# log collection from multiple source computers to a designated event collector.
# It sets up the necessary firewall rules, configures event subscriptions, and ensures that the Windows 
# Event Collector service (wecsvc) is running and properly set up on both the collector and source computers.

# Usage:
# 1. Run to load the module
#
# 2.
# # Setting computers to collect logs from
# $computers = @("Computer1", "Computer2")
# Set-RemoteLogging -SourceComputers $computers

# Note: This sets the device that it is run on as the collector and attempts to set the source computers as sources.

# Inspiration: https://www.loggly.com/ultimate-guide/centralizing-windows-logs/

function set-RemoteLogging {
    param (
        [string]$SubscriptionName = "DeviceSecAndSystemLog",
        [string]$Description = "Events from remote source servers",
        [string]$DestinationLog = "Forwarded Events",
        [Parameter(Mandatory=$true)]
        [string[]]$SourceComputers, # Replace with actual source computer names
        [string]$Protocol = "HTTP",
        [int]$Port = 5985,
        [string]$LoggedTime = "Last 24 hours",
        [string]$EventLevels = "All",
        [string[]]$LogNames = @("Security", "System") # List of log names
    )

    # Testing network connection to each listed computer
    foreach ($sourceComputer in $SourceComputers) {
        if (-not (Test-Connection -ComputerName $sourceComputer -Count 1 -Quiet)) {
            Write-Warning "$sourceComputer is not reachable."
            continue
        }
    }

    # Open necessary firewall ports on the collector
    try {
        New-NetFirewallRule -DisplayName "Allow Event Collector" -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow -Profile Domain,Private -ErrorAction Stop
        Write-Output "Firewall rule for Event Collector added."
    } catch {
        Write-Error "Failed to add firewall rule for Event Collector. $_"
        return
    }

    # Generate XML query for the subscription
    $logQueries = $LogNames | ForEach-Object {
        "<Query Id='0' Path='$_'><Select Path='$_'>*</Select></Query>"
    }
    $subscriptionXML = @"
<QueryList>
$($logQueries -join "`n")
</QueryList>
"@

    # Create the subscription
    $subscriptionID = "$SubscriptionName"

    # Generate the command to create the subscription
    $createSubscriptionCommand = @"
wecutil cs /d:""$DestinationLog"" /f:""$subscriptionXML"" /s:$($SourceComputers -join ",") /p:$Port /pr:$Protocol /t:""$LoggedTime"" /l:""$EventLevels"" /n:$subscriptionID
"@

    # Run the command
    try {
        Invoke-Expression $createSubscriptionCommand
        Write-Output "Event subscription created."
    } catch {
        Write-Error "Failed to create event subscription. $_"
        return
    }

    foreach ($sourceComputer in $SourceComputers) {
        try {
            Invoke-Command -ComputerName $sourceComputer -ScriptBlock {
                # Open necessary firewall ports on the source computers
                try {
                    New-NetFirewallRule -DisplayName "Allow Event Forwarding" -Direction Outbound -Protocol TCP -RemotePort 5985 -Action Allow -Profile Domain,Private -ErrorAction Stop
                    Write-Output "Firewall rule for Event Forwarding added."
                } catch {
                    Write-Error "Failed to add firewall rule for Event Forwarding. $_"
                }

                # Ensure Windows Event Collector service is running
                try {
                    Start-Service wecsvc -ErrorAction Stop
                    Write-Output "Windows Event Collector service started."
                } catch {
                    Write-Error "Failed to start Windows Event Collector service. $_"
                }

                # Configure the source computer to forward events to the collector
                wecutil qc

                # Optionally configure the source computers to accept connections from the collector
                $collector = $currentComputerName # Replace with the name of your collector server
                wecutil gs /c:$collector
            } -ErrorAction Stop
        } catch {
            Write-Error "Failed to configure $sourceComputer. $_"
        }
    }
}
