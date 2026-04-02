#!/usr/bin/env python3
"""Normaliza Markdown: * * * -> ***; fences ``` sem lang -> ```text ou ```dart."""
from __future__ import annotations

import re
import sys
from pathlib import Path

BOX = set("╔╗╚╝║═╠╣╦╩┌┐└┘│─┼")


def is_probably_dart(body: str) -> bool:
    s = body.strip()
    if not s:
        return False
    head = s[:4000]
    if "void main" in head:
        return True
    if re.search(r"^\s*import\s+['\"]", head, re.M):
        return True
    if re.search(r"^\s*(abstract\s+)?class\s+\w+", head, re.M):
        return True
    if re.search(r"^\s*enum\s+\w+", head, re.M):
        return True
    if re.search(r"^\s*typedef\s+", head, re.M):
        return True
    if re.search(r"^\s*extension\s+\w+", head, re.M):
        return True
    if re.search(r"^\s*@\w+", head, re.M):
        return True
    if re.search(r"^\s*(final|var|const|late)\s+\w+\s*=", head, re.M):
        return True
    if re.search(r"^\s*///", head, re.M) or re.search(r"^\s*//[^/]", head, re.M):
        return True
    if re.search(r"^\s*(for|while)\s*\(", head, re.M):
        return True
    if re.search(r"^\s*return\s+", head, re.M):
        return True
    if "{" in head and (";" in head or "=>" in head) and re.search(
        r"^\s*(print|stdout\.|stdin\.)\s*\(", head, re.M
    ):
        return True
    return False


def is_probably_terminal_or_plaintext(body: str) -> bool:
    s = body
    if any(c in s for c in BOX):
        return True
    if "Comando>" in s or ("Comando:" in s and "W/A/S" in s):
        return True
    if "Posição:" in s and "HP:" in s:
        return True
    if re.search(r"(?i)execução esperada|estado do jogo|mapa da masmorra", s):
        return True
    if re.search(r"^\[[ x]\]\s", s, re.M):
        return True
    if re.search(r"^Você (se moveu|entra|saiu|caminha|olha)", s, re.M):
        return True
    if re.search(r"^>\s*[a-z]", s, re.M):
        return True
    if "════" in s or "══════" in s:
        return True
    return False


def is_probably_bash(body: str) -> bool:
    s = body.strip()
    if not s:
        return False
    lines = [ln.strip() for ln in s.splitlines() if ln.strip()]
    if not lines:
        return False
    if lines[0].startswith("#!"):
        return True
    if re.match(r"^\$\s+\S", s, re.M):
        return True
    if re.match(r"^%\s+\S", s, re.M):
        return True
    hits = sum(
        1
        for ln in lines[:12]
        if re.match(
            r"^(cd|dart|flutter|git|mkdir|export|source|\./)[\s/]", ln, re.I
        )
    )
    return hits >= 2


def classify_bare_fence(body: str) -> str:
    if is_probably_dart(body):
        return "dart"
    if is_probably_bash(body):
        return "bash"
    if is_probably_terminal_or_plaintext(body):
        return "text"
    s = body.strip()
    if not s:
        return "text"
    if s.startswith("{") and s.endswith("}") and "\n" not in s[:200]:
        return "json"
    if re.match(r"^[\w.-]+:\s*(\S|$)", s, re.M) and "dependencies:" in s:
        return "yaml"
    if ";" in s and "{" in s and "(" in s:
        return "dart"
    return "text"


def process_content(text: str) -> str:
    lines = text.splitlines(keepends=True)
    out: list[str] = []
    i = 0
    n = len(lines)

    while i < n:
        line = lines[i]
        if line.strip() == "* * *":
            nl = "\n" if line.endswith("\n") else ""
            out.append("***" + nl)
            i += 1
            continue

        stripped = line.strip()
        if not stripped.startswith("```"):
            out.append(line)
            i += 1
            continue

        tail = stripped[3:].strip()
        if tail.startswith("{="):
            out.append(line)
            i += 1
            while i < n and lines[i].strip() != "```":
                out.append(lines[i])
                i += 1
            if i < n:
                out.append(lines[i])
                i += 1
            continue

        if tail != "":
            out.append(line)
            i += 1
            while i < n and lines[i].strip() != "```":
                out.append(lines[i])
                i += 1
            if i < n:
                out.append(lines[i])
                i += 1
            continue

        i += 1
        body_lines: list[str] = []
        while i < n and lines[i].strip() != "```":
            body_lines.append(lines[i])
            i += 1
        body = "".join(body_lines)
        lang = classify_bare_fence(body)
        nl = "\n" if line.endswith("\n") else ""
        out.append(f"```{lang}{nl}")
        out.extend(body_lines)
        if i < n:
            out.append(lines[i])
            i += 1
        else:
            out.append("```\n")

    return "".join(out)


def main(argv: list[str]) -> int:
    root = Path(__file__).resolve().parents[1] / "livro"
    if not root.is_dir():
        print("livro/ não encontrado", file=sys.stderr)
        return 1
    paths = sorted(root.rglob("*.md"))
    changed = 0
    for path in paths:
        old = path.read_text(encoding="utf-8")
        new = process_content(old)
        if new != old:
            path.write_text(new, encoding="utf-8", newline="\n")
            changed += 1
            print(path.relative_to(root.parent))
    print(f"Arquivos alterados: {changed}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
