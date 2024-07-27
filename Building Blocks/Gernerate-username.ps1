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
