<#
#Test
Author of scirpt: Samuel Valdez
Creation Date: 6/9/2024

This file is meant to be ran as a schedule task.

Modifications needed:
    1. Updating Zip URL as needed
    2. Change Save Directory

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




######################
# Setting contstants #
######################
$AutoRunUri = "https://download.sysinternals.com/files/Autoruns.zip"
$SaveDirectory = "C:\Users\svaldez\Desktop\Project\2024\AutoRuns\TestingData"
# How many days do you want to save on the machine before it gets deleted
[Int32]$daysToSave = 90
######################



$runerrors = $false

#######################################
# Checking for Installation Directory #
#######################################
try{
    if (Test-Path "$SaveDirectory"){
        Write-Host "Verbose: $SaveDirectory Folder is already Created"
    }
    else{
        new-item -Path $SaveDirectory -ItemType Directory
        Write-Host "Verbose: $SaveDirectory Folder Created"
    }
}
catch{
    Write-Host "Error: Unable to add folder"
    $runerrors = $true
}
#######################################


###############################################################
# Downloading Auto Run and expanding zip and deleting old zip #
###############################################################
try{

    # Testing if it is already installed
    if (Test-Path "$SaveDirectory\Autoruns"){
        Write-Host "Verbose: AutoRun is already installed"
    }

    else{
        Start-BitsTransfer -Source $AutoRunUri -Destination "$SaveDirectory\Autoruns.zip"
        Write-host "Verbose: AutoRun Zip Downloaded"
        Expand-Archive -Path "$SaveDirectory\Autoruns.zip"-DestinationPath "$SaveDirectory\Autoruns"
        Write-Host "Verbose: Auto Run Unzipped"
        Remove-Item -Path "$SaveDirectory\Autoruns.zip"
        Write-Host "Verbose: Autoruns.zip has been deleted"
        
    }

}
catch{
    Write-Host "Error: A issue occured when attempting to install AutoRun"
    $runerrors = $true
}
###############################################################



################
# Run the scan #
################
Write-Host "Verbose: Getting Date"
[string]$date = Get-Date -Format MMddyyyy

try{
    
    $datepath = "$SaveDirectory\" + $date + "autorun.arn"

    # Timing command output and running scan
    Write-Host "Verbose: Starting AutoRun Scan"
    $time = Measure-Command -Expression{
        $command = "$SaveDirectory\Autoruns\autorunsc.exe"
        & $command | out-file -FilePath $datepath
    }

    Write-Host "Verbose: Scan took $time.Seconds"
}
catch{
    Write-Host "Error: A Error occured when running todays scan" 
    $runerrors = $true 
}
################



############################
# Getting Past Informatoin #
############################
# Getting yesterdays information

Write-Host "Verbose: Getting Past information"

$yesterdaydate = (Get-Date).AddDays(-1).ToString('MMddyyyy')
$yesterdayfile = "$SaveDirectory\" + $yesterdaydate + "autorun.arn"
$testyesterday = (Test-Path $yesterdayfile)

# Getting file to delete
$lastmonthday = (Get-Date).AddDays(-$daysToSave).ToString('MMddyyyy')
$lastmonthdayfile = "$SaveDirectory\" + $lastmonthday + "autorun.arn"
$testlastmonth = (Test-Path $lastmonthdayfile)
############################



#####################
# Removing old file #
#####################
try {
    if($testlastmonth){
        Remove-Item -LiteralPath $lastmonthdayfile
        Write-Host "Verbose: Deleting last months file"
    }
    else {
        Write-Host "Verbose: No Baseline older than $daysToSave Days"
    }
}
catch {
    Write-Host "Error: Not able to delete $lastmonthdayfile"
    $runerrors = $true
}
#####################



#########################
# Getting file contents #
#########################
$yesterdayContent = $null
$todayContent = $null
try {
    if ($testyesterday){
        $yesterdayContent = Get-Content -LiteralPath $yesterdayfile
        $todayContent = get-content -LiteralPath $datepath
        Write-Host "Verbose: Got File Content"
    }
    else {
        Write-Host "End: No File to compare to"
        exit
    }
}
catch {
    Write-Host "Error: A error occured when getting file data"
    $runerrors = $true
}

#########################



##########################################
# Comparing yesterday and todays content #
##########################################

$filedifference = $false

if ($yesterdayContent -ne $todayContent){
    Write-Host "Verbose: Difference in Files"
    $filedifference = $true
}
##########################################



############################
# Test and create Log File #
############################
$logpath = "$SaveDirectory\logfile_autorun.csv"
$logpathtest = Test-Path $logpath

if($logpathtest){
    write-host "Verbose: Log file already exists"
}
else{
    new-item -Path $logpath -ItemType File
    Write-Host "Verbose: Log file created"
}
############################



#####################
# Creating log data #
#####################
#Holds log data
$logoutput = @()

#Error log
$errorouput = [PSCustomObject]@{
    Event = "RunError"
    EventDate = $date
}

#Differnece log
$differencelog = [PSCustomObject]@{
    Event = "Difference"
    EventDate = $date
}

#adding log data
if($filedifference){
    $logoutput += $differencelog
}

#adding log data
if($runerrors){
    $logoutput += $errorouput
}

Write-Host "Verbose: Adding Data to log Object"
#####################



#####################
# Write to log file #
#####################
$logoutput | export-csv $logpath -Append
#####################
