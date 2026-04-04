import 'dart:math';
import 'mapa_masmorra.dart';
import 'tile.dart';

class ValidadorMapa {
  /// Valida se o mapa é totalmente explorável
  MapaValidacaoResultado validarMapaCompleto(
    MapaMasmorra mapa,
  ) {
    // 1. Encontra região de chão contígua maior
    final regioes = _encontrarRegioesChao(mapa);
    if (regioes.isEmpty) {
      return MapaValidacaoResultado(
        valido: false,
        mensagem: 'Nenhuma região de chão encontrada',
      );
    }

    // 2. Verifica se existe uma escada
    Point<int>? escada;
    for (int y = 0; y < mapa.altura; y++) {
      for (int x = 0; x < mapa.largura; x++) {
        if (mapa.tileEm(x, y) == Tile.escadaDesce) {
          escada = Point(x, y);
          break;
        }
      }
    }

    if (escada == null) {
      return MapaValidacaoResultado(
        valido: false,
        mensagem: 'Nenhuma escada encontrada',
      );
    }

    // 3. Verifica se escada está na maior região
    final maiorRegiao = regioes.reduce((a, b) => a.length > b.length ? a : b);
    if (!maiorRegiao.contains(escada)) {
      return MapaValidacaoResultado(
        valido: false,
        mensagem: 'Escada está isolada em região separada',
      );
    }

    // 4. Calcula estatísticas úteis
    return MapaValidacaoResultado(
      valido: true,
      mensagem: 'Mapa válido e explorável',
      numRegioes: regioes.length,
      tamanhoMaiorRegiao: maiorRegiao.length,
    );
  }

  List<Set<Point<int>>> _encontrarRegioesChao(MapaMasmorra mapa) {
    final visitadas = <Point<int>>{};
    final regioes = <Set<Point<int>>>[];

    for (int y = 0; y < mapa.altura; y++) {
      for (int x = 0; x < mapa.largura; x++) {
        final ponto = Point(x, y);

        if (!visitadas.contains(ponto) && mapa.ehPassavel(x, y)) {
          final regiao = _explorarRegiao(ponto, mapa, visitadas);
          regioes.add(regiao);
        }
      }
    }

    return regioes;
  }

  Set<Point<int>> _explorarRegiao(
    Point<int> inicio,
    MapaMasmorra mapa,
    Set<Point<int>> visitadas,
  ) {
    final regiao = <Point<int>>{};
    final fila = <Point<int>>[inicio];

    while (fila.isNotEmpty) {
      final ponto = fila.removeAt(0);
      if (visitadas.contains(ponto)) continue;

      visitadas.add(ponto);
      regiao.add(ponto);

      for (final (dx, dy) in [(0, 1), (0, -1), (1, 0), (-1, 0)]) {
        final nx = ponto.x + dx;
        final ny = ponto.y + dy;

        if (nx >= 0 && nx < mapa.largura && ny >= 0 && ny < mapa.altura) {
          final prox = Point(nx, ny);
          if (!visitadas.contains(prox) && mapa.ehPassavel(nx, ny)) {
            fila.add(prox);
          }
        }
      }
    }

    return regiao;
  }
}

class MapaValidacaoResultado {
  final bool valido;
  final String mensagem;
  final int? numRegioes;
  final int? tamanhoMaiorRegiao;

  MapaValidacaoResultado({
    required this.valido,
    required this.mensagem,
    this.numRegioes,
    this.tamanhoMaiorRegiao,
  });
}
