// dungeon.dart - Mapa e entidades

import 'tile.dart';
import 'tela_ascii.dart';

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
    if (x < 0 || x >= largura || y < 0 || y >= altura) {
      return Tile.parede;
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

  void renderizarNaTela(TelaAscii tela) {
    for (int y = 0; y < altura; y++) {
      for (int x = 0; x < largura; x++) {
        final tile = tileEm(x, y);
        tela.desenharChar(x, y, tileParaChar(tile));
      }
    }
  }
}

abstract class Entidade {
  int x;
  int y;
  String simbolo;

  Entidade({required this.x, required this.y, required this.simbolo});

  void renderizarNaTela(TelaAscii tela) {
    tela.desenharChar(x, y, simbolo);
  }
}

class Jogador extends Entidade {
  String nome;
  int hpMax;
  int hpAtual;
  int ouro;

  Jogador({
    required this.nome,
    required int x,
    required int y,
    required this.hpMax,
    required this.ouro,
  })  : hpAtual = hpMax,
        super(x: x, y: y, simbolo: '@');

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
  String nome;
  int hpMax;
  int hpAtual;

  Inimigo({
    required this.nome,
    required int x,
    required int y,
    required this.hpMax,
    required String simbolo,
  })  : hpAtual = hpMax,
        super(x: x, y: y, simbolo: simbolo);
}

class Item extends Entidade {
  String nome;

  Item({
    required this.nome,
    required int x,
    required int y,
  }) : super(x: x, y: y, simbolo: '!');
}

class SessaoJogo {
  final MapaMasmorra mapa;
  final Jogador jogador;
  final List<Inimigo> inimigos;
  final List<Item> itens;
  final TelaAscii tela;

  int turnoAtual = 0;

  SessaoJogo({
    required this.mapa,
    required this.jogador,
    required this.inimigos,
    required this.itens,
    required this.tela,
  });

  String _construirBarraHP(int atual, int maximo) {
    const totalBlocos = 10;
    final blocos = (atual / maximo * totalBlocos).toInt();
    final cheios = '█' * blocos;
    final vazios = '░' * (totalBlocos - blocos);
    return '$cheios$vazios';
  }

  void renderizarHUD() {
    final hudY = mapa.altura + 1;

    tela.desenharString(0, hudY, '═' * tela.largura);

    final hpBar = _construirBarraHP(jogador.hpAtual, jogador.hpMax);
    final linha1 = 'HP: $hpBar ${jogador.hpAtual}/${jogador.hpMax} | '
        'Ouro: ${jogador.ouro} | Turno: $turnoAtual';
    tela.desenharString(0, hudY + 1, linha1);

    final linha2 = '[W]cima [A]esq [S]baixo [D]dir [Q]uit';
    tela.desenharString(0, hudY + 2, linha2);

    tela.desenharString(0, hudY + 3, '═' * tela.largura);
  }

  void renderizarFrame() {
    tela.limpar();

    // Camada 1: Mapa
    mapa.renderizarNaTela(tela);

    // Camada 2: Itens
    for (final item in itens) {
      item.renderizarNaTela(tela);
    }

    // Camada 3: Inimigos
    for (final inimigo in inimigos) {
      inimigo.renderizarNaTela(tela);
    }

    // Camada 4: Jogador (no topo)
    jogador.renderizarNaTela(tela);

    // Camada 5: HUD
    renderizarHUD();

    // Enviar tudo para tela
    tela.renderizar();
  }
}
