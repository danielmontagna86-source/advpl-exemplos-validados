# Contribuindo

Obrigado pelo interesse em melhorar esta skill!

## O que pode ser contribuído aqui

- Melhorias no `SKILL.md` (protocolo, clareza, novos casos de uso)
- Melhorias em `scripts/build-index.py` (extração de símbolos, categorização, tratamento de encoding)
- Correções em `scripts/update-repo.ps1` / `scripts/install-adapters.ps1`
- Documentação (`README.md`, este arquivo)

Abra uma issue ou um pull request descrevendo o problema/melhoria. Como os catálogos em
`references/*.md` são **gerados automaticamente**, não edite esses arquivos à mão — rode
`python scripts/build-index.py` depois de qualquer mudança em `scripts/build-index.py` e inclua os
arquivos regenerados no PR.

## O que NÃO pode ser contribuído aqui

O conteúdo de `assets/repo/` é uma cópia read-only do corpus
[dan-atilio/AdvPL](https://github.com/dan-atilio/AdvPL) (Daniel Atílio — Terminal de Informação),
licenciado sob GPL-3.0. Não aceitamos PRs que adicionem, removam ou modifiquem arquivos dentro de
`assets/repo/` — mudanças no corpus em si (novos exemplos, correções nos fontes) devem ser
propostas diretamente no repositório original. Depois de aceitas lá, rode
`scripts/update-repo.ps1` aqui para trazer a atualização.

## Reportando alucinação que passou pelo protocolo

Se a skill validou um símbolo que na verdade não existe (ou tem assinatura diferente da real), abra
uma issue com o nome do símbolo e o fonte do corpus que a skill apontou como exemplo — isso ajuda a
melhorar a extração de símbolos em `build-index.py`.
