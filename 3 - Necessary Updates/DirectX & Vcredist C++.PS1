<#
.SYNOPSIS


.DESCRIPTION


.LINK
https://ibrpride.com

.NOTES
Author: Ibrahim
Website: https://ibrpride.com
Script Version: 1.0
Last Updated: July 2024
#>


# Function to measure and display the time taken
function Measure-ExecutionTime {
    param (
        [Parameter(Mandatory)][scriptblock]$ScriptBlock
    )
    $startTime = Get-Date
    Invoke-Command -ScriptBlock $ScriptBlock
    $endTime = Get-Date
    $elapsedTime = $endTime - $startTime
    Write-Host "Time taken: $($elapsedTime.TotalSeconds) seconds"
}

# Function to set color and message for successful or failed operations
function Write-Log {
    param (
        [Parameter(Mandatory)][string]$Message,
        [Parameter()][string]$Color = "White"
    )
    Write-Host -ForegroundColor $Color $Message
}

# Check if running as administrator
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
{
    Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}
$Host.UI.RawUI.WindowTitle = "DirectX & Vcredist C++ | IBRPRIDE"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"
Clear-Host

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
            [Parameter()][int]$BarSize = 10,
            [Parameter()][switch]$Complete
        )
        $percent = $CurrentValue / $TotalValue
        $percentComplete = $percent * 100
        if ($psISE) {
            Write-Progress "$ProgressText" -id 0 -percentComplete $percentComplete
        }
        else {
            Write-Host -NoNewLine "`r$ProgressText $(''.PadRight($BarSize * $percent, [char]9608).PadRight($BarSize, [char]9617)) $($percentComplete.ToString('##0.0').PadLeft(6)) %"
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

# Download files
Write-Log "Downloading necessary files..." "Yellow"
Measure-ExecutionTime {
    # Download DirectX
    Get-FileFromWeb -URL "https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe" -File "$env:TEMP\DirectX.exe"

    # Download 7zip
    Get-FileFromWeb -URL "https://www.7-zip.org/a/7z2301-x64.exe" -File "$env:TEMP\7-Zip.exe"

    # Download C++ redistributables
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
}

Write-Log "`All files downloaded. Starting installations..." "Yellow"

# Install 7zip silently
Write-Log "Installing 7-Zip..." "Yellow"
Measure-ExecutionTime {
    Start-Process -wait "$env:TEMP\7-Zip.exe" /S | Out-Null
}

# Extract DirectX files with 7zip silently
Write-Log "Extracting DirectX files..." "Yellow"
Measure-ExecutionTime {
    cmd /c "C:\Program Files\7-Zip\7z.exe" x "$env:TEMP\DirectX.exe" -o"$env:TEMP\DirectX" -y | Out-Null
}

# Install DirectX silently
Write-Log "Installing DirectX..." "Yellow"
Measure-ExecutionTime {
    Start-Process -FilePath "$env:TEMP\DirectX\DXSETUP.exe" -ArgumentList "/silent" -Wait
}

Write-Log "C++ Redistributables..." "Yellow"

# Install C++ Redistributables silently
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
    Measure-ExecutionTime {
        Start-Process -wait $exe -ArgumentList $argList
    }
}

Write-Log "Installation of all components completed." "Green"

# Prompt to clean up downloaded files
$cleanup = Read-Host "Do you want to clean up the downloaded files? (y/n)"
if ($cleanup -eq 'y' -or $cleanup -eq 'Y') {
    Measure-ExecutionTime {
        Write-Log "Cleaning up downloaded files..." "Yellow"
        Remove-Item "$env:TEMP\DirectX.exe" -Force
        Remove-Item "$env:TEMP\7-Zip.exe" -Force
        Remove-Item "$env:TEMP\vcredist2005_x86.exe" -Force
        Remove-Item "$env:TEMP\vcredist2005_x64.exe" -Force
        Remove-Item "$env:TEMP\vcredist2008_x86.exe" -Force
        Remove-Item "$env:TEMP\vcredist2008_x64.exe" -Force
        Remove-Item "$env:TEMP\vcredist2010_x86.exe" -Force
        Remove-Item "$env:TEMP\vcredist2010_x64.exe" -Force
        Remove-Item "$env:TEMP\vcredist2012_x86.exe" -Force
        Remove-Item "$env:TEMP\vcredist2012_x64.exe" -Force
        Remove-Item "$env:TEMP\vcredist2013_x86.exe" -Force
        Remove-Item "$env:TEMP\vcredist2013_x64.exe" -Force
        Remove-Item "$env:TEMP\vcredist2015_2017_2019_2022_x86.exe" -Force
        Remove-Item "$env:TEMP\vcredist2015_2017_2019_2022_x64.exe" -Force
        Write-Log "Downloaded files cleaned up." "Green"
    }
}

$null = Read-Host "`nCompleted.`nPress Enter to exit "
