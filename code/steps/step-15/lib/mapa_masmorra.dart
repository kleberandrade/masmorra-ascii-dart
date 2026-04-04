// mapa_masmorra.dart - Estrutura do mapa com grade 2D

import 'dart:io';
import 'tile.dart';

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

  void renderizarComJogador(Jogador jogador) {
    print('\n╔════════════════════════════════════════╗');
    print('║         EXPLORAÇÃO DA MASMORRA         ║');
    print('╠════════════════════════════════════════╣');

    for (int y = 0; y < altura; y++) {
      stdout.write('║ ');
      for (int x = 0; x < largura; x++) {
        if (x == jogador.x && y == jogador.y) {
          stdout.write('@');
        } else {
          stdout.write(tileParaChar(tileEm(x, y)));
        }
      }
      stdout.write(' ║\n');
    }

    print('╠════════════════════════════════════════╣');
    print('${'║ Posição: (${jogador.x}, ${jogador.y}) | HP: ${jogador.hpAtual}/${jogador.hpMax}'
        .padRight(40)}║');
    print('${'║ [W]cima [A]esq [S]baixo [D]dir [Q]uit'
        .padRight(40)}║');
    print('╚════════════════════════════════════════╝\n');
  }
}

class Jogador {
  String nome;
  int hpMax;
  int hpAtual;
  int ouro;
  int x = 5;
  int y = 5;

  Jogador({
    required this.nome,
    required this.hpMax,
    required this.ouro,
  }) : hpAtual = hpMax;

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
