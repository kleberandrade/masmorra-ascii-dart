# Capítulo 19 - Campo de Visão e a Névoa de Guerra

> *Na escuridão, o medo toma forma. Você sabe que o perigo está aí, mas não consegue vê-lo. Quando a tocha ilumina uma divisão inesperada e novos inimigos surgem, o jogo respira diferente. Essa tensão da névoa de guerra é o ingrediente secreto que transforma uma grade de caracteres num mundo vivo.*


## O Que Vamos Aprender

Neste capítulo você vai aprender a implementar **campo de visão** (FOV) e **névoa de guerra**.

Especificamente:
- Três estados de um tile: unseen, seen (explorado), visible (iluminado)
- Estrutura de dados eficiente: `Set<Point<int>>`
- Algoritmo simples: FOV por círculo dentro de raio R
- Algoritmo avançado: Shadowcasting (raios em 8 direções)
- Linha visual (Bresenham-like): detectar se parede bloqueia visão
- Integração com renderização: respeitar FOV ao desenhar
- Performance: cache de FOV para evitar recálculos
- Impacto emocional: a névoa de guerra transforma tensão

Ao final, a masmorra ganhará mistério.


## Parte 1: Estrutura de Dados: `Set<Point>`

Antes de implementar o algoritmo, você precisa de uma estrutura para guardar "qual tile está visível agora". Um `Set<Point<int>>` é perfeito: é rápido para adicionar e verificar presença, não guarda duplicatas, e funciona com coordenadas 2D. Usamos dois sets: um para tiles visíveis neste turno (recalculado a cada movimento) e outro para tiles explorados (histórico permanente).

Pense como em Fog of War em StarCraft: tiles vistos agora são brancos, tiles já explorados ficam cinza, tiles nunca vistos são pretos.

```dart
// campo_visao.dart

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

O **shadowcasting** é um algoritmo elegante usado em roguelikes clássicos como Brogue. Em vez de verificar cada tile do mapa (lento), você lança raios em 8 direções a partir do jogador. Cada raio avança até bater em uma parede ou sair do raio de visão. Isto é rápido, realista e cria o efeito de "você não vê através de paredes".

A ideia é simples: de onde você está, lance raios em oito direções (norte, nordeste, leste, sudeste, sul, sudoeste, oeste, noroeste). Para cada direção, marque cada tile visível até encontrar uma parede que bloqueia a visão.

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

```
Sem FOV (todo o mapa):
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

Com FOV (jogador vê apenas isto):








   · @
        ·.
     .

   ·    ·



Explicação:
- @ = Jogador no centro (sempre visível)
- . = Chão explorado, visível agora
- · = Chão explorado, mas fora do FOV (névoa de guerra)
- G = Inimigo (Goblin) que o jogador pode ver
- E = Inimigo (Esqueleto) fora da visão
- B, C, D, F = Outros inimigos não vistos
- # = Parede (bloqueia raios de luz)
```

Vê como o padrão acompanha as 8 direções, criando uma forma em "V" expandido? Raios horizontais e verticais penetram de forma mais profunda, enquanto raios diagonais param mais cedo nas paredes de canto. Isto cria o realismo: você não vê "através" de uma esquina, a visão respeita obstáculos físicos.

### Implementação Básica

```dart
// campo_visao.dart (continuação)

class CampoVisao {
  void calcularShadowcast(
    Point<int> origem,
    int raio,
    MapaMasmorra mapa,
  ) {
    limpar();
    marcarVisivel(origem.x, origem.y);

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

### Versão Otimizada com Cache

Um problema: chamar `calcularShadowcast()` a cada turno é custoso. Se o mapa tem muitos tiles ou raio é grande, isso gasta CPU. A solução: **cache**. Guarde o resultado do último FOV. Só recalcule quando o jogador se move.

```dart
// campo_visao_otimizado.dart

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
    // Se o jogador não se moveu, reutilize o cache
    if (cacheValido && origem == ultimaPosicao) {
      return;
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

Em muitos roguelikes, a luz não é fixa. Você pode estar numa sala bem iluminada (raio 12) ou num corredor escuro com uma vela (raio 3). Implementar isto é trivial: só mude o parâmetro `raio`.

```dart
// Campo de visão com lanterna

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
```


## Parte 3: Renderização com FOV

Agora que você calcula o FOV, precisa usá-lo na renderização. A lógica é simples: se um tile está visível agora, desenhe com cor normal. Se foi explorado antes (mas está fora do FOV atual), desenhe esfumaçado (caracteres mais pálidos ou cinzentos). Se nunca foi visto, deixe vazio (espaço em branco). Isto cria o efeito de descoberta gradual: conforme você caminha, o mapa vai se revelando lentamente, transformando escuridão em exploração em ignorância.

### Renderização Básica com FOV

```dart
// dungeon_map.dart (adição)

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

        if (fov.estaVisivel(x, y)) {
          sb.write(char);
        } else if (fov.foiExplorado(x, y)) {
          sb.write(_esfumacar(char));
        } else {
          sb.write(' ');
        }
      }
      sb.write('\n');
    }

    return sb.toString();
  }

  String _esfumacar(String char) {
    return switch (char) {
      '#' => '░',
      '.' => '·',
      '>' => '┐',
      _ => char.toLowerCase(),
    };
  }
}
```

### Renderização Avançada com Entidades

Quando você tem inimigos, itens e o próprio jogador, a renderização fica mais complexa. Você precisa desenhar em camadas:

1. **Fundo**: Mapa (paredes e chão)
2. **Entidades**: Inimigos e itens (apenas se visíveis)
3. **Jogador**: Sempre no topo (sempre visível)

```dart
// explorador_masmorra.dart (integração completa)

class ExploradorMasmorra {
  void renderizarFrameCompleto() {
    tela.limpar();

    // Camada 1: Renderizar mapa respeitando FOV
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
          // Tile visível: cor normal
          tela.desenharChar(x, y, char);
        } else if (fov.foiExplorado(x, y)) {
          // Tile explorado: esfumaçado (cores ANSI opcionais; aqui usando char esfumaçado)
          final esfumacado = _esfumacar(char);
          tela.desenharChar(x, y, esfumacado);
        } else {
          // Tile nunca visto: vazio
          tela.desenharChar(x, y, ' ');
        }
      }
    }
  }

  void _renderizarEntidadesVisiveis() {
    for (final entidade in andarAtual.entidades) {
      if (fov.estaVisivel(entidade.x, entidade.y)) {
        // Renderizar apenas entidades visíveis
        // Nota: cores ANSI opcionais podem ser adicionadas via desenharCharComCor() posteriormente
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

Shadowcasting é rápido, mas em mapas gigantescos (200x200+) ou com muitos inimigos recalculando FOV, pode ficar lento. Aqui estão técnicas profissionais:

### Caching de FOV

Já vimos isto acima: guardar resultado e reutilizar até o jogador se mover. Economiza ~80% de recálculos.

```dart
// Exemplo de cache inteligente

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

  void _executarShadowcast(Point<int> pos, int raio, MapaMasmorra mapa) {
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

Se o jogador nunca olha para o canto nordeste do mapa, não calcule FOV para lá. Só calcule sob demanda usando lazy evaluation.

```dart
// FOV lazy: calcula sob demanda

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
```

## Pergaminho do Capítulo

Neste capítulo você implementou um dos pilares da atmosfera em roguelikes: o campo de visão (Field of View) e a névoa de guerra. Começou estruturando os dados com dois `Set<Point<int>>`: um para tiles visíveis neste turno (calculado a cada movimento) e outro para tiles já explorados (histórico permanente). Aprendeu a decompor o algoritmo shadowcasting passo a passo: originar do jogador, escolher direção, expandir até barreira, bloquear em parede, e parar no limite de raio. Viu exemplos ASCII visuais de como o FOV se expande em 8 direções criando um padrão em "V". Implementou a versão básica que lança raios em oito direções a partir do jogador, marcando tiles visíveis até encontrar parede opaca. Expandiu para uma versão otimizada com cache, evitando recálculos quando o jogador não se move — economizando ~80% de CPU. Aprendeu a implementar lanternas dinâmicas (raio variável) e como diferentes níveis de iluminação mudam a estratégia. Integrou FOV à renderização em camadas (mapa, entidades, jogador), aplicando três estados visuais: tiles visíveis em cor normal, tiles explorados esfumaçados (caracteres pálidos), tiles nunca vistos invisíveis. Estudou otimizações profissionais: caching inteligente, limitação de raio efetivo, e avaliação preguiçosa sob demanda. Essa mecânica de revelação gradual do mapa cria tensão psicológica real — o jogador sente medo genuíno ao rodear uma esquina. A névoa de guerra transforma uma grade de caracteres num mundo com presença, mistério e emoção autêntica.

::: dica
**Dica do Mestre:** Em jogos profissionais, o FOV é frequentemente cacheado e apenas recalculado quando o jogador se move ou quando entidades se movem. Alguns engines usam precalculated tables para mapas estáticos, guardando resultados em memória para acesso O(1). Para performance em mapas gigantescos, considere usar apenas shadowcast numa área limitada (10-15 tiles) em vez de todo o mapa. Brogue, um roguelike aclamado, usa shadowcasting de 8 direções exatamente como descrito — prova que o algoritmo é tanto elegante quanto prático.
:::

## Desafios da Masmorra

**Desafio 19.1. Lanterna dinâmica (Raio variável).** Implemente um sistema de "lanternas" com raios diferentes. Crie um enum `Luz` com variantes: `Lanterna(raio: 8)`, `Tocha(raio: 5)`, `Escuridão(raio: 1)`. O jogador começa com Tocha. Adicione comando `"lanterna"` para trocar. Cada luz muda o raio do FOV. Teste caminhando com diferentes luzes.

**Desafio 19.2. Transparência parcial (Vidro).** Modifique shadowcasting para permitir paredes semitransparentes (vidro, grades). Defina `Tile.paredeTransparente`. Raycast continua através delas (não para), mas marca tiles além como "parcialmente explorado" (símbolo diferente). Permite ver inimigos distante através de vidro, mas com aviso visual.

**Desafio 19.3. Mapa de densidade visual (Debug).** Crie modo debug que desenha cada tile colorido por distância ao jogador: próximo (1-2 tiles) = verde claro, distante (5-8) = amarelo, muito distante (8+) = cinza. Ajuda visualizar o raio do FOV. Use caracteres `▓`, `▒`, `░` ou cores ANSI para gradação.

**Desafio 19.4. Piscadas de movimento.** Tiles que entraram no FOV *este turno* piscam (símbolo especial, ex: `*` em vez de `.`) por 1 turno. Simula o olho humano capturando movimento novo. Dica: compare `tileVisivelAnterior` com `tileVisivelAgora`, destaque adições.

**Desafio 19.5. Inimigos escondidos (Fora do FOV).** Inimigos só aparecem se dentro de FOV. Fora do FOV, não renderizam (mas continuam existindo, movendo-se). Crie um "flanqueador" que sai do FOV deliberadamente, torna-se invisível, depois toca o jogador de surpresa. Dica: renderize como `?` enquanto fora do FOV se o jogador "sentir presença".

**Boss Final 19.6. FOV em múltiplos andares.** Estenda FOV para andares (subsolos). Tiles em andares abaixo são vistos com opacidade (símbolo diferente, menos perceptível). Escadas abertas aumentam raio para andares abaixo. Implemento: passe `andarAtual` como parâmetro, recalcule FOV com raio reduzido para cada andar (-50% por nível).
```
