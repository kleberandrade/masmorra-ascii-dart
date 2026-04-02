# Apêndice B: MUD em rede (opcional) {.unnumbered}

Este apêndice não faz parte do percurso obrigatório do livro. O núcleo permanece um jogo offline no terminal. Mas se você quiser dar o próximo passo e transformar a Masmorra ASCII em um MUD multiplayer, aqui estão as direções.

## A ideia

Um MUD (Multi-User Dungeon) é, essencialmente, o mesmo jogo que você já construiu, mas com vários jogadores conectados ao mesmo tempo via rede. O modelo de domínio (salas, jogador, combate, itens) permanece o mesmo. O que muda é a camada de transporte: em vez de ler do `stdin` local, o servidor recebe comandos via WebSocket; em vez de imprimir no terminal, envia texto de volta para cada cliente conectado.

## Ferramentas em Dart

O pacote `shelf` é um servidor HTTP leve em Dart que permite expor endpoints REST e WebSockets. Com `dart:io`, você pode criar um servidor WebSocket com poucas linhas.

```dart
import 'dart:io';

void main() async {
  final servidor = await HttpServer.bind('localhost', 8080);
  print('Servidor rodando em localhost:8080');

  await for (final requisicao in servidor) {
    if (WebSocketTransformer.isUpgradeRequest(requisicao)) {
      final ws = await WebSocketTransformer.upgrade(requisicao);
      tratarConexao(ws);
    }
  }
}

void tratarConexao(WebSocket ws) {
  ws.add('Bem-vindo à Masmorra ASCII Online!');
  ws.listen((mensagem) {
    // analisar comando e executar no mundo compartilhado
    final resposta = processarComando(mensagem.toString());
    ws.add(resposta);
  });
}
```

## Contrato de mensagens

Defina um formato para comandos e eventos, espelhando o parser que já existe no modo single-player. O formato pode ser JSON ou linhas de texto simples.

```dart
// Cliente envia
{"tipo": "mover", "direcao": "norte"}

// Servidor responde
{"tipo": "descricao", "sala": "Corredor Escuro", "saidas": ["norte", "sul"]}
```

## Arquitetura

A chave é manter o mesmo modelo de domínio e trocar apenas a camada de I/O. O `LoopJogo` passa a receber comandos de uma fila de mensagens em vez do `stdin`, e o renderizador envia texto para o WebSocket em vez de `stdout`. Assim o livro continua coerente e o apêndice vira extensão natural, não um segundo projeto.

## Próximos passos

Se quiser ir além, pesquise `package:shelf_web_socket` no `pub.dev` para uma integração mais robusta, e considere usar `Stream` (que você aprendeu no Capítulo 30) para gerenciar múltiplas conexões simultaneamente.
