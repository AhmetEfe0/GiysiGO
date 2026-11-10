$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Resolve-CatalogBuildTools.ps1')
$testRoot = Join-Path (Split-Path $PSScriptRoot) ('database/GiysiGo.Database/bin/ToolDiscoveryTests/' + [Guid]::NewGuid().ToString('N'))
function New-TestInstallation([string]$name, [string]$product, [string]$version, [bool]$complete = $true, [string]$missingFile) {
    $root = Join-Path $testRoot $name
    $files = @('MSBuild/Current/Bin/MSBuild.exe', 'Common7/IDE/Extensions/Microsoft/SQLDB/DAC/SqlPackage.exe')
    if ($complete) { $files += 'MSBuild/Microsoft/VisualStudio/v17.0/SSDT/Microsoft.Data.Tools.Schema.SqlTasks.targets' }
    if ($missingFile) { $files = @($files | Where-Object { (Split-Path $_ -Leaf) -ne $missingFile }) }
    foreach ($file in $files) {
        $path = Join-Path $root $file
        [void][System.IO.Directory]::CreateDirectory((Split-Path $path))
        [System.IO.File]::WriteAllText($path, '')
    }
    return [pscustomobject]@{ installationPath = $root; productId = $product; installationVersion = $version }
}
function Assert-Selected([object]$actual, [string]$root) {
    if ($actual.MSBuildExtensionsPath -ne (Join-Path $root 'MSBuild') -or $actual.VisualStudioVersion -ne '17.0') {
        throw 'Yanlış Visual Studio/SSDT kurulumu seçildi.'
    }
}
$community = New-TestInstallation 'Community' 'Microsoft.VisualStudio.Product.Community' '17.14.0'
$ssms = New-TestInstallation 'SSMS' 'Microsoft.VisualStudio.Product.SSMS' '22.0.0'
$incomplete = New-TestInstallation 'EksikSSDT' 'Microsoft.VisualStudio.Product.BuildTools' '18.0.0' $false
Assert-Selected (Resolve-CatalogBuildTools -Installations @($ssms, $incomplete, $community)) $community.installationPath
foreach ($missingFile in @('MSBuild.exe', 'SqlPackage.exe')) {
    $incompleteTool = New-TestInstallation $missingFile 'Microsoft.VisualStudio.Product.Enterprise' '18.0.0' $true $missingFile
    Assert-Selected (Resolve-CatalogBuildTools -Installations @($incompleteTool, $community)) $community.installationPath
}
$latestValid = New-TestInstallation 'YeniUygunVS' 'Microsoft.VisualStudio.Product.Professional' '17.15.0'
Assert-Selected (Resolve-CatalogBuildTools -Installations @($community, $latestValid)) $latestValid.installationPath
foreach ($edition in @('Professional', 'Enterprise', 'BuildTools')) {
    $installation = New-TestInstallation $edition "Microsoft.VisualStudio.Product.$edition" '17.14.0'
    Assert-Selected (Resolve-CatalogBuildTools -Installations @($installation)) $installation.installationPath
}
$externalTools = Join-Path $testRoot 'HariciAraclar'
[void][System.IO.Directory]::CreateDirectory($externalTools)
$externalMsbuild = Join-Path $externalTools 'MSBuild.exe'
$externalSqlpackage = Join-Path $externalTools 'SqlPackage.exe'
[System.IO.File]::WriteAllText($externalMsbuild, '')
[System.IO.File]::WriteAllText($externalSqlpackage, '')
$explicit = Resolve-CatalogBuildTools -Installations @($ssms) -VisualStudioPath $community.installationPath `
    -MSBuildPath $externalMsbuild -SqlPackagePath $externalSqlpackage
Assert-Selected $explicit $community.installationPath
if ($explicit.MSBuildPath -ne $externalMsbuild -or $explicit.SqlPackagePath -ne $externalSqlpackage) {
    throw 'Açık araç yolları kullanılmadı.'
}
$missingRejected = $false
try { Resolve-CatalogBuildTools -Installations @($community) -SqlPackagePath (Join-Path $testRoot 'yok.exe') | Out-Null }
catch { $missingRejected = $true }
if (-not $missingRejected) { throw 'Geçersiz açık araç yolu reddedilmedi.' }
$unsupportedRejected = $false
try { Resolve-CatalogBuildTools -Installations @($ssms, $incomplete) | Out-Null }
catch { $unsupportedRejected = $true }
if (-not $unsupportedRejected) { throw 'SSMS veya eksik SSDT kurulumu uygun kurulum sayıldı.' }
Write-Output 'Araç keşfi: 10 senaryo geçti (SSMS/eksik araç eleme, en yeni uygun kurulum, VS ürünleri, açık yollar, geçersiz yol ve uygun kurulum yokluğu).'
