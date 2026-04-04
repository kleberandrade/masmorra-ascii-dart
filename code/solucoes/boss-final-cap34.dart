/// Boss Final Capítulo 34: Comportamento Adaptativo de Inimigos
///
/// Objetivo: Inimigo começa com IAPatrulha. Após sofrer 3 ataques
/// consecutivos sem conseguir contra-atacar, muda para IAAgressiva.
/// Contador reseta quando consegue atacar.
///
/// Conceitos abordados:
/// - Padrão Strategy para IA
/// - Máquina de estados implícita
/// - Lógica de transição
/// - Interfaces/protocolos

void main() {
  print('═══════════════════════════════════════════════════════════');
  print('  Boss Final Capítulo 34: Comportamento Adaptativo');
  print('═══════════════════════════════════════════════════════════');
  print('');

  var inimigo = InimigoAdaptativo(nome: 'Lobo Selvagem');

  print('TESTE 1: Estado inicial - Patrulha');
  print('  Comportamento: ${inimigo.obterDescricao()}');
  print('');

  print('TESTE 2: Sofrer 3 ataques sem contra-atacar -> muda para Agressivo');
  for (var i = 1; i <= 3; i++) {
    print('  Ataque $i recebido...');
    inimigo.sofrerAtaque();
    print('  Comportamento: ${inimigo.obterDescricao()}');
    print('  Contador: ${inimigo.contadorAtaquesConsecutivos}/3');
  }
  print('');

  print('TESTE 3: Após mudar para agressivo, contra-ataca');
  print('  Ação do inimigo: ${inimigo.agir()}');
  print('  (Contador reseta ao contra-atacar)');
  print('  Contador: ${inimigo.contadorAtaquesConsecutivos}/3');
  print('');

  print('TESTE 4: Sofrer mais ataques em modo agressivo');
  for (var i = 1; i <= 2; i++) {
    inimigo.sofrerAtaque();
    print('  Ataque $i | Contador: ${inimigo.contadorAtaquesConsecutivos}');
  }
  print('');

  print('═══════════════════════════════════════════════════════════');
  print('  IA Adaptativa: Se você é agressivo, inimigo responde');
  print('═══════════════════════════════════════════════════════════');
}

/// Interface para comportamento de IA
abstract class ComportamentoIA {
  String obterNome();
  String agir();
  void sofrerAtaque();
}

/// Comportamento 1: Patrulha (passivo)
class IAPatrulha implements ComportamentoIA {
  @override
  String obterNome() => 'Patrulha';

  @override
  String agir() => 'anda em círculos, sem notá-lo';

  @override
  void sofrerAtaque() {
    // Patrulha não reage muito, apenas nota
  }
}

/// Comportamento 2: Agressivo (ofensivo)
class IAAgressiva implements ComportamentoIA {
  @override
  String obterNome() => 'Agressiva';

  @override
  String agir() => 'URRA! Avança com fúria!';

  @override
  void sofrerAtaque() {
    // Agressivo reage intensamente
  }
}

/// Comportamento 3: Defensivo (fuga)
class IADefensiva implements ComportamentoIA {
  @override
  String obterNome() => 'Defensiva';

  @override
  String agir() => 'tenta se esquivar e recua';

  @override
  void sofrerAtaque() {
    // Defensivo quer fugir
  }
}

/// Inimigo com IA adaptativa
class InimigoAdaptativo {
  final String nome;
  late ComportamentoIA _comportamento;
  int contadorAtaquesConsecutivos = 0;
  static const int _limiteParaMudarComportamento = 3;

  InimigoAdaptativo({required this.nome}) {
    // Começar em patrulha
    _comportamento = IAPatrulha();
  }

  /// Obter descrição do comportamento atual
  String obterDescricao() => '${nome} está em modo ${_comportamento.obterNome()}';

  /// Inimigo sofre um ataque
  void sofrerAtaque() {
    contadorAtaquesConsecutivos++;

    print('  -> ${nome} levou um ataque! (${contadorAtaquesConsecutivos}/$_limiteParaMudarComportamento)');

    // Verificar se deve mudar de comportamento
    if (contadorAtaquesConsecutivos >= _limiteParaMudarComportamento &&
        _comportamento is! IAAgressiva) {
      print('  -> ${nome} está furioso!');
      _comportamento = IAAgressiva();
      contadorAtaquesConsecutivos = 0;
    }
  }

  /// Inimigo age
  String agir() {
    var acao = _comportamento.agir();

    // Se em modo agressivo e contra-atacou, reseta contador
    if (_comportamento is IAAgressiva) {
      contadorAtaquesConsecutivos = 0;
    }

    return acao;
  }

  /// Passar um turno (sem ação ofensiva)
  void passarTurno() {
    // Contador mantém; só reseta se contra-atacar
  }

  /// Voltar a patrulha (quando perde interesse)
  void voltarAPatrulha() {
    _comportamento = IAPatrulha();
    contadorAtaquesConsecutivos = 0;
  }
}

/// Versão alternativa com mais estados
class InimigoComMaquinaDeEstados {
  enum Estado { patrulhando, alerta, perseguindo, atacando, fugindo }

  final String nome;
  Estado _estado = Estado.patrulhando;
  int _hpAtual;
  int _hpMax;

  InimigoComMaquinaDeEstados({
    required this.nome,
    required int hpMax,
  })  : _hpMax = hpMax,
        _hpAtual = hpMax;

  /// Atualizar estado baseado em HP
  void atualizarEstado() {
    var porcentagemHP = (_hpAtual / _hpMax) * 100;

    if (porcentagemHP < 25) {
      _estado = Estado.fugindo;
    } else if (porcentagemHP < 50) {
      _estado = Estado.alerta;
    } else {
      _estado = Estado.patrulhando;
    }
  }

  /// Sofrer dano e atualizar estado
  void sofrerDano(int dano) {
    _hpAtual -= dano;
    if (_hpAtual < 0) _hpAtual = 0;
    atualizarEstado();
  }

  /// Obter símbolo visual do inimigo baseado em estado
  String obterSimbolo() {
    switch (_estado) {
      case Estado.patrulhando:
        return 'L';
      case Estado.alerta:
        return 'L?';
      case Estado.perseguindo:
        return 'L!';
      case Estado.atacando:
        return 'L!!';
      case Estado.fugindo:
        return 'L..';
    }
  }
}
