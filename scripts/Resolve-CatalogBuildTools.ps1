function Resolve-CatalogBuildTools {
    param(
        [object[]]$Installations = @(),
        [string]$VisualStudioPath,
        [string]$MSBuildPath,
        [string]$SqlPackagePath
    )

    foreach ($override in @($MSBuildPath, $SqlPackagePath)) {
        if ($override -and -not (Test-Path -LiteralPath $override -PathType Leaf)) {
            throw "Belirtilen araç bulunamadı: $override"
        }
    }
    $allowedProducts = @(
        'Microsoft.VisualStudio.Product.Community', 'Microsoft.VisualStudio.Product.Professional',
        'Microsoft.VisualStudio.Product.Enterprise', 'Microsoft.VisualStudio.Product.BuildTools'
    )
    $candidates = @($Installations | Where-Object { $_.productId -in $allowedProducts } |
        Sort-Object { [version]$_.installationVersion } -Descending)
    if ($VisualStudioPath) { $candidates = @([pscustomobject]@{ installationPath = $VisualStudioPath }) }

    foreach ($candidate in $candidates) {
        $root = $candidate.installationPath
        $msbuild = if ($MSBuildPath) { $MSBuildPath } else { Join-Path $root 'MSBuild/Current/Bin/MSBuild.exe' }
        $sqlpackage = if ($SqlPackagePath) { $SqlPackagePath } else { Join-Path $root 'Common7/IDE/Extensions/Microsoft/SQLDB/DAC/SqlPackage.exe' }
        # Aynı kurulumda hem MSBuild hem SSDT hedefleri ve SqlPackage bulunmalıdır.
        $targetsRoot = Join-Path $root 'MSBuild/Microsoft/VisualStudio'
        $targets = Get-ChildItem -LiteralPath $targetsRoot -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '^v\d+\.\d+$' } |
            Sort-Object { [version]$_.Name.Substring(1) } -Descending |
            Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SSDT/Microsoft.Data.Tools.Schema.SqlTasks.targets') -PathType Leaf } |
            Select-Object -First 1
        if ((Test-Path -LiteralPath $msbuild -PathType Leaf) -and
            (Test-Path -LiteralPath $sqlpackage -PathType Leaf) -and $targets) {
            return [pscustomobject]@{
                MSBuildPath = $msbuild
                SqlPackagePath = $sqlpackage
                VisualStudioVersion = $targets.Name.Substring(1)
                MSBuildExtensionsPath = Join-Path $root 'MSBuild'
            }
        }
    }
    throw 'MSBuild, SSDT hedefleri ve SqlPackage içeren uygun Visual Studio/Build Tools kurulumu bulunamadı. -VisualStudioPath, -MSBuildPath ve -SqlPackagePath ile kurulum/araç yollarını belirtebilirsiniz.'
}
