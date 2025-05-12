# Lost and Found API Admin Functionality Test Script
# Author: David MANZI
# Customized for demonstration purposes

# Set up test variables
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$profilesPath = "$scriptDir\dummy_profiles.json"
$logFile = "$scriptDir\output\admin_tests_log.txt"
$jwtToken = ""
$userId = 0
$pendingLostItemId = 0
$pendingFoundItemId = 0

# Load test profiles
try {
    $testProfiles = Get-Content $profilesPath -Raw | ConvertFrom-Json
    Write-Host "Loaded test profiles successfully" -ForegroundColor Green
    $baseUrl = $testProfiles.apiSettings.baseUrl
    $regularUser = $testProfiles.regularUser
    $adminUser = $testProfiles.adminUser
    $lostItem = $testProfiles.testItems.lostItem
    $foundItem = $testProfiles.testItems.foundItem
    
    # Use admin credentials from the profiles
    $adminEmail = $adminUser.email
    $adminPassword = $adminUser.password
    $regularUserEmail = $regularUser.email
} catch {
    Write-Host "Error loading test profiles: $_" -ForegroundColor Red
    Write-Host "Using default admin credentials" -ForegroundColor Yellow
    $baseUrl = "http://localhost:8080"
    $adminEmail = "admin@lostfound.com"
    $adminPassword = "AdminPass123!"
    $regularUserEmail = "user@example.com"
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

# Start fresh log file
"" | Out-File -FilePath $logFile

# Helper function to log messages - uses approved PowerShell verb
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
        "STEP" = "Cyan"
        "ADMIN" = "Magenta"
    }
    
    $color = $colorMap[$level]
    
    "$timestamp [$level] - $message" | Out-File -FilePath $logFile -Append
    Write-Host "$timestamp [$level] - $message" -ForegroundColor $color
}

# For backward compatibility
function Log-Message {
    param(
        [string]$message,
        [string]$level = "INFO"
    )
    Write-TestLog $message $level
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
    if ($null -ne $body) {
        $jsonBody = $body | ConvertTo-Json
        Log-Message "Request Body: $jsonBody" -level "INFO"
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

# ============ ADMIN TESTS SCENARIO ============
# This test simulates admin functionality:
# 1. Register a new admin user (note: in production, this would be configured differently)
# 2. Register a regular user
# 3. Create pending items
# 4. Admin approves/rejects items
# 5. Admin bans/unbans users
# 6. Admin gets system reports
# =============================================

Log-Message "=====================================" -level "ADMIN"
Log-Message "STARTING LOST & FOUND ADMIN TESTS" -level "ADMIN"
Log-Message "=====================================" -level "ADMIN"

# Step 1: Ensure admin user exists and has proper credentials
Log-Message "STEP 1: VERIFYING ADMIN USER" -level "STEP"
Log-Message "Using admin user: $adminEmail (from dummy_profiles.json)" -level "INFO"
Log-Message "Password: $adminPassword" -level "INFO"
Log-Message "Note: The admin user should have been created during database reset" -level "INFO"

# Step 2: Login with admin user
Log-Message "STEP 2: LOGIN WITH ADMIN USER" -level "STEP"
$loginBody = @{
    email = $adminEmail
    password = $adminPassword
}

$response = Invoke-ApiRequest -method "POST" -endpoint "/api/v1/auth/signin" -body $loginBody -description "Admin Login"

if ($response -and $response.token) {
    $jwtToken = $response.token
    Log-Message "Admin logged in successfully, JWT token obtained" -level "SUCCESS"
}
else {
    Log-Message "Failed to login as admin, aborting tests" -level "ERROR"
    exit 1 # Exit with error code
}

# Setup auth headers for subsequent requests
$authHeaders = @{
    "Authorization" = "Bearer $jwtToken"
}

# Step 3: Register a regular user for testing
Log-Message "STEP 3: REGISTER REGULAR USER" -level "STEP"
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
    Log-Message "Regular user registered successfully with ID: $userId" -level "SUCCESS"
}
else {
    Log-Message "Failed to register regular user" -level "ERROR"
}

# Step 4: Create pending lost and found items (as admin)
Log-Message "STEP 4: CREATE PENDING ITEMS" -level "STEP"
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
    Log-Message "Pending lost item created successfully with ID: $pendingLostItemId" -level "SUCCESS"
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
    Log-Message "Pending found item created successfully with ID: $pendingFoundItemId" -level "SUCCESS"
}

# Step 5: Admin approves the lost item
Log-Message "STEP 5: ADMIN APPROVES LOST ITEM" -level "STEP"
$approveLostItemBody = @{
    status = "approved"
    type = "lost"
}

$response = Invoke-ApiRequest -method "PATCH" -endpoint "/api/v1/admin/items/$pendingLostItemId" -body $approveLostItemBody -headers $authHeaders -description "Admin Approves Lost Item"

if ($response) {
    Log-Message "Admin successfully approved lost item" -level "SUCCESS"
}

# Step 6: Admin rejects the found item
Log-Message "STEP 6: ADMIN REJECTS FOUND ITEM" -level "STEP"
$rejectFoundItemBody = @{
    status = "rejected"
    type = "found"
}

$response = Invoke-ApiRequest -method "PATCH" -endpoint "/api/v1/admin/items/$pendingFoundItemId" -body $rejectFoundItemBody -headers $authHeaders -description "Admin Rejects Found Item"

if ($response) {
    Log-Message "Admin successfully rejected found item" -level "SUCCESS"
}

# Step 7: Admin bans a user
Log-Message "STEP 7: ADMIN BANS USER" -level "STEP"
$banUserBody = @{
    is_banned = $true
}

$response = Invoke-ApiRequest -method "PATCH" -endpoint "/api/v1/admin/users/$userId" -body $banUserBody -headers $authHeaders -description "Admin Bans User"

if ($response) {
    Log-Message "Admin successfully banned user with ID: $userId" -level "SUCCESS"
}

# Step 8: Admin unbans the user
Log-Message "STEP 8: ADMIN UNBANS USER" -level "STEP"
$unbanUserBody = @{
    is_banned = $false
}

$response = Invoke-ApiRequest -method "PATCH" -endpoint "/api/v1/admin/users/$userId" -body $unbanUserBody -headers $authHeaders -description "Admin Unbans User"

if ($response) {
    Log-Message "Admin successfully unbanned user with ID: $userId" -level "SUCCESS"
}

# Step 9: Admin gets system reports
Log-Message "STEP 9: ADMIN GETS SYSTEM REPORTS" -level "STEP"
$response = Invoke-ApiRequest -method "GET" -endpoint "/api/v1/admin/reports" -headers $authHeaders -description "Admin Gets System Reports"

if ($response) {
    Log-Message "Admin successfully retrieved system reports" -level "SUCCESS"
    Log-Message "System Reports: $($response.data | ConvertTo-Json)" -level "INFO"
}

# Summary
Log-Message "=====================================" -level "ADMIN"
Log-Message "ADMIN TESTS COMPLETED" -level "ADMIN"
Log-Message "=====================================" -level "ADMIN"
Log-Message "Admin Tests Log file: $logFile" -level "INFO"

# Display success message
Log-Message "Admin functionality tests completed successfully" -level "SUCCESS"
Log-Message "The test demonstrated:" -level "INFO"
Log-Message "- Admin item approval/rejection" -level "INFO"
Log-Message "- Admin user management (ban/unban)" -level "INFO"
Log-Message "- Admin system reports" -level "INFO"
