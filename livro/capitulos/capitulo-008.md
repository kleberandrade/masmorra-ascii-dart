# Capítulo 8 - Classes: dando vida ao jogador

*Você deixou de ser turista na masmorra; agora é artesão. Classes são a forja onde você molda jogadores, inimigos e itens com precisão. Herança conecta criaturas em linhagens, como famílias de monstros que compartilham traços mas guardam suas próprias surpresas. Mixins são habilidades que qualquer criatura pode aprender, como um pergaminho de poder colado nas costas de quem precisar.*

*Nesta parte, o código deixa de ser uma sequência de instruções e vira um conjunto de objetos que conversam entre si. Você vai criar seu primeiro sistema de combate por turnos, com inventário, equipamentos e inimigos que morrem de verdade. Quando o último Zumbi cair, você vai perceber que não está mais apenas programando. Está construindo um mundo.*

> *Na mesa do mestre do jogo, a ficha do personagem é mais que números, é identidade. Nome, vida, força, inventário, tudo organizado numa folha. Em Dart, essa ficha chama-se classe. E o personagem escrito a lápis é o objeto.*

No Capítulo 7, o jogador era um punhado de variáveis soltas: `nomeJogador`, `hp`, `ouro`, `inventario`, `salaAtual`. Funcionava, mas era frágil. Se quiséssemos dois jogadores (multiplayer?), teríamos que duplicar tudo manualmente. Se uma função precisasse de todos os dados do jogador, teríamos que passar seis parâmetros; e se alguém alterasse `hp` num canto obscuro do código, não havia como rastrear.

Classes resolvem tudo isso. Uma **classe** agrupa dados relacionados e as operações que atuam sobre eles num único lugar. É a ferramenta mais importante de Dart (e de qualquer linguagem orientada a objetos), e a partir deste capítulo ela estará em cada linha do jogo.

## O conceito: classe vs objeto

Uma `class` é um molde. Ela descreve o que um tipo de coisa tem e o que pode fazer. A `class` `Jogador` diz: "um jogador tem nome, HP, ouro e inventário. Pode sofrer dano, coletar itens e equipar armas."

Um **objeto** (ou instância) é uma coisa concreta criada a partir desse molde. Quando você escreve `var heroi = Jogador('Aldric')`, está criando um objeto específico: o jogador Aldric, com seus próprios valores de HP, ouro e inventário.

A analogia clássica: a classe é a planta de uma casa; o objeto é a casa construída. Você pode construir várias casas a partir da mesma planta, e cada uma tem sua própria cor de parede e mobília.

## Criando a classe Jogador

A forma mais direta de transformar dados soltos em um objeto é criar uma classe que agrupa tudo. Uma classe Dart começa com `class` seguido do nome em PascalCase, depois declara os campos (dados que cada instância carrega) e o construtor (a função especial que cria novas instâncias). Para o Jogador, precisamos de nome, HP, ouro, arma, localização atual e inventário. Todos esses dados vivem juntos, são modificados em conjunto e fazem parte da mesma entidade.

```dart
class Jogador {
  String nome;
  int hp;
  int maxHp;
  int ouro;
  int ataque;
  String salaAtual;
  List<String> inventario;

  Jogador(this.nome, {
    this.hp = 100,
    this.maxHp = 100,
    this.ouro = 0,
    this.ataque = 5,
    this.salaAtual = 'praca',
    List<String>? inventario,
  }) : inventario = inventario ?? [];
}
```

Vamos decompor isso linha por linha.

`class Jogador {` declara o início da `class`. O nome `Jogador` segue a convenção Dart de PascalCase para classes (primeira letra de cada palavra em maiúscula).

Os campos (`nome`, `hp`, `maxHp`, etc.) são as propriedades do jogador, os dados que cada instância carrega consigo. São declarados com tipo e nome, como variáveis comuns.

`Jogador(this.nome, { ... })` é o construtor, a função especial que cria um novo objeto. O `this.nome` é um atalho de Dart que significa "o primeiro parâmetro se chama `nome` e vai direto para o campo `this.nome`". É equivalente a escrever:

```dart
Jogador(String nome) {
  this.nome = nome;
}
```

Os parâmetros entre `{ }` são parâmetros nomeados com valores padrão. Isso permite criar um jogador com apenas o nome, e tudo mais ganha valores automáticos:

```dart
var heroi = Jogador('Aldric');
// hp = 100, maxHp = 100, ouro = 0, ataque = 5, salaAtual = 'praca'

var veterano = Jogador('Kael', hp: 150, maxHp: 150, ouro: 50, ataque: 10);
// valores customizados
```

A parte `: inventario = inventario ?? []` é uma lista de inicialização, código que roda antes do corpo do construtor. Aqui garantimos que se ninguém passar um inventário, ele começa como lista vazia.

## Métodos: o que o jogador sabe fazer

Campos guardam dados. **Métodos** definem comportamentos, ações que o objeto pode executar (usando `void`, `bool`, etc.). Um método é uma função dentro da classe que pode acessar e modificar os campos do objeto. Para o Jogador, precisamos de métodos para sofrer dano, curar, gastar/receber ouro, pegar e largar itens. Cada método encapsula a lógica, garantindo que as regras do jogo sejam respeitadas.

```dart
class Jogador {
  String nome;
  int hp;
  int maxHp;
  int ouro;
  int ataque;
  String salaAtual;
  List<String> inventario;

  Jogador(this.nome, {
    this.hp = 100,
    this.maxHp = 100,
    this.ouro = 0,
    this.ataque = 5,
    this.salaAtual = 'praca',
    List<String>? inventario,
  }) : inventario = inventario ?? [];

  void sofrerDano(int quantidade) {
    hp -= quantidade;
    if (hp < 0) hp = 0;
  }

  void curar(int quantidade) {
    hp += quantidade;
    if (hp > maxHp) hp = maxHp;
  }

  bool gastarOuro(int quantidade) {
    if (ouro < quantidade) return false;
    ouro -= quantidade;
    return true;
  }

  void receberOuro(int quantidade) {
    ouro += quantidade;
  }

  bool get estaVivo => hp > 0;
  bool get inventarioCheio => inventario.length >= 10;

  bool pegarItem(String item) {
    if (inventarioCheio) return false;
    inventario.add(item);
    return true;
  }

  bool largarItem(String item) {
    return inventario.remove(item);
  }
}
```

Repare em vários padrões importantes aqui.

**Validação interna:** o método `sofrerDano` garante que HP nunca fica negativo. Antes, essa verificação teria que estar em cada lugar do código que modifica HP. Agora está num único lugar. Se amanhã a regra mudar (por exemplo, armadura reduz dano), você muda apenas aqui.

**Retorno booleano:** `gastarOuro` retorna `true` ou `false` indicando sucesso. Quem chama pode reagir:

```dart
if (heroi.gastarOuro(50)) {
  print('Compra realizada!');
} else {
  print('Ouro insuficiente.');
}
```

**Getters:** `estaVivo` e `inventarioCheio` usam a sintaxe `get`: são propriedades computadas que parecem campos mas na verdade calculam um valor (como `bool get`):

```dart
if (heroi.estaVivo) {
  print('Ainda de pé!');
}
```

A **arrow syntax** (`=>`) é um atalho para funções de uma linha. `bool get estaVivo => hp > 0;` é idêntico a usar `{ return ... }`:

```dart
bool get estaVivo {
  return hp > 0;
}
```

## A classe Sala

O mesmo princípio se aplica às salas. Uma sala tem dados (ID, nome, descrição, saídas, itens no chão) e comportamentos (verificar se tem uma saída em determinada direção, saber se há um inimigo, saber se contém itens). Ao encapsular essa lógica em métodos, reutilizamos código e mantemos as regras num único lugar.

Repare no uso de `final` nos campos. `id`, `nome`, `descricao` e `temLoja` são imutáveis: definidos na criação e nunca mudam. Isso faz sentido, uma sala não muda de nome no meio do jogo. Mas `itens` é uma lista `final` cujo conteúdo pode mudar (itens são pegos ou largados), e `saidas` pode ser modificado dinamicamente (uma porta secreta que se revela).

> **Nota sobre evolução do modelo:** No Capítulo 10, vamos expandir a classe `Sala` substituindo `inimigoId: String?` por `inimigoPresente: Inimigo?`, armazenando a instância do inimigo diretamente em vez de apenas um identificador de texto. Isso torna o modelo mais poderoso e tipado.

O parâmetro **required** obriga quem cria uma sala a fornecer `id`, `nome` e `descricao`. Sem eles, a sala não faz sentido. Você verá a implementação completa da classe `Sala` mais abaixo neste capítulo.

## Referências: mesmo objeto, vários nomes

Um conceito crucial em Dart (e em qualquer linguagem orientada a objetos): quando você passa um objeto para uma função, está passando uma referência, não uma cópia. Isso significa que qualquer modificação feita na função afeta o objeto original. É importante entender isso porque torna o código eficiente (nenhuma cópia desperdiçada) mas exige cuidado (qualquer função pode modificar o jogador).

```dart
void danificarJogador(Jogador p) {
  p.sofrerDano(10);
}

var heroi = Jogador('Aldric');
print(heroi.hp);
danificarJogador(heroi);
print(heroi.hp);
```

`p` e `heroi` apontam para o mesmo objeto na memória. Modificar um modifica o outro. Isso é poderoso (evita cópias desnecessárias) mas requer atenção: qualquer função que receba o jogador pode alterá-lo.

## Aplicação no jogo: refatorando com classes

Vamos refatorar o jogo do Capítulo 7 usando classes. Primeiro, criamos as classes num arquivo separado. A convenção em Dart é colocar cada classe no seu próprio arquivo em `lib/`. Essa separação torna o projeto escalável: adicionar um novo tipo de inimigo é adicionar um novo arquivo, não editar um megaarquivo. Por enquanto, mantemos tudo direto em `lib/`, sem subpastas. Mais adiante, quando o projeto crescer, vamos reorganizar em pastas por domínio.

Note que cada arquivo (como `lib/jogador.dart` e `lib/sala.dart`) pode ser importado noutros arquivos usando `import 'jogador.dart';` ou `import 'sala.dart';` quando estiverem na mesma pasta, ou com caminhos completos se em subpastas.

```dart
// lib/jogador.dart

class Jogador {
  String nome;
  int hp;
  int maxHp;
  int ouro;
  int ataque;
  String salaAtual;
  List<String> inventario;

  Jogador(this.nome, {
    this.hp = 100,
    this.maxHp = 100,
    this.ouro = 0,
    this.ataque = 5,
    this.salaAtual = 'praca',
    List<String>? inventario,
  }) : inventario = inventario ?? [];

  void sofrerDano(int quantidade) {
    hp -= quantidade;
    if (hp < 0) hp = 0;
  }

  void curar(int quantidade) {
    hp += quantidade;
    if (hp > maxHp) hp = maxHp;
  }

  bool gastarOuro(int quantidade) {
    if (ouro < quantidade) return false;
    ouro -= quantidade;
    return true;
  }

  void receberOuro(int quantidade) {
    ouro += quantidade;
  }

  bool get estaVivo => hp > 0;
  bool get inventarioCheio => inventario.length >= 10;

  bool pegarItem(String item) {
    if (inventarioCheio) return false;
    inventario.add(item);
    return true;
  }

  bool largarItem(String item) {
    return inventario.remove(item);
  }
}
```

```dart
// lib/sala.dart

class Sala {
  final String id;
  final String nome;
  final String descricao;
  final Map<String, String> saidas;
  final List<String> itens;
  final bool temLoja;
  final String? inimigoId;

  Sala({
    required this.id,
    required this.nome,
    required this.descricao,
    Map<String, String>? saidas,
    List<String>? itens,
    this.temLoja = false,
    this.inimigoId,
  }) : saidas = saidas ?? {},
       itens = itens ?? [];

  bool temSaida(String direcao) => saidas.containsKey(direcao);
  String? saidaPara(String direcao) => saidas[direcao];
  bool get temInimigo => inimigoId != null;
  bool get temItens => itens.isNotEmpty;
}
```

Agora o mundo do jogo usa objetos tipados em vez de `Map<String, dynamic>`:

```dart
// Antes (Capítulo 5-7): dados soltos em mapa genérico
var salas = <String, Map<String, dynamic>>{
  'praca': {
    'nome': 'Praça Central',
    'descricao': '...',
    'saidas': {'norte': 'corredor'},
    'itens': ['Tocha'],
  }
};

// Depois (Capítulo 8): objetos tipados
var salas = <String, Sala>{
  'praca': Sala(
    id: 'praca',
    nome: 'Praça Central',
    descricao: 'Uma fonte de pedra murmura ao centro...',
    saidas: {'norte': 'corredor', 'leste': 'taverna', 'sul': 'portao'},
    itens: ['Tocha', 'Chave Enferrujada'],
  )
};
```

A diferença é enorme. Com o mapa genérico, `sala['descricao']` podia ser qualquer coisa; o compilador não reclamava se você escrevesse `sala['desc']` por engano. Com a `class` `Sala`, `sala.descricao` é garantido como `String` pelo compilador. Erros de digitação viram erros de compilação, não bugs em tempo de execução.

E o jogador:

```dart
// Antes: variáveis soltas
var nomeJogador = 'Aventureiro';
var hp = 100;
var ouro = 0;

// Depois: um único objeto
var jogador = Jogador('Aventureiro');
```

No `loop` principal, em vez de `hp -= 10`, fazemos `jogador.sofrerDano(10)`. Em vez de verificar `hp > 0`, fazemos `jogador.estaVivo`. O código fica mais legível e as regras, centralizadas.

## O método toString

Todo objeto Dart pode ter um método `toString()` que define como ele é representado como texto. Isso é extraordinariamente útil para depuração: quando você imprime um objeto ou vê um erro, quer saber exatamente em que estado ele estava. Um bom `toString()` mostra os dados mais importantes num formato legível, sem ser tão longo a ponto de poluir o console.

```dart
class Jogador {
  // ... campos e métodos anteriores ...

  @override
  String toString() {
    return 'Jogador($nome, HP: $hp/$maxHp, Ouro: ${ouro}g, '
        'Sala: $salaAtual, Itens: ${inventario.length})';
  }
}
```

Agora `print(jogador)` mostra algo como:

```text
Jogador(Aldric, HP: 85/100, Ouro: 42g, Sala: corredor, Itens: 3)
```

O `@override` indica que estamos substituindo o `toString` padrão (que mostra apenas `Instance of 'Jogador'`). Vamos usar `@override` muito mais nos próximos capítulos com `extends` e herança.


***

## Desafios da Masmorra

**Desafio 8.1. Classe Item (Objeto com peso e descrição).** Crie uma classe `Item` com campos `nome`, `descricao` e `peso` (em gramas). Substitua as strings no inventário do jogador por objetos `Item`. Atualize `pegarItem` e `largarItem` para usar `Item` em vez de `String`. Implemente `toString()` para exibir o item de forma legível (exemplo: "Espada Curta (500g)").

**Desafio 8.2. Peso e limite de carga.** Adicione um campo `pesoMaximo` ao `Jogador` (padrão: 5000 gramas). O método `pegarItem` deve verificar se adicionar o novo item ultrapassaria o limite. Se ultrapassar, recuse com mensagem clara. Crie um getter `pesoAtual` que calcula o peso total do inventário em tempo real.

**Desafio 8.3. Método toString robusto para Sala.** Implemente `toString()` em `Sala` que mostra: nome, saídas disponíveis e quantidade de itens. Para debug, ao mudar de sala, imprima `print(novaSala)` para validar que o estado está correto. Formato exemplo: `"Sala(Praça Central, saídas: [n, l, s], itens: 2)"`.

**Desafio 8.4. Método descrever para renderização.** Adicione um método `String descrever()` em `Sala` que retorna uma descrição completa e formatada (usando `StringBuffer`): nome com moldura, descrição longa, saídas listadas, itens no chão com seus pesos. Substitua a função `exibirSala()` do Capítulo 7 por uma chamada a `sala.descrever()`.

**Boss Final 8.5. Classe MundoTexto (Gerenciador de mundo).** Crie uma classe `MundoTexto` que encapsula o `Map<String, Sala>` e fornece métodos: `Sala? obterSala(String id)`, `void adicionarSala(Sala sala)`, `List<String> salasConectadas(String id)` que retorna as salas alcançáveis. Substitua o mapa global `mundoSalas` por uma instância `var mundo = MundoTexto();` e use-a para todas as operações do jogo.

## Pergaminho do Capítulo

Neste capítulo você aprendeu a criar classes com campos e métodos, construtores com parâmetros posicionais e nomeados, valores padrão e `required`, getters computados, que objetos são passados por referência, e o método `toString()` para representação textual.

O jogo deu um salto de organização: de variáveis soltas e mapas genéricos para objetos tipados com validação interna. No Capítulo 9, vamos refinar essas classes com encapsulamento (campos privados com `_`), construtores nomeados e factory constructors, as ferramentas que transformam uma classe básica numa API bem desenhada.

::: dica
**Dica do Mestre:** Quando não souber se algo deveria ser um campo ou um getter, use esta regra: se o valor é armazenado e pode ser diferente entre instâncias, é um campo. Se o valor é calculado a partir de outros campos, é um getter. `nome` é campo. `estaVivo` é getter (calculado a partir de `hp`). Essa distinção mantém o modelo limpo e evita dados duplicados que ficam inconsistentes.
:::
