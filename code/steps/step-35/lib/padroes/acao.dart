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

/// Ação de movimento (simplificada — posição não modelada em Inimigo)
class AcaoMover implements Acao {
  final Inimigo self;
  final dynamic destino;

  AcaoMover(this.self, this.destino);

  @override
  void executar() {
    // Em um jogo completo, aqui atualizaríamos self.x / self.y.
    // Como Inimigo não possui coordenadas neste step,
    // a ação apenas registra a intenção de movimento.
  }

  @override
  void desfazer() {
    // Restauraria self.x / self.y para a posição anterior.
  }

  @override
  String get descricao => "${self.nome} se move em direção ao alvo";
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
