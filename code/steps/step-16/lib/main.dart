// bin/main.dart - Step 16

import 'dart:io';
import 'package:step_16_tela_ascii/mapa_masmorra.dart';
import 'package:step_16_tela_ascii/tela_ascii.dart';
import 'package:step_16_tela_ascii/tile.dart';

void main() {
  final mapa = MapaMasmorra(largura: 30, altura: 15);

  // Construir mapa
  for (int y = 0; y < 15; y++) {
    for (int x = 0; x < 30; x++) {
      if (x == 0 || x == 29 || y == 0 || y == 14) {
        mapa.definirTile(x, y, Tile.parede);
      }
    }
  }

  for (int y = 5; y <= 10; y++) {
    mapa.definirTile(15, y, Tile.parede);
  }

  final jogador = Jogador(
    nome: 'Aldric',
    x: 5,
    y: 5,
    hpMax: 100,
    ouro: 50,
  );

  final inimigos = [
    Inimigo(
      nome: 'Zumbi',
      x: 20,
      y: 10,
      hpMax: 30,
      simbolo: 'G',
    ),
    Inimigo(
      nome: 'Lobo',
      x: 10,
      y: 8,
      hpMax: 50,
      simbolo: 'S',
    ),
  ];

  final itens = [
    Item(nome: 'Ouro', x: 15, y: 5),
    Item(nome: 'Poção', x: 25, y: 12),
  ];

  final tela = TelaAscii(largura: 30, altura: 20);

  final sessao = SessaoJogo(
    mapa: mapa,
    jogador: jogador,
    inimigos: inimigos,
    itens: itens,
    tela: tela,
  );

  print('=== MASMORRA ASCII: Renderização Profissional ===\n');

  bool rodando = true;
  while (rodando) {
    sessao.renderizarFrame();

    stdout.write('> ');
    final entrada = stdin.readLineSync() ?? '';

    switch (entrada.toLowerCase()) {
      case 'w' || 'a' || 's' || 'd':
        jogador.moverEmDirecao(entrada, mapa);
        sessao.turnoAtual++;
      case 'q':
        print('Adeus, ${jogador.nome}!');
        rodando = false;
      default:
        // Ignorar silenciosamente
    }
  }
}
