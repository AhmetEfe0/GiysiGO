param()

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path $PSScriptRoot
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
if (-not (Test-Path -LiteralPath $vswhere)) { throw 'Visual Studio kurulum bulucusu (vswhere) bulunamadı.' }
$installation = (& $vswhere -latest -products '*' -format json | ConvertFrom-Json) | Select-Object -First 1
if (-not $installation) { throw 'Visual Studio veya Build Tools kurulumu bulunamadı.' }
$msbuildTool = Join-Path $installation.installationPath 'MSBuild\Current\Bin\MSBuild.exe'
$visualStudioVersion = ([version]$installation.installationVersion).Major.ToString() + '.0'
$sqlPackageTool = Join-Path $installation.installationPath 'Common7\IDE\Extensions\Microsoft\SQLDB\DAC\SqlPackage.exe'
$localDbTool = (Get-Command SqlLocalDB -ErrorAction SilentlyContinue).Source
$localDb2022Tool = Join-Path $env:ProgramFiles 'Microsoft SQL Server\160\Tools\Binn\SqlLocalDB.exe'
if (Test-Path -LiteralPath $localDb2022Tool) { $localDbTool = $localDb2022Tool }
$sqlcmdTool = (Get-Command sqlcmd -ErrorAction SilentlyContinue).Source
if (-not $localDbTool) {
    $localDbTool = Get-ChildItem (Join-Path $env:ProgramFiles 'Microsoft SQL Server') -Filter SqlLocalDB.exe -Recurse | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $sqlcmdTool) {
    $sqlcmdTool = Get-ChildItem (Join-Path $env:ProgramFiles 'Microsoft SQL Server') -Filter SQLCMD.EXE -Recurse | Select-Object -First 1 -ExpandProperty FullName
}
foreach ($tool in @($msbuildTool, $sqlPackageTool, $localDbTool, $sqlcmdTool)) {
    if (-not $tool -or -not (Test-Path -LiteralPath $tool)) { throw 'MSBuild/SSDT, SqlPackage, SqlLocalDB ve sqlcmd kurulu olmalıdır.' }
}
$localDbVersions = & $localDbTool versions
if ($LASTEXITCODE -ne 0 -or -not ($localDbVersions -match '16\.0\.')) {
    throw 'Bu doğrulama SQL Server 2022 LocalDB (16.x) gerektirir; eski sürüme otomatik geçilmez.'
}

& node (Join-Path $repositoryRoot 'docs/generate-catalog-seed.mjs')
if ($LASTEXITCODE -ne 0) { throw 'Katalog seed üretimi başarısız.' }
& node (Join-Path $repositoryRoot 'docs/generate-identity-permission-seed.mjs')
if ($LASTEXITCODE -ne 0) { throw 'Identity permission seed üretimi başarısız.' }
& $msbuildTool (Join-Path $repositoryRoot 'database/GiysiGo.Database/GiysiGo.Database.sqlproj') /p:Configuration=Release "/p:VisualStudioVersion=$visualStudioVersion" /p:Platform=AnyCPU /m /verbosity:minimal
if ($LASTEXITCODE -ne 0) { throw 'DACPAC derlemesi başarısız.' }

$suffix = [Guid]::NewGuid().ToString('N')
$instanceName = 'GGCA_' + $suffix.Substring(0, 12)
# Identity repository testlerinin ayrılmış veritabanı korumasıyla da uyumludur.
$databaseName = 'GiysiGo_IdentityTest_' + $suffix
if ($instanceName -notmatch '^GGCA_[a-f0-9]{12}$' -or $databaseName -notmatch '^GiysiGo_IdentityTest_[a-f0-9]{32}$') { throw 'Ayrılmış test veritabanının adı geçersiz.' }
$serverName = '(localdb)\' + $instanceName
$connectionString = "Server=$serverName;Database=$databaseName;Integrated Security=true;Encrypt=false;Pooling=false"
$previousConnection = $env:GIYSIGO_CATALOG_TEST_CONNECTION
$previousOrderingConnection = $env:GIYSIGO_ORDERING_TEST_CONNECTION_STRING
$previousIdentityConnection = $env:GIYSIGO_IDENTITY_TEST_CONNECTION
$resultsDirectory = Join-Path $repositoryRoot 'database/GiysiGo.Database/bin/Release/CatalogVerification'
function Invoke-ProjectTests([string]$project, [string]$resultName) {
    & dotnet test (Join-Path $repositoryRoot $project) --configuration Release --verbosity minimal --logger "trx;LogFileName=$resultName.trx" --results-directory $resultsDirectory
    if ($LASTEXITCODE -ne 0) { throw "$resultName testleri başarısız." }
}
$instanceCreated = $false
$instanceStarted = $false
try {
    & $localDbTool create $instanceName 16.0
    if ($LASTEXITCODE -ne 0) { throw 'Ayrılmış LocalDB örneği oluşturulamadı.' }
    $instanceCreated = $true
    & $localDbTool start $instanceName
    if ($LASTEXITCODE -ne 0) { throw 'Ayrılmış LocalDB örneği başlatılamadı.' }
    $instanceStarted = $true
    & $sqlcmdTool -S $serverName -d master -E -b -Q "IF CONVERT(int, SERVERPROPERTY('ProductMajorVersion')) <> 16 THROW 51000, N'Test sunucusu SQL Server 2022 olmalıdır.', 1; SELECT @@VERSION AS TestSunucusu;"
    if ($LASTEXITCODE -ne 0) { throw 'SQL Server 2022 çalışma zamanı doğrulanamadı.' }
    & $sqlPackageTool /Action:Publish "/SourceFile:$(Join-Path $repositoryRoot 'database/GiysiGo.Database/bin/Release/GiysiGo.Database.dacpac')" "/TargetConnectionString:$connectionString" /p:BlockOnPossibleDataLoss=true /p:AllowIncompatiblePlatform=false
    if ($LASTEXITCODE -ne 0) { throw 'DACPAC test veritabanına yüklenemedi.' }
    $env:GIYSIGO_CATALOG_TEST_CONNECTION = $connectionString
    $env:GIYSIGO_ORDERING_TEST_CONNECTION_STRING = $connectionString
    $env:GIYSIGO_IDENTITY_TEST_CONNECTION = $connectionString
    Invoke-ProjectTests 'tests/Modules/Catalog/GiysiGo.Modules.Catalog.Tests.csproj' 'Catalog'
    Invoke-ProjectTests 'tests/API/GiysiGo.API.IntegrationTests/GiysiGo.API.IntegrationTests.csproj' 'API'
    Invoke-ProjectTests 'tests/Modules/Identity/GiysiGo.Modules.Identity.Tests.csproj' 'Identity'
    Invoke-ProjectTests 'tests/Modules/Ordering/GiysiGo.Modules.Ordering.Tests.csproj' 'Ordering'
    Invoke-ProjectTests 'tests/Modules/Operations/GiysiGo.Modules.Operations.Tests.csproj' 'Operations'
    Invoke-ProjectTests 'tests/Contracts/GiysiGo.Contracts.Tests.csproj' 'Contracts'
}
finally {
    $env:GIYSIGO_CATALOG_TEST_CONNECTION = $previousConnection
    $env:GIYSIGO_ORDERING_TEST_CONNECTION_STRING = $previousOrderingConnection
    $env:GIYSIGO_IDENTITY_TEST_CONNECTION = $previousIdentityConnection
    if ($instanceStarted) {
        # Yalnız bu çalıştırmanın ürettiği, adı yukarıda doğrulanan test veritabanı silinir.
        & $sqlcmdTool -S $serverName -d master -E -b -i (Join-Path $PSScriptRoot 'Drop-CatalogTestDatabase.sql') -v "DatabaseName=$databaseName"
        if ($LASTEXITCODE -ne 0) { throw "Test veritabanı temizlenemedi; inceleme için korunuyor: $databaseName" }
        & $localDbTool stop $instanceName
        if ($LASTEXITCODE -ne 0) { throw 'Ayrılmış LocalDB örneği durdurulamadı.' }
        & $localDbTool delete $instanceName
        if ($LASTEXITCODE -ne 0) { throw 'Ayrılmış LocalDB örneği silinemedi.' }
    }
    elseif ($instanceCreated) {
        & $localDbTool delete $instanceName
    }
}
