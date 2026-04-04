# masmorra_ascii

Pacote Dart de apoio ao livro **Masmorra ASCII**.

Este é o **projeto de referência completo e executável**: exploração MUD, masmorra em grade, save/load e testes. Os snapshots por capítulo estão em `steps/step-XX/` (no mesmo repositório, sob `code/`); o **step-36** no livro não duplica aqui o código — usa este pacote como solução final (também ligada no site como “solução final”).

## Requisitos

- Dart SDK **3.11+**

## Executar

```bash
# A partir desta pasta (ou `code/masmorra_ascii` na raiz do repositório):
dart pub get
dart lib/main.dart
```

## Percurso mínimo (garantir que “está tudo a funcionar”)

1. `dart pub get` e `dart analyze` (sem erros).
2. `dart lib/main.dart` — escreve um nome quando pedido.
3. Menu: **1** Explorar — vês HUD, descrição da sala, prompt `> `.
4. Comandos úteis: `olhar`, `n` / `s` / `e` / `o`, `inventario`, `equipar punhal`, `atacar` (onde houver inimigo), `loja`, `comprar …`, `vender 0` (índice da lista).
5. Vai ao **portão** (`n` desde a praça, conforme o mapa em `world_data.dart`) e escreve `descer` — entras na **grade**; move com `n/s/e/o` ou `w/x/d/a`; recolhe `G`; sai pela célula `*`.
6. Escreve `menu` na exploração ou na masmorra para voltar ao menu principal; **3** guarda, **4** carrega `masmorra_save.json`.

Se `dart` não for reconhecido no terminal, instala ou atualiza o SDK em [dart.dev](https://dart.dev) (ou usa o Dart que vem com Flutter) e volta a abrir o terminal.

## O que o programa faz (visão geral)

- Banner em texto (`StringBuffer`, Cap. 6) e **menu** principal (0–4).
- **Exploração** estilo MUD: salas com saídas, `loja` / `comprar` / `vender`, **combate** contra inimigos selados, comando `descer` no portão para a **masmorra em grade** (`DungeonMap`, RNG com semente).
- **Guardar / carregar** JSON (`masmorra_save.json`, Cap. 26) — opções 3 e 4 do menu.
- **Stream** `GameSession.eventos` para observadores (Cap. 31).

## Testes

```bash
dart test
```

Inclui `test/ascii_screen_test.dart`, `test/parser_test.dart` (Cap. 24) e `test/shop_test.dart` (venda com arma equipada).

## Convenção de versões por capítulo

| Etiquetas | Parte do livro |
|-----------|----------------|
| `step-01` … `step-07` | Parte I |
| `step-08` … `step-14` | Parte II |
| `step-15` … `step-22` | Parte III |
| `step-23` … `step-27` | Parte IV |
| `step-28` … `step-34` | Parte V |

Podes usar **uma etiqueta por capítulo** (`step-01` … `step-34`).

## API principal

- **`GameSession`** — orquestra menu, exploração, masmorra, save/load.
- **`AsciiScreen`** — grade de caracteres (`clear`, `write`, `drawBox`).
- **`DungeonMap.gerar`** — masmorra procedural simples.
- **`analisarLinha` / `GameCommand`** — parser MUD.
