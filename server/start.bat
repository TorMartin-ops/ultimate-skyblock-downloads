@echo off
rem Starts the Voidhome server loop: backup, start, and start again after /skyblock restart.
rem Extra arguments go to start.ps1, for example: start.bat -RestartOnCrash
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start.ps1" %*
if errorlevel 1 pause
