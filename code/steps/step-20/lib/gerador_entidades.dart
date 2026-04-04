import 'dart:math';
import 'entidade.dart';
import 'entidade_escada.dart';
import 'entidade_inimigo.dart';
import 'entidade_item.dart';
import 'inimigo.dart';
import 'item.dart';
import 'mapa_masmorra.dart';

class GeradorEntidades {
  final MapaMasmorra mapa;
  final int andarAtual;
  final Random random;
  final Set<Point<int>> posicoesOcupadas = {};

  GeradorEntidades({
    required this.mapa,
    required this.andarAtual,
    required this.random,
  });

  List<Entidade> spawn() {
    final entidades = <Entidade>[];
    posicoesOcupadas.clear();

    entidades.addAll(_spawnInimigos());
    entidades.addAll(_spawnItens());
    entidades.addAll(_spawnEscada());

    return entidades;
  }

  List<Entidade> _spawnInimigos() {
    final inimigos = <Entidade>[];
    final quantidade = 2 + (andarAtual ~/ 2) + random.nextInt(2);

    for (int i = 0; i < quantidade; i++) {
      final pos = _encontrarPosicaoValida();
      if (pos != null) {
        final tipo = _escolherTipoInimigo();
        inimigos.add(EntidadeInimigo(
          x: pos.x,
          y: pos.y,
          inimigo: _criarInimigo(tipo),
        ));
        posicoesOcupadas.add(pos);
      }
    }

    return inimigos;
  }

  List<Entidade> _spawnItens() {
    final itens = <Entidade>[];
    final quantidade = 2 + random.nextInt(3);

    for (int i = 0; i < quantidade; i++) {
      final pos = _encontrarPosicaoValida();
      if (pos != null) {
        itens.add(EntidadeItem(
          x: pos.x,
          y: pos.y,
          item: Item(
            nome: ['Ouro', 'Poção', 'Gema'][random.nextInt(3)],
            x: pos.x,
            y: pos.y,
          ),
        ));
        posicoesOcupadas.add(pos);
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
    for (int tentativa = 0; tentativa < 50; tentativa++) {
      final x = random.nextInt(mapa.largura);
      final y = random.nextInt(mapa.altura);
      final pos = Point(x, y);

      if (mapa.ehPassavel(x, y) && !posicoesOcupadas.contains(pos)) {
        return pos;
      }
    }
    return null;
  }

  String _escolherTipoInimigo() {
    final tipos = ['Zumbi', 'Lobo', 'Orc'];
    return tipos[random.nextInt(tipos.length)];
  }

  Inimigo _criarInimigo(String tipo) {
    return switch (tipo) {
      'Zumbi' => Inimigo(nome: 'Zumbi', x: 0, y: 0, hpMax: 20, simbolo: 'Z'),
      'Lobo' => Inimigo(nome: 'Lobo', x: 0, y: 0, hpMax: 40, simbolo: 'L'),
      'Orc' => Inimigo(nome: 'Orc', x: 0, y: 0, hpMax: 60, simbolo: 'O'),
      _ => Inimigo(nome: 'Monstro', x: 0, y: 0, hpMax: 25, simbolo: '?'),
    };
  }
}
