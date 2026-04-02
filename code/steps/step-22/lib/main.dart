import 'economia.dart';
import 'tabelas_drops.dart';
import 'simulador_economia.dart';

void main() {
  print('╔════════════════════════════════════════╗');
  print('║   CAPÍTULO 22 - ECONOMIA E DROPS       ║');
  print('╚════════════════════════════════════════╝\n');

  // Criar economia
  final economia = Economia(tabelasDrops: TabelasDrops.criar());

  print('=== TESTANDO DROPS ===\n');

  // Testar drops para cada tipo de inimigo
  for (final tipoInimigo in ['Zumbi', 'Lobo', 'Orc']) {
    print('Drops do $tipoInimigo:');
    final drops = economia.resolverDrop(tipoInimigo);
    for (final drop in drops) {
      print('  > $drop');
    }
    print('');
  }

  print('=== TESTANDO PREÇOS ===\n');

  final itens = [
    'espada_ferro',
    'espada_aco',
    'espada_mithril',
    'armadura_couro',
    'pocao_vida',
  ];

  for (final itemId in itens) {
    final compra = economia.precoCompra(itemId);
    final venda = economia.precoVenda(itemId);
    print('$itemId: compra=$compra ouro, venda=$venda ouro');
  }

  print('\n=== TESTANDO ESCALAÇÃO POR ANDAR ===\n');

  for (int andar = 0; andar <= 5; andar++) {
    final dificuldade = economia.getDificuldadeAndar(andar);
    final ouro = economia.getOuroEscalonado(andar);
    print('Andar $andar: dificuldade=${dificuldade.toStringAsFixed(2)}x, ouro=$ouro');
  }

  print('\n=== SIMULAÇÃO DE 100 CORRIDAS ===\n');

  final simulador = SimuladorEconomia(economia);
  final resultado = simulador.simularCorridas(100);

  print('Resultado: $resultado');
  print('\nMédio de ouro por corrida: ${resultado['ouro_medio']}');
  print('Mínimo: ${resultado['ouro_minimo']}');
  print('Máximo: ${resultado['ouro_maximo']}');
}
