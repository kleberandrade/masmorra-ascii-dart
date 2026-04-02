import 'dart:math';

class Jogador {
  String nome;
  int hpMax;
  int hpAtual;
  int ataque;
  int defesa;
  int nivel;
  int xp;

  Jogador({
    required this.nome,
    required this.hpMax,
    this.ataque = 5,
    this.defesa = 1,
    this.nivel = 1,
    this.xp = 0,
  }) {
    hpAtual = hpMax;
  }

  bool get estaVivo => hpAtual > 0;

  void sofrerDano(int dano) {
    hpAtual = max(0, hpAtual - dano);
  }

  void ganharXP(int quantidade) {
    if (quantidade > 0) {
      xp += quantidade;
      if (xp >= 100) {
        nivel++;
        xp -= 100;
      }
    }
  }
}
