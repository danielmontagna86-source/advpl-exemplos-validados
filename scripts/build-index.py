#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-index.py — Gera os catálogos da skill advpl-exemplos-validados.

Varre o clone de github.com/dan-atilio/AdvPL em assets/repo/, extrai os blocos
ProtheusDOC, as funções declaradas e os símbolos de framework utilizados, e gera
os 4 arquivos de references/:

  - catalogo-fontes.md            (Fontes/ — utilitários z* por categoria)
  - catalogo-maratona.md          (Maratona de Exemplos/ — por número/tema)
  - catalogo-exemplos-projetos.md (demais pastas)
  - indice-simbolos.md            (índice invertido: símbolo -> arquivos)

Uso:  python build-index.py
Fontes ADVPL são lidos como CP1252 (errors=replace); catálogos gerados em UTF-8.
"""

import re
import sys
from collections import Counter, defaultdict
from datetime import date
from pathlib import Path

SKILL_DIR = Path(__file__).resolve().parents[1]
REPO = SKILL_DIR / "assets" / "repo"
REFS = SKILL_DIR / "references"

SOURCE_EXTS = {".prw", ".tlpp", ".prx", ".prg", ".ch", ".aph"}

# Palavras-chave/declarações AdvPL que não são funções de framework
KEYWORDS = {
    "if", "else", "elseif", "endif", "do", "while", "enddo", "for", "next",
    "to", "step", "exit", "loop", "return", "local", "private", "public",
    "static", "function", "user", "method", "class", "endclass", "wsmethod",
    "wsservice", "wsstruct", "wsrestful", "data", "case", "endcase",
    "otherwise", "begin", "end", "sequence", "transaction", "new", "self",
    "super", "_super", "include", "define", "ifdef", "ifndef", "endime",
    "constructor", "as", "from", "of", "and", "or", "not", "in",
    # cláusulas de xCommands (não são funções)
    "action", "size", "valid", "with", "init", "use", "pixel", "centered",
    "prompt", "when", "title", "message", "object", "status",
}

RE_PDOC = re.compile(r"/\*/\s*\{Protheus\.doc\}\s*(.+)")
RE_DECL = re.compile(
    r"^\s*(?:user\s+function|static\s+function|function|method|class)\s+([A-Za-z_]\w*)",
    re.IGNORECASE,
)
RE_CALL = re.compile(r"(?<![:\w#])([A-Za-z_]\w{1,})\s*\(")
RE_LINECOMMENT = re.compile(r"//.*")
RE_BLOCKCOMMENT = re.compile(r"/\*.*?\*/", re.DOTALL)
RE_STRING = re.compile(r'"[^"]*"|\'[^\']*\'')

# Categorias do catálogo de Fontes/ — a primeira que casar (nome ou descrição) vence
CATEGORIES = [
    ("E-mail", r"mail|smtp|e-?mail"),
    ("Excel e planilhas", r"excel|xls|planilha|fwmsexcel|csv"),
    ("JSON, XML e integração", r"json|xml|soap|rest|http|api|webservice|ws\b|ftp"),
    ("SQL e banco de dados", r"sql|quer|banco|tabela|alias|dbf|topconn|indice|index|reg\b|registro"),
    ("Datas e horas", r"\bdata\b|\bdt\b|date|hora|dia|mes|ano|feriado|util"),
    ("Strings e conversões", r"str|texto|char|palavra|extenso|convert|cpf|cnpj|valid|format|mascara|criptograf|base64|hex"),
    ("Arquivos e diretórios", r"arq|file|dir\b|pasta|copia|copy|txt|pdf|imprim|download|upload"),
    ("Interface e dialogs", r"tela|dialog|form|brow|menu|botao|button|slider|imagem|img|bitmap|painel|panel|grid|combo|check|radio|msg|aviso|pergunt|wizard|login|splash"),
    ("Pedidos, notas e ERP", r"ped|nota|nf\b|sc5|sc6|sd1|sd2|sa1|sa2|sb1|se1|se2|produto|prod|cliente|fornec|estoq|financ|contab|fatur"),
    ("Sistema e jobs", r"job|thread|semaforo|servi|schedule|param|ini\b|ambiente|environ|user|usuario|senha|log\b"),
]


def read_source(path: Path) -> str:
    # O corpus mistura CP1252 e UTF-8. Acentos CP1252 são sequências UTF-8
    # inválidas, então UTF-8 estrito primeiro decide corretamente os dois casos.
    raw = path.read_bytes()
    try:
        return raw.decode("utf-8")
    except UnicodeDecodeError:
        return raw.decode("cp1252", errors="replace")


def demojibake(s: str) -> str:
    """Repara palavras UTF-8 lidas como CP1252 (ex.: 'veÃ­culos' -> 'veículos').

    Alguns fontes do corpus misturam os dois encodings na mesma linha, então o
    reparo é por palavra: só aplica se a palavra reencodada for UTF-8 válido —
    palavras legítimas como 'NÃO' falham no decode e ficam intactas.
    """
    digraphs = {
        "Ã¡": "á", "Ã¢": "â", "Ã£": "ã", "Ã©": "é", "Ãª": "ê", "Ã­": "í",
        "Ã³": "ó", "Ã´": "ô", "Ãµ": "õ", "Ãº": "ú", "Ã§": "ç", "Ã ": "à",
    }

    def fix(w: str) -> str:
        if "Ã" in w or "Â" in w:
            try:
                return w.encode("cp1252").decode("utf-8")
            except (UnicodeEncodeError, UnicodeDecodeError):
                # palavra com encoding misto ('validaçÃµes'): troca só os dígrafos
                for bad, good in digraphs.items():
                    w = w.replace(bad, good)
        return w
    return " ".join(fix(w) for w in s.split(" "))


def strip_code(text: str) -> str:
    """Remove comentários e strings para extração de símbolos chamados."""
    text = RE_BLOCKCOMMENT.sub(" ", text)
    text = RE_LINECOMMENT.sub(" ", text)
    text = RE_STRING.sub('""', text)
    return text


def extract_pdoc(text: str):
    """Retorna lista de (nome, descricao) dos blocos ProtheusDOC."""
    results = []
    lines = text.splitlines()
    for i, line in enumerate(lines):
        m = RE_PDOC.search(line)
        if not m:
            continue
        name = m.group(1).strip()
        name = re.sub(r"^(user\s+function|static\s+function|function|class|method)\s+", "", name, flags=re.IGNORECASE).strip()
        desc_parts = []
        for j in range(i + 1, min(i + 12, len(lines))):
            ln = lines[j].strip()
            if ln.startswith("@") or "/*/" in ln or ln.startswith("*/"):
                break
            if ln:
                desc_parts.append(ln)
        desc = " ".join(desc_parts).strip()
        desc = re.sub(r"\s+", " ", desc)
        desc = demojibake(desc)
        if len(desc) > 160:
            desc = desc[:157] + "..."
        results.append((name, desc))
    return results


def extract_decls(text: str):
    decls = set()
    for line in text.splitlines():
        m = RE_DECL.match(line)
        if m:
            decls.add(m.group(1).lower())
    return decls


def extract_calls(code: str):
    calls = set()
    for m in RE_CALL.finditer(code):
        tok = m.group(1)
        low = tok.lower()
        if low in KEYWORDS or low.startswith("u_") or low.startswith("_"):
            continue
        calls.add(tok)
    return calls


def md_escape(s: str) -> str:
    return s.replace("|", "\\|")


def header(title: str, extra: str = "") -> str:
    return (
        f"# {title}\n\n"
        f"> Gerado por `scripts/build-index.py` em {date.today().isoformat()} — NÃO editar manualmente.\n"
        f"> Corpus: clone de https://github.com/dan-atilio/AdvPL em `assets/repo/`. Caminhos relativos à raiz do clone.\n"
        + (extra + "\n" if extra else "")
        + "\n"
    )


def main():
    if not REPO.is_dir():
        sys.exit(f"ERRO: clone nao encontrado em {REPO}. Rode scripts/update-repo.ps1 primeiro.")
    REFS.mkdir(exist_ok=True)

    files = sorted(
        p for p in REPO.rglob("*")
        if p.is_file() and p.suffix.lower() in SOURCE_EXTS and ".git" not in p.parts
    )

    all_decls = set()          # funções/classes declaradas no corpus
    info = {}                  # rel_path -> dict(pdoc, decls, calls)
    for f in files:
        text = read_source(f)
        rel = f.relative_to(REPO).as_posix()
        pdoc = extract_pdoc(text)
        decls = extract_decls(text)
        calls = extract_calls(strip_code(text))
        all_decls |= decls
        info[rel] = {"pdoc": pdoc, "decls": decls, "calls": calls, "name": f.name}

    # ----------------------------------------------------------- catalogo-fontes
    fontes = {r: d for r, d in info.items() if r.startswith("Fontes/")}
    by_cat = defaultdict(list)
    for rel, d in sorted(fontes.items()):
        desc = d["pdoc"][0][1] if d["pdoc"] else ""
        hay = (Path(rel).stem + " " + desc).lower()
        cat = "Outros utilitários"
        for cname, pat in CATEGORIES:
            if re.search(pat, hay):
                cat = cname
                break
        by_cat[cat].append((rel, desc))

    out = [header(
        "Catálogo — Fontes/ (utilitários z*)",
        f"> {len(fontes)} fontes utilitários prontos, com ProtheusDOC. Leia o arquivo indicado antes de usar/adaptar.",
    )]
    order = [c for c, _ in CATEGORIES] + ["Outros utilitários"]
    for cat in order:
        items = by_cat.get(cat)
        if not items:
            continue
        out.append(f"## {cat}\n")
        out.append("| Fonte | Descrição |")
        out.append("| --- | --- |")
        for rel, desc in items:
            out.append(f"| `{rel}` | {md_escape(desc) or '—'} |")
        out.append("")
    (REFS / "catalogo-fontes.md").write_text("\n".join(out), encoding="utf-8")

    # --------------------------------------------------------- catalogo-maratona
    mar = {r: d for r, d in info.items() if r.startswith("Maratona de Exemplos/")}
    rows = []
    for rel, d in mar.items():
        m = re.match(r"Exemplo_(\d+)_(.+)\.\w+$", Path(rel).name)
        num = int(m.group(1)) if m else 9999
        tema = m.group(2).replace("_", " ") if m else Path(rel).stem
        desc = d["pdoc"][0][1] if d["pdoc"] else ""
        rows.append((num, tema, rel, desc))
    rows.sort()

    out = [header(
        "Catálogo — Maratona de Exemplos (por número e tema)",
        f"> {len(rows)} exemplos curtos e focados (1 conceito por arquivo): operadores, arrays, strings, datas, arquivos, JSON, SQL, transações.",
    )]
    block = None
    for num, tema, rel, desc in rows:
        b = (num - 1) // 50
        if b != block:
            block = b
            out.append(f"\n## Exemplos {b*50+1:03d}–{b*50+50:03d}\n")
            out.append("| Nº | Tema | Fonte | Descrição |")
            out.append("| --- | --- | --- | --- |")
        out.append(f"| {num:03d} | {md_escape(tema)} | `{rel}` | {md_escape(desc) or '—'} |")
    (REFS / "catalogo-maratona.md").write_text("\n".join(out), encoding="utf-8")

    # ----------------------------------------- catalogo-exemplos-projetos
    rest = {r: d for r, d in info.items() if r not in fontes and r not in mar}
    by_folder = defaultdict(list)
    for rel, d in sorted(rest.items()):
        folder = str(Path(rel).parent).replace("\\", "/")
        by_folder[folder].append((rel, d))

    out = [header(
        "Catálogo — Exemplos, Projetos, Ti Responde, NETiZAP e eBook",
        "> Exemplos estruturais (MVC modelos 1/2/3/X, dialogs, pontos de entrada), projetos completos e soluções pontuais.",
    )]
    for folder in sorted(by_folder):
        out.append(f"## {folder}/\n")
        out.append("| Fonte | Funções declaradas | Descrição |")
        out.append("| --- | --- | --- |")
        for rel, d in by_folder[folder]:
            desc = d["pdoc"][0][1] if d["pdoc"] else ""
            decls = ", ".join(sorted(d["decls"]))[:80] or "—"
            out.append(f"| `{Path(rel).name}` | {md_escape(decls)} | {md_escape(desc) or '—'} |")
        out.append("")
    (REFS / "catalogo-exemplos-projetos.md").write_text("\n".join(out), encoding="utf-8")

    # ------------------------------------------------------------ indice-simbolos
    sym_files = defaultdict(set)
    for rel, d in info.items():
        for c in d["calls"]:
            if c.lower() in all_decls:      # declarado no próprio corpus = não é framework
                continue
            sym_files[c.lower()].add(rel)

    # nome de exibição: variante mais frequente preservando caixa original.
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

    out = [header(
        "Índice de símbolos — função/classe de framework → fontes que a utilizam",
        "> Uso: antes de usar uma função/classe do Protheus, procure-a aqui (busca case-insensitive). "
        "Se estiver listada, leia um dos fontes para confirmar assinatura e uso real. "
        "Se NÃO estiver aqui, procure no codebase do projeto e no TDN antes de usar — pode não existir.",
    )]
    out.append(f"Total de símbolos distintos: **{len(sym_files)}** em {len(files)} fontes.\n")
    letter = None
    for key in sorted(sym_files):
        frefs = sorted(sym_files[key])
        first = key[0].upper()
        if first != letter:
            letter = first
            out.append(f"\n## {letter}\n")
            out.append("| Símbolo | Usos | Exemplos (até 4) |")
            out.append("| --- | --- | --- |")
        shown = ", ".join(f"`{r}`" for r in frefs[:4])
        out.append(f"| `{display[key]}` | {len(frefs)} | {shown} |")
    (REFS / "indice-simbolos.md").write_text("\n".join(out), encoding="utf-8")

    print(f"OK: {len(files)} fontes varridos")
    print(f"  catalogo-fontes.md            : {len(fontes)} arquivos")
    print(f"  catalogo-maratona.md          : {len(rows)} arquivos")
    print(f"  catalogo-exemplos-projetos.md : {len(rest)} arquivos")
    print(f"  indice-simbolos.md            : {len(sym_files)} simbolos")


if __name__ == "__main__":
    main()
