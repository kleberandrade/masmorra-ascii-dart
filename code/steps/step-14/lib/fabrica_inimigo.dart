import 'dart:math';
import 'inimigo.dart';

class FabricaInimigo {
  static Inimigo criarPorId(String id) {
    switch (id) {
      case 'zumbi':
        return Zumbi();
      case 'lobo':
        return Lobo();
      case 'orc':
        return Orc();
      default:
        throw Exception('Inimigo desconhecido: $id');
    }
  }

  static final Map<String, List<String>> inimigosAmbiente = {
    'floresta': ['zumbi', 'lobo'],
    'catacumba': ['lobo', 'orc'],
    'caverna': ['zumbi', 'orc', 'lobo'],
  };

  static String gerarInimigo(String ambiente) {
    final opcoes = inimigosAmbiente[ambiente] ?? ['zumbi'];
    return opcoes[Random().nextInt(opcoes.length)];
  }
}
