import 'dart:math';
import 'tile.dart';
import 'tela_ascii.dart';
import 'sala.dart';
import 'validador_salas.dart';
import 'conector_corredores.dart';

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
      (y) => List<Tile>.generate(largura, (x) => Tile.parede),
    );
  }

  static MapaMasmorra comRandomWalk({
    required int largura,
    required int altura,
    required Random random,
    required int numPassos,
  }) {
    final mapa = MapaMasmorra(largura: largura, altura: altura);
    int x = largura ~/ 2;
    int y = altura ~/ 2;
    mapa._tiles[y][x] = Tile.chao;

    for (int passo = 0; passo < numPassos; passo++) {
      final direcao = random.nextInt(4);
      switch (direcao) {
        case 0:
          if (y > 1) y--;
        case 1:
          if (y < altura - 2) y++;
        case 2:
          if (x < largura - 2) x++;
        case 3:
          if (x > 1) x--;
      }
      mapa._tiles[y][x] = Tile.chao;
    }

    return mapa;
  }

  static MapaMasmorra comSalasECorredores({
    required int largura,
    required int altura,
    required Random random,
    required int numSalas,
    int minTamanho = 5,
    int maxTamanho = 12,
  }) {
    final mapa = MapaMasmorra(largura: largura, altura: altura);
    final salas = <Sala>[];

    // Usar ValidadorSalas para colocação inteligente de salas
    final validador = ValidadorSalas();
    validador.colocarSalasAleatorias(
      salas,
      numSalas,
      random,
      largura,
      altura,
      minTamanho: minTamanho,
      maxTamanho: maxTamanho,
    );

    // Garantir ao menos uma sala fallback
    if (salas.isEmpty) {
      salas.add(Sala(x: 5, y: 5, largura: 8, altura: 8));
    }

    // Desenhar todas as salas
    for (final sala in salas) {
      sala.desenharNa(mapa._tiles);
    }

    // Usar ConectorCorredores para conectar salas via Árvore Geradora Mínima
    final conector = ConectorCorredores();
    conector.conectarTodasAsSalas(salas, mapa._tiles);

    return mapa;
  }

  Tile tileEm(int x, int y) {
    if (x < 0 || x >= largura || y < 0 || y >= altura) return Tile.parede;
    return _tiles[y][x];
  }

  void definirTile(int x, int y, Tile tile) {
    if (x < 0 || x >= largura || y < 0 || y >= altura) return;
    _tiles[y][x] = tile;
  }

  bool ehPassavel(int x, int y) => tileEm(x, y) != Tile.parede;

  void renderizarNaTela(TelaAscii tela) {
    for (int y = 0; y < altura; y++) {
      for (int x = 0; x < largura; x++) {
        tela.desenharChar(x, y, tileParaChar(tileEm(x, y)));
      }
    }
  }
}

abstract class Entidade {
  int x;
  int y;
  String simbolo;
  String nome;

  Entidade({
    required this.x,
    required this.y,
    required this.simbolo,
    required this.nome,
  });

  void renderizarNaTela(TelaAscii tela) {
    tela.desenharChar(x, y, simbolo);
  }
}

class Jogador extends Entidade {
  int hpMax;
  int hpAtual;
  int ouro;

  Jogador({
    required super.nome,
    required super.x,
    required super.y,
    required this.hpMax,
    required this.ouro,
  })  : hpAtual = hpMax,
        super(simbolo: '@');

  bool mover(int novoX, int novoY, MapaMasmorra mapa) {
    if (!mapa.ehPassavel(novoX, novoY)) return false;
    x = novoX;
    y = novoY;
    return true;
  }

  void moverEmDirecao(String direcao, MapaMasmorra mapa) {
    int novoX = x, novoY = y;
    switch (direcao.toLowerCase()) {
      case 'w':
        novoY--;
      case 's':
        novoY++;
      case 'a':
        novoX--;
      case 'd':
        novoX++;
      default:
        return;
    }
    mover(novoX, novoY, mapa);
  }
}

class Inimigo extends Entidade {
  int hpMax;
  int hpAtual;

  Inimigo({
    required super.nome,
    required super.x,
    required super.y,
    required this.hpMax,
    required super.simbolo,
  })  : hpAtual = hpMax;
}

class Item extends Entidade {
  Item({
    required super.nome,
    required super.x,
    required super.y,
  }) : super(simbolo: '!');
}

class SessaoJogo {
  final MapaMasmorra mapa;
  final Jogador jogador;
  final List<Inimigo> inimigos = [];
  final List<Item> itens = [];
  final TelaAscii tela;

  int turnoAtual = 0;

  SessaoJogo({
    required this.mapa,
    required this.jogador,
    required this.tela,
  });

  void renderizarFrame() {
    tela.limpar();
    mapa.renderizarNaTela(tela);

    for (final item in itens) {
      item.renderizarNaTela(tela);
    }
    for (final inimigo in inimigos) {
      inimigo.renderizarNaTela(tela);
    }
    jogador.renderizarNaTela(tela);

    final hudY = mapa.altura + 1;
    tela.desenharString(0, hudY, '═' * tela.largura);
    tela.desenharString(
      0,
      hudY + 1,
      'Turno: $turnoAtual | HP: ${jogador.hpAtual}/${jogador.hpMax}',
    );
    tela.desenharString(0, hudY + 2, '[W]cima [A]esq [S]baixo [D]dir [Q]uit');

    tela.renderizar();
  }
}
