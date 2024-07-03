#Basic Error handling funtion to reduce code amount
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
