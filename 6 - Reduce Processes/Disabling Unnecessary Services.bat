@echo off

:: Enable Delayed Expansion
setlocal enabledelayedexpansion
    cd /d %~dp0 
whoami /user | find /i "S-1-5-18" > nul 2>&1 || (
    call "RunAsTI.cmd" "%~f0" %*
    exit /b
)

cd /d %~dp0 
start Disclaimer.txt
pause
cls
color 2
echo Disabling Unnecessary Services
powershell -ExecutionPolicy Bypass -Command "Checkpoint-Computer -Description 'Unnecessary Services' -RestorePointType 'MODIFY_SETTINGS'" 
:: Beep - Disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Beep" /v "Start" /t REG_DWORD /d 4 /f

:: GraphicsPerfSvc - Disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\GraphicsPerfSvc" /v "Start" /t REG_DWORD /d 4 /f

:: Desktop Activity Moderator Driver - Disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dam" /v "Start" /t REG_DWORD /d 4 /f

:: Background Activity Moderator Driver - Disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\bam" /v "Start" /t REG_DWORD /d 4 /f

:: GPU Energy Driver - Disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDrv" /v "Start" /t REG_DWORD /d 4 /f

:: NetBT - Disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NetBT" /v "Start" /t REG_DWORD /d 4 /f

:: Intel(R) Telemetry Service - Disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Telemetry" /v "Start" /t REG_DWORD /d 4 /f

:: Windows Network Data Usage Monitoring Driver - Disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Ndu" /v "Start" /t REG_DWORD /d 4 /f

:: Microsoft (R) Diagnostics Hub Standard Collector Service - Disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\diagnosticshub.standardcollector.service" /v "Start" /t REG_DWORD /d 4 /f

:: Windows Error Reporting Service - Disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WerSvc" /v "Start" /t REG_DWORD /d 4 /f

:: Unified Telemetry Client - Disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack" /v "Start" /t REG_DWORD /d 4 /f

:: Windows Insider Service - Disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\wisvc" /v "Start" /t REG_DWORD /d 4 /f

:: Program Compatibility Assistant Service - Disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PcaSvc" /v "Start" /t REG_DWORD /d 4 /f

:: Diagnostic Policy Service - Disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DPS" /v "Start" /t REG_DWORD /d 4 /f

:: Diagnostic Service Host - Disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdiServiceHost" /v "Start" /t REG_DWORD /d 4 /f

:: Diagnostic System Host - Disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdiSystemHost" /v "Start" /t REG_DWORD /d 4 /f

:: Tcpipreg - Disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\tcpipreg" /v "Start" /t REG_DWORD /d 4 /f

:: EdgeUpdate - Manual
reg add "HKLM\SYSTEM\CurrentControlSet\Services\edgeupdate" /v "Start" /t REG_DWORD /d 3 /f

:: Windows Event Collector - Disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Wecsvc" /v "Start" /t REG_DWORD /d 4 /f
timeout /t 1 /nobreak > NUL

