import 'dart:math';
import 'tile.dart';
import 'tela_ascii.dart';
import 'campo_visao.dart';

abstract class Entidade {
  int x;
  int y;
  String simbolo;
  String nome;

  Entidade({
    required this.x,
    required this.y,
    required this.simbolo,
    required this.nome,
  });

  void renderizarNaTela(TelaAscii tela, CampoVisao fov) {
    if (fov.estaVisivel(x, y)) {
      tela.desenharChar(x, y, simbolo);
    }
  }
}

class Jogador extends Entidade {
  int hpMax;
  int hpAtual;
  int ouro;

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
      case 's':
        novoY++;
      case 'a':
        novoX--;
      case 'd':
        novoX++;
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

class Inimigo extends Entidade {
  int hpMax;
  int hpAtual;

  Inimigo({
    required String nome,
    required int x,
    required int y,
    required this.hpMax,
    required String simbolo,
  })  : hpAtual = hpMax,
        super(x: x, y: y, simbolo: simbolo, nome: nome);
}

class Item extends Entidade {
  Item({
    required String nome,
    required int x,
    required int y,
  }) : super(x: x, y: y, simbolo: '!', nome: nome);
}

class SessaoJogo {
  final MapaMasmorra mapa;
  final Jogador jogador;
  final List<Inimigo> inimigos;
  final List<Item> itens;
  final TelaAscii tela;

  int turnoAtual = 0;

  SessaoJogo({
    required this.mapa,
    required this.jogador,
    required this.inimigos,
    required this.itens,
    required this.tela,
  });

  void renderizarFrame() {
    tela.limpar();

    // Renderizar mapa com FOV
    for (int y = 0; y < mapa.altura; y++) {
      for (int x = 0; x < mapa.largura; x++) {
        final char = tileParaChar(mapa.tileEm(x, y));

        if (mapa.fov.estaVisivel(x, y)) {
          tela.desenharChar(x, y, char);
        } else if (mapa.fov.foiExplorado(x, y)) {
          tela.desenharChar(x, y, _esfumacar(char));
        }
      }
    }

    // Renderizar itens
    for (final item in itens) {
      item.renderizarNaTela(tela, mapa.fov);
    }

    // Renderizar inimigos
    for (final inimigo in inimigos) {
      inimigo.renderizarNaTela(tela, mapa.fov);
    }

    // Renderizar jogador
    jogador.renderizarNaTela(tela, mapa.fov);

    // HUD
    final hudY = mapa.altura + 1;
    tela.desenharString(0, hudY, '═' * tela.largura);
    tela.desenharString(
      0,
      hudY + 1,
      'Turno: $turnoAtual | HP: ${jogador.hpAtual}/${jogador.hpMax} | Explorado: ${mapa.fov.tileExplorados.length}',
    );
    tela.desenharString(0, hudY + 2, '[W]cima [A]esq [S]baixo [D]dir [Q]uit');

    tela.renderizar();
  }

  String _esfumacar(String char) {
    return switch (char) {
      '#' => '░',
      '.' => '·',
      '>' => '┐',
      _ => char.toLowerCase(),
    };
  }
}
