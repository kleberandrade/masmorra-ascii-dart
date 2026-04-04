import 'dart:io';
import 'dart:math';
import 'package:step_18_geracao_procedural/mapa_masmorra.dart';
import 'package:step_18_geracao_procedural/tela_ascii.dart';
import 'package:step_18_geracao_procedural/gerador_masmorra_robusta.dart';

void main() {
  print('=== MASMORRA ASCII: Geração Procedural ===\n');
  print('1. Random Walk');
  print('2. Rooms and Corridors');
  print('3. Rooms and Corridors (com validação robusta)');
  stdout.write('Escolha (1-3): ');

  final escolha = stdin.readLineSync() ?? '1';
  final random = Random(42);

  late MapaMasmorra mapa;

  if (escolha == '2') {
    mapa = MapaMasmorra.comSalasECorredores(
      largura: 50,
      altura: 20,
      random: random,
      numSalas: 8,
    );
  } else if (escolha == '3') {
    final gerador = GeradorMasmorraRobusta();
    mapa = gerador.gerarValidado(
      largura: 50,
      altura: 20,
      numSalas: 8,
      maxTentativas: 10,
    );
  } else {
    mapa = MapaMasmorra.comRandomWalk(
      largura: 50,
      altura: 20,
      random: random,
      numPassos: 2000,
    );
  }

  final jogador = Jogador(
    nome: 'Aldric',
    x: mapa.largura ~/ 2,
    y: mapa.altura ~/ 2,
    hpMax: 100,
    ouro: 0,
  );

  // Encontrar chão para colocar jogador
  for (int y = 0; y < mapa.altura && !mapa.ehPassavel(jogador.x, jogador.y); y++) {
    for (int x = 0; x < mapa.largura; x++) {
      if (mapa.ehPassavel(x, y)) {
        jogador.x = x;
        jogador.y = y;
        break;
      }
    }
  }

  final tela = escolha == '2'
      ? TelaAscii(largura: 50, altura: 25)
      : TelaAscii(largura: 50, altura: 25);

  final sessao = SessaoJogo(
    mapa: mapa,
    jogador: jogador,
    tela: tela,
  );

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
        rodando = false;
      default:
        // Ignorar
    }
  }

  print('Até logo!');
}
