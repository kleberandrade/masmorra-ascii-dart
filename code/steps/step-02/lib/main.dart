import 'dart:io';

void exibirBanner() {
  print('');
  print('╔══════════════════════════════════╗');
  print('║       MASMORRA ASCII v0.1        ║');
  print('╚══════════════════════════════════╝');
  print('');
}

String pedirNome() {
  stdout.write('Como devo chamá-lo? ');
  var nome = stdin.readLineSync() ?? 'Aventureiro';
  return nome.trim();
}

void saudar(String nome) {
  print('');
  print('Bem-vindo à Masmorra, $nome!');
  print('Que os dados estejam ao seu favor.');
  print('');
}

void descreverSala(String nome) {
  print('');
  print('═══════════════════════════════════');
  print(' $nome, você está na Praça Central.');
  print('');
  print(' Uma fonte de pedra murmura ao centro');
  print(' da praça. Tochas iluminam três saídas.');
  print('');
  print(' Ao norte: um corredor escuro.');
  print(' A leste: uma porta de madeira.');
  print(' Ao sul: a saída da masmorra.');
  print('═══════════════════════════════════');
  print('');
}

String pedirComando() {
  stdout.write('O que deseja fazer? ');
  var comando = stdin.readLineSync() ?? '';
  return comando.trim().toLowerCase();
}

void responderComando(String comando) {
  if (comando == 'norte' || comando == 'n') {
    print('Você caminha para o norte...');
    print('O corredor é frio e úmido.');
  } else if (comando == 'leste' || comando == 'l') {
    print('Você empurra a porta de madeira...');
    print('Rangidos ecoam pelo corredor.');
  } else if (comando == 'sul' || comando == 's') {
    print('Você recua para a saída.');
    print('A luz do sol aquece seu rosto.');
  } else if (comando == 'sair') {
    print('Até a próxima aventura!');
  } else {
    print('Não entendi "$comando".');
    print('Tente: norte, leste, sul ou sair.');
  }
  print('');
}

void main() {
  exibirBanner();
  var nome = pedirNome();
  saudar(nome);
  descreverSala(nome);
  var comando = pedirComando();
  responderComando(comando);
}
