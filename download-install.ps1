function download-install {
    param(
        [Parameter(Mandatory = $true)]
        [string]$url,
        [string]$filename = $null
    )

    # If filename is not provided, extract it from the URL
    if ($filename -eq $null){
        $urlarray = $url -split '/'
        $filename = $urlarray[$urlarray.Length - 1]
    }

    # Construct the full path to download the file
    $path = Join-Path (Get-Location) $filename

    try {
        # Download file using BITS (Background Intelligent Transfer Service)
        Start-BitsTransfer -Source $url -Destination $path -ErrorAction Stop

        # Start the installation process
        Start-Process -FilePath $path -ErrorAction Stop
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
}
