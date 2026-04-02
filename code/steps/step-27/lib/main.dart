import 'dart:io';
import 'menu_principal.dart';
import 'criacao_personagem.dart';

void main() {
  final menu = MenuPrincipal();

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

void _novoJogo() {
  final charCreation = CriacaoPersonagem();
  charCreation.executar();

  print('\n╔════════════════════════════════════════╗');
  print('║     JOGO INICIANDO...                  ║');
  print('║     (Este é um protótipo de menu)      ║');
  print('╚════════════════════════════════════════╝\n');

  print('Herói: ${charCreation.nomePersonagem}');
  print('Dificuldade: ${charCreation.dificuldade.name}');

  print('\nEste step implementa o menu principal, criação de personagem');
  print('e estrutura base para integrar todos os sistemas anteriores.');
  print('\nNo step-28, o código será organizado em diretórios temáticos.');

  stdout.write('\nPressione ENTER para voltar ao menu...');
  stdin.readLineSync();
}
