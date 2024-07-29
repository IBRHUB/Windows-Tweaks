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

# Set the console window size
cmd /c "mode con: cols=75 lines=28"

# Set Console Opacity Transparent
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class ConsoleOpacity {
    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool SetLayeredWindowAttributes(IntPtr hwnd, uint crKey, byte bAlpha, uint dwFlags);

    private const uint LWA_ALPHA = 0x00000002;

    public static void SetOpacity(byte opacity) {
        IntPtr hwnd = GetConsoleWindow();
        if (hwnd == IntPtr.Zero) {
            throw new InvalidOperationException("Failed to get console window handle.");
        }
        bool result = SetLayeredWindowAttributes(hwnd, 0, opacity, LWA_ALPHA);
        if (!result) {
            throw new InvalidOperationException("Failed to set window opacity.");
        }
    }
}
"@

try {
    # Set opacity (0-255, where 255 is fully opaque and 0 is fully transparent)
    [ConsoleOpacity]::SetOpacity(230)
    Write-Host "Console opacity set successfully." -ForegroundColor Green
} catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
}

Set-ConsoleBackground
Clear-Host

function Write-CenteredText {
    param (
        [string]$text,
        [ConsoleColor]$color = 'Yellow'
    )
    $width = $Host.UI.RawUI.WindowSize.Width
    $padLength = [math]::Max(0, ($width - $text.Length) / 2)
    $paddedText = $text.PadLeft($text.Length + $padLength).PadRight($width)
    Write-Host $paddedText -ForegroundColor $color
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
	Write-Host
    Write-CenteredText -text "Disabling Visual Effects..."
    Start-Sleep -Seconds 1
	Write-Host

    Write-CenteredText -text "Set font smoothing to ClearType"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value "2"
    Start-Sleep -Seconds 1
    Write-Host

    Write-CenteredText -text "Modify user interface preferences"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))
    Start-Sleep -Seconds 1
    Write-Host

    Write-CenteredText -text "Enable full window drag"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Value "1"
    Start-Sleep -Seconds 1
    Write-Host

    Write-CenteredText -text "Disable window animation for minimizing and maximizing"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0"
    Start-Sleep -Seconds 1
    Write-Host

    Write-CenteredText -text "Enable alpha selection in list views"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Value "1"
    Start-Sleep -Seconds 1
    Write-Host

    Write-CenteredText -text "Show labels alongside icons on the taskbar"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Value "0"
    Start-Sleep -Seconds 1
    Write-Host

    Write-CenteredText -text "Disable animations in the taskbar"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value "0"
    Start-Sleep -Seconds 1
    Write-Host

    Write-CenteredText -text "Enable shadow under icons and open windows"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Value "1"
    Start-Sleep -Seconds 1
    Write-Host

    Write-CenteredText -text "Set custom visual effects settings"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value "3"
    Start-Sleep -Seconds 1
    Write-Host

    Write-CenteredText -text "Disable Aero Peek feature"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Value "0"
    Start-Sleep -Seconds 1
    Write-Host

    Write-CenteredText -text "Disable thumbnail caching in DWM (Desktop Window Manager)"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\DWM" -Name "AlwaysHibernateThumbnails" -Value "0"
    Start-Sleep -Seconds 1
    Write-Host

    Write-CenteredText -text "Visual Effects disabled successfully." -color Green
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
    Exit
}

# Main script execution
Write-Host
Write-Host
Write-Host
Write-Host
if (Confirm-Changes -Message "	   Do you want to disable visual effects?") {
    Disable-VisualEffects
} else {
    Write-CenteredText -text "	   Operation canceled by the user."
}

$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
