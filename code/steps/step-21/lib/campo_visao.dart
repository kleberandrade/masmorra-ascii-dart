import 'dart:math';
import 'tile.dart';

class CampoVisao {
  final Set<Point<int>> tileVisiveis = {};
  final Set<Point<int>> tileExplorados = {};

  void limpar() {
    tileVisiveis.clear();
  }

  bool estaVisivel(int x, int y) {
    return tileVisiveis.contains(Point(x, y));
  }

  bool foiExplorado(int x, int y) {
    return tileExplorados.contains(Point(x, y));
  }

  void marcarExplorado(int x, int y) {
    tileExplorados.add(Point(x, y));
  }

  void marcarVisivel(int x, int y) {
    tileVisiveis.add(Point(x, y));
    marcarExplorado(x, y);
  }

  void calcularShadowcast(
    Point<int> origem,
    int raio,
    MapaMasmorra mapa,
  ) {
    limpar();
    marcarVisivel(origem.x, origem.y);

    final direcoes = [
      (1, 0), (1, 1), (0, 1), (-1, 1),
      (-1, 0), (-1, -1), (0, -1), (1, -1),
    ];

    for (final (dx, dy) in direcoes) {
      _lancarRaio(origem.x, origem.y, dx, dy, raio, mapa);
    }
  }

  void _lancarRaio(
    int ox,
    int oy,
    int dx,
    int dy,
    int raio,
    MapaMasmorra mapa,
  ) {
    for (int passo = 1; passo <= raio; passo++) {
      final x = ox + dx * passo;
      final y = oy + dy * passo;

      if (x < 0 || x >= mapa.largura || y < 0 || y >= mapa.altura) {
        break;
      }

      marcarVisivel(x, y);

      if (mapa.tileEm(x, y) == Tile.parede) {
        break;
      }
    }
  }
}

class MapaMasmorra {
  final int largura;
  final int altura;
  late List<List<Tile>> _tiles;
  late CampoVisao fov;

  MapaMasmorra({required this.largura, required this.altura}) {
    _inicializarGrade();
    fov = CampoVisao();
  }

  void _inicializarGrade() {
    _tiles = List<List<Tile>>.generate(
      altura,
      (y) => List<Tile>.generate(largura, (x) => Tile.chao),
    );
  }

  static MapaMasmorra gerar({
    required int largura,
    required int altura,
  }) {
    final mapa = MapaMasmorra(largura: largura, altura: altura);

    // Borda de paredes
    for (int y = 0; y < altura; y++) {
      for (int x = 0; x < largura; x++) {
        if (x == 0 || x == largura - 1 || y == 0 || y == altura - 1) {
          mapa.definirTile(x, y, Tile.parede);
        }
      }
    }

    // Paredes internas aleatórias
    for (int i = 0; i < 10; i++) {
      final x = 5 + i * 6;
      for (int y = 3; y < altura - 3; y++) {
        mapa.definirTile(x, y, Tile.parede);
      }
      mapa.definirTile(x, altura ~/ 2, Tile.chao);
    }

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
}
