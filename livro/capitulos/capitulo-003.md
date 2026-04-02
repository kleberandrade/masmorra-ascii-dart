# Capítulo 3 - Decisões e repetições

> *O menu da taverna está pregado na parede com uma adaga. "1, Cerveja. 2, Hidromel. 0, Sair." O aventureiro escolhe. O taberneiro reage. E o menu continua ali, esperando a próxima escolha.*

Até agora o programa aceita um comando e morre. Isso não é um jogo, é uma máquina de venda automática com uma única moeda. Um jogo de verdade precisa de duas coisas: decisões (reagir de forma diferente a cada input) e repetição (continuar rodando até o jogador decidir parar). Neste capítulo vamos construir as duas, e o resultado será o primeiro loop interativo com **turnos** do nosso roguelike.

## Decisões com **if**, `else if`, `else`

Você já viu um `if` rápido no capítulo anterior. Agora vamos entendê-lo por completo.

A estrutura básica é:

```dart
if (condicao) {
  // código executado se a condição for verdadeira
}
```

A condição é uma expressão que resulta em `bool`, `true` ou `false`. Se for `true`, o bloco entre chaves executa. Se for `false`, o programa pula para o próximo bloco.

Para múltiplas alternativas, usamos `else if` e `else`:

```dart
var opcao = 1;

if (opcao == 1) {
  print('Você escolheu explorar.');
} else if (opcao == 2) {
  print('Você escolheu o inventário.');
} else if (opcao == 0) {
  print('Até a próxima!');
} else {
  print('Opção inválida.');
}
```

O Dart avalia as condições de cima para baixo e executa apenas o primeiro bloco cuja condição for verdadeira. O `else` final é a rede de segurança, pega tudo que não combinou com nenhuma condição anterior.

**Operadores de comparação:**

```dart
a == b    // igual a
a != b    // diferente de
a > b     // maior que
a < b     // menor que
a >= b    // maior ou igual
a <= b    // menor ou igual
```

**Operadores lógicos** para combinar condições:

```dart
a && b    // E lógico, ambos precisam ser true
a || b    // OU lógico, pelo menos um precisa ser true
!a        // NÃO, inverte o valor
```

Um exemplo prático para o jogo, aceitar sinônimos de comandos:

```dart
var cmd = 'n';

if (cmd == 'norte' || cmd == 'n') {
  print('Você vai para o norte.');
} else if (cmd == 'sul' || cmd == 's') {
  print('Você vai para o sul.');
}
```

## O **switch**, alternativa elegante para múltiplas opções

Quando você está comparando uma variável com vários valores fixos, o `switch` pode ser mais claro que uma cadeia de `if`/`else if`:

```dart
var opcao = 2;

switch (opcao) {
  case 1:
    print('Explorar a masmorra.');
  case 2:
    print('Ver inventário.');
  case 0:
    print('Sair do jogo.');
  default:
    print('Opção inválida.');
}
```

No Dart 3, o `switch` não precisa de `break`. Cada `case` termina automaticamente. O `default` funciona como o `else`: captura qualquer valor não listado.

O `switch` também funciona com strings, o que será útil quando construirmos o parser de comandos:

```dart
var comando = 'norte';

switch (comando) {
  case 'norte' || 'n':
    print('Indo para o norte...');
  case 'sul' || 's':
    print('Indo para o sul...');
  case 'sair':
    print('Até logo!');
  default:
    print('Comando desconhecido: $comando');
}
```

Repare na sintaxe `case 'norte' || 'n':`. Isso é um pattern do Dart 3 que permite agrupar valores no mesmo case. Muito prático para sinônimos de comandos.

## Repetição com **while**

O `while` executa um bloco de código enquanto a condição for verdadeira:

```dart
var contador = 1;

while (contador <= 5) {
  print('Contagem: $contador');
  contador++;
}
```

Saída:

```text
Contagem: 1
Contagem: 2
Contagem: 3
Contagem: 4
Contagem: 5
```

O `contador++` é uma abreviação de `contador = contador + 1`. Sem ele, o loop nunca terminaria, um loop infinito, que trava o programa.

### O loop infinito controlado com break

Para jogos, o padrão mais comum é um `while (true)` com `break`:

```dart
while (true) {
  // mostrar opções
  // ler input
  // se for "sair", break
  // senão, processar o comando
}
```

O `while (true)` roda para sempre, até encontrar um `break`, que sai imediatamente do loop. Esse padrão é limpo e legível: o loop continua rodando, e a condição de saída fica explícita dentro do bloco.

O `continue` é o irmão do `break`: em vez de sair do loop, ele pula o resto do bloco e volta ao início da próxima iteração:

### continue, pule para a próxima volta

```dart
while (true) {
  stdout.write('> ');
  var cmd = stdin.readLineSync() ?? '';
  cmd = cmd.trim().toLowerCase();

  if (cmd.isEmpty) {
    continue;
  }

  if (cmd == 'sair') {
    break;
  }

  print('Você digitou: $cmd');
}
```

Se o jogador pressionar Enter sem digitar nada, o `continue` pula o `print` e volta a pedir input.

## Repetição com **for**

O `for` é ideal quando você sabe quantas vezes quer repetir:

```dart
for (var i = 1; i <= 5; i++) {
  print('Item $i');
}
```

Lê-se: comece com `i` igual a 1, enquanto `i` for menor ou igual a 5, depois de cada volta, incremente `i` em 1.

O `for` vai ser essencial quando formos desenhar o mapa em grade, percorrer linhas e colunas. Mas por enquanto o `while` é a estrela do capítulo.

## De texto para número, int.tryParse

Quando o jogador digita "2" no terminal, o programa recebe o texto `"2"`, não o número `2`. Para usar em comparações numéricas, precisamos converter:

```dart
var texto = '42';
var numero = int.tryParse(texto);
```

`int.tryParse` é a versão segura: se o texto não for um número válido, retorna `null` em vez de causar um erro:

```dart
int.tryParse('42')     // 42
int.tryParse('abc')    // null
int.tryParse('')       // null
int.tryParse('3.14')   // null (não é inteiro)
```

O padrão que usaremos sempre:

```dart
var linha = stdin.readLineSync() ?? '';
var opcao = int.tryParse(linha.trim()) ?? -1;
```

Se o jogador digitar algo que não é número, `opcao` será `-1`, um valor que sabemos que não é nenhuma opção válida.

## Aplicação no jogo, o menu interativo

Agora vamos juntar tudo num menu que roda em loop:

```dart
import 'dart:io';

void exibirBanner() {
  print('');
  print('MASMORRA ASCII v0.1');
  print('');
}

void exibirMenu() {
  print('');
  print('O QUE DESEJA FAZER?');
  print('');
  print('  1, Explorar a masmorra');
  print('  2, Ver status do herói');
  print('  3, Ajuda');
  print('  0, Sair do jogo');
  print('');
}

void explorar(String nome) {
  print('');
  print('$nome adentra o corredor escuro...');
  print('Tochas fracas iluminam paredes de pedra.');
  print('Você ouve algo se movendo na escuridão.');
  print('(Exploração completa virá nos próximos capítulos.)');
  print('');
}

void mostrarStatus(String nome) {
  print('');
  print('HERÓI: $nome');
  print('HP: 100/100');
  print('Ouro: 0');
  print('Arma: Nenhuma');
  print('');
}

void mostrarAjuda() {
  print('');
  print('Masmorra ASCII é um roguelike em texto.');
  print('Use os números do menu para navegar.');
  print('Em breve você poderá explorar masmorras,');
  print('lutar contra monstros e coletar tesouros.');
  print('');
}

void main() {
  exibirBanner();

  stdout.write('Como devo chamá-lo? ');
  var nome = (stdin.readLineSync() ?? '').trim();
  if (nome.isEmpty) nome = 'Aventureiro';

  print('');
  print('Bem-vindo, $nome! Sua jornada começa agora.');

  var jogando = true;

  while (jogando) {
    print('');
    exibirMenu();
    stdout.write('> ');

    var linha = (stdin.readLineSync() ?? '').trim().toLowerCase();

    if (linha.isEmpty) {
      print('Digite uma opção do menu.');
      continue;
    }

    var opcao = int.tryParse(linha);
    if (opcao == null) {
      switch (linha) {
        case 'explorar' || 'jogar':
          opcao = 1;
        case 'status':
          opcao = 2;
        case 'ajuda' || 'help':
          opcao = 3;
        case 'sair' || 'quit':
          opcao = 0;
        default:
          print('Não entendi "$linha". Use os números do menu.');
          continue;
      }
    }

    switch (opcao) {
      case 1:
        explorar(nome);
      case 2:
        mostrarStatus(nome);
      case 3:
        mostrarAjuda();
      case 0:
        jogando = false;
        print('');
        print('Até a próxima aventura, $nome!');
      default:
        print('Opção $opcao não existe. Escolha entre 0 e 3.');
    }
  }
}
```

Execute e experimente:

```text

MASMORRA ASCII v0.1

Como devo chamá-lo? Aldric

Bem-vindo, Aldric! Sua jornada começa agora.

O QUE DESEJA FAZER?

  1, Explorar a masmorra
  2, Ver status do herói
  3, Ajuda
  0, Sair do jogo

> 2

HERÓI: Aldric
HP: 100/100
Ouro: 0
Arma: Nenhuma

> explorar

Aldric adentra o corredor escuro...
Tochas fracas iluminam paredes de pedra.
Você ouve algo se movendo na escuridão.
(Exploração completa virá nos próximos capítulos.)

> 0

Até a próxima aventura, Aldric!
```

Vamos destacar os pontos mais importantes desse código.

A variável `jogando` é um `bool` que controla o loop. Quando o jogador escolhe sair, `jogando = false` faz com que o `while (jogando)` termine na próxima verificação. Essa é uma alternativa ao `while (true)` com `break`, ambas funcionam.

O programa aceita tanto números (`1`, `2`, `0`) quanto palavras (`explorar`, `status`, `ajuda`, `sair`). Primeiro tenta usar `int.tryParse()`; se falhar (resultado `null`), tenta casar a palavra com um `switch`. Essa flexibilidade faz o jogo parecer mais inteligente.

O `continue` aparece em dois lugares: quando o input é vazio e quando a palavra não é reconhecida. Em ambos os casos, o programa pula o processamento e volta ao início do loop.

## Variáveis e escopo

Uma sutileza importante: variáveis declaradas dentro de um bloco (entre `{ }`) só existem dentro dele:

```dart
void main() {
  var nome = 'Aldric';

  if (nome.isNotEmpty) {
    var saudacao = 'Olá, $nome!';
    print(saudacao);
  }
}
```

Isso se chama escopo. A variável `nome` tem escopo de `main`, é acessível em qualquer lugar dentro da função. A `saudacao` tem escopo do `if`, existe apenas dentro daquelas chaves.

No jogo, as variáveis importantes (nome do jogador, flag de jogo ativo) são declaradas no escopo do `main` para que possam ser usadas em todo o loop. Variáveis temporárias podem ser declaradas dentro do loop, elas são recriadas a cada iteração.

## Operador ternário, if compacto

Para condições simples que produzem um valor, existe o operador ternário:

```dart
var mensagem = vida > 0 ? 'Vivo' : 'Morto';
```

Lê-se: se `vida > 0`, o resultado é `'Vivo'`; senão, é `'Morto'`. É um `if`/`else` condensado numa expressão. Útil para escolher valores, não para executar lógica complexa:

```dart
print('HP: ${hp}/${maxHp} ${hp < 20 ? "(PERIGO!)" : ""}');
```

***

## Desafios da Masmorra

**Desafio 3.1. Contador de turnos.** Adicione uma variável `turno` que começa em 1 e incrementa a cada vez que o jogador escolhe uma opção válida (não sair, não ajuda). Mostre o turno atual no prompt: `"[Turno 5] > "`. Isso simula a passagem de tempo na masmorra.

**Desafio 3.2. Menu com mais opções (Ver mapa).** Adicione a opção "4, Ver mapa" que imprime um mapa ASCII simples fixo da masmorra. Por enquanto, o mapa pode ser um retângulo com `#` (paredes) e `.` (chão vazio). Use o mesmo padrão de switch/case para processar a opção.

**Desafio 3.3. HP que diminui (Simulando perigo).** Declare `var hp = 100;` no início. Cada vez que o jogador escolher explorar, reduza o HP em um valor fixo (por exemplo, 10-20 pontos de dano simulado). Mostre o HP atualizado no status. Se HP chegar a 0 ou menos, encerre o jogo com uma mensagem de derrota. Observação: isso torna o jogo com tempo limitado.

**Desafio 3.4. Confirmação ao sair (Dupla verificação).** Quando o jogador escolher sair (opção 0), pergunte "Tem certeza (s/n)?" de forma clara. Se digitar s, sim, ou y (yes), saia de verdade. Caso contrário, volte ao menu. Use um loop interno ou um if para capturar essa confirmação.

**Boss Final 3.5. Painel de estatísticas finais.** Ao final do jogo, após sair confirmado ou morte (HP = 0), exiba um painel com uma tabela mostrando: nome do herói, total de turnos sobrevividos, HP final, dano total sofrido (100 - HP final), e uma nota final (S, A, B, C) baseada em turnos/HP. Use operadores ternários para determinar a nota e box-drawing para tornar o painel visual. Exemplo: se sobreviveu mais de 20 turnos, nota A; entre 10-20 turnos, nota B, etc.

## Pergaminho do Capítulo

Você aprendeu `if`/`else if`/`else`, `switch`/`case`, `while` com o padrão `while (true)` e `break`, `for` para repetições contadas, `int.tryParse` para conversão segura, e o operador ternário para condições compactas. O programa agora é um game loop funcional: roda continuamente, aceita múltiplos comandos, e trata input inválido.

No Capítulo 4, vamos entender null safety de Dart: por que `readLineSync()` retorna `String?` e como Dart protege você de crashes.

::: dica
**Dica do Mestre:** O `while (true)` com `break` e o `while (variavel)` são dois padrões igualmente válidos para game loops. Use o que fizer mais sentido para cada situação.
:::
