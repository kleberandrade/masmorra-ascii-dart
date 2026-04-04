import 'dart:math';

import '../modelos/inimigo.dart';
import '../modelos/jogador.dart';

/// Cap. 36 — ação de combate (Command); executa efeitos no jogador.
abstract class AcaoCombate {
  void executar(Inimigo atacante, Jogador alvo, void Function(String) log);
  String get descricao;
}

/// Ataque corpo a corpo: [max(1, ataque − defesa do jogador)].
final class AcaoAtacar implements AcaoCombate {
  AcaoAtacar(this.atacante, this.alvo);

  final Inimigo atacante;
  final Jogador alvo;

  @override
  void executar(Inimigo atacanteReal, Jogador alvoReal, void Function(String) log) {
    final d = max(1, atacanteReal.ataque - alvoReal.defesa);
    alvoReal.danificar(d);
    log(
      '${atacanteReal.nome} acerta-te por $d (HP teu: ${alvoReal.hp}).',
    );
  }

  @override
  String get descricao {
    final d = max(1, atacante.ataque - alvo.defesa);
    return '${atacante.nome} prepara ataque (~$d).';
  }
}

/// Sem dano neste turno.
final class AcaoAguardar implements AcaoCombate {
  AcaoAguardar(this.atacante);

  final Inimigo atacante;

  @override
  void executar(Inimigo atacanteReal, Jogador alvoReal, void Function(String) log) {
    log('${atacanteReal.nome} hesita.');
  }

  @override
  String get descricao => '${atacante.nome} aguarda.';
}

/// Intenção de movimento (sem grade no MUD — só narrativa).
final class AcaoMover implements AcaoCombate {
  AcaoMover(this.atacante);

  final Inimigo atacante;

  @override
  void executar(Inimigo atacanteReal, Jogador alvoReal, void Function(String) log) {
    log('${atacanteReal.nome} avança em tua direção.');
  }

  @override
  String get descricao => '${atacante.nome} aproxima-se.';
}

/// Fuga: não ataca (turno “perdido” para o inimigo).
final class AcaoFuga implements AcaoCombate {
  AcaoFuga(this.atacante);

  final Inimigo atacante;

  @override
  void executar(Inimigo atacanteReal, Jogador alvoReal, void Function(String) log) {
    log('${atacanteReal.nome} recua, à procura de fuga!');
  }

  @override
  String get descricao => '${atacante.nome} tenta fugir!';
}
