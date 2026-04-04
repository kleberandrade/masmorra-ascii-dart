import 'campo_visao.dart';
import 'tela_ascii.dart';

abstract class Entidade {
  int x;
  int y;
  final String simbolo;
  final String nome;

  Entidade({
    required this.x,
    required this.y,
    required this.simbolo,
    required this.nome,
  });

  bool aoTocada(Entidade visitante) {
    return false;
  }

  void renderizarNaTela(TelaAscii tela, CampoVisao fov) {
    if (fov.estaVisivel(x, y)) {
      tela.desenharChar(x, y, simbolo);
    }
  }

  @override
  String toString() => '$nome ($simbolo) em ($x, $y)';
}
