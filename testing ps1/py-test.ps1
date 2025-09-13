# PowerShell script to test the FastAPI API
# This script registers a user, logs in, accesses a protected page, and then deletes the user.

# Define the base URL and user credentials for the API.
$baseUrl = "http://127.0.0.1:80"
$username = "deneme"
$password = "testpass"

# Create the JSON body for the request.
$body = @{
    username = $username
    password = $password
} | ConvertTo-Json

# Step 1: Register a new user
Write-Host "Step 1: Registering user..." -ForegroundColor Yellow
try {
    $registerUrl = "$baseUrl/auth/register"
    Invoke-WebRequest -Uri $registerUrl -Method POST -Body $body -ContentType "application/json"
    Write-Host "User '$username' registered successfully." -ForegroundColor Green
} catch {
    Write-Host "User registration failed or user already exists. Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host " "

# Step 2: Log in with the created user
Write-Host "Step 2: Logging in..." -ForegroundColor Yellow
try {
    $loginUrl = "$baseUrl/auth/login"
    Invoke-WebRequest -Uri $loginUrl -Method POST -Body $body -ContentType "application/json"
    Write-Host "Login successful." -ForegroundColor Green
} catch {
    Write-Host "Login failed. Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host " "

# Step 3: Access the protected page
Write-Host "Step 3: Accessing the protected page..." -ForegroundColor Yellow
try {
    # Create credentials for HTTP Basic authentication.
    $credentials = New-Object System.Management.Automation.PSCredential($username, (ConvertTo-SecureString $password -AsPlainText -Force))
    $secretUrl = "$baseUrl/secret"
    $response = Invoke-WebRequest -Uri $secretUrl -Method GET -Credential $credentials
    Write-Host "Access successful! Response: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "Access failed. Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host " "

# Step 4: Delete the user
Write-Host "Step 4: Deleting the user..." -ForegroundColor Yellow
try {
    $credentials = New-Object System.Management.Automation.PSCredential($username, (ConvertTo-SecureString $password -AsPlainText -Force))
    $deleteUrl = "$baseUrl/auth/delete-user"
    Invoke-WebRequest -Uri $deleteUrl -Method DELETE -Credential $credentials
    Write-Host "User '$username' deleted successfully." -ForegroundColor Green
} catch {
    Write-Host "User deletion failed. Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host " "

# Step 5: Testing WebSocket connection
Write-Host "Step 5: Testing WebSocket connection..." -ForegroundColor Yellow
try {
    # Create a WebSocket client and connect to the correct ws:// URL.
    $wsUrl = "ws://127.0.0.1:80/ws"
    $uri = [System.Uri]$wsUrl
    $ws = New-Object System.Net.WebSockets.ClientWebSocket

    $ws.ConnectAsync($uri, [System.Threading.CancellationToken]::None).Wait()

    # Send a message
    $message = "Hello from PowerShell!"
    $messageBytes = [System.Text.Encoding]::UTF8.GetBytes($message)
    $sendBuffer = [System.ArraySegment[byte]]::new($messageBytes)
    $ws.SendAsync($sendBuffer, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, [System.Threading.CancellationToken]::None).Wait()

    # Add a short delay to give the server time to process the message and send a response.
    Start-Sleep -Milliseconds 500

    # Receive a message with a loop to ensure all parts are collected
    $receivedMessageBytes = [System.Collections.Generic.List[byte]]::new()
    $receiveBuffer = [System.ArraySegment[byte]]::new([byte[]]::new(1024))

    do {
        $receiveResult = $ws.ReceiveAsync($receiveBuffer, [System.Threading.CancellationToken]::None).Result
        if ($receiveResult.Count -gt 0) {
            $receivedMessageBytes.AddRange([byte[]]$receiveBuffer.Array[0..($receiveResult.Count - 1)])
        }
    } while (-not $receiveResult.EndOfMessage)

    $receivedMessage = [System.Text.Encoding]::UTF8.GetString($receivedMessageBytes.ToArray())

    Write-Host "WebSocket connection successful." -ForegroundColor Green
    Write-Host "Sent message: '$message'" -ForegroundColor Green
    Write-Host "Received message: '$receivedMessage'" -ForegroundColor Green

} catch [System.AggregateException] {
    Write-Host "WebSocket connection failed due to an AggregateException." -ForegroundColor Red
    $_.Exception.InnerExceptions | ForEach-Object {
        Write-Host "Inner Exception: $($_.Message)" -ForegroundColor Red
    }
} catch {
    Write-Host "WebSocket connection failed. Error: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    if ($ws.State -eq [System.Net.WebSockets.WebSocketState]::Open) {
        $ws.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "Client closing", [System.Threading.CancellationToken]::None).Wait()
    }
}
