# Keep this file ASCII-only and without a BOM: it is fetched as a string and passed to iex.
# Do not use `exit`: under iex it would close the caller's PowerShell window.
& {
    $ErrorActionPreference = 'Stop'

    $repo = 'https://github.com/takafumiokamoto/dotfiles.git'
    $dest = if ($env:DOTFILES_DIR) { $env:DOTFILES_DIR } else { Join-Path $HOME 'dotfiles' }

    if (-not (Get-Command git -CommandType Application -ErrorAction SilentlyContinue)) {
        winget install --id Git.Git --exact --source winget --accept-package-agreements --accept-source-agreements

        $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [Environment]::GetEnvironmentVariable('Path', 'User')

        if (-not (Get-Command git -CommandType Application -ErrorAction SilentlyContinue)) {
            throw 'git is still not available after "winget install Git.Git".'
        }
    }

    if (-not (Test-Path (Join-Path $dest '.git'))) {
        git clone $repo $dest
        if ($LASTEXITCODE -ne 0) {
            throw "git clone failed (exit code $LASTEXITCODE)."
        }
    }

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $dest 'install.ps1')
    if ($LASTEXITCODE -ne 0) {
        throw "install.ps1 failed (exit code $LASTEXITCODE)."
    }
}
