# Keep this file ASCII-only and without a BOM: `irm | iex` fetches it as a string and passes it to iex.
# Do not use `exit`: under iex it would close the caller's PowerShell window. Use `throw` instead.
& {
    $ErrorActionPreference = 'Stop'

    $Repo = 'https://github.com/takafumiokamoto/dotfiles.git'
    $ProjectRoot = if ($env:DOTFILES_DIR) { $env:DOTFILES_DIR } else { Join-Path $HOME 'dotfiles' }
    $MiseConfig = Join-Path $ProjectRoot 'configs\mise\config.toml'

    if (-not (Get-Command git -CommandType Application -ErrorAction SilentlyContinue)) {
        winget install --id Git.Git --exact --source winget --accept-package-agreements --accept-source-agreements

        $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [Environment]::GetEnvironmentVariable('Path', 'User')

        if (-not (Get-Command git -CommandType Application -ErrorAction SilentlyContinue)) {
            throw 'git is still not available after "winget install Git.Git".'
        }
    }

    if (-not (Test-Path (Join-Path $ProjectRoot '.git'))) {
        git clone $Repo $ProjectRoot
        if ($LASTEXITCODE -ne 0) {
            throw "git clone failed (exit code $LASTEXITCODE)."
        }
    }

    Set-Location $ProjectRoot

    winget configure --enable

    winget configure --file (Join-Path $ProjectRoot 'os\windows\apps.winget') --accept-configuration-agreements
    if ($LASTEXITCODE -ne 0) {
        throw "winget configure failed for apps.winget (exit code $LASTEXITCODE)."
    }

    winget configure --file (Join-Path $ProjectRoot 'os\windows\registry.winget') --accept-configuration-agreements
    if ($LASTEXITCODE -ne 0) {
        throw "winget configure failed for registry.winget (exit code $LASTEXITCODE)."
    }

    $LocalMise = Join-Path $HOME '.local\bin\mise.exe'
    if (Get-Command mise -CommandType Application -ErrorAction SilentlyContinue) {
        $MiseBin = (Get-Command mise -CommandType Application)[0].Path
    } elseif (Test-Path $LocalMise) {
        # mise is installed but not on PATH.
        $MiseBin = $LocalMise
    } else {
        Invoke-RestMethod https://mise.run/powershell | Invoke-Expression
        $MiseBin = $LocalMise
    }

    $env:MISE_GLOBAL_CONFIG_FILE = $MiseConfig

    & $MiseBin bootstrap --yes --force-dotfiles
    if ($LASTEXITCODE -ne 0) {
        throw "mise bootstrap failed (exit code $LASTEXITCODE)."
    }
}
