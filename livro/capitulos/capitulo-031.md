# Capítulo 31 - Persistência em JSON

> *Um jogo é um computador que se lembra de você. A primeira sessão aprende. A segunda cresce. A terceira é lendário. Sem persistência, cada partida é amnésia: resetada ao desligar. Com persistência, é uma verdadeira campanha que atravessa semanas.*

O que acontece quando o herói precisa parar no meio da masmorra? Seu corpo cansado, seus olhos piscando. Em todo roguelike clássico, desde Rogue até NetHack, save e load são essenciais. Você não pode carregar o jogo na sessão seguinte como se nada tivesse acontecido. Precisa restaurar exatamente onde parou: a posição do herói, a saúde dos seus aliados, o inventário que carrega, o mapa que explorou.

Neste capítulo você vai aplicar o `async`/`await` que aprendeu no Capítulo 30 para salvar o estado do jogo em arquivo JSON e carregá-lo depois. A combinação de assincronismo (para não congelar a masmorra enquanto salva) com serialização (para converter objetos Dart em texto) é o que torna a persistência possível.

## dart:io: Lendo e Escrevendo Arquivos

### Ler um Arquivo

```dart
import 'dart:io';

Future<String> lerArquivo(String caminho) async {
  final arquivo = File(caminho);

  if (!arquivo.existsSync()) {
    throw FileSystemException('Não encontrado: $caminho');
  }

  return arquivo.readAsString(); // Retorna Future
}

// Usar:
void main() async {
  try {
    final conteudo = await lerArquivo('dados.json');
    print('Lido: $conteudo');
  } catch (e) {
    print('Erro: $e');
  }
}
```

### Escrever um Arquivo

```dart
Future<void> escreverArquivo(String caminho, String conteudo) async {
  final arquivo = File(caminho);
  await arquivo.writeAsString(conteudo);
  print('Escrito: $caminho');
}

// Usar:
await escreverArquivo('dados.json', '{"nome": "Herói"}');
```

### Criar Diretórios

```dart
import 'dart:io';

Future<void> criarDiretorios() async {
  final dir = Directory('salves');

  if (!dir.existsSync()) {
    dir.createSync(recursive: true); // Cria se não existir
  }
}
```

## dart:convert: JSON

### Converter Dart para JSON

```dart
import 'dart:convert';

final dados = {
  'nome': 'Aragorn',
  'hp': 45,
  'ataque': 7,
  'inventario': ['espada', 'poção'],
};

// Converter para JSON string
final jsonString = jsonEncode(dados);
print(jsonString);
// Saída: {"nome":"Aragorn","hp":45,"ataque":7,"inventario":["espada","poção"]}
```

### Converter JSON para Dart

```dart
import 'dart:convert';

final jsonString = '{"nome":"Aragorn","hp":45}';

final dados = jsonDecode(jsonString);
print(dados['nome']); // "Aragorn"
print(dados['hp']); // 45
```

### Tratamento de Erros

```dart
// Erro 1: JSON malformado
try {
  jsonDecode('{"nome": "Hero"'); // Falta fechar
} catch (e) {
  print('Parse error: $e'); // FormatException
}

// Erro 2: Tipo seguro
final dados = jsonDecode('{"numero": 42}');
final resultado = dados['numero'] as int; // Safe cast

// Erro 3: Chave inexistente
final valor = dados['chaveQueNaoExiste']; // null
final valor2 = dados['chaveQueNaoExiste'] ?? 'padrão';
```

## Padrão toJson() / fromJson()

Toda classe serializável tem `toJson()` e `fromJson()`.

### Jogador: Serialização Completa

```dart
// lib/model/jogador.dart

class Jogador {
  String nome;
  int hpMax;
  int hpAtual;
  int ataque;
  int nivel;
  int xp;
  List<Item> inventario;
  Offset posicao;

  Jogador({
    required this.nome,
    required this.hpMax,
    this.ataque = 5,
    this.nivel = 1,
    this.xp = 0,
    this.inventario = const [],
    this.posicao = const Offset(0, 0),
  }) {
    hpAtual = hpMax;
  }

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'hpMax': hpMax,
      'hpAtual': hpAtual,
      'ataque': ataque,
      'nivel': nivel,
      'xp': xp,
      'inventario': inventario.map((i) => i.toJson()).toList(),
      'posicao': {
        'x': posicao.dx,
        'y': posicao.dy,
      },
    };
  }

  // Converter de JSON
  factory Jogador.fromJson(Map<String, dynamic> map) {
    return Jogador(
      nome: map['nome'] as String,
      hpMax: map['hpMax'] as int,
      ataque: map['ataque'] as int,
      nivel: map['nivel'] as int,
      xp: map['xp'] as int,
      inventario: (map['inventario'] as List)
          .map((i) => Item.fromJson(i as Map<String, dynamic>))
          .toList(),
      posicao: Offset(
        (map['posicao']['x'] as num).toDouble(),
        (map['posicao']['y'] as num).toDouble(),
      ),
    );
  }
}
```

### Item: Serialização Simples

```dart
// lib/model/item.dart

class Item {
  String nome;
  int quantidade;

  Item({required this.nome, required this.quantidade});

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'quantidade': quantidade,
  };

  factory Item.fromJson(Map<String, dynamic> map) {
    return Item(
      nome: map['nome'] as String,
      quantidade: map['quantidade'] as int,
    );
  }
}
```

## Serializar Todo o Estado do Jogo

```dart
// lib/jogo/estadoJogo.dart

class EstadoJogo {
  late Jogador jogador;
  late MapaMasmorra mapa;
  late List<Inimigo> entidades;
  int andarAtual = 0;
  DateTime ultimoSalva = DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'jogador': jogador.toJson(),
      'mapa': mapa.toJson(),
      'entidades': entidades.map((e) => e.toJson()).toList(),
      'andarAtual': andarAtual,
      'ultimoSalva': ultimoSalva.toIso8601String(),
    };
  }

  factory EstadoJogo.fromJson(Map<String, dynamic> map) {
    final estado = EstadoJogo();
    estado.jogador = Jogador.fromJson(
      map['jogador'] as Map<String, dynamic>,
    );
    estado.mapa = MapaMasmorra.fromJson(
      map['mapa'] as Map<String, dynamic>,
    );
    estado.entidades = (map['entidades'] as List)
        .map((e) => Inimigo.fromJson(e as Map<String, dynamic>))
        .toList();
    estado.andarAtual = map['andarAtual'] as int;
    estado.ultimoSalva = DateTime.parse(
      map['ultimoSalva'] as String,
    );
    return estado;
  }
}
```

### MapaMasmorra: Serializar Tiles

```dart
// lib/mundo/mapaMasmorra.dart

class MapaMasmorra {
  int largura;
  int altura;
  List<List<Tile>> tiles;

  MapaMasmorra(this.largura, this.altura)
    : tiles = List.generate(altura, (_) =>
        List.generate(largura, (_) => Tile.vazio())
      );

  Map<String, dynamic> toJson() {
    return {
      'largura': largura,
      'altura': altura,
      'tiles': tiles.map((linha) =>
          linha.map((tile) => tile.tipo.toString()).toList()
      ).toList(),
    };
  }

  factory MapaMasmorra.fromJson(Map<String, dynamic> map) {
    final largura = map['largura'] as int;
    final altura = map['altura'] as int;
    final mapa = MapaMasmorra(largura, altura);

    final tileStrings = map['tiles'] as List;
    for (int y = 0; y < altura; y++) {
      for (int x = 0; x < largura; x++) {
        final tipoStr = (tileStrings[y] as List)[x] as String;
        mapa.tiles[y][x] = Tile(tipo: TipoTile.values
          .firstWhere((t) => t.toString() == tipoStr));
      }
    }
    return mapa;
  }
}
```

## GerenciadorSalve: Múltiplos Slots

```dart
// lib/persistencia/gerenciadorSalve.dart

import 'dart:convert';
import 'dart:io';

class GerenciadorSalve {
  static const String dirSalves = 'salves';
  static const int numSlots = 5;

  static Future<void> inicializar() async {
    final dir = Directory(dirSalves);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  static Future<void> salvar(
    EstadoJogo estado,
    int slot,
  ) async {
    if (slot < 0 || slot >= numSlots) {
      throw ArgumentError('Slot inválido: $slot');
    }

    final arquivo = File('$dirSalves/salve_$slot.json');
    final json = jsonEncode(estado.toJson());

    try {
      await arquivo.writeAsString(json);
      print('Jogo salvo no slot $slot');
    } catch (e) {
      print('Erro ao salvar: $e');
      rethrow;
    }
  }

  static Future<EstadoJogo?> carregar(int slot) async {
    if (slot < 0 || slot >= numSlots) {
      throw ArgumentError('Slot inválido: $slot');
    }

    final arquivo = File('$dirSalves/salve_$slot.json');

    if (!arquivo.existsSync()) {
      return null; // Nenhum salve neste slot
    }

    try {
      final json = await arquivo.readAsString();
      final map = jsonDecode(json) as Map<String, dynamic>;
      return EstadoJogo.fromJson(map);
    } catch (e) {
      print('Erro ao carregar: $e');
      return null; // Arquivo corrompido
    }
  }

  static Future<List<DateTime?>> listarSalves() async {
    final slots = <DateTime?>[];

    for (int i = 0; i < numSlots; i++) {
      final arquivo = File('$dirSalves/salve_$i.json');

      if (arquivo.existsSync()) {
        try {
          final json = await arquivo.readAsString();
          final map = jsonDecode(json) as Map<String, dynamic>;
          final timestamp = DateTime.parse(
            map['ultimoSalva'] as String,
          );
          slots.add(timestamp);
        } catch (_) {
          slots.add(null); // Arquivo corrompido
        }
      } else {
        slots.add(null); // Vazio
      }
    }

    return slots;
  }
}
```

## Auto-Save Após Cada Andar

```dart
// lib/jogo/dungeonCrawl.dart

class DungeonCrawl {
  late EstadoJogo estado;
  static const int slotAutoSalve = 0;

  void executar() async {
    await GerenciadorSalve.inicializar();

    while (estado.jogador.estaVivo) {
      renderizar();
      final cmd = processarInput();
      executarComando(cmd);

      // Auto-salve a cada turno
      await _autoSalvar();
    }
  }

  Future<void> _autoSalvar() async {
    estado.ultimoSalva = DateTime.now();
    await GerenciadorSalve.salvar(estado, slotAutoSalve);
  }
}
```

## Carregar Save ao Iniciar

```dart
import 'dart:io';

// lib/jogo/menu.dart

void main() async {
  await GerenciadorSalve.inicializar();

  // Mostrar menu
  print('Bem-vindo ao Masmorra!');
  print('1. Novo jogo');
  print('2. Carregar salve');

  stdout.write('> ');
  final opcao = stdin.readLineSync() ?? '1';

  EstadoJogo estado;

  if (opcao == '1') {
    estado = criarNovoJogo();
  } else {
    print('\nSlots disponíveis:');
    final salves = await GerenciadorSalve.listarSalves();

    for (int i = 0; i < salves.length; i++) {
      if (salves[i] != null) {
        print('  $i. ${salves[i]}');
      } else {
        print('  $i. [Vazio]');
      }
    }

    stdout.write('Qual slot? > ');
    final slot = int.parse(stdin.readLineSync() ?? '0');

    final carregado = await GerenciadorSalve.carregar(slot);
    if (carregado == null) {
      print('Erro ao carregar. Novo jogo...');
      estado = criarNovoJogo();
    } else {
      estado = carregado;
    }
  }

  final game = DungeonCrawl()..estado = estado;
  game.executar();
}
```

## Desafios da Masmorra

**Desafio 31.1. Seu Primeiro Await.** I/O é lento—disco, rede. Dart não congela esperando. Escreva função que simula carregamento lento: `Future<String> carregarHistoria() async { await Future.delayed(Duration(seconds: 1)); return 'Epopeia carregada'; }`. Chame do `main()` com `async`: `print(await carregarHistoria())`. Note que programa continua responsivo. Dica: `async` + `await` é a base de I/O moderno.

**Desafio 31.2. Serializar e Reconstruir.** Escolha `Item` ou `Arma`. Implemente `Map<String, dynamic> toJson()`: retorna mapa com todas propriedades. E `factory Item.fromJson(Map m)` que reconstrói. Teste: `var item = Item('Espada', 10); var map = item.toJson(); var item2 = Item.fromJson(map); expect(item2.nome, equals(item.nome));`. Agora Item pode viajar como JSON. Dica: toJson/fromJson é padrão em Dart.

**Desafio 31.3. Salve em Disco.** JSON em memória é inútil—precisa ir pro disco. Escreva `Item` para arquivo JSON: (1) crie Item, (2) chame `jsonEncode(item.toJson())`, (3) escreva em arquivo com `await File('item.json').writeAsString(json)`, (4) leia de volta, (5) valide que dados são iguais. Arquivo persiste após fechar programa. Dica: sempre use `await` em operações de arquivo.

**Desafio 31.4. Múltiplos Saves.** Implemente `GerenciadorSalve` com 3 slots: `salvar(estado, slot)` serializa para `save_$slot.json`, `carregar(slot)` desserializa. Trate arquivo faltando (retorna null). Teste: (1) salve estado em slot 1, (2) mude estado, (3) carregue slot 1, deve ser igual ao original. Dica: try/catch captura erros de disco.

**Boss Final 31.5. Auto-Save Mágico.** Você está explorando andar 3, de repente fecha o jogo. Quando reabre, está no mesmo lugar. Integre auto-save: (1) no main, crie `GerenciadorSalve`, (2) em cada turno/comando do jogo, `await gerenciador.salvar(estadoJogo, 999)` (slot auto), (3) ao iniciar, pergunte "Recuperar save anterior?", (4) teste: jogue 10 turnos, fecha, reabre, deve estar no turno 10. Progresso é sagrado. Dica: `main()` deve ser `async`, salve após cada ação importante.

## Pergaminho do Capítulo

Você aprendeu persistência completa:

- `Future<T>` é uma promessa de um valor futuro
- `async` marca função como assíncrona (pode usar `await`)
- `await` aguarda uma Future
- `dart:io` para ler/escrever arquivos
- `dart:convert` para JSON encode/decode
- `toJson()/fromJson()` para serialização
- `GerenciadorSalve` gerencia múltiplos slots
- Auto-save garante progresso não é perdido
- Tratamento de erros para arquivos corrompidos

Um jogo sem persistência é um jogo que o jogador não pode realmente vencer: toda sessão é resetada. Com persistência, é uma campanha real que atravessa semanas.

::: dica
**Dica do Mestre:** Sempre trate erros em I/O assíncrono. Arquivo pode estar corrompido, disco cheio, permissões insuficientes. Use `try/catch`:

```dart
Future<EstadoJogo?> carregar(int slot) async {
  try {
    final arquivo = File('salve_$slot.json');
    final json = await arquivo.readAsString();
    return EstadoJogo.fromJson(jsonDecode(json));
  } on FileSystemException catch (e) {
    print('Erro de disco: $e');
    return null;
  } on FormatException catch (e) {
    print('Arquivo corrompido: $e');
    return null;
  } catch (e) {
    print('Erro desconhecido: $e');
    return null;
  }
}
```
:::

No próximo capítulo você vai organizar ainda mais: projeto com `lib/`, `test/` e `pubspec.yaml`. Persistência é apenas metade da história. Organização é a outra metade.
