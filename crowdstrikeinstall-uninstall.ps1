function Check-CrowdStrikePresence {
    # Check if the directory exists
    $dirExists = Test-Path -Path "C:\Windows\System32\drivers\CrowdStrike"

    # Check if the registry key exists
    $regKeyExists = Test-Path -Path "HKLM:\System\Crowdstrike"

    # Return $true if either exists, meaning CrowdStrike is still installed
    return ($dirExists -or $regKeyExists)
}

function Uninstall-CrowdStrike {
    param (
        [string]$CsUninstallPath
    )

    Write-Host "Starting the uninstallation process..."

    # Run CsUninstallTool.exe
    Start-Process -FilePath $CsUninstallPath -ArgumentList "/quiet" -Wait
    Write-Host "Uninstallation process completed. Verifying status..."

    # Verify uninstallation
    if (Check-CrowdStrikePresence) {
        Write-Error "Uninstallation failed. CrowdStrike is still detected."
        exit 1
    } else {
        Write-Host "CrowdStrike successfully uninstalled."
    }
}

function Reinstall-CrowdStrike {
    param (
        [string]$WindowsSensorPath,
        [string]$CID
    )

    Write-Host "Starting the reinstallation process with CID: $CID"
    Start-Process -FilePath $WindowsSensorPath -ArgumentList "/install /quiet /norestart CID=$CID" -Wait
    Write-Host "Reinstallation process completed. Verifying status..."

    # Verify reinstallation
    if (Check-CrowdStrikePresence) {
        Write-Host "CrowdStrike successfully reinstalled."
    } else {
        Write-Error "Reinstallation failed. CrowdStrike is not detected."
        exit 1
    }
}

function Show-Instructions {
    Write-Host "Please follow the steps below before proceeding:"
    Write-Host "1. Move the host into a Sensor Update Policy with 'Uninstall and Maintenance Protection' disabled."
    Write-Host "2. For detailed guidance, visit: https://supportportal.crowdstrike.com/s/article/ka16T000001xkpzQAA"
    Read-Host -Prompt "Press Enter once these steps are complete to continue"
}

# Display menu
Write-Host "Choose an option:"
Write-Host "1. Uninstall CrowdStrike"
Write-Host "2. Reinstall CrowdStrike"
Write-Host "3. Uninstall and Reinstall CrowdStrike"
$choice = Read-Host "Enter your choice (1, 2, or 3)"

# Common prompts
if ($choice -eq "1" -or $choice -eq "3") {
    $csUninstallPath = Read-Host "Enter the full path to CsUninstallTool.exe"
    if (!(Test-Path $csUninstallPath)) {
        Write-Error "The file '$csUninstallPath' does not exist. Please verify the path."
        exit 1
    }
}
if ($choice -eq "2" -or $choice -eq "3") {
    $windowsSensorPath = Read-Host "Enter the full path to WindowsSensor.exe"
    if (!(Test-Path $windowsSensorPath)) {
        Write-Error "The file '$windowsSensorPath' does not exist. Please verify the path."
        exit 1
    }
    $cid = Read-Host "Enter the CID value"
}

# Perform actions based on user choice
switch ($choice) {
    "1" {
        Show-Instructions
        Uninstall-CrowdStrike -CsUninstallPath $csUninstallPath
    }
    "2" {
        Reinstall-CrowdStrike -WindowsSensorPath $windowsSensorPath -CID $cid
    }
    "3" {
        Show-Instructions
        Uninstall-CrowdStrike -CsUninstallPath $csUninstallPath
        Reinstall-CrowdStrike -WindowsSensorPath $windowsSensorPath -CID $cid
    }
    default {
        Write-Error "Invalid choice. Please run the script again and select 1, 2, or 3."
        exit 1
    }
}

Write-Host "All operations completed successfully."
