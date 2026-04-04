import 'dart:math';
import '../padroes/estrategia_ia.dart';
import '../padroes/acao.dart';

class Inimigo {
  String nome;
  int hpMax;
  int hpAtual;
  int ataque;
  int defesa;
  EstrategiaIa estrategia;
  int x;
  int y;

  Inimigo({
    required this.nome,
    required this.hpMax,
    this.ataque = 3,
    this.defesa = 0,
    required this.estrategia,
    this.x = 0,
    this.y = 0,
  }) : hpAtual = hpMax;

  bool get estaVivo => hpAtual > 0;

  void sofrerDano(int dano) {
    hpAtual = max(0, hpAtual - dano);
  }

  Acao obterProximaAcao(dynamic alvo, dynamic mapa) {
    return estrategia.decidir(this, alvo, mapa);
  }
}
