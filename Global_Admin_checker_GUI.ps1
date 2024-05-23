
# This script will prompt a user to sign into m365 and select a file location and full a list of all global admins to a csv
# This is easy for when you need to audit a couple sites real quick(+10)

#Install msol online if not installed
$checkinstall = Get-Module -Name MSOnline
if ($checkinstall -eq $null){
    Install-Module MSOnline
}
try{
    #Connect to MSOL
    Connect-MsolService -ErrorAction Stop
    Write-Host -ForegroundColor Red  "Press enter to select a folder to store list of Global Admins" 
    Read-Host 
    #Folder Browing object
    Add-Type -AssemblyName System.Windows.Forms
    # Create a new FolderBrowserDialog object
    $FolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderBrowserDialog.ShowDialog()
    # Folder that was selected
    $SelectedFolder = $FolderBrowserDialog.SelectedPath
    #Chand PWD to selected folder for CSV
    cd $SelectedFolder

    #Getting global adminsitrator role
    $Globaladminrole = Get-MsolRole | Where-Object {$_.Name -eq "Company Administrator"}
    #Getting global admin user IDs
    $Gloabladminusers = get-msolrolemember -RoleObjectId $Globaladminrole.ObjectId | Select-Object DisplayName,EmailAddress,IsLicensed


    #Get comany Domain to name file
    $domains = get-msoldomain
    $defaultdomain = $null
    foreach ($domain in $domains){
        if ($domain.IsDefault -eq "True"){
        $defaultdomain = $domain.Name
        }
    }
    #Append CSV for file name
    $defaultdomain += ".csv"

    #Output file to selected directory
    $Gloabladminusers | export-csv -Path ".\$defaultdomain" 
}
catch{
    Write-Host $_.Exception.Message -ForegroundColor Yellow -BackgroundColor Black
}