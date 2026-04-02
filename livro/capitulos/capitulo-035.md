# Capítulo 35 - Factory e Observer: O Mundo Reage

> *Você mata um inimigo. Instantaneamente: som toca, tela pisca, XP sobe, conquista desbloqueia. O mundo não estava esperando sua ordem—estava observando. Quando algo muda, tudo que precisa saber é notificado. Cacos que se comunicam sem se acoplarem.*

Neste capítulo você vai implementar **Factory (padrão de design)** para criar inimigos e itens de forma escalável e data-driven, e **Observer (padrão de design)** para fazer múltiplos sistemas reagirem aos eventos sem acoplamento direto. Aprenderá também sobre **Singleton**, um padrão para garantir que apenas uma instância de uma classe exista no programa.

## Factory: Construtor Central

O padrão Factory centraliza a criação de objetos. Em vez de espalhar `new Inimigo(...)` por todo o código, temos um único lugar que sabe como construir cada tipo.

### O Problema: Criação Descentralizada

Sem Factory, você acaba com espaguete:

O código abaixo mostra exatamente o problema: toda vez que você precisa gerar um inimigo, você cria manualmente com todos os parâmetros. Se quer mudar HP, defesa ou estratégia de um zumbi, você precisa encontrar todos os lugares onde escreve `Inimigo(nome: "Zumbi", hp: 20, ...)` e atualizar. Esqueça de um lugar e o jogo fica inconsistente. Um zumbi que deveria ter 20 HP tem 15 em um andar e 20 em outro.

```dart
void gerarInimigos() {
  if (Random().nextInt(100) < 30) {
    var goblin = Inimigo(
      nome: "Goblin", hp: 20, arma: Arma(dano: 3),
      defesa: Defesa(1), estrategia: IACovardia(),
    );
    inimigos.add(goblin);
  } else if (Random().nextInt(100) < 60) {
    var lobo = Inimigo(
      nome: "Lobo", hp: 35, arma: Arma(dano: 5),
      defesa: Defesa(2), estrategia: IAAgressiva(),
    );
    inimigos.add(lobo);
  }
}
```

Problemas:
- Balanço espalhado por todo o código.
- Adicionar novo tipo é tedioso e propenso a erros.
- Sem consistência entre andares.
- Testes exigem saber detalhes de construção.

### FabricaInimigo: Solução Centralizada

Agora toda definição está em um único lugar. Um `Map` de catálogo mapeia tipo (string) para definição. Métodos estáticos criam inimigos: `criar('zumbi', 3)` cria um zumbi no andar 3, com HP e dano escalonados por andar. Mudar HP de um zumbi? Mude em um lugar. Quer um novo tipo? Adicione ao catálogo. O resto do código nunca vê os detalhes construtivos — sempre vai through a factory. Isso é elegância.

```dart
class FabricaInimigo {
  static final Map<String, DefinicaoInimigo> catalogo = {
    'zumbi': DefinicaoInimigo(
      nome: 'Zumbi',
      hpBase: 15,
      danoBase: 2,
      defesaBase: 0,
      raridade: 0.4,
      estrategia: IAPassiva(),
    ),
    'lobo': DefinicaoInimigo(
      nome: 'Lobo',
      hpBase: 25,
      danoBase: 5,
      defesaBase: 1,
      raridade: 0.35,
      estrategia: IAAgressiva(),
    ),
    'esqueleto': DefinicaoInimigo(
      nome: 'Esqueleto',
      hpBase: 30,
      danoBase: 4,
      defesaBase: 2,
      raridade: 0.25,
      estrategia: IAPatrulha([]),
    ),
  };

  static Inimigo criar(String tipo, int andar) {
    var def = catalogo[tipo];
    if (def == null) throw ArgumentError('Tipo desconhecido: $tipo');

    int hpFinal = def.hpBase + (andar * 3);
    int danoFinal = def.danoBase + (andar * 1);
    int defesaFinal = def.defesaBase + (andar ~/ 3);

    return Inimigo(
      nome: def.nome,
      hp: hpFinal,
      arma: Arma(dano: danoFinal),
      defesa: Defesa(defesaFinal),
      estrategia: def.estrategia,
    );
  }

  static Inimigo criarAleatorio(int andar) {
    double sorteio = Random().nextDouble();
    double acumulado = 0.0;

    for (var entrada in catalogo.entries) {
      acumulado += entrada.value.raridade;
      if (sorteio < acumulado) {
        return criar(entrada.key, andar);
      }
    }

    return criar('zumbi', andar);
  }

  static void carregarDoJSON(String json) {
    var mapa = jsonDecode(json) as Map<String, dynamic>;
    for (var tipo in mapa.keys) {
      var dados = mapa[tipo] as Map<String, dynamic>;
      catalogo[tipo] = DefinicaoInimigo(
        nome: dados['nome'] as String,
        hpBase: dados['hp'] as int,
        danoBase: dados['dano'] as int,
        defesaBase: dados['defesa'] as int,
        raridade: dados['raridade'] as double,
        estrategia: _criarEstrategia(dados['estrategia'] as String),
      );
    }
  }

  static EstrategiaIa _criarEstrategia(String tipo) {
    return switch (tipo) {
      'agressiva' => IAAgressiva(),
      'covardia' => IACovardia(),
      'patrulha' => IAPatrulha([]),
      'passiva' => IAPassiva(),
      'boss' => BossComFases(),
      _ => IAAgressiva(),
    };
  }
}

class DefinicaoInimigo {
  final String nome;
  final int hpBase;
  final int danoBase;
  final int defesaBase;
  final double raridade;
  final EstrategiaIa estrategia;

  DefinicaoInimigo({
    required this.nome,
    required this.hpBase,
    required this.danoBase,
    required this.defesaBase,
    required this.raridade,
    required this.estrategia,
  });
}
```

Agora criar é simples e centralizado:

```dart
var zumbi = FabricaInimigo.criar('zumbi', 3);
var aleatorio = FabricaInimigo.criarAleatorio(5);
```

É como o spawner de monstros em Minecraft: tudo vem de um único lugar, balanceado por andar.

### FabricaItem Similamente

Itens também precisam de factory. Aqui, cada item tem nome, descrição, valor, raridade, e um `criador` (uma função que constrói o item real). Isso permite criar diferentes tipos de poções, armas e armaduras sem espalhar lógica de construção por todo o código.

```dart
class FabricaItem {
  static final Map<String, DefinicaoItem> catalogo = {
    'pocao_vida': DefinicaoItem(
      nome: 'Poção de Vida',
      descricao: 'Restaura 20 HP',
      valor: 50,
      raridade: 0.5,
      criador: () => Pocao(cura: 20),
    ),
    'espada_ferrea': DefinicaoItem(
      nome: 'Espada de Ferro',
      descricao: 'Dano: 5',
      valor: 150,
      raridade: 0.2,
      criador: () => Arma(dano: 5, nome: 'Espada'),
    ),
  };

  static Item criar(String tipo) {
    var def = catalogo[tipo];
    if (def == null) throw ArgumentError('Item desconhecido: $tipo');
    return def.criador();
  }

  static Item criarAleatorio() {
    var tipos = catalogo.keys.toList();
    return criar(tipos[Random().nextInt(tipos.length)]);
  }
}

class DefinicaoItem {
  final String nome;
  final String descricao;
  final int valor;
  final double raridade;
  final Item Function() criador;

  DefinicaoItem({
    required this.nome,
    required this.descricao,
    required this.valor,
    required this.raridade,
    required this.criador,
  });
}
```

## Observer: Sistema de Reações

O padrão Observer permite que múltiplos observadores se inscrevam em eventos sem que o disparador conheça os observadores. Usa Dart **Stream** e `StreamController`.

### O Problema: Acoplamento

Sem Observer, matar um inimigo seria acoplado demais:

O código abaixo é a raiz do caos. Uma função `matarInimigo` que faz tudo: escreve log, adiciona XP, adiciona ouro, toca som, pisca tela, verifica conquistas. Quer adicionar animação? Edita aqui. Quer remover som? Edita aqui. Cada adição é um risco de quebrar algo que já funciona. Pior, `matarInimigo` precisa conhecer todos os sistemas: log, UI, som, conquistas, banco de dados. Altíssimo acoplamento.

```dart
void matarInimigo(Inimigo inimigo) {
  inimigo.hp = 0;
  log.escrever("${inimigo.nome} morreu!");
  heroi.xp += inimigo.xpRecompensa;
  heroi.ouro += inimigo.ouroRecompensa;
  ui.piscar(cor: Color.red);
  som.tocar('morte');
  conquistas.verificar('matador');
}
```

Tudo em uma função. Novo observador? Edita aqui. Ruim.

### BarramentoEventos: Solução

Em vez de `matarInimigo` saber de tudo, ele apenas emite um evento: "um inimigo morreu". Quem se importa? Log, UI, som, conquistas, estatísticas. Todos escutam. Nenhum conhece o outro. `matarInimigo` não precisa saber de nada além do evento básico. Quer adicionar um novo sistema que reage a morte? Cria um novo observador e o registra. Zero mudança no código de combate.

```dart
abstract class EventoJogo {
  final DateTime timestamp = DateTime.now();
}

class EventoMorteInimigo extends EventoJogo {
  final Inimigo inimigo;
  final Jogador matador;

  EventoMorteInimigo({required this.inimigo, required this.matador});
}

class EventoColheitaItem extends EventoJogo {
  final Item item;
  final Character personagem;

  EventoColheitaItem({required this.item, required this.personagem});
}

class EventoDanoAplicado extends EventoJogo {
  final Character atacante;
  final Character alvo;
  final int dano;

  EventoDanoAplicado({
    required this.atacante,
    required this.alvo,
    required this.dano,
  });
}

class BarramentoEventos {
  static final BarramentoEventos _instancia = BarramentoEventos._();

  final _controlador = StreamController<EventoJogo>.broadcast();

  BarramentoEventos._();

  factory BarramentoEventos() => _instancia;

  void emitir(EventoJogo evento) {
    _controlador.add(evento);
  }

  Stream<T> on<T extends EventoJogo>() {
    return _controlador.stream.whereType<T>();
  }

  void fechar() {
    _controlador.close();
  }
}
```

### Observadores Concretos

Cada observador é uma classe simples que escuta um tipo de evento e reage. `ObservadorLog` escreve no log. `ObservadorUI` pisca a tela. `ObservadorSom` toca um efeito sonoro. Cada um é isolado e testável. Se o log está quebrado, não afeta som. Se sound está quebrado, não afeta conquistas.

```dart
class ObservadorLog {
  final BarramentoEventos bus;
  final Log log;
  late StreamSubscription subscription;

  ObservadorLog(this.bus, this.log) {
    subscription = bus.on<EventoJogo>().listen((evento) {
      if (evento is EventoMorteInimigo) {
        log.escrever("${evento.inimigo.nome} foi derrotado!");
      } else if (evento is EventoDanoAplicado) {
        log.escrever(
          "${evento.atacante.nome} ataca ${evento.alvo.nome} por ${evento.dano}!",
        );
      }
    });
  }

  void cancelar() => subscription.cancel();
}

class ObservadorEstatisticas {
  final BarramentoEventos bus;
  late StreamSubscription subscription;

  int totalMatos = 0;
  int ouroColetado = 0;
  int danoTotal = 0;

  ObservadorEstatisticas(this.bus) {
    subscription = bus.on<EventoJogo>().listen((evento) {
      if (evento is EventoMorteInimigo) {
        totalMatos++;
      } else if (evento is EventoDanoAplicado) {
        danoTotal += evento.dano;
      }
    });
  }

  void cancelar() => subscription.cancel();
}

class ObservadorUI {
  final BarramentoEventos bus;
  final GerenciadorUI ui;
  late StreamSubscription subscription;

  ObservadorUI(this.bus, this.ui) {
    subscription = bus.on<EventoJogo>().listen((evento) {
      if (evento is EventoDanoAplicado) {
        ui.piscar(cor: Cor.vermelho, duracao: Duration(milliseconds: 150));
      } else if (evento is EventoMorteInimigo) {
        ui.mostrarAnimacaoMorte(evento.inimigo.pos);
      }
    });
  }

  void cancelar() => subscription.cancel();
}

class ObservadorSom {
  final BarramentoEventos bus;
  final GerenciadorSom som;
  late StreamSubscription subscription;

  ObservadorSom(this.bus, this.som) {
    subscription = bus.on<EventoJogo>().listen((evento) {
      if (evento is EventoDanoAplicado) {
        som.tocar('acerto');
      } else if (evento is EventoMorteInimigo) {
        som.tocar('morte');
      }
    });
  }

  void cancelar() => subscription.cancel();
}
```

É como o sistema de notificações do celular: quando algo acontece, múltiplos apps reagem. Nenhum conhece o outro.

## Integrando Factory e Observer

Factory cria, Observer reage. Combina assim:

Factory gera inimigos de forma consistente. Durante um turno, o inimigo age, e a ação é executada. Se a ação é um ataque que mata o alvo, um evento é emitido. Todos os observadores registrados escutam e reagem. Simples, elegante, extensível.

```dart
void gerarMasmorra(int andar) {
  var inimigos = <Inimigo>[];
  for (int i = 0; i < 5; i++) {
    inimigos.add(FabricaInimigo.criarAleatorio(andar));
  }
  return inimigos;
}

void executarTurnoInimigo(
  Inimigo inimigo,
  Jogador heroi,
  BarramentoEventos bus,
) {
  var acao = inimigo.obterProximaAcao(heroi, mapa);
  acao.executar();

  if (acao is AcaoAtacar) {
    int dano = calcularDano(inimigo.arma, heroi.defesa);
    bus.emitir(EventoDanoAplicado(
      atacante: inimigo,
      alvo: heroi,
      dano: dano,
    ));

    if (heroi.hp <= 0) {
      bus.emitir(EventoMorteInimigo(inimigo: heroi, matador: inimigo));
    }
  }
}
```

## Inicialização Completa

O fluxo de inicialização estabelece o barramento, registra todos os observadores, executa o combate, e depois limpa. Isso garante que observadores vivos escutam eventos e que recursos são liberados quando termina.

```dart
void main() {
  final bus = BarramentoEventos();

  final obsLog = ObservadorLog(bus, log);
  final obsEstat = ObservadorEstatisticas(bus);
  final obsUI = ObservadorUI(bus, ui);
  final obsSom = ObservadorSom(bus, som);

  var inimigos = gerarMasmorra(andar: 3);
  executarCombate(inimigos, heroi, bus);

  obsLog.cancelar();
  obsEstat.cancelar();
  obsUI.cancelar();
  obsSom.cancelar();
  bus.fechar();
}
```

## Vantagens do Design

Antes, adicionar novo efeito exigia editar código de combate. Depois, você apenas cria um novo observador:

Isso é Open/Closed Principle: o código é aberto para extensão (novos observadores) mas fechado para modificação (código de combate não muda). Um novo observador que desbloqueia conquistas é adicionado em um arquivo novo, sem tocar em nada existente. Quer remover? Apaga o arquivo e remove uma linha de registro. Manutenção simples.

```dart
class ObservadorConquistas {
  final BarramentoEventos bus;
  late StreamSubscription subscription;

  ObservadorConquistas(this.bus) {
    subscription = bus.on<EventoMorteInimigo>().listen((evento) {
      if (evento.inimigo.nome == "Dragão") {
        conquistas.desbloquear('matador_de_dragoes');
      }
    });
  }

  void cancelar() => subscription.cancel();
}
```

Feito. Nenhuma alteração em código de combate.

## Pergaminho do Capítulo

Neste capítulo você aprendeu como Factory centraliza a criação de objetos, removendo lógica de construção espalhada por todo o código. Implementou FabricaInimigo que define balanceamento em um único lugar e FabricaItem para itens, ambas permitindo fácil extensão e carregamento de dados via JSON. O padrão Observer permitiu que múltiplos sistemas (log, UI, som, estatísticas, conquistas) reajam a eventos do jogo (morte, dano, colheita) sem conhecerem um ao outro, eliminando acoplamento e simplificando a adição de novos comportamentos. Juntos, Factory e Observer transformam um jogo de um sistema monolítico em um ecossistema modular e extensível, onde novos inimigos e novos observadores se adicionam sem tocar em código existente.

::: dica
**Dica do Mestre:** Factory Pattern é essencial em desenvolvimento real. Qualquer sistema que cria múltiplos objetos de tipos variados deve centralizar essa criação. Em aplicações web, factories criam modelos de banco de dados. Em sistemas de configuração, factories parseiam dados e constroem objetos. Em testes, factories criam fixtures. Observer é igualmente crucial: é a base de qualquer sistema event-driven profissional. Desde sistemas de notificação em apps até pipelines de data processing, Observer permite que sistemas desacoplados se comuniquem. O investimento em aprender esses padrões agora te preparará para código profissional em qualquer contexto.
:::

***

## Desafios da Masmorra

**Desafio 35.1. Implemente uma `FabricaSala` que lê definição JSON (tipo de sala, inimigos, loot) e gera uma sala completa com todos os inimigos criados via Factory.

**Desafio 35.2. Crie um `EventoSubirNivel` e um `ObservadorSubidaNivel` que toca som especial, mostra animação e escreve no log quando o herói sobe de nível.

**Desafio 35.3. Implemente um `ObservadorRegistroCombate` que armazena todos os eventos de combate em uma lista, permitindo "replay" de combates para debug (refaz cada ação em sequência).

**Desafio 35.4. Crie um `ObservadorPersistencia` que escuta `EventoMorteInimigo` e atualiza um JSON com estatísticas globais (inimigos mais perigosos, itens mais valiosos encontrados).

**Boss Final 35.5. Implemente um sistema de "Reações em Cadeia" onde um evento dispara eventos posteriores (morte -> loot -> colheita -> XP -> subida de nível -> conquista). Use `Future` e `Timer` para simular delays entre reações.

***

Factory transformou criação de inimigos em um processo escalável e data-driven. Observer transformou sistemas isolados em um ecossistema de reações elegante. Juntos, eles permitem crescimento sem acoplamento: novos observadores se adicionam sem tocar em código anterior, balanço se muda via JSON.

> *"A verdadeira elegância de um sistema reside não no que ele faz hoje, mas em quanto pode crescer amanhã sem quebrar o que já funciona."*

No próximo capítulo, você verá o último padrão crucial: máquinas de estado para IA que comporta realmente inteligente.
