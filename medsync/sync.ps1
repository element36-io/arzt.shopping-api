$ErrorActionPreference = "Stop" 
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module GoogleCloud 
Install-Module GoogleOAuth2 


#Install-Module -Name GoogleAuth -Scope CurrentUser
# Set the bucket name, keyfile path, and destination directory
$locationId = "71781646576"
$bucketName = "arzt-${locationId}"
$keyfilePath = "/scripts/key-${locationId}.json"
$destDirectory = "/scripts/out"
$scope = "https://www.googleapis.com/auth/devstorage.read_write"
$pwd = "notasecret"
# Set the base URL for the Google Cloud Storage REST API
$baseUri = "https://www.googleapis.com/storage/v1/b/${bucketName}/o"
Write-Host "uri1 $baseUri" 
# Load the JSON key file
$keyFile = Get-Content $keyfilePath | ConvertFrom-Json
$clientId = $keyFile.client_id
$clientEmail = $keyFile.client_email
$privateKey = $keyFile.private_key
# Load the P12 file
$p12FilePath = "/scripts/key.p12"
$p12Password = "notasecret"


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


$response = Invoke-RestMethod -Uri $listObjectsUrl -Headers $headers
$files = $response.items
Write-Host $files


# Loop through each file and download it
foreach ($file in $files) {
    $fileName = $file.name
    $localPath = Join-Path -Path $destDirectory -ChildPath $fileName

    # Download the file
    $downloadUrl = "${baseUri}/${fileName}?alt=media"
    Write-Host "dl" $downloadUrl
    Invoke-RestMethod -Uri $downloadUrl -Headers $headers -OutFile $localPath

    # Check if the file was downloaded successfully
    if (Test-Path $localPath) {
        # File downloaded successfully, delete it from the bucket
        $deleteUrl = "${baseUri}/${fileName}"
        Write-Host "del " $deleteUrl
        Invoke-RestMethod -Uri $deleteUrl -Method DELETE -Headers $headers

        Write-Host "Downloaded and deleted: $fileName"
    }
    else {
        Write-Host "Failed to download: $fileName"
    }
}
