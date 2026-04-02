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

class Zumbi extends Inimigo {
  Zumbi()
      : super(
          nome: 'Zumbi',
          simbolo: 'Z',
          hp: 8,
          maxHp: 8,
          ataque: 3,
          descricao: 'Uma criatura de decomposição e vontade de carne.',
        );

  @override
  String descreverAcao() {
    return 'O Zumbi grunhe e avança, despedaçando o ar!';
  }
}

class Esqueleto extends Inimigo {
  Esqueleto()
      : super(
          nome: 'Esqueleto',
          simbolo: 'E',
          hp: 15,
          maxHp: 15,
          ataque: 4,
          descricao: 'Ossos antigos, alma presa. Rangem com cada passo.',
        );

  @override
  String descreverAcao() {
    return 'O Esqueleto levanta o braço ósseo, você sente o frio da morte.';
  }
}

class Lobo extends Inimigo {
  Lobo()
      : super(
          nome: 'Lobo',
          simbolo: 'L',
          hp: 5,
          maxHp: 5,
          ataque: 2,
          descricao: 'Uma criatura selvagem de garras afiadas.',
        );

  @override
  String descreverAcao() {
    return 'O Lobo rosna ameaçadoramente, dentes à mostra.';
  }
}

class Orc extends Inimigo {
  Orc()
      : super(
          nome: 'Orc',
          simbolo: 'O',
          hp: 12,
          maxHp: 12,
          ataque: 5,
          descricao: 'Uma criatura feroz de força bruta.',
        );

  @override
  String descreverAcao() {
    return 'O Orc desfere um grito de fúria e avança!';
  }
}
