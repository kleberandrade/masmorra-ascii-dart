# Capítulo 14 - Combate por turnos

> *Você enfrenta o inimigo. Não foge, não negocia. Apenas luta. Seu turno: ataca. Seu turno: defende. Seu turno: falha. A morte espreita cada decisão. Este é o coração que faz um roguelike bater.*

## O que vamos aprender

Neste capítulo você vai:
- Criar uma `class Combate` que orquestra lutas entre `Jogador` e `Inimigo`
- Implementar um `loop` de turnos com escolhas do jogador
- Usar `Random` de `dart:math` para dano variável (realismo)
- Registrar tudo numa `List<String> log` (história da luta)
- Mostrar status visual com barras de HP em ASCII
- Recompensar vitórias com XP e ouro
- Tratar derrota e morte

Ao final, você terá um sistema completo de combate que é o pico emocional desta parte.

## Parte 1: Conceitualizando a luta

Um **combate por turnos** em roguelike tem estrutura:

1. Inicialização: jogador encontra inimigo, entrada no "modo combate"
2. Loop de turnos:
   - Jogador escolhe ação (atacar, defender, fugir, usar item)
   - Resolver ação
   - Inimigo reage (se ainda vivo)
   - Checar condição de vitória/derrota
3. Resolução: prêmios ou game over

Vamos modelar isso em código.

## Aleatoriedade e RPGs: por que os dados nunca mentem

Você já notou que em um RPG real (D&D, Pathfinder, qualquer jogo de mesa), cada ação é incerta? Você rola um dado de 20 lados para saber se acerta um golpe. Rola novamente para determinar dano. Essa incerteza é essencial: sem ela, combate é determinístico, previsível, entediante. Se você sempre ataca com 8 de dano, o inimigo sempre ataca com 6, o resultado final é óbvio desde o início. Ninguém quer jogar um RPG onde sabe exatamente quem vai ganhar antes do combate começar.

Daí entra `Random` do Dart. Em vez de dano fixo, você rola dados: `jogador.dano - 20% + aleatório(40%)`. Isso gera um intervalo realista. Um ataque pode fazer 6 a 10 de dano em vez de sempre 8. Combates viram emocionantes. Uma derrota inesperada é possível. Uma vitória incrível contra um inimigo mais forte se torna história.

Neste capítulo, `Random` é seu aliado para criar combate que respira, que surpreende, que faz a adrenalina bombar.

## Parte 2: Classe Combate. Orchestrador

A classe `Combate` é o coração do sistema. Ela recebe um `Jogador` e um `Inimigo` e orquestra todo o loop de turnos. Mantém um `log` de mensagens (crucial para entender o que aconteceu), calcula dano com variação aleatória (para não ser previsível) e gerencia defesa, item e fuga. Note o método `_registrar()` que tanto escreve na tela quanto armazena no log para replay.

```dart
// lib/combate.dart

import 'dart:io';
import 'dart:math';
import 'jogador.dart';
import 'inimigo.dart';

class Combate {
  final Jogador jogador;
  final Inimigo inimigo;
  final List<String> log = [];
  final Random random = Random(); // Reutilize uma única instância

  int turno = 0;
  bool defesaAtiva = false;

  Combate({
    required this.jogador,
    required this.inimigo,
  });

  void _registrar(String mensagem) {
    log.add(mensagem);
    print(mensagem);
  }

  void mostrarStatus() {
    final barraJogador = _construirBarra(jogador.hp, jogador.maxHp);
    final barraInimigo = _construirBarra(inimigo.hp, inimigo.maxHp);

    print('');
    print('⚔ COMBATE ⚔');
    print('${jogador.nome} vs ${inimigo.nome}');
    print('$barraJogador $barraInimigo');
    print('HP: ${jogador.hp}/${jogador.maxHp}  HP: ${inimigo.hp}/${inimigo.maxHp}');
    print('Atq: ${jogador.danoTotal}  Atq: ${inimigo.danoBase}');
    print('');
  }

  String _construirBarra(int hp, int maxHp) {
    const totalBlocos = 10;
    final blocos = ((hp / maxHp) * totalBlocos).toInt();
    final cheios = '█' * blocos;
    final vazios = '░' * (totalBlocos - blocos);
    return '$cheios$vazios';
  }

  bool atacar() {
    final variacao = (jogador.danoTotal * 0.2).toInt();
    final dano = jogador.danoTotal - variacao + random.nextInt(variacao * 2);

    _registrar('> ${jogador.nome} ataca com força! Dano: $dano');

    if (inimigo.sofrerDano(dano)) {
      _registrar(' ${inimigo.nome} foi derrotado!');
      return true;
    }

    defesaAtiva = false;
    return false;
  }

  bool defender() {
    defesaAtiva = true;
    _registrar('> ${jogador.nome} assume posição defensiva!');
    return false;
  }

  bool fugir() {
    if (random.nextDouble() < 0.4) {
      _registrar(' ${jogador.nome} conseguiu fugir!');
      return true;
    } else {
      _registrar(' ${jogador.nome} não conseguiu escapar!');
      return false;
    }
  }

  bool usarItem(int indiceNoInventario) {
    if (indiceNoInventario < 0 ||
        indiceNoInventario >= jogador.inventario.length) {
      _registrar('Item não encontrado!');
      return false;
    }

    final item = jogador.inventario[indiceNoInventario];

    if (item.id == 'pocao-vida') {
      const cura = 20;
      final vidaAnterior = jogador.hp;
      jogador.hp = (jogador.hp + cura).clamp(0, jogador.maxHp);
      final curaReal = jogador.hp - vidaAnterior;

      _registrar('> ${jogador.nome} bebe uma poção e recupera $curaReal HP!');
      jogador.inventario.removeAt(indiceNoInventario);
      return false;
    }

    _registrar('Você não pode usar isso em combate!');
    return false;
  }

  void turnoDoInimigo() {
    if (inimigo.hp < inimigo.maxHp / 3 && random.nextDouble() < 0.3) {
      inimigo.executarHabilidadeEspecial(this);
    } else {
      final dano = inimigo.calcularDano();

      int danoFinal = dano;
      if (defesaAtiva) {
        danoFinal = (dano * 0.6).toInt();
        _registrar('> ${inimigo.nome} ataca, mas a defesa reduz o impacto!');
      } else {
        _registrar('> ${inimigo.nome} contra-ataca! Dano: $danoFinal');
      }

      if (jogador.sofrerDano(danoFinal)) {
        _registrar(' ${jogador.nome} foi derrotado...');
      }
    }

    defesaAtiva = false;
  }

  void executar() {
    turno = 0;
    mostrarStatus();

    while (jogador.hp > 0 && inimigo.hp > 0) {
      turno++;
      print('\n--- TURNO $turno ---');

      print('\nOpções:');
      print('1 - Atacar');
      print('2 - Defender');
      print('3 - Fugir');
      print('4 - Usar item');
      print('5 - Sair (não implementado)');
      stdout.write('\nEscolha: ');

      final escolha = stdin.readLineSync() ?? '1';

      bool combateAcabou = false;

      switch (escolha.trim()) {
        case '1':
          combateAcabou = atacar();
          break;
        case '2':
          defender();
          break;
        case '3':
          combateAcabou = fugir();
          if (combateAcabou) {
            _registrar('Você fugiu do combate.');
            return;
          }
          break;
        case '4':
          stdout.write('Qual item? (0-${jogador.inventario.length - 1}): ');
          final indiceStr = stdin.readLineSync() ?? '0';
          usarItem(int.tryParse(indiceStr) ?? 0);
          break;
        default:
          _registrar('Ação desconhecida!');
          continue;
      }

      if (combateAcabou && inimigo.hp <= 0) {
        break;
      }

      if (inimigo.hp > 0) {
        turnoDoInimigo();
      }

      if (jogador.hp <= 0) {
        _registrar('\n[DERROTA] Você caiu em combate.');
        _exibirGameOver();
        return;
      }

      mostrarStatus();
    }

    if (inimigo.hp <= 0) {
      _exibirVitoria();
    }
  }

  void _exibirVitoria() {
    _registrar('\n[VITÓRIA] Você venceu o combate!');
    final ouroGanho = inimigo.calcularOuroDrop();
    final xpGanho = inimigo.calcularXPDrop();

    jogador.ouro += ouroGanho;
    // O campo `xp` será introduzido no Capítulo 25 — Progressão.
    // Por enquanto, declare `int xp = 0;` na classe Jogador.
    jogador.xp += xpGanho;

    _registrar('Você ganhou $ouroGanho ouro e $xpGanho XP!');

    if (random.nextDouble() < 0.3) {
      final item = inimigo.gerarLoot();
      if (item != null) {
        jogador.inventario.add(item);
        _registrar('Você encontrou: ${item.nome}!');
      }
    }

    print('');
    print('[VITÓRIA] Você venceu o combate!');
    print('Ouro: +$ouroGanho');
    print('XP: +$xpGanho');
    print('');
  }

  void _exibirGameOver() {
    print('');
    print('[GAME OVER]');
    print('Você caiu em combate.');
    print('Durou $turno turnos de glória.');
    print('');
  }

  void mostrarLog() {
    print('\n=== LOG DE COMBATE ===');
    for (final mensagem in log) {
      print(mensagem);
    }
  }
}
```

Notas importantes:

- `stdin.readLineSync()` lê entrada do teclado. Você vai precisar de `import 'dart:io';`
- `_registrar()` escreve e armazena no `log`
- `defesaAtiva` é um flag booleano que dura um turno
- Dano tem variação (usando `random.nextInt()`) para não ser previsível
- Vitória e derrota têm tratamento especial em `_exibirVitoria()` e `_exibirGameOver()`

## Parte 3: Classe Inimigo e Subtipos

Agora você precisa de inimigos que funcionem com combate. Mas aqui surge um problema clássico: seu roguelike tem Zumbi, Lobo e Orc. Cada um é diferente em nome, HP, dano e habilidades. Se você criasse cada um do zero como uma classe separada, teria muita duplicação: `class Zumbi { int hpMax; int hpAtual; int dano; ... sofrerDano() { ... } }` e `class Lobo { int hpMax; int hpAtual; int dano; ... sofrerDano() { ... } }`. O código `sofrerDano()` é idêntico em ambos. Você estaria escrevendo a mesma coisa várias vezes.

Aí entra a classe abstrata. Você cria uma `abstract class Inimigo` que define a estrutura e o comportamento comum a todos os inimigos: HP, dano, método `sofrerDano()`, método para calcular dano aleatório. Depois, cada inimigo (Zumbi, Lobo, Orc) herda desse template e personaliza apenas o que é único: seu loot, suas habilidades especiais, seus valores base. Zero duplicação.

A `abstract class Inimigo` define o contrato: todo inimigo tem HP, dano, e pode sofrer dano. Mas cada subtipo (Zumbi, Lobo, Orc) personaliza seu loot e habilidades especiais. Observe `sofrerDano()` que retorna `bool`: true se o inimigo morreu, false se ainda está vivo. Isso simplifica o loop de combate.

```dart
// lib/inimigo.dart

import 'dart:math';
import 'item.dart';
import 'combate.dart';

abstract class Inimigo {
  static final Random _random = Random(); // Reutilize uma única instância entre todos os inimigos

  final String id;
  final String nome;
  int maxHp;
  int hp;
  final int danoBase;

  Inimigo({
    required this.id,
    required this.nome,
    required this.maxHp,
    required this.danoBase,
  }) : hp = maxHp;

  bool sofrerDano(int dano) {
    hp -= dano;
    return hp <= 0;
  }

  int calcularDano() {
    final variacao = (danoBase * 0.15).toInt();
    return danoBase - variacao + _random.nextInt(variacao * 2);
  }

  int calcularOuroDrop() {
    return 10 + _random.nextInt(10);
  }

  int calcularXPDrop() {
    return 50;
  }

  Item? gerarLoot() {
    return null;
  }

  void executarHabilidadeEspecial(Combate combate) {
    combate._registrar('> ${nome} não tem habilidade especial!');
  }
}

class Zumbi extends Inimigo {
  Zumbi()
      : super(
          id: 'zumbi',
          nome: 'Zumbi Pilhador',
          maxHp: 30,
          danoBase: 6,
        );

  @override
  Item? gerarLoot() {
    if (_random.nextDouble() < 0.5) {
      return Item(
        id: 'moedas-sujas',
        nome: 'Moedas Sujas',
        descricao: 'Roubo do zumbi',
        preco: 15,
        peso: 0,
      );
    }
    return null;
  }
}

class Lobo extends Inimigo {
  Lobo()
      : super(
          id: 'lobo',
          nome: 'Lobo Selvagem',
          maxHp: 50,
          danoBase: 8,
        );

  @override
  void executarHabilidadeEspecial(Combate combate) {
    combate._registrar('> ${nome} salta e rosna!');
    hp = (hp + 15).clamp(0, maxHp);
  }

  @override
  Item? gerarLoot() {
    if (_random.nextDouble() < 0.6) {
      return Arma(
        id: 'fanga-lobo',
        nome: 'Fanga do Lobo',
        descricao: 'Arma antiga',
        preco: 100,
        peso: 3,
        dano: 7,
        tipo: 'cortante',
      );
    }
    return null;
  }
}

class Orc extends Inimigo {
  Orc()
      : super(
          id: 'orc',
          nome: 'Orc Guerreiro',
          maxHp: 70,
          danoBase: 12,
        );

  @override
  void executarHabilidadeEspecial(Combate combate) {
    combate._registrar('> ${nome} desfere um golpe furioso!');
  }
}
```

Nota: cada inimigo herda estrutura (via `extends Inimigo`), mas personaliza HP, dano, loot e habilidades (via `@override`).

## Parte 4: Integrando Combate no Jogador

O `Jogador` precisa de métodos para combate. O método `sofrerDano()` decresce HP e retorna `true` se o jogador morreu (útil para saber se deve rodar game over). Já `enfrentarInimigo()` é o ponto de entrada: cria uma instância de `Combate`, executa o loop de turnos, e depois exibe o log completo para o jogador revisar. Isso conecta o sistema de combate com a classe Jogador.

```dart
// jogador.dart (adições)

class Jogador {
  int xp = 0;

  bool sofrerDano(int dano) {
    hp -= dano;
    if (hp < 0) hp = 0;
    return hp <= 0;
  }

  void enfrentarInimigo(Inimigo inimigo) {
    print('\n[COMBATE] Você encontrou um ${inimigo.nome}!');
    final combate = Combate(jogador: this, inimigo: inimigo);
    combate.executar();

    combate.mostrarLog();
  }
}
```

## Parte 5: Factory de Inimigos

Você agora tem `Zumbi()`, `Lobo()`, `Orc()` prontos para criar instâncias. Mas imagine uma masmorra grande com 20 tipos de inimigos diferentes. Ao gerar uma sala, você faria `if (ambiente == 'floresta') { inimigo = Lobo(); } else if (ambiente == 'catacumba') { inimigo = Zumbi(); } ...`. Espalhado pelo código. Se precisar adicionar um novo inimigo, tem que caçar todos os lugares onde inimigos são criados e adicionar novo `if`.

Aí entra o padrão Factory. Você centraliza toda a lógica de criação de inimigos num único lugar. Em vez de escrever `Zumbi()` espalhado pelo código, você chama `FabricaInimigo.criarPorId('zumbi')`. Se precisar trocar a lógica de criação, muda num só lugar. Se vai adicionar um novo inimigo, registra na Factory e pronto. O resto do código continua funcionando sem saber quantos tipos existem.

Para gerar inimigos pelo ID, use o padrão Factory (uma `class` com métodos estáticos). Você não cria `Zumbi()` diretamente, mas chama `FabricaInimigo.criarPorId('zumbi')`. Note a função `gerarInimigo()` que escolhe aleatoriamente qual tipo de inimigo aparece num certo ambiente (floresta vs catacumba).

```dart
// lib/enemy_factory.dart

import 'dart:math';
import 'inimigo.dart';
import 'zumbi.dart';
import 'lobo.dart';
import 'orc.dart';

class FabricaInimigo {
  static Inimigo criarPorId(String id) {
    switch (id) {
      case 'zumbi':
        return Zumbi();
      case 'lobo':
        return Lobo();
      case 'orc':
        return Orc();
      default:
        throw Exception('Inimigo desconhecido: $id');
    }
  }

  static final Map<String, List<String>> inimigosAmbiente = {
    'floresta': ['zumbi', 'lobo'],
    'catacumba': ['lobo', 'orc'],
    'caverna': ['zumbi', 'orc', 'lobo'],
  };

  static String gerarInimigo(String ambiente) {
    final opcoes = inimigosAmbiente[ambiente] ?? ['zumbi'];
    return opcoes[Random().nextInt(opcoes.length)];
  }
}
```

## Parte 6: Exemplo Completo. Uma Luta Real

Aqui está um exemplo de fim a fim: criamos um jogador com uma espada e poção, depois ele enfrenta um lobo. O combate roda com input do usuário até que o jogador vença, fuja ou morra. Este é o momento em que todo o sistema de combate (turnos, dano, itens, recompensas) se une numa experiência coerente.

```dart
// lib/main.dart

import 'dart:io';
import 'jogador.dart';
import 'arma.dart';
import 'item.dart';
import 'enemy_factory.dart';

void main() {
  final jogador = Jogador(
    nome: 'Aldric',
    maxHp: 100,
    ouro: 100,
  );

  final espada = Arma(
    id: 'espada-bronze',
    nome: 'Espada de Bronze',
    descricao: 'Uma arma comum',
    preco: 200,
    peso: 3,
    dano: 8,
    tipo: 'cortante',
  );

  jogador.inventario.add(espada);
  jogador.equiparArma(0);

  final pocao = Item(
    id: 'pocao-vida',
    nome: 'Poção de Vida',
    descricao: 'Recupera 20 HP',
    preco: 50,
    peso: 1,
  );
  jogador.inventario.add(pocao);

  print('=== AVENTURA COMEÇA ===\n');
  jogador.mostraStatus();

  final inimigo = FabricaInimigo.criarPorId('lobo');
  jogador.enfrentarInimigo(inimigo);

  jogador.mostraStatus();
}
```

### O Jogo Até Aqui

Ao final desta parte, seu combate no terminal se parece com isto:

```

⚔ COMBATE ⚔

Aldric          vs Lobo Selvagem
██████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
HP: 80/100          HP: 15/50
Atq: 12             Atq: 8

--- TURNO 3 ---

Opções:
1 - Atacar
2 - Defender
3 - Fugir
4 - Usar item

Escolha: 1
> Aldric ataca com força! Dano: 12
> Lobo Selvagem contra-ataca! Dano: 5

[VITÓRIA] Você venceu o combate!

Ouro: +20
XP: +50

```

Cada parte adiciona novas camadas ao jogo. Compare com o início e veja o quanto você evoluiu nesta jornada!

***

## Desafios da Masmorra

**Desafio 14.1. HUD em Combate com cores ANSI.** Crie um método `mostrarStatusCombate()` que exibe HP em percentual e com código de cor: verde se acima de 75%, amarelo entre 50-75%, vermelho abaixo de 50%. Use escape codes ANSI: `'\u001B[32m'` verde, `'\u001B[33m'` amarelo, `'\u001B[31m'` vermelho, `'\u001B[0m'` reset.

**Desafio 14.2. Ataque Crítico.** Implemente crítico: 15% de chance de dano dobrado (x2). Use `Random().nextDouble() < 0.15`. Quando crítico ocorrer, registre no log: "GOLPE CRÍTICO! Dano dobrado!" e mostre o dano com destaque.

**Desafio 14.3. Limite de turno (Fuga automática).** Adicione um limite: combate não pode durar mais de 10 turnos. Se chegar ao limite e ainda houver combate, o jogador é forçado a fugir automaticamente com mensagem: "A luta durou demais, você foge pela sua vida!"

**Desafio 14.4. Ação Defensa com Riposte.** Implemente uma ação `defender()`: reduz dano sofrido em 50% neste turno. Além disso, ao sofrer ataque enquanto defendendo, há 30% de chance de ripostear (contra-ataque) com 30% do seu dano normal.

**Desafio 14.5. Combate em Grupo (Avançado).** Implemente combate contra múltiplos inimigos. Crie uma classe `CombateGrupo` que recebe `List<Inimigo> inimigos` e o jogador enfrenta todos sequencialmente, mas numa ordem que você escolhe (IA básica: mais fraco primeiro). Registre cada transição entre inimigos no log.

**Boss Final 14.6. Poções dinâmicas (Integração com inventário).** Crie uma classe `Pocao extends Item` com um campo `int curaHP` e um método `usar(Jogador j)` que chama `j.curar(curaHP)`. Refatore `usarItem()` no combate para checar o tipo de item: se for `Pocao`, chama `pocao.usar(jogador)`. Crie três tipos: PocaoPequena (10 HP), PocaoMedia (25 HP), PocaoGrande (50 HP). Demonstre no combate.

## Pergaminho do Capítulo

Neste capítulo você aprendeu:

- `class Combate`: orchestrador que gerencia turnos, ações, `log` e resolução
- `loop` de turnos: escolha > ação > reação > checar fim
- Ações variadas: `atacar()`, `defender()`, `fugir()`, `usarItem()` (cada uma com lógica)
- Dano variável: `Random` para realismo (±20%)
- IA simples: cada inimigo reage diferente via `turnoDoInimigo()`
- Recompensas: ouro, XP, itens baseado em derrota
- ASCII visual: barras de HP, `log`, estrutura clara com `@override`

Seu jogo agora é um verdadeiro roguelike com combate completo. Isso é o pico emocional desta parte.

No próximo capítulo começaremos a expandir a exploração da masmorra, com salas, movimento 2D e encontros dinâmicos.

::: dica
**Dica do Mestre:** Sempre registre ações em combate (no `log`). Ajuda a entender o que aconteceu e é essencial para balanceamento. Além disso, considere criar diferentes níveis de dificuldade criando variantes dos inimigos. Por exemplo, `class GoblinForte extends Zumbi { ... }`. Teste bastante! Combate é onde o balanceamento importa.
:::
