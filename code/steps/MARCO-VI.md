# MARCO VI — Síntese (Capítulo 36)

Texto de encerramento do percurso do livro. O **código executável completo** está no pacote [`masmorra_ascii`](../masmorra_ascii/README.md) (irmão de `steps/` em `code/`), não na pasta `step-36` (marcador de capítulo).

Parabéns por chegares ao final. O que segue descreve o que construíste ao longo do livro e o que o jogo final agrega.

## O que construíste

- Capítulos 1–5: fundamentos Dart
- Capítulos 6–10: controlo de fluxo
- Capítulos 11–14: OOP e herança
- Capítulos 15–21: dungeon crawl e exploração
- Capítulos 22–27: economia, loja, progressão, boss final
- Capítulos 28–32: refatoração, testes, save/load, HUD
- Capítulos 33–35: padrões (Strategy, Command, Factory, Observer, State)
- Capítulo 36: síntese e polimento final

## Arquitectura alvo (conceito)

```
LoopJogo (orquestrador central)
├─ EstadoJogo (dados)
├─ MapaMasmorra (dungeon)
├─ Jogador (herói)
├─ List<Inimigo> (adversários com IA FSM)
├─ List<Item> (loot)
├─ BarramentoEventos (reações desacopladas)
├─ GerenciadorSalve (persistência JSON)
└─ TelaAscii (renderização polida)
```

## Padrões de desenho (resumo)

- **Strategy:** estratégias de IA intercambiáveis
- **Command:** acções com histórico / undo
- **Factory:** criação centralizada de inimigos
- **Observer:** eventos e reacções desacopladas
- **State:** máquinas de estado para IA

## Jogar a versão de referência

A partir da raiz do repositório:

```bash
cd code/masmorra_ascii
dart pub get
dart lib/main.dart
dart test
dart analyze
```

## Próximos passos sugeridos

- **Flutter:** UI móvel ou Web em cima da mesma lógica
- **Shelf / rede:** API, saves remotos, leaderboard
- **Pub.dev:** publicar bibliotecas reutilizáveis
- **Gameplay:** mais classes, magias, NPCs, eventos procedurais

## Recursos

- [Dart](https://dart.dev/guides)
- [Flutter](https://flutter.dev)
- [Game Programming Patterns](https://gameprogrammingpatterns.com)

---

Bem-vindo ao outro lado.
