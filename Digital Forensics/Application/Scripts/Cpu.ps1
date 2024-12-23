# Function Description: collect-CPUForensicsData
# Collects detailed information about CPU performance, running processes, system memory, and caching. It includes data on process handles, system uptime, and CPU usage by process.
function collect-CPUForensicsData {
    param (
        [string]$cpuFolder = "C:\forensics\cpu"
    )

    # Check if the folder exists, and create it if it doesn't
    if (-not (Test-Path -Path $cpuFolder)) {
        New-Item -Path $cpuFolder -ItemType Directory
    }

    # Get all processes and their file paths and cmd execute arguments
    Get-Process | Select-Object Name, Id, Path, @{Name="CommandLine";Expression={(Get-WmiObject Win32_Process -Filter "ProcessId = '$($_.Id)'").CommandLine}} | Export-Csv -Path "$cpuFolder\ProcessInfo.csv" -NoTypeInformation

    # Processor Information
    Get-WmiObject Win32_Processor | Select-Object Name, ProcessorId, MaxClockSpeed, CurrentClockSpeed, NumberOfCores, NumberOfLogicalProcessors | Export-Csv -Path "$cpuFolder\CPUInfo.csv"

    # Processes running
    Get-Process | Select-Object Name, Id, CPU, WorkingSet, Path | Export-Csv -Path "$cpuFolder\Processes.csv" -NoTypeInformation

    # Processor usage and load
    Get-WmiObject Win32_PerfFormattedData_PerfProc_Process | Select-Object Name, PercentProcessorTime | Sort-Object PercentProcessorTime -Descending | Export-Csv -Path "$cpuFolder\CPUByProcess.csv"

    # Caching and performance counters
    Get-Counter -Counter '\Cache\*' | Export-Csv -Path "$cpuFolder\CPUCaching.csv"

    # Boot Time
    Get-WmiObject Win32_OperatingSystem | Select-Object LastBootUpTime, @{Name="Uptime";Expression={(Get-Date) - $_.LastBootUpTime}} | Export-Csv -Path "$cpuFolder\SystemUptime.csv"

    # Process handles and Modules
    Get-Process | Select-Object Name, Id, @{Name="Handles";Expression={$_.HandleCount}}, @{Name="Modules";Expression={($_.Modules | Select-Object -ExpandProperty ModuleName) -join ", "}} | Export-Csv -Path "$cpuFolder\ProcessHandles.csv" -NoTypeInformation

    # System Memory Info
    Get-WmiObject Win32_OperatingSystem | Select-Object TotalVisibleMemorySize, FreePhysicalMemory, TotalVirtualMemorySize, FreeVirtualMemory | Export-Csv -Path "$cpuFolder\SystemMemoryInfo.csv"
}