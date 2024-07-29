@echo off
setlocal enabledelayedexpansion
mode con: cols=75 lines=28
powershell.exe -Command "$host.ui.RawUI.WindowTitle = 'Power Plan | @IBRPRIDE'"

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

:PowerPlanM
cls
mode con: cols=75 lines=28
echo:
echo:
echo:
echo:
echo:
echo:                             [96m Apply PowerPlan[0m     
echo:            ___________________________________________________ 
echo:                                                               
echo:                       [1] [93mPowerPlan ( IBRPRIDE )[0m
echo:                       [2] [93mPowerPlan ( Default ) [0m
echo:               _____________________________________________   
echo:                                                               
echo:                       [0] [91mExit[0m
echo:            ___________________________________________________
echo:
set /p choice=                            "Enter your choice: "
if "%choice%"=="1" (
    goto start
) else if "%choice%"=="2" (
    goto Default
) else if "%choice%"=="0" (
    goto end
) else (
    echo                    [91m Invalid choice. Please enter 1, 2, or 0.[0m
    pause
    cls
    goto PowerPlanM
)

:start

mode con: cols=113 lines=35
cls
echo.
echo Import power plan
powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 71111177-7117-7117-7117-711111111117 >nul 2>&1
if errorlevel 1 (
    echo Error: Unable to import power plan.
    pause
    goto PowerPlanM
)


echo.
echo Set power plan active
powercfg /SETACTIVE 71111177-7117-7117-7117-711111111117 >nul 2>&1
if errorlevel 1 (
    echo Error: Unable to set active power plan.
    pause
    goto PowerPlanM
)



:disableFeatures
echo.
echo Disable hibernate
powercfg /hibernate off >nul 2>&1
if errorlevel 1 (
    echo Error: Unable to disable hibernate.
)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabledDefault" /t REG_DWORD /d "0" /f >nul 2>&1


echo.
echo Disable lock
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" /v "ShowLockOption" /t REG_DWORD /d "0" /f >nul 2>&1


echo.
echo Disable sleep
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" /v "ShowSleepOption" /t REG_DWORD /d "0" /f >nul 2>&1


echo.
echo Disable fast boot
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f >nul 2>&1


:optimizeSettings
echo.
echo Unpark CPU cores
reg add "HKLM\SYSTEM\ControlSet001\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v "ValueMax" /t REG_DWORD /d "0" /f >nul 2>&1


echo.
echo Disable power throttling
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f >nul 2>&1


echo.
echo Optimization system responsiveness
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d "0" /f >nul 2>&1


echo.
echo Unhide hub selective suspend timeout
reg add "HKLM\System\ControlSet001\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\0853a681-27c8-4100-a2fd-82013e970683" /v "Attributes" /t REG_DWORD /d "2" /f >nul 2>&1


echo.
echo Unhide USB 3 link power management
reg add "HKLM\System\ControlSet001\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\d4e98f31-5ffe-4ce1-be31-1b38b384c009" /v "Attributes" /t REG_DWORD /d "2" /f >nul 2>&1


:modifySettings
echo.
echo [91mMODIFY DESKTOP [0m
echo Hard disk turn off hard disk after 0%
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0x00000000
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0x00000000


echo.
echo Desktop background settings slide show paused
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 001
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 001


echo.
echo Wireless adapter settings power saving mode maximum performance
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 000
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 000


echo.
echo Sleep after 0%
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 0x00000000
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 0x00000000


echo.
echo Allow hybrid sleep off
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 000
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 000


echo.
echo Hibernate after
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 238c9fa8-0aad-41ed-83f4-97be242c8f20 9d7815a6-7ee4-497e-8888-515a05f02364 0x00000000
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 238c9fa8-0aad-41ed-83f4-97be242c8f20 9d7815a6-7ee4-497e-8888-515a05f02364 0x00000000


echo.
echo Allow wake timers disable
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 238c9fa8-0aad-41ed-83f4-97be242c8f20 bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d 000
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 238c9fa8-0aad-41ed-83f4-97be242c8f20 bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d 000


echo.
echo USB settings
echo Hub selective suspend timeout 0
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 2a737441-1930-4402-8d77-b2bebba308a3 0853a681-27c8-4100-a2fd-82013e970683 0x00000000
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 2a737441-1930-4402-8d77-b2bebba308a3 0853a681-27c8-4100-a2fd-82013e970683 0x00000000


echo.
echo USB selective suspend setting disabled
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 000
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 000


echo.
echo USB 3 link power management - off
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 2a737441-1930-4402-8d77-b2bebba308a3 d4e98f31-5ffe-4ce1-be31-1b38b384c009 000
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 2a737441-1930-4402-8d77-b2bebba308a3 d4e98f31-5ffe-4ce1-be31-1b38b384c009 000


echo.
echo Power buttons and lid start menu power button shut down
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 4f971e89-eebd-4455-a8de-9e59040e7347 a7066653-8d6c-40a8-910e-a1f54b84c7e5 002
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 4f971e89-eebd-4455-a8de-9e59040e7347 a7066653-8d6c-40a8-910e-a1f54b84c7e5 002


echo.
echo PCI express link state power management off
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 000
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 000


echo.
echo Minimum processor state 100%
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 0x00000064
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 0x00000064


echo.
echo System cooling policy active
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 54533251-82be-4824-96c1-47b60b740d00 94d3a615-a899-4ac5-ae2b-e4d8f634367f 001
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 54533251-82be-4824-96c1-47b60b740d00 94d3a615-a899-4ac5-ae2b-e4d8f634367f 001


echo.
echo Maximum processor state 100%
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 0x00000064
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 0x00000064


echo.
echo Display
echo Turn off display after 0%
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0x00000000
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0x00000000


echo.
echo Display brightness 100%
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 7516b95f-f776-4464-8c53-06167f40cc99 aded5e82-b909-4619-9949-f5d71dac0bcb 0x00000064
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 7516b95f-f776-4464-8c53-06167f40cc99 aded5e82-b909-4619-9949-f5d71dac0bcb 0x00000064


echo.
echo Dimmed display brightness 100%
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 7516b95f-f776-4464-8c53-06167f40cc99 f1fbfde2-a960-4165-9f88-50667911ce96 0x00000064
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 7516b95f-f776-4464-8c53-06167f40cc99 f1fbfde2-a960-4165-9f88-50667911ce96 0x00000064


echo.
echo Enable adaptive brightness off
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 7516b95f-f776-4464-8c53-06167f40cc99 fbd9aa66-9553-4097-ba44-ed6e9d65eab8 000
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 7516b95f-f776-4464-8c53-06167f40cc99 fbd9aa66-9553-4097-ba44-ed6e9d65eab8 000


echo.
echo Video playback quality bias video playback performance bias
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 10778347-1370-4ee0-8bbd-33bdacaade49 001
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 10778347-1370-4ee0-8bbd-33bdacaade49 001


echo.
echo When playing video optimize video quality
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 000
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 000


Powercfg /changename "71111177-7117-7117-7117-711111111117" "IBRPRIDE Power Plan FREE" "The Ultimate Power Plan to increase FPS, improve latency and reduce input lag." >nul 2>&1

echo.


:: Check if the system is a laptop
for /f "skip=1 tokens=2 delims==" %%i in ('wmic path Win32_Battery get BatteryStatus /format:list') do set "BatteryStatus=%%i"
if "%BatteryStatus%"=="" (
    set "isLaptop=0"
) else (
    set "isLaptop=1"
)

if not "%isLaptop%"=="1" goto PowerPlanX
if not "%isLaptop%"=="0" goto MODIFY LAPTOP

:MODIFY LAPTOP
echo [91mMODIFY LAPTOP SETTINGS[0m 
echo Intel(r) graphics settings Intel(r) graphics power plan maximum performance
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 44f3beca-a7c0-460e-9df2-bb8b99e0cba6 3619c3f2-afb2-4afc-b0e9-e7fef372de36 002
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 44f3beca-a7c0-460e-9df2-bb8b99e0cba6 3619c3f2-afb2-4afc-b0e9-e7fef372de36 002
timeout /t 1 /nobreak > NUL

echo.
echo AMD power slider overlay best performance
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 c763b4ec-0e50-4b6b-9bed-2b92a6ee884e 7ec1751b-60ed-4588-afb5-9819d3d77d90 003
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 c763b4ec-0e50-4b6b-9bed-2b92a6ee884e 7ec1751b-60ed-4588-afb5-9819d3d77d90 003
timeout /t 1 /nobreak > NUL

echo.
echo ATI graphics power settings ATI powerplay settings maximize performance
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 f693fb01-e858-4f00-b20f-f30e12ac06d6 191f65b5-d45c-4a4f-8aae-1ab8bfd980e6 001
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 f693fb01-e858-4f00-b20f-f30e12ac06d6 191f65b5-d45c-4a4f-8aae-1ab8bfd980e6 001
timeout /t 1 /nobreak > NUL

echo.
echo Switchable dynamic graphics global settings maximize performance
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 e276e160-7cb0-43c6-b20b-73f5dce39954 a1662ab2-9d34-4e53-ba8b-2639b9e20857 003
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 e276e160-7cb0-43c6-b20b-73f5dce39954 a1662ab2-9d34-4e53-ba8b-2639b9e20857 003
timeout /t 1 /nobreak > NUL

echo.
echo Battery settings
echo Critical battery notification off
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 e73a048d-bf27-4f12-9731-8b2076e8891f 5dbb7c9f-38e9-40d2-9749-4f8a0e9f640f 000
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 e73a048d-bf27-4f12-9731-8b2076e8891f 5dbb7c9f-38e9-40d2-9749-4f8a0e9f640f 000
timeout /t 1 /nobreak > NUL

echo.
echo Critical battery action do nothing
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 e73a048d-bf27-4f12-9731-8b2076e8891f 637ea02f-bbcb-4015-8e2c-a1c7b9c0b546 000
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 e73a048d-bf27-4f12-9731-8b2076e8891f 637ea02f-bbcb-4015-8e2c-a1c7b9c0b546 000
timeout /t 1 /nobreak > NUL

echo.
echo Low battery level 0%
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 e73a048d-bf27-4f12-9731-8b2076e8891f 8183ba9a-e910-48da-8769-14ae6dc1170a 0x00000000
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 e73a048d-bf27-4f12-9731-8b2076e8891f 8183ba9a-e910-48da-8769-14ae6dc1170a 0x00000000
timeout /t 1 /nobreak > NUL

echo.
echo Critical battery level 0%
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 e73a048d-bf27-4f12-9731-8b2076e8891f 9a66d8d7-4ff7-4ef9-b5a2-5a326ca2a469 0x00000000
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 e73a048d-bf27-4f12-9731-8b2076e8891f 9a66d8d7-4ff7-4ef9-b5a2-5a326ca2a469 0x00000000
timeout /t 1 /nobreak > NUL

echo.
echo Low battery notification off
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 e73a048d-bf27-4f12-9731-8b2076e8891f bcded951-187b-4d05-bccc-f7e51960c258 000
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 e73a048d-bf27-4f12-9731-8b2076e8891f bcded951-187b-4d05-bccc-f7e51960c258 000
timeout /t 1 /nobreak > NUL

echo.
echo Low battery action do nothing
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 e73a048d-bf27-4f12-9731-8b2076e8891f d8742dcb-3e6a-4b3c-b3fe-374623cdcf06 000
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 e73a048d-bf27-4f12-9731-8b2076e8891f d8742dcb-3e6a-4b3c-b3fe-374623cdcf06 000
timeout /t 1 /nobreak > NUL

echo.
echo Reserve battery level 0%
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 e73a048d-bf27-4f12-9731-8b2076e8891f f3c5027d-cd16-4930-aa6b-90db844a8f00 0x00000000
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 e73a048d-bf27-4f12-9731-8b2076e8891f f3c5027d-cd16-4930-aa6b-90db844a8f00 0x00000000
timeout /t 1 /nobreak > NUL

echo.
echo Low screen brightness when using battery saver disable
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 de830923-a562-41af-a086-e3a2c6bad2da 13d09884-f74e-474a-a852-b6bde8ad03a8 0x00000064
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 de830923-a562-41af-a086-e3a2c6bad2da 13d09884-f74e-474a-a852-b6bde8ad03a8 0x00000064
timeout /t 1 /nobreak > NUL

echo.
echo Turn battery saver on automatically at never
powercfg /setacvalueindex 71111177-7117-7117-7117-711111111117 de830923-a562-41af-a086-e3a2c6bad2da e69653ca-cf7f-4f05-aa73-cb833fa90ad4 0x00000000 
powercfg /setdcvalueindex 71111177-7117-7117-7117-711111111117 de830923-a562-41af-a086-e3a2c6bad2da e69653ca-cf7f-4f05-aa73-cb833fa90ad4 0x00000000
timeout /t 1 /nobreak > NUL

Powercfg /changename "71111177-7117-7117-7117-711111111117" "IBRPRIDE Power Plan FREE" "The Ultimate Power Plan to increase FPS, improve latency and reduce input lag." >nul 2>&1


echo.
:PowerPlanX
echo Restart to apply . . .
pause >nul
goto PowerPlanM

:Default
cls
:: Restore power plans
powercfg -restoredefaultschemes

:: Enable hibernate
powercfg /hibernate on >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabledDefault" /t REG_DWORD /d "1" /f >nul 2>&1

:: Enable lock & sleep
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" /f >nul 2>&1

:: Enable fast boot
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "1" /f >nul 2>&1

:: Park CPU cores
reg add "HKLM\SYSTEM\ControlSet001\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v "ValueMax" /t REG_DWORD /d "100" /f >nul 2>&1

:: Enable power throttling
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /f >nul 2>&1

:: Default system responsiveness
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d "20" /f >nul 2>&1

:: Hide hub selective suspend timeout
reg add "HKLM\System\ControlSet001\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\0853a681-27c8-4100-a2fd-82013e970683" /v "Attributes" /t REG_DWORD /d "1" /f >nul 2>&1

:: Hide USB 3 link power management
reg add "HKLM\System\ControlSet001\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\d4e98f31-5ffe-4ce1-be31-1b38b384c009" /v "Attributes" /t REG_DWORD /d "1" /f >nul 2>&1

goto PowerPlanM

:end
exit /b
