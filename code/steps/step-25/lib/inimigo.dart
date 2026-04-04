/// Alvo mínimo para habilidades no demo do cap. 25.
class Inimigo {
  Inimigo({required this.nome, required this.hp});

  final String nome;
  int hp;

  bool get estaVivo => hp > 0;

  /// Aplica dano; devolve `true` se o inimigo ficou derrotado.
  bool sofrerDano(int d) {
    hp -= d;
    if (hp < 0) {
      hp = 0;
    }
    return !estaVivo;
  }
}
