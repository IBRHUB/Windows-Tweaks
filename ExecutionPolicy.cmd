@echo off
setlocal enabledelayedexpansion
mode con: cols=75 lines=28
title ExecutionPolicy
powershell.exe -Command "$host.ui.RawUI.WindowTitle = 'ExecutionPolicy | @IBRHUB'"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0/_Modules/SetConsoleOpacity.ps1"
:: Check for administrator privileges
fltmc > nul 2>&1 || (
	echo Administrator privileges are required.
	powershell -c "Start-Process -Verb RunAs -FilePath 'cmd' -ArgumentList " 2> nul || (
		echo You must run this script as admin.
		if "%*"=="" pause
		exit /b 1
	)
	exit /b
)

:ExecutionPolicyM
cls
echo:
echo:
echo:
echo:
echo:
echo:
echo:                     [96mPowerShell Execution Policy Bypass [0m     
echo:            ___________________________________________________ 
echo:                                                               
echo:                       [1] [93mExecution Policy ( Bypass ) [0m
echo:                       [2] [93mExecution Policy ( Default ) [0m
echo:               _____________________________________________   
echo:                                                               
echo:                       [3] [92mHelp[0m
echo:                       [0] [91mExit[0m
echo:            ___________________________________________________
echo:
set /p choice=                            "Enter your choice: "
if "%choice%"=="1" (
    goto ExecutionPolicy
) else if "%choice%"=="2" (
    goto Default
) else if "%choice%"=="3" (
    goto Help
) else if "%choice%"=="0" (
    goto exit
) else (
    echo                    [91m Invalid choice. Please enter 1, 2, or 0.[0m
    pause
    cls
    goto ExecutionPolicyM
)

:ExecutionPolicy
:: PowerShell
Reg.exe add "HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v "Path" /t REG_SZ /d "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v "ExecutionPolicy" /t REG_SZ /d "Bypass" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v "Path" /t REG_SZ /d "C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v "ExecutionPolicy" /t REG_SZ /d "Bypass" /f >nul 2>&1
cd %~dp0
powershell -Command "Get-ChildItem -Path $PSScriptRoot -Recurse | Unblock-File"

echo:
echo ExecutionPolicy is Enabled
echo:
pause
goto ExecutionPolicyM

:Default
reg add "HKCU\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v "ExecutionPolicy" /t REG_SZ /d "Restricted" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v "ExecutionPolicy" /t REG_SZ /d "Restricted" /f >nul 2>&1
echo:
echo Execution Policy is Default
echo:
pause
goto ExecutionPolicyM

:end
exit /b

