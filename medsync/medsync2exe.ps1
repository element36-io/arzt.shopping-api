# Import the PS2EXE module
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
#Install-Module -Name PS2EXE
# Check if PS2EXE module is already installed
if (-not (Get-Module -ListAvailable -Name PS2EXE)) {
    # Install PS2EXE module
    try {
        Install-Module -Name PS2EXE -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
    } catch {
        Write-Host "Failed to install the PS2EXE module. Error: $($_.Exception.Message)"
        Exit 1
    }
}




Import-Module PS2EXE

# Set the source script path
$sourceScript = "medsync.ps1"

# Set the target executable path
$targetExecutable = "medsync.exe"

# Convert the script to an executable
$ps2exeParams = @{
    ScriptFile      = $sourceScript
    OutputDirectory = Split-Path $targetExecutable
    OutputFile      = Split-Path $targetExecutable -Leaf
    NoConsole       = $true
}
ConvertTo-EXE @ps2exeParams
