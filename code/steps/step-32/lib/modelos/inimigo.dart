import 'dart:math';

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
  }) {
    hpAtual = hpMax;
  }

  bool get estaVivo => hpAtual > 0;

  void sofrerDano(int dano) {
    hpAtual = max(0, hpAtual - dano);
  }

  void curar(int quantia) {
    hpAtual = min(hpMax, hpAtual + quantia);
  }

  void aumentarAtaque(int quantidade) {
    if (quantidade > 0) {
      ataque += quantidade;
    }
  }

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
