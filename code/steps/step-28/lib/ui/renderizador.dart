import 'package:masmorra_ascii/modelos/jogador.dart';

/// Renderiza informações do jogador
class RenderizadorJogador {
  void mostrarStatus(Jogador jogador) {
    print('\n╔════════════════════════════════════╗');
    print('║            STATUS DO JOGADOR       ║');
    print('╠════════════════════════════════════╣');
    print('║ Nome: ${jogador.nome}');
    print('║ Nível: ${jogador.nivel}');
    print('║ HP: ${jogador.hp}/${jogador.maxHp}');
    print('║ Ataque: ${jogador.ataque}');
    print('║ Ouro: ${jogador.ouro}');
    print('║ XP: ${jogador.xp}');
    print('╚════════════════════════════════════╝\n');
  }

  void mostrarHUD(Jogador jogador) {
    final barra = _desenharBarraHP(jogador.hp, jogador.maxHp);
    print('[$barra] HP: ${jogador.hp}/${jogador.maxHp}');
  }

  String _desenharBarraHP(int atual, int maximo) {
    final percentual = (atual / maximo) * 10;
    final cheios = '█' * percentual.toInt();
    final vazios = '░' * (10 - percentual.toInt());
    return '$cheios$vazios';
  }
}
