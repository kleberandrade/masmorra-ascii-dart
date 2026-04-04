# Capítulo 21 - Dungeon Crawl: Juntando Tudo

> *Chegou a hora de deixar de construir peças soltas e montar a máquina completa. O jogador entra na masmorra no primeiro andar, explora em tempo real, combate inimigos quando os encontra, coleta ouro e armas, desce quando encontra a escada, e repete em andares cada vez mais profundos, cada vez mais perigosos. Este capítulo é o pico da Parte III: não é apenas um sistema isolado, é um jogo roguelike completo, jogável do início ao fim.*


## O Que Vamos Aprender

Neste capítulo você vai:

- Criar a classe `ExploradorMasmorra` - o orquestrador supremo
- Implementar um loop de jogo completo: input → update → render
- Gerenciar múltiplos andares com progressão dinâmica
- Integrar combate, colisão, FOV e renderização num fluxo coeso
- Rastrear estatísticas: turnos, inimigos mortos, ouro coletado, andares explorados
- Implementar condições de vitória (atingir andar 5) e derrota (morte do jogador)
- Criar uma tela de game over com resumo de estatísticas
- Demonstrar output completo do jogo funcionando

Ao final, você terá um roguelike dungeon totalmente funcional.


## Parte 1: Conceitualizando o Fluxo

Antes de código, visualize o fluxo completo. Um jogo roguelike não é desordenado; tem uma estrutura clara: inicializa, entra no loop, processa, renderiza, e verifica condições de vitória/derrota. Este diagrama mostra cada etapa e o que fazer em cada uma.

```text
INICIALIZAÇÃO
├─ Criar jogador
├─ Gerar andar 0
├─ Spawnar entidades
├─ Calcular FOV inicial
└─ Mostrar primeira frame

LOOP PRINCIPAL (enquanto vivo)
├─ Limpar tela
├─ Renderizar mapa (respeitando FOV)
├─ Renderizar entidades (respeitando FOV)
├─ Renderizar HUD
├─ Ler input
├─ Processar movimento (colisão)
├─ Recalcular FOV
├─ Verificar morte
├─ Verificar chegada à escada
└─ Próxima iteração

CONDIÇÕES DE SAÍDA
├─ Jogador morre → Game Over
└─ Jogador atinge andar 5 → Vitória!
```


## Parte 2: Classe ExploradorMasmorra - Orquestrador

A classe `ExploradorMasmorra` é o maestro que coordena tudo. Ela mantém o estado do jogo: quem é o jogador, qual é o andar atual, quantos turnos passaram, se o jogo acabou. Oferece métodos principais. `gerarAndar()` cria um mapa novo, `renderizarFrame()` desenha na tela, `processarComando()` lê input do jogador e reage, e `executar()` é o loop infinito que mantém o jogo vivo.

Esta é a orquestração completa: tudo passa por aqui, desde a inicialização até a vitória ou derrota.

```dart
// explorador_masmorra.dart

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
    final mapa = MapaMasmorra.gerar(
      largura: larguraMapa,
      altura: alturaMapa,
    );

    final spawner = GeradorEntidades(
      mapa: mapa,
      andarAtual: andarNumero,
    );

    andarAtual = AndarMasmorra(
      numero: andarNumero,
      mapa: mapa,
      entidades: spawner.spawn(),
    );

    // Encontrar posição inicial passável
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

    mapa.fov.calcularShadowcast(
      Point(jogador.x, jogador.y),
      8,
      mapa,
    );

    maiorAndarAlcancado = andarNumero;
  }

  void renderizarFrame() {
    tela.limpar();

    andarAtual.mapa.renderizarNaTela(tela);

    for (final entidade in andarAtual.entidades) {
      if (fov.estaVisivel(entidade.x, entidade.y)) {
        tela.desenharChar(entidade.x, entidade.y, entidade.simbolo);
      }
    }

    jogador.renderizarNaTela(tela);

    _renderizarHUD();
    tela.renderizar();
  }

  void _renderizarHUD() {
    final hudY = alturaMapa + 1;
    final hpBar = _construirBarraHP();

    tela.desenharString(0, hudY, '═' * larguraMapa);
    tela.desenharString(
      0,
      hudY + 1,
      'Andar: $andarNumero | Turno: $turno | $hpBar ${jogador.hpAtual}/${jogador.hpMax}',
    );
    tela.desenharString(
      0,
      hudY + 2,
      'Ouro: ${jogador.ouro} | Inimigos: ${totalInimigosDefeitos}',
    );
    tela.desenharString(0, hudY + 3, '[W]cima [A]esq [S]baixo [D]dir [I]nventário [Q]uit');
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
    int novoX = jogador.x;
    int novoY = jogador.y;

    switch (direcao.toLowerCase()) {
      case 'w': novoY--;
      case 's': novoY++;
      case 'a': novoX--;
      case 'd': novoX++;
    }

    if (!andarAtual.mapa.ehPassavel(novoX, novoY)) {
      return;
    }

    final entidade = andarAtual.encontrarEntidadeEm(novoX, novoY);
    if (entidade != null) {
      if (entidade is EntidadeInimigo) {
        // Combate
        final vitoria = _executarCombate(entidade.inimigo);
        if (!vitoria) {
          jogador.hpAtual = 0;
          return;
        }
        andarAtual.removerEntidade(entidade);
        totalInimigosDefeitos++;
        jogador.ouro += 25;
      } else if (entidade is EntidadeItem) {
        entidade.aoTocada(jogador);
        andarAtual.removerEntidade(entidade);
      } else if (entidade is EntidadeEscada) {
        andarNumero++;
        if (andarNumero >= andarFinal) {
          vitoria = true;
          emJogo = false;
        } else {
          gerarAndar();
        }
        return;
      }
    }

    jogador.x = novoX;
    jogador.y = novoY;
    turno++;

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
    gerarAndar();

    while (emJogo && jogador.hpAtual > 0) {
      renderizarFrame();

      stdout.write('> ');
      final entrada = stdin.readLineSync() ?? '';
      processarComando(entrada);
    }

    _mostrarGameOver();
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
    print('║${alinhar(' Inimigos Derrotados:', totalInimigosDefeitos)}║');
    print('║${alinhar(' Ouro Total:', jogador.ouro)}║');
    print('╚${'═' * largura}╝\n');
  }
}
```

### Máquina de Estados do Jogo

Um jogo bem estruturado tem estados claros e bem definidos. Você não está sempre explorando; às vezes está em combate tático, abrindo inventário, em transição entre andares, ou vendo a tela de morte. Use um enum para organizar estes estados distintos:

```dart
// game_state.dart

enum EstadoJogo {
  exploracao,
  combate,
  inventario,
  transicaoAndar,
  gameOver,
  vitoria,
}

class GerenciadorEstado {
  EstadoJogo estadoAtual = EstadoJogo.exploracao;

  void transicionar(EstadoJogo novoEstado) {
    print('Transição: ${estadoAtual.name} → ${novoEstado.name}');
    estadoAtual = novoEstado;
  }

  bool podeMovimentar() {
    return estadoAtual == EstadoJogo.exploracao;
  }

  bool podeAberturaInventario() {
    return estadoAtual == EstadoJogo.exploracao ||
        estadoAtual == EstadoJogo.inventario;
  }
}
```

### Transição de Andares com Efeitos

Descer para um novo andar é mais que mudar o número do andar. É lidar com efeitos visuais de transição, spawn novo de entidades, dificuldade aumentando gradualmente. A progressão deve oferecer tensão crescente que faz o jogador sentir o peso de descer mais fundo:

```dart
// transicao_andares.dart

class GerenciadorTransicao {
  void descerParaProximoAndar(
    ExploradorMasmorra explorador,
    GerenciadorEstado estado,
  ) {
    // 1. Efeito visual: "Você desce as escadas..."
    _mostrarTransicao(explorador.andarNumero, explorador.andarNumero + 1);

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

O jogo deve verificar continuamente se o jogador venceu ou perdeu. Uma abordagem limpa é centralizar essa lógica:

```dart
// condicoes_jogo.dart

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

Quando você executa o jogo, tudo começa aqui. Cria um jogador, cria um explorador, e chama `executar()`. A partir daí, é loop infinito até você morrer ou vencer. Isto é o ponto de entrada.

```dart
// main.dart

import 'dart:io';

void main() {
  final jogador = Jogador(
    nome: 'Aventureiro',
    hpMax: 100,
    ouro: 0,
  );

  final explorador = ExploradorMasmorra(
    jogador: jogador,
    larguraMapa: 80,
    alturaMapa: 24,
    andarFinal: 5,
  );

  explorador.executar();
}
```


### O Jogo Até Aqui

Ao final desta parte, seu dungeon crawl no terminal se parece com isto:

```
MASMORRA - Andar 1          Turno: 23

  ##########
  #........#####
  #.@..........#
  #....G.......#
  #........#####
  ####.#####
     #.#
  ####.####
  #........#
  #....Z...#
  #........>
  ##########

HP: [████████░░] 80/100
XP: 120/300 (Nv.2) | Ouro: 45

Comandos: [W]cima [A]esq [S]baixo [D]dir [Q]uit [I]nventário

>
```

Cada parte adiciona novas camadas ao jogo. Compare com o início e veja o quanto você evoluiu!

***

## Desafios da Masmorra

**Desafio 21.1. Melhorar o HUD.** Adicione mais informações na HUD: nível atual, XP para próximo nível, quantos inimigos você derrotou neste andar.

**Desafio 21.2. Tela de Pausa.** Implemente um comando `p` (pause) que para o jogo e mostra um menu: continuar, salvar, sair.

**Desafio 21.3. Animação de Movimento.** Adicione um pequeno delay ao movimento (`Future.delayed()` ou `sleep()`) para que o jogador veja os passos acontecendo lentamente na tela.

**Desafio 21.4. Log de Eventos.** Adicione um `List<String> logEventos` que registra o que aconteceu: "Você matou Zumbi", "Pegou ouro", "Subiu de nível". Mostre os últimos 3-5 eventos na HUD.

**Boss Final 21.5. Volte à classe `TelaAscii` do Capítulo 16.** Adicione cores ANSI para cada tipo de tile: verde para chão (`.`), cinza para paredes (`#`), vermelho para inimigos, amarelo para ouro, azul para escada (`>`). Execute o dungeon crawl inteiro e veja como cores melhoram a clareza visual do mapa. Dica: use códigos de escape como `'\x1B[32m'` para verde, `'\x1B[0m'` para resetar.

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

Neste capítulo final da Parte III, você juntou tudo: geração, entidades, visão, colisão, renderização. Num jogo roguelike completo e jogável. Começou visualizando o fluxo completo: inicialização, loop principal (renderizar → input → update), e verificação de vitória/derrota. Implementou `ExploradorMasmorra`, a orquestração central que coordena tudo: geração de andares, renderização com FOV, processamento de comandos, detecção de colisão com entidades, e transição entre andares. Criou `GerenciadorEstado` usando enum para organizar estados distintos (exploração, combate, inventário, transição, game over), permitindo lógica limpa e previsível. Implementou `GerenciadorTransicao` que cuida da descida entre andares: efeitos visuais, geração de novo andar com dificuldade crescente, recuperação de HP. Criou `VerificadorCondicoes` que centraliza toda lógica de vitória/derrota e geração de estatísticas finais. O resultado: um jogo onde o jogador entra em um andar procedural gerado, explora com névoa de guerra real, encontra inimigos que pode combater, coleta itens, desce andares cada vez mais perigosos, e eventualmente escapa ou morre. Tudo com feedback claro e estatísticas ao fim.

Você aprendeu a construir um roguelike completo:

- Capítulo 15: Grids 2D e movimento básico
- Capítulo 16: Renderização profissional com MVC
- Capítulo 17: Aleatoriedade controlada com sementes
- Capítulo 18: Geração procedural (Random Walk e Rooms & Corridors)
- Capítulo 19: Campo de visão e névoa de guerra
- Capítulo 20: Entidades polimórficas e spawn dinâmico
- Capítulo 21: Orquestração completa e loop de jogo

De um simples explorador de texto para um roguelike pleno e jogável. Este é o poder da programação orientada a objetos, padrões de design e algoritmos clássicos de game design.

Você tem agora a base para expandir: mais inimigos, mais itens, mais algoritmos de IA, mais mundos. O céu é o limite.

**Bem-vindo ao reino dos roguelikes.**
