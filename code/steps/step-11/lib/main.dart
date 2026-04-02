import 'dart:io';
import 'package:masmorra_ascii/jogador.dart';
import 'package:masmorra_ascii/sala.dart';
import 'package:masmorra_ascii/mundo_texto.dart';

void exibirBanner() {
  // ignore: avoid_print
  print('''
╔════════════════════════════════════════╗
║     MASMORRA ASCII - Step 11           ║
║          Mixins                        ║
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
  // ignore: avoid_print
  print(jogador);

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
    final comando = entrada.trim().toLowerCase();

    if (comando == 'sair' || comando == 'quit' || comando == 'exit') {
      // ignore: avoid_print
      print('Até logo!');
      break;
    }

    if (comando == 'ajuda' || comando == 'help') {
      // ignore: avoid_print
      print('''
Comandos:
  norte/sul/leste/oeste - Mover
  inv/inventário        - Inventário
  atacar                - Atacar inimigo
  dano <n>              - Sofrer dano
  curar <n>             - Curar
  ouro <n>              - Ganhar ouro
  sair/quit             - Sair
''');
      continue;
    }

    final partes = comando.split(' ');
    final verbo = partes[0];
    final arg = partes.length > 1 ? int.tryParse(partes[1]) : null;

    switch (verbo) {
      case 'norte':
      case 'sul':
      case 'leste':
      case 'oeste':
        final destino = sala.saidaPara(verbo);
        if (destino != null) {
          jogador.moverPara(destino);
          // ignore: avoid_print
          print('Você se moveu para $verbo.');
        } else {
          // ignore: avoid_print
          print('Não há saída para $verbo.');
        }

      case 'inv':
      case 'inventário':
        if (jogador.inventario.isEmpty) {
          // ignore: avoid_print
          print('Inventário vazio.');
        } else {
          // ignore: avoid_print
          print('Inventário: ${jogador.inventario.join(", ")}');
        }

      case 'atacar':
        if (sala.temInimigo) {
          final ini = sala.inimigoPresente!;
          // ignore: avoid_print
          print('Você ataca ${ini.nome}!');
          // ignore: avoid_print
          print(ini.descreverAcao());
          ini.sofrerDano(5);
          // ignore: avoid_print
          print('${ini.nome}: ${ini.mostrarBarraVida()}');
          if (ini.estaVivo) {
            jogador.sofrerDano(ini.ataque);
            // ignore: avoid_print
            print('${ini.nome} contra-ataca! Você: ${jogador.mostrarBarraVida()}');
          } else {
            // ignore: avoid_print
            print('Você derrotou ${ini.nome}!');
            sala.inimigoPresente = null;
            jogador.receberOuro(20);
          }
        } else {
          // ignore: avoid_print
          print('Nenhum inimigo aqui.');
        }

      case 'dano':
        if (arg != null && arg > 0) {
          jogador.sofrerDano(arg);
          // ignore: avoid_print
          print('Você sofreu $arg de dano! ${jogador.mostrarBarraVida()}');
        }

      case 'curar':
        if (arg != null && arg > 0) {
          jogador.curar(arg);
          // ignore: avoid_print
          print('Você curou $arg! ${jogador.mostrarBarraVida()}');
        }

      case 'ouro':
        if (arg != null && arg > 0) {
          jogador.receberOuro(arg);
          // ignore: avoid_print
          print('Você ganhou $arg ouro!');
        }

      default:
        // ignore: avoid_print
        print('Comando desconhecido.');
    }
  }

  if (!jogador.estaVivo) {
    // ignore: avoid_print
    print('\n[GAME OVER]');
  }
}
