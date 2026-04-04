import 'dart:io';

final salas = <String, Map<String, dynamic>>{
  'praca': {
    'descricao': 'Você está na Praça Central.\n'
        'Uma fonte de pedra murmura ao centro.\n'
        'Tochas iluminam três passagens.',
    'saidas': {'norte': 'corredor', 'leste': 'taverna', 'sul': 'portao'},
    'itens': <String>['Chave Enferrujada']
  },
  'corredor': {
    'descricao': 'Um corredor estreito e frio.\n'
        'As paredes são úmidas. Algo se move na escuridão.',
    'saidas': {'sul': 'praca'},
    'itens': <String>[]
  },
  'taverna': {
    'descricao': 'Uma taverna aconchegante.\n'
        'O cheiro de cerveja e pão fresco preenche o ar.\n'
        'Um velho sábio está sentado no canto.',
    'saidas': {'oeste': 'praca'},
    'itens': <String>['Poção de Vida']
  },
  'portao': {
    'descricao': 'Um portão de ferro enorme.\n'
        'Além dele, a escuridão absoluta.\n'
        'Você ainda não está pronto para entrar.',
    'saidas': {'norte': 'praca'},
    'itens': <String>[]
  }
};

final sinonimos = <String, String>{
  'n': 'norte',
  's': 'sul',
  'l': 'leste',
  'o': 'oeste',
  'e': 'leste',
  'w': 'oeste',
  'i': 'inventario',
  'inv': 'inventario',
};

var salaAtual = 'praca';
var inventario = <String>[];
var salasVisitadas = <String>{};

void exibirSala() {
  var sala = salas[salaAtual] ?? {};
  var descricao = sala['descricao'] as String?;
  var saidasMap = sala['saidas'] as Map<String, String>?;
  var itensNaSala = sala['itens'] as List<String>?;

  var primeira = !salasVisitadas.contains(salaAtual);
  if (primeira) salasVisitadas.add(salaAtual);

  print('');
  print('╔══════════════════════════════════════╗');
  if (primeira) {
    print('║  ** Lugar novo! **                   ║');
  }
  for (var linha in (descricao ?? '').split('\n')) {
    print('║  $linha');
    print('║');
  }
  print('╠══════════════════════════════════════╣');

  var saidasTexto = saidasMap?.keys.map((d) => '[$d]').join(' ') ?? 'Sem saídas';
  print('║  Saídas: $saidasTexto');
  print('║');

  if (itensNaSala != null && itensNaSala.isNotEmpty) {
    var itensTexto = itensNaSala.join(', ');
    print('║  No chão: $itensTexto');
    print('║');
  }

  print('╚══════════════════════════════════════╝');
}

void exibirInventario() {
  print('');
  if (inventario.isEmpty) {
    print('Sua mochila está vazia.');
  } else {
    print('Inventário:');
    for (var i = 0; i < inventario.length; i++) {
      print('  ${i + 1}. ${inventario[i]}');
    }
  }
  print('');
}

void mover(String direcao) {
  var sala = salas[salaAtual] ?? {};
  var saidasMap = sala['saidas'] as Map<String, String>?;

  if (saidasMap != null && saidasMap.containsKey(direcao)) {
    salaAtual = saidasMap[direcao] ?? salaAtual;
    print('Você vai para $direcao...');
    exibirSala();
  } else {
    print('Não há saída para $direcao.');
  }
}

void pegarItem(String nomeItem) {
  var sala = salas[salaAtual] ?? {};
  var itens = sala['itens'] as List<String>?;

  if (itens == null || itens.isEmpty) {
    print('Não há "$nomeItem" aqui.');
    return;
  }

  var encontrado = itens
      .where((item) => item.toLowerCase() == nomeItem.toLowerCase())
      .toList();

  if (encontrado.isEmpty) {
    print('Não há "$nomeItem" aqui.');
  } else {
    var item = encontrado.first;
    itens.remove(item);
    inventario.add(item);
    print('Você pegou: $item.');
  }
}

void main() {
  print('');
  print('╔══════════════════════════════════════╗');
  print('║        MASMORRA ASCII v0.2           ║');
  print('╚══════════════════════════════════════╝');

  stdout.write('\nComo devo chamá-lo? ');
  var nome = (stdin.readLineSync() ?? '').trim();
  if (nome.isEmpty) nome = 'Aventureiro';

  print('\nBem-vindo, $nome!');
  exibirSala();

  while (true) {
    stdout.write('\n> ');
    var input = (stdin.readLineSync() ?? '').trim().toLowerCase();

    if (input.isEmpty) continue;

    var partes = input.split(' ');
    var cmd = sinonimos[partes[0]] ?? partes[0];
    var argumento = partes.length > 1 ? partes.sublist(1).join(' ') : '';

    switch (cmd) {
      case 'norte' || 'sul' || 'leste' || 'oeste':
        mover(cmd);
      case 'inventario':
        exibirInventario();
      case 'pegar':
        if (argumento.isEmpty) {
          print('Pegar o quê? Use: pegar <item>');
        } else {
          pegarItem(argumento);
        }
      case 'olhar':
        exibirSala();
      case 'sair' || 'quit':
        print('\nAté a próxima aventura, $nome!');
        return;
      case 'ajuda':
        print('Comandos: norte, sul, leste, oeste, pegar <item>,');
        print('          inventario, olhar, ajuda, sair');
      default:
        print('Não entendi "$input". Digite "ajuda" para ver os comandos.');
    }
  }
}
