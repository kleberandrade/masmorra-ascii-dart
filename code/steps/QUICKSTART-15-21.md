# Guia rápido — Steps 15–21

## Estrutura de arquivos

```
code/steps/
├── step-15/   (Grid 2D)
├── step-16/   (TelaAscii)
├── step-17/   (Aleatoriedade)
├── step-18/   (Geração Procedural)
├── step-19/   (FOV)
├── step-20/   (Entidades)
├── step-21/   (Dungeon Crawl — MARCO III)
├── README.md
└── QUICKSTART-15-21.md (este arquivo)
```

## Execução Rápida

### Testar um Step Individual

```bash
cd step-21
dart lib/main.dart
```

### Testar todos os steps (15–21)

A partir de `code/steps/`:

```bash
for step in 15 16 17 18 19 20 21; do
  echo "=== STEP-$step ==="
  (cd "step-$step" && dart analyze && echo "✓ Sem warnings")
done
```

## O Que Cada Step Faz

| Step | Nome | Jogo? | Descrição |
|------|------|-------|-----------|
| 15 | Grid 2D | Sim | Mapa 2D, movimento WASD |
| 16 | TelaAscii | Sim | Renderização profissional, MVC |
| 17 | Aleatoriedade | Sim | Random com seeds, Rolador |
| 18 | Geração Procedural | Sim | Random Walk + Rooms & Corridors |
| 19 | FOV | Sim | Campo de visão, névoa de guerra |
| 20 | Entidades | Sim | Inimigos, itens, escadas |
| 21 | Dungeon Crawl | **SIM** | **Roguelike completo (MARCO III)** |

## Controles

### Movimento
- **W**: Cima
- **S**: Baixo
- **A**: Esquerda
- **D**: Direita

### Ações
- **I**: Inventário (step-20, 21)
- **Q**: Sair

### Interação com Entidades
Alguns steps têm menu de interação:
- **s**: Sim (engajar combate, descer escadas)
- **n**: Não

## Características por Step

### Step-15: Grid Básico
- Mapa 20x10
- Tiles: parede (#), chão (.), porta (+), escada (>)
- Movimento com colisão

### Step-16: Renderização Profissional
- Buffer 2D separado
- ANSI codes para limpeza de tela
- Renderização em camadas
- HUD com HP bar

### Step-17: Aleatoriedade
- Prompt para semente (deixe em branco para aleatório)
- Classe Rolador com:
  - `d(faces)` - rolagem de dado
  - `rolar(min, max)` - intervalo
  - `chance(percent)` - probabilidade
  - `escolher(lista)` - elemento aleatório
  - `escolherPonderado(pesos)` - seleção ponderada

### Step-18: Geração Procedural
- Menu escolhe algoritmo:
  - **1**: Random Walk (cavernas)
  - **2**: Rooms & Corridors (masmorra)
- Cada execução gera mapa diferente

### Step-19: FOV e Névoa
- Shadowcasting em 8 direções
- 3 estados de tile:
  - Vazio: nunca visto
  - Esfumaçado: explorado mas não visível agora
  - Normal: visível agora
- À medida que move, mapa se revela

### Step-20: Entidades
- Inimigos: Z (Zumbi), L (Lobo), O (Orc)
- Itens: ! (itens no chão)
- Escadas: > (descida)
- Combate simplificado (sempre vence)
- Menu de interação ao encontrar entidade

### Step-21: Jogo Completo
- **3 andares** até a vitória
- Progressão: inimigos ficam mais fortes em andares profundos
- Estatísticas ao final:
  - Turnos
  - Maior andar alcançado
  - Inimigos derrotados
  - Ouro coletado
  - Itens coletados
- Condições de vitória: descer 3 andares
- Condições de derrota: HP = 0

## Estrutura de Código

### Convenções
- **Idioma**: Português
- **Variáveis**: camelCase
- **Classes**: PascalCase
- **Constantes**: camelCase

### Organização Típica
```
step-XX/
├── pubspec.yaml              # Manifesto Dart
└── lib/
    ├── main.dart            # Ponto de entrada
    ├── tile.dart            # Enum Tile
    ├── tela_ascii.dart      # Renderização
    ├── campo_visao.dart     # FOV (step-19+)
    ├── entidade.dart        # Sistema de entidades (step-20+)
    ├── rolador.dart         # Aleatoriedade (step-17+)
    ├── sala.dart            # Salas (step-18)
    ├── dungeon.dart         # Mapa e sessão
    └── explorador_masmorra.dart # Orquestrador (step-21)
```

## Exemplos de Execução

### Step-21 (Mais Interessante)

```bash
$ cd step-21
$ dart lib/main.dart

╔════════════════════════════════════════╗
║   MASMORRA ASCII: Dungeon Crawl       ║
║         (MARCO III - Completo)        ║
╚════════════════════════════════════════╝

# Mapa ASCII renderizado
# HUD mostra: Andar, Turno, HP, Ouro

> W     # Mover cima
> D     # Mover direita
# Encontra Zumbi
> s     # Combater
# Vence, +25 ouro
> D     # Encontra item
# Inventário: [Ouro]
> >     # Encontra escada
# Desce para Andar 1

# Andar 2...
# Andar 3...
# VITÓRIA!

║ Estatísticas Finais:
║ Turnos: 145
║ Maior Andar: 3
║ Inimigos Derrotados: 8
║ Ouro Total: 250
║ Itens Coletados: 6
```

### Step-17 (Com Semente)

```bash
$ cd step-17
$ dart lib/main.dart
Semente aleatória (deixe em branco para aleatório): 42

# Com semente 42, mesmos resultados sempre
# Sem semente, resultados diferentes cada vez
```

### Step-18 (Escolher Gerador)

```bash
$ cd step-18
$ dart lib/main.dart
=== MASMORRA ASCII: Geração Procedural ===

1. Random Walk
2. Rooms and Corridors
Escolha (1-2): 1

# Gera caverna natural tipo Random Walk
```

## Compilação e Análise

Todos os steps compilam com zero warnings:

```bash
cd step-21
dart analyze    # Zero warnings garantido
dart format .   # Formata código (já formatado)
dart lib/main.dart        # Executa jogo
```

## Arquivos Criados

**Total: 28 arquivos Dart + 7 pubspec.yaml**

Distribuição:
- 7 projetos Dart
- 4 módulos base: tile.dart, tela_ascii.dart, dungeon.dart, main.dart
- 7 módulos crescentes (conforme steps aumentam em complexidade)

## Dicas

1. **Step-21 é o mais interessante**: É um roguelike completo e jogável
2. **Cada step melhora o anterior**: Não reinventar, apenas estender
3. **Composição sobre herança**: Use `final` e injeção de dependência
4. **Nomes descritivos**: Classes grandes têm nome único (ExploradorMasmorra)
5. **FOV muda tudo**: Step-19 adiciona dramatismo com névoa de guerra

## Debug

Se quiser adicionar prints:

```dart
// Em qualquer classe
print('Debug: $variavel');
```

Se quiser visualizar FOV:

```dart
// Em step-19+, descomentar:
// print('Visíveis: ${mapa.fov.tileVisiveis.length}');
```

## Próximas Extensões

Ideias para estender cada step:

1. **Step-15**: Adicionar múltiplos inimigos estáticos
2. **Step-16**: Cores ANSI (vermelho para HP baixo, verde para ouro)
3. **Step-17**: Loot tables com raridade
4. **Step-18**: Validação de conectividade (BFS)
5. **Step-19**: Melhorar aparência (use ▓ para parede em vez de #)
6. **Step-20**: IA simples para inimigos (perseguir jogador)
7. **Step-21**: Boss final, XP/níveis, upgrading de armas

---

**Tudo pronto para compilar e jogar!**

Use `dart lib/main.dart` em qualquer step-XX para começar.
Step-21 é o roguelike completo.
