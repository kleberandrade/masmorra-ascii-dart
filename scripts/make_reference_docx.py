#!/usr/bin/env python3
"""
Gera um reference.docx para o Pandoc, para que o DOCX fique mais próximo do PDF.

Motivação:
- O PDF usa `config/preamble.tex` (XeLaTeX) com tipografia (DejaVu Serif / TeX Gyre Heros, corpo 10pt), margens A5,
  espaçamento 1,5, recuo de parágrafo etc.
- O DOCX, sem `--reference-doc`, usa estilos padrão do Word e fica bem diferente.

Este script cria um DOCX "de referência" (somente estilos) e deve ser usado em:
  pandoc ... --reference-doc=output/reference.docx ...
"""

from __future__ import annotations

import sys
from pathlib import Path

from docx import Document
from docx.enum.style import WD_STYLE_TYPE
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Mm, Pt, RGBColor


def _set_style_font(style, name: str, size_pt: float | None = None, *, small_caps: bool = False, bold: bool | None = None):
    font = style.font
    font.name = name
    # Garante que o Word aplique a fonte também em caracteres "East Asia".
    try:
        style.element.rPr.rFonts.set(qn("w:eastAsia"), name)
    except Exception:
        # Alguns estilos podem não expor rPr como esperado; seguir sem falhar.
        pass
    if size_pt is not None:
        font.size = Pt(size_pt)
    font.small_caps = small_caps
    if bold is not None:
        font.bold = bold


def _ensure_paragraph_style(doc: Document, name: str, base: str | None = None):
    styles = doc.styles
    if name in styles:
        return styles[name]
    s = styles.add_style(name, WD_STYLE_TYPE.PARAGRAPH)
    if base and base in styles:
        s.base_style = styles[base]
    return s


def _set_paragraph_style_shading(style, fill_hex: str) -> None:
    """Fundo de parágrafo (ex.: blocos de código estilo terminal). fill_hex sem '#'."""
    p_pr = style.element.get_or_add_pPr()
    shd = OxmlElement("w:shd")
    shd.set(qn("w:fill"), fill_hex)
    shd.set(qn("w:val"), "clear")
    p_pr.append(shd)


def _ensure_character_style(doc: Document, name: str, base: str | None = None):
    styles = doc.styles
    if name in styles:
        return styles[name]
    s = styles.add_style(name, WD_STYLE_TYPE.CHARACTER)
    if base and base in styles:
        s.base_style = styles[base]
    return s


def build_reference_docx(out_path: Path) -> None:
    doc = Document()

    # Página A5 (148mm × 210mm) e margens aproximadas do PDF.
    # No PDF há inner/outer + bindingoffset. No DOCX, aproximamos com left/right.
    section = doc.sections[0]
    section.page_width = Mm(148)
    section.page_height = Mm(210)
    section.top_margin = Mm(25)
    section.bottom_margin = Mm(20)
    section.left_margin = Mm(25)   # 20mm + ~5mm de "binding"
    section.right_margin = Mm(15)

    styles = doc.styles

    # Normal / corpo do texto (Georgia no Word ≈ PDF; 1,5, justificado, recuo 0,6cm).
    normal = styles["Normal"]
    _set_style_font(normal, "Georgia", 10)
    pf = normal.paragraph_format
    pf.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    pf.first_line_indent = Cm(0.6)   # ~1,5em em 10pt
    pf.space_before = Pt(0)
    pf.space_after = Pt(0)
    pf.line_spacing = 1.5

    # Primeiro parágrafo após título: sem recuo (imitando LaTeX).
    first_para = _ensure_paragraph_style(doc, "First Paragraph", base="Normal")
    fp = first_para.paragraph_format
    fp.first_line_indent = Cm(0)
    fp.space_before = Pt(0)
    fp.space_after = Pt(0)
    fp.line_spacing = 1.5

    # Heading 1 (H1): capítulo.
    h1 = styles["Heading 1"]
    _set_style_font(h1, "Georgia", 15, small_caps=True, bold=False)
    h1pf = h1.paragraph_format
    h1pf.alignment = WD_ALIGN_PARAGRAPH.CENTER
    h1pf.space_before = Pt(0)
    h1pf.space_after = Pt(12)
    h1pf.keep_with_next = True
    h1pf.page_break_before = True

    # Heading 2 (H2): "título real" do capítulo (no PDF é alinhado à direita).
    h2 = styles["Heading 2"]
    _set_style_font(h2, "Georgia", 13, bold=True)
    h2pf = h2.paragraph_format
    h2pf.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    h2pf.space_before = Pt(6)
    h2pf.space_after = Pt(16)
    h2pf.keep_with_next = True

    # Heading 3 (H3): subseções internas.
    h3 = styles["Heading 3"]
    _set_style_font(h3, "Georgia", 10, bold=True)
    h3pf = h3.paragraph_format
    h3pf.alignment = WD_ALIGN_PARAGRAPH.LEFT
    h3pf.space_before = Pt(12)
    h3pf.space_after = Pt(6)
    h3pf.keep_with_next = True

    # Bloco de citação (blockquote): 9pt, alinhado ao PDF (`preamble.tex`).
    # O Pandoc costuma mapear para "Block Quote".
    for quote_style_name in ("Block Quote", "Quote"):
        if quote_style_name in styles:
            qs = styles[quote_style_name]
            _set_style_font(qs, "Georgia", 9, bold=False)
            qpf = qs.paragraph_format
            qpf.left_indent = Cm(0.6)
            qpf.right_indent = Cm(0.6)
            qpf.first_line_indent = Cm(0)
            qpf.space_before = Pt(8)
            qpf.space_after = Pt(8)
            qpf.line_spacing = 1.2

    # Código:
    # - Blocos (```): Pandoc costuma usar o estilo de parágrafo "Source Code".
    # - Inline (`code`): Pandoc costuma usar estilo de caractere "Verbatim Char".
    #
    # Criamos explicitamente (mesmo se não existir no DOCX base) para garantir.
    source_code = _ensure_paragraph_style(doc, "Source Code", base="Normal")
    _set_style_font(source_code, "Courier New", 8)
    scpf = source_code.paragraph_format
    scpf.first_line_indent = Cm(0)
    scpf.space_before = Pt(8)
    scpf.space_after = Pt(8)
    scpf.line_spacing = 1.0
    _set_paragraph_style_shading(source_code, "0D0D0D")
    source_code.font.color.rgb = RGBColor(0xE8, 0xE8, 0xE8)

    verbatim_char = _ensure_character_style(doc, "Verbatim Char")
    _set_style_font(verbatim_char, "Courier New", 8)

    # Alguns templates usam "Code" como estilo de caractere. Criar também.
    code_char = _ensure_character_style(doc, "Code")
    _set_style_font(code_char, "Courier New", 8)

    # Não precisamos de conteúdo; o importante é o styles.xml.
    out_path.parent.mkdir(parents=True, exist_ok=True)
    doc.save(out_path.as_posix())


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print("Uso: make_reference_docx.py <caminho_output.docx>", file=sys.stderr)
        return 2
    out_path = Path(argv[1]).expanduser().resolve()
    build_reference_docx(out_path)
    print(f" reference DOCX gerado: {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
