# This is a function that takes in a port and provides information regarding it and the associated process

# Defining function
function get-portprocess ([int]$port) {
    # Basic error handling using the stop method for failure
    try {
        # Get the PID based on port and other information regarding the connection
        $portinformation = Get-NetTCPConnection -LocalPort $port -ErrorAction Stop
        $portinformation = $portinformation[0]

        # Get values of the process ID (remember that it's an array)
        $processID = $portinformation.OwningProcess
        
        # Using Win32 process as it contains more information
        $processinformation = Get-CimInstance -Class Win32_Process -Filter "ProcessId = $processID" -ErrorAction Stop
        # Get the hashes SHA1, 
        $hash = Get-FileHash -Path $processinformation.ExecutablePath -ErrorAction Stop
        # Get File information
        $fileinformation = Get-ItemProperty $processinformation.ExecutablePath -ErrorAction Stop
        # Get file signature information
        $signatureinformation = Get-AuthenticodeSignature -FilePath $processinformation.ExecutablePath -ErrorAction Stop
        # Get parent ID
        $parentpid = $processinformation.ParentProcessId
        # Get parent information
        $parent_process = Get-CimInstance -Class Win32_Process -Filter "ProcessId = $parentpid" -ErrorAction Stop
 

    
    # Custom return object
    $returnvalue = [PSCustomObject]@{
        'ProcessName' = $processinformation.Name
        'PID' = $processinformation.ProcessId
        'ParentProcess' = $parent_process.Name
        'PPID' = $parent_process.ProcessId
        'Port' = $port
        'PortStatus' = $portinformation.State
        'ExePath' = $processinformation.Path
        'ExeCreationTime' = $fileinformation.CreationTime
        'ExeLastAccessTime' = $fileinformation.LastAccessTime
        'ExeLastWriteTime' = $fileinformation.LastWriteTime
        'ExeSHA256' = $hash.Hash
        'CertificateStatus' = $signatureinformation.Status
        'CertificateSubject' = $signatureinformation.SignerCertificate.Subject
        'CertificateIssuer' = $signatureinformation.SignerCertificate.Issuer
        'CertificateSerialNumber' = $signatureinformation.SignerCertificate.SerialNumber
    }
    # Return Value for funtion
    return $returnvalue
    # Write out error message
    catch {
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}
