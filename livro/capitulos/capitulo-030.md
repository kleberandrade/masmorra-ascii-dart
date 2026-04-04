# Capítulo 30 - Async, Await e o Tempo na Masmorra

> *Na masmorra, o tempo não para. Enquanto o herói abre um baú, o mundo continua: tochas crepitam, inimigos patrulham, armadilhas rearmam. Se o herói congelasse esperando o baú abrir, seria emboscado. Assincronismo é a arte de fazer coisas sem parar o mundo. Em Dart, `async` e `await` são os feitiços que permitem isso.*

Até agora, todo o código do jogo executou de forma síncrona: uma instrução após a outra, sem esperar por nada externo. Mas o mundo real é diferente. Salvar um arquivo em disco leva tempo. Ler dados da rede leva tempo. Carregar um save game leva tempo. Se o seu jogo congelar durante essas operações, o jogador vê uma tela morta. E isso é inaceitável.

Neste capítulo você vai aprender os fundamentos da programação assíncrona em Dart: *Future*, *async*, *await*, tratamento de erros assíncronos e *Stream*. No próximo capítulo, você vai aplicar tudo isso para implementar *save*/*load* com *JSON*.

## O Problema: Código que Congela

Imagine que seu jogo precisa salvar o progresso. Todo sistema de jogo moderno enfrenta esse desafio: operações de I/O (entrada/saída) como salvar em disco, carregar da rede ou acessar banco de dados são lentas. Se seu código as executa de forma síncrona, o jogo todo trava até terminar. A masmorra congela, o jogador vê uma tela morta. Isso é inaceitável em qualquer aplicação interativa.

A versão ingênua faz isso de forma síncrona (bloqueante):

```dart
// lib/persistencia/salvador.dart
import 'dart:io';

void salvarJogoSync(String dados) {
  final arquivo = File('save.json');
  // ← Bloqueia TUDO até disco terminar
  arquivo.writeAsStringSync(dados);
  print('Salvo!');
}

void main() {
  print('Jogando...');
  salvarJogoSync('{"hp": 42}'); // ← Congela aqui por 50-500ms
  print('Continuando...'); // ← Só executa depois do disco terminar
}
```

**Saída esperada:**
```text
Jogando...
[pausa de ~200ms - programa congelado]
Salvo!
Continuando...
```

O problema? `writeAsStringSync` bloqueia o programa inteiro. Nada mais executa até o disco terminar de escrever. Se o disco for lento, se o arquivo for grande, se o sistema operacional estiver ocupado, o jogador vê o jogo travar. Em uma aplicação com interface gráfica (como Flutter), isso significaria uma tela congelada.

## Future: Uma Promessa de Valor

A solução do Dart é o tipo `Future<T>`. Uma *Future* é uma promessa: "vou entregar um valor do tipo `T` eventualmente, mas não agora". É como ir a um restaurante, fazer um pedido, e receber um número ("sua mesa estará pronta em 15 minutos"). O número é a *Future*; você não quer esperar parado, então sai e faz outra coisa. Quando seu número é chamado, a refeição está pronta.

Uma *Future* não bloqueia sua execução. Ela é entregue imediatamente, mesmo que o valor ainda não exista. Dart inicia a operação de I/O em *background* e a resolve quando terminar.

```dart
// lib/persistencia/leitor.dart
// Future<String> = "prometo entregar uma String no futuro"
Future<String> lerArquivo() {
  return File('dados.txt').readAsString(); // ← Retorna IMEDIATAMENTE
}

void main() {
  final promessa = lerArquivo();
  print(promessa); // Instance of 'Future<String>'
  print('Continuo enquanto arquivo é lido em background!');
}
```

Quando você chama `lerArquivo()`, o retorno é imediato. Mas o valor ainda não existe. O Dart inicia a operação de I/O em *background* e retorna uma *Future* que será resolvida quando a leitura terminar.

**Saída esperada:**
```text
Instance of 'Future<String>'
Continuo enquanto arquivo é lido em background!
```

### Três estados de uma Future

Uma Future pode estar em um de três estados:

```text
┌─────────────────┐      resolve      ┌──────────────────┐
│   Pendente      │ ─────────────────> │  Completada      │
│  (esperando)    │                    │  (com valor)     │
└─────────────────┘                    └──────────────────┘
        │
        │ erro
        ▼
┌──────────────────┐
│    Falhou        │
│  (com erro)      │
└──────────────────┘
```

É como abrir um baú na masmorra: você inicia a ação (pendente), o baú abre e revela um item (completada com valor), ou está trancado e explode (falhou com erro).

## async e await: Os Feitiços do Tempo

### async: Marca a Função como Assíncrona

A palavra-chave `async` transforma uma função comum em uma função assíncrona. Toda função `async` automaticamente retorna uma `Future`, mesmo que você escreva `return valor`. É como prometer a alguém: "vou fazer isso, mas não tenho a resposta ainda". Dentro de uma função `async`, você pode usar `await` para pausar *apenas essa função*, deixando o resto do programa continuar.

```dart
// lib/ui/saudacao.dart
// Sem async: retorna String diretamente
String saudacao() {
  return 'Olá, aventureiro!';
}

// Com async: retorna Future<String> automaticamente
Future<String> saudacaoAsync() async {
  // ← Dart empacota em Future automaticamente
  return 'Olá, aventureiro!';
}

void main() async {
  final msg = await saudacao(); // Erro! String não é Future
  final msg2 = await saudacaoAsync(); // OK! Obtém a String da Future
  print(msg2);
}
```

Uma função `async` sempre retorna uma `Future`. Dentro dela, você pode usar `await`.

**Saída esperada:**
```text
Olá, aventureiro!
```

### await: Pausa Sem Congelar

A palavra-chave `await` é o complemento perfeito para `async`. Ela pausa a execução *dessa função* até a *Future* resolver, mas deixa o resto do programa continuar. É a diferença entre congelamento e pausa elegante.

```dart
// lib/exemplo/async_demo.dart
Future<void> exemploAwait() async {
  print('Início');

  // ← await pausa ESTA função, mas não congela o programa todo
  await Future.delayed(Duration(seconds: 2));

  print('Fim (2 segundos depois)');
}

void main() async {
  exemploAwait(); // Começa, mas não espera!
  print('Enquanto isso no main...');

  await Future.delayed(Duration(seconds: 3)); // Espera aqui no main
  print('Main terminou');
}
```

`await` é o feitiço que diz: "aguarde esta *Future* resolver, mas deixe o resto do mundo continuar". É a diferença entre o herói parado esperando o baú abrir (síncrono) e o herói fazendo outra coisa enquanto o baú abre sozinho (assíncrono).

**Saída esperada:**
```text
Início
Enquanto isso no main...
Fim (2 segundos depois)
Main terminou
```

### Sem await vs. Com await

A diferença entre `await` e não usar `await` é fundamental. Sem `await`, você obtém a *Future* (a promessa), não o valor. Com `await`, você aguarda e obtém o valor real.

```dart
// lib/exemplo/calculo.dart
Future<int> calcularLento() async {
  await Future.delayed(Duration(seconds: 1));
  return 42;
}

void main() async {
  // SEM await: obtemos a Future (a promessa), não o valor
  final promessa = calcularLento();
  print(promessa); // ← Instance of 'Future<int>'

  // COM await: obtemos o valor real
  // ← Aguarda 1 segundo, depois obtém 42
  final resultado = await promessa;
  print(resultado); // ← 42
}
```

**Saída esperada:**
```text
Instance of 'Future<int>'
42
```

## Encadeando Futures

Operações assíncronas frequentemente dependem umas das outras. Uma leitura de arquivo precisa terminar antes de você poder fazer *parse* do JSON. Com `await`, o encadeamento é natural e legível: cada linha aguarda a anterior, sem *callbacks* aninhadas.

```dart
// lib/persistencia/carregador.dart
import 'dart:convert';
import 'dart:io';

Future<Jogador> carregarJogador() async {
  // Cada passo aguarda o anterior terminar
  // ← Lê arquivo
  final jsonString = await File('save.json').readAsString();
  // ← Parse JSON
  final mapa = jsonDecode(jsonString) as Map<String, dynamic>;
  final jogador = Jogador.fromJson(mapa); // ← Constrói objeto

  print('Jogador ${jogador.nome} carregado!');
  return jogador;
}

// Usar:
void main() async {
  final heroi = await carregarJogador();
  print('Bem-vindo, ${heroi.nome}!');
}
```

**Saída esperada:**
```text
Jogador Aragorn carregado!
Bem-vindo, Aragorn!
```

### Executando Futures em Paralelo

Às vezes, operações são independentes e podem rodar ao mesmo tempo. Se você as coloca em sequência com `await` individual, elas rodam uma após a outra (sequencial). Isso é ineficiente. A solução é `Future.wait`, que inicia múltiplas *Futures* simultaneamente.

```dart
// lib/jogo/carregador.dart
Future<void> carregarRecursos() async {
  // RUIM: sequencial (2 segundos total)
  final mapa = await carregarMapa();         // ← 1 segundo
  final inimigos = await carregarInimigos(); // ← +1 segundo = 2 total

  // BOM: paralelo (1 segundo total, ambas rodando juntas)
  final resultados = await Future.wait([
    carregarMapa(),          // ← 1 segundo
    carregarInimigos(),      // ← 1 segundo (ao mesmo tempo)
  ]);
  final mapa = resultados[0] as MapaMasmorra;
  final inimigos = resultados[1] as List<Inimigo>;
}
```

`Future.wait` é como mandar dois exploradores por caminhos diferentes ao mesmo tempo. Ambos caminham em paralelo, e você continua quando o mais lento terminar. Sem `Future.wait`, você espera o primeiro terminar antes de iniciar o segundo (sequencial). A diferença é exponencial em jogos com muitos recursos.

**Saída esperada (tempo real):**
```text
[sequencial: 2 segundos]
Mapa carregado!
Inimigos carregados!

[paralelo: 1 segundo]
Mapa e inimigos carregados simultaneamente!
```

## Tratamento de Erros Assíncronos

### try/catch/finally com async

Erros em código assíncrono são capturados da mesma forma que em código síncrono: com `try`/`catch`/`finally`. A grande diferença é que você pode `await` dentro de um bloco `try`, e se a *Future* resolver com erro, o `catch` captura imediatamente.

A cláusula `finally` executa **sempre**, independentemente de sucesso ou erro, e é perfeita para limpeza: fechar recursos, liberar memória, atualizar estado. No contexto de jogos, `finally` garante que o estado do jogo não fica corrompido mesmo que uma operação falhe pela metade.

**Por que try/catch/finally é essencial em assincronismo:** Operações assincronas podem falhar de formas inesperadas. Um arquivo pode estar corrompido, o disco cheio, as permissões negadas. Sem tratamento robusto, essas falhas deixam o jogo em estado indefinido. Com `finally`, você garante que sempre haja limpeza.

```dart
// lib/persistencia/leitorSeguro.dart
Future<String> lerArquivoSeguro(String caminho) async {
  try {
    final arquivo = File(caminho);
    if (!await arquivo.exists()) {
      throw FileSystemException('Arquivo não encontrado: $caminho');
    }
    // ← Pode falhar (disco cheio, permissão negada)
    return await arquivo.readAsString();
  } on FileSystemException catch (e) {
    // ← Captura erros de FILE SYSTEM especificamente
    print('Erro de arquivo: ${e.message}');
    return '{}'; // ← Fallback: retorna JSON vazio
  } catch (e) {
    // ← Captura qualquer outro erro
    print('Erro inesperado: $e');
    rethrow; // ← Propaga erros que não sabemos tratar
  } finally {
    // ← SEMPRE executa, sucesso ou erro
    print('Leitura de arquivo concluída (com sucesso ou erro).');
  }
}
```

**Saída esperada (arquivo existente):**
```text
Leitura de arquivo concluída (com sucesso ou erro).
[conteúdo do arquivo]
```

**Saída esperada (arquivo não encontrado):**
```text
Erro de arquivo: Arquivo não encontrado: save.json
Leitura de arquivo concluída (com sucesso ou erro).
{}
```

### Exceções Customizadas

Para diferenciar erros específicos do seu jogo, crie classes de exceção customizadas. Uma exceção customizada comunica claramente o tipo de problema. "O arquivo de save está corrompido" é muito diferente de "permissão negada", e cada um merece tratamento diferente. Com exceções customizadas, seu código sabe exatamente como reagir a cada cenário.

```dart
// lib/excecoes/persistencia.dart
/// Exceção base para erros de persistência
class PersistenciaExcecao implements Exception {
  final String mensagem;
  PersistenciaExcecao(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Arquivo de save corrompido ou incompatível
class ArquivoCorruptidoExcecao extends PersistenciaExcecao {
  ArquivoCorruptidoExcecao(String details)
      : super('Save corrompido: $details');
}

/// Permissão insuficiente para ler/escrever
class PermissaoNegadaExcecao extends PersistenciaExcecao {
  PermissaoNegadaExcecao(String caminho)
      : super('Sem permissão para acessar: $caminho');
}

/// Disco cheio ou sem espaço para salvar
class EspacoDiscoInsuficienteExcecao extends PersistenciaExcecao {
  EspacoDiscoInsuficienteExcecao()
      : super('Espaço em disco insuficiente para salvar o jogo');
}
```

### Quando Capturar vs Relançar

A regra é simples: **capture se pode tratar, relance se não pode**. Se você tenta ler um save e o arquivo não existe, isso é um erro tratável (cria um novo jogo). Mas se o disco está cheio, não há salvação no nível local. Relance para a camada superior decidir (talvez avisar o jogador). Essa divisão de responsabilidades mantém seu código limpo: cada camada trata apenas o que consegue resolver.

```dart
// lib/persistencia/carregadorSave.dart
Future<Jogador> carregarSave(String caminhoSave) async {
  try {
    final arquivo = File(caminhoSave);
    // ← Pode falhar (arquivo não existe)
    final json = await arquivo.readAsString();
    final mapa = jsonDecode(json); // ← Pode falhar (JSON inválido)
    return Jogador.fromJson(mapa); // ← Pode falhar (schema errado)

  } on FileSystemException catch (e) {
    // ← Arquivo não existe ou permissão negada
    if (e.osError?.errorCode == 2) {
      // ← Código 2 = arquivo não encontrado (POSIX, tratável)
      print('Save não encontrado. Iniciando novo jogo...');
      return Jogador.novo(); // ← Fallback: novo jogo
    } else {
      // ← Permissão negada ou outro erro de I/O (não tratável aqui)
      rethrow; // ← Deixa a camada superior tratar
    }

  } on FormatException catch (e) {
    // ← JSON inválido = save corrompido (erro específico)
    throw ArquivoCorruptidoExcecao('JSON inválido: ${e.message}');

  } finally {
    // ← SEMPRE executa
    print('Finalização de carregamento do save.');
  }
}
```

**Saída esperada (save encontrado e válido):**
```text
Finalização de carregamento do save.
[Jogador carregado com sucesso]
```

**Saída esperada (save não encontrado):**
```text
Save não encontrado. Iniciando novo jogo...
Finalização de carregamento do save.
[Novo jogador criado]
```

### Exemplo Prático: Salvar e Carregar Save Game

Agora vamos montar um exemplo completo que encadeia carregamento, processamento e salvamento de forma robusta. Este é o padrão que você usará em qualquer jogo: carregar (se existir), jogar, salvar ao sair. Cada etapa tem seu próprio tratamento de erro.

```dart
// lib/jogo/ciclo.dart
Future<void> executarCicloJogo(String caminhoSave) async {
  Jogador jogador;

  // ← FASE 1: CARREGAR
  try {
    print('Carregando save...');
    jogador = await carregarSave(caminhoSave);
    print('Save carregado: ${jogador.nome} no nível ${jogador.nivel}.');
  } on ArquivoCorruptidoExcecao catch (e) {
    // ← Arquivo corrompido é tratável
    print('ERRO: $e');
    print('Iniciando novo jogo em vez disso.');
    jogador = Jogador.novo();
  } on PersistenciaExcecao catch (e) {
    // ← Outros erros são críticos
    print('ERRO CRÍTICO: $e');
    print('Não é possível continuar. Encerrando.');
    rethrow;
  }

  // ← FASE 2: JOGAR
  print('Bem-vindo, ${jogador.nome}!');
  // ... loop de jogo aqui ...

  // ← FASE 3: SALVAR AO SAIR
  try {
    print('Salvando jogo...');
    await salvarJogo(jogador, caminhoSave);
    print('Jogo salvo com sucesso!');
  } on EspacoDiscoInsuficienteExcecao catch (e) {
    // ← Aviso ao jogador
    print('AVISO: $e');
    print('O jogo pode não ter sido salvo completamente.');
  } on PersistenciaExcecao catch (e) {
    // ← Log de erro
    print('ERRO ao salvar: $e');
  }
}

// lib/persistencia/salvador.dart
Future<void> salvarJogo(Jogador jogador, String caminho) async {
  try {
    final arquivo = File(caminho);
    // ← O save é real. Ao contrário do bolo.
    final json = jsonEncode(jogador.toJson());
    await arquivo.writeAsString(json);
  } on FileSystemException catch (e) {
    if (e.osError?.errorCode == 28) {
      // ← Código 28 = No space left on device (disco cheio)
      throw EspacoDiscoInsuficienteExcecao();
    } else if (e.osError?.errorCode == 13) {
      // ← Código 13 = Permission denied (permissão negada)
      throw PermissaoNegadaExcecao(caminho);
    }
    rethrow;
  }
}
```

**Saída esperada (sucesso):**
```text
Carregando save...
Save carregado: Aragorn no nível 5.
Bem-vindo, Aragorn!
[jogo roda...]
Salvando jogo...
Jogo salvo com sucesso!
```

**Saída esperada (save corrompido):**
```text
Carregando save...
ERRO: Save corrompido: JSON inválido
Iniciando novo jogo em vez disso.
Bem-vindo, Novo Herói!
[jogo roda...]
Salvando jogo...
Jogo salvo com sucesso!
```

Observe a estratégia: **carregamento** em um bloco `try` separado com tratamento de erros conhecidos. **Salvamento** em outro bloco que valida condições específicas do SO. Cada fase tem seu próprio escopo de erro. O resultado é um fluxo robusto onde nenhuma situação deixa o jogo em estado indefinido.

### Timeouts

Operações assíncronas podem travar infinitamente se algo der errado (rede lenta, disco preso, deadlock). Use `timeout` para limitar a espera. É como dar ao herói um limite de tempo para abrir o baú: se demorar demais, desiste e segue em frente.

```dart
// lib/persistencia/leitorComTimeout.dart
Future<String> lerComTimeout(String caminho) async {
  try {
    return await File(caminho)
        .readAsString()
        .timeout(Duration(seconds: 5)); // ← Cancela se demorar >5s
  } on TimeoutException {
    // ← Timeout disparou
    print('Leitura demorou demais!');
    return '{}'; // ← Fallback
  }
}

// Usar:
void main() async {
  final dados = await lerComTimeout('save.json');
  print('Dados: $dados');
}
```

**Saída esperada (arquivo rápido):**
```text
Dados: {"nome": "Herói"}
```

**Saída esperada (arquivo muito lento):**
```text
Leitura demorou demais!
Dados: {}
```

## Stream: Fluxo Contínuo de Eventos

Uma `Future<T>` entrega um único valor no futuro. Uma `Stream<T>` entrega múltiplos valores ao longo do tempo. É a diferença entre receber uma carta (você abre uma vez) e ouvir rádio (você ouve continuamente).

**Por que *Streams* Importam no Jogo:**

Mais adiante, no Capítulo 35, quando implementarmos o padrão Observer, *Streams* serão a espinha dorsal: eventos de combate, morte de inimigos, coleta de itens. Tudo fluindo como uma *Stream* que qualquer sistema pode observar e reagir. Em vez de ter um sistema central que conhece todos os outros, cada sistema se inscreve numa *Stream* e reage independentemente. Desacoplamento total.

```dart
// lib/eventos/stream_demo.dart
import 'dart:async';

// ← StreamController cria e controla uma Stream
final controlador = StreamController<String>();

// ← Enviar eventos (como um rádio transmitindo)
controlador.add('Jogador atacou!');
controlador.add('Inimigo morreu!');
controlador.add('Item coletado!');

// ← Ouvir eventos (como um receptor sintonizado)
controlador.stream.listen((evento) {
  print('Evento: $evento');
});

controlador.close(); // ← Fecha a stream (limpeza)
```

**Saída esperada:**
```text
Evento: Jogador atacou!
Evento: Inimigo morreu!
Evento: Item coletado!
```

### Aplicação: Bus de Eventos do Jogo

Um *bus de eventos* é um padrão de desacoplamento total. Em vez de sistemas chamarem uns aos outros diretamente (acoplamento), todos se comunicam através de eventos numa *Stream*. O sistema de combate publica "Inimigo morreu", o sistema de XP ouve "morte" e reage, o sistema de som ouve "morte" e toca um som. Ninguém conhece ninguém.

```dart
// lib/eventos/busEventos.dart
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

/// Bus central de eventos: qualquer sistema pode publicar e ouvir
class BusEventos {
  // ← .broadcast() permite múltiplos ouvintes
  final _controlador = StreamController<EventoJogo>.broadcast();
  final List<EventoJogo> _historico = []; // ← Mantém registro de tudo

  /// Stream que qualquer sistema pode ouvir
  Stream<EventoJogo> get eventos => _controlador.stream;

  /// Publica um evento no bus
  void publicar(EventoJogo evento) {
    _historico.add(evento); // ← Registra
    _controlador.add(evento); // ← Transmite
  }

  /// Filtra eventos por tipo (Streams podem ser filtradas!)
  Stream<EventoJogo> filtrar(TipoEvento tipo) {
    return eventos.where((e) => e.tipo == tipo);
  }

  /// Retorna os últimos [n] eventos do histórico
  List<EventoJogo> ultimosEventos(int n) {
    if (n >= _historico.length) return List.unmodifiable(_historico);
    return List.unmodifiable(_historico.sublist(_historico.length - n));
  }

  /// Libera recursos quando o jogo termina
  void dispose() {
    _controlador.close(); // ← IMPORTANTE: sempre feche Streams!
  }
}
```

### Usando o Bus no Jogo

```dart
// lib/main.dart (ou arquivo de teste)
void main() {
  final bus = BusEventos();

  // ← Sistema de log ouve TODOS os eventos
  bus.eventos.listen((e) => print('[LOG] $e'));

  // ← Sistema de XP ouve apenas mortes
  bus.filtrar(TipoEvento.morte).listen((e) {
    print('[XP] +50 pontos de experiência!');
  });

  // ← Sistema de som ouve apenas combate
  bus.filtrar(TipoEvento.combate).listen((e) {
    print('[SOM] *clang* Espadas se chocam!');
  });

  // ← Simulação de jogo: apenas publica eventos
  bus.publicar(EventoJogo(TipoEvento.combate, 'Herói ataca Goblin'));
  bus.publicar(EventoJogo(TipoEvento.morte, 'Goblin derrotado'));
  bus.publicar(EventoJogo(TipoEvento.item, 'Poção coletada'));

  bus.dispose(); // ← Limpeza
}
```

**Saída esperada:**
```text
[LOG] [TipoEvento.combate] Herói ataca Goblin
[SOM] *clang* Espadas se chocam!
[LOG] [TipoEvento.morte] Goblin derrotado
[XP] +50 pontos de experiência!
[LOG] [TipoEvento.item] Poção coletada
```

Observe o design: cada sistema ouve apenas o que precisa. O barramento não sabe quem está ouvindo. Os ouvintes não sabem quem publica. Desacoplamento total. O sistema de som não conhece o sistema de XP, e vice-versa. Todos conversam através do bus de forma independente.

## Por que não usar Callbacks?

Antes de *async/await*, a forma de lidar com assincronismo era via *callbacks*: passar uma função que seria chamada quando a operação terminasse. Isso resulta em "callback hell" (inferno de callbacks), onde código fica aninhado e ilegível. Veja:

```dart
// Estilo callback (RUIM - difícil de ler)
lerArquivo('save.json', (json) {
  fazer_parse(json, (dados) {
    validar(dados, (valido) {
      if (valido) {
        salvar(dados, (resultado) {
          print('Salvo: $resultado');
        });
      }
    });
  });
});

// Estilo async/await (BOM - linear e legível)
try {
  final json = await lerArquivo('save.json');
  final dados = fazer_parse(json);
  if (validar(dados)) {
    final resultado = await salvar(dados);
    print('Salvo: $resultado');
  }
} catch (e) {
  print('Erro: $e');
}
```

Com `async/await`, o código é linear, sequencial e fácil de entender. Com *callbacks*, fica aninhado e difícil de debugar. *Streams* são similares, mas para múltiplos eventos ao longo do tempo.

## Resumo dos Conceitos

```text
┌─────────────────────────────────────────────────────┐
│                  ASYNC EM DART                      │
├──────────────┬──────────────────────────────────────┤
│ *Future<T>*    │ Promessa de valor único no futuro    │
│ *async*        │ Marca função como assíncrona         │
│ *await*        │ Pausa a função, não o programa       │
│ *Future.wait*  │ Executa Futures em paralelo          │
│ *Stream<T>*    │ Fluxo contínuo de valores            │
│ *listen()*     │ Inscreve ouvinte em uma Stream       │
│ *where()*      │ Filtra eventos da Stream             │
│ *broadcast()*  │ Stream com múltiplos ouvintes        │
│ *try/catch*    │ Captura erros assíncronos            │
│ *timeout*      │ Limita tempo de espera               │
└──────────────┴──────────────────────────────────────┘
```

## Dica Profissional

::: dica
Assincronismo é difícil de debugar. Use estas práticas:

1. **Sempre adicione logging em pontos críticos:** Quando inicia uma operação assíncrona, log. Quando termina, log novamente. Assim você vê onde o programa está preso.
2. **Use *timeouts* generosamente:** Operações que deveriam levar 1 segundo mas levam 10 são sinais de que algo está errado. Sempre adicione `.timeout(Duration(...))`.
3. **Teste com *Future.wait* em paralelo:** Se uma operação trava quando rodando em paralelo, provavelmente há concorrência errada ou compartilhamento de estado.
4. **Streams precisam ser fechadas:** Um `StreamController` aberto forever vaza memória. Sempre chame `.dispose()` quando termina.
:::

## Pergaminho do Capítulo

Neste capítulo você aprendeu os fundamentos essenciais da programação assíncrona em Dart que transformam um jogo congelado em uma experiência fluida. Começou com o conceito de `Future<T>`, uma promessa de valor futuro que não bloqueia a execução. Aprendeu que `async` marca uma função como assíncrona (retornando automaticamente uma `Future`) e `await` pausa apenas essa função até a `Future` resolver, permitindo que o resto do programa continue. Dominou `Future.wait` para executar múltiplas operações em paralelo, economizando tempo crítico no carregamento de recursos. Entendeu o tratamento robusto de erros assíncronos com `try`/`catch`/`finally`, garantindo que exceções em operações assincronas são capturadas e que limpeza sempre ocorre. Viu como encadear *Futures* mantém código legível sem "callback hell". Finalmente, aprendeu sobre `Stream<T>`, fluxo contínuo de eventos, e implementou um `BusEventos` completo que desacopla sistemas através de um barramento de eventos: log, XP, som, UI e conquistas escutam eventos sem conhecerem um ao outro. Junto com `try`/`catch` robusto e `timeout` para operações que travam, você está pronto para persistência segura, rede, e qualquer operação I/O que seus jogos exijam.

::: dica
**Dica do Mestre:** Assincronismo é onde muitos programadores iniciantes começam a lutar. O segredo é pensar em *Futures* como "coisas que vão acontecer" não "coisas que estão presas". Uma `Future` é libertadora: você não congela esperando, você continua. E `Stream` é a evolução: em vez de um valor único, múltiplos eventos fluindo indefinidamente. Pratique estas três regras: (1) sempre use `await` se você precisa do valor de uma `Future`, (2) sempre coloque `try`/`catch` em torno de `await` se a operação pode falhar, (3) sempre feche `Stream` quando termina com `.dispose()` ou `.cancel()`. Siga essas e assincronismo se torna natural.
:::

***

## Desafios da Masmorra

**Desafio 30.1.** Implemente uma função `carregarArquivoComRetentativa(String caminho, int tentativas)` que tenta ler um arquivo até `tentativas` vezes, aguardando 500ms entre tentativas. Se falhar em todas as tentativas, retorna um fallback vazio.

**Desafio 30.2.** Crie um `FluxoTempoReal` que emite eventos a cada 100ms (use `Stream.periodic`) durante 5 segundos. Inscreva-se, filtre apenas eventos com valor par, e print cada um.

**Desafio 30.3.** Implemente `Future.wait` para carregar 3 recursos em paralelo (mapa, inimigos, itens). Cada um retorna após delay variável (1s, 2s, 1.5s). Meça o tempo total e verifique que é o do mais lento, não a soma.

**Desafio 30.4.** Crie um `BusEventos` com histórico. Quando você pede os últimos N eventos, retorna uma lista. Emita 10 eventos e recupere os últimos 5.

**Desafio 30.5.** Implemente tratamento de erro assíncrono onde uma operação pode falhar com três exceções diferentes. Use `catch (e)` específico para cada uma, com fallback apropriado para cada tipo.

**Desafio 30.6.** Crie uma função `correrEmParalelo(List<Future<int>> futures)` que executa todas em paralelo com `Future.wait` e retorna a soma de todos os resultados.

**Desafio 30.7.** Implemente um `RegistroEventos` que armazena cada evento emitido com timestamp. Adicione método `gerarRelatorio()` que imprime todos os eventos em ordem cronológica com delta de tempo entre eles.

**Boss Final 30.8.** Monte um sistema de carregamento de jogo completo: (1) Carrega arquivo JSON do save (com retry e timeout), (2) faz parse JSON (com tratamento de erro), (3) cria jogador a partir do JSON, (4) enquanto isso, carrega mapa, inimigos, itens em paralelo com `Future.wait`, (5) quando tudo está pronto, emite `EventoJogoCarregado` que faz log, mostra tela de transição, e toca música. Use `async`, `await`, `Future.wait`, `try`/`catch`, `timeout`, e um `BusEventos` real.

***

Você dominou assincronismo. Agora todo recurso pode ser carregado sem congelar o jogo. A masmorra pode ser persistida em disco, na nuvem, transmitida pela rede. Tudo sem travar.

> *"O herói não espera o baú abrir. Enquanto o baú abre, ele explore, ataca, se defende. E quando o baú está pronto, uma notificação o avisa. Assim é assincronismo: o mundo continua."*

## Próximo Capítulo

No Capítulo 31, usaremos *async*/*await* para persistir o estado do jogo em *JSON*. *Save* e *load* transformam a masmorra de uma sessão única numa aventura que o jogador pode retomar a qualquer momento.
