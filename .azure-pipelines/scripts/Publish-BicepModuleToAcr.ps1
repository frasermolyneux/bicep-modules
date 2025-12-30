param (
    [string] $moduleName,
    [string] $modulesRootPath,
    [string] $acrName,
    [string] $repositoryPrefix = "bicep/modules",
    [boolean] $previewRelease = $true
)

$moduleFilePath = Join-Path $modulesRootPath $moduleName "main.bicep"
$metadataFilePath = Join-Path $modulesRootPath $moduleName "metadata.json"
$acrRepository = "$repositoryPrefix/$moduleName".ToLower()

if ((Test-Path $moduleFilePath) -eq $false) {
    Write-Error "The module at '$moduleFilePath' could not be found!"
    exit
}

if ((Test-Path $metadataFilePath) -eq $false) {
    Write-Error "The metadata file at '$metadataFilePath' could not be found!"
    exit
}

Write-Host "Using module file: '$moduleFilePath'"
Write-Host "Using metadata file: '$metadataFilePath'"
$moduleMetadata = Get-Content $metadataFilePath | ConvertFrom-Json

$tagsToPushTo = @()

if ($previewRelease) {
    $majorMinorRevisionVersion = "V$($moduleMetadata.version.major).$($moduleMetadata.version.minor).$($moduleMetadata.version.revision)-preview"
}
else {
    $majorMinorRevisionVersion = "V$($moduleMetadata.version.major).$($moduleMetadata.version.minor).$($moduleMetadata.version.revision)"
}

$majorXVersion = "V$($moduleMetadata.version.major).x"
$majorMinorXRevisionVersion = "V$($moduleMetadata.version.major).$($moduleMetadata.version.minor).x"

$repositories = az acr repository list --name $acrName | ConvertFrom-Json
if ($null -eq $repositories -or !$repositories.Contains($acrRepository)) {
    $tagsToPushTo += $majorMinorRevisionVersion

    if (!$previewRelease) {
        $tagsToPushTo += $majorXVersion
        $tagsToPushTo += $majorMinorXRevisionVersion
        $tagsToPushTo += "latest"
    }
}
else {
    $moduleTags = az acr repository show-tags --name $acrName --repository $acrRepository | ConvertFrom-Json

    if ($moduleTags.Contains($majorMinorRevisionVersion)) {
        Write-Warning "There is already a published image with the tag '$majorMinorRevisionVersion'"
    }
    else {
        $tagsToPushTo += $majorMinorRevisionVersion

        if (!$previewRelease) {
            $tagsToPushTo += $majorXVersion
            $tagsToPushTo += $majorMinorXRevisionVersion
            $tagsToPushTo += "latest"
        }
    }
}

$tagsToPushTo | ForEach-Object {
    Write-Host "Publishing module to: 'br:$acrName.azurecr.io/${acrRepository}' with tag: '$_'"
    az bicep publish --file $moduleFilePath --target "br:$acrName.azurecr.io/${acrRepository}:$_" --force
}