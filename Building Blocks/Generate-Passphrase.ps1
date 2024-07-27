# Passphase generator
<#
Author: Samuel Valdez
Function: Generate-Passphrase

Description:
    Generates a passphrase using a specified word list and number of words, appending a random number at the end.

Usage:
    1. Run the function:
        Generate-Passphrase -wordlist @("word1", "word2", "word3") -wordcount 4
    2. Provide a word list and specify the number of words to include in the passphrase.

Parameters:
    - wordlist (mandatory): An array of words to construct the passphrase.
    - wordcount (mandatory): Number of words to include in the passphrase.
    
#>
function Generate-Passphrase ([array]$wordlist, [int]$wordcount) {
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
