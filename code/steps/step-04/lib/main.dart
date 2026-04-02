import 'dart:io';

/// Lê uma linha do terminal, limpa espaços e converte para minúsculas.
String lerComando() {
  stdout.write('> ');
  var entrada = stdin.readLineSync();

  if (entrada == null) {
    return 'sair';
  }

  return entrada.trim().toLowerCase();
}

/// Tenta interpretar o input como número do menu.
int? interpretarComoNumero(String input) {
  if (input.isEmpty) return null;
  return int.tryParse(input);
}

/// Converte uma palavra em número de menu, se for sinônimo conhecido.
int? interpretarComoPalavra(String input) {
  return switch (input) {
    'explorar' || 'jogar' || 'entrar' => 1,
    'status' || 'heroi' => 2,
    'ajuda' || 'help' => 3,
    'sair' || 'quit' || 'fim' => 0,
    _ => null,
  };
}

/// Interpreta o input do jogador como opção de menu.
int? interpretarInput(String input) {
  return interpretarComoNumero(input) ?? interpretarComoPalavra(input);
}

void exibirBanner() {
  print('');
  print('╔══════════════════════════════════════╗');
  print('║        MASMORRA ASCII v0.1           ║');
  print('╚══════════════════════════════════════╝');
  print('');
}

void mostrarMenu() {
  print('');
  print('┌──────────────────────────────────────┐');
  print('│           O QUE DESEJA FAZER?        │');
  print('├──────────────────────────────────────┤');
  print('│  1, Explorar a masmorra             │');
  print('│  2, Ver status                      │');
  print('│  3, Ajuda                           │');
  print('│  0, Sair do jogo                    │');
  print('└──────────────────────────────────────┘');
}

void main() {
  exibirBanner();

  stdout.write('Como devo chamá-lo? ');
  var nomeEntrada = stdin.readLineSync()?.trim() ?? '';
  var nome = nomeEntrada.isEmpty ? 'Aventureiro' : nomeEntrada;

  print('Bem-vindo, $nome!');

  while (true) {
    mostrarMenu();
    var cmd = lerComando();

    if (cmd.isEmpty) {
      print('Digite algo.');
      continue;
    }

    var opcao = interpretarInput(cmd);

    if (opcao == null) {
      print('Não entendi "$cmd".');
      continue;
    }

    switch (opcao) {
      case 1:
        print('Explorando...');
      case 2:
        print('Status...');
      case 3:
        print('Ajuda...');
      case 0:
        print('Até logo!');
        return;
      default:
        print('Opção inválida.');
    }
  }
}
