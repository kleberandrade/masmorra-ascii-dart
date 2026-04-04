# Índice de Soluções - Boss Final Exercises

## Resumo

Este diretório contém **37 soluções implementadas** para os Boss Final exercises de todos os capítulos do livro *Masmorra ASCII em Dart*.

Cada solução é um arquivo Dart executável que demonstra:
- Código funcional com Dart 3 e null safety
- Comentários explicativos em PT-BR
- Nomes de variáveis/classes/funções em português
- Extensões práticas dos conceitos do capítulo

## Soluções por Parte

### Parte I — Fundamentos (Capítulos 1–7)

| Arquivo | Capítulo | Tema |
|---------|----------|------|
| `boss-final-cap01.dart` | 1 — Seu primeiro programa Dart | Arte ASCII de Portal Mágico |
| `boss-final-cap02.dart` | 2 — Conversando com o terminal | Diálogo com NPC |
| `boss-final-cap03.dart` | 3 — Decisões e repetições | Painel de Estatísticas Finais |
| `boss-final-cap04.dart` | 4 — Null safety | Cadeia de Null Safety |
| `boss-final-cap05.dart` | 5 — Coleções | Mapa de adjacência |
| `boss-final-cap06.dart` | 6 — Arte ASCII e StringBuffer | Tela de Game Over Épica |
| `boss-final-cap07.dart` | 7 — O game loop | Sistema de diálogo com NPC |

### Parte II — Orientação a Objetos (Capítulos 8–14)

| Arquivo | Capítulo | Tema |
|---------|----------|------|
| `boss-final-cap08.dart` | 8 — Classes | Classe MundoTexto |
| `boss-final-cap09.dart` | 9 — Construtores e encapsulamento | Padrão Copy-With |
| `boss-final-cap10.dart` | 10 — Herança | Integração de combate ao game loop |
| `boss-final-cap11.dart` | 11 — Mixins | Múltiplos Mixins e resolução de conflito |
| `boss-final-cap12.dart` | 12 — Enums e parser | ComandoFala com argumentos |
| `boss-final-cap13.dart` | 13 — Ouro, Armas e Inventário | Sistema de Loja |
| `boss-final-cap14.dart` | 14 — Combate por turnos | Poções dinâmicas |

### Parte III — Sistemas de Jogo (Capítulos 15–27)

| Arquivo | Capítulo | Tema |
|---------|----------|------|
| `boss-final-cap15.dart` | 15 — Da Sala ao Tile | Campo de Visão (FOV) |
| `boss-final-cap16.dart` | 16 — TelaAscii | Números flutuantes (feedback visual) |
| `boss-final-cap17.dart` | 17 — Aleatoriedade | Testes de determinismo |
| `boss-final-cap18.dart` | 18 — Geração Procedural | Sementes reproduzíveis |
| `boss-final-cap19.dart` | 19 — Campo de Visão | FOV múltiplos andares |
| `boss-final-cap20.dart` | 20 — Entidades no Mapa | IA de perseguição e patrulha |
| `boss-final-cap21.dart` | 21 — Dungeon Crawl | Cores ANSI no terminal |
| `boss-final-cap22.dart` | 22 — Economia | A Profundeza Recompensa (bônus de ouro) |
| `boss-final-cap23.dart` | 23 — A Loja do Mercador | Itens Únicos e Valiosos |
| `boss-final-cap24.dart` | 24 — Generics e Pattern Matching | Combate Recente (análise temporal) |
| `boss-final-cap25.dart` | 25 — XP e Níveis | Invencibilidade Temporária |
| `boss-final-cap26.dart` | 26 — Múltiplos Andares | Troféu de Glória |
| `boss-final-cap27.dart` | 27 — Dungeon Run Completo | Economia Equilibrada |

### Parte IV — Engenharia de Software (Capítulos 28–33)

| Arquivo | Capítulo | Tema |
|---------|----------|------|
| `boss-final-cap28.dart` | 28 — Refatoração Guiada | Quebra da Deus Classe (SRP) |
| `boss-final-cap29.dart` | 29 — Testes Unitários | Suite de Defesa (15+ testes) |
| `boss-final-cap30.dart` | 30 — Async/Await | Sistema de Eventos Completo |
| `boss-final-cap31.dart` | 31 — Persistência em JSON | Auto-Save Mágico |
| `boss-final-cap32.dart` | 32 — Organização de Projeto | Pronto para Produção |
| `boss-final-cap33.dart` | 33 — Testes Golden | Progressão Cinematográfica |

### Parte V — Padrões de Projeto (Capítulos 34–37)

| Arquivo | Capítulo | Tema |
|---------|----------|------|
| `boss-final-cap34.dart` | 34 — Strategy e Command | Comportamento Adaptativo |
| `boss-final-cap35.dart` | 35 — Factory e Observer | Reações em Cadeia |
| `boss-final-cap36.dart` | 36 — Máquinas de Estado | FSM Completa do Lobo (5 estados) |
| `boss-final-cap37.dart` | 37 — Síntese | Padrão MVC |

---

## Como Usar

### Executar uma solução
```bash
dart boss-final-cap01.dart
```

### Analisar código
```bash
dart analyze boss-final-cap01.dart
```

### Formatar código
```bash
dart format boss-final-cap01.dart
```

---

## Mapa de Conceitos Dart

| Capítulo | Conceitos Principais |
|----------|---------------------|
| 1 | print(), string interpolation, Unicode |
| 2 | stdin, stdout, funções |
| 3 | Operadores ternários, switch, formatação |
| 4 | Null safety, ??, ?., type promotion |
| 5 | List, Map, Set, spread operator |
| 6 | StringBuffer, arte ASCII, layout |
| 7 | Game loop, estado global, comando |
| 8 | Classes, campos, métodos, getters |
| 9 | Imutabilidade, padrão copy-with |
| 10 | Herança, polimorfismo, abstract |
| 11 | Mixins, method resolution order |
| 12 | Enums, sealed classes, pattern matching |
| 13 | Item hierarchy, economia, validação |
| 14 | Random, combate, log de ações |
| 15 | Grid 2D, tiles, coordenadas |
| 16 | Buffer de renderização, MVC |
| 17 | Seed, determinismo, loot tables |
| 18 | Geração procedural, BFS |
| 19 | FOV, Bresenham, névoa de guerra |
| 20 | Entidades, spawner, colisão |
| 21 | Integração, ANSI, dungeon crawl |
| 22 | Economia, drops, balanceamento |
| 23 | Loja, raridade, restoque |
| 24 | Generics, eventos, streams |
| 25 | XP, níveis, progressão |
| 26 | Boss, andares, vitória |
| 27 | Economia equilibrada, simulação |
| 28 | SRP, refatoração, code smells |
| 29 | Testes unitários, mocks, matchers |
| 30 | async/await, Future, Stream |
| 31 | JSON, persistência, auto-save |
| 32 | Organização, imports, pubspec |
| 33 | Golden tests, HUD, snapshot |
| 34 | Strategy, Command, undo/redo |
| 35 | Factory, Observer, eventos |
| 36 | State pattern, FSM, transições |
| 37 | MVC, arquitetura, síntese |

---

## Dicas para Estudar

1. **Comece pelos caps 1–4** para entender fundações do Dart
2. **Passe para caps 8–12** para dominar orientação a objetos
3. **Explore caps 15–21** para sistemas de jogo 2D
4. **Avance para caps 28–33** para engenharia de software
5. **Estude caps 34–37** para padrões de projeto avançados

Cada arquivo está documentado e pronto para ser adaptado ao seu próprio jogo.

---

**Versão**: 2.0 — Completa (37/37 soluções)
**Dart**: 3.11.0+
**Atualizado**: Abril 2026
