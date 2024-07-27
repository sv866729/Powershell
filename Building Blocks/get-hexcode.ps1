
<#
Author: Samuel Valdez
Function: get-hexcode

Description:
    Converts a decimal value to its hexadecimal representation, ensuring it is formatted to an 8-character code with leading zeros.

Usage:
    1. Run the function:
        get-hexcode -decimalvalue 123
    2. Provide the decimal value to convert to hexadecimal.

Parameters:
    - decimalvalue (mandatory): The decimal value to convert to hexadecimal. If not provided, the function prompts for user input.

#>

function get-hexcode([int]$decimalvalue) {
    if ( $decimalvalue -eq $null ){[int]$decimalvalue = Read-Host "Input bugcheck code" }
    $testvalue = $true
    try{
        # Converstion to hex
        $hex = $decimalvalue.Tostring("x")
        # Counting characters in hex
        $count = $hex.ToString()| Measure-Object -Character
        # Subtract 8 from the number of characters in in hex 
        # this is used to aas all codes have 8 characters and
        # blank characters are 0's
        $zero = 8-$count.Characters
        # Convert previous value into actual 0's
        $zero = $("0" * $zero)
        # Output results
        $hex = "0x$zero$hex"
    }
    catch{
        Write-Host $_.Exception.Message -ForegroundColor Yellow -BackgroundColor Black
        $testvalue = $false
    }
    if ($testvalue){
        return $hex
    }
    else {
        return $false
    }
}