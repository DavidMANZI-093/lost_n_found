# Database Cleanup Script for Lost and Found API Tests
# Author: KASOGA Justesse
# Reg: 11471/2024

# Set up variables
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$logFile = "$scriptDir\output\db_cleanup_log.txt"

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
        "DB" = "Magenta"
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
    
    $baseUrl = "http://localhost:8080"
    $url = "$baseUrl$endpoint"
    
    Write-TestLog "REQUESTING: [$method] $url - $description" -level "DB"
    
    $jsonBody = $null
    if ($null -ne $body) {
        $jsonBody = $body | ConvertTo-Json
        Write-TestLog "Request Body: $jsonBody" -level "DB"
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

# ==================== DATABASE CLEANUP OPERATIONS ====================

Write-TestLog "=====================================" -level "DB"
Write-TestLog "STARTING DATABASE CLEANUP" -level "DB"
Write-TestLog "=====================================" -level "DB"

# First, authenticate as admin to get token for cleanup operations
# Load admin credentials from dummy profiles
$profilesJson = Get-Content -Path "$scriptDir\dummy_profiles.json" | ConvertFrom-Json
$adminEmail = $profilesJson.admin.email
$adminPassword = $profilesJson.admin.password

Write-TestLog "Authenticating as administrator for cleanup operations" -level "DB"
$loginBody = @{
    email = $adminEmail
    password = $adminPassword
}

# First try to register the admin (in case it doesn't exist)
$registerAdminBody = @{
    email = $adminEmail
    password = $adminPassword
    firstName = $profilesJson.admin.firstName
    lastName = $profilesJson.admin.lastName
    phoneNumber = $profilesJson.admin.phoneNumber
    address = $profilesJson.admin.address
}

Invoke-ApiRequest -method "POST" -endpoint "/api/v1/auth/signup" -body $registerAdminBody -description "Register Admin User"

# Now login
$response = Invoke-ApiRequest -method "POST" -endpoint "/api/v1/auth/signin" -body $loginBody -description "Admin Login for Cleanup"

if ($response -and $response.token) {
    $jwtToken = $response.token
    Write-TestLog "Authenticated as admin, proceeding with cleanup" -level "SUCCESS"
    
    # Setup auth headers
    $authHeaders = @{
        "Authorization" = "Bearer $jwtToken"
    }
    
    # Create a custom endpoint for database reset (for testing purposes only)
    # Note: In a real application, you would implement a proper database cleanup endpoint with admin-only access
    Write-TestLog "Executing database cleanup (via special test endpoint)..." -level "DB"
    
    try {
        # Call cleanup endpoint (this will be implemented in the Spring Boot application)
        $response = Invoke-ApiRequest -method "POST" -endpoint "/api/v1/admin/test/reset-database" -headers $authHeaders -description "Reset Database"
        
        if ($response) {
            Write-TestLog "Database cleanup completed successfully" -level "SUCCESS"
            Write-TestLog "Ready for test execution" -level "SUCCESS"
            exit 0  # Success
        }
        else {
            # If the special endpoint doesn't exist, try to clean each table individually
            Write-TestLog "Special cleanup endpoint not available. Trying manual cleanup..." -level "WARNING"
            
            # Delete all items
            Invoke-ApiRequest -method "POST" -endpoint "/api/v1/admin/test/cleanup-items" -headers $authHeaders -description "Cleanup Items"
            
            # Delete all users except admin
            Invoke-ApiRequest -method "POST" -endpoint "/api/v1/admin/test/cleanup-users" -headers $authHeaders -description "Cleanup Users"
            
            Write-TestLog "Manual cleanup completed" -level "SUCCESS"
            exit 0  # Success
        }
    }
    catch {
        Write-TestLog "Database cleanup failed: $_" -level "ERROR"
        Write-TestLog "WARNING: Tests will run with existing database state" -level "WARNING"
        exit 0  # Still continue with tests
    }
}
else {
    Write-TestLog "Failed to authenticate as admin for cleanup" -level "ERROR"
    Write-TestLog "WARNING: Tests will run with existing database state" -level "WARNING"
    exit 0  # Still continue with tests
}
