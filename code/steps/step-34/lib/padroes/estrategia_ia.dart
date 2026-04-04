import '../modelos/inimigo.dart';
import 'acao.dart';

/// Interface para estratégias de IA
abstract class EstrategiaIa {
  Acao decidir(Inimigo self, dynamic alvo, dynamic mapa);
}

/// Estratégia agressiva: persegue e ataca
class IAAgressiva implements EstrategiaIa {
  @override
  Acao decidir(Inimigo self, dynamic alvo, dynamic mapa) {
    return AcaoAtacar(self, alvo);
  }
}

/// Estratégia covarde: foge quando ferido
class IACovardia implements EstrategiaIa {
  final int limiteHP;

  IACovardia({this.limiteHP = 30});

  @override
  Acao decidir(Inimigo self, dynamic alvo, dynamic mapa) {
    if (self.hpAtual < (self.hpMax * limiteHP / 100)) {
      return AcaoFuga(self, alvo);
    }
    return AcaoAtacar(self, alvo);
  }
}

/// Estratégia passiva: ignora até ser atacado
class IAPassiva implements EstrategiaIa {
  bool foiAtacada = false;

  @override
  Acao decidir(Inimigo self, dynamic alvo, dynamic mapa) {
    if (!foiAtacada) {
      return AcaoAguardar(self);
    }
    return AcaoAtacar(self, alvo);
  }
}

/// Estratégia de patrulha: segue rota até detectar alvo
class IAPatrulha implements EstrategiaIa {
  final List<dynamic> rota;
  int indiceRota = 0;
  bool emCombate = false;

  IAPatrulha(this.rota);

  @override
  Acao decidir(Inimigo self, dynamic alvo, dynamic mapa) {
    // Simplificado: detecta alvo por proximidade
    if (alvo != null) {
      final vivo = alvo.estaVivo;
      if (vivo is bool && vivo) {
        emCombate = true;
      }
    }

    if (emCombate) {
      return AcaoAtacar(self, alvo);
    }

    // Patrulha: segue a rota
    if (rota.isEmpty) {
      return AcaoAguardar(self);
    }

    var proxAlvo = rota[indiceRota];
    indiceRota = (indiceRota + 1) % rota.length;
    return AcaoMover(self, proxAlvo, mapa);
  }
}

/// Estratégia do chefe: muda de tática conforme HP cai
class BossComFases implements EstrategiaIa {
  late EstrategiaIa estrategiaAtual = IAAgressiva();

  @override
  Acao decidir(Inimigo self, dynamic alvo, dynamic mapa) {
    if (self.hpAtual < (self.hpMax * 50 / 100)) {
      estrategiaAtual = IACovardia(limiteHP: 20);
    } else if (self.hpAtual < (self.hpMax * 25 / 100)) {
      estrategiaAtual = IAAgressiva(); // Desesperado
    }

    return estrategiaAtual.decidir(self, alvo, mapa);
  }
}
