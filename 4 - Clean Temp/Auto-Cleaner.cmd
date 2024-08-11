@echo off
setlocal EnableDelayedExpansion
powershell.exe -Command "$host.ui.RawUI.WindowTitle = 'Auto Cleaner | @IBRHUB'"

::  Set Console Opacity Transparent
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0SetConsoleOpacity.ps1"

mode con: cols=75 lines=28

:Auto-Cleaner
cls

echo:
echo:
echo:
echo:
echo:
echo:
echo:                               [96m Auto Cleaner[0m     
echo:            ___________________________________________________ 
echo:                                                               
echo:                   	[1] [93m Temp and Prefetch  [0m
echo:                  	[2] [93m Event Viewer[0m
echo:               _____________________________________________   
echo:                                                               
echo:                            	 [0] [91mExit[0m
echo:            ___________________________________________________
echo:
set /p choice=                            "Enter your choice: "
if "%choice%"=="1" (
    goto TempPrefetch
) else if "%choice%"=="2" (
    goto EventViewer
) else if "%choice%"=="0" (
    goto end
) else (
    echo                    [91m Invalid choice. Please enter 1, 2, or 0.[0m
    pause
    cls
    goto Auto-Cleaner
)


:TempPrefetch
echo.
echo [93m- Clean up temp folders[0m
rd /s /q !TEMP! >nul 2>&1
rd /s /q !windir!\temp >nul 2>&1
md !TEMP! >nul 2>&1
md !windir!\temp >nul 2>&1
echo  [92mTemp folders have been cleaned[0m
echo.
echo.
echo [93m- Clean up the Prefetch folder[0m
rd /s /q !windir!\Prefetch >nul 2>&1

echo  [92mPrefetch folder has been cleaned[0m
echo.

pause
goto Auto-Cleaner

:EventViewer
echo.
echo [93m- Clear all Event Viewer logs[0m
echo.
echo.
for /f "tokens=*" %%a in ('wevtutil el') do (
    wevtutil cl "%%a"
) >nul 2>&1
echo [93m- Event Viewer logs has been cleaned[0m
echo.

pause
goto Auto-Cleaner

:end
exit /b

