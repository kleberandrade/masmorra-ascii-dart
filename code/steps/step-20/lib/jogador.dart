import 'campo_visao.dart';
import 'entidade.dart';
import 'mapa_masmorra.dart';
import 'tela_ascii.dart';

class Jogador extends Entidade {
  int hpMax;
  int hpAtual;
  int ouro;
  List<dynamic> inventario = [];

  Jogador({
    required String nome,
    required int x,
    required int y,
    required this.hpMax,
    required this.ouro,
  })  : hpAtual = hpMax,
        super(x: x, y: y, simbolo: '@', nome: nome);

  bool mover(int novoX, int novoY, MapaMasmorra mapa) {
    if (!mapa.ehPassavel(novoX, novoY)) return false;
    x = novoX;
    y = novoY;
    return true;
  }

  void moverEmDirecao(String direcao, MapaMasmorra mapa) {
    int novoX = x, novoY = y;
    switch (direcao.toLowerCase()) {
      case 'w':
        novoY--;
        break;
      case 's':
        novoY++;
        break;
      case 'a':
        novoX--;
        break;
      case 'd':
        novoX++;
        break;
      default:
        return;
    }
    mover(novoX, novoY, mapa);
  }

  @override
  void renderizarNaTela(TelaAscii tela, CampoVisao fov) {
    tela.desenharChar(x, y, simbolo);
  }
}
