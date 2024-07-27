# This is a command line version with the option too specify a file path and login. It is meant to be used for over 50 sites and
# will not stop unless there is a error action when logging in (this prevents it from using the last logged in account)
while ($true){
    Write-Host ""
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "Enter Save file name"
    $defaultdomain = Read-Host 
    $defaultdomain = $defaultdomain.Trim()
   
    #Connect to MSOL
    try{
        Connect-MsolService -ErrorAction Stop


        #Getting global adminsitrator role
        $Globaladminrole = Get-MsolRole | Where-Object {$_.Name -eq "Company Administrator"}
        #Getting global admin user IDs
        $Gloabladminusers = get-msolrolemember -RoleObjectId $Globaladminrole.ObjectId | Select-Object DisplayName,EmailAddress,IsLicensed


        $defaultdomain += ".csv"
        #Output file to selected directory
        if (Test-Path -Path ".\$defaultdomain"){
            Write-Host -ForegroundColor red -BackgroundColor DarkGray "FILE ALREADY EXISTS"
        }
        else{
            $Gloabladminusers | export-csv -Path ".\$defaultdomain" 
            ls
            type ".\$defaultdomain"
        }
    }
    catch{
        Write-Host $_.Exception.Message -ForegroundColor Yellow -BackgroundColor Black}
    
}

