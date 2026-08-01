---
name: advpl-exemplos-validados
description: "Corpus local de ~995 fontes AdvPL/TLPP reais e validados (github.com/dan-atilio/AdvPL — Terminal de Informação) para validar existência, assinatura e uso real de funções/classes do framework Protheus antes de gerar código, evitando alucinação de APIs. Use ao gerar QUALQUER código AdvPL/TLPP com APIs não confirmadas, ou quando o usuário disser 'exemplo real', 'como usar a função X', 'essa função existe?', 'validar função/classe', 'mostra um fonte que usa X'."
license: "Skill: MIT. Corpus em assets/repo: GPL-3.0 (dan-atilio/AdvPL)"
metadata:
  domain: Protheus
  author: Daniel Montagna (corpus por Daniel Atílio — Terminal de Informação)
  version: '1.0.0'
  category: Reference / Anti-hallucination
---

# AdvPL — Exemplos Validados (corpus dan-atilio/AdvPL)

## Visão Geral

Corpus local com **~995 fontes AdvPL/TLPP reais, compiláveis e testados** do repositório
[github.com/dan-atilio/AdvPL](https://github.com/dan-atilio/AdvPL) (Daniel Atílio — Terminal de
Informação), incluído em `assets/repo/`. Serve como **fonte de validação de símbolos e sintaxe**:
antes de gerar código que usa uma função, classe ou método do framework Protheus, confirme aqui
que o símbolo existe em código real e veja como é usado de verdade.

Alucinação de API (usar função/classe que não existe) é a causa nº 1 de `Cannot find method` e
`Class not found` em runtime. Este corpus + o codebase do seu projeto eliminam a necessidade de
"presumir" que uma API existe.

## Quando Usar

- Antes de gerar qualquer código AdvPL/TLPP que use API de framework ainda não confirmada no codebase
- Quando precisar da **assinatura real** (ordem/tipo de parâmetros) de uma função nativa
- Quando o usuário pedir "exemplo real de X", "como se usa a classe Y", "essa função existe?"
- Durante migração/refatoração, para validar que um símbolo legado realmente existe
- Como uma camada extra de validação, entre a documentação interna do seu projeto e o TDN

---

## Protocolo Anti-Alucinação (workflow central)

Para CADA símbolo de framework (função, classe, método) que o código a gerar precisa:

1. **Codebase do seu projeto primeiro** — grep no seu próprio código de produção. Código já em
   produção no seu projeto é a verdade nº 1 (já segue as convenções do seu time).
2. **Índice de símbolos** — procure o símbolo em [references/indice-simbolos.md](references/indice-simbolos.md)
   (busca case-insensitive). Se listado, ele existe: leia um dos fontes indicados.
3. **Grep no corpus** — se não estiver no índice (índice cobre chamadas de função; métodos e
   constantes não), grep direto em `assets/repo/` (ex.: `grep -ri "FWTemporaryTable" assets/repo --include=*.prw --include=*.tlpp`).
4. **Encontrou** → leia o exemplo inteiro (ou a função relevante) e confirme assinatura, ordem de
   parâmetros e padrão de uso ANTES de gerar. Cite o fonte de origem no código gerado se útil.
5. **Não encontrou em nenhum** → consulte o TDN (tdn.totvs.com). Se ainda assim não achar,
   **NÃO USE o símbolo** — documente a lacuna e pergunte ao usuário. Jamais invente.

> Leitura dos fontes do corpus: são CP1252 (alguns UTF-8). Tolere acentos corrompidos na leitura,
> ou leia com uma ferramenta que suporte esse encoding — NUNCA edite nem re-salve arquivos de
> `assets/repo/` (corpus é somente leitura).

---

## Arquivos de Referência (progressive disclosure)

| Referência | Quando ler | Conteúdo |
| --- | --- | --- |
| [references/indice-simbolos.md](references/indice-simbolos.md) | **Sempre** que precisar validar um símbolo de framework | Índice invertido: ~910 funções/classes → fontes que as usam (com contagem de usos) |
| [references/catalogo-fontes.md](references/catalogo-fontes.md) | Precisa de um **utilitário pronto** (e-mail, Excel, FTP, validação, arquivos, SQL→Excel...) | 105 funções `z*` completas com ProtheusDOC, agrupadas por categoria |
| [references/catalogo-maratona.md](references/catalogo-maratona.md) | Precisa de exemplo **focado em 1 conceito** (operador, função de array/string/data, classe visual) | 552 exemplos numerados `Exemplo_NNN_Tema.prw` |
| [references/catalogo-exemplos-projetos.md](references/catalogo-exemplos-projetos.md) | Precisa de exemplo **estrutural**: MVC (modelos 1/2/3/X), dialogs, pontos de entrada, integração WhatsApp, projetos completos | 338 fontes de Exemplos/, Projetos/, Ti Responde/, NETiZAP/ e eBook/ |

Caminhos dos catálogos são relativos à raiz desta skill: `<pasta desta skill>/assets/repo/`.

---

## ⚠️ Precedência de Estilo — corpus NÃO manda no estilo

Os exemplos do corpus são **educacionais** (2015–2024) e podem usar padrões que seu projeto
considera legado ou proibidos por regras de qualidade (SonarQube, guia de estilo interno etc.). A
regra de precedência é absoluta:

- **Corpus = verdade para**: existência do símbolo, assinatura, ordem de parâmetros, sintaxe de uso.
- **Regras do seu projeto = verdade para**: estilo, padrões obrigatórios, convenções de qualidade.

Ao adaptar um exemplo do corpus, **traduza sempre** os padrões legados para os padrões atuais do
seu projeto. Exemplo ilustrativo de como essa tradução costuma ser (ajuste para as regras reais do
seu time — isto NÃO é uma lista fixa, é só um exemplo de tipo de tradução a se fazer):

| Padrão comum no corpus (legado/educacional) | Exemplo de padrão moderno equivalente |
| --- | --- |
| `#Include "Protheus.ch"` | `#Include "TOTVS.ch"` |
| `ConOut()` / `?` para log | `FWLogMsg()` |
| `IIF(cond, a, b)` | `If/Else/EndIf` explícito |
| `TCQuery` / `BeginSql` para SELECT | `FWExecStatement` ⚠️ |
| Query com valores concatenados | Query parametrizada |
| `CriaTrab()` / `MSCREATE()` / `DBCREATE()` | `FWTemporaryTable` |
| `HTTPGet()` / `HTTPPost()` / `HTTPQuote()` | `FWRest` |
| `Function Xxx()` em customização | `User Function` (pública) ou `Static Function` |

> ⚠️ **Alvos modernos ausentes do corpus.** O corpus é educacional e não cobre toda a API atual.
> `FWExecStatement` não aparece em nenhum dos 995 fontes. Símbolos marcados com ⚠️ nesta tabela são
> exceção ao passo 5 do protocolo: valide-os no TDN, não no corpus — a ausência aqui não significa
> que não existem. (`FWTemporaryTable`, `FWLogMsg`, `FWMsExcel` e `FWRest`, esses sim, estão no corpus.)

Divisão de trabalho com skills geradoras de estrutura (MVC, REST, pontos de entrada, queries): elas
geram a **estrutura**; esta skill **valida os símbolos** e fornece **uso real**. Use as duas juntas.

---

## Destaques do Corpus

- **Utilitários prontos** (`Fontes/`): `zEnvMail.prw` (e-mail com anexos), `zQry2Excel.prw`
  (query→Excel), `zExcel2DBF.prw`, `zFTPEnv.prw`, `zPrettyXML.prw`, `zGerDanfe.prw`,
  `zRecurDir.prw`, `zCriaPar.prw` (cria SX6), `zVldGrid.prw`
- **MVC completo** (`Exemplos/MVC/`): `zMVCMd1.prw` (Modelo 1), `zMVCMd3.prw` (Modelo 3
  master-detail), `zMVCMdX.prw` (Modelo X com 3 entidades)
- **Pontos de entrada** (`Exemplos/Pontos de Entrada/`, `Exemplos/Vídeo Aulas/`): incluindo EPs em MVC
- **Classes visuais** (Maratona 400+): TDialog, TButton, FWBrowse, FWMsExcel, FWChartBar, TBitmap
- **Integração** (`NETiZAP/`): consumo de API REST (WhatsApp) de ponta a ponta

## Limitações conhecidas

- Índice gerado por regex sobre chamadas de função, não por parser AdvPL — pode ter falsos negativos
  em sintaxes incomuns (xCommands, chamadas via macro `&()`).
- Cerca de metade dos símbolos indexados aparece em **um único fonte**. Existência fica bem
  estabelecida; confirmação de assinatura, nesses casos, merece uma checagem no TDN.
- O corpus valida a API do framework, não o comportamento detalhado de cada função.

## Manutenção

- **Atualizar corpus**: `scripts/update-repo.ps1` (baixa a versão mais recente de dan-atilio/AdvPL
  e regenera os catálogos)
- **Regenerar catálogos**: `python scripts/build-index.py` (nunca editar `references/*.md` na mão)
- **Instalar em outras ferramentas** (Cline, Codex): `scripts/install-adapters.ps1`

## Licença do Corpus

O conteúdo de `assets/repo/` é GPL-3.0 (© Daniel Atílio, github.com/dan-atilio/AdvPL). Use como
**referência de aprendizado e validação de API**. Ao gerar código para os seus próprios fontes
proprietários, **adapte** o padrão de uso conforme as regras do seu projeto — não copie arquivos
inteiros verbatim.
