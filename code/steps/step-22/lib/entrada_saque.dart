import 'dart:math';

/// Uma entrada na tabela de drops de um inimigo
/// Define qual item pode cair, com que probabilidade, e em que quantidade
class EntradaSaque {
  final String itemId;
  final double chance;
  final int quantidadeMin;
  final int quantidadeMax;
  final String nomeItem;

  EntradaSaque({
    required this.itemId,
    required this.chance,
    required this.quantidadeMin,
    required this.quantidadeMax,
    required this.nomeItem,
  })  : assert(chance >= 0.0 && chance <= 1.0),
        assert(quantidadeMin >= 0 && quantidadeMax >= quantidadeMin);

  /// Calcula a quantidade a cair (entre min e max)
  int resolverQuantidade(Random random) {
    if (quantidadeMin == quantidadeMax) {
      return quantidadeMin;
    }
    return quantidadeMin + random.nextInt(quantidadeMax - quantidadeMin + 1);
  }

  @override
  String toString() =>
      '$nomeItem (${(chance * 100).toStringAsFixed(1)}%): '
      '$quantidadeMin—$quantidadeMax';
}
