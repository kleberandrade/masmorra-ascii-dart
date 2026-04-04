import 'entidade.dart';
import 'inimigo.dart';

class EntidadeInimigo extends Entidade {
  final Inimigo inimigo;

  EntidadeInimigo({
    required int x,
    required int y,
    required this.inimigo,
  }) : super(
          x: x,
          y: y,
          simbolo: inimigo.simbolo,
          nome: inimigo.nome,
        );

  @override
  bool aoTocada(Entidade visitante) {
    return false;
  }
}
