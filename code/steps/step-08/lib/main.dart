import 'dart:io';
import 'package:masmorra_ascii/jogador.dart';
import 'package:masmorra_ascii/sala.dart';
import 'package:masmorra_ascii/mundo.dart';

void exibirBanner() {
  // ignore: avoid_print
  print('''
╔════════════════════════════════════════╗
║     MASMORRA ASCII - Step 8            ║
║     Classes: Jogador e Sala            ║
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
  if (sala.temItens) {
    // ignore: avoid_print
    print('│ Itens aqui: ${sala.itens.join(", ")}');
  }
  // ignore: avoid_print
  print('│ Saídas: ${sala.saidas.keys.join(", ")}');
  // ignore: avoid_print
  print('└────────────────────────────────────┘');
}

void exibirStatus(Jogador jogador) {
  // ignore: avoid_print
  print('\n╭─ Status ──────────────────────────╮');
  // ignore: avoid_print
  print('│ ${jogador.nome}');
  // ignore: avoid_print
  print('│ HP: ${jogador.hp}/${jogador.maxHp}');
  // ignore: avoid_print
  print('│ Ouro: ${jogador.ouro}g');
  // ignore: avoid_print
  print('│ Sala: ${jogador.salaAtual}');
  // ignore: avoid_print
  print('│ Inventário: ${jogador.inventario.isEmpty ? "vazio" : jogador.inventario.join(", ")}');
  // ignore: avoid_print
  print('╰────────────────────────────────────╯');
}

void main() {
  exibirBanner();

  final mundo = criarMundoVila();
  final jogador = Jogador('Aventureiro');

  // ignore: avoid_print
  print('\nBem-vindo, ${jogador.nome}!');

  while (true) {
    final sala = mundo[jogador.salaAtual];
    if (sala == null) {
      // ignore: avoid_print
      print('Erro: sala não encontrada!');
      break;
    }

    exibirSala(sala);
    exibirStatus(jogador);

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
Comandos disponíveis:
  norte/sul/leste/oeste - Mover para essa direção
  inventário/inv        - Ver inventário
  status                - Ver status
  pegar <item>          - Pegar um item
  largar <item>         - Largar um item
  dano <número>         - Sofrer dano (teste)
  curar <número>        - Curar (teste)
  ouro <número>         - Receber ouro (teste)
  ajuda/help            - Mostrar esta mensagem
  sair/quit             - Sair do jogo
''');
      continue;
    }

    final partes = comando.split(' ');
    final verbo = partes[0];
    final argumento = partes.length > 1 ? partes.sublist(1).join(' ') : '';

    switch (verbo) {
      case 'norte':
      case 'sul':
      case 'leste':
      case 'oeste':
        final destino = sala.saidaPara(verbo);
        if (destino != null) {
          jogador.salaAtual = destino;
          // ignore: avoid_print
          print('Você se moveu para $verbo.');
        } else {
          // ignore: avoid_print
          print('Não há saída para $verbo.');
        }

      case 'inventário':
      case 'inv':
        if (jogador.inventario.isEmpty) {
          // ignore: avoid_print
          print('Seu inventário está vazio.');
        } else {
          // ignore: avoid_print
          print('Inventário: ${jogador.inventario.join(", ")}');
        }

      case 'status':
        exibirStatus(jogador);

      case 'pegar':
        if (argumento.isEmpty) {
          // ignore: avoid_print
          print('Pegar o quê?');
        } else if (sala.itens.contains(argumento)) {
          if (jogador.pegarItem(argumento)) {
            sala.itens.remove(argumento);
            // ignore: avoid_print
            print('Você pegou $argumento.');
          } else {
            // ignore: avoid_print
            print('Seu inventário está cheio!');
          }
        } else {
          // ignore: avoid_print
          print('Não há $argumento aqui.');
        }

      case 'largar':
        if (argumento.isEmpty) {
          // ignore: avoid_print
          print('Largar o quê?');
        } else if (jogador.largarItem(argumento)) {
          sala.itens.add(argumento);
          // ignore: avoid_print
          print('Você largou $argumento.');
        } else {
          // ignore: avoid_print
          print('Você não tem $argumento no inventário.');
        }

      case 'dano':
        final d = int.tryParse(argumento) ?? 0;
        if (d > 0) {
          jogador.sofrerDano(d);
          // ignore: avoid_print
          print('Você sofreu $d de dano! HP: ${jogador.hp}/${jogador.maxHp}');
        } else {
          // ignore: avoid_print
          print('Dano inválido.');
        }

      case 'curar':
        final c = int.tryParse(argumento) ?? 0;
        if (c > 0) {
          jogador.curar(c);
          // ignore: avoid_print
          print('Você foi curado por $c! HP: ${jogador.hp}/${jogador.maxHp}');
        } else {
          // ignore: avoid_print
          print('Cura inválida.');
        }

      case 'ouro':
        final o = int.tryParse(argumento) ?? 0;
        if (o > 0) {
          jogador.receberOuro(o);
          // ignore: avoid_print
          print('Você ganhou $o ouro! Total: ${jogador.ouro}g');
        } else {
          // ignore: avoid_print
          print('Ouro inválido.');
        }

      default:
        // ignore: avoid_print
        print('Comando desconhecido. Tente "ajuda".');
    }
  }
}
