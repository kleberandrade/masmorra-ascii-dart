import 'dart:async';

import 'package:test/test.dart';

import '../lib/bus_eventos.dart';
import '../lib/evento_jogo.dart';

void main() {
  late BusEventos bus;

  setUp(() {
    bus = BusEventos();
  });

  tearDown(() {
    bus.dispose();
  });

  group('BusEventos', () {
    test('publica e recebe eventos', () async {
      final recebidos = <EventoJogo>[];
      bus.eventos.listen(recebidos.add);

      bus.publicar(EventoJogo(TipoEvento.combate, 'Ataque'));
      bus.publicar(EventoJogo(TipoEvento.morte, 'Goblin morreu'));

      // Aguarda processamento
      await Future.delayed(Duration(milliseconds: 50));

      expect(recebidos, hasLength(2));
      expect(recebidos[0].tipo, equals(TipoEvento.combate));
      expect(recebidos[1].tipo, equals(TipoEvento.morte));
    });

    test('filtra eventos por tipo', () async {
      final mortes = <EventoJogo>[];
      bus.filtrar(TipoEvento.morte).listen(mortes.add);

      bus.publicar(EventoJogo(TipoEvento.combate, 'Ataque'));
      bus.publicar(EventoJogo(TipoEvento.morte, 'Goblin morreu'));
      bus.publicar(EventoJogo(TipoEvento.item, 'Poção coletada'));
      bus.publicar(EventoJogo(TipoEvento.morte, 'Rato morreu'));

      await Future.delayed(Duration(milliseconds: 50));

      expect(mortes, hasLength(2));
      expect(mortes.every((e) => e.tipo == TipoEvento.morte), isTrue);
    });

    test('múltiplos ouvintes recebem o mesmo evento', () async {
      final ouvinte1 = <EventoJogo>[];
      final ouvinte2 = <EventoJogo>[];

      bus.eventos.listen(ouvinte1.add);
      bus.eventos.listen(ouvinte2.add);

      bus.publicar(EventoJogo(TipoEvento.nivel, 'Nível 2!'));

      await Future.delayed(Duration(milliseconds: 50));

      expect(ouvinte1, hasLength(1));
      expect(ouvinte2, hasLength(1));
      expect(ouvinte1[0].mensagem, equals(ouvinte2[0].mensagem));
    });

    test('ultimosEventos retorna os N mais recentes', () {
      bus.publicar(EventoJogo(TipoEvento.combate, 'Evento 1'));
      bus.publicar(EventoJogo(TipoEvento.combate, 'Evento 2'));
      bus.publicar(EventoJogo(TipoEvento.combate, 'Evento 3'));
      bus.publicar(EventoJogo(TipoEvento.combate, 'Evento 4'));
      bus.publicar(EventoJogo(TipoEvento.combate, 'Evento 5'));

      final ultimos = bus.ultimosEventos(3);

      expect(ultimos, hasLength(3));
      expect(ultimos[0].mensagem, equals('Evento 3'));
      expect(ultimos[1].mensagem, equals('Evento 4'));
      expect(ultimos[2].mensagem, equals('Evento 5'));
    });

    test('ultimosEventos com N maior que histórico retorna tudo', () {
      bus.publicar(EventoJogo(TipoEvento.item, 'Único'));

      final ultimos = bus.ultimosEventos(10);

      expect(ultimos, hasLength(1));
      expect(ultimos[0].mensagem, equals('Único'));
    });

    test('EventoJogo tem timestamp', () {
      final antes = DateTime.now();
      final evento = EventoJogo(TipoEvento.save, 'Salvo');
      final depois = DateTime.now();

      expect(evento.timestamp.isAfter(antes) || evento.timestamp == antes,
          isTrue);
      expect(evento.timestamp.isBefore(depois) || evento.timestamp == depois,
          isTrue);
    });

    test('EventoJogo toString formata corretamente', () {
      final evento = EventoJogo(TipoEvento.combate, 'Herói ataca');
      expect(evento.toString(), equals('[TipoEvento.combate] Herói ataca'));
    });
  });
}
