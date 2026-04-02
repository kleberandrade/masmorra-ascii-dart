import 'evento_jogo.dart';
import 'barramento_eventos.dart';
import 'processador_eventos.dart';

void main() {
  print('╔════════════════════════════════════════╗');
  print('║   CAPÍTULO 24 - EVENTOS COM GENERICS   ║');
  print('╚════════════════════════════════════════╝\n');

  // Criar barramento de eventos
  final eventoBus = BarramentoEventos<EventoJogo>();

  // Subscrever para imprimir eventos
  eventoBus.subscreve((evento) {
    print('  [EVENTO] ${ProcessadorEventos.renderizar(evento)}');
  });

  // Simular alguns eventos
  print('=== DISPARANDO EVENTOS ===\n');

  eventoBus.dispara(EventoCombate(
    mensagem: 'Você atacou um Lobo',
    dano: 25,
    atacante: 'Jogador',
    alvo: 'Lobo',
  ));

  eventoBus.dispara(EventoLoot(
    itemId: 'pocao_vida',
    nomeItem: 'Poção de vida',
    quantidade: 2,
    fonte: 'Inimigo',
  ));

  eventoBus.dispara(EventoMovimento(
    de: (5, 5),
    para: (6, 5),
  ));

  eventoBus.dispara(EventoNivel(
    nivelAnterior: 1,
    nivelNovo: 2,
    bonus: '+5 HP, +2 ATK',
  ));

  eventoBus.dispara(EventoCombate(
    mensagem: 'Ataque crítico!',
    dano: 85,
    atacante: 'Jogador',
    alvo: 'Orc',
  ));

  // Analisar eventos
  print('\n=== ANÁLISE DE EVENTOS ===\n');

  print('Total de eventos: ${eventoBus.contador}');
  print('Último evento: ${eventoBus.ultimoEvento}');

  // Filtrar por tipo
  print('\n--- Apenas Combates ---');
  final combates = eventoBus.filtrarPorTipo<EventoCombate>();
  for (final combate in combates) {
    print('  ${ProcessadorEventos.renderizar(combate)}');
  }

  print('\n--- Apenas Loots ---');
  final loots = eventoBus.filtrarPorTipo<EventoLoot>();
  for (final loot in loots) {
    print('  ${ProcessadorEventos.renderizar(loot)}');
  }

  // Log completo
  print('\n=== LOG COMPLETO ===\n');
  print(eventoBus.logCompleto());
}
