# Capítulo 12 - Enums e o parser de comandos

> *A masmorra entende apenas algumas palavras: "norte", "ataca", "inventário". Se o jogador sussurra algo estranho, o jogo não compreende. Os enums são como um dicionário fechado—só existem as palavras que você definiu, nada mais, nada menos.*

## Enums: tipos fechados e pequenos

Um **enum** (enumeração) é um tipo que só pode ter um conjunto predefinido de valores. É perfeito para coisas que não mudam: direções cardeais, dias da semana, fases da lua. Use `enum` para valores imutáveis:

```dart
// lib/direcao.dart

enum Direcao {
  norte,
  sul,
  leste,
  oeste,
}
```

Simples e poderoso:

```dart
void main() {
  final direcao = Direcao.norte;
  print(direcao);
}
```

Dart garante que `direcao` é uma das quatro opções. Nada de erros estranhos como `direcao = 'septentriao'` (typo). O compilador não permite valores inválidos.

## Enums com membros (Dart 3+)

Em Dart 3, `enum` podem ter propriedades, construtores e métodos (use `const` no construtor):

```dart
// lib/direcao.dart

enum Direcao {
  norte(simbolo: '↑', id: 'n'),
  sul(simbolo: '↓', id: 's'),
  leste(simbolo: '→', id: 'e'),
  oeste(simbolo: '←', id: 'o');

  final String simbolo;
  final String id;

  const Direcao({required this.simbolo, required this.id});

  Direcao get oposta {
    switch (this) {
      case Direcao.norte:
        return Direcao.sul;
      case Direcao.sul:
        return Direcao.norte;
      case Direcao.leste:
        return Direcao.oeste;
      case Direcao.oeste:
        return Direcao.leste;
    }
  }

  static Direcao? deString(String s) {
    switch (s.toLowerCase()) {
      case 'n':
      case 'norte':
        return Direcao.norte;
      case 's':
      case 'sul':
        return Direcao.sul;
      case 'e':
      case 'leste':
        return Direcao.leste;
      case 'o':
      case 'oeste':
        return Direcao.oeste;
      default:
        return null;
    }
  }
}
```

Uso:

```dart
void main() {
  final dir = Direcao.norte;
  print('Vou para ${dir.simbolo}');

  final dirOposta = dir.oposta;
  print('Oposta: ${dirOposta.simbolo}');

  final dirDoInput = Direcao.deString('n');
  print(dirDoInput);
}
```

## **Sealed classes**: comandos com tipagem estrita

Agora vem o prato forte. `sealed class` são uma forma de Dart de dizer "esta hierarquia está fechada, apenas estas subclasses existem". É perfeito para command (padrão de design), porque cada comando é diferente e tem argumentos diferentes. Dart também oferece extensions para adicionar métodos a tipos existentes sem herança e typedefs para nomear assinaturas de função complexas. Use `sealed class` para hierarquias fechadas:

```dart
// lib/comando_jogo.dart

import 'direcao.dart';

sealed class ComandoJogo {
  const ComandoJogo();

  String executar(); // Método abstrato
}

class ComandoMover extends ComandoJogo {
  final Direcao direcao;

  const ComandoMover(this.direcao);

  @override
  String executar() => 'Movendo para $direcao';
}

class ComandoAtacar extends ComandoJogo {
  final String alvo;

  const ComandoAtacar(this.alvo);

  @override
  String executar() => 'Atacando $alvo!';
}

class ComandoPegar extends ComandoJogo {
  final String item;

  const ComandoPegar(this.item);

  @override
  String executar() => 'Você pegou $item';
}

class ComandoInventario extends ComandoJogo {
  const ComandoInventario();

  @override
  String executar() => 'Abrindo inventário...';
}

class ComandoOlhar extends ComandoJogo {
  const ComandoOlhar();

  @override
  String executar() => 'Você observa ao seu redor...';
}

class ComandoStatus extends ComandoJogo {
  const ComandoStatus();

  @override
  String executar() => 'Mostrando status...';
}

class ComandoAjuda extends ComandoJogo {
  const ComandoAjuda();

  @override
  String executar() =>
      'Comandos: norte/sul/leste/oeste, atacar, pegar, inv, status, olhar, ajuda, sair';
}

class ComandoSair extends ComandoJogo {
  const ComandoSair();

  @override
  String executar() => 'Até logo!';
}

class ComandoDesconhecido extends ComandoJogo {
  final String entrada;

  const ComandoDesconhecido(this.entrada);

  @override
  String executar() => 'Não entendo "$entrada". Tenta "ajuda".';
}
```

## O parser: transformar texto em comandos

Agora o coração da magia: uma função que lê uma linha de texto e devolve um `ComandoJogo` tipado.

```dart
// lib/parser.dart

import 'comando_jogo.dart';
import 'direcao.dart';

ComandoJogo analisarLinha(String entrada) {
  final linha = entrada.trim().toLowerCase();

  if (linha.isEmpty) {
    return const ComandoDesconhecido('(vazio)');
  }

  final palavras = linha.split(RegExp(r'\s+'));
  final verbo = palavras[0];
  final args = palavras.length > 1 ? palavras.sublist(1) : [];

  switch (verbo) {
    case 'n':
    case 'norte':
      return const ComandoMover(Direcao.norte);

    case 's':
    case 'sul':
      return const ComandoMover(Direcao.sul);

    case 'e':
    case 'leste':
      return const ComandoMover(Direcao.leste);

    case 'o':
    case 'oeste':
      return const ComandoMover(Direcao.oeste);

    case 'atacar':
    case 'a':
      if (args.isEmpty) {
        return const ComandoDesconhecido('atacar o quê?');
      }
      final alvo = args.join(' ');
      return ComandoAtacar(alvo);

    case 'inv':
    case 'inventario':
    case 'i':
      return const ComandoInventario();

    case 'pegar':
    case 'p':
      if (args.isEmpty) {
        return const ComandoDesconhecido('pegar o quê?');
      }
      final item = args.join(' ');
      return ComandoPegar(item);

    case 'status':
      return const ComandoStatus();

    case 'olhar':
    case 'ver':
    case 'l':
      return const ComandoOlhar();

    case 'ajuda':
    case 'help':
    case '?':
      return const ComandoAjuda();

    case 'sair':
    case 'quit':
    case 'exit':
      return const ComandoSair();

    default:
      return ComandoDesconhecido(entrada);
  }
}
```

## Switch exaustivo com sealed classes

Isso é onde Dart brilha. Quando você faz um `switch` sobre uma `sealed class`, o compilador força-te a tratar todos os casos (switch exaustivo):

```dart
// lib/loop_jogo.dart

import 'comando_jogo.dart';
import 'parser.dart';

class LoopJogo {
  void processarComando(ComandoJogo cmd) {
    switch (cmd) {
      case ComandoMover(:final direcao):
        print('Movendo para $direcao...');

      case ComandoAtacar(:final alvo):
        print('Atacando $alvo...');

      case ComandoPegar(:final item):
        print('Pegando em $item...');

      case ComandoInventario():
        print('Mostrando inventário...');

      case ComandoOlhar():
        print('Observando...');

      case ComandoStatus():
        print('Mostrando status...');

      case ComandoAjuda():
        print('Mostrando ajuda...');

      case ComandoSair():
        print('Saindo do jogo...');

      case ComandoDesconhecido(:final entrada):
        print('Comando desconhecido: $entrada');
    }
  }

  void mainLoop() {
    while (true) {
      print('> ');
      final entrada = stdin.readLineSync() ?? '';

      final cmd = analisarLinha(entrada);
      processarComando(cmd);
    }
  }
}
```

## Pattern matching com extração

Note a sintaxe especial: `case ComandoAtacar(:final alvo)`. Isso é pattern matching. Extrai o campo `alvo` diretamente no `case`, tornando o código mais conciso:

```dart
// Sem pattern matching (mais verboso)
case ComandoAtacar cmd:
  final alvo = cmd.alvo;
  print('Atacando $alvo');
  break;

// Com pattern matching (mais elegante)
case ComandoAtacar(:final alvo):
  print('Atacando $alvo');
```

## Integração completa: do input ao jogo

Veja como tudo flui. Note o `import 'dart:io';` necessário para `stdin` e `stdout`:

```dart
// lib/main.dart

import 'dart:io';
import 'comando_jogo.dart';
import 'parser.dart';
import 'mundo_texto.dart';
import 'mundo_dados.dart';

void main() {
  final mundo = criarMundoVila();
  var salaAtual = 'praca';

  print('=== MASMORRA ASCII ===');
  print('Digite "ajuda" para ver comandos.\n');

  while (true) {
    final sala = mundo.obterSala(salaAtual);
    print('\n[${sala!.nome}]');
    print(sala.descricao);

    if (sala.inimigoPresente != null) {
      final ini = sala.inimigoPresente!;
      print('Aqui está um ${ini.nome} (${ini.simbolo})!');
    }

    print('Saídas: ${sala.saidas.keys.join(", ")}');

    stdout.write('> ');
    final entrada = stdin.readLineSync() ?? '';

    final cmd = analisarLinha(entrada);

    switch (cmd) {
      case ComandoMover(:final direcao):
        final dirStr = direcao.id;
        if (mundo.temSaida(salaAtual, dirStr)) {
          salaAtual = mundo.irParaDirecao(salaAtual, dirStr)!;
          print('Você se moveu para ${direcao.simbolo}');
        } else {
          print('Você não pode ir para $direcao.');
        }

      case ComandoAtacar(:final alvo):
        final sala2 = mundo.obterSala(salaAtual);
        if (sala2?.inimigoPresente != null) {
          print('Você atacou ${sala2!.inimigoPresente!.nome}!');
        } else {
          print('Não há nada para atacar aqui.');
        }

      case ComandoPegar(:final item):
        print('Você procurou por $item, mas não encontrou nada.');

      case ComandoInventario():
        print('Inventário vazio.');

      case ComandoOlhar():
        print('(você já vê isto)');

      case ComandoAjuda():
        print(cmd.executar());

      case ComandoSair():
        print('Até logo!');
        return;

      case ComandoDesconhecido(:final entrada):
        print(cmd.executar());
    }
  }
}
```

***

## Desafios da Masmorra

**Desafio 12.1. Estender o enum Direcao (Direções diagonais).** Adicione `nordeste`, `noroeste`, `sudeste`, `sudoeste` como novos membros ao enum. Cada um deve ter um símbolo apropriado (`'↗'`, `'↖'`, `'↘'`, `'↙'`) e id curto (`'ne'`, `'nw'`, `'se'`, `'sw'`). Atualize o método `oposta()` também.

**Desafio 12.2. Novo comando ComandoEquipar.** Crie uma sealed subclass `ComandoEquipar` com um campo `arma: String`. Adicione-a ao parser quando o jogador escreve "equipar espada" ou "eq lança". Teste que o parser extrai o nome da arma corretamente.

**Desafio 12.3. Sinonímia no parser (Abreviações).** Adicione abreviações para direções: `"u"` (up) para norte, `"d"` (down) para sul, `"l"` para leste, `"o"` para oeste. Teste que `analisarLinha("u")` retorna `ComandoMover(Direcao.norte)` e `analisarLinha("inv")` retorna `ComandoInventario()`.

**Desafio 12.4. Sugestão de comando semelhante.** Quando o jogador escreve um comando desconhecido, em vez de apenas retornar `ComandoDesconhecido(entrada)`, verifique se é similar a um comando válido (ex.: "atlcar" ≈ "atacar") e sugira: "Você quis dizer 'atacar'? Tente novamente."

**Boss Final 12.5. Comando ComandoFala (Fala com argumento).** Crie `ComandoFala` que aceita uma frase inteira (ex.: `falar "Olá, mundo!"`). Modifique o parser para capturar tudo após "falar" como argumento único (pode incluir múltiplas palavras e pontuação). Demonstre com uma frase completa.

## Pergaminho do Capítulo

Neste capítulo você aprendeu:

- `enum` definem tipos fechados com um conjunto finito de valores.
- `enum` com membros (Dart 3+) podem ter propriedades, construtores e métodos.
- `sealed class` são hierarquias fechadas, apenas as subclasses declaradas podem existir.
- Parser transforma texto em objetos tipados, eliminando strings soltas e ambíguas.
- Pattern matching (`case ComandoAtacar(:final alvo)`) extrai dados `inline`.
- `switch` exaustivo força você a tratar todos os casos de uma `sealed class`; o compilador avisa se você esquecer algum.

`enum` e `sealed class` são ferramentas poderosas para tornar o código mais seguro. Quando combinadas, garantem que cada comando é um tipo diferente (nenhuma confusão), cada comando tem os campos corretos (não há erros de acesso), e o código que despacha comandos trata todos os casos (compilador força isso).

::: dica
**Dica do Mestre:** `sealed class` + `switch` exaustivo = refatoração segura. Imagine que você adiciona um novo comando `ComandoMagia` num projeto grande. Com `sealed class`, o compilador anuncia cada lugar onde você faz `switch` sobre `ComandoJogo`, dizendo "ei, você esqueceu de tratar `ComandoMagia`!". Em linguagens sem `sealed class`, você recebe silenciosamente um `default` anônimo e a lógica fica incompleta. `sealed class` transformam erros em tempo de execução em avisos em tempo de compilação. Isso é refatoração segura.
:::
