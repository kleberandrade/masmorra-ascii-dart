import 'dart:async';

import 'evento_jogo.dart';

/// Bus central de eventos — qualquer sistema pode publicar e ouvir.
///
/// Usa [StreamController.broadcast] para permitir múltiplos ouvintes
/// simultâneos. Cada sistema se inscreve apenas nos eventos que precisa.
class BusEventos {
  final _controlador = StreamController<EventoJogo>.broadcast();
  final List<EventoJogo> _historico = [];

  /// Stream que qualquer sistema pode ouvir.
  Stream<EventoJogo> get eventos => _controlador.stream;

  /// Publica um evento no bus.
  void publicar(EventoJogo evento) {
    _historico.add(evento);
    _controlador.add(evento);
  }

  /// Filtra eventos por tipo.
  Stream<EventoJogo> filtrar(TipoEvento tipo) {
    return eventos.where((e) => e.tipo == tipo);
  }

  /// Retorna os últimos [n] eventos do histórico.
  List<EventoJogo> ultimosEventos(int n) {
    if (n >= _historico.length) return List.unmodifiable(_historico);
    return List.unmodifiable(_historico.sublist(_historico.length - n));
  }

  /// Libera recursos quando o jogo termina.
  void dispose() {
    _controlador.close();
  }
}
