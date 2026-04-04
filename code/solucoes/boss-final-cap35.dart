/// Boss Final Capítulo 35: Sistema de Reações em Cadeia
///
/// Objetivo: Um evento dispara eventos posteriores
/// (morte -> loot -> colheita -> XP -> subida de nível -> conquista).
/// Use Future e Timer para simular delays.
///
/// Conceitos abordados:
/// - Future e async/await
/// - Timer para delays
/// - Encadeamento de eventos
/// - Callbacks e streams

import 'dart:async';

void main() async {
  print('═══════════════════════════════════════════════════════════');
  print('  Boss Final Capítulo 35: Reações em Cadeia');
  print('═══════════════════════════════════════════════════════════');
  print('');

  // Sistema de eventos
  var sistema = SistemaDeReacoes();

  print('Iniciando reação em cadeia...');
  print('');

  // Disparar evento de morte (começa a cadeia)
  await sistema.disparar(Evento.morte);

  print('');
  print('═══════════════════════════════════════════════════════════');
  print('  Todos os eventos foram disparados!');
  print('═══════════════════════════════════════════════════════════');
}

/// Enum de eventos
enum Evento { morte, loot, colheita, xp, subida, conquista }

/// Classe que gerencia reações em cadeia
class SistemaDeReacoes {
  /// Disparar evento e seus efeitos em cascata
  Future<void> disparar(Evento evento) async {
    switch (evento) {
      case Evento.morte:
        await _executarMorte();
        // Morte dispara loot
        await disparar(Evento.loot);
        break;

      case Evento.loot:
        await _executarLoot();
        // Loot dispara colheita
        await disparar(Evento.colheita);
        break;

      case Evento.colheita:
        await _executarColheita();
        // Colheita dispara XP
        await disparar(Evento.xp);
        break;

      case Evento.xp:
        await _executarXP();
        // XP dispara subida
        await disparar(Evento.subida);
        break;

      case Evento.subida:
        await _executarSubida();
        // Subida dispara conquista
        await disparar(Evento.conquista);
        break;

      case Evento.conquista:
        await _executarConquista();
        break;
    }
  }

  /// Simular delay e executar morte
  Future<void> _executarMorte() async {
    await Future.delayed(Duration(milliseconds: 500));
    print('[MORTE]');
    print('  O inimigo cai...');
  }

  /// Simular delay e executar loot
  Future<void> _executarLoot() async {
    await Future.delayed(Duration(milliseconds: 500));
    print('[LOOT]');
    print('  ✨ Ouro cai no chão: +50g');
  }

  /// Simular delay e executar colheita
  Future<void> _executarColheita() async {
    await Future.delayed(Duration(milliseconds: 500));
    print('[COLHEITA]');
    print('  📦 Item coletado: Espada Rara');
  }

  /// Simular delay e executar ganho de XP
  Future<void> _executarXP() async {
    await Future.delayed(Duration(milliseconds: 500));
    print('[XP GANHO]');
    print('  ⭐ +150 XP');
  }

  /// Simular delay e executar subida de nível
  Future<void> _executarSubida() async {
    await Future.delayed(Duration(milliseconds: 500));
    print('[SUBIDA DE NÍVEL]');
    print('  🎉 Você atingiu Nível 5!');
    print('  HP restaurado!');
  }

  /// Simular delay e executar conquista
  Future<void> _executarConquista() async {
    await Future.delayed(Duration(milliseconds: 500));
    print('[CONQUISTA DESBLOQUEADA]');
    print('  🏆 "Matador de Dragões" desbloqueado!');
  }
}

/// Versão alternativa com callbacks
class SistemaComCallbacks {
  final List<void Function(Evento)> _ouvintes = [];

  /// Registrar ouvinte para eventos
  void registrarOuvinte(void Function(Evento) callback) {
    _ouvintes.add(callback);
  }

  /// Disparar evento
  Future<void> disparar(Evento evento, {int delayMs = 500}) async {
    await Future.delayed(Duration(milliseconds: delayMs));

    // Notificar todos os ouvintes
    for (var ouvinte in _ouvintes) {
      ouvinte(evento);
    }

    // Disparar próximo evento na cadeia
    if (evento == Evento.morte) {
      await disparar(Evento.loot);
    } else if (evento == Evento.loot) {
      await disparar(Evento.colheita);
    } else if (evento == Evento.colheita) {
      await disparar(Evento.xp);
    } else if (evento == Evento.xp) {
      await disparar(Evento.subida);
    } else if (evento == Evento.subida) {
      await disparar(Evento.conquista);
    }
  }
}

/// Versão com Stream para múltiplos eventos
class SistemaComStream {
  final _controlador = StreamController<Evento>.broadcast();

  /// Obter stream de eventos
  Stream<Evento> get eventos => _controlador.stream;

  /// Disparar evento e cadeia
  Future<void> dispararCadeia() async {
    await _dispararComDelay(Evento.morte, 0);
  }

  Future<void> _dispararComDelay(Evento evento, int delaySomaAcumulada) async {
    var novoDelay = delaySomaAcumulada + 500;
    await Future.delayed(Duration(milliseconds: novoDelay));
    _controlador.add(evento);

    // Determinar próximo evento
    Evento? proximo;
    switch (evento) {
      case Evento.morte:
        proximo = Evento.loot;
      case Evento.loot:
        proximo = Evento.colheita;
      case Evento.colheita:
        proximo = Evento.xp;
      case Evento.xp:
        proximo = Evento.subida;
      case Evento.subida:
        proximo = Evento.conquista;
      case Evento.conquista:
        proximo = null;
    }

    if (proximo != null) {
      await _dispararComDelay(proximo, novoDelay);
    }
  }

  void fechar() {
    _controlador.close();
  }
}
