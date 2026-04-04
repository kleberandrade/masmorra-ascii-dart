import '../model/room.dart';

/// Mapa textual de salas (Cap. 10).
class TextWorld {
  TextWorld(this.salas);
  final Map<String, Room> salas;

  /// Obtém sala pelo ID. Lança exception se sala não existir.
  /// Assume-se que IDs válidos são sempre fornecidos em contexto controlado.
  Room obterSala(String id) => salas[id]!;
}
