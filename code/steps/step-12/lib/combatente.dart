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
    final preenchimento = '█' * (hp ~/ (maxHp ~/ 10 + 1));
    final vazio = '░' * (10 - preenchimento.length);
    return '[$preenchimento$vazio] $hp/$maxHp';
  }
}

mixin Curavel on Combatente {
  void regenerar(int pontos) {
    curar(pontos);
  }
}

mixin Envenenavel on Combatente {
  int veneno = 0;

  void envenenar(int quantidade) {
    veneno += quantidade;
  }

  void aplicarDanoVeneno() {
    if (veneno > 0) {
      sofrerDano(veneno);
      veneno = 0;
    }
  }
}
