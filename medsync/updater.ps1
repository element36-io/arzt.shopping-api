$ErrorActionPreference = "Stop" 

# Import the init.psm1 module
$modulePath = Join-Path -Path $PSScriptRoot -ChildPath "init.ps1" 
Import-Module -Force -Scope Global -Name $modulePath

$logLevel =[Environment]::GetEnvironmentVariable("log")
$DebugPreference="$logLevel"
$VerbosePreference="$logLevel"
$branch = [Environment]::GetEnvironmentVariable("github_branch")

$githubBaseUrl = "https://api.github.com/repos/element36-io/arzt.shopping-api/contents//medsync"


$localFiles = Get-Content updater.txt

Write-Host "files " $localFiles

# Iterate over the local files
foreach ($localFile in $localFiles) {
    # Check if the local file exists
    if (Test-Path $localFile) {
        # Retrieve the file contents from GitHub
        $githubContentUrl = "${githubBaseUrl}/${localFile}?ref=${branch}"
        Write-Host "checking URL: "$githubContentUrl
        #base 64 encoded 
        $githubContent = (Invoke-RestMethod -Uri $githubContentUrl).content 
        $githubContent = [System.Text.Encoding]::UTF8.GetString(([System.Convert]::FromBase64String($githubContent)))

        Write-Host "web: "$githubContent

        # Read the local file contents
        $localContent = Get-Content $localFile -Raw 
        
        # Compare the contents of the local file with GitHub content
        Write-Host "..."
        $localContent
        $githubContent
        if ($localContent.Trim() -ne $githubContent.Trim()) {
            # Contents are different, update the local file
            Write-Host "Updating file $localFile from GitHub."
            Set-Content -Path "${localFile}" -Value $githubContent
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