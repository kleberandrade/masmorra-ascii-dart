import 'dart:io';
import 'package:masmorra_ascii/modelos/jogador.dart';
import 'package:masmorra_ascii/ui/renderizador.dart';
import 'package:masmorra_ascii/sistemas/tabela_progressao.dart';

/// Orquestrador principal do jogo
class MasmorraAscii {
  late Jogador jogador;
  final renderer = RenderizadorJogador();
  final tabela = TabelaProgressao();

  void executar() {
    print('╔════════════════════════════════════════╗');
    print('║   MASMORRA ASCII - STEP 28             ║');
    print('║   Código refatorado em diretórios      ║');
    print('╚════════════════════════════════════════╝\n');

    _criarPersonagem();
    _loopPrincipal();
  }

  void _criarPersonagem() {
    stdout.write('Qual é o nome do seu herói? ');
    final nome = stdin.readLineSync() ?? 'Aventureiro';

    jogador = Jogador(nome: nome);

    print('\nBem-vindo, ${jogador.nome}!');
    print('Sua jornada começa agora...\n');
  }

  void _loopPrincipal() {
    bool jogando = true;

    while (jogando) {
      renderer.mostrarStatus(jogador);
      renderer.mostrarHUD(jogador);

      stdout.write('> ');
      final comando = stdin.readLineSync() ?? 'help';

      switch (comando.toLowerCase()) {
        case 'xp':
          final xp = 50;
          jogador.xp += xp;
          print('Você ganhou $xp XP! Total: ${jogador.xp}');
          break;

        case 'nivel':
          jogador.nivel++;
          jogador.maxHp += 10;
          jogador.hp = jogador.maxHp;
          jogador.ataque += 2;
          print('LEVEL UP! Agora você é nível ${jogador.nivel}!');
          break;

        case 'ouro':
          jogador.ouro += 100;
          print('Você ganhou 100 ouro! Total: ${jogador.ouro}');
          break;

        case 'dano':
          final dano = 10;
          jogador.sofrerDano(dano);
          print('Você sofreu $dano dano! HP: ${jogador.hp}');
          break;

        case 'curar':
          final cura = 15;
          jogador.curar(cura);
          print('Você se curou! HP: ${jogador.hp}');
          break;

        case 'quit':
          jogando = false;
          print('\nVocê saiu do jogo.');
          break;

        default:
          print('Comandos: xp, nivel, ouro, dano, curar, quit');
      }
    }
  }
}
