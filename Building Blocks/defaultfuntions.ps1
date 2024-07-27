#############################################
# Basic error handling for running commands #
#############################################

function error-handling {
    param(
        [Parameter(Mandatory=$true)]
        [string]$command,
        [string]$Successful_message = "Successfully executed: $command",
        [string]$error_message = "Error executing: $command",
        [string]$error_command = 'return'
    )
    
    try {
        Invoke-Expression $command
        Write-Host $Successful_message -ForegroundColor Green
    }
    catch {
        Write-Host $error_message -ForegroundColor Red
        Invoke-Expression $error_command
    }
}

################################
# Install the module if needed #
################################

function Install-ModuleIfNeeded {
    param (
        [string]$ModuleName
    )
    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        try {
            Install-Module -Name $ModuleName -Scope CurrentUser -Force
            Write-Host "Module $ModuleName installed successfully." -ForegroundColor Green
        } catch {
            Write-Host "Failed to install module $ModuleName. Error: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Module $ModuleName is already installed." -ForegroundColor Yellow
    }
}
