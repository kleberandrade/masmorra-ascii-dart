import 'dart:math';
import '../padroes/estrategia_ia.dart';

class Inimigo {
  String nome;
  int hpMax;
  int hpAtual;
  int ataque;
  int defesa;
  EstrategiaIA estrategia;

  Inimigo({
    required this.nome,
    required this.hpMax,
    this.ataque = 3,
    this.defesa = 0,
    required this.estrategia,
  }) {
    hpAtual = hpMax;
  }

  bool get estaVivo => hpAtual > 0;

  void sofrerDano(int dano) {
    hpAtual = max(0, hpAtual - dano);
  }

  void obterProximaAcao(dynamic alvo, dynamic mapa) {
    estrategia.decidir(this, alvo, mapa);
  }
}
