<#
Author: Samuel Valdez
Function: error-handling

Description:
    Executes a command and handles errors gracefully, providing customizable messages for success and failure.

Usage:
    1. Run the function:
        error-handling -command "YourCommandHere"
    2. Specify the command to execute.

Parameters:
    - command (mandatory): The command to execute.
    - Successful_message (optional): Custom message displayed on successful execution (default: "Successfully executed: $command").
    - error_message (optional): Custom message displayed on error (default: "Error executing: $command").
    - error_command (optional): Command to execute upon encountering an error (default: 'return').

#>
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
