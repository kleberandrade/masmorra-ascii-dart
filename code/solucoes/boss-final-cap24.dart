// ============================================================================
// Capítulo 24 - Boss Final: Combate Recente
// ============================================================================
// Exercício: Análise Temporal de Eventos
//
// Implementa um sistema que registra eventos de combate com timestamp.
// Permite filtrar eventos ocorridos nos últimos N minutos.
// Demonstra generics, sealed classes, pattern matching e análise temporal.
// ============================================================================

// Classe base selada para eventos
sealed class EventoJogo {
  final DateTime timestamp;

  EventoJogo({DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();

  /// Calcula quantos minutos atrás este evento ocorreu
  int get minutosAtras {
    return DateTime.now().difference(timestamp).inMinutes;
  }
}

// Evento de combate: dano causado ou sofrido
class EventoCombate extends EventoJogo {
  final String atacante;
  final String alvo;
  final int dano;
  final bool esCritico;

  EventoCombate({
    required this.atacante,
    required this.alvo,
    required this.dano,
    this.esCritico = false,
    super.timestamp,
  });

  @override
  String toString() =>
      '[$atacante → $alvo] Dano: $dano${esCritico ? ' (CRÍTICO!)' : ''}';
}

// Evento de cura
class EventoCura extends EventoJogo {
  final String personagem;
  final int hpRestaurado;

  EventoCura({
    required this.personagem,
    required this.hpRestaurado,
    super.timestamp,
  });

  @override
  String toString() => '[$personagem] Curou $hpRestaurado HP';
}

// Evento de morte
class EventoMorte extends EventoJogo {
  final String personagem;

  EventoMorte({
    required this.personagem,
    super.timestamp,
  });

  @override
  String toString() => '☠ $personagem MORREU';
}

// Barramento de eventos com análise temporal
class BarramentoEventos<T extends EventoJogo> {
  final List<T> eventos = [];

  /// Dispara um evento (adiciona ao log)
  void disparar(T evento) {
    eventos.add(evento);
  }

  /// Filtra eventos dos últimos N minutos
  List<T> eventosUltimosMinutos(int minutos) {
    return eventos.where((e) {
      final deltaMinutos = e.minutosAtras;
      return deltaMinutos <= minutos;
    }).toList();
  }

  /// Filtra eventos de tipo específico
  List<U> filtrarPorTipo<U extends T>() {
    return eventos.whereType<U>().toList();
  }

  /// Calcula dano total em um período de tempo
  int somaGolpesCombate(int ultramosMinutos) {
    final combates = eventosUltimosMinutos(ultramosMinutos)
        .whereType<EventoCombate>()
        .toList();

    return combates.fold<int>(0, (soma, evento) => soma + evento.dano);
  }

  /// Conta eventos críticos recentes
  int contarGoilpesCriticos(int ultimosMinutos) {
    final combates = eventosUltimosMinutos(ultimosMinutos)
        .whereType<EventoCombate>()
        .where((e) => e.esCritico)
        .length;

    return combates;
  }

  /// Obtém total de eventos em um período
  int contarEventos(int ultimosMinutos) {
    return eventosUltimosMinutos(ultimosMinutos).length;
  }

  /// Exibe relatório de eventos recentes
  void exibirRelatorioTempo(int ultimosMinutos) {
    final eventosRecentes = eventosUltimosMinutos(ultimosMinutos);
    final danoTotal = somaGolpesCombate(ultimosMinutos);
    final criticosTotais = contarGoilpesCriticos(ultimosMinutos);

    print('\n╔════════════════════════════════════════════════════════════╗');
    print('║        RELATÓRIO: Últimos $ultimosMinutos minutos');
    print('╠════════════════════════════════════════════════════════════╣');
    print('║ Total de eventos: ${eventosRecentes.length}');
    print('║ Dano total em combate: $danoTotal');
    print('║ Golpes críticos: $criticosTotais');
    print('╠════════════════════════════════════════════════════════════╣');

    if (eventosRecentes.isEmpty) {
      print('║ (sem eventos neste período)');
    } else {
      for (int i = 0; i < eventosRecentes.length; i++) {
        final evento = eventosRecentes[i];
        final minutos = evento.minutosAtras;
        print('║ [$minutos min atrás] $evento');
      }
    }

    print('╚════════════════════════════════════════════════════════════╝');
  }

  /// Log completo de todos os eventos
  String logCompleto() {
    return eventos.map((e) => '${e.timestamp}: $e').join('\n');
  }
}

// ============================================================================
// Demonstração do sistema
// ============================================================================

void main() {
  print('\n════════════════════════════════════════════════════════════');
  print('  MASMORRA ASCII - Capítulo 24: Combate Recente');
  print('════════════════════════════════════════════════════════════\n');

  final barramento = BarramentoEventos<EventoJogo>();

  // ======================================================================
  // TESTE 1: Simular combate com eventos espaçados
  // ======================================================================
  print('🔍 TESTE 1: Gerando Eventos de Combate');
  print('───────────────────────────────────────────────────────────');

  // Criar eventos com timestamps simulados (atual)
  for (int i = 0; i < 5; i++) {
    barramento.disparar(EventoCombate(
      atacante: 'Herói',
      alvo: 'Goblin $i',
      dano: 10 + (i * 3),
      esCritico: i % 2 == 0,
    ));
  }

  barramento.disparar(EventoCura(
    personagem: 'Herói',
    hpRestaurado: 25,
  ));

  print('✓ Disparados 6 eventos (5 combate, 1 cura)');

  // ======================================================================
  // TESTE 2: Análise de últimos N minutos
  // ======================================================================
  print('\n🔍 TESTE 2: Eventos dos Últimos 5 Minutos');
  print('───────────────────────────────────────────────────────────');

  barramento.exibirRelatorioTempo(5);

  // ======================================================================
  // TESTE 3: Filtragem por tipo de evento
  // ======================================================================
  print('\n🔍 TESTE 3: Filtragem por Tipo');
  print('───────────────────────────────────────────────────────────');

  final combates = barramento.filtrarPorTipo<EventoCombate>();
  final curas = barramento.filtrarPorTipo<EventoCura>();
  final mortes = barramento.filtrarPorTipo<EventoMorte>();

  print('Total de eventos: ${barramento.eventos.length}');
  print('Combates: ${combates.length}');
  print('Curas: ${curas.length}');
  print('Mortes: ${mortes.length}');

  // ======================================================================
  // TESTE 4: Dano total em combate
  // ======================================================================
  print('\n🔍 TESTE 4: Dano Total Acumulado');
  print('───────────────────────────────────────────────────────────');

  final danoTotal = combates.fold<int>(0, (soma, e) => soma + e.dano);
  final mediaGolpe = (danoTotal / combates.length).toStringAsFixed(1);

  print('Dano total: $danoTotal');
  print('Número de ataques: ${combates.length}');
  print('Dano médio por ataque: $mediaGolpe');

  // ======================================================================
  // TESTE 5: Golpes críticos vs normais
  // ======================================================================
  print('\n🔍 TESTE 5: Críticos vs Normais');
  print('───────────────────────────────────────────────────────────');

  final criticos = combates.where((e) => e.esCritico).toList();
  final normais = combates.where((e) => !e.esCritico).toList();

  final danoCritico = criticos.fold<int>(0, (s, e) => s + e.dano);
  final danoNormal = normais.fold<int>(0, (s, e) => s + e.dano);

  print('Golpes críticos: ${criticos.length} (dano total: $danoCritico)');
  print('Golpes normais: ${normais.length} (dano total: $danoNormal)');

  if (criticos.isNotEmpty) {
    final mediaCritico = (danoCritico / criticos.length).toStringAsFixed(1);
    print('Dano médio crítico: $mediaCritico');
  }

  // ======================================================================
  // TESTE 6: Cenário com eventos antigos e recentes
  // ======================================================================
  print('\n🔍 TESTE 6: Análise Temporal Comparativa');
  print('───────────────────────────────────────────────────────────');

  // Simular que eventos antigos foram removidos (demonstração)
  // Na prática, você poderia usar DateTime.now().subtract(Duration(...))
  print('Eventos nos últimos 1 minuto: ${barramento.contarEventos(1)}');
  print('Eventos nos últimos 5 minutos: ${barramento.contarEventos(5)}');
  print('Eventos nos últimos 10 minutos: ${barramento.contarEventos(10)}');

  // ======================================================================
  // TESTE 7: Padrão matching em eventos
  // ======================================================================
  print('\n🔍 TESTE 7: Pattern Matching em Eventos');
  print('───────────────────────────────────────────────────────────');

  for (final evento in barramento.eventos.take(3)) {
    final descricao = switch (evento) {
      EventoCombate(:final atacante, :final dano, :final esCritico) =>
        '⚔ $atacante causou $dano de dano${esCritico ? ' (CRÍTICO)' : ''}',
      EventoCura(:final personagem, :final hpRestaurado) =>
        '+ $personagem recuperou $hpRestaurado HP',
      EventoMorte(:final personagem) =>
        '☠ $personagem foi derrotado',
      _ => 'Evento desconhecido',
    };

    print(descricao);
  }

  print('\n════════════════════════════════════════════════════════════');
  print('  ⚔ Seu histórico de combate está registrado!');
  print('════════════════════════════════════════════════════════════\n');
}
