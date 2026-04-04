import 'dart:io';
import 'comando_jogo.dart';
import 'parser.dart';

class LoopJogo {
  void processarComando(ComandoJogo cmd) {
    switch (cmd) {
      case ComandoMover(:final direcao):
        print('Movendo para $direcao...');

      case ComandoAtacar(:final alvo):
        print('Atacando $alvo...');

      case ComandoPegar(:final item):
        print('Pegando em $item...');

      case ComandoInventario():
        print('Mostrando inventário...');

      case ComandoOlhar():
        print('Observando...');

      case ComandoStatus():
        print('Mostrando status...');

      case ComandoAjuda():
        print('Mostrando ajuda...');

      case ComandoSair():
        print('Saindo do jogo...');

      case ComandoDesconhecido(:final entrada):
        print('Comando desconhecido: $entrada');
    }
  }

  void mainLoop() {
    while (true) {
      print('> ');
      final entrada = stdin.readLineSync() ?? '';

      final cmd = analisarLinha(entrada);
      processarComando(cmd);
    }
  }
}
