<#
.SYNOPSIS
Applies various registry tweaks for system optimization.

.DESCRIPTION
This script modifies several registry keys and system settings to optimize performance and disable unnecessary features.
It checks for administrator privileges and prompts the user for confirmation before applying changes.

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

# Function to set console background and title
function Set-ConsoleBackground {
    $Host.UI.RawUI.WindowTitle = "Registry Tweaks | IBRPRIDE"
    $Host.UI.RawUI.BackgroundColor = "Black"
    $Host.PrivateData.ProgressBackgroundColor = "Black"
    $Host.PrivateData.ProgressForegroundColor = "White"
    Clear-Host
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

# Function to apply registry tweaks
function Apply-RegistryTweaks {
    # Enable Virtual Terminal Level for ANSI escape sequences
    Set-ItemProperty -Path "HKCU:\Console" -Name "VirtualTerminalLevel" -Value 1 2> $null
    Clear-Host

    # Set User Account Control (UAC) to never notify
    Write-Host "- Setting UAC - never notify" -ForegroundColor Yellow
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value 0 2> $null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0 2> $null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0 2> $null
    Start-Sleep -Seconds 1
    Write-Host

    # Set Microsoft Edge policies
    Write-Host "- Setting Edge policies" -ForegroundColor Yellow
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "StartupBoostEnabled" -Value 0 2> $null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "HardwareAccelerationModeEnabled" -Value 0 2> $null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "BackgroundModeEnabled" -Value 0 2> $null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\MicrosoftEdgeElevationService" -Name "Start" -Value 4 2> $null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\edgeupdate" -Name "Start" -Value 4 2> $null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\edgeupdatem" -Name "Start" -Value 4 2> $null
    Start-Sleep -Seconds 1
    Write-Host

    # Set Google Chrome policies
    Write-Host "- Setting Chrome policies" -ForegroundColor Yellow
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Name "StartupBoostEnabled" -Value 0 2> $null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Name "HardwareAccelerationModeEnabled" -Value 0 2> $null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Name "BackgroundModeEnabled" -Value 0 2> $null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Name "HighEfficiencyModeEnabled" -Value 1 2> $null
    Start-Sleep -Seconds 1
    Write-Host

    # Set NVIDIA settings
    Write-Host "- NVIDIA settings" -ForegroundColor Yellow
    Write-Host "Enable old NVIDIA sharpening"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" -Name "EnableGR535" -Value 0 2> $null
    Start-Sleep -Seconds 1
    Write-Host

    # Disable NVIDIA Telemetry
    Write-Host "- Disabling NVIDIA Telemetry" -ForegroundColor Yellow
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "NvBackend" 2> $null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" -Name "OptInOrOutPreference" -Value 0 2> $null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global\FTS" -Name "EnableRID66610" -Value 0 2> $null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global\FTS" -Name "EnableRID64640" -Value 0 2> $null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\NVIDIA Corporation\Global\FTS" -Name "EnableRID44231" -Value 0 2> $null
    $taskNames = @(
        "NvTmRep_CrashReport1_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}",
        "NvTmRep_CrashReport2_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}",
        "NvTmRep_CrashReport3_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}",
        "NvTmRep_CrashReport4_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}",
        "NvDriverUpdateCheckDaily_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}",
        "NVIDIA GeForce Experience SelfUpdate_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}",
        "NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
    )
    foreach ($task in $taskNames) {
        schtasks /change /disable /tn $task 2> $null
    }
    Start-Sleep -Seconds 1
    Write-Host

    # Enable multi-plane overlay (MPO) in graphics settings
    Write-Host "- Graphics settings" -ForegroundColor Yellow
    Write-Host "Enable MPO (multi-plane overlay)"
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Dwm" -Name "OverlayTestMode" 2> $null
    Start-Sleep -Seconds 1
    Write-Host

    # Set game scheduling for performance
    Write-Host "- Setting game scheduling (performance)" -ForegroundColor Yellow
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Affinity" -Value 0 2> $null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Background Only" -Value "False" 2> $null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Clock Rate" -Value 10000 2> $null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "GPU Priority" -Value 8 2> $null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Priority" -Value 6 2> $null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Scheduling Category" -Value "High" 2> $null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "SFIO Priority" -Value "High" 2> $null
    Start-Sleep -Seconds 1
    Write-Host

    # Enable Hardware-Accelerated GPU Scheduling
    Write-Host "- Enabling Hardware-Accelerated GPU Scheduling" -ForegroundColor Yellow
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 2> $null
    Start-Sleep -Seconds 1
    Write-Host

    # Enable Game Mode
    Write-Host "- Enabling Game Mode" -ForegroundColor Yellow
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1 2> $null
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 1 2> $null
    Start-Sleep -Seconds 1
    Write-Host

    # Adjust for best performance of programs
    Write-Host "- Adjusting for best performance of programs" -ForegroundColor Yellow
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 2> $null
    Start-Sleep -Seconds 1
    Write-Host

    # Reduce menu delay
    Write-Host "- Reducing Menu Delay" -ForegroundColor Yellow
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value 0 2> $null
    Start-Sleep -Seconds 1
    Write-Host

    # Set privacy permissions
    Write-Host "- Setting Privacy permissions" -ForegroundColor Yellow
    $privacySettings = @{
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" = "Deny";
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" = "Deny";
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts" = "Deny";
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments" = "Deny";
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall" = "Deny";
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory" = "Deny";
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email" = "Deny";
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks" = "Deny";
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat" = "Deny";
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios" = "Deny";
        "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync" = "Deny";
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" = "Deny";
    }
    foreach ($key in $privacySettings.Keys) {
        Set-ItemProperty -Path $key -Name "Value" -Value $privacySettings[$key] 2> $null
    }
    Start-Sleep -Seconds 1
    Write-Host

    # Disable Telemetry Services
    Write-Host "- Disabling Telemetry Services" -ForegroundColor Yellow
    Stop-Service -Name "DiagTrack" 2> $null
    Set-Service -Name "DiagTrack" -StartupType Disabled 2> $null
    Stop-Service -Name "dmwappushservice" 2> $null
    Set-Service -Name "dmwappushservice" -StartupType Disabled 2> $null
    Stop-Service -Name "diagnosticshub.standardcollector.service" 2> $null
    Set-Service -Name "diagnosticshub.standardcollector.service" -StartupType Disabled 2> $null
    Start-Sleep -Seconds 1
    Write-Host

    # Disable Cortana
    Write-Host "- Disabling Cortana" -ForegroundColor Yellow
    $cortanaKeys = @{
        "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" = @(
            @{ Name = "AllowCortana"; Value = 0 },
            @{ Name = "AllowCloudSearch"; Value = 0 },
            @{ Name = "AllowCortanaAboveLock"; Value = 0 },
            @{ Name = "AllowSearchToUseLocation"; Value = 0 },
            @{ Name = "ConnectedSearchUseWeb"; Value = 0 },
            @{ Name = "ConnectedSearchUseWebOverMeteredConnections"; Value = 0 },
            @{ Name = "DisableWebSearch"; Value = 0 }
        )
    }
    foreach ($key in $cortanaKeys.Keys) {
        foreach ($entry in $cortanaKeys[$key]) {
            Set-ItemProperty -Path $key -Name $entry.Name -Value $entry.Value 2> $null
        }
    }
    Get-AppxPackage -AllUsers *Microsoft.549981C3F5F10* | Remove-AppxPackage 2> $null
    Start-Sleep -Seconds 1
    Write-Host

    # Disable OneDrive
    Write-Host "- Disabling OneDrive" -ForegroundColor Yellow
    Stop-Process -Name "OneDrive" -Force 2> $null
    $oneDriveKeys = @(
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive",
        "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive",
        "HKCU:\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}",
        "HKCU:\Software\Classes\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
    )
    $oneDriveValues = @{
        "DisableFileSyncNGSC" = 1;
        "DisableLibrariesDefaultSaveToOneDrive" = 1;
        "DisableMeteredNetworkFileSync" = 1;
    }
    foreach ($key in $oneDriveKeys) {
        foreach ($valueName in $oneDriveValues.Keys) {
            Set-ItemProperty -Path $key -Name $valueName -Value $oneDriveValues[$valueName] 2> $null
        }
    }
    Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" 2> $null
    Start-Sleep -Seconds 10
    Write-Host

    # Complete message
    Write-Host "Registry tweaks applied successfully." -ForegroundColor Green
    Read-Host -Prompt "Press Enter to continue..."
}

# Main script execution
Set-ConsoleBackground

if (Confirm-Changes -Message "Do you want to apply registry tweaks?") {
    Apply-RegistryTweaks
} else {
    Read-Host -Prompt "Operation canceled by the user."
}

