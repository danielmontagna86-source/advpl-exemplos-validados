# install-adapters.ps1 - Instala a regra da skill advpl-exemplos-validados em outras ferramentas de IA.
#
# Uso:
#   powershell -File install-adapters.ps1 -ClineWorkspace "c:\Users\...\Documents\Fontes"
#       -> cria <workspace>\.clinerules\advpl-exemplos-validados.md (Cline / VS Code)
#   powershell -File install-adapters.ps1 -CodexGlobal
#       -> insere/atualiza secao delimitada em ~\.codex\AGENTS.md (OpenAI Codex CLI)
#   Os dois parametros podem ser combinados.
param(
    [string]$ClineWorkspace,
    [switch]$CodexGlobal
)
$ErrorActionPreference = "Stop"

if (-not $ClineWorkspace -and -not $CodexGlobal) {
    Write-Host "Informe -ClineWorkspace <pasta> e/ou -CodexGlobal. Veja o cabecalho do script."
    exit 0
}

$skillDir = Split-Path -Parent $PSScriptRoot
$repoDir  = Join-Path $skillDir "assets\repo"
$refsDir  = Join-Path $skillDir "references"

$regra = @"
# AdvPL — Exemplos Validados (anti-alucinação de API Protheus)

Corpus local com ~995 fontes AdvPL/TLPP reais (github.com/dan-atilio/AdvPL) em:
- Corpus (somente leitura, GPL-3.0): $repoDir
- Índice de símbolos:                $refsDir\indice-simbolos.md
- Catálogos:                          $refsDir\catalogo-fontes.md | catalogo-maratona.md | catalogo-exemplos-projetos.md

## Protocolo obrigatório antes de gerar código AdvPL/TLPP

Para cada função/classe/método do framework Protheus que o código precisar:
1. Procure o símbolo no codebase do projeto (código de produção é a verdade nº 1).
2. Procure no índice de símbolos acima (case-insensitive). Se listado, leia um dos fontes indicados.
3. Se não estiver no índice, faça busca textual direta no corpus ($repoDir).
4. Encontrou -> leia o exemplo e confirme assinatura/ordem de parâmetros ANTES de gerar.
5. Não encontrou em nenhum -> consulte tdn.totvs.com; se ainda não achar, NÃO USE — documente a lacuna. Jamais invente API.

## Precedência de estilo

O corpus valida EXISTÊNCIA e ASSINATURA; o estilo do projeto (CLAUDE.md) prevalece SEMPRE:
Protheus.ch->TOTVS.ch | ConOut->FWLogMsg | IIF->If/Else | TCQuery/BeginSql->FWExecStatement |
CriaTrab->FWTemporaryTable | HTTPGet/Post->FWRest | sem UI em transação | sem GetMV em loop |
User/Static Function (nunca Function) | sempre D_E_L_E_T_ = ' ' e filtro de filial em query.

Nunca edite arquivos do corpus. Encoding dos fontes: CP1252. Não copie arquivos inteiros verbatim (GPL-3.0) — adapte.
"@

$utf8SemBom = New-Object System.Text.UTF8Encoding($false)
$inicio = "<!-- BEGIN advpl-exemplos-validados -->"
$fim    = "<!-- END advpl-exemplos-validados -->"

function Update-SecaoDelimitada([string]$arquivo, [string]$novaSecao) {
    # Substitui (ou acrescenta ao final) a secao delimitada, preservando o restante do arquivo
    $conteudo = ""
    if (Test-Path $arquivo) {
        $conteudo = [System.IO.File]::ReadAllText($arquivo)
        $padrao = "(?s)" + [regex]::Escape($inicio) + ".*?" + [regex]::Escape($fim) + "(\r?\n)?"
        $conteudo = ([regex]::Replace($conteudo, $padrao, "")).TrimEnd()
    }
    if ($conteudo -ne "") {
        $conteudo = $conteudo + "`r`n`r`n" + $novaSecao + "`r`n"
    } else {
        $conteudo = $novaSecao + "`r`n"
    }
    [System.IO.File]::WriteAllText($arquivo, $conteudo, $utf8SemBom)
}

if ($ClineWorkspace) {
    if (-not (Test-Path $ClineWorkspace)) {
        Write-Error "Workspace nao encontrado: $ClineWorkspace"
        exit 1
    }
    $clinePath = Join-Path $ClineWorkspace ".clinerules"
    if (Test-Path $clinePath -PathType Leaf) {
        # Formato arquivo unico (.clinerules e um arquivo): atualiza secao delimitada
        Update-SecaoDelimitada $clinePath ("$inicio`r`n$regra`r`n$fim")
        Write-Host "Cline: secao instalada/atualizada no arquivo $clinePath"
    } else {
        # Formato pasta (.clinerules\*.md)
        New-Item -ItemType Directory -Force -Path $clinePath | Out-Null
        $clineFile = Join-Path $clinePath "advpl-exemplos-validados.md"
        [System.IO.File]::WriteAllText($clineFile, $regra, $utf8SemBom)
        Write-Host "Cline: regra instalada em $clineFile"
    }
}

if ($CodexGlobal) {
    $codexDir  = Join-Path $env:USERPROFILE ".codex"
    New-Item -ItemType Directory -Force -Path $codexDir | Out-Null
    $agentsFile = Join-Path $codexDir "AGENTS.md"
    Update-SecaoDelimitada $agentsFile ("$inicio`r`n$regra`r`n$fim")
    Write-Host "Codex: secao instalada/atualizada em $agentsFile"
}
