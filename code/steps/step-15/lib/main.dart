// bin/main.dart - Ponto de entrada do jogo

import 'dart:io';
import 'package:step_15_grid_2d/mapa_masmorra.dart';
import 'package:step_15_grid_2d/tile.dart';

void main() {
  final mapa = MapaMasmorra(largura: 20, altura: 10);

  // Desenhar borda
  for (int y = 0; y < 10; y++) {
    for (int x = 0; x < 20; x++) {
      if (x == 0 || x == 19 || y == 0 || y == 9) {
        mapa.definirTile(x, y, Tile.parede);
      }
    }
  }

  // Parede interna em forma de T
  for (int y = 2; y <= 7; y++) {
    mapa.definirTile(10, y, Tile.parede);
  }
  mapa.definirTile(10, 4, Tile.porta);

  // Escadas no canto
  mapa.definirTile(18, 8, Tile.escadaDesce);

  final jogador = Jogador(
    nome: 'Aldric',
    hpMax: 100,
    ouro: 50,
  );

  print('=== Bem-vindo à Masmorra ASCII ===\n');

  bool rodando = true;
  while (rodando) {
    mapa.renderizarComJogador(jogador);

    stdout.write('Comando> ');
    final entrada = stdin.readLineSync() ?? '';

    switch (entrada.toLowerCase()) {
      case 'w' || 'a' || 's' || 'd':
        jogador.moverEmDirecao(entrada, mapa);
      case 'q':
        print('Adeus, ${jogador.nome}!');
        rodando = false;
      default:
        if (entrada.isNotEmpty) {
          print('Inválido: $entrada');
        }
    }
  }
}
