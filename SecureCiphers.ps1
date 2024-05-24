# This is used to disable weakCiphers on a windows machine. I believe this is not a issue anymore but once was.
$DHE_CipherSuites = "TLS_DHE_RSA_WITH_AES_128_CBC_SHA", "TLS_DHE_RSA_WITH_AES_128_CBC_SHA256", "TLS_DHE_RSA_WITH_AES_128_CCM", "TLS_DHE_RSA_WITH_AES_128_CCM_8", "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_DHE_RSA_WITH_AES_256_CBC_SHA", "TLS_DHE_RSA_WITH_AES_256_CBC_SHA256", "TLS_DHE_RSA_WITH_AES_256_CCM", "TLS_DHE_RSA_WITH_AES_256_CCM_8", "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384", "TLS_DHE_RSA_WITH_ARIA_128_GCM_SHA256", "TLS_DHE_RSA_WITH_ARIA_256_GCM_SHA384", "TLS_DHE_RSA_WITH_CAMELLIA_128_CBC_SHA", "TLS_DHE_RSA_WITH_CAMELLIA_128_CBC_SHA256", "TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA", "TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA256", "TLS_DHE_RSA_WITH_CHACHA20_POLY1305_SHA256"
# Disable each cipher
foreach ($cipherSuite in $DHE_CipherSuites) {
    try {
        disable-TlsCipherSuite -Name $cipherSuite
        Write-Host -ForegroundColor Green "$cipherSuite was Disabled"

    }
    catch {
        write-host -ForegroundColor red "The $ciphersuite is already disabled"
    }
}
    