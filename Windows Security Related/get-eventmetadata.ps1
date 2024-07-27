# This is not my code but i did convert it into a funtion for easy use just want to keep it 100 
# https://stackoverflow.com/questions/59154238/powershell-getting-advanced-eventlog-informations-xml
# The log name is like "System" or "Security" and is a string value
function get-eventmetadata ([string]$eventid, [string]$logname) {
    # Pull logs
    $result = Get-WinEvent -FilterHashtable @{LogName = $logname; Id = $eventid} | ForEach-Object {
        # Convert the event to XML and grab the Event node
        $eventXml = ([xml]$_.ToXml()).Event
        # Create an ordered hashtable object to collect all data
        # Add some information from the XML 'System' node first
        $evt = [ordered]@{
            EventDate = [DateTime]$eventXml.System.TimeCreated.SystemTime
            Computer  = $eventXml.System.Computer
        }
        $eventXml.EventData.ChildNodes | ForEach-Object { $evt[$_.Name] = $_.'#text' }
        # Output as PsCustomObject. This ensures the $result array can be written to CSV easily
        [PsCustomObject]$evt
    }
    return [array]$result
}

#Example use case
#get-eventmetadata -eventid 4672 -logname Security

#Security logs reviews have to be ran as a admin or you will get a no event found error
