# Apêndice A: Referência Rápida de Dart {.unnumbered}

Este apêndice reúne os principais conceitos de Dart usados ao longo do livro. Use como consulta rápida quando precisar lembrar de uma sintaxe ou padrão.

## Tipos básicos

```dart
int vida = 100;
double dano = 7.5;
String nome = 'Guerreiro';
bool vivo = true;
```

## Null safety

```dart
String? alvo;            // pode ser nulo
String nome = 'Herói';   // nunca nulo
alvo?.length;            // acesso seguro
alvo ?? 'ninguém';       // valor padrão se nulo
alvo ??= 'padrão';      // atribui se nulo
```

## Coleções

```dart
// Lista
List<String> itens = ['espada', 'poção', 'escudo'];
itens.add('anel');
itens.removeAt(0);

// Map
Map<String, int> precos = {'espada': 50, 'poção': 20};
precos['escudo'] = 80;

// Set
Set<String> visitados = {'sala1', 'sala2'};
visitados.add('sala3');
```

## Funções

```dart
// Função com retorno
int calcularDano(int forca, int nivel) {
  return forca * nivel;
}

// Arrow function
int dobro(int x) => x * 2;

// Função com parâmetros nomeados
void criar({required String nome, int vida = 100}) {
  print('$nome tem $vida HP');
}
```

## Classes

```dart
class Jogador {
  final String nome;
  int _vida;

  Jogador(this.nome, this._vida);

  // Named constructor
  Jogador.iniciante(this.nome) : _vida = 100;

  // Getter
  int get vida => _vida;

  // Método
  void receberDano(int dano) {
    _vida = (_vida - dano).clamp(0, _vida);
  }

  @override
  String toString() => '$nome (HP: $_vida)';
}
```

## Herança e classes abstratas

```dart
abstract class Inimigo {
  String get nome;
  int get vida;
  void agir(Jogador alvo);
}

class Zumbi extends Inimigo {
  @override
  String get nome => 'Zumbi';

  @override
  int get vida => 30;

  @override
  void agir(Jogador alvo) {
    // anda aleatoriamente
  }
}
```

## Mixins

```dart
mixin Combatente {
  int atacar(int forca) => forca + Random().nextInt(6);
}

mixin Curavel {
  void curar(int quantidade) { /* ... */ }
}

class Guerreiro extends Jogador with Combatente, Curavel {
  Guerreiro(String nome) : super(nome, 100);
}
```

## Enums (Dart 3)

```dart
enum Direcao {
  norte(0, -1),
  sul(0, 1),
  leste(1, 0),
  oeste(-1, 0);

  final int dx;
  final int dy;
  const Direcao(this.dx, this.dy);
}
```

## Sealed classes e pattern matching

```dart
sealed class ComandoJogo {}
class CmdMover extends ComandoJogo { final Direcao dir; CmdMover(this.dir); }
class CmdAtacar extends ComandoJogo {}
class CmdUsarItem extends ComandoJogo { final Item item; CmdUsarItem(this.item); }

// Switch exaustivo
switch (comando) {
  case CmdMover(:final dir):
    jogador.mover(dir);
  case CmdAtacar():
    iniciarCombate();
  case CmdUsarItem(:final item):
    jogador.usar(item);
}
```

## Async e await

```dart
Future<String> carregarSave(String caminho) async {
  final arquivo = File(caminho);
  if (await arquivo.exists()) {
    return await arquivo.readAsString();
  }
  return '{}';
}

// Uso
void main() async {
  final dados = await carregarSave('save.json');
  print(dados);
}
```

## JSON

```dart
import 'dart:convert';

// Serializar
String json = jsonEncode({'nome': 'Herói', 'vida': 100});

// Deserializar
Map<String, dynamic> mapa = jsonDecode(json);
```

## Testes

```dart
import 'package:test/test.dart';

void main() {
  group('Jogador', () {
    test('receber dano reduz vida', () {
      final jogador = Jogador('Teste', 100);
      jogador.receberDano(30);
      expect(jogador.vida, equals(70));
    });

    test('vida não fica negativa', () {
      final jogador = Jogador('Teste', 10);
      jogador.receberDano(50);
      expect(jogador.vida, equals(0));
    });
  });
}
```

## Padrões de projeto usados no livro

Strategy: cada inimigo tem uma estratégia de IA que decide seu comportamento. Permite trocar o comportamento em tempo de execução.

Command: ações do jogo (mover, atacar, usar item) são objetos com `executar()` e `desfazer()`. Permite histórico e undo.

Factory: criação centralizada de inimigos e itens por tipo e andar. Facilita balanceamento e extensão.

Observer: sistema de eventos com `Stream`. Quando algo acontece no jogo, vários sistemas são notificados (log, UI, estatísticas).

State: máquinas de estado para comportamento de inimigos (patrulha, alerta, perseguição, ataque, fuga) e fases de boss.

## Para Explorar Depois

O calabouço vai mais fundo. Aqui estão os skills para a próxima aventura—recursos avançados que transformam seus programas Dart de "funcional" para "obra-prima".

### Streams: Fluxos de Dados Assíncronos

Streams são tubos por onde dados fluem continuamente. Perfeito para eventos em tempo real, atualizações de sensores, ou qualquer coisa que acontece ao longo do tempo. Use `Stream`, `StreamController`, ou `async*` com `yield` para criar seus próprios.

```dart
Stream<int> contadorStream() async* {
  for (int i = 0; i < 5; i++) {
    yield i;
    await Future.delayed(Duration(seconds: 1));
  }
}
```

### Isolates: Concorrência de Verdade

Isolates são "threads" do Dart—mundos paralelos que executam código pesado sem travar a UI. Diferente de threads convencionais, eles não compartilham memória, o que evita deadlocks e race conditions. Use para cálculos pesados ou processamento de dados.

```dart
void computarFatorialPesado() async {
  final resultado = await compute(fatorial, 1000000);
}

int fatorial(int n) => n <= 1 ? 1 : n * fatorial(n - 1);
```

### typedef: Apelidos para Tipos

Typedefs criam aliases para funções e tipos complexos, melhorando legibilidade do código. Essencial para callbacks complicados.

```dart
typedef Comparador = int Function(dynamic a, dynamic b);
typedef DadosJogo = ({String nome, int vida});

Comparador minhaComparacao = (a, b) => a.toString().compareTo(b.toString());
```

### Extensions: Superpoderes para Tipos Existentes

Extensions adicionam métodos a classes já existentes—String, List, num—sem herança ou modificação. Transforme a forma como você trabalha com tipos padrão.

```dart
extension on String {
  String gritarEmMaisculas() => toUpperCase();
}

print('herói'.gritarEmMaisculas()); // HERÓI
```

### Mixins Avançados: O Poder da Composição

Mixins com restrições (`on`) garantem que suas misturas só funcionam em classes específicas. Prefira mixins a herança múltipla—são mais seguros e flexíveis.

```dart
mixin Curioso on Jogador {
  void investigar() => print('$nome investigou a sala');
}

class Paladino extends Jogador with Curioso {
  Paladino(String nome) : super(nome, 150);
}
```

## Recursos úteis

- Documentação oficial: `dart.dev`
- Pacotes: `pub.dev`
- Guia de estilo: `dart.dev/effective-dart`
- Flutter: `flutter.dev`
