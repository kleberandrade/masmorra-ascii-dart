abstract class Inimigo {
  final String nome;
  final String simbolo;
  int hp;
  final int maxHp;
  final int ataque;
  final String descricao;

  Inimigo({
    required this.nome,
    required this.simbolo,
    required this.hp,
    required this.maxHp,
    required this.ataque,
    required this.descricao,
  });

  void sofrerDano(int d) {
    hp -= d;
    if (hp < 0) {
      hp = 0;
    }
  }

  bool get estaVivo => hp > 0;

  String descreverAcao();

  @override
  String toString() => '$nome (HP: $hp/$maxHp), $descricao';
}
