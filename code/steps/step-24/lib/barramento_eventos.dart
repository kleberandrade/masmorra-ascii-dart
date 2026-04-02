import 'evento_jogo.dart';

/// Barramento de eventos genérico com subscrição e filtragem
class BarramentoEventos<T extends EventoJogo> {
  final List<T> eventos = [];
  final List<void Function(T)> _listeners = [];

  /// Dispara um evento e notifica todos os listeners
  void dispara(T evento) {
    eventos.add(evento);
    for (final listener in _listeners) {
      listener(evento);
    }
  }

  /// Subscreve para receber notificações de eventos
  void subscreve(void Function(T) callback) {
    _listeners.add(callback);
  }

  /// Desinscreve de notificações
  void desinscreve(void Function(T) callback) {
    _listeners.remove(callback);
  }

  /// Filtra eventos por tipo
  List<U> filtrarPorTipo<U extends T>() {
    return eventos.whereType<U>().toList();
  }

  /// Retorna o último evento disparado
  T? get ultimoEvento => eventos.isEmpty ? null : eventos.last;

  /// Gera um log completo de todos os eventos
  String logCompleto() {
    return eventos.map((e) => e.toString()).join('\n');
  }

  /// Limpa o histórico de eventos
  void limpar() {
    eventos.clear();
  }

  /// Retorna a contagem de eventos
  int get contador => eventos.length;
}
