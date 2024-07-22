<#
.SYNOPSIS
Script to create or restore a system restore point.

.DESCRIPTION
This script checks if it is running with administrative privileges, then prompts the user to create or restore a system restore point. The script uses PowerShell cmdlets for creating and restoring restore points.

.NOTES
Author: Ibrahim
Website: https://ibrpride.com
Script Version: 1.1
Last Updated: July 2024
#>

# Check if the script is running as an admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Relaunch as an administrator
    Start-Process powershell.exe -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $MyInvocation.MyCommand.Definition) -Verb RunAs
    exit
}

# Set console window properties for administrator session
$Host.UI.RawUI.WindowTitle = "Restore Point Management | @IBRPRIDE"
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

# Function to restore a backup from a selected restore point
function Restore-Backup {
    $restorePoints = Get-ComputerRestorePoint | Select-Object -Property SequenceNumber, Description, CreationTime
    if ($restorePoints) {
        Write-Host "Available restore points:"
        $restorePoints | ForEach-Object { Write-Host "$($_.SequenceNumber) - $($_.Description) - $($_.CreationTime)" }
        $sequenceNumber = Read-Host "Enter the Sequence Number of the restore point you want to restore"
        $restorePoint = $restorePoints | Where-Object { $_.SequenceNumber -eq [int]$sequenceNumber }
        if ($restorePoint) {
            Restore-Computer -RestorePoint $restorePoint.SequenceNumber
            if ($?) {
                Write-Host "Backup restored successfully." -ForegroundColor Green
            } else {
                Write-Host "Failed to restore the backup." -ForegroundColor Red
            }
        } else {
            Write-Host "Invalid Sequence Number. Restore point not found." -ForegroundColor Red
        }
    } else {
        Write-Host "No restore points available." -ForegroundColor Red
    }
    pause
}

# Main script execution
Check-Admin

Write-Host "Select an option:"
Write-Host "1. Create a Restore Point"
Write-Host "2. Restore from an available restore point"
Write-Host "3. Exit"
Write-Host ""

$choice = Read-Host "Enter your choice (1/2/3)"
switch ($choice) {
    1 {
        $restoreName = Read-Host "Enter the name for the Restore Point"
        Create-RestorePoint -RestoreName $restoreName
    }
    2 {
        Restore-Backup
    }
    3 {
        exit
    }
    default {
        Write-Host "Invalid choice. Please enter 1, 2, or 3."
        pause
    }
}

# Pause the script to view the output
Write-Host "Press any key to exit..." -ForegroundColor Yellow
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
