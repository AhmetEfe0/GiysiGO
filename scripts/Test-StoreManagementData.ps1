param([string]$VisualStudioPath, [string]$MSBuildPath, [string]$SqlPackagePath, [string]$LocalDbPath, [string]$SqlCmdPath)
$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path $PSScriptRoot
. (Join-Path $PSScriptRoot 'Resolve-CatalogBuildTools.ps1')
$installations = @()
if (-not $VisualStudioPath) {
    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
    $installations = @(& $vswhere -products Microsoft.VisualStudio.Product.Community Microsoft.VisualStudio.Product.Professional Microsoft.VisualStudio.Product.Enterprise Microsoft.VisualStudio.Product.BuildTools -format json | ConvertFrom-Json)
    if ($LASTEXITCODE -ne 0) { throw 'Visual Studio kurulumları sorgulanamadı.' }
}
$tools = Resolve-CatalogBuildTools -Installations $installations -VisualStudioPath $VisualStudioPath -MSBuildPath $MSBuildPath -SqlPackagePath $SqlPackagePath
$localDb = if ($LocalDbPath) { $LocalDbPath } else { Join-Path $env:ProgramFiles 'Microsoft SQL Server/160/Tools/Binn/SqlLocalDB.exe' }
$sqlcmd = if ($SqlCmdPath) { $SqlCmdPath } else { (Get-Command sqlcmd -ErrorAction SilentlyContinue).Source }
if (-not $sqlcmd) { $sqlcmd = Get-ChildItem (Join-Path $env:ProgramFiles 'Microsoft SQL Server') -Filter SQLCMD.EXE -Recurse | Select-Object -First 1 -ExpandProperty FullName }
foreach ($tool in @($localDb,$sqlcmd)) { if (-not $tool -or -not (Test-Path -LiteralPath $tool -PathType Leaf)) { throw 'SQL Server 2022 LocalDB ve sqlcmd gereklidir.' } }
$versions = & $localDb versions
if ($LASTEXITCODE -ne 0 -or -not ($versions -match '\b16\.0\.')) { throw 'SQL Server 2022 LocalDB kurulmalıdır.' }
Write-Output "MSBuild: $($tools.MSBuildPath); SSDT: $($tools.MSBuildExtensionsPath); SqlPackage: $($tools.SqlPackagePath)"
& $tools.MSBuildPath (Join-Path $repositoryRoot 'database/GiysiGo.Database/GiysiGo.Database.sqlproj') /p:Configuration=Release "/p:VisualStudioVersion=$($tools.VisualStudioVersion)" "/p:MSBuildExtensionsPath=$($tools.MSBuildExtensionsPath)" /p:Platform=AnyCPU /m /verbosity:minimal
if ($LASTEXITCODE -ne 0) { throw 'DACPAC derlenemedi.' }
$suffix = [Guid]::NewGuid().ToString('N')
$instance = 'GGST_' + $suffix.Substring(0,12)
$database = 'GiysiGo_IdentityTest_' + $suffix
if ($instance -notmatch '^GGST_[a-f0-9]{12}$' -or $database -notmatch '^GiysiGo_IdentityTest_[a-f0-9]{32}$') { throw 'Güvenli test adı üretilemedi.' }
$server = '(localdb)\' + $instance
$connection = "Server=$server;Database=$database;Integrated Security=true;Encrypt=false;Pooling=false"
$variables = @('GIYSIGO_STORE_TEST_CONNECTION','GIYSIGO_IDENTITY_TEST_CONNECTION','GIYSIGO_CATALOG_TEST_CONNECTION','GIYSIGO_ORDERING_TEST_CONNECTION_STRING')
$previous = @{}
foreach ($variable in $variables) { $previous[$variable] = [Environment]::GetEnvironmentVariable($variable) }
$created = $false; $started = $false
$results = Join-Path $repositoryRoot 'database/GiysiGo.Database/bin/Release/StoreVerification'
try {
    & $localDb create $instance 16.0
    if ($LASTEXITCODE -ne 0) { throw 'Test örneği oluşturulamadı.' }; $created = $true
    & $localDb start $instance
    if ($LASTEXITCODE -ne 0) { throw 'Test örneği başlatılamadı.' }; $started = $true
    & $sqlcmd -S $server -d master -E -b -Q "IF CONVERT(int,SERVERPROPERTY('ProductMajorVersion'))<>16 THROW 51000,N'SQL Server 2022 gereklidir.',1; SELECT @@VERSION;"
    if ($LASTEXITCODE -ne 0) { throw 'SQL sürümü doğrulanamadı.' }
    foreach ($publication in 1..2) {
        & $tools.SqlPackagePath /Action:Publish "/SourceFile:$(Join-Path $repositoryRoot 'database/GiysiGo.Database/bin/Release/GiysiGo.Database.dacpac')" "/TargetConnectionString:$connection" /p:AllowIncompatiblePlatform=false /p:BlockOnPossibleDataLoss=true
        if ($LASTEXITCODE -ne 0) { throw 'DACPAC yayını başarısız.' }
        if ($publication -eq 1) {
            & $sqlcmd -S $server -d $database -E -I -b -i (Join-Path $repositoryRoot 'tests/Modules/Identity/Fixtures/PrepareSeedRedeploy.sql')
            if ($LASTEXITCODE -ne 0) { throw 'Identity seed tekrar testi hazırlanamadı.' }
        }
    }
    foreach ($variable in $variables) { [Environment]::SetEnvironmentVariable($variable,$connection) }
    $projects = [ordered]@{
        Catalog = 'tests/Modules/Catalog/GiysiGo.Modules.Catalog.Tests.csproj'
        API = 'tests/API/GiysiGo.API.IntegrationTests/GiysiGo.API.IntegrationTests.csproj'
        Identity = 'tests/Modules/Identity/GiysiGo.Modules.Identity.Tests.csproj'
        Ordering = 'tests/Modules/Ordering/GiysiGo.Modules.Ordering.Tests.csproj'
        Operations = 'tests/Modules/Operations/GiysiGo.Modules.Operations.Tests.csproj'
        Contracts = 'tests/Contracts/GiysiGo.Contracts.Tests.csproj'
    }
    foreach ($entry in $projects.GetEnumerator()) {
        & dotnet test (Join-Path $repositoryRoot $entry.Value) --configuration Release --verbosity minimal --logger "trx;LogFileName=$($entry.Key).trx" --results-directory $results
        if ($LASTEXITCODE -ne 0) { throw "$($entry.Key) testleri başarısız." }
        [xml]$trx = Get-Content -LiteralPath (Join-Path $results ($entry.Key + '.trx'))
        if ([int]$trx.TestRun.ResultSummary.Counters.notExecuted -ne 0) { throw "$($entry.Key) paketinde atlanan test var." }
    }
}
finally {
    foreach ($variable in $variables) { [Environment]::SetEnvironmentVariable($variable,$previous[$variable]) }
    if ($started) {
        & $sqlcmd -S $server -d master -E -b -i (Join-Path $PSScriptRoot 'Drop-IdentityTestDatabase.sql') -v "DatabaseName=$database"
        if ($LASTEXITCODE -ne 0) { throw 'Test veritabanı temizlenemedi; inceleme için örnek korundu.' }
        & $localDb stop $instance
        if ($LASTEXITCODE -ne 0) { throw 'Test örneği durdurulamadı.' }
        & $localDb delete $instance
        if ($LASTEXITCODE -ne 0) { throw 'Test örneği silinemedi.' }
    }
    elseif ($created) { & $localDb delete $instance }
}
