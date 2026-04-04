import 'dart:math';

/// Representa o jogador no jogo com serialização JSON
class Jogador {
  String nome;
  int hpMax;
  int hpAtual;
  int ataque;
  int defesa;
  int nivel;
  int xp;
  List<String> inventario;

  Jogador({
    required this.nome,
    required this.hpMax,
    this.ataque = 5,
    this.defesa = 1,
    this.nivel = 1,
    this.xp = 0,
    this.inventario = const [],
  }) : hpAtual = hpMax;

  /// Verifica se o jogador está vivo
  bool get estaVivo => hpAtual > 0;

  /// Aplica dano ao jogador
  void sofrerDano(int dano) {
    hpAtual = max(0, hpAtual - dano);
  }

  /// Cura o jogador
  void curar(int quantia) {
    hpAtual = min(hpMax, hpAtual + quantia);
  }

  /// Ganha XP (não pode ser negativo)
  void ganharXP(int quantidade) {
    if (quantidade > 0) {
      xp += quantidade;
      _verificarSubidaNivel();
    }
  }

  /// Verifica se deve subir de nível
  void _verificarSubidaNivel() {
    int xpPorNivel = 100;
    int nivelAtual = (xp ~/ xpPorNivel) + 1;

    if (nivelAtual > nivel) {
      nivel = nivelAtual;
      hpMax += 10;
      curar(10);
      ataque += 1;
    }
  }

  /// Adiciona item ao inventário
  void adicionarItem(String item) {
    inventario = [...inventario, item];
  }

  /// Remove item do inventário
  bool removerItem(String item) {
    if (inventario.contains(item)) {
      inventario = inventario.where((i) => i != item).toList();
      return true;
    }
    return false;
  }

  /// Converte para Map para JSON
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'hpMax': hpMax,
      'hpAtual': hpAtual,
      'ataque': ataque,
      'defesa': defesa,
      'nivel': nivel,
      'xp': xp,
      'inventario': inventario,
    };
  }

  /// Cria Jogador a partir de Map (JSON)
  factory Jogador.fromJson(Map<String, dynamic> json) {
    return Jogador(
      nome: json['nome'] as String,
      hpMax: json['hpMax'] as int,
      ataque: json['ataque'] as int,
      defesa: json['defesa'] as int,
      nivel: json['nivel'] as int,
      xp: json['xp'] as int,
      inventario: List<String>.from(json['inventario'] as List? ?? []),
    );
  }
}
