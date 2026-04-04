// Capítulo 21 - Boss Final: Cores ANSI para Tiles
// Descrição: Adiciona cores ANSI ao TelaAscii.
// Verde para chão, cinza para paredes, vermelho para inimigos, etc.

import 'dart:io';

// Códigos ANSI para cores
class CoresANSI {
  static const reset = '\x1B[0m';
  static const verde = '\x1B[32m';
  static const cinza = '\x1B[37m';
  static const vermelho = '\x1B[31m';
  static const amarelo = '\x1B[33m';
  static const azul = '\x1B[34m';
  static const branco = '\x1B[37m';
  static const magenta = '\x1B[35m';

  // Versões em negrito
  static const negritoverde = '\x1B[1;32m';
  static const negritovermelho = '\x1B[1;31m';
  static const negritoreset = '\x1B[1;0m';
}

enum TileMapa {
  parede,
  chao,
  agua,
  escada,
}

class TelaASCIIColorida {
  final int largura;
  final int altura;
  late List<List<String>> _buffer;
  late List<List<String>> _cores;

  TelaASCIIColorida({required this.largura, required this.altura}) {
    _inicializarBuffer();
  }

  void _inicializarBuffer() {
    _buffer = List<List<String>>.generate(
      altura,
      (y) => List<String>.generate(largura, (x) => ' '),
    );
    _cores = List<List<String>>.generate(
      altura,
      (y) => List<String>.generate(largura, (x) => CoresANSI.reset),
    );
  }

  void limpar() {
    for (int y = 0; y < altura; y++) {
      for (int x = 0; x < largura; x++) {
        _buffer[y][x] = ' ';
        _cores[y][x] = CoresANSI.reset;
      }
    }
  }

  void desenharChar(int x, int y, String char, String cor) {
    if (x < 0 || x >= largura || y < 0 || y >= altura) {
      return;
    }
    _buffer[y][x] = char;
    _cores[y][x] = cor;
  }

  void desenharString(int x, int y, String texto, String cor) {
    for (int i = 0; i < texto.length; i++) {
      final charX = x + i;
      if (charX >= largura) break;
      desenharChar(charX, y, texto[i], cor);
    }
  }

  void renderizar() {
    stdout.write('\x1B[2J\x1B[H'); // Limpar tela ANSI

    final sb = StringBuffer();
    for (int y = 0; y < altura; y++) {
      for (int x = 0; x < largura; x++) {
        sb.write(_cores[y][x]);
        sb.write(_buffer[y][x]);
        sb.write(CoresANSI.reset);
      }
      sb.write('\n');
    }

    stdout.write(sb.toString());
  }

  String obterChar(int x, int y) {
    if (x < 0 || x >= largura || y < 0 || y >= altura) {
      return ' ';
    }
    return _buffer[y][x];
  }
}

class MapaColorido {
  final int largura;
  final int altura;
  late List<List<TileMapa>> _tiles;
  late TelaASCIIColorida tela;

  MapaColorido({required this.largura, required this.altura}) {
    _inicializar();
    tela = TelaASCIIColorida(largura: largura, altura: altura);
  }

  void _inicializar() {
    _tiles = List.generate(
      altura,
      (y) => List.generate(
        largura,
        (x) {
          if (x == 0 || x == largura - 1 || y == 0 || y == altura - 1) {
            return TileMapa.parede;
          }
          if (x > 5 && x < 10 && y > 5 && y < 10) {
            return TileMapa.agua;
          }
          if (x == largura - 3 && y == altura - 3) {
            return TileMapa.escada;
          }
          return TileMapa.chao;
        },
      ),
    );
  }

  TileMapa obterTile(int x, int y) {
    if (x < 0 || x >= largura || y < 0 || y >= altura) {
      return TileMapa.parede;
    }
    return _tiles[y][x];
  }

  String tileParaChar(TileMapa tile) {
    return switch (tile) {
      TileMapa.parede => '#',
      TileMapa.chao => '.',
      TileMapa.agua => '~',
      TileMapa.escada => '>',
    };
  }

  String obtercorParaTile(TileMapa tile) {
    return switch (tile) {
      TileMapa.parede => CoresANSI.cinza, // Paredes: cinza
      TileMapa.chao => CoresANSI.verde, // Chão: verde
      TileMapa.agua => CoresANSI.azul, // Água: azul
      TileMapa.escada => CoresANSI.amarelo, // Escada: amarelo
    };
  }

  void renderizar() {
    tela.limpar();

    // Desenhar mapa com cores
    for (int y = 0; y < altura; y++) {
      for (int x = 0; x < largura; x++) {
        final tile = obterTile(x, y);
        final char = tileParaChar(tile);
        final cor = obtercorParaTile(tile);
        tela.desenharChar(x, y, char, cor);
      }
    }

    // Desenhar jogador em verde negrito
    tela.desenharChar(15, 12, '@', CoresANSI.negritoverde);

    // Desenhar inimigos em vermelho negrito
    tela.desenharChar(5, 3, 'G', CoresANSI.negritovermelho);
    tela.desenharChar(20, 8, 'O', CoresANSI.negritovermelho);

    // Desenhar item em amarelo
    tela.desenharChar(12, 10, '!', CoresANSI.amarelo);

    // HUD
    _renderizarHUD();

    tela.renderizar();
  }

  void _renderizarHUD() {
    final hudY = altura - 3;
    final linhaHUD = '═' * largura;

    tela.desenharString(0, hudY, linhaHUD, CoresANSI.branco);
    tela.desenharString(
      0,
      hudY + 1,
      'HP: [████░░░░] 60/100 | Ouro: 150 | Turno: 42',
      CoresANSI.branco,
    );
    tela.desenharString(
      0,
      hudY + 2,
      '[W]cima [A]esq [S]baixo [D]dir [Q]uit',
      CoresANSI.branco,
    );
  }
}

void demonstrarcoresANSI() {
  print('=== Boss Final Cap 21: Cores ANSI para Tiles ===\n');

  // Mostrar legenda de cores
  print('LEGENDA DE CORES:');
  print('${CoresANSI.verde}●${CoresANSI.reset} Chão (verde)');
  print('${CoresANSI.cinza}●${CoresANSI.reset} Parede (cinza)');
  print('${CoresANSI.azul}●${CoresANSI.reset} Água (azul)');
  print('${CoresANSI.amarelo}●${CoresANSI.reset} Escada (amarelo)');
  print('${CoresANSI.negritoverde}●${CoresANSI.reset} Jogador (verde negrito)');
  print('${CoresANSI.negritovermelho}●${CoresANSI.reset} Inimigos (vermelho negrito)');
  print('');

  sleep(Duration(seconds: 1));

  // Criar mapa colorido
  final mapa = MapaColorido(largura: 40, altura: 20);

  print('Renderizando mapa com cores...\n');
  sleep(Duration(milliseconds: 500));

  mapa.renderizar();

  print('\n✓ Mapa renderizado com cores ANSI!');
  print('  Verde = chão explorado');
  print('  Cinza = paredes');
  print('  Azul = água/obstáculo');
  print('  Amarelo = escada descendente');
  print('  @ em verde negrito = jogador');
  print('  G, O em vermelho = inimigos\n');
}

void main() {
  demonstrarcoresANSI();
}
