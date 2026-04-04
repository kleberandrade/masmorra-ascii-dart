import 'dart:math';
import 'economia.dart';

/// Simula corridas de teste para validar balanceamento
class SimuladorEconomia {
  final Economia economia;

  SimuladorEconomia(this.economia);

  /// Simula N corridas e retorna estatísticas médias
  Map<String, dynamic> simularCorridas(int numCorridas) {
    final stats = <int>[];

    for (int i = 0; i < numCorridas; i++) {
      int ouroTotal = 0;

      for (final nomeInimigo in ['Zumbi', 'Lobo', 'Orc']) {
        final drops = economia.resolverDrop(nomeInimigo);
        for (final drop in drops) {
          final partes = drop.split(':');
          if (partes[0] == 'ouro') {
            ouroTotal += int.parse(partes[1]);
          }
        }
      }

      stats.add(ouroTotal);
    }

    final media = stats.reduce((a, b) => a + b) / stats.length;
    final minimo = stats.reduce((a, b) => min(a, b));
    final maximo = stats.reduce((a, b) => max(a, b));

    return {
      'corridas': numCorridas,
      'ouro_medio': media.toStringAsFixed(2),
      'ouro_minimo': minimo,
      'ouro_maximo': maximo,
    };
  }
}
