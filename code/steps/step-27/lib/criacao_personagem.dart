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
