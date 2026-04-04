import 'dart:math';

/// Representa um inimigo no jogo com serialização JSON
class Inimigo {
  String nome;
  int hpMax;
  int hpAtual;
  int ataque;
  int defesa;
  int xpRecompensa;
  int ouroRecompensa;

  Inimigo({
    required this.nome,
    required this.hpMax,
    this.ataque = 3,
    this.defesa = 0,
    this.xpRecompensa = 50,
    this.ouroRecompensa = 25,
  }) : hpAtual = hpMax;

  /// Verifica se o inimigo está vivo
  bool get estaVivo => hpAtual > 0;

  /// Aplica dano ao inimigo
  void sofrerDano(int dano) {
    hpAtual = max(0, hpAtual - dano);
  }

  /// Recupera HP
  void curar(int quantia) {
    hpAtual = min(hpMax, hpAtual + quantia);
  }

  /// Aumenta permanentemente o ataque
  void aumentarAtaque(int quantidade) {
    if (quantidade > 0) {
      ataque += quantidade;
    }
  }

  /// Converte para Map para JSON
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'hpMax': hpMax,
      'hpAtual': hpAtual,
      'ataque': ataque,
      'defesa': defesa,
      'xpRecompensa': xpRecompensa,
      'ouroRecompensa': ouroRecompensa,
    };
  }

  /// Cria Inimigo a partir de Map (JSON)
  factory Inimigo.fromJson(Map<String, dynamic> json) {
    return Inimigo(
      nome: json['nome'] as String,
      hpMax: json['hpMax'] as int,
      ataque: json['ataque'] as int,
      defesa: json['defesa'] as int,
      xpRecompensa: json['xpRecompensa'] as int,
      ouroRecompensa: json['ouroRecompensa'] as int,
    );
  }
}
