import 'dart:math' show Point;

import 'tela_ascii.dart';
import 'campo_visao.dart';

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

class Jogador extends Entidade {
  int hpMax;
  int hpAtual;
  int ouro;
  List<Item> inventario = [];

  Jogador({
    required super.nome,
    required super.x,
    required super.y,
    required this.hpMax,
    required this.ouro,
  })  : hpAtual = hpMax,
        super(simbolo: '@');

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
    required super.nome,
    required super.x,
    required super.y,
    required this.hpMax,
    required super.simbolo,
  })  : hpAtual = hpMax;
}

class Item extends Entidade {
  Item({
    required super.nome,
    required super.x,
    required super.y,
  }) : super(simbolo: '!');

  @override
  bool aoTocada(Entidade visitante) {
    if (visitante is! Jogador) return false;
    visitante.inventario.add(this);
    visitante.ouro += 10;
    return true;
  }
}

class EntidadeInimigo extends Entidade {
  final Inimigo inimigo;

  EntidadeInimigo({
    required super.x,
    required super.y,
    required this.inimigo,
  }) : super(
    simbolo: inimigo.simbolo,
    nome: inimigo.nome,
  );

  @override
  bool aoTocada(Entidade visitante) {
    return false;
  }
}

class EntidadeItem extends Entidade {
  final Item item;

  EntidadeItem({
    required super.x,
    required super.y,
    required this.item,
  }) : super(
    simbolo: '!',
    nome: item.nome,
  );

  @override
  bool aoTocada(Entidade visitante) {
    if (visitante is! Jogador) return false;
    visitante.inventario.add(item);
    visitante.ouro += 10;
    return true;
  }
}

class EntidadeEscada extends Entidade {
  final int andarAtual;

  EntidadeEscada({
    required super.x,
    required super.y,
    required this.andarAtual,
  }) : super(
    simbolo: '>',
    nome: 'Escada Descendente',
  );

  @override
  bool aoTocada(Entidade visitante) {
    return false;
  }
}

class AndarMasmorra {
  final int numero;
  final MapaMasmorra mapa;
  final List<Entidade> entidades;

  AndarMasmorra({
    required this.numero,
    required this.mapa,
    required this.entidades,
  });

  Entidade? encontrarEntidadeEm(int x, int y) {
    try {
      return entidades.firstWhere((e) => e.x == x && e.y == y);
    } catch (e) {
      return null;
    }
  }

  void removerEntidade(Entidade entidade) {
    entidades.remove(entidade);
  }
}

class GeradorEntidades {
  final MapaMasmorra mapa;
  final int andarAtual;
  final Set<Point<int>> posicoesPrecupadas = {};

  GeradorEntidades({
    required this.mapa,
    required this.andarAtual,
  });

  List<Entidade> spawn() {
    final entidades = <Entidade>[];
    posicoesPrecupadas.clear();

    entidades.addAll(_spawnInimigos());
    entidades.addAll(_spawnItens());
    entidades.addAll(_spawnEscada());

    return entidades;
  }

  List<Entidade> _spawnInimigos() {
    final inimigos = <Entidade>[];
    final quantidade = 2 + (andarAtual ~/ 2);

    for (int i = 0; i < quantidade; i++) {
      final pos = _encontrarPosicaoValida();
      if (pos != null) {
        final tipo = _escolherTipoInimigo();
        inimigos.add(EntidadeInimigo(
          x: pos.x,
          y: pos.y,
          inimigo: _criarInimigo(tipo),
        ));
        posicoesPrecupadas.add(pos);
      }
    }

    return inimigos;
  }

  List<Entidade> _spawnItens() {
    final itens = <Entidade>[];
    final quantidade = 2 + andarAtual;

    for (int i = 0; i < quantidade; i++) {
      final pos = _encontrarPosicaoValida();
      if (pos != null) {
        itens.add(EntidadeItem(
          x: pos.x,
          y: pos.y,
          item: Item(
            nome: ['Ouro', 'Poção', 'Gema'][i % 3],
            x: pos.x,
            y: pos.y,
          ),
        ));
        posicoesPrecupadas.add(pos);
      }
    }

    return itens;
  }

  List<Entidade> _spawnEscada() {
    final pos = _encontrarPosicaoValida();
    if (pos != null) {
      return [EntidadeEscada(x: pos.x, y: pos.y, andarAtual: andarAtual)];
    }
    return [];
  }

  Point<int>? _encontrarPosicaoValida() {
    for (int tentativa = 0; tentativa < 100; tentativa++) {
      final x = 5 + (tentativa * 7) % (mapa.largura - 10);
      final y = 3 + (tentativa * 11) % (mapa.altura - 6);
      final pos = Point(x, y);

      if (mapa.ehPassavel(x, y) && !posicoesPrecupadas.contains(pos)) {
        return pos;
      }
    }
    return null;
  }

  String _escolherTipoInimigo() {
    final tipos = ['Zumbi', 'Lobo', 'Orc'];
    return tipos[andarAtual % tipos.length];
  }

  Inimigo _criarInimigo(String tipo) {
    return switch (tipo) {
      'Zumbi' => Inimigo(nome: 'Zumbi', x: 0, y: 0, hpMax: 15 + andarAtual * 3, simbolo: 'Z'),
      'Lobo' => Inimigo(nome: 'Lobo', x: 0, y: 0, hpMax: 25 + andarAtual * 4, simbolo: 'L'),
      'Orc' => Inimigo(nome: 'Orc', x: 0, y: 0, hpMax: 35 + andarAtual * 5, simbolo: 'O'),
      _ => Inimigo(nome: 'Monstro', x: 0, y: 0, hpMax: 20 + andarAtual * 3, simbolo: '?'),
    };
  }
}
