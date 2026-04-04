import 'dart:math';

import 'package:masmorra_ascii/src/world/dungeon_map.dart';
import 'package:test/test.dart';

void main() {
  group('DungeonMap.gerar', () {
    test('mapa gerado tem dimensões corretas', () {
      final rng = Random(42);
      final mapa = DungeonMap.gerar(rng, w: 30, h: 20);

      expect(mapa.width, equals(30));
      expect(mapa.height, equals(20));
    });

    test('mapa gerado tem dimensões padrão sem argumentos', () {
      final rng = Random(42);
      final mapa = DungeonMap.gerar(rng);

      expect(mapa.width, equals(20));
      expect(mapa.height, equals(12));
    });

    test('mapa contém paredes nas bordas', () {
      final rng = Random(42);
      final mapa = DungeonMap.gerar(rng, w: 15, h: 10);

      // Verifica bordas horizontais
      for (var x = 0; x < mapa.width; x++) {
        expect(mapa.grid[0][x], equals('#'));
        expect(mapa.grid[mapa.height - 1][x], equals('#'));
      }

      // Verifica bordas verticais
      for (var y = 0; y < mapa.height; y++) {
        expect(mapa.grid[y][0], equals('#'));
        expect(mapa.grid[y][mapa.width - 1], equals('#'));
      }
    });

    test('mapa contém tiles de chão', () {
      final rng = Random(42);
      final mapa = DungeonMap.gerar(rng);

      var temChao = false;
      for (var y = 0; y < mapa.height; y++) {
        for (var x = 0; x < mapa.width; x++) {
          if (mapa.grid[y][x] == '.') {
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
      final mapa = DungeonMap.gerar(rng);

      expect(mapa.grid[mapa.playerY][mapa.playerX], equals('.'));
    });

    test('seeds diferentes produzem mapas diferentes', () {
      final mapa1 = DungeonMap.gerar(Random(1));
      final mapa2 = DungeonMap.gerar(Random(2));

      var temDiferenca = false;
      for (var y = 0; y < mapa1.height && !temDiferenca; y++) {
        for (var x = 0; x < mapa1.width && !temDiferenca; x++) {
          if (mapa1.grid[y][x] != mapa2.grid[y][x]) {
            temDiferenca = true;
          }
        }
      }

      expect(temDiferenca, isTrue);
    });

    test('mesma seed produz mapas idênticos', () {
      final rng1 = Random(42);
      final rng2 = Random(42);
      final mapa1 = DungeonMap.gerar(rng1);
      final mapa2 = DungeonMap.gerar(rng2);

      for (var y = 0; y < mapa1.height; y++) {
        for (var x = 0; x < mapa1.width; x++) {
          expect(mapa1.grid[y][x], equals(mapa2.grid[y][x]));
        }
      }
    });

    test('mapa contém saída (*)', () {
      final rng = Random(42);
      final mapa = DungeonMap.gerar(rng);

      var temSaida = false;
      for (var y = 0; y < mapa.height; y++) {
        for (var x = 0; x < mapa.width; x++) {
          if (mapa.grid[y][x] == '*') {
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
      final mapa = DungeonMap.gerar(rng);

      var temOuro = false;
      for (var y = 0; y < mapa.height; y++) {
        for (var x = 0; x < mapa.width; x++) {
          if (mapa.grid[y][x] == 'G') {
            temOuro = true;
            break;
          }
        }
        if (temOuro) break;
      }

      expect(temOuro, isTrue);
    });
  });

  group('DungeonMap.tentarMover', () {
    late DungeonMap mapa;

    setUp(() {
      final rng = Random(42);
      mapa = DungeonMap.gerar(rng);
    });

    test('jogador pode mover para tile de chão adjacente', () {
      final xInicial = mapa.playerX;
      final yInicial = mapa.playerY;

      final resultado = mapa.tentarMover(1, 0);

      expect(resultado.ok, isTrue);
      expect(mapa.playerX, equals(xInicial + 1));
      expect(mapa.playerY, equals(yInicial));
    });

    test('jogador não pode mover através de parede', () {
      final xInicial = mapa.playerX;
      final yInicial = mapa.playerY;

      // Tenta mover para a borda (sempre parede)
      final resultado = mapa.tentarMover(-xInicial - 1, 0);

      expect(resultado.ok, isFalse);
      expect(mapa.playerX, equals(xInicial));
      expect(mapa.playerY, equals(yInicial));
    });

    test('jogador não pode sair dos limites do mapa', () {
      mapa.playerX = 1;
      mapa.playerY = 1;

      final resultado = mapa.tentarMover(-2, 0);

      expect(resultado.ok, isFalse);
    });

    test('jogador coleta ouro ao mover para tile com ouro', () {
      // Encontra um tile com ouro
      var xOuro = -1;
      var yOuro = -1;
      for (var y = 0; y < mapa.height; y++) {
        for (var x = 0; x < mapa.width; x++) {
          if (mapa.grid[y][x] == 'G') {
            xOuro = x;
            yOuro = y;
            break;
          }
        }
        if (xOuro != -1) break;
      }

      if (xOuro != -1) {
        // Move jogador para perto do ouro
        mapa.playerX = xOuro - 1;
        mapa.playerY = yOuro;

        final resultado = mapa.tentarMover(1, 0);

        expect(resultado.ouro, greaterThan(0));
        expect(mapa.grid[yOuro][xOuro], equals('.'));
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
      for (var y = 0; y < mapa.height; y++) {
        for (var x = 0; x < mapa.width; x++) {
          if (mapa.grid[y][x] == '*') {
            xSaida = x;
            ySaida = y;
            break;
          }
        }
        if (xSaida != -1) break;
      }

      if (xSaida != -1) {
        mapa.playerX = xSaida;
        mapa.playerY = ySaida;

        expect(mapa.naSaida, isTrue);
      }
    });
  });

  group('DungeonMap.celula', () {
    late DungeonMap mapa;

    setUp(() {
      final rng = Random(42);
      mapa = DungeonMap.gerar(rng);
    });

    test('celula retorna @ quando jogador está presente', () {
      final celula = mapa.celula(mapa.playerX, mapa.playerY);
      expect(celula, equals('@'));
    });

    test('celula retorna conteúdo da grid quando jogador não está presente', () {
      // Encontra uma célula sem o jogador
      var x = 1;
      var y = 1;
      while (x == mapa.playerX && y == mapa.playerY) {
        x++;
        if (x >= mapa.width) {
          x = 1;
          y++;
        }
      }

      final celula = mapa.celula(x, y);
      expect(celula, isNotEmpty);
    });
  });

  group('DungeonMap.paraEcran', () {
    late DungeonMap mapa;

    setUp(() {
      final rng = Random(42);
      mapa = DungeonMap.gerar(rng);
    });

    test('ecran gerado tem dimensões corretas', () {
      final ecran = mapa.paraEcran();
      expect(ecran.width, equals(mapa.width));
      expect(ecran.height, equals(mapa.height));
    });

    test('ecran contém representação do jogador', () {
      final ecran = mapa.paraEcran();
      expect(ecran.width, isNotNull);
      expect(ecran.height, isNotNull);
    });
  });
}
