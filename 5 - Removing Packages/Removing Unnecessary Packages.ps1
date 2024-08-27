<#
.SYNOPSIS
Installs or removes selected UWP AppxPackages from all users on the system.

.DESCRIPTION
This script provides a GUI to either install all UWP AppxPackages or remove specified AppxPackages from all users on the system. 
It checks if running with Administrator privileges and restarts with elevated rights if necessary. 
Console window properties, such as title, colors, and opacity, are set for better visibility.

.LINK
https://ibrpride.com

.NOTES
Author: Ibrahim
Website: https://ibrpride.com
Script Version: 2.1
Last Updated: August 2024
#>

# Check if the script is running as an admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Relaunch as an administrator
    Start-Process powershell.exe -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $MyInvocation.MyCommand.Definition) -Verb RunAs
    exit
}

# Set console window properties for administrator session
$Host.UI.RawUI.WindowTitle = "UWP App Manager | @IBRHUB"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ErrorForegroundColor = "Red"
$Host.PrivateData.WarningForegroundColor = "Yellow"
$Host.PrivateData.DebugForegroundColor = "Cyan"
$Host.PrivateData.VerboseForegroundColor = "Green"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"

# Clear the console screen
Clear-Host

# Set console opacity
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
Clear-Host

# Create a new form with dark/light mode support
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "UWP App Manager | @IBRHUB"
$form.Size = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = "CenterScreen"

# Detect the Windows theme (dark or light)
$theme = Get-ItemPropertyValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'AppsUseLightTheme'

if ($theme -eq 0) {
    $form.BackColor = [System.Drawing.Color]::Black
    $form.ForeColor = [System.Drawing.Color]::White
} else {
    $form.BackColor = [System.Drawing.Color]::White
    $form.ForeColor = [System.Drawing.Color]::Black
}

# Create a button for installing all UWP apps
$installButton = New-Object System.Windows.Forms.Button
$installButton.Text = "Install All UWP Apps"
$installButton.Size = New-Object System.Drawing.Size(150, 50)
$installButton.Location = New-Object System.Drawing.Point(20, 50)
$installButton.BackColor = $form.BackColor
$installButton.ForeColor = $form.ForeColor
$installButton.FlatStyle = "Flat"
$installButton.FlatAppearance.BorderColor = $form.ForeColor

$installButton.Add_Click({
    Get-AppxPackage -AllUsers | Foreach-Object {
        Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"
    }
    [System.Windows.Forms.MessageBox]::Show("All UWP apps have been installed.", "Completed", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})

# Create a button for removing selected UWP apps
$removeButton = New-Object System.Windows.Forms.Button
$removeButton.Text = "Remove Selected UWP Apps"
$removeButton.Size = New-Object System.Drawing.Size(150, 50)
$removeButton.Location = New-Object System.Drawing.Point(200, 50)
$removeButton.BackColor = $form.BackColor
$removeButton.ForeColor = $form.ForeColor
$removeButton.FlatStyle = "Flat"
$removeButton.FlatAppearance.BorderColor = $form.ForeColor

$removeButton.Add_Click({
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

    foreach ($package in $packagesToRemove) {
        try {
            Get-AppxPackage -AllUsers *$package* | Remove-AppxPackage -ErrorAction Stop
            Write-Host "Removed AppxPackage: $package" -ForegroundColor Green
        } catch {
            Write-Host "Failed to remove AppxPackage: $package. Continuing..." -ForegroundColor Yellow
        }
    }

    [System.Windows.Forms.MessageBox]::Show("Selected UWP apps have been removed.", "Completed", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})

# Add the buttons to the form
$form.Controls.Add($installButton)
$form.Controls.Add($removeButton)

# Show the form
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()
