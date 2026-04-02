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
  final int destinoX;
  final int destinoY;
  late int origemX;
  late int origemY;

  AcaoMover(this.self, this.destinoX, this.destinoY);

  @override
  void executar() {
    origemX = self.x;
    origemY = self.y;
    self.x = destinoX;
    self.y = destinoY;
  }

  @override
  void desfazer() {
    self.x = origemX;
    self.y = origemY;
  }

  @override
  String get descricao => "${self.nome} se move para ($destinoX, $destinoY)";
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
