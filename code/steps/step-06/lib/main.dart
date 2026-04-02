import 'dart:io';

const larguraTela = 40;

final salas = <String, Map<String, dynamic>>{
  'praca': {
    'nome': 'Praça Central',
    'descricao': 'Uma fonte de pedra murmura ao centro da praça.\n'
        'Tochas iluminam três passagens que se abrem\n'
        'nas paredes de pedra.',
    'saidas': {'norte': 'corredor', 'leste': 'taverna', 'sul': 'portao'},
    'itens': <String>['Tocha', 'Chave Enferrujada']
  },
  'corredor': {
    'nome': 'Corredor Escuro',
    'descricao': 'Um corredor estreito e frio. As paredes são\n'
        'cobertas de musgo. Água pinga do teto. Algo\n'
        'se move na escuridão à frente.',
    'saidas': {'sul': 'praca', 'norte': 'armaria'},
    'itens': <String>[]
  },
  'taverna': {
    'nome': 'Taverna do Javali',
    'descricao': 'Uma taverna aconchegante. O cheiro de cerveja\n'
        'e pão fresco preenche o ar. Um velho sábio\n'
        'cochila no canto junto à lareira.',
    'saidas': {'oeste': 'praca'},
    'itens': <String>['Poção de Vida']
  },
  'portao': {
    'nome': 'Portão da Masmorra',
    'descricao': 'Um portão de ferro enorme. Além dele, escuridão\n'
        'absoluta. Correntes de ar frio sopram de dentro.\n'
        'Você sente que não está pronto... ainda.',
    'saidas': {'norte': 'praca'},
    'itens': <String>['Moeda de Ouro']
  },
  'armaria': {
    'nome': 'Armaria Abandonada',
    'descricao': 'Armas enferrujadas penduradas nas paredes.\n'
        'A maioria está inútil, mas algo brilha\n'
        'debaixo de um pano rasgado.',
    'saidas': {'sul': 'corredor'},
    'itens': <String>['Adaga', 'Escudo de Madeira']
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
  'p': 'pegar',
};

var nomeJogador = 'Aventureiro';
var salaAtual = 'praca';
var inventario = <String>[];
var salasVisitadas = <String>{};
var ouro = 0;
var hp = 100;
var maxHp = 100;

String centralizar(String texto, int largura) {
  if (texto.length >= largura) return texto;
  var espacos = largura - texto.length;
  var esquerda = espacos ~/ 2;
  return texto.padLeft(texto.length + esquerda).padRight(largura);
}

String barraHP(int atual, int maximo, {int largura = 15}) {
  var prop = atual / maximo;
  var cheios = (prop * largura).round();
  var vazios = largura - cheios;
  return '${'█' * cheios}${'░' * vazios} $atual/$maximo';
}

void exibirHUD() {
  var l = larguraTela;
  print('╔${'═' * l}╗');
  print('║${'  $nomeJogador'.padRight(l)}║');
  print('║${'  HP: ${barraHP(hp, maxHp)}'.padRight(l)}║');
  print('║${'  Ouro: ${ouro}g'.padRight(l)}║');
  print('╚${'═' * l}╝');
}

void exibirSala() {
  var sala = salas[salaAtual]!;
  var nome = sala['nome'] as String;
  var descricao = sala['descricao'] as String;
  var saidas = sala['saidas'] as Map<String, String>;
  var itens = sala['itens'] as List<String>;

  var primeira = !salasVisitadas.contains(salaAtual);
  if (primeira) salasVisitadas.add(salaAtual);

  print('');
  var l = larguraTela;
  print('╔${'═' * l}╗');
  if (primeira) {
    print('║${centralizar('★ Lugar novo! ★', l)}║');
  }
  print('║${centralizar(nome.toUpperCase(), l)}║');
  print('╠${'═' * l}╣');

  for (var linha in descricao.split('\n')) {
    print('║${'  $linha'.padRight(l)}║');
  }

  print('╠${'─' * l}╣');

  var saidasTexto = saidas.keys.map((d) => '[$d]').join(' ');
  print('║${'  Saídas: $saidasTexto'.padRight(l)}║');

  if (itens.isNotEmpty) {
    print('║${'  No chão: ${itens.join(', ')}'.padRight(l)}║');
  }

  print('╚${'═' * l}╝');
}

void exibirInventario() {
  print('');
  if (inventario.isEmpty) {
    print('Sua mochila está vazia.');
  } else {
    print('╔${'═' * larguraTela}╗');
    print('║${centralizar('INVENTÁRIO', larguraTela)}║');
    print('╠${'═' * larguraTela}╣');
    for (var i = 0; i < inventario.length; i++) {
      print('║${'  ${i + 1}. ${inventario[i]}'.padRight(larguraTela)}║');
    }
    print('╚${'═' * larguraTela}╝');
  }
}

void mover(String direcao) {
  var sala = salas[salaAtual]!;
  var saidas = sala['saidas'] as Map<String, String>;

  if (!saidas.containsKey(direcao)) {
    print('Não há saída para $direcao.');
    return;
  }

  salaAtual = saidas[direcao]!;
  print('Você vai para $direcao...');
  exibirSala();
}

void pegarItem(String nomeItem) {
  var sala = salas[salaAtual]!;
  var itens = sala['itens'] as List<String>;

  var encontrado = itens
      .where((item) =>
          item.toLowerCase().contains(nomeItem.toLowerCase()))
      .toList();

  if (encontrado.isEmpty) {
    print('Não há "$nomeItem" aqui.');
    return;
  }

  if (inventario.length >= 10) {
    print('Mochila cheia! Largue algo primeiro.');
    return;
  }

  var item = encontrado.first;
  itens.remove(item);
  inventario.add(item);

  if (item == 'Moeda de Ouro') {
    inventario.remove(item);
    ouro += 10;
    print('Você pegou $item e ganhou 10g! (Total: ${ouro}g)');
  } else {
    print('Você pegou: $item.');
  }
}

void largarItem(String nomeItem) {
  var encontrado = inventario
      .where((item) =>
          item.toLowerCase().contains(nomeItem.toLowerCase()))
      .toList();

  if (encontrado.isEmpty) {
    print('Você não tem "$nomeItem".');
    return;
  }

  var item = encontrado.first;
  inventario.remove(item);
  var sala = salas[salaAtual]!;
  (sala['itens'] as List<String>).add(item);
  print('Você largou: $item.');
}

void main() {
  print('');
  print('╔${'═' * larguraTela}╗');
  print('║${centralizar('M A S M O R R A   A S C I I', larguraTela)}║');
  print('║${centralizar('v0.2.0', larguraTela)}║');
  print('╚${'═' * larguraTela}╝');
  print('');

  stdout.write('Como devo chamá-lo? ');
  nomeJogador = (stdin.readLineSync() ?? '').trim();
  if (nomeJogador.isEmpty) nomeJogador = 'Aventureiro';

  print('\nBem-vindo, $nomeJogador! Sua aventura começa agora.\n');

  exibirHUD();
  exibirSala();

  while (true) {
    print('');
    stdout.write('> ');
    var input = (stdin.readLineSync() ?? '').trim().toLowerCase();

    if (input.isEmpty) continue;

    var partes = input.split(' ');
    var cmd = sinonimos[partes[0]] ?? partes[0];
    var argumento =
        partes.length > 1 ? partes.sublist(1).join(' ') : '';

    switch (cmd) {
      case 'norte' || 'sul' || 'leste' || 'oeste':
        mover(cmd);

      case 'pegar':
        if (argumento.isEmpty) {
          print('Pegar o quê? Use: pegar <item>');
        } else {
          pegarItem(argumento);
        }

      case 'largar':
        if (argumento.isEmpty) {
          print('Largar o quê? Use: largar <item>');
        } else {
          largarItem(argumento);
        }

      case 'inventario':
        exibirInventario();

      case 'olhar':
        exibirSala();

      case 'status':
        exibirHUD();

      case 'ajuda':
        print('');
        print('Comandos disponíveis:');
        print('  norte/sul/leste/oeste (n/s/l/o), mover');
        print('  pegar <item> (p), pegar item do chão');
        print('  largar <item>, largar item no chão');
        print('  inventario (i), ver mochila');
        print('  olhar, ver sala atual');
        print('  status, ver HP e ouro');
        print('  ajuda (h/?), esta mensagem');
        print('  sair (q), encerrar o jogo');

      case 'sair' || 'quit':
        print('');
        print('╔${'═' * larguraTela}╗');
        print('║${centralizar('Até a próxima aventura!', larguraTela)}║');
        print('╚${'═' * larguraTela}╝');
        return;

      default:
        print('Não entendi "$input". Digite "ajuda" para ver os comandos.');
    }
  }
}
