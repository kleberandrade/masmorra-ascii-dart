# Catálogo do site (`site_catalog.json`)

O arquivo [`site_catalog.json`](site_catalog.json) descreve **capítulos**, **partes** e **recursos** do livro para o site Flutter (repositório privado [kleberandrade/masmorra-ascii](https://github.com/kleberandrade/masmorra-ascii)). O URL padrão no código do site aponta para este arquivo no branch `main` do **repositório público** do livro ([kleberandrade/masmorra-ascii-dart](https://github.com/kleberandrade/masmorra-ascii-dart)):

`https://raw.githubusercontent.com/<GITHUB_USER>/<GITHUB_BOOK_REPO>/main/site/site_catalog.json`

Mudança de layout (antigo vs novo): [`RAW_GITHUB_PATHS.md`](RAW_GITHUB_PATHS.md).

## Geração automática

O catálogo é atualizado manualmente com `generate_catalog.py` ou em PRs; o CI valida alinhamento com [`.github/workflows/validate_site_catalog.yml`](../../.github/workflows/validate_site_catalog.yml). Os títulos dos capítulos são extraídos dos cabeçalhos H1 dos arquivos Markdown; partes e recursos vêm de `catalog_meta.json`.

Para gerar manualmente:

```bash
python3 scripts/generate_catalog.py
```

Use `--check` para validar sem alterar o arquivo.

## Contrato para PRs

Se alterar **partes** ou **recursos**, atualize `catalog_meta.json` no mesmo PR. Alterações em capítulos e títulos são detectadas automaticamente pelo CI.

## Desenvolvimento do site

Para desativar o fetch remoto e usar só o asset embutido no Flutter, defina `bookCatalogUrlOverride = '-'` em `SiteConfig` no repositório do site.

## Formato

- `chapters`: lista de títulos (ordem = número do passo no site).
- `chapterSolutionPaths`: lista paralela a `chapters` (mesmo comprimento); cada item é `null` ou caminho relativo à raiz do repo (ex.: `code/solucoes/boss-final-cap01.dart`). Preenchido pelo `generate_catalog.py` a partir de `code/solucoes/boss-final-cap*.dart`.
- `parts`: objetos com `number`, `title`, `description`.
- `resources`: lista de objetos com `title`, `subtitle`, `path`, `iconHint`.
