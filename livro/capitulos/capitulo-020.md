# Capítulo 20 - Entidades no Mapa: Inimigos, Itens, Escadas

> *Até agora, o mapa era um pano vazio de azulejos. Mas uma masmorra viva está viva porque tem coisas: um goblin à espreita numa esquina, uma poção perdida no chão, uma escada descendente. Sem entidades, não há jogo. Apenas tiles. Agora aprenderá a colocar "coisas" em pontos específicos do mapa e a decidir o que acontece quando o jogador as toca.*


## O Que Vamos Aprender

Neste capítulo você vai:

- Criar a classe abstrata Entidade . o contrato para "qualquer coisa no mapa"
- Implementar EntidadeInimigo, EntidadeItem, EntidadeEscada
- Preencher o mapa com listas de entidades após geração
- Detectar colisões quando o jogador se move para uma entidade
- Renderizar entidades apenas quando visíveis (FOV)
- Remover entidades quando são "usadas" (inimigo morre, item apanhado)
- Implementar **pathfinding** para movimento inteligente de inimigos (incluindo **A*** para otimização)
- Criar um modelo de entidades por andar (progressão de dificuldade)

Ao final, você terá um mapa dinâmico com inimigos, itens e escadas.


## Parte 1: O Conceito de Entidade

Uma masmorra viva tem muitas coisas: o jogador, inimigos que atacam, itens valiosos, escadas para descer. São entidades, e todas compartilham propriedades: posição (x, y), símbolo visual para renderizar, nome descritivo. Mas cada uma reage diferente quando tocada. Um inimigo ativa combate. Um item vai para seu inventário. Uma escada muda de andar.

A classe abstrata `Entidade` é o contrato que diz: qualquer coisa no mapa precisa ter coordenadas, símbolo e nome. Subclasses (inimigo, item, escada) implementam o método `aoTocada()` diferente. Quando o jogador anda para cima de uma entidade, a entidade reage de forma apropriada.

```dart
// entidade.dart

abstract class Entidade {
  int x;
  int y;
  final String simbolo;
  final String nome;

  Entidade({
    required this.x,
    required this.y,
    required this.simbolo,
    required this.nome,
  });

  bool aoTocada(Jogador jogador);

  @override
  String toString() => '$nome ($simbolo) em ($x, $y)';
}
```


## Parte 2: As Três Entidades Concretas

Agora você implementa as três versões principais. `EntidadeInimigo` envolve um `Inimigo` (que será gerado e lutará contra você). `EntidadeItem` contém um item que você pode apanhar (entra no inventário). `EntidadeEscada` é o portal para o próximo andar.

Cada uma responde de forma diferente ao método `aoTocada()`: um inimigo não faz nada especial (combate é tratado separadamente), um item é adicionado ao seu inventário e marcado para remoção, uma escada desencadeia a transição de andar.

```dart
// entidade_inimigo.dart

class EntidadeInimigo extends Entidade {
  final Inimigo inimigo;

  EntidadeInimigo({
    required int x,
    required int y,
    required this.inimigo,
  }) : super(
    x: x,
    y: y,
    simbolo: inimigo.simbolo,
    nome: inimigo.nome,
  );

  @override
  bool aoTocada(Jogador jogador) {
    return false; // Combate tratado separadamente
  }
}

// entidade_item.dart

class EntidadeItem extends Entidade {
  final Item item;

  EntidadeItem({
    required int x,
    required int y,
    required this.item,
  }) : super(
    x: x,
    y: y,
    simbolo: '!',
    nome: item.nome,
  );

  @override
  bool aoTocada(Jogador jogador) {
    jogador.inventario.add(item);
    return true; // Remover do mapa
  }
}

// entidade_escada.dart

class EntidadeEscada extends Entidade {
  final int andarAtual;

  EntidadeEscada({
    required int x,
    required int y,
    required this.andarAtual,
  }) : super(
    x: x,
    y: y,
    simbolo: '>',
    nome: 'Escada Descendente',
  );

  @override
  bool aoTocada(Jogador jogador) {
    return false; // Descida tratada separadamente
  }
}
```

> **Importante:** A classe `Jogador` deve ter um campo `inventario` declarado como `List<Item> inventario = [];` para permitir que `EntidadeItem.aoTocada()` adicione itens coletados. Este campo é definido na classe Jogador conforme demonstrado neste capítulo.


## Parte 3: Spawning de Entidades

"Spawn" significa "gerar" ou "aparecer". Depois que a masmorra é gerada, você precisa preenchê-la com inimigos, itens e escada. A classe `GeradorEntidades` faz exatamente isto: calcula quantos inimigos aparecem (escalado por andar), coloca itens em posições válidas (piso sólido, não parede), e garante sempre uma escada para descida.

Note que cada entidade precisa de uma posição única (não sobrepostas). Usamos um set `posicoesPrecupadas` para rastrear onde já colocamos coisas. Se não encontrar espaço após 50 tentativas aleatórias, desistimos (é ok, às vezes um item não consegue aparecer em um andar apertado).

```dart
// entity_spawner.dart

class GeradorEntidades {
  final MapaMasmorra mapa;
  final int andarAtual;
  final Random random;
  final Set<Point<int>> posicoesPrecupadas = {};

  GeradorEntidades({
    required this.mapa,
    required this.andarAtual,
    required this.random,
  });

  List<Entidade> spawn() {
    final entidades = <Entidade>[];
    posicoesPrecupadas.clear();

    entidades.addAll(_spawnInimigos());
    entidades.addAll(_spawnItens());
    entidades.addAll(_spawnEscada());

    return entidades;
  }

  List<Entidade> _spawnInimigos() {
    final inimigos = <Entidade>[];
    final quantidade = 2 + (andarAtual ~/ 2) + random.nextInt(2);

    for (int i = 0; i < quantidade; i++) {
      final pos = _encontrarPosicaoValida();
      if (pos != null) {
        final tipo = _escolherTipoInimigo();
        inimigos.add(EntidadeInimigo(
          x: pos.x,
          y: pos.y,
          inimigo: _criarInimigo(tipo),
        ));
        posicoesPrecupadas.add(pos);
      }
    }

    return inimigos;
  }

  List<Entidade> _spawnItens() {
    final itens = <Entidade>[];
    final quantidade = 2 + random.nextInt(3);

    for (int i = 0; i < quantidade; i++) {
      final pos = _encontrarPosicaoValida();
      if (pos != null) {
        itens.add(EntidadeItem(
          x: pos.x,
          y: pos.y,
          item: Item(
            nome: ['Ouro', 'Poção', 'Gema'][random.nextInt(3)],
          ),
        ));
        posicoesPrecupadas.add(pos);
      }
    }

    return itens;
  }

  List<Entidade> _spawnEscada() {
    final pos = _encontrarPosicaoValida();
    if (pos != null) {
      return [EntidadeEscada(x: pos.x, y: pos.y, andarAtual: andarAtual)];
    }
    return [];
  }

  Point<int>? _encontrarPosicaoValida() {
    for (int tentativa = 0; tentativa < 50; tentativa++) {
      final x = random.nextInt(mapa.largura);
      final y = random.nextInt(mapa.altura);
      final pos = Point(x, y);

      if (mapa.ehPassavel(x, y) && !posicoesPrecupadas.contains(pos)) {
        return pos;
      }
    }
    return null;
  }

  String _escolherTipoInimigo() {
    final tipos = ['Zumbi', 'Lobo', 'Orc'];
    return tipos[random.nextInt(tipos.length)];
  }

  Inimigo _criarInimigo(String tipo) {
    return switch (tipo) {
      'Zumbi' => Inimigo(nome: 'Zumbi', hpMax: 20, simbolo: 'Z'),
      'Lobo' => Inimigo(nome: 'Lobo', hpMax: 40, simbolo: 'L'),
      'Orc' => Inimigo(nome: 'Orc', hpMax: 60, simbolo: 'O'),
      _ => Inimigo(nome: 'Monstro', hpMax: 25, simbolo: '?'),
    };
  }
}
```

### Spawning Inteligente com Distância

Em vez de colocar entidades completamente ao acaso, você pode ser mais inteligente: inimigos longe da entrada, itens distribuídos por salas, escada no fim. Use distância Manhattan:

```dart
// entity_spawner_avancado.dart

class GeradorEntidadesAvancado {
  final MapaMasmorra mapa;
  final List<Sala> salas;
  final int andarAtual;
  final Random random;

  GeradorEntidadesAvancado({
    required this.mapa,
    required this.salas,
    required this.andarAtual,
    required this.random,
  });

  List<Entidade> spawnInteligente() {
    final entidades = <Entidade>[];

    // Entrada assume-se no centro
    final posEntrada = Point(mapa.largura ~/ 2, mapa.altura ~/ 2);

    // Inimigos: longe da entrada (min 15 tiles)
    entidades.addAll(_spawnInimigosLonge(posEntrada));

    // Itens: distribuídos por diferentes salas
    entidades.addAll(_spawnItensEmSalas());

    // Escada: bem longe, usualmente no canto oposto
    entidades.add(_spawnEscadaLonge(posEntrada));

    return entidades;
  }

  List<Entidade> _spawnInimigosLonge(Point<int> entrada) {
    final inimigos = <Entidade>[];
    final quantidade = 2 + (andarAtual ~/ 2) + random.nextInt(2);

    for (int i = 0; i < quantidade; i++) {
      Point<int>? pos;

      for (int tentativa = 0; tentativa < 30; tentativa++) {
        final x = random.nextInt(mapa.largura);
        final y = random.nextInt(mapa.altura);
        final cand = Point(x, y);

        if (mapa.ehPassavel(x, y)) {
          final dist = _distanciaManhattan(entrada, cand);
          if (dist > 15) {
            pos = cand;
            break;
          }
        }
      }

      if (pos != null) {
        final tipo = _escolherTipoInimigo();
        inimigos.add(EntidadeInimigo(
          x: pos.x,
          y: pos.y,
          inimigo: _criarInimigo(tipo),
        ));
      }
    }

    return inimigos;
  }

  List<Entidade> _spawnItensEmSalas() {
    final itens = <Entidade>[];

    for (int i = 0; i < 2 + random.nextInt(2); i++) {
      if (salas.isEmpty) break;

      final sala = salas[random.nextInt(salas.length)];
      final x = sala.x + 1 + random.nextInt((sala.largura - 2).clamp(1, 100));
      final y = sala.y + 1 + random.nextInt((sala.altura - 2).clamp(1, 100));

      if (mapa.ehPassavel(x, y)) {
        itens.add(EntidadeItem(
          x: x,
          y: y,
          item: Item(
            nome: ['Ouro', 'Poção', 'Gema'][random.nextInt(3)],
          ),
        ));
      }
    }

    return itens;
  }

  EntidadeEscada _spawnEscadaLonge(Point<int> entrada) {
    Point<int>? melhorPos;
    double maiorDist = 0;

    for (int tentativa = 0; tentativa < 100; tentativa++) {
      final x = random.nextInt(mapa.largura);
      final y = random.nextInt(mapa.altura);

      if (mapa.ehPassavel(x, y)) {
        final dist = _distanciaManhattan(entrada, Point(x, y)).toDouble();
        if (dist > maiorDist) {
          maiorDist = dist;
          melhorPos = Point(x, y);
        }
      }
    }

    melhorPos ??= Point(mapa.largura - 5, mapa.altura - 5);

    return EntidadeEscada(
      x: melhorPos.x,
      y: melhorPos.y,
      andarAtual: andarAtual,
    );
  }

  int _distanciaManhattan(Point<int> a, Point<int> b) {
    return (a.x - b.x).abs() + (a.y - b.y).abs();
  }

  String _escolherTipoInimigo() {
    final tipos = ['Zumbi', 'Lobo', 'Orc'];
    return tipos[random.nextInt(tipos.length)];
  }

  Inimigo _criarInimigo(String tipo) {
    return switch (tipo) {
      'Zumbi' => Inimigo(nome: 'Zumbi', hpMax: 20, simbolo: 'Z'),
      'Lobo' => Inimigo(nome: 'Lobo', hpMax: 40, simbolo: 'L'),
      'Orc' => Inimigo(nome: 'Orc', hpMax: 60, simbolo: 'O'),
      _ => Inimigo(nome: 'Monstro', hpMax: 25, simbolo: '?'),
    };
  }
}
```
```


## Parte 4: Detecção de **Colisão** e Interação

Quando o jogador tenta se mover para uma posição, você precisa checar se há uma entidade lá. Se houver, trata a **colisão**. A interface define o contrato; subclasses definem comportamentos específicos:

```dart
// colisao_detector.dart

class DetectorColisao {
  /// Tenta mover o jogador para (novoX, novoY)
  /// Retorna ResultadoMovimento com tipo de colisão (se houver)
  ResultadoMovimento verificarMovimento(
    int novoX,
    int novoY,
    Jogador jogador,
    AndarMasmorra andar,
  ) {
    // 1. Checa se é passável (não é parede)
    if (!andar.mapa.ehPassavel(novoX, novoY)) {
      return ResultadoMovimento.colisaoParede();
    }

    // 2. Checa se há entidade naquela posição
    final entidade = andar.encontrarEntidadeEm(novoX, novoY);

    if (entidade == null) {
      // Sem colisão: movimento livre
      return ResultadoMovimento.sucesso(novoX, novoY);
    }

    // 3. Processa tipo de colisão
    return switch (entidade) {
      EntidadeInimigo enemyEnt =>
        ResultadoMovimento.colisaoInimigo(enemyEnt.inimigo),
      EntidadeItem itemEnt =>
        ResultadoMovimento.colisaoItem(itemEnt.item, entidade),
      EntidadeEscada escadaEnt =>
        ResultadoMovimento.colisaoEscada(escadaEnt),
      _ => ResultadoMovimento.colisaoDesconhecida(),
    };
  }
}

enum TipoColisao {
  nenhuma,
  parede,
  inimigo,
  item,
  escada,
  outro,
}

class ResultadoMovimento {
  final bool podeMovimentar;
  final TipoColisao tipo;
  final int? novoX;
  final int? novoY;
  final dynamic alvo; // Inimigo, Item, Escada, etc

  ResultadoMovimento._({
    required this.podeMovimentar,
    required this.tipo,
    this.novoX,
    this.novoY,
    this.alvo,
  });

  factory ResultadoMovimento.sucesso(int x, int y) => ResultadoMovimento._(
    podeMovimentar: true,
    tipo: TipoColisao.nenhuma,
    novoX: x,
    novoY: y,
  );

  factory ResultadoMovimento.colisaoParede() => ResultadoMovimento._(
    podeMovimentar: false,
    tipo: TipoColisao.parede,
  );

  factory ResultadoMovimento.colisaoInimigo(Inimigo inimigo) =>
    ResultadoMovimento._(
      podeMovimentar: false,
      tipo: TipoColisao.inimigo,
      alvo: inimigo,
    );

  factory ResultadoMovimento.colisaoItem(Item item, Entidade entidade) =>
    ResultadoMovimento._(
      podeMovimentar: false,
      tipo: TipoColisao.item,
      alvo: entidade,
    );

  factory ResultadoMovimento.colisaoEscada(EntidadeEscada escada) =>
    ResultadoMovimento._(
      podeMovimentar: false,
      tipo: TipoColisao.escada,
      alvo: escada,
    );

  factory ResultadoMovimento.colisaoDesconhecida() => ResultadoMovimento._(
    podeMovimentar: false,
    tipo: TipoColisao.outro,
  );
}
```

### Processador de Interações

Depois de detectar colisão, você precisa processar a interação específica:

```dart
// interacao_processador.dart

class ProcessadorInteracao {
  void processarColisao(
    ResultadoMovimento resultado,
    Jogador jogador,
    AndarMasmorra andar,
    void Function(String) logCallback,
  ) {
    switch (resultado.tipo) {
      case TipoColisao.nenhuma:
        // Sem ação
        break;

      case TipoColisao.parede:
        logCallback('Você bateu numa parede!');
        break;

      case TipoColisao.inimigo:
        final inimigo = resultado.alvo as Inimigo;
        logCallback('Você encontrou um ${inimigo.nome}! Luta!');
        // Combate será tratado separadamente
        break;

      case TipoColisao.item:
        final entidade = resultado.alvo as Entidade;
        final foiColetado = entidade.aoTocada(jogador);
        if (foiColetado) {
          logCallback('Você coletou ${entidade.nome}!');
          andar.removerEntidade(entidade);
        }
        break;

      case TipoColisao.escada:
        logCallback('Você encontrou a escada! Digite "d" para descer.');
        break;

      case TipoColisao.outro:
        logCallback('Algo estranho aqui...');
        break;
    }
  }
}
```

## Parte 5: AndarMasmorra . Encapsulando Tudo

Um andar é mais que um mapa: é o mapa MAIS as entidades nele. A classe `AndarMasmorra` agrupa mapa, lista de entidades e número do andar. Oferece serviços úteis: encontrar uma entidade em (x, y), remover uma entidade (quando morre ou é coletada), e filtrar entidades por tipo.

Este é um padrão importante: composição. Uma classe não herda, mas contém outras. Um `AndarMasmorra` não é um `Mapa`, mas tem um `Mapa`. Isto é mais flexível que herança.

```dart
// andar_masmorra.dart

class AndarMasmorra {
  final int numero;
  final MapaMasmorra mapa;
  final List<Entidade> entidades;

  AndarMasmorra({
    required this.numero,
    required this.mapa,
    required this.entidades,
  });

  Entidade? encontrarEntidadeEm(int x, int y) {
    try {
      return entidades.firstWhere((e) => e.x == x && e.y == y);
    } catch (e) {
      return null;
    }
  }

  void removerEntidade(Entidade entidade) {
    entidades.remove(entidade);
  }

  /// Retorna todas as entidades de um tipo específico
  List<T> entidadesDoTipo<T extends Entidade>() {
    return entidades.whereType<T>().toList();
  }

  /// Conta quantos inimigos ainda existem neste andar
  int contarInimigos() {
    return entidadesDoTipo<EntidadeInimigo>().length;
  }
}
```
```

## Pergaminho do Capítulo

Neste capítulo você trouxe a masmorra à vida através de entidades — objetos que ocupam espaço no mapa e reagem quando tocados. Criou uma classe abstrata `Entidade` como contrato que garante toda coisa tem posição (x, y), símbolo visual e nome, além de um método abstrato `aoTocada()` que define comportamento ao ser colidida. Implementou três subclasses concretas: `EntidadeInimigo` que envolve um combatente, `EntidadeItem` que pode ser coletada para inventário (e marcada para remoção), e `EntidadeEscada` que permite descida para o próximo andar. Criou o `GeradorEntidades`, um spawner básico que popula masmorras com inimigos escalados por dificuldade de andar, itens valiosos, e escada garantida, respeitando posições válidas (piso). Aprendeu a versão inteligente `GeradorEntidadesAvancado` que usa distância Manhattan para posicionar inimigos longe da entrada (realismo), itens espalhados por salas diferentes (exploração), e escada bem distante (progressão). Implementou `DetectorColisao` que checa movimentos do jogador contra paredes e entidades, retornando `ResultadoMovimento` com tipo específico de colisão. Criou `ProcessadorInteracao` para lidar com cada tipo de colisão diferentemente: paredes bloqueiam, itens são coletados, inimigos disparam combate, escadas permitem descida. Finalmente, agrupou tudo na classe `AndarMasmorra`, que encapsula mapa + entidades + número, oferecendo métodos para encontrar, remover e filtrar entidades — um exemplo puro do padrão composição. O resultado é um mundo vivo onde colisões significam algo, e o jogador verdadeiramente interage com coisas reais.

::: dica
**Dica do Mestre:** Em engines profissionais como libGDX ou Godot, entidades são frequentemente atores/nós que herdam de uma classe mãe cena e possuem componentes (física, renderização, IA). O padrão entity-component-system (ECS) é ainda mais escalável — uma entidade é apenas um ID, dados são armazenados em tabelas. Para roguelikes, composição simples (como feito aqui) é suficiente até milhares de entidades. Sempre marque entidades como "persistentes" em andar anterior vs "geradas" em novo andar — alguns roguelikes mantêm andar anterior "vivo" para você voltar. Considere usar objeto Pool para reusar instâncias de entidades em vez de criar/destruir constantemente.
:::

## Desafios da Masmorra

**Desafio 20.1. Armadilha (Entidade customizada).** Crie `EntidadeArmadilha`: ao ser tocada, aplica dano ao jogador (5 HP) e dispara mensagem. O símbolo é `^`. Retorna `false` de `aoTocada()`, permanecendo no mapa. Adicione com 20% de chance em cada sala. Dica: passe jogador como parâmetro, aplique dano via `jogador.sofrerDano(5)`.

**Desafio 20.2. Tipos de Item.** Estenda Item com propriedades: crie enum `TipoItem` com valores OURO, POCAO_VIDA, POCAO_MANA, GEMA, CHAVE. Cada tipo tem efeito único ao ser coletado. POCAO_VIDA restaura 25 HP, GEMA aumenta ouro, CHAVE abre portas. Implemente efeito em `aoTocada()`.

**Desafio 20.3. Inimigos por dificuldade.** Estenda `GeradorEntidades` para aceitar `int andar`. Conforme o andar aumenta, inimigos ficam mais fortes (HP += andar * 2), mais raros e variados. Andar 5+: aparece um Orc. Andar 10+: Dragão. Use `random.nextInt(andar)` para verificar se spawna inimigo raro.

**Desafio 20.4. Colisão com eventos.** Integre entidades com movimento: ao jogador tentar se mover, chame `mapa.entidadeEm(x, y)`. Se houver, chame `aoTocada(jogador)`. Implemente um log visual no HUD mostrando últimas ações: "Coletou Ouro", "Levou dano de Armadilha", etc. Use `List<String> logAcoes` para rastrear.

**Desafio 20.5. Spawn inteligente (Distribuição).** Inimigos nunca aparecem a menos de 20 tiles da entrada (distância Manhattan). Itens são distribuídos em salas diferentes. Escadas ficam no fundo (distante). Passe as salas ao gerador, determine sala aleatória, spawn dentro dela.

**Boss Final 20.6. IA de Inimigos (Movimentação).** Adicione método `moveIA(Pos jogadorPos)` em Inimigo que retorna nova posição. Se jogador está no FOV, persegue (distância < 10 tiles). Senão, anda aleatoriamente. Implemente no turno inimigo: primeiro inimigos se movem, depois jogador age. Crie um `InimigoPerseguidor` que tenta se aproximar do jogador.
```
