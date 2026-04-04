import '../ia/estado_ia.dart';
import 'jogador.dart';

/// Cap. 14 — família selada; Cap. 28 — estratégias; Cap. 36 — FSM ([EstadoIa]).
sealed class Inimigo {
  Inimigo({
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

  void executarTurno(Jogador alvo, void Function(String) log) {
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

final class Goblin extends Inimigo {
  Goblin()
      : super(
          hpMax: 6,
          nome: 'Goblin',
          ataque: 2,
          estadoInicial: Atacando(),
        );
}

final class Esqueleto extends Inimigo {
  Esqueleto()
      : super(
          hpMax: 8,
          nome: 'Esqueleto',
          ataque: 3,
          estadoInicial: Atacando(),
        );
}

final class Gosma extends Inimigo {
  Gosma()
      : super(
          hpMax: 5,
          nome: 'Gosma',
          ataque: 1,
          estadoInicial: Atacando(),
        );
}
