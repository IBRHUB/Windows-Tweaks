<#
.SYNOPSIS
Reboots the system and opens the advanced boot options menu.

.DESCRIPTION
This script reboots the system and opens the advanced boot options menu immediately after user confirmation.

.LINK
https://ibrpride.com

.NOTES
Author: Ibrahim
Website: https://ibrpride.com
Script Version: 1.0
Last Updated: July 2024
#>

# Check if the script is running as an admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Relaunch as an administrator
    Start-Process powershell.exe -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $MyInvocation.MyCommand.Definition) -Verb RunAs
    exit
}

# Set console window properties for administrator session
$Host.UI.RawUI.WindowTitle = "Advanced Boot Options | IBRPRIDE"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ProgressBackgroundColor = "Black"

# Function to prompt user for confirmation before rebooting
function Confirm-Reboot {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    $confirmation = Read-Host -Prompt "$Message (Y/N)"
    return $confirmation -eq 'Y'
}

# Function to reboot and open advanced boot options
function Reboot-ToAdvancedBootOptions {
    Write-Host "Rebooting and opening advanced boot options..."
    # Equivalent to: shutdown /r /o /t 0
    shutdown.exe /r /o /t 0
    shutdown.exe /r /o /t 0
}

# Main script execution
if (Confirm-Reboot -Message "Do you want to reboot and open advanced boot options?") {
    Reboot-ToAdvancedBootOptions
} else {
    Write-Host "Operation canceled by the user."
}
Write-Host ""
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")