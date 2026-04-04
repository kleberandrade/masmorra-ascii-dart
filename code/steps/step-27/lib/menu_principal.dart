import 'dart:io';

/// Menu principal do jogo
class MenuPrincipal {
  String exibir() {
    _limpar();

    print('''
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║                         MASMORRA ASCII                       ║
║                                                              ║
║                      Uma Epopeia Roguelike em Dart           ║
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
    return stdin.readLineSync() ?? '0';
  }

  void _limpar() {
    for (int i = 0; i < 50; i++) {
      print('');
    }
  }

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
║    • Derrota inimigos para ganhar XP                         ║
║    • Colete itens e ouro                                     ║
║    • Suba de nível para desbloquear habilidades              ║
║    • Chegue ao andar 5 e derrote o Rei da Masmorra           ║
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
║    • Geração procedural de dungeon (algoritmo BSP)           ║
║    • Sistema completo de combate por turnos                  ║
║    • Progressão com XP e habilidades desbloqueáveis          ║
║    • 5 andares com dificuldade crescente                     ║
║    • Chefão final com sistema de fases                       ║
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
