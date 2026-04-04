import 'item.dart';

class Armadura extends Item {
  final int defesa;
  final String localizacao;

  Armadura({
    required String id,
    required String nome,
    required String descricao,
    required int preco,
    required int peso,
    required this.defesa,
    required this.localizacao,
  }) : super(
    id: id,
    nome: nome,
    descricao: descricao,
    preco: preco,
    peso: peso,
  );

  @override
  String toString() => '$nome (+$defesa DEF em $localizacao)';
}
