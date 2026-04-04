/// Boss Final Capítulo 25: Invencibilidade Temporária (Fúria Perfeita)
///
/// Objetivo: Se derrotar 5 inimigos seguidos sem dano, entra em
/// "Fúria Perfeita" e ganha +50% XP na próxima vitória.
/// Rastrear streakSemDano e testar.
///
/// Conceitos abordados:
/// - Rastreamento de estado
/// - Multiplicadores de recompensa
/// - Getters computados
/// - Lógica de combate com streaks

void main() {
  print('═══════════════════════════════════════════════════════════');
  print('  Boss Final Capítulo 25: Invencibilidade Temporária');
  print('═══════════════════════════════════════════════════════════');
  print('');

  var jogador = Jogador(nome: 'Guerreiro Lendário');

  // Teste 1: Derrotar 5 inimigos sem dano
  print('TESTE 1: Derrotar 5 inimigos sem sofrer dano');
  for (var i = 1; i <= 5; i++) {
    jogador.derrotarInimigo(danoRecebido: 0, xpGanho: 100);
    print('  Inimigo $i derrotado | Streak: ${jogador.streakSemDano} | '
        'Fúria Perfeita: ${jogador.emFuriaPerfeita ? "SIM" : "NÃO"}');
  }
  print('');

  // Teste 2: Próxima vitória com Fúria Perfeita (+50% XP)
  print('TESTE 2: Próxima vitória com bônus de Fúria Perfeita');
  jogador.derrotarInimigo(danoRecebido: 0, xpGanho: 100);
  print('  XP ganho com bônus: ${jogador.xpTotal} (100 + 50 de bônus)');
  print('  Fúria Perfeita ativada: ${jogador.emFuriaPerfeita ? "SIM" : "NÃO"}');
  print('');

  // Teste 3: Sofrer dano reseta streak
  print('TESTE 3: Sofrer dano reseta streak');
  jogador.derrotarInimigo(danoRecebido: 10, xpGanho: 100);
  print('  Streak resetada: ${jogador.streakSemDano}');
  print('');

  // Teste 4: Reconstruir streak
  print('TESTE 4: Reconstruir streak');
  for (var i = 1; i <= 3; i++) {
    jogador.derrotarInimigo(danoRecebido: 0, xpGanho: 100);
    print('  Vitória $i sem dano | Streak: ${jogador.streakSemDano}');
  }
  print('');

  print('═══════════════════════════════════════════════════════════');
  print('  Fúria Perfeita: Incentiva jogo sem falhas');
  print('═══════════════════════════════════════════════════════════');
}

/// Classe Jogador com sistema de Fúria Perfeita
class Jogador {
  final String nome;
  int xpTotal = 0;
  int _streakSemDano = 0;

  Jogador({required this.nome});

  /// Getter que retorna o streak atual
  int get streakSemDano => _streakSemDano;

  /// Getter que verifica se está em Fúria Perfeita
  /// Fúria Perfeita ocorre quando streak >= 5
  bool get emFuriaPerfeita => _streakSemDano >= 5;

  /// Derrotar um inimigo e registrar o combate
  void derrotarInimigo({required int danoRecebido, required int xpGanho}) {
    if (danoRecebido == 0) {
      // Sem dano: incrementar streak
      _streakSemDano++;
    } else {
      // Sofreu dano: resetar streak
      _streakSemDano = 0;
    }

    // Aplicar bônus de Fúria Perfeita (50% extra)
    var xpAplicar = xpGanho;
    if (emFuriaPerfeita) {
      xpAplicar = (xpGanho * 1.5).toInt();
      print('    ⭐ FÚRIA PERFEITA! +50% XP!');
    }

    xpTotal += xpAplicar;
  }

  /// Informações do jogador
  void exibirStatus() {
    print('Jogador: $nome');
    print('XP Total: $xpTotal');
    print('Streak sem dano: $streakSemDano/5');
    print('Status: ${emFuriaPerfeita ? "🔥 FÚRIA PERFEITA!" : "Normal"}');
  }
}

/// Alternativa: Sistema com repouso de Fúria Perfeita
class JogadorComRepouso {
  final String nome;
  int xpTotal = 0;
  int _streakSemDano = 0;
  int _turnosEmFuria = 0; // Quantos turnos faltam para perder Fúria

  JogadorComRepouso({required this.nome});

  int get streakSemDano => _streakSemDano;

  bool get emFuriaPerfeita => _streakSemDano >= 5;

  int get turnosRestantesEmFuria => _turnosEmFuria;

  /// Derrotar inimigo com repouso de Fúria
  void derrotarInimigo({
    required int danoRecebido,
    required int xpGanho,
  }) {
    if (danoRecebido == 0) {
      _streakSemDano++;

      if (emFuriaPerfeita) {
        _turnosEmFuria = 10; // Mantém Fúria por 10 turnos
      }
    } else {
      _streakSemDano = 0;
      _turnosEmFuria = 0; // Perde Fúria
    }

    var xpAplicar = xpGanho;
    if (emFuriaPerfeita) {
      xpAplicar = (xpGanho * 1.5).toInt();
    }

    xpTotal += xpAplicar;
  }

  /// Passar um turno (reduz contador de Fúria)
  void passarTurno() {
    if (_turnosEmFuria > 0) {
      _turnosEmFuria--;
    } else if (_turnosEmFuria == 0 && emFuriaPerfeita) {
      // Fúria expirou
      print('Fúria Perfeita expirou!');
    }
  }
}
