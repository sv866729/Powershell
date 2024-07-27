# Author: Samuel Valdez
# Creation Date: 06/10/2024

# Used to quickly pull logs 


function Get-EventLogs {
    param (
        [string]$SaveDirectory = ".\EventLogs"
    )

    # Define the source directories and log files
    $SYSTEMLOGS = "C:\Windows\Logs"
    $SECURITYLOGS = "C:\Windows\System32\winevt\Logs\Security.evtx"
    $SETUPLOGS = "C:\Windows\Panther"

    # Check if the save directory exists, if not create it
    if (-not (Test-Path -Path $SaveDirectory)) {
        New-Item -ItemType Directory -Path $SaveDirectory
    }

    # Function to copy logs
    function Copy-Logs {
        param (
            [string]$Source,
            [string]$Destination
        )
        if (Test-Path -Path $Source) {
            Copy-Item -Path $Source -Destination $Destination -Recurse -Force
        } else {
            Write-Output "Source path '$Source' does not exist."
        }
    }

    # Copy system logs
    Copy-Logs -Source $SYSTEMLOGS -Destination "$SaveDirectory\SystemLogs"

    # Copy security logs
    Copy-Logs -Source $SECURITYLOGS -Destination "$SaveDirectory\Security.evtx"

    # Copy setup logs
    Copy-Logs -Source $SETUPLOGS -Destination "$SaveDirectory\SetupLogs"

    Write-Output "Logs have been copied to $SaveDirectory."
}

# Example usage
Get-EventLogs -SaveDirectory "C:\SavedEventLogs"