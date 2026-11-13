$ErrorActionPreference = 'Stop'

$ProjectRoot = $PSScriptRoot
$MiseConfig = Join-Path $ProjectRoot 'configs\mise\config.toml'

Set-Location $ProjectRoot

winget configure --enable

winget configure --file (Join-Path $ProjectRoot 'os\windows\apps.winget') --accept-configuration-agreements
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

winget configure --file (Join-Path $ProjectRoot 'os\windows\registry.winget') --accept-configuration-agreements
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$LocalMise = Join-Path $HOME '.local\bin\mise.exe'
if (Get-Command mise -CommandType Application -ErrorAction SilentlyContinue) {
    $MiseBin = (Get-Command mise -CommandType Application)[0].Path
} elseif (Test-Path $LocalMise) {
    # miseがPATHにないが、インストールされている場合
    $MiseBin = $LocalMise
} else {
    Invoke-RestMethod https://mise.run/powershell | Invoke-Expression
    $MiseBin = $LocalMise
}

$env:MISE_GLOBAL_CONFIG_FILE = $MiseConfig

& $MiseBin bootstrap --yes --force-dotfiles
exit $LASTEXITCODE
