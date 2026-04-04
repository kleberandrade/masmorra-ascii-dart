import '../modelos/inimigo.dart';
import '../modelos/jogador.dart';
import 'acao_combate.dart';

/// Cap. 36 — estado de IA (State pattern) para [Inimigo].
abstract class EstadoIa {
  EstadoIa? atualizar(Inimigo self, Jogador alvo);
  AcaoCombate agir(Inimigo self, Jogador alvo);
  String get nome;
}

bool _jogadorVivo(Jogador alvo) => alvo.hp > 0;

/// Combate direto (estado inicial típico no MUD).
final class Atacando implements EstadoIa {
  @override
  EstadoIa? atualizar(Inimigo self, Jogador alvo) {
    if (self.hp <= 0) {
      return null;
    }
    if (self.hp * 100 <= self.hpMax * 25) {
      return Fugindo();
    }
    return null;
  }

  @override
  AcaoCombate agir(Inimigo self, Jogador alvo) {
    return AcaoAtacar(self, alvo);
  }

  @override
  String get nome => 'Atacando';
}

/// Perseguição: um turno de aproximação antes de voltar a atacar.
final class Perseguindo implements EstadoIa {
  @override
  EstadoIa? atualizar(Inimigo self, Jogador alvo) {
    if (self.hp * 100 < self.hpMax * 30) {
      return Fugindo();
    }
    if (!_jogadorVivo(alvo)) {
      return Patrulhando(const []);
    }
    return Atacando();
  }

  @override
  AcaoCombate agir(Inimigo self, Jogador alvo) {
    return AcaoMover(self);
  }

  @override
  String get nome => 'Perseguindo';
}

/// Fuga: não inflige dano; pode voltar a perseguir com HP alto.
final class Fugindo implements EstadoIa {
  int _turnos = 0;

  @override
  EstadoIa? atualizar(Inimigo self, Jogador alvo) {
    _turnos++;
    if (self.hp * 100 > self.hpMax * 60) {
      return Perseguindo();
    }
    if (_turnos > 10) {
      return Patrulhando(const []);
    }
    return null;
  }

  @override
  AcaoCombate agir(Inimigo self, Jogador alvo) {
    return AcaoFuga(self);
  }

  @override
  String get nome => 'Fugindo';
}

/// Patrulha / idle — sem rota no MUD: aguarda.
final class Patrulhando implements EstadoIa {
  Patrulhando(this.rota);

  final List<Object?> rota;

  @override
  EstadoIa? atualizar(Inimigo self, Jogador alvo) {
    return null;
  }

  @override
  AcaoCombate agir(Inimigo self, Jogador alvo) {
    if (rota.isEmpty) {
      return AcaoAguardar(self);
    }
    return AcaoMover(self);
  }

  @override
  String get nome => 'Patrulhando';
}

/// Alerta: hesita antes de perseguir.
final class Alerta implements EstadoIa {
  int _turnos = 0;

  @override
  EstadoIa? atualizar(Inimigo self, Jogador alvo) {
    _turnos++;
    if (_turnos > 3) {
      return Patrulhando(const []);
    }
    if (_jogadorVivo(alvo)) {
      return Perseguindo();
    }
    return null;
  }

  @override
  AcaoCombate agir(Inimigo self, Jogador alvo) {
    return AcaoAguardar(self);
  }

  @override
  String get nome => 'Alerta';
}
