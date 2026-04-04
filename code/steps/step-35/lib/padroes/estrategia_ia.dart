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
