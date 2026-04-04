# Capítulo 2 - Conversando com o terminal

> *O aventureiro se aproxima da inscrição na parede. Letras brilham: "Diga seu nome e a porta se abrirá." Ele digita. A masmorra escuta.*

No capítulo anterior, o programa falava mas não ouvia. Mostrava um banner bonito e saía. Isso é um pôster, não um jogo. A partir de agora, o programa vai ler o que o jogador digita, processar a entrada e responder. Essa ida e volta, input, processamento, output, é o alicerce de qualquer programa interativo, e de todo jogo que já existiu.

## Saída, o que já sabemos e um pouco mais

Você já conhece a função `print()`, que escreve uma linha no terminal e pula para a próxima. Dart oferece outra função de saída que é útil em jogos:

```dart
import 'dart:io';

void main() {
  stdout.write('Qual é o seu nome? ');
}
```

A diferença entre `print()` e `stdout.write()` é sutil mas importante. A função `print()` sempre adiciona uma quebra de linha no final; o cursor vai para a linha seguinte. `stdout.write()` escreve o texto e mantém o cursor na mesma linha. Isso é perfeito para prompts onde queremos que o jogador digite na mesma linha da pergunta:

```text
Qual é o seu nome? _
```

Em vez de:

```text
Qual é o seu nome?
_
```

Para usar `stdout.write()`, precisamos importar `dart:io`, a biblioteca de entrada e saída do Dart. A linha `import 'dart:io';` deve ficar no topo do arquivo, antes de tudo. **stdout** e **stdin** são objetos do módulo `dart:io` para escrever e ler do terminal.

Para ler o que o jogador digita, usamos `stdin.readLineSync()`:

## Entrada, ouvindo o jogador

```dart
import 'dart:io';

void main() {
  stdout.write('Qual é o seu nome? ');
  var nome = stdin.readLineSync();
  print('Bem-vindo, $nome!');
}
```

Execute com o comando `dart lib/main.dart`:

```text
Qual é o seu nome? Aldric
Bem-vindo, Aldric!
```

O programa parou, esperou você digitar algo e pressionar Enter, capturou o texto, guardou na variável `nome`, e usou interpolação para incluí-lo na mensagem de boas-vindas.

Mas há um detalhe importante. O tipo retornado por `stdin.readLineSync()` não é `String`, é `String?` (**nullable**). Isso significa que o valor pode ser uma string ou `null` (nada). O Dart nos avisa disso porque existem situações em que `readLineSync()` pode não conseguir ler nada; por exemplo, se a entrada padrão for redirecionada de um arquivo vazio.

Para lidar com esse risco de `null`, usamos o operador `??`:

```dart
import 'dart:io';

void main() {
  stdout.write('Qual é o seu nome? ');
  var nome = stdin.readLineSync() ?? 'Aventureiro';
  print('Bem-vindo, $nome!');
}
```

O operador `??` é o "operador de coalescência nula": se o valor à esquerda for `null`, usa o valor à direita. Então se `readLineSync()` retornar `null`, `nome` será `'Aventureiro'`. Vamos explorar null safety em profundidade no Capítulo 4. Por enquanto, pense no operador `??` como uma rede de segurança contra o nada.

## Funções, organizando o código

Conforme o programa cresce, colocar tudo dentro do `main` vira uma bagunça rápido. **Funções** são a primeira ferramenta de organização, blocos de código com nome, que fazem uma coisa específica e podem ser chamados de qualquer lugar.

### Funções que não retornam nada (void)

Vamos criar uma função que exibe o banner do jogo:

```dart
void exibirBanner() {
  print('');
  print('╔══════════════════════════════════╗');
  print('║       MASMORRA ASCII v0.1        ║');
  print('╚══════════════════════════════════╝');
  print('');
}
```

`void` indica que a função não retorna nada, ela faz algo (imprime no terminal) mas não produz um valor. `exibirBanner` é o nome que escolhemos. Os parênteses vazios indicam que a função não recebe parâmetros.

Para chamar a função, basta escrever o nome com parênteses:

```dart
void main() {
  exibirBanner();
}
```

### Funções que retornam um valor

Agora uma função que retorna um valor:

```dart
String pedirNome() {
  stdout.write('Como devo chamá-lo? ');
  var nome = stdin.readLineSync() ?? 'Aventureiro';
  return nome.trim();
}
```

Aqui o tipo de retorno é `String`. A função recebe input do jogador e devolve o nome como texto. A instrução `return` diz qual é o valor que a função produz. O método `.trim()` remove espaços em branco no início e no final do texto, um cuidado que evita problemas se o jogador digitar `"  Aldric  "` com espaços acidentais.

Quando chamamos essa função, podemos guardar o resultado numa variável:

```dart
var nome = pedirNome();
```

### Funções com parâmetros

Funções também podem receber valores de entrada, chamados parâmetros:

```dart
void saudar(String nome) {
  print('Bem-vindo à Masmorra, $nome!');
  print('Que os dados estejam ao seu favor.');
}
```

O parâmetro `nome` é declarado com seu tipo (`String`) dentro dos parênteses. Quando chamamos a função `saudar('Aldric')`, o valor `'Aldric'` é passado para `nome` dentro da função.

Funções podem ter múltiplos parâmetros:

```dart
void exibirStatus(String nome, int nivel, int ouro) {
  print('$nome, Nível $nivel, $ouro moedas de ouro');
}
```

### Juntando tudo

Vamos usar todas essas funções juntas:

```dart
// main.dart
import 'dart:io';

void exibirBanner() {
  print('');
  print('MASMORRA ASCII v0.1.0');
  print('');
}

String pedirNome() {
  stdout.write('Como devo chamá-lo? ');
  var nome = stdin.readLineSync() ?? 'Aventureiro';
  return nome.trim();
}

void saudar(String nome) {
  print('');
  print('Bem-vindo à Masmorra, $nome!');
  print('Que os dados estejam ao seu favor.');
  print('');
}

void main() {
  exibirBanner();
  var nome = pedirNome();
  saudar(nome);
}
```

Execute:

```text

MASMORRA ASCII v0.1.0

Como devo chamá-lo? Aldric

Bem-vindo à Masmorra, Aldric!
Que os dados estejam ao seu favor.

```

Repare como o `main` agora é limpo e legível. Três linhas que contam uma história: mostrar banner, pedir nome, saudar. Os detalhes ficam dentro de cada função. Essa clareza é fundamental num projeto que vai crescer para milhares de linhas de código.

## Strings em detalhe

Strings são o tipo de dado mais usado num jogo de texto, então vale a pena conhecê-las bem.

**Criação com aspas simples e duplas.** Ambas são equivalentes em Dart. A convenção em Dart é usar aspas simples:

```dart
var a = 'texto com aspas simples';
var b = "texto com aspas duplas";
```

**Interpolação com cifrão (`$`).** O cifrão insere variáveis. Chaves (`${}`) são necessárias para expressões:

```dart
var nome = 'Aldric';
var nivel = 3;
print('$nome está no nível $nivel');
print('Próximo nível: ${nivel + 1}');
print('Nome em maiúsculas: ${nome.toUpperCase()}');
```

**Strings multilinha com aspas triplas.** Permitem texto que ocupa várias linhas:

```dart
var descricao = '''
Você está numa sala escura.
O ar é úmido e cheira a mofo.
Uma tocha fraca ilumina a parede norte.''';
print(descricao);
```

**Métodos úteis de String.** Esses métodos vão aparecer repetidamente no jogo:

```dart
var texto = '  Masmorra ASCII  ';

texto.trim()           // 'Masmorra ASCII', remove espaços nas pontas
texto.toUpperCase()    // '  MASMORRA ASCII  '
texto.toLowerCase()    // '  masmorra ascii  '
texto.contains('ASCII') // true
texto.length           // 19
texto.isEmpty          // false
''.isEmpty             // true

print('═' * 30);       // ══════════════════════════════
```

O `.trim()` limpa input do jogador. `.toLowerCase()` permite comparar comandos sem se preocupar com maiúsculas/minúsculas. `.contains()` procura palavras-chave. `.isEmpty` verifica se o jogador pressionou Enter sem digitar nada. A repetição com `*` é perfeita para desenhar molduras ASCII.

**Caracteres de escape.** Alguns caracteres especiais precisam de barra invertida:

```dart
print('Linha 1\nLinha 2');
print('Coluna1\tColuna2');
print('Ele disse: \'olá\'');
```

## Tipos de dados, a primeira visão

Até agora usamos `var` para declarar variáveis e deixamos o Dart inferir o tipo. Mas é importante saber quais tipos básicos existem em Dart:

```dart
String nome = 'Aldric';
int nivel = 1;
double vida = 100.0;
bool estaVivo = true;
```

Quando usamos `var`, o Dart determina o tipo automaticamente a partir do valor inicial. O tipo `bool` é o booleano, pode ser `true` ou `false`:

```dart
var nome = 'Aldric';
var nivel = 1;
var vida = 100.0;
var estaVivo = true;
```

Depois da atribuição inicial, o tipo é fixo. Você não pode fazer `nome = 42`, o Dart vai reclamar porque `nome` é `String`, não `int`. Essa é a tipagem estática em ação: erros de tipo são encontrados antes de o programa rodar.

**`final` e `const`: variáveis imutáveis.** Quando um valor não deveria mudar, declare com `final`:

```dart
final nomeJogo = 'Masmorra ASCII';
```

E `const` para valores que são conhecidos em tempo de compilação:

```dart
const versao = '0.1.0';
const maxVida = 100;
```

A diferença prática: `final` aceita valores calculados em runtime (como o resultado de `pedirNome()`), enquanto `const` exige valores literais. Usaremos `final` na maioria dos casos e `const` para constantes globais do jogo como dano base e HP máximo.

**Convertendo entre tipos.** Quando o jogador digita um número, ele chega como `String`. Para usá-lo como **double** ou `int`:

```dart
var texto = '42';
var numero = int.parse(texto);
```

Mas se o texto não for um número válido, `int.parse` causa um erro. A versão segura é `int.tryParse`:

```dart
var resultado = int.tryParse('abc');
var numero = int.tryParse('42');
```

Vamos usar `tryParse` sempre que o jogador puder digitar algo que não é um número, o que em jogos de texto é o tempo todo.

## Aplicação no jogo, o primeiro diálogo interativo

Vamos expandir o programa para algo que já começa a parecer um jogo. O programa vai pedir o nome, apresentar uma descrição de sala, e oferecer opções ao jogador:

```dart
// main.dart
import 'dart:io';

void exibirBanner() {
  print('');
  print('MASMORRA ASCII v0.1.0');
  print('Aprenda Dart, conquiste a masmorra');
  print('');
}

String pedirNome() {
  stdout.write('Como devo chamá-lo, aventureiro? ');
  var entrada = stdin.readLineSync() ?? '';
  var nome = entrada.trim();
  if (nome.isEmpty) {
    nome = 'Aventureiro';
    print('Sem nome? Tudo bem, chamarei você de $nome.');
  }
  return nome;
}

void descreverSala(String nome) {
  print('');
  print('═══════════════════════════════════');
  print(' $nome, você está na Praça Central.');
  print('');
  print(' Uma fonte de pedra murmura ao centro');
  print(' da praça. Tochas iluminam três saídas.');
  print('');
  print(' Ao norte: um corredor escuro.');
  print(' A leste: uma porta de madeira.');
  print(' Ao sul: a saída da masmorra.');
  print('═══════════════════════════════════');
  print('');
}

String pedirComando() {
  stdout.write('O que deseja fazer? ');
  var comando = stdin.readLineSync() ?? '';
  return comando.trim().toLowerCase();
}

void responderComando(String comando) {
  if (comando == 'norte' || comando == 'n') {
    print('Você caminha para o norte...');
    print('O corredor é frio e úmido.');
  } else if (comando == 'leste' || comando == 'l') {
    print('Você empurra a porta de madeira...');
    print('Rangidos ecoam pelo corredor.');
  } else if (comando == 'sul' || comando == 's') {
    print('Você recua para a saída.');
    print('A luz do sol aquece seu rosto.');
  } else if (comando == 'sair') {
    print('Até a próxima aventura!');
  } else {
    print('Não entendi "$comando".');
    print('Tente: norte, leste, sul ou sair.');
  }
  print('');
}

void main() {
  exibirBanner();
  var nome = pedirNome();
  descreverSala(nome);
  var comando = pedirComando();
  responderComando(comando);
}
```

Execute e interaja:

```text

MASMORRA ASCII v0.1.0
Aprenda Dart, conquiste a masmorra

Como devo chamá-lo, aventureiro? Aldric

Aldric, você está na Praça Central.

Uma fonte de pedra murmura ao centro
da praça. Tochas iluminam três saídas.

Ao norte: um corredor escuro.
A leste: uma porta de madeira.
Ao sul: a saída da masmorra.

O que deseja fazer? norte
Você caminha para o norte...
O corredor é frio e úmido.
```

O programa ainda aceita apenas um comando e depois termina. No Capítulo 3, vamos adicionar repetição para que o jogador possa dar vários comandos seguidos.

Repare em dois detalhes importantes no código acima. Primeiro, `pedirComando()` usa `.trim().toLowerCase()`. Isso significa que `"Norte"`, `"NORTE"`, `"  norte  "` e `"norte"` funcionam da mesma forma. Sempre normalize a entrada do jogador antes de compará-la. Segundo, a função `responderComando()` trata o caso "não entendi" com uma mensagem clara que lista os comandos válidos. Nunca ignore input inválido. Um bom jogo sempre responde ao jogador, mesmo que seja para dizer que não entendeu.

## Desafios da Masmorra

**Desafio 2.1. Pergunta extra.** Depois de pedir o nome, pergunte a classe do personagem (Guerreiro, Mago ou Ladrão) e inclua essa informação na saudação. Crie uma função `pedirClasse()` que retorna `String`. Valide que a entrada é uma das três opções válidas.

**Desafio 2.2. Moldura dinâmica.** Escreva uma função `exibirEmMoldura(String texto)` que recebe qualquer texto e o exibe dentro de uma moldura com bordas box-drawing. A moldura deve se ajustar dinamicamente ao tamanho do texto. Dica: use `texto.length` para saber o tamanho e `'═' * n` para repetir o caractere.

**Desafio 2.3. Validação de entrada robusta.** Modifique `pedirNome()` para recusar nomes com menos de 2 caracteres ou mais de 20. Se o jogador digitar algo fora desse intervalo, mostre uma mensagem clara de erro, sugira um intervalo válido, e peça novamente em vez de usar nome padrão. Dica: use `nome.length` na condição e considere um loop.

**Desafio 2.4. Múltiplas salas com navegação.** Crie três funções: `descreverPraca()`, `descreverCorredor()`, `descreverPorta()`. Dependendo do comando que o jogador digitar na praça, chame a função correspondente. O programa ainda aceita um único comando e termina, mas a ideia de navegar entre descrições já começa a surgir. Observe como a lógica começa a ficar mais complexa.

**Boss Final 2.5. Diálogo com NPC (Velho Sábio).** Adicione um comando especial `"falar"` que inicia uma conversa com um NPC chamado Velho Sábio na Praça Central. O Velho Sábio faz uma pergunta ao jogador (por exemplo: "Qual é a sua maior virtude?" com opções "coragem", "sabedoria", "justiça") e responde com uma observação diferente para cada escolha. Integre isso ao fluxo principal: depois de responder, o programa termina com uma mensagem final do Velho Sábio.

*Dica do Mestre: Crie uma função `iniciarDialogoVelhoSabio()` que encapsula toda a conversa: lê input do jogador, valida a opção, mostra a resposta. A função `main()` fica limpa, apenas chama essa função quando apropriado.*

## Pergaminho do Capítulo

Você aprendeu a ler entrada do jogador com `stdin.readLineSync()`, importar bibliotecas com `import 'dart:io'`, criar funções com parâmetros e retornos, manipular strings com métodos como `.trim()` e `.toLowerCase()`, e usar o operador `??` para fornecer valores padrão. O programa agora conversa com o jogador: pede nome, descreve uma sala, e responde a comandos.

No Capítulo 3, você adicionará loops e decisões mais complexas para manter o jogo rodando enquanto o jogador quiser.

::: dica
**Dica do Mestre:** Em jogos de texto, a regra de ouro é nunca ignore o input do jogador. Mesmo que o comando não faça sentido, responda. Um simples "Não entendi, tente novamente" é infinitamente melhor que silêncio. O jogador precisa saber que o jogo está ouvindo, caso contrário, vai achar que travou.
:::

## Próximo Capítulo

No próximo capítulo, suas variáveis ganham poder de decisão. Com `if`, `else` e `switch`, o jogo começará a reagir às escolhas do jogador. Prepare-se para loops que dão vida ao combate.
