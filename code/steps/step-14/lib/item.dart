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
  String toString() => nome;
}

class Arma extends Item {
  final int dano;
  final String tipo;

  Arma({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.preco,
    required super.peso,
    required this.dano,
    required this.tipo,
  });

  @override
  String toString() => '$nome (+$dano dano)';
}

class Armadura extends Item {
  final int defesa;
  final String localizacao;

  Armadura({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.preco,
    required super.peso,
    required this.defesa,
    required this.localizacao,
  });

  @override
  String toString() => '$nome (+$defesa DEF)';
}

final espadaDeBronze = Arma(
  id: 'espada-bronze',
  nome: 'Espada de Bronze',
  descricao: 'Uma arma comum',
  preco: 200,
  peso: 3,
  dano: 8,
  tipo: 'cortante',
);

final pocaoDeVida = Item(
  id: 'pocao-vida',
  nome: 'Poção de Vida',
  descricao: 'Cura 20 HP',
  preco: 50,
  peso: 1,
);

final camisaDeCouro = Armadura(
  id: 'camisa-couro',
  nome: 'Camisa de Couro',
  descricao: 'Proteção básica',
  preco: 100,
  peso: 2,
  defesa: 3,
  localizacao: 'peito',
);
