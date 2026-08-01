from __future__ import annotations

import json
import subprocess
from pathlib import Path

ROOT = Path.cwd()


def replace(path: str, old: str, new: str) -> None:
    p = ROOT / path
    s = p.read_text(encoding="utf-8-sig")
    if old not in s:
        raise SystemExit(f"Bloco nao encontrado em {path}: {old[:120]!r}")
    p.write_text(s.replace(old, new), encoding="utf-8")


# 1) plugin.json
p = ROOT / ".claude-plugin/plugin.json"
obj = json.loads(p.read_text(encoding="utf-8-sig"))
ordered = {
    "$schema": "https://json.schemastore.org/claude-code-plugin-manifest.json",
    "displayName": "AdvPL — Exemplos Validados",
    "skills": ["./"],
}
ordered.update({k: v for k, v in obj.items() if k not in ordered})
p.write_text(json.dumps(ordered, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

# 2-3) build-index.py
replace("scripts/build-index.py", "from collections import defaultdict", "from collections import Counter, defaultdict")
replace(
    "scripts/build-index.py",
    '    "constructor", "as", "from", "of", "and", "or", "not", "len", "in",',
    '    "constructor", "as", "from", "of", "and", "or", "not", "in",',
)
replace(
    "scripts/build-index.py",
    '''    # nome de exibição: variante mais frequente preservando caixa original
    display = {}
    for rel, d in info.items():
        for c in d["calls"]:
            k = c.lower()
            if k in sym_files and k not in display:
                display[k] = c
''',
    '''    # nome de exibição: variante mais frequente preservando caixa original.
    # Counter + desempate alfabético para que a saída não dependa da ordem de
    # iteração de set (PYTHONHASHSEED), que tornava o arquivo não-determinístico.
    casings = defaultdict(Counter)
    for rel, d in info.items():
        for c in d["calls"]:
            k = c.lower()
            if k in sym_files:
                casings[k][c] += 1
    display = {
        k: min(cnt.items(), key=lambda kv: (-kv[1], kv[0]))[0]
        for k, cnt in casings.items()
    }
''',
)

# 4) SKILL.md
replace("SKILL.md", "~909 funções/classes", "~910 funções/classes")
replace(
    "SKILL.md",
    "| `TCQuery` / `BeginSql` para SELECT | `FWExecStatement` |",
    "| `TCQuery` / `BeginSql` para SELECT | `FWExecStatement` ⚠️ |",
)
replace(
    "SKILL.md",
    "Divisão de trabalho com skills geradoras de estrutura (MVC, REST, pontos de entrada, queries): elas\n",
    "> ⚠️ **Alvos modernos ausentes do corpus.** O corpus é educacional e não cobre toda a API atual.\n"
    "> `FWExecStatement` não aparece em nenhum dos 995 fontes. Símbolos marcados com ⚠️ nesta tabela são\n"
    "> exceção ao passo 5 do protocolo: valide-os no TDN, não no corpus — a ausência aqui não significa\n"
    "> que não existem. (`FWTemporaryTable`, `FWLogMsg`, `FWMsExcel` e `FWRest`, esses sim, estão no corpus.)\n\n"
    "Divisão de trabalho com skills geradoras de estrutura (MVC, REST, pontos de entrada, queries): elas\n",
)
replace(
    "SKILL.md",
    "## Manutenção\n",
    "## Limitações conhecidas\n\n"
    "- Índice gerado por regex sobre chamadas de função, não por parser AdvPL — pode ter falsos negativos\n"
    "  em sintaxes incomuns (xCommands, chamadas via macro `&()`).\n"
    "- Cerca de metade dos símbolos indexados aparece em **um único fonte**. Existência fica bem\n"
    "  estabelecida; confirmação de assinatura, nesses casos, merece uma checagem no TDN.\n"
    "- O corpus valida a API do framework, não o comportamento detalhado de cada função.\n\n"
    "## Manutenção\n",
)

# 5) README.md
replace("README.md", "909 símbolos", "910 símbolos")
replace(
    "README.md",
    "/reload-plugins\n```\n",
    "/reload-plugins\n```\n\n"
    "> O `SKILL.md` fica na raiz do repositório: o Claude Code v2.1.142+ carrega esse layout\n"
    "> automaticamente como plugin de skill única. O `plugin.json` declara `\"skills\": [\"./\"]`\n"
    "> explicitamente, o que também cobre versões anteriores. Para conferir a instalação:\n"
    "> `claude plugin validate ./advpl-exemplos-validados --strict`.\n",
)
marker = "- A tradução de estilo em `SKILL.md` é apenas ilustrativa — ajuste às regras reais do seu projeto.\n"
p = ROOT / "README.md"
s = p.read_text(encoding="utf-8")
if marker not in s:
    raise SystemExit("Marcador README Limitações não encontrado")
p.write_text(
    s.replace(
        marker,
        marker
        + "- Cerca de metade dos 910 símbolos indexados aparece em um único fonte: bom para confirmar\n"
        + "  **existência**, mais fraco para confirmar **assinatura**. Nesses casos, cruze com o TDN.\n"
        + "- Alvos modernos como `FWExecStatement` não aparecem em nenhum fonte — a skill sinaliza esses\n"
        + "  casos com ⚠️ para não bloquear o uso deles.\n"
        + "- O corpus herda binários do repositório original (`escapi.dll`, dois `.rar`, um `.xlsx` de 1,7 MB).\n"
        + "  `scripts/update-repo.ps1` exclui esses arquivos ao sincronizar.\n",
    ),
    encoding="utf-8",
)

# 6) update-repo.ps1
replace(
    "scripts/update-repo.ps1",
    'robocopy $tmpDir $repoDir /MIR /XD ".git" /NFL /NDL /NJH /NJS /NC /NS',
    '# /XF: binarios herdados do repo de origem que nao servem para validacao de API\n'
    '# e que ninguem quer clonando para dentro de ~\\.claude\\skills (escapi.dll, .rar, planilhas).\n'
    'robocopy $tmpDir $repoDir /MIR /XD ".git" /XF "*.dll" "*.exe" "*.rar" "*.zip" "*.xlsx" /NFL /NDL /NJH /NJS /NC /NS',
)

# 7) install-adapters.ps1
p = ROOT / "scripts/install-adapters.ps1"
s = p.read_text(encoding="utf-8-sig")
old = '''#   Os dois parametros podem ser combinados.
param(
    [string]$ClineWorkspace,
    [switch]$CodexGlobal
)
'''
new = '''#   Os dois parametros podem ser combinados.
#
# -StyleRules define as regras de estilo inseridas nos adaptadores. O valor padrao
# abaixo e apenas UM EXEMPLO: corresponde as regras do autor desta skill. Passe as
# regras reais do seu projeto; use -StyleRules "" para omitir a secao de regras.
param(
    [string]$ClineWorkspace,
    [switch]$CodexGlobal,
    [string]$StyleRules = @"
Protheus.ch->TOTVS.ch | ConOut->FWLogMsg | IIF->If/Else | TCQuery/BeginSql->FWExecStatement |
CriaTrab->FWTemporaryTable | HTTPGet/Post->FWRest | sem UI em transação | sem GetMV em loop |
User/Static Function (nunca Function) | sempre D_E_L_E_T_ = ' ' e filtro de filial em query.
"@
)
'''
if old not in s:
    raise SystemExit("Cabeçalho install-adapters.ps1 não encontrado")
s = s.replace(old, new)
old_style = '''## Precedência de estilo

O corpus valida EXISTÊNCIA e ASSINATURA; o estilo do projeto (CLAUDE.md) prevalece SEMPRE:
Protheus.ch->TOTVS.ch | ConOut->FWLogMsg | IIF->If/Else | TCQuery/BeginSql->FWExecStatement |
CriaTrab->FWTemporaryTable | HTTPGet/Post->FWRest | sem UI em transação | sem GetMV em loop |
User/Static Function (nunca Function) | sempre D_E_L_E_T_ = ' ' e filtro de filial em query.

Alguns alvos modernos (ex.: FWExecStatement) NÃO existem no corpus. Ausência aqui não prova
inexistência: valide esses casos no TDN antes de descartar.
'''
if old_style not in s:
    old_style = '''## Precedência de estilo

O corpus valida EXISTÊNCIA e ASSINATURA; o estilo do projeto (CLAUDE.md) prevalece SEMPRE:
Protheus.ch->TOTVS.ch | ConOut->FWLogMsg | IIF->If/Else | TCQuery/BeginSql->FWExecStatement |
CriaTrab->FWTemporaryTable | HTTPGet/Post->FWRest | sem UI em transação | sem GetMV em loop |
User/Static Function (nunca Function) | sempre D_E_L_E_T_ = ' ' e filtro de filial em query.
'''
new_style = '''## Precedência de estilo

O corpus valida EXISTÊNCIA e ASSINATURA; o estilo do projeto (CLAUDE.md) prevalece SEMPRE.
Tabela de tradução em uso (exemplo — ajuste às regras reais do seu time):
$StyleRules

Alguns alvos modernos (ex.: FWExecStatement) NÃO existem no corpus. Ausência aqui não prova
inexistência: valide esses casos no TDN antes de descartar.
'''
if old_style not in s:
    raise SystemExit("Bloco de estilo install-adapters.ps1 não encontrado")
p.write_text(s.replace(old_style, new_style), encoding="utf-8")

# 8) .gitattributes
(ROOT / ".gitattributes").write_text(
    "# O corpus em assets/repo/ e um snapshot read-only em CP1252. Nenhuma conversao\n"
    "# de fim de linha deve ser aplicada no checkout: core.autocrlf=true no Windows\n"
    "# reescreveria os 995 fontes e sujaria qualquer diff de update-repo.ps1.\n"
    "assets/repo/** -text\n\n"
    "# Binarios herdados do corpus original.\n"
    "*.dll  binary\n"
    "*.rar  binary\n"
    "*.xlsx binary\n"
    "*.png  binary\n",
    encoding="utf-8",
)

# Verificações
subprocess.run(
    [
        "python",
        "-c",
        "import json;[json.load(open(f)) for f in ['.claude-plugin/plugin.json','.claude-plugin/marketplace.json']];print('JSON OK')",
    ],
    check=True,
)
first = subprocess.run(["python", "scripts/build-index.py"], check=True, text=True, capture_output=True)
print(first.stdout, end="")
expected = [
    "OK: 995 fontes varridos",
    "  catalogo-fontes.md            : 105 arquivos",
    "  catalogo-maratona.md          : 552 arquivos",
    "  catalogo-exemplos-projetos.md : 338 arquivos",
    "  indice-simbolos.md            : 910 simbolos",
]
for line in expected:
    if line not in first.stdout:
        raise SystemExit(f"Saída esperada ausente: {line}")

idx = (ROOT / "references/indice-simbolos.md").read_text(encoding="utf-8")
if "| `Len` | 216 |" not in idx:
    raise SystemExit("Len com 216 usos não encontrado")
print("LEN OK: 216 usos")

first_norm = "\n".join(line for line in idx.splitlines() if "Gerado por" not in line)
subprocess.run(["python", "scripts/build-index.py"], check=True, stdout=subprocess.DEVNULL)
idx2 = (ROOT / "references/indice-simbolos.md").read_text(encoding="utf-8")
second_norm = "\n".join(line for line in idx2.splitlines() if "Gerado por" not in line)
if first_norm != second_norm:
    raise SystemExit("Índice não determinístico")
print("DETERMINISMO OK")

corpus_status = subprocess.run(
    ["git", "status", "--porcelain", "--", "assets/repo/"],
    check=True,
    text=True,
    capture_output=True,
).stdout
if corpus_status.strip():
    raise SystemExit("assets/repo/ foi alterado")
print("CORPUS OK: sem alterações")
