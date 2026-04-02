import 'dart:io';
import 'package:masmorra_ascii/jogador.dart';
import 'package:masmorra_ascii/sala.dart';
import 'package:masmorra_ascii/mundo_texto.dart';
import 'package:masmorra_ascii/comando_jogo.dart';
import 'package:masmorra_ascii/parser.dart';
import 'package:masmorra_ascii/direcao.dart';

void exibirBanner() {
  // ignore: avoid_print
  print('''
╔════════════════════════════════════════╗
║     MASMORRA ASCII - Step 12           ║
║      Enums e Parser                    ║
╚════════════════════════════════════════╝
''');
}

void exibirSala(Sala sala) {
  // ignore: avoid_print
  print('\n┌─ [${sala.nome}] ─────────────────────┐');
  // ignore: avoid_print
  print('│ ${sala.descricao}');
  // ignore: avoid_print
  print('│');
  if (sala.temInimigo) {
    final ini = sala.inimigoPresente!;
    // ignore: avoid_print
    print('│ Inimigo: ${ini.nome} (${ini.simbolo}) ${ini.mostrarBarraVida()}');
  }
  if (sala.temItens) {
    // ignore: avoid_print
    print('│ Itens: ${sala.itens.join(", ")}');
  }
  // ignore: avoid_print
  print('│ Saídas: ${sala.saidas.keys.join(", ")}');
  // ignore: avoid_print
  print('└────────────────────────────────────┘');
}

void main() {
  exibirBanner();

  final mundo = criarMundoVila();
  final jogador = Jogador('Aventureiro');

  // ignore: avoid_print
  print('\nBem-vindo, ${jogador.nome}!');

  while (jogador.estaVivo) {
    final sala = mundo.obterSala(jogador.salaAtual);
    if (sala == null) {
      // ignore: avoid_print
      print('Erro: sala não encontrada!');
      break;
    }

    exibirSala(sala);
    // ignore: avoid_print
    print('\nHP: ${jogador.mostrarBarraVida()}');

    // ignore: avoid_print
    stdout.write('\n> ');
    final entrada = stdin.readLineSync() ?? '';

    final cmd = analisarLinha(entrada);

    switch (cmd) {
      case ComandoMover(:final direcao):
        final destino = sala.saidaPara(direcao.id);
        if (destino != null) {
          jogador.moverPara(destino);
          // ignore: avoid_print
          print('Você se moveu para ${direcao.simbolo}');
        } else {
          // ignore: avoid_print
          print('Não há saída para ${direcao.simbolo}');
        }

      case ComandoAtacar(:final alvo):
        if (sala.temInimigo) {
          final ini = sala.inimigoPresente!;
          if (ini.nome.toLowerCase().contains(alvo.toLowerCase())) {
            // ignore: avoid_print
            print('Você ataca ${ini.nome}!');
            ini.sofrerDano(5);
            if (ini.estaVivo) {
              // ignore: avoid_print
              print('${ini.nome}: ${ini.mostrarBarraVida()}');
              jogador.sofrerDano(ini.ataque);
              // ignore: avoid_print
              print('${ini.nome} contra-ataca! ${jogador.mostrarBarraVida()}');
            } else {
              // ignore: avoid_print
              print('Você derrotou ${ini.nome}!');
              sala.inimigoPresente = null;
              jogador.receberOuro(20);
            }
          } else {
            // ignore: avoid_print
            print('Você não vê isso aqui.');
          }
        } else {
          // ignore: avoid_print
          print('Nenhum inimigo aqui.');
        }

      case ComandoPegar(:final item):
        if (sala.itens.contains(item)) {
          if (jogador.pegarItem(item)) {
            sala.removerItem(item);
            // ignore: avoid_print
            print('Você pegou $item.');
          } else {
            // ignore: avoid_print
            print('Seu inventário está cheio!');
          }
        } else {
          // ignore: avoid_print
          print('Não há $item aqui.');
        }

      case ComandoInventario():
        if (jogador.inventario.isEmpty) {
          // ignore: avoid_print
          print('Inventário vazio.');
        } else {
          // ignore: avoid_print
          print('Inventário: ${jogador.inventario.join(", ")}');
        }

      case ComandoStatus():
        // ignore: avoid_print
        print('${jogador.nome} - HP: ${jogador.mostrarBarraVida()}, Ouro: ${jogador.ouro}g');

      case ComandoOlhar():
        // ignore: avoid_print
        print('(você já vê isto)');

      case ComandoAjuda():
        // ignore: avoid_print
        print(cmd.executar());

      case ComandoSair():
        // ignore: avoid_print
        print('Até logo!');
        return;

      case ComandoDesconhecido():
        // ignore: avoid_print
        print(cmd.executar());
    }
  }

  if (!jogador.estaVivo) {
    // ignore: avoid_print
    print('\n[GAME OVER]');
  }
}
