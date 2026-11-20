# rsh — быстрая установка из GitHub Releases (готовый бинарь, без локальной сборки).
#   irm https://raw.githubusercontent.com/Zenoku-Dev/rsh/main/install.ps1 | iex
# Переменные: $env:RSH_INSTALL_DIR, $env:RSH_INSTALL_TAG (по умолчанию latest).
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$repo = 'Zenoku-Dev/rsh'
$tag = if ($env:RSH_INSTALL_TAG) { $env:RSH_INSTALL_TAG } else { 'latest' }
$asset = 'rsh-windows-amd64.exe'
$url = "https://github.com/$repo/releases/$tag/download/$asset"

$arch = $env:PROCESSOR_ARCHITECTURE
if ($arch -ne 'AMD64') {
    throw "rsh: нет готового ассета для $arch (нужен windows/amd64)."
}

$destDir = if ($env:RSH_INSTALL_DIR) { $env:RSH_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA 'Programs\rsh' }
$dest = Join-Path $destDir 'rsh.exe'
New-Item -ItemType Directory -Path $destDir -Force | Out-Null

$tmp = Join-Path $env:TEMP ("rsh-install-{0}.exe" -f $PID)
try {
    Write-Host "rsh: скачиваю $asset ($tag)…"
    Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing

    $banner = (& $tmp -h 2>$null | Select-Object -First 1)
    if (-not $banner -or -not $banner.StartsWith('rsh')) {
        throw "rsh: подкачанный бинарь не запускается. Старый файл не тронут."
    }

    if (Test-Path $dest) {
        Copy-Item $dest "$dest.bak-$(Get-Date -Format yyyyMMdd-HHmmss)" -Force
    }
    Move-Item $tmp $dest -Force

    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if ($userPath -notlike "*$destDir*") {
        [Environment]::SetEnvironmentVariable('Path', "$userPath;$destDir", 'User')
        Write-Host "rsh: каталог $destDir добавлен в PATH пользователя (переоткрой терминал)."
    }
    Write-Host "rsh: установлен $dest ($banner)"
    Write-Host "rsh: положи %USERPROFILE%\.rsh\{id,id.pub,config.json,.device_token} (скопируй с dev), затем: rsh vps hostname"
} finally {
    if (Test-Path $tmp) { Remove-Item $tmp -Force }
}
