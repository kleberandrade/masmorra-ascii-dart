/// Capítulo 30 - Async, Await e o Tempo na Masmorra
/// Boss Final: Sistema de Eventos Completo
///
/// Implementa um barramento de eventos assíncrono que permite que múltiplos
/// sistemas observem e reajam a eventos do jogo (combate, morte, item, etc).
/// Demonstra Future, async/await, Stream, e o padrão Observer.

import 'dart:async';

/// Tipos de evento que podem ocorrer na masmorra
enum TipoEvento { combate, morte, item, nivel, save }

/// Representa um evento com tipo, mensagem e timestamp
class EventoJogo {
  final TipoEvento tipo;
  final String mensagem;
  final DateTime timestamp;

  EventoJogo(this.tipo, this.mensagem)
      : timestamp = DateTime.now();

  @override
  String toString() => '[$tipo] $mensagem (${timestamp.hour}:${timestamp.minute}:${timestamp.second})';
}

/// Bus central de eventos: qualquer sistema pode publicar e ouvir eventos
class BusEventos {
  final _controlador = StreamController<EventoJogo>.broadcast();
  final List<EventoJogo> _historico = [];

  /// Stream que qualquer sistema pode ouvir
  Stream<EventoJogo> get eventos => _controlador.stream;

  /// Publica um evento no bus
  void publicar(EventoJogo evento) {
    _historico.add(evento);
    _controlador.add(evento);
  }

  /// Filtra eventos por tipo
  Stream<EventoJogo> filtrar(TipoEvento tipo) {
    return eventos.where((e) => e.tipo == tipo);
  }

  /// Retorna os últimos [n] eventos do histórico
  List<EventoJogo> ultimosEventos(int n) {
    if (n >= _historico.length) return List.unmodifiable(_historico);
    return List.unmodifiable(_historico.sublist(_historico.length - n));
  }

  /// Libera recursos quando o jogo termina
  void dispose() {
    _controlador.close();
  }
}

/// Observador que registra todos os eventos em log
class ObservadorLog {
  final BusEventos bus;

  ObservadorLog(this.bus) {
    bus.eventos.listen((evento) {
      print('[LOG] $evento');
    });
  }
}

/// Observador que reage a eventos de morte (inimigo derrotado)
class ObservadorExperiencia {
  final BusEventos bus;

  ObservadorExperiencia(this.bus) {
    bus.filtrar(TipoEvento.morte).listen((evento) {
      print('[XP] +50 pontos de experiência ganhos!');
    });
  }
}

/// Observador que reage a eventos de item coletado
class ObservadorInventario {
  final BusEventos bus;
  final List<String> itensColetados = [];

  ObservadorInventario(this.bus) {
    bus.filtrar(TipoEvento.item).listen((evento) {
      itensColetados.add(evento.mensagem);
      print('[INVENTÁRIO] Item adicionado: ${evento.mensagem}');
    });
  }
}

/// Simula uma sequência de combate e emite eventos correspondentes
Future<void> simularCombate(BusEventos bus) async {
  print('\n--- Iniciando sequência de combate ---\n');

  // Herói ataca inimigo
  await Future.delayed(Duration(milliseconds: 500));
  bus.publicar(EventoJogo(TipoEvento.combate, 'Herói ataca Goblin com espada'));

  // Defesa do inimigo
  await Future.delayed(Duration(milliseconds: 500));
  bus.publicar(EventoJogo(TipoEvento.combate, 'Goblin se defende, toma 12 de dano'));

  // Segundo ataque
  await Future.delayed(Duration(milliseconds: 500));
  bus.publicar(EventoJogo(TipoEvento.combate, 'Herói ataca novamente'));

  // Inimigo morre
  await Future.delayed(Duration(milliseconds: 500));
  bus.publicar(EventoJogo(TipoEvento.morte, 'Goblin foi derrotado!'));

  // Item coletado
  await Future.delayed(Duration(milliseconds: 500));
  bus.publicar(EventoJogo(TipoEvento.item, 'Poção de Vida +20'));

  // Nível aumenta
  await Future.delayed(Duration(milliseconds: 500));
  bus.publicar(EventoJogo(TipoEvento.nivel, 'Nível aumentou para 2!'));
}

void main() async {
  print('╔════════════════════════════════════════════╗');
  print('║     SISTEMA DE EVENTOS COMPLETO           ║');
  print('║       Capítulo 30 - Boss Final             ║');
  print('╚════════════════════════════════════════════╝');
  print('');

  final bus = BusEventos();

  // Registra três observadores que reagem independentemente
  final obsLog = ObservadorLog(bus);
  final obsXP = ObservadorExperiencia(bus);
  final obsInventario = ObservadorInventario(bus);

  // Simula uma sequência de combate
  await simularCombate(bus);

  // Aguarda um pouco para todos os eventos serem processados
  await Future.delayed(Duration(milliseconds: 1000));

  // Mostra histórico dos últimos 5 eventos
  print('\n--- Últimos 5 Eventos ---');
  final ultimos = bus.ultimosEventos(5);
  for (final evento in ultimos) {
    print('  • $evento');
  }

  print('\n--- Inventário Final ---');
  for (final item in obsInventario.itensColetados) {
    print('  • $item');
  }

  bus.dispose();
  print('\nBus de eventos finalizado.');
}
