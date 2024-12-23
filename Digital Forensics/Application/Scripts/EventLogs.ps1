function Export-EventLogs {
    param (
        [string]$logFolder = "C:\forensics\EventLogs"
    )

    # Check if the folder exists, and create it if it doesn't
    if (-not (Test-Path -Path $logFolder)) {
        New-Item -Path $logFolder -ItemType Directory
    }

    # Export Application Log (full details)
    Get-WinEvent -LogName Application | Select-Object TimeCreated, Id, LevelDisplayName, Message, ProviderName, TaskDisplayName, OpcodeDisplayName, UserId | Export-Csv -Path "$logFolder\ApplicationLog.csv" -NoTypeInformation

    # Export System Log (full details)
    Get-WinEvent -LogName System | Select-Object TimeCreated, Id, LevelDisplayName, Message, ProviderName, TaskDisplayName, OpcodeDisplayName, UserId | Export-Csv -Path "$logFolder\SystemLog.csv" -NoTypeInformation

    # Export Security Log (full details)
    Get-WinEvent -LogName Security | Select-Object TimeCreated, Id, LevelDisplayName, Message, ProviderName, TaskDisplayName, OpcodeDisplayName, UserId | Export-Csv -Path "$logFolder\SecurityLog.csv" -NoTypeInformation

    # Export Setup Log (full details)
    Get-WinEvent -LogName Setup | Select-Object TimeCreated, Id, LevelDisplayName, Message, ProviderName, TaskDisplayName, OpcodeDisplayName, UserId | Export-Csv -Path "$logFolder\SetupLog.csv" -NoTypeInformation
}
