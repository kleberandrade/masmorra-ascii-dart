# Código acompanhante: Masmorra ASCII

Cada pasta `step-XX` corresponde ao estado do código ao final do capítulo XX.

## Solução final executável (`masmorra_ascii`)

O **jogo completo** de referência (MUD + masmorra em grade, testes, save/load) está em [`../masmorra_ascii/`](../masmorra_ascii/README.md), não em `step-36`. A pasta `step-36` marca o capítulo 36 no livro; o código runnable final usa o pacote `masmorra_ascii` (irmão desta pasta em `code/`) — o mesmo destino do link “solução final” no site.

```bash
cd ../masmorra_ascii
dart pub get
dart lib/main.dart
```

Os steps **29–35** contêm trechos evolutivos (testes, persistência, padrões); o **29–36** em detalhe narrativo: [STEPS-29-36.md](STEPS-29-36.md). Encerramento do percurso: [MARCO-VI.md](MARCO-VI.md).

## Como usar

Entra na pasta do step desejado e corre (ajusta o comando se o `pubspec` expuser outro executável):

```bash
cd step-01
dart pub get
dart lib/main.dart
```

Guias rápidos: [QUICKSTART-15-21.md](QUICKSTART-15-21.md) · [QUICKSTART-29-36.md](QUICKSTART-29-36.md).

**Requisitos:** Dart compatível com cada `pubspec.yaml` (os steps 29+ pedem tipicamente Dart 3.11+; `masmorra_ascii` usa SDK ^3.5 — ver o respetivo arquivo).

## Estrutura dos steps

| Step | Capitulo | O que funciona |
|------|----------|----------------|
| step-01 | Cap 1: Primeiro programa | Banner do jogo no terminal |
| step-02 | Cap 2: Conversando com o terminal | Input do jogador, menu interativo |
| step-03 | Cap 3: Decisoes e repeticoes | Menu com opcoes, loops |
| step-04 | Cap 4: Null safety | Tratamento seguro de null |
| step-05 | Cap 5: Colecoes | Salas como Map, inventario |
| step-06 | Cap 6: Arte ASCII e StringBuffer | HUD formatado, molduras |
| step-07 | Cap 7: Game loop | Aventura textual completa (MARCO I) |
| step-08 | Cap 8: Classes | Jogador e Sala como objetos |
| step-09 | Cap 9: Construtores | Encapsulamento, factory constructors |
| step-10 | Cap 10: Heranca | Inimigo abstrato, subclasses |
| step-11 | Cap 11: Mixins | Combatente, Curavel, Envenenavel |
| step-12 | Cap 12: Enums e parser | Comandos tipados, switch exaustivo |
| step-13 | Cap 13: Inventario | Armas, armaduras, equipar |
| step-14 | Cap 14: Combate | Sistema de combate por turnos (MARCO II) |
| step-15 | Cap 15: Grid 2D | Mapa com tiles, movimento WASD |
| step-16 | Cap 16: TelaAscii | Renderizador separado, MVC |
| step-17 | Cap 17: Aleatoriedade | Random, seeds, Roller |
| step-18 | Cap 18: Geracao procedural | Masmorras geradas automaticamente |
| step-19 | Cap 19: Campo de visao | FOV, nevoa de guerra |
| step-20 | Cap 20: Entidades | Inimigos, itens e escadas no mapa |
| step-21 | Cap 21: Dungeon crawl | Exploracao completa (MARCO III) |
| step-22 | Cap 22: Economia | Drops, precos, balanceamento |
| step-23 | Cap 23: Loja | Mercador com UI ASCII |
| step-24 | Cap 24: Eventos | Sistema de eventos com generics |
| step-25 | Cap 25: Progressao | XP, niveis, habilidades |
| step-26 | Cap 26: Boss | Multiplos andares, boss final |
| step-27 | Cap 27: Dungeon run | Jogo completo (MARCO IV) |
| step-28 | Cap 28: Refatoracao | Codigo organizado em pastas |
| step-29 | Cap 29: Testes | Suite de testes unitarios |
| step-30 | Cap 30: Persistencia | Save/load com JSON |
| step-31 | Cap 31: Organizacao | Projeto Dart profissional |
| step-32 | Cap 32: Golden tests | HUD polido, testes visuais (MARCO V) |
| step-33 | Cap 33: Strategy/Command | IA com estrategias |
| step-34 | Cap 34: Factory/Observer | Eventos reativos |
| step-35 | Cap 35: State machines | Inimigos com estados |
| step-36 | Cap 36: Sintese | Marco VI no livro; código final em `masmorra_ascii/` |

## Compilar e validar

Dentro de cada `step-XX/`:

```bash
dart pub get
dart analyze
dart format .
dart lib/main.dart  # programa principal de cada step
dart test      # a partir do step-29, quando existirem testes
```

Para percorrer todos os steps: [`../scripts/validate_all.sh`](../scripts/validate_all.sh) (a partir da pasta `code/` na raiz do repositório).
