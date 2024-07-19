<#
.SYNOPSIS
Script to create or restore a system restore point.

.DESCRIPTION
This script checks if it is running with administrative privileges, then prompts the user to create or restore a system restore point. The script uses PowerShell cmdlets for creating and restoring restore points.

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
$Host.UI.RawUI.WindowTitle = "Removing Unnecessary Packages | IBRPRIDE"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ErrorForegroundColor = "Red"
$Host.PrivateData.WarningForegroundColor = "Yellow"
$Host.PrivateData.DebugForegroundColor = "Cyan"
$Host.PrivateData.VerboseForegroundColor = "Green"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"

# Clear the console screen
Clear-Host


# Function to check if the script is running as an administrator
function Check-Admin {
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "This script must be run as Administrator."
        pause
        exit 1
    }
}

# Function to create a restore point
function Create-RestorePoint {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RestoreName
    )
    Write-Host "Creating Restore Point with name: $RestoreName ..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "SystemRestorePointCreationFrequency" -Value 0 -Force
    if ($?) {
        Checkpoint-Computer -Description $RestoreName -RestorePointType "MODIFY_SETTINGS"
        if ($?) {
			Clear-Host
            Write-Host ""
            Write-Host "Restore point created successfully." -ForegroundColor Green
			Write-Host ""
        } else {
            Write-Host "Failed to create restore point." -ForegroundColor Red
        }
    } else {
        Write-Host "Failed to set registry key." -ForegroundColor Red
    }
    pause
}

# Function to restore the backup named 'ibrpride'
function Restore-Backup {
    Write-Host "Restoring the backup named 'ibrpride'..."
    $restorePoint = Get-ComputerRestorePoint | Where-Object { $_.Description -eq 'IBRPRIDE' } | Select-Object -First 1
    if ($restorePoint) {
        Restore-Computer -RestorePoint $restorePoint.SequenceNumber
        if ($?) {
            Write-Host "Backup restored successfully." -ForegroundColor Green
        } else {
            Write-Host "Failed to restore the backup." -ForegroundColor Red
        }
    } else {
        Write-Host "Restore point 'IBRPRIDE' not found." -ForegroundColor Red
    }
    pause
}

# Main script execution
Check-Admin

$Host.UI.RawUI.WindowTitle = "Restore Point Management | @IBRPRIDE"

Write-Host "Do you want to Create a Restore Point?"
Write-Host ""
Write-Host "1 = Yes"
Write-Host ""

$choice = Read-Host "Enter your choice"
switch ($choice) {
    1 {
        $restoreName = Read-Host "Enter the name for the Restore Point"
        Create-RestorePoint -RestoreName $restoreName
    }
    2 {
        Write-Host "Do you want to restore the backup named 'ibrpride'?"
        Write-Host ""
        Write-Host "1 = Yes"
        Write-Host "2 = No"
        Write-Host ""

        $choice = Read-Host "Enter your choice"
        switch ($choice) {
            1 {
                Restore-Backup
            }
            2 {
                Write-Host "Continuing with other tasks..."
                pause
            }
            default {
                Write-Host "Invalid choice. Please enter 1 or 2."
                pause
            }
        }
    }
    3 {
        exit
    }
    default {
        Write-Host "Invalid choice. Please enter 1, 2, or 3."
        pause
    }
}
