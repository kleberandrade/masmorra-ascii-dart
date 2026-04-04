# Capítulo 1 - Seu primeiro programa Dart

*O terminal pisca. Você digita o primeiro comando e algo acontece: letras surgem na tela, obedecendo à sua vontade. Não é mágica, é Dart. Mas a sensação é parecida. Nesta primeira descida, você vai aprender a falar a língua da masmorra. Variáveis guardam informações como baús guardam ouro. Tipos definem o que cabe em cada baú. Funções são feitiços que você invoca com um nome e parênteses. Tudo aqui é novo, e a masmorra sabe disso, então os corredores são largos e os inimigos, poucos.*

*Ao final desta parte, você terá um jogo de texto rodando no terminal. Simples, sim. Mas funcional. E o mais importante: escrito por você, linha por linha, entendendo cada palavra. A descida começa devagar, mas cada passo conta.*

> *Você empurra a porta de pedra. Ela range, revelando um corredor iluminado por tochas. No chão, alguém gravou uma inscrição: `void main() {}`. É o começo de tudo.*

Antes de construir masmorras, criar monstros ou gerar mapas procedurais, precisamos de uma base sólida. Um projeto Dart que compila e executa. Este capítulo não é sobre o jogo, é sobre garantir que a ferramenta obedece a você. Quando terminar, terá um programa rodando, saberá o que cada arquivo faz, e terá os hábitos que vão acompanhar todo o resto do livro.

## O que é Dart e por que usá-lo num **roguelike**

Dart é uma linguagem criada pelo Google, conhecida principalmente por ser a base do Flutter. Mas Dart não é apenas Flutter. É uma linguagem completa, com tipagem estática, **null safety** nativo, compilação ahead-of-time (AOT) e just-in-time (JIT), e um ecossistema maduro de pacotes.

Para um **roguelike** no terminal, Dart oferece vantagens reais. A tipagem estática captura erros antes de o programa rodar, e num jogo com dezenas de classes interagindo (jogador, inimigos, itens, salas), isso evita bugs que só apareceriam em runtime. O null safety, que vamos explorar no Capítulo 4, impede aquele crash clássico de tentar acessar algo que não existe. E a sintaxe é limpa o suficiente para que o código seja legível mesmo durante o aprendizado.

Um **roguelike** clássico combina morte permanente (**permadeath**), exploração de dungeon, combate por turnos, e **geração procedural** para criar infinitos mundos únicos.

Além disso, tudo que aprender aqui se aplica diretamente ao Flutter. Quando terminar o livro, a transição para interfaces gráficas será natural, a lógica do jogo e os padrões já estarão prontos.

## Instalando o **Dart SDK**

O primeiro passo é garantir que o Dart SDK está instalado. Acesse [dart.dev/get-dart](https://dart.dev/get-dart) e siga as instruções para o seu sistema operacional.

**No Windows**, a forma mais simples é usar o Chocolatey:

```bash
choco install dart-sdk
```

**No macOS**, com Homebrew:

```bash
brew tap dart-lang/dart
brew install dart
```

**No Linux** (Debian/Ubuntu):

```bash
sudo apt-get update
sudo apt-get install dart
```

Se você já tem o Flutter instalado, o Dart vem junto. O comando `dart` provavelmente já está disponível no seu terminal.

Depois de instalar, abra um terminal e confirme que tudo está funcionando:

```bash
dart --version
```

Você deve ver algo como:

```text
Dart SDK version: 3.11.3 (stable) on "linux_x64"
```

Este livro assume Dart 3.11.3 ou superior. Se sua versão for mais antiga, atualize antes de continuar. Vamos usar recursos como *pattern matching* e *sealed classes* que só existem a partir do Dart 3. Para experimentar sem instalar, use **DartPad** (dartpad.dev), um IDE online para Dart.

## Criando o projeto

Dart tem uma ferramenta de linha de comando que gera a estrutura inicial. Para uma aplicação de console, usamos o template `console`:

```bash
dart create -t console masmorra_ascii
```

Esse comando cria uma pasta `masmorra_ascii` com a seguinte estrutura:

```text
masmorra_ascii/
├── analysis_options.yaml
├── bin/
│   └── masmorra_ascii.dart
├── lib/
│   └── masmorra_ascii.dart
├── pubspec.yaml
├── README.md
└── test/
    └── masmorra_ascii_test.dart
```

Vamos entender cada peça que vai acompanhar todo o desenvolvimento.

O arquivo **pubspec.yaml** é o coração administrativo do projeto. Ele declara o nome do pacote, a versão do SDK, e as dependências. Por enquanto está quase vazio, vamos adicionar coisas à medida que precisarmos.

A pasta `bin/` contém um ponto de entrada gerado automaticamente pelo `dart create`. Em projetos maiores, esse arquivo serve como inicializador fino que delega para o código em `lib/`. No nosso caso, vamos simplificar: todo o código do jogo, incluindo a função `main()`, ficará em `lib/main.dart`. Isso mantém tudo num lugar só enquanto aprendemos, e é o padrão que vamos seguir em todo o livro.

A pasta `lib/` é onde ficará todo o código do jogo: a função `main()`, classes, funções utilitárias, modelos de dados. À medida que o projeto crescer, vamos criar mais arquivos dentro de `lib/` para organizar melhor, mas o ponto de entrada será sempre `lib/main.dart`.

A pasta `test/` é para testes automatizados. Vamos usá-la bastante mais adiante, mas é bom saber que ela existe desde o início.

O arquivo `analysis_options.yaml` configura a análise estática, as regras que o Dart usa para apontar problemas no código antes mesmo de executá-lo.

Agora entre na pasta do projeto:

```bash
cd masmorra_ascii
```

## A função `main`, onde tudo começa

Crie o arquivo `lib/main.dart`. Este será o programa principal do nosso jogo durante todo o livro. Escreva:

```dart
void main() {
  print('Bem-vindo à Masmorra ASCII!');
  print('Prepare-se para explorar o desconhecido.');
}
```

Vamos analisar linha por linha.

`void main()` é a função principal do programa. Toda aplicação Dart começa aqui. A palavra `void` indica que a função não retorna nenhum valor. O nome `main` é especial, é o ponto de entrada que o Dart procura quando você executa o programa. Os parênteses vazios indicam que, por enquanto, não precisamos receber argumentos da linha de comando.

`print()` é a função que escreve texto no terminal. Tudo que você passar entre os parênteses aparece como uma linha na saída. A string (texto) fica entre aspas simples, essa é a convenção em Dart, embora aspas duplas também funcionem.

Cada instrução termina com ponto e vírgula (`;`). Dart é uma linguagem onde o ponto e vírgula é obrigatório. Se esquecer, o analisador vai reclamar.

## Executando pela primeira vez

Antes de executar, precisamos resolver as dependências do projeto. Mesmo que não tenhamos nenhuma dependência externa por enquanto, esse passo é necessário:

```bash
dart pub get
```

Você verá algo como:

```text
Resolving dependencies...
Got dependencies!
```

Agora, execute o programa:

```bash
dart lib/main.dart
```

Se tudo correu bem, o terminal mostra:

```text
Bem-vindo à Masmorra ASCII!
Prepare-se para explorar o desconhecido.
```

Esse é o seu primeiro programa Dart compilado e executado com sucesso. Pode parecer pouco, duas linhas de texto, mas o mecanismo por trás é poderoso. O Dart leu o código-fonte, verificou se havia erros de tipo, compilou para uma representação intermediária, e a máquina virtual Dart executou as instruções. Todo esse pipeline vai funcionar silenciosamente a cada `dart lib/main.dart` que você fizer daqui para frente.

## Expandindo o programa, variáveis e interpolação

Vamos dar um passo além. Altere o `main` para usar uma variável:

```dart
void main() {
  var nomeJogo = 'Masmorra ASCII';
  var versao = 1;

  print('');
  print('$nomeJogo, versão $versao');
  print('');
  print('Prepare-se para explorar o desconhecido.');
  print('');
}
```

Aqui aparecem três conceitos novos.

Variáveis com `var`. `var nomeJogo = 'Masmorra ASCII'` cria uma **variável** chamada `nomeJogo` e armazena o texto `'Masmorra ASCII'` nela. O Dart infere automaticamente que o **tipo** é `String`. Depois da atribuição, `nomeJogo` só pode guardar textos; a tipagem é estática, mesmo usando `var`. Da mesma forma, `versao` é inferido como `int` (número inteiro).

Interpolação de strings. O cifrão (`$`) dentro de uma string permite inserir o valor de uma variável diretamente no texto. `'$nomeJogo, versão $versao'` produz `'Masmorra ASCII, versão 1'`. Para expressões mais complexas, usamos chaves: `'${2 + 3}'` produz `'5'`.

Caracteres especiais. Os caracteres `═` são caracteres Unicode que formam linhas. Dart suporta Unicode nativamente, o que é ótimo para arte ASCII.

Execute novamente com `dart lib/main.dart` e veja a saída formatada:

```text

Masmorra ASCII, versão 1

Prepare-se para explorar o desconhecido.

```

Está começando a parecer um jogo.

## Analisar e formatar, os dois hábitos essenciais

Dois comandos vão acompanhar você pelo resto do livro. Internalize-os agora, porque quanto mais cedo virarem hábito, menos tempo você vai perder caçando bugs.

**dart analyze** examina o código sem executá-lo. Ele procura erros de tipo, variáveis não usadas, imports desnecessários e dezenas de outros problemas. Execute agora:

```bash
dart analyze
```

Se o código estiver correto, você verá:

```text
Analyzing masmorra_ascii...
No issues found!
```

Vamos provocar um erro de propósito para ver o que acontece. Adicione esta linha no `main`:

```dart
int x = 'texto';  // tipo errado!
```

Execute `dart analyze` novamente:

```text
Analyzing masmorra_ascii...

  error - A value of type 'String' can't be assigned to a variable
          of type 'int' - lib/main.dart:3:11

1 issue found.
```

O analisador encontrou o problema antes mesmo de você tentar executar. Ele diz exatamente qual é o erro, em qual arquivo e em qual linha. Remova a linha com erro e siga em frente.

`dart format .` reformata todo o código do projeto segundo as convenções oficiais de Dart. Indentação, espaçamento, quebras de linha, tudo fica padronizado:

```bash
dart format .
```

Não existe discussão sobre tabs vs espaços em Dart. O formatter decide, e todo mundo segue. Isso é libertador, você escreve do jeito que quiser, roda o formatter, e o resultado é sempre limpo.

O ciclo que vai se repetir a cada capítulo é: escrever, `dart analyze`, `dart format`, `dart lib/main.dart`. Decore isso.

## O arquivo pubspec.yaml em detalhe

Abra o arquivo `pubspec.yaml`. Ele deve estar assim:

```yaml
name: masmorra_ascii
description: A sample command-line application.
version: 1.0.0

environment:
  sdk: ^3.11.0

dev_dependencies:
  lints: ^5.0.0
  test: ^1.24.0
```

`name` é o identificador do pacote. `description` é uma descrição curta. `version` segue o versionamento semântico (major.minor.patch).

`environment.sdk: ^3.11.0` significa este projeto precisa do Dart SDK versão 3.11.0 ou superior, mas inferior a 4.0.0. O acento circunflexo (`^`) indica compatibilidade com versões futuras dentro da mesma major version.

`dev_dependencies` são pacotes usados apenas durante o desenvolvimento, não vão junto quando alguém usa o seu pacote como biblioteca. `lints` fornece regras de análise estática e `test` é o framework de testes.

Vamos personalizar um pouco:

```yaml
name: masmorra_ascii
description: Um roguelike em ASCII construído com Dart puro.
version: 0.1.0

environment:
  sdk: ^3.11.0

dev_dependencies:
  lints: ^5.0.0
  test: ^1.24.0
```

Mudamos a descrição para algo que faz sentido para o nosso projeto e a versão para `0.1.0`, ainda estamos na fase inicial.

## Configurando a análise estática

Abra o arquivo `analysis_options.yaml`. Vamos configurá-lo para ser rigoroso desde o início:

```yaml
include: package:lints/recommended.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
```

Essas três flags ativam o modo mais exigente do analisador Dart. `strict-casts` proíbe conversões implícitas de `dynamic` para tipos concretos. `strict-inference` exige que o Dart consiga inferir o tipo de toda expressão. `strict-raw-types` proíbe usar tipos genéricos sem especificar o parâmetro (como `List` em vez de `List<String>`).

Pode parecer excessivo para um projeto simples, mas essas regras vão nos salvar de bugs quando o jogo ficar complexo. Melhor acostumar desde o primeiro capítulo.

## Polindo o banner

Nosso programa funciona, mas o banner está nu demais. Vamos usar os caracteres box-drawing do Unicode para dar um ar de jogo ao terminal. Substitua o conteúdo de `lib/main.dart`:

```dart
void main() {
  var nomeJogo = 'Masmorra ASCII';
  var versao = '0.1.0';

  print('');
  print('═══════════════════════════════════');
  print('       $nomeJogo v$versao');
  print('═══════════════════════════════════');
  print('');
  print('  Prepare-se para explorar');
  print('  o desconhecido.');
  print('');
  print('═══════════════════════════════════');
  print('');
}
```

Execute `dart lib/main.dart` e veja o banner:

```text

═══════════════════════════════════
       Masmorra ASCII v0.1.0
═══════════════════════════════════

  Prepare-se para explorar
  o desconhecido.

═══════════════════════════════════

```

O jogo ainda não é um jogo, é uma placa na porta da masmorra. Mas a fundação está sólida: o projeto existe, compila sem erros, e você já sabe como analisar e formatar o código.

Observe que todo nosso código vive em `lib/main.dart`. À medida que o jogo crescer, vamos criar mais arquivos em `lib/` para organizar classes e funções, mas o ponto de entrada será sempre `lib/main.dart`. O arquivo `lib/masmorra_ascii.dart` gerado pelo `dart create` serve como declaração da biblioteca:

```dart
/// Masmorra ASCII, um roguelike em Dart puro.
///
/// Biblioteca principal do jogo.
library;
```

Ele ficará útil quando começarmos a importar módulos entre arquivos.

***

## Desafios da Masmorra

**Desafio 1.1. Personalize o banner.** Modifique o banner para incluir o seu nome como autor. Use uma nova variável `autor` e interpolação de string para exibi-la. Dica: use múltiplas linhas de `print()` para deixar o banner legível.

**Desafio 1.2. Explore o dart analyze.** Introduza três erros diferentes no código (tipo errado, variável não usada, ponto e vírgula faltando) e veja como o `dart analyze` os reporta. Depois corrija todos. Observe como o analisador ajuda você a encontrar problemas sem executar o programa.

**Desafio 1.3. Moldura com caracteres box-drawing.** Reescreva o banner usando os caracteres `╔`, `╗`, `╚`, `╝`, `║` e `═` para criar uma moldura completa. A moldura deve ter largura fixa de 40 caracteres. Execute e veja o resultado alinhado.

**Desafio 1.4. Múltiplas linhas com quebra de linha.** Em vez de usar vários `print()`, tente criar uma única string multilinha usando `\n` ou aspas triplas (`'''`). Execute e compare qual abordagem você acha mais legível no código.

**Boss Final 1.5. **ASCII art** de portal mágico.** Crie uma arte ASCII de um portal mágico ou de uma inscrição antiga na parede da masmorra, usando apenas `print()`. Comece simples (5-10 linhas) e incremente. Teste caracteres especiais: `◆`, `◊`, `✦`, `✧` para efeitos visuais. O objetivo é dominar a saída no terminal e entender como texto visual funciona num roguelike.

*Dica do Mestre: Comece com caracteres simples como `*`, `#` e `-` para desenhar a forma geral, depois refine com box-drawing como `╔`, `║`, `═`. Linhas de symmetry ajudam: desenha metade, depois copia e inverte.*

## Pergaminho do Capítulo

Neste capítulo você instalou o Dart SDK, criou um projeto com `dart create`, entendeu a estrutura de pastas e definiu `lib/main.dart` como o ponto de entrada do jogo. Escreveu e executou seu primeiro programa, aprendeu os dois hábitos essenciais (`dart analyze` e `dart format`), e viu como variáveis e interpolação de strings funcionam em Dart.

No Capítulo 2, vamos ligar o programa ao teclado: o jogador vai poder digitar comandos, e o programa vai responder. É o primeiro passo para transformar um programa estático num jogo interativo.

::: dica
**Dica do Mestre:** Use um editor com suporte a Dart. VS Code com a extensão Dart, IntelliJ com o plugin Dart, ou até o Android Studio. Esses editores rodam `dart analyze` automaticamente enquanto você digita, mostram erros sublinhados em vermelho, oferecem auto-complete e permitem navegar entre definições. Escrever Dart num editor sem suporte é como explorar uma masmorra sem tocha: possível, mas desnecessariamente difícil.
:::
