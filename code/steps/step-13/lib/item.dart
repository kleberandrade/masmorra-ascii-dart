class Item {
  final String id;
  final String nome;
  final String descricao;
  final int preco;
  final int peso;

  Item({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.peso,
  });

  @override
  String toString() => '$nome (id: $id, preço: $preco ouro, peso: $peso)';
}
