import 'player.dart';

/// Cap. 14 — família selada; Cap. 28 — estratégias de turno.
sealed class Enemy {
  Enemy({required this.hp, required this.nome});
  int hp;
  final String nome;

  int get danoBase;

  void executarTurno(Player alvo, void Function(String) log) {
    final d = danoBase;
    alvo.danificar(d);
    log('$nome acerta-te por $d (HP teu: ${alvo.hp}).');
  }

  bool get morto => hp <= 0;
}

final class Goblin extends Enemy {
  Goblin() : super(hp: 6, nome: 'Goblin');
  @override
  int get danoBase => 2;
}

final class Skeleton extends Enemy {
  Skeleton() : super(hp: 8, nome: 'Esqueleto');
  @override
  int get danoBase => 3;
}

final class Slime extends Enemy {
  Slime() : super(hp: 5, nome: 'Slime');
  @override
  int get danoBase => 1;
}
