import 'dart:math';

import '../model/enemy.dart';
import '../model/player.dart';

/// Cap. 36 — ação de combate (Command); executa efeitos no jogador.
abstract class AcaoCombate {
  void executar(Enemy atacante, Player alvo, void Function(String) log);
  String get descricao;
}

/// Ataque corpo a corpo: [max(1, ataque − defesa do jogador)].
final class AcaoAtacar implements AcaoCombate {
  AcaoAtacar(this.atacante, this.alvo);

  final Enemy atacante;
  final Player alvo;

  @override
  void executar(Enemy atacanteReal, Player alvoReal, void Function(String) log) {
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

  final Enemy atacante;

  @override
  void executar(Enemy atacanteReal, Player alvoReal, void Function(String) log) {
    log('${atacanteReal.nome} hesita.');
  }

  @override
  String get descricao => '${atacante.nome} aguarda.';
}

/// Intenção de movimento (sem grade no MUD — só narrativa).
final class AcaoMover implements AcaoCombate {
  AcaoMover(this.atacante);

  final Enemy atacante;

  @override
  void executar(Enemy atacanteReal, Player alvoReal, void Function(String) log) {
    log('${atacanteReal.nome} avança em tua direção.');
  }

  @override
  String get descricao => '${atacante.nome} aproxima-se.';
}

/// Fuga: não ataca (turno “perdido” para o inimigo).
final class AcaoFuga implements AcaoCombate {
  AcaoFuga(this.atacante);

  final Enemy atacante;

  @override
  void executar(Enemy atacanteReal, Player alvoReal, void Function(String) log) {
    log('${atacanteReal.nome} recua, à procura de fuga!');
  }

  @override
  String get descricao => '${atacante.nome} tenta fugir!';
}
