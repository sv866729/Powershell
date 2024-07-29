function dot-timer{
    param(
        [int]
        $seconds = 30
    )
    for ($i = 0; $i -lt $seconds; $i++) {
    Write-Host -NoNewline "."
    Start-Sleep -Seconds 1
    }
    Write-Host ""
}
