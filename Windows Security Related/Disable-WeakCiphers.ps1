<#
Author: Samuel Valdez
Function: Disable-WeakCiphers

Description:
    Disables a list of weak cipher suites on a Windows machine. This script iterates over a predefined list of cipher suites and disables each one. It handles errors and provides feedback on the success or failure of disabling each cipher suite.

Usage:
    1. Run the function to disable the weak cipher suites:
        Disable-WeakCiphers

Notes:
    - This function disables specific TLS cipher suites that were considered weak.
    - Ensure you have the appropriate permissions to modify system security settings.
    - The provided cipher suites may be outdated; check current security recommendations.

#>

function Disable-WeakCiphers {
    # List of DHE cipher suites to disable
    $DHE_CipherSuites = @(
        "TLS_DHE_RSA_WITH_AES_128_CBC_SHA",
        "TLS_DHE_RSA_WITH_AES_128_CBC_SHA256",
        "TLS_DHE_RSA_WITH_AES_128_CCM",
        "TLS_DHE_RSA_WITH_AES_128_CCM_8",
        "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256",
        "TLS_DHE_RSA_WITH_AES_256_CBC_SHA",
        "TLS_DHE_RSA_WITH_AES_256_CBC_SHA256",
        "TLS_DHE_RSA_WITH_AES_256_CCM",
        "TLS_DHE_RSA_WITH_AES_256_CCM_8",
        "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384",
        "TLS_DHE_RSA_WITH_ARIA_128_GCM_SHA256",
        "TLS_DHE_RSA_WITH_ARIA_256_GCM_SHA384",
        "TLS_DHE_RSA_WITH_CAMELLIA_128_CBC_SHA",
        "TLS_DHE_RSA_WITH_CAMELLIA_128_CBC_SHA256",
        "TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA",
        "TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA256",
        "TLS_DHE_RSA_WITH_CHACHA20_POLY1305_SHA256",
        "TLS_DHE_DSS_WITH_AES_128_CBC_SHA",         # Added
        "TLS_DHE_PSK_WITH_AES_256_CBC_SHA",         # Added
        "TLS_DHE_RSA_WITH_SEED_CBC_SHA"             # Added
    )


    # Disable each cipher suite
    foreach ($cipherSuite in $DHE_CipherSuites) {
        try {
            # Attempt to disable the cipher suite
            disable-TlsCipherSuite -Name $cipherSuite
            Write-Host -ForegroundColor Green "$cipherSuite was Disabled"
        }
        catch {
            # Handle the error if the cipher suite is already disabled
            Write-Host -ForegroundColor Red "The $cipherSuite is already disabled or an error occurred"
        }
    }
}
