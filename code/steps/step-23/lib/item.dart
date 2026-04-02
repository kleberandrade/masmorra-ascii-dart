/// Representa um item no inventário
class Item {
  final String id;
  final String nome;
  final String descricao;
  int? preco;

  Item({
    required this.id,
    required this.nome,
    required this.descricao,
    this.preco,
  });

  @override
  String toString() => '$nome ($id)';
}
