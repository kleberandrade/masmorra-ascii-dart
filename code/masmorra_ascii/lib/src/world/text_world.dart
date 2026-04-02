import '../model/room.dart';

/// Mapa textual de salas (Cap. 10).
class TextWorld {
  TextWorld(this.salas);
  final Map<String, Room> salas;

  Room obterSala(String id) => salas[id]!;
}
