# Contribuir — Masmorra ASCII

Obrigado por considerar ajudar!

## Onde contribuir

| Contexto | Repositório | Notas |
|----------|-------------|-------|
| **Livro + código + catálogo** | Repositório **público** ([masmorra-ascii-dart](https://github.com/kleberandrade/masmorra-ascii-dart)) | Um único clone: Markdown em `livro/`, Dart em `code/`, catálogo em `site/site_catalog.json`. |
| **Site (Flutter, Pages)** | Repositório **privado** do autor | Não é necessário para PRs de livro ou código Dart no repositório público. |

## Texto do livro

- Fontes em `livro/` (capítulos, pré/pós-textual, partes). Ordem em `config/chapters.txt`.
- Build local: [`BOOK.md`](BOOK.md) (`./build.sh`). Normalização opcional: `python3 scripts/normalize_markdown_book.py`.

## Código Dart

- Pacote final: `code/masmorra_ascii/`. Snapshots por capítulo: `code/steps/step-NN/`.
- Detalhes: [`code/README.md`](code/README.md).

## Site e `site_catalog.json`

O site lê **`site/site_catalog.json`** no branch `main` do repositório público (via `raw.githubusercontent.com`). Caminhos atualizados: [`site/RAW_GITHUB_PATHS.md`](site/RAW_GITHUB_PATHS.md).

O catálogo é atualizado com `python3 scripts/generate_catalog.py` ou em PRs; o CI valida alinhamento com [`.github/workflows/validate_site_catalog.yml`](.github/workflows/validate_site_catalog.yml). Os títulos dos capítulos vêm dos H1 dos Markdown; partes e recursos vêm de `site/catalog_meta.json`.

Se alterar **partes** ou **recursos**, atualize `catalog_meta.json` no mesmo PR.

## Antes de abrir um PR

1. **Problema pequeno (typo, README, um teste)?** Pode ir direto a um PR.
2. **Refactor ou nova funcionalidade em Dart?** Abra uma **issue** primeiro: descreva o objetivo e o pacote (`masmorra_ascii` vs `steps/step-NN`).
3. Execute validação no que tocou:
   - Dart: na pasta do pacote, `dart pub get`, `dart analyze`, e `dart test` se existirem testes.
   - Todos os steps: a partir de `code/`, `./scripts/validate_all.sh`.

## Convenções

- Mantenha o estilo existente no código (lints por `analysis_options.yaml` em cada pacote).
- Alinhe commits ou descrição de PR com **capítulos** ou tags **`step-NN`** quando a mudança corresponde a um snapshot do livro.
- Licença: **MIT** — ver [`LICENSE.md`](LICENSE.md). Contribuições assumem a mesma licença.

## Reportar bugs

- No GitHub público: [Issues — masmorra-ascii-dart](https://github.com/kleberandrade/masmorra-ascii-dart/issues).
- Para Dart: indique versão do Dart, comando, pasta (`masmorra_ascii` ou `steps/step-XX`) e mensagem de erro completa.
