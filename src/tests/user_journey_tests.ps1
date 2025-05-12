# Lost and Found API User Journey Test Script
# Author: KASOGA Justesse
# Reg: 11471/2024

# Set up test variables
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$baseUrl = "http://localhost:8080"
$logFile = "$scriptDir\output\user_journey_tests_log.txt"
$jwtToken = ""
$userId = 0
$lostItemId = 0
$foundItemId = 0

# Ensure output directory exists
New-Item -ItemType Directory -Force -Path "$scriptDir\output" | Out-Null

# Start fresh log file
"" | Out-File -FilePath $logFile

# Helper function to log messages
function Log-Message {
    param (
        [string]$message,
        [string]$level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $colorMap = @{
        "INFO" = "White"
        "SUCCESS" = "Green"
        "WARNING" = "Yellow"
        "ERROR" = "Red"
        "STEP" = "Cyan"
    }
    
    $color = $colorMap[$level]
    
    "$timestamp [$level] - $message" | Out-File -FilePath $logFile -Append
    Write-Host "$timestamp [$level] - $message" -ForegroundColor $color
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
    
    Log-Message "REQUESTING: [$method] $url - $description" -level "STEP"
    
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
        Log-Message "Response: $responseJson" -level "SUCCESS"
        
        return $response
    }
    catch {
        Log-Message "Error: $_" -level "ERROR"
        
        if ($err) {
            Log-Message "Error Detail: $($err.Message)" -level "ERROR"
        }
        
        return $null
    }
}

# ============ USER JOURNEY TEST SCENARIO ============
# This test simulates a complete user journey:
# 1. Register a new user
# 2. Login and get JWT token
# 3. Report a lost item
# 4. Report a found item
# 5. Search for items
# 6. Update item status
# 7. Claim a found item that matches a lost item
# ===================================================

Log-Message "=====================================" -level "STEP"
Log-Message "STARTING LOST & FOUND USER JOURNEY TEST" -level "STEP"
Log-Message "=====================================" -level "STEP"

# Step 1: Register a new user with random email to avoid conflicts
$randomId = Get-Random -Minimum 1000 -Maximum 9999
$userEmail = "justesseciza$randomId@mymail.com"

Log-Message "STEP 1: REGISTER NEW USER ($userEmail)" -level "STEP"
$registerBody = @{
    email = $userEmail
    password = "SecurePass123!"
    firstName = "KASOGA"
    lastName = "Justesse"
    phoneNumber = "0799886644"
    address = "UNILAK, KK 508 St, Kigali"
}

$response = Invoke-ApiRequest -method "POST" -endpoint "/api/v1/auth/signup" -body $registerBody -description "Register User"

if ($response -and $response.data) {
    $userId = $response.data.id
    Log-Message "User registered successfully with ID: $userId" -level "SUCCESS"
}
else {
    Log-Message "Failed to register user, aborting tests" -level "ERROR"
    exit
}

# Step 2: Login with the new user
Log-Message "STEP 2: LOGIN WITH NEW USER" -level "STEP"
$loginBody = @{
    email = $userEmail
    password = "SecurePass123!"
}

$response = Invoke-ApiRequest -method "POST" -endpoint "/api/v1/auth/signin" -body $loginBody -description "User Login"

if ($response -and $response.token) {
    $jwtToken = $response.token
    Log-Message "User logged in successfully, JWT token obtained" -level "SUCCESS"
}
else {
    Log-Message "Failed to login, aborting tests" -level "ERROR"
    exit
}

# Setup auth headers for subsequent requests
$authHeaders = @{
    "Authorization" = "Bearer $jwtToken"
}

# Step 3: Report a lost item
Log-Message "STEP 3: REPORT A LOST ITEM" -level "STEP"
$lostItemBody = @{
    title = "Lost MacBook Pro"
    description = "16-inch MacBook Pro, Space Gray, last seen in the Computer Science building room 302"
    category = "Electronics"
    location = "Computer Science Building, Room 302"
    imageUrl = "https://dummymac.com/macbook.jpg"
    lostDate = (Get-Date).AddDays(-2).ToString("yyyy-MM-ddTHH:mm:ss")
}

$response = Invoke-ApiRequest -method "POST" -endpoint "/api/v1/lost-items" -body $lostItemBody -headers $authHeaders -description "Report Lost Item"

if ($response -and $response.data) {
    $lostItemId = $response.data.id
    Log-Message "Lost item reported successfully with ID: $lostItemId" -level "SUCCESS"
}
else {
    Log-Message "Failed to report lost item" -level "ERROR"
}

# Step 4: Report a found item that matches the lost item
Log-Message "STEP 4: REPORT A FOUND ITEM" -level "STEP"
$foundItemBody = @{
    title = "Found MacBook Pro Laptop"
    description = "16-inch MacBook Pro, Space Gray, found in the Computer Science building near room 304"
    category = "Electronics"
    location = "Computer Science Building, Room 304"
    imageUrl = "https://dummyfoundmac.com/found_macbook.jpg"
    foundDate = (Get-Date).AddDays(-1).ToString("yyyy-MM-ddTHH:mm:ss")
    storageLocation = "Campus Security Office"
}

$response = Invoke-ApiRequest -method "POST" -endpoint "/api/v1/found-items" -body $foundItemBody -headers $authHeaders -description "Report Found Item"

if ($response -and $response.data) {
    $foundItemId = $response.data.id
    Log-Message "Found item reported successfully with ID: $foundItemId" -level "SUCCESS"
}
else {
    Log-Message "Failed to report found item" -level "ERROR"
}

# Step 5: Search for the lost item
Log-Message "STEP 5: SEARCH FOR ITEMS" -level "STEP"
$response = Invoke-ApiRequest -method "GET" -endpoint "/api/v1/search?type=lost&keyword=MacBook" -headers $authHeaders -description "Search Lost Items"

if ($response) {
    $resultCount = $response.data.Count
    Log-Message "Search completed successfully, found $resultCount matching lost items" -level "SUCCESS"
}

# Step 6: Update lost item with more details
Log-Message "STEP 6: UPDATE LOST ITEM WITH MORE DETAILS" -level "STEP"
$updateLostItemBody = @{
    description = "16-inch MacBook Pro, Space Gray, serial number FVFXC123456, has a sticker of a penguin on the lid"
}

$response = Invoke-ApiRequest -method "PATCH" -endpoint "/api/v1/lost-items/$lostItemId" -body $updateLostItemBody -headers $authHeaders -description "Update Lost Item"

if ($response) {
    Log-Message "Updated lost item successfully with additional details" -level "SUCCESS"
}

# Step 7: Simulate admin approving the found item
Log-Message "STEP 7: SIMULATE ADMIN APPROVING FOUND ITEM" -level "STEP"
Log-Message "Note: In a real scenario, this would be done by an admin user" -level "WARNING"
$approveFoundItemBody = @{
    status = "active"
}

$response = Invoke-ApiRequest -method "PATCH" -endpoint "/api/v1/found-items/$foundItemId" -body $approveFoundItemBody -headers $authHeaders -description "Approve Found Item"

if ($response) {
    Log-Message "Found item status updated to 'active'" -level "SUCCESS"
}

# Step 8: Get both items to confirm they are updated
Log-Message "STEP 8: VERIFY ITEM STATUSES" -level "STEP"
$response = Invoke-ApiRequest -method "GET" -endpoint "/api/v1/lost-items/$lostItemId" -headers $authHeaders -description "Get Lost Item Details"

if ($response) {
    $lostItemStatus = $response.data.status
    Log-Message "Lost item status: $lostItemStatus" -level "INFO"
}

$response = Invoke-ApiRequest -method "GET" -endpoint "/api/v1/found-items/$foundItemId" -headers $authHeaders -description "Get Found Item Details"

if ($response) {
    $foundItemStatus = $response.data.status
    Log-Message "Found item status: $foundItemStatus" -level "INFO"
}

# Step 9: Simulate claiming the found item
Log-Message "STEP 9: SIMULATE CLAIMING THE FOUND ITEM" -level "STEP"
$claimFoundItemBody = @{
    status = "claimed"
}

$response = Invoke-ApiRequest -method "PATCH" -endpoint "/api/v1/found-items/$foundItemId" -body $claimFoundItemBody -headers $authHeaders -description "Claim Found Item"

if ($response) {
    Log-Message "Found item claimed successfully" -level "SUCCESS"
}

# Step 10: Update the lost item to claimed as well
Log-Message "STEP 10: UPDATE LOST ITEM TO CLAIMED" -level "STEP"
$claimLostItemBody = @{
    status = "claimed"
}

$response = Invoke-ApiRequest -method "PATCH" -endpoint "/api/v1/lost-items/$lostItemId" -body $claimLostItemBody -headers $authHeaders -description "Update Lost Item to Claimed"

if ($response) {
    Log-Message "Lost item updated to claimed status" -level "SUCCESS"
}

# Step 11: Get item statistics to see the claims reflected
Log-Message "STEP 11: GET UPDATED ITEM STATISTICS" -level "STEP"
$response = Invoke-ApiRequest -method "GET" -endpoint "/api/v1/items/stats" -headers $authHeaders -description "Get Updated Item Statistics"

if ($response) {
    Log-Message "Retrieved updated item statistics successfully" -level "SUCCESS"
    Log-Message "Item statistics: $($response.data | ConvertTo-Json)" -level "INFO"
}

# Summary
Log-Message "=====================================" -level "STEP"
Log-Message "USER JOURNEY TEST COMPLETED" -level "STEP"
Log-Message "=====================================" -level "STEP"
Log-Message "User Journey Log file: $logFile" -level "INFO"

# Display success message
Log-Message "User journey successfully simulated for user $userEmail" -level "SUCCESS"
Log-Message "The test demonstrated:" -level "INFO"
Log-Message "- User registration and authentication" -level "INFO"
Log-Message "- Lost item reporting" -level "INFO"
Log-Message "- Found item reporting" -level "INFO"
Log-Message "- Item searching" -level "INFO"
Log-Message "- Item updating" -level "INFO"
Log-Message "- Item claiming" -level "INFO"
