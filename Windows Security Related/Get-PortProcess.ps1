<#
Author: Samuel Valdez
Function: Get-PortProcess

Description:
    Retrieves detailed information about the process that is listening on a specified TCP port. This function provides data about the process, its parent process, executable file properties, and digital signature details.

Usage:
    1. Run the function with the desired port number:
        Get-PortProcess -Port <PortNumber>

    Example:
        Get-PortProcess -Port 80

Notes:
    - Ensure you run this function with appropriate permissions to access process and file information.
    - The function provides information including executable path, file timestamps, SHA256 hash, and certificate details.

#>

function Get-PortProcess {
    param (
        [int]$Port
    )

    # Basic error handling using the stop method for failure
    try {
        # Get the TCP connection details based on the local port
        $portInformation = Get-NetTCPConnection -LocalPort $Port -ErrorAction Stop
        $portInformation = $portInformation[0]

        # Extract the process ID from the TCP connection information
        $processID = $portInformation.OwningProcess
        
        # Retrieve process information using Win32_Process
        $processInformation = Get-CimInstance -Class Win32_Process -Filter "ProcessId = $processID" -ErrorAction Stop
        
        # Get file hash of the executable
        $hash = Get-FileHash -Path $processInformation.ExecutablePath -ErrorAction Stop
        
        # Retrieve file information
        $fileInformation = Get-ItemProperty -Path $processInformation.ExecutablePath -ErrorAction Stop
        
        # Get file signature information
        $signatureInformation = Get-AuthenticodeSignature -FilePath $processInformation.ExecutablePath -ErrorAction Stop
        
        # Extract parent process information
        $parentPID = $processInformation.ParentProcessId
        $parentProcess = Get-CimInstance -Class Win32_Process -Filter "ProcessId = $parentPID" -ErrorAction Stop

        # Create a custom object with all the collected information
        $returnValue = [PSCustomObject]@{
            'ProcessName'                = $processInformation.Name
            'PID'                        = $processInformation.ProcessId
            'ParentProcess'              = $parentProcess.Name
            'PPID'                       = $parentProcess.ProcessId
            'Port'                       = $Port
            'PortStatus'                 = $portInformation.State
            'ExePath'                    = $processInformation.ExecutablePath
            'ExeCreationTime'            = $fileInformation.CreationTime
            'ExeLastAccessTime'          = $fileInformation.LastAccessTime
            'ExeLastWriteTime'           = $fileInformation.LastWriteTime
            'ExeSHA256'                  = $hash.Hash
            'CertificateStatus'          = $signatureInformation.Status
            'CertificateSubject'         = $signatureInformation.SignerCertificate.Subject
            'CertificateIssuer'          = $signatureInformation.SignerCertificate.Issuer
            'CertificateSerialNumber'    = $signatureInformation.SignerCertificate.SerialNumber
        }
        
        # Return the custom object
        return $returnValue
    }
    catch {
        # Handle exceptions and display error messages
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}
