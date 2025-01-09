function Get-LatestFirefoxVersion {
    $versionUrl = "https://product-details.mozilla.org/1.0/firefox_versions.json"
    try {
        $json = Invoke-RestMethod -Uri $versionUrl -UseBasicParsing
        Write-Host "Fetched latest Firefox version: $($json.LATEST_FIREFOX_VERSION)"
        return $json.LATEST_FIREFOX_VERSION
    } catch {
        Write-Error "Failed to fetch the latest Firefox version."
        return $false
    }
}

function Get-InstalledFirefoxVersion {
    $exepath = "C:\Program Files\Mozilla Firefox\firefox.exe"
    if (Test-Path $exepath) {
        try {
            $installedVersion = (Get-Item $exepath).VersionInfo.ProductVersion
            Write-Host "Installed Firefox version: $installedVersion"
            return $installedVersion
        } catch {
            Write-Error "Failed to fetch the installed Firefox version."
            return $false
        }
    } else {
        Write-Error "Firefox is not installed at $exepath."
        return $false
    }
}

function Compare-InstalledToLatest {
    try {
        Write-Host "Comparing installed Firefox version with the latest version..."
        $latest = Get-LatestFirefoxVersion
        $installed = Get-InstalledFirefoxVersion
    } catch {
        Write-Host "Unable to process functions for version comparison."
        return $false
    }
    
    if ($latest -eq $installed) {
        Write-Host "The client already has the latest Firefox version: $latest"
        return $true
    } else {
        Write-Host "The installed version ($installed) is not the latest version ($latest)."
        return $false
    }
}

function Install-Firefox {
    $url = "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US"
    $installerPath = "C:\firefox-latest.exe"
    
    Write-Host "Downloading the latest Firefox installer..."
    # Download the latest Firefox installer
    Invoke-WebRequest -Uri $url -OutFile $installerPath
    
    Write-Host "Running Firefox installer silently..."
    # Run the installer silently
    Start-Process -FilePath $installerPath -ArgumentList "/silent" -Wait
    
    Write-Host "Installation completed. Removing the installer file..."
    # Remove the installer after installation
    Remove-Item $installerPath
}

function Update-FireFox {
    Write-Host "Starting Firefox update process..."
    
    if (Compare-InstalledToLatest) {
        Write-Host "No update needed. The client has the latest version."
    } else {
        Write-Host "An update is required. Installing the latest version of Firefox..."
        Install-Firefox
        Write-Host "Firefox has been updated successfully."
    }
}

# Call the update function to trigger the process
Update-FireFox
