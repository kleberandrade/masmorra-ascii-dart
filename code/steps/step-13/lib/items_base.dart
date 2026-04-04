import 'item.dart';
import 'arma.dart';
import 'armadura.dart';

final espadaDeBronze = Arma(
  id: 'espada-bronze',
  nome: 'Espada de Bronze',
  descricao: 'Uma arma comum, de metal maleável',
  preco: 200,
  peso: 3,
  dano: 8,
  tipo: 'cortante',
);

final pocaoDeVida = Item(
  id: 'pocao-vida',
  nome: 'Poção de Vida',
  descricao: 'Recupera 20 HP',
  preco: 50,
  peso: 1,
);

final camisaDeCouro = Armadura(
  id: 'camisa-couro',
  nome: 'Camisa de Couro',
  descricao: 'Proteção básica, elegante e prática',
  preco: 100,
  peso: 2,
  defesa: 3,
  localizacao: 'peito',
);

final lojaPrincipal = [
  espadaDeBronze,
  pocaoDeVida,
  camisaDeCouro,
];
