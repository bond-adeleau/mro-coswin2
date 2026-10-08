@echo off
setlocal
start "Assistant de creation" powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Serveur Assistant.ps1"
endlocal
