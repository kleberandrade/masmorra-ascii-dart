// Masmorra ASCII — Capítulo 37: Síntese

import 'dart:io';

void main() {
  mostrarSplash();
  stdin.readLineSync();
  mostrarMenuPrincipal();
}

void limparTela() {
  // Limpa o terminal: ANSI escape code
  stdout.write('\u001B[2J\u001B[0;0H');
}

void mostrarSplash() {
  limparTela();

  final arte = '''
╔════════════════════════════════════════════════════════╗
║                                                        ║
║           M A S M O R R A   A S C I I                 ║
║                                                        ║
║         Um Roguelike em Dart — Capítulo 37             ║
║                                                        ║
║         De "print('Olá')" até um Jogo Completo        ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
  ''';

  print(arte);
  print('');
  print('          [ Pressione ENTER para continuar ]');
  print('');
}

void mostrarMenuPrincipal() {
  while (true) {
    limparTela();

    final menu = '''
╔════════════════════════════════════════════════════════╗
║                   MENU PRINCIPAL                      ║
╚════════════════════════════════════════════════════════╝

  [1] Novo Jogo
  [2] Continuar Jogo
  [3] Créditos
  [4] Sair

  Escolha uma opção (1-4):
''';

    stdout.write(menu);
    stdout.write('  > ');

    final entrada = stdin.readLineSync()?.trim() ?? '';

    switch (entrada) {
      case '1':
        iniciarNovoJogo();
        break;
      case '2':
        carregarJogo();
        break;
      case '3':
        mostrarCreditos();
        break;
      case '4':
        sair();
        return;
      default:
        mostrarAviso('Opção inválida. Digite 1-4.');
    }
  }
}

void iniciarNovoJogo() {
  limparTela();

  print('');
  print('╔════════════════════════════════════════════════════════╗');
  print('║              NOVO JOGO - CRIAÇÃO DO HERÓI             ║');
  print('╚════════════════════════════════════════════════════════╝');
  print('');

  stdout.write('Como se chama o teu herói? ');
  final nome = stdin.readLineSync()?.trim() ?? 'Aventureiro';

  print('');
  print('Bem-vindo, $nome!');
  print('');
  print('Tua jornada começou. Desce à masmorra...');
  print('');

  print('═══════════════════════════════════════════════════════');
  print('');
  print('ESTATÍSTICAS INICIAIS:');
  print('  HP: 30');
  print('  Defesa: 2');
  print('  Ouro: 10');
  print('  Arma: Punhal enferrujado (dano: 2)');
  print('');
  print('═══════════════════════════════════════════════════════');
  print('');

  print('[ Pressione ENTER para começar a explorar ]');
  stdin.readLineSync();

  mostrarGameplay();
}

void mostrarGameplay() {
  limparTela();

  final gameplay = '''
╔════════════════════════════════════════════════════════╗
║              EXPLORAÇÃO DA MASMORRA                   ║
╚════════════════════════════════════════════════════════╝

VOCÊ:
  HP: 25/30
  Arma: Punhal enferrujado (dano: 2)
  Ouro: 10

LOCAL: Corredor da Masmorra (Andar 1)
  Um corredor de pedra com tochas acesas nas paredes.
  Um bafo frio vem das profundezas.

VISÍVEL:
  - Um Goblin ao longe!
  - Uma pequena bolsa com ouro

AÇÕES:
  [a] Atacar Goblin
  [e] Explorar
  [i] Inventário
  [m] Menu

Escolha uma ação:
''';

  print(gameplay);
  stdout.write('  > ');

  final entrada = stdin.readLineSync()?.trim() ?? 'm';

  switch (entrada) {
    case 'a':
      executarCombate();
      break;
    case 'e':
      explorar();
      break;
    case 'i':
      mostrarInventario();
      break;
    case 'm':
      return; // volta ao menu
    default:
      print('Ação desconhecida.');
      stdin.readLineSync();
      mostrarGameplay();
  }
}

void executarCombate() {
  limparTela();

  print('');
  print('╔════════════════════════════════════════════════════════╗');
  print('║               COMBATE - TURNOS MÚLTIPLOS              ║');
  print('╚════════════════════════════════════════════════════════╝');
  print('');

  print('=== TURNO 1 ===');
  print('Você ataca o Goblin por 2 danos!');
  print('Goblin HP: 5/7');
  print('Goblin ataca você por 1 dano!');
  print('Seu HP: 24/30');
  print('');

  print('=== TURNO 2 ===');
  print('Você ataca o Goblin por 2 danos!');
  print('Goblin HP: 3/7');
  print('Goblin ataca você por 1 dano!');
  print('Seu HP: 23/30');
  print('');

  print('=== TURNO 3 ===');
  print('Você ataca o Goblin por 2 danos!');
  print('Goblin HP: 1/7');
  print('Goblin está desesperado!');
  print('Goblin ataca você por 2 danos!');
  print('Seu HP: 21/30');
  print('');

  print('=== TURNO 4 ===');
  print('Você ataca o Goblin por 2 danos!');
  print('');
  print('╔════════════════════════════════════════════════════════╗');
  print('║                  VITÓRIA!                             ║');
  print('║          O Goblin foi derrotado!                      ║');
  print('║                                                        ║');
  print('║  +3 Ouro                                              ║');
  print('║  +10 Experiência                                      ║');
  print('╚════════════════════════════════════════════════════════╝');
  print('');

  print('[ Pressione ENTER para continuar ]');
  stdin.readLineSync();

  mostrarVitoria();
}

void explorar() {
  limparTela();

  print('');
  print('Você explora o corredor com cuidado...');
  print('Encontra uma bolsa de couro com moedas de ouro!');
  print('+5 Ouro');
  print('');

  print('[ Pressione ENTER para voltar ]');
  stdin.readLineSync();

  mostrarGameplay();
}

void mostrarInventario() {
  limparTela();

  print('');
  print('╔════════════════════════════════════════════════════════╗');
  print('║                  INVENTÁRIO                           ║');
  print('╚════════════════════════════════════════════════════════╝');
  print('');

  print('EQUIPADO:');
  print('  [E] Punhal enferrujado (dano: 2)');
  print('');

  print('MOCHILA:');
  print('  Poção de Vida (restora 20 HP)');
  print('  Maçã');
  print('');

  print('OURO: 13');
  print('');

  print('[ Pressione ENTER para voltar ]');
  stdin.readLineSync();

  mostrarGameplay();
}

void mostrarVitoria() {
  limparTela();

  final tela = '''
╔════════════════════════════════════════════════════════╗
║                   VITÓRIA!                            ║
║                                                        ║
║        Você derrotou o Chefão da Masmorra!           ║
║                                                        ║
╚════════════════════════════════════════════════════════╝

ESTATÍSTICAS DA JORNADA:
  Andares conquistados: 5/5
  Inimigos derrotados: 42
  Ouro coletado: 2.350
  Turnos totais: 287
  Nível final: 8
  Tempo de jogo: ~45 minutos

CONQUISTAS DESBLOQUEADAS:
  ★ Primeira Vitória
  ★ Caçador de Tesouros
  ★ Exterminador
  ★ Vencedor Absoluto

═══════════════════════════════════════════════════════

Parabéns, aventureiro! Você não é mais iniciante.

Deseja jogar novamente? (s/n)
''';

  print(tela);
  stdout.write('  > ');

  final entrada = stdin.readLineSync()?.trim().toLowerCase() ?? 'n';

  if (entrada == 's') {
    iniciarNovoJogo();
  } else {
    mostrarMenuPrincipal();
  }
}

void mostrarCreditos() {
  limparTela();

  final creditos = '''
╔════════════════════════════════════════════════════════╗
║               CRÉDITOS - MASMORRA ASCII               ║
╚════════════════════════════════════════════════════════╝

DESENVOLVIMENTO:
  Programação e Design: Você
  Linguagem: Dart
  Plataforma: Terminal/CLI

JORNADA DE APRENDIZADO:

  Capítulos 1-5:      Fundamentos Dart
                      (variáveis, operadores, listas)

  Capítulos 6-10:     Controle de Fluxo
                      (if/else, loops, funções, closures)

  Capítulos 11-14:    Orientação a Objetos
                      (classes, herança, mixins, enums)

  Capítulos 15-21:    2D, ASCII e Exploração
                      (geração procedural, dungeon crawl)

  Capítulos 22-27:    Economia e Progressão
                      (loja, items, chefe, jogo completo)

  Capítulos 28-33:    Refatoração e Profissionalismo
                      (testes, async/await, save/load)

  Capítulos 34-36:    Padrões de Design
                      (Strategy, Command, Factory,
                       Observer, State)

  Capítulo 37:        Síntese e Próximos Passos
                      (polimento, documentação, reflexão)

═══════════════════════════════════════════════════════

PADRÕES DE DESIGN APRENDIDOS:

  ● Strategy: Comportamentos plugáveis
  ● Command: Ações reversíveis
  ● Factory: Criação centralizada
  ● Observer: Reações desacopladas
  ● State: Máquinas de estado

═══════════════════════════════════════════════════════

AGRADECIMENTOS:

  - Dart, por ser uma linguagem incrível
  - Design Patterns, por nos tornar melhores
  - Você, por persistir até aqui

═══════════════════════════════════════════════════════

REFLEXÃO FINAL:

  "De 'print('Olá')' até um roguelike profissional.
   Você começou aqui. Agora tem ferramentas para
   construir qualquer coisa.

   Não é pouco. É tudo.

   Bem-vindo ao outro lado."

═══════════════════════════════════════════════════════

[ Pressione ENTER para voltar ]
''';

  print(creditos);
  stdin.readLineSync();

  mostrarMenuPrincipal();
}

void carregarJogo() {
  limparTela();

  print('');
  print('╔════════════════════════════════════════════════════════╗');
  print('║              CARREGAR JOGO SALVO                      ║');
  print('╚════════════════════════════════════════════════════════╝');
  print('');

  print('Procurando saves...');
  print('');
  print('✓ Aventureiro (Nível 5, Andar 3)');
  print('✓ Cavaleiro (Nível 7, Andar 4)');
  print('✗ Nenhum outro save encontrado');
  print('');

  print('Qual deseja carregar? (1 ou 2, ou [0] para voltar)');
  stdout.write('  > ');

  final entrada = stdin.readLineSync()?.trim() ?? '0';

  if (entrada == '0') {
    return; // volta ao menu
  }

  print('');
  print('Carregando Aventureiro...');
  print('✓ Jogo carregado com sucesso!');
  print('');

  print('[ Pressione ENTER para continuar ]');
  stdin.readLineSync();

  mostrarGameplay();
}

void mostrarAviso(String mensagem) {
  limparTela();

  print('');
  print('╔════════════════════════════════════════════════════════╗');
  print('║                      AVISO                            ║');
  print('╚════════════════════════════════════════════════════════╝');
  print('');
  print('  $mensagem');
  print('');

  print('[ Pressione ENTER para continuar ]');
  stdin.readLineSync();

  mostrarMenuPrincipal();
}

void sair() {
  limparTela();

  print('');
  print('╔════════════════════════════════════════════════════════╗');
  print('║              ATÉ BREVE, AVENTUREIRO!                  ║');
  print('║                                                        ║');
  print('║       Volte quando estiver pronto para a próxima      ║');
  print('║              grande aventura na masmorra!             ║');
  print('╚════════════════════════════════════════════════════════╝');
  print('');

  exit(0);
}
