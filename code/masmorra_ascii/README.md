# Masmorra ASCII

Um roguelike completo em Dart, desenvolvido através de 37 capítulos de aprendizado progressivo. O jogo oferece exploração de masmorras procedurais, combate tático, IA inteligente de inimigos, economia de jogo, persistência de dados e uma arquitetura baseada em padrões de design profissionais.

## Descrição do Projeto

**Masmorra ASCII** é um jogo roguelike em tempo real (baseado em turnos) que roda em terminal. Você controla um aventureiro que desce a uma masmorra infinita em busca de ouro, experiência e glória. O jogo oferece:

- **Exploração dinâmica**: Uma masmorra procedural gerada infinitamente
- **Combate estratégico**: Sistema de turnos com múltiplas opções de ataque
- **IA inteligente**: Inimigos com máquinas de estado (patrulha, alerta, perseguição, fuga)
- **Economia completa**: Loja, compra/venda de itens, progressão de ouro
- **Progressão de herói**: Sistema de XP e níveis
- **Chefe final**: Um antagonista multi-fase com fase especial
- **Save/Load**: Persistência de dados em JSON
- **Testes automatizados**: Cobertura de testes com o package `test`

## Requisitos

- Dart SDK **3.11+**

## Como Executar

### Rodar o Jogo

```bash
cd code/masmorra_ascii
dart pub get
dart run
```

O jogo iniciará um menu interativo onde você pode:
- Iniciar um novo jogo
- Continuar um jogo salvo
- Ver créditos
- Sair

### Rodar os Testes

```bash
cd code/masmorra_ascii
dart test
```

Todos os testes devem passar. Os testes cobrem:
- **Combate**: Cálculo de dano, morte de inimigos
- **Economia**: Compra/venda de itens
- **Mapa**: Geração procedural, colisões
- **Parser**: Análise de entrada do jogador
- **Tela**: Renderização ASCII

## Arquitetura do Projeto

A estrutura de diretórios:

```
lib/
├── main.dart                    # Ponto de entrada, inicia SessaoJogo
├── masmorra_ascii.dart          # Exports públicos da biblioteca
└── src/
    ├── combate/                 # Lógica de combate
    │   └── combate.dart         # Executa combates entre Jogador e Inimigo
    │
    ├── economia/                # Sistema econômico do jogo
    │   └── loja.dart            # Funções de compra/venda
    │
    ├── ia/                      # Inteligência artificial dos inimigos
    │   ├── acao_combate.dart    # Classe de ações possíveis em combate
    │   └── estado_ia.dart       # Máquinas de estado (Patrulha, Alerta, etc)
    │
    ├── jogo/                    # Loop principal do jogo
    │   └── sessao_jogo.dart     # Gerencia menu, exploração, save/load
    │
    ├── modelos/                 # Modelos de dados
    │   ├── fabrica_inimigo.dart # Factory para criação de inimigos
    │   ├── inimigo.dart         # Classe Inimigo com IA
    │   ├── item.dart            # Classes Item e Arma
    │   ├── jogador.dart         # Classe Jogador (herói)
    │   └── sala.dart            # Classe Sala (locais do jogo)
    │
    ├── mundo/                   # Geração e gerenciamento do mundo
    │   ├── dados_mundo.dart     # Factory do mundo demo
    │   ├── mapa_masmorra.dart   # Gerador procedural de masmorra
    │   └── mundo_texto.dart     # Mapa de salas textuais
    │
    ├── parse/                   # Análise de entrada do jogador
    │   ├── comando_jogo.dart    # Enum de comandos válidos
    │   └── parseador.dart       # Parser de strings em comandos
    │
    ├── persistencia/            # Save/Load de jogo
    │   └── gerenciador_salve.dart # Funções de serialização em JSON
    │
    ├── tela_ascii.dart          # Renderização ASCII do jogo
    │
    └── ui/                      # Componentes da interface
        └── banner.dart          # Títulos e banners decorativos

test/
├── combate_test.dart
├── loja_test.dart
├── mapa_masmorra_test.dart
├── parseador_test.dart
└── tela_ascii_test.dart
```

## Classes Principais

### Modelos de Dados

| Classe | Responsabilidade |
|--------|------------------|
| `Jogador` | Representa o herói: HP, ouro, inventário, estatísticas |
| `Inimigo` | Representa adversários com IA: HP, dano, estratégia |
| `Item` | Classe base para objetos coletáveis (armas, poções) |
| `Arma` | Item especial com dano e preço |
| `Sala` | Localidade do mundo: descrição, saídas, inimigos |

### Mundo e Exploração

| Classe | Responsabilidade |
|--------|------------------|
| `MundoTexto` | Mapa de salas conectadas |
| `MapaMasmorra` | Gerador procedural de masmorra infinita |
| `DadosMundo` | Factory para criar o mundo demo |
| `MundoTexto` | Acesso a salas pelo ID |

### Jogo e Sessão

| Classe | Responsabilidade |
|--------|------------------|
| `SessaoJogo` | Loop principal: menu, exploração, combate, save/load |
| `TelaAscii` | Renderização do estado do jogo em terminal |
| `Parseador` | Conversão de entrada do jogador em comandos |
| `ComandoJogo` | Enum de ações possíveis |

### IA e Combate

| Classe | Responsabilidade |
|--------|------------------|
| `EstadoIA` | Máquina de estado (interface) |
| `EstadoPatrulha`, `EstadoAlerta`, `EstadoPerseguicao`, `EstadoFuga` | Implementações concretas de comportamento |
| `AcaoCombate` | Ação que um inimigo pode executar em combate |
| `executarCombate()` | Simula um combate turno a turno |

### Persistência

| Classe/Função | Responsabilidade |
|--------|------------------|
| `guardarJogo()` | Serializa Jogador e metadata para JSON |
| `carregarJogo()` | Desserializa Jogador de arquivo JSON |
| `DadosSalve` | Container para dados carregados |

## Padrões de Design Utilizados

### 1. Strategy
Cada `Inimigo` tem uma `EstrategiaIA` que pode ser trocada em tempo de execução. Permite desacoplar comportamento da classe.

```dart
var lobo = Inimigo(
  nome: “Lobo”,
  estrategia: IAAgressiva(),
);
if (lobo.hp < lobo.hpMax * 30 / 100) {
  lobo.estrategia = IACovardia();
}
```

### 2. Command
Cada ação é um objeto (`AcaoCombate`) que pode ser executado e desfeito. Permite replay e undo.

### 3. Factory
`FabricaInimigo` centraliza a criação de inimigos. `DadosMundo` centraliza a criação do mundo.

```dart
var inimigo = FabricaInimigo.criarAleatorio(andar: 3);
```

### 4. Observer
`BarramentoEventos` permite que múltiplos observadores reajam a eventos sem conhecer uns aos outros.

### 5. State
Inimigos usam máquinas de estado (`EstadoIA`) com transições explícitas entre Patrulha, Alerta, Perseguição e Fuga.

## Conceitos Dart Utilizados

- **Variáveis e tipos**: null safety, const, late
- **Operadores e expressões**: aritméticos, lógicos, spread
- **Coleções**: List, Map, Set
- **Controle de fluxo**: if/else, switch, while, for
- **Funções e closures**: higher-order functions, callbacks
- **Classes e OOP**: construtores, getters/setters, herança
- **Mixins**: composição de comportamento
- **Enums e sealed classes**: tipagem de estados
- **Generics**: tipos parametrizados
- **Async/Await**: operações assíncronas
- **Exceções**: try/catch/finally
- **JSON**: serialização com dart:convert
- **Testes**: test package com expect, grupo de testes

## Aprendizado Progressivo

Este projeto foi desenvolvido através de 37 capítulos:

- **Capítulos 1-5**: Fundamentos Dart
- **Capítulos 6-10**: Controle de fluxo
- **Capítulos 11-14**: Orientação a Objetos
- **Capítulos 15-21**: 2D, ASCII, exploração
- **Capítulos 22-27**: Economia, progressão, jogo completo
- **Capítulos 28-33**: Refatoração, testes, save/load
- **Capítulos 34-36**: Padrões de design
- **Capítulo 37**: Síntese e polimento

## Próximos Passos

### Flutter
Adapt o roguelike para mobile/desktop com Flutter, usando a mesma lógica de jogo.

### Networking
Publique um backend com Shelf ou Serverpod para multiplayer.

### Publicação
Publique o código como package em pub.dev:
```bash
dart pub publish
```

## Recursos

- [Documentação oficial Dart](https://dart.dev/guides)
- [Flutter](https://flutter.dev)
- [Pub.dev (packages)](https://pub.dev)
- Livro: “Design Patterns: Elements of Reusable Object-Oriented Software” (Gang of Four)
- Livro: “Game Programming Patterns” (online gratuito)

---

**Desenvolvido com ❤️ em Dart. Você não é mais iniciante.**
