@echo off
setlocal enabledelayedexpansion
mode con: cols=75 lines=28
title AMD settings
powershell.exe -Command "$host.ui.RawUI.WindowTitle = 'AMD settings | @IBRHUB'"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0SetConsoleOpacity.ps1"
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

:Menu
mode con: cols=75 lines=28
cls
echo:
echo:
echo:
echo:
echo:
echo:
echo:
echo:                               [96mAMD settings[0m     
echo:            ___________________________________________________ 
echo:                                                               
echo:                        [1] [93mAdrenalin Edition Settings  [0m
echo:
echo:                        [2] [93mAMD Drivers  [0m
echo:               _____________________________________________   
echo:                                                               
echo:                        [3] [92mHelp[0m
echo:                        [0] [91mExit[0m
echo:            ___________________________________________________
echo:
set /p choice="Enter your choice: "
if "%choice%"=="1" goto AMDsettingsX
if "%choice%"=="2" goto AMDDrivers
if "%choice%"=="3" goto HELP
if "%choice%"=="0" goto end
echo                    [91m Invalid choice. Please enter 1, 2, or 0.[0m
pause
cls
goto Menu





:AMDsettingsX
mode con: cols=80 lines=44
::Start-Process "C:\Program Files\AMD\CNext\CNext\RadeonSoftware.exe"
echo.
echo:        _____________________________________________________________
echo:  
echo         "Open [93mAdrenalin Edition Software[0m  > Go to [93mGaming[0m  > [93mDisplay[0m "
echo:        _____________________________________________________________
echo:
echo:                               [93mDisplay Settings[0m 
echo: 
echo          "In Game Overlay [[91mOFF[0m]"
echo          "Check For Updates [[91mManual[0m]"
echo          "Issue Detection [[91mOFF[0m]"
echo. 
echo          "AMD FreeSync [[91mOFF[0m]"
echo          "Virtual Super Resolution [[91mOFF[0m]"
echo          "GPU Scaling [[91mOFF[0m]"
echo          "Integer Scaling [[91mOFF[0m]"
echo:
echo:        _____________________________________________________________
echo:  
echo         "Open [93mAdrenalin Edition Software[0m  > Go to [93mGaming[0m  > [93mGraphics[0m"
echo:        _____________________________________________________________
echo:
echo:                               [93mGraphics Settings[0m 
echo: 
echo        "Radeon Super Resolution [[91mOFF[0m]"
echo        "Radeon Anti-Lag [[91mOFF buggy[0m]"
echo        "Radeon Chill [[91mOFF[0m]"
echo        "Radeon Enhanced Sync [[91mOFF[0m]"
echo        "Wait for Vertical Refresh [[91mOFF[0m]"
echo        "Frame rate target control [[91mOFF[0m]"
echo        "Morphological Anti-Aliasing [[91mOFF[0m]"
echo        "Ansiotropic Filtering [[91mOFF[0m]"
echo        "Texture Filtering Quality [[91mPerformance[0m]"
echo        "Surface Format Optimization [[91mOn[0m]"
echo        "Tessellation Mode [[91mOverride Application Settings[0m]"
echo        "Maximum Tessellation Level [[91mOFF[0m]"
echo        "OpenGL Triple Buffering [[91mOFF[0m]"
echo        "10-Bit Pixel Format [[91mOFF[0m]"
echo: 

pause
goto Menu

:AMDDrivers
start "" "https://www.amd.com/en/support/download/drivers.html"

pause
goto Menu

:HELP

start "" "https://IBRPRIDE.COM"
pause
goto Menu

:end
exit /b