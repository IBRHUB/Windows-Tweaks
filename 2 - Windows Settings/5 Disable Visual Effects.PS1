<#
.SYNOPSIS
Disables various visual effects to improve system performance.

.DESCRIPTION
This script modifies several registry keys to disable visual effects on Windows. It prompts the user for confirmation before making changes.

.LINK
https://ibrpride.com

.NOTES
Author: Ibrahim
Website: https://ibrpride.com
Script Version: 1.0
Last Updated: July 2024
#>

# Check if the script is running as an admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    # Relaunch as an administrator
    Start-Process powershell.exe -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $MyInvocation.MyCommand.Definition) -Verb RunAs
    exit
}

function Set-ConsoleBackground {
	    $Host.UI.RawUI.WindowTitle = " Disable Visual Effects | IBRPRIDE"
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.PrivateData.ProgressBackgroundColor = "Black"
        $Host.PrivateData.ProgressForegroundColor = "White"
}

Set-ConsoleBackground
Clear-Host

function Write-ColorfulHost {
    param (
        [string]$text,
        [ConsoleColor]$color = 'Yellow'
    )
    Write-Host $text -ForegroundColor $color
}
# Function to prompt user for confirmation before making changes
function Confirm-Changes {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    $confirmation = Read-Host -Prompt "$Message (Y/N)"
    return $confirmation -eq 'Y'
}

# Function to disable visual effects
function Disable-VisualEffects {
    Write-Host "Disabling Visual Effects..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1

    Write-Host " Set font smoothing to ClearType" -ForegroundColor Yellow
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value "2"
    Start-Sleep -Seconds 1
    Write-Host

    Write-Host " Modify user interface preferences" -ForegroundColor Yellow
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))
    Start-Sleep -Seconds 1
    Write-Host

    Write-Host " Enable full window drag" -ForegroundColor Yellow
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Value "1"
    Start-Sleep -Seconds 1
    Write-Host

    Write-Host " Disable window animation for minimizing and maximizing" -ForegroundColor Yellow
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0"
    Start-Sleep -Seconds 1
    Write-Host

    Write-Host " Enable alpha selection in list views" -ForegroundColor Yellow
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Value "1"
    Start-Sleep -Seconds 1
    Write-Host

    Write-Host " Show labels alongside icons on the taskbar" -ForegroundColor Yellow
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Value "0"
    Start-Sleep -Seconds 1
    Write-Host

    Write-Host " Disable animations in the taskbar" -ForegroundColor Yellow
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value "0"
    Start-Sleep -Seconds 1
    Write-Host

    Write-Host " Enable shadow under icons and open windows" -ForegroundColor Yellow
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Value "1"
    Start-Sleep -Seconds 1
    Write-Host

    Write-Host " Set custom visual effects settings" -ForegroundColor Yellow
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value "3"
    Start-Sleep -Seconds 1
    Write-Host

    Write-Host " Disable Aero Peek feature" -ForegroundColor Yellow
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Value "0"
    Start-Sleep -Seconds 1
    Write-Host

    Write-Host " Disable thumbnail caching in DWM (Desktop Window Manager)" -ForegroundColor Yellow
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\DWM" -Name "AlwaysHibernateThumbnails" -Value "0"
    Start-Sleep -Seconds 1
    Write-Host

    Write-Host " Visual Effects disabled successfully." -ForegroundColor Green
    pause
	Exit
}

# Main script execution
if (Confirm-Changes -Message "Do you want to disable visual effects?") {
    Disable-VisualEffects
} else {
    Write-Host "Operation canceled by the user."
}

$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
