# Capítulo 15 - Da Sala ao Tile: Pensando em 2D

*A masmorra ganha duas dimensões. Até agora, salas eram nomes em um mapa de texto. Agora são tiles em um grid, paredes são `#`, chão é `.`, e o jogador é um `@` que se move com WASD. A névoa de guerra esconde o que você ainda não explorou, e tochas iluminam apenas o que está ao alcance. O mapa gera-se sozinho a cada partida, diferente toda vez, porque você escreveu o algoritmo que o cria.*

*Nesta parte, a masmorra finalmente parece uma masmorra. Inimigos patrulham corredores, itens brilham no chão, e escadas levam para andares mais profundos. O terminal vira uma janela para um mundo procedural que responde ao seu código. Quando você compilar e vir o mapa aparecer pela primeira vez, vai entender por que roguelikes são viciantes.*

> *Você explorou um único aposento como texto puro. Mas um verdadeiro aventureiro não caminha palavra por palavra. Caminha tile por tile. E todo mundo, por maior que seja, é feito de pequenos quadrados alinhados numa grade. A grade 2D é como o mapa de Zelda visto de cima: cada posição tem um tile que diz se há parede, chão passável ou algo especial.*


## O Que Vamos Aprender

Neste capítulo você vai deixar para trás o modelo de salas separadas (texto puro, grafo de conexões) e abraçar o paradigma roguelike clássico: um mapa 2D baseado em **tiles** (quadrados numa grade).

Especificamente:
- Entender por que *roguelikes* usam grades: colisão em tempo real, movimento gradual, visão de distância
- Criar uma estrutura de dados 2D eficiente em Dart: `List<List<Tile>>` com **collection for** e **collection if**
- Usar **typedef** para melhorar legibilidade: `typedef Grade = List<List<Tile>>`
- Definir um enum `Tile` com tipos: `parede`, `chao`, `porta`, `escadaDesce`
- Construir a classe `MapaMasmorra` que encapsula o mapa e fornece métodos seguros
- Renderizar a grade no terminal com loops aninhados
- Implementar movimento do jogador com WASD: atualizar posição, verificar colisões
- Aplicar boundary checks para não sair da tela
- Mostrar um exemplo completo funcionando: masmorra 10x10, jogador move-se com feedback

Ao final, você terá o alicerce de toda exploração *roguelike*. Sem um grid não há mapa. Sem mapa não há jogo.


## Parte 1: Do Grafo ao Grid — Mudança Conceitual

### Por Que Sair das Salas?

Nos capítulos anteriores você tinha um grafo de salas: cada sala era um nó, conexões eram arestas. Isso funciona para aventuras em prosa, mas *roguelikes* precisam de geometria real.

Considere:
- Visibilidade (*FOV*): um inimigo pode ver o jogador? Precisa distância e linha de visão
- Movimento: um jogador não pula de sala a sala. Caminha tile por tile
- Pathfinding: como um inimigo caminha até o jogador? Precisa de coordenadas (x, y)
- Colisões: paredes não são abstratas. Ocupam posições específicas
- Geração procedural: criar uma masmorra aleatória é mais fácil em grade (pense em algoritmos como random walk)

Uma grade 2D é a linguagem natural de *roguelikes*.

### Conceitos Fundamentais

Antes de código, entenda a geometria:

```text
     x=0 x=1 x=2 ... x=9
   ┌─────────────────────┐
y=0│ (0,0)(1,0)(2,0)...(9,0)
y=1│ (0,1)(1,1)(2,1)...(9,1)
y=2│ (0,2)(1,2)(2,2)...(9,2)
... │
y=9│ (0,9)(1,9)(2,9)...(9,9)
   └─────────────────────┘
```

Notação (x, y):
- x = coluna (horizontal, esquerda para direita)
- y = linha (vertical, topo para fundo)
- Origem (0, 0) é o canto superior esquerdo

Para acessar a célula em (2, 3) na grade:

```dart
final tile = grade[3][2]; // grade[y][x] ... cuidado com a ordem!
```

Sempre `grid[y][x]`, nunca `grid[x][y]`. Essa é a convenção porque iteramos linhas (y) primeiro, colunas (x) segundo.


## Parte 2: Definindo Tiles. Enum e Typedef

Comece definindo que tipo de tile existe:

```dart
// tile.dart

enum Tile {
  parede,      // '#' - parede sólida, intransponível
  chao,        // '.' - chão passável
  porta,       // '+' - porta fechada ou aberta
  escadaDesce, // '>' - escadas para próximo nível
}

String tileParaChar(Tile tile) {
  return switch (tile) {
    Tile.parede => '#',
    Tile.chao => '.',
    Tile.porta => '+',
    Tile.escadaDesce => '>',
  };
}

bool ehPassavelTile(Tile tile) {
  return tile == Tile.chao ||
      tile == Tile.porta ||
      tile == Tile.escadaDesce;
}
```

Agora, typedef para clareza:

```dart
// mapa_masmorra.dart

typedef Grade = List<List<Tile>>;
typedef Posicao = ({int x, int y});
```

Por que typedef? Seu código fica mais legível:

```dart
Grade mapa = [...];  // Mais claro do que List<List<Tile>>
Posicao jogador = (x: 5, y: 5);  // Mais semântico que Point(5, 5)
```


## Parte 3: Classe MapaMasmorra. Encapsulamento

A classe `MapaMasmorra` encapsula a lógica do mapa:

```dart
// mapa_masmorra.dart

class MapaMasmorra {
  final int largura;
  final int altura;
  late Grade _tiles;

  MapaMasmorra({required this.largura, required this.altura}) {
    _inicializarGrade();
  }

  void _inicializarGrade() {
    _tiles = List<List<Tile>>.generate(
      altura,
      (y) => List<Tile>.generate(largura, (x) => Tile.chao),
    );
  }

  Tile tileEm(int x, int y) {
    if (x < 0 || x >= largura || y < 0 || y >= altura) {
      return Tile.parede; // Fora do mapa é parede
    }
    return _tiles[y][x];
  }

  void definirTile(int x, int y, Tile tile) {
    if (x < 0 || x >= largura || y < 0 || y >= altura) {
      return;
    }
    _tiles[y][x] = tile;
  }

  bool ehPassavel(int x, int y) {
    return ehPassavelTile(tileEm(x, y));
  }

  void renderizar() {
    for (int y = 0; y < altura; y++) {
      for (int x = 0; x < largura; x++) {
        final tile = tileEm(x, y);
        stdout.write(tileParaChar(tile));
      }
      stdout.write('\n');
    }
  }
}
```

Observações importantes:
- `late Grade _tiles` é inicializada no construtor (inicialização tardia)
- `_tiles[y][x]` segue a convenção: Y primeiro, depois X
- `ehPassavel()` encapsula a lógica (tiles passáveis ficam num único lugar)
- `renderizar()` itera com loops aninhados: for Y, depois X


## Parte 4: Construindo um Mapa Hardcoded

Vamos criar um pequeno mapa 10x10 manualmente:

```dart
// main.dart

import 'dart:io';

void main() {
  final mapa = MapaMasmorra(largura: 10, altura: 10);

  // Desenhar paredes ao redor (borda)
  for (int y = 0; y < 10; y++) {
    for (int x = 0; x < 10; x++) {
      if (x == 0 || x == 9 || y == 0 || y == 9) {
        mapa.definirTile(x, y, Tile.parede);
      } else {
        mapa.definirTile(x, y, Tile.chao);
      }
    }
  }

  // Adicionar algumas paredes internas (corredor em T)
  for (int y = 2; y <= 7; y++) {
    mapa.definirTile(5, y, Tile.parede);
  }

  // Porta no meio do corredor
  mapa.definirTile(5, 4, Tile.porta);

  // Escadas no canto
  mapa.definirTile(8, 8, Tile.escadaDesce);

  print('=== MAPA ===\n');
  mapa.renderizar();
}
```

Output esperado:

```text
##########
#........#
#....#...#
#....#...#
#....+...#
#....#...#
#....#...#
#....#...#
#........>
##########
```


## Parte 5: Posição do Jogador. Coordenadas

Agora o jogador tem uma posição (x, y):

```dart
// jogador.dart

class Jogador {
  String nome;
  int hpMax;
  int hpAtual;
  int ouro;
  int xp;

  int x = 5;
  int y = 5;

  Jogador({
    required this.nome,
    required this.hpMax,
    required this.ouro,
  }) : hpAtual = hpMax;

  bool mover(int novoX, int novoY, MapaMasmorra mapa) {
    if (!mapa.ehPassavel(novoX, novoY)) {
      return false;
    }
    x = novoX;
    y = novoY;
    return true;
  }

  void moverEmDirecao(String direcao, MapaMasmorra mapa) {
    int novoX = x;
    int novoY = y;

    switch (direcao.toLowerCase()) {
      case 'w': novoY--;
      case 's': novoY++;
      case 'a': novoX--;
      case 'd': novoX++;
      default: return;
    }

    mover(novoX, novoY, mapa);
  }
}
```


## Parte 6: Renderizando com o Jogador

Modificar `MapaMasmorra` para desenhar o jogador:

```dart
// mapa_masmorra.dart (adição)

class MapaMasmorra {
  // ... código anterior ...

  void renderizarComJogador(Jogador jogador) {
    print('');
    print('MAPA DA MASMORRA');

    for (int y = 0; y < altura; y++) {
      stdout.write('');
      for (int x = 0; x < largura; x++) {
        if (x == jogador.x && y == jogador.y) {
          stdout.write('@');
        } else {
          stdout.write(tileParaChar(tileEm(x, y)));
        }
      }
      stdout.write('\n');
    }

    print('Posição: (${jogador.x}, ${jogador.y})');
    print('HP: ${jogador.hpAtual}/${jogador.hpMax} | '
        'Ouro: ${jogador.ouro}');
    print('Comandos: W/A/S/D para mover, Q para sair');
    print('');
  }
}
```


## Parte 7: Loop de Movimento. Input

Agora o loop principal que aceita entrada do usuário:

```dart
import 'dart:io';

// main.dart

void main() {
  final mapa = MapaMasmorra(largura: 10, altura: 10);

  // ... código de construção do mapa ...

  final jogador = Jogador(
    nome: 'Aldric',
    hpMax: 100,
    ouro: 50,
  );

  jogador.x = 5;
  jogador.y = 5;

  print('=== MASMORRA ASCII: Exploração em 2D ===\n');
  print('Use W/A/S/D para se mover. Q para sair.\n');

  bool rodando = true;
  while (rodando) {
    mapa.renderizarComJogador(jogador);

    stdout.write('Comando> ');
    final entrada = stdin.readLineSync() ?? '';

    switch (entrada.toLowerCase()) {
      case 'w' || 'a' || 's' || 'd':
        jogador.moverEmDirecao(entrada, mapa);
      case 'q':
        print('Adeus, ${jogador.nome}!');
        rodando = false;
      default:
        if (entrada.isNotEmpty) {
          print('Inválido: $entrada');
        }
    }
  }
}
```

Execução esperada:

```text
MAPA DA MASMORRA

##########
#........#
#....#...#
#....#...#
#....+...#
#....@...#  <- Você está aqui!
#....#...#
#....#...#
#........>
##########

Posição: (5, 5)
HP: 100/100 | Ouro: 50
Comandos: W/A/S/D para mover, Q

> w
Você se moveu para (5, 4)
```


## Parte 8: Exemplo Completo. Tudo Junto

Aqui está um programa funcionando completamente (em um único arquivo para referência):

```dart
// main.dart (versão completa e auto-contida)

import 'dart:io';

enum Tile { parede, chao, porta, escadaDesce }

String tileParaChar(Tile tile) => switch (tile) {
  Tile.parede => '#',
  Tile.chao => '.',
  Tile.porta => '+',
  Tile.escadaDesce => '>',
};

typedef Grade = List<List<Tile>>;

class MapaMasmorra {
  final int largura;
  final int altura;
  late Grade _tiles;

  MapaMasmorra({required this.largura, required this.altura}) {
    _inicializarGrade();
  }

  void _inicializarGrade() {
    _tiles = List<List<Tile>>.generate(
      altura,
      (y) => List<Tile>.generate(largura, (x) => Tile.chao),
    );
  }

  Tile tileEm(int x, int y) {
    if (x < 0 || x >= largura || y < 0 || y >= altura)
      return Tile.parede;
    return _tiles[y][x];
  }

  void definirTile(int x, int y, Tile tile) {
    if (x < 0 || x >= largura || y < 0 || y >= altura) return;
    _tiles[y][x] = tile;
  }

  bool ehPassavel(int x, int y) => tileEm(x, y) != Tile.parede;

  void renderizarComJogador(Jogador jogador) {
    print('');
    print('EXPLORAÇÃO DA MASMORRA');

    for (int y = 0; y < altura; y++) {
      stdout.write('');
      for (int x = 0; x < largura; x++) {
        if (x == jogador.x && y == jogador.y) {
          stdout.write('@');
        } else {
          stdout.write(tileParaChar(tileEm(x, y)));
        }
      }
      stdout.write('\n');
    }

    final pos = '(${jogador.x}, ${jogador.y})';
    final hp = '${jogador.hpAtual}/${jogador.hpMax}';
    print('Posição: $pos | HP: $hp');
    print('[W]cima [A]esq [S]baixo [D]dir [Q]uit');
    print('');
  }
}

class Jogador {
  String nome;
  int hpMax;
  int hpAtual;
  int ouro;
  int x = 5;
  int y = 5;

  Jogador({required this.nome, required this.hpMax, required this.ouro})
      : hpAtual = hpMax;

  bool mover(int novoX, int novoY, MapaMasmorra mapa) {
    if (!mapa.ehPassavel(novoX, novoY)) return false;
    x = novoX;
    y = novoY;
    return true;
  }

  void moverEmDirecao(String direcao, MapaMasmorra mapa) {
    int novoX = x, novoY = y;
    switch (direcao.toLowerCase()) {
      case 'w': novoY--;
      case 's': novoY++;
      case 'a': novoX--;
      case 'd': novoX++;
      default: return;
    }
    mover(novoX, novoY, mapa);
  }
}

void main() {
  final mapa = MapaMasmorra(largura: 10, altura: 10);

  for (int y = 0; y < 10; y++) {
    for (int x = 0; x < 10; x++) {
      if (x == 0 || x == 9 || y == 0 || y == 9) {
        mapa.definirTile(x, y, Tile.parede);
      }
    }
  }

  for (int y = 2; y <= 7; y++) {
    mapa.definirTile(5, y, Tile.parede);
  }
  mapa.definirTile(5, 4, Tile.porta);
  mapa.definirTile(8, 8, Tile.escadaDesce);

  final jogador = Jogador(nome: 'Aldric', hpMax: 100, ouro: 50);

  print('=== Bem-vindo à Masmorra ASCII ===\n');

  bool rodando = true;
  while (rodando) {
    mapa.renderizarComJogador(jogador);

    stdout.write('Comando> ');
    final entrada = stdin.readLineSync() ?? '';

    switch (entrada.toLowerCase()) {
      case 'w' || 'a' || 's' || 'd':
        jogador.moverEmDirecao(entrada, mapa);
      case 'q':
        print('Adeus, ${jogador.nome}!');
        rodando = false;
      default:
        if (entrada.isNotEmpty) print('Inválido: $entrada');
    }
  }
}
```

Compile e execute:

```bash
dart main.dart
```


***
## Desafios da Masmorra

### Desafios Básicos

**Desafio 15.1. O Corredor da Perdição (Mapa com segredos).** Crie um mapa 20x15 onde um corredor central horizontal liga uma entrada (esquerda) a uma saída (direita). Adicione duas pequenas salas laterais (uma acima, outra abaixo do corredor), cada uma com uma escada. Teste caminhando: consegue sair? Encontra as escadas? Use loops e lógica para desenhar, não hardcode cada tile.

**Desafio 15.2. Paredes Atmosféricas (Visual).** Modifique `tileParaChar()` para renderizar diferentes símbolos para tipos de parede: `█` para pedra sólida, `╬` para rachaduras, `∿` para umidade. Escolha pelo menos dois. Execute para comparar o visual. Qual versão transmite mais a sensação de masmorra antiga?

### Desafios Avançados

**Desafio 15.3. Teleportes mágicos (Dinâmica).** Adicione um novo tipo de tile `teleporte` que renderiza como `◆`. Quando o jogador pisa nele, é teletransportado para outra posição aleatória do mapa. Crie um mapa com 3-4 teleportes. Dica: use `Random().nextInt(largura)` e `Random().nextInt(altura)` para coordenadas aleatórias válidas (não em paredes).

**Desafio 15.4. Múltiplos andares (Profundidade).** Implemente andares: quando o jogador pisa em `escadaDesce`, um novo `MapaMasmorra` é gerado. Use `List<MapaMasmorra> andares` para rastreá-los. Mostre "Andar 3 de 10" na HUD. Cada andar mais profundo deveria ter mais inimigos (aumentar dificuldade). Use uma seed ligeiramente diferente para cada andar.

**Boss Final 15.5. Campo de Visão com tocha (*FOV* simplificado).** Implemente campo de visão: cada tile tem um bool `visivel`. Inicialmente, renderize apenas tiles dentro de um raio 3 do jogador (distância Manhattan). Conforme caminha, novos tiles são marcados como explorados. Tiles não visíveis aparecem como `░` (sombra). Isso simula uma tocha iluminando a escuridão. Ao pisar em novo tile, atualiza a visibilidade dinamicamente.


## Pergaminho do Capítulo

Neste capítulo você aprendeu:

- Grade 2D é a base de *roguelikes*: pensamento em coordenadas (x, y)
- Enums para tiles: `parede`, `chao`, `porta`, `escadaDesce`. Semântica clara
- Typedef para legibilidade: `typedef Grade = List<List<Tile>>`
- Classe MapaMasmorra: encapsula mapa, oferece `tileEm()`, `ehPassavel()`, renderização
- Posição do jogador: `int x, int y` na classe Jogador
- Movimento: WASD atualiza posição, boundary checks impedem sair da tela
- Rendering em loop: itera Y (linhas), depois X (colunas)
- Colisões: `mapa.ehPassavel()` bloqueia movimento para paredes

Seu jogo agora tem um mapa explorador real. Já não é prosa, é geometria.

No próximo capítulo (16), você aprenderá a separar modelo e visão com a classe `TelaAscii`, tornando a renderização muito mais poderosa e flexível para adicionar inimigos, itens e UIs complexas.


::: dica
**Dica do Mestre:** Debugging de mapa: ao trabalhar com grades, erros de índice são comuns. Sempre use helper:

```dart
void renderDebug(MapaMasmorra mapa) {
  print('   0123456789');
  for (int y = 0; y < mapa.altura; y++) {
    stdout.write('$y: ');
    for (int x = 0; x < mapa.largura; x++) {
      stdout.write(tileParaChar(mapa.tileEm(x, y)));
    }
    stdout.write('\n');
  }
}
```

Performance: se seu mapa fica muito grande (100x100+), considere renderizar apenas um viewport ao redor do jogador (raio 7-8 tiles). Isso é essencial em jogos maiores.
:::
