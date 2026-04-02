import 'package:masmorra_ascii/config/constantes.dart';

/// Sistema de economia com preços e drops
class Economia {
  int precoCompra(String itemId) {
    return switch (itemId) {
      'espada_ferro' => Constantes.precoEspadaFerro,
      'espada_aco' => (Constantes.precoEspadaFerro * 1.5).toInt(),
      'armadura_couro' => Constantes.precoArmaduraCouro,
      'pocao_vida' => Constantes.precoPocaoVida,
      _ => 10,
    };
  }

  int precoVenda(String itemId) {
    final compra = precoCompra(itemId);
    return (compra * Constantes.margemVenda).toInt();
  }

  List<String> resolverDrop(String nomeInimigo) {
    return switch (nomeInimigo) {
      'Zumbi' => ['ouro:5', 'adaga_velha:0.15'],
      'Lobo' => ['ouro:10', 'espada_ferro:0.25'],
      'Orc' => ['ouro:20', 'armadura_couro:0.2'],
      _ => ['ouro:5'],
    };
  }
}
