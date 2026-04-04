/// Classe base para todos os eventos do jogo
sealed class EventoJogo {
  final DateTime timestamp;

  EventoJogo({DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}

/// Evento de combate: você atacou ou foi atacado
class EventoCombate extends EventoJogo {
  final String mensagem;
  final int dano;
  final String? atacante;
  final String? alvo;

  EventoCombate({
    required this.mensagem,
    required this.dano,
    this.atacante,
    this.alvo,
    super.timestamp,
  });

  @override
  String toString() => 'Combate: $mensagem (dano: $dano)';
}

/// Evento de loot: item foi adquirido
class EventoLoot extends EventoJogo {
  final String itemId;
  final String nomeItem;
  final int quantidade;
  final String fonte;

  EventoLoot({
    required this.itemId,
    required this.nomeItem,
    required this.quantidade,
    required this.fonte,
    super.timestamp,
  });

  @override
  String toString() =>
      'Loot: Adquiriu $quantidade x $nomeItem (de $fonte)';
}

/// Evento de movimento: você moveu-se
class EventoMovimento extends EventoJogo {
  final (int x, int y) de;
  final (int x, int y) para;

  EventoMovimento({
    required this.de,
    required this.para,
    super.timestamp,
  });

  @override
  String toString() =>
      'Movimento: (${de.$1},${de.$2}) → (${para.$1},${para.$2})';
}

/// Evento de nivelação: você subiu de nível
class EventoNivel extends EventoJogo {
  final int nivelAnterior;
  final int nivelNovo;
  final String bonus;

  EventoNivel({
    required this.nivelAnterior,
    required this.nivelNovo,
    required this.bonus,
    super.timestamp,
  });

  @override
  String toString() =>
      'Nível UP: $nivelAnterior → $nivelNovo! Bônus: $bonus';
}
