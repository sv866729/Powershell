# Function Description: Export-StartupCommands
# Retrieves startup command information by querying the system's startup entries. It exports this data for analysis.
function Export-AutoRun {
    param (
        [string]$outputFolder = "C:\forensics\autorun"
    )

    # Define file paths
    $autorunZipUrl = "https://download.sysinternals.com/files/Autoruns.zip"
    $autorunZipPath = Join-Path $outputFolder "Autoruns.zip"
    $autorunExePath = Join-Path $outputFolder "autorunsc.exe"
    $autorunCsvPath = Join-Path $outputFolder "autorun.csv"

    # Download Autoruns.zip
    Invoke-WebRequest -Uri $autorunZipUrl -OutFile $autorunZipPath

    # Unzip the file
    Expand-Archive -Path $autorunZipPath -DestinationPath $outputFolder -Force

    # Run autorunsc.exe and save output as autorun.csv
    & $autorunExePath /accepteula -a * -c > $autorunCsvPath

    # Cleanup - Optionally remove the zip file
    Remove-Item $autorunZipPath -Force
}