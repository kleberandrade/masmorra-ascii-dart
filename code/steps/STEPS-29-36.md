# Steps 29-36: Roguelike ASCII Completo

Jornada completa de desenvolvimento de um roguelike em Dart com padrões de design profissionais.

## Visão Geral

| Step | Capítulo | Tema | Marca |
|------|----------|------|-------|
| 29 | Testes | Suite completa de testes unitários (38 testes) | ✅ |
| 30 | Persistência | Save/load com JSON + async/await | ✅ |
| 31 | Organização | Projeto profissional (lib/, test/) | ✅ |
| 32 | Golden Tests | Testes visuais + HUD polido | MARCO V |
| 33 | Strategy+Command | IA com estratégias + ações reversíveis | ✅ |
| 34 | Factory+Observer | Criação escalável + eventos reativos | ✅ |
| 35 | State Machines | Inimigos com FSM (5 estados) | ✅ |
| 36 | Síntese | Marco VI no livro; jogo completo em `../masmorra_ascii/` | MARCO VI |

## Step-29: Testes Unitários

**Tema:** `package:test` para proteção de código

```bash
cd step-29
dart pub get
dart test           # 38 testes
dart lib/main.dart
```

**Implementado:**
- Jogador (13 testes): atributos, HP, XP, inventário
- Inimigo (11 testes): combate, cura, estatísticas
- Combate (14 testes): dano, vitória/derrota, combate longo

**Padrão:** Testes espelham lib/

**Estrutura:**
```
step-29/
├── lib/modelos/     (jogador, inimigo)
├── lib/sistemas/    (combate)
├── test/modelos/    (testes espelho)
└── test/sistemas/
```

## Step-30: Persistência JSON

**Tema:** `async/await` + `dart:convert` para save/load

```bash
cd step-30
dart lib/main.dart      # Demo salvar/carregar
dart test                   # Testes de serialização
```

**Implementado:**
- `Jogador.toJson()/fromJson()` - Serialização
- `GerenciadorSalve` - 5 slots de save
- Auto-save após cada andar
- Testes roundtrip JSON

**Padrão:** toMap/fromMap em toda classe serializável

## Step-31: Organização Profissional

**Tema:** Estrutura Dart profissional (lib/, test/, pubspec.yaml)

```bash
cd step-31
dart analyze        # Zero avisos
dart format .      # Formata automático
dart lib/main.dart
```

**Implementado:**
- `lib/main.dart` - Ponto de entrada
- `analysis_options.yaml` - Qualidade de código
- `.gitignore` - Padrão Dart

**Convenções:**
- Imports relativos em lib/, package: em test/
- lib/ organizado: modelos/, sistemas/, ui/
- test/ espelhando lib/

## Step-32: Golden Tests e HUD (MARCO V)

**Tema:** Testes visuais ASCII + renderizador polido

```bash
cd step-32
dart test                          # Golden tests
dart test --update-goldens         # Atualizar após mudanças
```

**Implementado:**
- Renderizador com barras (█░)
- Golden files capturam output esperado
- Testes detectam mudanças visuais acidentais
- HUD profissional com alinhamento

**Exemplo Golden:**
```
╔════════════════════════════════════════════╗
║              Aragorn                       ║
║ HP: [████████████░░░░░░░░] 90%             ║
║ Nível: 2 │ XP: 150                         ║
╚════════════════════════════════════════════╝
```

## Step-33: Strategy e Command

**Tema:** Padrões para IA inteligente e ações reversíveis

```bash
cd step-33
dart lib/main.dart      # Demo estratégias
dart test
```

**Strategy Pattern:**
```dart
class IAAgressiva implements EstrategiaIA { ... }
class IACovardia implements EstrategiaIA { ... }
class IAPassiva implements EstrategiaIA { ... }

var lobo = Inimigo(estrategia: IAAgressiva());
```

**Command Pattern:**
```dart
var ataque = AcaoAtacar(inimigo, heroi);
gerenciador.executar(ataque);
gerenciador.desfazer();
```

**Implementado:**
- 3 estratégias de IA
- 4 ações (Atacar, Mover, Fuga, Aguardar)
- Histórico completo com undo/redo
- Descrições de ações para log

## Step-34: Factory e Observer

**Tema:** Criação escalável + sistemas reativos desacoplados

```bash
cd step-34
dart lib/main.dart
```

**Factory Pattern:**
```dart
var inimigo = FabricaInimigo.criar('lobo', andar: 3);
var aleatorio = FabricaInimigo.criarAleatorio(5);
```

- Catálogo centralizado
- Escalamento por andar
- Raridade configurável

**Observer Pattern:**
```dart
bus.emitir(EventoMorteInimigo(...));
// Log, Stats, UI, Som reagem independentemente
```

**Implementado:**
- FabricaInimigo com 3 tipos
- BarramentoEventos (Singleton)
- ObservadorLog
- ObservadorEstatisticas
- (Extensível para Áudio, UI, Conquistas)

## Step-35: Máquinas de Estado (MARCO V+)

**Tema:** FSM para IA verdadeiramente inteligente

```bash
cd step-35
dart test
```

**Estados Implementados:**
```
Patrulhando ──(vê alvo)──> Alerta
     ^                        │
     │                        │
     │                        v
     │                   Perseguindo
     │                        │
     │                        v
     └──────── Fugindo <── Atacando
```

**5 Estados:**
1. **Patrulhando** - Repouso, segue rota
2. **Alerta** - Viu alvo, 3 turnos de incerteza
3. **Perseguindo** - Comprometido, segue alvo
4. **Atacando** - Combate direto
5. **Fugindo** - Retirada, regenera HP

**Visual:**
```dart
String get simbolo {
  return switch (estado) {
    Patrulhando() => 'z',
    Alerta() => 'z!',
    Perseguindo() => 'Z!',
    Atacando() => 'Z!!',
    Fugindo() => 'z...',
  };
}
```

## Step-36: Roguelike final (MARCO VI)

**Tema:** Síntese e fecho do capítulo 36 no livro. A pasta `step-36` não contém o snapshot completo do jogo; o **pacote executável de referência** é `masmorra_ascii` (irmão de `steps/` em `code/`).

```bash
cd ../masmorra_ascii
dart pub get
dart lib/main.dart
dart test
dart analyze
```

Texto de encerramento: [MARCO-VI.md](MARCO-VI.md).

**Características do projeto de referência (`masmorra_ascii`):**
- Dungeon procedural infinita
- 5 inimigos com IA FSM completa
- Boss com múltiplas fases
- Combate tático com defesa
- Economia (ouro, itens, loot)
- Progressão (XP, níveis, habilidades)
- Save/load persistente
- HUD ASCII polida com barras visuais
- Suite completa de testes (100+)
- Código 100% profissional

## Padrões de Design Resumo

| Padrão | Propósito | Step |
|--------|-----------|------|
| Strategy | IA intercambiável | 33 |
| Command | Ações reversíveis | 33 |
| Factory | Criação centralizada | 34 |
| Observer | Eventos reativos | 34 |
| State | Máquinas de estado | 35 |

## Comandos habituais

```bash
cd step-NN
dart pub get
dart lib/main.dart
dart test
dart analyze
dart format .
```

Para jogar a versão completa: `cd ../masmorra_ascii` e `dart lib/main.dart`.

## Estrutura Geral

Cada step segue a mesma organização:

```
step-NN/
├── lib/
│   ├── modelos/         (dados: Jogador, Inimigo)
│   ├── sistemas/        (lógica: Combate)
│   ├── ui/              (renderização)
│   └── padroes/         (Step 33+: Strategy, Command, Factory, Observer, State)
├── test/
│   ├── modelos/
│   ├── sistemas/
│   └── padroes/
├── pubspec.yaml         (dependências)
├── analysis_options.yaml (qualidade)
└── README.md            (opcional; índice geral em README.md desta pasta)
```

## Checklist de Aprendizado

- [x] Step-29: Testes unitários (package:test)
- [x] Step-30: Async/await + JSON (persistência)
- [x] Step-31: Organização profissional (lib/, test/)
- [x] Step-32: Golden tests + HUD polido
- [x] Step-33: Strategy + Command (IA + ações)
- [x] Step-34: Factory + Observer (escalabilidade)
- [x] Step-35: State machines (FSM inteligente)
- [x] Step-36: Marco VI (código final em `masmorra_ascii/`)

## Próximas Jornadas

Após concluíres o percurso (e explorares `masmorra_ascii/`), você está pronto para:

1. **Flutter** - Transforme em app mobile
2. **Flame** - Game engine com gráficos
3. **Shelf/Serverpod** - Backend multiplayer
4. **Pub.dev** - Publique sua biblioteca
5. **Novos padrões** - Abstract Factory, Builder, Decorator, etc.

## Recursos

- [Dart Documentation](https://dart.dev/guides)
- [Flutter](https://flutter.dev)
- [Pub.dev](https://pub.dev)
- [Game Programming Patterns](https://gameprogrammingpatterns.com)
- [Refactoring Guru - Design Patterns](https://refactoring.guru/design-patterns)

---

**Você fez isso. Você construiu um roguelike profissional do zero.**

Não é pouco. É tudo. 🎮
