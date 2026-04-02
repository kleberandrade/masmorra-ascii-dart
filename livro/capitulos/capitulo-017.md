# Capítulo 17 - Aleatoriedade com Propósito

> *Você poderia desenhar cada masmorra à mão. Mas há maravilha em algo que você nunca viu antes, que forma-se sob as mesmas regras, cada vez diferente, mas sempre com lógica. Isso é aleatoriedade com propósito. Não é caos. É criatividade guiada. Uma semente é como um código secreto que diz ao universo: "Construa este mundo específico, e apenas este."*


## O Que Vamos Aprender

Neste capítulo você vai aprender a usar aleatoriedade de forma controlada e profissional em Dart. A **Random** de `dart:math` oferece `nextInt()`, `nextDouble()` e `nextBool()` para criar comportamentos imprevíveis mas controláveis:

Especificamente:
- A classe Random de `dart:math`: `nextInt()`, `nextDouble()`, `nextBool()`
- Sementes (seeds): entender por que reprodutibilidade é essencial
- Seeded vs unseeded Random. Diferença e quando usar cada uma
- Por que sementes importam em roguelikes: debugging, testes, modo replayável
- Geração aleatória de itens em tiles de chão
- Colocação aleatória de inimigos (evitando posição inicial do jogador)
- Loot tables: probabilidades ponderadas (comum, raro, épico)
- List.shuffle() e random element picking
- Funções puras vs estado: boas práticas
- Criar uma classe Rolador utilitária: `rolar(min, max)`, `chance(percentual)`, `escolher(lista)`
- Exemplo completo: masmorra procedural com itens e inimigos aleatórios

Ao final, seu jogo terá infinita rejogabilidade. Cada sessão é única, mas com seeds você pode replicar qualquer sessão para debug.


## Parte 1: Entendendo Random

### Unseeded vs Seeded

Há dois modos de usar `Random` em Dart. Unseeded gera números verdadeiramente aleatórios (diferentes cada execução). Seeded usa uma sementa inicial para gerar uma sequência determinística (mesma semente = mesma sequência sempre). Em roguelikes, sementes são ouro puro: permitem replay de sessões, debug de bugs, e testes automatizados.

```dart
import 'dart:math';

void main() {
  // Unseeded — muda a cada execução
  final random1 = Random();
  print(random1.nextInt(100)); // 47 (primeira execução)
  print(random1.nextInt(100)); // 23 (primeira execução)

  // Segunda execução? Números DIFERENTES

  print('---\n');

  // Seeded — sempre mesmos números
  final random2 = Random(42);
  print(random2.nextInt(100)); // 47 (sempre)
  print(random2.nextInt(100)); // 23 (sempre)

  // Segunda execução? Números IGUAIS
}
```

A semente é um valor inicial que determina toda a sequência.


## Parte 2: Métodos de Random (dart:math)

A classe `Random` oferece alguns métodos essenciais. `nextInt(max)` dá um inteiro de 0 até max-1. Com um offset você pode rolar dados (`1d6`). `nextDouble()` dá um real entre 0 e 1 (útil para porcentagens). `nextBool()` dá 50/50. Vamos explorar cada um com exemplos práticos.

```dart
import 'dart:math';

void main() {
  final random = Random(42);

  // nextInt(max) . número inteiro de 0 a max-1
  print('nextInt(10): ${random.nextInt(10)}'); // 0-9

  // nextInt com offset . número de min a max
  int rolar(int min, int max) {
    return min + random.nextInt(max - min + 1);
  }
  print('Dado 1-6: ${rolar(1, 6)}');

  // nextDouble() . número real de 0.0 a 1.0
  print('nextDouble: ${random.nextDouble()}');

  // nextBool() . true ou false com 50/50
  print('nextBool: ${random.nextBool()}');

  // Probabilidade customizada
  bool chance(int percentual) {
    return random.nextInt(100) < percentual;
  }
  print('40% chance: ${chance(40)}');
}
```


## Parte 3: Por Que Sementes Importam em Roguelikes

Sementes são a arma secreta para debug e testes em roguelikes. Em vez de "meu jogo está quebrado aleatoriamente", você pode reproduzir exatamente o mesmo mapa/combate e investigar. Vamos ver dois cenários onde sementes são essenciais.

### Caso 1: Debugging

```dart
// Jogador encontra bug: "Mapa de nível 3 tem inimigo infinito!"
// Você: "Qual era a semente?"
// Jogador: "42"

void main() {
  // Recriar EXATAMENTE a sessão do jogador
  final random = Random(42);
  gerarDungeonLevel(3, random);

  // Investigar bug
  // Depois de corrigir, replayteste com semente 42
}
```

### Caso 2: Testes Automatizados

```dart
void test() {
  final mapa1 = MapaMasmorra.gerar(width: 20, height: 20, seed: 999);
  final mapa1str = mapa1.paraString();

  final mapa2 = MapaMasmorra.gerar(width: 20, height: 20, seed: 999);
  final mapa2str = mapa2.paraString();

  assert(mapa1str == mapa2str, 'Sementes não reproduzem!');
  print('Geração procedural é determinística');
}
```


## Parte 4: Colocação Aleatória de Itens

Para gerar items espalhados pela masmorra, você escolhe um `(x, y)` aleatório até encontrar uma célula passável que não seja onde o jogador começa. Isso garante que items sempre apareçam em chão, nunca dentro de paredes. Uma curiosidade: o loop `while (gerados < quantidade)` pode rodar para sempre se o mapa for muito pequeno ou muito cheio de paredes. Numa versão robusta, você adicionaria um máximo de tentativas.

```dart
// game.dart

class SessaoJogo {
  final MapaMasmorra mapa;
  final Jogador jogador;
  final List<Item> itens = [];
  final Random random;

  SessaoJogo({
    required this.mapa,
    required this.jogador,
    int? seed,
  }) : random = Random(seed ?? DateTime.now().millisecondsSinceEpoch);

  void gerarItens(int quantidade) {
    int gerados = 0;

    while (gerados < quantidade) {
      final x = random.nextInt(mapa.largura);
      final y = random.nextInt(mapa.altura);

      if (mapa.ehPassavel(x, y) && !(x == jogador.x && y == jogador.y)) {
        itens.add(Item(
          nome: _gerarNomeItem(),
          x: x,
          y: y,
        ));
        gerados++;
      }
    }
  }

  String _gerarNomeItem() {
    final nomes = ['Ouro', 'Poção', 'Gema', 'Anel', 'Escudo'];
    return nomes[random.nextInt(nomes.length)];
  }
}
```


## Parte 5: Colocação Aleatória de Inimigos

Gerar inimigos é similar a items, mas com validação extra: distância mínima do jogador. Use `Manhattan distance` (distância de táxi) para evitar que um Orc nasça diretamente ao lado do jogador. O truque é: se a distância é menor que a mínima, faça `continue` para tentar outro lugar. Isso cria uma "aura de segurança" ao redor do jogador.

```dart
// game.dart (adição)

class SessaoJogo {
  final List<Inimigo> inimigos = [];

  void gerarInimigos(int quantidade, int minDistanciaDoJogador) {
    int gerados = 0;

    while (gerados < quantidade) {
      final x = random.nextInt(mapa.largura);
      final y = random.nextInt(mapa.altura);

      final distancia = ((x - jogador.x).abs() + (y - jogador.y).abs());
      if (distancia < minDistanciaDoJogador) {
        continue;
      }

      if (mapa.ehPassavel(x, y)) {
        final tipo = _gerarTipoInimigo();
        inimigos.add(Inimigo(
          nome: tipo,
          x: x,
          y: y,
          hpMax: _vidaPorTipo(tipo),
          simbolo: _simboloPorTipo(tipo),
        ));
        gerados++;
      }
    }
  }

  String _gerarTipoInimigo() {
    final tipos = ['Zumbi', 'Lobo', 'Orc', 'Orc'];
    return tipos[random.nextInt(tipos.length)];
  }

  int _vidaPorTipo(String tipo) {
    return switch (tipo) {
      'Zumbi' => 20,
      'Lobo' => 40,
      'Orc' => 60,
      _ => 25,
    };
  }

  String _simboloPorTipo(String tipo) {
    return switch (tipo) {
      'Zumbi' => 'Z',
      'Lobo' => 'L',
      'Orc' => 'O',
      _ => '?',
    };
  }
}
```


## Parte 6: Loot Tables . Probabilidades Ponderadas

Loot tables com raridade são essenciais em RPGs. Você define probabilidades (70% comum, 20% raro, etc.) e sorteia aleoriamente qual item o jogador recebe. A técnica é simples: role um número 0-99, e dependendo do resultado, devolva a raridade. Depois, `gerarItemPorRaridade()` escolhe qual item específico dessa raridade. Isso cria variedade realista sem sobrecarga de código.

```dart
// loot.dart

enum RaridadeItem {
  comum,      // 70%
  raro,       // 20%
  epico,      // 9%
  lendario,   // 1%
}

class TabelaLoot {
  final Random random;

  TabelaLoot({required this.random});

  RaridadeItem sortearRaridade() {
    final roll = random.nextInt(100);
    if (roll < 70) return RaridadeItem.comum;
    if (roll < 90) return RaridadeItem.raro;
    if (roll < 99) return RaridadeItem.epico;
    return RaridadeItem.lendario;
  }

  String gerarItemPorRaridade(RaridadeItem raridade) {
    return switch (raridade) {
      RaridadeItem.comum => ['Moeda', 'Pão', 'Lenha'][random.nextInt(3)],
      RaridadeItem.raro => ['Poção de Vida', 'Espada de Ferro'][random.nextInt(2)],
      RaridadeItem.epico => ['Sabre de Ouro', 'Capa Mágica'][random.nextInt(2)],
      RaridadeItem.lendario => 'Excalibur',
    };
  }

  Item gerarItem(int x, int y) {
    final raridade = sortearRaridade();
    return Item(
      nome: gerarItemPorRaridade(raridade),
      x: x,
      y: y,
    );
  }
}
```


## Parte 7: Classe Rolador . Utilitária de Dados

A classe `Rolador` encapsula operações aleatórias comuns em RPGs. Em vez de escrever `random.nextInt(...)` em cem lugares diferentes, você usa `rolador.d(6)` ou `rolador.chance(60)`. Note o método `escolherPonderado()` que sorteia de um `Map<String, int>` onde as chaves são opções e valores são pesos. Isso é muito usado para raridade, inimigos em ambientes, etc.

```dart
// rolador.dart

import 'dart:math';

class Rolador {
  final Random random;

  Rolador({Random? random}) : random = random ?? Random();

  int rolar(int min, int max) {
    return min + random.nextInt(max - min + 1);
  }

  int d(int faces) => rolar(1, faces);

  bool chance(int percentual) {
    return random.nextInt(100) < percentual;
  }

  T escolher<T>(List<T> lista) {
    if (lista.isEmpty) throw Exception('Lista vazia');
    return lista[random.nextInt(lista.length)];
  }

  String escolherPonderado(Map<String, int> pesos) {
    final total = pesos.values.fold(0, (sum, p) => sum + p);
    var roll = random.nextInt(total);

    for (final entry in pesos.entries) {
      roll -= entry.value;
      if (roll < 0) return entry.key;
    }

    throw Exception('Erro interno');
  }

  int interpretarDados(String notacao) {
    // "2d6+3" → rolar 2d6 e somar 3
    final partes = notacao.split('+');
    final dado = partes[0];
    final bonus = partes.length > 1 ? int.parse(partes[1]) : 0;

    final dadoPartes = dado.split('d');
    final quantidade = int.parse(dadoPartes[0]);
    final faces = int.parse(dadoPartes[1]);

    int total = 0;
    for (int i = 0; i < quantidade; i++) {
      total += rolar(1, faces);
    }

    return total + bonus;
  }
}

// Uso:
void main() {
  final rolador = Rolador(random: Random(42));

  print('1d6: ${rolador.d(6)}');
  print('2d6+3: ${rolador.interpretarDados('2d6+3')}');
  print('60% chance: ${rolador.chance(60)}');
  print('Escolher: ${rolador.escolher(['A', 'B', 'C'])}');

  final pesos = {'comum': 70, 'raro': 25, 'épico': 5};
  print('Raridade: ${rolador.escolherPonderado(pesos)}');
}
```

***

## Desafios da Masmorra

**Desafio 17.1. Modo Speedrun (Semente escolhida).** Adicione um menu ao iniciar que permite inserir uma semente ou deixar aleatória. Exemplos: "Deixe em branco para aleatório, ou digite um número (ex: 1337)". Use `int.tryParse()`. Depois, mostre a semente na HUD: "Semente: 1337". Isso permite streamers e jogadores compartilharem sementes para replay e speedrun.

**Desafio 17.2. Tabela de Loot.** Ao derrotar inimigos, implemente drops ponderados: 70% comum (50-100 ouro), 20% raro (Poção de Vida), 10% épico (Gema = muito ouro). Use `Random.nextDouble()` para decimalização. Crie uma função `Item? resolverDrop(Random random)` que retorna o item baseado na chance. Teste derrotando 10 inimigos: a distribuição parece razoável?

**Desafio 17.3. Rolador de Dados (Variação de stats).** Implemente uma classe `Rolador` com métodos: `rolar(int minimo, int maximo)`, `rolarDados(String expressao)` (ex: "2d6+3" = dois d6 mais 3), `chance(int percentual)`. Use para gerar HP variável em inimigos: Goblin fraco (d4+5), normal (d6+10), forte (d8+15). Gere 20 inimigos e verifique a variação.

**Desafio 17.4. Spawn seguro (Longe do jogador).** Ao gerar inimigos aleatoriamente, garanta que estejam a pelo menos 5 tiles do jogador (distância Manhattan). Se a posição aleatória violar isso, tente novamente. Crie `bool longeDoJogador(Pos inimigo, Pos jogador, int minDistancia)`. Teste visualmente: jogador está sempre isolado no spawn.

**Boss Final 17.5. Teste de Determinismo (Replicabilidade).** Implemente `==` e `hashCode` em suas classes principais (Mapa, Jogador, Inimigo). Escreva testes que verificam: (1) Mapas com semente 42 são idênticos, (2) Semente 43 é diferente, (3) Semente 42 novamente = idêntico à primeira. Isso demonstra que o caos é controlado: mesma semente = mesma jornada. Esse é o fundamento de replays.


::: dica
**Dica do Mestre:** Gerenciamento de sementes em produção: em um jogo real, você quer que a semente seja visível ao jogador (para replay, streaming, speedrun). Considere adicionar um menu que mostra a semente inicial ou salve-a junto com o savegame:

```dart
class SalvoJogo {
  final int seed;
  final int turno;
  final Posicao posicaoJogador;

  SalvoJogo({
    required this.seed,
    required this.turno,
    required this.posicaoJogador,
  });

  // Serializar e desserializar para JSON
  Map<String, dynamic> toJson() => {
    'seed': seed,
    'turno': turno,
    'x': posicaoJogador.x,
    'y': posicaoJogador.y,
  };
}
```

Performance: Aleatoriedade massiva (milhares de rolls por frame) é rara em Dart. Se precisar, considere pré-gerar resultados ou usar um RNG mais rápido que `Random` padrão (como xorshift, usado em motores profissionais).
:::


## Pergaminho do Capítulo

Neste capítulo você aprendeu:

- Random sem semente: muda a cada execução (não determinístico)
- Random com semente: sempre mesma sequência (determinístico)
- Métodos: `nextInt()`, `nextDouble()`, `nextBool()`
- Por que sementes importam: debugging, testes, replay, speedrun
- Colocação aleatória: itens e inimigos em posições válidas
- Loot tables: probabilidades ponderadas (comum vs raro vs épico)
- List.shuffle() e picking: embaralhar e escolher elementos
- Classe Rolador: utilitária para operações aleatórias comuns
- Notação de dados: parse simples para `2d6+3`
- Boas práticas: passar `Random` como parâmetro (funções puras)

Seu jogo agora tem infinita rejogabilidade. Cada sessão é diferente, mas reprodutível. Perfeito para testes e clips de gameplay.

No próximo capítulo (18), você aprenderá algoritmos de geração procedural avançados: Random Walk e Rooms-and-Corridors.

