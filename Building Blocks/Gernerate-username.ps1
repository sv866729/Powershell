<#
Author: Samuel Valdez
Function: Generate-usernames

Description:
    Generates usernames based on first and last names from a CSV file, optionally adding a random number to each username.

Usage:
    1. Run the function:
        Generate-usernames -csvpath "C:\path\to\your\file.csv"
    2. Provide the path to the CSV file containing first and last names.

Parameters:
    - csvpath (mandatory): Path to the CSV file containing first and last names.
    - RemoveFirstRow (optional): If set to $false, includes the first row of the CSV file (default: $true).
    - addrandomnumber (optional): If set to $true, adds a random number to each generated username (default: $true).
    
#>

function Generate-usernames([string]$csvpath,$RemoveFirstRow = $true,$addrandomnumber = $true){
    #Create a array for Usernames to be stored
    $userdata = @()

    #Get file content
    $file = Get-Content -Path $csvpath
    foreach ($line in $file){
        # Skips first line    
        if ($RemoveFirstRow -eq $false){
            # Split first and last name
            $user = $line -split ","
            # Get randomnumber
            if ($addrandomnumber){$randomnumber = Get-Random -Minimum 100 -Maximum 999}
            else{$randomnumber = ""}
            #This gets the first character of the firstname
            # the last name
            # and addes a random 3 character number
            $username = $user[0][0] + $user[1] + $randomnumber
            #Create a custom object
            $userinfo = [PSCustomObject]@{
                'FirstName' = $user[0]
                'LastName' = $user[1]
                'Username' = $username.ToLower()
            }
            #Append each user
            $userdata += $userinfo
        }
        # Makes it go to second line
        else{$RemoveFirstRow = $false}
    }
    return $userdata
}
