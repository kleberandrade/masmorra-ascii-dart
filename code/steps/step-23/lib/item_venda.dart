import 'item.dart';

/// Um item no inventário da loja (com preço e quantidade)
class ItemVenda {
  final Item item;
  final int precoCompra;
  int quantidade;

  ItemVenda({
    required this.item,
    required this.precoCompra,
    required this.quantidade,
  });

  int get precoVenda => (precoCompra * 0.5).toInt();
  bool get temEstoque => quantidade > 0;

  void removerDoEstoque() {
    if (quantidade > 0) quantidade--;
  }

  void adicionarAoEstoque() {
    quantidade++;
  }

  @override
  String toString() =>
      '${item.nome} ($precoCompra ouro) × $quantidade';
}
