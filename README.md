# Masmorra ASCII — Aprenda Dart construindo um roguelike no terminal

Material de um livro que ensina **Dart** na prática: cada capítulo avança um jogo **roguelike em ASCII** que corre no terminal — do primeiro `print` a um MUD com masmorra em grelha, persistência e padrões de código.

## Sobre o livro

O método é **aprender fazendo**. O texto guia conceitos (sintaxe, tipos, classes, coleções, assincronia, testes, arquitetura) e o **código acompanhante** mostra o estado do jogo ao fim de cada capítulo. Assim consegues comparar o teu progresso com snapshots coerentes com a narrativa.

O jogo é apresentado em **arte ASCII** e **interface textual**: mapas, combate, loja e ecrãs no terminal, sem motor gráfico — ideal para focar na linguagem e na lógica.

A pasta `code/steps/step-NN/` corresponde ao fim do **capítulo NN**; o pacote `code/masmorra_ascii/` é a **solução final** executável (o destino natural depois de percorreres o livro). Quem já programa noutras linguagens pode usar o livro como rampa para Dart; quem está a começar beneficia do percurso linear e dos exercícios implícitos em cada etapa.

## O que está neste repositório

Este é o repositório **público** do livro. Aqui vivem:

- a **fonte do livro** em Markdown (pasta `livro/`: capítulos, pré-textual, pós-textual, partes), compilável para PDF, EPUB e DOCX com Pandoc;
- todo o **código Dart** citado e evolutivo (`masmorra_ascii` + `steps`);
- o **catálogo JSON** (`site/site_catalog.json`) que o site **[masmorra.io](https://masmorra.io)** consome para listar capítulos, partes e recursos (via `raw.githubusercontent.com` neste repositório).

## Estrutura do repositório

Na **raiz**:

- [`CONTRIBUTING.md`](CONTRIBUTING.md) — como contribuir
- [`LICENSE.md`](LICENSE.md) — licença MIT
- [`requirements.txt`](requirements.txt) — dependências Python do build (DOCX)
- [`BOOK.md`](BOOK.md) — build do livro, scripts e ficheiros principais

Árvore principal:

```
livro/                # capítulos e material pré/pós-textual (Markdown)
code/                 # código Dart do livro
├── masmorra_ascii/   # projeto final executável
├── steps/step-NN/    # estado do código ao fim de cada capítulo
└── scripts/          # validação (ex.: validate_all.sh)
site/                 # site_catalog.json, catalog_meta.json
scripts/              # build Pandoc, catálogo, normalização Markdown
config/               # metadata.yaml, chapters.txt, estilos LaTeX/CSS
output/               # PDF/EPUB finais versionados (masmorra-ascii-dart.pdf/.epub); DOCX e resto ignorados pelo Git
assets/               # imagens e recursos do livro
.github/workflows/    # CI: validação do catálogo
```

## Requisitos (resumo)

| Ferramenta | Para quê |
|------------|----------|
| [Pandoc](https://pandoc.org/) | Juntar Markdown e gerar PDF, EPUB, DOCX |
| XeLaTeX (distribuição TeX) | PDF com tipografia e Unicode |
| Python 3 + [`requirements.txt`](requirements.txt) | Geração do `reference.docx` (pacote `python-docx`) usado pelo alvo DOCX |
| [Dart SDK](https://dart.dev/get-dart) | Opcional para correr ou validar o código em `code/` |

Detalhes de versões e comandos por pacote: [`BOOK.md`](BOOK.md) e [`code/README.md`](code/README.md).

## Build do livro (PDF, EPUB, DOCX)

O DOCX depende de `python-docx`. Recomenda-se um virtualenv na raiz do repositório (o script de build usa `.venv/bin/python3` automaticamente se existir):

```bash
python3 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

A partir da raiz:

```bash
./scripts/build.sh
```

Saídas em `output/`. Para variantes de build (por exemplo sem PDF/XeLaTeX em ambientes minimalistas), vê [`BOOK.md`](BOOK.md).

## Site e catálogo

O site público **[masmorra.io](https://masmorra.io)** consome este repositório: lê `site/site_catalog.json` no branch `main` (URL raw no GitHub). O código do site (Flutter) está no repositório [masmorra-ascii](https://github.com/kleberandrade/masmorra-ascii).

**Migração de URLs:** se o site ainda apontava para `.../main/livro/site/site_catalog.json` ou prefixava caminhos com `livro/src/`, atualiza para [`site/RAW_GITHUB_PATHS.md`](site/RAW_GITHUB_PATHS.md).

- **Atualizar o JSON:** `python3 scripts/generate_catalog.py` (ou inclui as alterações num PR). Partes e recursos manuais ficam em `site/catalog_meta.json` — vê [`site/README.md`](site/README.md).
- **CI:** o workflow [`.github/workflows/validate_site_catalog.yml`](.github/workflows/validate_site_catalog.yml) **valida** que o número de ficheiros `capitulo-*.md`, de pastas `step-NN` e de entradas no catálogo coincidem; **não** regera o ficheiro sozinho.

## Contribuir

O guia completo está em [`CONTRIBUTING.md`](CONTRIBUTING.md) (texto do livro, Dart e catálogo).

## Documentação

- [`BOOK.md`](BOOK.md) — build, scripts e ficheiros principais do livro
- [`code/README.md`](code/README.md) — Dart, `masmorra_ascii` e steps
- [`code/steps/README.md`](code/steps/README.md) — índice dos steps por capítulo
- [`site/README.md`](site/README.md) — contrato do catálogo e geração

## Licença

Licença [MIT](LICENSE.md). Projeto de código aberto por [Kleber de Oliveira Andrade](https://kleberandrade.dev/).
