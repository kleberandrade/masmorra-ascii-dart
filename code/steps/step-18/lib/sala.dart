import 'dart:math';
import 'tile.dart';

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
        if (yy >= 0 && yy < grade.length && xx >= 0 && xx < grade[yy].length) {
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
