/// Classe base abstrata para todas as habilidades
abstract class Habilidade {
  final String nome;
  final String descricao;
  final int nivelRequerido;

  Habilidade({
    required this.nome,
    required this.descricao,
    required this.nivelRequerido,
  });

  bool executar();

  String formato() {
    return '[$nome] (Nív $nivelRequerido) - $descricao';
  }

  @override
  String toString() => formato();
}

/// Habilidade: Golpe Forte
/// Desbloqueado no nível 3
/// Dano: 2× o ataque normal
class GolpeFort extends Habilidade {
  GolpeFort()
      : super(
        nome: 'Golpe Forte',
        descricao: 'Ataque de 2x dano. Gasta 1 turno.',
        nivelRequerido: 3,
      );

  @override
  bool executar() {
    print('\nVocê executa um GOLPE FORTE!');
    print('   Dano: 2x');
    return true;
  }
}

/// Habilidade: Curar
/// Desbloqueado no nível 5
/// Efeito: +30% do HP máximo
class Curar extends Habilidade {
  Curar()
      : super(
        nome: 'Curar',
        descricao: 'Recupera 30% do HP máximo. Gasta 1 turno.',
        nivelRequerido: 5,
      );

  @override
  bool executar() {
    print('\nVocê invoca CURAR!');
    print('   Recuperou HP');
    return true;
  }
}

/// Habilidade: Ataque Rápido (nível 7)
/// Ataque 2x de 60% cada
class AtaqueRapido extends Habilidade {
  AtaqueRapido()
      : super(
        nome: 'Ataque Rápido',
        descricao: 'Dois ataques rápidos de 60% cada. Gasta 1 turno.',
        nivelRequerido: 7,
      );

  @override
  bool executar() {
    print('\nVocê executa ATAQUE RÁPIDO!');
    print('   Golpe 1: 60% de dano');
    print('   Golpe 2: 60% de dano');
    return true;
  }
}
