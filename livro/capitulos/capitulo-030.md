# Capítulo 30 - Async, Await e o Tempo na Masmorra

> *Na masmorra, o tempo não para. Enquanto o herói abre um baú, o mundo continua: tochas crepitam, inimigos patrulham, armadilhas rearmam. Se o herói congelasse esperando o baú abrir, seria emboscado. Assincronismo é a arte de fazer coisas sem parar o mundo. Em Dart, `async` e `await` são os feitiços que permitem isso.*

Até agora, todo o código do jogo executou de forma síncrona: uma instrução após a outra, sem esperar por nada externo. Mas o mundo real é diferente. Salvar um arquivo em disco leva tempo. Ler dados da rede leva tempo. Carregar um save game leva tempo. Se o seu jogo congelar durante essas operações, o jogador vê uma tela morta — e isso é inaceitável.

Neste capítulo você vai aprender os fundamentos da programação assíncrona em Dart: `Future`, `async`, `await`, tratamento de erros assíncronos e `Stream`. No próximo capítulo, você vai aplicar tudo isso para implementar save/load com JSON.

## O Problema: Código que Congela

Imagine que seu jogo precisa salvar o progresso. A versão ingênua faz isso de forma síncrona:

```dart
import 'dart:io';

void salvarJogoSync(String dados) {
  final arquivo = File('save.json');
  arquivo.writeAsStringSync(dados); // Bloqueia tudo!
  print('Salvo!');
}

void main() {
  print('Jogando...');
  salvarJogoSync('{"hp": 42}'); // Congela por 50-500ms
  print('Continuando...'); // Só executa depois do disco terminar
}
```

O problema? `writeAsStringSync` bloqueia o programa inteiro. Nada mais executa até o disco terminar de escrever. Se o disco for lento, se o arquivo for grande, se o sistema operacional estiver ocupado — o jogador vê o jogo travar. Em uma aplicação com interface gráfica (como Flutter), isso significaria uma tela congelada.

## Future: Uma Promessa de Valor

A solução do Dart é o tipo `Future<T>`. Uma Future é uma promessa: "vou entregar um valor do tipo `T` eventualmente, mas não agora".

```dart
// Future<String> = "prometo entregar uma String no futuro"
Future<String> lerArquivo() {
  return File('dados.txt').readAsString();
}
```

Quando você chama `lerArquivo()`, o retorno é imediato — mas o valor ainda não existe. O Dart inicia a operação de I/O em background e retorna uma Future que será resolvida quando a leitura terminar.

### Três estados de uma Future

Uma Future pode estar em um de três estados:

```text
╔═══════════════╗     resolve      ╔═══════════════╗
║   Pendente    ║ ───────────────> ║  Completada   ║
║  (esperando)  ║                  ║  (com valor)  ║
╚═══════════════╝                  ╚═══════════════╝
        │
        │ erro
        ▼
╔═══════════════╗
║    Falhou     ║
║  (com erro)   ║
╚═══════════════╝
```

É como abrir um baú na masmorra: você inicia a ação (pendente), o baú abre e revela um item (completada com valor), ou está trancado e explode (falhou com erro).

## async e await: Os Feitiços do Tempo

### async: Marca a Função como Assíncrona

```dart
// Sem async: retorna String diretamente
String saudacao() {
  return 'Olá, aventureiro!';
}

// Com async: retorna Future<String>
Future<String> saudacaoAsync() async {
  return 'Olá, aventureiro!'; // Dart empacota em Future automaticamente
}
```

Uma função `async` sempre retorna uma `Future`. Dentro dela, você pode usar `await`.

### await: Pausa Sem Congelar

```dart
Future<void> exemploAwait() async {
  print('Início');

  // await pausa ESTA função, mas não congela o programa
  await Future.delayed(Duration(seconds: 2));

  print('Fim (2 segundos depois)');
}
```

`await` é o feitiço que diz: "espere esta Future resolver, mas deixe o resto do mundo continuar". É a diferença entre o herói parado esperando o baú abrir (síncrono) e o herói fazendo outra coisa enquanto o baú abre sozinho (assíncrono).

### Sem await vs. Com await

```dart
Future<int> calcularLento() async {
  await Future.delayed(Duration(seconds: 1));
  return 42;
}

void main() async {
  // SEM await: obtemos a Future (a promessa), não o valor
  final promessa = calcularLento();
  print(promessa); // Instance of 'Future<int>'

  // COM await: obtemos o valor real
  final resultado = await promessa;
  print(resultado); // 42
}
```

## Encadeando Futures

Operações assíncronas frequentemente dependem umas das outras. Com `await`, o encadeamento é natural:

```dart
Future<Jogador> carregarJogador() async {
  // Cada passo espera o anterior terminar
  final jsonString = await File('save.json').readAsString();
  final mapa = jsonDecode(jsonString) as Map<String, dynamic>;
  final jogador = Jogador.fromJson(mapa);

  print('Jogador ${jogador.nome} carregado!');
  return jogador;
}
```

### Executando Futures em Paralelo

Às vezes, operações são independentes e podem rodar ao mesmo tempo:

```dart
Future<void> carregarRecursos() async {
  // RUIM: sequencial (2 segundos total)
  final mapa = await carregarMapa();       // 1 segundo
  final inimigos = await carregarInimigos(); // 1 segundo

  // BOM: paralelo (1 segundo total)
  final resultados = await Future.wait([
    carregarMapa(),
    carregarInimigos(),
  ]);
  final mapa = resultados[0] as MapaMasmorra;
  final inimigos = resultados[1] as List<Inimigo>;
}
```

`Future.wait` é como mandar dois exploradores por caminhos diferentes ao mesmo tempo — ambos voltam, e você continua quando o mais lento terminar.

## Tratamento de Erros Assíncronos

### try/catch com async

Erros em código assíncrono são capturados da mesma forma que em código síncrono — com `try`/`catch`:

```dart
Future<String> lerArquivoSeguro(String caminho) async {
  try {
    final arquivo = File(caminho);
    if (!await arquivo.exists()) {
      throw FileSystemException('Arquivo não encontrado: $caminho');
    }
    return await arquivo.readAsString();
  } on FileSystemException catch (e) {
    print('Erro de arquivo: ${e.message}');
    return '{}'; // Retorna JSON vazio como fallback
  } catch (e) {
    print('Erro inesperado: $e');
    rethrow; // Propaga erros que não sabemos tratar
  }
}
```

### Timeouts

Operações assíncronas podem travar. Use `timeout` para limitar a espera:

```dart
Future<String> lerComTimeout(String caminho) async {
  try {
    return await File(caminho)
        .readAsString()
        .timeout(Duration(seconds: 5));
  } on TimeoutException {
    print('Leitura demorou demais!');
    return '{}';
  }
}
```

É como dar ao herói um limite de tempo para abrir o baú — se demorar demais, desiste e segue em frente.

## Stream: Fluxo Contínuo de Eventos

Uma `Future` entrega um único valor no futuro. Uma `Stream` entrega múltiplos valores ao longo do tempo. É a diferença entre receber uma carta (Future) e ouvir rádio (Stream).

### Por que Streams importam no jogo?

Mais adiante, no Capítulo 35, quando implementarmos o Observer pattern, Streams serão a espinha dorsal: eventos de combate, morte de inimigos, coleta de itens — tudo fluindo como uma Stream que qualquer sistema pode observar.

```dart
import 'dart:async';

// StreamController cria e controla uma Stream
final controlador = StreamController<String>();

// Enviar eventos (como um rádio transmitindo)
controlador.add('Jogador atacou!');
controlador.add('Inimigo morreu!');
controlador.add('Item coletado!');

// Ouvir eventos (como um receptor sintonizado)
controlador.stream.listen((evento) {
  print('Evento: $evento');
});
```

### Aplicação: Bus de Eventos do Jogo

```dart
import 'dart:async';

/// Tipos de evento do jogo
enum TipoEvento { combate, morte, item, nivel, save }

/// Um evento com tipo e dados
class EventoJogo {
  final TipoEvento tipo;
  final String mensagem;
  final DateTime timestamp;

  EventoJogo(this.tipo, this.mensagem)
      : timestamp = DateTime.now();

  @override
  String toString() => '[$tipo] $mensagem';
}

/// Bus central de eventos — qualquer sistema pode publicar e ouvir
class BusEventos {
  final _controlador = StreamController<EventoJogo>.broadcast();

  /// Stream que qualquer sistema pode ouvir
  Stream<EventoJogo> get eventos => _controlador.stream;

  /// Publica um evento no bus
  void publicar(EventoJogo evento) {
    _controlador.add(evento);
  }

  /// Filtra eventos por tipo
  Stream<EventoJogo> filtrar(TipoEvento tipo) {
    return eventos.where((e) => e.tipo == tipo);
  }

  /// Libera recursos quando o jogo termina
  void dispose() {
    _controlador.close();
  }
}
```

### Usando o Bus no Jogo

```dart
void main() {
  final bus = BusEventos();

  // Sistema de log ouve TODOS os eventos
  bus.eventos.listen((e) => print('[LOG] $e'));

  // Sistema de XP ouve apenas mortes
  bus.filtrar(TipoEvento.morte).listen((e) {
    print('[XP] +50 pontos de experiência!');
  });

  // Sistema de som ouve apenas combate
  bus.filtrar(TipoEvento.combate).listen((e) {
    print('[SOM] *clang* Espadas se chocam!');
  });

  // Simulação de jogo
  bus.publicar(EventoJogo(TipoEvento.combate, 'Herói ataca Goblin'));
  bus.publicar(EventoJogo(TipoEvento.morte, 'Goblin derrotado'));
  bus.publicar(EventoJogo(TipoEvento.item, 'Poção coletada'));

  bus.dispose();
}
```

Saída:

```text
[LOG] [TipoEvento.combate] Herói ataca Goblin
[SOM] *clang* Espadas se chocam!
[LOG] [TipoEvento.morte] Goblin derrotado
[XP] +50 pontos de experiência!
[LOG] [TipoEvento.item] Poção coletada
```

Cada sistema ouve apenas o que precisa. O bus não sabe quem está ouvindo. Os ouvintes não sabem quem publica. Desacoplamento total.

## Resumo dos Conceitos

```text
┌─────────────────────────────────────────────────────┐
│                  ASYNC EM DART                      │
├──────────────┬──────────────────────────────────────┤
│ Future<T>    │ Promessa de valor único no futuro    │
│ async        │ Marca função como assíncrona         │
│ await        │ Pausa a função, não o programa       │
│ Future.wait  │ Executa Futures em paralelo          │
│ Stream<T>    │ Fluxo contínuo de valores            │
│ listen()     │ Inscreve ouvinte em uma Stream       │
│ where()      │ Filtra eventos da Stream             │
│ broadcast()  │ Stream com múltiplos ouvintes        │
│ try/catch    │ Captura erros assíncronos            │
│ timeout      │ Limita tempo de espera               │
└──────────────┴──────────────────────────────────────┘
```

## Boss Final: Sistema de Eventos Completo

Implemente o `BusEventos` no seu jogo:

1. Crie a classe `EventoJogo` com tipo, mensagem e timestamp.
2. Crie o `BusEventos` com StreamController broadcast.
3. Inscreva três sistemas: log (todos os eventos), XP (mortes), e inventário (itens).
4. Simule uma sequência de combate: ataque, defesa, morte, loot.
5. Verifique que cada sistema reagiu corretamente.

**Bônus:** adicione um método `ultimosEventos(int n)` que retorna os últimos N eventos do bus (dica: mantenha uma lista interna).

No próximo capítulo, você vai usar `async`/`await` para salvar e carregar o estado completo do jogo em JSON — persistência real que sobrevive ao fechar o terminal.
