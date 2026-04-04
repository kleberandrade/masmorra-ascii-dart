import '../modelos/sala.dart';

/// Mapa textual de salas (Cap. 10).
class MundoTexto {
  MundoTexto(this.salas);
  final Map<String, Sala> salas;

  /// Obtém sala pelo ID. Lança exception se sala não existir.
  /// Assume-se que IDs válidos são sempre fornecidos em contexto controlado.
  Sala obterSala(String id) => salas[id]!;
}
