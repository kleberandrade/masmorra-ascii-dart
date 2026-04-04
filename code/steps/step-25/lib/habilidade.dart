import 'jogador.dart';
import 'inimigo.dart';

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

  bool executar(Jogador jogador, {Inimigo? alvo});

  String formato() {
    return '[$nome] (Nív $nivelRequerido) - $descricao';
  }
}

/// Habilidade: Golpe Forte
/// Desbloqueado no nível 3
/// Dano: 2× o ataque normal
class GolpeForte extends Habilidade {
  GolpeForte()
      : super(
        nome: 'Golpe Forte',
        descricao: 'Ataque de 2x dano. Gasta 1 turno.',
        nivelRequerido: 3,
      );

  @override
  bool executar(Jogador jogador, {Inimigo? alvo}) {
    if (alvo == null) return false;

    final danoDuplicado = jogador.ataque * 2;
    print('\n${jogador.nome} executa um GOLPE FORTE!');
    print('   Dano: $danoDuplicado');

    return alvo.sofrerDano(danoDuplicado);
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
  bool executar(Jogador jogador, {Inimigo? alvo}) {
    final curaQuantidade = (jogador.maxHp * 0.3).toInt();
    final hpAnterior = jogador.hp;
    jogador.hp = (jogador.hp + curaQuantidade).clamp(0, jogador.maxHp);
    final curaReal = jogador.hp - hpAnterior;

    print('\n${jogador.nome} invoca CURAR!');
    print('   Recuperou $curaReal HP');

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
  bool executar(Jogador jogador, {Inimigo? alvo}) {
    if (alvo == null) return false;

    final dano1 = (jogador.ataque * 0.6).toInt();
    final dano2 = (jogador.ataque * 0.6).toInt();

    print('\n${jogador.nome} executa ATAQUE RÁPIDO!');
    print('   Golpe 1: $dano1 de dano');
    alvo.sofrerDano(dano1);

    if (!alvo.estaVivo) return true;

    print('   Golpe 2: $dano2 de dano');
    return alvo.sofrerDano(dano2);
  }
}
