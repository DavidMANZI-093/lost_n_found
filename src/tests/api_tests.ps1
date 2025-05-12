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
function Write-TestLog {
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
    
    Write-TestLog "Testing: $testCase"
    
    $jsonBody = $null
    if ($null -ne $body) {
        $jsonBody = $body | ConvertTo-Json
        Write-TestLog "Request Body: $jsonBody"
    }
    
    try {
        $params = @{
            Method = $method
            Uri = $url
            ContentType = "application/json"
            Headers = $headers
        }
        
        if ($null -ne $jsonBody -and ($method -eq "POST" -or $method -eq "PUT" -or $method -eq "PATCH")) {
            $params.Body = $jsonBody
        }
        
        $response = Invoke-RestMethod @params -ErrorVariable err -ErrorAction SilentlyContinue
        
        $responseJson = $response | ConvertTo-Json -Depth 10
        Write-TestLog "Response: $responseJson"
        
        "✅ PASSED: $testCase" | Out-File -FilePath $resultsFile -Append
        
        return $response
    }
    catch {
        Write-TestLog "Error: $_"
        "❌ FAILED: $testCase - $_" | Out-File -FilePath $resultsFile -Append
        
        if ($err) {
            Write-TestLog "Error Detail: $($err.Message)"
        }
        
        return $null
    }
}

# Test setup
Write-TestLog "=== Starting Lost and Found API Tests ==="
Write-TestLog "Base URL: $baseUrl"

# Test 1: Check if API is up and running
Write-TestLog "=== Test 1: API Health Check ==="
$response = Invoke-ApiRequest -method "GET" -endpoint "/api/" -description "API Health Check"

if ($response) {
    Write-TestLog "API is up and running"
}
else {
    Write-TestLog "API is not responding, stopping tests"
    exit 1  # Exit with non-zero status code to indicate failure
}

# Test 2: User Registration
Write-TestLog "=== Test 2: User Registration ==="
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
    Write-TestLog "User registered successfully"
}

# Test 3: User Login
Write-TestLog "=== Test 3: User Login ==="
$loginBody = @{
    email = "testuser@example.com"
    password = "password123"
}

$response = Invoke-ApiRequest -method "POST" -endpoint "/api/v1/auth/signin" -body $loginBody -description "User Login"

if ($response -and $response.token) {
    $jwtToken = $response.token
    Write-TestLog "User logged in successfully"
    Write-TestLog "JWT Token: $jwtToken"
}

# Setup auth headers for subsequent requests
$authHeaders = @{
    "Authorization" = "Bearer $jwtToken"
}

# Test 4: Create a Lost Item
Write-TestLog "=== Test 4: Create Lost Item ==="
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
    Write-TestLog "Lost item created successfully with ID: $lostItemId"
}

# Test 5: Create a Found Item
Write-TestLog "=== Test 5: Create Found Item ==="
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
    Write-TestLog "Found item created successfully with ID: $foundItemId"
}

# Test 6: Get Lost Item
Write-TestLog "=== Test 6: Get Lost Item ==="
$response = Invoke-ApiRequest -method "GET" -endpoint "/api/v1/lost-items/$lostItemId" -headers $authHeaders -description "Get Lost Item"

if ($response) {
    Write-TestLog "Retrieved lost item successfully"
}

# Test 7: Get Found Item
Write-TestLog "=== Test 7: Get Found Item ==="
$response = Invoke-ApiRequest -method "GET" -endpoint "/api/v1/found-items/$foundItemId" -headers $authHeaders -description "Get Found Item"

if ($response) {
    Write-TestLog "Retrieved found item successfully"
}

# Test 8: Update Lost Item
Write-TestLog "=== Test 8: Update Lost Item ==="
$updateLostItemBody = @{
    description = "Updated description for lost iPhone"
}

$response = Invoke-ApiRequest -method "PATCH" -endpoint "/api/v1/lost-items/$lostItemId" -body $updateLostItemBody -headers $authHeaders -description "Update Lost Item"

if ($response) {
    Write-TestLog "Updated lost item successfully"
}

# Test 9: Update Found Item
Write-TestLog "=== Test 9: Update Found Item ==="
$updateFoundItemBody = @{
    description = "Updated description for found laptop"
}

$response = Invoke-ApiRequest -method "PATCH" -endpoint "/api/v1/found-items/$foundItemId" -body $updateFoundItemBody -headers $authHeaders -description "Update Found Item"

if ($response) {
    Write-TestLog "Updated found item successfully"
}

# Test 10: Search Items
Write-TestLog "=== Test 10: Search Items ==="
$response = Invoke-ApiRequest -method "GET" -endpoint "/api/v1/search?type=lost&keyword=iPhone" -headers $authHeaders -description "Search Lost Items"

if ($response) {
    Write-TestLog "Search completed successfully"
}

# Test 11: Get Items Statistics
Write-TestLog "=== Test 11: Get Items Statistics ==="
$response = Invoke-ApiRequest -method "GET" -endpoint "/api/v1/items/stats" -headers $authHeaders -description "Get Items Statistics"

if ($response) {
    Write-TestLog "Retrieved items statistics successfully"
}

# Test 12: Delete Lost Item
Write-TestLog "=== Test 12: Delete Lost Item ==="
$response = Invoke-ApiRequest -method "DELETE" -endpoint "/api/v1/lost-items/$lostItemId" -headers $authHeaders -description "Delete Lost Item"

if ($response) {
    Write-TestLog "Deleted lost item successfully"
}

# Test 13: Delete Found Item
Write-TestLog "=== Test 13: Delete Found Item ==="
$response = Invoke-ApiRequest -method "DELETE" -endpoint "/api/v1/found-items/$foundItemId" -headers $authHeaders -description "Delete Found Item"

if ($response) {
    Write-TestLog "Deleted found item successfully"
}

# Summary
Write-TestLog "=== API Tests Completed ==="
Write-TestLog "Log file: $logFile"
Write-TestLog "Test cases file: $testCasesFile"
Write-TestLog "Results file: $resultsFile"

# Display test results summary
$passedCount = (Get-Content $resultsFile | Select-String -Pattern "✅ PASSED").Count
$failedCount = (Get-Content $resultsFile | Select-String -Pattern "❌ FAILED").Count
$totalCount = $passedCount + $failedCount

Write-TestLog "Test Summary:"
Write-TestLog "  Total: $totalCount"
Write-TestLog "  Passed: $passedCount"
Write-TestLog "  Failed: $failedCount"

if ($failedCount -eq 0) {
    Write-TestLog "All tests passed! 🎉"
}
else {
    Write-TestLog "Some tests failed. Check results file for details."
}
