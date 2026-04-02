import 'jogador.dart';
import 'item.dart';
import 'item_venda.dart';
import 'economia.dart';

/// O comerciante da loja
class Mercador {
  List<ItemVenda> inventario;
  final Economia economia;
  final String nome;

  Mercador({
    required this.inventario,
    required this.economia,
    this.nome = 'Mestre Aldwin',
  });

  /// Compra um item do inventário da loja
  String comprar(Jogador jogador, int indiceItem) {
    if (indiceItem < 0 || indiceItem >= inventario.length) {
      return 'Item inválido!';
    }

    final itemVenda = inventario[indiceItem];

    if (!itemVenda.temEstoque) {
      return '${itemVenda.item.nome} está em falta.';
    }

    if (jogador.ouro < itemVenda.precoCompra) {
      return 'Você não tem ouro suficiente (custo: ${itemVenda.precoCompra})';
    }

    if (jogador.inventario.length >= jogador.tamanhoInventario) {
      return 'Inventário cheio!';
    }

    jogador.ouro -= itemVenda.precoCompra;
    jogador.adicionarItem(itemVenda.item);
    itemVenda.removerDoEstoque();

    return '${itemVenda.item.nome} comprado por ${itemVenda.precoCompra} ouro!';
  }

  /// Vende um item do inventário do jogador para a loja
  String vender(Jogador jogador, int indiceItem) {
    if (indiceItem < 0 || indiceItem >= jogador.inventario.length) {
      return 'Item inválido!';
    }

    final item = jogador.inventario[indiceItem];
    final precoVenda = economia.precoVenda(item.id);

    if (precoVenda <= 0) {
      return 'Este item não tem valor!';
    }

    jogador.ouro += precoVenda;
    jogador.inventario.removeAt(indiceItem);
    _adicionarAoEstoqueDaLoja(item, precoVenda);

    return '${item.nome} vendido por $precoVenda ouro!';
  }

  void _adicionarAoEstoqueDaLoja(Item item, int preco) {
    final existe = inventario.firstWhereOrNull(
      (iv) => iv.item.id == item.id,
    );

    if (existe != null) {
      existe.adicionarAoEstoque();
    } else {
      inventario.add(ItemVenda(
        item: item,
        precoCompra: preco,
        quantidade: 1,
      ));
    }
  }

  /// Restoque da loja com novos items
  void restoquear(int andarNumero) {
    inventario.clear();
    inventario.addAll(_inventarioBase());

    if (andarNumero >= 3) {
      inventario.addAll(_inventarioAndarAvancado());
    }
    if (andarNumero >= 7) {
      inventario.addAll(_inventarioAndarMuitoAvancado());
    }
  }

  List<ItemVenda> _inventarioBase() {
    return [
      ItemVenda(
        item: Item(
          id: 'pocao_vida',
          nome: 'Poção de vida',
          descricao: 'Restaura 20 HP quando usada.',
        ),
        precoCompra: 25,
        quantidade: 5,
      ),
      ItemVenda(
        item: Item(
          id: 'pocao_mana',
          nome: 'Poção de mana',
          descricao: 'Restaura 10 mana quando usada.',
        ),
        precoCompra: 15,
        quantidade: 3,
      ),
    ];
  }

  List<ItemVenda> _inventarioAndarAvancado() {
    return [
      ItemVenda(
        item: Item(
          id: 'espada_aco',
          nome: 'Espada de aço',
          descricao: 'Uma lâmina bem forjada. +3 ataque.',
        ),
        precoCompra: 75,
        quantidade: 2,
      ),
      ItemVenda(
        item: Item(
          id: 'armadura_couro',
          nome: 'Armadura de couro',
          descricao: 'Proteção básica. +2 defesa.',
        ),
        precoCompra: 50,
        quantidade: 1,
      ),
    ];
  }

  List<ItemVenda> _inventarioAndarMuitoAvancado() {
    return [
      ItemVenda(
        item: Item(
          id: 'espada_mithril',
          nome: 'Espada de mithril',
          descricao: 'Lendária e afiada. +6 ataque.',
        ),
        precoCompra: 200,
        quantidade: 1,
      ),
    ];
  }
}

extension _FirstWhereOrNull<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
