#!/usr/bin/env python3
"""Gera site/site_catalog.json a partir dos fontes do repositório.

Capítulos são extraídos automaticamente dos H1 dos arquivos Markdown.
Caminhos de solução Boss Final vêm de code/solucoes/boss-final-cap*.dart.
Partes e recursos vêm de site/catalog_meta.json (curadoria manual).

Uso (a partir da raiz do repositório):
    python3 scripts/generate_catalog.py
    python3 scripts/generate_catalog.py --check
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
CHAPTERS_DIR = REPO_ROOT / "livro" / "capitulos"
META_PATH = REPO_ROOT / "site" / "catalog_meta.json"
OUTPUT_PATH = REPO_ROOT / "site" / "site_catalog.json"

H1_RE = re.compile(r"^#\s+(.+?)(?:\s*\{[^}]*\})?\s*$")
BOSS_FINAL_RE = re.compile(r"^boss-final-cap(\d+)\.dart$")
SOLUTIONS_DIR = REPO_ROOT / "code" / "solucoes"


def extract_chapter_title(path: Path) -> str:
    """Extrai o título H1 da primeira linha do capítulo."""
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            m = H1_RE.match(line)
            if m:
                return m.group(1).strip()
            break
    return path.stem.replace("-", " ").title()


def collect_chapters() -> list[str]:
    """Coleta títulos de todos os capítulos, ordenados por nome de arquivo."""
    files = sorted(CHAPTERS_DIR.glob("capitulo-*.md"))
    if not files:
        print(f"ERRO: nenhum capítulo encontrado em {CHAPTERS_DIR}", file=sys.stderr)
        sys.exit(1)
    return [extract_chapter_title(f) for f in files]


def collect_solution_paths(n_chapters: int) -> list[str | None]:
    """Uma entrada por capítulo: caminho relativo ao repo ou None se não houver solução."""
    out: list[str | None] = [None] * n_chapters
    if not SOLUTIONS_DIR.is_dir():
        return out
    for f in sorted(SOLUTIONS_DIR.glob("boss-final-cap*.dart")):
        m = BOSS_FINAL_RE.match(f.name)
        if not m:
            continue
        cap = int(m.group(1))
        if cap < 1 or cap > n_chapters:
            continue
        idx = cap - 1
        rel = f.relative_to(REPO_ROOT).as_posix()
        out[idx] = rel
    return out


def load_meta() -> dict:
    """Carrega metadados curados (parts + resources)."""
    if not META_PATH.exists():
        print(f"ERRO: {META_PATH} não encontrado", file=sys.stderr)
        sys.exit(1)
    with open(META_PATH, encoding="utf-8") as f:
        return json.load(f)


def validate(
    chapters: list[str],
    meta: dict,
    chapter_solution_paths: list[str | None],
) -> list[str]:
    """Valida consistência entre capítulos, partes e paths de solução."""
    errors: list[str] = []
    parts = meta.get("parts", [])
    total = len(chapters)

    if len(chapter_solution_paths) != total:
        errors.append(
            f"chapterSolutionPaths tem {len(chapter_solution_paths)} entradas, "
            f"esperado {total} (igual a chapters)"
        )
    else:
        for i, p in enumerate(chapter_solution_paths):
            if p is None:
                continue
            full = REPO_ROOT / p
            if not full.is_file():
                errors.append(
                    f"chapterSolutionPaths[{i}] (cap. {i + 1}): ficheiro inexistente: {p}"
                )

    for p in parts:
        first = p.get("firstChapter", 0)
        last = p.get("lastChapter", 0)
        if first < 1 or last > total or first > last:
            errors.append(
                f"Parte {p['number']} ({p['title']}): "
                f"range {first}–{last} inválido (total: {total} capítulos)"
            )

    covered = set()
    for p in parts:
        for c in range(p["firstChapter"], p["lastChapter"] + 1):
            if c in covered:
                errors.append(f"Capítulo {c} pertence a mais de uma parte")
            covered.add(c)

    expected = set(range(1, total + 1))
    missing = expected - covered
    if missing:
        errors.append(f"Capítulos sem parte: {sorted(missing)}")

    for r in meta.get("resources", []):
        rpath = REPO_ROOT / r["path"]
        if not rpath.exists():
            errors.append(f"Recurso não encontrado: {r['path']}")

    return errors


def build_catalog(
    chapters: list[str],
    meta: dict,
    chapter_solution_paths: list[str | None],
) -> dict:
    """Monta o catálogo final."""
    parts_out = []
    for p in meta["parts"]:
        parts_out.append({
            "number": p["number"],
            "title": p["title"],
            "subtitle": p["subtitle"],
            "description": p["description"],
        })
    return {
        "chapters": chapters,
        "chapterSolutionPaths": chapter_solution_paths,
        "parts": parts_out,
        "resources": meta.get("resources", []),
    }


def main() -> None:
    check_mode = "--check" in sys.argv

    chapters = collect_chapters()
    meta = load_meta()
    solution_paths = collect_solution_paths(len(chapters))

    errors = validate(chapters, meta, solution_paths)
    if errors:
        print("Erros de validação:", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        sys.exit(1)

    catalog = build_catalog(chapters, meta, solution_paths)
    catalog_json = json.dumps(catalog, ensure_ascii=False, indent=2) + "\n"

    if check_mode:
        if OUTPUT_PATH.exists():
            current = OUTPUT_PATH.read_text(encoding="utf-8")
            if current == catalog_json:
                print("site_catalog.json está atualizado.")
                sys.exit(0)
            else:
                print(
                    "site_catalog.json está desatualizado! "
                    "Rode: python3 scripts/generate_catalog.py",
                    file=sys.stderr,
                )
                sys.exit(1)
        else:
            print(f"{OUTPUT_PATH} não existe.", file=sys.stderr)
            sys.exit(1)

    OUTPUT_PATH.write_text(catalog_json, encoding="utf-8")
    n_sol = sum(1 for p in solution_paths if p is not None)
    print(f"Gerado {OUTPUT_PATH} ({len(chapters)} capítulos, {n_sol} soluções, "
          f"{len(meta['parts'])} partes, {len(meta.get('resources', []))} recursos)")


if __name__ == "__main__":
    main()
