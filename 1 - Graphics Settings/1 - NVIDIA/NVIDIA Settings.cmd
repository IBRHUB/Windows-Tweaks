@echo off
setlocal enabledelayedexpansion
mode con: cols=75 lines=28
title NVIDIA Settings 
powershell.exe -Command "$host.ui.RawUI.WindowTitle = 'NVIDIA Settings | @IBRPRIDE'"
::  Set Console Opacity Transparent

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\_Modules\SetConsoleOpacity.ps1"

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

REM Set script directory as the current directory
pushd "%CD%"
CD /D "%~dp0"

:NVIDIAs
cls
echo:
echo:
echo:
echo:
echo:
echo:
echo:
echo:             [96m Do you want to Modify your NVIDIA Control Panel[0m     
echo:            ___________________________________________________ 
echo:                                                               
echo:                       [1] [93mNVIDIA Settings ( Tweaked )[0m
echo:                       [2] [93mNVIDIA Settings ( Default ) [0m
echo:               _____________________________________________   
echo:                                                               
echo:                       [0] [91mExit[0m
echo:            ___________________________________________________
echo:
set /p choice=                            "Enter your choice: "
if "%choice%"=="1" (
    goto NVIDIA
) else if "%choice%"=="2" (
    goto Default
) else if "%choice%"=="0" (
    goto exit
) else (
    echo                    [91m Invalid choice. Please enter 1, 2, or 0.[0m
    pause
    cls
    goto NVIDIAs
)



:NVIDIA
cls
echo [94mExecute NVIDIA Profile Inspector with the appropriate settings file[0m
powershell.exe -Command "& '%~dp0\_nvidiaProfileInspector.exe' -ArgumentList '%~dp0\IBRPRIDE.nip'"

goto done

:Default
cls
echo [94mExecute NVIDIA Profile Inspector with the default settings file[0m
powershell.exe -Command "& '%~dp0\_nvidiaProfileInspector.exe' -ArgumentList '%~dp0\Default.nip'"

goto done

:done
echo.
echo [92mYour Nvidia Profile Inspector has been changed successfully.[0m
echo.
pause
goto NVIDIAs

:exit
popd
exit /B

