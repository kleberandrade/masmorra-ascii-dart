import 'dart:io';
import 'package:masmorra_ascii/jogador.dart';
import 'package:masmorra_ascii/sala.dart';
import 'package:masmorra_ascii/mundo_texto.dart';
import 'package:masmorra_ascii/item.dart';

void exibirBanner() {
  // ignore: avoid_print
  print('''
╔════════════════════════════════════════╗
║     MASMORRA ASCII - Step 13           ║
║         Inventário e Items            ║
╚════════════════════════════════════════╝
''');
}

void main() {
  exibirBanner();

  final mundo = criarMundoVila();
  final jogador = Jogador('Aldric', hpInicial: 100, ouro: 500);

  // ignore: avoid_print
  print('\n${jogador.toString()}\n');

  jogador.adicionarItem(espadaDeBronze);
  jogador.adicionarItem(pocaoDeVida);
  jogador.adicionarItem(camisaDeCouro);

  while (jogador.estaVivo) {
    final sala = mundo.obterSala(jogador.salaAtual);
    if (sala == null) {
      // ignore: avoid_print
      print('Erro: sala inválida!');
      break;
    }

    // ignore: avoid_print
    print('\n┌─ ${sala.nome} ─────┐');
    // ignore: avoid_print
    print('│ ${sala.descricao}');
    if (sala.temInimigo) {
      // ignore: avoid_print
      print('│ Inimigo: ${sala.inimigoPresente!.nome}');
    }
    // ignore: avoid_print
    print('│ Saídas: ${sala.saidas.keys.join(", ")}');
    // ignore: avoid_print
    print('└────────────────────┘');

    // ignore: avoid_print
    print('\nHP: ${jogador.mostrarBarraVida()}');

    // ignore: avoid_print
    stdout.write('\n> ');
    final entrada = stdin.readLineSync() ?? '';
    final partes = entrada.trim().toLowerCase().split(' ');
    final cmd = partes[0];
    final arg = partes.length > 1 ? int.tryParse(partes[1]) : null;

    switch (cmd) {
      case 'n':
      case 'norte':
        final dest = sala.saidaPara('norte');
        if (dest != null) {
          jogador.moverPara(dest);
          // ignore: avoid_print
          print('Você foi para norte.');
        }

      case 's':
      case 'sul':
        final dest = sala.saidaPara('sul');
        if (dest != null) {
          jogador.moverPara(dest);
          // ignore: avoid_print
          print('Você foi para sul.');
        }

      case 'e':
      case 'leste':
        final dest = sala.saidaPara('leste');
        if (dest != null) {
          jogador.moverPara(dest);
          // ignore: avoid_print
          print('Você foi para leste.');
        }

      case 'o':
      case 'oeste':
        final dest = sala.saidaPara('oeste');
        if (dest != null) {
          jogador.moverPara(dest);
          // ignore: avoid_print
          print('Você foi para oeste.');
        }

      case 'inv':
      case 'inventário':
        if (jogador.inventario.isEmpty) {
          // ignore: avoid_print
          print('Inventário vazio.');
        } else {
          // ignore: avoid_print
          print('\n=== INVENTÁRIO ===');
          for (int i = 0; i < jogador.inventario.length; i++) {
            // ignore: avoid_print
            print('${i + 1}. ${jogador.inventario[i]}');
          }
        }

      case 'status':
        jogador.mostraStatus();

      case 'equipar':
        if (arg != null && arg > 0 && arg <= jogador.inventario.length) {
          if (jogador.equiparArma(arg - 1)) {
            // ignore: avoid_print
            print('Arma equipada!');
          } else if (jogador.equiparArmadura(arg - 1)) {
            // ignore: avoid_print
            print('Armadura equipada!');
          } else {
            // ignore: avoid_print
            print('Não podes equipar isso.');
          }
        }

      case 'vender':
        if (arg != null && arg > 0 && arg <= jogador.inventario.length) {
          if (jogador.tentarVender(arg - 1)) {
            // ignore: avoid_print
            print('Vendido!');
          } else {
            // ignore: avoid_print
            print('Não podes vender isso.');
          }
        }

      case 'comprar':
        // ignore: avoid_print
        print('Digite "comprar 1" (espada), "comprar 2" (poção), "comprar 3" (armadura)');

      case 'atacar':
        if (sala.temInimigo) {
          final ini = sala.inimigoPresente!;
          ini.sofrerDano(jogador.danoTotal);
          if (ini.estaVivo) {
            jogador.sofrerDano(ini.ataque);
          } else {
            // ignore: avoid_print
            print('Inimigo derrotado!');
            sala.inimigoPresente = null;
            jogador.receberOuro(20);
          }
        }

      case 'sair':
      case 'quit':
        return;

      default:
        // ignore: avoid_print
        print('Desconhecido.');
    }
  }
}
