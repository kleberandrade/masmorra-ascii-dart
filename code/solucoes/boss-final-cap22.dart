// ============================================================================
// Capítulo 22 - Boss Final: A Profundeza Recompensa
// ============================================================================
// Exercício: Sistema de Bônus de Ouro por Profundidade
//
// Implementa um sistema onde o ouro ganho aumenta 10% a cada 2 andares.
// O jogador sente-se recompensado conforme desce mais fundo na masmorra.
// Demonstra constantes, cálculos escalonados e progressão econômica.
// ============================================================================

import 'dart:math';

// Constantes de balanceamento da economia
class ConstantesEconomia {
  // Ouro base que um inimigo solta
  static const int ouroBasePorInimigo = 5;

  // Bônus de ouro por profundidade: +10% a cada 2 andares
  static const double bonusOuoPor2Andares = 0.10;

  // Número de andares para avaliar
  static const int andaresTotais = 10;

  // Número de inimigos por andar para teste
  static const int inimigosPorAndar = 3;
}

// Classe que calcula recompensas escalonadas por andar
class SistemaEconomiaProgundeza {
  /// Calcula o bônus de ouro baseado na profundidade (andar)
  /// Fórmula: andar ~/ 2 * 0.10
  /// Andar 0-1: +0% | Andar 2-3: +10% | Andar 4-5: +20% | ...
  double obterBonusAndarpor2(int andar) {
    final grupos = andar ~/ 2; // Quantos grupos de 2 andares desceu
    return grupos * ConstantesEconomia.bonusOuoPor2Andares;
  }

  /// Calcula o ouro escalonado para um inimigo em um andar específico
  int calcularOuroEscalonado(int andar) {
    final bonus = obterBonusAndarpor2(andar);
    final multiplicador = 1.0 + bonus;
    final ouroFinal = ConstantesEconomia.ouroBasePorInimigo * multiplicador;
    return ouroFinal.toInt();
  }

  /// Simula a descida por N andares, coletando ouro de inimigos
  Map<String, dynamic> simularDescida(int numAndares) {
    int ouroTotal = 0;
    int inimigosDerrotados = 0;
    final detalhesAndares = <int, int>{};

    for (int andar = 0; andar < numAndares; andar++) {
      int ouroNoAndar = 0;

      // Combate contra 3 inimigos por andar
      for (int i = 0; i < ConstantesEconomia.inimigosPorAndar; i++) {
        final ouroDoInimigo = calcularOuroEscalonado(andar);
        ouroNoAndar += ouroDoInimigo;
        inimigosDerrotados++;
      }

      ouroTotal += ouroNoAndar;
      detalhesAndares[andar] = ouroNoAndar;
    }

    return {
      'ouroTotal': ouroTotal,
      'inimigosDerrotados': inimigosDerrotados,
      'detalhesAndares': detalhesAndares,
    };
  }

  /// Exibe relatório formatado da simulação
  void exibirRelatorio(Map<String, dynamic> resultado) {
    print('\n╔═══════════════════════════════════════════════════════════╗');
    print('║         SIMULAÇÃO: A PROFUNDEZA RECOMPENSA              ║');
    print('╠═══════════════════════════════════════════════════════════╣');

    final detalhes = resultado['detalhesAndares'] as Map<int, int>;
    print('║ Andar │ Ouro Ganho │ Bônus (%)  │ Acumulado              ║');
    print('├───────┼────────────┼────────────┼────────────────────────┤');

    int acumulado = 0;
    for (int andar = 0; andar < detalhes.length; andar++) {
      final ouro = detalhes[andar]!;
      acumulado += ouro;

      final bonus = obterBonusAndarpor2(andar);
      final bonusPercent = (bonus * 100).toInt();

      final linhaAndares = '│   $andar   │   $ouro    │   $bonusPercent%    │   $acumulado';
      print('$linhaAndares');
    }

    print('╠═══════════════════════════════════════════════════════════╣');
    print('║ TOTAL: ${resultado['ouroTotal']} ouro em ${resultado['inimigosDerrotados']} inimigos derrotados');
    print('╚═══════════════════════════════════════════════════════════╝\n');
  }
}

void main() {
  print('\n════════════════════════════════════════════════════════════');
  print('  MASMORRA ASCII - Capítulo 22: A Profundeza Recompensa');
  print('════════════════════════════════════════════════════════════\n');

  final economia = SistemaEconomiaProgundeza();

  // Teste 1: Verificar bônus por andar individual
  print('🔍 TESTE 1: Bônus por Andar Individual');
  print('─────────────────────────────────────────────────────────────');
  for (int andar = 0; andar <= 10; andar += 2) {
    final bonus = economia.obterBonusAndarpor2(andar);
    final bonusPercent = (bonus * 100).toInt();
    final ouro = economia.calcularOuroEscalonado(andar);
    print('Andar $andar: +$bonusPercent% de bônus → $ouro ouro por inimigo');
  }

  // Teste 2: Simular descida completa por 10 andares
  print('\n🔍 TESTE 2: Simulação Completa de Descida');
  print('─────────────────────────────────────────────────────────────');
  final resultado = economia.simularDescida(ConstantesEconomia.andaresTotais);
  economia.exibirRelatorio(resultado);

  // Teste 3: Comparar progressão
  print('🔍 TESTE 3: Progressão de Recompensas');
  print('─────────────────────────────────────────────────────────────');
  final resultado5 = economia.simularDescida(5);
  final resultado10 = economia.simularDescida(10);

  print('Descendo 5 andares: ${resultado5['ouroTotal']} ouro total');
  print('Descendo 10 andares: ${resultado10['ouroTotal']} ouro total');

  final diferenca = resultado10['ouroTotal'] as int - resultado5['ouroTotal'] as int;
  final percentualMais = ((diferenca / (resultado5['ouroTotal'] as int)) * 100).toStringAsFixed(1);
  print('Diferença: $diferenca ouro ($percentualMais% a mais) por descer 5 andares extras\n');

  // Teste 4: Validar que a progressão é suave (não há saltos)
  print('🔍 TESTE 4: Suavidade da Progressão');
  print('─────────────────────────────────────────────────────────────');
  int ouroAnterior = economia.calcularOuroEscalonado(0) * ConstantesEconomia.inimigosPorAndar;
  bool progressaoSuave = true;

  for (int andar = 1; andar < ConstantesEconomia.andaresTotais; andar++) {
    final ouroAtual = economia.calcularOuroEscalonado(andar) * ConstantesEconomia.inimigosPorAndar;
    final diferenca = ouroAtual - ouroAnterior;

    if (diferenca.abs() > ConstantesEconomia.ouroBasePorInimigo) {
      progressaoSuave = false;
    }
    ouroAnterior = ouroAtual;
  }

  if (progressaoSuave) {
    print('✓ Progressão é SUAVE: sem saltos abruptos');
  } else {
    print('✗ Progressão tem SALTOS: ajuste os multiplicadores');
  }

  print('\n════════════════════════════════════════════════════════════');
  print('  Sinta-se recompensado pela sua coragem em descer!');
  print('════════════════════════════════════════════════════════════\n');
}
