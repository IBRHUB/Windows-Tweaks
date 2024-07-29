mode con: cols=75 lines=28
@(set "0=%~f0"^)#) & powershell -nop -c iex([io.file]::ReadAllText($env:0)) & exit 
<#
.SYNOPSIS
Creates or removes firewall rules for various games and configures network adapters.

.DESCRIPTION
This script creates or removes inbound and outbound TCP/UDP firewall rules for popular games including:
- Fortnite
- Valorant
- Apex Legends
- CS:GO
- Overwatch
- MW3

Additionally, it configures network adapters to allow only IPv4 and QoS Packet Scheduler and disables power-saving settings.

.LINK
https://ibrpride.com

.NOTES
Author: Ibrahim
Website: https://ibrpride.com
Script Version: 1.3
Last Updated: July 2024
#>

# Check if the script is running as an admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Relaunch as an administrator
    Start-Process powershell.exe -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $MyInvocation.MyCommand.Definition) -Verb RunAs
    exit
}

# Set console window properties for administrator session
$Host.UI.RawUI.WindowTitle = "Network and Firewall Management | IBRPRIDE"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ErrorForegroundColor = "Red"
$Host.PrivateData.WarningForegroundColor = "Yellow"
$Host.PrivateData.DebugForegroundColor = "Cyan"
$Host.PrivateData.VerboseForegroundColor = "Green"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"
Clear-Host

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


# Function to check if the script is running as an administrator
function Check-Admin {
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "This script must be run as Administrator."
        pause
        exit 1
    }
}

# Function to configure network adapter settings
function Configure-NetworkAdapter {
    Write-Host "Configuring network adapter: Only Allow IPv4 & QoS Packet Scheduler..." -ForegroundColor Yellow

    # Disable unwanted components
    Disable-NetAdapterBinding -Name "*" -ComponentID ms_lldp, ms_lltdio, ms_implat, ms_rspndr, ms_tcpip6, ms_server, ms_msclient -ErrorAction SilentlyContinue

    # Enable necessary components
    Enable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip -ErrorAction SilentlyContinue

    Write-Host "Network adapter configured." -ForegroundColor Green
}

# Function to disable network adapter power-saving settings
function Disable-NetworkAdapterPowerSaving {
    Write-Host "Disabling network adapter power-saving..." -ForegroundColor Yellow
    $properties = Get-NetAdapter -Physical | Get-NetAdapterAdvancedProperty
    foreach ($setting in @(
        "ULPMode", "EEE", "EEELinkAdvertisement", "AdvancedEEE", "EnableGreenEthernet", "EeePhyEnable", "uAPSDSupport",
        "EnablePowerManagement", "EnableSavePowerNow", "bLowPowerEnable", "PowerSaveMode", "PowerSavingMode",
        "SavePowerNowEnabled", "AutoPowerSaveModeEnabled", "NicAutoPowerSaver", "SelectiveSuspend"
    )) {
        $properties | Where-Object { $_.RegistryKeyword -eq "*$setting" -or $_.RegistryKeyword -eq $setting } | Set-NetAdapterAdvancedProperty -RegistryValue 0
    }
    Write-Host "Network adapter power-saving settings disabled." -ForegroundColor Green
}

# Function to write headers
function Write-Header {
    param (
        [string]$text
    )
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host "     ===============================================================" -ForegroundColor Cyan
    Write-Host "	                 $text"
    Write-Host "     ===============================================================" -ForegroundColor Cyan
    Write-Host ""
}

# Function to create firewall rules
function Create-FirewallRules {
    param (
        [string]$gameName,
        [string[]]$tcpPorts,
        [string[]]$udpPorts
    )
    
    Write-Host "		Creating rules for $gameName..." -ForegroundColor Green

    # Create TCP Inbound and Outbound rules
    foreach ($port in $tcpPorts) {
        New-NetFirewallRule -DisplayName "$gameName TCP Inbound $port" -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow > $null
        New-NetFirewallRule -DisplayName "$gameName TCP Outbound $port" -Direction Outbound -Protocol TCP -LocalPort $port -Action Allow > $null
    }

    # Create UDP Inbound and Outbound rules
    foreach ($port in $udpPorts) {
        New-NetFirewallRule -DisplayName "$gameName UDP Inbound $port" -Direction Inbound -Protocol UDP -LocalPort $port -Action Allow > $null
        New-NetFirewallRule -DisplayName "$gameName UDP Outbound $port" -Direction Outbound -Protocol UDP -LocalPort $port -Action Allow > $null
    }

    Write-Host "Rules for $gameName created successfully." -ForegroundColor Green
    Write-Host "---------------------------------------------------------------" -ForegroundColor Green
}

# Function to remove firewall rules
function Remove-FirewallRules {
    param (
        [string]$gameName
    )
    
    Write-Host "Removing rules for $gameName..." -ForegroundColor Red
    $rules = Get-NetFirewallRule | Where-Object { $_.DisplayName -like "$gameName *" }
    foreach ($rule in $rules) {
        Remove-NetFirewallRule -Name $rule.Name > $null
    }
    Write-Host "Rules for $gameName removed successfully." -ForegroundColor Red
    Write-Host "---------------------------------------------------------------" -ForegroundColor Red
}

# Function to show progress
function Show-Progress {
    param (
        [string]$activity
    )
    for ($i = 0; $i -le 100; $i += 10) {
        Write-Progress -Activity $activity -Status "Processing..." -PercentComplete $i
        Start-Sleep -Milliseconds 200
    }
    Write-Progress -Activity $activity -Status "Completed" -Completed
}

# Function to display game menu
function Game-Menu {
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host "			     Select a game:" -ForegroundColor Yellow
    Write-Host ""
	Write-Host "            ___________________________________________________ "
	Write-Host ""
    Write-Host "			[1] CALL OF DUTY: MODERN WARFARE 3" -ForegroundColor White
    Write-Host "			[2] Fortnite" -ForegroundColor White
    Write-Host "			[3] Valorant" -ForegroundColor White
    Write-Host "			[4] Apex Legends" -ForegroundColor White
    Write-Host "			[5] CSGO" -ForegroundColor White
    Write-Host "			[6] Overwatch" -ForegroundColor White
    Write-Host "			[7] All games" -ForegroundColor White
    Write-Host ""
	Write-Host "            ___________________________________________________ "
    Write-Host ""
    return (Read-Host "             Enter a menu option in the Keyboard [1,2,3]")
}

# Function to process user's choice
function Process-Choice {
    param (
        [string]$choice,
        [string]$action
    )

    switch ($choice) {
        '1' {
            if ($action -eq 'create') {
                Create-FirewallRules -gameName "CALL OF DUTY: MODERN WARFARE 3" -tcpPorts '3074', '3075', '27015-27030', '27036-27037' -udpPorts '3074', '4380', '27000-27036'
            } else {
                Remove-FirewallRules -gameName "CALL OF DUTY: MODERN WARFARE 3"
            }
        }
        '2' {
            if ($action -eq 'create') {
                Create-FirewallRules -gameName "Fortnite" -tcpPorts '5222-5223', '5795', '8080', '3478-3479' -udpPorts '7000-9000', '20000-25000'
            } else {
                Remove-FirewallRules -gameName "Fortnite"
            }
        }
        '3' {
            if ($action -eq 'create') {
                Create-FirewallRules -gameName "Valorant" -tcpPorts '2099', '5223', '443', '8088', '8393', '8400' -udpPorts '5000-5500', '6000-7000'
            } else {
                Remove-FirewallRules -gameName "Valorant"
            }
        }
        '4' {
            if ($action -eq 'create') {
                Create-FirewallRules -gameName "Apex Legends" -tcpPorts '1024-1124', '3216', '9960-9969', '18000', '18060' -udpPorts '1024-1124', '18000', '18060'
            } else {
                Remove-FirewallRules -gameName "Apex Legends"
            }
        }
        '5' {
            if ($action -eq 'create') {
                Create-FirewallRules -gameName "CSGO" -tcpPorts '27014-27050' -udpPorts '27000-27031'
            } else {
                Remove-FirewallRules -gameName "CSGO"
            }
        }
        '6' {
            if ($action -eq 'create') {
                Create-FirewallRules -gameName "Overwatch" -tcpPorts '1119', '3724', '6113', '80' -udpPorts '5060', '5062', '6250', '3478-3479'
            } else {
                Remove-FirewallRules -gameName "Overwatch"
            }
        }
        '7' {
            if ($action -eq 'create') {
                Create-FirewallRules -gameName "CALL OF DUTY: MODERN WARFARE 3" -tcpPorts '3074', '3075', '27015-27030', '27036-27037' -udpPorts '3074', '4380', '27000-27036'
                Create-FirewallRules -gameName "Fortnite" -tcpPorts '5222-5223', '5795', '8080', '3478-3479' -udpPorts '7000-9000', '20000-25000'
                Create-FirewallRules -gameName "Valorant" -tcpPorts '2099', '5223', '443', '8088', '8393', '8400' -udpPorts '5000-5500', '6000-7000'
                Create-FirewallRules -gameName "Apex Legends" -tcpPorts '1024-1124', '3216', '9960-9969', '18000', '18060' -udpPorts '1024-1124', '18000', '18060'
                Create-FirewallRules -gameName "CSGO" -tcpPorts '27014-27050' -udpPorts '27000-27031'
                Create-FirewallRules -gameName "Overwatch" -tcpPorts '1119', '3724', '6113', '80' -udpPorts '5060', '5062', '6250', '3478-3479'
            } else {
                Remove-FirewallRules -gameName "CALL OF DUTY: MODERN WARFARE 3"
                Remove-FirewallRules -gameName "Fortnite"
                Remove-FirewallRules -gameName "Valorant"
                Remove-FirewallRules -gameName "Apex Legends"
                Remove-FirewallRules -gameName "CSGO"
                Remove-FirewallRules -gameName "Overwatch"
            }
        }
        default {
            Write-Host "Invalid choice. Please run the script again and select a valid option." -ForegroundColor Red
            Write-Host "===============================================================" -ForegroundColor Red
        }
    }
}

# Main script execution
Check-Admin
# Set the console window size
cmd /c "mode con: cols=75 lines=28"
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host "                   Network and Firewall Management Script" -ForegroundColor Yellow
Write-Host "            ____________________________________________________ "
Write-Host ""
Write-Host "           	   [1] Remove firewall rules for games" -ForegroundColor RED
Write-Host "           	   [2] Create firewall rules for games" -ForegroundColor GREEN
Write-Host "           	   [3] Only Allow IPv4 & QoS Packet Scheduler" -ForegroundColor Cyan
Write-Host "           	   [4] Disable network power-saving settings" -ForegroundColor Cyan
Write-Host ""
Write-Host "            ____________________________________________________ "
Write-Host ""
$choice = Read-Host "			Select an option (1-4)"
cmd /c "mode con: cols=75 lines=34"
switch ($choice) {
    '1' {
        Write-Header "Removing Firewall Rules"
        Show-Progress -activity "Removing firewall rules"
        $gameChoice = Game-Menu
        Process-Choice -choice $gameChoice -action 'remove'
        Write-Host "===============================================================" -ForegroundColor Red
    }
    '2' {
        Write-Header "Creating Firewall Rules"
        Show-Progress -activity "Creating firewall rules"
        $gameChoice = Game-Menu
        Process-Choice -choice $gameChoice -action 'create'
        Write-Host "===============================================================" -ForegroundColor Green
    }
    '3' {
        Write-Header "Configuring Network Adapter"
        Show-Progress -activity "Configuring network adapter"
        Configure-NetworkAdapter
        Write-Host "===============================================================" -ForegroundColor Green
    }
    '4' {
        Write-Header "Disabling Network Adapter Power-Saving"
        Show-Progress -activity "Disabling network adapter power-saving"
        Disable-NetworkAdapterPowerSaving
        Write-Host "===============================================================" -ForegroundColor Green
    }
    default {
        Write-Host "Invalid choice. Please run the script again and select a valid option." -ForegroundColor Red
        Write-Host "===============================================================" -ForegroundColor Red
    }
}

Write-Host "Completed." -ForegroundColor Cyan
Write-Host "Press any key to exit..." -ForegroundColor Yellow
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
