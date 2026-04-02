import 'dart:math';
import '../padroes/estado_ia.dart';

class Inimigo {
  String nome;
  int hpMax;
  int hpAtual;
  int ataque;
  int defesa;
  EstadoIA estadoAtual;

  Inimigo({
    required this.nome,
    required this.hpMax,
    this.ataque = 3,
    this.defesa = 0,
    required this.estadoAtual,
  }) {
    hpAtual = hpMax;
  }

  bool get estaVivo => hpAtual > 0;

  void sofrerDano(int dano) {
    hpAtual = max(0, hpAtual - dano);
  }

  void atualizarEstado(dynamic alvo, dynamic mapa) {
    var novoEstado = estadoAtual.atualizar(this, alvo, mapa);
    if (novoEstado != null) {
      estadoAtual = novoEstado;
    }
  }

  String obterProximaAcao(dynamic alvo, dynamic mapa) {
    atualizarEstado(alvo, mapa);
    return estadoAtual.agir(this, alvo, mapa).descricao;
  }
}
