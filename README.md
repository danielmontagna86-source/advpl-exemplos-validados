# advpl-exemplos-validados

Skill do [Claude Code](https://code.claude.com) que valida, contra ~995 fontes AdvPL/TLPP reais e
compiláveis, se uma função ou classe do framework Protheus realmente existe **antes** de a IA gerar
código que a usa — evitando o erro clássico de `Cannot find method` / `Class not found` causado por
alucinação de API.

## O problema

Pedir para uma IA generativa escrever ADVPL/TLPP é diferente de pedir Python ou JavaScript. O
Protheus tem milhares de funções e classes proprietárias, pouco representadas nos dados de treino
públicos. O resultado mais comum é a IA **inventar uma função** que parece plausível mas não existe
— e o erro só aparece no compilador ou, pior, em runtime no ambiente do cliente.

## A solução

Esta skill mantém um corpus local com **~995 fontes reais** do repositório aberto
[dan-atilio/AdvPL](https://github.com/dan-atilio/AdvPL) (Daniel Atílio — Terminal de Informação) e
obriga o agente a seguir um protocolo de validação antes de usar qualquer símbolo de framework:

1. Existe no codebase do seu projeto? (verdade nº 1)
2. Existe no índice de símbolos do corpus (`references/indice-simbolos.md`)?
3. Se não, busca textual direta no corpus.
4. Achou → lê o fonte inteiro, confirma assinatura e ordem dos parâmetros **antes** de gerar.
5. Não achou em lugar nenhum → não usa. Documenta a lacuna. Nunca inventa.

Uma regra importante: o corpus manda na **existência** do símbolo, nunca no **estilo** — os fontes
são educacionais (2015–2024) e podem usar padrões que seu projeto considera legado. Veja a seção
"Precedência de estilo" em [SKILL.md](SKILL.md) para os detalhes.

## Estrutura do repositório

```
advpl-exemplos-validados/
├── .claude-plugin/
│   ├── marketplace.json      # catálogo do plugin (para /plugin install)
│   └── plugin.json           # manifesto do plugin
├── SKILL.md                  # instruções principais (o que Claude lê)
├── references/                # catálogos gerados automaticamente
│   ├── indice-simbolos.md     #   909 símbolos de framework -> fontes que os usam
│   ├── catalogo-fontes.md     #   105 utilitários prontos, por categoria
│   ├── catalogo-maratona.md   #   552 exemplos curtos, 1 conceito por arquivo
│   └── catalogo-exemplos-projetos.md  # 338 exemplos estruturais (MVC, EPs, integrações)
├── scripts/
│   ├── build-index.py         # gera os 4 arquivos de references/ a partir do corpus
│   ├── update-repo.ps1        # atualiza o corpus e regenera os catálogos
│   └── install-adapters.ps1   # replica o protocolo para Cline e Codex CLI
└── assets/
    └── repo/                   # corpus (snapshot de dan-atilio/AdvPL, GPL-3.0, somente leitura pelos agentes)
```

## Instalação

Escolha uma das formas abaixo.

### 1. Manual (mais simples, funciona em qualquer versão do Claude Code)

```bash
git clone https://github.com/danielmontagna86-source/advpl-exemplos-validados ~/.claude/skills/advpl-exemplos-validados
```

No Windows (PowerShell):

```powershell
git clone https://github.com/danielmontagna86-source/advpl-exemplos-validados "$env:USERPROFILE\.claude\skills\advpl-exemplos-validados"
```

Sem git, também funciona baixar o ZIP do repositório e extrair a pasta para
`~/.claude/skills/advpl-exemplos-validados/` (o `SKILL.md` precisa ficar direto dentro dessa
pasta, sem outro nível de subpasta no meio).

Reinicie o Claude Code (ou aguarde a detecção automática de mudanças) e pergunte
`quais skills estão disponíveis?` para confirmar que ela carregou.

### 2. Via plugin marketplace (recomendado — dá atualização automática)

Dentro do Claude Code:

```
/plugin marketplace add danielmontagna86-source/advpl-exemplos-validados
/plugin install advpl-exemplos-validados@advpl-exemplos-validados
/reload-plugins
```

Para atualizar depois:

```
/plugin marketplace update advpl-exemplos-validados
/plugin update advpl-exemplos-validados@advpl-exemplos-validados
```

### 3. Claude Desktop

No painel **Customize → Skills**, use a opção de adicionar um plugin pessoal e informe o caminho do
repositório GitHub (`danielmontagna86-source/advpl-exemplos-validados`).

## Uso

Depois de instalada, a skill é carregada automaticamente pelo Claude quando a conversa envolve
gerar ou validar código AdvPL/TLPP. Também pode ser consultada diretamente perguntando coisas como:

- "essa função existe no Protheus? `FWTemporaryTable`"
- "me mostra um exemplo real de MVC Modelo 3"
- "como se usa a classe `FWMsExcel`?"

## Manutenção — mantendo o corpus atualizado

O corpus incluído neste repositório é um **snapshot** do repositório original. Para atualizar com
os fontes mais recentes de `dan-atilio/AdvPL` e regenerar os catálogos:

```powershell
powershell -File scripts/update-repo.ps1
```

O script baixa a versão atual do repositório de origem, sincroniza o conteúdo em `assets/repo/` e
roda `scripts/build-index.py` para regerar os 4 arquivos de `references/`. Requer `git` e `python`
no PATH.

## Créditos e licença

Este repositório combina dois componentes com licenças diferentes:

| Componente | Licença | Autor |
| --- | --- | --- |
| A skill em si (`SKILL.md`, `scripts/`, `references/`, esta documentação) | [MIT](LICENSE) | Daniel Montagna |
| Corpus de exemplos (`assets/repo/`) | [GPL-3.0](assets/repo/LICENSE) | Daniel Atílio — [Terminal de Informação](http://terminaldeinformacao.com) |

O corpus é derivado de **[github.com/dan-atilio/AdvPL](https://github.com/dan-atilio/AdvPL)** e é
mantido como somente leitura pelos agentes. Este snapshot recebeu apenas normalização de whitespace,
sem alteração de lógica ou conteúdo funcional dos exemplos. Todo o crédito pelos ~995 fontes, anos
de conteúdo educacional AdvPL/TLPP e pela série "Maratona de Exemplos" é do Daniel Atílio. Se esta
skill for útil para você, considere dar uma estrela no
[repositório original](https://github.com/dan-atilio/AdvPL) também.

## Contribuindo

Veja [CONTRIBUTING.md](CONTRIBUTING.md). Resumo: PRs na skill (protocolo, scripts, documentação) são
bem-vindos; mudanças no corpus (`assets/repo/`) devem ser propostas no repositório original.

## Limitações

- O índice de símbolos é gerado por análise de texto (regex sobre chamadas de função), não por um
  parser AdvPL completo — pode ter falsos negativos em sintaxes incomuns.
- O corpus é educacional: cobre bem a API do framework, mas não substitui a documentação oficial
  (TDN) para comportamento detalhado de cada função.
- A tradução de estilo em `SKILL.md` é apenas ilustrativa — ajuste às regras reais do seu projeto.
