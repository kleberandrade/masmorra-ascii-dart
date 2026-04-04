# Capítulo 21 - Dungeon Crawl: Juntando Tudo

> *Chegou a hora de deixar de construir peças soltas e montar a máquina completa. O jogador entra na masmorra no primeiro andar, explora em tempo real, combate inimigos quando os encontra, coleta ouro e armas, desce quando encontra a escada, e repete em andares cada vez mais profundos, cada vez mais perigosos. Este capítulo é o pico da Parte III: não é apenas um sistema isolado, é um jogo roguelike completo, jogável do início ao fim.*


## O Que Vamos Aprender

Neste capítulo você vai:

- Criar a classe `ExploradorMasmorra` - o orquestrador supremo
- Implementar um loop de jogo completo: input → update → render
- Gerenciar múltiplos andares com progressão dinâmica
- Integrar combate, colisão, *FOV* e renderização num fluxo coeso
- Rastrear estatísticas: turnos, inimigos mortos, ouro coletado, andares explorados
- Implementar condições de vitória (atingir andar 5) e derrota (morte do jogador)
- Criar uma tela de game over com resumo de estatísticas
- Demonstrar output completo do jogo funcionando

Ao final, você terá um *roguelike* dungeon totalmente funcional.


## Parte 1: Conceitualizando o Fluxo

Antes de código, visualize o fluxo completo. Um jogo *roguelike* não é desordenado; tem uma estrutura clara: inicializa, entra no loop, processa, renderiza, e verifica condições de vitória/derrota. Este diagrama mostra cada etapa e o que fazer em cada uma.

Até agora você construiu blocos individuais: gerador de mapas (Cap 12), renderização (Cap 15), *FOV* (Cap 19), combate (Cap 18), entidades (Cap 20). Agora junta tudo num orquestrador central que coordena cada peça. A classe `ExploradorMasmorra` é esse coração: ela mantém o estado completo do jogo (jogador, mapa, entidades, turnos), lê input, atualiza lógica e renderiza a tela. Sem essa orquestração, você teria partes desconexas. Com ela, temos um jogo coerente.

Fluxo do jogo: inicialização, loop principal e condições de saída. A fonte editável do diagrama está em `assets/diagrams/capitulo-021-fluxo-jogo.mmd`; o PNG é gerado em `./scripts/build.sh` com Node.js/npx (`@mermaid-js/mermaid-cli`).

![Fluxo do jogo: inicialização, loop principal e condições de saída](assets/diagrams/capitulo-021-fluxo-jogo.png)


## Parte 2: Classe ExploradorMasmorra - Orquestrador

A classe `ExploradorMasmorra` é o maestro que coordena tudo. Ela mantém o estado do jogo: quem é o jogador, qual é o andar atual, quantos turnos passaram, se o jogo acabou. Oferece métodos principais: `gerarAndar()` cria um mapa novo (integra Capítulo 12), `renderizarFrame()` desenha na tela respeitando *FOV* (integra Capítulos 15 e 19), `processarComando()` lê input do jogador e reage (lógica de movimento e colisão), e `executar()` é o loop infinito que mantém o jogo vivo.

Esta é a orquestração completa: tudo passa por aqui, desde a inicialização até a vitória ou derrota. O padrão de design aqui é **Facade**: um único ponto de entrada que esconde a complexidade de múltiplos subsistemas trabalhando em harmonia.

### Por Que Orquestração Centralizada?

Você poderia ter cada sistema (renderização, input, colisão) rodando independentemente. Mas isso criaria caos: quem decide quando renderizar? Quem processa input? Como sincronizam? A resposta é simples: um orquestrador central. Ele mantém o controle, garante que eventos acontecem na ordem correta (sempre render → input → update → verify), e evita *race conditions* ou estados inconsistentes. Em jogos maiores, isso evoluiria para um engine de eventos ou máquina de estados, mas o princípio é o mesmo: coordenação central cria previsibilidade.

```dart
// lib/explorador_masmorra.dart

class ExploradorMasmorra {
  final Jogador jogador;
  late AndarMasmorra andarAtual;
  late TelaAscii tela;

  final int larguraMapa;
  final int alturaMapa;
  final int andarFinal;

  int andarNumero = 0;
  int turno = 0;
  bool emJogo = true;
  bool vitoria = false;

  int totalInimigosDefeitos = 0;
  int maiorAndarAlcancado = 0;

  ExploradorMasmorra({
    required this.jogador,
    this.larguraMapa = 60,
    this.alturaMapa = 20,
    this.andarFinal = 3,
  }) {
    tela = TelaAscii(largura: larguraMapa, altura: alturaMapa + 5);
  }

  void gerarAndar() {
    // 1. Gerar novo mapa proceduralmente (Cap 12)
    final mapa = MapaMasmorra.gerar(
      largura: larguraMapa,
      altura: alturaMapa,
    );

    // 2. Spawnar entidades (inimigos, itens) progressivas (Cap 20)
    final spawner = GeradorEntidades(
      mapa: mapa,
      andarAtual: andarNumero, // ← Dificuldade aumenta a cada andar
    );

    andarAtual = AndarMasmorra(
      numero: andarNumero,
      mapa: mapa,
      entidades: spawner.spawn(),
    );

  // 3. Encontrar posição inicial passável (não começa dentro de parede)
   
    bool encontrou = false;
    for (int y = 1; y < alturaMapa - 1 && !encontrou; y++) {
      for (int x = 1; x < larguraMapa - 1 && !encontrou; x++) {
        if (mapa.ehPassavel(x, y)) {
          jogador.x = x;
          jogador.y = y;
          encontrou = true;
        }
      }
    }

    // 4. Calcular *FOV* inicial (Cap 19)
    mapa.fov.calcularShadowcast(
      Point(jogador.x, jogador.y),
      8,
      mapa,
    );

    maiorAndarAlcancado = andarNumero;
  }

  void renderizarFrame() {
    tela.limpar();

    // Camada 1: Mapa respeitando *FOV* (Cap 15 + Cap 19)
    andarAtual.mapa.renderizarNaTela(tela);

    // Camada 2: Entidades (inimigos, itens) apenas se visíveis
    for (final entidade in andarAtual.entidades) {
      if (andarAtual.mapa.fov.estaVisivel(entidade.x, entidade.y)) {
        tela.desenharChar(entidade.x, entidade.y, entidade.simbolo);
      }
    }

    // Camada 3: Jogador sempre visível (está sobre tudo)
    jogador.renderizarNaTela(tela);

    _renderizarHUD();
    tela.renderizar(); // ← Enviar buffer para terminal
  }

  void _renderizarHUD() {
    final hudY = alturaMapa + 1;
    final hpBar = _construirBarraHP();

    tela.desenharString(0, hudY, '═' * larguraMapa);
    tela.desenharString(
      0,
      hudY + 1,
      'Andar: $andarNumero | Turno: $turno | $hpBar '
      '${jogador.hpAtual}/${jogador.hpMax}',
    );
    tela.desenharString(
      0,
      hudY + 2,
      'Ouro: ${jogador.ouro} | Inimigos: ${totalInimigosDefeitos}',
    );
    tela.desenharString(0, hudY + 3,
        '[W]cima [A]esq [S]baixo [D]dir [I]nv [Q]uit');
  }

  String _construirBarraHP() {
    const blocos = 5;
    final cheios = (jogador.hpAtual / jogador.hpMax * blocos).toInt();
    final vazios = blocos - cheios;
    return '█' * cheios + '░' * vazios;
  }

  void processarComando(String comando) {
    switch (comando.toLowerCase()) {
      case 'w' || 'a' || 's' || 'd':
        _processarMovimento(comando);
      case 'i':
        _mostrarInventario();
      case 'q':
        emJogo = false;
      default:
        // Ignorar
    }
  }

  void _processarMovimento(String direcao) {
    // Calcular próxima posição
    int novoX = jogador.x;
    int novoY = jogador.y;

    switch (direcao.toLowerCase()) {
      case 'w': novoY--; // ← Cima
      case 's': novoY++; // ← Baixo
      case 'a': novoX--; // ← Esquerda
      case 'd': novoX++; // ← Direita
    }

    // Verificar colisão com parede
    if (!andarAtual.mapa.ehPassavel(novoX, novoY)) {
      return; // ← Não se move, turno não avança
    }

    // Verificar colisão com entidade (inimigo, item, escada)
    final entidade = andarAtual.encontrarEntidadeEm(novoX, novoY);
    if (entidade != null) {
      if (entidade is EntidadeInimigo) {
        // COMBATE: Ataque direto
        final vitoria = _executarCombate(entidade.inimigo);
        if (!vitoria) {
          // ← Morte (jogo acabará no loop principal)
          jogador.hpAtual = 0;
          return;
        }
        andarAtual.removerEntidade(entidade);
        totalInimigosDefeitos++;
        jogador.ouro += 25; // ← Recompensa
      } else if (entidade is EntidadeItem) {
        // COLETA: Item é consumido/coletado
        entidade.aoTocada(jogador);
        andarAtual.removerEntidade(entidade);
      } else if (entidade is EntidadeEscada) {
        // DESCIDA: Próximo andar
        andarNumero++;
        if (andarNumero >= andarFinal) {
          vitoria = true; // ← Vitória!
          emJogo = false;
        } else {
          gerarAndar(); // ← Gerar próximo andar com mais dificuldade
        }
        return;
      }
    }

    // Se chegou aqui, movimento é válido
    jogador.x = novoX;
    jogador.y = novoY;
    turno++;

    // Recalcular *FOV* para nova posição (Cap 19)
    andarAtual.mapa.fov.calcularShadowcast(
      Point(jogador.x, jogador.y),
      8,
      andarAtual.mapa,
    );
  }

  bool _executarCombate(Inimigo inimigo) {
    // Simplificado: jogador sempre ganha
    return true;
  }

  void _mostrarInventario() {
    // Implementar depois
  }

  void executar() {
    print('=== MASMORRA ASCII: Dungeon Crawl ===\n');
    gerarAndar(); // ← Inicialização: criar andar 0

    // LOOP PRINCIPAL: Render → Input → Update
    while (emJogo && jogador.hpAtual > 0) {
      renderizarFrame(); // ← Desenhar tela atual

      stdout.write('> ');
      final entrada = stdin.readLineSync() ?? ''; // ← Ler input
      // ← Processar comando (move, inventário, etc)
      processarComando(entrada);

      // Após comando, colisão e *FOV* já foram processados.
    }

    _mostrarGameOver(); // ← Condição de saída atingida
  }

  void _mostrarGameOver() {
    final largura = 40;
    String centralizar(String texto) {
      final espacos = (largura - texto.length) ~/ 2;
      return ' ' * espacos + texto;
    }
    String alinhar(String rotulo, dynamic valor) {
      final conteudo = '$rotulo $valor';
      return conteudo.padRight(largura);
    }

    print('\n╔${'═' * largura}╗');
    if (vitoria) {
      print('║${centralizar('ESCAPOU DA MASMORRA!')}║');
      print('║${centralizar('PARABÉNS!')}║');
    } else {
      print('║${centralizar('GAME OVER')}║');
      print('║${centralizar('Caiu na masmorra...')}║');
    }
    print('╠${'═' * largura}╣');
    print('║${alinhar(' Estatísticas:', '')}║');
    print('║${alinhar(' Turnos:', turno)}║');
    print('║${alinhar(' Maior Andar:', maiorAndarAlcancado)}║');
    var inimigosText = alinhar(
      ' Inimigos Derrotados:',
      totalInimigosDefeitos,
    );
    print('║$inimigosText║');
    print('║${alinhar(' Ouro Total:', jogador.ouro)}║');
    print('╚${'═' * largura}╝\n');
  }
}
```

### Máquina de Estados do Jogo

Um jogo bem estruturado tem estados claros e bem definidos. Você não está sempre explorando; às vezes está em combate tático, abrindo inventário, em transição entre andares, ou vendo a tela de morte. Uma máquina de estados formaliza isso: cada estado tem comportamentos permitidos e transições bem definidas. Por exemplo, em exploração você pode mover-se; em combate você só pode atacar ou defender; em inventário você só pode equipar itens. Sem estados, você teria if/else aninhados no movimento checando "estou em combate?", "estou em inventário?", gerando código acoplado e frágil.

Use um enum para organizar estes estados distintos, e um gerenciador para as transições:

```dart
// lib/game_state.dart

enum EstadoJogo {
  exploracao,      // ← Andando, vendo o mapa
  combate,         // ← Em luta com inimigo
  inventario,      // ← Menu de itens
  transicaoAndar,  // ← Descendo escada (efeito visual)
  gameOver,        // ← Morte (jogo acabou)
  vitoria,         // ← Venceu (jogo acabou)
}

class GerenciadorEstado {
  EstadoJogo estadoAtual = EstadoJogo.exploracao;

  void transicionar(EstadoJogo novoEstado) {
    print('Transição: ${estadoAtual.name} → ${novoEstado.name}');
    estadoAtual = novoEstado;
  }

  // Verificar transições válidas
  bool podeMovimentar() {
    // Só pode mover em exploração normal
    return estadoAtual == EstadoJogo.exploracao;
  }

  bool podeAbrirInventario() {
    // Pode abrir inventário enquanto explora ou já está no inventário
    return estadoAtual == EstadoJogo.exploracao ||
        estadoAtual == EstadoJogo.inventario;
  }

  bool estaVivo() {
    // Jogo ainda corre se não está em game over ou vitória
    return estadoAtual != EstadoJogo.gameOver &&
        estadoAtual != EstadoJogo.vitoria;
  }
}
```

### Transição de Andares com Efeitos

Descer para um novo andar é mais que mudar o número do andar. É lidar com efeitos visuais de transição, *spawn* novo de entidades, dificuldade aumentando gradualmente. A progressão deve oferecer tensão crescente que faz o jogador sentir o peso de descer mais fundo.

Quando o jogador chega à escada, você entra em um estado de transição especial. Aqui você pode:
1. Parar a renderização normal (criar um efeito de "descendo...")
2. Atualizar dificuldade (mais inimigos, mais fortes)
3. Recuperar um pouco de HP (recompensa por sobreviver)
4. Voltar à exploração no novo andar

Isso torna cada descida um evento narrativo, não apenas um carregamento de nível:

```dart
// lib/transicao_andares.dart

class GerenciadorTransicao {
  void descerParaProximoAndar(
    ExploradorMasmorra explorador,
    GerenciadorEstado estado,
  ) {
    // 1. Efeito visual: "Você desce as escadas..."
    _mostrarTransicao(
      explorador.andarNumero,
      explorador.andarNumero + 1,
    );

    // 2. Atualizar estado
    explorador.andarNumero++;
    estado.transicionar(EstadoJogo.transicaoAndar);

    // 3. Gerar novo andar (com mais dificuldade)
    explorador.gerarAndar();

    // 4. Recuperar um pouco de HP (tensão + recompensa)
    explorador.jogador.hpAtual = (explorador.jogador.hpAtual + 15)
        .clamp(0, explorador.jogador.hpMax);

    // 5. Voltar à exploração
    estado.transicionar(EstadoJogo.exploracao);

    print('Você desceu para o andar ${explorador.andarNumero}');
  }

  void _mostrarTransicao(int andarAtual, int proximoAndar) {
    print('\n...');
    sleep(Duration(milliseconds: 300));
    print('Você desce as escadas...');
    sleep(Duration(milliseconds: 500));
    print('...');
    sleep(Duration(milliseconds: 300));
    print('Andar $proximoAndar alcançado!\n');
  }
}
```

### Sistema de Condições de Vitória/Derrota

O jogo deve verificar continuamente se o jogador venceu ou perdeu. Uma abordagem limpa é centralizar essa lógica numa classe dedicada. Isso separa a responsabilidade: o orquestrador coordena, mas a verificação de condições vive num lugar bem definido. Quando o HP chega a 0 ou o jogador alcança o andar final, a classe informa ao orquestrador que o jogo acabou:

```dart
// lib/condicoes_jogo.dart

class VerificadorCondicoes {
  /// Verifica se o jogador morreu
  bool jogadorMorreu(Jogador jogador) {
    return jogador.hpAtual <= 0;
  }

  /// Verifica se o jogador venceu
  bool jogadorVenceu(int andarAtual, int andarFinal) {
    return andarAtual >= andarFinal;
  }

  /// Gera estatísticas finais
  EstatisticasJogo gerarEstatisticas(
    ExploradorMasmorra explorador,
  ) {
    return EstatisticasJogo(
      turnosJogados: explorador.turno,
      maiorAndarAlcancado: explorador.maiorAndarAlcancado,
      inimigosDefeitos: explorador.totalInimigosDefeitos,
      ouroColetado: explorador.totalOuroColetado,
      tempoJogo: DateTime.now(),
      jogadorVenceu: explorador.vitoria,
    );
  }
}

class EstatisticasJogo {
  final int turnosJogados;
  final int maiorAndarAlcancado;
  final int inimigosDefeitos;
  final int ouroColetado;
  final DateTime tempoJogo;
  final bool jogadorVenceu;

  EstatisticasJogo({
    required this.turnosJogados,
    required this.maiorAndarAlcancado,
    required this.inimigosDefeitos,
    required this.ouroColetado,
    required this.tempoJogo,
    required this.jogadorVenceu,
  });

  void imprimirResumo() {
    final resultado = jogadorVenceu ? 'VITÓRIA' : 'DERROTA';
    print('\n╔════════════════════════════════════════╗');
    print('║       RESULTADO: $resultado         ║');
    print('╠════════════════════════════════════════╣');
    print('║ Turnos: $turnosJogados');
    print('║ Maior Andar: $maiorAndarAlcancado');
    print('║ Inimigos Derrotados: $inimigosDefeitos');
    print('║ Ouro Total: $ouroColetado');
    print('║ Data/Hora: ${tempoJogo.toString()}');
    print('╚════════════════════════════════════════╝\n');
  }
}
```

## Exemplo Completo: Main

Quando você executa o jogo, tudo começa aqui. O arquivo `main.dart` é o ponto de entrada: cria um jogador, cria um explorador com os parâmetros desejados (tamanho do mapa, número final de andares), e chama `executar()`. A partir daí, o orquestrador assume o controle e não solta até você morrer ou vencer. Este é um exemplo de padrão **Builder** simplificado: você constrói os objetos necessários e depois passa para um controlador central.

Note que você pode experimentar facilmente modificando os parâmetros aqui: aumentar `alturaMapa` para um mapa maior, aumentar `andarFinal` para uma progressão mais longa, etc. Toda a lógica do jogo roda independente de que tamanho o mapa tem ou quantos andares existem.

```dart
// main.dart

import 'dart:io';

void main() {
  // 1. Criar jogador com stats iniciais
  final jogador = Jogador(
    nome: 'Aventureiro',
    hpMax: 100,
    ouro: 0, // ← Começar pobre, enriquecer matando inimigos
  );

  // 2. Criar explorador (orquestrador) com configurações de jogo
  final explorador = ExploradorMasmorra(
    jogador: jogador,
    larguraMapa: 80,    // ← Largura de cada andar
    alturaMapa: 24,     // ← Altura de cada andar
    andarFinal: 5,      // ← Vencer ao atingir andar 5
  );

  // 3. Executar: inicia o loop infinito até morte ou vitória
  explorador.executar();
}
```


### O Jogo Até Aqui - Saída Esperada

Quando você executa `dart main.dart` e joga por alguns turnos, a saída parece assim:

```text
=== MASMORRA ASCII: Dungeon Crawl ===

#####################
#..........·········#
#.@.G......·········#
#..........·········#
###....###·····#####·
····#····#·····#····
····#····#·····#····
#####....####Z####···
#···................#
#···...........E...#
#···................>
#####################

═══════════════════════════════════════
Andar: 0 | Turno: 15 | [████░░░░░░] 75/100
Ouro: 50 | Inimigos: 1
[W]cima [A]esq [S]baixo [D]dir [I]nventário [Q]uit
> d
```

Explicação da saída:
- `@` = Jogador
- `G` = Goblin visível
- `E` = Esqueleto visível
- `Z` = Zumbi visível
- `>` = Escada para próximo andar
- `.` = Piso visível
- `·` = Piso explorado (fora do *FOV*)
- ` ` (espaço) = Nunca visto
- `#` = Parede opaca

O HUD mostra: número do andar, turnos passados, barra de HP, ouro coletado, inimigos derrotados, e controles disponíveis.

Cada turno que você se move, o *FOV* recalcula (imperceptível para o jogador), e a névoa de guerra revela novos tiles enquanto você explora. Quando encontra um inimigo visível (dentro do *FOV*), pode atacar movendo-se para ele. Quando encontra a escada, desce para o próximo andar com mais dificuldade.

## Apêndice: Códigos de Escape ANSI para Cores

Se você quiser adicionar cores ao jogo (Boss Final 21.5), aqui está o essencial sobre *ANSI escape codes*. Terminais modernos interpretam sequências especiais que controlam formatação, cores e posicionamento de cursor.

A sintaxe básica é: `\x1B[<código>m`, onde `\x1B` é o caractere ESC e `<código>` é o comando.

Cores de foreground (texto):
- `\x1B[30m` = Preto
- `\x1B[31m` = Vermelho (para inimigos)
- `\x1B[32m` = Verde (para chão)
- `\x1B[33m` = Amarelo (para ouro)
- `\x1B[34m` = Azul (para escada)
- `\x1B[37m` = Branco / `\x1B[90m` = Cinza (para paredes)
- `\x1B[0m` = Reset (volta ao padrão)

Exemplo de uso:
```dart
String textoVerde = '\x1B[32m.\x1B[0m'; // Piso verde normal
String textoVermelho = '\x1B[31mG\x1B[0m'; // Goblin em vermelho
stdout.write(textoVermelho);
```

Integrar cores é simples: ao desenhar cada tile, imprima o código ANSI antes do caractere e um reset depois. O terminal cuida da formatação. Cuidado: nem todos os terminais suportam ANSI (especialmente Windows antigo), mas Windows 10+ e todos os terminais Unix suportam nativamente.

## Integração com Capítulos Anteriores

Este capítulo é o pico de integração. Tudo que você aprendeu até aqui converge:

- **Capítulo 12** *(Gerador de Mapas)*: `MapaMasmorra.gerar()` cria cada andar proceduralmente
- **Capítulo 15** *(Grid e Renderização)*: `TelaAscii` e `renderizarNaTela()` desenham cada frame
- **Capítulo 18** *(Combate)*: `_executarCombate()` resolve encontros com inimigos
- **Capítulo 19** *(Campo de Visão)*: `fov.calcularShadowcast()` recalcula a cada movimento
- **Capítulo 20** *(Entidades)*: `GeradorEntidades` popula cada andar com criatura e itens

`ExploradorMasmorra` orquestra todos esses subsistemas num loop coeso. A máquina de estados (exploração → combate → transição de andares → game over) controla o fluxo. O resultado: um *roguelike* jogável do início ao fim.

## Design Decision: Por Que Não Input Assíncrono?

Você pode estar pensando: por que bloquear em `stdin.readLineSync()`? Não seria melhor ler input assincronamente enquanto o jogo atualiza em paralelo? A resposta é **simplicidade vs. complexidade**. Em um jogo baseado em turnos (como este), bloquear em input é natural: o jogador faz uma ação, o jogo processa, o jogo renderiza. Não há necessidade de concorrência. Input assincronamente adicionaria channels, futures e race conditions sem benefício real. Em um jogo com tempo real (como um *action RPG* ou *FPS*), você precisaria de input não-bloqueante; mas em um *roguelike* turn-based, simplicidade vence.

## Dica Profissional

::: dica
Escalabilidade do loop de jogo em produção: o loop apresentado aqui é funcional, mas em um jogo real você pode encontrar gargalos. Considere separar completamente entrada (I/O bloqueante) da lógica de jogo usando filas de comando ou channels. Para jogos mais complexos, implemente deltaTime em vez de turnos síncronos, permitindo frames consistentes em diferentes máquinas. Salvar o estado completo (seed do mapa, posição jogador, turnos) permite implementar rewind ou replay, funcionalidades muito valorizadas em comunidades de speedrunning e streaming.
:::

***

## Desafios da Masmorra

### Desafios Básicos

**Desafio 21.1. Melhorar o HUD.** Adicione mais informações na HUD: nível atual, XP para próximo nível, quantos inimigos você derrotou neste andar.

**Desafio 21.2. Tela de Pausa.** Implemente um comando `p` (pause) que para o jogo e mostra um menu: continuar, salvar, sair.

### Desafios Avançados

**Desafio 21.3. Animação de Movimento.** Adicione um pequeno delay ao movimento (`Future.delayed()` ou `sleep()`) para que o jogador veja os passos acontecendo lentamente na tela.

**Desafio 21.4. Log de Eventos.** Adicione um `List<String> logEventos` que registra o que aconteceu: "Você matou Zumbi", "Pegou ouro", "Subiu de nível". Mostre os últimos 3-5 eventos na HUD.

**Boss Final 21.5. Cores ANSI - Cores no Terminal.** Volte à classe `TelaAscii` do Capítulo 16 e adicione suporte a cores ANSI (*ANSI escape codes*). Cada tipo de tile deve ter sua cor: verde para chão (`.`), cinza para paredes (`#`), vermelho para inimigos, amarelo para ouro, azul para escada (`>`). Códigos de escape ANSI são sequências especiais que o terminal interpreta como comandos de formatação. Por exemplo, `'\x1B[32m'` ativa verde, `'\x1B[31m'` ativa vermelho, e `'\x1B[0m'` reseta para padrão. Implemente um método `desenharCharComCor(int x, int y, String char, String corAnsi)` na `TelaAscii` e modifique `_renderizarMapaComFOV()` para usar cores de acordo com o tile. Execute o dungeon crawl inteiro e veja como cores melhoram drasticamente a clareza visual do mapa sem adicionar complexidade.

::: dica
**Dica do Mestre:** Escalabilidade do loop de jogo em produção: o loop apresentado aqui é funcional, mas em um jogo real você pode encontrar gargalos. Considere separar completamente entrada (I/O bloqueante) da lógica de jogo. Use filas de comando ou channels para desacoplar a leitura do stdin do update lógico. Para jogos mais complexos, implemente um deltaTime (time stepping) em vez de turnos síncronos:

```dart
void executarComDeltaTime() {
  final stopwatch = Stopwatch()..start();
  const targetFrameTime = 1000 ~/ 60; // 60 FPS = ~16ms por frame

  while (emJogo && jogador.hpAtual > 0) {
    renderizarFrame();

    final deltaTimeMs = stopwatch.elapsedMilliseconds;
    if (deltaTimeMs < targetFrameTime) {
      sleep(Duration(milliseconds: targetFrameTime - deltaTimeMs));
    }

    stopwatch.reset();
  }
}
```

Além disso, salvar o estado completo (seed do mapa, posição jogador, turnos) permite implementar rewind ou replay de sessões, uma funcionalidade muito valorizada em comunidades speedrunning e streaming de roguelikes.
:::

## Pergaminho do Capítulo

- Fluxo completo do jogo: inicialização, loop principal (renderizar → input → update), verificação de vitória/derrota
- Classe `ExploradorMasmorra` orquestrando centralizado: geração, renderização, input, colisão, transição de andares
- Enum `EstadoJogo` organizando estados distintos: exploração, combate, inventário, transição, game over
- Máquina de estados com `GerenciadorEstado` permitindo lógica limpa e previsível
- Classe `GerenciadorTransicao` cuidando de descidas: efeitos visuais, geração com dificuldade crescente, recuperação de HP
- Classe `VerificadorCondicoes` centralizando lógica de vitória/derrota e estatísticas finais
- Loop principal integrado com stdin/stdout permitindo exploração interativa tempo-real
- Tela de game over com resumo de estatísticas: turnos, andar máximo, inimigos derrotados, ouro coletado

## Próximo Capítulo

No Capítulo 22, vamos adicionar profundidade econômica ao jogo. Preços, *drops*, tabelas de saque e balanceamento de dificuldade por andar transformarão a masmorra de uma sequência de lutas numa experiência estratégica com decisões significativas.

***
