# Capítulo 27 - Dungeon Run Completo: A Jornada Épica

> *Até agora, você construiu peças: movimento, combate, progressão, andares, um boss. Mas peças isoladas não fazem um jogo. Agora junta tudo numa máquina que funciona. Do menu inicial até a vitória ou morte final. Isto é completude. Isto é um produto jogável, pronto para ser compartilhado. Este capítulo é a celebração de tudo que aprendeu.*

## O Que Vamos Aprender

Neste capítulo (o pico da Parte IV) você vai:

- Criar a classe `MasmorraAscii`, o orquestrador mestre de todo o jogo
- Implementar o menu principal com ASCII art épico
- Criar seleção de dificuldade (Recruta / Normal / Veterano)
- Integrar criação de personagem (nome + atributos)
- Implementar o loop completo: menu → exploração → combate → progressão → andares → boss → vitória/derrota
- Demonstrar uma sessão de jogo completa com geração procedural
- Comparar a evolução desde o Capítulo 7 até agora
- Refletir sobre a jornada: do acadêmico ao produto profissional

Ao final, você terá um jogo roguelike completo e jogável. Pronto para distribuir, ensinar, expandir.

## Menu Principal

Todo jogo profissional começa com um menu. A classe `MenuPrincipal` desenha ASCII art bonita que diz bem-vindo, oferece opções: novo jogo, instruções, créditos, sair. Isto é o rosto do seu jogo. Deixa claro o que é, cria atmosfera.

```dart
// lib/menu_principal.dart

import 'dart:io';

/// Menu principal do jogo
class MenuPrincipal {
  String exibir() {
    _limpar();

    print('''
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║                         MASMORRA ASCII                                    ║
║                                                                            ║
║                      Uma Epopeia Roguelike em Dart                         ║
║                                                                            ║
╠════════════════════════════════════════════════════════════════════════════╣
║                                                                            ║
║   Bem-vindo, aventureiro! Você está prestes a descer numa masmorra        ║
║   antiga repleta de perigos, tesouros e poderes esquecidos.              ║
║                                                                            ║
║   Preparado para a jornada?                                               ║
║                                                                            ║
╠════════════════════════════════════════════════════════════════════════════╣
║                            MENU PRINCIPAL                                  ║
║                                                                            ║
║   [1]  Novo Jogo                                                          ║
║   [2]  Como Jogar                                                         ║
║   [3]  Créditos                                                           ║
║   [0]  Sair                                                               ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝

    ''');

    stdout.write('Escolha: ');
    return stdin.readLineSync() ?? '0';
  }

  void _limpar() {
    for (int i = 0; i < 50; i++) {
      print('');
    }
  }

  static void mostrarComoJogar() {
    print('''
╔════════════════════════════════════════════════════════════════════════════╗
║                          COMO JOGAR                                        ║
╠════════════════════════════════════════════════════════════════════════════╣
║                                                                            ║
║  MOVIMENTO:                                                                ║
║    W  - Norte     S  - Sul     A  - Oeste    D  - Leste                   ║
║                                                                            ║
║  AÇÕES:                                                                    ║
║    >      - Descer escada                                                 ║
║    i      - Inventário                                                    ║
║    status - Ver status                                                    ║
║    quit   - Abandonar jogo                                                ║
║                                                                            ║
║  PROGRESSÃO:                                                               ║
║    • Derrota inimigos para ganhar XP                                       ║
║    • Colete itens e ouro                                                  ║
║    • Suba de nível para desbloquear habilidades                           ║
║    • Chegue ao andar 5 e derrote o Rei da Masmorra!                       ║
║                                                                            ║
║  DIFICULDADES:                                                             ║
║    Recruta:   +50% XP, inimigos mais fracos (treino)                      ║
║    Normal:    Balanço perfeito (recomendado)                              ║
║    Veterano:  -50% XP, inimigos mais fortes (desafio!)                    ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝

    ''');

    stdout.write('Pressione ENTER para voltar ao menu...');
    stdin.readLineSync();
  }

  static void mostrarCreditos() {
    print('''
╔════════════════════════════════════════════════════════════════════════════╗
║                          CRÉDITOS                                          ║
╠════════════════════════════════════════════════════════════════════════════╣
║                                                                            ║
║  MASMORRA ASCII, Uma Epopeia de Aprendizado                              ║
║                                                                            ║
║  Desenvolvido com Dart e ensino de programação como foco central          ║
║                                                                            ║
║  SISTEMAS IMPLEMENTADOS:                                                   ║
║    • Geração procedural de dungeon (algoritmo BSP)                         ║
║    • Sistema completo de combate por turnos                               ║
║    • Progressão com XP e habilidades desbloqueáveis                        ║
║    • 5 andares com dificuldade crescente                                  ║
║    • Chefão final com sistema de fases                                     ║
║    • Interface ASCII com barras de saúde                                  ║
║    • Sistema de economia (ouro, loja, itens)                              ║
║                                                                            ║
║  CONCEITOS DART ENSINADOS:                                                 ║
║    • Programação orientada a objetos (classes, herança)                    ║
║    • Polimorfismo e métodos abstratos                                     ║
║    • Sealed classes e enums                                               ║
║    • Generics e type parameters                                           ║
║    • Pattern matching em Dart 3                                           ║
║    • Event systems e padrões de design                                    ║
║                                                                            ║
║  DESENVOLVIDO EM: Dart 3.0+                                               ║
║                                                                            ║
║  AGRADECIMENTOS:                                                           ║
║    A todos os aventureiros que jogam, aprendem e criam!                   ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝

    ''');

    stdout.write('Pressione ENTER para voltar ao menu...');
    stdin.readLineSync();
  }
}
```

## Seleção de Dificuldade e Criação de Personagem

Antes de começar, você escolhe: quer treino (recruta, +50% XP, inimigos mais fracos), balanço perfeito (normal), ou desafio extremo (veterano, -50% XP, inimigos mais fortes)? Depois, digita o nome do seu herói. Isto personaliza a jornada: é SEU herói, não um genérico.

```dart
// lib/criacao_personagem.dart

import 'dart:io';

/// Dificuldade do jogo
enum Dificuldade { recruta, normal, veterano }

/// Gerencia criação de personagem e seleção de dificuldade
class CriacaoPersonagem {
  String? nomePersonagem;
  Dificuldade dificuldade = Dificuldade.normal;

  void executar() {
    _selecionarDificuldade();
    _criarPersonagem();
  }

  void _selecionarDificuldade() {
    print('\n╔════════════════════════════════════════╗');
    print('║    ESCOLHA SEU NÍVEL DE DIFICULDADE    ║');
    print('╠════════════════════════════════════════╣');
    print('║ [1]  RECRUTA (recomendado iniciante) ║');
    print('║     +50% XP, inimigos -20% saúde      ║');
    print('║                                        ║');
    print('║ [2]   NORMAL (balanço perfeito)      ║');
    print('║     1x XP, dificuldade média           ║');
    print('║                                        ║');
    print('║ [3]  VETERANO (para desafiadores)    ║');
    print('║     -50% XP, inimigos +30% saúde      ║');
    print('╚════════════════════════════════════════╝\n');

    stdout.write('Escolha (1-3): ');
    final escolha = stdin.readLineSync() ?? '2';

    dificuldade = switch (escolha) {
      '1' => Dificuldade.recruta,
      '3' => Dificuldade.veterano,
      _ => Dificuldade.normal,
    };

    print('\nDificuldade: ${dificuldade.name.toUpperCase()}');
  }

  void _criarPersonagem() {
    print('\n╔════════════════════════════════════════╗');
    print('║        CRIE SEU PERSONAGEM             ║');
    print('╚════════════════════════════════════════╝\n');

    stdout.write('Qual é o nome do seu herói? ');
    nomePersonagem = stdin.readLineSync() ?? 'Aventureiro Sem Nome';

    print('\nBem-vindo, $nomePersonagem!');
    print('Sua jornada na masmorra começa agora...\n');
  }
}
```

## Classe MasmorraAscii: Orquestrador Mestre

A classe `MasmorraAscii` é o pico da pirâmide. Ela orquestra TUDO: menu, criação de personagem, loop de exploração, transições de andar, combate, vitória/derrota. É o mestre que coordena 27 capítulos de aprendizado em uma experiência coesa.

```dart
// lib/masmorraAscii.dart

import 'jogador.dart';
import 'dungeonMultiAndar.dart';
import 'menuPrincipal.dart';
import 'criacaoPersonagem.dart';
import 'dart:io';

/// A classe `DungeonMultiAndar` encapsula a lógica de múltiplos andares do Capítulo 26:
/// Gerencia a geração procedural de andares, transições, e integração com o jogador.
/// Cada andar tem dificuldade progressiva (mais HP para inimigos, mais itens raros conforme desce).

/// A classe máster que orquestra o jogo inteiro
class MasmorraAscii {
  late Jogador jogador;
  late DungeonMultiAndar dungeon;
  late MenuPrincipal menu;

  MasmorraAscii() {
    menu = MenuPrincipal();
  }

  /// Executa o jogo completo: menu → criação → exploração → fim
  void executar() {
    while (true) {
      final opcao = menu.exibir();

      switch (opcao) {
        case '1':
          _novoJogo();
          break;
        case '2':
          MenuPrincipal.mostrarComoJogar();
          break;
        case '3':
          MenuPrincipal.mostrarCreditos();
          break;
        case '0':
          print('\nObrigado por jogar Masmorra ASCII!');
          exit(0);
        default:
          print('Opção inválida!');
      }
    }
  }

  /// Novo jogo: criação de personagem → dungeons
  void _novoJogo() {
    final criacaoPersonagem = CriacaoPersonagem();
    criacaoPersonagem.executar();

    jogador = Jogador(
      nome: criacaoPersonagem.nomePersonagem!,
      hpMax: 50,
      ataque: 5,
    );

    final dificuldade = criacaoPersonagem.dificuldade;

    dungeon = DungeonMultiAndar(jogador: jogador);

    dungeon.gerarAndar();
    _loopExploracaoPrincipal();
  }

  /// Loop principal de exploração
  void _loopExploracaoPrincipal() {
    print('\n${dungeon.gerenciadorAndares.descreverAndar(0)}\n');

    while (true) {
      _renderizar();

      stdout.write('> ');
      final comando = stdin.readLineSync() ?? 'nada';

      final continua = _processarComando(comando);
      if (!continua) break;
    }
  }

  void _renderizar() {
    dungeon.renderizar();
    dungeon.mostrarHud();
  }

  bool _processarComando(String cmd) {
    final partes = cmd.toLowerCase().split(' ');
    final acao = partes[0];

    switch (acao) {
      case 'w':
        dungeon.moverJogador(0, -1);
        return true;
      case 's':
        dungeon.moverJogador(0, 1);
        return true;
      case 'a':
        dungeon.moverJogador(-1, 0);
        return true;
      case 'd':
        dungeon.moverJogador(1, 0);
        return true;
      case '>':
        dungeon.descerAndar();
        return true;
      case 'i':
        dungeon.mostrarInventario();
        return true;
      case 'status':
        dungeon.mostrarStatus();
        return true;
      case 'quit':
        print('Você abandona a masmorra cobardemente...');
        return false;
      default:
        print('Comando desconhecido.');
        return true;
    }
  }
}

void main() {
  final jogo = MasmorraAscii();
  jogo.executar();
}
```

## A Jornada Completa

Você começou no capítulo 7 com um texto-adventure simples. Agora você tem:

- Capítulo 8-12: Fundações de OOP, entidades, combate
- Capítulo 13-17: Mapas procedurais, campo de visão, UI ASCII
- Capítulo 18-21: Inventário, itens, equipamento
- Capítulo 22-27: Economia, loja, eventos, progressão, andares, boss final

De 27 capítulos, você transformou conceitos de programação em um produto jogável.

## Pergaminho do Capítulo

Neste capítulo, você aprendeu:

- `MasmorraAscii` orquestra o jogo inteiro
- Menu principal oferece opções: novo jogo, instruções, créditos
- `CriacaoPersonagem` gerencia dificuldade e nome do herói
- Loop principal processa comandos e renderiza a tela
- Integração perfeita entre todos os sistemas anteriores
- Um roguelike completo, de menu até vitória/derrota

Você não apenas aprendeu Dart; você criou um produto real.

## Dica Profissional

::: dica
De agora em diante, a manutenção é contínua. Reúna feedback de jogadores reais (amigos, comunidades online). O que é muito difícil? Muito fácil? Chato? Cada feedback é uma oportunidade para melhorar. Iteração é como você vai de "produto acadêmico" para "jogo verdadeiramente bom". Ouça seus jogadores.
:::

## Próximas Etapas

Este é o fim da Parte IV, o fim da jornada do código para o produto. Na Parte V (que está além deste livro), você pode explorar:

- Persistência (salvar/carregar jogo)
- Modos adicionais (endless mode, hard mode)
- Achievements e estatísticas
- Multiplayer (quem consegue mais ouro? mais andares?)
- Novas criaturas, itens, habilidades
- Refatoração e testes completos
- Distribuição como executável

Mas por agora, você tem um jogo completo. Jogue-o. Mostre aos seus amigos. Aperfeiçoe-o. E acima de tudo, celebre o caminho que você trilhou: do "Hello, World" até um roguelike funcional com economia, progressão e chefe épico.

***

## Fechamento

Parabéns! Você não é mais um aprendiz de programação. Você é um desenvolvedor de jogos em Dart que criou um roguelike funcional, com economias, progressão, múltiplos inimigos, um boss épico com fases e uma campanha completa.

A jornada continua. Cada sistema que você construiu pode ser expandido, aperfeiçoado, testado. A aventura nunca termina.

Bem-vindo ao mundo da criação. Que suas masmorras sejam épicas, seus bosses memoráveis, e seus aventureiros lendários.

**Que a programação seja com você!**

### O Jogo Até Aqui

Ao final desta parte, seu jogo completo no terminal se parece com isto:

```

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
