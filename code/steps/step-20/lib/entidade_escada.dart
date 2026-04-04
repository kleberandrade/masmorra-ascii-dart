import 'entidade.dart';

class EntidadeEscada extends Entidade {
  final int andarAtual;

  EntidadeEscada({
    required int x,
    required int y,
    required this.andarAtual,
  }) : super(
          x: x,
          y: y,
          simbolo: '>',
          nome: 'Escada Descendente',
        );

  @override
  bool aoTocada(Entidade visitante) {
    return false;
  }
}
