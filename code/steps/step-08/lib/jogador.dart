class Jogador {
  String nome;
  int hp;
  int maxHp;
  int ouro;
  int ataque;
  String salaAtual;
  List<String> inventario;

  Jogador(
    this.nome, {
    this.hp = 100,
    this.maxHp = 100,
    this.ouro = 0,
    this.ataque = 5,
    this.salaAtual = 'praca',
    List<String>? inventario,
  }) : inventario = inventario ?? [];

  void sofrerDano(int quantidade) {
    hp -= quantidade;
    if (hp < 0) {
      hp = 0;
    }
  }

  void curar(int quantidade) {
    hp += quantidade;
    if (hp > maxHp) {
      hp = maxHp;
    }
  }

  bool gastarOuro(int quantidade) {
    if (ouro < quantidade) {
      return false;
    }
    ouro -= quantidade;
    return true;
  }

  void receberOuro(int quantidade) {
    ouro += quantidade;
  }

  bool get estaVivo => hp > 0;
  bool get inventarioCheio => inventario.length >= 10;

  bool pegarItem(String item) {
    if (inventarioCheio) {
      return false;
    }
    inventario.add(item);
    return true;
  }

  bool largarItem(String item) {
    return inventario.remove(item);
  }

  @override
  String toString() {
    return 'Jogador($nome, HP: $hp/$maxHp, Ouro: ${ouro}g, '
        'Sala: $salaAtual, Itens: ${inventario.length})';
  }
}
