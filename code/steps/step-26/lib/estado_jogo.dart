/// Estados possíveis do jogo
enum EstadoJogo {
  menuPrincipal,
  explorando,
  combatendo,
  naLoja,
  subindoNivel,
  pausado,
  vitoria,
  derrota,
}

/// Gerencia o estado global do jogo
class GerenciadorEstadoJogo {
  EstadoJogo estadoAtual = EstadoJogo.menuPrincipal;
  EstadoJogo estadoAnterior = EstadoJogo.menuPrincipal;

  void mudarPara(EstadoJogo novoEstado) {
    estadoAnterior = estadoAtual;
    estadoAtual = novoEstado;
    print('\n→ Estado: ${estadoAtual.name}');
  }

  void voltarPara() {
    final temp = estadoAtual;
    estadoAtual = estadoAnterior;
    estadoAnterior = temp;
  }

  bool em(EstadoJogo estado) => estadoAtual == estado;
}
