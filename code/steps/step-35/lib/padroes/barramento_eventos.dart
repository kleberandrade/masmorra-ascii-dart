import 'dart:async';

/// Evento base do jogo
abstract class EventoJogo {
  final DateTime timestamp = DateTime.now();
}

/// Evento de morte de inimigo
class EventoMorteInimigo extends EventoJogo {
  final String nomeInimigo;
  final int xpRecompensa;

  EventoMorteInimigo({
    required this.nomeInimigo,
    required this.xpRecompensa,
  });
}

/// Evento de colheita de item
class EventoColheitaItem extends EventoJogo {
  final String nomeItem;
  final String personagem;

  EventoColheitaItem({
    required this.nomeItem,
    required this.personagem,
  });
}

/// Evento de dano aplicado
class EventoDanoAplicado extends EventoJogo {
  final String atacante;
  final String alvo;
  final int dano;

  EventoDanoAplicado({
    required this.atacante,
    required this.alvo,
    required this.dano,
  });
}

/// Barramento de eventos (Observer pattern)
class BarramentoEventos {
  static final BarramentoEventos _instancia = BarramentoEventos._();

  final StreamController<EventoJogo> _controlador =
      StreamController<EventoJogo>.broadcast();

  BarramentoEventos._();

  factory BarramentoEventos() => _instancia;

  void emitir(EventoJogo evento) {
    _controlador.add(evento);
  }

  Stream<T> on<T extends EventoJogo>() {
    return _controlador.stream.where((e) => e is T).cast<T>();
  }

  void fechar() {
    _controlador.close();
  }
}

/// Observador de log
class ObservadorLog {
  final BarramentoEventos bus;
  late StreamSubscription<EventoJogo> subscription;

  ObservadorLog(this.bus) {
    subscription = bus.on<EventoJogo>().listen((evento) {
      if (evento is EventoMorteInimigo) {
        print('[LOG] ${evento.nomeInimigo} foi derrotado!');
      } else if (evento is EventoDanoAplicado) {
        print('[LOG] ${evento.atacante} ataca ${evento.alvo} por ${evento.dano}!');
      }
    });
  }

  void cancelar() => subscription.cancel();
}

/// Observador de estatísticas
class ObservadorEstatisticas {
  final BarramentoEventos bus;
  late StreamSubscription<EventoJogo> subscription;

  int totalMatos = 0;
  int danoTotal = 0;

  ObservadorEstatisticas(this.bus) {
    subscription = bus.on<EventoJogo>().listen((evento) {
      if (evento is EventoMorteInimigo) {
        totalMatos++;
      } else if (evento is EventoDanoAplicado) {
        danoTotal += evento.dano;
      }
    });
  }

  void cancelar() => subscription.cancel();
}
