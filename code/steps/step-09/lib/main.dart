import 'dart:io';
import 'package:masmorra_ascii/jogador.dart';
import 'package:masmorra_ascii/sala.dart';
import 'package:masmorra_ascii/mundo_texto.dart';

void exibirBanner() {
  // ignore: avoid_print
  print('''
╔════════════════════════════════════════╗
║     MASMORRA ASCII - Step 9            ║
║  Encapsulamento e Construtores         ║
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

  // Demonstração de construtores
  // ignore: avoid_print
  print('\n=== Demonstração de Construtores ===\n');

  final recruta = Jogador.recruta('Timmy');
  // ignore: avoid_print
  print('Recruta: $recruta');

  final veterano = Jogador.veterano('Kael');
  // ignore: avoid_print
  print('Veterano: $veterano');

  final normal = Jogador('Aldric');
  // ignore: avoid_print
  print('Normal: $normal');

  final dados = {
    'nome': 'Sareth',
    'hp': 120,
    'maxHp': 150,
    'ouro': 500,
    'ataque': 10,
    'salaAtual': 'taverna',
    'inventario': ['Espada', 'Escudo'],
  };
  final carregado = Jogador.deArquivo(dados);
  // ignore: avoid_print
  print('Carregado: $carregado');

  // Jogo real
  // ignore: avoid_print
  print('\n=== Iniciando jogo com $normal ===\n');

  var jogador = normal;

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
  dano <número>         - Sofrer dano (teste)
  curar <número>        - Curar (teste)
  ouro <número>         - Ganhar ouro (teste)
  salvar                - Mostrar dados para salvar
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

      case 'dano':
        final d = int.tryParse(argumento) ?? 0;
        if (d > 0) {
          jogador.sofrerDano(d);
          // ignore: avoid_print
          print('Você sofreu $d de dano!');
          if (!jogador.estaVivo) {
            // ignore: avoid_print
            print('Você morreu!');
          }
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

      case 'salvar':
        final mapa = jogador.paraMap();
        // ignore: avoid_print
        print('Dados para salvar:');
        // ignore: avoid_print
        print(mapa);

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
