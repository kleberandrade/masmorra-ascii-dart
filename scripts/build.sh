#!/bin/bash
set -e

# Raiz do repositório (Markdown em livro/, config/, code/, site/, scripts/)
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

PYTHON="python3"
if [ -x "$REPO_ROOT/.venv/bin/python3" ]; then
  PYTHON="$REPO_ROOT/.venv/bin/python3"
fi

ensure_python_docx() {
  if "$PYTHON" -c "from docx import Document" 2>/dev/null; then
    return 0
  fi
  local venv="$REPO_ROOT/.venv"
  if [ ! -x "$venv/bin/python3" ]; then
    echo " Criando venv em .venv (python-docx; PEP 668 bloqueia pip no Python do sistema)..."
    python3 -m venv "$venv"
  fi
  echo " Instalando python-docx no venv do repositório..."
  "$venv/bin/pip" install -q python-docx
  PYTHON="$venv/bin/python3"
}

CONFIG_DIR="config"
BOOK_SRC_DIR="livro"
OUTPUT_DIR="output"
METADATA="$CONFIG_DIR/metadata.yaml"
PREAMBLE="$CONFIG_DIR/preamble.tex"
STYLESHEET="$CONFIG_DIR/style.css"
# Nome dos artefactos em output/ (PDF/EPUB versionados no Git; ver .gitignore)
BOOK_NAME="masmorra-ascii-dart"
CHAPTERS_FILE="$CONFIG_DIR/chapters.txt"
# Tema de syntax highlight — zenburn (escuro) para PDF, tango (claro) para EPUB/DOCX
# Pandoc 3.x: --syntax-highlighting substitui --highlight-style (deprecado).
SYNTAX_PDF="zenburn"
SYNTAX_EPUB="tango"

mkdir -p "$OUTPUT_DIR"

echo "Rendering Mermaid diagrams (assets/diagrams)..."
bash "$REPO_ROOT/scripts/render_mermaid_diagrams.sh"

echo "Regenerating site catalog (site/site_catalog.json)..."
"$PYTHON" "$REPO_ROOT/scripts/generate_catalog.py"

if [ -f "$CHAPTERS_FILE" ]; then
    echo "Generating book from chapters file: $CHAPTERS_FILE"
    INPUT_ARGS=()
    while IFS= read -r line || [ -n "$line" ]; do
        [ -z "$line" ] && continue
        INPUT_ARGS+=("$line")
    done < "$CHAPTERS_FILE"
else
    CHAPTERS=$(ls "$BOOK_SRC_DIR"/*.md | sort -V)
    echo "Generating book from: $CHAPTERS"
    INPUT_ARGS=($CHAPTERS)
fi

if [ ${#INPUT_ARGS[@]} -eq 0 ]; then
    echo " No input files found. Check $CHAPTERS_FILE or $BOOK_SRC_DIR/*.md"
    exit 1
fi

echo "Generating PDF..."
pandoc "${INPUT_ARGS[@]}" \
    --metadata-file="$METADATA" \
    --include-in-header="$PREAMBLE" \
    --syntax-highlighting="$SYNTAX_PDF" \
    --pdf-engine=xelatex \
    --top-level-division=chapter \
    --toc-depth=1 \
    --resource-path="assets:livro/capitulos:livro/pre-textual:livro/partes:livro/pos-textual" \
    -V fontsize=11pt \
    -V classoption=twoside \
    -o "$OUTPUT_DIR/$BOOK_NAME.pdf"

if [ $? -eq 0 ]; then
    echo " PDF generated: $OUTPUT_DIR/$BOOK_NAME.pdf"
else
    echo " Error generating PDF"
fi

echo "Generating EPUB..."
EPUB_INPUT_ARGS=()
for f in "${INPUT_ARGS[@]}"; do
  [[ "$f" == *"01b-sumario.md" ]] && continue
  EPUB_INPUT_ARGS+=("$f")
done

pandoc "${EPUB_INPUT_ARGS[@]}" \
    --metadata-file="$METADATA" \
    --template="$CONFIG_DIR/default.epub3" \
    --syntax-highlighting="$SYNTAX_EPUB" \
    --metadata toc-title="Sumário" \
    --css="$STYLESHEET" \
    --epub-title-page=false \
    --toc \
    --toc-depth=2 \
    --resource-path="assets:livro/capitulos:livro/pre-textual:livro/partes:livro/pos-textual" \
    --file-scope \
    -o "$OUTPUT_DIR/$BOOK_NAME.epub"

if [ $? -eq 0 ]; then
    "$PYTHON" "scripts/fix_epub_spine.py" "$OUTPUT_DIR/$BOOK_NAME.epub" || {
         echo "Warning: Could not run spine fix script."
    }
    echo " EPUB generated: $OUTPUT_DIR/$BOOK_NAME.epub"
else
    echo " Error generating EPUB"
fi

echo "Generating DOCX..."
pydocx_ref="$OUTPUT_DIR/reference.docx"
echo "Preparing DOCX reference styles..."
ensure_python_docx
"$PYTHON" "scripts/make_reference_docx.py" "$pydocx_ref" || {
    echo " Error generating DOCX reference styles: $pydocx_ref"
    exit 1
}
DOCX_INPUT_ARGS=()
for f in "${INPUT_ARGS[@]}"; do
  [[ "$f" == *"01b-sumario.md" ]] && continue
  DOCX_INPUT_ARGS+=("$f")
done

pandoc "${DOCX_INPUT_ARGS[@]}" \
    --metadata-file="$METADATA" \
    --syntax-highlighting="$SYNTAX_EPUB" \
    --metadata toc-title="Sumário" \
    --toc \
    --toc-depth=3 \
    --resource-path="assets:livro/capitulos:livro/pre-textual:livro/partes:livro/pos-textual" \
    --reference-doc="$pydocx_ref" \
    --lua-filter="scripts/docx_first_paragraph.lua" \
    -o "$OUTPUT_DIR/$BOOK_NAME.docx"

if [ $? -eq 0 ]; then
    echo " DOCX generated: $OUTPUT_DIR/$BOOK_NAME.docx"
else
    echo " Error generating DOCX"
fi

echo "Done!"
