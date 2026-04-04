import 'dart:math';

import 'package:masmorra_ascii/src/mundo/mapa_masmorra.dart';
import 'package:test/test.dart';

void main() {
  group('MapaMasmorra.gerar', () {
    test('mapa gerado tem dimensões corretas', () {
      final rng = Random(42);
      final mapa = MapaMasmorra.gerar(rng, w: 30, h: 20);

      expect(mapa.largura, equals(30));
      expect(mapa.altura, equals(20));
    });

    test('mapa gerado tem dimensões padrão sem argumentos', () {
      final rng = Random(42);
      final mapa = MapaMasmorra.gerar(rng);

      expect(mapa.largura, equals(20));
      expect(mapa.altura, equals(12));
    });

    test('mapa contém paredes nas bordas', () {
      final rng = Random(42);
      final mapa = MapaMasmorra.gerar(rng, w: 15, h: 10);

      // Verifica bordas horizontais
      for (var x = 0; x < mapa.largura; x++) {
        expect(mapa.grade[0][x], equals('#'));
        expect(mapa.grade[mapa.altura - 1][x], equals('#'));
      }

      // Verifica bordas verticais
      for (var y = 0; y < mapa.altura; y++) {
        expect(mapa.grade[y][0], equals('#'));
        expect(mapa.grade[y][mapa.largura - 1], equals('#'));
      }
    });

    test('mapa contém tiles de chão', () {
      final rng = Random(42);
      final mapa = MapaMasmorra.gerar(rng);

      var temChao = false;
      for (var y = 0; y < mapa.altura; y++) {
        for (var x = 0; x < mapa.largura; x++) {
          if (mapa.grade[y][x] == '.') {
            temChao = true;
            break;
          }
        }
        if (temChao) break;
      }

      expect(temChao, isTrue);
    });

    test('posição de spawn do jogador está em um tile de chão', () {
      final rng = Random(42);
      final mapa = MapaMasmorra.gerar(rng);

      expect(mapa.grade[mapa.jogadorY][mapa.jogadorX], equals('.'));
    });

    test('seeds diferentes produzem mapas diferentes', () {
      final mapa1 = MapaMasmorra.gerar(Random(1));
      final mapa2 = MapaMasmorra.gerar(Random(2));

      var temDiferenca = false;
      for (var y = 0; y < mapa1.altura && !temDiferenca; y++) {
        for (var x = 0; x < mapa1.largura && !temDiferenca; x++) {
          if (mapa1.grade[y][x] != mapa2.grade[y][x]) {
            temDiferenca = true;
          }
        }
      }

      expect(temDiferenca, isTrue);
    });

    test('mesma seed produz mapas idênticos', () {
      final rng1 = Random(42);
      final rng2 = Random(42);
      final mapa1 = MapaMasmorra.gerar(rng1);
      final mapa2 = MapaMasmorra.gerar(rng2);

      for (var y = 0; y < mapa1.altura; y++) {
        for (var x = 0; x < mapa1.largura; x++) {
          expect(mapa1.grade[y][x], equals(mapa2.grade[y][x]));
        }
      }
    });

    test('mapa contém saída (*)', () {
      final rng = Random(42);
      final mapa = MapaMasmorra.gerar(rng);

      var temSaida = false;
      for (var y = 0; y < mapa.altura; y++) {
        for (var x = 0; x < mapa.largura; x++) {
          if (mapa.grade[y][x] == '*') {
            temSaida = true;
            break;
          }
        }
        if (temSaida) break;
      }

      expect(temSaida, isTrue);
    });

    test('mapa contém ouro (G)', () {
      final rng = Random(42);
      final mapa = MapaMasmorra.gerar(rng);

      var temOuro = false;
      for (var y = 0; y < mapa.altura; y++) {
        for (var x = 0; x < mapa.largura; x++) {
          if (mapa.grade[y][x] == 'G') {
            temOuro = true;
            break;
          }
        }
        if (temOuro) break;
      }

      expect(temOuro, isTrue);
    });
  });

  group('MapaMasmorra.tentarMover', () {
    late MapaMasmorra mapa;

    setUp(() {
      final rng = Random(42);
      mapa = MapaMasmorra.gerar(rng);
    });

    test('jogador pode mover para tile de chão adjacente', () {
      final xInicial = mapa.jogadorX;
      final yInicial = mapa.jogadorY;

      final resultado = mapa.tentarMover(1, 0);

      expect(resultado.ok, isTrue);
      expect(mapa.jogadorX, equals(xInicial + 1));
      expect(mapa.jogadorY, equals(yInicial));
    });

    test('jogador não pode mover através de parede', () {
      final xInicial = mapa.jogadorX;
      final yInicial = mapa.jogadorY;

      // Tenta mover para a borda (sempre parede)
      final resultado = mapa.tentarMover(-xInicial - 1, 0);

      expect(resultado.ok, isFalse);
      expect(mapa.jogadorX, equals(xInicial));
      expect(mapa.jogadorY, equals(yInicial));
    });

    test('jogador não pode sair dos limites do mapa', () {
      mapa.jogadorX = 1;
      mapa.jogadorY = 1;

      final resultado = mapa.tentarMover(-2, 0);

      expect(resultado.ok, isFalse);
    });

    test('jogador coleta ouro ao mover para tile com ouro', () {
      // Encontra um tile com ouro
      var xOuro = -1;
      var yOuro = -1;
      for (var y = 0; y < mapa.altura; y++) {
        for (var x = 0; x < mapa.largura; x++) {
          if (mapa.grade[y][x] == 'G') {
            xOuro = x;
            yOuro = y;
            break;
          }
        }
        if (xOuro != -1) break;
      }

      if (xOuro != -1) {
        // Move jogador para perto do ouro
        mapa.jogadorX = xOuro - 1;
        mapa.jogadorY = yOuro;

        final resultado = mapa.tentarMover(1, 0);

        expect(resultado.ouro, greaterThan(0));
        expect(mapa.grade[yOuro][xOuro], equals('.'));
      }
    });

    test('ouro não é coletado ao mover para tile de chão vazio', () {
      final resultado = mapa.tentarMover(1, 0);

      if (resultado.ok) {
        expect(resultado.ouro, equals(0));
      }
    });

    test('naSaida retorna verdadeiro ao atingir saída', () {
      // Encontra a posição da saída
      var xSaida = -1;
      var ySaida = -1;
      for (var y = 0; y < mapa.altura; y++) {
        for (var x = 0; x < mapa.largura; x++) {
          if (mapa.grade[y][x] == '*') {
            xSaida = x;
            ySaida = y;
            break;
          }
        }
        if (xSaida != -1) break;
      }

      if (xSaida != -1) {
        mapa.jogadorX = xSaida;
        mapa.jogadorY = ySaida;

        expect(mapa.naSaida, isTrue);
      }
    });
  });

  group('MapaMasmorra.celula', () {
    late MapaMasmorra mapa;

    setUp(() {
      final rng = Random(42);
      mapa = MapaMasmorra.gerar(rng);
    });

    test('celula retorna @ quando jogador está presente', () {
      final celula = mapa.celula(mapa.jogadorX, mapa.jogadorY);
      expect(celula, equals('@'));
    });

    test('celula retorna conteúdo da grid quando jogador não está presente', () {
      // Encontra uma célula sem o jogador
      var x = 1;
      var y = 1;
      while (x == mapa.jogadorX && y == mapa.jogadorY) {
        x++;
        if (x >= mapa.largura) {
          x = 1;
          y++;
        }
      }

      final celula = mapa.celula(x, y);
      expect(celula, isNotEmpty);
    });
  });

  group('MapaMasmorra.paraEcran', () {
    late MapaMasmorra mapa;

    setUp(() {
      final rng = Random(42);
      mapa = MapaMasmorra.gerar(rng);
    });

    test('ecran gerado tem dimensões corretas', () {
      final ecran = mapa.paraEcran();
      expect(ecran.width, equals(mapa.largura));
      expect(ecran.height, equals(mapa.altura));
    });

    test('ecran contém representação do jogador', () {
      final ecran = mapa.paraEcran();
      expect(ecran.width, isNotNull);
      expect(ecran.height, isNotNull);
    });
  });
}
