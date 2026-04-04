# Capítulo 10 - Herança: a família dos inimigos

> *Toda a masmorra é feita de famílias de criaturas. Um zumbi é um zumbi porque tem aquele espírito errante e faminto. Um esqueleto é resistente mas lento. Se você modelar cada um separadamente, o código fica repleto de cópias. Mas se você criar uma antepassada comum, uma classe `Inimigo`, você define uma vez o que qualquer criatura faz e deixa cada descendente escolher seu próprio caminho. Assim cresce a masmorra: através de herança e extends.*

## A família de inimigos: onde a herança brilha

Quando você começou a desenhar a `Jogador`, copiou muito código. Linhas iguais: `int hp`, `int maxHp`, `String nome`. Agora vai criar inimigos: `Zumbi`, `Esqueleto`, `Lobo`, e pode parecer que, se copiar a mesma estrutura várias vezes, em seis meses quando precisar mudar "calcular dano", vai ter de editar em múltiplos lugares. Isso se chama duplicação de código, e é o sintoma clássico de que você precisa de herança.

**Herança** em Dart significa: uma `class` "herda" de outra. A classe-mãe (ou superclasse) define o que é comum; a classe-filha (ou subclasse) especifica o que é diferente.

## O primeiro conceito: **extends**

```dart
// lib/inimigo.dart

abstract class Inimigo {
  final String nome;
  final String simbolo;
  int hp;
  final int maxHp;
  final int ataque;
  final String descricao;

  Inimigo({
    required this.nome,
    required this.simbolo,
    required this.hp,
    required this.maxHp,
    required this.ataque,
    required this.descricao,
  });

  void sofrerDano(int d) {
    hp -= d;
    if (hp < 0) {
      hp = 0;
    }
  }

  bool get estaVivo => hp > 0;

  String descreverAcao();

  @override
  String toString() => '$nome (HP: $hp/$maxHp), $descricao';
}
```

Nota bem a palavra-chave `abstract`. Uma **classe abstrata** é um contrato de abstração: define o que toda subclasse deve fazer, mas não é uma entidade que você pode criar diretamente com `Inimigo(...)`. Isso força os criadores de zumbis, esqueletos etc. a respeitar a interface.

## As três famílias: Zumbi, Esqueleto, Lobo

Agora vêm os filhos. Cada um `extends Inimigo` (herda da classe-mãe). Nem todo baú é o que parece—alguns inimigos têm natureza enganadora, como aqueles que fingem ser simples cofres de tesouro. Mas comecemos com os mais óbvios:

```dart
// lib/zumbi.dart

import 'inimigo.dart';

class Zumbi extends Inimigo {
  Zumbi()
      : super(
          nome: 'Zumbi',
          simbolo: 'Z',
          hp: 8,
          maxHp: 8,
          ataque: 3,
          descricao: 'Uma criatura de decomposição e vontade de carne.',
        );

  @override
  String descreverAcao() {
    return 'O Zumbi grunhe e avança, despedaçando o ar!';
  }
}
```

```dart
// lib/esqueleto.dart

import 'inimigo.dart';

class Esqueleto extends Inimigo {
  Esqueleto()
      : super(
          nome: 'Esqueleto',
          simbolo: 'E',
          hp: 15,
          maxHp: 15,
          ataque: 4,
          descricao: 'Ossos antigos, alma presa. '
              'Rangem com cada passo.',
        );

  @override
  String descreverAcao() {
    return 'O Esqueleto levanta o braço ósseo, '
        'você sente o frio da morte.';
  }
}
```

```dart
// lib/lobo.dart

import 'inimigo.dart';

class Lobo extends Inimigo {
  Lobo()
      : super(
          nome: 'Lobo',
          simbolo: 'L',
          hp: 5,
          maxHp: 5,
          ataque: 2,
          descricao: 'Uma criatura selvagem de garras afiadas.',
        );

  @override
  String descreverAcao() {
    return 'O Lobo rosna ameaçadoramente, dentes à mostra.';
  }
}
```

```dart
// lib/mimico.dart
// Classe em ASCII (`Mimico`); nome exibido no jogo continua
// acentuado.

import 'inimigo.dart';

class Mimico extends Inimigo {
  Mimico()
      : super(
          nome: 'Mímico',
          simbolo: 'M',
          hp: 12,
          maxHp: 12,
          ataque: 5,
          descricao: 'Um baú vivo. Nem todo tesouro é o que parece.',
        );

  @override
  String descreverAcao() {
    return 'O baú se abre de repente! Garras saem de suas laterais!';
  }
}
```

## A palavra-chave @override

Quando você redefine um método da classe-mãe (como `descreverAcao()`), marca-o com `@override`. Isso diz ao analisador Dart: "Sei que estou redefinindo isto propositalmente". Se você escrever o nome errado, o Dart avisa antes de você rodar o programa:

```dart
@override
String descreverAcao() {
  return '...';
}
```

## Como chama-se a relação IS-A

Quando você diz `class Zumbi extends Inimigo`, está dizendo: um Zumbi IS-A (é um) Inimigo. Isso significa:

- Um `Zumbi` é um `Inimigo` (pode ser usado onde se espera um `Inimigo`).
- Um `Zumbi` herda todos os campos e métodos de `Inimigo`.
- Um `Zumbi` pode redefinir (`@override`) métodos para ter comportamento específico.

Se você quiser tratar todos os inimigos de forma igual (no combate, por exemplo), você pode armazenar qualquer inimigo numa variável do tipo `Inimigo`:

```dart
Inimigo ini = Zumbi();
print(ini.estaVivo);
ini.sofrerDano(3);
print(ini.descreverAcao());
```

## MundoTexto: o mapa de salas como um grafo

Agora você precisa de um lugar para guardar os inimigos: as salas. Uma `Sala` pode conter um inimigo. O mapa de salas é um grafo dirigido onde os nós são `Sala` e as arestas são as direções.

> **Nota sobre inimigoPresente:** No Capítulo 8, usávamos `inimigoId: String?` como simples texto. Agora, armazenamos a instância do inimigo diretamente com `inimigoPresente: Inimigo?`. Isso é mais poderoso e totalmente tipado: podemos chamar métodos do inimigo (como `inimigoPresente.sofrerDano()`) sem conversões.

```dart
// lib/sala.dart

import 'inimigo.dart';

class Sala {
  final String id;
  final String nome;
  final String descricao;
  final Map<String, String> saidas;
  final bool temLoja;
  Inimigo? inimigoPresente;

  Sala({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.saidas,
    this.temLoja = false,
    this.inimigoPresente,
  });

  @override
  String toString() => '$nome ($id)';
}
```

```dart
// lib/mundo_texto.dart

class MundoTexto {
  final Map<String, Sala> salas;

  MundoTexto({required this.salas});

  Sala? obterSala(String id) => salas[id];

  bool temSaida(String salaId, String direcao) {
    final sala = obterSala(salaId);
    return sala?.saidas.containsKey(direcao) ?? false;
  }

  String? irParaDirecao(String salaId, String direcao) {
    final sala = obterSala(salaId);
    return sala?.saidas[direcao];
  }
}
```

## Populando o mundo com inimigos

Aqui está como você integra tudo numa criação do mundo:

```dart
// lib/mundo_dados.dart

import 'inimigo.dart';
import 'zumbi.dart';
import 'esqueleto.dart';
import 'lobo.dart';
import 'sala.dart';
import 'mundo_texto.dart';

MundoTexto criarMundoVila() {
  final salas = {
    'praca': Sala(
      id: 'praca',
      nome: 'Praça da Vila',
      descricao: 'O coração da vila. Uma fonte antiga no centro.',
      saidas: {
        'norte': 'taverna',
        'leste': 'mercado',
      },
      inimigoPresente: null,
    ),
    'taverna': Sala(
      id: 'taverna',
      nome: 'Taverna do Galo Bravo',
      descricao: 'Fumo, som de risadas, cheiro a cerveja.',
      saidas: {
        'sul': 'praca',
        'norte': 'floresta',
      },
      inimigoPresente: Zumbi(),
    ),
    'mercado': Sala(
      id: 'mercado',
      nome: 'Mercado da Vila',
      descricao: 'Bancas de comida, armas, e poções.',
      saidas: {
        'oeste': 'praca',
        'norte': 'cripta',
      },
      temLoja: true,
      inimigoPresente: null,
    ),
    'floresta': Sala(
      id: 'floresta',
      nome: 'Floresta Escura',
      descricao: 'Árvores altas. Sons estranhos na escuridão.',
      saidas: {
        'sul': 'taverna',
        'norte': 'caverna',
      },
      inimigoPresente: Lobo(),
    ),
    'cripta': Sala(
      id: 'cripta',
      nome: 'Cripta Antiga',
      descricao: 'Lápides rotas. Silêncio assustador.',
      saidas: {
        'sul': 'mercado',
      },
      inimigoPresente: Esqueleto(),
    ),
    'caverna': Sala(
      id: 'caverna',
      nome: 'Caverna do Dragão',
      descricao: 'Escura demais. Você sente respiração quente.',
      saidas: {
        'sul': 'floresta',
      },
      inimigoPresente: null,
    ),
  };

  return MundoTexto(salas: salas);
}
```

***

## Desafios da Masmorra

**Desafio 10.1. Novo tipo de inimigo (Orc).** Crie uma classe `Orc` que estende `Inimigo`. Dê-lhe: HP=12, maxHp=12, ataque=5, símbolo='O', e uma descrição agressiva ("Um orc musculoso com fome de batalha"). Sobrescreva `descreverAcao()` para retornar algo temível como "O orc rosna e levanta sua clava!". Teste criando uma instância e imprimindo.

**Desafio 10.2. Popule o mundo com Orcs.** Mude a `cripta` no `MundoTexto` para ter um `Orc` em vez de `Esqueleto`. Verifique se o símbolo `'O'` aparece corretamente. Adicione também um `Orc` em outra sala, por exemplo a `caverna`.

**Desafio 10.3. Método em MundoTexto (Listar todos).** Escreva um método `List<Inimigo> todosOsInimigos()` em `MundoTexto` que devolve uma lista com todos os inimigos das salas (filtrando nulos). Teste imprimindo um relatório de todos os inimigos encontrados, mostrando nome, tipo e HP.

**Desafio 10.4. Sala de Combate obrigatório.** Crie uma classe `SalaCombate extends Sala` que força a derrota do inimigo antes de permitir sair. Adicione um método `bool podeSair()` que verifica se o `inimigoPresente` está vivo. O jogador pode executar ações normais, mas `"sair"` retorna erro se o inimigo não estiver derrotado.

**Desafio 10.5. Hierarquia de três níveis (Avó e netos).** Crie uma classe `BipedeInteligente extends Inimigo` (sem `abstract`) que adiciona um campo `inteligencia: int` e um método `String insulto()`. Depois crie `Zumbi` e `Orc` estendendo `BipedeInteligente` e sobrescrevendo `insulto()` com mensagens diferentes. Teste a hierarquia: Zumbi → BipedeInteligente → Inimigo.

**Boss Final 10.6. Integrar combate ao game loop.** Refatore o game loop do Capítulo 7 para usar a classe `Jogador` em vez de variáveis soltas. Depois, modifique as salas para conter inimigos (use `Sala.inimigoPresente`). Quando o jogador entrar numa sala com inimigo, mostre: "Um [Zumbi] está aqui! [Z] HP: 5/8". Adicione o comando `"atacar"` que reduz o HP do inimigo e toca um turno do inimigo atacando de volta. Sem a classe `Combate` ainda; apenas lógica simples de turnos. Quando o inimigo morre, a sala fica segura.

## Pergaminho do Capítulo

Neste capítulo você aprendeu:

- Herança (`extends`) permite que uma `class` herde campos e métodos de outra.
- `abstract class` definem um contrato que as subclasses devem cumprir.
- `@override` marca explicitamente que você está redefinindo um método da classe-mãe.
- IS-A: um `Zumbi` IS-A `Inimigo`, pode ser usado onde se espera um `Inimigo`.
- `MundoTexto` encapsula um `Map<String, Sala>`, modelando o mapa como um grafo dirigido.
- Salas podem conter inimigos, criando o cenário para combate no próximo capítulo.

A herança é a ferramenta clássica para eliminar duplicação quando há uma relação clara "tipo de". No próximo capítulo, veremos mixins, que servem para compartilhar comportamento sem forçar uma árvore de herança profunda.

::: dica
**Dica do Mestre:** Evite hierarquias profundas. A cada vez que você adiciona um nível de herança, aumenta a complexidade. Depois de três níveis (`Inimigo > BipedeInteligente > Zumbi`), fica difícil compreender onde cada comportamento vem. Use herança quando há uma razão clara para IS-A; caso contrário, prefira composição (guardar um objeto dentro de outro) ou `mixin`. Dart favorece composição e `mixin` para código mais limpo.
:::

## Próximo Capítulo

No próximo capítulo, descobrimos poderes compartilhados. Mixins permitem que qualquer criatura ganhe habilidades sem herança múltipla.
