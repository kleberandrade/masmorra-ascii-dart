/// Cap. 13 — itens e armas.
class Item {
  Item({required this.id, required this.nome, this.preco = 0});
  final String id;
  final String nome;
  int preco;
}

class Weapon extends Item {
  Weapon({
    required super.id,
    required super.nome,
    required this.dano,
    super.preco = 0,
  });
  final int dano;
}
