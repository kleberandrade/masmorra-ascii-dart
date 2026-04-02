# Capítulo 18 - Geração Procedural: Cavernas e Corredores

> *Cada masmorra tem uma história. Mas desenhar cada um dos nossos mundos à mão seria loucura. Assim, ensinamos a máquina a criar. Não infinitamente, mas com regras e criatividade. Cada sessão, a masmorra muda. Essa é a promessa do roguelike verdadeiro.*


## O Que Vamos Aprender

Neste capítulo você vai aprender dois algoritmos fundamentais de **geração procedural**:
- Random Walk: simples, orgânico, tipo caverna natural
- Rooms and Corridors: estruturado, clássico, tipo masmorra construída

Especificamente:
- Entender o conceito de geração procedural: regras + aleatoriedade criam conteúdo
- Algoritmo Random Walk: um "bêbado" anda aleatoriamente, deixando um caminho
- Desenho ASCII de como funciona
- Implementação completa em Dart
- Algoritmo Rooms & Corridors: gerar salas aleatórias, evitar sobreposição, conectar com corredores
- Classe Sala com métodos de sobreposição e desenho
- Validação de mapas: garantir que existe um caminho da entrada até a saída
- Comparação visual entre os dois algoritmos
- Exemplo completo funcionando

Ao final, você terá mapas únicos e procedurais.


## Parte 1: Random Walk (Embriaguez Errante)

### O Conceito

Imagina um bêbado começando no meio da masmorra e andando aleatoriamente. Cada passo que dá converte a parede em chão. Depois de muitos passos, deixa um traço de um caminho sinuoso. Isso simula como as cavernas naturais surgem: água ou criaturas erodindo rochas ao longo de séculos. O resultado é mapas muito orgânicos e exploráveis.

```text
Passo 1: Start no (5, 5), marca como chão
#########
#   @   #
#########

Passos 2-50: Anda N/S/E/O aleatoriamente, marcando chão
#...#...#
#.###...#
#.......#
#########

Resultado: caverna natural, conexões orgânicas
```

Vantagens: Fácil de implementar. Mapas parecem cavernas naturais. Gasto computacional mínimo.
Desvantagens: Sem estrutura (sem salas claras). Pode ficar muito aberto ou muito cheio.

### Implementação

A implementação é simples: comece no centro, escolha uma direção aleatória a cada passo, e marque a célula como chão. Use boundary checks para não sair do mapa. Quanto mais passos, mais "furos" o mapa terá. Com 1000 passos você tem uma caverna exploável; com 100 fica muito linear.

```dart
// dungeon_generator.dart

class MapaMasmorra {
  static MapaMasmorra comRandomWalk({
    required int largura,
    required int altura,
    required Random random,
    required int numPassos,
  }) {
    final grade = List<List<Tile>>.generate(
      altura,
      (y) => List<Tile>.generate(largura, (x) => Tile.parede),
    );

    int x = largura ~/ 2;
    int y = altura ~/ 2;
    grade[y][x] = Tile.chao;

    for (int passo = 0; passo < numPassos; passo++) {
      final direcao = random.nextInt(4);
      switch (direcao) {
        case 0: if (y > 1) y--;
        case 1: if (y < altura - 2) y++;
        case 2: if (x < largura - 2) x++;
        case 3: if (x > 1) x--;
      }
      grade[y][x] = Tile.chao;
    }

    final mapa = MapaMasmorra(largura: largura, altura: altura);
    mapa._definirGrade(grade);
    return mapa;
  }

  void _definirGrade(List<List<Tile>> grade) {
    _tiles = grade;
  }
}
```


## Parte 2: Rooms and Corridors (Clássico de Roguelike)

### O Conceito

Este é o algoritmo clássico dos roguelikes antigos (Rogue, Nethack, Angband). A ideia é:

1. Gerar N retângulos aleatórios (salas)
2. Descartar sobreposições (para não ter salas dentro de salas)
3. Ligar salas com corredores em forma de L (horizontal-depois-vertical)

Resultado: masmorra estruturada, com salas distintas e corredores conectando-as. Fácil de navegar, visual clara, muito mais "construída" que Random Walk.

### Classe Sala

```dart
// sala.dart

import 'dart:math';

class Sala {
  final int x;
  final int y;
  final int largura;
  final int altura;

  Sala({
    required this.x,
    required this.y,
    required this.largura,
    required this.altura,
  }) : assert(largura >= 3 && altura >= 3);

  Point<int> get centro => Point(x + largura ~/ 2, y + altura ~/ 2);

  int get xMax => x + largura - 1;
  int get yMax => y + altura - 1;

  bool sobrepoe(Sala outra, {int margem = 1}) {
    return !(xMax + margem < outra.x ||
        outra.xMax + margem < x ||
        yMax + margem < outra.y ||
        outra.yMax + margem < y);
  }

  void desenharNa(List<List<Tile>> grade) {
    for (int yy = y; yy <= yMax; yy++) {
      for (int xx = x; xx <= xMax; xx++) {
        if (yy >= 0 && yy < grade.length &&
            xx >= 0 && xx < grade[yy].length) {
          grade[yy][xx] = Tile.chao;
        }
      }
    }
  }

  void desenharCorredorPara(Sala outra, List<List<Tile>> grade) {
    final x1 = centro.x;
    final y1 = centro.y;
    final x2 = outra.centro.x;
    final y2 = outra.centro.y;

    for (int xx = (x1 < x2 ? x1 : x2); xx <= (x1 > x2 ? x1 : x2); xx++) {
      if (xx >= 0 && xx < grade[0].length && y1 >= 0 && y1 < grade.length) {
        grade[y1][xx] = Tile.chao;
      }
    }

    for (int yy = (y1 < y2 ? y1 : y2); yy <= (y1 > y2 ? y1 : y2); yy++) {
      if (yy >= 0 && yy < grade.length && x2 >= 0 && x2 < grade[yy].length) {
        grade[yy][x2] = Tile.chao;
      }
    }
  }
}
```

### Factory de Mapas

Este método é a "factory" que constrói um mapa completo com salas e corredores. Ele tenta criar N salas aleatórias, mas só adiciona se não se sobreporem com salas existentes. Depois, desenha cada sala e conecta-as com corredores. O resultado é um mapa exploável e estruturado, perfeito para masmorras construídas.

```dart
// dungeon_generator.dart

class MapaMasmorra {
  static MapaMasmorra comSalasECorredores({
    required int largura,
    required int altura,
    required Random random,
    required int numSalas,
    int minTamanho = 5,
    int maxTamanho = 12,
  }) {
    final grade = List<List<Tile>>.generate(
      altura,
      (y) => List<Tile>.generate(largura, (x) => Tile.parede),
    );

    final salas = <Sala>[];

    for (int i = 0; i < numSalas; i++) {
      final w = minTamanho + random.nextInt(maxTamanho - minTamanho + 1);
      final h = minTamanho + random.nextInt(maxTamanho - minTamanho + 1);
      final x = 1 + random.nextInt(largura - w - 2);
      final y = 1 + random.nextInt(altura - h - 2);

      final novaSala = Sala(x: x, y: y, largura: w, altura: h);

      bool valida = true;
      for (final sala in salas) {
        if (novaSala.sobrepoe(sala, margem: 2)) {
          valida = false;
          break;
        }
      }

      if (valida) {
        salas.add(novaSala);
      }
    }

    if (salas.isEmpty) {
      salas.add(Sala(x: 5, y: 5, largura: 8, altura: 8));
    }

    for (final sala in salas) {
      sala.desenharNa(grade);
    }

    for (int i = 0; i < salas.length - 1; i++) {
      salas[i].desenharCorredorPara(salas[i + 1], grade);
    }

    final mapa = MapaMasmorra(largura: largura, altura: altura);
    mapa._definirGrade(grade);
    return mapa;
  }
}
```


## Parte 3: Validação de Mapas

Um mapa "bom" tem um caminho do jogador até as escadas (saída). Isso é chamado "connectivity validation". O método usa **BFS** (Breadth-First Search) para verificar se existe um caminho entre o centro (onde o jogador começa) e as escadas. Se não houver, o mapa é inválido e você deve gerar de novo. Isso garante que o jogo é sempre ganhável.

```dart
// dungeon_map.dart

class MapaMasmorra {
  bool validar() {
    final escadas = _encontrarEscadas();
    if (escadas == null) return false;

    return _temCaminhoAte(largura ~/ 2, altura ~/ 2, escadas.x, escadas.y);
  }

  Point<int>? _encontrarEscadas() {
    for (int y = 0; y < altura; y++) {
      for (int x = 0; x < largura; x++) {
        if (tileEm(x, y) == Tile.escadaDesce) {
          return Point(x, y);
        }
      }
    }
    return null;
  }

  bool _temCaminhoAte(int startX, int startY, int endX, int endY) {
    final visitadas = <Point<int>>{};
    final fila = <Point<int>>[Point(startX, startY)];

    while (fila.isNotEmpty) {
      final ponto = fila.removeAt(0);
      if (visitadas.contains(ponto)) continue;
      visitadas.add(ponto);

      if (ponto.x == endX && ponto.y == endY) {
        return true;
      }

      for (final (dx, dy) in [(0, 1), (0, -1), (1, 0), (-1, 0)]) {
        final nx = ponto.x + dx;
        final ny = ponto.y + dy;

        if (nx >= 0 && nx < largura && ny >= 0 && ny < altura) {
          if (ehPassavel(nx, ny) && !visitadas.contains(Point(nx, ny))) {
            fila.add(Point(nx, ny));
          }
        }
      }
    }

    return false;
  }
}
```

### Colocação Inteligente de Salas

Ao gerar uma sala nova, você precisa não apenas garantir que não sobrepõe salas existentes, mas também que está bem espaçada. Esta função testa se uma sala é válida:

```dart
// sala_validador.dart

class ValidadorSalas {
  bool salaEValida(
    Sala novaSala,
    List<Sala> salasExistentes, {
    int margem = 2,
    int larguraMinima = 80,
    int alturaMinima = 24,
  }) {
    // Verifica se fica dentro dos limites do mapa
    if (novaSala.xMax >= larguraMinima || novaSala.yMax >= alturaMinima) {
      return false;
    }

    // Verifica sobreposição com todas as salas existentes
    for (final sala in salasExistentes) {
      if (novaSala.sobrepoe(sala, margem: margem)) {
        return false;
      }
    }

    return true;
  }

  // Tenta colocar N salas aleatoriamente, retorna quantas conseguiu
  int colocarSalasAleatorias(
    List<Sala> salasDestino,
    int quantasGenerar,
    Random random,
    int larguraMapa,
    int alturaMapa, {
    int minTamanho = 5,
    int maxTamanho = 12,
  }) {
    int colocadas = 0;

    for (int tentativa = 0; tentativa < quantasGenerar * 3; tentativa++) {
      final largura = minTamanho + random.nextInt(maxTamanho - minTamanho + 1);
      final altura = minTamanho + random.nextInt(maxTamanho - minTamanho + 1);
      final x = 1 + random.nextInt((larguraMapa - largura).clamp(1, larguraMapa));
      final y = 1 + random.nextInt((alturaMapa - altura).clamp(1, alturaMapa));

      final novaSala = Sala(x: x, y: y, largura: largura, altura: altura);

      if (salaEValida(novaSala, salasDestino, margem: 2)) {
        salasDestino.add(novaSala);
        colocadas++;

        if (colocadas >= quantasGenerar) break;
      }
    }

    return colocadas;
  }
}
```

### Conexão de Corredores Melhorada

Quando você tem 5+ salas, conectar sala i com sala i+1 pode deixar algumas isoladas. Esta versão garante que todas as salas estão conectadas:

```dart
// conector_corredores.dart

import 'dart:math';

class ConectorCorredores {
  void conectarTodasAsSalas(
    List<Sala> salas,
    List<List<Tile>> grade,
  ) {
    if (salas.isEmpty) return;

    // Usar algoritmo de Árvore Geradora Mínima (MST)
    // Conecta cada sala à mais próxima ainda não conectada
    final conectadas = <Sala>{salas[0]};
    final naoConectadas = <Sala>{...salas};
    naoConectadas.remove(salas[0]);

    while (naoConectadas.isNotEmpty) {
      // Encontra a par (conectada, não conectada) com menor distância
      Sala? salaProxima;
      Sala? salaConectarA;
      double menorDistancia = double.infinity;

      for (final con in conectadas) {
        for (final nao in naoConectadas) {
          final dist = _distancia(con.centro, nao.centro);
          if (dist < menorDistancia) {
            menorDistancia = dist;
            salaProxima = nao;
            salaConectarA = con;
          }
        }
      }

      if (salaProxima != null && salaConectarA != null) {
        salaConectarA.desenharCorredorPara(salaProxima, grade);
        conectadas.add(salaProxima);
        naoConectadas.remove(salaProxima);
      }
    }
  }

  double _distancia(Point<int> a, Point<int> b) {
    final dx = (a.x - b.x).toDouble();
    final dy = (a.y - b.y).toDouble();
    return sqrt(dx * dx + dy * dy);
  }
}
```

### Teste de Conectividade Completa

Após gerar e conectar as salas, valide que o mapa inteiro é explorável:

```dart
// mapa_validador.dart

class ValidadorMapa {
  /// Valida se o mapa é totalmente explorável
  MapaValidacaoResultado validarMapaCompleto(
    MapaMasmorra mapa,
  ) {
    // 1. Encontra região de chão contígua maior
    final regioes = _encontrarRegioesChao(mapa);
    if (regioes.isEmpty) {
      return MapaValidacaoResultado(
        valido: false,
        mensagem: 'Nenhuma região de chão encontrada',
      );
    }

    // 2. Verifica se existe uma escada
    Point<int>? escada;
    for (int y = 0; y < mapa.altura; y++) {
      for (int x = 0; x < mapa.largura; x++) {
        if (mapa.tileEm(x, y) == Tile.escadaDesce) {
          escada = Point(x, y);
          break;
        }
      }
    }

    if (escada == null) {
      return MapaValidacaoResultado(
        valido: false,
        mensagem: 'Nenhuma escada encontrada',
      );
    }

    // 3. Verifica se escada está na maior região
    final maiorRegiao = regioes.reduce((a, b) => a.length > b.length ? a : b);
    if (!maiorRegiao.contains(escada)) {
      return MapaValidacaoResultado(
        valido: false,
        mensagem: 'Escada está isolada em região separada',
      );
    }

    // 4. Calcula estatísticas úteis
    return MapaValidacaoResultado(
      valido: true,
      mensagem: 'Mapa válido e explorável',
      numRegioes: regioes.length,
      tamanhoMaiorRegiao: maiorRegiao.length,
    );
  }

  List<Set<Point<int>>> _encontrarRegioesChao(MapaMasmorra mapa) {
    final visitadas = <Point<int>>{};
    final regioes = <Set<Point<int>>>[];

    for (int y = 0; y < mapa.altura; y++) {
      for (int x = 0; x < mapa.largura; x++) {
        final ponto = Point(x, y);

        if (!visitadas.contains(ponto) && mapa.ehPassavel(x, y)) {
          final regiao = _explorarRegiao(ponto, mapa, visitadas);
          regioes.add(regiao);
        }
      }
    }

    return regioes;
  }

  Set<Point<int>> _explorarRegiao(
    Point<int> inicio,
    MapaMasmorra mapa,
    Set<Point<int>> visitadas,
  ) {
    final regiao = <Point<int>>{};
    final fila = <Point<int>>[inicio];

    while (fila.isNotEmpty) {
      final ponto = fila.removeAt(0);
      if (visitadas.contains(ponto)) continue;

      visitadas.add(ponto);
      regiao.add(ponto);

      for (final (dx, dy) in [(0, 1), (0, -1), (1, 0), (-1, 0)]) {
        final nx = ponto.x + dx;
        final ny = ponto.y + dy;

        if (nx >= 0 && nx < mapa.largura && ny >= 0 && ny < mapa.altura) {
          final prox = Point(nx, ny);
          if (!visitadas.contains(prox) && mapa.ehPassavel(nx, ny)) {
            fila.add(prox);
          }
        }
      }
    }

    return regiao;
  }
}

class MapaValidacaoResultado {
  final bool valido;
  final String mensagem;
  final int? numRegioes;
  final int? tamanhoMaiorRegiao;

  MapaValidacaoResultado({
    required this.valido,
    required this.mensagem,
    this.numRegioes,
    this.tamanhoMaiorRegiao,
  });
}
```
```

### Estratégia de Geração Iterativa

Para mapas mais robustos, você pode usar uma abordagem iterativa: gera um mapa, valida, e se for inválido, regenera automaticamente com ajustes:

```dart
// gerador_com_retentativas.dart

class GeradorMasmorraRobusta {
  MapaMasmorra gerarValidado({
    required int largura,
    required int altura,
    required int numSalas,
    int maxTentativas = 10,
  }) {
    final validador = ValidadorMapa();

    for (int tentativa = 0; tentativa < maxTentativas; tentativa++) {
      final mapa = MapaMasmorra.comSalasECorredores(
        largura: largura,
        altura: altura,
        random: Random(),
        numSalas: numSalas,
      );

      final resultado = validador.validarMapaCompleto(mapa);

      if (resultado.valido) {
        print('Mapa válido gerado na tentativa ${tentativa + 1}');
        print('Regiões conectadas: ${resultado.numRegioes}');
        print('Tamanho maior região: ${resultado.tamanhoMaiorRegiao}');
        return mapa;
      }

      print('Tentativa ${tentativa + 1}: ${resultado.mensagem}');
    }

    // Fallback: retorna mapa inválido (ou lança exceção)
    throw Exception(
      'Falha ao gerar mapa válido após $maxTentativas tentativas'
    );
  }
}
```

## Pergaminho do Capítulo

Neste capítulo você aprendeu:

- Algoritmo Random Walk: caminhante aleatório esculpe cavernas orgânicas e sinuosas
- Algoritmo Rooms & Corridors: gera salas estruturadas e as conecta com corredores
- Validação de salas: evitar sobreposições e garantir conectividade
- Árvore Geradora Mínima (MST): conectar todas as salas garantidamente
- Validação de mapas com BFS: detectar regiões isoladas e rejeitar mapas inválidos
- Regeneração inteligente: recriar mapas que falhem validação, com limite de tentativas

::: dica
**Dica do Mestre:** Em produção, muitos estúdios combinam Random Walk para subcavernas internas (caves, cavernas naturais) e Rooms & Corridors para estrutura macro (fortalezas, dungeons construídas). Use testes de validação agressivos: regenere mapas inválidos automaticamente, nunca deixe o jogador preso. Alguns jogos armazenam seeds para permitir "recriação" de masmorras já exploradas — útil para speedruns ou competições.
:::

## Desafios da Masmorra

**Desafio 18.1. Comparar algoritmos lado a lado.** Crie um programa que gera dois mapas com mesmos parâmetros de tamanho: um com Random Walk, outro com Rooms & Corridors. Imprima lado a lado usando StringBuffer. Qual parece mais natural? Qual mais estruturado? Qual você preferiria explorar?

**Desafio 18.2. Tuning de Random Walk.** Teste Random Walk com diferentes `numPassos`: 100, 500, 1000, 5000. Para cada valor, imprima o mapa. Em qual ponto fica "supercavado"? Qual balancia exploração com estrutura? Teste em tamanhos diferentes (80x50, 120x60) e identifique valores ideais.

**Desafio 18.3. Sala Boss.** Modifique o gerador Rooms & Corridors para garantir que a última sala gerada é significativamente maior (ex: 15x15). Use-a como "sala do boss final". Todas as outras salas são menores (6-10 tiles). Imprima o mapa destacando a sala boss com símbolo especial (`B` ou `◆`).

**Desafio 18.4. Algoritmo Híbrido.** Implemente um terceiro algoritmo que combina ambos: primeiro Random Walk para criar exploração orgânica, depois Rooms & Corridors para adicionar estrutura. Comece com Random Walk pequeno (200 passos), depois tente encaixar 3-5 salas regulares. Valide que as salas não sobrepõem corredores existentes.

**Desafio 18.5. Detector de regiões desconexas.** Crie uma função `int contarRegioesDesconexas(MapaMasmorra mapa)` que usa BFS para contar "ilhas" de floor desconectadas. Mapas válidos devem ter apenas 1 região. Rejeite automaticamente mapas com múltiplas regiões. Teste com Random Walk pouco iterado (ele gera ilhas).

**Boss Final 18.6. Sistema de Sementes reproduzível.** Modifique MapaMasmorra para aceitar seed opcional. Gere 10 mapas com mesma seed: todos devem ser idênticos. Implemente modo "debug" que exibe a seed na HUD ("Seed: 12345"). Permite que jogadores compartilhem sementes para "desafios reproduzíveis": "Vence essa seed em 20 minutos!" Isso torna o jogo estratégico.
