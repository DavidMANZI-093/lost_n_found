# Reset database script for Lost and Found API Tests
# This script truncates all tables in the database to ensure a clean state for testing

# Set up variables
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$logFile = "$scriptDir\output\reset_log.txt"

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
        "STEP" = "Cyan"
    }
    
    $color = $colorMap[$level]
    
    "$timestamp [$level] - $message" | Out-File -FilePath $logFile -Append
    Write-Host "$timestamp [$level] - $message" -ForegroundColor $color
}

# Database connection details - these should match your application.properties
$pgHost = "localhost"
$pgPort = "5432"
$pgDatabase = "lost_n_found"
$pgUser = "postgres"
$pgPassword = "post093"

Write-TestLog "Resetting database..." -level "STEP"
Write-TestLog "This will truncate all tables in the lost_n_found database!" -level "WARNING"

# Check if psql is available
try {
    $null = Get-Command psql -ErrorAction Stop
    $psqlAvailable = $true
} catch {
    $psqlAvailable = $false
    Write-TestLog "PostgreSQL command-line tools not found. Please install PostgreSQL or add it to your PATH." -level "ERROR"
    Write-TestLog "Manual database reset is required before running tests." -level "WARNING"
    exit 1
}

if ($psqlAvailable) {
    # Create a temporary SQL file
    $tempFile = [System.IO.Path]::GetTempFileName()
    
    # SQL commands to truncate all tables and reset sequences
    @"
-- Disable foreign key constraints temporarily
SET session_replication_role = 'replica';

-- Truncate all tables
TRUNCATE TABLE users, lost_items, found_items CASCADE;

-- Reset sequences
ALTER SEQUENCE users_id_seq RESTART WITH 1;
ALTER SEQUENCE lost_items_id_seq RESTART WITH 1;
ALTER SEQUENCE found_items_id_seq RESTART WITH 1;

-- Re-enable foreign key constraints
SET session_replication_role = 'origin';

-- Insert admin user
INSERT INTO users (email, password, first_name, last_name, phone_number, address, is_admin, is_banned, created_at, updated_at)
VALUES ('admin@lostfound.com', '\$2a\$10\$J3phU5ST8vVCvUqFLmRYOuZB.s.viyL1rzVbXxO6ncCxz7L8R/No2', 'David', 'Admin', '0799775533', 'Kigali, Rwanda', true, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
"@ | Out-File -FilePath $tempFile -Encoding utf8
    
    # Run the SQL script using psql
    try {
        $env:PGPASSWORD = $pgPassword
        psql -h $pgHost -p $pgPort -d $pgDatabase -U $pgUser -f $tempFile
        Write-TestLog "Database reset successfully!" -level "SUCCESS"
        Write-TestLog "Admin user created with email: admin@lostfound.com and password: AdminPass123!" -level "INFO"
    }
    catch {
        Write-TestLog "Error resetting database: $_" -level "ERROR"
        exit 1
    }
    finally {
        # Clean up
        Remove-Item -Path $tempFile -Force
        $env:PGPASSWORD = ""
    }
}

# Return success
exit 0
