import '../ai/estado_ia.dart';
import 'player.dart';

/// Cap. 14 — família selada; Cap. 28 — estratégias; Cap. 36 — FSM ([EstadoIa]).
sealed class Enemy {
  Enemy({
    required this.hpMax,
    required this.nome,
    required this.ataque,
    this.defesa = 0,
    required EstadoIa estadoInicial,
  })  : hp = hpMax,
        estado = estadoInicial;

  int hp;
  final int hpMax;
  final String nome;
  final int ataque;
  final int defesa;
  EstadoIa estado;

  int get danoBase => ataque;

  void executarTurno(Player alvo, void Function(String) log) {
    final novo = estado.atualizar(this, alvo);
    if (novo != null) {
      estado = novo;
      log('$nome muda para ${estado.nome}.');
    }
    final acao = estado.agir(this, alvo);
    acao.executar(this, alvo, log);
  }

  bool get morto => hp <= 0;
}

final class Goblin extends Enemy {
  Goblin()
      : super(
          hpMax: 6,
          nome: 'Goblin',
          ataque: 2,
          estadoInicial: Atacando(),
        );
}

final class Skeleton extends Enemy {
  Skeleton()
      : super(
          hpMax: 8,
          nome: 'Esqueleto',
          ataque: 3,
          estadoInicial: Atacando(),
        );
}

final class Slime extends Enemy {
  Slime()
      : super(
          hpMax: 5,
          nome: 'Slime',
          ataque: 1,
          estadoInicial: Atacando(),
        );
}
