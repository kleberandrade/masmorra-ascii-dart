# Capítulo 27 - Dungeon Run Completo: A Jornada Épica

> *Até agora, você construiu peças: movimento, combate, progressão, andares, um boss. Mas peças isoladas não fazem um jogo. Agora junta tudo numa máquina que funciona. Do menu inicial até a vitória ou morte final. Isto é completude. Isto é um produto jogável, pronto para ser compartilhado. Este capítulo é a celebração de tudo que aprendeu.*

## O Que Vamos Aprender

Neste capítulo (o pico da Parte IV) você vai:

- Criar a classe `MasmorraAscii`, o orquestrador mestre de todo o jogo
- Implementar o menu principal com ASCII art épico
- Criar seleção de dificuldade (Recruta / Normal / Veterano)
- Integrar criação de personagem (nome + atributos)
- Implementar o *loop* completo: menu → exploração → combate → progressão → andares → *boss* → vitória/derrota
- Demonstrar uma sessão de jogo completa com geração procedural
- Comparar a evolução desde o Capítulo 7 até agora
- Refletir sobre a jornada: do acadêmico ao produto profissional

Ao final, você terá um jogo *roguelike* completo e jogável. Pronto para distribuir, ensinar, expandir.

## Menu Principal

Todo jogo profissional começa com um menu. A classe `MenuPrincipal` desenha ASCII art bonita que diz bem-vindo, oferece opções: novo jogo, instruções, créditos, sair. Isto é o rosto do seu jogo. É a primeira impressão: deixa claro o que é, cria atmosfera, estabelece tom.

**Por que um menu?** Porque sem menu, o jogador entra direto no jogo sem contexto. Com menu, você constrói antecipação. A tela bonita diz: "Isto é um projeto acabado, profissional, pensado." É psicologia de design: detalhes pequenos mudam percepção gigantemente.

```dart
// lib/menu_principal.dart
import 'dart:io';

/// Menu principal do jogo
class MenuPrincipal {
  /// Exibe menu e retorna escolha do usuário
  String exibir() {
    _limpar();  // ← limpa tela para sensação de "novo"

    print('''
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║                         MASMORRA ASCII                       ║
║                                                              ║
║                      Uma Epopeia *Roguelike* em Dart         ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║   Bem-vindo, aventureiro! Você está prestes a descer         ║
║   numa masmorra antiga repleta de perigos, tesouros          ║
║   e poderes esquecidos.                                      ║
║                                                              ║
║   Preparado para a jornada?                                  ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║                            MENU PRINCIPAL                    ║
║                                                              ║
║   [1]  Novo Jogo                                             ║
║   [2]  Como Jogar                                            ║
║   [3]  Créditos                                              ║
║   [0]  Sair                                                  ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

    ''');

    stdout.write('Escolha: ');
    // ← defaulta a sair se entrada inválida
    return stdin.readLineSync() ?? '0';
  }

  /// Limpa tela (visual agradável)
  void _limpar() {
    for (int i = 0; i < 50; i++) {
      print('');
    }
  }

  /// Tela de instruções (disponível no menu)
  static void mostrarComoJogar() {
    print('''
╔══════════════════════════════════════════════════════════════╗
║                          COMO JOGAR                          ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  MOVIMENTO:                                                  ║
║    W  - Norte     S  - Sul     A  - Oeste    D  - Leste      ║
║                                                              ║
║  AÇÕES:                                                      ║
║    >      - Descer escada                                    ║
║    i      - Inventário                                       ║
║    status - Ver status                                       ║
║    quit   - Abandonar jogo                                   ║
║                                                              ║
║  PROGRESSÃO:                                                 ║
║    • Derrota inimigos para ganhar XP (*experience points*)   ║
║    • Colete itens e ouro                                     ║
║    • Suba de nível para desbloquear habilidades (*level up*) ║
║    • Chegue ao andar 5 e derrote o Rei da Masmorra           ║
║      (*boss fight*)!                                         ║
║                                                              ║
║  DIFICULDADES:                                               ║
║    Recruta:   +50% XP, inimigos mais fracos (treino)         ║
║    Normal:    Balanço perfeito (recomendado)                 ║
║    Veterano:  -50% XP, inimigos mais fortes (desafio!)       ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

    ''');

    stdout.write('Pressione ENTER para voltar ao menu...');
    stdin.readLineSync();
  }

  /// Tela de créditos (disponível no menu)
  static void mostrarCreditos() {
    print('''
╔══════════════════════════════════════════════════════════════╗
║                          CRÉDITOS                            ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  MASMORRA ASCII, Uma Epopeia de Aprendizado                  ║
║                                                              ║
║  Desenvolvido com Dart e ensino de programação               ║
║  como foco central                                           ║
║                                                              ║
║  SISTEMAS IMPLEMENTADOS:                                     ║
║    • Geração procedural de *dungeon* (algoritmo BSP)         ║
║    • Sistema completo de combate por turnos                  ║
║    • Progressão com XP e habilidades desbloqueáveis          ║
║    • 5 andares com dificuldade crescente                     ║
║    • *Boss* final com sistema de fases                       ║
║    • Interface ASCII com barras de saúde                     ║
║    • Sistema de economia (ouro, loja, itens)                 ║
║                                                              ║
║  CONCEITOS DART ENSINADOS:                                   ║
║    • Programação orientada a objetos (classes, herança)      ║
║    • Polimorfismo e métodos abstratos                        ║
║    • Sealed classes e enums                                  ║
║    • Generics e type parameters                              ║
║    • Pattern matching em Dart 3                              ║
║    • Event systems e padrões de design                       ║
║                                                              ║
║  DESENVOLVIDO EM: Dart 3.0+                                  ║
║                                                              ║
║  AGRADECIMENTOS:                                             ║
║    A todos os aventureiros que jogam, aprendem e criam!      ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

    ''');

    stdout.write('Pressione ENTER para voltar ao menu...');
    stdin.readLineSync();
  }
}
```

## Seleção de Dificuldade e Criação de Personagem

Antes de começar, você escolhe: quer treino (recruta, +50% XP, inimigos mais fracos), balanço perfeito (normal), ou desafio extremo (veterano, -50% XP, inimigos mais fortes)? Depois, digita o nome do seu herói. Isto personaliza a jornada: é SEU herói, não um genérico.

**Por que três dificuldades?** Porque diferentes jogadores têm diferentes expectativas. Iniciante quer "aprender sem frustração". Normal quer "balanço fair, recompensa merecida". Veterano quer "arranque-meu-coração, eu gosto de sofrer". Opções de dificuldade respeitam cada um. Isto torna o jogo acessível sem perder desafio.

```dart
// lib/criacao_personagem.dart
import 'dart:io';

/// Dificuldade do jogo (afeta multiplicadores de XP e HP inimigo)
enum Dificuldade { recruta, normal, veterano }

/// Gerencia criação de personagem e seleção de dificuldade
class CriacaoPersonagem {
  String? nomePersonagem;
  Dificuldade dificuldade = Dificuldade.normal;

  /// Executa fluxo: dificuldade → nome do herói
  void executar() {
    _selecionarDificuldade();  // ← primeiro: escolhe dificuldade
    _criarPersonagem();         // ← segundo: escolhe nome
  }

  /// Menu de dificuldade com descriptions claras
  void _selecionarDificuldade() {
    print('\n╔════════════════════════════════════════╗');
    print('║    ESCOLHA SEU NÍVEL DE DIFICULDADE    ║');
    print('╠════════════════════════════════════════╣');
    print('║ [1]  RECRUTA (recomendado iniciante) ║');
    // ← para aprender
    print('║     +50% XP, inimigos -20% saúde      ║');
    print('║                                        ║');
    print('║ [2]   NORMAL (balanço perfeito)      ║');
    // ← recomendado
    print('║     1x XP, dificuldade média           ║');
    print('║                                        ║');
    print('║ [3]  VETERANO (para desafiadores)    ║');
    // ← para veteranos
    print('║     -50% XP, inimigos +30% saúde      ║');
    print('╚════════════════════════════════════════╝\n');

    stdout.write('Escolha (1-3): ');
    final escolha = stdin.readLineSync() ?? '2';

    // ← enum switch garante type safety
    dificuldade = switch (escolha) {
      '1' => Dificuldade.recruta,
      '3' => Dificuldade.veterano,
      _ => Dificuldade.normal,  // ← default seguro
    };

    print('\nDificuldade: ${dificuldade.name.toUpperCase()}');
  }

  /// Menu de criação de personagem (nome personalizado)
  void _criarPersonagem() {
    print('\n╔════════════════════════════════════════╗');
    print('║        CRIE SEU PERSONAGEM             ║');
    print('╚════════════════════════════════════════╝\n');

    stdout.write('Qual é o nome do seu herói? ');
    // ← padrão se vazio
    nomePersonagem = stdin.readLineSync() ?? 'Aventureiro Sem Nome';

    print('\nBem-vindo, $nomePersonagem!');
    print('Sua jornada na masmorra começa agora...\n');
  }
}
```

**Saída esperada ao criar personagem:**

```text
╔══════════════════════════════════════════════════════════════╗
║    ESCOLHA SEU NÍVEL DE DIFICULDADE                          ║
╠══════════════════════════════════════════════════════════════╣
║ [1]  RECRUTA (recomendado iniciante)                         ║
║     +50% XP, inimigos -20% saúde                             ║
║                                                              ║
║ [2]   NORMAL (balanço perfeito)                              ║
║     1x XP, dificuldade média                                 ║
║                                                              ║
║ [3]  VETERANO (para desafiadores)                            ║
║     -50% XP, inimigos +30% saúde                             ║
╚══════════════════════════════════════════════════════════════╝

Escolha (1-3): 2

Dificuldade: NORMAL

╔══════════════════════════════════════════════════════════════╗
║        CRIE SEU PERSONAGEM                                   ║
╚══════════════════════════════════════════════════════════════╝

Qual é o nome do seu herói? Guerreiro

Bem-vindo, Guerreiro!
Sua jornada na masmorra começa agora...
```

## Classe MasmorraAscii: Orquestrador Mestre

A classe `MasmorraAscii` é o pico da pirâmide. Ela orquestra TUDO: menu, criação de personagem, *loop* de exploração, transições de andar, combate, vitória/derrota. É o maestro que coordena 27 capítulos de aprendizado em uma experiência coesa.

**Design:** MasmorraAscii não implementa lógica de combate, geração de mapa, ou progressão. Ela apenas *orquestra*: chama outras classes, processa entrada, renderiza. Isto é separação de responsabilidades (Single Responsibility Principle): cada classe faz uma coisa bem. MasmorraAscii faz uma coisa: coordenar o fluxo principal.

```dart
// lib/masmorra_ascii.dart
import 'jogador.dart';
import 'dungeon_multi_andar.dart';
import 'menu_principal.dart';
import 'criacao_personagem.dart';
import 'dart:io';

/// `DungeonMultiAndar`: lógica de múltiplos andares do Cap. 26.
/// Gera andares, gerencia transições e integra com o jogador.
/// Dificuldade cresce por andar (mais HP e itens raros ao descer).

/// A classe maestro que orquestra o jogo inteiro
/// ← Design: não implementa lógica, apenas coordena
class MasmorraAscii {
  late Jogador jogador;
  late DungeonMultiAndar dungeon;
  late MenuPrincipal menu;

  MasmorraAscii() {
    menu = MenuPrincipal();
  }

  /// Executa o jogo completo: menu → criação → exploração → fim
  /// ← Loop infinito: fica no menu até sair ou jogar
  void executar() {
    while (true) {
      final opcao = menu.exibir();

      switch (opcao) {
        case '1':
          _novoJogo();  // ← inicia jogo completo
          break;
        case '2':
          MenuPrincipal.mostrarComoJogar();  // ← instruções
          break;
        case '3':
          MenuPrincipal.mostrarCreditos();  // ← créditos
          break;
        case '0':
          print('\nObrigado por jogar Masmorra ASCII!');
          exit(0);  // ← sai
        default:
          print('Opção inválida!');
      }
    }
  }

  /// Novo jogo: criação de personagem → exploração
  void _novoJogo() {
    // ← Stage 1: Criação de personagem
    final criacaoPersonagem = CriacaoPersonagem();
    criacaoPersonagem.executar();

    // ← Stage 2: Inicializa jogador com stats base
    jogador = Jogador(
      nome: criacaoPersonagem.nomePersonagem!,
      hpMax: 50,
      ataque: 5,
    );

    final dificuldade = criacaoPersonagem.dificuldade;

    // ← Stage 3: Gera dungeon com dificuldade selecionada
    dungeon = DungeonMultiAndar(jogador: jogador);

    dungeon.gerarAndar();  // ← gera primeiro andar
    _loopExploracaoPrincipal();  // ← entra no loop principal
  }

  /// Loop principal de exploração (repete até vitória/derrota/quit)
  void _loopExploracaoPrincipal() {
    print('\n${dungeon.gerenciadorAndares.descreverAndar(0)}\n');

    while (true) {
      _renderizar();  // ← desenha mapa + HUD

      stdout.write('> ');
      final comando = stdin.readLineSync() ?? 'nada';

      // ← processa entrada
      final continua = _processarComando(comando);
      if (!continua) break;  // ← sai se quit/morte/vitória
    }
  }

  /// Renderiza mapa + status do jogador
  void _renderizar() {
    dungeon.renderizar();  // ← desenha mapa ASCII
    dungeon.mostrarHud();  // ← mostra HP, nível, XP
  }

  /// Processa comando do jogador (movimento, ação, etc)
  /// ← Retorna false para sair do loop
  bool _processarComando(String cmd) {
    final partes = cmd.toLowerCase().split(' ');
    final acao = partes[0];

    switch (acao) {
      case 'w':  // ← move norte
        dungeon.moverJogador(0, -1);
        return true;
      case 's':  // ← move sul
        dungeon.moverJogador(0, 1);
        return true;
      case 'a':  // ← move oeste
        dungeon.moverJogador(-1, 0);
        return true;
      case 'd':  // ← move leste
        dungeon.moverJogador(1, 0);
        return true;
      case '>':  // ← desce escada
        dungeon.descerAndar();
        return true;
      case 'i':  // ← inventário
        dungeon.mostrarInventario();
        return true;
      case 'status':  // ← status detalhado
        dungeon.mostrarStatus();
        return true;
      case 'quit':  // ← abandona
        print('Você abandona a masmorra cobardemente...');
        return false;  // ← sai do loop
      default:
        print('Comando desconhecido.');
        return true;
    }
  }
}

/// Ponto de entrada: cria jogo e executa
void main() {
  final jogo = MasmorraAscii();
  jogo.executar();  // ← inicia máquina de estados do jogo
}
```

**Fluxo de execução (resumido):**

```text
main()
  ↓
MasmorraAscii.executar() [loop infinito]
  ↓
menu.exibir()
  ↓
[1] _novoJogo()
    ↓
    CriacaoPersonagem
      ↓ escolhe dificuldade e nome
    Cria Jogador
      ↓
    DungeonMultiAndar.gerarAndar()
      ↓
    _loopExploracaoPrincipal() [loop até morte/vitória]
      ↓
      _renderizar() + _processarComando()
        ↓ repete
```

**Nota técnica:** O método `main()` é o entry point do Dart. Você executa o programa digitando `dart bin/main.dart` e o Dart chama `main()`. Dentro, você cria a instância de `MasmorraAscii` e chama `executar()`.

## Por Que Não...?

Você pode perguntar: "Por que uma classe `MasmorraAscii` centralizadora? Por que não deixar `DungeonMultiAndar` gerenciar tudo?" Resposta técnica e reflexão sobre design:

### Por Que Não Sistemas Independentes Sem Coordenador?

Se cada sistema (menu, dungeon, combate, loja) rodasse isoladamente sem coordenação central, você teria:

1. **Transições caóticas:** Como o menu sabe quando começar um jogo? Como o dungeon sabe quando retornar ao menu? Sem coordenador, cada sistema grita para todos. Resulta em código espaguete acoplado.

2. **Estado inconsistente:** Menu tem uma instância de `Jogador`, dungeon tem outra. Duas verdades simultâneas. Bugs surtem do nada porque dados não sincronizam.

3. **Fluxo indefinido:** Um loop no menu, outro no dungeon, outro na loja. Múltiplos eventos rodando concorrentemente sem coordenação = racing conditions e deadlocks.

A solução é o padrão **Coordinator** (ou **Orchestrator**). Uma classe central (`MasmorraAscii`) que conhece cada subsistema e coordena: "Menu, exiba. Jogador clicou '1'. Dungeon, inicie andar 1. Loja, apareça quando entrar em sala especial. Combate, resolva este turno." Uma verdade única, fluxo explícito, estado sincronizado.

### Por Que Não Herança Para as Fases do Jogo?

Você poderia modelar: `class MenuPrincipal extends FaseJogo`, `class Exploração extends FaseJogo`, `class CombateBoss extends FaseJogo`. Todos herdando de uma `FaseJogo` base com `executar()` abstrato.

Problema: herança é frágil. Se adicionar uma propriedade ao `FaseJogo` (ex: `bool pausado`), todas as subclasses precisam entender e atualizar. Se quiser compartilhar lógica entre menu e créditos sem compartilhar com dungeon, herança força hierarquias artificiais. Composition é melhor: `MasmorraAscii` **compõe** `MenuPrincipal` e `DungeonMultiAndar` como campos, sem herança. Cada um é independente. Cada um é testável isoladamente. Se um quebra, outro não sofre. Isto é flexibilidade verdadeira.

### Por Que Não Máquina de Estados Global?

Um estado gigante `enum GamePhase { menu, exploração, combate, loja, boss, gameover }` com um `switch` gigante processando tudo.

Problema: você teria um método central de 500+ linhas tentando orquestrar tudo. Mudança em um estado afeta dez outros. É impossível entender sem ler o arquivo inteiro. Divisão de responsabilidades quebra. Cada classe (`MenuPrincipal`, `DungeonMultiAndar`) já é uma máquina de estados interna. `MasmorraAscii` apenas coordena as máquinas, não é uma super-máquina.

**A lição:** Bom design é sobre coesão (cada classe faz uma coisa bem) e acoplamento baixo (classes não dependem uma da outra). `MasmorraAscii` é o acoplador consciente que conecta peças desacopladas de forma clara.

## A Jornada Completa

Você começou no capítulo 7 com um texto-*adventure* simples. Agora você tem:

- Capítulo 8-12: Fundações de OOP, entidades, combate por turnos
- Capítulo 13-17: Mapas procedurais (BSP), campo de visão, UI ASCII
- Capítulo 18-21: Inventário, itens, equipamento, economia
- Capítulo 22-24: Sistema de eventos, loja, transações
- Capítulo 25-27: Progressão (XP/*level up*), habilidades, múltiplos andares, *boss* final

De 27 capítulos, você transformou conceitos de programação acadêmicos em um produto jogável profissional.

**Compare com um protótipo:**

Capítulo 7: "Um herói caminha num mapa. Clica em inimigo, ambos atacam."

Capítulo 27: "Um herói sobe de nível, desbloqueia habilidades, desce 5 andares cada vez mais difíceis, enfrenta um chefe com 3 fases, e ao vencer, vê uma tela de celebração com suas estatísticas."

Isto é evolução exponencial.

## Comparação: Capítulo 7 vs. Capítulo 27

### Capítulo 7 (Protótipo)

```dart
// Simplesmente cria herói e inimigo, combate direto
final jogador = Jogador(hpMax: 20, ataque: 3);
final inimigo = Zumbi(hpMax: 10, ataque: 1);

while (jogador.estaVivo && inimigo.estaVivo) {
  jogador.atacar(inimigo);
  inimigo.atacar(jogador);
}
```

Resultado: Um combate único. Nenhuma progressão, nenhuma escolha, nenhum objetivo claro.

### Capítulo 27 (Produto)

```dart
final jogo = MasmorraAscii();
jogo.executar();  // Menu → criação → 5 andares → boss → vitória/derrota
```

Resultado: Uma campanha completa com 27 capítulos de estrutura, fluxo, psicologia de design.

**A diferença:** Código cresceu não em quantidade, mas em organização. Protótipo é 50 linhas bagunçadas. Produto é 5000 linhas bem estruturadas. Qualidade não vem de código maior; vem de código bem organizado.

## Pergaminho do Capítulo

Neste capítulo, você aprendeu:

- `MasmorraAscii` orquestra o jogo inteiro (padrão *Coordinator*)
- Menu principal oferece opções: novo jogo, instruções, créditos (UX)
- `CriacaoPersonagem` gerencia dificuldade e nome do herói (personalização)
- *Loop* principal processa comandos e renderiza a tela (máquina de estados)
- Integração perfeita entre todos os sistemas anteriores (arquitetura)
- Um *roguelike* completo, de menu até vitória/derrota (produto)

Você não apenas aprendeu Dart; você criou um produto real, profissional, jogável, e extensível.

**A maior lição:** Desenvolvimento de software é 10% código, 90% design. Você aprendeu arquitetura, não apenas sintaxe.

## Dica Profissional

::: dica
**Dica do Mestre:** De agora em diante, a manutenção é contínua. Reúna feedback de jogadores reais (amigos, comunidades online, fóruns). O que é muito difícil? Muito fácil? Chato? Que tipo de jogador desiste primeiro? Cada feedback é uma oportunidade para melhorar. Iteração rápida (teste → feedback → ajuste) é como você vai de "produto acadêmico" para "jogo verdadeiramente bom". Ouça seus jogadores. Dados sempre vencem intuição, mas feedback qualitativo frequentemente revela a verdade que dados não capturam.
:::

## Próximas Etapas

Este é o fim da Parte IV, o fim da jornada do código para o produto. Na Parte V (que está além deste livro), você pode explorar:

- Persistência (salvar/carregar jogo com dados)
- Modos adicionais (*endless mode*, *hard mode*, *survival*)
- Achievements e estatísticas de longa duração
- Multiplayer (quem consegue mais ouro? mais andares?)
- Novas criaturas, itens, habilidades desbloqueáveis
- Refatoração e testes completos (unit tests, integration tests)
- Distribuição como executável (compilar para diferentes plataformas)
- Publicação em repositório (GitHub, para comunidade contribuir)

Mas por agora, você tem um jogo completo. Jogue-o. Mostre aos seus amigos. Aperfeiçoe-o baseado no feedback real. E acima de tudo, celebre o caminho que você trilhou: do "Hello, World" até um *roguelike* funcional com economia, progressão, múltiplos andares, inimigos dinâmicos com IA, e um *boss* épico com fases.

***

## Fechamento

Parabéns! Você não é mais um aprendiz de programação. Você é um desenvolvedor de jogos em Dart que criou um *roguelike* funcional, com economia robusta, progressão escalável, múltiplos inimigos com comportamentos diferentes, um *boss* épico com 3 fases, e uma campanha completa de 5 andares.

**O que você aprendeu:**

- Arquitetura de software (separação de responsabilidades, padrões de design)
- Programação orientada a objetos em Dart (classes, herança, polimorfismo)
- Estruturas de dados complexas (generics, sealed classes, enums)
- Algoritmos (geração procedural, busca de caminho, campo de visão)
- Design de jogos (progressão, balanceamento, UX, psicologia do jogador)

**O que você pode fazer agora:**

Pegue um dos 27 desafios propostos ao longo do livro e implemente. Escolha o que te interessa mais. Quer adicionar mais habilidades? Novos inimigos? Um sistema de magia? Um modo endless? Escolhe um desafio, implementa, testa com amigos, recolhe feedback.

A jornada continua. Cada sistema que você construiu pode ser expandido, aperfeiçoado, testado. A aventura nunca termina.

Bem-vindo ao mundo da criação. Que suas masmorras sejam épicas, seus *bosses* memoráveis, e seus aventureiros lendários.

**Que a programação seja com você!**

### O Jogo Até Aqui

Ao final desta parte, seu jogo completo no terminal se parece com isto:

```text

MASMORRA ASCII
───────────────────────────────────────
Uma Epopeia Roguelike em Dart

Bem-vindo, aventureiro! Você está prestes a descer numa masmorra
antiga repleta de perigos, tesouros e poderes esquecidos.

Preparado para a jornada?

MENU PRINCIPAL
───────────────────────────────────────
  [1]  Novo Jogo
  [2]  Como Jogar
  [3]  Créditos
  [0]  Sair

Escolha: 1

ESCOLHA SEU NÍVEL DE DIFICULDADE
────────────────────────────────────────
[1]  RECRUTA (recomendado iniciante)
     +50% XP, inimigos -20% saúde

[2]   NORMAL (balanço perfeito)
     1x XP, dificuldade média

[3]  VETERANO (para desafiadores)
     -50% XP, inimigos +30% saúde

Escolha (1-3): 2

Dificuldade: NORMAL

CRIE SEU PERSONAGEM
────────────────────────────────────────

Qual é o nome do seu herói? Aventureiro

Bem-vindo, Aventureiro!
Sua jornada na masmorra começa agora...
```

Cada parte adiciona novas camadas ao jogo. Compare com o início e veja o quanto você evoluiu!

***

## Desafios da Masmorra

**Desafio 27.1. Seu Reino, Seu Brasão.** O menu principal é a porta de entrada para seu mundo. Personalize o ASCII art: adicione seu nome, símbolo único, padrão visual que represente seu jogo. Mude de `MASMORRA ASCII` genérico para algo memorável. Execute, veja a tela inicial—deve inspirar aventura. Dica: use ASCII art criativo, espaçamento interessante, e títulos impactantes para criar identidade visual.

**Desafio 27.2. A Descida Sem Fim.** Após derrotar o boss no andar 5, você pode escolher: sair com vitória ou continuar descendo. Implemente modo "Endless": andares 6, 7, 8... aparecem com escalação infinita. Boss fica 5% mais forte a cada andar adicional. Opção no menu: "Campanha Clássica (5 andares)" vs "Modo Endless (sem limite)". Teste: vencedor pode ficar até andar 20? Quanto consegue?. Dica: `if (andar > 5) permitirContinuarOuSair()`.

**Desafio 27.3. Seus Recordes.** O jogo memoriza seus feitos. Implemente um arquivo `stats.txt` que salva **records** globais: maior nível atingido, ouro máximo coletado em uma partida, mais inimigos derrotados, andar mais profundo. Ao iniciar, carregue e mostre no menu: "Seu Recorde: Nível 8, 15000 ouro". Teste: vença 3 partidas diferentes, veja os recordes atualizarem. Dica: serialize `Record` para JSON, salve e carregue com `File`.

**Desafio 27.4. Seu Jogo, Suas Regras.** Iniciantes podem querer jogo mais fácil. Implemente submenu "Customização": ajuste multiplicadores de HP de inimigos (0.5x até 2.0x), XP ganho (0.5x até 2.0x), preços na loja (0.5x até 2.0x). Mostre preview: "Com essas mudanças, inimigos terão 50% HP". Teste: crie dois savefiles, um fácil (0.5x tudo), um insano (2.0x tudo). Compare dificuldade. Dica: armazene multiplicadores em um objeto `ConfigJogo`.

**Desafio 27.5. (Desafio): Corrida Contra o Tempo.** Speedrunners amam desafios timeboxed. Implemente "Speedrun Mode": você tem 10 minutos reais para derrotar o boss. Após o limite, o boss fica 10% mais forte a cada minuto. Timer na HUD conta de trás para frente. Teste: consegue vencer em 8 minutos? O que acontece após 10? Dica: use `Stopwatch` para rastrear tempo, atualize força do boss por `1.0 + ((tempoPassado - 600) / 60) * 0.10`.

**Boss Final 27.6. Economia Equilibrada.** Conforme desce, itens na loja ficam mais caros (fornecedor remoto cobra mais para trazer itens ao fundo). Implemente: preços aumentam 5% por andar (andar 0 = base, andar 5 = +25%). MAS aumente drops também (+5% ouro por andar, ou itens raros aparecem mais). Teste: descida ao andar 5 deve se sentir viável economicamente, não trapaceado. Dica: cálculo final = `precoBase * (1.0 + andar * 0.05)`, depois balance drops.

***

## Próximo Capítulo

Aqui termina a Parte IV. Você tem um jogo jogável de ponta a ponta: criação de personagem, descida por cinco andares de masmorra procedural, combate tático, economia funcional, loja, progressão de nível, boss final, tela de vitória e menu principal. É um roguelike completo, que um amigo pode baixar, rodar e jogar até o fim.

Mas o código que construiu esse jogo cresceu orgânico, capítulo a capítulo, feature a feature. Há arquivos grandes demais, funções que fazem coisa demais, duplicações que se acumularam pelo caminho, e quase nenhum teste automatizado para proteger o que já funciona. O jogo *funciona*. O código ainda não é *profissional*.

Na Parte V — **A Forja do Código** — você vai pegar esse mesmo jogo e passá-lo pelo martelo e pela bigorna da engenharia de software: reorganização modular, testes unitários que travam regressões, `async`/`await` para operações não bloqueantes, e persistência com JSON para salvar e carregar a jornada entre sessões. O jogo não ganhará uma única feature nova visível para o jogador — e, ainda assim, vai sair da forja mais forte, mais leve e pronto para durar.

No próximo capítulo, abrimos a forja.

