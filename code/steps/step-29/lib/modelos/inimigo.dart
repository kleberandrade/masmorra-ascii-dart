import 'dart:math';

/// Representa um inimigo no jogo
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
}
