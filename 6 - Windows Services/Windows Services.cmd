mode con: cols=75 lines=28
@(set "0=%~f0"^)#) & powershell -nop -c iex([io.file]::ReadAllText($env:0)) & exit 

# Check if the script is running as an admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Relaunch as an administrator
    Start-Process powershell.exe -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $MyInvocation.MyCommand.Definition) -Verb RunAs
    exit
}

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


function Show-Progress {
    param (
        [Parameter(Mandatory=$true)][int]$Total,
        [Parameter(Mandatory=$true)][int]$Current,
        [Parameter(Mandatory=$true)][string]$Text,
        [Parameter()][int]$BarSize = 50
    )
    $percent = [math]::Floor(($Current / $Total) * 100)
    $filledSize = [math]::Floor($BarSize * ($Current / $Total))
    $unfilledSize = $BarSize - $filledSize
    $progressBar = '█' * $filledSize + '░' * $unfilledSize
    Write-Host -NoNewLine "`r$Text $progressBar $percent% " -ForegroundColor Yellow
}

function Disable-Services {
    Clear-Host
    Write-Host ""
    Write-Host "Disabling rarely used Windows services..." -ForegroundColor Cyan
    $services = @(
        'SEMgrSvc', 'AxInstSV', 'tzautoupdate', 'lfsvc', 'SharedAccess',
        'CscService', 'PhoneSvc', 'RemoteAccess', 'upnphost',
        'UevAgentService', 'WalletService', 'Ndu'
    )
    $totalServices = $services.Count
    for ($i = 0; $i -lt $totalServices; $i++) {
        Show-Progress -Total $totalServices -Current ($i + 1) -Text "Disabling Services:"
        Set-Service -Name $services[$i] -StartupType Disabled -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 200
    }
    Write-Host "`nAll services have been disabled." -ForegroundColor Green
    Pause
    Show-Menu
}

function Restore-Default-Services {
    Clear-Host
    Write-Host ""
    Write-Host "Restoring default Windows services..." -ForegroundColor Cyan
    $services = @(
        'SEMgrSvc', 'AxInstSV', 'tzautoupdate', 'lfsvc', 'SharedAccess',
        'CscService', 'PhoneSvc', 'RemoteAccess', 'upnphost',
        'UevAgentService', 'WalletService', 'FrameServer', 'Ndu'
    )
    $totalServices = $services.Count
    for ($i = 0; $i -lt $totalServices; $i++) {
        Show-Progress -Total $totalServices -Current ($i + 1) -Text "Restoring Services:"
        $startupType = if ($services[$i] -eq 'tzautoupdate' -or $services[$i] -eq 'RemoteAccess' -or $services[$i] -eq 'UevAgentService') { 'Disabled' } else { 'Manual' }
        Set-Service -Name $services[$i] -StartupType $startupType -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 200
    }
    Write-Host "`nAll services have been restored to default." -ForegroundColor Green
    Pause
    Show-Menu
}

function Show-Menu {
    Clear-Host
	$file = Get-ChildItem -Path (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent) -Filter 'Disclaimer.txt' -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'Disclaimer.txt' }; if ($file) { Start-Process -FilePath $file.FullName } else { Write-Output "The file does not exist." }
	Clear-Host
	Write-Host ""
	Write-Host ""
	Write-Host ""
	Write-Host ""
	Write-Host ""
	Write-Host ""
	Write-Host ""
	Write-Host ""
	$null = Read-Host "Do you agree with the Disclaimer you read?`nPress Enter to continue"
	Clear-Host
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host "                   Disable Rarely Used Windows Services" -ForegroundColor Cyan
    Write-Host "            ___________________________________________________ "
    Write-Host "                                                                "
    Write-Host "                     [1] Windows Services ( Disable )" -ForegroundColor Yellow
    Write-Host ""	
    Write-Host "                     [2] Windows Services ( Default ) " -ForegroundColor Green
    Write-Host "               _____________________________________________   "
    Write-Host "                                                                "
    Write-Host "                                [0] Exit" -ForegroundColor Red
    Write-Host "            ___________________________________________________"
    Write-Host ""
    $choice = Read-Host "Enter your choice"
    switch ($choice) {
        '1' { Disable-Services }
        '2' { Restore-Default-Services }
        '0' { Exit }
        default {
            Write-Host "Invalid choice. Please enter 1, 2, or 0." -ForegroundColor Red
            Pause
            Show-Menu
        }
    }
}

Show-Menu

