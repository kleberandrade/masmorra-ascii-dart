import 'item.dart';

class Arma extends Item {
  final int dano;
  final String tipo;

  Arma({
    required String id,
    required String nome,
    required String descricao,
    required int preco,
    required int peso,
    required this.dano,
    required this.tipo,
  }) : super(
    id: id,
    nome: nome,
    descricao: descricao,
    preco: preco,
    peso: peso,
  );

  @override
  String toString() => '$nome ($tipo, +$dano dano)';
}
