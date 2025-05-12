# Lost and Found API Master Test Runner
# Author: KASOGA Justesse
# Reg: 11471/2024

# Set up variables
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$logDir = "$scriptDir\output"
$summaryFile = "$logDir\test_summary.txt"
$startTime = Get-Date

# Ensure output directory exists
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

# Start fresh summary file
"" | Out-File -FilePath $summaryFile
"=====================================" | Out-File -FilePath $summaryFile -Append
"LOST AND FOUND API TEST SUMMARY" | Out-File -FilePath $summaryFile -Append
"=====================================" | Out-File -FilePath $summaryFile -Append
"Test Started: $startTime" | Out-File -FilePath $summaryFile -Append
"" | Out-File -FilePath $summaryFile -Append

# Color theme for console output
$colors = @{
    "Header" = "Cyan"
    "Success" = "Green"
    "Error" = "Red"
    "Warning" = "Yellow"
    "Info" = "White"
    "Highlight" = "Magenta"
}

# Helper function to write formatted console and log output
function Write-TestLog {
    param (
        [string]$message,
        [string]$level = "Info",
        [switch]$NoNewLine
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    
    # Add to summary file
    $logMessage | Out-File -FilePath $summaryFile -Append
    
    # Output to console with color
    if ($colors.ContainsKey($level)) {
        if ($NoNewLine) {
            Write-Host $logMessage -ForegroundColor $colors[$level] -NoNewline
        } else {
            Write-Host $logMessage -ForegroundColor $colors[$level]
        }
    } else {
        if ($NoNewLine) {
            Write-Host $logMessage -NoNewline
        } else {
            Write-Host $logMessage
        }
    }
}

# Write divider to provide visual separation
function Write-Divider {
    $divider = "=" * 60
    Write-TestLog $divider -level "Header"
}

# Helper function to run tests
function Start-Test {
    param (
        [string]$testName,
        [string]$scriptPath
    )
    
    Write-Divider
    Write-TestLog "RUNNING TEST: $testName" -level "Header"
    Write-Divider
    
    $testStartTime = Get-Date
    
    try {
        # First try to execute the script directly to show any error messages
        try {
            Write-TestLog "Executing test script directly..." -level "Info"
            & $scriptPath
            $exitCode = $?
            
            $testEndTime = Get-Date
            $duration = $testEndTime - $testStartTime
            
            if ($exitCode) {
                Write-TestLog "TEST PASSED: $testName" -level "Success"
                "✅ PASSED: $testName (Duration: $($duration.TotalSeconds) seconds)" | Out-File -FilePath $summaryFile -Append
                return $true
            }
        } catch {
            # If direct execution fails, try with execution policy bypass
            Write-TestLog "Direct execution failed, attempting bypass for test script" -level "Warning"
            Write-TestLog "Error was: $_" -level "Warning"
            
            # Execute the test script in a separate process with policy bypass
            $process = Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`"" -NoNewWindow -PassThru -Wait
            $exitCode = $process.ExitCode
            
            $testEndTime = Get-Date
            $duration = $testEndTime - $testStartTime
            
            if ($exitCode -eq 0) {
                Write-TestLog "TEST PASSED: $testName" -level "Success"
                "✅ PASSED: $testName (Duration: $($duration.TotalSeconds) seconds)" | Out-File -FilePath $summaryFile -Append
                return $true
            } else {
                Write-TestLog "TEST FAILED: $testName (Exit Code: $exitCode)" -level "Error"
                "❌ FAILED: $testName (Duration: $($duration.TotalSeconds) seconds)" | Out-File -FilePath $summaryFile -Append
                return $false
            }
        }
    } catch {
        $testEndTime = Get-Date
        $duration = $testEndTime - $testStartTime
        Write-TestLog "TEST ERROR: $testName - $_" -level "Error"
        "❌ ERROR: $testName - $_ (Duration: $($duration.TotalSeconds) seconds)" | Out-File -FilePath $summaryFile -Append
        return $false
    }
}

# Check PowerShell execution policy
$currentPolicy = Get-ExecutionPolicy
Write-TestLog "Current PowerShell execution policy: $currentPolicy" -level "Info"

# Provide instructions if execution policy is restrictive
if ($currentPolicy -eq "Restricted" -or $currentPolicy -eq "AllSigned") {
    Write-TestLog "⚠️ PowerShell execution policy is restrictive, tests might not run properly" -level "Warning"
    Write-TestLog "To run tests, you may need to temporarily change the execution policy." -level "Warning"
    Write-TestLog "Run this command as Administrator: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process" -level "Warning"
    Write-TestLog "Press any key to try continuing..." -level "Info"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Run database cleanup first
Write-TestLog "🧹 Cleaning database before tests..." -level "Highlight"
try {
    # Try running the script directly first to show any error messages
    try {
        & "$scriptDir\db_cleanup.ps1"
        Write-TestLog "Database cleanup completed successfully" -level "Success"
    } catch {
        # If direct execution fails, try bypassing policy for just this script
        Write-TestLog "Direct script execution failed, attempting bypass for cleanup script" -level "Warning"
        $cleanupProcess = Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptDir\db_cleanup.ps1`"" -NoNewWindow -PassThru -Wait
        
        if ($cleanupProcess.ExitCode -eq 0) {
            Write-TestLog "Database cleanup completed successfully with bypass" -level "Success"
        } else {
            Write-TestLog "Database cleanup completed with warnings (tests will continue)" -level "Warning"
        }
    }
} catch {
    Write-TestLog "Database cleanup encountered an error: $_" -level "Error"
    Write-TestLog "Continuing with tests anyway..." -level "Warning"
}

# Define test cases in order of execution
$tests = @(
    @{
        Name = "API Basic Tests"
        Script = "$scriptDir\api_tests.ps1"
    },
    @{
        Name = "User Journey Tests"
        Script = "$scriptDir\user_journey_tests.ps1"
    },
    @{
        Name = "Admin Functionality Tests"
        Script = "$scriptDir\admin_tests.ps1"
    }
)

# Run all tests sequentially
$results = @()
foreach ($test in $tests) {
    $result = Start-Test -testName $test.Name -scriptPath $test.Script
    $results += [PSCustomObject]@{
        Name = $test.Name
        Passed = $result
    }
    
    # Add separator in log
    "" | Out-File -FilePath $summaryFile -Append
    
    # Add a 3-second delay between tests to ensure complete separation
    Start-Sleep -Seconds 3
}

# Calculate summary
$totalTests = $results.Count
$passedTests = ($results | Where-Object { $_.Passed -eq $true }).Count
$failedTests = $totalTests - $passedTests
$endTime = Get-Date
$totalDuration = $endTime - $startTime

# Write summary to file and console
Write-Divider
Write-TestLog "TEST SUMMARY" -level "Highlight"
Write-Divider

"Total Tests: $totalTests" | Out-File -FilePath $summaryFile -Append
"Passed: $passedTests" | Out-File -FilePath $summaryFile -Append
"Failed: $failedTests" | Out-File -FilePath $summaryFile -Append
"Total Duration: $($totalDuration.TotalSeconds) seconds" | Out-File -FilePath $summaryFile -Append
"Test Completed: $endTime" | Out-File -FilePath $summaryFile -Append

# Display summary
Write-TestLog "Total Tests: $totalTests" -level "Info"
Write-TestLog "Passed: $passedTests" -level "Success"
Write-TestLog "Failed: $failedTests" -level "Error"
Write-TestLog "Total Duration: $($totalDuration.TotalSeconds) seconds" -level "Info"
Write-TestLog "Test Completed: $endTime" -level "Info"
Write-TestLog "Summary saved to: $summaryFile" -level "Info"

# Open summary file
Write-TestLog "Opening summary file..." -level "Info"
Invoke-Item $summaryFile