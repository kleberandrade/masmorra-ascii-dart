import 'tabela_progressao.dart';
import 'habilidade.dart';

/// Jogador com sistema de progressão completo
class Jogador {
  final String nome;
  int hp;
  int maxHp;
  int ataque;
  int ouro;

  int nivel = 1;
  int xp = 0;

  late TabelaProgressao tabela;
  List<Habilidade> habilidades = [];

  Jogador({
    required this.nome,
    int hpMax = 50,
    this.ataque = 5,
  })  : hp = hpMax,
        maxHp = hpMax,
        ouro = 0 {
    tabela = TabelaProgressao();
  }

  bool get estaVivo => hp > 0;

  /// Ganha XP e verifica se sobe de nível
  void ganharXp(int quantidade) {
    xp += quantidade;
    print('$nome ganhou $quantidade XP (Total: $xp)');
    verificarNivel();
  }

  /// Verifica se o jogador deve subir de nível
  void verificarNivel() {
    final proximoNivel = nivel + 1;
    final xpNecessario = tabela.xpParaNivel(proximoNivel);

    while (xp >= xpNecessario && nivel < tabela.nivelMaximo()) {
      nivel++;
      maxHp += tabela.bonusHPPorNivel();
      hp = maxHp;
      ataque += tabela.bonusAtaquePorNivel();

      print('\nLEVEL UP! $nome agora é nível $nivel!');
      print('   HP máximo: +${tabela.bonusHPPorNivel()} (agora $maxHp)');
      print('   Ataque: +${tabela.bonusAtaquePorNivel()} (agora $ataque)');
      print('   HP restaurado!\n');

      _desbloquearHabilidades();
    }
  }

  /// Mostra barra de progresso até próximo nível
  String barraProgresso() {
    final percent = tabela.percentualProgresso(nivel, xp);
    final blocos = (percent / 10).toInt();
    final cheios = '#' * blocos;
    final vazios = '-' * (10 - blocos);
    return '$cheios$vazios $percent%';
  }

  /// Desbloqueia habilidades conforme o nível
  void _desbloquearHabilidades() {
    switch (nivel) {
      case 3:
        if (!habilidades.any((h) => h.nome == 'Golpe Forte')) {
          habilidades.add(GolpeForte());
          print('* Você aprendeu a habilidade: Golpe Forte!');
        }
        break;
      case 5:
        if (!habilidades.any((h) => h.nome == 'Curar')) {
          habilidades.add(Curar());
          print('* Você aprendeu a habilidade: Curar!');
        }
        break;
      case 7:
        if (!habilidades.any((h) => h.nome == 'Ataque Rápido')) {
          habilidades.add(AtaqueRapido());
          print('* Você aprendeu a habilidade: Ataque Rápido!');
        }
        break;
    }
  }

  /// Mostra todas as habilidades desbloqueadas
  void mostrarHabilidades() {
    if (habilidades.isEmpty) {
      print('Nenhuma habilidade desbloqueada ainda.');
      return;
    }

    print('\n╔════════ HABILIDADES ════════╗');
    for (int i = 0; i < habilidades.length; i++) {
      print('║ [$i] ${habilidades[i].formato()}');
    }
    print('╚═════════════════════════════╝\n');
  }

  void sofrerDano(int dano) {
    hp = (hp - dano).clamp(0, maxHp);
  }

  void curar(int amount) {
    hp = (hp + amount).clamp(0, maxHp);
  }

  @override
  String toString() =>
      '$nome (Nv.$nivel) | HP: $hp/$maxHp | ATK: $ataque | XP: $xp';
}
