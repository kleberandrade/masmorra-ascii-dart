# Apêndice F - Records e Extensions: recursos Dart 3 que merecem mais atenção

> *Um bom tesouro raramente aparece na primeira sala. Dois recursos do Dart 3 ficaram discretos ao longo do livro, usados en passant quando conveniente, mas jamais apresentados com o respeito que merecem. Este apêndice corrige isso.*

Ao longo dos 37 capítulos, usamos dezenas de construções do Dart 3 — sealed classes, pattern matching, enhanced enums, null safety. Dois recursos apareceram de raspão, sempre que um atalho elegante se tornava útil, mas nunca ganharam um capítulo próprio: **Records** e **Extensions**. Este apêndice os apresenta com calma. Depois de ler, você provavelmente vai querer voltar ao próprio código e refatorar vários lugares.

## F.1 Records: tuplas com nome e tipo

Um **record** é uma forma leve de agrupar valores sem precisar criar uma classe. Pense nele como uma tupla tipada: você junta algumas variáveis numa estrutura, cada uma com seu tipo, e passa adiante.

```dart
// Record anônimo: dois campos posicionais
(int, String) parUsuario = (42, 'Kleber');
print(parUsuario.$1); // 42
print(parUsuario.$2); // Kleber

// Record nomeado: campos com rótulos
({int id, String nome}) usuario = (id: 42, nome: 'Kleber');
print(usuario.id);   // 42
print(usuario.nome); // Kleber
```

### Quando usar records em vez de classes

Records brilham quando você precisa retornar múltiplos valores de uma função e criar uma classe seria excessivo. No contexto da masmorra:

```dart
// Antes: retornar dois valores exigia uma classe auxiliar ou lista não-tipada
(int dano, bool critico) calcularAtaque(int forca, int destreza) {
  final dano = forca + 3;
  final critico = destreza > 15;
  return (dano, critico);
}

void main() {
  final (dano, critico) = calcularAtaque(10, 18);
  print('Dano: $dano (crítico? $critico)');
}
```

Repare: o destructuring `final (dano, critico) = ...` vem de graça. Não precisa acessar `.$1` e `.$2`.

### Records com nomes

Para APIs mais legíveis, prefira nomes:

```dart
({int hp, int maxHp, int ouro}) lerEstado(Jogador j) {
  return (hp: j.hp, maxHp: j.maxHp, ouro: j.ouro);
}

final estado = lerEstado(meuJogador);
print('HP: ${estado.hp}/${estado.maxHp} - Ouro: ${estado.ouro}');
```

### Records em pattern matching

Eles combinam naturalmente com `switch`:

```dart
String descreverAtaque((int, bool) resultado) {
  return switch (resultado) {
    (0, _) => 'Errou!',
    (final d, true) => 'CRÍTICO! Dano: $d',
    (final d, false) => 'Acerto normal. Dano: $d',
  };
}
```

### Quando NÃO usar records

Records são imutáveis e não têm métodos próprios. Se o conjunto de dados tem comportamento (métodos), identidade (mais do que um par de valores iguais) ou vai crescer com o tempo, use uma classe. Regra prática: record para *dados de passagem*, classe para *entidades*.

## F.2 Extensions: adicionando métodos a tipos existentes

Uma **extension** permite acrescentar métodos a tipos que você não pode (ou não quer) modificar — tipos da biblioteca padrão, pacotes de terceiros, ou até suas próprias classes que você prefere não inchar.

```dart
extension StringMasmorra on String {
  String get emCaixa => '[ $this ]';
  String repetirTres() => '$this$this$this';
  bool get pareceComando => startsWith('/') && length > 1;
}

void main() {
  print('entrar'.emCaixa);      // [ entrar ]
  print('.'.repetirTres());     // ...
  print('/norte'.pareceComando); // true
}
```

### Extensions no contexto da masmorra

Suponha que você queira formatar qualquer `int` como barra de HP visual:

```dart
extension BarraVida on int {
  String barra(int maximo, {int largura = 10}) {
    final preenchido = (this / maximo * largura).round();
    return '[${'█' * preenchido}${'░' * (largura - preenchido)}]';
  }
}

void main() {
  print(7.barra(10));  // [███████░░░]
  print(3.barra(10));  // [███░░░░░░░]
}
```

Ou data/hora amigável para logs de combate:

```dart
extension DataLog on DateTime {
  String get hhmm {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

void main() {
  print('[${DateTime.now().hhmm}] Ataque iniciado.');
}
```

### Extensions com genéricos

Você pode estender tipos genéricos:

```dart
extension ListaMasmorra<T> on List<T> {
  T? aleatorio(Random rng) => isEmpty ? null : this[rng.nextInt(length)];
  T? get primeiroOuNulo => isEmpty ? null : first;
}
```

### Cuidados com extensions

- Extensions **não podem** ser chamadas dinamicamente: o Dart precisa conhecer o tipo estático em tempo de compilação.
- Evite criar extensions muito genéricas com nomes curtos (ex: `.x` em `String`) — o código fica enigmático.
- Se várias extensions definem o mesmo método para o mesmo tipo, o Dart pede desambiguação.

## F.3 Combinando records e extensions

Os dois recursos se complementam. Você pode ter uma função que retorna record, e extensions que formatam esse record:

```dart
typedef Resultado = ({int dano, bool critico, bool esquivou});

Resultado atacar(int forca, Random rng) {
  if (rng.nextDouble() < 0.1) return (dano: 0, critico: false, esquivou: true);
  final crit = rng.nextDouble() < 0.15;
  final dano = forca * (crit ? 2 : 1);
  return (dano: dano, critico: crit, esquivou: false);
}

extension FormatarResultado on Resultado {
  String descrever() {
    if (esquivou) return 'Esquiva!';
    if (critico) return 'CRÍTICO! ($dano de dano)';
    return 'Acerto: $dano de dano';
  }
}

void main() {
  final r = atacar(10, Random());
  print(r.descrever());
}
```

Repare que `typedef Resultado` dá um nome amigável ao record para usar em assinaturas.

## F.4 Quando voltar e refatorar

Após ler este apêndice, você provavelmente vai enxergar pelo menos três lugares no seu código que poderiam ser mais claros com records (funções que retornam `Map<String, dynamic>` ou listas) ou extensions (helpers espalhados em funções top-level). Faça isso aos poucos: refatorações pequenas, uma de cada vez, com os testes do capítulo 32 te protegendo.

E, quando tiver tempo, releia a documentação oficial em https://dart.dev/language/records e https://dart.dev/language/extension-methods. Há mais detalhes sobre igualdade de records, cópias imutáveis e extensions estáticas que valem a leitura.
