/// Capítulo 8 - Classes: dando vida ao jogador
/// Boss Final 8.5 - Classe MundoTexto (Gerenciador de mundo)
///
/// Implementa um gerenciador de mundo que encapsula salas e oferece
/// métodos para navegação, consulta e análise do mapa.

import 'dart:io';

// ══════════════════════════════════════
// CLASSES DE DOMÍNIO
// ══════════════════════════════════════

class Sala {
  final String id;
  final String nome;
  final String descricao;
  final Map<String, String> saidas;
  final List<String> itens;

  Sala({
    required this.id,
    required this.nome,
    required this.descricao,
    Map<String, String>? saidas,
    List<String>? itens,
  })  : saidas = saidas ?? {},
        itens = itens ?? [];

  bool temSaida(String direcao) => saidas.containsKey(direcao);
  String? saidaPara(String direcao) => saidas[direcao];
  bool get temItens => itens.isNotEmpty;

  @override
  String toString() =>
      'Sala($nome, saídas: [${saidas.keys.join(", ")}], itens: ${itens.length})';
}

// ══════════════════════════════════════
// GERENCIADOR DE MUNDO
// ══════════════════════════════════════

class MundoTexto {
  final Map<String, Sala> salas;

  MundoTexto({required this.salas});

  /// Obtém uma sala pelo ID
  Sala? obterSala(String id) => salas[id];

  /// Adiciona uma sala ao mundo
  void adicionarSala(Sala sala) {
    salas[sala.id] = sala;
  }

  /// Retorna lista de salas conectadas diretamente a partir de um ID
  List<String> salasConectadas(String id) {
    final sala = obterSala(id);
    if (sala == null) return [];
    return sala.saidas.values.toList();
  }

  /// Retorna todos os IDs de salas do mundo
  List<String> todasAsSalas() => salas.keys.toList();

  /// Verifica se existe uma saída em determinada direção
  bool temSaida(String salaId, String direcao) {
    final sala = obterSala(salaId);
    return sala?.temSaida(direcao) ?? false;
  }

  /// Navega para uma direção específica, retornando o ID da nova sala
  String? irParaDirecao(String salaId, String direcao) {
    final sala = obterSala(salaId);
    return sala?.saidaPara(direcao);
  }

  /// Exibe um mapa visual simples mostrando adjacências
  void exibirMapa() {
    print('\n╔ MAPA DO MUNDO ╗');
    print('');
    for (final sala in salas.values) {
      print('📍 ${sala.nome} (${sala.id})');
      if (sala.saidas.isEmpty) {
        print('   └─ Sem saídas');
      } else {
        for (final (direcao, destino) in sala.saidas.entries) {
          print('   ├─ [$direcao] → ${salas[destino]?.nome ?? destino}');
        }
      }
      if (sala.temItens) {
        print('   └─ Itens: ${sala.itens.join(", ")}');
      }
      print('');
    }
  }

  /// Retorna caminho mais curto entre duas salas (BFS simplificado)
  List<String> encontrarCaminho(String origem, String destino) {
    if (origem == destino) return [origem];

    final visitadas = <String>{};
    final fila = <List<String>>[
      [origem]
    ];
    visitadas.add(origem);

    while (fila.isNotEmpty) {
      final caminho = fila.removeAt(0);
      final atual = caminho.last;

      final sala = obterSala(atual);
      if (sala == null) continue;

      for (final proximaId in sala.saidas.values) {
        if (proximaId == destino) {
          return [...caminho, proximaId];
        }

        if (!visitadas.contains(proximaId)) {
          visitadas.add(proximaId);
          fila.add([...caminho, proximaId]);
        }
      }
    }

    return [];
  }

  /// Conta total de itens no mundo
  int contarItens() => salas.values.fold(0, (sum, sala) => sum + sala.itens.length);
}

// ══════════════════════════════════════
// CRIAÇÃO DO MUNDO
// ══════════════════════════════════════

MundoTexto criarMundo() {
  final salas = {
    'praca': Sala(
      id: 'praca',
      nome: 'Praça Central',
      descricao: 'Uma fonte de pedra murmura. Tochas iluminam passagens.',
      saidas: {
        'norte': 'corredor',
        'leste': 'taverna',
        'sul': 'portao',
      },
      itens: ['Tocha', 'Chave Enferrujada'],
    ),
    'corredor': Sala(
      id: 'corredor',
      nome: 'Corredor Escuro',
      descricao: 'Frio e úmido. Água pinga do teto.',
      saidas: {
        'sul': 'praca',
        'norte': 'armaria',
      },
      itens: [],
    ),
    'armaria': Sala(
      id: 'armaria',
      nome: 'Armaria Abandonada',
      descricao: 'Armas enferrujadas penduradas nas paredes.',
      saidas: {
        'sul': 'corredor',
      },
      itens: ['Adaga', 'Escudo de Madeira'],
    ),
    'taverna': Sala(
      id: 'taverna',
      nome: 'Taverna do Javali',
      descricao: 'Aconchegante, com cheiro de cerveja e pão fresco.',
      saidas: {
        'oeste': 'praca',
      },
      itens: ['Poção de Vida'],
    ),
    'portao': Sala(
      id: 'portao',
      nome: 'Portão da Masmorra',
      descricao: 'Um portão de ferro enorme. Escuridão além dele.',
      saidas: {
        'norte': 'praca',
      },
      itens: ['Moeda de Ouro'],
    ),
  };

  return MundoTexto(salas: salas);
}

// ══════════════════════════════════════
// ESTADO DO JOGO
// ══════════════════════════════════════

late MundoTexto mundo;
var nomeJogador = 'Aventureiro';
var salaAtual = 'praca';
var inventario = <String>[];
var turno = 0;

// ══════════════════════════════════════
// FUNÇÕES DE JOGO
// ══════════════════════════════════════

void exibirSalaAtual() {
  final sala = mundo.obterSala(salaAtual);
  if (sala == null) {
    print('Sala não encontrada!');
    return;
  }

  print('');
  print('═══════════════════════════════════');
  print(sala.nome.toUpperCase());
  print('═══════════════════════════════════');
  print(sala.descricao);
  print('');

  if (sala.temItens) {
    print('📦 No chão: ${sala.itens.join(", ")}');
  }

  final saidasTexto = sala.saidas.keys.map((d) => '[$d]').join(' ');
  print('🚪 Saídas: $saidasTexto');
  print('');
}

void mover(String direcao) {
  if (!mundo.temSaida(salaAtual, direcao)) {
    print('❌ Não há saída para $direcao.');
    return;
  }

  final novaSala = mundo.irParaDirecao(salaAtual, direcao);
  if (novaSala != null) {
    salaAtual = novaSala;
    turno++;
    print('✈️  Você vai para $direcao...');
    exibirSalaAtual();
  }
}

void pegarItem(String nomeItem) {
  final sala = mundo.obterSala(salaAtual);
  if (sala == null) return;

  final encontrado = sala.itens
      .where((item) => item.toLowerCase().contains(nomeItem.toLowerCase()))
      .toList();

  if (encontrado.isEmpty) {
    print('❌ Não há "$nomeItem" aqui.');
    return;
  }

  if (inventario.length >= 5) {
    print('❌ Mochila cheia! (Limite: 5 itens)');
    return;
  }

  final item = encontrado.first;
  sala.itens.remove(item);
  inventario.add(item);
  print('✅ Você pegou: $item.');
  turno++;
}

void exibirInventario() {
  print('');
  print('📦 INVENTÁRIO:');
  if (inventario.isEmpty) {
    print('   Vazio');
  } else {
    for (var i = 0; i < inventario.length; i++) {
      print('   ${i + 1}. ${inventario[i]}');
    }
  }
  print('');
}

void exibirInfo() {
  print('');
  print('ℹ️  INFORMAÇÕES:');
  print('   Jogador: $nomeJogador');
  print('   Sala Atual: ${mundo.obterSala(salaAtual)?.nome}');
  print('   Turnos: $turno');
  print('   Itens no inventário: ${inventario.length}/5');
  print('   Total de itens no mundo: ${mundo.contarItens()}');
  print('');
}

void exibirComandos() {
  print('');
  print('📋 COMANDOS:');
  print('   mover [direção] - norte, sul, leste, oeste');
  print('   pegar [item]    - pegar item da sala');
  print('   inventario      - ver mochila');
  print('   mapa            - mostrar mapa do mundo');
  print('   info            - ver informações');
  print('   caminho [sala]  - encontrar caminho para sala');
  print('   sair            - encerrar jogo');
  print('');
}

// ══════════════════════════════════════
// GAME LOOP
// ══════════════════════════════════════

void main() {
  mundo = criarMundo();

  print('');
  print('╔════════════════════════════════════╗');
  print('║    MASMORRA ASCII - Exploração     ║');
  print('║          com MundoTexto            ║');
  print('╚════════════════════════════════════╝');
  print('');

  stdout.write('Seu nome, aventureiro? ');
  nomeJogador = (stdin.readLineSync() ?? '').trim();
  if (nomeJogador.isEmpty) nomeJogador = 'Aventureiro';

  print('\nBem-vindo, $nomeJogador!\n');
  exibirSalaAtual();
  exibirComandos();

  while (true) {
    stdout.write('> ');
    var input = (stdin.readLineSync() ?? '').trim().toLowerCase();

    if (input.isEmpty) continue;

    var partes = input.split(RegExp(r'\s+'));
    var cmd = partes[0];
    var arg = partes.length > 1 ? partes.sublist(1).join(' ') : '';

    switch (cmd) {
      case 'mover':
        if (arg.isEmpty) {
          print('❌ Para onde? Use: mover [norte|sul|leste|oeste]');
        } else {
          mover(arg);
        }

      case 'norte':
      case 'n':
        mover('norte');

      case 'sul':
      case 's':
        mover('sul');

      case 'leste':
      case 'l':
        mover('leste');

      case 'oeste':
      case 'o':
        mover('oeste');

      case 'pegar':
      case 'p':
        if (arg.isEmpty) {
          print('❌ Pegar o quê?');
        } else {
          pegarItem(arg);
        }

      case 'inventario':
      case 'inv':
      case 'i':
        exibirInventario();

      case 'mapa':
        mundo.exibirMapa();

      case 'info':
        exibirInfo();

      case 'caminho':
        if (arg.isEmpty) {
          print('❌ Caminho para onde? Use: caminho [id_sala]');
        } else {
          final caminho = mundo.encontrarCaminho(salaAtual, arg);
          if (caminho.isEmpty) {
            print('❌ Nenhum caminho encontrado para "$arg".');
          } else {
            print('✅ Caminho: ${caminho.join(" → ")}');
          }
        }

      case 'ajuda':
      case 'help':
        exibirComandos();

      case 'sair':
      case 'quit':
        print('');
        print('Até logo, $nomeJogador!');
        print('Explorou $turno turnos. Coletou ${inventario.length} itens.');
        return;

      default:
        print('❌ Comando desconhecido: "$cmd". Use "ajuda" para ver comandos.');
    }
  }
}
