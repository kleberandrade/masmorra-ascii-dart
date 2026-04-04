# Capítulo 22 - Economia: Preços, Drops e Balanceamento

*Ouro cintila no chão. Mercadores surgem nas sombras oferecendo armas que você ainda não pode pagar. Cada inimigo derrotado deixa recompensas, e cada recompensa alimenta a escalada de poder que vai levar você até o chefe final. A economia da masmorra obedece regras que você mesmo vai definir: preços, drops, curvas de dificuldade, tabelas de progressão.*

*Nesta parte, o jogo ganha profundidade mecânica. XP e níveis transformam o `@` fraco do primeiro andar em um guerreiro capaz de enfrentar o Dragão. Múltiplos andares empilham desafios crescentes. E quando tudo estiver conectado, loja, combate, progressão, boss final, você terá um roguelike completo e jogável. O jogo que você imaginava no começo do livro agora existe.*

> *A masmorra não é um labirinto vazio. Cada inimigo carrega ouro, armas, poções. Cada item tem um preço. O comerciante cobra mais caro em gemas raras e paga menos por sucata velha. Quanto mais fundo desce o herói, mais ricos e perigosos são os espólios. Este é o coração invisível do roguelike: regras simples de incentivo e progressão. A economia torna cada decisão relevante.*

## O Que Vamos Aprender

Neste capítulo você vai:

- Entender por que a economia importa em roguelikes (como o sistema de Gil em Final Fantasy): tudo tem preço, e o balanceamento decide se o jogo é justo ou quebrado
- Modelar *loot tables* com pesos aleatórios (como os *drops* em Diablo): cada criatura tem uma tabela de probabilidades
- Criar a classe `EntradaSaque` e `Economia` para governar preços e recompensas
- Implementar cascatas de dificuldade: inimigos mais fortes em andares mais profundos
- Usar constantes de balanceamento para ajustes rápidos de design
- Simular corridas de teste para validar a curva de dificuldade
- Integrar *drops* no combate da Masmorra

Ao final, você terá um sistema econômico coerente que propicia progressão justa e recompensadora.

## O Ciclo de Incentivos

Antes de código, pense no jogo como um jogador. Por que continuo descendo, tentando sobreviver?

1. Ganho ouro dos inimigos que derroto
2. Compro armas melhores com esse ouro na loja
3. Com armas melhores, consigo derrotar inimigos mais fortes
4. Inimigos mais fortes soltam mais ouro e itens raros
5. Volto à loja, compro armadura, deço mais fundo
6. No andar final, enfrento o chefe com tudo que consegui acumular

Este é o ciclo de progressão. É o coração psicológico do jogo. Se o primeiro inimigo soltar tanto ouro quanto o chefe, o jogo é entediante (sem senso de progressão). Se o primeiro inimigo soltar nada, é frustrante (sem recompensa). A economia bem balanceada é o pulso que mantém o jogo vivo.

## Constantes de Balanceamento

Vamos definir constantes que governam toda a progressão. Isso é crucial porque ajustar um número muda tudo. É como ajustar a economia de Final Fantasy: um número muda, e o jogo inteiro se desbalanceia ou se equilibra perfeitamente.

Estas constantes vivem num único lugar (`EconomiaConstants`). Se você quer deixar o jogo mais fácil, muda um número e pronto. Sem procurar pelo código inteiro. Isto é design limpo.

```dart
// lib/economia_constants.dart

/// Constantes de balanceamento da economia
class EconomiaConstants {
  /// Dificuldade escalonada por andar
  static const int kBaseHPPorInimigo = 10;
  static const double kAumentoHPPorAndar = 0.2; // +20% HP por andar

  /// Recompensas em ouro
  static const int kOuroBasePorInimigo = 5;
  static const double kAumentoOuroPorAndar = 0.3; // +30% ouro por andar

  /// Preços base da loja
  static const int kPrecoEspadaFerro = 50;
  static const int kPrecoArmaduraCouro = 75;
  static const int kPrecoPocaoVida = 20;

  /// Margem do comerciante
  static const double kMargemVenda = 0.5; // Comerciante oferece 50%
}
```

Estas constantes são parâmetros de design. Ajuste um deles e observe como o jogo responde. A progressão fica lenta demais? Aumente `kOuroBasePorInimigo`. O primeiro inimigo é muito fácil e entediante? Aumente `kAumentoHPPorAndar`. Isto é iteração de design: números controlam a sensação inteira do jogo. Este é o coração invisível do balanceamento.

## EntradaSaque: A Tabela de Drops

Cada tipo de inimigo tem uma tabela de *drops*, uma lista de itens que pode soltar com probabilidades. Por exemplo:

- Zumbi: 80% moeda de ouro, 15% adaga velha, 5% nada
- Lobo: 60% moeda de ouro, 30% espada de ferro, 10% poção de vida
- Orc: 50% moeda de ouro, 40% poção de vida, 10% nada

Loot tables são como os *drops* em Diablo: cada monstro tem uma probabilidade de soltar cada item. Modelamos isto com a classe `EntradaSaque`, que encapsula item, chance e quantidade mínima/máxima.

```dart
// lib/entrada_saque.dart

import 'dart:math';

/// Uma entrada na tabela de drops de um inimigo
/// Define qual item pode cair, com que
/// probabilidade, e em que quantidade
class EntradaSaque {
  final String itemId;
  final double chance;
  final int quantidadeMin;
  final int quantidadeMax;
  final String nomeItem;

  EntradaSaque({
    required this.itemId,
    required this.chance,
    required this.quantidadeMin,
    required this.quantidadeMax,
    required this.nomeItem,
  })  : assert(chance >= 0.0 && chance <= 1.0),
        assert(quantidadeMin >= 0 && quantidadeMax >= quantidadeMin);

  /// Calcula a quantidade a cair (entre min e max)
  int resolverQuantidade(Random random) {
    if (quantidadeMin == quantidadeMax) {
      return quantidadeMin;
    }
    return quantidadeMin +
        random.nextInt(quantidadeMax - quantidadeMin + 1);
  }

  @override
  String toString() =>
      '$nomeItem (${(chance * 100).toStringAsFixed(1)}%): '
      '$quantidadeMin—$quantidadeMax';
}
```

## Classe Economia: O Governador

A classe `Economia` centraliza toda a lógica de economia. Tem dois serviços principais:

1. Determinar *drops* após combate (usa um Rolador para decisões probabilísticas)
2. Calcular preços de compra e venda

```dart
// lib/economia.dart

import 'dart:math';
import 'rolador.dart';
import 'entrada_saque.dart';
import 'economia_constants.dart';

/// Sistema de economia: drops, preços, balanceamento
class Economia {
  final Map<String, List<EntradaSaque>> tabelasDrops;
  final Rolador roller;

  Economia({
    required this.tabelasDrops,
    Rolador? roller,
  }) : roller = roller ?? Rolador();

  /// Resolve os drops de um inimigo derrotado
  List<String> resolverDrop(String nomeInimigo) {
    final drops = tabelasDrops[nomeInimigo];
    if (drops == null) {
      return ['ouro:${EconomiaConstants.kOuroBasePorInimigo}'];
    }

    final resultado = <String>[];

    for (final entry in drops) {
      if (roller.teste(entry.chance)) {
        final qtd = entry.resolverQuantidade(roller.random);
        resultado.add('${entry.itemId}:$qtd');
      }
    }

    if (resultado.isEmpty) {
      resultado.add('ouro:${EconomiaConstants.kOuroBasePorInimigo}');
    }

    return resultado;
  }

  /// Calcula o preço de compra (preço que você paga à loja)
  int precoCompra(String itemId) {
    return switch (itemId) {
      'espada_ferro' => EconomiaConstants.kPrecoEspadaFerro,
      'espada_aco' =>
        (EconomiaConstants.kPrecoEspadaFerro * 1.5)
            .toInt(),
      'espada_mithril' =>
        (EconomiaConstants.kPrecoEspadaFerro * 3.0)
            .toInt(),
      'armadura_couro' => EconomiaConstants.kPrecoArmaduraCouro,
      'armadura_ferro' =>
        (EconomiaConstants.kPrecoArmaduraCouro * 1.5).toInt(),
      'pocao_vida' => EconomiaConstants.kPrecoPocaoVida,
      'pocao_restauracao' =>
        (EconomiaConstants.kPrecoPocaoVida * 2).toInt(),
      _ => 10,
    };
  }

  /// Calcula o preço de venda (preço que o comerciante oferece)
  int precoVenda(String itemId) {
    final compra = precoCompra(itemId);
    return (compra * EconomiaConstants.kMargemVenda).toInt();
  }

  /// Retorna dificuldade escalonada para um andar
  double getDificuldadeAndar(int numero) {
    return 1.0 + (numero * EconomiaConstants.kAumentoHPPorAndar);
  }

  /// Retorna recompensa escalonada para um andar
  int getOuroEscalonado(int numero) {
    final base = EconomiaConstants.kOuroBasePorInimigo.toDouble();
    final aum = EconomiaConstants.kAumentoOuroPorAndar;
    final multiplicador = 1.0 + (numero * aum);
    return (base * multiplicador).toInt();
  }
}
```

## Criando as Tabelas de Drops

Agora populamos as tabelas com dados concretos para cada tipo de inimigo:

```dart
// lib/tabelas_drops.dart

import 'entrada_saque.dart';

/// Tabelas de drops padrão para todos os tipos de inimigo
class TabelasDrops {
  static Map<String, List<EntradaSaque>> criar() {
    return {
      'Zumbi': [
        EntradaSaque(
          itemId: 'ouro',
          chance: 1.0,
          quantidadeMin: 3,
          quantidadeMax: 8,
          nomeItem: 'Moedas de ouro',
        ),
        EntradaSaque(
          itemId: 'adaga_velha',
          chance: 0.15,
          quantidadeMin: 1,
          quantidadeMax: 1,
          nomeItem: 'Adaga velha',
        ),
      ],
      'Lobo': [
        EntradaSaque(
          itemId: 'ouro',
          chance: 0.9,
          quantidadeMin: 5,
          quantidadeMax: 15,
          nomeItem: 'Moedas de ouro',
        ),
        EntradaSaque(
          itemId: 'espada_ferro',
          chance: 0.25,
          quantidadeMin: 1,
          quantidadeMax: 1,
          nomeItem: 'Espada de ferro',
        ),
        EntradaSaque(
          itemId: 'pocao_vida',
          chance: 0.1,
          quantidadeMin: 1,
          quantidadeMax: 2,
          nomeItem: 'Poção de vida',
        ),
      ],
      'Orc': [
        EntradaSaque(
          itemId: 'ouro',
          chance: 0.95,
          quantidadeMin: 15,
          quantidadeMax: 30,
          nomeItem: 'Moedas de ouro',
        ),
        EntradaSaque(
          itemId: 'espada_aco',
          chance: 0.35,
          quantidadeMin: 1,
          quantidadeMax: 1,
          nomeItem: 'Espada de aço',
        ),
        EntradaSaque(
          itemId: 'armadura_ferro',
          chance: 0.2,
          quantidadeMin: 1,
          quantidadeMax: 1,
          nomeItem: 'Armadura de ferro',
        ),
      ],
    };
  }
}
```

## Integrando Drops no Combate

Quando você derrota um inimigo, resolvemos o *drop*. Isto acontece no sistema de combate:

```dart
// Exemplo: em combate.dart, quando inimigo morre

void executarCombate(
  Jogador jogador,
  Inimigo inimigo,
  Economia economia,
) {
  // ... combate normal ...

  if (!inimigo.estaVivo) {
    print('${inimigo.nome} foi derrotado!');

    final drops = economia.resolverDrop(inimigo.nome);

    for (final drop in drops) {
      final partes = drop.split(':');
      final tipo = partes[0];
      final quantidade = int.parse(partes[1]);

      if (tipo == 'ouro') {
        jogador.ouro += quantidade;
        print('Você ganhou $quantidade ouro!');
      } else {
        jogador.adicionarItem(tipo, quantidade);
        print('Você encontrou: $tipo x$quantidade');
      }
    }
  }
}
```

## Testando a Curva de Dificuldade

Uma boa economia só se revela após testes. Simule 100 corridas e veja se você sai ganhando ou quebrado. A classe `SimuladorEconomia` roda múltiplas corridas hipotéticas, contando ouro ganho, e mostra estatísticas: média, mínimo, máximo. Se a média é muito alta ou muito baixa, você ajusta as constantes e testa de novo.

```dart
// lib/simulador_economia.dart

import 'dart:math';
import 'economia.dart';
import 'tabelas_drops.dart';

/// Simula corridas de teste para validar balanceamento
class SimuladorEconomia {
  final Economia economia;

  SimuladorEconomia(this.economia);

  /// Simula N corridas e retorna estatísticas médias
  Map<String, dynamic> simularCorridas(int numCorridas) {
    final stats = <int>[];

    for (int i = 0; i < numCorridas; i++) {
      int ouroTotal = 0;

      for (final nomeInimigo in ['Zumbi', 'Lobo', 'Orc']) {
        final drops = economia.resolverDrop(nomeInimigo);
        for (final drop in drops) {
          final partes = drop.split(':');
          if (partes[0] == 'ouro') {
            ouroTotal += int.parse(partes[1]);
          }
        }
      }

      stats.add(ouroTotal);
    }

    final media = stats.reduce((a, b) => a + b) / stats.length;
    final minimo = stats.reduce((a, b) => min(a, b));
    final maximo = stats.reduce((a, b) => max(a, b));

    return {
      'corridas': numCorridas,
      'ouro_medio': media.toStringAsFixed(2),
      'ouro_minimo': minimo,
      'ouro_maximo': maximo,
    };
  }
}
```

Uso (exemplo de como rodar a simulação):

```dart
void main() {
  final economia = Economia(tabelasDrops: TabelasDrops.criar());
  final simulador = SimuladorEconomia(economia);

  final resultado = simulador.simularCorridas(100);
  print('Simulação de 100 corridas:');
  print(resultado);
}
```

Saída esperada:

```text
Simulação de 100 corridas:
{corridas: 100, ouro_medio: 85.45, ouro_minimo: 52, ouro_maximo: 148}
```

Se a média é muito baixa, aumente `kOuroBasePorInimigo`. Se é muito alta, reduza. Isto é iteração de design.

## Dificuldade por Andar

A dificuldade aumenta gradualmente. Quanto mais fundo, mais perigoso. O sistema usa `getDificuldadeAndar()` para calcular um multiplicador: no andar 0, é 1.0x (normal). No andar 3, é 1.6x (60% mais forte). No andar 10, é 3.0x (3 vezes mais forte).

```dart
// Exemplo de escalação de dificuldade por andar

void aplicarDificuldadeAndar(
  Inimigo inimigo,
  int andarNumero,
  Economia economia,
) {
  final multiplicador = economia.getDificuldadeAndar(andarNumero);

  inimigo.hpMax = (inimigo.hpMax * multiplicador).toInt();
  inimigo.hp = inimigo.hpMax;

  inimigo.ataque = (inimigo.ataque * multiplicador).toInt();

  print('Inimigo escalonado para andar $andarNumero: '
      'HP=${inimigo.hpMax}, ATK=${inimigo.ataque}');
}
```

Isto significa:

- Andar 0: Zumbi tem 10 HP
- Andar 3: Zumbi tem 10 * 1.6 = 16 HP
- Andar 10: Zumbi tem 10 * 3.0 = 30 HP

A mesma criatura fica progressivamente mais desafiadora.

## Desafios da Masmorra

### Desafios Básicos

**Desafio 22.1. O Tesouro do Dragão Antigo.** A lenda diz que um dragão guardava uma Chave Dourada nos tempos antigos. Crie uma nova tabela de *drops* onde o Dragão tem 5% de chance de deixar cair essa chave rara. Implemente em `EntradaSaque` com id `'chave_dourada'`, chance `0.05`, quantidade 1, descrição épica. Teste: derrote o dragão 20 vezes, conte quantas vezes recebe a chave. A probabilidade bate com 5%? Dica: use `EntradaSaque` para encapsular cada possível *drop*.

**Desafio 22.2. Ganância do Comerciante.** O comerciante da masmorra cobrava margem de 50%. Você descobriu que ele é ganancioso demais. Reduza a margem de venda para 30% mudando `kMargemVenda` de 0.5 para 0.3. Agora uma Espada de Ferro que custa 50 ouro vale quanto em venda? Calcule manualmente e depois valide em código. Os preços mais justos faz você comprar mais itens? Dica: novo preço = 50 × 0.3.

### Desafios Avançados

**Desafio 22.3. A Maldição dos Cinco Andares.** Você desce 5 andares, cada um com 3 Lobos hostis. Implemente uma simulação: (1) Faça loop dos andares 0-4, (2) em cada andar, gere 3 Lobos com HP escalonado por `getDificuldadeAndar()`, (3) resolva *drops* de cada lobo, (4) some o ouro total. Execute e veja: quantos ouro ganharam? O HP dos lobos aumenta conforme desce? A economia se ajusta naturalmente? Dica: imprima resumo: "Andar X: 3 Lobos, Y ouro, HP variou de Z a W".

**Desafio 22.4. Modo Fácil para Aprendizes.** Criar um jogo que escala dificuldade é difícil. Você quer testar em modo fácil onde tudo é menos letal. Crie `EconomiaFacil extends Economia`: dificuldade em 50% (inimigos mais fracos), *drops* em 150% (mais ouro). Simule 5 andares em modo fácil e modo normal, compare. Em fácil, sobrevive melhor? Ganha mais ouro? Dica: use `super.getDificuldadeAndar()` para chamar o pai e depois multiplicar.

**Desafio 22.5. (Desafio): Raríssimo.** Nem todo item é igual. Itens raros são mais caros. Crie um enum `Raridade { comum, raro, mitico }` e adicione esse campo em `EntradaSaque`. Depois, multiplique preço de compra: comum (1x), raro (3x), mítico (10x). Crie 3 *drops* de um inimigo: ouro comum (50 ouro), espada rara (200 ouro), artefato mítico (5000 ouro). Teste o balanceamento: qual é mais comum? Qual mais valioso? Dica: use switch/case no getter `precoCompra()`.

**Boss Final 22.6. A Profundeza Recompensa.** Conforme desce, as recompensas aumentam. Implemente um bônus de +10% de ouro a cada 2 andares (andar 2→+10%, andar 4→+20%, andar 6→+30%). Integre em `getOuroEscalonado()`. Teste descendo 10 andares: o ouro cresce suavemente ou tem saltos? Sinta-se recompensado pela sua coragem. Dica: use `(andar ~/ 2) * 0.10` para calcular bônus.

## Pergaminho do Capítulo

Neste capítulo, você aprendeu:

- Loot tables modelam o que cada inimigo deixa cair quando morre
- `EntradaSaque` encapsula item, chance e quantidade; `Rolador` resolve aleatoriedade
- `Economia` é o governador central: preços, *drops*, dificuldade escalonada
- Constantes de balanceamento permitem ajustar o jogo rapidamente
- Simulação valida a curva: 100 corridas revelam se o jogo é justo ou quebrado
- Dificuldade por andar escala inimigos naturalmente, sem queda abrupta

A economia é o pulso invisível. Inimigos derrotados alimentam o ciclo: ouro para armas melhores para derrotar inimigos mais fortes. Sem isto, o jogo é apenas um labirinto.

## Dica Profissional

::: dica
Testes de economia são tão importantes quanto testes de código. Uma simples mudança em `kAumentoOuroPorAndar` (0.3 para 0.5) pode quebrar o balanceamento inteiro. Use simulações: rode 1000 corridas, meça ouro médio, morte média, velocidade de progressão. Se a curva não é suave, volta atrás. Economia é iteração contínua, não é "colocar números e esperar". Dados revelam verdades que intuição esconde.
:::

## Próximo Capítulo

No Capítulo 23, a economia ganha uma interface tangível. Vamos construir a loja do mercador — com `ItemVenda`, `Mercador`, `LojaRenderer` e `ModoLoja` — onde o jogador pode comprar, vender e planejar estraticamente seus próximos movimentos.

***
