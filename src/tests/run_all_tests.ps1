# Lost and Found API Master Test Runner
# Author: KASOGA Justesse
# Reg: 11471/2024

# Set up variables
$logDir = ".\output"
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

# Helper function to run test and record result
function Run-Test {
    param (
        [string]$testName,
        [string]$scriptPath
    )
    
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "RUNNING TEST: $testName" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    
    $testStartTime = Get-Date
    
    try {
        & $scriptPath
        $success = $?
        $testEndTime = Get-Date
        $duration = $testEndTime - $testStartTime
        
        if ($success) {
            Write-Host "TEST PASSED: $testName" -ForegroundColor Green
            "✅ PASSED: $testName (Duration: $($duration.TotalSeconds) seconds)" | Out-File -FilePath $summaryFile -Append
            return $true
        }
        else {
            Write-Host "TEST FAILED: $testName" -ForegroundColor Red
            "❌ FAILED: $testName (Duration: $($duration.TotalSeconds) seconds)" | Out-File -FilePath $summaryFile -Append
            return $false
        }
    }
    catch {
        $testEndTime = Get-Date
        $duration = $testEndTime - $testStartTime
        Write-Host "TEST ERROR: $testName - $_" -ForegroundColor Red
        "❌ ERROR: $testName - $_ (Duration: $($duration.TotalSeconds) seconds)" | Out-File -FilePath $summaryFile -Append
        return $false
    }
}

# Define test cases
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
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

# Run all tests
$results = @()
foreach ($test in $tests) {
    $result = Run-Test -testName $test.Name -scriptPath $test.Script
    $results += [PSCustomObject]@{
        Name = $test.Name
        Passed = $result
    }
    
    # Add separator in log
    "" | Out-File -FilePath $summaryFile -Append
}

# Calculate summary
$totalTests = $results.Count
$passedTests = ($results | Where-Object { $_.Passed -eq $true }).Count
$failedTests = $totalTests - $passedTests
$endTime = Get-Date
$totalDuration = $endTime - $startTime

# Write summary to file
"=====================================" | Out-File -FilePath $summaryFile -Append
"SUMMARY" | Out-File -FilePath $summaryFile -Append
"=====================================" | Out-File -FilePath $summaryFile -Append
"Total Tests: $totalTests" | Out-File -FilePath $summaryFile -Append
"Passed: $passedTests" | Out-File -FilePath $summaryFile -Append
"Failed: $failedTests" | Out-File -FilePath $summaryFile -Append
"Total Duration: $($totalDuration.TotalSeconds) seconds" | Out-File -FilePath $summaryFile -Append
"Test Completed: $endTime" | Out-File -FilePath $summaryFile -Append

# Display summary
Write-Host "=====================================" -ForegroundColor Yellow
Write-Host "TEST SUMMARY" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Yellow
Write-Host "Total Tests: $totalTests"
Write-Host "Passed: $passedTests" -ForegroundColor Green
Write-Host "Failed: $failedTests" -ForegroundColor Red
Write-Host "Total Duration: $($totalDuration.TotalSeconds) seconds"
Write-Host "Test Completed: $endTime"
Write-Host "Summary saved to: $summaryFile"

# Open summary file
Write-Host "Opening summary file..."
Invoke-Item $summaryFile
