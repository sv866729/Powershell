
# Load All Funtions into Running Program.
function Load-Functions {
    param(
        [string]$folderName = "Scripts"  # Default folder name is "Application"
    )

    $pwd = Get-Location
    $scriptFolder = Join-Path $pwd $folderName

    # Check if the folder exists
    if (Test-Path $scriptFolder) {
        # Get all PowerShell script files in the folder
        $scriptFiles = Get-ChildItem -Path $scriptFolder -Filter *.ps1

        # Load each script into the session
        foreach ($script in $scriptFiles) {
            Write-Host "Loading script: $($script.FullName)"
            . $script.FullName
        }
    }
    else {
        Write-Host "The specified folder '$folderName' does not exist."
    }
}

# Create all  the Directorys
function Create-ForensicsDirectories {
    # Define the main directory and subdirectories
    $directories = @(
        "C:\forensics",
        "C:\forensics\cpu",
        "C:\forensics\NetworkInfo",
        "C:\forensics\EventLogs",
        "C:\forensics\usersandgroup",
        "C:\forensics\externaldevices",
        "C:\forensics\Applications",
        "C:\forensics\MemoryImage",
        "C:\forensics\FileSystemMap",
        "C:\forensics\FeaturesAndRoles",
        "C:\forensics\CPUCaching"
    )

    # Create each directory if it does not exist
    foreach ($directory in $directories) {
        if (-not (Test-Path -Path $directory)) {
            New-Item -Path $directory -ItemType Directory
            Write-Host "Directory created: $directory"
        } else {
            Write-Host "Directory already exists: $directory"
        }
    }
}


function main{
    # Load all scripts
    Load-Functions
    # Create all Required folders
    Create-ForensicsDirectories
    
}