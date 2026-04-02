import 'dart:io';

void exibirBanner() {
  print('');
  print('╔══════════════════════════════════════╗');
  print('║        MASMORRA ASCII v0.1           ║');
  print('╚══════════════════════════════════════╝');
  print('');
}

void exibirMenu() {
  print('┌──────────────────────────────────────┐');
  print('│           O QUE DESEJA FAZER?        │');
  print('├──────────────────────────────────────┤');
  print('│  1, Explorar a masmorra             │');
  print('│  2, Ver status do herói             │');
  print('│  3, Ajuda                           │');
  print('│  0, Sair do jogo                    │');
  print('└──────────────────────────────────────┘');
}

void explorar(String nome) {
  print('');
  print('$nome adentra o corredor escuro...');
  print('Tochas fracas iluminam paredes de pedra.');
  print('Você ouve algo se movendo na escuridão.');
  print('(Exploração completa virá nos próximos capítulos.)');
  print('');
}

void mostrarStatus(String nome) {
  print('');
  print('╔══════════════════════════════════╗');
  print('║  HERÓI: $nome');
  print('║  HP: 100/100');
  print('║  Ouro: 0');
  print('║  Arma: Nenhuma');
  print('╚══════════════════════════════════╝');
  print('');
}

void mostrarAjuda() {
  print('');
  print('Masmorra ASCII é um roguelike em texto.');
  print('Use os números do menu para navegar.');
  print('Em breve você poderá explorar masmorras,');
  print('lutar contra monstros e coletar tesouros.');
  print('');
}

void main() {
  exibirBanner();

  stdout.write('Como devo chamá-lo? ');
  var nome = (stdin.readLineSync() ?? '').trim();
  if (nome.isEmpty) nome = 'Aventureiro';

  print('');
  print('Bem-vindo, $nome! Sua jornada começa agora.');

  var jogando = true;

  while (jogando) {
    print('');
    exibirMenu();
    stdout.write('> ');

    var linha = (stdin.readLineSync() ?? '').trim().toLowerCase();

    if (linha.isEmpty) {
      print('Digite uma opção do menu.');
      continue;
    }

    var opcao = int.tryParse(linha);
    if (opcao == null) {
      switch (linha) {
        case 'explorar' || 'jogar':
          opcao = 1;
        case 'status':
          opcao = 2;
        case 'ajuda' || 'help':
          opcao = 3;
        case 'sair' || 'quit':
          opcao = 0;
        default:
          print('Não entendi "$linha". Use os números do menu.');
          continue;
      }
    }

    switch (opcao) {
      case 1:
        explorar(nome);
      case 2:
        mostrarStatus(nome);
      case 3:
        mostrarAjuda();
      case 0:
        jogando = false;
        print('');
        print('Até a próxima aventura, $nome!');
      default:
        print('Opção $opcao não existe. Escolha entre 0 e 3.');
    }
  }
}
