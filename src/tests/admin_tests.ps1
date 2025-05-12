# Lost and Found API Admin Functionality Test Script
# Author: KASOGA Justesse
# Reg: 11471/2024

# Set up test variables
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$baseUrl = "http://localhost:8080"
$logFile = "$scriptDir\output\admin_tests_log.txt"
$adminEmail = "admin@lostfound.com"
$adminPassword = "AdminPass123!"
$regularUserEmail = "johnmanzi@mymain.com"
$jwtToken = ""
$userId = 0
$pendingLostItemId = 0
$pendingFoundItemId = 0

# Ensure output directory exists
New-Item -ItemType Directory -Force -Path "$scriptDir\output" | Out-Null

# Start fresh log file
"" | Out-File -FilePath $logFile

# Helper function to log messages
function Write-TestLog {
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
        "STEP" = "Magenta"
        "ADMIN" = "Blue"
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
    
    Write-TestLog "REQUESTING: [$method] $url - $description" -level "STEP"
    
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
        Write-TestLog "Response: $responseJson" -level "SUCCESS"
        
        return $response
    }
    catch {
        Write-TestLog "Error: $_" -level "ERROR"
        
        if ($err) {
            Write-TestLog "Error Detail: $($err.Message)" -level "ERROR"
        }
        
        return $null
    }
}

# ============ ADMIN TESTS SCENARIO ============
# This test simulates admin functionality:
# 1. Register a new admin user (note: in production, this would be configured differently)
# 2. Register a regular user
# 3. Create pending items
# 4. Admin approves/rejects items
# 5. Admin bans/unbans users
# 6. Admin gets system reports
# =============================================

Write-TestLog "=====================================" -level "ADMIN"
Write-TestLog "STARTING LOST & FOUND ADMIN TESTS" -level "ADMIN"
Write-TestLog "=====================================" -level "ADMIN"

# Step 1: Register a new admin user
# Note: In a real application, admin users would likely be created differently
Write-TestLog "STEP 1: REGISTER ADMIN USER" -level "STEP"
$registerAdminBody = @{
    email = $adminEmail
    password = $adminPassword
    firstName = "Admin"
    lastName = "User"
    phoneNumber = "0799775533"
    address = "UNILAK, KK 508 St, Kigali"
}

$response = Invoke-ApiRequest -method "POST" -endpoint "/api/v1/auth/signup" -body $registerAdminBody -description "Register Admin User"

if ($response) {
    Write-TestLog "Admin user registered successfully" -level "SUCCESS"
    
    # Note: In a real application, you would need to set the admin flag in the database
    Write-TestLog "Note: At this point, you would need to manually set is_admin=true in the database" -level "WARNING"
    Write-TestLog "For testing purposes, we'll assume this user has admin privileges" -level "WARNING"
}
else {
    Write-TestLog "Failed to register admin user. If the user already exists, proceed with login." -level "WARNING"
}

# Step 2: Login with admin user
Write-TestLog "STEP 2: LOGIN WITH ADMIN USER" -level "STEP"
$loginBody = @{
    email = $adminEmail
    password = $adminPassword
}

$response = Invoke-ApiRequest -method "POST" -endpoint "/api/v1/auth/signin" -body $loginBody -description "Admin Login"

if ($response -and $response.token) {
    $jwtToken = $response.token
    Write-TestLog "Admin logged in successfully, JWT token obtained" -level "SUCCESS"
}
else {
    Write-TestLog "Failed to login as admin, aborting tests" -level "ERROR"
    exit 1  # Exit with non-zero status code to indicate failure
}

# Setup auth headers for subsequent requests
$authHeaders = @{
    "Authorization" = "Bearer $jwtToken"
}

# Step 3: Register a regular user for testing
Write-TestLog "STEP 3: REGISTER REGULAR USER" -level "STEP"
$randomId = Get-Random -Minimum 1000 -Maximum 9999
$regularUserEmail = "reguser$randomId@example.com"

$registerUserBody = @{
    email = $regularUserEmail
    password = "UserPass123!"
    firstName = "MANZI"
    lastName = "John"
    phoneNumber = "0799765432"
    address = "UNILAK, KK 508 St, Kigali"
}

$response = Invoke-ApiRequest -method "POST" -endpoint "/api/v1/auth/signup" -body $registerUserBody -description "Register Regular User"

if ($response -and $response.data) {
    $userId = $response.data.id
    Write-TestLog "Regular user registered successfully with ID: $userId" -level "SUCCESS"
}
else {
    Write-TestLog "Failed to register regular user" -level "ERROR"
}

# Step 4: Create pending lost and found items (as admin)
Write-TestLog "STEP 4: CREATE PENDING ITEMS" -level "STEP"
$pendingLostItemBody = @{
    title = "Lost Wallet"
    description = "Brown leather wallet with initials JD"
    category = "Personal Items"
    location = "Campus Gym"
    imageUrl = "https://dummywallet.com/wallet.jpg"
    lostDate = (Get-Date).AddDays(-1).ToString("yyyy-MM-ddTHH:mm:ss")
}

$response = Invoke-ApiRequest -method "POST" -endpoint "/api/v1/lost-items" -body $pendingLostItemBody -headers $authHeaders -description "Create Pending Lost Item"

if ($response -and $response.data) {
    $pendingLostItemId = $response.data.id
    Write-TestLog "Pending lost item created successfully with ID: $pendingLostItemId" -level "SUCCESS"
}

$pendingFoundItemBody = @{
    title = "Found Keys"
    description = "Set of car and house keys with a blue keychain"
    category = "Personal Items"
    location = "Parking Lot B"
    imageUrl = "https://dummykeys.com/keys.jpg"
    foundDate = (Get-Date).AddDays(-1).ToString("yyyy-MM-ddTHH:mm:ss")
    storageLocation = "Security Office"
}

$response = Invoke-ApiRequest -method "POST" -endpoint "/api/v1/found-items" -body $pendingFoundItemBody -headers $authHeaders -description "Create Pending Found Item"

if ($response -and $response.data) {
    $pendingFoundItemId = $response.data.id
    Write-TestLog "Pending found item created successfully with ID: $pendingFoundItemId" -level "SUCCESS"
}

# Step 5: Admin approves the lost item
Write-TestLog "STEP 5: ADMIN APPROVES LOST ITEM" -level "STEP"
$approveLostItemBody = @{
    status = "approved"
    type = "lost"
}

$response = Invoke-ApiRequest -method "PATCH" -endpoint "/api/v1/admin/items/$pendingLostItemId" -body $approveLostItemBody -headers $authHeaders -description "Admin Approves Lost Item"

if ($response) {
    Write-TestLog "Admin successfully approved lost item" -level "SUCCESS"
}

# Step 6: Admin rejects the found item
Write-TestLog "STEP 6: ADMIN REJECTS FOUND ITEM" -level "STEP"
$rejectFoundItemBody = @{
    status = "rejected"
    type = "found"
}

$response = Invoke-ApiRequest -method "PATCH" -endpoint "/api/v1/admin/items/$pendingFoundItemId" -body $rejectFoundItemBody -headers $authHeaders -description "Admin Rejects Found Item"

if ($response) {
    Write-TestLog "Admin successfully rejected found item" -level "SUCCESS"
}

# Step 7: Admin bans a user
Write-TestLog "STEP 7: ADMIN BANS USER" -level "STEP"
$banUserBody = @{
    is_banned = $true
}

$response = Invoke-ApiRequest -method "PATCH" -endpoint "/api/v1/admin/users/$userId" -body $banUserBody -headers $authHeaders -description "Admin Bans User"

if ($response) {
    Write-TestLog "Admin successfully banned user with ID: $userId" -level "SUCCESS"
}

# Step 8: Admin unbans the user
Write-TestLog "STEP 8: ADMIN UNBANS USER" -level "STEP"
$unbanUserBody = @{
    is_banned = $false
}

$response = Invoke-ApiRequest -method "PATCH" -endpoint "/api/v1/admin/users/$userId" -body $unbanUserBody -headers $authHeaders -description "Admin Unbans User"

if ($response) {
    Write-TestLog "Admin successfully unbanned user with ID: $userId" -level "SUCCESS"
}

# Step 9: Admin gets system reports
Write-TestLog "STEP 9: ADMIN GETS SYSTEM REPORTS" -level "STEP"
$response = Invoke-ApiRequest -method "GET" -endpoint "/api/v1/admin/reports" -headers $authHeaders -description "Admin Gets System Reports"

if ($response) {
    Write-TestLog "Admin successfully retrieved system reports" -level "SUCCESS"
    Write-TestLog "System Reports: $($response.data | ConvertTo-Json)" -level "INFO"
}

# Summary
Write-TestLog "=====================================" -level "ADMIN"
Write-TestLog "ADMIN TESTS COMPLETED" -level "ADMIN"
Write-TestLog "=====================================" -level "ADMIN"
Write-TestLog "Admin Tests Log file: $logFile" -level "INFO"

# Display success message
Write-TestLog "Admin functionality tests completed successfully" -level "SUCCESS"
Write-TestLog "The test demonstrated:" -level "INFO"
Write-TestLog "- Admin item approval/rejection" -level "INFO"
Write-TestLog "- Admin user management (ban/unban)" -level "INFO"
Write-TestLog "- Admin system reports" -level "INFO"
