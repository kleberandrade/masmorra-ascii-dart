# Livro — Masmorra ASCII

Markdown, Pandoc, PDF (XeLaTeX), EPUB e DOCX.

O site Flutter (**masmorra.io**) é um repositório à parte; este repositório público fornece o texto e o `site/site_catalog.json`. URLs raw: [`site/RAW_GITHUB_PATHS.md`](site/RAW_GITHUB_PATHS.md).

## Build

**Diagramas Mermaid (PDF/EPUB/DOCX):** vários capítulos e o Apêndice B usam PNGs em `assets/diagrams/`, gerados a partir dos ficheiros `.mmd` homónimos por [`scripts/render_mermaid_diagrams.sh`](scripts/render_mermaid_diagrams.sh) (invocado no início de [`scripts/build.sh`](scripts/build.sh)). Exemplos: capítulos 21 e 36–37, `apendice-b-camadas-rede`. Para **regenerar** os PNGs é necessário **Node.js** com `npx` (o script executa `npx -y @mermaid-js/mermaid-cli …` para cada `.mmd`). Se não houver Node, o build continua desde que cada PNG referenciado já exista no repositório (versionado).

**Catálogo do site:** o [`scripts/build.sh`](scripts/build.sh) chama em seguida [`scripts/generate_catalog.py`](scripts/generate_catalog.py), que reescreve `site/site_catalog.json` com base nos capítulos, steps e soluções no disco. Depois de adicionar capítulos ou ficheiros em `code/solucoes/`, convém correr `./scripts/build.sh` (ou só o script Python) e **commitar** o JSON atualizado; o CI valida com `generate_catalog.py --check`.

**Dependência Python (DOCX):** o alvo DOCX usa [`scripts/make_reference_docx.py`](scripts/make_reference_docx.py), que precisa do pacote `python-docx`. O [`scripts/build.sh`](scripts/build.sh) usa `python3` do sistema ou, se existir, `.venv/bin/python3` na **raiz do repositório**. Recomendado:

```bash
# na raiz do repositório
python3 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

Os restantes scripts de build (EPUB, `fix_epub_spine.py`) usam só a biblioteca padrão do Python.

A partir da **raiz do repositório**:

```bash
./scripts/build.sh
```

Saídas em `output/`. No Git, só `masmorra-ascii-dart.pdf` e `masmorra-ascii-dart.epub` são versionados; DOCX e outros ficheiros em `output/` ficam ignorados (ver `.gitignore`).

## Arquivos principais

- `site/site_catalog.json` — catálogo para o site (capítulos e partes); regenerado por `build.sh` / `scripts/generate_catalog.py`; o CI valida com `--check`; ver [`site/README.md`](site/README.md)
- `config/chapters.txt` — ordem dos arquivos Markdown
- `config/metadata.yaml`, `preamble.tex`, `style.css`
- `livro/` — capítulos e material pré/pós-textual
- `code/` — código Dart (`masmorra_ascii`, `steps/step-NN`, `scripts/validate_all.sh`); ver [`code/README.md`](code/README.md); contribuição: [`CONTRIBUTING.md`](CONTRIBUTING.md)

## Scripts Python

A partir da raiz do repositório:

```bash
python3 scripts/normalize_markdown_book.py
```
