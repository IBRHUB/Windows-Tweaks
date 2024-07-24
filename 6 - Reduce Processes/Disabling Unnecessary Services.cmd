@echo off
setlocal enabledelayedexpansion
title Reduce Processes
mode con: cols=75 lines=28
powershell.exe -Command "$host.ui.RawUI.WindowTitle = 'Reduce Processes | @IBRPRIDE'"

cd /d %~dp0 
:: Open Disclaimer.txt in Notepad
start "" notepad.exe "%~dp0Disclaimer.txt"

timeout /t 15 /nobreak >nul
pause

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

:Reduce-ProcessesM
cls

echo:
echo:
echo:
echo:
echo:
echo:                             [96m Reduce Processes[0m     
echo:            ___________________________________________________ 
echo:                                                               
echo:                   [1] [93mReduce Processes [0m
echo:                   [2] [93mReduce Processes ( Default ) [0m
echo:               _____________________________________________   
echo:                                                               
echo:                             [0] [91mExit[0m
echo:            ___________________________________________________
echo:
set /p choice=                            "Enter your choice: "
if "%choice%"=="1" (
    goto Reduce
) else if "%choice%"=="2" (
    goto Default
) else if "%choice%"=="0" (
    goto end
) else (
    echo                    [91m Invalid choice. Please enter 1, 2, or 0.[0m
    pause
    cls
    goto Reduce-ProcessesM
)
:Reduce
Fsutil behavior set memoryusage 2 > $null 2>&1
Reg.exe Add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management" /v "SystemPages" /t REG_DWORD /d "4294967295" /f > $null 2>&1
Reg.exe Add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f > $null 2>&1
Reg.exe Add "HKLM\System\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d "4294967295" /f > $null 2>&1
Try { Disable-MMAgent -MemoryCompression  > $null 2>&1 } Catch {}
Try { Disable-MMAgent -PageCombining  > $null 2>&1 } Catch {}
Reg.exe Add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePageCombining" /t REG_DWORD /d "1" /f > $null 2>&1
Reg.exe Add "HKLM\System\CurrentControlSet\Control\Session Manager" /v "HeapDeCommitFreeBlockThreshold" /t REG_DWORD /d "262144" /f > $null 2>&1

timeout /t 1 /nobreak >nul

powershell.exe -Command "Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services' | Where-Object { `$_.Name -notmatch 'Xbl|Xbox|BITS' } | ForEach-Object { `$path = 'SYSTEM\CurrentControlSet\Services\' + `$_.PSChildName; `$found = Get-ItemProperty -Path "REGISTRY::`$_"; if (`$null -ne `$found.Start) { Reg.exe Add "`$_" /v "SvcHostSplitDisable" /t REG_DWORD /d "1" /f  } }; exit"


pause
goto Reduce-ProcessesM
:Default
Fsutil behavior set memoryusage 0 > $null 2>&1
Reg.exe Add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management" /v "SystemPages" /t REG_DWORD /d "0" /f > $null 2>&1
Reg.exe Add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "0" /f > $null 2>&1
Reg.exe Add "HKLM\System\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d "3670016" /f > $null 2>&1
Try { Enable-MMAgent -MemoryCompression  > $null 2>&1 } Catch {}
Try { Enable-MMAgent -PageCombining  > $null 2>&1 } Catch {}
Reg.exe Delete "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePageCombining" /f > $null 2>&1
Reg.exe Add "HKLM\System\CurrentControlSet\Control\Session Manager" /v "HeapDeCommitFreeBlockThreshold" /t REG_DWORD /d "0" /f > $null 2>&1

timeout /t 1 /nobreak >nul

powershell.exe -Command "Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services' | Where-Object { `$_.Name -notmatch 'Xbl|Xbox|BITS' } | ForEach-Object { `$path = 'SYSTEM\CurrentControlSet\Services\' + `$_.PSChildName; `$found = Get-ItemProperty -Path "REGISTRY::`$_"; if (`$null -ne `$found.Start) { Reg.exe Delete "`$_" /v "SvcHostSplitDisable" /f  } }; exit"

pause
goto Reduce-ProcessesM

:end
exit /b
