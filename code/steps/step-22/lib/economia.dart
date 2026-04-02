import 'entrada_saque.dart';
import 'economia_constants.dart';
import 'roller.dart';

/// Sistema de economia: drops, preços, balanceamento
class Economia {
  final Map<String, List<EntradaSaque>> tabelasDrops;
  final Roller roller;

  Economia({
    required this.tabelasDrops,
    Roller? roller,
  }) : roller = roller ?? Roller();

  /// Resolve os drops de um inimigo derrotado
  List<String> resolverDrop(String nomeInimigo) {
    final drops = tabelasDrops[nomeInimigo];
    if (drops == null) {
      return ['ouro:${EconomiaConstants.kOuroBasePorInimigo}'];
    }

    final resultado = <String>[];

    for (final entry in drops) {
      if (roller.teste(entry.chance)) {
        final qtd = entry.resolverQuantidade(roller.random);
        resultado.add('${entry.itemId}:$qtd');
      }
    }

    if (resultado.isEmpty) {
      resultado.add('ouro:${EconomiaConstants.kOuroBasePorInimigo}');
    }

    return resultado;
  }

  /// Calcula o preço de compra (preço que você paga à loja)
  int precoCompra(String itemId) {
    return switch (itemId) {
      'espada_ferro' => EconomiaConstants.kPrecoEspadaFerro,
      'espada_aco' => (EconomiaConstants.kPrecoEspadaFerro * 1.5).toInt(),
      'espada_mithril' => (EconomiaConstants.kPrecoEspadaFerro * 3.0).toInt(),
      'armadura_couro' => EconomiaConstants.kPrecoArmaduraCouro,
      'armadura_ferro' =>
        (EconomiaConstants.kPrecoArmaduraCouro * 1.5).toInt(),
      'pocao_vida' => EconomiaConstants.kPrecoPocaoVida,
      'pocao_restauracao' =>
        (EconomiaConstants.kPrecoPocaoVida * 2).toInt(),
      _ => 10,
    };
  }

  /// Calcula o preço de venda (preço que o comerciante oferece)
  int precoVenda(String itemId) {
    final compra = precoCompra(itemId);
    return (compra * EconomiaConstants.kMargemVenda).toInt();
  }

  /// Retorna dificuldade escalonada para um andar
  double getDificuldadeAndar(int numero) {
    return 1.0 + (numero * EconomiaConstants.kAumentoHpPorAndar);
  }

  /// Retorna recompensa escalonada para um andar
  int getOuroEscalonado(int numero) {
    final base = EconomiaConstants.kOuroBasePorInimigo.toDouble();
    final multiplicador = 1.0 + (numero * EconomiaConstants.kAumentoOuroPorAndar);
    return (base * multiplicador).toInt();
  }
}
