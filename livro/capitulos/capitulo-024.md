# Capítulo 24 - Generics e Pattern Matching: Sistema de Eventos

> *A economia gera ouro. A loja oferece itens. Você compra uma espada e... sente nada, sem feedback. Mas quando equipa essa espada, o seu ataque sobe. Quando bebe uma poção, o seu HP sobe. Quando level-up, ganha habilidades. Cada uma destas ações é um evento, um fato histórico que o jogo deveria registrar. Este capítulo transforma o silêncio em narrativa: um sistema de eventos tipado que registra, filtra e notifica em tempo real. Aqui aprenderá o poder dos generics e do pattern matching em Dart 3 para criar código limpo e expressivo.*

## O Que Vamos Aprender

Neste capítulo você vai:

- Entender *generics*: `List<T>`, `BarramentoEventos<T extends EventoJogo>`
- Criar uma hierarquia de *sealed classes* para eventos: `EventoCombate`, `EventoLoot`, `EventoMovimento`, `EventoNivel`
- Usar *pattern matching* em Dart 3: *switch expressions* com destructuring
- Implementar um `BarramentoEventos` genérico que filtra eventos por tipo
- Criar um log de eventos *rich*, com renderização diferenciada por tipo
- Integrar eventos no fluxo de jogo: cada ação dispara um evento
- Mostrar notificações em tempo real: *loot pickups*, *levelups*, combate
- Demonstrar *guard clauses* em pattern matching

Ao final, você terá um sistema de eventos tipado que torna o jogo mais narrativo e reativo.

## Generics: Uma Rápida Recordação

Você já conhece `List<T>`. *Generics* são a forma de Dart dizer: "esta estrutura pode guardar qualquer tipo, mas vou ser estrito sobre qual tipo é". É segurança de tipos em tempo de compilação. Sem generics, você teria listas sem tipo e teria que fazer *cast* (conversão) manual toda vez, arriscando erros em tempo de execução. Com generics, o compilador sabe exatamente o que você guardou e avisa se tenta usar errado.

```dart
List<int> numeros = [1, 2, 3];
List<String> nomes = ['Alice', 'Bob'];
// Isto não compila:
// numeros.add('texto'); // ← erro em tempo de compilação: esperava int
```

O `T` é um parâmetro de tipo. Significa: esta lista pode conter qualquer tipo, desde que todas as coisas nela sejam do mesmo tipo.

**Generics em classes customizadas:** Você pode criar suas próprias classes genéricas. Observe como `Caixa<T>` funciona para qualquer tipo:

```dart
class Caixa<T> {
  T? conteudo;

  void guardar(T item) {
    // ← T é substituído pelo tipo real quando você cria a Caixa
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

final caixaString = Caixa<String>();
caixaString.guardar('magia');
print(caixaString.remover()); // magia
```

**Saída esperada:**
```text
42
magia
```

Cada instância de `Caixa` é especializada para um tipo específico. Isto é o poder dos generics: código reutilizável mas type-safe.

## Hierarquia de Eventos com Sealed Classes

Eventos são dados imutáveis que representam algo que aconteceu no jogo. Cada evento é um snapshot de um momento: "você atacou", "coletou item", "subiu de nível". Eventos são *sealed classes* — uma hierarquia fechada onde apenas certos tipos podem existir. Isto garante que quando você processa eventos em um switch, o compilador pode certificar que cobriu **todos** os casos possíveis. Sem sealed classes, seria fácil esquecer um tipo de evento e ter comportamento não esperado.

**Por que eventos imutáveis?** Uma vez criado um evento, ele representa um fato histórico que não muda. Se você lança `EventoLoot(quantidade: 5)` e depois muda para `3`, você falsificou a história. Imutabilidade força clareza: para mudar o comportamento futuro, lance um novo evento, não modifique o antigo.

```dart
// lib/evento_jogo.dart

// ← sealed class: apenas as subclasses neste
// arquivo podem herdar EventoJogo
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
/// Nota: usa *records* de Dart 3 para pares de coordenadas.
class EventoMovimento extends EventoJogo {
  // ← Tupla nomeada: (int x, int y) é imutável e anônima
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

**Por que este padrão?** Sem eventos, cada ação (ataque, loot, movimento) teria que informar manualmente à UI, ao log, ao sistema de achievements, etc. Código cada vez mais acoplado. Com eventos, há um canal central: tudo que importa dispara um evento, qualquer coisa interessada subscreve. Adicionar nova feature (áudio, efeitos, achievements) é trivial: cria um novo listener, subscreve ao evento relevante, pronto. Nada no código de combate muda.

```dart
// lib/barramento_eventos.dart

/// Sistema de eventos genérico e tipado
/// T deve ser EventoJogo ou subclasse para garantir compatibilidade
class BarramentoEventos<T extends EventoJogo> {
  final List<T> eventos = [];
  // ← Callbacks: funções que reagem quando um evento é disparado
  final List<void Function(T)> _listeners = [];

  /// Dispara um evento e notifica todos os listeners
  void dispara(T evento) {
    eventos.add(evento);
    // ← Itera listeners e chama cada um; qualquer pode reagir
    for (final listener in _listeners) {
      listener(evento);
    }
  }

  /// Subscreve a este barramento: ao disparar, seu callback é chamado
  void subscreve(void Function(T) callback) {
    _listeners.add(callback);
  }

  /// Remove um callback da lista de listeners
  void desinscreve(void Function(T) callback) {
    _listeners.remove(callback);
  }

  /// Filtra eventos por tipo: retorna só EventoLoot, por ex.
  /// Útil para gerar relatórios: "quantos loots coletei?"
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

O *pattern matching* permite desconstructir dados de forma clara e expressar lógica condicional de forma muito mais legível do que if/else aninhados. Dart 3 introduziu *switch expressions* (não apenas statements): em vez de `if (evento is EventoCombate) { ... }`, você escreve um `switch` que desconstructura e filtra simultaneamente. É como decomposição estrutural: "este dado tem essa forma? Se sim, extraia seus campos e processe."

**Antes (if/else aninhado):**
```dart
if (evento is EventoCombate) {
  final dano = evento.dano;
  if (dano > 50) {
    print('[CRÍTICO] Dano muito alto: $dano');
  } else {
    print('Dano normal: $dano');
  }
}
```

**Depois (pattern matching):**
```dart
// ← Muito mais conciso e legível
final mensagem = switch (evento) {
  EventoCombate(:final dano) when dano > 50 => '[CRÍTICO] Dano: $dano',
  EventoCombate(:final dano) => 'Dano: $dano',
  _ => 'Outro tipo de evento',
};
```

Aqui está o power:

```dart
// lib/processador_eventos.dart

class ProcessadorEventos {
  // ← switch expression: retorna um valor (String)
  static String renderizar(EventoJogo evento) {
    return switch (evento) {
      // ← Extrai campos com (:final dano)
      // ← when clause: condição extra; só aplica se dano > 50
      EventoCombate(:final mensagem, :final dano) when dano > 50 =>
        '[CRÍTICO] $mensagem (dano: $dano)',

      // ← Mesmo tipo, mas sem guard clause: todos
      // os combates com dano <= 50
      EventoCombate(:final mensagem, :final dano) =>
        '> $mensagem (dano: $dano)',

      // ← Extrai nomeItem e quantidade; mostra
      // plural se quantidade > 1
      EventoLoot(:final nomeItem, :final quantidade)
          when quantidade > 1 =>
        '+ $quantidade x $nomeItem',

      EventoLoot(:final nomeItem, :final quantidade) =>
        '+ $nomeItem',

      // ← Extrai tupla de coordenadas e acessa campos ($1 = x, $2 = y)
      EventoMovimento(:final de, :final para) =>
        '> Movimento: (${de.$1},${de.$2}) → (${para.$1},${para.$2})',

      EventoNivel(:final nivelNovo, :final bonus) =>
        'LEVEL UP! Nível $nivelNovo! +$bonus',

      // ← Fallback: qualquer outro tipo de evento
      _ => '? Evento desconhecido',
    };
  }

  // ← switch statement: executa código, não retorna valor
  static void processar(EventoJogo evento) {
    switch (evento) {
      // ← (:final atacante?) = atacante é opcional (pode ser null)
      case EventoCombate(:final dano, :final atacante?) when dano > 0:
        print('> $atacante causou $dano dano!');

      // ← dano < 0 significa você sofreu dano (negativo)
      case EventoCombate(:final dano) when dano < 0:
        print('! Recebeu ${dano.abs()} de dano!');

      case EventoLoot(:final itemId, :final quantidade):
        print('+ Adquiriu: $itemId x$quantidade');

      case EventoNivel(:final nivelAnterior, :final nivelNovo):
        print('* Subiu de nível $nivelAnterior → $nivelNovo!');

      // ← Matches mas não usa nada; break é suficiente
      case EventoMovimento():
        break;

      case _:
        break;
    }
  }
}
```

**Saída esperada (após disparar eventos):**
```text
[CRÍTICO] Dragão ataca! (dano: 75)
+ 3 x Moeda de Ouro
+ Poção de Mana
LEVEL UP! Nível 5! +5 HP, +2 ATK
```

**Símbolos descodificados:**

- `(:final dano)` desconstructures o campo `dano` de `EventoCombate`
- `when dano > 50` é uma *guard clause*: a correspondência só aplica se verdadeira
- `(:final atacante?)` significa "pode ser null"; o `?` o marca como opcional
- `_` é *match-all*: qualquer coisa; usado para fallback
- `$1` e `$2` acessam campos de um *record* (tupla): primeiro e segundo elementos
- `switch (x)` pode ser expressão (`=> valor`) ou statement (`{ código }`)

## Integrando Eventos no Jogo

Cada ação dispara um evento. Quando você se move, um `EventoMovimento` é disparado. Quando coleta item, um `EventoLoot`. Quando sofre dano, um `EventoCombate`. Cada evento é registado no barramento, listeners recebem notificação, renderizam mensagem na tela.

Observe como isso desacopla completamente o código: a classe que gerencia movimento não precisa saber nada sobre renderização. Ela apenas dispara o evento. Qualquer coisa interessada em movimento subscreve ao barramento e reage. Isto permite:

1. **Múltiplos listeners**: UI, log, áudio, achievements — todos reagem ao mesmo evento
2. **Fácil adicionar features**: novo sistema de achievements? Subscreve ao barramento, pronto
3. **Testabilidade**: você pode testar o comportamento sem UI, disparando eventos diretamente
4. **Auditoria**: o histórico de eventos é uma log completa do que aconteceu

```dart
// lib/dungeon_com_eventos.dart

/// Gerenciador do dungeon que dispara eventos para tudo que acontece
class DungeonComEventos {
  late BarramentoEventos<EventoJogo> eventoBus;
  late Jogador jogador;
  late MapaMasmorra mapa;

  DungeonComEventos() {
    eventoBus = BarramentoEventos<EventoJogo>();
    // ← Subscreve ao barramento: toda vez que algo é disparado,
    //   ProcessadorEventos.renderizar() é chamado
    eventoBus.subscreve((evento) {
      print(ProcessadorEventos.renderizar(evento));
    });
  }

  /// Movimento dispara evento com origem e destino (para replay/undo)
  void moverJogador(int dx, int dy) {
    final xAnterior = jogador.x;
    final yAnterior = jogador.y;

    jogador.x += dx;
    jogador.y += dy;

    // ← Cria um record (tupla) com as coordenadas
    eventoBus.dispara(EventoMovimento(
      de: (xAnterior, yAnterior),
      para: (jogador.x, jogador.y),
    ));
  }

  /// Ganhar item dispara evento de loot com fonte
  void ganharItem(String itemId, String nomeItem, int quantidade) {
    jogador.adicionarItem(itemId);

    // ← Registra a fonte do item (chão, inimigo, loja, etc.)
    eventoBus.dispara(EventoLoot(
      itemId: itemId,
      nomeItem: nomeItem,
      quantidade: quantidade,
      fonte: 'chão',
    ));
  }

  /// Sofrer dano dispara combate (dano negativo = você recebeu dano)
  void sofrerDano(int dano) {
    jogador.hp -= dano;

    // ← dano é negativo aqui; ProcessadorEventos
    // interpreta como sofrimento
    eventoBus.dispara(EventoCombate(
      mensagem: 'Sofreste dano!',
      dano: -dano,
      alvo: 'Jogador',
    ));
  }

  /// Level up dispara evento com bônus
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

**Saída esperada (sequência típica):**
```text
> Movimento: (5,3) → (6,3)
+ Poção de Mana
> Dragão causou 15 dano!
! Recebeu 15 de dano!
* Subiu de nível 3 → 4!
```

## Antes vs. Depois: Arquitetura de Eventos

### Antes: Acoplamento Direto

```dart
// Combate conhece tudo; tudo está entrosado
class Combate {
  void atacar(Inimigo inimigo) {
    int dano = calcularDano(heroi.arma, inimigo.defesa);
    inimigo.hp -= dano;

    // UI deve saber como renderizar
    ui.mostrarDano(dano);

    // Log deve saber como registrar
    log.adicionarLinha('Ataque causou $dano');

    // Sistema de sons deve saber
    audio.tocarSomCombate(dano);

    // Se adicionar achievements, muda tudo aqui
    if (dano > 50) achievements.unlock('CRITICO');
  }
}
```

**Problema:** Combate conhece UI, Log, Áudio, Achievements. Adicionar novidade quebra tudo.

### Depois: Desacoplamento com Eventos

```dart
// Combate é puro
class Combate {
  final BarramentoEventos eventoBus;

  void atacar(Inimigo inimigo) {
    int dano = calcularDano(heroi.arma, inimigo.defesa);
    inimigo.hp -= dano;

    // Dispara evento; ninguém especifico é chamado
    eventoBus.dispara(EventoCombate(
      mensagem: 'Ataque!',
      dano: dano,
    ));
  }
}

// UI subscreve
eventoBus.subscreve((evento) {
  if (evento is EventoCombate) {
    ui.mostrarDano(evento.dano);
  }
});

// Log subscreve
eventoBus.subscreve((evento) {
  log.adicionarLinha(evento.toString());
});

// Áudio subscreve
eventoBus.subscreve((evento) {
  if (evento is EventoCombate) {
    audio.tocarSomCombate(evento.dano);
  }
});

// Achievements subscreve
eventoBus.subscreve((evento) {
  if (evento is EventoCombate && evento.dano > 50) {
    achievements.unlock('CRITICO');
  }
});
```

**Ganho:** Combate não muda. Cada sistema subscreve independentemente. Adicionar nova feature é adicionar um novo listener — zero modificação do código existente.

## Por Que Não Apenas Callbacks Simples?

Você pode pensar: "Por que não apenas passar um callback para Combate.atacar()?" Resposta: porque então Combate precisa conhecer **todos** os callbacks. Se temos UI, Log, Áudio, Achievements, Combate.atacar() teria 4+ parâmetros de callback. Cada novo sistema adiciona um parâmetro. Isto é **hell de parâmetros**.

Com eventos, há um único canal central. Qualquer coisa que queira reagir subscreve uma vez. Combate nunca muda sua assinatura. Isto é escalável: 5 sistemas, 5 listeners independentes. Mil sistemas? Mil listeners independentes. Combate não sabe disso tudo.

Além disso, eventos são **históricos**: você pode guardar uma lista completa de tudo que aconteceu (para replay, debug, análise). Com callbacks, é fugace: reage e esquece.

## Desafios da Masmorra

**Desafio 24.1. Quando o Guerreiro Muda de Arma.** Seu guerreiro equipa uma Espada Lendária, depois a desequipa para voltar ao escudo. Cada mudança conta. Crie `EventoEquipamento extends EventoJogo` com `itemId`, `nomeItem`, `equipado` (bool). Dispare esse evento toda vez que equipar/desequipar. Teste: equipe e desequipe 3 vezes, veja se 6 eventos foram registrados. Dica: sealed class mantém a tipagem segura.

**Desafio 24.2. Narrativa do Equipamento.** O log de ações deve refletir sua jornada de equipamento. Adicione um case em `ProcessadorEventos.renderizar()`: se `EventoEquipamento` com `equipado=true`, exiba em verde `[EQUIP] Equipaste: Espada Lendária`. Se `equipado=false`, em vermelho `[DESQUIP] Desequipaste:...`. Execute uma sequência de mudanças, o log deve contar a história. Dica: use padrão com guard: `equipado when equipado == true`.

**Desafio 24.3. Combate Violento.** Nem todo dano é importante. Filtre eventos de combate: retorne só `EventoCombate` com `dano > 20` (golpes críticos e devastadores). Itere e exiba: "Crítico! Dano: 35". Teste: em 100 turnos de combate, quantos golpes foram >= 20 dano? Você vai notar que a maioria é fraca e apenas alguns são épicos. Dica: combine `whereType<EventoCombate>()` com `.where()`.

**Desafio 24.4. Resumo da Partida.** Ao fim do jogo, você quer saber: Quantas vezes equipou itens? Quantas vezes sofreu dano? Quantas compras na loja? Implemente `contagemPorTipo()` que retorna um mapa: `{'EventoCombate': 145, 'EventoEquipamento': 8, 'EventoCompra': 3}`. Use pattern matching no switch para cada tipo. Execute uma partida e veja o resumo final. Dica: isto é análise agregada.

**Desafio 24.5. (Desafio): Assista a Sua Epopeia.** Você quer mostrar a um amigo o que aconteceu na masmorra. Implemente `EventReplay` que armazena eventos e tem método `async tocar()`: exibe cada evento com 500ms entre eles. Use `Future.delayed(Duration(milliseconds: 500))`. Assim, narrativa toda se desenrola visualmente. Teste: grave 50 eventos, toque e veja cada um aparecer sequencialmente. Você consegue acompanhar a história? Dica: `await` faz o programa esperar sem travar.

**Boss Final 24.6. Combate Recente.** Você quer saber: Nos últimos 5 minutos de jogo, qual foi o dano total sofrido? Implemente um método que retorna eventos de combate ocorridos nos últimos N minutos. Use `DateTime.now()` e `evento.timestamp.difference(DateTime.now()).inMinutes < N`. Some o dano. Teste: após 10 minutos de jogo, pergunte dano dos últimos 3 minutos vs últimos 10. Dica: Delta de tempo revela ritmo de combate.

## Pergaminho do Capítulo

Neste capítulo, você aprendeu:

- *Generics* (`<T>`, `<T extends BaseType>`) permitem código reutilizável e *type-safe*
- *Sealed classes* criam hierarquias fechadas e seguras de eventos
- *Pattern matching* em Dart 3 (`switch` com destructuring e `when`) é limpo e expressivo
- `BarramentoEventos<T>` é um sistema de eventos tipado que notifica subscritos (padrão *Observer*)
- `ProcessadorEventos` renderiza eventos de forma humanizada com regras por tipo
- Integração: cada ação do jogo dispara um evento, criando um log narrativo
- Desacoplamento: nenhum sistema precisa conhecer os outros; todos reagem a eventos

O sistema de eventos transforma um jogo silencioso em um que fala. Cada ação é registada, cada vitória é celebrada. A arquitetura fica limpa: adicionar novidades é subscrever um novo listener, não modificar código existente.

::: nota
**Código Completo no Step**

O diretório `code/steps/step-24/` contém a classe `DungeonComEventos`, que integra todos os componentes de eventos ensinados neste capítulo. `DungeonComEventos` é o maestro que orquestra movimento, coleta de itens, dano e subidas de nível — cada ação dispara eventos apropriados no `BarramentoEventos`. É aqui que você vê sealed classes, generics e pattern matching trabalhando juntos para criar uma arquitetura reactiva, limpa e extensível. Consulte o step para ver como a integração entre `ProcessadorEventos`, listeners e o gerenciador central funciona em contexto real.
:::

## Dica Profissional

::: dica
Eventos são a coluna vertebral de sistemas reativos. Quando adicionar uma nova feature (feitiço, item especial, achievement), não altere 50 funções; dispare um evento novo. Qualquer listener que se importe com esse evento vai reagir. Isto é desacoplamento: combate não sabe de UI, UI sente eventos. Mantém o código limpo e modular.
:::

## Próximo Capítulo

No Capítulo 25, vamos implementar progressão completa: um sistema de XP com fórmulas, níveis que desbloquem habilidades especiais, e visualização clara do progresso em tempo real.

***
