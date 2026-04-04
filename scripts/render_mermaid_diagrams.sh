#!/usr/bin/env bash
# Gera PNGs a partir de diagramas Mermaid (.mmd) para o livro (Pandoc PDF/EPUB/DOCX).
# Requisito: Node.js com npx (usa @mermaid-js/mermaid-cli sob demanda).
# Se npx não existir, usa os PNGs já versionados em assets/diagrams/ (Opção A do livro).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIAG_DIR="$REPO_ROOT/assets/diagrams"

mkdir -p "$DIAG_DIR"

shopt -s nullglob
MMD_FILES=("$DIAG_DIR"/*.mmd)
shopt -u nullglob

if [[ ${#MMD_FILES[@]} -eq 0 ]]; then
  echo " Error: no .mmd files in $DIAG_DIR" >&2
  exit 1
fi

render_one() {
  local mmd="$1"
  local png="${mmd%.mmd}.png"
  echo "Rendering Mermaid: $mmd -> $png"
  # -b white: fundo legível em PDF A5; -w 1400: largura útil para impressão
  # O binário do pacote é invocado diretamente pelo npx (não usar "mmdc" extra).
  npx -y @mermaid-js/mermaid-cli -i "$mmd" -o "$png" -b white -w 1400
  echo " PNG updated: $png"
}

if command -v npx >/dev/null 2>&1; then
  for mmd in "${MMD_FILES[@]}"; do
    render_one "$mmd"
  done
  exit 0
fi

missing=()
for mmd in "${MMD_FILES[@]}"; do
  png="${mmd%.mmd}.png"
  if [[ ! -f "$png" ]]; then
    missing+=("$png")
  fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
  echo " Error: npx not found and missing PNG(s):" >&2
  printf '  %s\n' "${missing[@]}" >&2
  echo " Install Node.js to render from .mmd, or add the PNGs to the repo." >&2
  exit 1
fi

echo "Warning: npx not found; using existing PNGs in $DIAG_DIR. Install Node.js to regenerate from .mmd." >&2
exit 0
