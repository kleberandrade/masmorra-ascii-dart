import 'dart:io';
import 'package:step_17_aleatoriedade/mapa_masmorra.dart';
import 'package:step_17_aleatoriedade/tela_ascii.dart';
import 'package:step_17_aleatoriedade/tile.dart';

void main() {
  // Solicitar semente ao usuário
  stdout.write('Semente aleatória (deixe em branco para aleatório): ');
  final entrada = stdin.readLineSync() ?? '';
  final seed = entrada.isEmpty ? null : int.tryParse(entrada);

  final mapa = MapaMasmorra(largura: 40, altura: 15);

  // Construir mapa com parede na borda
  for (int y = 0; y < 15; y++) {
    for (int x = 0; x < 40; x++) {
      if (x == 0 || x == 39 || y == 0 || y == 14) {
        mapa.definirTile(x, y, Tile.parede);
      }
    }
  }

  final jogador = Jogador(
    nome: 'Aldric',
    x: 20,
    y: 7,
    hpMax: 100,
    ouro: 0,
  );

  final tela = TelaAscii(largura: 40, altura: 20);

  final sessao = SessaoJogo(
    mapa: mapa,
    jogador: jogador,
    tela: tela,
    seed: seed,
  );

  // Gerar itens e inimigos aleatórios
  sessao.gerarItens(5);
  sessao.gerarInimigos(4, 5);

  print('=== MASMORRA ASCII: Aleatoriedade ===\n');
  if (seed != null) {
    print('Semente: $seed\n');
  }

  bool rodando = true;
  while (rodando) {
    sessao.renderizarFrame();

    stdout.write('> ');
    final cmd = stdin.readLineSync() ?? '';

    switch (cmd.toLowerCase()) {
      case 'w' || 'a' || 's' || 'd':
        jogador.moverEmDirecao(cmd, mapa);
        sessao.turnoAtual++;
      case 'q':
        print('Adeus!');
        rodando = false;
      default:
        // Ignorar
    }
  }
}
