import 'dart:math';
import '../padroes/estado_ia.dart';

class Inimigo {
  String nome;
  int hpMax;
  int hpAtual;
  int ataque;
  int defesa;
  late EstadoIA estado;

  Inimigo({
    required this.nome,
    required this.hpMax,
    this.ataque = 3,
    this.defesa = 0,
    required this.estado,
  }) : hpAtual = hpMax;

  bool get estaVivo => hpAtual > 0;

  void sofrerDano(int dano) {
    hpAtual = max(0, hpAtual - dano);
  }

  void executarTurno(dynamic alvo, dynamic mapa) {
    var novoEstado = estado.atualizar(this, alvo, mapa);
    if (novoEstado != null) {
      print('$nome muda para ${novoEstado.nome}');
      estado = novoEstado;
    }

    var acao = estado.agir(this, alvo, mapa);
    acao.executar();
  }

  String obterProximaAcao(dynamic alvo, dynamic mapa) {
    var acao = estado.agir(this, alvo, mapa);
    return acao.descricao;
  }
}
