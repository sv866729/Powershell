function Get-Location {
    param (
        [string]$ipAddress
    )
    #
    # Make a request to the API
    $url = "https://ipapi.co/$ipAddress/json/"
    $response = Invoke-RestMethod -Uri $url -Method Get

    # Create a custom object to store the location data
    $locationData = [PSCustomObject]@{
        ip      = $ipAddress
        city    = $response.city
        region  = $response.region
        country = $response.country_name
    }

    return $locationData
}

# Example usage:
$location = Get-Location -ipAddress "8.8.8.8"
$location
