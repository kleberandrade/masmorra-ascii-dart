import 'dart:io';
import 'package:masmorra_ascii/jogador.dart';
import 'package:masmorra_ascii/sala.dart';
import 'package:masmorra_ascii/mundo_texto.dart';

void exibirBanner() {
  // ignore: avoid_print
  print('''
╔════════════════════════════════════════╗
║     MASMORRA ASCII - Step 10           ║
║       Herança: Inimigos                ║
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
    print('│ Inimigo aqui: ${ini.nome} (${ini.simbolo})');
  }
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
  print('│ Ataque: ${jogador.ataque}');
  // ignore: avoid_print
  print('│ Ouro: ${jogador.ouro}g');
  // ignore: avoid_print
  print('╰────────────────────────────────────╯');
}

void main() {
  exibirBanner();

  final mundo = criarMundoVila();
  final jogador = Jogador('Aldric');

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
  norte/sul/leste/oeste - Mover
  inventário/inv        - Ver inventário
  status                - Ver status
  pegar <item>          - Pegar item
  largar <item>         - Largar item
  ataqueInimigo         - Atacar inimigo da sala
  inimigos              - Listar todos inimigos do mundo
  dano <número>         - Sofrer dano (teste)
  curar <número>        - Curar (teste)
  ouro <número>         - Ganhar ouro (teste)
  ajuda/help            - Esta mensagem
  sair/quit             - Sair
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
          jogador.moverPara(destino);
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
            sala.removerItem(argumento);
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
          sala.adicionarItem(argumento);
          // ignore: avoid_print
          print('Você largou $argumento.');
        } else {
          // ignore: avoid_print
          print('Você não tem $argumento no inventário.');
        }

      case 'ataqueInimigo':
        if (sala.temInimigo) {
          final inimigo = sala.inimigoPresente!;
          // ignore: avoid_print
          print('Você ataca ${inimigo.nome}!');
          // ignore: avoid_print
          print(inimigo.descreverAcao());
          inimigo.sofrerDano(jogador.ataque);
          if (inimigo.estaVivo) {
            // ignore: avoid_print
            print('${inimigo.nome} sofre $jogador.ataque de dano!');
            jogador.sofrerDano(inimigo.ataque);
            // ignore: avoid_print
            print('${inimigo.nome} contra-ataca! Você sofre ${inimigo.ataque} de dano!');
          } else {
            // ignore: avoid_print
            print('${inimigo.nome} foi derrotado!');
            sala.inimigoPresente = null;
            jogador.receberOuro(10);
          }
        } else {
          // ignore: avoid_print
          print('Não há inimigos aqui para atacar.');
        }

      case 'inimigos':
        // ignore: avoid_print
        print('\n=== Inimigos do Mundo ===');
        for (final entry in mundo.salas.entries) {
          if (entry.value.temInimigo) {
            final ini = entry.value.inimigoPresente!;
            // ignore: avoid_print
            print('${entry.value.nome}: ${ini.toString()}');
          }
        }

      case 'dano':
        final d = int.tryParse(argumento) ?? 0;
        if (d > 0) {
          jogador.sofrerDano(d);
          // ignore: avoid_print
          print('Você sofreu $d de dano!');
        } else {
          // ignore: avoid_print
          print('Dano inválido.');
        }

      case 'curar':
        final c = int.tryParse(argumento) ?? 0;
        if (c > 0) {
          jogador.curar(c);
          // ignore: avoid_print
          print('Você foi curado por $c!');
        } else {
          // ignore: avoid_print
          print('Cura inválida.');
        }

      case 'ouro':
        final o = int.tryParse(argumento) ?? 0;
        if (o > 0) {
          jogador.receberOuro(o);
          // ignore: avoid_print
          print('Você ganhou $o ouro!');
        } else {
          // ignore: avoid_print
          print('Ouro inválido.');
        }

      default:
        // ignore: avoid_print
        print('Comando desconhecido. Tente "ajuda".');
    }
  }

  if (!jogador.estaVivo) {
    // ignore: avoid_print
    print('\n[GAME OVER] Sua aventura terminou.');
  }
}
