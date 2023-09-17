param(
    [string]$clientID = 'c85f5c98-1c82-45e1-9746-216c097c45cc',
    [Parameter(Mandatory=$true)]
    [string]$clientSecret, # Remember to pass this securely
    [string]$baseURI = "https://login.microsoftonline.com",
    [string]$tenantName = "ashleyhollisoutlook.onmicrosoft.com"
)

# Derived values
$tokenURI = "$baseURI/$tenantName/oauth2/v2.0/token"
$scope = "api://apiapp01/.default"  # Use the ".default" scope for client credentials flow

# Default headers
$headers = @{
    'Accept' = '*/*'
    'Cache-Control' = 'no-cache'
    'Connection' = 'keep-alive'
    'Content-Type' = 'application/x-www-form-urlencoded'
    'Host' = 'login.microsoftonline.com'
    'accept-encoding' = 'gzip, deflate'
}

$body = @{
    'client_id' = $clientID
    'grant_type' = 'client_credentials'
    'client_secret' = $clientSecret
    'scope' = $scope
}

try {
    # Acquire the token
    $response = Invoke-RestMethod -Uri $tokenURI -Method Post -Headers $headers -Body $body
    $accessToken = $response.access_token
    
    # Use the acquired token for authentication
    $authHeaders = @{
        'Authorization' = "Bearer $accessToken"
    }
    
    $authenticatedURI = 'http://localhost:7071/Authenticated'
    $response = Invoke-RestMethod -Uri $authenticatedURI -Headers $authHeaders
    $response
} catch {
    Write-Error "Error occurred: $_"
}
