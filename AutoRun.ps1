<#

Author of scirpt: Samuel Valdez
Creation Date: 6/9/2024

This file is meant to be ran as a schedule task.

Modifications needed:
    1. Updating Zip URL as needed
    2. Changing Company name

Company Name is the location on the C Drive where reports will be set.

This script is used to download and run the Autorunsc.exe and pull the results and compare them from yesterdays.
This is meant to be on a machine that is backed up daily so autorun tasks can be tacked and compared for easy
incidents responce for possible malware.

Usage: 
    1. Complete Modifications
    2. Create a Daily Scheduled task
    3. Pull results to a with RMM

Recommended modification:
    1. Set the output to go to a RMM tool to track verbose output
    2. Set RMM tool to check the comparision file for data daily on servers to report changes

Information:
    The comparision will show when the first line where data is different starts doing a line by line comparision.

#>


#Setting contstants
$AutoRunUri = "https://download.sysinternals.com/files/Autoruns.zip"
$COMPANYNAME = "Samv123INC"
#Checking for Installation Directory and verifying permissions to edit C: Drive
try{
    if (Test-Path "C:\$COMPANYNAME"){
        Write-Host "Verbose: $COMPANYNAME Folder is already Created"
    }
    else{
        new-item -Path "C:\" -ItemType Directory -Name "$COMPANYNAME"
        Write-Host "Verbose: $COMPANYNAME Folder Created"
    }
}
catch{
    Write-Host "Error: Unable to Access C Drive to create folder"
    exit
}


# Downloading Auto Run and expanding zip and deleting old zip
try{

    # Testing if it is already installed
    if (Test-Path "C:\$COMPANYNAME\Autoruns"){
        Write-Host "Verbose: AutoRun is already installed"
    }

    else{
        Start-BitsTransfer -Source $AutoRunUri -Destination "C:\$COMPANYNAME\Autoruns.zip"
        Write-host "Verbose: AutoRun Zip Downloaded"
        Expand-Archive -Path "C:\$COMPANYNAME\Autoruns.zip"-DestinationPath "C:\$COMPANYNAME\Autoruns"
        Write-Host "Verbose: Auto Run Unzipped"
        Remove-Item -Path "C:\$COMPANYNAME\Autoruns.zip"
        Write-Host "Verbose: Autoruns.zip has been deleted"
        
    }

}
catch{
    Write-Host "Error: A issue occured when attempting to install AutoRun"
    exit
}


# Run the scan ############Error######### File path on auto run
try{
    Write-Host "Verbose: Getting Date"
    [string]$date = Get-Date -Format MMddyyyy
    $datepath = "C:\$COMPANYNAME\" + $date + "autorun.csv"

    # Timing command output
    Write-Host "Verbose: Starting AutoRun Scan"
    $time = Measure-Command -Expression{
        $command = "C:\$COMPANYNAME\Autoruns\autorunsc.exe"
        & $command | out-file -FilePath $datepath
    }

    Write-Host "Verbose: Scan took $time.Seconds"
}
catch{
    Write-Host "Error: A Error occured when running todays scan" 
    exit 
}


# Compare to the file from yesterday and remove yesterdays
try{
    Write-Host "Verbose: Getting Yesterdays date"
    $yesterdaydate = (Get-Date).AddDays(-1).ToString('MMddyyyy')
    $yesterdayfile = "C:\$COMPANYNAME\" + $yesterdaydate + "autorun.csv"

    if (Test-Path $yesterdayfile){
        Write-Host "Verbose: A file from yesterday was found"
        $yesterday = $true
        $yesterdaydata = Get-Content -Path $yesterdayfile
        $todaysdata = Get-Content -Path $datepath

        Remove-Item -Path "C:\$COMPANYNAME\AutoRunDifferences.csv" -ErrorAction SilentlyContinue
        Write-Host "Verbose: Removing yesterdays Comparision"

        Compare-Object -ReferenceObject $yesterdaydata -DifferenceObject $todaysdata | export-csv "C:\$COMPANYNAME\Comparisionautoruns.csv"
        Write-Host "Verbose: Comparison CSV Saved"

        Remove-Item -Path $yesterdayfile
        Write-Host "Verbose: Yesterdays file removed"

        }
    else{
        $yesterday = $false
        Write-Host "End: No file found for yesterday to compare to"
        exit
        }
}
catch{
    Write-Host "Error: A Error occur when comparing files"
    exit
}

$contents = Get-Content .\Comparisionautoruns.csv
if ($contents -ne $null){
    Write-Host "Verbose: Differnece in AutoStartups from yesterday"
}

Write-Host "End: Completed Successfully"