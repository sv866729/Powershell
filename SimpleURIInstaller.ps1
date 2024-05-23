
[string]$URL= Read-Host "Enter installer URL"
[string]$Path="C:\WINDOWS\Temp\installer.exe"
Start-BitsTransfer -Source $URL -Destination $Path
start-process -filepath $Path