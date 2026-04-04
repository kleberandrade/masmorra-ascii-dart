/// Boss Final Capítulo 15: Campo de Visão com Tocha (FOV Simplificado)
///
/// Objetivo: Implementar campo de visão onde cada tile tem um bool `visivel`.
/// Renderizar apenas tiles dentro de um raio 3 do jogador (distância Manhattan).
/// Novos tiles são marcados como explorados. Tiles não visíveis aparecem como ░.
///
/// Conceitos abordados:
/// - Distância Manhattan (|x1-x2| + |y1-y2|)
/// - Raio de visão em volta do personagem
/// - Diferença entre explorado e visível
/// - Renderização condicional
/// - Sistemas de iluminação em roguelikes
///
/// Instruções:
/// 1. Execute este arquivo com: dart boss-final-cap15.dart
/// 2. Observe o campo de visão do jogador (@)
/// 3. Mude a posição do jogador e veja FOV atualizar
/// 4. Nota: Tiles explorados permanecem visíveis mesmo quando obscuros
///
/// Resultado esperado: Dungeon com campo de visão dinâmico

void main() {
  print('═══════════════════════════════════════════════════════════');
  print('  Boss Final Capítulo 15: Campo de Visão com Tocha');
  print('═══════════════════════════════════════════════════════════');
  print('');

  // Criar mapa
  var mapa = MapaComFOV(largura: 20, altura: 12);

  // Posição inicial do jogador
  var posJogador = Pos(x: 10, y: 6);

  // Teste 1: Jogador no centro
  print('TESTE 1: Jogador no centro do mapa');
  mapa.atualizarFOV(posJogador);
  mapa.renderizar(posJogador);
  print('  Posição do jogador: (${ posJogador.x}, ${ posJogador.y})');
  print('  Raio de visão: 3 (distância Manhattan)');
  print('');

  // Teste 2: Mover para canto
  print('TESTE 2: Mover jogador para canto superior esquerdo');
  posJogador = Pos(x: 2, y: 2);
  mapa.atualizarFOV(posJogador);
  mapa.renderizar(posJogador);
  print('  Posição do jogador: (${ posJogador.x}, ${ posJogador.y})');
  print('  Observe: Tiles explorados marcados como ░ quando fora do FOV');
  print('');

  // Teste 3: Mover novamente
  print('TESTE 3: Mover para lado oposto');
  posJogador = Pos(x: 17, y: 10);
  mapa.atualizarFOV(posJogador);
  mapa.renderizar(posJogador);
  print('  Novo FOV revela mais tiles');
  print('');

  print('═══════════════════════════════════════════════════════════');
  print('  FOV simula uma tocha iluminando a escuridão');
  print('═══════════════════════════════════════════════════════════');
}

/// Classe para representar posição (x, y)
class Pos {
  int x;
  int y;

  Pos({required this.x, required this.y});

  /// Calcular distância Manhattan até outra posição
  int distanciaManhatanAte(Pos outra) {
    return (x - outra.x).abs() + (y - outra.y).abs();
  }

  @override
  String toString() => '($x, $y)';
}

/// Classe para representar um tile no mapa
class Tile {
  String simbolo;
  bool visivel;
  bool explorado;

  Tile({
    required this.simbolo,
    this.visivel = false,
    this.explorado = false,
  });
}

/// Classe que gerencia o mapa com sistema de FOV
class MapaComFOV {
  final int largura;
  final int altura;
  final int raioVis = 3; // Raio de visão (distância Manhattan)
  late List<List<Tile>> tiles;

  MapaComFOV({required this.largura, required this.altura}) {
    // Inicializar mapa aleatório
    _inicializarMapa();
  }

  /// Inicializar mapa com tiles aleatórios
  void _inicializarMapa() {
    tiles = [];

    for (var y = 0; y < altura; y++) {
      var linha = <Tile>[];
      for (var x = 0; x < largura; x++) {
        // 70% chance de chão, 30% de parede
        var simbolo = (x + y) % 3 == 0 ? '#' : '.';
        linha.add(Tile(simbolo: simbolo));
      }
      tiles.add(linha);
    }
  }

  /// Atualizar FOV baseado na posição do jogador
  void atualizarFOV(Pos jogador) {
    // Primeiro, marcar tiles dentro do raio como visíveis
    for (var y = 0; y < altura; y++) {
      for (var x = 0; x < largura; x++) {
        var pos = Pos(x: x, y: y);
        var dist = jogador.distanciaManhatanAte(pos);

        if (dist <= raioVis) {
          // Dentro do raio: visível e explorado
          tiles[y][x].visivel = true;
          tiles[y][x].explorado = true;
        } else {
          // Fora do raio: não visível
          tiles[y][x].visivel = false;
        }
      }
    }
  }

  /// Renderizar mapa com FOV
  void renderizar(Pos jogador) {
    print('');
    // Borda superior
    print('  ╔' + '═' * (largura * 2 - 1) + '╗');

    for (var y = 0; y < altura; y++) {
      print('  ║', end: '');
      for (var x = 0; x < largura; x++) {
        var tile = tiles[y][x];
        var pos = Pos(x: x, y: y);

        // Desenhar jogador se estiver nesta posição
        if (pos.x == jogador.x && pos.y == jogador.y) {
          print('@', end: ' ');
        } else if (tile.visivel) {
          // Visível: mostrar o tile
          print(tile.simbolo, end: ' ');
        } else if (tile.explorado) {
          // Explorado mas não visível: mostrar ░ (sombra)
          print('░', end: ' ');
        } else {
          // Nunca explorado: mostrar espaço vazio
          print(' ', end: ' ');
        }
      }
      print('║');
    }

    // Borda inferior
    print('  ╚' + '═' * (largura * 2 - 1) + '╝');
    print('');
  }

  /// Obter o símbolo a renderizar para uma posição
  /// Considerando FOV e exploração
  String obterSimbolo(Pos pos, Pos jogador) {
    if (pos.x == jogador.x && pos.y == jogador.y) {
      return '@';
    }

    var tile = tiles[pos.y][pos.x];

    if (tile.visivel) {
      return tile.simbolo;
    } else if (tile.explorado) {
      return '░';
    } else {
      return ' ';
    }
  }
}

/// Alternativa: FOV circular (distância euclidiana)
/// Para comparação
class MapaComFOVCircular {
  final int largura;
  final int altura;
  final double raioVis = 3.5; // Raio de visão (distância euclidiana)
  late List<List<Tile>> tiles;

  MapaComFOVCircular({required this.largura, required this.altura}) {
    _inicializarMapa();
  }

  void _inicializarMapa() {
    tiles = [];
    for (var y = 0; y < altura; y++) {
      var linha = <Tile>[];
      for (var x = 0; x < largura; x++) {
        var simbolo = (x + y) % 3 == 0 ? '#' : '.';
        linha.add(Tile(simbolo: simbolo));
      }
      tiles.add(linha);
    }
  }

  /// Usar distância euclidiana em vez de Manhattan
  void atualizarFOV(Pos jogador) {
    for (var y = 0; y < altura; y++) {
      for (var x = 0; x < largura; x++) {
        var dx = x - jogador.x;
        var dy = y - jogador.y;
        var dist = (dx * dx + dy * dy).toDouble().squareRoot();

        if (dist <= raioVis) {
          tiles[y][x].visivel = true;
          tiles[y][x].explorado = true;
        } else {
          tiles[y][x].visivel = false;
        }
      }
    }
  }
}
