/// Gerenciador simples de preços
class Economia {
  int precoCompra(String itemId) {
    return switch (itemId) {
      'pocao_vida' => 25,
      'pocao_mana' => 15,
      'espada_aco' => 75,
      'armadura_couro' => 50,
      'espada_mithril' => 200,
      _ => 10,
    };
  }

  int precoVenda(String itemId) {
    final compra = precoCompra(itemId);
    return (compra * 0.5).toInt();
  }
}
