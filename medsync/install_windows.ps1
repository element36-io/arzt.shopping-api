param(
    [string]$branch = "medisync"
)

$ErrorActionPreference = "Stop" 

# Import the init.psm1 module
$modulePath = Join-Path -Path $PSScriptRoot -ChildPath "init.ps1" 
Import-Module -Force -Scope Global -Name $modulePath
Import-Module ScheduledTasks



[string]$baseUrl = "https://api.github.com/repos/element36-io/arzt.shopping-api/contents/medsync/"

# Function to download file from GitHub
function Download-FileFromGitHub {
    param(

        [string]$filename
    )

    $url = "$baseUrl$filename?ref=$branch"
    $outputFile = $filename

    Write-Host "Downloading file: $filename"

    $githubContent = (Invoke-RestMethod -Uri $url).content 
    $githubContent = [System.Text.Encoding]::UTF8.GetString(([System.Convert]::FromBase64String($githubContent)))

    # Read the local file contents
    $localContent = Get-Content $localFile -Raw 
  
    Write-Host "Updating file $localFile from GitHub."
    Set-Content -Path "${localFile}" -Value $githubContent
    Write-Host "File downloaded: $outputFile"
}



# Download files
#Download-FileFromGitHub  -filename "install_windows.ps1"
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
Download-FileFromGitHub -filename "medsync.ps1"
Download-FileFromGitHub -filename "medsync.txt"
Download-FileFromGitHub -filename "init.ps1"
Download-FileFromGitHub -filename "updater.ps1"
Download-FileFromGitHub -filename "updater.txt"

# Function to remove existing scheduled tasks for the script
function Remove-ExistingScheduledTasks {
    param(
        [string]$scriptName
    )

    # Get the existing scheduled tasks with the specified script name
    $existingTasks = Get-ScheduledTask | Where-Object { $_.Action -like "*$scriptName*" }

    foreach ($task in $existingTasks) {
        Write-Host "Removing existing scheduled task: $($task.TaskName)"
        Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false
    }
}

# Function to add script as a scheduled task
function Add-ScheduledTask {
    param(
        [string]$taskName,
        [string]$scriptPath,
        [string]$arguments,
        [string]$triggerSchedule
    )
    Write-Verbose $taskName $scriptPath 
    # Create a new scheduled task
    $taskAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" $arguments"
    $taskTrigger = New-ScheduledTaskTrigger -Daily -At $triggerSchedule
    $taskSettings = New-ScheduledTaskSettingsSet

    Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger -Settings $taskSettings
    Write-Host "Scheduled task added: $taskName"
}

# Schedule for updater script
$updaterScriptName = "updater.ps1"
$updaterSchedule = "17:00"
$updaterParameters = "updater"

# Schedule for regular script
$regularScriptName = "medsync.ps1"
$regularSchedule = "*/5 * * * *"
$regularParameters = "medsync"



# Remove existing scheduled tasks for the updater script
Remove-ExistingScheduledTasks -scriptName $scriptName

# Add updater script as a scheduled task
Add-ScheduledTask -taskName $scriptName -scriptPath "$PWD\$scriptName" -arguments $updaterParameters -triggerSchedule $updaterSchedule

# Add regular script as a scheduled task
Add-ScheduledTask -taskName $scriptName -scriptPath "$PWD\$scriptName" -arguments $regularParameters
