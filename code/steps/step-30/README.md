# Step 30 — Async, Await e o Tempo na Masmorra

Este step implementa o sistema de eventos assíncrono do jogo usando `Stream` e `StreamController.broadcast()`.

## Estrutura

```
lib/
  evento_jogo.dart   # Enum TipoEvento + classe EventoJogo
  bus_eventos.dart    # BusEventos com StreamController broadcast
  main.dart           # Simulação de combate com 3 sistemas ouvintes
test/
  bus_eventos_test.dart  # Testes do BusEventos
```

## Executar

```bash
dart run lib/main.dart
```

## Testar

```bash
dart test
```
