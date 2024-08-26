# mode con: cols=75 lines=28
# @(set "0=%~f0"^)#) & powershell -nop -c iex([io.file]::ReadAllText($env:0)) & exit 
<#
.SYNOPSIS
    A script to install DirectX and VC++ Redistributables with a menu-driven interface.
.DESCRIPTION
    This script downloads and installs DirectX and various versions of VC++ Redistributables.
.LINK
    https://ibrpride.com
.NOTES
    Author: Ibrahim
    Website: https://ibrpride.com
    Script Version: 1.2
    Last Updated: July 2024
#>

# Function to set color and message for successful or failed operations
function Write-Log {
    param (
        [Parameter(Mandatory)][string]$Message,
        [Parameter()][string]$Color = "White"
    )
    Write-Host -ForegroundColor $Color $Message
}

# Check if the script is running as an admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    # Relaunch as an administrator
    Start-Process powershell.exe -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $MyInvocation.MyCommand.Definition) -Verb RunAs
    exit
}

$Host.UI.RawUI.WindowTitle = "DirectX & Vcredist C++ | @IBRHUB"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"

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

Clear-Host

# Set the console window size
cmd /c "mode con: cols=75 lines=28"

# Function to download files from the web with progress display
function Get-FileFromWeb {
    param (
        [Parameter(Mandatory)][string]$URL,
        [Parameter(Mandatory)][string]$File
    )

    function Show-Progress {
        param (
            [Parameter(Mandatory)][Single]$TotalValue,
            [Parameter(Mandatory)][Single]$CurrentValue,
            [Parameter(Mandatory)][string]$ProgressText,
            [Parameter()][int]$BarSize = 50,
            [Parameter()][switch]$Complete
        )
        $percent = $CurrentValue / $TotalValue
        $percentComplete = $percent * 100
        if ($psISE) {
            Write-Progress "$ProgressText" -id 0 -percentComplete $percentComplete
        } else {
            $progressBar = ''.PadRight([math]::Floor($BarSize * $percent), [char]9608).PadRight($BarSize, [char]9617)
            Write-Host -NoNewLine "`r$ProgressText $progressBar $($percentComplete.ToString('N2').PadLeft(6)) % "
        }
    }
    try {
        $request = [System.Net.HttpWebRequest]::Create($URL)
        $response = $request.GetResponse()
        if ($response.StatusCode -eq 401 -or $response.StatusCode -eq 403 -or $response.StatusCode -eq 404) {
            throw "Remote file either doesn't exist, is unauthorized, or is forbidden for '$URL'."
        }
        $baseFileName = [System.IO.Path]::GetFileName($File)
        if ($File -match '^\.\\') {
            $File = Join-Path (Get-Location -PSProvider 'FileSystem') ($File -Split '^\.')[1]
        }
        if ($File -and !(Split-Path $File)) {
            $File = Join-Path (Get-Location -PSProvider 'FileSystem') $File
        }
        if ($File) {
            $fileDirectory = $([System.IO.Path]::GetDirectoryName($File))
            if (!(Test-Path($fileDirectory))) {
                [System.IO.Directory]::CreateDirectory($fileDirectory) | Out-Null
            }
        }
        [long]$fullSize = $response.ContentLength
        $sizeMB = [math]::Round($fullSize / 1MB, 1)
        Write-Log " Downloading $baseFileName ($sizeMB MB)" "Green"
        [byte[]]$buffer = new-object byte[] 1048576
        [long]$total = [long]$count = 0
        $reader = $response.GetResponseStream()
        $writer = new-object System.IO.FileStream $File, 'Create'
        do {
            $count = $reader.Read($buffer, 0, $buffer.Length)
            $writer.Write($buffer, 0, $count)
            $total += $count
            if ($fullSize -gt 0) {
                Show-Progress -TotalValue $fullSize -CurrentValue $total -ProgressText " $($File.Name)"
            }
        } while ($count -gt 0)
    }
    finally {
        $reader.Close()
        $writer.Close()
    }
}

# Function to download and install DirectX
function Download-And-InstallDirectX {
Clear-Host
cmd /c "mode con: cols=113 lines=35"
    Write-Log "Downloading DirectX..." "Cyan"
    Get-FileFromWeb -URL "https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe" -File "$env:TEMP\DirectX.exe"
    Write-Host""
    Write-Log "Extracting DirectX files..." "Yellow"
    cmd /c "C:\Program Files\7-Zip\7z.exe" x "$env:TEMP\DirectX.exe" -o"$env:TEMP\DirectX" -y | Out-Null
    Write-Host""
    Write-Log "Installing DirectX..." "Cyan"
    Start-Process -FilePath "$env:TEMP\DirectX\DXSETUP.exe" -ArgumentList "/silent" -Wait
    Write-Host""
    Write-Log "DirectX installation completed." "Green"
}

# Function to download and install VC++ Redistributables
function Download-And-InstallVCRedist {
Clear-Host
cmd /c "mode con: cols=135 lines=35"
    Write-Host""
    Write-Log "Downloading VC++ Redistributables..." "Cyan"
    Write-Host""
    $vcRedists = @(
        "https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.EXE=$env:TEMP\vcredist2005_x86.exe",
        "https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x64.EXE=$env:TEMP\vcredist2005_x64.exe",
        "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe=$env:TEMP\vcredist2008_x86.exe",
        "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe=$env:TEMP\vcredist2008_x64.exe",
        "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe=$env:TEMP\vcredist2010_x86.exe",
        "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe=$env:TEMP\vcredist2010_x64.exe",
        "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe=$env:TEMP\vcredist2012_x86.exe",
        "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe=$env:TEMP\vcredist2012_x64.exe",
        "https://aka.ms/highdpimfc2013x86enu=$env:TEMP\vcredist2013_x86.exe",
        "https://aka.ms/highdpimfc2013x64enu=$env:TEMP\vcredist2013_x64.exe",
        "https://aka.ms/vs/17/release/vc_redist.x86.exe=$env:TEMP\vcredist2015_2017_2019_2022_x86.exe",
        "https://aka.ms/vs/17/release/vc_redist.x64.exe=$env:TEMP\vcredist2015_2017_2019_2022_x64.exe"
    )
	
    foreach ($vcRedist in $vcRedists) {
        $url, $file = $vcRedist -split '='
        Get-FileFromWeb -URL $url -File $file
    }
    Write-Host""
    Write-Log "Installing VC++ Redistributables..." "Cyan"
    $vcRedistFiles = @(
        "$env:TEMP\vcredist2005_x86.exe /q",
        "$env:TEMP\vcredist2005_x64.exe /q",
        "$env:TEMP\vcredist2008_x86.exe /qb",
        "$env:TEMP\vcredist2008_x64.exe /qb",
        "$env:TEMP\vcredist2010_x86.exe /passive /norestart",
        "$env:TEMP\vcredist2010_x64.exe /passive /norestart",
        "$env:TEMP\vcredist2012_x86.exe /passive /norestart",
        "$env:TEMP\vcredist2012_x64.exe /passive /norestart",
        "$env:TEMP\vcredist2013_x86.exe /passive /norestart",
        "$env:TEMP\vcredist2013_x64.exe /passive /norestart",
        "$env:TEMP\vcredist2015_2017_2019_2022_x86.exe /passive /norestart",
        "$env:TEMP\vcredist2015_2017_2019_2022_x64.exe /passive /norestart"
    )
    foreach ($file in $vcRedistFiles) {
        $args = $file -split ' '
        $exe = $args[0]
        $argList = $args[1..($args.Length - 1)] -join ' '
        $baseFileName = [System.IO.Path]::GetFileName($exe)
        Write-Log "Installing $baseFileName..." "Yellow"
        Start-Process -wait $exe -ArgumentList $argList
    }
    Write-Log "VC++ Redistributables installation completed." "Green"
}

# Function to download and install both DirectX and VC++ Redistributables
function Download-And-InstallDirectXAndVCRedist {
    Download-And-InstallDirectX
    Download-And-InstallVCRedist
}

# Main Menu loop
$continue = $true
while ($continue) {
    Clear-Host
	cmd /c "mode con: cols=75 lines=28"
    Write-Host""
    Write-Host""
    Write-Host""
    Write-Host""
    Write-Host""
    Write-Host "                       DirectX & VC++ Installer Menu" -ForegroundColor Yellow
    Write-Host "             ___________________________________________________"
    Write-Host ""
    Write-Host "                    [1] Install DirectX" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "                    [2] Install VC++ " -ForegroundColor Cyan
    Write-Host ""
    Write-Host "                    [3] Install DirectX and VC++ " -ForegroundColor Green
    Write-Host ""
    Write-Host "                    [4] Manual download and install"  -ForegroundColor Yellow
    Write-Host ""
    Write-Host "             ___________________________________________________"
    Write-Host ""
    Write-Host "                                 [0] Exit"  -ForegroundColor red
    Write-Host "             ___________________________________________________"
    Write-Host ""

do {
    $choice = Read-Host "                        Enter a menu option [0-5]" 

    # Validate input
    if ($choice -match '^[0-5]$') {
        switch ($choice) {
            0 { Write-Host "Option 0 selected" -ForegroundColor Green }
            1 { Write-Host "Option 1 selected" -ForegroundColor Green }
            2 { Write-Host "Option 2 selected" -ForegroundColor Green }
            3 { Write-Host "Option 3 selected" -ForegroundColor Green }
            4 { Write-Host "Option 4 selected" -ForegroundColor Green }
            5 { Write-Host "Option 5 selected" -ForegroundColor Green }
            default { Write-Host "Invalid selection" -ForegroundColor Red }
        }
    } else {
        Write-Host "                  Please enter a number between 0 and 5." -ForegroundColor Red
        Write-Host ""
    }
} while ($choice -notin '0','1','2','3','4','5')
    switch ($choice) {
        1 {
            Download-And-InstallDirectX
        }
        2 {
            Download-And-InstallVCRedist
        }
        3 {
            Download-And-InstallDirectXAndVCRedist
        }
        4 {
        Clear-Host
        cmd /c "mode con: cols=100 lines=40"
    
        Write-Log "Manual Download and Install Instructions:" -Color "Yellow"
        Write-Host ""
    
        Write-Log "DirectX Installation:" -Color "Yellow"
        Write-Host ""
    
        Write-Log "Visit the DirectX End-User Runtime Web Installer page:" -Color "Yellow"
        Write-Log "DirectX End-User Runtime Web Installer" -Color "Yellow"
        Write-Log "Download the Installer:" -Color "Yellow"
        Write-Host ""
        Write-Log "Click on the 'Download' button to get the directx_Jun2010_redist.exe file." -Color "Yellow"
        Write-Log "Run the Installer:" -Color "Yellow"
        Write-Log "Locate the downloaded file and double-click on it to start the installation process." -Color "Yellow"
        Write-Log "Follow the on-screen instructions to complete the installation." -Color "Yellow"
        Write-Host ""
    
        Write-Log "VC++ Redistributables Installation:" -Color "Yellow"
        Write-Host ""
    
        Write-Log "Visit the Microsoft Visual C++ Redistributable Downloads page:" -Color "Yellow"
        Write-Log "Visual C++ Redistributables" -Color "Yellow"
        Write-Log "Download the Redistributables: Depending on your system architecture" -Color "Yellow"
        Write-Log "(32-bit or 64-bit), download the appropriate versions." -Color "Yellow"
        Write-Log "The page typically lists versions for:" -Color "Yellow"
        Write-Host ""
    
        Write-Log "2005" -Color "Yellow"
        Write-Log "2008" -Color "Yellow"
        Write-Log "2010" -Color "Yellow"
        Write-Log "2012" -Color "Yellow"
        Write-Log "2013" -Color "Yellow"
        Write-Log "2015" -Color "Yellow"
        Write-Log "2017" -Color "Yellow"
        Write-Log "2019" -Color "Yellow"
        Write-Host ""
    
        Write-Log "Run Each Installer: For each downloaded redistributable," -Color "Yellow"
        Write-Log "double-click on the file to start the installation." -Color "Yellow"
        Write-Log "Follow the on-screen instructions" -Color "Yellow"
        Write-Log "for each version to ensure they are properly installed." -Color "Yellow"
    
            Pause
        }
        0 {
            $continue = $false
        }
        default {
            Write-Log "Invalid choice. Please enter [0-5]." "Red"
        }
    }
}

Write-Log "Script execution completed." "Green"

# Function to set color and message for successful or failed operations
function Write-Log {
    param (
        [Parameter(Mandatory)][string]$Message,
        [Parameter()][string]$Color = "White"
    )

    # If Message is empty, do not write anything
    if ($Message -ne "") {
        Write-Host -ForegroundColor $Color $Message
    }
}
