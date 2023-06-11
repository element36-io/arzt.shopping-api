Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

# Check if the file exists
if (Test-Path -Path "medsync.txt" -PathType Leaf) {
    # Read the file content as key-value pairs
    $content = Get-Content -Path "medsync.txt"  -Raw
    $keyValuePairs = $content | ConvertFrom-StringData 

    # Set environment variables for each key-value pair
    foreach ($pair in $keyValuePairs.GetEnumerator()) {
        $key = $pair.Name
        $value = $pair.Value
        #Write-PSFMessage -Level Verbose "Environment variable:$key,$value."

        # Check if the key is empty
        if (![string]::IsNullOrEmpty($key)) {
            # Check if the environment variable already exists
            if (![Environment]::GetEnvironmentVariable($key)) {
                # Set the environment variable
                [Environment]::SetEnvironmentVariable($key, $value)
                Write-Verbose  "Environment variable '$key' set to '$value'"
            }
            else {
                Write-Verbose  "Environment variable '$key' already exists with value . Skipping. value: "+[Environment]::GetEnvironmentVariable($key)
            }
        }
        else {
            #Write-PSFMessage -Level Verbose  "Empty key found. Skipping."
        }
    }
} else {
    Write-Error  "File '$filePath' does not exist."
}

$logLevel =[Environment]::GetEnvironmentVariable("log")
Write-Host "set debug and verbose log level to $logLevel"
$DebugPreference="$logLevel"
$VerbosePreference="$logLevel"

Write-Host  "testing logger - these entries will be written: Debug, Verbose, Host, Warning (Error ommitted) "
Write-Verbose "Verbose Log"
Write-Debug "Debug Log"
Write-Host "Host Log"
Write-Warning "Warning Log"
