# Capítulo 31 - Persistência em JSON

> *Um jogo é um computador que se lembra de você. A primeira sessão aprende. A segunda cresce. A terceira é lendário. Sem persistência, cada partida é amnésia: resetada ao desligar. Com persistência, é uma verdadeira campanha que atravessa semanas.*

O que acontece quando o herói precisa parar no meio da masmorra? Seu corpo cansado, seus olhos piscando. Em todo *roguelike* clássico, desde Rogue até NetHack, *save* e *load* são essenciais. Você não pode carregar o jogo na sessão seguinte como se nada tivesse acontecido. Precisa restaurar exatamente onde parou: a posição do herói, a saúde dos seus aliados, o inventário que carrega, o mapa que explorou.

Neste capítulo você vai aplicar o *async*/*await* que aprendeu no Capítulo 30 para salvar o estado do jogo em arquivo *JSON* e carregá-lo depois. A combinação de assincronismo (para não congelar a masmorra enquanto salva) com *serialização* (para converter objetos Dart em texto) é o que torna a persistência possível.

**Integração com Capítulo 30:** No capítulo anterior, aprendemos como usar `async`/`await` para operações de I/O não bloqueantes. Agora aplicamos esse conhecimento num caso prático: persistência de jogo. Este é um padrão que aparecerá em todos os próximos capítulos que precisam de estado persistente.

## dart:io: Lendo e Escrevendo Arquivos

A biblioteca `dart:io` é sua porta para o sistema de arquivos. Com ela, você lê, escreve, cria diretórios e gerencia arquivos. Essas operações são assincronas (não bloqueiam), então combinam perfeitamente com `async`/`await` do Capítulo 30.

### Ler um Arquivo

```dart
// lib/persistencia/leitor.dart
import 'dart:io';

Future<String> lerArquivo(String caminho) async {
  final arquivo = File(caminho);

  if (!arquivo.existsSync()) {
    throw FileSystemException('Não encontrado: $caminho');
  }

  return arquivo.readAsString(); // ← Retorna Future (não bloqueia)
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

**Saída esperada:**
```text
Lido: {"nome": "Aragorn", "hp": 42}
```

### Escrever um Arquivo

Escrever é similar: crie um `File`, chame `writeAsString()` com `await`, e o arquivo é criado (ou sobrescrito se existir).

```dart
// lib/persistencia/escritor.dart
Future<void> escreverArquivo(String caminho, String conteudo) async {
  final arquivo = File(caminho);
  await arquivo.writeAsString(conteudo); // ← Escreve assincronamente
  print('Escrito: $caminho');
}

// Usar:
void main() async {
  await escreverArquivo('dados.json', '{"nome": "Herói"}');
  print('Arquivo criado!');
}
```

**Saída esperada:**
```text
Escrito: dados.json
Arquivo criado!
```

### Criar Diretórios

Antes de salvar, você precisa garantir que o diretório existe. Use `Directory` para isso. Observe que `createSync()` é síncrono (criação de diretório é rápido), mas para ser consistente com `async/await`, considere usar `create()` com `await`.

```dart
// lib/persistencia/gerenciadorDiretorios.dart
import 'dart:io';

Future<void> criarDiretorios() async {
  final dir = Directory('salves');

  if (!dir.existsSync()) {
    // ← Cria se não existir (rápido, ok síncrono)
    dir.createSync(recursive: true);
  }
}

// Ou de forma assíncrona:
Future<void> criarDiretoriosAsync() async {
  final dir = Directory('salves');

  if (!await dir.exists()) {
    await dir.create(recursive: true); // ← Forma assíncrona
  }
}
```

## dart:convert: JSON

A biblioteca `dart:convert` fornece ferramentas para *serializar* (converter objetos em texto) e *desserializar* (converter texto em objetos). *JSON* é o formato universal: leve, legível e suportado por todas as linguagens.

**Por que JSON é melhor que alternatives:**
- *CSV*: Difícil com dados aninhados
- *XML*: Verboso, mais lento para parsear
- *Binary* (protobuf, etc): Mais rápido, mas menos legível e debugável
- *JSON*: Balanço perfeito: legível, estruturado, rápido

### Converter Dart para JSON

```dart
// lib/serializacao/exemplo.dart
import 'dart:convert';

final dados = {
  'nome': 'Aragorn',
  'hp': 45,
  'ataque': 7,
  'inventario': ['espada', 'poção'],
};

// ← Converter para JSON string
final jsonString = jsonEncode(dados);
print(jsonString);
```

**Saída esperada:**
```text
{"nome":"Aragorn","hp":45,"ataque":7,"inventario":["espada","poção"]}
```

Observe que `jsonEncode()` converte estruturas Dart em texto puro. Números, strings e listas são preservados. Você pode salvar `jsonString` num arquivo.

### Converter JSON para Dart

O inverso: leia um *JSON* string e converta para estrutura Dart.

```dart
// lib/serializacao/decodificador.dart
import 'dart:convert';

final jsonString = '{"nome":"Aragorn","hp":45}';

final dados = jsonDecode(jsonString); // ← Converte string para Map
print(dados['nome']); // ← "Aragorn"
print(dados['hp']); // ← 45
print(dados.runtimeType); // ← Map<String, dynamic>
```

**Saída esperada:**
```text
Aragorn
45
_InternalLinkedHashMap<String, dynamic>
```

Note que `jsonDecode()` retorna um `Map<String, dynamic>`: dinâmico porque pode conter qualquer tipo de valor.

### Tratamento de Erros

Três erros comuns ao trabalhar com *JSON*:

```dart
// Erro 1: JSON malformado
try {
  jsonDecode('{"nome": "Hero"'); // ← Falta fechar
} catch (e) {
  print('Parse error: $e'); // ← FormatException
}

// Erro 2: Tipo seguro (sempre faça cast)
final dados = jsonDecode('{"numero": 42}');
final resultado = dados['numero'] as int; // ← Safe cast (valida tipo)

// Erro 3: Chave inexistente
final valor = dados['chaveQueNaoExiste']; // ← null
// ← null coalescing
final valor2 = dados['chaveQueNaoExiste'] ?? 'padrão';
```

**Saída esperada:**
```text
Parse error: FormatException: Unexpected end of input (at character 15)
null
padrão
```

Sempre use `try/catch` ao fazer *parse* de *JSON*, pois dados corrompidos lançam `FormatException`.

## Padrão toJson() / fromJson()

Este é o padrão de ouro em Dart para *serialização*: toda classe que precisa ser salva tem dois métodos:
- `toJson()`: Converte a instância em `Map<String, dynamic>` (pronta para `jsonEncode()`)
- `fromJson()`: Factory que reconstrói a instância de um `Map<String, dynamic>`

É simples, poderoso e reutilizável.

### Jogador: Serialização Completa

Vamos serializar um `Jogador` completo: atributos básicos, inventário (lista de itens), e posição. Observe como `toJson()` também serializa objetos aninhados (`inventario`, `posicao`), criando uma estrutura *JSON* profunda que `jsonEncode()` consegue transformar em string.

```dart
// lib/modelos/jogador.dart
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

  // ← Converter para JSON (estrutura para arquivo)
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'hpMax': hpMax,
      'hpAtual': hpAtual,
      'ataque': ataque,
      'nivel': nivel,
      'xp': xp,
      // ← Items também serializam
      'inventario': inventario.map((i) => i.toJson()).toList(),
      'posicao': {
        'x': posicao.dx,
        'y': posicao.dy,
      },
    };
  }

  // ← Converter de JSON (reconstruir do arquivo)
  factory Jogador.fromJson(Map<String, dynamic> map) {
    return Jogador(
      nome: map['nome'] as String,
      hpMax: map['hpMax'] as int,
      ataque: map['ataque'] as int,
      nivel: map['nivel'] as int,
      xp: map['xp'] as int,
      inventario: (map['inventario'] as List)
          .map((i) => Item.fromJson(i as Map<String, dynamic>))
          .toList(), // ← Items também desserializam
      posicao: Offset(
        (map['posicao']['x'] as num).toDouble(),
        (map['posicao']['y'] as num).toDouble(),
      ),
    );
  }
}
```

**Saída esperada (após toJson()):**
```json
{
  "nome": "Aragorn",
  "hpMax": 100,
  "hpAtual": 100,
  "ataque": 8,
  "nivel": 5,
  "xp": 1250,
  "inventario": [
    {"nome": "Espada de Elendil", "quantidade": 1},
    {"nome": "Poção de Cura", "quantidade": 3}
  ],
  "posicao": {"x": 10, "y": 15}
}
```

### Item: Serialização Simples

Items são mais simples que jogadores. Observe que `toJson()` pode ser uma arrow function se for curta.

```dart
// lib/modelos/item.dart
class Item {
  String nome;
  int quantidade;

  Item({required this.nome, required this.quantidade});

  // ← Serializar (arrow function)
  Map<String, dynamic> toJson() => {
    'nome': nome,
    'quantidade': quantidade,
  };

  // ← Desserializar
  factory Item.fromJson(Map<String, dynamic> map) {
    return Item(
      nome: map['nome'] as String,
      quantidade: map['quantidade'] as int,
    );
  }
}
```

**Saída esperada (após toJson()):**
```json
{"nome": "Poção de Cura", "quantidade": 5}
```

## Serializar Todo o Estado do Jogo

Para salvar um jogo inteiro, você precisa de uma classe que agregue todo o estado: jogador, mapa, inimigos, etc. Esta é a "foto" do jogo num momento específico.

```dart
// lib/jogo/estadoJogo.dart
class EstadoJogo {
  late Jogador jogador;
  late MapaMasmorra mapa;
  late List<Inimigo> entidades;
  int andarAtual = 0;
  DateTime ultimoSalva = DateTime.now();

  // ← Serializar tudo
  Map<String, dynamic> toJson() {
    return {
      'jogador': jogador.toJson(), // ← Jogador serializa a si mesmo
      'mapa': mapa.toJson(), // ← Mapa serializa a si mesmo
      // ← Lista de inimigos
      'entidades': entidades.map((e) => e.toJson()).toList(),
      'andarAtual': andarAtual,
      // ← DateTime como string ISO
      'ultimoSalva': ultimoSalva.toIso8601String(),
    };
  }

  // ← Desserializar tudo
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
      map['ultimoSalva'] as String, // ← Reconstrói DateTime de string
    );
    return estado;
  }
}
```

Este padrão funciona recursivamente: `EstadoJogo` chama `toJson()` de seus membros, que chamam `toJson()` de seus membros, e assim por diante. No final, você tem uma estrutura de *JSON* profunda.

### MapaMasmorra: Serializar Tiles

Serializar um mapa é complexo: temos uma matriz 2D de tiles. Não podemos salvar objetos `Tile` diretamente; convertemos para strings (nomes dos tipos) e reconvertemos.

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

  // ← Serializar: converte tiles em strings
  Map<String, dynamic> toJson() {
    return {
      'largura': largura,
      'altura': altura,
      'tiles': tiles.map((linha) =>
          // ← TipoTile como string
          linha.map((tile) => tile.tipo.toString()).toList()
      ).toList(),
    };
  }

  // ← Desserializar: reconstrói tiles de strings
  factory MapaMasmorra.fromJson(Map<String, dynamic> map) {
    final largura = map['largura'] as int;
    final altura = map['altura'] as int;
    final mapa = MapaMasmorra(largura, altura);

    final tileStrings = map['tiles'] as List;
    for (int y = 0; y < altura; y++) {
      for (int x = 0; x < largura; x++) {
        final tipoStr = (tileStrings[y] as List)[x] as String;
        // ← Encontra enum pelo nome
        mapa.tiles[y][x] = Tile(tipo: TipoTile.values
          .firstWhere((t) => t.toString() == tipoStr));
      }
    }
    return mapa;
  }
}
```

Observe a estratégia: enums são serializados como strings, e ao desserializar, encontramos o enum novamente usando `.values.firstWhere()`.

## GerenciadorSalve: Múltiplos Slots

Um jogo típico permite vários *save slots*: save 1, save 2, save 3. Cada um é um arquivo separado. `GerenciadorSalve` centraliza toda a lógica: salvar, carregar, listar. É uma camada de abstração que o resto do jogo usa sem conhecer detalhes do disco.

```dart
// lib/persistencia/gerenciadorSalve.dart
import 'dart:convert';
import 'dart:io';

class GerenciadorSalve {
  static const String dirSalves = 'salves'; // ← Diretório de saves
  static const int numSlots = 5; // ← 5 slots disponíveis

  static Future<void> inicializar() async {
    final dir = Directory(dirSalves);
    if (!dir.existsSync()) {
      // ← Cria diretório se não existir
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
    final json = jsonEncode(estado.toJson()); // ← Serializa para string

    try {
      await arquivo.writeAsString(json); // ← Escreve em disco
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
      return null; // ← Nenhum salve neste slot
    }

    try {
      final json = await arquivo.readAsString(); // ← Lê de disco
      // ← Parse JSON
      final map = jsonDecode(json) as Map<String, dynamic>;
      return EstadoJogo.fromJson(map); // ← Reconstrói estado
    } catch (e) {
      print('Erro ao carregar: $e');
      return null; // ← Arquivo corrompido
    }
  }

  // ← Listar todos os saves com timestamps
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
          slots.add(null); // ← Arquivo corrompido
        }
      } else {
        slots.add(null); // ← Vazio
      }
    }

    return slots;
  }
}
```

**Saída esperada (após salvar):**
```text
Jogo salvo no slot 0
Jogo salvo no slot 1
```

**Saída esperada (listarSalves()):**
```text
[2026-04-04 10:30:45, 2026-04-03 18:15:20, null, null, null]
```

## Auto-Save Após Cada Andar

Um *auto-save* garante que o progresso do jogador não é perdido. No slot 0, você mantém uma "foto" automática do jogo que atualiza a cada turno. Se o jogo crasha, quando o jogador reabre, pode recuperar de onde parou.

```dart
// lib/jogo/dungeonCrawl.dart
class DungeonCrawl {
  late EstadoJogo estado;
  static const int slotAutoSalve = 0; // ← Slot dedicado para auto-save

  void executar() async {
    await GerenciadorSalve.inicializar();

    while (estado.jogador.estaVivo) {
      renderizar();
      final cmd = processarInput();
      executarComando(cmd);

    // ← Auto-salve a cada turno (importante: jogo continua responsivo)
     
      await _autoSalvar();
    }
  }

  Future<void> _autoSalvar() async {
    estado.ultimoSalva = DateTime.now();
    // ← Salva assincronamente
    await GerenciadorSalve.salvar(estado, slotAutoSalve);
  }
}
```

Observe que `_autoSalvar()` é `async` e `await`. Assim, se o disco for lento, o jogo não congela esperando—continua rodando enquanto o save acontece em *background*.

**Saída esperada (durante jogo):**
```text
Turno 1: Herói se move
[auto-save em background]
Turno 2: Herói ataca Goblin
[auto-save em background]
```

## Carregar Save ao Iniciar

Este é o fluxo completo: menu inicial, escolha do jogador, carregamento ou novo jogo. Integra tudo que aprendemos: *async/await*, persistência, *JSON*, tratamento de erros.

```dart
// lib/main.dart
import 'dart:io';

void main() async {
  await GerenciadorSalve.inicializar(); // ← Prepara diretório

  // ← MENU
  print('Bem-vindo ao Masmorra!');
  print('1. Novo jogo');
  print('2. Carregar salve');

  stdout.write('> ');
  final opcao = stdin.readLineSync() ?? '1';

  EstadoJogo estado;

  if (opcao == '1') {
    // ← NOVO JOGO
    estado = criarNovoJogo();
  } else {
    // ← CARREGAR JOGO
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

  // ← INICIAR JOGO
  final game = DungeonCrawl()..estado = estado;
  game.executar();
}
```

**Saída esperada (novo jogo):**
```text
Bem-vindo ao Masmorra!
1. Novo jogo
2. Carregar salve
> 1
[jogo começa]
```

**Saída esperada (carregar jogo):**
```text
Bem-vindo ao Masmorra!
1. Novo jogo
2. Carregar salve
> 2

Slots disponíveis:
  0. 2026-04-04 10:30:45.123456
  1. 2026-04-03 18:15:20.654321
  2. [Vazio]
  3. [Vazio]
  4. [Vazio]
Qual slot? > 0
[jogo continua do turno salvo]
```

## Por que não usar banco de dados?

Você poderia usar SQLite ou Firebase em vez de *JSON* em arquivo. Cada abordagem tem trade-offs:

**JSON em arquivo (escolha neste capítulo):**
- ✓ Simples, sem dependências externas
- ✓ Arquivo legível, fácil debugar
- ✓ Rápido para pequenos saves (<10MB)
- ✗ Não escala para dados gigantes
- ✗ Sem queries sofisticadas
- ✗ Sem índices (busca é O(n))

**SQLite:**
- ✓ Rápido para muitos dados
- ✓ Queries sofisticadas
- ✓ Índices para busca O(1)
- ✗ Mais complexo
- ✗ Requer biblioteca externa

**Firebase:**
- ✓ Multiplayer sincronizado
- ✓ Backup automático na nuvem
- ✗ Requer conexão
- ✗ Dados compartilhados (privacidade)

Para um *roguelike* offline, *JSON* em arquivo é perfeito. Quando você precisar de multiplayer ou dados massivos, migre para banco de dados.

## Desafios da Masmorra

**Desafio 31.1. Seu Primeiro Await.** I/O é lento—disco, rede. Dart não congela esperando. Escreva função que simula carregamento lento: `Future<String> carregarHistoria() async { await Future.delayed(Duration(seconds: 1)); return 'Epopeia carregada'; }`. Chame do `main()` com `async`: `print(await carregarHistoria())`. Note que programa continua responsivo. Dica: `async` + `await` é a base de I/O moderno.

**Desafio 31.2. Serializar e Reconstruir.** Escolha `Item` ou `Arma`. Implemente `Map<String, dynamic> toJson()`: retorna mapa com todas propriedades. E `factory Item.fromJson(Map m)` que reconstrói. Teste: `var item = Item('Espada', 10); var map = item.toJson(); var item2 = Item.fromJson(map); expect(item2.nome, equals(item.nome));`. Agora Item pode viajar como JSON. Dica: toJson/fromJson é padrão em Dart.

**Desafio 31.3. Salve em Disco.** JSON em memória é inútil—precisa ir pro disco. Escreva `Item` para arquivo JSON: (1) crie Item, (2) chame `jsonEncode(item.toJson())`, (3) escreva em arquivo com `await File('item.json').writeAsString(json)`, (4) leia de volta, (5) valide que dados são iguais. Arquivo persiste após fechar programa. Dica: sempre use `await` em operações de arquivo.

**Desafio 31.4. Múltiplos Saves.** Implemente `GerenciadorSalve` com 3 slots: `salvar(estado, slot)` serializa para `save_$slot.json`, `carregar(slot)` desserializa. Trate arquivo faltando (retorna null). Teste: (1) salve estado em slot 1, (2) mude estado, (3) carregue slot 1, deve ser igual ao original. Dica: try/catch captura erros de disco.

**Boss Final 31.5. Auto-Save Mágico.** Você está explorando andar 3, de repente fecha o jogo. Quando reabre, está no mesmo lugar. Integre auto-save: (1) no main, crie `GerenciadorSalve`, (2) em cada turno/comando do jogo, `await gerenciador.salvar(estadoJogo, 999)` (slot auto), (3) ao iniciar, pergunte "Recuperar save anterior?", (4) teste: jogue 10 turnos, fecha, reabre, deve estar no turno 10. Progresso é sagrado. Dica: `main()` deve ser `async`, salve após cada ação importante.

## Pergaminho do Capítulo

Você aprendeu persistência completa:

- *Future<T>* é uma promessa de um valor futuro
- *async* marca função como assíncrona (pode usar *await*)
- *await* aguarda uma *Future*
- *dart:io* para ler/escrever arquivos
- *dart:convert* para *JSON* encode/decode
- *toJson()*/*fromJson()* para *serialização*
- *GerenciadorSalve* gerencia múltiplos slots
- *Auto-save* garante progresso não é perdido
- Tratamento de erros para arquivos corrompidos

Um jogo sem persistência é um jogo que o jogador não pode realmente vencer: toda sessão é resetada. Com persistência, é uma campanha real que atravessa semanas.

::: dica
**Dica do Mestre:** Sempre trate erros em I/O assíncrono. Arquivo pode estar corrompido, disco cheio, permissões insuficientes. Use `try`/`catch`:

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

## Próximo Capítulo

No Capítulo 32, organizaremos o projeto para escala profissional. Estrutura de pastas, imports consistentes, `pubspec.yaml` e `analysis_options.yaml` são a base de qualquer projeto Dart sério.
