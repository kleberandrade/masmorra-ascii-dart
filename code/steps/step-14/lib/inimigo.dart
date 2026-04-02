import 'dart:math';
import 'combatente.dart';
import 'item.dart';

abstract class Inimigo with Combatente {
  final String id;
  final String nome;
  final String simbolo;
  final int danoBase;
  final String descricao;

  Inimigo({
    required this.id,
    required this.nome,
    required this.simbolo,
    required int hpInicial,
    required int maxHpInicial,
    required this.danoBase,
    required this.descricao,
  }) {
    hp = hpInicial;
    maxHp = maxHpInicial;
  }

  String descreverAcao();

  int calcularDano() {
    final random = Random();
    final variacao = (danoBase * 0.15).toInt();
    return danoBase - variacao + random.nextInt(variacao * 2);
  }

  int calcularOuroDrop() {
    return 10 + Random().nextInt(10);
  }

  int calcularXPDrop() {
    return 50;
  }

  Item? gerarLoot() {
    return null;
  }

  @override
  String toString() => '$nome ${mostrarBarraVida()}';
}

class Zumbi extends Inimigo {
  Zumbi()
      : super(
          id: 'zumbi',
          nome: 'Zumbi Pilhador',
          simbolo: 'Z',
          hpInicial: 30,
          maxHpInicial: 30,
          danoBase: 6,
          descricao: 'Criatura decomposta.',
        );

  @override
  String descreverAcao() => 'O Zumbi grunhe e avança!';

  @override
  Item? gerarLoot() {
    if (Random().nextDouble() < 0.5) {
      return Item(
        id: 'moedas-sujas',
        nome: 'Moedas Sujas',
        descricao: 'Roubo do zumbi',
        preco: 15,
        peso: 0,
      );
    }
    return null;
  }
}

class Esqueleto extends Inimigo {
  Esqueleto()
      : super(
          id: 'esqueleto',
          nome: 'Esqueleto Antigo',
          simbolo: 'E',
          hpInicial: 40,
          maxHpInicial: 40,
          danoBase: 7,
          descricao: 'Ossos antigos.',
        );

  @override
  String descreverAcao() => 'O Esqueleto levanta o braço ósseo!';
}

class Lobo extends Inimigo {
  Lobo()
      : super(
          id: 'lobo',
          nome: 'Lobo Selvagem',
          simbolo: 'L',
          hpInicial: 50,
          maxHpInicial: 50,
          danoBase: 8,
          descricao: 'Criatura selvagem.',
        );

  @override
  String descreverAcao() => 'O Lobo rosna!';

  @override
  Item? gerarLoot() {
    if (Random().nextDouble() < 0.6) {
      return Arma(
        id: 'fanga-lobo',
        nome: 'Fanga do Lobo',
        descricao: 'Arma antiga',
        preco: 100,
        peso: 3,
        dano: 7,
        tipo: 'cortante',
      );
    }
    return null;
  }
}

class Orc extends Inimigo {
  Orc()
      : super(
          id: 'orc',
          nome: 'Orc Guerreiro',
          simbolo: 'O',
          hpInicial: 70,
          maxHpInicial: 70,
          danoBase: 12,
          descricao: 'Criatura feroz.',
        );

  @override
  String descreverAcao() => 'O Orc desfere golpe furioso!';
}
