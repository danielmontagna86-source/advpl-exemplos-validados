# update-repo.ps1 - Atualiza o snapshot de dan-atilio/AdvPL e regenera os catalogos.
#
# Diferente da versao interna desta skill, assets/repo/ AQUI nao e um clone git vivo
# (o .git interno nao foi versionado, para nao virar um repositorio dentro do repositorio).
# Este script clona a origem numa pasta temporaria, sincroniza o conteudo para assets/repo/
# e descarta o clone temporario.
#
# Uso: powershell -File update-repo.ps1
$ErrorActionPreference = "Stop"

$skillDir = Split-Path -Parent $PSScriptRoot
$repoDir  = Join-Path $skillDir "assets\repo"
$tmpDir   = Join-Path $env:TEMP ("advpl-exemplos-validados-" + [guid]::NewGuid().ToString("N"))

Write-Host "Clonando https://github.com/dan-atilio/AdvPL em pasta temporaria ..."
git clone --depth 1 https://github.com/dan-atilio/AdvPL $tmpDir
if ($LASTEXITCODE -ne 0) {
    Write-Error "git clone retornou erro ($LASTEXITCODE). Catalogos NAO foram regenerados."
    exit 1
}

Write-Host "Sincronizando conteudo para $repoDir ..."
if (-not (Test-Path $repoDir)) {
    New-Item -ItemType Directory -Force -Path $repoDir | Out-Null
}
# /XF: binarios herdados do repo de origem que nao servem para validacao de API
# e que ninguem quer clonando para dentro de ~\.claude\skills (escapi.dll, .rar, planilhas).
robocopy $tmpDir $repoDir /MIR /XD ".git" /XF "*.dll" "*.exe" "*.rar" "*.zip" "*.xlsx" /NFL /NDL /NJH /NJS /NC /NS
# robocopy usa codigos de saida 0-7 para sucesso; 8+ indica erro real
if ($LASTEXITCODE -ge 8) {
    Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue
    Write-Error "robocopy retornou erro ($LASTEXITCODE). Catalogos NAO foram regenerados."
    exit 1
}

Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue

Write-Host "Regenerando catalogos ..."
python (Join-Path $PSScriptRoot "build-index.py")
if ($LASTEXITCODE -ne 0) {
    Write-Error "build-index.py retornou erro ($LASTEXITCODE)."
    exit 1
}
Write-Host "Concluido."
