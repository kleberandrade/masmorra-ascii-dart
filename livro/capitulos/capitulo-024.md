# Capítulo 24 - Generics e Pattern Matching: Sistema de Eventos

> *A economia gera ouro. A loja oferece itens. Você compra uma espada e... sente nada, sem feedback. Mas quando equipa essa espada, o seu ataque sobe. Quando bebe uma poção, o seu HP sobe. Quando level-up, ganha habilidades. Cada uma destas ações é um evento, um fato histórico que o jogo deveria registrar. Este capítulo transforma o silêncio em narrativa: um sistema de eventos tipado que registra, filtra e notifica em tempo real. Aqui aprenderá o poder dos generics e do pattern matching em Dart 3 para criar código limpo e expressivo.*

## O Que Vamos Aprender

Neste capítulo você vai:

- Entender generics: `List<T>`, `BarramentoEventos<T extends EventoJogo>`
- Criar uma hierarquia de sealed classes para eventos: `EventoCombate`, `EventoLoot`, `EventoMovimento`, `EventoNivel`
- Usar pattern matching em Dart 3: **switch expressions** com destructuring
- Implementar um `BarramentoEventos` genérico que filtra eventos por tipo
- Criar um log de eventos rich, com renderização diferenciada por tipo
- Integrar eventos no fluxo de jogo: cada ação dispara um evento
- Mostrar notificações em tempo real: loot pickups, levelups, combate
- Demonstrar **guard clauses** em pattern matching

Ao final, você terá um sistema de eventos tipado que torna o jogo mais narrativo e reativo.

## Generics: Uma Rápida Recordação

Você já conhece `List<T>`. Generics são a forma de Dart dizer: "esta estrutura pode guardar qualquer tipo, mas vou ser estrito sobre qual tipo é". É segurança de tipos em tempo de compilação.

```dart
List<int> numeros = [1, 2, 3];
List<String> nomes = ['Alice', 'Bob'];
```

O `T` é um parâmetro de tipo. Significa: esta lista pode conter qualquer tipo, desde que todas as coisas nela sejam do mesmo tipo.

**Generics em classes customizadas:**

```dart
class Caixa<T> {
  T? conteudo;

  void guardar(T item) {
    conteudo = item;
  }

  T? remover() {
    final temp = conteudo;
    conteudo = null;
    return temp;
  }
}

final caixaInt = Caixa<int>();
caixaInt.guardar(42);
print(caixaInt.remover()); // 42
```

## Hierarquia de Eventos com Sealed Classes

Eventos são dados imutáveis que representam algo que aconteceu. Usamos sealed classes para uma hierarquia fechada:

```dart
// lib/evento_jogo.dart

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
      'Loot: Adquiriu $quantidade × $nomeItem (de $fonte)';
}

/// Evento de movimento: você moveu-se
/// Nota: usa registros (records) de Dart 3 para pares de coordenadas
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
```

## BarramentoEventos Genérico

Um `BarramentoEventos` é um registador (log) de eventos tipado. Permite subscrições filtradas e callbacks. Pense como um serviço de notificações: alguém dispara um evento (ex: item coletado), e todas as subscrições recebem a notificação automaticamente. Isto desacopla completamente: o gerenciador de combate não precisa saber que a UI existe; combate dispara evento, UI sente e reage de forma independente.

```dart
// lib/barramento_eventos.dart

class BarramentoEventos<T extends EventoJogo> {
  final List<T> eventos = [];
  final List<void Function(T)> _listeners = [];

  void dispara(T evento) {
    eventos.add(evento);
    for (final listener in _listeners) {
      listener(evento);
    }
  }

  void subscreve(void Function(T) callback) {
    _listeners.add(callback);
  }

  void desinscreve(void Function(T) callback) {
    _listeners.remove(callback);
  }

  List<T> filtrarPorTipo<U extends T>() {
    return eventos.whereType<U>().toList();
  }

  T? get ultimoEvento => eventos.isEmpty ? null : eventos.last;

  String logCompleto() {
    return eventos.map((e) => e.toString()).join('\n');
  }

  void limpar() {
    eventos.clear();
  }

  int get contador => eventos.length;
}
```

## Pattern Matching em Dart 3

O pattern matching permite desconstructir dados de forma clara. Aqui está o power:

```dart
// lib/processador_eventos.dart

class ProcessadorEventos {
  static String renderizar(EventoJogo evento) {
    return switch (evento) {
      EventoCombate(:final mensagem, :final dano) when dano > 50 =>
        '[CRÍTICO] $mensagem (dano: $dano)',

      EventoCombate(:final mensagem, :final dano) =>
        '> $mensagem (dano: $dano)',

      EventoLoot(:final nomeItem, :final quantidade) when quantidade > 1 =>
        '+ $quantidade x $nomeItem',

      EventoLoot(:final nomeItem, :final quantidade) =>
        '+ $nomeItem',

      EventoMovimento(:final de, :final para) =>
        '> Movimento: (${de.$1},${de.$2}) → (${para.$1},${para.$2})',

      EventoNivel(:final nivelNovo, :final bonus) =>
        'LEVEL UP! Nível $nivelNovo! +$bonus',

      _ => '? Evento desconhecido',
    };
  }

  static void processar(EventoJogo evento) {
    switch (evento) {
      case EventoCombate(:final dano, :final atacante?) when dano > 0:
        print('> $atacante causou $dano dano!');

      case EventoCombate(:final dano) when dano < 0:
        print('! Recebeu ${dano.abs()} de dano!');

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
```

**Quebra-cabeça:**

- `(:final dano)` desconstructures o campo `dano`
- `when dano > 50` é uma guard clause: aplica-se só se verdadeira
- `(:final atacante?)` significa "pode ser null"
- `_` é match-all (qualquer coisa)

## Integrando Eventos no Jogo

Cada ação dispara um evento. Quando você se move, um `EventoMovimento` é disparado. Quando coleta item, um `EventoLoot`. Quando sofre dano, um `EventoCombate`. Cada evento é registado no barramento, listeners recebem notificação, renderizam mensagem na tela.

```dart
// lib/dungeon_com_eventos.dart

class DungeonComEventos {
  late BarramentoEventos<EventoJogo> eventoBus;

  DungeonComEventos() {
    eventoBus = BarramentoEventos<EventoJogo>();
    eventoBus.subscreve((evento) {
      print(ProcessadorEventos.renderizar(evento));
    });
  }

  void moverJogador(int dx, int dy) {
    final xAnterior = jogador.x;
    final yAnterior = jogador.y;

    jogador.x += dx;
    jogador.y += dy;

    eventoBus.dispara(EventoMovimento(
      de: (xAnterior, yAnterior),
      para: (jogador.x, jogador.y),
    ));
  }

  void ganharItem(String itemId, String nomeItem, int quantidade) {
    jogador.adicionarItem(itemId);

    eventoBus.dispara(EventoLoot(
      itemId: itemId,
      nomeItem: nomeItem,
      quantidade: quantidade,
      fonte: 'chão',
    ));
  }

  void sofrerDano(int dano) {
    jogador.hp -= dano;

    eventoBus.dispara(EventoCombate(
      mensagem: 'Sofreste dano!',
      dano: -dano,
      alvo: 'Jogador',
    ));
  }

  void levelUp() {
    final nivelAnterior = jogador.nivel;
    jogador.nivel++;

    eventoBus.dispara(EventoNivel(
      nivelAnterior: nivelAnterior,
      nivelNovo: jogador.nivel,
      bonus: '+5 HP, +2 ATK',
    ));
  }
}
```

## Desafios da Masmorra

**Desafio 24.1. Quando o Guerreiro Muda de Arma.** Seu guerreiro equipa uma Espada Lendária, depois a desequipa para voltar ao escudo. Cada mudança conta. Crie `EventoEquipamento extends EventoJogo` com `itemId`, `nomeItem`, `equipado` (bool). Dispare esse evento toda vez que equipar/desequipar. Teste: equipe e desequipe 3 vezes, veja se 6 eventos foram registrados. Dica: sealed class mantém a tipagem segura.

**Desafio 24.2. Narrativa do Equipamento.** O log de ações deve refletir sua jornada de equipamento. Adicione um case em `ProcessadorEventos.renderizar()`: se `EventoEquipamento` com `equipado=true`, exiba em verde `[EQUIP] Equipaste: Espada Lendária`. Se `equipado=false`, em vermelho `[DESQUIP] Desequipaste:...`. Execute uma sequência de mudanças, o log deve contar a história. Dica: use padrão com guard: `equipado when equipado == true`.

**Desafio 24.3. Combate Violento.** Nem todo dano é importante. Filtre eventos de combate: retorne só `EventoCombate` com `dano > 20` (golpes críticos e devastadores). Itere e exiba: "Crítico! Dano: 35". Teste: em 100 turnos de combate, quantos golpes foram >= 20 dano? Você vai notar que a maioria é fraca e apenas alguns são épicos. Dica: combine `whereType<EventoCombate>()` com `.where()`.

**Desafio 24.4. Resumo da Partida.** Ao fim do jogo, você quer saber: Quantas vezes equipou itens? Quantas vezes sofreu dano? Quantas compras na loja? Implemente `contagemPorTipo()` que retorna um mapa: `{'EventoCombate': 145, 'EventoEquipamento': 8, 'EventoCompra': 3}`. Use pattern matching no switch para cada tipo. Execute uma partida e veja o resumo final. Dica: isto é análise agregada.

**Desafio 24.5. (Desafio): Assista a Sua Epopeia.** Você quer mostrar a um amigo o que aconteceu na masmorra. Implemente `EventReplay` que armazena eventos e tem método `async tocar()`: exibe cada evento com 500ms entre eles. Use `Future.delayed(Duration(milliseconds: 500))`. Assim, narrativa toda se desenrola visualmente. Teste: grave 50 eventos, toque e veja cada um aparecer sequencialmente. Você consegue acompanhar a história? Dica: `await` faz o programa esperar sem travar.

**Boss Final 24.6. Combate Recente.** Você quer saber: Nos últimos 5 minutos de jogo, qual foi o dano total sofrido? Implemente um método que retorna eventos de combate ocorridos nos últimos N minutos. Use `DateTime.now()` e `evento.timestamp.difference(DateTime.now()).inMinutes < N`. Some o dano. Teste: após 10 minutos de jogo, pergunte dano dos últimos 3 minutos vs últimos 10. Dica: Delta de tempo revela ritmo de combate.

## Pergaminho do Capítulo

Neste capítulo, você aprendeu:

- Generics (`<T>`, `<T extends BaseType>`) permitem código reutilizável e tipado
- Sealed classes criam hierarquias fechadas e hierárquicas de eventos
- Pattern matching em Dart 3 (`switch` com destructuring e `when`) é limpo e expressivo
- `BarramentoEventos<T>` é um sistema de eventos tipado que notifica subscritos
- `ProcessadorEventos` renderiza eventos de forma humanizada com regras por tipo
- Integração: cada ação do jogo dispara um evento, criando um log narrativo

O sistema de eventos transforma um jogo silencioso em um que fala. Cada ação é registada, cada vitória é celebrada.

## Dica Profissional

::: dica
Eventos são a coluna vertebral de sistemas reativos. Quando adicionar uma nova feature (feitiço, item especial, achievement), não altere 50 funções; dispare um evento novo. Qualquer listener que se importe com esse evento vai reagir. Isto é desacoplamento: combate não sabe de UI, UI sente eventos. Mantém o código limpo e modular.
:::

## Próximo Capítulo

No Capítulo 25, vamos implementar progressão completa: um sistema de XP com fórmulas, níveis que desbloquem habilidades especiais, e visualização clara do progresso em tempo real.

***
