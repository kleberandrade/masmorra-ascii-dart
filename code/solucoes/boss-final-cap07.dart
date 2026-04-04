/// Capítulo 7 - O game loop, o coração do jogo
/// Boss Final 7.5 - Sistema de diálogo com NPC (Velho Sábio)
///
/// Implementa um sistema completo de diálogo com um NPC que oferece dicas
/// e desbloqueia salas secretas baseado em conversas anteriores.

import 'dart:io';

// ══════════════════════════════════════
// CONSTANTES E CONFIGURAÇÃO
// ══════════════════════════════════════

const versao = '0.3.5';
const larguraTela = 40;

// ══════════════════════════════════════
// ESTADO DO JOGO
// ══════════════════════════════════════

var nomeJogador = 'Aventureiro';
var salaAtual = 'praca';
var inventario = <String>[];
var salasVisitadas = <String>{};
var hp = 100;
var maxHp = 100;
var ouro = 0;
var turno = 0;
var conversouComVelhoSabio = false;
var descobriuDicaSecreta = false;

// ══════════════════════════════════════
// MAPA DO MUNDO
// ══════════════════════════════════════

final mundoSalas = <String, Map<String, dynamic>>{
  'praca': {
    'nome': 'Praça Central',
    'descricao': 'Uma fonte de pedra murmura. Tochas iluminam passagens.',
    'saidas': {'norte': 'corredor', 'leste': 'taverna', 'sul': 'portao'},
    'itens': <String>['Tocha', 'Chave Enferrujada']
  },
  'taverna': {
    'nome': 'Taverna do Javali',
    'descricao': 'Um velho sábio cochila perto da lareira.',
    'saidas': {'oeste': 'praca'},
    'itens': <String>['Poção de Vida']
  },
  'corredor': {
    'nome': 'Corredor Escuro',
    'descricao': 'Frio e úmido. Água pinga do teto.',
    'saidas': {'sul': 'praca'},
    'itens': <String>[]
  },
  'portao': {
    'nome': 'Portão da Masmorra',
    'descricao': 'Um portão de ferro enorme. Escuridão além dele.',
    'saidas': {'norte': 'praca', 'leste': 'camaraSecreta'},
    'itens': <String>['Moeda de Ouro']
  },
  'camaraSecreta': {
    'nome': 'Câmara Secreta',
    'descricao': 'Ouro brilha! Uma arma lendária repousa aqui.',
    'saidas': {'oeste': 'portao'},
    'itens': <String>['Espada Lendária', 'Baú de Ouro']
  }
};

// ══════════════════════════════════════
// FUNÇÕES DE RENDERIZAÇÃO
// ══════════════════════════════════════

void exibirBanner() {
  print('');
  print('╔${'═' * larguraTela}╗');
  print('║${_centralizar('M A S M O R R A   A S C I I', larguraTela)}║');
  print('║${_centralizar('v$versao', larguraTela)}║');
  print('╚${'═' * larguraTela}╝');
  print('');
}

void exibirSala() {
  var sala = mundoSalas[salaAtual]!;
  var nome = sala['nome'] as String;
  var descricao = sala['descricao'] as String;
  var saidas = sala['saidas'] as Map<String, String>;
  var itens = sala['itens'] as List<String>;

  var primeira = !salasVisitadas.contains(salaAtual);
  if (primeira) {
    salasVisitadas.add(salaAtual);
    print('');
    print('★ Lugar novo! ★');
  }
  print(nome.toUpperCase());
  print('  $descricao');

  var saidasTexto = saidas.keys.map((d) => '[$d]').join(' ');
  print('Saídas: $saidasTexto');

  if (itens.isNotEmpty) {
    print('No chão: ${itens.join(', ')}');
  }
  print('');
}

void exibirInventario() {
  print('');
  if (inventario.isEmpty) {
    print('Sua mochila está vazia.');
  } else {
    print('INVENTÁRIO:');
    for (var i = 0; i < inventario.length; i++) {
      print('  ${i + 1}. ${inventario[i]}');
    }
  }
  print('');
}

String _centralizar(String texto, int largura) {
  if (texto.length >= largura) return texto;
  var espacos = largura - texto.length;
  var esquerda = espacos ~/ 2;
  return texto.padLeft(texto.length + esquerda).padRight(largura);
}

// ══════════════════════════════════════
// DIÁLOGO COM VELHO SÁBIO
// ══════════════════════════════════════

void iniciarDialogoVelhoSabio() {
  print('');
  print('O Velho Sábio abre os olhos lentamente.');
  print('');
  print('Velho Sábio: "Ah, um aventureiro! Qual é sua maior virtude?"');
  print('');
  print('1. Coragem - "Enfrento perigos de frente!"');
  print('2. Sabedoria - "Conheço os segredos antigos."');
  print('3. Justiça - "Luto pelo que é certo."');
  print('');

  stdout.write('Escolha (1-3): ');
  var escolha = stdin.readLineSync() ?? '1';

  print('');
  switch (escolha.trim()) {
    case '1':
      print('Velho Sábio: "Coragem! Um traço nobre.');
      print('Ouça bem: existe uma câmara secreta além do portão.');
      print('A Chave Enferrujada abrirá seus mistérios..."');
      descobriuDicaSecreta = true;
      break;
    case '2':
      print('Velho Sábio: "Sabedoria! Rara de se encontrar.');
      print('Ouça bem: existe uma câmara secreta além do portão.');
      print('A Chave Enferrujada abrirá seus mistérios..."');
      descobriuDicaSecreta = true;
      break;
    case '3':
      print('Velho Sábio: "Justiça! Um caminho árduo.');
      print('Ouça bem: existe uma câmara secreta além do portão.');
      print('A Chave Enferrujada abrirá seus mistérios..."');
      descobriuDicaSecreta = true;
      break;
    default:
      print('O Velho Sábio observa você com confusão.');
  }

  print('');
  conversouComVelhoSabio = true;
  turno++;
}

void verificarAcessoCamaraSecreta() {
  if (descobriuDicaSecreta && inventario.contains('Chave Enferrujada')) {
    print('A Chave Enferrujada brilha! Uma passagem secreta se abre!');
    var sala = mundoSalas['portao']!;
    var saidas = sala['saidas'] as Map<String, String>;
    if (!saidas.containsKey('leste')) {
      saidas['leste'] = 'camaraSecreta';
      print('Você agora pode entrar: [leste] - Câmara Secreta');
    }
  }
}

// ══════════════════════════════════════
// COMANDOS DO JOGO
// ══════════════════════════════════════

void mover(String direcao) {
  var sala = mundoSalas[salaAtual]!;
  var saidas = sala['saidas'] as Map<String, String>;

  if (!saidas.containsKey(direcao)) {
    print('Não há saída para $direcao.');
    return;
  }

  salaAtual = saidas[direcao]!;
  turno++;
  print('Você vai para $direcao...');
  exibirSala();

  if (salaAtual == 'portao') {
    verificarAcessoCamaraSecreta();
  }
}

void pegarItem(String nomeItem) {
  var sala = mundoSalas[salaAtual]!;
  var itens = sala['itens'] as List<String>;

  var encontrado = itens
      .where((item) => item.toLowerCase().contains(nomeItem.toLowerCase()))
      .toList();

  if (encontrado.isEmpty) {
    print('Não há "$nomeItem" aqui.');
    return;
  }

  if (inventario.length >= 10) {
    print('Mochila cheia!');
    return;
  }

  var item = encontrado.first;
  itens.remove(item);
  inventario.add(item);
  print('Você pegou: $item.');
  turno++;
}

// ══════════════════════════════════════
// GAME LOOP
// ══════════════════════════════════════

void main() {
  exibirBanner();

  stdout.write('Como devo chamá-lo? ');
  nomeJogador = (stdin.readLineSync() ?? '').trim();
  if (nomeJogador.isEmpty) nomeJogador = 'Aventureiro';

  print('\nBem-vindo, $nomeJogador!\n');

  exibirSala();

  while (true) {
    stdout.write('Turno $turno > ');
    var input = (stdin.readLineSync() ?? '').trim().toLowerCase();

    if (input.isEmpty) continue;

    var partes = input.split(' ');
    var cmd = partes[0];
    var arg = partes.length > 1 ? partes.sublist(1).join(' ') : '';

    switch (cmd) {
      case 'norte' || 'n' || 'sul' || 's' || 'leste' || 'l' || 'oeste' || 'o':
        var direcao = cmd == 'n' || cmd == 'norte'
            ? 'norte'
            : cmd == 's' || cmd == 'sul'
                ? 'sul'
                : cmd == 'l' || cmd == 'leste'
                    ? 'leste'
                    : 'oeste';
        mover(direcao);

      case 'pegar' || 'p':
        if (arg.isEmpty) {
          print('Pegar o quê?');
        } else {
          pegarItem(arg);
        }

      case 'inventario' || 'i':
        exibirInventario();

      case 'falar':
        if (salaAtual == 'taverna') {
          iniciarDialogoVelhoSabio();
        } else {
          print('Não há ninguém para falar aqui.');
        }

      case 'sair' || 'quit':
        print(
            '\nAté logo, $nomeJogador! Durou $turno turnos e conquistou ${ouro}g.');
        return;

      default:
        print('Comando desconhecido: "$cmd"');
    }
  }
}
