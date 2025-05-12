# Lost and Found API Test Script
# Author: David MANZI
# Customized for demonstration purposes

# Set up test variables
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$profilesPath = "$scriptDir\dummy_profiles.json"
$logFile = "$scriptDir\output\api_tests_log.txt"
$testCasesFile = "$scriptDir\output\test_cases.txt"
$resultsFile = "$scriptDir\output\test_results.txt"
$jwtToken = ""

# Load test profiles
try {
    $testProfiles = Get-Content $profilesPath -Raw | ConvertFrom-Json
    Write-Host "Loaded test profiles successfully" -ForegroundColor Green
    $baseUrl = $testProfiles.apiSettings.baseUrl
    $regularUser = $testProfiles.regularUser
    $adminUser = $testProfiles.adminUser
    $lostItem = $testProfiles.testItems.lostItem
    $foundItem = $testProfiles.testItems.foundItem
} catch {
    Write-Host "Error loading test profiles: $_" -ForegroundColor Red
    Write-Host "Using default test profiles" -ForegroundColor Yellow
    $baseUrl = "http://localhost:8080"
}

# Reset database before tests
Write-Host "Resetting database before running tests..."
try {
    & "$scriptDir\reset_database.ps1"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Warning: Database reset failed. Tests may have unexpected results." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Warning: Database reset script error: $_" -ForegroundColor Yellow
}

# Ensure output directory exists
New-Item -ItemType Directory -Force -Path "$scriptDir\output" | Out-Null

# Start fresh log files
"" | Out-File -FilePath $logFile
"" | Out-File -FilePath $testCasesFile
"" | Out-File -FilePath $resultsFile

# Helper function to log messages - uses approved PowerShell verb
function Write-TestLog {
    param (
        [string]$message
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logFile -Append
    Write-Host "$timestamp - $message"
}

# For backward compatibility
function Log-Message { 
    param([string]$message) 
    Write-TestLog $message 
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

# Security Note: We need to authenticate first before accessing protected endpoints

# Test 1: User Registration 
Log-Message "=== Test 1: User Registration ==="
$registerBody = @{
    email = $regularUser.email
    password = $regularUser.password
    firstName = $regularUser.firstName
    lastName = $regularUser.lastName
    phoneNumber = $regularUser.phoneNumber
    address = $regularUser.address
}

$response = Invoke-ApiRequest -method "POST" -endpoint "/api/v1/auth/signup" -body $registerBody -description "User Registration"

if ($response) {
    Log-Message "User registered successfully"
}

# Test 2: User Login to get JWT token
Log-Message "=== Test 2: User Login ==="
$loginBody = @{
    email = $regularUser.email
    password = $regularUser.password 
}

$response = Invoke-ApiRequest -method "POST" -endpoint "/api/v1/auth/signin" -body $loginBody -description "User Login"

if ($response -and $response.token) {
    $jwtToken = $response.token
    Log-Message "User logged in successfully"
    Log-Message "JWT Token obtained for authenticated requests"
} else {
    Log-Message "Failed to obtain authentication token, stopping tests"
    exit 1 # Exit with error code
}

# Setup auth headers for subsequent requests
$authHeaders = @{
    "Authorization" = "Bearer $jwtToken"
}

# Test 3: Check if API is up (with authentication)
Log-Message "=== Test 3: API Health Check (Authenticated) ==="
$response = Invoke-ApiRequest -method "GET" -endpoint "/api/" -headers $authHeaders -description "API Health Check (Authenticated)"

if ($response) {
    Log-Message "API is up and running and properly authenticated"
}
else {
    Log-Message "API is not responding even with authentication, stopping tests"
    exit 1 # Exit with error code
}

# Test 4: Create a Lost Item (Using values from profiles)
Log-Message "=== Test 4: Create Lost Item ==="
$lostItemBody = @{
    title = $lostItem.title
    description = $lostItem.description
    category = $lostItem.category
    location = $lostItem.location
    imageUrl = $lostItem.imageUrl
    lostDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
}

$response = Invoke-ApiRequest -method "POST" -endpoint "/api/v1/lost-items" -body $lostItemBody -headers $authHeaders -description "Create Lost Item"

if ($response) {
    $lostItemId = $response.data.id
    Log-Message "Lost item created successfully with ID: $lostItemId"
}

# Test 5: Create a Found Item (Using values from profiles)
Log-Message "=== Test 5: Create Found Item ==="
$foundItemBody = @{
    title = $foundItem.title
    description = $foundItem.description
    category = $foundItem.category
    location = $foundItem.location
    imageUrl = $foundItem.imageUrl
    foundDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
    storageLocation = $foundItem.storageLocation
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
