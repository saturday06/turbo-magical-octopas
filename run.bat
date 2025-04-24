REM run.bat
setlocal

cd /d "%~dp0"

where pwsh >nul 2>&1
if %errorlevel% equ 0 (
  pwsh -ExecutionPolicy Bypass -File run.ps1
  exit /b %errorlevel%
)

where powershell >nul 2>&1
if %errorlevel% equ 0 (
  powershell -ExecutionPolicy Bypass -File run.ps1
  exit /b %errorlevel%
)

echo PowerShellが見つかりません。
endlocal
pause
exit /b 1
