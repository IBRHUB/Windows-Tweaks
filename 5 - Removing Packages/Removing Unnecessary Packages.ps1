<#
.SYNOPSIS
Removes selected AppxPackages from all users on the system.

.DESCRIPTION
This script removes specified AppxPackages from all users on the system. 
It checks if running with Administrator privileges and restarts with elevated rights if necessary. 
Console window properties are set for better visibility.

.LINK
https://ibrpride.com

.NOTES
Author: Ibrahim
Website: https://ibrpride.com
Script Version: 1.0
Last Updated: June 2024
#>

# Check if the script is running as an admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Relaunch as an administrator
    Start-Process powershell.exe -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $MyInvocation.MyCommand.Definition) -Verb RunAs
    exit
}

# Set console window properties for administrator session
$Host.UI.RawUI.WindowTitle = "Removing Unnecessary Packages | @IBRHUB"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ErrorForegroundColor = "Red"
$Host.PrivateData.WarningForegroundColor = "Yellow"
$Host.PrivateData.DebugForegroundColor = "Cyan"
$Host.PrivateData.VerboseForegroundColor = "Green"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"

# Clear the console screen
Clear-Host

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


# Function to remove AppxPackage without logging
function Remove-AppxPackageWithoutLogging {
    param (
        [Parameter(Mandatory = $true)]
        [string]$AppName
    )

    try {
        # Use PowerShell command to remove the AppxPackage
        Get-AppxPackage -AllUsers *$AppName* | Remove-AppxPackage -ErrorAction Stop
        Write-Host "Removed AppxPackage: $AppName" -ForegroundColor Green
    } catch {
        Write-Host "Failed to remove AppxPackage: $AppName. Continuing..." -ForegroundColor Yellow
    }
}

# List of AppxPackage names to remove
$packagesToRemove = @(
    "3DBuilder",
    "bing",
    "bingfinance",
    "bingsports",
    "BingWeather",
    "CommsPhone",
    "Drawboard PDF",
    "Facebook",
    "Getstarted",
    "Microsoft.Messaging",
    "MicrosoftOfficeHub",
    "Office.OneNote",
    "OneNote",
    "people",
    "SkypeApp",
    "solit",
    "Sway",
    "Twitter",
    "WindowsAlarms",
    "WindowsPhone",
    "WindowsMaps",
    "WindowsFeedbackHub",
    "WindowsSoundRecorder",
    "windowscommunicationsapps",
    "zune"
)

# Loop through each package and remove it
foreach ($package in $packagesToRemove) {
    Remove-AppxPackageWithoutLogging -AppName $package
}

# Output completion message
Write-Host "AppxPackage removal completed." -ForegroundColor Cyan
