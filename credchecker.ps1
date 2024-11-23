Install-Module Posh-SSH
Import-Module Posh-SSH
$IPs = @(

)


$creds = get-Credential

$results = @()

foreach ($ip in $IPs){
   $result = New-SSHSession -ComputerName $ip -Port "22" -Credential $creds -AcceptKey:$AcceptKey -ErrorAction SilentlyContinue
   $result
   $results += $result 
}
