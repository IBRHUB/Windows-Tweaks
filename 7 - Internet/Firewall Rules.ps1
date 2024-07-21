<#
    .SYNOPSIS
    Creates or removes firewall rules for various games.
    
    .DESCRIPTION
    This script creates or removes inbound and outbound TCP/UDP firewall rules for popular games including 
    - Fortnite
    - Valorant
    - Apex Legends
    - CS:GO
    - Overwatch
    - MW3

    .LINK
    https://ibrpride.com

    .NOTES
    Author: Ibrahim
    Website: https://ibrpride.com
    Script Version: 1.2
    Last Updated: June 2024
#>

# Set console colors and clear the screen
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "Yellow"
Clear-Host

function Write-Header {
    param (
        [string]$text
    )
    Write-Host ""
    Write-Host "===============================================================" -ForegroundColor Cyan
    Write-Host "                          $text"
    Write-Host "===============================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Create-FirewallRules {
    param (
        [string]$gameName,
        [string[]]$tcpPorts,
        [string[]]$udpPorts
    )
    
    Write-Host "Creating rules for $gameName..." -ForegroundColor Green
    try {
        # Create TCP Inbound and Outbound rules
        foreach ($port in $tcpPorts) {
            New-NetFirewallRule -DisplayName "$gameName TCP Inbound $port" -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow -ErrorAction Stop
            New-NetFirewallRule -DisplayName "$gameName TCP Outbound $port" -Direction Outbound -Protocol TCP -LocalPort $port -Action Allow -ErrorAction Stop
        }

        # Create UDP Inbound and Outbound rules
        foreach ($port in $udpPorts) {
            New-NetFirewallRule -DisplayName "$gameName UDP Inbound $port" -Direction Inbound -Protocol UDP -LocalPort $port -Action Allow -ErrorAction Stop
            New-NetFirewallRule -DisplayName "$gameName UDP Outbound $port" -Direction Outbound -Protocol UDP -LocalPort $port -Action Allow -ErrorAction Stop
        }

        Write-Host "Rules for $gameName created successfully." -ForegroundColor Green
    } catch {
        Write-Host "Error creating rules for $gameName: $_" -ForegroundColor Red
    }
    Write-Host "---------------------------------------------------------------" -ForegroundColor Green
}

function Remove-FirewallRules {
    param (
        [string]$gameName
    )
    
    Write-Host "Removing rules for $gameName..." -ForegroundColor Red
    try {
        $rules = Get-NetFirewallRule | Where-Object { $_.DisplayName -like "$gameName *" }
        foreach ($rule in $rules) {
            Remove-NetFirewallRule -Name $rule.Name -ErrorAction Stop
        }
        Write-Host "Rules for $gameName removed successfully." -ForegroundColor Red
    } catch {
        Write-Host "Error removing rules for $gameName: $_" -ForegroundColor Red
    }
    Write-Host "---------------------------------------------------------------" -ForegroundColor Red
}

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

function Game-Menu {
    Write-Host "Select a game:" -ForegroundColor Yellow
    Write-Host "1. CALL OF DUTY: MODERN WARFARE 3" -ForegroundColor White
    Write-Host "2. Fortnite" -ForegroundColor White
    Write-Host "3. Valorant" -ForegroundColor White
    Write-Host "4. Apex Legends" -ForegroundColor White
    Write-Host "5. CSGO" -ForegroundColor White
    Write-Host "6. Overwatch" -ForegroundColor White
    Write-Host "7. All games" -ForegroundColor White
    Write-Host ""
    return (Read-Host "Select an option (1-7)")
}

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

Write-Host "Firewall Rules Management Script" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Remove firewall rules for games" -ForegroundColor White
Write-Host "2. Create firewall rules for games" -ForegroundColor White
Write-Host ""
$choice = Read-Host "Select an option (1 or 2)"

if ($choice -eq '1') {
    Write-Header "Removing Firewall Rules"
    Show-Progress -activity "Removing firewall rules"
    $gameChoice = Game-Menu
    Process-Choice -choice $gameChoice -action 'remove'
    Write-Host "===============================================================" -ForegroundColor Red
} elseif ($choice -eq '2') {
    Write-Header "Creating Firewall Rules"
    Show-Progress -activity "Creating firewall rules"
    $gameChoice = Game-Menu
    Process-Choice -choice $gameChoice -action 'create'
    Write-Host "===============================================================" -ForegroundColor Green
} else {
    Write-Host "Invalid choice. Please run the script again and select a valid option." -ForegroundColor Red
    Write-Host "===============================================================" -ForegroundColor Red
}

Write-Host "Completed." -ForegroundColor Cyan
