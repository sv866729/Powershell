function Export-ExternalDevices {
    param (
        [string]$externalDevicesPath = "C:\forensics\externaldevices"
    )

    # Check if the folder exists, and create it if it doesn't
    if (-not (Test-Path -Path $externalDevicesPath)) {
        New-Item -Path $externalDevicesPath -ItemType Directory
    }

    # Export USB Devices
    Get-WmiObject Win32_USBHub | Select-Object DeviceID, PNPDeviceID, Description | Export-Csv -Path "$externalDevicesPath\usb_devices.csv" -NoTypeInformation

    # Export Network Adapters
    Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, MacAddress | Export-Csv -Path "$externalDevicesPath\network_adapters.csv" -NoTypeInformation

    # Export Storage Devices
    Get-WmiObject Win32_DiskDrive | Select-Object DeviceID, Model, MediaType, Size | Export-Csv -Path "$externalDevicesPath\storage_devices.csv" -NoTypeInformation

    # Export Connected Devices
    Get-WmiObject -Class Win32_PnPEntity | Select-Object DeviceID, PNPDeviceID, Caption | Export-Csv -Path "$externalDevicesPath\connected_devices.csv" -NoTypeInformation

    # Export Bluetooth Devices
    Get-WmiObject Win32_PnPEntity | Where-Object { $_.Caption -like "*Bluetooth*" } | Select-Object DeviceID, Caption | Export-Csv -Path "$externalDevicesPath\bluetooth_devices.csv" -NoTypeInformation

    # Export Printers
    Get-WmiObject Win32_Printer | Select-Object Name, DeviceID, Status, PortName | Export-Csv -Path "$externalDevicesPath\printers.csv" -NoTypeInformation

    # Export Installed Drivers (including shared drivers)
    Get-WmiObject Win32_PnPSignedDriver | Select-Object DeviceName, DriverVersion, Manufacturer, InfName, PNPDeviceID | Export-Csv -Path "$externalDevicesPath\drivers.csv" -NoTypeInformation

    # Export Shared Resources
    net share | Export-Csv -Path "$externalDevicesPath\shared_resources.csv" -NoTypeInformation
}
