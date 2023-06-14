Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

# Check if the file exists
Write-Host "Start init"

# Check if the file exists
if (Test-Path -Path "medsync.txt" -PathType Leaf) {
    # Read the file content as key-value pairs
    $content = Get-Content -Path "medsync.txt"  -Raw
    $keyValuePairs = $content | ConvertFrom-StringData 

    Write-Host "config ${content}"
    # Set environment variables for each key-value pair
    foreach ($pair in $keyValuePairs.GetEnumerator()) {
        $key = $pair.Name
        $value = $pair.Value
        Write-Host "Environment variable:$key,$value."

        # Check if the key is empty
        if (![string]::IsNullOrEmpty($key)) {
		# Set the environment variable
		[Environment]::SetEnvironmentVariable($key, $value)
		Write-Verbose  "Environment variable '$key' set to '$value'"

        }
        else {
            #Write-PSFMessage -Level Verbose  "Empty key found. Skipping."
        }
    }
} else {
    Write-Error  "File '$filePath' does not exist."
}
Write-Host "Vars: location_id: ${location_id}, github_branch: ${github_branch}, client_id: ${client_id}, target_dir: ${target_dir}, log: ${log}"


Write-Host "Vars (init.ps1): location_id: ${location_id}, github_branch: ${github_branch}, client_id: ${client_id}, target_dir: ${target_dir}, log: ${log}"

$logLevel =[Environment]::GetEnvironmentVariable("log")
Write-Host "set debug and verbose log level to $logLevel"
$DebugPreference="$logLevel"
$VerbosePreference="$logLevel"

Write-Host  "testing logger - these entries will be written: Debug, Verbose, Host, Warning (Error ommitted) "
Write-Verbose "Verbose Log"
Write-Debug "Debug Log"
Write-Host "Host Log"
Write-Warning "Warning Log"
