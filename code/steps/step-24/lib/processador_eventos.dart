import 'evento_jogo.dart';

/// Processa e renderiza eventos com pattern matching
class ProcessadorEventos {
  /// Renderiza um evento em formato legível
  static String renderizar(EventoJogo evento) {
    return switch (evento) {
      EventoCombate(:final mensagem, :final dano) when dano > 50 =>
        '[CRÍTICO] $mensagem (dano: $dano)',

      EventoCombate(:final mensagem, :final dano) =>
        '> $mensagem (dano: $dano)',

      EventoLoot(:final nomeItem, :final quantidade) when quantidade > 1 =>
        '+ $quantidade x $nomeItem',

      EventoLoot(:final nomeItem) =>
        '+ $nomeItem',

      EventoMovimento(:final de, :final para) =>
        '> Movimento: (${de.$1},${de.$2}) → (${para.$1},${para.$2})',

      EventoNivel(:final nivelNovo, :final bonus) =>
        'LEVEL UP! Nível $nivelNovo! +$bonus',
    };
  }

  /// Processa um evento com efeitos colaterais
  static void processar(EventoJogo evento) {
    switch (evento) {
      case EventoCombate(:final dano, :final atacante?) when dano > 0:
        print('> $atacante causou $dano dano!');

      case EventoCombate(:final dano) when dano < 0:
        print('! Recebeu ${dano.abs()} dano!');

      case EventoLoot(:final itemId, :final quantidade):
        print('+ Adquiriu: $itemId x$quantidade');

      case EventoNivel(:final nivelAnterior, :final nivelNovo):
        print('* Subiu de nível $nivelAnterior → $nivelNovo!');

      case EventoMovimento():
        break;

      case _:
        break;
    }
  }
}
