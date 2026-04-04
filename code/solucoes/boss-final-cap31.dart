/// Capítulo 31 - Persistência em JSON
/// Boss Final 31.5: Auto-Save Mágico
///
/// Implementa um sistema completo de auto-save que persiste o estado do jogo
/// em JSON. O jogo pode ser salvo em disco e carregado na próxima execução,
/// restaurando exatamente o estado anterior.

import 'dart:convert';
import 'dart:io';

/// Representa um item no inventário
class Item {
  String nome;
  int quantidade;

  Item({required this.nome, required this.quantidade});

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'quantidade': quantidade,
  };

  factory Item.fromJson(Map<String, dynamic> map) {
    return Item(
      nome: map['nome'] as String,
      quantidade: map['quantidade'] as int,
    );
  }
}

/// Representa o jogador com seus atributos
class Jogador {
  String nome;
  int hpMax;
  int hpAtual;
  int ataque;
  int nivel;
  int xp;
  int ouro;
  List<Item> inventario;
  int posicaoX;
  int posicaoY;

  Jogador({
    required this.nome,
    required this.hpMax,
    this.ataque = 5,
    this.nivel = 1,
    this.xp = 0,
    this.ouro = 0,
    this.inventario = const [],
    this.posicaoX = 0,
    this.posicaoY = 0,
  }) {
    hpAtual = hpMax;
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'hpMax': hpMax,
      'hpAtual': hpAtual,
      'ataque': ataque,
      'nivel': nivel,
      'xp': xp,
      'ouro': ouro,
      'inventario': inventario.map((i) => i.toJson()).toList(),
      'posicaoX': posicaoX,
      'posicaoY': posicaoY,
    };
  }

  factory Jogador.fromJson(Map<String, dynamic> map) {
    return Jogador(
      nome: map['nome'] as String,
      hpMax: map['hpMax'] as int,
      ataque: map['ataque'] as int,
      nivel: map['nivel'] as int,
      xp: map['xp'] as int,
      ouro: map['ouro'] as int,
      inventario: (map['inventario'] as List)
          .map((i) => Item.fromJson(i as Map<String, dynamic>))
          .toList(),
      posicaoX: map['posicaoX'] as int,
      posicaoY: map['posicaoY'] as int,
    );
  }

  factory Jogador.novo(String nome) {
    return Jogador(
      nome: nome,
      hpMax: 50,
      ataque: 5,
      nivel: 1,
    );
  }
}

/// Estado completo do jogo em um momento específico
class EstadoJogo {
  Jogador jogador;
  int andarAtual;
  DateTime ultimoSalva;

  EstadoJogo({
    required this.jogador,
    this.andarAtual = 1,
    DateTime? ultimoSalva,
  }) : ultimoSalva = ultimoSalva ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'jogador': jogador.toJson(),
      'andarAtual': andarAtual,
      'ultimoSalva': ultimoSalva.toIso8601String(),
    };
  }

  factory EstadoJogo.fromJson(Map<String, dynamic> map) {
    return EstadoJogo(
      jogador: Jogador.fromJson(map['jogador'] as Map<String, dynamic>),
      andarAtual: map['andarAtual'] as int,
      ultimoSalva: DateTime.parse(map['ultimoSalva'] as String),
    );
  }
}

/// Gerencia salvamentos em disco (múltiplos slots)
class GerenciadorSalve {
  static const String dirSalves = 'saves';
  static const int numSlots = 3;
  static const int slotAutoSalve = 999;

  /// Inicializa diretório de salvamentos
  static Future<void> inicializar() async {
    final dir = Directory(dirSalves);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
      print('Diretório de saves criado: $dirSalves');
    }
  }

  /// Salva estado do jogo em um slot específico
  static Future<void> salvar(EstadoJogo estado, int slot) async {
    if (slot < 0 || slot >= numSlots && slot != slotAutoSalve) {
      throw ArgumentError('Slot inválido: $slot');
    }

    final arquivo = File('$dirSalves/save_$slot.json');
    final json = jsonEncode(estado.toJson());

    try {
      await arquivo.writeAsString(json);
      print('✓ Jogo salvo no slot $slot');
    } catch (e) {
      print('✗ Erro ao salvar: $e');
      rethrow;
    }
  }

  /// Carrega estado do jogo de um slot específico
  static Future<EstadoJogo?> carregar(int slot) async {
    if (slot < 0 || slot >= numSlots && slot != slotAutoSalve) {
      throw ArgumentError('Slot inválido: $slot');
    }

    final arquivo = File('$dirSalves/save_$slot.json');

    if (!arquivo.existsSync()) {
      return null;
    }

    try {
      final json = await arquivo.readAsString();
      final map = jsonDecode(json) as Map<String, dynamic>;
      return EstadoJogo.fromJson(map);
    } catch (e) {
      print('✗ Erro ao carregar: $e');
      return null;
    }
  }

  /// Lista timestamps dos saves disponíveis
  static Future<List<DateTime?>> listarSalves() async {
    final slots = <DateTime?>[];

    for (int i = 0; i < numSlots; i++) {
      final arquivo = File('$dirSalves/save_$i.json');
      if (arquivo.existsSync()) {
        try {
          final json = await arquivo.readAsString();
          final map = jsonDecode(json) as Map<String, dynamic>;
          slots.add(DateTime.parse(map['ultimoSalva'] as String));
        } catch (_) {
          slots.add(null);
        }
      } else {
        slots.add(null);
      }
    }

    return slots;
  }
}

void main() async {
  print('╔════════════════════════════════════════════╗');
  print('║     AUTO-SAVE MÁGICO                      ║');
  print('║       Capítulo 31 - Boss Final             ║');
  print('╚════════════════════════════════════════════╝');
  print('');

  // Inicializa sistema de salvamentos
  await GerenciadorSalve.inicializar();

  // Simula novo jogo
  print('--- Iniciando novo jogo ---');
  var jogador = Jogador.novo('Aventureiro');
  var estado = EstadoJogo(jogador: jogador);

  print('Bem-vindo, ${jogador.nome}!');
  print('Você está no andar 1 com ${jogador.hpAtual}/${jogador.hpMax} HP\n');

  // Simula exploração (10 turnos)
  print('--- Explorando a masmorra (10 turnos) ---');
  for (int turno = 1; turno <= 10; turno++) {
    // Simula progresso
    estado.jogador.xp += 10;
    if (turno % 5 == 0) {
      estado.jogador.nivel++;
      print('Turno $turno: Nível aumentou para ${estado.jogador.nivel}!');
    }
    if (turno % 3 == 0) {
      estado.jogador.ouro += 50;
      print('Turno $turno: Coletou 50 de ouro');
    }

    // Auto-save a cada turno
    await GerenciadorSalve.salvar(estado, GerenciadorSalve.slotAutoSalve);
    print('Turno $turno: Auto-salvo realizado');
  }

  estado.andarAtual = 2;
  print('\nProgrediu para o andar 2!');
  print('Estado atual: Nível ${estado.jogador.nivel}, XP ${estado.jogador.xp}, Ouro ${estado.jogador.ouro}');

  // Salva em um slot numerado também
  await GerenciadorSalve.salvar(estado, 1);

  // Simula fechamento e reabertura do jogo
  print('\n--- Fechando jogo (simulado) ---');
  print('Ganhando novo jogo...');

  // Carrega do auto-save
  final carregado = await GerenciadorSalve.carregar(GerenciadorSalve.slotAutoSalve);

  if (carregado != null) {
    print('\n--- Jogo Carregado ---');
    print('Bem-vindo de volta, ${carregado.jogador.nome}!');
    print('Você estava no andar ${carregado.andarAtual}');
    print('Nível: ${carregado.jogador.nivel}');
    print('XP: ${carregado.jogador.xp}');
    print('Ouro: ${carregado.jogador.ouro}');
    print('HP: ${carregado.jogador.hpAtual}/${carregado.jogador.hpMax}');
    print('Último salvo: ${carregado.ultimoSalva}');
  } else {
    print('Erro ao carregar save');
  }
}
