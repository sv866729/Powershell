# Passphase generator
function GeneratePassphrase ([array]$wordlist, [int]$wordcount) {
    $passphrase = ""
    for ($i = 1; $i -le $wordcount; $i++){
        [int]$randomnumber = get-random -Minimum 0 -Maximum $wordlist.Length
        [string]$randomword = $wordlist[$randomnumber]
        [string]$randomnumber = get-random -Minimum 0 -Maximum 9
        $passphrase += [string]$randomword + $randomnumber + "-"
        
    }
    [string]$randomnumber = get-random -Minimum 0 -Maximum 1000
    $passphrase += $randomnumber
    return $passphrase.Trim()
}
