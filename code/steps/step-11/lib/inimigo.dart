import 'combatente.dart';
import 'envenenavel.dart';

abstract class Inimigo with Combatente, Envenenavel {
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
          descricao: 'Uma criatura de decomposição e vontade de carne.',
        );

  @override
  String descreverAcao() {
    return 'O Zumbi grunhe e avança!';
  }
}

class Esqueleto extends Inimigo {
  Esqueleto()
      : super(
          nome: 'Esqueleto',
          simbolo: 'E',
          hpInicial: 15,
          maxHpInicial: 15,
          ataque: 4,
          descricao: 'Ossos antigos, alma presa. Rangem com cada passo.',
        );

  @override
  String descreverAcao() {
    return 'O Esqueleto levanta o braço ósseo!';
  }
}

class Lobo extends Inimigo {
  Lobo()
      : super(
          nome: 'Lobo',
          simbolo: 'L',
          hpInicial: 5,
          maxHpInicial: 5,
          ataque: 2,
          descricao: 'Uma criatura selvagem de garras afiadas.',
        );

  @override
  String descreverAcao() {
    return 'O Lobo rosna ameaçadoramente!';
  }
}

class Orc extends Inimigo {
  Orc()
      : super(
          nome: 'Orc',
          simbolo: 'O',
          hpInicial: 12,
          maxHpInicial: 12,
          ataque: 5,
          descricao: 'Uma criatura feroz de força bruta.',
        );

  @override
  String descreverAcao() {
    return 'O Orc desfere um grito de fúria!';
  }
}
