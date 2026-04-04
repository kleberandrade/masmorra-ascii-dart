mixin Combatente {
  int hp = 0;
  int maxHp = 0;

  void sofrerDano(int d) {
    hp -= d;
    if (hp < 0) {
      hp = 0;
    }
    print('Sofri $d de dano! HP agora é $hp');
  }

  void curar(int q) {
    hp += q;
    if (hp > maxHp) {
      hp = maxHp;
    }
    print('Curado por $q. HP agora é $hp');
  }

  bool get estaVivo => hp > 0;

  String mostrarBarraVida() {
    final preenchimento = '█' * (hp ~/ (maxHp ~/ 10 + 1));
    final vazio = '░' * (10 - preenchimento.length);
    return '[$preenchimento$vazio] $hp/$maxHp';
  }
}
