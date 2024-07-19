@echo off
setlocal EnableDelayedExpansion
title Auto-Cleaner
color 2
echo [93m- Clean up temp folders[0m
rd /s /q !TEMP! >nul 2>&1
rd /s /q !windir!\temp >nul 2>&1
md !TEMP! >nul 2>&1
md !windir!\temp >nul 2>&1
echo  [92mTemp folders have been cleaned[0m
echo.


echo [93m- Clean up the Prefetch folder[0m
rd /s /q !windir!\Prefetch >nul 2>&1
echo  [92mPrefetch folder has been cleaned[0m
echo.


echo [93m- Clear all Event Viewer logs[0m
for /f "tokens=*" %%a in ('wevtutil el') do (
    wevtutil cl "%%a"
) >nul 2>&1
echo  [92mAll Event Viewer logs have been cleared[0m
echo.

pause
exit /b
