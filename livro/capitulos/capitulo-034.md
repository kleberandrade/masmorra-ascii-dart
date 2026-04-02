# Capítulo 34 - Strategy e Command: Inimigos que Pensam

*Nos andares mais profundos da masmorra, há inscrições nas paredes. São padrões de design, técnicas que programadores experientes usam há décadas para resolver problemas recorrentes. Strategy ensina que há muitas formas de atacar o mesmo problema, e o código pode trocar entre elas em tempo de execução. Command transforma ações em objetos, permitindo desfazer jogadas e gravar histórico. Factory cria inimigos e itens sem que o resto do código precise saber dos detalhes. Observer conecta sistemas que não se conhecem. State dá aos inimigos comportamentos que mudam conforme a situação.*

*Nesta parte final, você vai aplicar cada um desses padrões no jogo que já construiu. A IA dos inimigos ficará mais inteligente, o código mais flexível, e a arquitetura mais elegante. Quando terminar, não terá apenas um jogo completo. Terá um projeto que demonstra domínio de Dart e de engenharia de software. A ascensão final não é derrotar o Dragão. É perceber que você se tornou o tipo de programador que sabe construir qualquer coisa.*

> *Um zumbi se arrasta lentamente em padrão aleatório. Um lobo te persegue ferozmente. Um esqueleto patrulha sua rota, ignorando você até você cruzar seu caminho. Cada um tem uma mente própria, não escravizada em if/else aninhados, mas livre para mudar de estratégia como as circunstâncias exigem.*

Neste capítulo você vai implementar dois padrões de design essenciais: Strategy para comportamentos intercambiáveis e Command para ações rastreáveis. Juntos, eles transformam inimigos estáticos em adversários inteligentes.

## O Problema: Comportamento Rígido

Até agora, em um combate típico, todos os inimigos agem da mesma forma:

```dart
void atacarInimigo(Inimigo inimigo) {
  int dano = calcularDano(heroi.arma, inimigo.defesa);
  inimigo.hp -= dano;

  // Inimigo sempre ataca de volta do mesmo jeito
  int danoRetorno = calcularDano(inimigo.arma, heroi.defesa);
  heroi.hp -= danoRetorno;
}
```

Todos fazem a mesma coisa. Um zumbi deveria andar aleatoriamente. Um lobo deveria perseguir você. Um dragão deveria mudar de tática conforme a luta avança. Sem um padrão, você acaba com centenas de if/else aninhados, e cada novo tipo de inimigo quebra a lógica anterior.

## Strategy: Uma Mente para Cada Inimigo

O padrão **Strategy** encapsula um conjunto de algoritmos e os torna intercambiáveis. É como em Final Fantasy VII: muda de matéria, muda de poder. A classe do personagem fica a mesma, mas o comportamento muda.

Defina uma interface abstrata:

```dart
abstract class EstrategiaIa {
  Acao decidir(Inimigo self, Jogador alvo, MapaMasmorra mapa);
}
```

Uma estratégia recebe o inimigo, o alvo e o mapa, e retorna uma **Acao** (que veremos em breve). Agora implemente estratégias concretas.

### IAAgressiva: Ataque Direto

Um lobo não hesita. Vê você, vai atrás.

A estratégia agressiva é simples mas efetiva: se o alvo está longe, ande em sua direção. Se está perto (1 tile), ataque. Se você não conseguir traçar uma linha reta até o alvo (há paredes no caminho), apenas ande aleatoriamente. Observe como a decisão retorna uma `Acao` (que veremos em breve) — o padrão Command encapsula o que fazer.

```dart
class IAAgressiva implements EstrategiaIa {
  @override
  Acao decidir(Inimigo self, Jogador alvo, MapaMasmorra mapa) {
    int distancia = mapa.distancia(self.pos, alvo.pos);

    if (distancia <= 1) {
      return AcaoAtacar(self, alvo);
    } else if (self.temLinhaDeVisao(alvo, mapa)) {
      var proxPasso = mapa.caminhoParaPos(self.pos, alvo.pos);
      return AcaoMover(self, proxPasso);
    } else {
      return AcaoMoverAleatorio(self, mapa);
    }
  }
}
```

### IACovardia: Retirada Estratégica

Um goblin covarde foge quando ferido:

Observe que `IACovardia` recebe um `limiteHP` (padrão 30%). Se o HP atual cai abaixo desse percentual, muda para fuga. Caso contrário, atua como agressivo. Isso permite criar variações: um goblin que foge em 30%, um orc que só foge em 10%, um dragão que nunca foge. Tudo com a mesma classe, apenas parâmetros diferentes.

```dart
class IACovardia implements EstrategiaIa {
  final int limiteHP;

  IACovardia({this.limiteHP = 30});

  @override
  Acao decidir(Inimigo self, Jogador alvo, MapaMasmorra mapa) {
    if (self.hp < (self.hpMax * limiteHP / 100)) {
      var fuga = mapa.caminhoParaPos(
        self.pos,
        alvo.pos,
        inverso: true
      );
      return AcaoMover(self, fuga);
    }

    int distancia = mapa.distancia(self.pos, alvo.pos);
    if (distancia <= 1) {
      return AcaoAtacar(self, alvo);
    }
    return AcaoMover(self, mapa.caminhoParaPos(self.pos, alvo.pos));
  }
}
```

### IAPatrulha: Vigilância Constante

Um esqueleto segue uma rota. Se você aparecer no seu campo de visão, passa a atacar:

Patrulha é mais sofisticada. O inimigo caminha por uma rota predefinida. Se deteta o alvo, passa para combate direto. Note o `emCombate` — uma vez em combate, o inimigo permanece assim até a morte ou vitória. Sem isso, um inimigo poderia ficar alternando entre patrulha e perseguição infinitamente. Esse flag garante coerência no comportamento.

```dart
class IAPatrulha implements EstrategiaIa {
  final List<Pos> rota;
  int indiceRota = 0;
  bool emCombate = false;

  IAPatrulha(this.rota);

  @override
  Acao decidir(Inimigo self, Jogador alvo, MapaMasmorra mapa) {
    if (self.temLinhaDeVisao(alvo, mapa)) {
      emCombate = true;
    }

    if (emCombate) {
      int distancia = mapa.distancia(self.pos, alvo.pos);
      if (distancia <= 1) {
        return AcaoAtacar(self, alvo);
      }
      return AcaoMover(self, mapa.caminhoParaPos(self.pos, alvo.pos));
    }

    var proxAlvo = rota[indiceRota];
    if (self.pos == proxAlvo) {
      indiceRota = (indiceRota + 1) % rota.length;
      proxAlvo = rota[indiceRota];
    }

    return AcaoMover(self, mapa.caminhoParaPos(self.pos, proxAlvo));
  }
}
```

### IAPassiva: Defesa Apenas

Um zumbi anda aleatoriamente e só ataca se for atacado primeiro:

Passiva é o oposto de agressiva. O inimigo ignora você até ser atacado. Depois, reage. Isso simula zumbis que estão dormindo ou distraídos, ou animais selvagens que fogem de humanos mas atacam se provocados. Note como `foiAtacada` é um flag que nunca volta a falso — uma vez despertado, o zumbi permanece hostil.

```dart
class IAPassiva implements EstrategiaIa {
  bool foiAtacada = false;

  @override
  Acao decidir(Inimigo self, Jogador alvo, MapaMasmorra mapa) {
    if (!foiAtacada) {
      return AcaoMoverAleatorio(self, mapa);
    }

    int distancia = mapa.distancia(self.pos, alvo.pos);
    if (distancia <= 1) {
      return AcaoAtacar(self, alvo);
    }
    return AcaoMover(self, mapa.caminhoParaPos(self.pos, alvo.pos));
  }
}
```

## Integrando Strategy no Inimigo

Modifique a classe Inimigo para usar uma estratégia:

```dart
class Inimigo {
  late Pos pos;
  late String nome;
  late int hp;
  late int hpMax;
  late Arma arma;
  late Defesa defesa;
  final EstrategiaIa estrategia;

  Inimigo({
    required this.nome,
    required this.hp,
    required this.arma,
    required this.defesa,
    required this.estrategia,
  }) : hpMax = hp;

  Acao obterProximaAcao(Jogador alvo, MapaMasmorra mapa) {
    return estrategia.decidir(this, alvo, mapa);
  }
}
```

## Command: Ações Reversíveis

Strategy diz *o quê fazer*. Command diz *como fazer* de forma reversível e histórica. Command encapsula uma solicitação como um objeto, permitindo desfazer, refazer e manter histórico.

Defina a interface:

Em vez de métodos que executam diretamente, cada ação é um objeto que sabe como se executar, desfazer e descrever a si mesma. Isso permite construir um histórico de ações — útil para replay de combates, undo, e logging. A interface é simples: `executar()` faz a coisa, `desfazer()` desfaz, e `descricao` descreve.

```dart
abstract class Acao {
  void executar();
  void desfazer();
  String get descricao;
}
```

### AcaoAtacar

A ação de ataque captura o estado antes (HP anterior) e depois (dano aplicado). Isso permite desfazer: basta restaurar `hp` para o valor anterior. Observe como `dano` é calculado e armazenado em `executar()` — é necessário porque em `desfazer()` você precisa saber quanto dano foi aplicado para poder reverter.

```dart
class AcaoAtacar implements Acao {
  final Inimigo atacante;
  final Character alvo;
  late int dano;
  late int hpAnterior;

  AcaoAtacar(this.atacante, this.alvo);

  @override
  void executar() {
    hpAnterior = alvo.hp;
    dano = calcularDano(atacante.arma, alvo.defesa);
    alvo.hp -= dano;
  }

  @override
  void desfazer() {
    alvo.hp = hpAnterior;
  }

  @override
  String get descricao => "${atacante.nome} ataca ${alvo.nome} por $dano!";
}
```

### AcaoMover

Movimento também é uma ação. Captura a posição original, move, permite desfazer restaurando a posição. Note que `ePassavel()` garante que você não anda através de paredes — se o destino é inválido, a ação não muda `pos`. Importante: sempre validar antes de modificar estado.

```dart
class AcaoMover implements Acao {
  final Inimigo self;
  final Pos destino;
  late Pos origem;
  final MapaMasmorra mapa;

  AcaoMover(this.self, this.destino, this.mapa);

  @override
  void executar() {
    origem = self.pos;
    if (mapa.ePassavel(destino)) {
      self.pos = destino;
    }
  }

  @override
  void desfazer() {
    self.pos = origem;
  }

  @override
  String get descricao => "${self.nome} se move";
}
```

### AcaoAguardar

Uma ação que não faz nada. Parece inútil, mas é essencial. Um inimigo pode decidir que a melhor ação este turno é aguardar: recarregar, regenerar, ou simplesmente deixar o alvo fazer a próxima ação. Sem `AcaoAguardar`, você precisaria de `if (acao == null)` em todo o código. Com ela, tudo é uniforme: sempre execute uma ação, mesmo que não faça nada.

```dart
class AcaoAguardar implements Acao {
  final Character self;

  AcaoAguardar(this.self);

  @override
  void executar() {}

  @override
  void desfazer() {}

  @override
  String get descricao => "${self.nome} aguarda";
}
```

## Histórico de Ações e Undo

Uma das grandes vantagens de Command é manter um histórico completo:

O `GerenciadorAcoes` mantém uma lista de todas as ações já executadas. Quando você quer desfazer, volta um índice e chama `desfazer()` do comando anterior. Quer refazer? Avança o índice. Quer replay do combate inteiro? Itere o histórico. Quer ver o log? Obtenha as descrições. Tudo vem grátis dessa abstração simples.

```dart
class GerenciadorAcoes {
  final List<Acao> historico = [];
  int indiceAtual = -1;

  void executar(Acao cmd) {
    cmd.executar();
    historico.removeRange(indiceAtual + 1, historico.length);
    historico.add(cmd);
    indiceAtual = historico.length - 1;
  }

  void desfazer() {
    if (indiceAtual >= 0) {
      historico[indiceAtual].desfazer();
      indiceAtual--;
    }
  }

  void refazer() {
    if (indiceAtual < historico.length - 1) {
      indiceAtual++;
      historico[indiceAtual].executar();
    }
  }

  List<String> obterHistorico() => historico
      .sublist(0, indiceAtual + 1)
      .map((cmd) => cmd.descricao)
      .toList();
}
```

## Turno de Combate Integrado

Agora um turno é limpo e legível:

Veja como `executarTurnoInimigo` é agora uma função simples e linear. O inimigo decide uma ação (via sua estratégia), a ação se executa, o log registra. Sem if/else aninhados, sem estado implícito, sem surpresas. A IA vem da estratégia, a reversibilidade vem do comando.

```dart
void executarTurnoInimigo(
  Inimigo inimigo,
  Jogador heroi,
  MapaMasmorra mapa,
  GerenciadorAcoes gerenciador,
) {
  var acao = inimigo.obterProximaAcao(heroi, mapa);
  gerenciador.executar(acao);
  log.escrever(acao.descricao);

  if (heroi.hp <= 0) {
    log.escrever("${heroi.nome} caiu!");
  }
}
```

## Boss com Fases

Um padrão avançado: um chefe que muda de estratégia conforme seu HP cai:

Um boss não é apenas um inimigo forte. É um combate progredindo. Conforme o herói inflige dano, o chefe muda de tática. Assim como em Dark Souls, onde o boss fica desesperado quando está perto de morrer. Aqui, `BossComFases` muda a estratégia interna baseado no HP. O resto do código não precisa saber disso — para o jogo principal, é apenas mais uma `EstrategiaIa`.

```dart
class BossComFases implements EstrategiaIa {
  late EstrategiaIa estrategiaAtual = IAAgressiva();

  @override
  Acao decidir(Inimigo self, Jogador alvo, MapaMasmorra mapa) {
    if (self.hp < (self.hpMax * 50 / 100)) {
      estrategiaAtual = IACovardia(limiteHP: 20);
    } else if (self.hp < (self.hpMax * 25 / 100)) {
      estrategiaAtual = IAAgressiva(); // Desesperado
    }

    return estrategiaAtual.decidir(self, alvo, mapa);
  }
}
```

É como em Dragon Ball: conforme Goku fica mais ferido, ele muda de abordagem. Cada fase tem uma mente própria.

## Antes e Depois

Antes, inimigos eram indistintos:

```text
Zumbi: sempre anda aleatoriamente, sempre ataca se próximo
Lobo: sempre persegue, sempre ataca
Dragão: sempre ataca com força bruta
```

Depois, cada um é único:

```text
Zumbi (IAPassiva): anda lentamente até ser provocado
Lobo (IAAgressiva): persegue agressivamente, não desiste
Esqueleto (IAPatrulha): patrulha, mas quando vê você muda para combate
Dragão (BossComFases): adapta tática a cada fase, inteligente
```

## Pergaminho do Capítulo

Neste capítulo, você aprendeu dois padrões de design que transformam inimigos estáticos em adversários inteligentes e comportamentos previsíveis. O padrão Strategy permite que cada inimigo tenha sua própria "mente" — uma agressiva persegue você ferozmente, outra patrulha e dispara quando detectada, outra foge quando ferida — tudo sem modificar a classe Inimigo. Você implementou cinco estratégias diferentes (IAAgressiva, IACovardia, IAPatrulha, IAPassiva, e BossComFases), cada uma definindo como um inimigo decide agir em um turno. O padrão Command encapsula cada ação (ataque, movimento, espera) como um objeto reversível, permitindo que você construa um histórico completo, desfaça ações, e implemente replay de combates. Juntos, Strategy e Command eliminam if/else aninhados, criam inimigos que "pensam", e proveem a base para sistemas de IA sofisticados que respeitam a elegância do código.

::: dica
**Dica do Mestre:** Strategy e Command são padrões que vão muito além de jogos. Em aplicações reais, use Strategy sempre que tiver múltiplas formas de executar um algoritmo que pode mudar em runtime, e Command sempre que precisar de histórico, undo/redo, ou logging de operações. Um exemplo: um sistema de pagamentos que pode usar Visa, Mastercard, ou Pix — cada é uma Strategy. Um editor de documentos que permite desfazer múltiplas edições — cada edição é um Command. O investimento em aprender esses padrões numa masmorra digital te torna um desenvolvedor melhor em qualquer contexto.
:::

***

## Desafios da Masmorra

**Desafio 34.1. Implemente uma estratégia `IASuicida` que sempre avança em sua direção até ficar ao seu lado e então "explode", causando dano em raio de 3 tiles em volta (afeta você e outros inimigos).

**Desafio 34.2. Implemente um comando `AcaoLancarMagia` que custa mana (novo atributo do Inimigo) e pode ser desfeito. Crie uma estratégia que lança magia se tiver mana suficiente.

**Desafio 34.3. Modifique `IAPatrulha` para suportar múltiplas rotas e escolha uma aleatoriamente quando criada ou quando termina a rota atual.

**Desafio 34.4. Implemente `AcaoFuga` que move o inimigo para uma posição segura; se não encontrar após 5 turnos, o inimigo muda para `IAAgressiva`.

**Boss Final 34.5. Crie um sistema de "Comportamento Adaptativo" onde um inimigo começa com `IAPatrulha` e, após sofrer 3 ataques consecutivos sem conseguir contra-atacar, muda para `IAAgressiva`. Use um contador interno que reseta quando consegue atacar.

***

O padrão Strategy transformou inimigos passivos em adversários inteligentes. Command permitiu que cada ação fosse registrada e revertida. Juntos, eles formam a base de IA sofisticada. A próxima fronteira é multiplicar esses inimigos inteligentes de forma eficiente e fazer o mundo todo reagir aos eventos do combate.

> *"A inteligência sem ação é mera reflexão. A ação sem inteligência é mera sorte. Um rei verdadeiro domina ambas."*

No próximo capítulo você verá como usar Factory para criar centenas de inimigos variados de forma escalável, e Observer para fazer o mundo inteiro reagir aos eventos sem acoplamento.
