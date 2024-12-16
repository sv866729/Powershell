#Check if anydesk is installed:
$anydeskpath = test-path "C:\Program Files (x86)\AnyDesk\AnyDesk.exe"
if ($anydeskpath){
    #Check if Config file exists 
    $anydeskconfigpath = "C:\ProgramData\AnyDesk\system.conf"
    $anydeskconfigexists = Test-Path $anydeskconfigpath
    #Check for unattended access
    $passwordConfig = "ad.security.permission_profiles._unattended_access.pwd="
    $saltConfig = "ad.security.permission_profiles._unattended_access.salt="
    $unattendedAccessPW = Select-String -Path $anydeskconfigpath -Pattern $passwordConfig
    $unattendedAccessSalt = Select-String -Path $anydeskconfigpath -Pattern $saltConfig
    $unattendedaccess = $unattendedAccessPW -ne $null -or $unattendedAccessSalt -ne $null
    #Check if device is discoverable
    $NetworkDiscoveryConfig = "ad.discovery.hidden="
    $NetworkDiscoverySetting = Select-String -Path $anydeskconfigpath -Pattern $NetworkDiscoveryConfig
    $NetworkDiscoveryDesired = "ad.discovery.hidden=true"
    $NetworkDiscovery = $NetworkDiscoverySetting.Line -ne $NetworkDiscoveryDesired
    #Check for Prompting
    $InteractiveAccessConfig = "ad.security.interactive_access="
    $InteractiveAccessSetting = Select-String -Path $anydeskconfigpath -Pattern $InteractiveAccessConfig
    $InteractiveAccessDesired = "ad.security.interactive_access=2"
    $InteractivecAccess = $InteractiveAccessSetting.Line -ne $InteractiveAccessDesired


    # This is the logic that and result format the I want for the dataview so I can see what clients
    # Have unattended access configured so we can reachout and see why
    $anydesksettings = [PSCustomObject]@{
        UnattenedAccess = if ($unattendedaccess){"Enabled"}else{"Disabled"}
        DeviceDiscoverable = if($NetworkDiscovery){"Enabled"}else{"Disabled"}
        InteracticeAccess =  if($InteractivecAccess){"Enabled"}else{"Disbaled"}
    }

}
