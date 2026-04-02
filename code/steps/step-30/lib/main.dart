import 'dart:async';

import 'bus_eventos.dart';
import 'evento_jogo.dart';

/// Demonstra o sistema de eventos assíncrono do jogo.
///
/// Três sistemas se inscrevem no [BusEventos]:
/// - Log: ouve todos os eventos
/// - XP: ouve apenas mortes de inimigos
/// - Inventário: ouve apenas coleta de itens
///
/// Uma sequência de combate é simulada e cada sistema reage
/// apenas aos eventos que lhe interessam.
Future<void> main() async {
  final bus = BusEventos();

  // Sistema de log ouve TODOS os eventos
  bus.eventos.listen((e) => print('[LOG] $e'));

  // Sistema de XP ouve apenas mortes
  bus.filtrar(TipoEvento.morte).listen((e) {
    print('[XP] +50 pontos de experiência!');
  });

  // Sistema de inventário ouve apenas itens
  bus.filtrar(TipoEvento.item).listen((e) {
    print('[INVENTÁRIO] Adicionado ao inventário!');
  });

  // Simulação de combate
  print('=== Simulação de Combate ===\n');

  bus.publicar(EventoJogo(TipoEvento.combate, 'Herói encontra Goblin'));

  // Simula delay entre ações (como num jogo real)
  await Future.delayed(Duration(milliseconds: 100));

  bus.publicar(EventoJogo(TipoEvento.combate, 'Herói ataca Goblin por 12 de dano'));

  await Future.delayed(Duration(milliseconds: 100));

  bus.publicar(EventoJogo(TipoEvento.combate, 'Goblin ataca Herói por 5 de dano'));

  await Future.delayed(Duration(milliseconds: 100));

  bus.publicar(EventoJogo(TipoEvento.combate, 'Herói ataca Goblin por 15 de dano'));
  bus.publicar(EventoJogo(TipoEvento.morte, 'Goblin derrotado'));

  await Future.delayed(Duration(milliseconds: 100));

  bus.publicar(EventoJogo(TipoEvento.item, 'Poção de vida coletada'));
  bus.publicar(EventoJogo(TipoEvento.item, 'Adaga enferrujada coletada'));

  // Aguarda processamento dos eventos
  await Future.delayed(Duration(milliseconds: 100));

  // Demonstra ultimosEventos (bônus do Boss Final)
  print('\n=== Últimos 3 eventos ===');
  for (final e in bus.ultimosEventos(3)) {
    print('  $e');
  }

  bus.dispose();
}
