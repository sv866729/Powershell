#Created by: Samuel Valdez
#Date: 12/13/2024
# Usage: This  is used to disable to Unattented remote access of anydesk, Disable network discover, and to disable access prompts on a device.


$anydeskPath = "C:\ProgramData\AnyDesk\system.conf"

if (Test-Path $anydeskPath) {
    # Configuration Change Variable
    $configFileContent = Get-Content -Path $anydeskPath

    # Unattended Access
    $passwordConfig = "ad.security.permission_profiles._unattended_access.pwd="
    $saltConfig = "ad.security.permission_profiles._unattended_access.salt="
    $unattendedAccessPW = Select-String -Path $anydeskPath -Pattern $passwordConfig
    $unattendedAccessSalt = Select-String -Path $anydeskPath -Pattern $saltConfig

    if ($unattendedAccessPW -or $unattendedAccessSalt) {
        Write-Host "Unattended access: Enabled"

        if ($unattendedAccessPW) {
            $configFileContent = $configFileContent -replace [regex]::Escape($unattendedAccessPW.Line), ""
        }

        if ($unattendedAccessSalt) {
            $configFileContent = $configFileContent -replace [regex]::Escape($unattendedAccessSalt.Line), ""
        }
    } elseif (!$unattendedAccessPW -and !$unattendedAccessSalt) {
        Write-Host "Unattended access: Disabled"
    }

    # Interactive Access Disabled
    $InteractiveAccessConfig = "ad.security.interactive_access="
    $InteractiveAccessSetting = Select-String -Path $anydeskPath -Pattern $InteractiveAccessConfig
    $InteractiveAccessDesired = "ad.security.interactive_access=2"

    if ($InteractiveAccessSetting) {
        if ($InteractiveAccessSetting.Line -ne $InteractiveAccessDesired) {
            Write-Host "Prompting: Allowed"
            $configFileContent = $configFileContent -replace [regex]::Escape($InteractiveAccessSetting.Line), "$InteractiveAccessDesired"
        } else {
            Write-Host "Prompting: Disabled"
        }
    } else {
        Write-Host "Interactive Access: Not Present"
        $configFileContent += "$InteractiveAccessDesired"
    }

    # Network Discovery
    $NetworkDiscoveryConfig = "ad.discovery.hidden="
    $NetworkDiscoverySetting = Select-String -Path $anydeskPath -Pattern $NetworkDiscoveryConfig
    $NetworkDiscoveryDesired = "ad.discovery.hidden=true"

    if ($NetworkDiscoverySetting) {
        if ($NetworkDiscoverySetting.Line -ne $NetworkDiscoveryDesired) {
            Write-Host "Network Hidden: False"
            $configFileContent = $configFileContent -replace [regex]::Escape($NetworkDiscoverySetting.Line), "$NetworkDiscoveryDesired"
        } else {
            Write-Host "Network Hidden: True"
        }
    } else {
        Write-Host "Network Hidden: Not Present"
        $configFileContent += "$NetworkDiscoveryDesired"
    }

    # Setting file contents
    Set-Content -Path $anydeskPath -Value $configFileContent
} else {
    Write-Host "Configuration file not found."
}
