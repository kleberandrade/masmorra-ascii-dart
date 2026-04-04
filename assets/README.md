# Recursos gráficos — *Masmorra ASCII*

- **`epub-cover.png`** — capa recomendada para EPUB e para a capa integral no PDF (o `00-frontmatter.md` usa `\IfFileExists{assets/epub-cover.png}`).
- **`book-cover.jpg`** — opcional, para marketing ou repositório paralelo.
- **`diagrams/`** — diagramas Mermaid (`.mmd`) e PNG gerados para o livro. O [`scripts/build.sh`](../scripts/build.sh) chama [`scripts/render_mermaid_diagrams.sh`](../scripts/render_mermaid_diagrams.sh) antes do Pandoc; com **Node.js + npx** todos os `.mmd` da pasta são convertidos para `.png`. Sem Node, o build exige que cada PNG referenciado no Markdown já exista (versionado). Ficheiros atuais: `capitulo-021-fluxo-jogo`, `capitulo-036-fsm-transicoes`, `capitulo-037-arquitetura-mvc`, `apendice-b-camadas-rede`.

Sem estes arquivos, o PDF usa a **capa textual** definida no front matter.
