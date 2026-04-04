enum EstadoJogo {
  exploracao,
  combate,
  inventario,
  transicaoAndar,
  gameOver,
  vitoria,
}

class GerenciadorEstado {
  EstadoJogo estadoAtual = EstadoJogo.exploracao;

  void transicionar(EstadoJogo novoEstado) {
    // ignore: avoid_print
    print('Transição: ${estadoAtual.name} → ${novoEstado.name}');
    estadoAtual = novoEstado;
  }

  bool podeMovimentar() {
    return estadoAtual == EstadoJogo.exploracao;
  }

  bool podeAberturaInventario() {
    return estadoAtual == EstadoJogo.exploracao ||
        estadoAtual == EstadoJogo.inventario;
  }
}
