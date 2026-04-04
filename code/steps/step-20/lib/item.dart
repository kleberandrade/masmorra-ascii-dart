import 'entidade.dart';
import 'jogador.dart';

class Item extends Entidade {
  Item({
    required String nome,
    required int x,
    required int y,
  }) : super(
          x: x,
          y: y,
          simbolo: '!',
          nome: nome,
        );

  @override
  bool aoTocada(Entidade visitante) {
    if (visitante is! Jogador) return false;
    visitante.inventario.add(this);
    return true;
  }
}
