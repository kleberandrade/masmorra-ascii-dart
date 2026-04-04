# Capítulo 36 - Máquinas de Estado: Patrulha, Alerta e Perseguição

> *Um inimigo não ataca você instantaneamente quando te vê. Para um momento, alerta. Olha em volta. Se você sair de seu campo de visão, recua lentamente para patrulha. Se você se aproximar, começa a persegui-lo. Se você o ferir, persegue com fúria. Se você for muito forte, foge. Isto é uma máquina de estados: estados discretos, claramente nomeados, com transições explícitas. Cada estado é um objeto que sabe quando e como mudar para outro. Isso é mais organizado do que dizer "se X e se Y e se Z", porque os estados são visualizáveis, testáveis e extensíveis.*

Neste capítulo você vai aprender o padrão State, transformando comportamento complexo em máquinas de estado finito (FSM). Cada inimigo terá estados como Patrulhando, Alerta, Perseguindo, Atacando e Fugindo.

## O Problema: Comportamento Confuso

Sem máquinas de estado, o código fica confuso assim:

```dart
class Inimigo {
  bool viu_jogador = false;
  bool perto_jogador = false;
  int turnos_alerta = 0;
  bool fugindo = false;

  void executarTurno(Jogador alvo, MapaMasmorra mapa) {
    if (hp < 10 && viu_jogador) {
      fugindo = true;
      moverAoContrario(alvo);
    } else if (perto_jogador) {
      atacar(alvo);
    } else if (viu_jogador) {
      moverEm(alvo);
      turnos_alerta++;
      if (turnos_alerta > 5) {
        viu_jogador = false;
      }
    } else {
      patrulhar();
    }
  }
}
```

Problemas:
- Estados implícitos (várias bools não formam um estado claro).
- Transições obscuras (quando exatamente mudar de "alerta" para "patrulha"?).
- Difícil de estender (novo estado quebra tudo).
- Difícil de debugar (qual é o estado real?).

## A Solução: State Pattern

Defina uma interface abstrata para estados:

Cada estado sabe como atualizar-se (transicionar para outro) e como agir (executar ação). Isso torna cada estado independente e testável. Um teste de "Patrulhando" não precisa saber de "Atacando". Cada um é uma máquina simples com regras claras.

```dart
abstract class EstadoIA {
  EstadoIA? atualizar(Inimigo self, Jogador alvo, MapaMasmorra mapa);
  Acao agir(Inimigo self, Jogador alvo, MapaMasmorra mapa);
  String get nome;
}
```

Cada estado retorna um novo estado (ou null se continua). A classe Inimigo muda de estado automaticamente:

Veja como `executarTurno` é simples: atualizar o estado, agir, pronto. O estado decide transições, a classe apenas obedece. Se um novo estado retorna null, o inimigo permanece no estado atual; isso previne mudanças erráticas.

```dart
class Inimigo {
  late EstadoIA estado = Patrulhando([]);
  late Pos pos;
  late String nome;
  late int hp;

  void executarTurno(Jogador alvo, MapaMasmorra mapa) {
    var novoEstado = estado.atualizar(this, alvo, mapa);
    if (novoEstado != null) {
      print('$nome muda para ${novoEstado.nome}');
      estado = novoEstado;
    }

    var acao = estado.agir(this, alvo, mapa);
    acao.executar();
  }
}
```

## Implementando Estados Concretos

### Patrulhando

Patrulhando é o estado de repouso. O inimigo segue uma rota. Se detecta o alvo, passa para "Alerta". Caso contrário, continua patrulhando. Simples e previsível.

```dart
class Patrulhando implements EstadoIA {
  final List<Pos> rota;
  int indiceRota = 0;

  Patrulhando(this.rota);

  @override
  EstadoIA? atualizar(Inimigo self, Jogador alvo, MapaMasmorra mapa) {
    if (self.temLinhaDeVisao(alvo, mapa)) {
      return Alerta();
    }
    return null;
  }

  @override
  Acao agir(Inimigo self, Jogador alvo, MapaMasmorra mapa) {
    var proxPosicao = rota[indiceRota];
    if (self.pos == proxPosicao) {
      indiceRota = (indiceRota + 1) % rota.length;
      proxPosicao = rota[indiceRota];
    }

    var proxPasso = mapa.caminhoParaPos(self.pos, proxPosicao);
    return AcaoMover(self, proxPasso, mapa);
  }

  @override
  String get nome => "Patrulhando";
}
```

> **Nota:** O método `self.temLinhaDeVisao()` verifica se há linha de visão direta entre o inimigo e o alvo usando o algoritmo de Bresenham, sem paredes ou obstáculos bloqueando (implementado em `campo_visao.dart`, Capítulo 19). O método `mapa.caminhoParaPos()` retorna o próximo passo do caminho mais curto entre duas posições (implementado em `pathing.dart`, Capítulo 20).

### Alerta

Alerta é um estado intermediário. O inimigo viu você, mas não tem certeza. Aguarda 3 turnos. Se você sair de visão, volta a patrulhar. Se se aproximar, passa para perseguição ou ataque. É como em Zelda quando um inimigo te vê, pisca e fica em guarda antes de atacar.

```dart
class Alerta implements EstadoIA {
  int turnosAlerta = 0;

  @override
  EstadoIA? atualizar(Inimigo self, Jogador alvo, MapaMasmorra mapa) {
    if (!self.temLinhaDeVisao(alvo, mapa)) {
      turnosAlerta++;
      if (turnosAlerta > 3) {
        // Retorna ao patrulhamento com rota vazia (simplificado).
        // Num sistema real, poderia gerar rota aleatória ou
        // retomar a patrulha anterior. Com rota vazia, o inimigo
        // fica imóvel até detectar o jogador novamente.
        return Patrulhando([]);
      }
      return null;
    }

    turnosAlerta = 0;
    int distancia = mapa.distancia(self.pos, alvo.pos);
    if (distancia <= 1) {
      return Atacando();
    }

    return Perseguindo();
  }

  @override
  Acao agir(Inimigo self, Jogador alvo, MapaMasmorra mapa) {
    return AcaoAguardar(self);
  }

  @override
  String get nome => "Alerta";
}
```

> **Nota:** O método `mapa.distancia()` calcula a distância Manhattan entre duas posições, usada para determinar se o inimigo está próximo o suficiente para atacar (implementado em `mapa.dart`, Capítulo 12).

### Perseguindo

Perseguindo é comprometido. O inimigo está atrás de você. Se você sair de visão, volta para alerta. Se ficar perto demais, passa para ataque. Se ficar muito ferido, foge. É o "combate em movimento": nem está descansando, nem atacando diretamente.

```dart
class Perseguindo implements EstadoIA {
  @override
  EstadoIA? atualizar(Inimigo self, Jogador alvo, MapaMasmorra mapa) {
    if (!self.temLinhaDeVisao(alvo, mapa)) {
      return Alerta();
    }

    int distancia = mapa.distancia(self.pos, alvo.pos);
    if (distancia <= 1) {
      return Atacando();
    }

    if (self.hp < (self.hpMax * 30 / 100)) {
      return Fugindo();
    }

    return null;
  }

  @override
  Acao agir(Inimigo self, Jogador alvo, MapaMasmorra mapa) {
    var proxPasso = mapa.caminhoParaPos(self.pos, alvo.pos);
    return AcaoMover(self, proxPasso, mapa);
  }

  @override
  String get nome => "Perseguindo";
}
```

> **Nota:** O método `mapa.caminhoParaPos()` retorna o próximo passo do caminho mais curto, essencial para fazer o inimigo se mover inteligentemente em direção ao alvo sem atravessar paredes (implementado em `pathing.dart`, Capítulo 20).

### Atacando

Atacando é o engajamento total. O inimigo está ao seu lado (1 tile) e batendo. Se você se afasta, volta a perseguir. Se fica muito ferido, foge. Caso contrário, continua atacando.

```dart
class Atacando implements EstadoIA {
  @override
  EstadoIA? atualizar(Inimigo self, Jogador alvo, MapaMasmorra mapa) {
    int distancia = mapa.distancia(self.pos, alvo.pos);

    if (distancia > 1) {
      return Perseguindo();
    }

    if (self.hp < (self.hpMax * 25 / 100)) {
      return Fugindo();
    }

    return null;
  }

  @override
  Acao agir(Inimigo self, Jogador alvo, MapaMasmorra mapa) {
    return AcaoAtacar(self, alvo);
  }

  @override
  String get nome => "Atacando";
}
```

### Fugindo

Fugindo é retirada. O inimigo anda longe de você, tentando se regenerar. Se HP regenera, volta a perseguir. Se passa muito tempo fugindo (turnos_fuga > 10), desiste e volta a patrulhar. Nenhum inimigo foge eternamente.

```dart
class Fugindo implements EstadoIA {
  int turnosFuga = 0;

  @override
  EstadoIA? atualizar(Inimigo self, Jogador alvo, MapaMasmorra mapa) {
    turnosFuga++;

    if (self.hp > (self.hpMax * 60 / 100)) {
      return Perseguindo();
    }

    if (turnosFuga > 10) {
      // Retorna ao patrulhamento com rota vazia (simplificado).
      // Num sistema real, poderia gerar rota aleatória ou retomar
      // a patrulha anterior. Com rota vazia, o inimigo fica imóvel
      // até detectar o jogador novamente.
      return Patrulhando([]);
    }

    return null;
  }

  @override
  Acao agir(Inimigo self, Jogador alvo, MapaMasmorra mapa) {
    var fuga = mapa.caminhoParaPos(
      self.pos,
      alvo.pos,
      inverso: true,
    );
    return AcaoMover(self, fuga, mapa);
  }

  @override
  String get nome => "Fugindo";
}
```

> **Nota:** O método `mapa.caminhoParaPos()` com `inverso: true` retorna o próximo passo na direção *oposta* ao alvo, implementando assim um comportamento inteligente de fuga (em vez de apenas mover aleatoriamente). Esse mecanismo evita que inimigos fuja eternamente: após 10 turnos de fuga, retorna ao patrulhamento (implementado em `pathing.dart`, Capítulo 20).

## Diagrama de Transições

Ciclo de vida de um inimigo (FSM). A fonte editável do diagrama está em `assets/diagrams/capitulo-036-fsm-transicoes.mmd`; o PNG é gerado em `./scripts/build.sh` com Node.js/npx (`@mermaid-js/mermaid-cli`).

![Diagrama de transições da FSM do inimigo](assets/diagrams/capitulo-036-fsm-transicoes.png)

## Fases de Boss com FSM

Um chefe inteligente tem fases que são estados:

Um boss não é estático. Conforme você o machuca, ele muda. Primeira fase: caminha em sua direção. Segunda fase (quando perde 50% de HP): ataca com força dobrada. Isso é exatamente o padrão State: cada fase é um estado com comportamento diferente. Transição automática baseada em HP.

```dart
class BossFaseUm implements EstadoIA {
  @override
  EstadoIA? atualizar(Inimigo self, Jogador alvo, MapaMasmorra mapa) {
    if (self.hp < (self.hpMax * 50 / 100)) {
      print('${self.nome} entra em fúria! Fase 2!');
      return BossFaseDois();
    }
    return null;
  }

  @override
  Acao agir(Inimigo self, Jogador alvo, MapaMasmorra mapa) {
    var proxPasso = mapa.caminhoParaPos(self.pos, alvo.pos);
    return AcaoMover(self, proxPasso, mapa);
  }

  @override
  String get nome => "BossFaseUm";
}

class BossFaseDois implements EstadoIA {
  @override
  EstadoIA? atualizar(Inimigo self, Jogador alvo, MapaMasmorra mapa) {
    return null;
  }

  @override
  Acao agir(Inimigo self, Jogador alvo, MapaMasmorra mapa) {
    int dano = calcularDano(self.arma, alvo.defesa) * 2;
    return AcaoAtacarEspecial(self, alvo, dano);
  }

  @override
  String get nome => "BossFaseDois";
}
```

É como em Dark Souls: cada padrão de ataque é um estado. O chefe muda conforme você o danifica.

## Feedback Visual: Símbolo Muda por Estado

Para o jogador entender em que estado o inimigo está:

O símbolo que renderiza no mapa muda dinamicamente baseado no estado. Um 'z' patrulhando, um 'z!' em alerta, 'Z!!' atacando, 'z...' fugindo. O jogador lê o mapa e instantaneamente entende o estado de cada inimigo. Feedback visual é essencial em jogos; o jogador não consegue ler seu código, mas consegue entender um símbolo.

```dart
class Inimigo {
  String get simbolo {
    return switch (estado) {
      Patrulhando() => 'Z',
      Alerta() => 'z',
      Perseguindo() => 'z!',
      Atacando() => 'Z!!',
      Fugindo() => 'z...',
      _ => '?',
    };
  }
}
```

Agora o jogador vê um "z" (patrulhando) virar "Z!!" (atacando) ao ser descoberto.

## Comparação: Antes vs. Depois

### Antes

O código com if/else aninhados é impossível de seguir. Quantos estados há? Não está claro. Como vai de um para outro? Você tem que ler cada condição, manter na cabeça, rastrear lógica. É mental exaustão.

```dart
if (viu && perto) atacar();
else if (viu && longe) perseguir();
else if (viu && !perto) aguardar();
else if (!viu && turnos > 5) patrulhar();
```

### Depois

Aqui, a máquina de estados é explícita. Cada estado é uma classe independente. Transições são claras (o método `atualizar` retorna um novo estado ou null). O código de execução não muda; é sempre "atualizar, depois agir". Elegante, testável, extensível.

```dart
var novoEstado = estado.atualizar(this, alvo, mapa);
if (novoEstado != null) estado = novoEstado;
var acao = estado.agir(this, alvo, mapa);
```

Claro, lógico, testável.

## Pergaminho do Capítulo

Neste capítulo você aprendeu o padrão State, transformando comportamento complexo e difícil de manter em máquinas de estado finito explícitas e testáveis. Em vez de múltiplos booleanos e if/else aninhados, cada inimigo possui um único `estado` que define seu comportamento e transições. Implementou cinco estados (Patrulhando, Alerta, Perseguindo, Atacando, Fugindo) onde cada um sabe quando transicionar para o próximo baseado em condições claras (distância, linha de visão, HP). Viu como o padrão State torna comportamento visual; o símbolo do inimigo no mapa muda conforme muda o estado, dando feedback instantâneo ao jogador. Finalmente, aplicou State a chefes multi-fases para criar adversários adaptativos que mudam tática conforme você os danifica, como em Dark Souls.

::: dica
**Dica do Mestre:** O padrão State é fundamental em qualquer sistema que tem múltiplos modos de operação. Máquinas de vendas, compiladores, games, interfaces de aplicação; todos usam State internamente. A vantagem principal é que cada estado é isolado e testável: você consegue testar o comportamento de "Patrulhando" sem saber de "Atacando". Máquinas de estado são também visualmente debugáveis; você consegue desenhar um diagrama e comparar com o código. Em desenvolvimento profissional, quando você se deparar com uma classe cheia de booleans e condicionais, pense em State. Seu código futuro (e seus colegas de time) vão agradecer a clareza.
:::

***

## Desafios da Masmorra

**Desafio 36.1. Implemente um estado `Confuso` onde o inimigo anda aleatoriamente durante 5 turnos. Adicione uma estratégia que pode fazer inimigo entrar em pânico quando toma dano crítico.

**Desafio 36.2. Crie um estado `Regenerando` para um inimigo especial que, quando sua HP fica baixa, entra em um ciclo de regeneração onde sua HP sobe 2 por turno durante 8 turnos. Se tomar dano, sai deste estado.

**Desafio 36.3. Implemente um sistema de "Agressão Escalada" onde cada hit que você acerta incrementa um contador que faz o chefe passar por fases mais cedo (fase 2 em 40% de HP em vez de 50%).

**Desafio 36.4. Crie um estado `SaltoEspecial` onde um inimigo pula para uma posição aleatória e depois volta. Integre com a FSM de forma que o inimigo escolhe esse estado aleatoriamente durante perseguição.

**Desafio 36.5. (Desafio). Implemente uma máquina de estado de "Comportamento Imprevisível" onde o boss tem 5 estados (Atacando, Fugindo, Invulnerável, ChamandoMinions, Regenerando), cada um com 30% de chance de ser escolhido quando o anterior termina. Adicione debug logging de cada mudança de estado.

**Desafio 36.7. Implemente um estado `Confuso` com o seguinte comportamento:
- O inimigo anda aleatoriamente durante exatamente 5 turnos
- A cada turno, há 10% de chance de se recuperar (transicionar de volta para `Alerta`)
- Se o inimigo é atacado enquanto confuso, sai do estado imediatamente e vai para `Atacando`
- Adicione uma estratégia que faz o inimigo entrar em pânico quando toma dano crítico (> 50% do HP em uma ação), transitando para `Confuso` por 3 turnos como reflexo defensivo

**Desafio 36.8. Crie um estado `VigiaEspecial` que transiciona automaticamente para `Confuso`:
- Este estado representa um inimigo em alta alerta que vai ficar confuso se não conseguir atacar por muito tempo
- Se o inimigo não consegue atingir o herói em linha reta por 4 turnos consecutivos (está bloqueado), fica confuso
- Use um contador interno `turnosBloquados` que incrementa cada turno se o inimigo não tem linha reta para o herói
- Implemente transição: `VigiaEspecial` -> `Confuso` (quando contador atinge 4) -> `Alerta` (após 5 turnos confuso)

**Desafio 36.9. Implemente um estado `BossEmFuria` que:
- Só é acessível quando o boss tem menos de 20% de HP (estado enraivecido)
- Neste estado, o boss ignora linha de visão e persegue o herói por toda a masmorra
- Ataque a cada turno (não aguarda) com dano aumentado em 50%
- Após 10 turnos de fúria, o boss explode e morre (mecanismo de limite de tempo para evitar combates infinitos)
- Transição visual: símbolo muda para `D!!!` (Dragão em fúria) quando entra neste estado

**Boss Final 36.10. Volte ao Capítulo 34 (Strategy) e substitua os `if/else` aninhados que controlam a IA dos inimigos por uma máquina de estados completa. Implementa estados para o Lobo: Patrulhando (começa aqui), Alerta (quando você está a 5 tiles de distância e tem linha de visão), Perseguindo (quando está a 3 tiles), Atacando (quando está ao lado), Fugindo (quando HP < 25%). O símbolo do Lobo muda a cada estado no mapa: `L` patrulhando, `L?` alerta, `L!` perseguindo, `L!!` atacando, `L..` fugindo. Rode o jogo e observe como a máquina de estados torna o comportamento do inimigo previsível mas estratégico: você consegue "ler" o mapa pelo símbolo e saber exatamente em que estado cada Lobo está.

***

O padrão State transformou comportamento complexo em máquinas de estado explícitas. Agora inimigos têm "vidas" que você consegue visualizar e entender. Cada transição é clara. Cada estado é testável isoladamente.

> *"Uma máquina de estado bem feita é como um roteiro bem escrito: cada cena conhece a próxima, cada personagem conhece seu papel nesta cena, e a audiência acompanha cada passo."*

## Próximo Capítulo

No Capítulo 37, você consolidará tudo que aprendeu sobre design patterns e assincronismo numa aplicação completa. Verá como State, Factory, Observer e Strategy trabalham juntos para criar um ecossistema de jogo coeso. Polirá a interface, salvará o jogo com persistência robusta, e estará pronto para mostrar seu projeto ao mundo como um exemplo de engenharia de software profissional em Dart.
