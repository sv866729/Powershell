# Function Description: Export-UsersAndGroups
# Collects information about local users and groups, including their SIDs and memberships in local groups. It also gathers data on active sessions.
function Export-UsersAndGroups {
    param (
        [string]$usersAndGroupFolder = "C:\forensics\usersandgroup"
    )

    # Check if the folder exists, and create it if it doesn't
    if (-not (Test-Path -Path $usersAndGroupFolder)) {
        New-Item -Path $usersAndGroupFolder -ItemType Directory
    }

    # Get all local users and their SIDs
    Get-LocalUser | Select-Object Name, SID | Export-Csv -Path "$usersAndGroupFolder\LocalUserSIDs.csv" -NoTypeInformation

    # Get all local groups and their SIDs
    Get-LocalGroup | Select-Object Name, SID | Export-Csv -Path "$usersAndGroupFolder\LocalGroupSIDs.csv" -NoTypeInformation

    # Collect all local group memberships
    $localGroups = Get-LocalGroup
    $localGroupMembers = foreach ($group in $localGroups) {
        Get-LocalGroupMember -Group $group.Name | Select-Object @{Name="GroupName";Expression={$group.Name}}, Name, SID
    }

    # Export all local group memberships to a CSV file
    $localGroupMembers | Export-Csv -Path "$usersAndGroupFolder\LocalGroupMemberships.csv" -NoTypeInformation
    ## Active sessions
    $outputFile = "$usersAndGroupFolder\ActiveSessions.csv"
    # Define the URL and paths for download and extraction
    $url = "https://download.sysinternals.com/files/logonSessions.zip"
    $downloadPath = "$usersAndGroupFolder\logonSessions.zip"
    $extractPath = "$usersAndGroupFolder\logonSessions"
    # Download the zip file
    Invoke-WebRequest -Uri $url -OutFile $downloadPath
    # Extract the zip file
    Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force
    # Run LogonSessions with -c and export to the specified file
    $logonSessionsExe = Join-Path -Path $extractPath -ChildPath "LogonSessions.exe"
    if (Test-Path $logonSessionsExe) {
        & $logonSessionsExe -c > $outputFile
    } else {
        Write-Error "LogonSessions.exe not found in the extracted folder."
    }
}
