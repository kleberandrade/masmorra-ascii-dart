import 'dart:io';
import 'package:masmorra_ascii/jogador.dart';
import 'package:masmorra_ascii/sala.dart';
import 'package:masmorra_ascii/mundo_texto.dart';
import 'package:masmorra_ascii/combate.dart';
import 'package:masmorra_ascii/item.dart';

void exibirBanner() {
  // ignore: avoid_print
  print('''
╔════════════════════════════════════════╗
║   MASMORRA ASCII - Step 14             ║
║   Combate por Turnos (MARCO II)        ║
║   ⚔ JOGO JOGÁVEL ⚔                    ║
╚════════════════════════════════════════╝
''');
}

void exibirSala(Sala sala) {
  // ignore: avoid_print
  print('\n┌─ ${sala.nome} ─────────────────────┐');
  // ignore: avoid_print
  print('│ ${sala.descricao}');
  // ignore: avoid_print
  print('│');
  if (sala.temInimigo) {
    final ini = sala.inimigoPresente!;
    // ignore: avoid_print
    print('│ ⚔ Inimigo aqui: ${ini.nome} (${ini.simbolo})');
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
  var jogador = Jogador('Aventureiro', hpInicial: 100, ouro: 200);

  // Equipar com itens iniciais
  jogador.adicionarItem(espadaDeBronze);
  jogador.adicionarItem(pocaoDeVida);
  jogador.adicionarItem(camisaDeCouro);
  jogador.equiparArma(0);
  jogador.equiparArmadura(2);

  // ignore: avoid_print
  print('\nBem-vindo, ${jogador.nome}!');
  // ignore: avoid_print
  print('Você começou com:');
  // ignore: avoid_print
  print('  Arma: ${jogador.armaEquipada?.nome ?? "nenhuma"}');
  // ignore: avoid_print
  print('  Armadura: ${jogador.armaduraEquipada?.nome ?? "nenhuma"}');
  // ignore: avoid_print
  print('  HP: ${jogador.hp}/${jogador.maxHp}');

  while (jogador.estaVivo) {
    final sala = mundo.obterSala(jogador.salaAtual);
    if (sala == null) {
      // ignore: avoid_print
      print('Erro: sala não encontrada!');
      break;
    }

    exibirSala(sala);
    // ignore: avoid_print
    print('\nHP: ${jogador.mostrarBarraVida()} | Ouro: ${jogador.ouro}g | XP: ${jogador.xp}');

    // ignore: avoid_print
    stdout.write('\n> ');
    final entrada = stdin.readLineSync() ?? '';
    final partes = entrada.trim().toLowerCase().split(' ');
    final cmd = partes[0];

    switch (cmd) {
      case 'n':
      case 'norte':
        final dest = sala.saidaPara('norte');
        if (dest != null) {
          jogador.moverPara(dest);
          // ignore: avoid_print
          print('Você foi para norte.');
        } else {
          // ignore: avoid_print
          print('Não há saída para norte.');
        }

      case 's':
      case 'sul':
        final dest = sala.saidaPara('sul');
        if (dest != null) {
          jogador.moverPara(dest);
          // ignore: avoid_print
          print('Você foi para sul.');
        } else {
          // ignore: avoid_print
          print('Não há saída para sul.');
        }

      case 'e':
      case 'leste':
        final dest = sala.saidaPara('leste');
        if (dest != null) {
          jogador.moverPara(dest);
          // ignore: avoid_print
          print('Você foi para leste.');
        } else {
          // ignore: avoid_print
          print('Não há saída para leste.');
        }

      case 'o':
      case 'oeste':
        final dest = sala.saidaPara('oeste');
        if (dest != null) {
          jogador.moverPara(dest);
          // ignore: avoid_print
          print('Você foi para oeste.');
        } else {
          // ignore: avoid_print
          print('Não há saída para oeste.');
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
        // ignore: avoid_print
        print('\n╔═══════════════════════════╗');
        // ignore: avoid_print
        print('║  HP: ${jogador.mostrarBarraVida()}');
        // ignore: avoid_print
        print('║  Dano: ${jogador.danoTotal} (arma: ${jogador.armaEquipada?.dano ?? 0})');
        // ignore: avoid_print
        print('║  Defesa: ${jogador.defesaTotal} (armadura: ${jogador.armaduraEquipada?.defesa ?? 0})');
        // ignore: avoid_print
        print('║  Ouro: ${jogador.ouro}g');
        // ignore: avoid_print
        print('║  XP: ${jogador.xp}');
        // ignore: avoid_print
        print('╚═══════════════════════════╝');

      case 'combater':
      case 'lutar':
        if (sala.temInimigo) {
          final ini = sala.inimigoPresente!;
          // ignore: avoid_print
          print('\n⚔️ Você enfrenta ${ini.nome}!');
          final combate = Combate(jogador: jogador, inimigo: ini);
          combate.executar();

          if (!ini.estaVivo) {
            sala.inimigoPresente = null;
          }

          if (!jogador.estaVivo) {
            // ignore: avoid_print
            print('\n[GAME OVER] Sua aventura terminou.');
            return;
          }
        } else {
          // ignore: avoid_print
          print('Nenhum inimigo aqui para combater.');
        }

      case 'ajuda':
      case 'help':
        // ignore: avoid_print
        print('''
Comandos:
  norte/sul/leste/oeste - Mover
  inv/inventário        - Ver inventário
  status                - Ver status
  combater/lutar        - Lutar contra inimigo
  ajuda/help            - Esta mensagem
  sair/quit             - Sair
''');

      case 'sair':
      case 'quit':
        return;

      default:
        // ignore: avoid_print
        print('Comando desconhecido. Tente "ajuda".');
    }
  }
}
