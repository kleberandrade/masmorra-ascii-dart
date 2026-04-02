import 'dart:math';

import '../ascii_screen.dart';

/// Caps. 15–18 — grade simples e geração por *random walk*.
class DungeonMap {
  DungeonMap._(this.width, this.height, this.grid, this.playerX, this.playerY);

  final int width;
  final int height;
  final List<List<String>> grid;
  int playerX;
  int playerY;

  static const _parede = '#';
  static const _chao = '.';
  static const _ouro = 'G';
  static const _saida = '*';

  factory DungeonMap.gerar(Random rng, {int w = 20, int h = 12}) {
    final g = List.generate(h, (_) => List<String>.filled(w, _parede));
    var x = w ~/ 2;
    var y = h ~/ 2;
    for (var i = 0; i < 160; i++) {
      g[y][x] = _chao;
      final d = rng.nextInt(4);
      if (d == 0) {
        x = (x + 1).clamp(1, w - 2);
      } else if (d == 1) {
        x = (x - 1).clamp(1, w - 2);
      } else if (d == 2) {
        y = (y + 1).clamp(1, h - 2);
      } else {
        y = (y - 1).clamp(1, h - 2);
      }
    }
    g[y][x] = _chao;
    for (var k = 0; k < 6; k++) {
      final fx = 1 + rng.nextInt(w - 2);
      final fy = 1 + rng.nextInt(h - 2);
      if (g[fy][fx] == _chao) {
        g[fy][fx] = _ouro;
      }
    }
    g[y][x] = _saida;
    var px = w ~/ 2;
    var py = h ~/ 2;
    for (var t = 0; t < 80 && g[py][px] != _chao; t++) {
      px = 1 + rng.nextInt(w - 2);
      py = 1 + rng.nextInt(h - 2);
    }
    return DungeonMap._(w, h, g, px, py);
  }

  String celula(int x, int y) {
    if (x == playerX && y == playerY) {
      return '@';
    }
    return grid[y][x];
  }

  /// `ok == false` se bloqueado; `ouro` moedas recolhidas neste passo.
  ({bool ok, int ouro}) tentarMover(int dx, int dy) {
    final nx = playerX + dx;
    final ny = playerY + dy;
    if (nx < 0 || ny < 0 || nx >= width || ny >= height) {
      return (ok: false, ouro: 0);
    }
    final c = grid[ny][nx];
    if (c == _parede) {
      return (ok: false, ouro: 0);
    }
    var ouro = 0;
    if (c == _ouro) {
      ouro = 3;
    }
    playerX = nx;
    playerY = ny;
    if (c == _ouro) {
      grid[ny][nx] = _chao;
    }
    return (ok: true, ouro: ouro);
  }

  bool get naSaida => grid[playerY][playerX] == _saida;

  AsciiScreen paraEcran() {
    final scr = AsciiScreen(width: width, height: height);
    scr.clear(_parede);
    for (var yy = 0; yy < height; yy++) {
      for (var xx = 0; xx < width; xx++) {
        scr.write(xx, yy, celula(xx, yy));
      }
    }
    return scr;
  }
}
