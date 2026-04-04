import 'jogador.dart';

/// Classe base para inimigos
abstract class Inimigo {
  final String nome;
  int hp;
  int hpMax;
  int ataque;
  final String descricao;

  Inimigo({
    required this.nome,
    required this.hpMax,
    required this.ataque,
    required this.descricao,
  }) : hp = hpMax;

  bool get estaVivo => hp > 0;

  void sofrerDano(int dano) {
    hp = (hp - dano).clamp(0, hpMax);
  }

  void executarTurno(Jogador jogador) {
    print('$nome ataca!');
  }

  String descreverAcao() {
    return '$nome ataca!';
  }

  @override
  String toString() => '$nome (HP: $hp/$hpMax)';
}
