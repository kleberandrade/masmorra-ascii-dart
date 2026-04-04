# Capítulo 19 - Campo de Visão e a Névoa de Guerra

> *Na escuridão, o medo toma forma. Você sabe que o perigo está aí, mas não consegue vê-lo. Quando a tocha ilumina uma divisão inesperada e novos inimigos surgem, o jogo respira diferente. Essa tensão da névoa de guerra é o ingrediente secreto que transforma uma grade de caracteres num mundo vivo.*


## O Que Vamos Aprender

Neste capítulo você vai aprender a implementar **campo de visão** (*FOV*) e **névoa de guerra**.

Especificamente:
- Três estados de um tile: unseen, seen (explorado), visible (iluminado)
- Estrutura de dados eficiente: `Set<Point<int>>`
- Algoritmo simples: *FOV* por círculo dentro de raio R
- Algoritmo avançado: Shadowcasting (raios em 8 direções)
- Linha visual (*Bresenham*-like): detectar se parede bloqueia visão
- Integração com renderização: respeitar *FOV* ao desenhar
- Performance: cache de *FOV* para evitar recálculos
- Impacto emocional: a névoa de guerra transforma tensão

Ao final, a masmorra ganhará mistério.


## Parte 1: Estrutura de Dados: `Set<Point>`

Antes de implementar o algoritmo, você precisa de uma estrutura para guardar "qual tile está visível agora". Um `Set<Point<int>>` é perfeito: é rápido para adicionar e verificar presença, não guarda duplicatas, e funciona com coordenadas 2D. Usamos dois sets: um para tiles visíveis neste turno (recalculado a cada movimento) e outro para tiles explorados (histórico permanente).

Pense como em Fog of War em StarCraft: tiles vistos agora são brancos, tiles já explorados ficam cinza, tiles nunca vistos são pretos.

```dart
// lib/campo_visao.dart

import 'dart:math';

class CampoVisao {
  final Set<Point<int>> tileVisiveis = {};
  final Set<Point<int>> tileExplorados = {};

  void limpar() {
    tileVisiveis.clear();
  }

  bool estaVisivel(int x, int y) {
    return tileVisiveis.contains(Point(x, y));
  }

  bool foiExplorado(int x, int y) {
    return tileExplorados.contains(Point(x, y));
  }

  void marcarExplorado(int x, int y) {
    tileExplorados.add(Point(x, y));
  }

  void marcarVisivel(int x, int y) {
    tileVisiveis.add(Point(x, y));
    marcarExplorado(x, y);
  }
}
```


## Parte 2: Algoritmo Shadowcasting

O **shadowcasting** é um algoritmo elegante usado em *roguelikes* clássicos como Brogue. Em vez de verificar cada tile do mapa (lento), você lança raios em 8 direções a partir do jogador. Cada raio avança até bater em uma parede ou sair do raio de visão. Isto é rápido, realista e cria o efeito de "você não vê através de paredes".

A ideia é simples: de onde você está, lance raios em oito direções (norte, nordeste, leste, sudeste, sul, sudoeste, oeste, noroeste). Para cada direção, marque cada tile visível até encontrar uma parede que bloqueia a visão.

### Por Que Shadowcasting e Não Apenas Verificar Todos os Tiles?

Você pode estar se perguntando: por que não apenas verificar se cada tile do mapa está dentro do raio máximo do jogador? Por que toda essa complexidade de raios? A resposta é dupla. **Primeiro, performance**: se o mapa tem 200×200 tiles e você verifica cada um a cada turno, são 40.000 verificações por turno. Em um raio 8, você precisa verificar apenas ~200 tiles. **Segundo, realismo**: verificar todos os tiles criaria um círculo perfeito, e você veria através de paredes. Shadowcasting respeita a física: luz não passa por obstáculos. A masmorra fica mais imersiva quando paredes realmente bloqueiam sua visão.

### Como Funciona Passo a Passo

O algoritmo shadowcasting segue esta lógica em cada raio:

1. **Origem**: Marca o tile do jogador como visível (ele sempre se vê).
2. **Direção**: Escolhe uma das 8 direções cardinais/diagonais.
3. **Expansão**: Avança passo a passo naquela direção, incrementando distância.
4. **Visibilidade**: Cada tile é marcado como visível enquanto não houver obstáculo.
5. **Bloqueio**: Quando encontra uma parede opaca, o raio para (aquela direção fica escura).
6. **Limite**: Quando atinge o raio máximo (ex: 8 tiles), para a expansão.

Resultado: Um padrão em forma de "V" apontando para cada uma das 8 direções, criando o campo de visão.

### Visualização ASCII

Aqui está como fica um mapa 15x15 com um jogador no centro (@) e raio 8:

```text
Sem *FOV* (todo o mapa):
###############
#........G....#
#...B...G.....#
###....#......#
#.........E...#
###....#......#
#...........D.#
#..........G..#
###..@..#.....#
#.........G...#
#.....C.......#
###........#..#
#...E...#...F.#
#..............#
###############

Com *FOV* (jogador vê apenas isto):








   · @
        ·.
     .

   ·    ·



Explicação:
- @ = Jogador no centro (sempre visível)
- . = Chão explorado, visível agora
- · = Chão explorado, mas fora do *FOV* (névoa de guerra)
- G = Inimigo (Goblin) que o jogador pode ver
- E = Inimigo (Esqueleto) fora da visão
- B, C, D, F = Outros inimigos não vistos
- # = Parede (bloqueia raios de luz)
```

Vê como o padrão acompanha as 8 direções, criando uma forma em "V" expandido? Raios horizontais e verticais penetram de forma mais profunda, enquanto raios diagonais param mais cedo nas paredes de canto. Isto cria o realismo: você não vê "através" de uma esquina, a visão respeita obstáculos físicos.

### Implementação Básica

A implementação básica de shadowcasting segue a lógica que descreveremos acima passo a passo. O método `calcularShadowcast` é o ponto de entrada: ele limpa o estado anterior, marca o jogador como sempre visível, depois itera sobre as 8 direções cardinais/diagonais. Para cada direção, um raio é lançado que avança progressivamente até encontrar uma barreira. O método `_lancarRaio` é o coração do algoritmo: ele caminha célula por célula na direção escolhida, marcando cada como visível até bater em parede opaca ou sair dos limites do mapa.

```dart
// lib/campo_visao.dart (continuação)

class CampoVisao {
  void calcularShadowcast(
    Point<int> origem,
    int raio,
    MapaMasmorra mapa,
  ) {
    limpar();
    marcarVisivel(origem.x, origem.y); // ← Jogador sempre se vê

    // Oito direções cardinais e diagonais para cobertura completa
    final direcoes = [
      (1, 0), (1, 1), (0, 1), (-1, 1),
      (-1, 0), (-1, -1), (0, -1), (1, -1),
    ];

    for (final (dx, dy) in direcoes) {
      _lancarRaio(origem.x, origem.y, dx, dy, raio, mapa);
    }
  }

  void _lancarRaio(
    int ox,
    int oy,
    int dx,
    int dy,
    int raio,
    MapaMasmorra mapa,
  ) {
    for (int passo = 1; passo <= raio; passo++) {
      final x = ox + dx * passo;
      final y = oy + dy * passo;

      // Boundary check: parou se saiu do mapa
      if (x < 0 || x >= mapa.largura || y < 0 || y >= mapa.altura) {
        break;
      }

      marcarVisivel(x, y);

      // Raio para se bate em parede opaca (bloqueia luz)
      if (mapa.tileEm(x, y) == Tile.parede) {
        break;
      }
    }
  }
}
```

### Versão Otimizada com Cache

Um problema: chamar `calcularShadowcast()` a cada turno é custoso. Se o mapa tem muitos tiles ou raio é grande, isso gasta CPU. A solução: **cache**. Guarde o resultado do último *FOV*. Só recalcule quando o jogador se move. Esta otimização é essencial em jogos reais onde o loop de jogo pode rodar 60 vezes por segundo. Se o jogador não se moveu, não há razão de recalcular o *FOV*: o resultado é idêntico ao anterior. Mantemos um flag `cacheValido` e a última posição conhecida, verificando ambos antes de fazer o cálculo custoso.

```dart
// lib/campo_visao_otimizado.dart

class CampoVisaoOtimizado {
  final Set<Point<int>> tileVisiveis = {};
  final Set<Point<int>> tileExplorados = {};

  late Point<int> ultimaPosicao;
  bool cacheValido = false;

  void calcularShadowcast(
    Point<int> origem,
    int raio,
    MapaMasmorra mapa,
  ) {
    // Cache hit: jogador está na mesma posição e cache é válido
    if (cacheValido && origem == ultimaPosicao) {
      return; // ← Economiza ~80% de CPU em exploração normal
    }

    limpar();
    marcarVisivel(origem.x, origem.y);

    final direcoes = [
      (1, 0), (1, 1), (0, 1), (-1, 1),
      (-1, 0), (-1, -1), (0, -1), (1, -1),
    ];

    for (final (dx, dy) in direcoes) {
      _lancarRaio(origem.x, origem.y, dx, dy, raio, mapa);
    }

    ultimaPosicao = origem;
    // ← Próxima iteração reutiliza este resultado se posição não mudou
    cacheValido = true;
  }

  void invalidarCache() {
    cacheValido = false;
  }

  void limpar() {
    tileVisiveis.clear();
  }

  bool estaVisivel(int x, int y) {
    return tileVisiveis.contains(Point(x, y));
  }

  bool foiExplorado(int x, int y) {
    return tileExplorados.contains(Point(x, y));
  }

  void marcarExplorado(int x, int y) {
    tileExplorados.add(Point(x, y));
  }

  void marcarVisivel(int x, int y) {
    tileVisiveis.add(Point(x, y));
    marcarExplorado(x, y);
  }

  void _lancarRaio(
    int ox,
    int oy,
    int dx,
    int dy,
    int raio,
    MapaMasmorra mapa,
  ) {
    for (int passo = 1; passo <= raio; passo++) {
      final x = ox + dx * passo;
      final y = oy + dy * passo;

      if (x < 0 || x >= mapa.largura || y < 0 || y >= mapa.altura) {
        break;
      }

      marcarVisivel(x, y);

      if (mapa.tileEm(x, y) == Tile.parede) {
        break;
      }
    }
  }
}
```

### Raio Variável (Dinâmico)

Em muitos *roguelikes*, a luz não é fixa. Você pode estar numa sala bem iluminada (raio 12) ou num corredor escuro com uma vela (raio 3). Implementar isto é trivial: só mude o parâmetro `raio`. Este é um exemplo de um aspecto que torna *roguelikes* estratégicos: diferentes equipamentos (lanternas, tochas, anéis mágicos) modificam a tática e a exploração. Sem a lanterna, você caminha às cegas; com ela, planeja com confiança. A dinâmica cria tensão natural.

```dart
// lib/campo_visao_com_lanterna.dart

class CampoVisaoComLanterna {
  enum Lanterna {
    nada(1),
    vela(3),
    tocha(6),
    lampadaMagica(12);

    final int raio;
    const Lanterna(this.raio);
  }

  Lanterna lanternaAtual = Lanterna.tocha;

  void atualizarComLanterna(
    Point<int> origem,
    MapaMasmorra mapa,
  ) {
    calcularShadowcast(origem, lanternaAtual.raio, mapa);
  }

  void trocarLanterna(Lanterna nova) {
    lanternaAtual = nova;
    print('Lanterna trocada para ${nova.name} (raio ${nova.raio})');
  }

  // ... resto do código de shadowcasting
}
```

## Parte 3: Renderização com *FOV*

Agora que você calcula o *FOV*, precisa usá-lo na renderização. A lógica é simples: se um tile está visível agora, desenhe com cor normal. Se foi explorado antes (mas está fora do *FOV* atual), desenhe esfumaçado (caracteres mais pálidos ou cinzentos). Se nunca foi visto, deixe vazio (espaço em branco). Isto cria o efeito de descoberta gradual: conforme você caminha, o mapa vai se revelando lentamente, transformando escuridão em exploração em mistério.

Esta separação de estados (visível/explorado/nunca visto) é crucial para a experiência emocional de um *dungeon crawl*. Você sente que está descobrindo o mundo incrementalmente, não vendo tudo de uma vez. A névoa de guerra combina com o shadowcasting para criar a tensão: há sempre uma borda de desconhecimento ao redor de você, forçando você a explorar cuidadosamente.

### Renderização Básica com *FOV*

A renderização com *FOV* integra três camadas de visualização em uma única passagem pelo mapa. Para cada tile, verificamos se está visível agora, se foi explorado antes, ou se é completamente novo. O método `_esfumacar` transforma caracteres visíveis em versões "embaçadas" usando caracteres Unicode de densidade menor (`░` para paredes, `·` para chão). Isto dá feedback visual: você sabe o que existia ali, mas não consegue ver claramente agora (é como você lembrar de um cômodo escuro que passou antes).

```dart
// lib/mapa_masmorra.dart (adição)

class MapaMasmorra {
  late CampoVisao fov = CampoVisao();

  void atualizarFOV({int raio = 8}) {
    fov.calcularShadowcast(
      Point(jogadorX, jogadorY),
      raio,
      this,
    );
  }

  String paraStringComFOV() {
    final sb = StringBuffer();

    for (int y = 0; y < altura; y++) {
      for (int x = 0; x < largura; x++) {
        final char = tileParaChar(tileEm(x, y));

        // Três estados visuais distintos
        if (fov.estaVisivel(x, y)) {
          sb.write(char); // ← Visível agora: cor/caractere normal
        } else if (fov.foiExplorado(x, y)) {
          sb.write(_esfumacar(char)); // ← Explorado antes: esfumaçado
        } else {
          sb.write(' '); // ← Nunca visto: invisível
        }
      }
      sb.write('\n');
    }

    return sb.toString();
  }

  String _esfumacar(String char) {
    // Caracteres mais claros/vazados para simular falta de luz
    return switch (char) {
      '#' => '░', // Parede: de █ para ░ (menos denso)
      '.' => '·', // Chão: de . para · (mais sutil)
      '>' => '┐', // Escada: símbolo diferente
      _ => char.toLowerCase(), // Outros: minúsculo para parecer apagado
    };
  }
}
```

### Renderização Avançada com Entidades

Quando você tem inimigos, itens e o próprio jogador, a renderização fica mais complexa. Você precisa desenhar em camadas: **Fundo** (mapa respeitando *FOV*), **Entidades** (inimigos e itens apenas se visíveis), e **Jogador** (sempre no topo). Esta ordem é crítica: se você desenhasse o jogador primeiro, inimigos sobre ele o encobririam, o que seria confuso. A ordem de camadas define a prioridade visual e, consequentemente, a clareza do jogo.

Observe que o *FOV* se integra em duas camadas: o mapa respeita completamente (tiles fora de *FOV* são ocultos), e entidades também respeitam (não vemos inimigos no escuro). O jogador é exceção: está sempre visível porque sempre sabemos onde estamos.

1. **Fundo**: Mapa (paredes e chão respeitando *FOV*)
2. **Entidades**: Inimigos e itens (apenas se visíveis no *FOV* atual)
3. **Jogador**: Sempre no topo (sempre visível)

```dart
// lib/explorador_masmorra.dart (integração completa)

class ExploradorMasmorra {
  void renderizarFrameCompleto() {
    tela.limpar();

    // Camada 1: Renderizar mapa respeitando *FOV*
    _renderizarMapaComFOV();

    // Camada 2: Renderizar entidades (inimigos, itens) se visíveis
    _renderizarEntidadesVisiveis();

    // Camada 3: Jogador sempre visível (está sobre o mapa)
    tela.desenharChar(
      jogador.x,
      jogador.y,
      jogador.simbolo,
    );

    // HUD e caixa de informações
    _renderizarHUD();

    // Enviar tudo para a tela
    tela.renderizar();
  }

  void _renderizarMapaComFOV() {
    for (int y = 0; y < andarAtual.mapa.altura; y++) {
      for (int x = 0; x < andarAtual.mapa.largura; x++) {
        final tile = andarAtual.mapa.tileEm(x, y);
        final char = andarAtual.mapa.tileParaChar(tile);

        if (fov.estaVisivel(x, y)) {
          // Tile visível: cor normal, brilhante ← Conhecimento presente
          tela.desenharChar(x, y, char);
        } else if (fov.foiExplorado(x, y)) {
          // Tile explorado: esfumaçado (aqui usando char esfumaçado)
          final esfumacado = _esfumacar(char);
          tela.desenharChar(x, y, esfumacado); // ← Memória do passado
        } else {
          // Tile nunca visto: vazio ← Completa escuridão
          tela.desenharChar(x, y, ' ');
        }
      }
    }
  }

  void _renderizarEntidadesVisiveis() {
    for (final entidade in andarAtual.entidades) {
      if (fov.estaVisivel(entidade.x, entidade.y)) {
        // Renderizar apenas entidades visíveis no *FOV* atual
        // Se não está visível, inimigos não aparecem (cria tensão)
        // Nota: cores ANSI opcionais via desenharCharComCor()
        tela.desenharChar(
          entidade.x,
          entidade.y,
          entidade.simbolo,
        );
      }
    }
  }

  String _esfumacar(String char) {
    return switch (char) {
      '#' => '░',
      '.' => '·',
      '>' => '┐',
      '<' => '┌',
      _ => char.toLowerCase(),
    };
  }
}
```

## Parte 4: Otimizações de Performance

Shadowcasting é rápido, mas em mapas gigantescos (200x200+) ou com muitos inimigos recalculando *FOV*, pode ficar lento. Aqui estão técnicas profissionais:

### Caching de *FOV*

Já vimos isto acima: guardar resultado e reutilizar até o jogador se mover. Economiza ~80% de recálculos.

```dart
// lib/campo_visao_com_cache.dart

class CampoVisaoComCache {
  Set<Point<int>> tileVisiveis = {};
  Set<Point<int>> tileExplorados = {};

  Point<int>? ultimaPosicao;
  int ultimoRaio = 8;

  void calcular(Point<int> pos, int raio, MapaMasmorra mapa) {
    // Só recalcula se posição ou raio mudou
    if (ultimaPosicao == pos && ultimoRaio == raio) {
      return; // Cache hit! Sem cálculo.
    }

    // Calcula normalmente
    _executarShadowcast(pos, raio, mapa);

    ultimaPosicao = pos;
    ultimoRaio = raio;
  }

  void _executarShadowcast(
    Point<int> pos,
    int raio,
    MapaMasmorra mapa,
  ) {
    tileVisiveis.clear();
    // ... algoritmo normal ...
  }
}
```

### Limitação de Raio Efetivo

Se seu mapa é 200x200, mas o raio é 8, você não precisa lançar raios para toda a masmorra. Limitar a busca a ~500-600 tiles (aproximadamente raio * raio * 2) acelera muito.

```dart
// Shadowcast limitado por distância

int _distanciaManhattan(int x1, int y1, int x2, int y2) {
  return (x1 - x2).abs() + (y1 - y2).abs();
}

void _lancarRaioOtimizado(
  int ox, int oy, int dx, int dy, int raio, MapaMasmorra mapa
) {
  for (int passo = 1; passo <= raio; passo++) {
    final x = ox + dx * passo;
    final y = oy + dy * passo;

    // Boundary check rápido
    if (x < 0 || x >= mapa.largura || y < 0 || y >= mapa.altura) {
      break;
    }

    // Distância diagonal: pare se ultrapassar raio
    if (_distanciaManhattan(ox, oy, x, y) > raio) {
      break;
    }

    marcarVisivel(x, y);

    if (mapa.tileEm(x, y) == Tile.parede) {
      break;
    }
  }
}
```

### Cálculo Preguiçoso (Lazy Evaluation)

Se o jogador nunca olha para o canto nordeste do mapa, não calcule *FOV* para lá. Só calcule sob demanda usando lazy evaluation.

```dart
// lib/campo_visao_preguicoso.dart

class CampoVisaoPreguicoso {
  final Map<Point<int>, bool> cacheVisiblidade = {};

  bool estaVisivel(int x, int y, MapaMasmorra mapa) {
    final ponto = Point(x, y);

    if (cacheVisiblidade.containsKey(ponto)) {
      return cacheVisiblidade[ponto]!;
    }

    // Calcular sob demanda
    final resultado = _testarVisibilidade(x, y, mapa);
    cacheVisiblidade[ponto] = resultado;
    return resultado;
  }

  bool _testarVisibilidade(int x, int y, MapaMasmorra mapa) {
    // Teste rápido de linha visual
    return _temLinhaVisualDireta(
      jogadorX, jogadorY, x, y, mapa
    );
  }
}
```

### Saída Esperada

Quando você roda o jogo com *FOV* implementado após descer uma escada:

```text
ANDAR 1 - TURNOS: 0

  ########         ·   ·
  #......#         ·   ·
  #.@....#    ·····.···
  #......#    · ··G····
  ########    ·····.···

  #.#.#.#          · ·
  #.....#      ····.···
  #...G.#      · ··Z···
  #.....>      ····.···
  #.#.#.#

HP: [████████░░] 80/100 | TURNO: 0
```

Note: `@` é sempre visível (é você), `.` é piso visível, `·` é piso explorado (fora do *FOV*), espaços em branco são tiles nunca vistos, `G` e `Z` aparecem apenas se dentro do *FOV*. As paredes `#` também respeita *FOV*: são exibidas normalmente se visíveis, como `░` se exploradas, ou como espaço em branco se nunca vistas.

## Integração com Capítulos Anteriores

No **Capítulo 12** *(Gerador de Mapas)*, criamos a estrutura de dados do mapa com tiles e geradores procedurais. No **Capítulo 15** *(Grid e Renderização)*, aprendemos a desenhar a masmorra inteira em ASCII. Agora, no Capítulo 19, sabemos *o quê* mostrar: não o mapa inteiro, mas apenas o que o jogador consegue ver. A combinação cria um jogo que se sente coeso: temos um mundo, sabemos gerá-lo, e agora sabemos revelar incrementalmente conforme o jogador explora.

No **Capítulo 20** *(Entidades e Inimigos)*, colocaremos criaturas que nascem dentro ou fora do *FOV*. Muitas apenas aparecem quando você explora profundamente. O *FOV* cria a tensão narrativa: você não sabe o que vem pela próxima corner.

## Pergaminho do Capítulo

- Estrutura de dados com dois `Set<Point<int>>`: um para tiles visíveis neste turno e outro para tiles explorados (histórico permanente)
- Algoritmo shadowcasting passo a passo: originar do jogador, escolher direção, expandir até barreira, bloquear em parede e parar no limite de raio
- Exemplos ASCII visuais mostrando como o *FOV* se expande em 8 direções criando um padrão em "V"
- Implementação básica que lança raios em oito direções, marcando tiles visíveis até encontrar parede opaca
- Versão otimizada com cache, economizando ~80% de CPU ao evitar recálculos quando o jogador não se move
- Lanternas dinâmicas (raio variável) com diferentes níveis de iluminação e impacto estratégico
- Integração com renderização em camadas (mapa, entidades, jogador) e três estados visuais: visível, explorado (esfumaçado), nunca visto (invisível)
- Otimizações profissionais: caching inteligente, limitação de raio efetivo e avaliação preguiçosa sob demanda

## Dica Profissional

::: dica
Em jogos profissionais, o *FOV* é frequentemente cacheado e apenas recalculado quando o jogador se move ou quando entidades se movem. Alguns engines usam precalculated tables para mapas estáticos, guardando resultados em memória para acesso O(1). Para performance em mapas gigantescos, considere usar apenas shadowcast numa área limitada (10-15 tiles) em vez de todo o mapa. Brogue, um *roguelike* aclamado, usa shadowcasting de 8 direções exatamente como descrito: prova que o algoritmo é tanto elegante quanto prático.
:::

## Desafios da Masmorra

**Desafio 19.1. Lanterna dinâmica (Raio variável (*dynamic radius*)).** Implemente um sistema de "lanternas" com raios diferentes. Crie um enum `Luz` com variantes: `Lanterna(raio: 8)`, `Tocha(raio: 5)`, `Escuridão(raio: 1)`. O jogador começa com Tocha. Adicione comando `"lanterna"` para trocar. Cada luz muda o raio do *FOV*. Teste caminhando com diferentes luzes.

**Desafio 19.2. Transparência parcial (Vidro).** Modifique shadowcasting para permitir paredes semitransparentes (vidro, grades). Defina `Tile.paredeTransparente`. Raycast continua através delas (não para), mas marca tiles além como "parcialmente explorado" (símbolo diferente). Permite ver inimigos distante através de vidro, mas com aviso visual.

**Desafio 19.3. Mapa de densidade visual (Debug).** Crie modo debug que desenha cada tile colorido por distância ao jogador: próximo (1-2 tiles) = verde claro, distante (5-8) = amarelo, muito distante (8+) = cinza. Ajuda visualizar o raio do *FOV*. Use caracteres `▓`, `▒`, `░` ou cores ANSI para gradação.

**Desafio 19.4. Piscadas de movimento.** Tiles que entraram no *FOV* *este turno* piscam (símbolo especial, ex: `*` em vez de `.`) por 1 turno. Simula o olho humano capturando movimento novo. Dica: compare `tileVisivelAnterior` com `tileVisivelAgora`, destaque adições.

**Desafio 19.5. Inimigos escondidos (Fora do *FOV*).** Inimigos só aparecem se dentro de *FOV*. Fora do *FOV*, não renderizam (mas continuam existindo, movendo-se). Crie um "flanqueador" que sai do *FOV* deliberadamente, torna-se invisível, depois toca o jogador de surpresa. Dica: renderize como `?` enquanto fora do *FOV* se o jogador "sentir presença".

**Boss Final 19.6. *FOV* em múltiplos andares.** Estenda *FOV* para andares (subsolos). Tiles em andares abaixo são vistos com opacidade (símbolo diferente, menos perceptível). Escadas abertas aumentam raio para andares abaixo. Implementação: passe `andarAtual` como parâmetro, recalcule *FOV* com raio reduzido para cada andar (-50% por nível).

## Próximo Capítulo

No Capítulo 20, a masmorra ganha vida. Vamos criar entidades — inimigos, itens, escadas — que habitam o mapa e reagem à presença do jogador. O `GeradorEntidades` posicionará criaturas e tesouros de forma inteligente, respeitando distância e dificuldade.

***
