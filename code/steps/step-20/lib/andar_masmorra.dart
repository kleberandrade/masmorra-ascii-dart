import 'entidade.dart';
import 'entidade_inimigo.dart';
import 'mapa_masmorra.dart';

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

  /// Retorna todas as entidades de um tipo específico
  List<T> entidadesDoTipo<T extends Entidade>() {
    return entidades.whereType<T>().toList();
  }

  /// Conta quantos inimigos ainda existem neste andar
  int contarInimigos() {
    return entidadesDoTipo<EntidadeInimigo>().length;
  }
}
