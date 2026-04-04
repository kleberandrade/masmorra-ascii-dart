# Capítulo 29 - Testes Unitários com package:test

> *Você desenvolve em silêncio, noite após noite. O jogo funciona. Refatora uma classe. Quebra algo, mas não sabe o quê. Passa horas debugando. Testes são como save points em Dark Souls: você pode errar depois sem perder tudo. Com testes, você refatora com confiança. Sem testes, refatoração é salto de fé.*

Todo aventureiro experiente testa seu equipamento antes de descer para um andar perigoso. Verifica se a espada está afiada, se o escudo não rachou, se as poções não expiraram. **Testes unitários** (por exemplo com `package:test`) são a versão do programador desse ritual. Você escreve uma série de pequenos testes que verificam se cada pedaço do seu código funciona como esperado.

Testes não eliminam todos os bugs (nenhuma masmorra é completamente segura), mas eliminam os piores: aqueles que quebram coisas que funcionavam, aqueles que ignoram casos extremos, aqueles que parecem pequenos mas destroem sua aventura horas depois. A masmorra é escura e cheia de bugs, mas os testes são sua tocha na escuridão. Um jogo com testes é um jogo que você consegue manter, refatorar e expandir durante meses ou anos. Sem testes, cada mudança é um salto no escuro.

## Por Que Testar?

### Cenário 1: Sem Testes

```dart
// lib/combate/calculadorDano.dart
class CalculadorDano {
  int calcular(Jogador atacante, Inimigo alvo) {
    return atacante.ataque - alvo.defesa;
  }
}

// Alguém refatora isto:
int calcular(Jogador atacante, Inimigo alvo) {
  return atacante.ataque + alvo.defesa; // Oops! Operador errado
}

// Ninguém percebe até um jogador reclamar: "Inimigos muito fortes!"
// Você passa 3 horas debugando. Demora 2 minutos para achar.
```

### Cenário 2: Com Testes

Com testes automatizados, você detecta o erro instantaneamente. Você escreve um teste que diz: "calculadora deve retornar 7 quando ataco com 10 e defendo com 3". Agora qualquer mudança acidental é flagrada. Não existe "alguém reclamou horas depois". O teste falha nos primeiros segundos, na sua máquina, antes de você fazer commit.

```dart
// test/combate/calculadorDano_test.dart
void main() {
  test('CalculadorDano: calcular dano simples', () {
    final calc = CalculadorDano();
    final atacante = Jogador(ataque: 10);
    final alvo = Inimigo(defesa: 3);

    final dano = calc.calcular(atacante, alvo);

    expect(dano, equals(7)); // 10 - 3 = 7
  });
}

// Se alguém muda + por -, o teste falha IMEDIATAMENTE:
// $ dart test
// FAILED: dano simples
// Expected: 7
// Actual: 13
```

Testes apanham erros nos primeiros segundos, não após horas de debugação.

## Configurar package:test

Se criou o projeto com `dart create`, `package:test` já está lá:

```yaml
dev_dependencies:
  test: ^1.25.0
```

Se não estiver, adicione:

```bash
dart pub add --dev test
```

## Seu Primeiro Teste

Estrutura básica:

```dart
// test/exemplo_test.dart
import 'package:test/test.dart';

void main() {
  test('dois mais dois é quatro', () {
    final resultado = 2 + 2;
    expect(resultado, equals(4));
  });
}
```

Execute:

```bash
$ dart test
```

Saída esperada:

```text
test/exemplo_test.dart: dois mais dois é quatro
  ok
```

## Organizando Testes em Espelho de lib/

Organize testes como você organiza o código:

```text
lib/
  modelos/
    jogador.dart
    inimigo.dart
  combate/
    combate.dart
  jogo/
    parseador.dart

test/
  modelos/
    jogador_test.dart
    inimigo_test.dart
  combate/
    combate_test.dart
  jogo/
    parseador_test.dart
```

Convenção: `lib/combate/combate.dart` → `test/combate/combate_test.dart` (snake_case para arquivos de teste)

## Testando uma Classe Simples: Jogador

```dart
// test/modelos/jogador_test.dart
import 'package:test/test.dart';
import 'package:masmorra_ascii/modelos/jogador.dart';

void main() {
  group('Jogador', () {
    late Jogador jogador;

    setUp(() {
      // Checkpoint: como uma fogueira em Dark Souls, mas sem Hollow.
      // Executado antes de cada teste
      jogador = Jogador(
        nome: 'Aragorn',
        hpMax: 50,
        ataque: 5,
      );
    });

    test('construir jogador com atributos', () {
      expect(jogador.nome, equals('Aragorn'));
      expect(jogador.hpMax, equals(50));
      expect(jogador.ataque, equals(5));
      expect(jogador.estaVivo, isTrue);
    });

    test('sofrer dano reduz HP', () {
      jogador.sofrerDano(10);
      expect(jogador.hpAtual, equals(40));
    });

    test('sofrer dano crítico mata', () {
      jogador.sofrerDano(100);
      expect(jogador.estaVivo, isFalse);
    });

    test('ganhar XP acumula total', () {
      jogador.ganharXP(50);
      expect(jogador.xp, equals(50));

      jogador.ganharXP(30);
      expect(jogador.xp, equals(80));
    });

    test('não pode ganhar XP negativo', () {
      jogador.ganharXP(-50);
      expect(jogador.xp, equals(0)); // Ignorado
    });
  });
}
```

Execute apenas este teste:

```bash
$ dart test test/modelos/jogador_test.dart
```

Saída esperada:

```text
test/modelos/jogador_test.dart:
  Jogador
    [ok] construir jogador com atributos
    [ok] sofrer dano reduz HP
    [ok] sofrer dano crítico mata
    [ok] ganhar XP acumula total
    [ok] não pode ganhar XP negativo

All tests passed!
```

## Matchers: Verificações Poderosas

`expect(atual, matcher)` verifica se `atual` corresponde ao matcher:

```dart
test('matchers comuns', () {
  // Igualdade
  expect(5, equals(5));
  expect('hello', equals('hello'));

  // Booleanos
  expect(true, isTrue);
  expect(false, isFalse);

  // Nulidade
  expect(null, isNull);
  expect('texto', isNotNull);

  // Tipo
  expect(5, isA<int>());
  expect('texto', isA<String>());

  // Listas
  expect([1, 2, 3], contains(2));
  expect([1, 2, 3], hasLength(3));

  // Exceções
  expect(
    () => throw FormatException('Erro!'),
    throwsA(isA<FormatException>()),
  );

  // Comparações
  expect(5, greaterThan(3));
  expect(2, lessThan(5));

  // Strings
  expect('hello', startsWith('he'));
  expect('hello', endsWith('lo'));

  // Negação
  expect(5, isNot(equals(3)));
});
```

## Testando Combate

```dart
// test/combate/combate_test.dart
import 'package:test/test.dart';
import 'package:masmorra_ascii/modelos/jogador.dart';
import 'package:masmorra_ascii/modelos/inimigo.dart';
import 'package:masmorra_ascii/sistemas/combate.dart';

void main() {
  group('Combate', () {
    late Jogador jogador;
    late Inimigo inimigo;
    late Combate combate;

    setUp(() {
      jogador = Jogador(nome: 'Herói', hpMax: 50, ataque: 10);
      inimigo = Inimigo(nome: 'Goblin', hpMax: 20, ataque: 3);
      combate = Combate(jogador: jogador, inimigo: inimigo);
    });

    test('jogador ataca e causa dano', () {
      final hpAntes = inimigo.hpAtual;
      combate.atacarInimigo();
      expect(inimigo.hpAtual, lessThan(hpAntes));
    });

    test('inimigo morre após dano suficiente', () {
      for (int i = 0; i < 3; i++) {
        combate.atacarInimigo();
      }
      expect(inimigo.estaVivo, isFalse);
    });

    test('jogador pode defender-se', () {
      final hpAntes = jogador.hpAtual;
      combate.defender();

      combate.ataqueInimigo();
      final danoSofrido = hpAntes - jogador.hpAtual;

      expect(danoSofrido, lessThan(inimigo.ataque));
    });

    test('combate termina quando inimigo morre', () {
      while (inimigo.estaVivo) {
        combate.atacarInimigo();
      }
      expect(combate.terminou, isTrue);
    });

    test('combate termina quando jogador morre', () {
      jogador.sofrerDano(jogador.hpMax - 1);

      for (int i = 0; i < 10; i++) {
        if (jogador.estaVivo) {
          combate.ataqueInimigo();
        }
      }
      expect(jogador.estaVivo, isFalse);
    });
  });
}
```

## Testando o Parseador com Diferentes Entradas

```dart
// test/jogo/parseador_test.dart
import 'package:test/test.dart';
import 'package:masmorra_ascii/jogo/parseador.dart';

void main() {
  group('Parseador', () {
    late Parseador parser;

    setUp(() {
      parser = Parseador();
    });

    test('parse movimento w', () {
      final cmd = parser.parse('w');
      expect(cmd, isA<CmdMover>());
    });

    test('parse movimento a', () {
      final cmd = parser.parse('a');
      expect(cmd, isA<CmdMover>());
    });

    test('parse sair', () {
      final cmd = parser.parse('sair');
      expect(cmd, isA<CmdSair>());
    });

    test('parse comando desconhecido', () {
      final cmd = parser.parse('xyz');
      expect(cmd, isA<CmdPadrao>());
    });

    test('parse insensível a maiúsculas', () {
      final cmd1 = parser.parse('W');
      final cmd2 = parser.parse('w');
      expect(
        cmd1.runtimeType,
        equals(cmd2.runtimeType),
      );
    });

    test('parse com espaços extras', () {
      final cmd = parser.parse('  w  ');
      expect(cmd, isA<CmdMover>());
    });
  });
}
```

## Mocks Manuais: Valores Previsíveis

Às vezes você precisa de aleatoriedade **previsível** para testar. Crie "fakes":

```dart
// test/suporte/aleatorio_falso.dart
import 'dart:math';

class AleatorioFalso implements Random {
  final List<int> valores;
  int _indice = 0;

  AleatorioFalso(this.valores);

  @override
  int nextInt(int max) => valores[_indice++ % valores.length] % max;

  @override
  double nextDouble() => valores[_indice++ % valores.length] / 100;

  @override
  bool nextBool() => valores[_indice++ % valores.length] % 2 == 0;

  // Métodos abstratos adicionais (implementação mínima)
  @override
  double nextDoubleInRange(double from, double to) {
    return from + (nextDouble() * (to - from));
  }

  @override
  int nextIntInRange(int from, int to) {
    return from + (nextInt(to - from + 1));
  }
}
```

Uso:

```dart
// test/jogo/lancador_test.dart
import 'package:test/test.dart';
import 'package:masmorra_ascii/jogo/lancador.dart';
import '../suporte/aleatorio_falso.dart';

void main() {
  group('Lancador', () {
    test('d6 com valores previsíveis', () {
      final fake = AleatorioFalso([2, 3, 4]);
      final lancador = Lancador(aleatorio: fake);

      expect(lancador.d6(), equals(3)); // 2 + 1
      expect(lancador.d6(), equals(4)); // 3 + 1
      expect(lancador.d6(), equals(5)); // 4 + 1
    });

    test('d20 máximo', () {
      final fake = AleatorioFalso([19]);
      final lancador = Lancador(aleatorio: fake);

      expect(lancador.d20(), equals(20));
    });

    test('d20 mínimo', () {
      final fake = AleatorioFalso([0]);
      final lancador = Lancador(aleatorio: fake);

      expect(lancador.d20(), equals(1));
    });
  });
}
```

Testes agora são **determinísticos**: sempre o mesmo resultado.

## Testando Distribuição (Em Média)

Às vezes você quer verificar que um sistema funciona corretamente em média:

```dart
// test/economia/tabelaDrop_test.dart
import 'package:test/test.dart';
import 'package:masmorra_ascii/economia/tabelaDrop.dart';

void main() {
  group('TabelaDrop', () {
    test('ouro distribui corretamente em média', () {
      final tabela = TabelaDrop();
      final drops = <int>[];

      // Rola 100 vezes
      for (int i = 0; i < 100; i++) {
        drops.add(tabela.rolarOuro());
      }

      // Verifica média
      final media = drops.reduce((a, b) => a + b) ~/ drops.length;
      expect(media, greaterThan(8));
      expect(media, lessThan(12));
    });

    test('loot raro aparece ocasionalmente', () {
      final tabela = TabelaDrop();
      final raridades = <String>[];

      for (int i = 0; i < 1000; i++) {
        raridades.add(tabela.rolarRaridade());
      }

      final rarasCount = raridades.where((r) => r == 'rara').length;
      expect(rarasCount, greaterThan(0));
      expect(rarasCount, lessThan(100));
    });
  });
}
```

## Executar Todos os Testes

Execute toda a suite:

```bash
$ dart test
```

Saída esperada:

```text
test/modelos/jogador_test.dart: Jogador
  [ok] construir jogador com atributos
  [ok] sofrer dano reduz HP
  [ok] sofrer dano crítico mata

test/combate/combate_test.dart: Combate
  [ok] jogador ataca e causa dano
  [ok] inimigo morre após dano suficiente

test/jogo/parseador_test.dart: Parseador
  [ok] parse movimento w
  [ok] parse sair

All tests passed! 15 tests in 0.2s
```

## Desafios da Masmorra

**Desafio 29.1. Seu Primeiro Escudo.** Testes são rede de segurança. Escreva o primeiro teste: uma classe simples como `Item` ou `Arma`. Teste cria instância, verifica atributos com `expect(item.nome, equals('Espada'))`, `expect(item.dano, equals(10))`. Use `group('Item', () { ... })` e `setUp()` para reutilizar. Execute `dart test` e veja verde. Agora você tem confiança de que Item não quebrou. Dica: um teste por funcionalidade.

**Desafio 29.2. Defendendo Mochila.** Escolha `Inventario` (classe que muda estado). Escreva 5 testes: (1) adicionar item aumenta tamanho, (2) remover diminui, (3) mochila cheia recusa novo item, (4) buscar por nome acha corretamente, (5) usar item (ex: poção) remove do inventário. Use `setUp()` que cria mochila fresca para cada teste. Execute; todos devem passar. Agora refatore `Inventario` com segurança: testes protegem você. Dica: cada teste deve caber em 5-10 linhas.

**Desafio 29.3. Erros Esperados.** Nem sempre sucesso é erro. Falhas controladas são comportamento. Teste 3 exceções: (1) acessar inventário em índice negativo lança exceção, (2) dividir HP por zero, (3) carregar arquivo inexistente. Use `expect(() => inventario[-1], throwsA(isA<RangeError>()))`. Teste que exceções são lançadas corretamente. Dica: exceções são comportamento de primeira classe que merecem testes.

**Desafio 29.4. RNG Determinístico.** Testes com `Random` real falham aleatoriamente; inútil. Crie `RandomFalso extends Random` que retorna valores fixos: próximo valor sempre 42, próximo sempre 0.5. Use em testes: com `RandomFalso`, tabelas de drops são previsíveis. Teste que `Rolador.rolar('d6', randomFalso)` sempre retorna mesmo resultado. Dica: fakes tornam testes determinísticos.

**Boss Final 29.5. Suite de Defesa.** Escolha classe complexa: `Inimigo` ou `Combate`. Escreva 9 testes: (1-5) casos normais (criar, atacar, levar dano, morrer, saudar), (6-7) extremos (HP 0, dano negativo), (8) exceção (dividir por zero), (9) com fake. Organize em `group()`, use `setUp()` compartilhado, execute `dart test`. Se todos verdes, suite protege você contra regressões. Refatore a classe com confiança. Dica: suite robusta = código que dura.

## Pergaminho do Capítulo

Você aprendeu a escrever testes que protegem seu código:

- `test()` para um teste simples
- `group()` para organizar testes relacionados
- `setUp()` para preparar dados antes de cada teste
- Matchers como `equals()`, `isTrue()`, `throws()` para verificações
- Fakes manuais para valores previsíveis
- Organização de testes em espelho de `lib/`
- `dart test` para executar toda a suite

Testes são investimento. Primeiro você escreve mais código (testes + implementação). Mas depois você refatora com confiança, debuga em segundos em vez de horas, e dorme sabendo que o código funciona. Um jogo com 30 funcionalidades e nenhum teste é improvável que seja mantido. Um com 5 funcionalidades e suite completa de testes é sólido.

::: dica
**Dica do Mestre:** Escreva testes **antes** de refatorar. Isso é chamado TDD (Test-Driven Development) em sua forma suave:

1. Escreva um teste que falha (Testar você deve)
2. Escreva código mínimo para passar (Não há tentativa de meias-medidas)
3. Refatore com segurança (testes protegem você)

Assim você tem confiança de que refatorações não quebraram nada. Cada teste que passa é um save point. Você pode caminhar pela caverna escura com segurança.
:::

## Próximo Capítulo

No Capítulo 30, o jogo ganha dimensão temporal. `async`, `await` e `Stream` permitirão operações assíncronas como leitura de arquivos, delays cinematográficos e sistemas de eventos reativos.
