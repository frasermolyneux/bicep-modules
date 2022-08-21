param (
    [string] $moduleName,
    [string] $modulesRootPath,
    [string] $metadataRootPath,
    [string] $acrName,
    [string] $repositoryPrefix = "bicep/modules",
    [boolean] $previewRelease = $true
)

$moduleFilePath = Join-Path $modulesRootPath "$moduleName.bicep"
$metadataFilePath = Join-Path $metadataRootPath "$moduleName.json"
$acrRepository = "$repositoryPrefix/$moduleName".ToLower()

if ((Test-Path $moduleFilePath) -eq $false) {
    Write-Error "The module at '$moduleFilePath' could not be found!"
    exit
}

if ((Test-Path $metadataFilePath) -eq $false) {
    Write-Error "The module at '$moduleFilePath' could not be found!"
    exit
}

Write-Host "Using metadata file: '$metadataFilePath'"
$moduleMetadata = Get-Content $metadataFilePath | ConvertFrom-Json

$moduleTag = "V$($moduleMetadata.version)"
if ($previewRelease) {
    $moduleTag = "$moduleTag-preview"
}

Write-Host "Setting the module version tag to: '$moduleTag'"

$publishModule = $false

$repositories = az acr repository list --name $acrName | ConvertFrom-Json
if ($null -eq $repositories -or !$repositories.Contains($acrRepository)) {
    $publishModule = $true
}
else {
    $moduleTags = az acr repository show-tags --name $acrName --repository $acrRepository | ConvertFrom-Json

    if ($moduleTags.Contains($moduleTag)) {
        Write-Warning "There is already a published image with the tag '$moduleTag'"
    }
    else {
        $publishModule = $true
    }
}

if ($publishModule) {
    Write-Host "Publishing new module to: 'br:$acrName.azurecr.io/${acrRepository}' with tag: '$moduleTag'"
    az bicep publish --file $moduleFilePath --target "br:$acrName.azurecr.io/${acrRepository}:$moduleTag"
}

if ($publishModule -and $previewRelease -eq $false) {
    Write-Host "Publishing new module to: 'br:$acrName.azurecr.io/${acrRepository}' with tag: 'latest'"
    az bicep publish --file $moduleFilePath --target "br:$acrName.azurecr.io/${acrRepository}:latest"
}