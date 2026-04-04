/// Capítulo 36 - Máquinas de Estado: Patrulha, Alerta e Perseguição
/// Boss Final 36.10: Máquina de Estados Completa do Lobo
///
/// Implementa uma FSM (Finite State Machine) completa para um inimigo tipo Lobo
/// com estados: Patrulhando, Alerta, Perseguindo, Atacando, Fugindo.
/// O símbolo visual muda a cada estado.

/// Tipo para representar posição (simplificado)
typedef Posicao = (int x, int y);

/// Interface abstrata para estados da IA
abstract class EstadoIA {
  /// Atualiza e retorna novo estado (null = continua neste estado)
  EstadoIA? atualizar(Lobo self, Jogador alvo);

  /// Executa ação do estado
  String agir(Lobo self, Jogador alvo);

  /// Nome do estado para debug
  String get nome;

  /// Símbolo visual no mapa
  String get simbolo;
}

/// Estado: Patrulhando normalmente
class Patrulhando implements EstadoIA {
  @override
  String get nome => 'Patrulhando';

  @override
  String get simbolo => 'L';

  @override
  EstadoIA? atualizar(Lobo self, Jogador alvo) {
    // Se jogador está dentro de 5 tiles e tem linha de visão
    if (self.distancia(alvo.pos) <= 5) {
      return Alerta();
    }
    return null;
  }

  @override
  String agir(Lobo self, Jogador alvo) {
    return 'Patrulha tranquilamente pela masmorra';
  }
}

/// Estado: Alerta - viu o jogador mas não tem certeza
class Alerta implements EstadoIA {
  int turnosAlerta = 0;

  @override
  String get nome => 'Alerta';

  @override
  String get simbolo => 'L?';

  @override
  EstadoIA? atualizar(Lobo self, Jogador alvo) {
    // Se perdeu de vista, volta a patrulhar
    if (self.distancia(alvo.pos) > 5) {
      turnosAlerta++;
      if (turnosAlerta > 3) {
        return Patrulhando();
      }
      return null;
    }

    turnosAlerta = 0;

    // Se muito perto, vai para perseguição
    if (self.distancia(alvo.pos) <= 3) {
      return Perseguindo();
    }

    return null;
  }

  @override
  String agir(Lobo self, Jogador alvo) {
    return 'Fica em alerta, olhando para os lados';
  }
}

/// Estado: Perseguindo - atrás do alvo
class Perseguindo implements EstadoIA {
  @override
  String get nome => 'Perseguindo';

  @override
  String get simbolo => 'L!';

  @override
  EstadoIA? atualizar(Lobo self, Jogador alvo) {
    final dist = self.distancia(alvo.pos);

    // Perdeu de vista? Volta para alerta
    if (dist > 5) {
      return Alerta();
    }

    // Muito perto? Ataca!
    if (dist <= 1) {
      return Atacando();
    }

    // Muito ferido? Fuge!
    if (self.hp < (self.hpMax * 25 / 100)) {
      return Fugindo();
    }

    return null;
  }

  @override
  String agir(Lobo self, Jogador alvo) {
    return 'Persegue selvagemente em sua direção!';
  }
}

/// Estado: Atacando - em combate próximo
class Atacando implements EstadoIA {
  @override
  String get nome => 'Atacando';

  @override
  String get simbolo => 'L!!';

  @override
  EstadoIA? atualizar(Lobo self, Jogador alvo) {
    final dist = self.distancia(alvo.pos);

    // Afastou demais? Volta a perseguir
    if (dist > 1) {
      return Perseguindo();
    }

    // Muito ferido? Foge!
    if (self.hp < (self.hpMax * 20 / 100)) {
      return Fugindo();
    }

    return null;
  }

  @override
  String agir(Lobo self, Jogador alvo) {
    final dano = 8 + (self.agressividade > 50 ? 2 : 0);
    alvo.tomarDano(dano);
    return 'Lobo ataca violentamente! ${alvo.nome} toma $dano de dano';
  }
}

/// Estado: Fugindo - vida baixa, recuando
class Fugindo implements EstadoIA {
  int turnosFuga = 0;

  @override
  String get nome => 'Fugindo';

  @override
  String get simbolo => 'L..';

  @override
  EstadoIA? atualizar(Lobo self, Jogador alvo) {
    turnosFuga++;

    // Se regenerou, volta ao ataque
    if (self.hp > (self.hpMax * 60 / 100)) {
      turnosFuga = 0;
      return Perseguindo();
    }

    // Se fugiu muito tempo, volta a patrulhar
    if (turnosFuga > 10) {
      turnosFuga = 0;
      return Patrulhando();
    }

    return null;
  }

  @override
  String agir(Lobo self, Jogador alvo) {
    // Lobo foge para longe
    self.pos = (self.pos.$1 - 1, self.pos.$2);
    return 'Lobo grita e foge covardemente!';
  }
}

/// Representa um Lobo (inimigo com FSM)
class Lobo {
  String nome;
  Posicao pos;
  int hp;
  int hpMax = 40;
  int agressividade = 50; // 0-100

  late EstadoIA estado = Patrulhando();

  Lobo({
    required this.nome,
    required this.pos,
    int? hp,
  }) {
    hp = hp ?? hpMax;
  }

  /// Calcula distância Manhattan até outro ponto
  int distancia(Posicao outra) {
    return (pos.$1 - outra.$1).abs() + (pos.$2 - outra.$2).abs();
  }

  /// Símbolo visual baseado no estado
  String get simbolo => estado.simbolo;

  /// Executa turno do Lobo
  String executarTurno(Jogador alvo) {
    // Atualiza estado
    var novoEstado = estado.atualizar(this, alvo);
    if (novoEstado != null) {
      print('  [TRANSIÇÃO] $nome: ${estado.nome} → ${novoEstado.nome}');
      estado = novoEstado;
    }

    // Executa ação
    return estado.agir(this, alvo);
  }
}

/// Representa o jogador (alvo)
class Jogador {
  String nome;
  Posicao pos;
  int hp = 50;
  int hpMax = 50;

  Jogador({
    required this.nome,
    required this.pos,
  });

  void tomarDano(int dano) {
    hp -= dano;
    if (hp < 0) hp = 0;
  }
}

void main() {
  print('╔════════════════════════════════════════════╗');
  print('║     MÁQUINA DE ESTADOS COMPLETA            ║');
  print('║       Capítulo 36 - Boss Final             ║');
  print('╚════════════════════════════════════════════╝');
  print('');

  // Setup
  final heroi = Jogador(nome: 'Aventureiro', pos: (10, 10));
  final lobo = Lobo(nome: 'Lobo Selvagem', pos: (15, 10));

  print('Estados iniciais:');
  print('  Herói: ${heroi.nome} em ${heroi.pos} (${heroi.hp}/${heroi.hpMax} HP)');
  print('  Lobo: ${lobo.nome} em ${lobo.pos} [${lobo.simbolo}] (${lobo.hp}/${lobo.hpMax} HP)');
  print('');

  // Simulação de combate
  print('--- Simulação de Combate ---\n');

  for (int turno = 1; turno <= 12; turno++) {
    print('Turno $turno:');
    print('  Lobo: [${lobo.simbolo}] em ${lobo.pos} - ${lobo.estado.nome}');

    // Aproxima herói gradualmente
    if (turno > 2 && heroi.pos.$1 > lobo.pos.$1) {
      heroi.pos = (heroi.pos.$1 - 1, heroi.pos.$2);
    }
    print('  Herói: em ${heroi.pos} (${heroi.hp}/${heroi.hpMax} HP)');

    // Lobo atua
    final acao = lobo.executarTurno(heroi);
    print('  Ação: $acao');

    // Herói contra-ataca se perto
    if (lobo.distancia(heroi.pos) <= 1) {
      lobo.hp -= 5;
      print('  Herói contra-ataca! Lobo toma 5 de dano');
    }

    print('');

    // Verifica fim
    if (heroi.hp <= 0 || lobo.hp <= 0) {
      break;
    }
  }

  // Resultado
  print('--- Resultado ---');
  if (heroi.hp > 0) {
    print('✓ Herói venceu! (${heroi.hp} HP restantes)');
  } else {
    print('✗ Lobo venceu! (${lobo.hp} HP restantes)');
  }

  print('\nTransições de Estado Observadas:');
  print('  Patrulhando [L] → Alerta [L?] → Perseguindo [L!] → Atacando [L!!]');
  print('  Os estados formam uma máquina clara e visual.');
}
