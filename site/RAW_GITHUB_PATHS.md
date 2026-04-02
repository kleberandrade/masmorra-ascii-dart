# Caminhos raw no GitHub (para o site masmorra.io)

Após a reestruturação do repositório, os ficheiros do livro e do catálogo estão na **raiz** do repo (não dentro de `livro/` como pasta-mãe).

Substitui `OWNER` e `REPO` pelos valores reais (ex.: `kleberandrade` / `masmorra-ascii-dart`).

## Catálogo

| Antes | Depois |
|--------|--------|
| `.../main/livro/site/site_catalog.json` | `.../main/site/site_catalog.json` |

Exemplo:

`https://raw.githubusercontent.com/OWNER/REPO/main/site/site_catalog.json`

## Recursos Markdown (campo `path` no JSON)

Os valores em `site_catalog.json` são relativos à **raiz do repositório**.

| Antes (exemplo) | Depois |
|-----------------|--------|
| `src/pos-textual/apendice-a-dart-cheatsheet.md` | `livro/pos-textual/apendice-a-dart-cheatsheet.md` |

URL raw típica:

`https://raw.githubusercontent.com/OWNER/REPO/main/livro/pos-textual/apendice-a-dart-cheatsheet.md`

## Links `tree` para código (steps)

| Antes | Depois |
|--------|--------|
| `.../tree/main/livro/code/steps/step-NN` | `.../tree/main/code/steps/step-NN` |

Atualiza no cliente Flutter (ou outro) qualquer constante que monte estes URLs.
