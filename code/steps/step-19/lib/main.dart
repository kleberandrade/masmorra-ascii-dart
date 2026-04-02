import 'dart:io';
import 'dart:math';
import 'package:step_19_campo_visao/dungeon.dart';
import 'package:step_19_campo_visao/tile.dart';
import 'package:step_19_campo_visao/campo_visao.dart';

void main() {
  final mapa = MapaMasmorra(largura: 50, altura: 20);

  // Criar labirinto simples
  for (int y = 0; y < 20; y++) {
    for (int x = 0; x < 50; x++) {
      if (x == 0 || x == 49 || y == 0 || y == 19) {
        mapa.definirTile(x, y, Tile.parede);
      }
    }
  }

  // Adicionar paredes internas
  for (int x = 10; x < 40; x += 5) {
    for (int y = 2; y < 18; y++) {
      mapa.definirTile(x, y, Tile.parede);
    }
    mapa.definirTile(x, 10, Tile.chao);
  }

  final jogador = Jogador(
    nome: 'Aldric',
    x: 5,
    y: 5,
    hpMax: 100,
    ouro: 0,
  );

  // Criar inimigos
  final inimigos = [
    Inimigo(
      nome: 'Zumbi',
      x: 35,
      y: 5,
      hpMax: 20,
      simbolo: 'Z',
    ),
    Inimigo(
      nome: 'Lobo',
      x: 40,
      y: 15,
      hpMax: 30,
      simbolo: 'L',
    ),
  ];

  // Criar itens
  final itens = [
    Item(nome: 'Ouro', x: 15, y: 10),
    Item(nome: 'Poção', x: 25, y: 15),
    Item(nome: 'Gema', x: 45, y: 5),
  ];

  final tela = TelaAscii(largura: 50, altura: 25);

  final sessao = SessaoJogo(
    mapa: mapa,
    jogador: jogador,
    inimigos: inimigos,
    itens: itens,
    tela: tela,
  );

  print('=== MASMORRA ASCII: FOV e Névoa de Guerra ===\n');

  bool rodando = true;
  while (rodando) {
    // Atualizar FOV
    mapa.fov.calcularShadowcast(
      Point(jogador.x, jogador.y),
      8,
      mapa,
    );

    sessao.renderizarFrame();

    stdout.write('> ');
    final cmd = stdin.readLineSync() ?? '';

    switch (cmd.toLowerCase()) {
      case 'w' || 'a' || 's' || 'd':
        jogador.moverEmDirecao(cmd, mapa);
        sessao.turnoAtual++;
      case 'q':
        rodando = false;
      default:
        // Ignorar
    }
  }

  print('Até logo!');
}
