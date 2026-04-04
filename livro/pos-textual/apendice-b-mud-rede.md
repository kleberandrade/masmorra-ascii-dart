# Apêndice B: MUD em Rede (Opcional) {.unnumbered}

Este apêndice não faz parte do percurso obrigatório do livro. O núcleo permanece um jogo offline no terminal. Mas se você quiser dar o próximo passo e transformar a Masmorra ASCII em um MUD (Multi-User Dungeon) multiplayer que funciona em rede, aqui estão as direções (e não são tão longas quanto pode parecer).

## A Ideia Fundamental

Um MUD é, essencialmente, o mesmo jogo que você já construiu, mas com vários jogadores conectados ao mesmo tempo via rede. O modelo de domínio (salas, jogador, combate, itens) permanece intacto. O que muda é a camada de transporte e estado:

- **Localmente:** você lê do `stdin` e escreve em `stdout`. O jogo é uma sequência de iterações no seu terminal.
- **Em rede:** o servidor recebe comandos via WebSocket de múltiplos clientes. Mantém um mundo compartilhado na memória. Envia eventos para todos os jogadores afetados por uma ação.

Não é magia. É arquitetura: separar o modelo de domínio (que não muda) da apresentação (que agora é remota) e da comunicação (que agora é de muitos para um servidor).

## Arquitetura em Camadas

Pensar em rede significa pensar em separação:

Camadas da arquitetura em rede. A fonte editável do diagrama está em `assets/diagrams/apendice-b-camadas-rede.mmd`; o PNG é gerado em `./scripts/build.sh` com Node.js/npx (`@mermaid-js/mermaid-cli`).

![Arquitetura em camadas: cliente, transporte, lógica e persistência](assets/diagrams/apendice-b-camadas-rede.png)

A beleza disso: quase nada do que você escreveu no livro muda. Você reutiliza suas classes `Jogador`, `Sala`, `Inimigo`, etc. O que muda é o **loop principal**: deixa de ser single-player local e vira um servidor que coordena múltiplos clientes.

## Implementação: Servidor WebSocket Básico

O pacote `dart:io` já traz tudo que você precisa. Não é necessário adicionar dependências externas (embora `package:shelf` seja excelente para APIs mais complexas).

```dart
import 'dart:io';
import 'dart:convert';

// Mapa global: cada jogador ativo está aqui
final jogadoresAtivos = <String, JogadorConectado>{};

// O mundo compartilhado — sua masmorra vive aqui
late Mundo mundoCompartilhado;

void main() async {
  // Inicializa o mundo (mesmo código do livro)
  mundoCompartilhado = Mundo(semente: 12345);

  // Cria o servidor HTTP
  final servidor = await HttpServer.bind('localhost', 8080);
  print('Servidor MUD rodando em localhost:8080');

  // Loop infinito aguardando conexões
  await for (final requisicao in servidor) {
    if (WebSocketTransformer.isUpgradeRequest(requisicao)) {
      // Uma nova pessoa entrou na masmorra
      final ws = await WebSocketTransformer.upgrade(requisicao);
      tratarNovaConexao(ws);
    }
  }
}

// Representa um jogador conectado
class JogadorConectado {
  final String id;
  final Jogador jogador; // Sua classe do livro
  final WebSocket ws;
  bool ativo = true;

  JogadorConectado(this.id, this.jogador, this.ws);

  void enviar(String mensagem) {
    if (ativo && ws.closeCode == null) {
      ws.add(mensagem);
    }
  }

  void fechar() {
    ativo = false;
    ws.close();
  }
}

void tratarNovaConexao(WebSocket ws) {
  // Cria um jogador novo
  final idJogador = _gerarID();
  final novoJogador = Jogador(
    nome: 'Aventureiro#$idJogador',
    vida: 100,
  );

  final conectado = JogadorConectado(idJogador, novoJogador, ws);
  jogadoresAtivos[idJogador] = conectado;

  // Envio inicial
  conectado.enviar('Bem-vindo à Masmorra ASCII Online!');
  conectado.enviar('Seu nome é: ${novoJogador.nome}');
  _descreverSala(conectado);

  // Escuta mensagens do cliente
  ws.listen(
    (mensagem) => _processarComando(idJogador, mensagem.toString()),
    onDone: () => _desconectar(idJogador),
    onError: (erro) {
      print('Erro no WebSocket: $erro');
      _desconectar(idJogador);
    },
  );
}

void _processarComando(String idJogador, String comando) {
  final conectado = jogadoresAtivos[idJogador];
  if (conectado == null) return;

  // Parse: "mover norte", "atacar", "usar poção", etc.
  final partes = comando.trim().toLowerCase().split(' ');
  if (partes.isEmpty) return;

  final acao = partes[0];

  switch (acao) {
    case 'mover':
      if (partes.length < 2) {
        conectado.enviar('Sintaxe: mover [norte|sul|leste|oeste]');
        return;
      }
      _moverJogador(idJogador, partes[1]);
      break;

    case 'atacar':
      _iniciarCombate(idJogador);
      break;

    case 'inventario':
      final inv = conectado.jogador.inventario;
      conectado.enviar('Seu inventário: $inv');
      break;

    case 'sair':
      conectado.enviar('Você saiu da masmorra. Até logo!');
      _desconectar(idJogador);
      break;

    default:
      conectado.enviar('Comando desconhecido: $acao');
  }
}

void _moverJogador(String idJogador, String direcao) {
  final conectado = jogadoresAtivos[idJogador];
  if (conectado == null) return;

  // Aqui você chama a lógica de movimento do seu Jogador
  // Por exemplo: conectado.jogador.mover(direcao);
  // E verifica colisões, inimigos, etc.

  conectado.enviar('Você se moveu para $direcao');
  _descreverSala(conectado);

  // Notifica outros jogadores na mesma sala
  _notificarSala(conectado, '${conectado.jogador.nome} entrou');
}

void _descreverSala(JogadorConectado conectado) {
  // Sua classe Sala tem descrição?
  // conectado.enviar(sala.descreverPara(jogador));
  // Isso renderiza a sala, lista inimigos visíveis, saídas, etc.
}

void _notificarSala(JogadorConectado origem, String mensagem) {
  // Encontra todos os jogadores na mesma sala
  for (final outro in jogadoresAtivos.values) {
    if (outro.ativo && outro.id != origem.id) {
      // Verifica se estão na mesma sala
      if (_mesmasSalas(origem.jogador, outro.jogador)) {
        outro.enviar(mensagem);
      }
    }
  }
}

void _desconectar(String idJogador) {
  final conectado = jogadoresAtivos.remove(idJogador);
  if (conectado != null) {
    conectado.fechar();
    print('${conectado.jogador.nome} desconectou');
    // Notifica outros jogadores
    final n = conectado.jogador.nome;
    _notificarSala(conectado, '$n saiu da masmorra');
  }
}

String _gerarID() => DateTime.now().millisecondsSinceEpoch.toString();
bool _mesmasSalas(Jogador a, Jogador b) {
  // Implementar conforme sua estrutura de Sala
  return a.salaAtual == b.salaAtual;
}
```

## Padrões de Mensagem: Contrato Client-Servidor

Defina um formato claro para trocas entre cliente e servidor. JSON é limpo e extensível:

```dart
// Cliente ENVIA
{
  "tipo": "comando",
  "acao": "mover",
  "parametro": "norte"
}

// Servidor RESPONDE
{
  "tipo": "descricao",
  "sala": "Corredor Escuro e Úmido",
  "saidas": ["norte", "sul"],
  "inimigos": ["Zumbi", "Múmia"],
  "jogadores": ["Aventureiro#123", "Aventureiro#456"]
}

// Evento de broadcast (servidor notifica TODOS afetados)
{
  "tipo": "evento",
  "acao": "morte",
  "jogador": "Aventureiro#123",
  "mensagem": "Aventureiro#123 foi derrotado!"
}
```

Parse robusto em Dart:

```dart
void _processarMensagem(String json) {
  final dados = jsonDecode(json) as Map<String, dynamic>;
  final tipo = dados['tipo'] as String;

  switch (tipo) {
    case 'comando':
      _executarComando(dados);
    case 'chat':
      _broadcast(dados);
    // etc.
  }
}
```

## Gerenciamento de Estado Compartilhado

A chave: **uma única instância do mundo, protegida por sincronização**.

Se dois jogadores atacarem o mesmo inimigo simultaneamente, você precisa garantir que:
1. Ambas as ações sejam registradas
2. O HP do inimigo não seja decrementado duas vezes por engano
3. Se o inimigo morre, ambos veem a morte

Use `Mutex` ou `Lock` do Dart para seções críticas:

```dart
import 'dart:async';

class MundoCritico {
  final mundo = Mundo();
  final _lock = Lock(); // De package:async

  Future<void> executarAcao(String idJogador, String acao) async {
    await _lock.synchronized(() {
      // Apenas uma ação por vez nesta seção
      final jogador = mundo.obterJogador(idJogador);
      if (acao == 'atacar') {
        final inimigo = mundo.obterInimigoProximo(jogador);
        if (inimigo != null) {
          jogador.atacar(inimigo);
          if (inimigo.vida <= 0) {
            mundo.removerInimigo(inimigo);
          }
        }
      }
    });
  }
}
```

## Broadcast: Notificando Múltiplos Clientes

Quando algo acontece (inimigo morre, tesouro aparece, outro jogador chega), **todos na sala precisam saber**.

```dart
void _broadcast(String mensagem) {
  for (final conectado in jogadoresAtivos.values) {
    if (conectado.ativo) {
      conectado.enviar(mensagem);
    }
  }
}

void _broadcastParaSala(String nomeSala, String mensagem) {
  for (final conectado in jogadoresAtivos.values) {
    if (conectado.ativo && conectado.jogador.salaAtual == nomeSala) {
      conectado.enviar(mensagem);
    }
  }
}
```

## Sessões e Persistência

Cada jogador merece uma sessão:

```dart
class Sessao {
  final String id;
  late Jogador jogador;
  late DateTime conectadoEm;
  int ultimaAtividadeEm = DateTime.now().millisecondsSinceEpoch;

  Sessao(this.id);

  bool estaInativa(int tempoMaximoEmMs) {
    return DateTime.now().millisecondsSinceEpoch - ultimaAtividadeEm >
        tempoMaximoEmMs;
  }
}
```

E salvar periodicamente:

```dart
void _salvarProgresso(Sessao sessao) {
  final json = jsonEncode({
    'nome': sessao.jogador.nome,
    'vida': sessao.jogador.vida,
    'ouro': sessao.jogador.ouro,
    'sala': sessao.jogador.salaAtual,
    'inventario': sessao.jogador.inventario.map((i) => i.nome).toList(),
  });

  // Salva em arquivo ou banco de dados
  File('saves/${sessao.id}.json').writeAsStringSync(json);
}
```

## Escalabilidade: Próximos Passos

O servidor acima funciona para **dezenas de jogadores**. Se você quiser milhares:

1. **Distribuir o estado:** Não guarde tudo na memória de um servidor. Use Redis para cache, PostgreSQL para persistência.
2. **Sharding:** Cada servidor gerencia um "andar" diferente da masmorra.
3. **Message queues:** Use RabbitMQ ou Kafka para fila de mensagens assíncronas entre servidores.
4. **Logging e monitoramento:** Adicione observabilidade com Sentry ou Datadog.

Mas para aprender, o acima é suficiente. Uma masmorra funcionando em rede é um projeto denso, e você já tem toda a lógica do livro. Agora é apenas orquestração.

## Recursos Complementares

- `package:shelf_web_socket` para uma camada de transporte mais robusta
- `package:async` (incluída com Dart) para `Lock`, `Mutex` e outros primitivos de concorrência
- `package:shelf` se quiser adicionar endpoints REST (status do servidor, rankings, etc.)
- Dart docs: `dart.dev/guides/libraries/library-tour#dartio` para WebSocket detalhes

O calabouço não termina aqui. Ele só fica mais profundo. E agora, mais multiplayer.
