import 'dart:math';
import 'tile.dart';
import 'tela_ascii.dart';
import 'rolador.dart';

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
    required String nome,
    required int x,
    required int y,
    required this.hpMax,
    required this.ouro,
  })  : hpAtual = hpMax,
        super(x: x, y: y, simbolo: '@', nome: nome);

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
    required String nome,
    required int x,
    required int y,
    required this.hpMax,
    required String simbolo,
  })  : hpAtual = hpMax,
        super(x: x, y: y, simbolo: simbolo, nome: nome);
}

class Item extends Entidade {
  Item({
    required String nome,
    required int x,
    required int y,
  }) : super(x: x, y: y, simbolo: '!', nome: nome);
}

class SessaoJogo {
  final MapaMasmorra mapa;
  final Jogador jogador;
  final List<Inimigo> inimigos = [];
  final List<Item> itens = [];
  final TelaAscii tela;
  final Random random;

  int turnoAtual = 0;

  SessaoJogo({
    required this.mapa,
    required this.jogador,
    required this.tela,
    int? seed,
  }) : random = Random(seed ?? DateTime.now().millisecondsSinceEpoch);

  void gerarItens(int quantidade) {
    int gerados = 0;
    while (gerados < quantidade) {
      final x = random.nextInt(mapa.largura);
      final y = random.nextInt(mapa.altura);

      if (mapa.ehPassavel(x, y) && !(x == jogador.x && y == jogador.y)) {
        itens.add(Item(
          nome: _gerarNomeItem(),
          x: x,
          y: y,
        ));
        gerados++;
      }
    }
  }

  String _gerarNomeItem() {
    final nomes = ['Ouro', 'Poção', 'Gema', 'Anel', 'Escudo'];
    return nomes[random.nextInt(nomes.length)];
  }

  void gerarInimigos(int quantidade, int minDistancia) {
    int gerados = 0;
    while (gerados < quantidade) {
      final x = random.nextInt(mapa.largura);
      final y = random.nextInt(mapa.altura);

      final distancia = ((x - jogador.x).abs() + (y - jogador.y).abs());
      if (distancia < minDistancia) continue;

      if (mapa.ehPassavel(x, y)) {
        final tipo = _gerarTipoInimigo();
        inimigos.add(Inimigo(
          nome: tipo,
          x: x,
          y: y,
          hpMax: _hpPorTipo(tipo),
          simbolo: _simboloPorTipo(tipo),
        ));
        gerados++;
      }
    }
  }

  String _gerarTipoInimigo() {
    final tipos = ['Zumbi', 'Lobo', 'Orc', 'Orc'];
    return tipos[random.nextInt(tipos.length)];
  }

  int _hpPorTipo(String tipo) {
    return switch (tipo) {
      'Zumbi' => 20,
      'Lobo' => 40,
      'Orc' => 60,
      _ => 25,
    };
  }

  String _simboloPorTipo(String tipo) {
    return switch (tipo) {
      'Zumbi' => 'Z',
      'Lobo' => 'L',
      'Orc' => 'O',
      _ => '?',
    };
  }

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
    mapa.renderizarNaTela(tela);
    for (final item in itens) {
      item.renderizarNaTela(tela);
    }
    for (final inimigo in inimigos) {
      inimigo.renderizarNaTela(tela);
    }
    jogador.renderizarNaTela(tela);
    renderizarHUD();
    tela.renderizar();
  }
}
