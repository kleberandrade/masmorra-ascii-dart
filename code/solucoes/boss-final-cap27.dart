// ============================================================================
// Capítulo 27 - Boss Final: Economia Equilibrada
// ============================================================================
// Exercício: Sistema de Escalação de Preços e Drops Dinâmicos
//
// Implementa preços que aumentam 5% por andar (afastamento do comerciante).
// Drops também aumentam 5% por andar para manter equilíbrio econômico.
// Demonstra progressão justa, matemática de escalação e balanceamento.
// ============================================================================

import 'dart:math';

// Constantes para balanceamento
class ConstantesCap27 {
  // Preço base para itens na loja
  static const int precoBase = 100;

  // Aumenta de preço conforme desce (afastamento do fornecedor)
  static const double aumentoPrecoPorantdar = 0.05; // 5% por andar

  // Ouro base ganho de inimigos
  static const int ouroBasePorInimigo = 10;

  // Aumenta drops para compensar preços maiores
  static const double aumentoOuroPorantdar = 0.05; // 5% por andar

  // Número de andares para teste
  static const int andaresTotais = 10;
}

// Sistema de economia escalada
class SistemaEconomiaEscalada {
  /// Calcula preço ajustado por profundidade
  /// Fórmula: precoBase * (1.0 + andar * 0.05)
  /// Andar 0: 100 | Andar 5: 125 | Andar 10: 150
  int calcularPrecoAjustado(int andar) {
    final multiplicador = 1.0 + (andar * ConstantesCap27.aumentoPrecoPorantdar);
    final precoFinal = ConstantesCap27.precoBase * multiplicador;
    return precoFinal.toInt();
  }

  /// Calcula ouro ganho de inimigos ajustado por andar
  /// Fórmula: ouroBase * (1.0 + andar * 0.05)
  int calcularOuroAjustado(int andar) {
    final multiplicador = 1.0 + (andar * ConstantesCap27.aumentoOuroPorantdar);
    final ouroFinal = ConstantesCap27.ouroBasePorInimigo * multiplicador;
    return ouroFinal.toInt();
  }

  /// Calcula quanto uma compra custaria em um andar específico
  int precoCompraNeste(int itemId, int andar) {
    return calcularPrecoAjustado(andar);
  }

  /// Simula uma jornada completa: descendo, ganhando ouro, comprando itens
  Map<String, dynamic> simularJornada() {
    final detalhes = <int, Map<String, dynamic>>{};
    int ouroTotalGanho = 0;
    int ouroTotalGasto = 0;
    int itemosComprados = 0;

    for (int andar = 0; andar < ConstantesCap27.andaresTotais; andar++) {
      final precoItem = calcularPrecoAjustado(andar);
      final ouroGanho = calcularOuroAjustado(andar) * 3; // 3 inimigos por andar
      final podeComprar = ouroTotalGanho + ouroGanho >= precoItem;

      int ouroGastoNoAndar = 0;
      int comprasNoAndar = 0;

      // Se tiver ouro suficiente, compra um item
      if (podeComprar && ouroTotalGanho + ouroGanho >= precoItem) {
        ouroGastoNoAndar = precoItem;
        ouroTotalGasto += precoItem;
        comprasNoAndar = 1;
        itemosComprados++;
      }

      ouroTotalGanho += ouroGanho;

      detalhes[andar] = {
        'precoItem': precoItem,
        'ouroGanho': ouroGanho,
        'ouroGastoNoAndar': ouroGastoNoAndar,
        'compras': comprasNoAndar,
        'ouroDisponivel': ouroTotalGanho - ouroTotalGasto,
      };
    }

    return {
      'detalhes': detalhes,
      'ouroTotalGanho': ouroTotalGanho,
      'ouroTotalGasto': ouroTotalGasto,
      'saldoFinal': ouroTotalGanho - ouroTotalGasto,
      'itemosComprados': itemosComprados,
    };
  }

  /// Exibe relatório formatado da jornada
  void exibirRelatorio(Map<String, dynamic> resultado) {
    print('\n╔════════════════════════════════════════════════════════════════╗');
    print('║       ECONOMIA EQUILIBRADA - Jornada Completa               ║');
    print('╠════════════════════════════════════════════════════════════════╣');
    print('║ Andar │ Preço │ Ouro Ganho │ Compra │ Saldo');
    print('├───────┼───────┼───────────┼────────┼────────────────────────┤');

    final detalhes = resultado['detalhes'] as Map<int, Map<String, dynamic>>;

    for (int andar = 0; andar < detalhes.length; andar++) {
      final info = detalhes[andar]!;
      final preco = info['precoItem'] as int;
      final ganho = info['ouroGanho'] as int;
      final compra = info['compras'] as int > 0 ? '✓' : '─';
      final saldo = info['ouroDisponivel'] as int;

      print('║  $andar   │  $preco  │   $ganho   │   $compra   │  $saldo');
    }

    print('╠════════════════════════════════════════════════════════════════╣');
    print('║ TOTAIS:');
    print('║   Ouro Ganho: ${resultado['ouroTotalGanho']}');
    print('║   Ouro Gasto: ${resultado['ouroTotalGasto']}');
    print('║   Saldo Final: ${resultado['saldoFinal']}');
    print('║   Itens Comprados: ${resultado['itemosComprados']}');
    print('╚════════════════════════════════════════════════════════════════╝\n');
  }

  /// Verifica se o equilíbrio é justo (viável economicamente)
  bool validarEquilibrio() {
    bool ehEquilibrado = true;

    for (int andar = 0; andar < ConstantesCap27.andaresTotais; andar++) {
      final preco = calcularPrecoAjustado(andar);
      final ouro = calcularOuroAjustado(andar) * 3; // 3 inimigos

      // Verificação: é possível comprar um item neste andar?
      if (ouro < preco) {
        print('⚠ Andar $andar: ganho ($ouro) < preço ($preco) - DESFAVORÁVEL');
        ehEquilibrado = false;
      }
    }

    return ehEquilibrado;
  }
}

// ============================================================================
// Demonstração completa do sistema
// ============================================================================

void main() {
  print('\n════════════════════════════════════════════════════════════════');
  print('  MASMORRA ASCII - Capítulo 27: Economia Equilibrada');
  print('════════════════════════════════════════════════════════════════\n');

  final economia = SistemaEconomiaEscalada();

  // ======================================================================
  // TESTE 1: Escalação de preços
  // ======================================================================
  print('🔍 TESTE 1: Escalação de Preços Por Andar');
  print('───────────────────────────────────────────────────────────────');

  for (int andar = 0; andar <= 10; andar += 2) {
    final preco = economia.calcularPrecoAjustado(andar);
    final aumento = (andar * ConstantesCap27.aumentoPrecoPorantdar * 100).toInt();
    print('Andar $andar: ${ConstantesCap27.precoBase} → $preco ouro (+$aumento%)');
  }

  // ======================================================================
  // TESTE 2: Escalação de drops (compensação)
  // ======================================================================
  print('\n🔍 TESTE 2: Escalação de Drops Por Andar');
  print('───────────────────────────────────────────────────────────────');

  for (int andar = 0; andar <= 10; andar += 2) {
    final ouro = economia.calcularOuroAjustado(andar);
    final aumento = (andar * ConstantesCap27.aumentoOuroPorantdar * 100).toInt();
    print('Andar $andar: ${ConstantesCap27.ouroBasePorInimigo} → $ouro ouro (+$aumento%)');
  }

  // ======================================================================
  // TESTE 3: Comparação preços vs ganho
  // ======================================================================
  print('\n🔍 TESTE 3: Preço vs Ganho (3 Inimigos por Andar)');
  print('───────────────────────────────────────────────────────────────');

  for (int andar = 0; andar <= 10; andar += 2) {
    final preco = economia.calcularPrecoAjustado(andar);
    final ganho = economia.calcularOuroAjustado(andar) * 3;
    final proporcao = (ganho / preco * 100).toStringAsFixed(0);

    final status = ganho >= preco ? '✓' : '✗';
    print('Andar $andar: Preço $preco | Ganho $ganho | Proporção: $proporcao% $status');
  }

  // ======================================================================
  // TESTE 4: Simulação completa de jornada
  // ======================================================================
  print('\n🔍 TESTE 4: Simulação Completa de Jornada');
  print('───────────────────────────────────────────────────────────────');

  final resultado = economia.simularJornada();
  economia.exibirRelatorio(resultado);

  // ======================================================================
  // TESTE 5: Validação de equilíbrio
  // ======================================================================
  print('🔍 TESTE 5: Validação de Equilíbrio');
  print('───────────────────────────────────────────────────────────────');

  final ehValido = economia.validarEquilibrio();

  if (ehValido) {
    print('✓ ECONOMIA BALANCEADA: viável descer todos os andares');
  } else {
    print('✗ ECONOMIA DESEQUILIBRADA: alguns andares são impossíveis');
  }

  // ======================================================================
  // TESTE 6: Análise de viabilidade econômica
  // ======================================================================
  print('\n🔍 TESTE 6: Análise de Viabilidade');
  print('───────────────────────────────────────────────────────────────');

  int andarMaisFacil = 0;
  int andarMaisDificil = 0;
  double facilidadeMaxima = 0;
  double facilidadeMinima = double.infinity;

  for (int andar = 0; andar < ConstantesCap27.andaresTotais; andar++) {
    final preco = economia.calcularPrecoAjustado(andar);
    final ouro = economia.calcularOuroAjustado(andar) * 3;
    final facilidade = ouro.toDouble() / preco;

    if (facilidade > facilidadeMaxima) {
      facilidadeMaxima = facilidade;
      andarMaisFacil = andar;
    }

    if (facilidade < facilidadeMinima) {
      facilidadeMinima = facilidade;
      andarMaisDificil = andar;
    }
  }

  print('Andar mais fácil: $andarMaisFacil (ganho ${(facilidadeMaxima * 100).toStringAsFixed(0)}% do preço)');
  print('Andar mais difícil: $andarMaisDificil (ganho ${(facilidadeMinima * 100).toStringAsFixed(0)}% do preço)');

  // ======================================================================
  // TESTE 7: Progressão suave
  // ======================================================================
  print('\n🔍 TESTE 7: Progressão Suave (sem saltos)');
  print('───────────────────────────────────────────────────────────────');

  bool progressaoSuave = true;
  int precoAnterior = economia.calcularPrecoAjustado(0);

  for (int andar = 1; andar < ConstantesCap27.andaresTotais; andar++) {
    final precoAtual = economia.calcularPrecoAjustado(andar);
    final diferenca = precoAtual - precoAnterior;

    if (diferenca > 10) {
      print('⚠ Salto no andar $andar: +$diferenca ouro');
      progressaoSuave = false;
    }

    precoAnterior = precoAtual;
  }

  if (progressaoSuave) {
    print('✓ Progressão é SUAVE: aumenta de forma consistente');
  }

  print('\n════════════════════════════════════════════════════════════════');
  print('  A economia cresce com você. Tudo é possível se descer.');
  print('════════════════════════════════════════════════════════════════\n');
}
