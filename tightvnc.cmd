#Check Version
powershell -command "(Get-Item 'C:\Program Files\TightVNC\tvnserver.exe').VersionInfo.FileVersion; (Get-Item 'C:\Program Files\TightVNC\tvnviewer.exe').VersionInfo.FileVersion"

#Update
powershell -command "$folderPath = 'C:\Program Files\TightVNC'; $installerUrl = 'https://www.tightvnc.com/download/2.8.85/tightvnc-2.8.85-gpl-setup-64bit.msi'; $installerPath = 'C:\tightvnc-2.8.85.msi'; if (Test-Path $folderPath) { Write-Host 'Folder exists. Proceeding with download and installation…'; Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath; Start-Process -FilePath 'msiexec.exe' -ArgumentList '/i `"C:\tightvnc-2.8.85.msi`" /quiet /norestart' -Wait; Write-Host 'Installation completed.' } else { Write-Host 'Folder does not exist. No action taken.' }"
