<#
.SYNOPSIS
Optimizes Windows by disabling unnecessary scheduled tasks and logging.

.DESCRIPTION
This script modifies several registry keys and disables various scheduled tasks to optimize Windows performance. It checks for administrator privileges and prompts the user for confirmation before applying changes.

.LINK
https://ibrpride.com

.NOTES
Author: Ibrahim
Website: https://ibrpride.com
Script Version: 1.0
Last Updated: July 2024
#>

# Set the console window size
cmd /c "mode con: cols=75 lines=28"

# Check if the script is running as an admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    # Relaunch as an administrator
    Start-Process powershell.exe -ArgumentList ('-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $MyInvocation.MyCommand.Definition) -Verb RunAs
    exit
}

# Function to set console background and title
function Set-ConsoleBackground {
    $Host.UI.RawUI.WindowTitle = "Optimize Windows Scheduled Tasks | @IBRHUB"
    $Host.UI.RawUI.BackgroundColor = "Black"
    $Host.PrivateData.ProgressBackgroundColor = "Black"
    $Host.PrivateData.ProgressForegroundColor = "White"
    Clear-Host
}

# Function to write centered text
function Write-CenteredText {
    param (
        [string]$text,
        [ConsoleColor]$color = 'Yellow'
    )
    $width = $Host.UI.RawUI.WindowSize.Width
    $padLength = [math]::Max(0, ($width - $text.Length) / 2)
    $paddedText = $text.PadLeft($text.Length + $padLength).PadRight($width)
    Write-Host $paddedText -ForegroundColor $color
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

# Function to apply scheduled task optimizations
function Optimize-ScheduledTasks {
	Clear-Host
	Write-Host""
	Write-Host""
	Write-Host""
	Write-Host""
	Write-Host""
	Write-Host""
	Write-Host""
    Write-CenteredText -text "Optimizing Windows Scheduled Tasks"

    # Disable Maintenance tasks
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" -Name "MaintenanceDisabled" -Value 1 2> $null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\ScheduledDiagnostics" -Name "EnabledExecution" -Value 0 2> $null

# Disable specific scheduled tasks
$tasksToDisable = @(
    "\Microsoft\Windows\Application Experience\StartupAppTask",
    "\Microsoft\Windows\Application Experience\AitAgent",
    "\Microsoft\Windows\Application Experience\MareBackup",
    "\Microsoft\Windows\Application Experience\PcaPatchDbTask",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\ApplicationData\CleanupTemporaryState",
    "\Microsoft\Windows\ApplicationData\DsSvcCleanup",
    "\Microsoft\Windows\AppID\SmartScreenSpecific",
    "\Microsoft\Windows\Autochk\Proxy",
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
    "\Microsoft\Windows\Shell\FamilySafetyUpload",
    "\Microsoft\Windows\Location\Notifications",
    "\Microsoft\Windows\Location\WindowsActionDialog",
    "\Microsoft\Windows\Shell\FamilySafetyMonitorToastTask",
    "\Microsoft\Windows\SettingSync\BackgroundUploadTask",
    "\Microsoft\Windows\Customer Experience Improvement Program\Uploader",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\Customer Experience Improvement Program\BthSQM",
    "\Microsoft\Windows\Customer Experience Improvement Program\HypervisorFlightingTask",
    "\Microsoft\Windows\DiskFootprint\Diagnostics",
    "\Microsoft\Windows\Feedback\Siuf\DmClient",
    "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload",
    "\Microsoft\Windows\Maintenance\WinSAT",
    "\Microsoft\Windows\Maps\MapsToastTask",
    "\Microsoft\Windows\Maps\MapsUpdateTask",
    "\Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser",
    "\Microsoft\Windows\NetTrace\GatherNetworkInfo",
    "\Microsoft\Windows\Offline Files\Background Synchronization",
    "\Microsoft\Windows\Offline Files\Logon Synchronization",
    "\Driver Easy Scheduled Scan",
    "\Microsoft\Windows\Shell\FamilySafetyMonitor",
    "\Microsoft\Windows\Shell\FamilySafetyRefresh",
    "\Microsoft\Windows\SpacePort\SpaceAgentTask",
    "\Microsoft\Windows\SpacePort\SpaceManagerTask",
    "\Microsoft\Windows\Speech\SpeechModelDownloadTask",
    "\Microsoft\Windows\User Profile Service\HiveUploadTask",
    "\Microsoft\Windows\Wininet\CacheTask",
    "\Microsoft\Windows\Work Folders\Work Folders Logon Synchronization",
    "\Microsoft\Windows\Work Folders\Work Folders Maintenance Work",
    "\Microsoft\Windows\Workplace Join\Automatic-Device-Join",
    "\Microsoft\Windows\Windows Media Sharing\UpdateLibrary",
    "\Microsoft\Windows\SettingSync\BackupTask",
    "\Microsoft\Windows\SettingSync\NetworkStateChangeTask",
    "\Microsoft\Windows\Windows Filtering Platform\BfeOnServiceStartTypeChange",
    "\Microsoft\Windows\File Classification Infrastructure\Property Definition Sync",
    "\Microsoft\Windows\Management\Provisioning\Logon",
    "\Microsoft\Windows\NlaSvc\WiFiTask",
    "\Microsoft\Windows\WCM\WiFiTask",
    "\Microsoft\Windows\Ras\MobilityManager"
)

foreach ($task in $tasksToDisable) {
    schtasks /change /tn $task /disable > $null 2>&1
}

    # Disable SleepStudy logging
    wevtutil.exe set-log "Microsoft-Windows-SleepStudy/Diagnostic" /e:false 2> $null
    wevtutil.exe set-log "Microsoft-Windows-Kernel-Processor-Power/Diagnostic" /e:false 2> $null
    wevtutil.exe set-log "Microsoft-Windows-UserModePowerService/Diagnostic" /e:false 2> $null
	Write-Host""
	Write-Host""
	Write-Host""
    Write-CenteredText -text "Scheduled tasks optimized successfully." -color Green
	Write-Host""
	Write-Host""
	Write-Host""
    Read-Host -Prompt "                       Press Enter to continue..."

}

# Main script execution
Set-ConsoleBackground

if (Confirm-Changes -Message "Do you want to optimize Windows scheduled tasks?") {
    Optimize-ScheduledTasks
} else {
    Write-CenteredText -text "Operation canceled by the user."
    Read-Host -Prompt "Press Enter to exit..."
}

