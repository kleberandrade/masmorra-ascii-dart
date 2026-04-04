import 'entidade.dart';
import 'item.dart';
import 'jogador.dart';

class EntidadeItem extends Entidade {
  final Item item;

  EntidadeItem({
    required int x,
    required int y,
    required this.item,
  }) : super(
          x: x,
          y: y,
          simbolo: '!',
          nome: item.nome,
        );

  @override
  bool aoTocada(Entidade visitante) {
    if (visitante is! Jogador) return false;
    visitante.inventario.add(item);
    return true;
  }
}
