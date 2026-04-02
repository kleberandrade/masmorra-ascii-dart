# Capítulo 13 - Ouro, Armas e Inventário

> *Toda mochila de aventureiro carrega histórias. Um bastão em mãos certas é a diferença entre vida e tumba. O ouro abre portas, as poções salvam vidas, as armas transformam um novato em guerreiro. O que você carrega define quem você é.*

## O que vamos aprender

Neste capítulo você vai:
- Modelar itens como classes (identidade, preço, peso)
- Criar hierarquia de classes com `extends` (Arma estende Item)
- Implementar um sistema de equipamento com slots e validações
- Construir um sistema de economia (ouro, compra, venda)
- Entender como equipamento afeta estatísticas (dano total, defesa total)

Ao final, você terá um **inventário** (mochila) completamente funcional que o jogo possa usar para compras, trocas, e combate.

## Parte 1: Pensando em Itens. Abstração

Antes de codificar, vamos pensar como um designer. Um item numa masmorra tem características gerais:
- Um identificador único (ID)
- Um nome legível (o que mostra na tela)
- Uma descrição (sabor do jogo)
- Um preço (quanto custa comprar)
- Um peso (realismo mínimo)

Mas nem todos os itens são iguais. Uma espada é um `Item`, mas precisa de `dano`. Uma armadura é `Item`, mas precisa de `defesa`. Uma poção é `Item`, mas precisa de `efeitoHps`.

Essa é a oportunidade perfeita para herança de classes.

## Conceito: Herança com extends

Em Dart, você pode criar uma `class` base (`Item`) e depois especializá-la com `extends`. Esta é uma oportunidade perfeita para herança: todos os itens têm propriedades comuns (nome, preço, peso), mas cada tipo especializa isso de forma diferente. Vamos começar com a classe `Item` genérica que serve como base para todos os itens da masmorra.

```dart
// lib/item.dart - A classe genérica

class Item {
  final String id;
  final String nome;
  final String descricao;
  final int preco;
  final int peso;

  Item({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.peso,
  });

  @override
  String toString() => '$nome (id: $id, preço: $preco ouro, peso: $peso)';
}
```

Agora, uma arma é tudo que `Item` é, mais dano. Use `extends` para herança:

```dart
// lib/arma.dart

class Arma extends Item {
  final int dano;
  final String tipo;

  Arma({
    required String id,
    required String nome,
    required String descricao,
    required int preco,
    required int peso,
    required this.dano,
    required this.tipo,
  }) : super(
    id: id,
    nome: nome,
    descricao: descricao,
    preco: preco,
    peso: peso,
  );

  @override
  String toString() => '$nome ($tipo, +$dano dano) . $descricao';
}
```

Nota importante: quando você faz `class Arma extends Item`, a `class` `Arma` herda todos os atributos de `Item`. Por isso você passa `id`, `nome`, etc. ao construtor `super()`, assim a classe-pai é inicializada corretamente.

## Testando a Herança

Agora vamos criar alguns items concretos e testar como herança permite que `Arma` reutilize todos os campos de `Item`, adicionando apenas o que é específico de armas. Observe como o construtor de `Arma` passa os dados genéricos via `super()` para inicializar a classe-mãe.

```dart
void main() {
  final pocao = Item(
    id: 'pocao-simples',
    nome: 'Poção de Vida',
    descricao: 'Recupera 10 HP',
    preco: 50,
    peso: 1,
  );

  final espada = Arma(
    id: 'espada-bastarda',
    nome: 'Espada Bastarda',
    descricao: 'Uma lâmina versátil de dois gumes',
    preco: 300,
    peso: 4,
    dano: 12,
    tipo: 'cortante',
  );

  print(pocao);
  print(espada);

  print('Preço: ${espada.preco}');
}
```

Por que herança (`extends`) é boa aqui?
- Reutilização: não repetimos `id`, `nome`, `descricao`, etc. em cada `class`.
- Polimorfismo: numa `List<Item>` você pode misturar items genéricos, armas, armaduras.
- Manutenibilidade: se mudar o que um `Item` é, automaticamente todas as subclasses mudam.

## Parte 2: Armadura

Vamos criar `class Armadura` pelo mesmo princípio (`extends Item`). Assim como `Arma`, uma `Armadura` herda todas as propriedades de `Item` (nome, preço, peso) e adiciona seu próprio comportamento específico (quanto de defesa oferece e em qual parte do corpo se encaixa).

```dart
// lib/armadura.dart

class Armadura extends Item {
  final int defesa;
  final String localizacao;

  Armadura({
    required String id,
    required String nome,
    required String descricao,
    required int preco,
    required int peso,
    required this.defesa,
    required this.localizacao,
  }) : super(
    id: id,
    nome: nome,
    descricao: descricao,
    preco: preco,
    peso: peso,
  );

  @override
  String toString() => '$nome (+$defesa DEF em $localizacao)';
}
```

Agora temos:

```dart
final peitoral = Armadura(
  id: 'peitoral-couro',
  nome: 'Peitoral de Couro Endurecido',
  descricao: 'Proteção leve e flexível',
  preco: 150,
  peso: 3,
  defesa: 5,
  localizacao: 'peito',
);

print(peitoral);
```

## Parte 3: O Inventário. Uma Lista com Propósito

O jogador tem uma mochila: uma `List<Item>` onde qualquer `Item` cabe (herança permite **polimorfismo**). Esse é o poder da herança em ação: graças a `Arma extends Item` e `Armadura extends Item`, você pode guardar qualquer tipo de item numa única lista, sem necessidade de casts ou verificações de tipo. A mochila não precisa saber se contém uma arma ou uma poção, só sabe que são itens.

```dart
// lib/jogador.dart (trecho)

class Jogador {
  String nome;
  int hp;
  int maxHp;
  int ouro;
  List<Item> inventario;

  Jogador({
    required this.nome,
    required this.maxHp,
    required this.ouro,
    this.inventario = const [],
  }) : hp = maxHp;

  void adicionarItem(Item item) {
    inventario.add(item);
  }

  void listarInventario() {
    if (inventario.isEmpty) {
      print('Sua mochila está vazia.');
      return;
    }
    print('\n=== INVENTÁRIO ===');
    for (int i = 0; i < inventario.length; i++) {
      print('${i + 1}. ${inventario[i]}');
    }
  }

  Item? removerItem(int indice) {
    if (indice < 0 || indice >= inventario.length) {
      return null;
    }
    return inventario.removeAt(indice);
  }
}
```

Vantagem de indexar: quando você escreve `vender 2`, você sabe exatamente qual item é o segundo da lista.

## Parte 4: Equipamento. Slots e Validação

Equipar uma arma significa tirar da mochila e pôr na mão. Para isso, o jogador precisa de slots (variáveis que guardam qual item está equipado). Note o operador `is`: você usa `is Arma` e `is Armadura` para verificar o tipo específico do item antes de tentar equipar. Isso é crucial porque nem todo `Item` é uma arma.

```dart
// lib/jogador.dart (continuação)

class Jogador {
  Arma? armaEquipada;
  Armadura? armaduraEquipada;

  bool equiparArma(int indiceNoInventario) {
    final item = inventario[indiceNoInventario];

    if (item is! Arma) {
      print('Isso não é uma arma!');
      return false;
    }

    if (armaEquipada != null) {
      inventario.add(armaEquipada!);
    }

    inventario.removeAt(indiceNoInventario);
    armaEquipada = item;
    print('Você equipou ${item.nome}!');
    return true;
  }

  void desequiparArma() {
    if (armaEquipada == null) {
      print('Você não tem uma arma equipada!');
      return;
    }
    inventario.add(armaEquipada!);
    print('Você desequipou ${armaEquipada!.nome}.');
    armaEquipada = null;
  }

  bool equiparArmadura(int indiceNoInventario) {
    final item = inventario[indiceNoInventario];

    if (item is! Armadura) {
      print('Isso não é uma armadura!');
      return false;
    }

    if (armaduraEquipada != null) {
      inventario.add(armaduraEquipada!);
    }

    inventario.removeAt(indiceNoInventario);
    armaduraEquipada = item;
    print('Você equipou ${item.nome}!');
    return true;
  }

  void desequiparArmadura() {
    if (armaduraEquipada == null) {
      print('Você não tem armadura equipada!');
      return;
    }
    inventario.add(armaduraEquipada!);
    print('Você desequipou ${armaduraEquipada!.nome}.');
    armaduraEquipada = null;
  }
}
```

O operador `is`: `item is Arma` pergunta "item é do tipo `Arma`?". Se não for, retorna `false` e você trata graciosamente. Também existe `is!` para "não é". Seguro e legível.

## Parte 5: Dano Total. Equação Simples

Agora, o dano do jogador não é mais fixo. Depende do que ele está carregando. Uma das maravilhas de um sistema de equipamento real é que as estatísticas são dinâmicas: se você equipa uma espada melhor, o dano total sobe imediatamente. Isso usa o padrão `get` do Dart (uma propriedade calculada) para sempre retornar o dano atualizado.

```dart
// lib/jogador.dart

class Jogador {
  int danoBase = 5;

  int get danoTotal {
    int total = danoBase;
    if (armaEquipada != null) {
      total += armaEquipada!.dano;
    }
    return total;
  }

  int get defesaTotal {
    int total = 2;
    if (armaduraEquipada != null) {
      total += armaduraEquipada!.defesa;
    }
    return total;
  }

  void mostraStatus() {
    print('\n== STATUS ==');
    print('HP: $hp/$maxHp');
    print('Dano: $danoTotal (base: $danoBase' +
          (armaEquipada != null ? ' + ${armaEquipada!.dano} arma' : '') +
          ')');
    print('Defesa: $defesaTotal (base: 2' +
          (armaduraEquipada != null ? ' + ${armaduraEquipada!.defesa} armadura' : '') +
          ')');
    print('Ouro: $ouro');
  }
}
```

Propriedade `get`: `int get danoTotal { ... }` é uma propriedade calculada. Você acessa com `jogador.danoTotal`, não `jogador.danoTotal()`. Dart calcula o valor à hora, sempre atualizado. É como um getter sem parênteses.

## Parte 6: Economia. Ouro, Compra e Venda

O jogador tem `int ouro` que funciona como a moeda do jogo. Um sistema de economia é essencial em masmorra: faz o jogador escolher (comprar a espada cara agora ou economizar?), cria sacrifício (vender items para comprar melhores). Note que ao vender você recebe 50% do preço: isso é economia de jogo típica que desincentiva spam de compra/venda e mantém o ouro valioso.

```dart
// lib/jogador.dart

class Jogador {
  int ouro;

  bool tentarComprar(Item item) {
    if (ouro < item.preco) {
      print('Dinheiro insuficiente! Custa ${item.preco}, você tem $ouro.');
      return false;
    }

    ouro -= item.preco;
    inventario.add(item);
    print('Comprou ${item.nome} por ${item.preco} ouro!');
    return true;
  }

  bool tentarVender(int indiceNoInventario) {
    if (indiceNoInventario < 0 || indiceNoInventario >= inventario.length) {
      print('Índice inválido!');
      return false;
    }

    final item = inventario[indiceNoInventario];

    if (armaEquipada == item || armaduraEquipada == item) {
      print('Você não pode vender algo que está equipado! Desequipe primeiro.');
      return false;
    }

    int precoVenda = (item.preco * 0.5).toInt();
    ouro += precoVenda;
    inventario.removeAt(indiceNoInventario);
    print('Vendeu ${item.nome} por $precoVenda ouro.');
    return true;
  }
}
```

Nota: ao vender, você recebe 50% do valor (calculado com `(item.preco * 0.5).toInt()`). Isso é economia de jogo típica, desincentiva spam de compra/venda.

## Parte 7: Loot Tables. Drop de Items

Quando um inimigo morre, às vezes deixa items. Vamos criar uma tabela simples usando um `Map<String, List<Item>>` que mapeia cada tipo de inimigo para os itens que pode droppar. Isso é comum em RPGs: um zumbi droppa moedas sujas e armas fracas, enquanto um esqueleto droppa tesouro mais valioso de guerreiro antigo. Usamos `Random` para escolher aleatoriamente qual item da lista ele deixa.

```dart
// lib/loot_table.dart

import 'dart:math';
import 'item.dart';
import 'arma.dart';

final Map<String, List<Item>> lootTablePorInimigo = {
  'zumbi': [
    Item(
      id: 'moedas-sujas',
      nome: 'Moedas Sujas',
      descricao: 'Ouro roubado que o zumbi carregava',
      preco: 5,
      peso: 0,
    ),
    Arma(
      id: 'cutelo-enferrujado',
      nome: 'Cutelo Enferrujado',
      descricao: 'Uma arma pobre, mas cortante',
      preco: 40,
      peso: 2,
      dano: 4,
      tipo: 'cortante',
    ),
  ],
  'esqueleto': [
    Arma(
      id: 'sabre-ossudo',
      nome: 'Sabre do Túmulo',
      descricao: 'Arma de um cavaleiro há séculos falecido',
      preco: 120,
      peso: 3,
      dano: 9,
      tipo: 'cortante',
    ),
    Item(
      id: 'anel-prata',
      nome: 'Anel de Prata',
      descricao: 'Um adorno antigo, de valor incerto',
      preco: 80,
      peso: 0,
    ),
  ],
};

Item? obterLootAleatorio(String nomeDoInimigo) {
  final loot = lootTablePorInimigo[nomeDoInimigo];
  if (loot == null || loot.isEmpty) {
    return null;
  }

  final random = Random();
  return loot[random.nextInt(loot.length)];
}
```

Importar `Random` do pacote `dart:math`:
```dart
import 'dart:math';
```

## Parte 8: Constantes. Items Predefinidos

É conveniente ter items já prontos como constantes globais. Assim, toda vez que você quer dar uma espada ao jogador (no inicio, na loja, como loot), você reutiliza a mesma definição. Evita duplicação e torna fácil balancear (mudar o dano em um só lugar).

```dart
// lib/items_base.dart

final espadaDeBronze = Arma(
  id: 'espada-bronze',
  nome: 'Espada de Bronze',
  descricao: 'Uma arma comum, de metal maleável',
  preco: 200,
  peso: 3,
  dano: 8,
  tipo: 'cortante',
);

final pocaoDeVida = Item(
  id: 'pocao-vida',
  nome: 'Poção de Vida',
  descricao: 'Recupera 20 HP',
  preco: 50,
  peso: 1,
);

final camisaDeCouro = Armadura(
  id: 'camisa-couro',
  nome: 'Camisa de Couro',
  descricao: 'Proteção básica, elegante e prática',
  preco: 100,
  peso: 2,
  defesa: 3,
  localizacao: 'peito',
);

final lojaPrincipal = [
  espadaDeBronze,
  pocaoDeVida,
  camisaDeCouro,
];
```

## Parte 9: Exemplo Completo. Uma Sessão de Jogo

Vamos ver tudo funcionando junto: um jogador compra items, equipa armas, vê seu dano aumentar, vende items para financiar novas compras. Este exemplo mostra o sistema de economia e equipamento em ação, desde a criação do jogador até a manipulação do inventário.

```dart
void main() {
  final jogador = Jogador(
    nome: 'Aldric',
    maxHp: 100,
    ouro: 500,
  );

  print('=== SESSÃO DE JOGO ===\n');

  jogador.mostraStatus();

  print('\n--- Entrando na Loja ---');
  print('Espada de Bronze custa 200 ouro.');
  jogador.tentarComprar(espadaDeBronze);
  jogador.mostraStatus();

  print('\n--- Equipando ---');
  jogador.equiparArma(0);
  jogador.mostraStatus();

  print('\n--- Compra 2 ---');
  jogador.tentarComprar(camisaDeCouro);
  jogador.equiparArmadura(0);
  jogador.mostraStatus();

  print('\n--- Compra 3 (vai falhar) ---');
  jogador.tentarComprar(Arma(
    id: 'espada-draco',
    nome: 'Espada do Dragão',
    descricao: 'Lendária',
    preco: 2000,
    peso: 5,
    dano: 25,
    tipo: 'cortante',
  ));

  jogador.mostraStatus();

  if (jogador.inventario.isNotEmpty) {
    print('\n--- Vendendo ---');
    jogador.tentarVender(0);
  }

  jogador.mostraStatus();
}
```

***

## Desafios da Masmorra

**Desafio 13.1. Item Consumível (Poções).** Crie uma classe `Consumivel extends Item` com um atributo `efeito` (string descrevendo o efeito, ex: "Cura 30 HP") e `hpRecuperado: int`. Implemente na classe `Jogador` um método `usarConsumivel(int indice)` que remove o item do inventário, aplica o efeito (chama `curar(hpRecuperado)`), e mostra a mensagem de efeito.

**Desafio 13.2. Limite de peso realista.** Adicione um getter `pesoTotalInventario` ao `Jogador` que calcula o peso total. Implemente um limite de 5000 gramas total. O método `tentarEquipar(Arma a)` deve verificar se a mochila não ficará muito pesada. Se exceder, mostre: "Sua mochila está muito pesada! Largue algo antes de equipar."

**Desafio 13.3. Comparador de itens.** Crie um método `String compararItens(int indice1, int indice2)` na classe `Jogador` que recebe dois índices e retorna uma string comparando: qual tem mais dano/defesa/efeito? Útil para o jogador decidir qual equipar.

**Desafio 13.4. Venda em massa.** Implemente um método `int venderTodosDoTipo<T extends Item>()` que vende todos os itens de tipo T (exceto equipados) e retorna o ouro total obtido. Por exemplo, `venderTodosDoTipo<Consumivel>()` vende todas as poções de uma vez.

**Boss Final 13.5. Sistema de Loja.** Crie uma classe `Loja` com um `String nome`, um `List<Item> estoque`, e um `double taxaMarcup` (ex: 1.2 para 20% mais caro). Implemente `bool venderAoJogador(Jogador j, int indiceEstoque)` que verifica ouro, cobra com markup, e adiciona ao inventário. Implemente `bool comprarDoJogador(Jogador j, int indiceInventario)` que compra a 50% do preço. Demonstre uma loja funcional.

## Pergaminho do Capítulo

Neste capítulo você aprendeu:

- Herança (`extends`): classes filhas (`Arma`, `Armadura`) herdam de `Item`, reutilizando código e criando uma hierarquia lógica.
- Inventário: uma simples `List<Item>` que mantém ordem, crucial para indexação. Suporta qualquer subclasse de `Item`.
- Equipamento: slots (`armaEquipada`, `armaduraEquipada`) que guardam o que o jogador está usando.
- Estatísticas calculadas: `danoTotal` e `defesaTotal` usando `get` que combinam base + bônus de equipamento.
- Economia: ouro sobe/desce com compra e venda, com validações para evitar negativo.
- Loot tables: mapeamentos `String → List<Item>` que simulam drops realistas.

No próximo capítulo, vamos usar todo esse sistema num combate real, onde o dano que você calcula aqui vai fazer diferença.

::: dica
**Dica do Mestre:** `sealed class` (Dart 3+) são incríveis para limitar a hierarquia. Use `sealed class Item` e `final class Arma extends Item` para garantir que apenas `Arma`, `Armadura`, `Consumivel` podem estender `Item`. Com `sealed`, o compilador avisa se você esquecer um caso num `switch`. Isso previne bugs no futuro, quando adicionar novos tipos.
:::
