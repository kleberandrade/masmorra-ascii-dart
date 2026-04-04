# Capítulo 9 - Construtores e encapsulamento

> *O ferreiro não deixa qualquer um enfiar a mão na forja. Há uma porta para pedidos e uma janela para entregas. O que acontece lá dentro (o martelar, o temperar, o polir) é problema dele. Em código, chamamos isso de encapsulamento.*

Trataremos de **construtores** e **encapsulamento**: no capítulo anterior, criamos classes com campos públicos. Qualquer parte do código pode ler e modificar `jogador.hp` diretamente. Isso funciona, mas à medida que o jogo cresce, o acesso irrestrito vira fonte de bugs; alguém pode setar `hp = -50` sem querer, ou mudar `salaAtual` para uma sala que não existe. Neste capítulo, vamos aprender a proteger o estado interno das classes e a criar múltiplas formas de construir objetos.

## O sublinhado `_`: privacidade em Dart

Em Dart, a privacidade funciona no nível da biblioteca (ou seja, do arquivo). Qualquer identificador que comece com `_` é invisível fora daquele arquivo. Isso permite que você mantenha detalhes internos da classe privados, forçando o código externo a usar a API pública (getters e métodos) que você expôs. Use `_nomeVariavel` para campos privados e crie getters públicos apenas para o que realmente precisa ser lido de fora.

```dart
// lib/jogador.dart

class Jogador {
  final String nome;
  int _hp;
  int _maxHp;
  int _ouro;
  int _ataque;
  String _salaAtual;
  final List<String> _inventario;

  Jogador(this.nome, {
    int hp = 100,
    int maxHp = 100,
    int ouro = 0,
    int ataque = 5,
    String salaAtual = 'praca',
    List<String>? inventario,
  }) : _hp = hp,
       _maxHp = maxHp,
       _ouro = ouro,
       _ataque = ataque,
       _salaAtual = salaAtual,
       _inventario = inventario ?? [];

  int get hp => _hp;
  int get maxHp => _maxHp;
  int get ouro => _ouro;
  int get ataque => _ataque;
  String get salaAtual => _salaAtual;
  List<String> get inventario => List.unmodifiable(_inventario);
}
```

Agora, de fora do arquivo, `jogador._hp` causa erro de compilação. O único jeito de mudar o HP é através dos métodos que a `class` oferece (como `sofrerDano()` e `curar()`):

```dart
  void sofrerDano(int quantidade) {
    if (quantidade < 0) return;
    _hp -= quantidade;
    if (_hp < 0) _hp = 0;
  }

  void curar(int quantidade) {
    if (quantidade < 0) return;
    _hp += quantidade;
    if (_hp > _maxHp) _hp = _maxHp;
  }
```

Repare que agora temos validação dupla: dano negativo é ignorado e HP nunca fica abaixo de zero. Essas garantias são impossíveis com campos públicos, porque qualquer trecho de código pode escrever `jogador.hp = -999`.

O getter `inventario` retorna `List.unmodifiable(_inventario)`, uma visão da lista que não permite `.add()` ou `.remove()` de fora. Quem quiser modificar o inventário precisa usar os métodos da classe:

```dart
  bool pegarItem(String item) {
    if (_inventario.length >= 10) return false;
    _inventario.add(item);
    return true;
  }

  bool largarItem(String item) {
    return _inventario.remove(item);
  }

  bool temItem(String item) {
    return _inventario.any(
      (i) => i.toLowerCase() == item.toLowerCase()
    );
  }
```

## O campo `final`: imutável após construção

O `nome` do jogador é `final`: definido no construtor e nunca mais alterado. Isso faz sentido, o aventureiro não muda de nome no meio da partida. Marcar um campo como `final` diz ao compilador (e aos futuros leitores do código) que esse valor é um atributo permanente do objeto. Use `final` para campos imutáveis, tanto por clareza quanto por segurança:

```dart
final String nome;
```

Já `_hp` é mutável (sem `final`) porque o HP muda durante o jogo. A regra prática: se um campo não deve mudar após a criação do objeto, marque como `final`.

Para a `class` `Sala`, quase tudo é `final`:

```dart
class Sala {
  final String id;
  final String nome;
  final String descricao;
  final Map<String, String> saidas;
  final List<String> itens;
  final bool temLoja;
  final String? inimigoId;
}
```

Uma distinção sutil: `final List<String> itens` significa que a variável `itens` sempre aponta para a mesma lista, mas o conteúdo da lista pode mudar (itens adicionados ou removidos). Se quiséssemos impedir até isso, usaríamos uma lista imutável usando `const` ou `List.unmodifiable()` no construtor de forma mais robusta.

## Construtores nomeados

Dart permite ter múltiplos construtores com nomes diferentes. Enquanto o construtor principal faz inicialização genérica, construtores nomeados podem oferecer formas especializadas de criar objetos. No jogo, queremos criar um recruta fraco para modo fácil, um veterano forte para modo difícil ou carregar um jogador salvo de um arquivo. Cada situação é um construtor nomeado, tornando o código que cria o jogador legível e expressivo.

```dart
class Jogador {
  // Construtor principal
  Jogador(this.nome, { /* ... */ });

  // Construtor nomeado: novo recruta com stats fracos
  Jogador.recruta(String nome)
      : this(nome, hp: 80, maxHp: 80, ouro: 10, ataque: 3);

  // Construtor nomeado: veterano com stats fortes
  Jogador.veterano(String nome)
      : this(nome, hp: 150, maxHp: 150, ouro: 100, ataque: 12);

  // Construtor nomeado: carregar de um mapa (para save/load)
  Jogador.deArquivo(Map<String, dynamic> dados)
      : this(
          dados['nome'] as String,
          hp: (dados['hp'] as int?) ?? 100,
          maxHp: (dados['maxHp'] as int?) ?? 100,
          ouro: (dados['ouro'] as int?) ?? 0,
          ataque: (dados['ataque'] as int?) ?? 5,
          salaAtual: (dados['salaAtual'] as String?) ?? 'praca',
          inventario: List<String>.from(
            dados['inventario'] as List? ?? [],
          ),
        );
}
```

Uso:

```dart
var noob = Jogador.recruta('Timmy');
var lenda = Jogador.veterano('Kael');

// Carregar do arquivo com tratamento de erro
Jogador? salvo;
try {
  salvo = Jogador.deArquivo(dadosSalvos);
} catch (e) {
  print('Erro ao carregar jogador: $e');
  salvo = null;
}
```

O construtor `Jogador.deArquivo` é uma prévia do sistema de save/load que construiremos mais adiante. A ideia é simples: salvar o jogador como um mapa JSON e reconstruí-lo de volta.

## **Factory constructors**

Um **factory constructor** é um construtor que tem poderes especiais: pode retornar uma instância já existente (útil para cache), pode fazer lógica complexa antes de criar o objeto e pode retornar uma subclasse em vez do tipo original. Diferente de um construtor normal, um factory não tem acesso a `this` porque pode não estar criando um novo objeto. No nosso jogo, usaremos factory constructors para construir inimigos a partir de dados, aplicando regras e validações antes de criar a instância final.

```dart
class Sala {
  static final Map<String, Sala> _cache = {};

  factory Sala.cacheado({
    required String id,
    required String nome,
    required String descricao,
    Map<String, String>? saidas,
    List<String>? itens,
    bool temLoja = false,
    String? inimigoId,
  }) {
    return _cache.putIfAbsent(id, () => Sala(
      id: id,
      nome: nome,
      descricao: descricao,
      saidas: saidas,
      itens: itens,
      temLoja: temLoja,
      inimigoId: inimigoId,
    ));
  }
}
```

O `factory` é diferente de um construtor normal porque pode retornar um objeto já existente (do cache), pode retornar uma instância de uma subclasse e não tem acesso a `this` no corpo.

No nosso jogo, factory constructors serão muito úteis quando criarmos inimigos a partir de dados (JSON/tabelas).

## O método paraMap: preparando para persistência

O inverso de `deArquivo` é `paraMap()`, que converte o objeto para um mapa que pode ser salvo como JSON ou convertido em string. Esse par de métodos é fundamental para save/load: você salva o objeto convertendo-o para um mapa (facilmente serializado em JSON) e o carrega criando um novo objeto a partir de um mapa.

```dart
class Jogador {
  Map<String, dynamic> paraMap() {
    return {
      'nome': nome,
      'hp': _hp,
      'maxHp': _maxHp,
      'ouro': _ouro,
      'ataque': _ataque,
      'salaAtual': _salaAtual,
      'inventario': List<String>.from(_inventario),
    };
  }

  @override
  String toString() {
    return 'Jogador($nome, HP: $_hp/$_maxHp, '
        'Ouro: ${_ouro}g, Sala: $_salaAtual)';
  }
}
```

O par `paraMap()`/`deArquivo()` é um padrão essencial em Dart, é assim que objetos viajam para JSON e voltam. Vamos usá-lo extensivamente mais adiante.

## Movimentação encapsulada

Agora que temos campos privados, podemos adicionar métodos que modificam o estado interno de forma controlada. O método `moverPara()` permite que o jogador se mova, mas apenas atualizando a sala interna. Ninguém de fora pode setar `_salaAtual = 'invalida'`: podem apenas chamar `moverPara()` e confiar que a lógica interna está correta.

```dart
  void moverPara(String novaSalaId) {
    _salaAtual = novaSalaId;
  }
```

E no jogo, o código de navegação fica mais limpo:

```dart
// Antes (Capítulo 7):
if (saidas.containsKey(direcao)) {
  salaAtual = saidas[direcao]!;
}

// Depois (Capítulo 9):
var destino = sala.saidaPara(direcao);
if (destino != null) {
  jogador.moverPara(destino);
}
```

Cada objeto cuida do que é seu. A sala sabe quais saídas tem (via `saidaPara()`). O jogador sabe como mudar de sala (via `moverPara()`). Ninguém acessa campos internos diretamente.

***

## Desafios da Masmorra

**Desafio 9.1. Sala com API protegida.** Torne os campos de `Sala` que são listas (`itens`) verdadeiramente protegidos com `_`: `_itens`. Adicione métodos públicos `adicionarItem(String)` e `removerItem(String)` em vez de expor a lista diretamente. Crie um getter `List<String> get itens => List.unmodifiable(_itens)` para leitura segura.

**Desafio 9.2. Construtores nomeados de dificuldade.** Crie `Jogador.facil(nome)`, `Jogador.normal(nome)` e `Jogador.dificil(nome)` com stats progressivamente mais altos (HP: 50/100/150, ataque: 3/5/10, ouro inicial: 0/50/200). Teste cada um imprimindo `toString()` e verificando se os stats fazem sentido.

**Desafio 9.3. Validação de movimentação.** Refatore o método `moverPara(String novaSalaId)` para aceitar também o `MundoTexto` (ou `Map<String, Sala>`) do jogo. Valide se a sala destino realmente existe antes de permitir o movimento. Se não existir, lance uma `Exception` ou retorne `bool false`.

**Desafio 9.4. Construtor deArquivo resiliente (Carregamento seguro).** Aperfeiçoe o construtor `Jogador.deArquivo(Map<String, dynamic> dados)` com tratamento de erros: se uma chave estiver faltando ou for do tipo errado, use valores padrão em vez de crashar. Use casting seguro: `(dados['hp'] as int?) ?? 100`.

**Boss Final 9.5. Padrão Copy-With (Imutabilidade).** Crie ou refatore `Sala` para ser completamente imutável com `final` em todos os campos. Implemente um método `Sala copyWith({List<String>? itens, bool? temLoja})` que retorna uma nova `Sala` com as mudanças aplicadas. Demonstre com uma sequência: sala1 → adiciona item (cria sala2) → remove item (cria sala3).

## Pergaminho do Capítulo

Neste capítulo você aprendeu privacidade com `_` (no nível do arquivo), getters como interface pública controlada, `final` para campos imutáveis, construtores nomeados para múltiplas formas de criação, factory constructors para lógica antes da instanciação e o par `paraMap`/`deArquivo` para serialização.

O modelo do jogo agora é robusto: campos protegidos, validação interna, e uma API clara. No Capítulo 10, vamos usar herança para criar uma família de inimigos, `Zumbi`, `Esqueleto`, `Lobo`, cada um com stats e comportamentos diferentes, todos compartilhando uma base comum `Inimigo`.

::: dica
**Dica do Mestre:** Em Dart, a regra é: torne privado por padrão, exponha por necessidade. Se um campo não precisa ser lido de fora, não crie getter. Se precisa ser lido mas não escrito, crie getter sem setter. Só exponha o mínimo necessário. Quanto menos superfície de API, menos formas o código externo tem de criar bugs no seu objeto.
:::

## Próximo Capítulo

No próximo capítulo, a masmorra ganha inimigos variados. Herança permite criar zumbis, esqueletos e goblins a partir de uma base comum.
