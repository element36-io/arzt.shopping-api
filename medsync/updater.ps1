$ErrorActionPreference = "Stop" 

# Import the init.psm1 module
$modulePath = Join-Path -Path $PSScriptRoot -ChildPath "init.ps1" 
Import-Module -Force -Scope Global -Name $modulePath

$logLevel =[Environment]::GetEnvironmentVariable("log")
$DebugPreference="$logLevel"
$VerbosePreference="$logLevel"
$branch = [Environment]::GetEnvironmentVariable("github_branch")

$github_base_url="https://api.github.com/repos/element36-io/arzt.shopping-api/commits/$branch"

$localFiles = Get-Content updater.txt

Write-Host "files " $localFiles

# Retrieve the commit information from GitHub API
$commitInfo = Invoke-RestMethod -Uri $githubBaseUrl

# Extract the file paths from the commit
$githubFiles = $commitInfo.files.path
# Iterate over the local files
foreach ($localFile in $localFiles) {
    # Check if the local file exists
    if (Test-Path $localFile) {
        # Retrieve the file contents from GitHub
        $githubContentUrl = "$githubBaseUrl/$localFile"
        $githubContent = (Invoke-RestMethod -Uri $githubContentUrl).content

        # Read the local file contents
        $localContent = Get-Content $localFile -Raw

        # Compare the contents of the local file with GitHub content
        if ($localContent -ne $githubContent) {
            # Contents are different, update the local file
            Write-Host "Updating file $localFile from GitHub."

            # Add your code logic here to download and update the file
        }
        else {
            # Contents are the same
            Write-Host "File $localFile is up to date."
        }
    }
    else {
        # File doesn't exist locally, download it from GitHub
        Write-Host "Downloading file $localFile from GitHub."

        # Add your code logic here to download the file
    }
}