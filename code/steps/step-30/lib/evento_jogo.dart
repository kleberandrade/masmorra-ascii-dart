/// Tipos de evento do jogo.
enum TipoEvento { combate, morte, item, nivel, save }

/// Um evento com tipo, mensagem e timestamp.
class EventoJogo {
  final TipoEvento tipo;
  final String mensagem;
  final DateTime timestamp;

  EventoJogo(this.tipo, this.mensagem) : timestamp = DateTime.now();

  @override
  String toString() => '[$tipo] $mensagem';
}
