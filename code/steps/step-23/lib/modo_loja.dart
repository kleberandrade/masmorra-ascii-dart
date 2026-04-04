import 'dart:io';
import 'jogador.dart';
import 'mercador.dart';
import 'loja_renderer.dart';

/// Executa a sessão de loja (estado especial do jogo)
class ModoLoja {
  final Jogador jogador;
  final Mercador mercador;
  final LojaRenderer renderer;

  bool emLoja = true;

  ModoLoja({
    required this.jogador,
    required this.mercador,
  }) : renderer = LojaRenderer();

  void executar() {
    renderer.renderizar(jogador, mercador);

    while (emLoja) {
      stdout.write('\n> ');
      final comando = stdin.readLineSync() ?? 'ajuda';
      processarComando(comando.trim());
      renderer.renderizar(jogador, mercador);
    }

    print('\nVocê saiu da loja.');
  }

  void processarComando(String cmd) {
    final partes = cmd.split(' ');
    final acao = partes[0].toLowerCase();

    switch (acao) {
      case 'comprar' || 'c':
        if (partes.length < 2) {
          print('Uso: comprar <número>');
          break;
        }
        final indice = int.tryParse(partes[1]);
        if (indice != null) {
          final mensagem = mercador.comprar(jogador, indice);
          print(mensagem);
        }
        break;

      case 'vender' || 'v':
        if (partes.length < 2) {
          print('Uso: vender <número>');
          break;
        }
        final indice = int.tryParse(partes[1]);
        if (indice != null) {
          final mensagem = mercador.vender(jogador, indice);
          print(mensagem);
        }
        break;

      case 'sair' || 's':
        emLoja = false;
        break;

      case 'status':
        print('Ouro: ${jogador.ouro} | HP: ${jogador.hp}/${jogador.maxHp}');
        break;

      default:
        print('Comando desconhecido. Digita "ajuda".');
    }
  }
}
