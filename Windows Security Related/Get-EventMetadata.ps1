<#
Author: Samuel Valdez
Function: Get-EventMetadata

Description:
    Retrieves detailed metadata for a specific event from the Windows Event Log. The function filters events by the specified event ID and log name, converts them to XML format, and extracts relevant information. It returns the event data as a `PSCustomObject` for easy manipulation and export.

Usage:
    1. Run the function with the desired event ID and log name:
        Get-EventMetadata -EventId <EventID> -LogName <LogName>

    Example:
        Get-EventMetadata -EventId 4672 -LogName "Security"

Notes:
    - Ensure you have the appropriate permissions to access security logs. Running this function as an administrator may be required to avoid errors.
    - The `LogName` should be a valid event log name, such as "System" or "Security".
    - The `EventId` should be the numeric ID of the event you wish to retrieve.

Credit to: https://stackoverflow.com/questions/59154238/powershell-getting-advanced-eventlog-informations-xml
#>

function Get-EventMetadata {
    param (
        [string]$EventId,
        [string]$LogName
    )

    # Pull logs
    $result = Get-WinEvent -FilterHashtable @{LogName = $LogName; Id = $EventId} | ForEach-Object {
        # Convert the event to XML and grab the Event node
        $eventXml = ([xml]$_.ToXml()).Event
        # Create an ordered hashtable object to collect all data
        # Add some information from the XML 'System' node first
        $evt = [ordered]@{
            EventDate = [DateTime]$eventXml.System.TimeCreated.SystemTime
            Computer  = $eventXml.System.Computer
        }
        # Add event data from 'EventData' child nodes
        $eventXml.EventData.ChildNodes | ForEach-Object { $evt[$_.Name] = $_.'#text' }
        # Output as PsCustomObject. This ensures the $result array can be written to CSV easily
        [PsCustomObject]$evt
    }
    return [array]$result
}
