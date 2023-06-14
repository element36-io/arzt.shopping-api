$ErrorActionPreference = "Stop" 

$filePath = "medsync.txt"
# Read the property file as an associative array
$properties = Get-Content -Path $filePath | ForEach-Object {
    $line = $_.Trim()
    if (-not [string]::IsNullOrWhiteSpace($line) -and -not $line.StartsWith("#")) {
        $parts = $line -split "\s*=\s*", 2
        if ($parts.Count -eq 2) {
            $parts[0] = $parts[0].Trim()
            $parts[1] = $parts[1].Trim()
            [PSCustomObject]@{ Key = $parts[0]; Value = $parts[1] }
        }
    }
}


$locationId = $properties | Where-Object { $_.Key -eq "location_id" } | Select-Object -ExpandProperty Value
$branch =  $properties | Where-Object { $_.Key -eq "github_branch" } | Select-Object -ExpandProperty Value
$clientId = $properties | Where-Object { $_.Key -eq "client_id" } | Select-Object -ExpandProperty Value
$destDirectory = $properties | Where-Object { $_.Key -eq "target_dir" } | Select-Object -ExpandProperty Value
$logLevel =$properties | Where-Object { $_.Key -eq "log" } | Select-Object -ExpandProperty Value

Write-Verbose "Vars (medsync.ps1): location_id: ${location_id}, github_branch: ${github_branch}, client_id: ${client_id}, target_dir: ${target_dir}, log: ${log}"

$DebugPreference="$logLevel"
$VerbosePreference="$logLevel"

$bucketName = "arzt-${locationId}"
$clientEmail="mediscript-${locationId}@arzt-shopping.iam.gserviceaccount.com"
$scope = "https://www.googleapis.com/auth/devstorage.read_write"
# Set the base URL for the Google Cloud Storage REST API
$baseUri = "https://www.googleapis.com/storage/v1/b/${bucketName}/o"
# Load the P12 file

$p12Password = "notasecret"
$p12FilePath = "key.p12"
if (-not (Test-Path $p12FilePath)) {
    Write-Host "--> USING DEMO KEY"
    $p12FilePath = "demo-key.p12"
}
if (-not (Test-Path $destDirectory)) {
    Write-Host "--> output directory not found"
    Exit 1
}


$jwtHeader = @{
    alg = 'RS256'
    typ = 'JWT'
}
#Write-Host "jwtHeader" ($jwtHeader | ConvertTo-Json -Compress)
$encodedJwtHeader = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(($jwtHeader | ConvertTo-Json -Compress)))

$jwtPayload = @{
    iss = $clientEmail
    sub = 'walter.strametz@element36.io'
    scope = $scope
    aud = 'https://oauth2.googleapis.com/token'
    iat = [int][math]::Truncate((Get-Date -UFormat "%s")) # Current UNIX timestamp
    exp = [int][math]::Truncate((Get-Date -UFormat "%s")) + 3000 # Expiration time in UNIX timestamp (1 hour from now)
}
#Write-Host "jwtPayload" ($jwtPayload | ConvertTo-Json -Compress)

$encodedJwtPayload = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(($jwtPayload | ConvertTo-Json -Compress)))

# Create the JWT signature
$dataToSign = $encodedJwtHeader + '.' + $encodedJwtPayload

$certificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($p12FilePath,$p12Password)

$signedData = $certificate.privateKey.SignData(
    [system.text.encoding]::utf8.getbytes($dataToSign), 
    [System.Security.Cryptography.HashAlgorithmName]::SHA256,
    [System.Security.Cryptography.RSASignaturePadding]::Pkcs1) 

$signedData64= [System.Convert]::ToBase64String($signedData)

$submit = $encodedJwtHeader + '.' + $encodedJwtPayload + '.' + $signedData64

$authParams = @{
    grant_type    = "urn:ietf:params:oauth:grant-type:jwt-bearer"
    assertion     = $submit
}
    
$response = Invoke-RestMethod -Uri 'https://oauth2.googleapis.com/token' -Method POST -Body $authParams
$accessToken = $response.access_token


# Get the list of objects/files in the bucket
$listObjectsUrl = "${baseUri}?fields=items(name)"
$headers = @{
    "Authorization" = "Bearer $accessToken"
}

Write-Host "get PDFs "
$response = Invoke-RestMethod -Uri $listObjectsUrl -Headers $headers
Write-Verbose "response $response.items"

$files = $response.items


# Loop through each file and download it
foreach ($file in $files) {
    Write-Verbose "file $file"
    $fileName = $file.name
    $localPath = Join-Path -Path $destDirectory -ChildPath $fileName

    # Download the file
    $downloadUrl = "${baseUri}/${fileName}?alt=media"
    Write-Debug "download: ${downloadUrl}"
    Invoke-RestMethod -Uri $downloadUrl -Headers $headers -OutFile $localPath
    Write-Debug "check $localPath"

    # Check if the file was downloaded successfully
    if (Test-Path $localPath) {
        # File downloaded successfully, delete it from the bucket
        $deleteUrl = "${baseUri}/${fileName}"
        Write-Debug "delete  $deleteUrl"
        Invoke-RestMethod -Uri $deleteUrl -Method DELETE -Headers $headers

        Write-Verbose "Downloaded and deleted: $fileName"
    }
    else {
        Write-Warning "Failed to download: $fileName"
    }
}