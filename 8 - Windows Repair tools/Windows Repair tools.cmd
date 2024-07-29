@echo off
setlocal enabledelayedexpansion
mode con: cols=100 lines=35
title Windows Repair tools
powershell.exe -Command "$host.ui.RawUI.WindowTitle = 'Windows Repair tools | @IBRPRIDE'"

::  Set Console Opacity Transparent
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



if exist "%windir%\logs\cbs\cbs.log" (del /f /q "%windir%\logs\cbs\cbs.log" >nul 2>&1)
if exist "%windir%\logs\dism\dism.log" (del /f /q "%windir%\logs\dism\dism.log" >nul 2>&1)
if exist "%~dp0bin\dism\dism.exe" (set "dism=%~dp0bin\dism\dism.exe") else (set dism=%systemroot%\system32\dism.exe)
if exist "%~dp0bin\wimlib-imagex.exe" (set "wimlib=%~dp0bin\wimlib-imagex.exe")

:menu
mode con: cols=100 lines=35
cls
set userinp=
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                             [93m          Windows Repair tools    [0m  
echo              _______________________________________________________________________ 
echo.
echo.                   [1] [92mRun Dism /Online /Cleanup-Image /ScanHealth[0m
echo.                   [2] [93mRun Dism /Online /Cleanup-Image /RestoreHealth[0m
echo.                   [3] [94mRun Dism /Online /Cleanup-Image /RestoreHealth /Source[0m            
echo.                   [4] [92mRun Dism /Online /Cleanup-Image /AnalyzeComponentStore[0m
echo.                   [5] [93mRun Dism /Online /Cleanup-Image /StartComponentCleanup[0m
echo.                   [6] [94mRun Dism /Online /Cleanup-Image /StartComponentCleanup /ResetBase[0m
echo.                   [7] [85mRun SFC /Scannow[0m
echo              _______________________________________________________________________ 
echo:
echo:                                          [0] [91mExit[0m
echo              _______________________________________________________________________ 
echo.
set /p userinp= ^>                       Enter Your Option: 
if [%userinp%]==[] echo.&echo Invalid User Input&echo.&pause&goto :menu
if %userinp% gtr 16 echo.&echo Invalid User Selection&echo.&pause&goto :menu
if %userinp%==0 goto :done
if %userinp%==1 goto :opt1
if %userinp%==2 goto :opt2
if %userinp%==3 goto :opt3
if %userinp%==4 goto :opt4
if %userinp%==5 goto :opt5
if %userinp%==6 goto :opt6
if %userinp%==7 goto :opt7
goto :eof

:opt1

cls
mode con: cols=100 lines=25
echo.           
echo. 
echo.           
echo. 
echo                    _________________________________________________________          
echo.           
echo.                     Dism is scanning the online image for health.
echo.                     Dism will report whether the image is Healthy or Repairable
echo.                     If Dism reports as repairable - Select Option 2
echo.                     Please Wait.. This will take 5-15 minutes..
echo.
echo.
echo                   _________________________________________________________
echo.
if exist "%windir%\logs\cbs\cbs.log" (del /f /q "%windir%\logs\cbs\cbs.log" >nul 2>&1)
%Dism% /Online /Cleanup-Image /ScanHealth
copy "%windir%\logs\cbs\cbs.log" "%userprofile%\desktop\ScanHealth Details.txt"
pause
goto :menu

:opt2

cls
mode con: cols=100 lines=25

echo.           
echo. 
echo.           
echo.
echo                    _________________________________________________________
echo.              
echo.                     Dism uses Windows Update to provide the files required to fix corruption.
echo.                     If Dism reports Source Files Could Not Be Found - Select Option 3
echo.                     Please Wait.. This will take 10-15 minutes or more..
echo.
echo.
echo                    _________________________________________________________
echo.
if exist "%windir%\logs\cbs\cbs.log" (del /f /q "%windir%\logs\cbs\cbs.log" >nul 2>&1)
%Dism% /Online /Cleanup-Image /RestoreHealth
copy "%windir%\logs\cbs\cbs.log" "%userprofile%\desktop\RestoreHealth Details.txt"
pause
goto :menu

:opt3

cls
mode con: cols=100 lines=25

for %%I in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do if exist "%%I:\\setup.exe" set setup=%%I
if defined setup (for %%I in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do if exist "%%I:\\autorun.inf" set autorun=%%I)
if defined autorun (for %%I in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do if exist "%%I:\\sources\install.wim" set setupdrv=%%I)
if defined setupdrv (
echo.           
echo. 
echo.           
echo.
echo                    _________________________________________________________
echo.
echo.                     Found Source Install.wim on Drive %setupdrv%:
echo.
echo                    _________________________________________________________
echo.
goto :wimmenu
)
for %%I in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do if exist "%%I:\\setup.exe" set setup=%%I
if defined setup (for %%I in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do if exist "%%I:\\autorun.inf" set autorun=%%I)
if defined autorun (for %%I in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do if exist "%%I:\\sources\install.esd" set setupdrv=%%I)
if defined setupdrv (
echo.           
echo. 
echo.           
echo.
echo                    _________________________________________________________
echo.
echo.                     Found Source Install.esd on Drive %setupdrv%:
echo.
echo                    _________________________________________________________
echo.
goto :esdmenu
)
if not defined setupdrv (
CLS
echo.           
echo. 
echo.           
echo.
echo                    _________________________________________________________
echo.              
echo.                     No Installation Media Found!
echo.
echo.                     Mount Media ISO or Insert DVD or USB flash drive and run this option again. 
echo _________________________________________________________
pause
goto :menu
)

:wimmenu

cls
mode con: cols=100 lines=25

set userinp=
echo.           
echo. 
echo.           
echo.
echo                    _________________________________________________________
echo.
echo.                    [0]Use Source^:Wim^:Install.wim as Repair Method ^( source:wim: ^)
echo.
echo.                    [1]Mount the Windows Image as the Repair Source ^( Recommended ^)
echo _________________________________________________________
echo.
set /p userinp= ^> Enter Your Option: 
if [%userinp%]==[] echo.&echo Invalid User Input&echo.&pause&goto :wimmenu
if %userinp% gtr 1 echo.&echo Invalid User Selection&echo.&pause&goto :wimmenu
if %userinp%==0 goto :restorewim
if %userinp%==1 goto :mountwim
goto :menu

:restorewim

cls
mode con: cols=100 lines=25
echo.           
echo. 
echo.           
echo.
echo                    _________________________________________________________
echo.
echo.                     Dism is restoring the online image health using the source Install.wim
echo.
echo.                     Please Wait.. This will take 10-15 minutes or more..
echo                    _________________________________________________________
echo.
%Dism% /Online /Cleanup-Image /RestoreHealth /source:wim:%setupdrv%:\sources\install.wim:1 /limitaccess
pause
goto :menu

:Mountwim

cls
mode con: cols=100 lines=25
echo.           
echo. 
echo.           
echo.          
echo.          
echo.                   _________________________________________________________
echo.
echo.                      Mounting the Source Install.wim as the Repair Source
echo.
echo.                      Please Wait.. This will take 5-10 minutes..
echo                    _________________________________________________________
echo.
md "%~dp0Source\Mount"
copy %setupdrv%:\sources\install.wim "%~dp0Source\install.wim"
if not exist "%~dp0Source\install.wim" (echo.&echo ERROR: Required File Copy Failed - File Not Found.&pause&goto :Done)
%Dism% /Mount-Image /ImageFile:"%~dp0Source\install.wim" /Index:1 /MountDir:"%~dp0Source\Mount"
echo.           
echo. 
echo.           
echo.
echo.
echo.
echo                    _________________________________________________________
echo.                   
echo.                      Dism is restoring the online image health using the mounted source media.
echo.                      Please Wait.. This will take 10-15 minutes or more..
echo                    _________________________________________________________
echo.
%Dism% /Online /Cleanup-Image /RestoreHealth /Source:"%~dp0Source\Mount\Windows" /LimitAccess
%Dism% /Unmount-Image /MountDir:"%~dp0Source\Mount" /discard
pause
goto :menu

:esdmenu

cls
mode con: cols=100 lines=25

set userinp=
echo.           
echo. 
echo.           
echo.
echo.
echo.
echo                    _________________________________________________________
echo.
echo.                    [0 ]Use the Source^:ESD^:Install.esd as Repair Method ^( soure:esd: ^)
echo.
echo.                    [1] Export Install.esd to Install.wim as Repair Source ^( source:wim: ^)
echo.
echo.                    [2] Mount the Windows Image as the Repair Source ^( Recommended ^)
echo _________________________________________________________
echo. 
set /p userinp= ^> Enter Your Option: 
if [%userinp%]==[] echo.&echo Invalid User Input&echo.&pause&goto :esdmenu
if %userinp% gtr 2 echo.&echo Invalid User Selection&echo.&pause&goto :esdmenu
if %userinp%==0 goto :restoreesd
if %userinp%==1 goto :exportesd
if %userinp%==2 goto :mountesd
goto :menu

:restoreesd

cls
mode con: cols=100 lines=25
echo.           
echo. 
echo.           
echo.
echo.
echo.
echo                     _________________________________________________________
echo.
echo.                      Dism is restoring the online image health using the source Install.esd
echo.
echo.                      Please Wait.. This will take 10-15 minutes or more..
echo                     _________________________________________________________
%Dism% /Online /Cleanup-Image /RestoreHealth /source:esd:%setupdrv%:\sources\install.esd:1 /limitaccess
pause
goto :menu

:exportesd
if not exist "%~dp0bin\wimlib-imagex.exe" (echo.&echo ERROR: Required Wimlib-Imagex Files Not Found.&pause&goto :done)

cls
mode con: cols=100 lines=25
echo.           
echo. 
echo.           
echo.
echo.
echo.
echo                     _________________________________________________________
echo.
echo.                      Exporting the Sources\Install.esd into a Source\Install.wim
echo.
echo.                      Please Wait.. This will take 5-10 minutes..
echo                     _________________________________________________________
md "%~dp0Source"
%wimlib% export "%setupdrv%:\sources\install.esd" 1 "%~dp0Source\install.wim" --compress=maximum
if not exist "%~dp0Source\install.wim" (echo.&echo ERROR: Required File Export Failed - File Not Found.&pause&goto :done)
CLS
echo.           
echo. 
echo.           
echo.
echo.
echo.
echo                     _________________________________________________________
echo.
echo.                      Dism is restoring the online image health using the exported source media.
echo.
echo.                      Please Wait.. This will take 10-15 minutes or more..
echo                     _________________________________________________________
echo.
%Dism% /Online /Cleanup-Image /RestoreHealth /Source:wim:"%~dp0Source\install.wim":1 /LimitAccess
pause
goto :menu

:Mountesd
if not exist "%~dp0bin\wimlib-imagex.exe" (echo.&echo ERROR: Required Wimlib-Imagex Files Not Found.&pause&goto :done)

cls
mode con: cols=100 lines=25
echo.           
echo. 
echo.           
echo.
echo.
echo.
echo                     _________________________________________________________
echo.
echo.                      Exporting and Mounting the Source Install.esd
echo.
echo.                      Please Wait.. This will take 5-10 minutes..
echo                     _________________________________________________________
echo.
md "%~dp0Source\Mount"
%wimlib% export "%setupdrv%:\sources\install.esd" 1 "%~dp0Source\install.wim" --compress=maximum
if not exist "%~dp0Source\install.wim" (echo.&echo ERROR: Required File Export Failed - File Not Found.&pause&goto :Done)
%Dism% /Mount-Image /ImageFile:"%~dp0Source\install.wim" /Index:1 /MountDir:"%~dp0Source\Mount"
echo.           
echo. 
echo.           
echo.
echo.
echo.
echo                     _________________________________________________________
echo.
echo.                       Dism is restoring the online image health using the mounted source media.
echo.
echo.                       Please Wait.. This will take 10-15 minutes or more..
echo                     _________________________________________________________
echo.
%Dism% /Online /Cleanup-Image /RestoreHealth /Source:"%~dp0Source\Mount\Windows" /LimitAccess
%Dism% /Unmount-Image /MountDir:"%~dp0Source\Mount" /discard
pause
goto :menu

:opt4

cls
mode con: cols=100 lines=25
echo.           
echo. 
echo.           
echo.
echo.
echo.
echo                     _________________________________________________________
echo.
echo.                      Dism is Analyzing the Component Store.
echo.
echo.                      If Dism reports Component Store Cleanup Recommended 
echo.                                        Select Option 5 or 6 
echo.
echo.                      Please Wait.. This will take 5-10 minutes..
echo                     _________________________________________________________
echo.
%Dism% /Online /Cleanup-Image /AnalyzeComponentStore
pause
goto :menu

:opt5

cls
mode con: cols=100 lines=25
echo.           
echo. 
echo.           
echo.
echo.
echo.
echo                     _________________________________________________________   
echo.           
echo.                      Dism is Cleaning Up the Component Store.
echo.
echo.                      Please Wait.. This will take 10-15 minutes..
echo                       _________________________________________________________
echo.
%Dism% /Online /Cleanup-Image /StartComponentCleanup
pause
goto :menu

:opt6

cls
mode con: cols=100 lines=25
echo.           
echo. 
echo.           
echo.
echo.
echo.
echo                       _________________________________________________________  
echo.            
echo.                        Dism is Resetting the Component Store.
echo.
echo.                        Please Wait.. This will take 10-15 minutes or more..
echo                       _________________________________________________________
echo.
%Dism% /Online /Cleanup-Image /StartComponentCleanup /ResetBase
pause
goto :menu

:opt7

cls
mode con: cols=100 lines=25
echo.           
echo. 
echo.           
echo.
echo.
echo.
echo                       _________________________________________________________     
echo.       
echo.                        System File Checker is scanning the online image for corruption. 
echo.
echo.                        Please Wait.. This will take 10-15 minutes or more..
echo                       _________________________________________________________
echo.
if exist "%windir%\logs\cbs\cbs.log" (del /f /q "%windir%\logs\cbs\cbs.log" >nul 2>&1)
sfc.exe /scannow
findstr /c:"[SR]" %windir%\logs\cbs\cbs.log >"%userprofile%\desktop\SFC Details.txt"
CLS
echo.           
echo. 
echo.           
echo.
echo.
echo.         
echo.                     _________________________________________________________    
echo.         
echo.                        A SFC Details Report was Created on your Desktop
echo                       _________________________________________________________
echo. 
pause                      
goto :menu

:done
exit