param(
    [string]$clientID = 'c85f5c98-1c82-45e1-9746-216c097c45cc',
    [Parameter(Mandatory=$true)]
    [string]$clientSecret, # Remember to pass this securely
    [string]$baseURI = "https://login.microsoftonline.com",
    [string]$tenantName = "ashleyhollisoutlook.onmicrosoft.com"
)

# Build the authorization URI
$redirectURI = 'http://localhost:7071'
$scope = "openid"
$authURI = "$baseURI/$tenantName/oauth2/v2.0/authorize?response_type=code&client_id=$clientID&redirect_uri=$redirectURI&scope=$scope"

function Get-InputBox {
  param(
      [string]$Title = "Input Box",
      [string]$Prompt = "Enter the value:"
  )

  Add-Type -AssemblyName PresentationFramework

  # Create XAML for the input box
  $xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
      xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
      Title="$Title" Height="150" Width="400" Topmost="True">
  <Grid>
      <Label Content="$Prompt" Height="30" VerticalAlignment="Top" />
      <TextBox Name="InputTextBox" VerticalAlignment="Top" Margin="0,30,0,0" />
      <Button Name="OkButton" Content="OK" Height="25" Width="75" VerticalAlignment="Bottom" HorizontalAlignment="Right" Margin="0,0,10,10" IsDefault="True" />
  </Grid>
</Window>
"@

  # Load the XAML
  $inputBox = [Windows.Markup.XamlReader]::Parse($xaml)

  # Get the TextBox and Button from the XAML
  $textBox = $inputBox.FindName("InputTextBox")
  $okButton = $inputBox.FindName("OkButton")

  # Set up the button click event to close the window
  $okButton.Add_Click({ $inputBox.Close() })

  # Display the input box
  $inputBox.ShowDialog() | Out-Null

  # Return the value entered
  return $textBox.Text
}

# Display the URI and instruct the user
Write-Host "Please open the following URL in your browser:"
Write-Host $authURI

# Use the input box to get the auth code
$authCode = Get-InputBox -Title "Enter Auth Code" -Prompt "After authorizing the app, please copy the auth code from the browser's address bar and paste it here:"

# Derived values
$tokenURI = "$baseURI/$tenantName/oauth2/v2.0/token"
$redirectURI = 'http://localhost:7071'
$scope = "api://apiapp01/user_impersonation"
$authenticatedURI = 'http://localhost:7071/Authenticated'

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
    'redirect_uri' = $redirectURI
    'client_id' = $clientID
    'grant_type' = 'authorization_code'
    'code' = $authCode
    'session_state' = [Guid]::NewGuid().ToString() # Generating a new session state
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
    
    $response = Invoke-RestMethod -Uri $authenticatedURI -Headers $authHeaders
    $response
} catch {
    Write-Error "Error occurred: $_"
}
