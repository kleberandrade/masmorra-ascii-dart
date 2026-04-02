# Capítulo 4 - Null safety, o escudo contra crashes

> *O aventureiro abre um baú. Dentro, encontra... nada. Não uma espada, não uma poção, não um mapa, literalmente nada. Em muitas linguagens, tentar usar esse nada causaria um crash. Em Dart, o compilador já teria avisado: "esse baú pode estar vazio. Trate isso antes de enfiar a mão."*

Se você veio de linguagens como JavaScript, Python ou Java, provavelmente já encontrou a infame null pointer exception, um erro que acontece quando o código tenta usar um valor que não existe. É o bug mais comum do mundo, responsável por bilhões de dólares em prejuízo.

Dart resolveu esse problema de forma elegante com o **null safety**: o sistema de tipos distingue entre valores que sempre existem e valores que podem ser nulos. O compilador força você a tratar a possibilidade de nulo antes de o programa rodar. Este capítulo explica como isso funciona e por que vai salvar seu jogo de crashes misteriosos.

## Tipos normais vs tipos **nullable**

Em Dart, por padrão, uma variável não pode ser nula:

```dart
String nome = 'Aldric';
String nome2 = null;       // ERRO de compilação!
```

Se você quiser que uma variável possa conter `null`, precisa declarar isso explicitamente com `?` no tipo:

```dart
String? nome = null;
String? nome2 = 'Aldric';
```

Pense assim: `String` é um contrato que diz "aqui sempre haverá texto". `String?` diz "aqui pode haver texto ou pode não haver nada". O ponto de interrogação é o sinal visual de "cuidado, pode estar vazio".

Essa distinção existe para todos os tipos:

```dart
int vida = 100;
int? dano = null;

bool vivo = true;
bool? fugiu = null;

List<String> itens = [];
List<String>? inventario = null;
```

## Por que readLineSync retorna String?

Agora faz sentido por que usamos `??` desde o Capítulo 2:

```dart
var nome = stdin.readLineSync() ?? 'Aventureiro';
```

A função `stdin.readLineSync()` retorna `String?` porque existem situações em que ela genuinamente não consegue ler nada, por exemplo, se o programa receber input redirecionado de um arquivo que acabou. Nesses casos, retornar `null` é mais honesto que retornar uma string vazia.

Da mesma forma, `int.tryParse()` retorna `null` porque uma entrada como `"abc"` não é um número. Retornar `null` é mais informativo que retornar `0` ou lançar uma exceção.


## Os quatro operadores de null safety

Dart oferece quatro operadores para trabalhar com valores nullable. Cada um resolve um problema diferente: acessar propriedades com segurança, fornecer valores padrão, atribuir sob condição, ou garantir explicitamente que algo não é nulo. Você vai usar esses operadores o tempo todo daqui para frente.

### 1. O operador ?., acesso condicional

O `?.` chama um método ou acessa uma propriedade somente se o valor não for null. Se for null, o resultado inteiro é null. Pense nele como uma forma de dizer "se isso existir, me dá aquilo; se não existir, me dá null em vez de crashar":

```dart
String? texto = obterTexto();
var tamanho = texto?.length;
```

Se `texto` for `'Masmorra'`, `tamanho` será `8`. Se `texto` for `null`, `tamanho` será `null`, sem crash.

Você pode encadear vários operadores `?.`:

```dart
String? descricao = sala?.inimigo?.nome;
```

Se `sala` for null ou `inimigo` for null, o resultado também é null.

### 2. O operador ??, valor padrão

O `??` fornece um valor substituto quando algo é null. É um operador muito prático: se você tem um valor que pode ser null mas precisa de uma alternativa garantida, o `??` resolve de forma elegante:

```dart
var nome = entrada ?? 'Aventureiro';
```

Se `entrada` não for null, `nome` recebe `entrada`. Se for null, recebe `'Aventureiro'`.

O operador `??` pode ser encadeado:

```dart
var local = salaAtual ?? salaAnterior ?? 'Praça Central';
```

### 3. O operador ??=, atribuição se nulo

O `??=` é um atalho que combina verificação e atribuição: atribui um valor somente se a variável for null, fazendo tudo em uma linha. Você vai vê-lo muito em inicializações defaults:

```dart
String? apelido;
apelido ??= 'Herói Sem Nome';
apelido ??= 'Outro Nome';
print(apelido);
```

A primeira atribuição funciona porque `apelido` é `null`. A segunda não atribui porque já tem valor.

### 4. O operador !, asserção de não-nulo

O `!` é o operador mais perigoso dos quatro. Ele diz ao compilador: "eu tenho certeza de que isso não é null neste momento, confie em mim". Se você estiver errado, o programa crasha. Use com extrema cautela:

```dart
String? texto = obterTexto();
var tamanho = texto!.length;
```

Se `texto` for null, o programa lança uma exceção em tempo de execução. Use `!` com extrema cautela, ele desativa exatamente a proteção que null safety oferece. Neste livro, evitaremos `!` sempre que possível.

## Promoção de tipo (type promotion)

Uma das funcionalidades mais inteligentes do Dart é a promoção de tipo. Quando você faz uma verificação de null, o Dart automaticamente promove o tipo dentro desse bloco:

```dart
String? entrada = stdin.readLineSync();

if (entrada != null) {
  var tamanho = entrada.length;
  print('Você digitou: ${entrada.trim()}');
}
```

Fora do `if`, `entrada` continua sendo `String?`. Mas dentro do bloco onde verificamos `!= null`, Dart promove para `String`, e todos os métodos ficam disponíveis sem operadores especiais.

A promoção funciona com vários tipos de verificação:

```dart
void processar(String? entrada) {
  if (entrada == null) {
    print('Nada digitado.');
    return;
  }
  print('Você disse: ${entrada.toUpperCase()}');
}

void mostrar(Object? valor) {
  if (valor is String) {
    print('Texto com ${valor.length} caracteres');
  } else if (valor is int) {
    print('Número: ${valor * 2}');
  }
}
```

## Aplicação no jogo, input robusto

Vamos criar funções de leitura de input que tratam todos os casos de forma limpa:

```dart
import 'dart:io';

/// Lê uma linha do terminal, limpa espaços e converte para minúsculas.
String lerComando() {
  stdout.write('> ');
  var entrada = stdin.readLineSync();

  if (entrada == null) {
    return 'sair';
  }

  return entrada.trim().toLowerCase();
}

/// Tenta interpretar o input como número do menu.
int? interpretarComoNumero(String input) {
  if (input.isEmpty) return null;
  return int.tryParse(input);
}

/// Converte uma palavra em número de menu, se for sinônimo conhecido.
int? interpretarComoPalavra(String input) {
  return switch (input) {
    'explorar' || 'jogar' || 'entrar' => 1,
    'status' || 'heroi' => 2,
    'ajuda' || 'help' => 3,
    'sair' || 'quit' || 'fim' => 0,
    _ => null,
  };
}

/// Interpreta o input do jogador como opção de menu.
int? interpretarInput(String input) {
  return interpretarComoNumero(input) ?? interpretarComoPalavra(input);
}
```

Repare como o `null` flui naturalmente pelo código. A função `interpretarComoNumero()` retorna `null` se não for número. A função `interpretarComoPalavra()` retorna `null` se não for palavra conhecida. O operador `??` encadeia as duas tentativas.

```dart
void main() {
  while (true) {
    var cmd = lerComando();

    if (cmd.isEmpty) {
      print('Digite algo.');
      continue;
    }

    var opcao = interpretarInput(cmd);

    if (opcao == null) {
      print('Não entendi "$cmd".');
      continue;
    }

    switch (opcao) {
      case 1:
        print('Explorando...');
      case 2:
        print('Status...');
      case 3:
        print('Ajuda...');
      case 0:
        print('Até logo!');
        return;
      default:
        print('Opção inválida.');
    }
  }
}
```

Esse código nunca crasha por causa de `null`. Toda possibilidade de valor ausente é tratada explicitamente. Esse é o poder do null safety.

## Padrão, leitura segura com validação

Aqui está um padrão que vamos reutilizar ao longo de todo o livro:

```dart
/// Pede um número ao jogador dentro de um intervalo.
int pedirOpcao(String prompt, int min, int max) {
  while (true) {
    stdout.write(prompt);
    var linha = stdin.readLineSync()?.trim() ?? '';

    if (linha.isEmpty) {
      print('Digite um número entre $min e $max.');
      continue;
    }

    var numero = int.tryParse(linha);
    if (numero == null) {
      print('"$linha" não é um número.');
      continue;
    }

    if (numero < min || numero > max) {
      print('Escolha entre $min e $max.');
      continue;
    }

    return numero;
  }
}
```

Essa função é um mini-loop que só sai quando recebe um número válido dentro do intervalo. Cada tipo de erro tem sua própria mensagem.

Exemplo de uso:

```dart
var opcao = pedirOpcao('Escolha (0-3): ', 0, 3);
```

O resultado é um `int` garantido entre 0 e 3, sem null, sem surpresas.

## O tipo late, inicialização tardia

Há situações em que você sabe que uma variável vai ser inicializada antes de ser usada, mas não consegue dar um valor no momento da declaração:

```dart
late String nomeDoJogador;

void inicializarJogo() {
  nomeDoJogador = pedirNome();
}

void mostrarHUD() {
  print('Jogador: $nomeDoJogador');
}
```

O **late** diz ao Dart: essa variável será inicializada antes de ser acessada, confie em mim. Use `late` quando a inicialização depende de algo que acontece depois da declaração.

***

## Desafios da Masmorra

**Desafio 4.1. Validação de nome robusto.** Reescreva `pedirNome()` para recusar nomes com menos de 2 caracteres ou mais de 20. Se inválido, mostre exatamente o motivo ("Muito curto", "Muito longo") e peda novamente em vez de usar um padrão. Use promoção de tipo dentro de um `if (entrada != null)` para garantir segurança.

**Desafio 4.2. Menu com confirmação bilateral.** Crie uma função `confirmar(String mensagem) -> bool` que mostra a mensagem, aceita s/sim/y/yes para verdadeiro e n/não/no para falso. Se o jogador digitar algo inválido, repita a pergunta. Use `??` para proteger `readLineSync()`.

**Desafio 4.3. Interpretação de comandos em três níveis.** Implemente um parser que reconheça três formas do mesmo comando: numeração (1), palavra completa (explorar) e abreviação (e). Use `int.tryParse()` para tentar número primeiro, depois `??` para tentar palavra, depois `??` para tentar abreviação. Demonstre com explorar/e/1.

**Desafio 4.4. Função parametrizada pedirTexto.** Escreva `String pedirTexto(String prompt, {int minLength = 1, int maxLength = 50})` com parâmetros nomeados e valores padrão. A função repete até receber um texto com tamanho válido. Use `texto.length` e lance exceção (ou retorne padrão) se sair do intervalo.

**Boss Final 4.5. Cadeia de null safety (Sala inicial).** Crie um mapa representando três salas: `salaPraca`, `salaCorredo`, `salaTesouraria`, cada uma como `String?`. Algumas salas podem ser `null` (não existem). Implemente um getter `salaAtual() -> String` que usa encadeamento `??` para sempre garantir que o jogador está em uma sala válida, caindo para "Praça Central" se tudo mais for nulo. Demonstre que o encadeamento funciona mesmo com múltiplos níveis de null.

## Pergaminho do Capítulo

Neste capítulo você aprendeu o que é null safety e por que Dart o implementa, a diferença entre `String` e `String?`, os quatro operadores de null: `?.`, `??`, `??=` e `!`, promoção de tipo em blocos `if`, `late` para inicialização tardia, e padrões reutilizáveis de validação de input.

O código do jogo agora é robusto contra qualquer input do jogador. Nenhuma combinação de Enter vazio, texto aleatório ou números fora do intervalo causa crash. No Capítulo 5, vamos dar memória real ao jogo com coleções: listas para o inventário, mapas para as salas, e conjuntos para itens únicos.

::: dica
**Dica do Mestre:** Em Dart, prefira `??` e promoção de tipo ao operador `!`. O `!` é a última opção, não a primeira. Sempre que você escreve `!`, está dizendo se eu estiver errado, o programa pode crashar. Com `??`, você está dizendo se estiver vazio, use isso, o programa nunca crasha. Código de jogo que não crasha é código de jogo que os jogadores respeitam.
:::
