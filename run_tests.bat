@echo off
echo Running Lost and Found API Test Suite with execution policy bypass...
powershell.exe -ExecutionPolicy Bypass -File "%~dp0src\tests\run_all_tests.ps1"
pause
