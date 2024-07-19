@echo off
setlocal enabledelayedexpansion

title NVIDIA Settings 
powershell.exe -Command "$host.ui.RawUI.WindowTitle = 'NVIDIA Settings | @IBRPRIDE'"

REM Check if script is running with administrative privileges, elevate if not
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    goto :uacprompt
) else (
    goto :gotadmin
)

:uacprompt
REM Elevate using PowerShell
powershell.exe -Command "Start-Process '%~0' -Verb RunAs"
exit /B

:gotadmin
REM Clean up the temporary VBScript if it exists
if exist "%temp%\getadmin.vbs" (
    del "%temp%\getadmin.vbs"
)

REM Set script directory as the current directory
pushd "%CD%"
CD /D "%~dp0"

:NVIDIAs
echo.
echo [96m Do you want to Modify your NVIDIA Control Panel[0m
echo.
echo  1 = [93mNVIDIA Settings (Default)[0m
echo  2 = [93mNVIDIA Settings[0m
echo.
set /p choice="Enter your choice: "
if "%choice%"=="1" (
    goto Default
) else if "%choice%"=="2" (
    goto NVIDIA
) else (
    echo [91m Invalid choice. Please enter 1 or 2.[0m
    pause
    cls
    goto NVIDIAs
)

:NVIDIA
echo [92mExecute NVIDIA Profile Inspector with the appropriate settings file[0m
powershell.exe -Command "& '%~dp0\_nvidiaProfileInspector.exe' -ArgumentList '%~dp0\IBRPRIDE.nip'"

goto done

:Default
echo [92mExecute NVIDIA Profile Inspector with the default settings file[0m
powershell.exe -Command "& '%~dp0\_nvidiaProfileInspector.exe' -ArgumentList '%~dp0\NVIDIA Settings.nip'"

goto done

:done
echo [92mYour Nvidia Profile Inspector has been changed successfully.[0m
echo.
pause
goto exit

:exit
popd
exit /B
