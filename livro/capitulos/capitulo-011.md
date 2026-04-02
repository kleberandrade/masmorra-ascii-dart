# Capítulo 11 - Mixins: poderes compartilhados

> *Toda criatura que respira sente dano e sangra. O dragão, o mago, o zumbi—todos sofrem golpes da mesma forma. Em vez de copiar essa verdade a cada classe, Dart oferece uma verdade compartilhada: um mixin é como um poder que você injeta em qualquer criatura sem reescrever sua árvore familiar.*

## O problema que mixins resolvem

No capítulo anterior, você criou `Inimigo` com o método `sofrerDano()`. Agora você tem um `Jogador` que também precisa de `sofrerDano()`, e mais tarde talvez tenha `Besta` ou `Golem` com a mesma lógica. Se você copiar a implementação várias vezes, quando tiver de corrigir um bug ou mudar as regras, tem de editar em muitos lugares.

**Mixins** são a solução: é um "pacote reutilizável de comportamento" que você pode aplicar a várias classes sem necessidade de herança.

## Entender `mixin` e **with**

Um `mixin` é definido de forma parecida a uma `class`, mas usa a palavra-chave `mixin`:

```dart
// lib/combatente.dart

mixin Combatente {
  int hp = 0;
  int maxHp = 0;

  void sofrerDano(int d) {
    hp -= d;
    if (hp < 0) {
      hp = 0;
    }
    print('Sofri $d de dano! HP agora é $hp');
  }

  void curar(int q) {
    hp += q;
    if (hp > maxHp) {
      hp = maxHp;
    }
    print('Curado por $q. HP agora é $hp');
  }

  bool get estaVivo => hp > 0;

  String mostrarBarraVida() {
    final preenchimento = '█' * (hp ~/ (maxHp ~/ 10));
    final vazio = '░' * (10 - preenchimento.length);
    return '[$preenchimento$vazio] $hp/$maxHp';
  }
}
```

Agora, quando você criar um `Jogador`, aplica este mixin com a palavra-chave `with`:

```dart
// lib/jogador.dart

import 'combatente.dart';

class Jogador with Combatente {
  String nome;
  String classe;
  int nivel = 1;
  List<Item> inventario = [];
  Item? armaEquipada;

  Jogador({
    required this.nome,
    required this.classe,
    required int hpInicial,
  }) {
    hp = hpInicial;
    maxHp = hpInicial;
  }

  @override
  String toString() => '$nome [$classe, nível $nivel], ${mostrarBarraVida()}';

  void adicionarItem(Item item) {
    inventario.add(item);
    print('Você obteve ${item.nome}!');
  }

  void equiparArma(Item item) {
    if (item is Arma) {
      armaEquipada = item;
      print('Você equipou ${item.nome}');
    } else {
      print('Você não pode equipar isto.');
    }
  }
}
```

E também aplica a `Inimigo`:

```dart
// lib/inimigo.dart

import 'combatente.dart';

abstract class Inimigo with Combatente {
  final String nome;
  final String simbolo;
  final int ataque;
  final String descricao;

  Inimigo({
    required this.nome,
    required this.simbolo,
    required int hp,
    required int maxHp,
    required this.ataque,
    required this.descricao,
  }) {
    this.hp = hp;
    this.maxHp = maxHp;
  }

  String descreverAcao();

  @override
  String toString() => '$nome ${mostrarBarraVida()}, $descricao';
}
```

## A diferença: extends (IS-A) vs with (HAS-A-BEHAVIOR)

Isso é crucial para entender quando usar cada um:

| Ferramenta | Significado | Exemplo |
|-----------|-----------|---------|
| `extends` | IS-A | `class Zumbi extends Inimigo`: "Um Zumbi IS-A (é um) tipo de Inimigo" |
| `with` | HAS-A-BEHAVIOR | `class Jogador with Combatente`: "Um Jogador HAS-A comportamento Combatente" |

Quando você diz `extends`, você está dizendo "isto é um tipo especializado daquilo". Quando você diz `with`, você está dizendo "isto partilha este conjunto de comportamentos, mas a sua natureza é diferente".

## Um exemplo prático

```dart
final jogador = Jogador(nome: 'Herói', classe: 'Guerreiro', hpInicial: 30);
final zumbi = Zumbi();

jogador.sofrerDano(5);
zumbi.sofrerDano(3);

if (jogador is Zumbi) {
  print('Isto é falso!');
}

if (jogador is Combatente && zumbi is Combatente) {
  print('Ambos sabem combater! Usam o mixin Combatente');
}
```

## Restrições de mixins: on keyword

Por vezes, um `mixin` depende de propriedades específicas. Por exemplo, um `mixin` `Envenenavel` precisa de acesso ao campo `hp` e ao método `sofrerDano()`. Use a palavra-chave `on` para declarar isto:

```dart
// lib/envenenavel.dart

import 'combatente.dart';

mixin Envenenavel on Combatente {
  int veneno = 0;

  void envenenar(int quantidade) {
    veneno += quantidade;
    print('Veneno acumulado: $veneno!');
  }

  void aplicarDanoVeneno() {
    if (veneno > 0) {
      sofrerDano(veneno);
      veneno = 0;
    }
  }
}
```

Agora você pode fazer (uma `class` com múltiplos `mixin`):

```dart
abstract class Inimigo with Combatente, Envenenavel {
  // Inimigo tem acesso a:
  // - sofrerDano(), curar(), estaVivo (de Combatente)
  // - envenenar(), aplicarDanoVeneno() (de Envenenavel)
}
```

## Vários mixins na mesma classe

Você pode aplicar múltiplos `mixin`. Isso é poderoso em Dart (ao contrário de linguagens que só permitem uma classe-mãe):

```dart
// lib/descritivel.dart

mixin Descritivel {
  String get descricaoCompleta => 'Uma criatura indescritível.';

  void apresentar() {
    print('Sou: $descricaoCompleta');
  }
}
```

```dart
class Zumbi extends Inimigo with Combatente, Envenenavel, Descritivel {
  // Agora tem todas as capacidades dos mixins
}
```

## Integração no combate

Vê como tudo se junta quando há combate:

```dart
// lib/turno_combate.dart

class TurnoCombate {
  final Jogador jogador;
  final Inimigo inimigo;

  TurnoCombate(this.jogador, this.inimigo);

  void atacarInimigo(int dano) {
    print('${jogador.nome} ataca!');
    inimigo.sofrerDano(dano);
    print(inimigo.mostrarBarraVida());

    if (!inimigo.estaVivo) {
      print('${inimigo.nome} foi derrotado!');
      return;
    }

    print('${inimigo.nome} contra-ataca!');
    jogador.sofrerDano(inimigo.ataque);
    print('${jogador.nome}: ${jogador.mostrarBarraVida()}');
  }

  void executarCombate() {
    while (jogador.estaVivo && inimigo.estaVivo) {
      print('\n--- Turno ---');
      print('Ataca o ${jogador.nome}?');
      atacarInimigo(5);
    }

    if (jogador.estaVivo) {
      print('Vitória! ${inimigo.nome} foi derrotado!');
    } else {
      print('Derrota... ${jogador.nome} morreu.');
    }
  }
}
```

***

## Desafios da Masmorra

**Desafio 11.1. Mixin Herbívoro.** Crie um mixin `Herbivoro` com um método `comer(String planta)` que imprime "Comi uma $planta! Recuperei 3 HP." e chama `curar(3)`. Aplique-o a uma classe concreta `Coelho` que também herda de `Inimigo with Combatente`. Teste comendo uma maçã.

**Desafio 11.2. Aplicar Combatente ao Jogador (Integração).** Certifique-se de que a sua classe `Jogador` usa `with Combatente`. Teste `sofrerDano()` e `mostrarBarraVida()` no main. Verifique se a barra de vida funciona corretamente durante combate.

**Desafio 11.3. Mixin Voador.** Crie um mixin `Voador` com `bool estaNoAr = false` e métodos `voar()` (coloca `estaNoAr = true`), `pousar()` (coloca `false`). Crie uma classe `Dragao extends Inimigo with Combatente, Voador`. O dragão pode voar enquanto está em combate (aumentando sua defesa?).

**Desafio 11.4. Mixin restrito com on.** Crie um mixin `Regenerador on Combatente` que tem um método `regenerar()` que cura 2 HP por turno. Aplique-o a `Inimigo with Combatente, Regenerador`. O inimigo deve regenerar 2 HP ao final de cada turno de combate.

**Boss Final 11.5. Múltiplos mixins e resolução de conflito.** Crie dois mixins `Lutador` e `Mago`, ambos com métodos `atacar()` que retornam `String`. Depois crie uma classe `Paladim extends Inimigo with Combatente, Lutador, Mago`. Como Dart resolve o conflito? (O último mixin, `Mago`, ganha.) Teste implementando `String atacar()` em ambos e veja qual é chamado. Demonstre a ordem de resolução.

## Pergaminho do Capítulo

Neste capítulo você aprendeu:

- `mixin` são "pacotes reutilizáveis de comportamento" definidos com `mixin`.
- `with` aplica um `mixin` a uma `class`. Uma `class` pode ter múltiplos `mixin`.
- `extends` (IS-A) vs `with` (HAS-A-BEHAVIOR): `extends` é para hierarquias, `with` é para compartilhar comportamento.
- `on` keyword restringe um `mixin` a apenas funcionar com `class` que já têm outro `mixin`.
- Múltiplos `mixin` são poderosos: `class Zumbi with Combatente, Envenenavel, Descritivel`.
- Quando há conflito de nomes (dois `mixin` com `atacar()`), o último `mixin` ganha. Melhor: usar nomes distintos.

`mixin` são particularmente úteis em jogos, onde muitos tipos diferentes de entidades (jogador, inimigos, objetos) compartilham capacidades (receber dano, mover, descrição).

::: dica
**Dica do Mestre:** Mixins resolvem a "Maldição dos Diamantes" melhor que herança múltipla. Em linguagens como C++, herança múltipla pode criar confusão sobre qual classe-mãe fornece qual método. Dart evita isso: é explícito (`with` te diz que é um `mixin`). Se uma `class` `Zumbi` usa `with Combatente, Envenenavel, Descritivel`, toda a gente sabe que tem esses comportamentos. Quando há dúvida sobre compartilhar código, `mixin` são geralmente a resposta mais limpa do que herança profunda.
:::
