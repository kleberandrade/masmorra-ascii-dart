mixin Combatente {
  int hp = 0;
  int maxHp = 0;

  void sofrerDano(int d) {
    hp -= d;
    if (hp < 0) {
      hp = 0;
    }
  }

  void curar(int q) {
    hp += q;
    if (hp > maxHp) {
      hp = maxHp;
    }
  }

  bool get estaVivo => hp > 0;

  String mostrarBarraVida() {
    final pre = '█' * (hp ~/ (maxHp ~/ 10 + 1));
    final vaz = '░' * (10 - pre.length);
    return '[$pre$vaz] $hp/$maxHp';
  }
}
