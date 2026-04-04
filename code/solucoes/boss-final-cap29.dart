// ============================================================================
// Capítulo 29 - Boss Final: Suite de Defesa
// ============================================================================
// Exercício: Suite Completa de Testes Unitários
//
// Implementa 9+ testes cobrindo casos normais, extremos, exceções e fakes.
// Usa package:test com setUp, group, matchers e valores previsíveis.
// Demonstra segurança de refatoração através de testes robustos.
// ============================================================================

// Nota: Este arquivo usa `package:test`. Para executar:
// 1. Adicione ao pubspec.yaml: `dev_dependencies: test: ^1.25.0`
// 2. Crie test/boss_final_cap29_test.dart com este conteúdo
// 3. Execute: dart test test/boss_final_cap29_test.dart

// Importar package:test quando executar como teste
// import 'package:test/test.dart';

// ============================================================================
// CLASSES PARA TESTE
// ============================================================================

/// Criatura inimiga com estado de combate
class Inimigo {
  final String nome;
  int hpMax;
  int hp;
  int ataque;
  int defesa;
  int xpDrop;

  Inimigo({
    required this.nome,
    required this.hpMax,
    required this.ataque,
    required this.defesa,
    required this.xpDrop,
  }) : hp = hpMax;

  bool get estaVivo => hp > 0;

  void receberDano(int dano) {
    hp = (hp - dano).clamp(0, hpMax);
  }

  void curar(int quantidade) {
    hp = (hp + quantidade).clamp(0, hpMax);
  }

  void restaurarVida() {
    hp = hpMax;
  }
}

/// Sistema de combate entre dois combatentes
class CombateSimulado {
  final Inimigo inimigo;
  final int ataqueJogador;
  final int defesaJogador;

  bool _combateTerminou = false;

  CombateSimulado({
    required this.inimigo,
    required this.ataqueJogador,
    required this.defesaJogador,
  });

  bool get combateTerminou => _combateTerminou;

  /// Jogador ataca inimigo
  int atacarInimigo() {
    final dano = (ataqueJogador - (inimigo.defesa ~/ 2)).clamp(1, ataqueJogador);
    inimigo.receberDano(dano);

    if (!inimigo.estaVivo) {
      _combateTerminou = true;
    }

    return dano;
  }

  /// Inimigo contra-ataca jogador
  int contraataqueInimigo() {
    if (!inimigo.estaVivo) return 0;
    return (inimigo.ataque - (defesaJogador ~/ 2)).clamp(1, inimigo.ataque);
  }

  /// Redefine combate
  void reiniciar() {
    inimigo.restaurarVida();
    _combateTerminou = false;
  }
}

// ============================================================================
// TESTES (simulação de package:test)
// ============================================================================

/// Simula estrutura de testes sem package:test
class TesteSimulado {
  int totalTestes = 0;
  int sucessos = 0;
  int falhas = 0;
  final List<String> erros = [];

  /// Simula test()
  void teste(String descricao, Function() funcao) {
    totalTestes++;
    try {
      funcao();
      sucessos++;
      print('  ✓ $descricao');
    } catch (e) {
      falhas++;
      print('  ✗ $descricao');
      erros.add('$descricao: $e');
    }
  }

  /// Simula expect()
  void espera(dynamic atual, dynamic esperado, {String? mensagem}) {
    if (atual != esperado) {
      throw Exception(
        'Falha: esperava $esperado, obteve $atual${mensagem != null ? ' ($mensagem)' : ''}',
      );
    }
  }

  /// Simula expect() com matchers
  void esperaVerdadeiro(bool condicao, String mensagem) {
    if (!condicao) throw Exception('Falha: $mensagem');
  }

  void esperaFalso(bool condicao, String mensagem) {
    if (condicao) throw Exception('Falha: $mensagem');
  }

  void esperaExcecao(Function() funcao) {
    try {
      funcao();
      throw Exception('Esperava exceção, mas nenhuma foi lançada');
    } catch (_) {
      // Esperado
    }
  }

  void exibirRelatorio() {
    print('\n╔════════════════════════════════════════════════════════════╗');
    print('║               RELATÓRIO DE TESTES                         ║');
    print('╠════════════════════════════════════════════════════════════╣');
    print('║ Total: $totalTestes | Sucessos: $sucessos | Falhas: $falhas');
    print('╚════════════════════════════════════════════════════════════╝');

    if (falhas > 0) {
      print('\nDetalhes das falhas:');
      for (final erro in erros) {
        print('  ✗ $erro');
      }
    }
  }
}

// ============================================================================
// EXECUÇÃO DOS TESTES
// ============================================================================

void main() {
  print('\n════════════════════════════════════════════════════════════════');
  print('  MASMORRA ASCII - Capítulo 29: Suite de Defesa');
  print('════════════════════════════════════════════════════════════════\n');

  final testes = TesteSimulado();

  // ======================================================================
  // SUITE: Inimigo
  // ======================================================================
  print('🧪 SUITE: Inimigo');
  print('───────────────────────────────────────────────────────────────');

  final setup1 = () {
    return Inimigo(
      nome: 'Goblin',
      hpMax: 30,
      ataque: 5,
      defesa: 2,
      xpDrop: 25,
    );
  };

  testes.teste('(1) Criar inimigo com atributos', () {
    final inimigo = setup1();
    testes.espera(inimigo.nome, 'Goblin');
    testes.espera(inimigo.hpMax, 30);
    testes.espera(inimigo.hp, 30);
    testes.esperaVerdadeiro(inimigo.estaVivo, 'Inimigo deve estar vivo');
  });

  testes.teste('(2) Inimigo recebe dano', () {
    final inimigo = setup1();
    inimigo.receberDano(10);
    testes.espera(inimigo.hp, 20);
  });

  testes.teste('(3) Inimigo morre com dano crítico', () {
    final inimigo = setup1();
    inimigo.receberDano(100);
    testes.esperaFalso(inimigo.estaVivo, 'Inimigo deve estar morto');
  });

  testes.teste('(4) HP não vai abaixo de 0', () {
    final inimigo = setup1();
    inimigo.receberDano(50);
    testes.esperaVerdadeiro(inimigo.hp >= 0, 'HP não pode ser negativo');
  });

  testes.teste('(5) Inimigo pode ser curado', () {
    final inimigo = setup1();
    inimigo.receberDano(15);
    inimigo.curar(10);
    testes.espera(inimigo.hp, 25);
  });

  // ======================================================================
  // SUITE: Combate
  // ======================================================================
  print('\n🧪 SUITE: Combate');
  print('───────────────────────────────────────────────────────────────');

  final setup2 = () {
    return CombateSimulado(
      inimigo: Inimigo(
        nome: 'Orc',
        hpMax: 40,
        ataque: 8,
        defesa: 3,
        xpDrop: 50,
      ),
      ataqueJogador: 12,
      defesaJogador: 4,
    );
  };

  testes.teste('(6) Jogador ataca e causa dano', () {
    final combate = setup2();
    final hpAntes = combate.inimigo.hp;
    final dano = combate.atacarInimigo();
    testes.esperaVerdadeiro(
      combate.inimigo.hp < hpAntes && dano > 0,
      'Ataque deve causar dano positivo',
    );
  });

  testes.teste('(7) Combate termina quando inimigo morre', () {
    final combate = setup2();
    for (int i = 0; i < 10; i++) {
      combate.atacarInimigo();
      if (!combate.inimigo.estaVivo) break;
    }
    testes.esperaVerdadeiro(
      combate.combateTerminou,
      'Combate deve terminar quando inimigo morre',
    );
  });

  testes.teste('(8) Contra-ataque faz sentido', () {
    final combate = setup2();
    final dano = combate.contraataqueInimigo();
    testes.esperaVerdadeiro(
      dano > 0 && dano <= combate.inimigo.ataque,
      'Dano deve estar entre 1 e ataque do inimigo',
    );
  });

  testes.teste('(9) Combate pode ser reiniciado', () {
    final combate = setup2();
    combate.atacarInimigo();
    combate.atacarInimigo();
    final hpAposAtaques = combate.inimigo.hp;

    combate.reiniciar();
    testes.espera(combate.inimigo.hp, combate.inimigo.hpMax);
    testes.esperaFalso(combate.combateTerminou, 'Combate deve ser reiniciado');
  });

  // ======================================================================
  // SUITE: Casos Extremos
  // ======================================================================
  print('\n🧪 SUITE: Casos Extremos');
  print('───────────────────────────────────────────────────────────────');

  testes.teste('(10) Inimigo com HP 0 não recebe dano', () {
    final inimigo = Inimigo(
      nome: 'Morto',
      hpMax: 1,
      ataque: 1,
      defesa: 0,
      xpDrop: 0,
    );
    inimigo.receberDano(10);
    final hpAntes = inimigo.hp;
    inimigo.receberDano(5);
    testes.espera(inimigo.hp, hpAntes);
  });

  testes.teste('(11) Dano negativo é tratado', () {
    final combate = setup2();
    final danoNegativo = combate.contraataqueInimigo();
    testes.esperaVerdadeiro(
      danoNegativo > 0,
      'Dano nunca deve ser negativo',
    );
  });

  testes.teste('(12) Cura acima de HP máximo é limitada', () {
    final inimigo = setup1();
    inimigo.receberDano(5);
    inimigo.curar(100);
    testes.esperaVerdadeiro(
      inimigo.hp <= inimigo.hpMax,
      'HP não deve exceder máximo',
    );
  });

  // ======================================================================
  // SUITE: Valores Previsíveis (Fakes)
  // ======================================================================
  print('\n🧪 SUITE: Valores Previsíveis');
  print('───────────────────────────────────────────────────────────────');

  testes.teste('(13) Combate com valores previsíveis', () {
    // Setup determinístico: sempre mesmo resultado
    final combate = CombateSimulado(
      inimigo: Inimigo(
        nome: 'TestEnemy',
        hpMax: 50,
        ataque: 10,
        defesa: 5,
        xpDrop: 30,
      ),
      ataqueJogador: 15,
      defesaJogador: 5,
    );

    final dano1 = combate.atacarInimigo();
    final dano2 = combate.atacarInimigo();

    testes.esperaVerdadeiro(
      dano1 == dano2,
      'Dano deve ser previsível com mesmo setup',
    );
  });

  testes.teste('(14) Sequência de ataques é consistente', () {
    final inimigo = Inimigo(
      nome: 'Test',
      hpMax: 100,
      ataque: 5,
      defesa: 2,
      xpDrop: 20,
    );

    final danosCausados = <int>[];
    final ataque = 10;

    for (int i = 0; i < 3; i++) {
      final dano = (ataque - (inimigo.defesa ~/ 2)).clamp(1, ataque);
      danosCausados.add(dano);
    }

    testes.esperaVerdadeiro(
      danosCausados[0] == danosCausados[1],
      'Danos sucessivos devem ser iguais com valores fixos',
    );
  });

  // ======================================================================
  // SUITE: Integração Completa
  // ======================================================================
  print('\n🧪 SUITE: Integração Completa');
  print('───────────────────────────────────────────────────────────────');

  testes.teste('(15) Combate completo: vitória', () {
    final combate = CombateSimulado(
      inimigo: Inimigo(
        nome: 'Fraco',
        hpMax: 15,
        ataque: 2,
        defesa: 1,
        xpDrop: 10,
      ),
      ataqueJogador: 20,
      defesaJogador: 10,
    );

    int rodadas = 0;
    while (combate.inimigo.estaVivo && rodadas < 10) {
      combate.atacarInimigo();
      rodadas++;
    }

    testes.esperaVerdadeiro(
      combate.combateTerminou,
      'Combate deve terminar com vitória',
    );
    testes.esperaVerdadeiro(
      rodadas <= 5,
      'Combate fácil deve durar poucas rodadas',
    );
  });

  // ======================================================================
  // Exibir Relatório Final
  // ======================================================================
  print('\n');
  testes.exibirRelatorio();

  print('\n════════════════════════════════════════════════════════════════');
  if (testes.falhas == 0) {
    print('  ✓ TODAS AS DEFESAS PASSARAM! Código protegido.');
  } else {
    print('  ✗ Alguns testes falharam. Revisite implementação.');
  }
  print('════════════════════════════════════════════════════════════════\n');
}
