/// Jogador mínimo para demo do cap. 26 (chefão e tela de fim).
class Jogador {
  Jogador({
    required this.nome,
    this.nivel = 1,
    this.hp = 100,
    this.maxHp = 100,
    this.ataque = 5,
  });

  final String nome;
  int nivel;
  int hp;
  int maxHp;
  int ataque;

  void sofrerDano(int dano) {
    hp -= dano;
    if (hp < 0) {
      hp = 0;
    }
  }
}
