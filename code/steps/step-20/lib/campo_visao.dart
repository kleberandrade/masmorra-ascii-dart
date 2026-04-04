import 'dart:math';
import 'mapa_masmorra.dart';
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
