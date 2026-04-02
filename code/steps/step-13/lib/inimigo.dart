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

abstract class Inimigo with Combatente {
  final String nome;
  final String simbolo;
  final int ataque;
  final String descricao;

  Inimigo({
    required this.nome,
    required this.simbolo,
    required int hpInicial,
    required int maxHpInicial,
    required this.ataque,
    required this.descricao,
  }) {
    hp = hpInicial;
    maxHp = maxHpInicial;
  }

  String descreverAcao();

  @override
  String toString() => '$nome ${mostrarBarraVida()}, $descricao';
}

class Zumbi extends Inimigo {
  Zumbi()
      : super(
          nome: 'Zumbi',
          simbolo: 'Z',
          hpInicial: 8,
          maxHpInicial: 8,
          ataque: 3,
          descricao: 'Uma criatura de decomposição.',
        );

  @override
  String descreverAcao() => 'O Zumbi grunhe!';
}

class Esqueleto extends Inimigo {
  Esqueleto()
      : super(
          nome: 'Esqueleto',
          simbolo: 'E',
          hpInicial: 15,
          maxHpInicial: 15,
          ataque: 4,
          descricao: 'Ossos antigos com alma presa.',
        );

  @override
  String descreverAcao() => 'O Esqueleto levanta o braço ósseo!';
}

class Lobo extends Inimigo {
  Lobo()
      : super(
          nome: 'Lobo',
          simbolo: 'L',
          hpInicial: 5,
          maxHpInicial: 5,
          ataque: 2,
          descricao: 'Uma criatura selvagem.',
        );

  @override
  String descreverAcao() => 'O Lobo rosna!';
}

class Orc extends Inimigo {
  Orc()
      : super(
          nome: 'Orc',
          simbolo: 'O',
          hpInicial: 12,
          maxHpInicial: 12,
          ataque: 5,
          descricao: 'Uma criatura feroz.',
        );

  @override
  String descreverAcao() => 'O Orc grita!';
}
