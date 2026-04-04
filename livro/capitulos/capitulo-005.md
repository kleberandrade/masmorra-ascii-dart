# Capítulo 5 - Coleções, o inventário do herói

> *O aventureiro abre a mochila. Dentro, uma tocha, uma chave enferrujada e três moedas de ouro. Ele precisa de algo para guardar tudo isso, algo com ordem, algo que associe nomes a coisas, algo que responda rápido: já tenho essa chave?*

Até agora, cada dado do jogo vivia numa variável separada: `nome`, `hp`, `opcao`. Isso funciona para três ou quatro valores, mas um jogo de verdade precisa de listas de itens, mapas de salas, conjuntos de comandos válidos. Neste capítulo, vamos conhecer as três **coleções** fundamentais de Dart: **List**, **Map** e **Set**, e usá-las para dar estrutura real ao jogo.

## **List**, quando a ordem importa

Uma **lista** é uma sequência ordenada de valores. Pense numa fila: o primeiro elemento tem índice 0, o segundo tem índice 1, e assim sucessivamente. No nosso jogo, a lista será essencial para guardar o inventário do jogador, os itens numa sala e a sequência de ações registradas. Quando a ordem importa ou você precisa acessar elementos por posição, use `List`.

```dart
var inventario = ['Tocha', 'Chave Enferrujada', 'Poção de Vida'];
```

O Dart infere o tipo como `List<String>`, uma lista onde cada elemento é uma `String`.

**Acessar elementos por índice:**

```dart
print(inventario[0]);
print(inventario[2]);
print(inventario.length);
```

Cuidado: acessar um índice que não existe causa erro em runtime. Por exemplo, `inventario[5]` crasha se a lista possui apenas 3 elementos.

**Adicionar e remover:**

```dart
inventario.add('Espada Curta');
inventario.insert(0, 'Mapa Antigo');
inventario.remove('Tocha');
inventario.removeAt(1);
```

**Percorrer a lista:**

```dart
for (var item in inventario) {
  print('- $item');
}

for (var i = 0; i < inventario.length; i++) {
  print('${i + 1}. ${inventario[i]}');
}
```

**Verificar conteúdo:**

```dart
inventario.contains('Tocha');
inventario.isEmpty;
inventario.isNotEmpty;
```

**Métodos funcionais** (muito úteis no jogo):

```dart
var numeros = [3, 1, 4, 1, 5, 9];

numeros.where((n) => n > 3).toList();
numeros.map((n) => n * 2).toList();
numeros.any((n) => n > 8);
numeros.every((n) => n > 0);

var armas = ['Adaga', 'Espada', 'Machado'];
var lista = armas.map((a) => '  - $a').join('\n');
print(lista);
```

A sintaxe `(n) => n > 3` é uma arrow function, uma função anônima compacta. Lê-se: para cada `n`, retorne `n > 3`.

## **Map**, quando cada valor tem um nome

Um **mapa** associa chaves a valores, como um dicionário: você procura por uma chave e recebe o valor correspondente. Mapas serão fundamentais no nosso jogo para associar IDs de sala a descrições, nomes de itens a seus preços em ouro ou abreviações a comandos completos. Se você precisa procurar algo por nome e depois recuperar um dado associado, use `Map`.

```dart
var salas = <String, String>{
  'praca': 'Uma praça com uma fonte de pedra murmurante.',
  'taverna': 'Uma taverna barulhenta.',
  'corredor': 'Um corredor estreito e escuro.'
};
```

O tipo é `Map<String, String>`, chaves `String`, valores `String`.

**Acessar valores:**

```dart
var descricao = salas['praca'];
var nada = salas['floresta'];
```

Repare: acessar uma chave que não existe retorna `null`, não um erro. O tipo de retorno é `String?`. O null safety força você a tratar isso:

```dart
var descricao = salas['praca'] ?? 'Local desconhecido.';
```

**Adicionar e remover:**

```dart
salas['portao'] = 'Um portão de ferro oxidado.';
salas.remove('corredor');
```

**Percorrer:**

```dart
for (var entrada in salas.entries) {
  print('${entrada.key}: ${entrada.value}');
}

for (var nome in salas.keys) {
  print(nome);
}

salas.containsKey('taverna');
```

**Mapa de sinônimos**, muito útil para o parser de comandos (interpretador de comandos):

```dart
var sinonimos = <String, String>{
  'n': 'norte', 's': 'sul', 'l': 'leste', 'o': 'oeste',
  'e': 'leste',
  'i': 'inventario',
};

var input = 'n';
var comando = sinonimos[input] ?? input;
```

## **Set**, quando só importa se existe

Um **conjunto** é como uma lista que não permite duplicatas e não garante ordem. Sua vantagem principal é a velocidade: verificar se um elemento existe num `Set` é muito mais rápido que em uma `List`, pois usa uma tabela de hash internamente. No jogo, usaremos `Set` para rastrear salas visitadas, inimigos derrotados ou conquistas desbloqueadas, quando só importa se algo foi feito ou não, não quantas vezes ou em que ordem.

```dart
var chavesPossuidas = <String>{'chave_prata', 'chave_ouro'};

chavesPossuidas.contains('chave_prata');
chavesPossuidas.contains('chave_ferro');

chavesPossuidas.add('chave_ferro');
chavesPossuidas.add('chave_prata');
print(chavesPossuidas.length);
```

No jogo, conjuntos são perfeitos para salas já visitadas, inimigos derrotados, conquistas desbloqueadas. Estruturas como **fila** (Queue) e **pilha** (Stack) são especializações: fila é FIFO (primeiro a entrar, primeiro a sair), pilha é LIFO (último a entrar, primeiro a sair). Não as usaremos diretamente neste jogo, mas são fundamentais em algoritmos como BFS ou backtracking.

```dart
var salasVisitadas = <String>{};

void visitarSala(String id) {
  if (salasVisitadas.contains(id)) {
    print('Você já esteve aqui antes.');
  } else {
    print('Um lugar novo!');
    salasVisitadas.add(id);
  }
}
```

## Listas tipadas, o tipo importa

Dart permite especificar o tipo dos elementos:

```dart
List<String> itens = ['Espada', 'Escudo'];
List<int> danos = [10, 5, 15];
Map<String, int> precos = {'Espada': 100, 'Poção': 30};
Set<String> visitadas = {'praca', 'taverna'};
```

Isso evita misturar tipos por acidente. `itens.add(42)` causa erro de compilação, pois a lista é de `String`, não `int`. Essa segurança de tipos é especialmente valiosa num jogo com centenas de itens. Estruturas de dados são frequentemente visualizadas como **árvores** (hierarquias) ou **grafos** (redes): o mapa da masmorra é, tecnicamente, um grafo, com salas como nós e corredores como arestas.

## O **operador spread** (...)

O **operador spread** (`...`) é uma forma compacta e legível de desempacotar uma coleção dentro de outra. Em vez de manualmente copiar cada elemento de uma lista, você coloca três pontos e deixa o Dart fazer o trabalho. Vamos usar spread o tempo todo para combinar inventários, juntar listas de saídas possíveis ou montar listas de resultado.

```dart
var basicos = ['Tocha', 'Corda'];
var extras = ['Poção', 'Mapa'];
var todosItens = [...basicos, ...extras];
```

Útil para combinar inventários ou montar listas de opções.

## Aplicação no jogo, salas com dados estruturados

Vamos reconstruir o jogo usando coleções para representar o mundo. Cada sala é uma entrada num mapa:

```dart
import 'dart:io';

final salas = <String, Map<String, dynamic>>{
  'praca': {
    'descricao': 'Você está na Praça Central.\n'
        'Uma fonte de pedra murmura ao centro.\n'
        'Tochas iluminam três passagens.',
    'saidas': {'norte': 'corredor', 'leste': 'taverna', 'sul': 'portao'},
    'itens': <String>['Chave Enferrujada'],
  },
  'corredor': {
    'descricao': 'Um corredor estreito e frio.\n'
        'As paredes são úmidas. Algo se move na escuridão.',
    'saidas': {'sul': 'praca'},
    'itens': <String>[],
  },
  'taverna': {
    'descricao': 'Uma taverna aconchegante.\n'
        'O cheiro de cerveja e pão fresco preenche o ar.\n'
        'Um velho sábio está sentado no canto.',
    'saidas': {'oeste': 'praca'},
    'itens': <String>['Poção de Vida'],
  },
  'portao': {
    'descricao': 'Um portão de ferro enorme.\n'
        'Além dele, a escuridão absoluta.\n'
        'Você ainda não está pronto para entrar.',
    'saidas': {'norte': 'praca'},
    'itens': <String>[],
  },
};

final sinonimos = <String, String>{
  'n': 'norte', 's': 'sul', 'l': 'leste', 'o': 'oeste',
  'e': 'leste', 'w': 'oeste',
  'i': 'inventario', 'inv': 'inventario',
};

var salaAtual = 'praca';
var inventario = <String>[];
var salasVisitadas = <String>{};

void exibirSala() {
  var sala = salas[salaAtual] ?? {};
  var descricao = sala['descricao'] as String?;
  var saidasMap = sala['saidas'] as Map<String, String>?;
  var itensNaSala = sala['itens'] as List<String>?;

  var primeira = !salasVisitadas.contains(salaAtual);
  if (primeira) salasVisitadas.add(salaAtual);

  print('');
  if (primeira) {
    print('** Lugar novo! **');
  }
  for (var linha in (descricao ?? '').split('\n')) {
    print(linha);
  }

  var saidasTexto = saidasMap?.keys.map((d) => '[$d]').join(' ') ?? 'Sem saídas';
  print('Saídas: $saidasTexto');

  if (itensNaSala != null && itensNaSala.isNotEmpty) {
    var itensTexto = itensNaSala.join(', ');
    print('No chão: $itensTexto');
  }

  print('');
}

void exibirInventario() {
  print('');
  if (inventario.isEmpty) {
    print('Sua mochila está vazia.');
  } else {
    print('Inventário:');
    for (var i = 0; i < inventario.length; i++) {
      print('  ${i + 1}. ${inventario[i]}');
    }
  }
  print('');
}

void mover(String direcao) {
  var sala = salas[salaAtual] ?? {};
  var saidasMap = sala['saidas'] as Map<String, String>?;

  if (saidasMap != null && saidasMap.containsKey(direcao)) {
    salaAtual = saidasMap[direcao] ?? salaAtual;
    print('Você vai para $direcao...');
    exibirSala();
  } else {
    print('Não há saída para $direcao.');
  }
}

void pegarItem(String nomeItem) {
  var sala = salas[salaAtual] ?? {};
  var itens = sala['itens'] as List<String>?;

  if (itens == null || itens.isEmpty) {
    print('Não há "$nomeItem" aqui.');
    return;
  }

  var encontrado = itens.where(
    (item) => item.toLowerCase() == nomeItem.toLowerCase()
  ).toList();

  if (encontrado.isEmpty) {
    print('Não há "$nomeItem" aqui.');
  } else {
    var item = encontrado.first;
    itens.remove(item);
    inventario.add(item);
    print('Você pegou: $item.');
  }
}

void main() {
  print('');
  print('MASMORRA ASCII v0.2');
  print('');

  stdout.write('Como devo chamá-lo? ');
  var nome = (stdin.readLineSync() ?? '').trim();
  if (nome.isEmpty) nome = 'Aventureiro';

  print('\nBem-vindo, $nome!');
  exibirSala();

  while (true) {
    stdout.write('\n> ');
    var input = (stdin.readLineSync() ?? '').trim().toLowerCase();

    if (input.isEmpty) continue;

    var partes = input.split(' ');
    var cmd = sinonimos[partes[0]] ?? partes[0];
    var argumento = partes.length > 1 ? partes.sublist(1).join(' ') : '';

    switch (cmd) {
      case 'norte' || 'sul' || 'leste' || 'oeste':
        mover(cmd);
      case 'inventario':
        exibirInventario();
      case 'pegar':
        if (argumento.isEmpty) {
          print('Pegar o quê? Use: pegar <item>');
        } else {
          pegarItem(argumento);
        }
      case 'olhar':
        exibirSala();
      case 'sair' || 'quit':
        print('\nAté a próxima aventura, $nome!');
        return;
      case 'ajuda':
        print('Comandos: norte, sul, leste, oeste, pegar <item>,');
        print('          inventario, olhar, ajuda, sair');
      default:
        print('Não entendi "$input". Digite "ajuda" para ver os comandos.');
    }
  }
}
```

Execute e explore:

```text

MASMORRA ASCII v0.2

Como devo chamá-lo? Aldric

Bem-vindo, Aldric!

** Lugar novo! **
Você está na Praça Central.
Uma fonte de pedra murmura ao centro.
Tochas iluminam três passagens.

Saídas: [norte] [leste] [sul]
No chão: Chave Enferrujada

> pegar chave enferrujada
Você pegou: Chave Enferrujada.

> i
Inventário:
  1. Chave Enferrujada

> n
Você vai para norte...

** Lugar novo! **
Um corredor estreito e frio.
As paredes são úmidas. Algo se move na escuridão.

Saídas: [sul]

```

Repare como os mapas e listas tornam o código flexível: adicionar uma nova sala é acrescentar uma entrada em `salas`, não reescrever a lógica. Adicionar um sinônimo é uma linha em `sinonimos`. O mapa de saídas define automaticamente a navegação, sem `if`/`else` para cada direção.

O uso de `dynamic` no mapa de salas não é ideal. No Capítulo 8, classes resolvem isso de forma tipada. Mas por enquanto, funciona e mostra o poder das coleções.

***

## Desafios da Masmorra

**Desafio 5.1. Expandir o mundo (Mais salas).** Adicione pelo menos duas salas novas ao mapa: por exemplo, "Câmara do Tesouro" e "Biblioteca Antiga". Conecte-as ao mundo existente com saídas apropriadas e descrições atmosféricas. Teste navegando até elas e verificando se as saídas funcionam nos dois sentidos.

**Desafio 5.2. Largar itens.** Implemente o comando `"largar <item>"` que remove um item do inventário e o coloca na sala atual (adicionando à lista de `itens` da sala). Valide que o jogador realmente possui o item antes de largá-lo. Dica: é exatamente o inverso de `pegarItem`.

**Desafio 5.3. Limite de inventário com feedback.** Adicione um limite de 5 itens máximo no inventário. Se estiver cheio, mostre uma mensagem clara: "Sua mochila está cheia! Você tem 5/5 itens. Largue algo antes de pegar novo item." Use `.length` para verificar.

**Desafio 5.4. Sala de tesouro (Múltiplos itens).** Adicione uma sala especial "Câmara do Tesouro" com 5 itens valiosos (Moeda de Ouro, Anel de Prata, Diamante, Corrente, Gema). Implemente o comando `"pegar tudo"` que pega todos os itens da sala de uma vez, respeitando o limite do inventário. Se a mochila ficar cheia no meio, mostre quantos pôde pegar.

**Boss Final 5.5. Visualizar o mundo (Mapa de adjacência).** Crie uma função `exibirMapaMundi()` que imprime um diagrama ASCII mostrando todas as salas conectadas. Por exemplo, usando um formato de árvore ou de grafo simples. Use nomes de salas e setas para mostrar as conexões (Praça →[norte] Corredor, etc). Isso ajuda o jogador a visualizar a topologia do mundo.

*Dica do Mestre: Comece simples: imprima cada sala e suas saídas diretas. Próxima evolução: use indentação ou ASCII arrows para mostrar hierarquia. Use `.keys` para iterar sobre as salas e `.entries` para pegar chaves e valores (conexões).*

## Pergaminho do Capítulo

Neste capítulo você aprendeu `List` para sequências ordenadas, `Map` para associar chaves a valores, `Set` para conjuntos de valores únicos, métodos essenciais como `.add`, `.remove`, `.contains`, `.where`, `.map` e `.join`, a sintaxe de arrow functions, e o operador spread `...`.

O jogo agora tem um mundo real com salas conectadas, itens coletáveis e navegação por comandos de texto. No Capítulo 6, vamos dar um salto visual: construir molduras, barras e arte ASCII usando `StringBuffer`.

::: dica
**Dica do Mestre:** Resista à tentação de usar `Map<String, dynamic>` para tudo. É flexível mas perde toda a segurança de tipos. No Capítulo 8, vamos substituir esses mapas por classes tipadas, e muitos bugs potenciais vão simplesmente desaparecer.
:::
