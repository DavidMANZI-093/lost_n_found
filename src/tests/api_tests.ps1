# Lost and Found API Test Script
# Author: KASOGA Justesse
# Reg: 11471/2024

# Set up test variables
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$baseUrl = "http://localhost:8080"
$logFile = "$scriptDir\output\api_tests_log.txt"
$testCasesFile = "$scriptDir\output\test_cases.txt"
$resultsFile = "$scriptDir\output\test_results.txt"
$jwtToken = ""

# Ensure output directory exists
New-Item -ItemType Directory -Force -Path "$scriptDir\output" | Out-Null

# Start fresh log files
"" | Out-File -FilePath $logFile
"" | Out-File -FilePath $testCasesFile
"" | Out-File -FilePath $resultsFile

# Helper function to log messages
function Log-Message {
    param (
        [string]$message
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logFile -Append
    Write-Host "$timestamp - $message"
}

# Helper function for API requests
function Invoke-ApiRequest {
    param (
        [string]$method,
        [string]$endpoint,
        [object]$body = $null,
        [hashtable]$headers = @{},
        [string]$description = ""
    )
    
    $url = "$baseUrl$endpoint"
    $testCase = "[$method] $url - $description"
    $testCase | Out-File -FilePath $testCasesFile -Append
    
    Log-Message "Testing: $testCase"
    
    $jsonBody = $null
    if ($body -ne $null) {
        $jsonBody = $body | ConvertTo-Json
        Log-Message "Request Body: $jsonBody"
    }
    
    try {
        $params = @{
            Method = $method
            Uri = $url
            ContentType = "application/json"
            Headers = $headers
        }
        
        if ($jsonBody -ne $null -and ($method -eq "POST" -or $method -eq "PUT" -or $method -eq "PATCH")) {
            $params.Body = $jsonBody
        }
        
        $response = Invoke-RestMethod @params -ErrorVariable err -ErrorAction SilentlyContinue
        
        $responseJson = $response | ConvertTo-Json -Depth 10
        Log-Message "Response: $responseJson"
        
        "✅ PASSED: $testCase" | Out-File -FilePath $resultsFile -Append
        
        return $response
    }
    catch {
        Log-Message "Error: $_"
        "❌ FAILED: $testCase - $_" | Out-File -FilePath $resultsFile -Append
        
        if ($err) {
            Log-Message "Error Detail: $($err.Message)"
        }
        
        return $null
    }
}

# Test setup
Log-Message "=== Starting Lost and Found API Tests ==="
Log-Message "Base URL: $baseUrl"

# Test 1: Check if API is up and running
Log-Message "=== Test 1: API Health Check ==="
$response = Invoke-ApiRequest -method "GET" -endpoint "/api/" -description "API Health Check"

if ($response) {
    Log-Message "API is up and running"
}
else {
    Log-Message "API is not responding, stopping tests"
    exit
}

# Test 2: User Registration
Log-Message "=== Test 2: User Registration ==="
$registerBody = @{
    email = "testuser@example.com"
    password = "password123"
    firstName = "MANZI"
    lastName = "John"
    phoneNumber = "0798986565"
    address = "123 Test Street"
}

$response = Invoke-ApiRequest -method "POST" -endpoint "/api/v1/auth/signup" -body $registerBody -description "User Registration"

if ($response) {
    Log-Message "User registered successfully"
}

# Test 3: User Login
Log-Message "=== Test 3: User Login ==="
$loginBody = @{
    email = "testuser@example.com"
    password = "password123"
}

$response = Invoke-ApiRequest -method "POST" -endpoint "/api/v1/auth/signin" -body $loginBody -description "User Login"

if ($response -and $response.token) {
    $jwtToken = $response.token
    Log-Message "User logged in successfully"
    Log-Message "JWT Token: $jwtToken"
}

# Setup auth headers for subsequent requests
$authHeaders = @{
    "Authorization" = "Bearer $jwtToken"
}

# Test 4: Create a Lost Item
Log-Message "=== Test 4: Create Lost Item ==="
$lostItemBody = @{
    title = "Lost Smartphone"
    description = "iPhone 14 Pro, Space Gray, lost at the library"
    category = "Electronics"
    location = "University Library"
    imageUrl = "https://dummyiphone.com/iphone.jpg"
    lostDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
}

$response = Invoke-ApiRequest -method "POST" -endpoint "/api/v1/lost-items" -body $lostItemBody -headers $authHeaders -description "Create Lost Item"

if ($response) {
    $lostItemId = $response.data.id
    Log-Message "Lost item created successfully with ID: $lostItemId"
}

# Test 5: Create a Found Item
Log-Message "=== Test 5: Create Found Item ==="
$foundItemBody = @{
    title = "Found Laptop"
    description = "Dell XPS 13, found at the cafeteria"
    category = "Electronics"
    location = "University Cafeteria"
    imageUrl = "https://dummylaptop.com/laptop.jpg"
    foundDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
    storageLocation = "Lost and Found Office"
}

$response = Invoke-ApiRequest -method "POST" -endpoint "/api/v1/found-items" -body $foundItemBody -headers $authHeaders -description "Create Found Item"

if ($response) {
    $foundItemId = $response.data.id
    Log-Message "Found item created successfully with ID: $foundItemId"
}

# Test 6: Get Lost Item
Log-Message "=== Test 6: Get Lost Item ==="
$response = Invoke-ApiRequest -method "GET" -endpoint "/api/v1/lost-items/$lostItemId" -headers $authHeaders -description "Get Lost Item"

if ($response) {
    Log-Message "Retrieved lost item successfully"
}

# Test 7: Get Found Item
Log-Message "=== Test 7: Get Found Item ==="
$response = Invoke-ApiRequest -method "GET" -endpoint "/api/v1/found-items/$foundItemId" -headers $authHeaders -description "Get Found Item"

if ($response) {
    Log-Message "Retrieved found item successfully"
}

# Test 8: Update Lost Item
Log-Message "=== Test 8: Update Lost Item ==="
$updateLostItemBody = @{
    description = "Updated description for lost iPhone"
}

$response = Invoke-ApiRequest -method "PATCH" -endpoint "/api/v1/lost-items/$lostItemId" -body $updateLostItemBody -headers $authHeaders -description "Update Lost Item"

if ($response) {
    Log-Message "Updated lost item successfully"
}

# Test 9: Update Found Item
Log-Message "=== Test 9: Update Found Item ==="
$updateFoundItemBody = @{
    description = "Updated description for found laptop"
}

$response = Invoke-ApiRequest -method "PATCH" -endpoint "/api/v1/found-items/$foundItemId" -body $updateFoundItemBody -headers $authHeaders -description "Update Found Item"

if ($response) {
    Log-Message "Updated found item successfully"
}

# Test 10: Search Items
Log-Message "=== Test 10: Search Items ==="
$response = Invoke-ApiRequest -method "GET" -endpoint "/api/v1/search?type=lost&keyword=iPhone" -headers $authHeaders -description "Search Lost Items"

if ($response) {
    Log-Message "Search completed successfully"
}

# Test 11: Get Items Statistics
Log-Message "=== Test 11: Get Items Statistics ==="
$response = Invoke-ApiRequest -method "GET" -endpoint "/api/v1/items/stats" -headers $authHeaders -description "Get Items Statistics"

if ($response) {
    Log-Message "Retrieved items statistics successfully"
}

# Test 12: Delete Lost Item
Log-Message "=== Test 12: Delete Lost Item ==="
$response = Invoke-ApiRequest -method "DELETE" -endpoint "/api/v1/lost-items/$lostItemId" -headers $authHeaders -description "Delete Lost Item"

if ($response) {
    Log-Message "Deleted lost item successfully"
}

# Test 13: Delete Found Item
Log-Message "=== Test 13: Delete Found Item ==="
$response = Invoke-ApiRequest -method "DELETE" -endpoint "/api/v1/found-items/$foundItemId" -headers $authHeaders -description "Delete Found Item"

if ($response) {
    Log-Message "Deleted found item successfully"
}

# Summary
Log-Message "=== API Tests Completed ==="
Log-Message "Log file: $logFile"
Log-Message "Test cases file: $testCasesFile"
Log-Message "Results file: $resultsFile"

# Display test results summary
$passedCount = (Get-Content $resultsFile | Select-String -Pattern "✅ PASSED").Count
$failedCount = (Get-Content $resultsFile | Select-String -Pattern "❌ FAILED").Count
$totalCount = $passedCount + $failedCount

Log-Message "Test Summary:"
Log-Message "  Total: $totalCount"
Log-Message "  Passed: $passedCount"
Log-Message "  Failed: $failedCount"

if ($failedCount -eq 0) {
    Log-Message "All tests passed! 🎉"
}
else {
    Log-Message "Some tests failed. Check results file for details."
}
