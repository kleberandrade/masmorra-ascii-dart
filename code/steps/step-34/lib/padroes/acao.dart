import 'dart:math';
import '../modelos/inimigo.dart';

/// Interface para ações reversíveis (Command pattern)
abstract class Acao {
  void executar();
  void desfazer();
  String get descricao;
}

/// Ação de ataque
class AcaoAtacar implements Acao {
  final Inimigo atacante;
  final dynamic alvo;
  late int dano;
  late int hpAnterior;

  AcaoAtacar(this.atacante, this.alvo);

  @override
  void executar() {
    hpAnterior = alvo.hpAtual as int;
    dano = max(1, atacante.ataque - (alvo.defesa as int));
    alvo.sofrerDano(dano);
  }

  @override
  void desfazer() {
    alvo.hpAtual = hpAnterior;
  }

  @override
  String get descricao => "${atacante.nome} ataca ${alvo.nome} por $dano!";
}

/// Ação de movimento
class AcaoMover implements Acao {
  final Inimigo self;
  final dynamic destino;
  final dynamic mapa;
  late int origemX;
  late int origemY;

  AcaoMover(this.self, this.destino, this.mapa);

  @override
  void executar() {
    origemX = self.x;
    origemY = self.y;
    final d = destino;
    if (d is Map && d.containsKey('x') && d.containsKey('y')) {
      self.x = d['x'] as int;
      self.y = d['y'] as int;
    }
  }

  @override
  void desfazer() {
    self.x = origemX;
    self.y = origemY;
  }

  @override
  String get descricao => "${self.nome} se move";
}

/// Ação de fuga
class AcaoFuga implements Acao {
  final Inimigo self;
  final dynamic alvo;

  AcaoFuga(this.self, this.alvo);

  @override
  void executar() {
    // Fuga reduz dano tomado
  }

  @override
  void desfazer() {
    //
  }

  @override
  String get descricao => "${self.nome} tenta fugir!";
}

/// Ação que não faz nada
class AcaoAguardar implements Acao {
  final dynamic self;

  AcaoAguardar(this.self);

  @override
  void executar() {}

  @override
  void desfazer() {}

  @override
  String get descricao => "${self.nome} aguarda";
}
