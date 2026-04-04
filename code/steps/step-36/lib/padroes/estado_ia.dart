import '../modelos/inimigo.dart';
import 'acao.dart';

/// Interface para estados de IA (State pattern)
abstract class EstadoIA {
  EstadoIA? atualizar(Inimigo self, dynamic alvo, dynamic mapa);
  Acao agir(Inimigo self, dynamic alvo, dynamic mapa);
  String get nome;
}

/// Patrulha: estado de repouso
class Patrulhando implements EstadoIA {
  final List<dynamic> rota;
  int indiceRota = 0;

  Patrulhando(this.rota);

  @override
  EstadoIA? atualizar(Inimigo self, dynamic alvo, dynamic mapa) {
    // Se vê alvo, passa para Alerta
    return null; // Continua patrulhando
  }

  @override
  Acao agir(Inimigo self, dynamic alvo, dynamic mapa) {
    if (rota.isEmpty) {
      return AcaoAguardar(self);
    }

    // Sem coordenadas no modelo: avança o índice da rota a cada agir (demonstração).
    final proxPosicao = rota[indiceRota];
    indiceRota = (indiceRota + 1) % rota.length;
    return AcaoMover(self, proxPosicao);
  }

  @override
  String get nome => "Patrulhando";
}

/// Alerta: viu alvo, incerto
class Alerta implements EstadoIA {
  int turnosAlerta = 0;

  @override
  EstadoIA? atualizar(Inimigo self, dynamic alvo, dynamic mapa) {
    turnosAlerta++;
    if (turnosAlerta > 3) {
      return Patrulhando([]); // Perdeu interesse, volta a patrulhar
    }
    if (alvo != null) {
      final vivo = alvo.estaVivo;
      if (vivo is bool && vivo) {
        return Perseguindo();
      }
    }
    return null; // Continua em alerta
  }

  @override
  Acao agir(Inimigo self, dynamic alvo, dynamic mapa) {
    return AcaoAguardar(self);
  }

  @override
  String get nome => "Alerta";
}

/// Perseguindo: comprometido em perseguir
class Perseguindo implements EstadoIA {
  @override
  EstadoIA? atualizar(Inimigo self, dynamic alvo, dynamic mapa) {
    if (self.hpAtual < (self.hpMax * 30 / 100)) {
      return Fugindo();
    }
    if (alvo == null) {
      return Patrulhando([]);
    }
    final vivo = alvo.estaVivo;
    if (vivo is! bool || !vivo) {
      return Patrulhando([]);
    }
    // Simplificação: assume alcance de combate atingido
    return Atacando();
  }

  @override
  Acao agir(Inimigo self, dynamic alvo, dynamic mapa) {
    return AcaoMover(self, alvo);
  }

  @override
  String get nome => "Perseguindo";
}

/// Atacando: em combate direto
class Atacando implements EstadoIA {
  @override
  EstadoIA? atualizar(Inimigo self, dynamic alvo, dynamic mapa) {
    if (self.hpAtual < (self.hpMax * 25 / 100)) {
      return Fugindo();
    }
    return null;
  }

  @override
  Acao agir(Inimigo self, dynamic alvo, dynamic mapa) {
    return AcaoAtacar(self, alvo);
  }

  @override
  String get nome => "Atacando";
}

/// Fugindo: retirada estratégica
class Fugindo implements EstadoIA {
  int turnosFuga = 0;

  @override
  EstadoIA? atualizar(Inimigo self, dynamic alvo, dynamic mapa) {
    turnosFuga++;

    if (self.hpAtual > (self.hpMax * 60 / 100)) {
      return Perseguindo();
    }

    if (turnosFuga > 10) {
      return Patrulhando([]);
    }

    return null;
  }

  @override
  Acao agir(Inimigo self, dynamic alvo, dynamic mapa) {
    return AcaoFuga(self, alvo);
  }

  @override
  String get nome => "Fugindo";
}
